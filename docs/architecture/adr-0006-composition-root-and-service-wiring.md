# ADR-0006: Composition Root and Service Wiring

## Status
Accepted

## Date
2026-10-15

## Last Verified
2026-10-15

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
The Foundation services (sandbox, puzzle repository, event bus, config,
strings, clock, build flavour) must be created once, in a fixed order, and
reach every system without global singletons, so that each GDD's Logic ACs run
headless with fakes. One composition root scene builds a `Services` container
and injects it into feature scenes through `setup(services)`; there are **no
gameplay autoloads**, and time comes from an injectable `Clock`.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core (scene architecture) |
| **Knowledge Risk** | LOW — scenes, `Node`, `RefCounted`, `_init`, `_ready`, notifications, `Time.get_ticks_usec` are pre-4.3. 4.7 typed-return rule applies to overrides of typed virtuals |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.7 typed-return overrides), `deprecated-apis.md` (cached `@onready` references, typed signal connections), `current-best-practices.md` (`-s` scripts and autoloads, lambda capture by value); ADR-0001…0004 |
| **Post-Cutoff APIs Used** | `@abstract` (4.5) on `Clock` — probed on 4.7.2 (RefCounted base + typed abstract method + concrete subclass parse and run, 2026-10-15) |
| **Verification Required** | (0) godot-specialist probes 2026-10-15 on 4.7.2: `await` in `_ready` works and returns control at the first `await`; `setup()` before `add_child` is in place when the child's `_ready` runs; an app-level `NOTIFICATION_APPLICATION_FOCUS_OUT` sent via the SceneTree reaches a non-root child; mutual `RefCounted` references leak. (1) Real focus events on Linux and Windows (headless probe only) — first workbench build. (2) gdUnit4 — **verified 2026-10-16 at `/test-setup` (gdUnit4 v6.2.2 on 4.7.2)**: it adds **no autoloads** (no `add_autoload_singleton` / `autoload/` writes in its source; the plugin only adds `gdunit4/*` settings and editor docks; `tests/unit/test_infra/test_infra_project_settings_test.gd` asserts the project has no `autoload/` entries and passes). `scene_runner(scene: Variant)` **accepts an already set-up instance** (it adds the given `Node` to the root, which runs `_ready`); `tests/integration/test_infra/test_infra_scene_runner_test.gd` calls `setup()` first and asserts `_ready` saw the dependency — passes, and fails (exit 100) when `setup` is moved after `scene_runner`. No wrapper scene is needed. Note: the runner frees only scenes it loaded by path, so tests wrap instances in `auto_free()` (else exit 101, orphan node) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None (it wires the sandbox, repository, verifier, event bus and clock services but changes none of their decisions; see Related) |
| **Enables** | Every epic — fixes how a system receives its dependencies and how tests substitute them |
| **Blocks** | First code story of any epic (project skeleton: `src/main.tscn`, `Services`) |
| **Ordering Note** | Sets `run/main_scene` in `project.godot` when the root scene is created |

## Context

### Problem Statement
The coding standard requires dependency injection over singletons and unit-
testable public methods. ADR-0001…0004 introduced shared Foundation services,
and several GDDs require fake clocks and stubs in their ACs (Hint HS-03/04,
Dialogue RD fixtures, Playtest Log PL-03, Sandbox SB-17). Godot's idiom is
autoloads, which are globals reachable by name from anywhere. The boot order in
`architecture.md` (config → strings → bus → sandbox → repository + verifier →
progression → dialogue → workbench) must also be enforced somewhere.

### Constraints
- Nodes instantiated from scenes cannot take constructor arguments.
- The sandbox runner needs `_process` (a `Node` in the tree — ADR-0001).
- CI scripts (`tools/ci/verify_content.gd`, gdUnit4 suites) must build the
  services they need without the full game.
- One developer; the MVP has essentially one play screen plus the chapter
  list, payslip and setup prompt.

## Decision

1. **One composition root.** `src/main.tscn` (script `Main`) is the main scene.
   In `_ready()` it builds the services in boot order, awaits
   `ContentVerifier.verify_all(false)` (ADR-0003) behind a loading state, then instantiates the
   play scenes and calls `setup(services)` on each **before** `add_child`.
2. **`Services` container** — a `RefCounted` with typed fields, built once:
   ```gdscript
   class_name Services extends RefCounted
   var flavour: BuildFlavour
   var clock: Clock
   var config: GameConfig
   var strings: StringTable
   var bus: EventBus
   var sandbox: SqlSandbox
   var puzzles: PuzzleRepository
   var grader: HiddenDataGrader
   var verifier: ContentVerifier   # built after the grader: (puzzles, sandbox, grader) — ADR-0003 §4
   # feature systems (hints, progression, challenges, dialogue, manual, onboarding) added by their epics
   ```
   Node services (`SqlSandbox` with its runner, `EventBus`, the clock's focus
   listener, `PlaytestRecorder`) are children of `Main`, so they live for the
   whole run (ADR-0002: the sandbox is never freed with a request in flight).
3. **Injection rules.**
   - `RefCounted` systems take their dependencies in `_init(...)` (e.g.
     `HiddenDataGrader.new(sandbox, puzzles, bus)`).
   - Scene scripts expose `func setup(services: Services) -> void`, store what
     they need in typed fields, and pass narrower dependencies to their
     children. A scene must work with any `Services` it is given, real or fake.
   - Systems depend on the narrowest type they need (a grader receives the
     sandbox, not the whole container).
4. **No gameplay autoloads.** The project registers no autoload for game
   systems. (Tooling autoloads that addons install, e.g. gdUnit4's, are
   allowed.)
5. **Clock.**
   ```gdscript
   @abstract
   class_name Clock extends RefCounted
   @abstract func now_ms() -> float      # monotonic since session start
   @abstract func is_focused() -> bool   # application focus
   @abstract func wall_iso() -> String   # UTC ISO 8601, for the log's `wall` field (ADR-0004)
   ```
   (`@abstract` is a 4.5 feature recorded in `current-best-practices.md`; it
   avoids typed-return bodies on the base class under the 4.7 rule.)
   `RealClock` uses `Time.get_ticks_usec()` and a small `FocusListener` node
   under `Main` that tracks `NOTIFICATION_APPLICATION_FOCUS_IN/OUT`.
   `FakeClock` (tests) exposes `advance(ms)` and `set_focused(bool)`. Every
   time-based rule reads `Clock`: the hint `active_time`, Dialogue hold/reveal
   timers, the sandbox timeout watchdog, log `t_ms`. The engine's `_process`
   `delta` may drive animation only, never a rule.

   **Accumulated rule time** (e.g. hint `active_time = Σ dt × focused × shown ×
   idle`, dt clamped to 0.25 s — `hint-system.md` Formulas, HS-03/04): the
   owning system samples `Clock.now_ms()` once per tick, takes the difference
   from its previous sample as `dt`, applies the rule's clamp, and adds it only
   while the rule's conditions hold. A **tick** is one `_process` call in the
   game and one `FakeClock.advance(ms)` in tests — so "a single 2 s frame adds
   0.25 s" (HS-04) is `advance(2000)` followed by one tick. Gameplay pause
   (challenge mode, briefing, a closed request) is not a `Clock` concern: it
   comes from the owning system's state (Progression / Constraint Challenges
   signals); `Clock` reports application focus only.
6. **Tests and tools** construct only what they need: `Services` fields left
   `null` are a programming error caught at `setup` with `assert` in debug.
   gdUnit4 suites use fakes (`FakeClock`, an in-memory `LogSink`, stub
   datasets); integration suites build real services the same way `Main` does
   through a shared `ServicesFactory.build(flavour, clock)`.

### Architecture Diagram
```
main.tscn (Main) ── _ready ──► ServicesFactory.build()
  ├─ FocusListener (Node)      → RealClock
  ├─ SqlSandbox (Node, runner) ← GameConfig
  ├─ EventBus (Node)           ← Clock, PuzzleRepository (hash)
  ├─ PlaytestRecorder (Node, playtest only) ← EventBus, BuildFlavour
  │   grader = HiddenDataGrader.new(sandbox, puzzles, bus, hint_counter)
  │   verifier = ContentVerifier.new(puzzles, sandbox, grader)
  │   await verifier.verify_all(false)  (loading state)
  └─ play scenes: chapter list / workbench / payslip
       scene.setup(services) → add_child(scene)
```

### Key Interfaces
`Services` (§2), `Clock` (§5), `setup(services: Services) -> void` on every
scene script, `ServicesFactory.build(flavour, clock) -> Services`.

### Implementation Guidelines
- Must not register gameplay systems as autoloads, and must not reach a service by node path or `get_node("/root/…")`.
- Every scene script that needs a service must expose `setup(services)` and must be set up before it enters the tree.
- `RefCounted` systems must receive dependencies through `_init` arguments.
- Every rule that depends on time must read `Clock`; `Time.*` may be called only inside `RealClock` (incl. `wall_iso()` for ADR-0004's `wall` field). The CI grep checks `src/` excluding `real_clock.gd`; tests and `FakeClock` are not scanned.
- `ContentVerifier` is built by `ServicesFactory` after the grader; `PuzzleRepository` receives no upstream service (ADR-0003 §4).
- The grader's `hint_counter: Callable` (ADR-0004 §2) is bound by `ServicesFactory` once the Hint System exists; until its epic lands it is a stub returning `false`.
- **Ownership is one-way** (probed: two `RefCounted` objects referencing each other are never freed and leak at exit): `Main` / `ServicesFactory` own the services; no service holds the `Services` container; a service that must notify an upstream one does it with a signal (or a `WeakRef`), never a stored strong reference back. EventBus (a Node) may read `PuzzleRepository`; `PuzzleRepository` must not hold the bus.
- Nothing may wait on `Main.ready`: `_ready` returns at its first `await` (probed), before the services exist. Input is blocked by the loading state until `verify_all(false)` completes and the play scenes are set up.
- The `FocusListener` node (and the sandbox runner, ADR-0001) must use `process_mode = PROCESS_MODE_ALWAYS` so a paused tree does not freeze focus tracking.
- Services must be built only by `ServicesFactory` (game and integration tests share it).
- Overrides of typed engine virtuals must return on every path (4.7).
- Signals between systems must use typed `signal.connect(callable)` connections, never string-based `connect`.

## Alternatives Considered

### Alternative 1: Autoload singletons per service (Godot idiom)
- **Description**: `Sandbox`, `Puzzles`, `Events`… as autoloads used by name.
- **Pros**: Least code; idiomatic; available in `-s` scripts.
- **Cons**: Hidden global dependencies; tests cannot swap a fake clock or sink without global mutation; load order of autoloads becomes the boot order.
- **Rejection Reason**: Violates the coding standard (DI over singletons) and makes the fake-clock ACs awkward.

### Alternative 2: One `Services` autoload holding injected instances
- **Description**: A single autoload container; scenes pull from it in `_ready`.
- **Pros**: Simple; one global.
- **Cons**: Still a service locator reachable from anywhere; scenes pull instead of being given; tests must reset global state between suites.
- **Rejection Reason**: The explicit `setup(services)` costs one method per scene and keeps dependencies visible.

## Consequences

### Positive
- Every Logic AC can run headless with fakes; integration tests build the real graph the same way the game does.
- Boot order lives in one place.
- Dependencies are visible in each `setup` / `_init` signature.

### Negative
- Each scene needs a `setup` method and must be set up before `add_child`.
- New services require an edit to `Services` and `ServicesFactory`.

## Risks
- **A scene added to the tree without `setup`** (e.g. dropped into another scene in the editor). Mitigation: `assert` on null dependencies in `_ready` (debug builds).
- **Focus notifications** not reaching the listener on a platform. Mitigation: verification item above; HS-04 uses `FakeClock` regardless.

*Engine validation (godot-specialist, 2026-10-15, probed on 4.7.2): one BLOCKING finding — reference cycles between `RefCounted` services leak — resolved by the one-way ownership rule; minor notes (`Main.ready` fires early, `wall_iso()` to remove the conflict with ADR-0004's system-clock `wall`, `@abstract` Clock, gdUnit4 `scene_runner` check) folded in. TD-ADR skipped — lean mode.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| hint-system.md | `active_time` = frame time × focus × shown × idle cutoff; HS-03/04 fake clock | `Clock.now_ms()` + `is_focused()`; `FakeClock` |
| request-and-reaction-dialogue.md | Hold / reveal timers; RD fixtures with a fake clock | Timers read `Clock` |
| playtest-log.md | PL-03 monotonic `t_ms` | `Clock.now_ms()` |
| sql-execution-sandbox.md | SB-17 limit logic testable | Runner reads `Clock` (ADR-0001 guideline) |
| shift-and-chapter-progression.md | Session-only state at MVP, serialisable later | State lives in injected systems as plain data, not in autoload globals |
| all MVP GDDs | Logic ACs testable in isolation (coding standard) | Constructor / `setup` injection |

## Performance Implications
- **CPU / Memory**: negligible (one container, a few nodes).
- **Load Time**: boot shows a loading state while `verify_all(false)` runs (≈ 0.6 s for Chapter 1 at 60 fps with 6 executions in flight, ADR-0003; corrected 2026-10-15 from ≈ 0.1 s).
- **Network**: none.

## Migration Plan
No production code exists. The first code story creates `src/main.tscn`, `Services`, `ServicesFactory`, `RealClock`, `FakeClock` and sets `run/main_scene`.

## Validation Criteria
- A gdUnit4 suite builds `HiddenDataGrader` with a stub sandbox and asserts a verdict without any scene tree.
- HS-03/04 pass with `FakeClock`.
- A static check (grep in CI) finds no `/root/` node-path service lookups in `src/`.

## Related
- ADR-0001…0004 — the services wired here
- `docs/architecture/architecture.md` — boot order, Architecture Principle 4
- `.claude/docs/coding-standards.md` — DI over singletons
