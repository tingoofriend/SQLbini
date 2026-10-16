# SQLbini — Master Architecture

## Document Status

- Version: 2
- Last Updated: 2026-10-16
- Engine: Godot 4.7.2 (GDScript) + godot-sqlite v4.9 (GDExtension, `compatibility_minimum = "4.7"`)
- Workflow tier: `standard` — system layer map + critical ADR list (module ownership, data flow and API boundaries kept to what the Foundation ADRs need)
- GDDs Covered: all 11 MVP GDDs (Approved) — hidden-data-grader, puzzle-definition-and-datasets, sql-execution-sandbox, query-workbench, hint-system, constraint-challenges, shift-and-chapter-progression, request-and-reaction-dialogue, store-manual, onboarding-first-shift, playtest-log; plus `game-concept.md`, `systems-index.md`, `design/art/art-bible.md` §8 (display chain, budgets)
- ADRs Referenced: ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0006 — **Accepted** 2026-10-15 after `/architecture-review` (amended per `architecture-review-2026-10-15.md` and the 2026-10-16 re-review); ADR-0007 (tuning config, string tables, settings) and ADR-0010 (gameplay signal contracts) — **Accepted** 2026-10-16 (amended per `architecture-review-2026-10-16.md`); ADR-0005 not written (pending the Windows spike); ADR-0008, ADR-0009 planned in [Required ADRs](#required-adrs)
- Reviews: `docs/architecture/architecture-review-2026-10-16.md` (latest), `architecture-review-2026-10-15.md`; permanent requirement IDs: `docs/architecture/tr-registry.yaml` (60), matrix: `docs/architecture/requirements-traceability.md`
- Inputs carried forward: Technical Director items from `production/gate-checks/2026-10-15-systems-design-to-technical-setup.md`
- TD-ARCHITECTURE: 2026-10-15 — skipped — lean mode
- LP-FEASIBILITY: 2026-10-15 — skipped — lean mode

## Engine Knowledge Gap Summary

LLM training covers Godot up to ~4.3. Post-cutoff: 4.4, 4.5, 4.6, 4.7 (pin 4.7.2).
Every claim below is sourced from `docs/engine-reference/godot/`; anything that
file set does not cover is marked **NOT SOURCEABLE** and must be verified by a
probe before an ADR relies on it.

### HIGH risk — touched by this game

| Domain | Change (version) | Where it bites SQLbini |
|---|---|---|
| Project defaults | New projects default to stretch `canvas_items` / aspect `expand` (4.7) — set explicitly | `project.godot` already states both; viewport size 1280×720 is **missing** (ADR-0005) |
| UI / Input | Dual focus: mouse focus separate from keyboard focus; `grab_focus()` is keyboard-only (4.6) | Keyboard-first workbench (QW rule 15, F6 pane cycling, focus ring QW-20) |
| Input | Mouse/keyboard device IDs are `InputEvent.DEVICE_ID_MOUSE` / `DEVICE_ID_KEYBOARD`, not `0` (4.7) | Never compare `event.device` to 0; branch on event type |
| GDScript | Overrides of typed-return methods need an explicit return on every path (4.7) | All `_get_*` / virtual overrides in UI code |
| Accessibility | AccessKit screen-reader support (4.5); `Control.accessibility_live` type → `AccessibilityServer.AccessibilityLiveMode` (4.7) | VS Accessibility Options; QW OQ3 (does `CodeEdit` expose text to AccessKit?) |
| Rendering | D3D12 is the Windows default backend (4.6); `CanvasItem` lines lose the AA feather (4.7) | Renderer choice (ADR-0005); art bible procedural paper edges may need thicker lines |
| GUI | `RichTextLabel.add_image` units changed (4.7) | Only if the Store Manual / message log embeds images — avoid or use the new `width_unit` API |

### MEDIUM risk

| Domain | Change (version) | Where it bites |
|---|---|---|
| Core I/O | `FileAccess.store_*` return `bool` (4.4) | Playtest Log writer must check every store result (log rule 8: a failed write stops the log) |
| Core / OS | `OS.execute_with_pipe` gained optional `blocking` (4.4) | Child-process option for the sandbox timeout (ADR-0001) |
| Resources | `duplicate_deep()` for nested resources (4.5) | Only if puzzle data becomes `Resource` (ADR-0003) |

### NOT SOURCEABLE — must be probed, not assumed

- **`CodeEdit` / `TextEdit` changes 4.4–4.7**: the 4.7 migration guide lists none — that means "none listed", not "verified unchanged".
- **Threading APIs (`Thread`, `Mutex`, `Semaphore`, `WorkerThreadPool`) after 4.3**: not covered by the reference. Use only the pre-4.3 surface and verify on 4.7.2 in the ADR-0001 spike.
- **godot-sqlite thread behaviour**: third-party, not engine reference. Whether one `SQLite` object per worker thread is safe is a spike question (ADR-0001).
- **`DPITexture`** (art bible §8, already marked [UNVERIFIED]).
- **IME composition in `CodeEdit`** on Windows/Linux (QW OQ4) and **AccessKit + `CodeEdit`** (QW OQ3).
- **4.7 new features**: the 4.7 release-notes page was not sourceable; nothing here relies on a 4.7 addition.

### LOW risk (in training data, used as-is)

Signals and `Callable`, `call_deferred`, `JSON`, `FileAccess` reads, `DirAccess`,
`SubViewport` + `TextureRect`, `canvas_item` shaders, `Theme`, `OS.has_feature`
(feature tags), `Time.get_ticks_usec`, `NOTIFICATION_APPLICATION_FOCUS_IN/OUT`,
stretch `scale_mode = fractional` (4.2).

## Technical Requirements Baseline

Extracted from 11 GDDs (Detailed Rules, Formulas, Dependencies, Tuning Knobs,
Acceptance Criteria) plus the art bible's §8 constraints. **Superseded by
`docs/architecture/tr-registry.yaml`** (2026-10-15: these 44 IDs kept, 16 added,
some citations corrected) — the table below is the v1 snapshot.

| Req ID | GDD | Requirement | Domain | Planned ADR |
|---|---|---|---|---|
| TR-sandbox-001 | sandbox r.2 | Fresh in-memory DB per `query` request, destroyed after | Core | 0002 |
| TR-sandbox-002 | sandbox r.5–9 | Lexer-based statement check before execution: one statement, EMPTY, verb rules, `WITH RECURSIVE` rejected | Core | 0002 |
| TR-sandbox-003 | sandbox r.5a | `tokenize(sql) -> Array of {kind, text}` exposed to Hints and Challenges | Core | 0002 |
| TR-sandbox-004 | sandbox r.10–13 | Temp-view wrapper, column metadata for zero rows, positional rows, `fetch_limit = grader_row_cap + 1`, `truncated` | Core | 0002 |
| TR-sandbox-005 | sandbox r.15, SB-19 | Execution never on the frame thread; frame ≤ 16.6 ms during any query | Threading | 0001 |
| TR-sandbox-006 | sandbox r.15, SB-18 | `TIMEOUT` delivered within `exec_time_limit` + 50 ms; next request succeeds | Threading | 0001 |
| TR-sandbox-007 | sandbox r.16 | Result record (status, error_kind, error_text, build_message, columns, column_count, rows, truncated, rows_changed, elapsed_ms) | Core | 0002 |
| TR-sandbox-008 | sandbox r.4, r.14 | Scratch DB lifecycle (Alpha — Back Room); API must not preclude it | Core | 0002 |
| TR-sandbox-009 | sandbox SB-20 | p95 ≤ 25 ms per execution on the target PC (not yet named) | Performance | 0005 |
| TR-puzzle-001 | puzzle r.1–2 | Chapter definition (schema, base datasets, shifts) + puzzle definitions; text, diffable, data-driven | Data | 0003 |
| TR-puzzle-002 | puzzle r.5 | Dataset overrides (`add`/`remove`/`set`/`reverse`/`renumber`) resolved at load | Data | 0003 |
| TR-puzzle-003 | puzzle r.10–14 | Content verifier (`puzzle_valid`) runs identically in CI and at game load (L-04) | Data / CI | 0003 |
| TR-puzzle-004 | puzzle States | Content hash over a canonical serialisation, excluding `content_status` and the hash | Data | 0003 |
| TR-puzzle-005 | puzzle States | Runtime `loaded`/`withheld` by build flavour (dev allows all; playtest/release only verified+) | Build | 0003, 0004 |
| TR-puzzle-006 | puzzle r.3 | Target result computed from `reference_sql`, never stored | Data | 0003 |
| TR-grader-001 | grader r.5–9a | Submit pipeline: pre-check, determinism, per-dataset grading, early stop on hidden TIMEOUT, UNAVAILABLE | Core | 0002 (async contract) |
| TR-grader-002 | grader r.8 | Reference results cached per puzzle + dataset for the session | Core | 0003 |
| TR-grader-003 | grader Formulas | `canon` / `result_match` / `tie_list_eq` — pure functions, unit-testable | Core | — (GDD is the spec) |
| TR-grader-004 | grader r.11 | Missing/extra rows never reach player or Dialogue — only the log | Core | 0004 |
| TR-grader-005 | grader AC-26 | Submit p95 ≤ 300 ms, Run p95 ≤ 200 ms on the target PC | Performance | 0005 |
| TR-workbench-001 | workbench r.1–6 | `CodeEdit` editor with SQL highlighting, schema browser, result vs target tables at 1280×720 | UI | 0008 |
| TR-workbench-002 | workbench r.15 | Keyboard-first: every action has a shortcut; F6 pane cycle; focus ring | UI / Input | 0008 |
| TR-workbench-003 | workbench r.16 | IME composition committed before Run | UI / Input | 0008 |
| TR-workbench-004 | workbench Formulas | `ui_scale` 1.0–2.0 through Theme font sizes, not `content_scale_factor` | UI | 0005, 0008 |
| TR-workbench-005 | workbench r.14 | Reacts to Restart (draft, last Run result, verdict reset) | Events | 0004 |
| TR-hint-001 | hint Formulas | `active_time` from frame dt × window focus × shown × idle cutoff; fake-clock testable | Core | 0006 (clock injection) |
| TR-hint-002 | hint r.4a–4b | Distinct-query counting via `tokenize` normalization; returns `hint_counted` | Core | 0002 |
| TR-challenge-001 | CC rules | `forbid`/`require` keyword checks on `WORD` tokens; `canonical_length` for `max_chars` | Core | 0002 |
| TR-challenge-002 | CC r.9.2 | Per-challenge counter set supplied to the grader | Core | — (GDD spec) |
| TR-progression-001 | progression r.1–12a | Request/shift/chapter state machine; Restart event; session-only persistence at MVP | Core | 0006 |
| TR-progression-002 | progression r.13 | No save at MVP; VS Save/Load must be able to serialise this state | Persistence | deferred (VS) |
| TR-dialogue-001 | dialogue r.9 | String tables keyed by id; missing id → `[id]` in dev, generic line in release, logged | Data / L10n | 0007 |
| TR-dialogue-002 | dialogue Formulas | Reveal / hold timers (`reaction_hold`, `reveal_cps`), reduced motion | UI | — (GDD spec) |
| TR-dialogue-003 | art bible §8 | Counter strip: 320×30 `SubViewport`, Nearest, palette shader, integer ×k, `strip_to_ui()` | Rendering | 0009 |
| TR-manual-001 | manual r.1–4 | Page data; CI: examples never pass a puzzle, `watch_out.rule_tag` ∉ Chapter 1 `trap_rules` | Data / CI | 0003 |
| TR-onboarding-001 | onboarding r.7a | Puzzle-scoped coach marks; ghost-text CI check (OB-18) | Data / CI | 0003 |
| TR-playtest-001 | log r.3–4 | Canonical event catalogue; undeclared events rejected and counted | Events | 0004 |
| TR-playtest-002 | log r.8–9 | Append + flush per event to `user://playtest-logs/<session>.jsonl`; write failure stops the log, never gameplay | I/O | 0004 |
| TR-playtest-003 | log r.1 | Playtest flag: compiled in, disabled in release; "● Recording playtest" label | Build | 0004 |
| TR-playtest-004 | log r.7 | F9 facilitator key + note field returning focus to the editor | Input | 0004 |
| TR-playtest-005 | log r.10 | `tools/playtest-report` reads JSONL and prints the threshold table | Tools | 0004 |
| TR-platform-001 | concept / prefs | Windows + Linux desktop (Steam); godot-sqlite `.dll` must load on 4.7.2 | Platform | 0005 |
| TR-platform-002 | art bible §8.9 | Total 2D texture memory ≤ 64 MB; < 500 draw calls; 60 fps | Performance | 0005 |
| TR-config-001 | all Tuning Knobs | Every gameplay value from data files with load-time range validation (e.g. hint HS-14, sandbox SB-17) | Data | 0007 |

**Count:** 44 requirements, 0 covered (no ADRs yet). Every row has a planned ADR
or is covered by its GDD's own formulas (pure logic, no architectural decision).

## System Layer Map

```
┌──────────────────────────────────────────────────────────────────────────┐
│ PRESENTATION   WorkbenchView (CodeEdit, tables, schema shelf, strip host)│
│                CounterStrip (SubViewport + palette shader) · Bubble · Log│
│                ManualView · HintPanel · Payslip / chapter list · Coach   │
├──────────────────────────────────────────────────────────────────────────┤
│ FEATURE        HintSystem · ConstraintChallenges · ShiftProgression      │
│                DialogueDirector (+ reaction queue) · StoreManual         │
│                Onboarding · PlaytestRecorder (subscriber)                │
│                GameplayWiring (connects every gameplay signal, ADR-0010) │
├──────────────────────────────────────────────────────────────────────────┤
│ CORE           HiddenDataGrader · WorkbenchController (draft/Run/Submit) │
│                RunMatcher (visible match bit, via the grader)            │
│                ContentVerifier (separate object above the grader)        │
├──────────────────────────────────────────────────────────────────────────┤
│ FOUNDATION     SqlSandbox (+ SqlLexer, ExecutionRunner) · PuzzleRepository│
│                (loader, dataset resolver, content hash, reference cache) │
│                EventBus · GameConfig (tuning) · StringTable · Settings   │
│                Clock · InputActivity · BuildFlavour (dev/playtest/rel.)  │
├──────────────────────────────────────────────────────────────────────────┤
│ PLATFORM       Godot 4.7.2 (Forward+ today — ADR-0005) · godot-sqlite 4.9│
│                user:// filesystem · OS process/thread primitives         │
└──────────────────────────────────────────────────────────────────────────┘
```

**Why this split (balanced density).** The GDDs' layering (systems-index) is a
*design* dependency order; the architecture keeps it but makes three changes:

1. **The Query Workbench is split** into a `WorkbenchController` (Core: owns the
   draft, Run/Submit orchestration, Restart reset) and a `WorkbenchView`
   (Presentation: `CodeEdit`, tables, focus). The controller is testable without
   a scene tree; the view holds every HIGH-risk UI API (dual focus, IME, AccessKit).
2. **The Playtest Log is split** into an `EventBus` (Foundation — every system
   emits through it from day one) and a `PlaytestRecorder` (Feature-level
   subscriber that writes JSONL). The catalogue lives with the bus, so "the log
   rejects undeclared events" (log rule 4) is enforced at the emit site, not only
   in the file writer.
3. **Cross-cutting Foundation services** that no GDD owns but every GDD assumes:
   `GameConfig` (all tuning knobs + range validation), `StringTable` (dialogue
   rule 9), `Clock` (monotonic time, injectable for the fake-clock tests that the
   Hint, Dialogue and Log ACs require), and `BuildFlavour` (dev / playtest /
   release — Puzzle Definition load states and the Playtest flag both depend on it).
   ADR-0007 adds `Settings` (session player settings) and ADR-0010 adds
   `InputActivity` (hint input-activity feed) to this group.

`ContentVerifier` sits in Core, not inside `PuzzleRepository`: it is built with
`(repository, sandbox, grader)` and pushes load states and reference results into
the repository through setters, so the repository holds nothing upstream
(ADR-0003 §4, ADR-0006). `GameplayWiring` is the one function that connects
gameplay signals (ADR-0010 §1); it is listed with the Feature layer because it
runs after every feature system exists.

**Engine-risk flags for Core and Foundation**

| Module | Risk domain | Note |
|---|---|---|
| SqlSandbox / ExecutionRunner | Threading — NOT SOURCEABLE post-4.3; godot-sqlite thread behaviour unknown | ADR-0001 spike decides |
| PuzzleRepository | Core I/O (LOW for reads) | `FileAccess.get_file_as_string`, `JSON` — in training data |
| EventBus / PlaytestRecorder | Core I/O — MEDIUM (`store_*` returns `bool`, 4.4) | Check every write |
| WorkbenchController | none (pure GDScript) | — |
| HiddenDataGrader | none (pure GDScript + Sandbox) | Async because the sandbox is off-thread |

## Module Ownership

Kept to the Foundation and Core modules (standard tier). Feature and
Presentation modules follow their GDD's "Interactions" table.

| Module | Owns | Exposes | Consumes | Engine / library APIs |
|---|---|---|---|---|
| **SqlSandbox** | Statement check, DB build from a resolved dataset, temp-view wrapper, fetch, result record, execution thread/process, timeout | `execute(request) -> SqlResult` (async), `tokenize(sql)` | Resolved dataset (PuzzleRepository), `GameConfig` (`grader_row_cap`, `exec_time_limit_ms`) | godot-sqlite `SQLite` (`open_db`, `query`, `query_with_bindings`, `query_result`, `close_db`); `Thread` or `OS.create_process`/`OS.execute_with_pipe` (ADR-0001) |
| **SqlLexer** (part of Sandbox) | Token kinds `WORD, NUMBER, STRING, QUOTED_IDENT, COMMENT, PUNCT` | `tokenize`, `statement_shape(tokens)` (count, verb, recursive) | — | none (pure GDScript) |
| **PuzzleRepository** | Chapter + puzzle files, dataset resolution, content hash, load state, reference-result cache | `get_puzzle(id)`, `get_chapter(id)`, `resolve_dataset(puzzle, dataset_id)`, `reference_result(puzzle, dataset_id)`, `content_hash(puzzle)`; setters `set_load_state` / `set_reference_result` (ContentVerifier only) | `BuildFlavour`, `GameConfig` — no upstream service (ADR-0003 §4) | `FileAccess`, `JSON` (`JSON.new().parse()`) |
| **ContentVerifier** (Core, separate object) | `puzzle_valid` + chapter checks + report; CI-only manual/hint/ghost-text/challenge check modules | `verify_all(include_ci_checks) -> ContentReport` (awaitable; headless CLI + load) | PuzzleRepository (setters), Sandbox, Grader `grade()` (never `submit()`); ≤ `verify_parallelism` in flight | runs under `godot --headless -s` in CI |
| **EventBus** | Event catalogue (declared names + required fields), dispatch | `emit_event(event_name, puzzle_id: Variant, data)`, `event_recorded(record)`, `undeclared_count()` | `Clock`, `PuzzleRepository` (hash) | Signals |
| **GameConfig** | All tuning-knob values, defaults, clamps, validation errors | typed getters | data files | `FileAccess`, `JSON` |
| **StringTable** | Player-facing text by id (own table over English JSON); missing-id behaviour | `text(id, args)` (single-pass `{name}` substitution), `grapheme_len(text)` | `BuildFlavour`, `PuzzleRepository` (`puzzle:<id>:<field>` ids); missing ids reported with `push_warning` (dev) / `push_error` (others), not log events | `TextServerManager` (graphemes); **no** `tr()` / `TranslationServer` at MVP (ADR-0007 §2) |
| **Settings** | Session player settings (`ui_scale`, `reduced_motion`, `coach_marks`, `reveal_cps`) | getters, `effective_reveal_cps()`, `set_value(key, value)`, `setting_changed(key)`, `to_dict` / `from_dict` | `GameConfig` (`ConfigSchema` validation) | none (plain data, ADR-0007 §3) |
| **InputActivity** | Time of the last player input (hint `last_input_t`) | `last_input_ms() -> float` | `Clock` | `get_tree().root.window_input` (not `_input`), `PROCESS_MODE_ALWAYS` (ADR-0010 §7) |
| **Clock** | Monotonic ms, window focus state, UTC wall time (ADR-0006) | `now_ms()`, `is_focused()`, `wall_iso()` | — | `Time.get_ticks_usec`, `NOTIFICATION_APPLICATION_FOCUS_*` |
| **HiddenDataGrader** | Verdict pipeline, cause selection, per-cause counters (in the caller's set), neutral statements | `grade(puzzle, sql, counters) -> Verdict` (async, no side effects), `submit(puzzle, sql, counters) -> Verdict` (async: `grade` → `hint_counter` → `submit` event → `verdict_given`), `run_match(puzzle, result) -> bool` | Sandbox, Repository, EventBus, `hint_counter` Callable | none |
| **WorkbenchController** | Draft text per puzzle, last Run result, last verdict, "checking…" state, the main request's per-cause counter set | `run()`, `submit()`, `restart()` (the `request_restarted` handler), `draft_is_empty()` (bound as Progression's Callable); signals `run_started`, `run_finished`, `submit_started`, `draft_edited`, `line_requested` (ADR-0010 §4) | Sandbox, Grader, Progression signals (`request_shown`, `request_restarted`), EventBus | none |

```
            WorkbenchView ─────► WorkbenchController ─────► HiddenDataGrader ◄── grade() ── ContentVerifier
                 │                     │   │                     │                      │   │ setters
  Dialogue/Hint/ │                     │   └──────► SqlSandbox ◄─┴──────────────────────┘   ▼
  Challenges/    ▼                     ▼                                          PuzzleRepository
  Manual   ─► EventBus ◄──── every module            (repository holds nothing upstream)
                 │
          PlaytestRecorder            GameConfig · StringTable · Settings · Clock · InputActivity
```

## Data Flow

### Run (visible data) — the 200 ms path

```
CodeEdit ──Ctrl+Enter──► WorkbenchController.run()        [main thread]
   └─► SqlSandbox.execute({sql, dataset: visible, mode: query})
          ├─ lexer check (sync, main thread, µs)           → error result at once
          └─ build DB + view + fetch  ═══ worker/process ═══►  (crosses thread boundary)
   ◄── SqlResult (main thread: the runner's next `_process` poll completes a per-request completion object — ADR-0001 §3, ADR-0002 §4)
   ├─► Grader.run_match(puzzle, result) → bool (reference from cache)
   ├─► WorkbenchView shows table + marks + note
   ├─► run_finished(puzzle_id, result_ok, rows_match, feedback) → Dialogue
   │     (Kenji's Run-error reaction from `DialogueFeedback.from_run_result`), Onboarding
   └─► EventBus "run" {sql, dataset, ok, error_kind, rows, match}
```

If no result arrives within 200 ms, the view shows "checking…" (QW Game Feel);
`TIMEOUT` arrives by `exec_time_limit` + 50 ms.

### Submit — the 300 ms path

`WorkbenchController.submit()` → `HiddenDataGrader.submit()` → `grade()` awaits
`2 + D` sandbox executions **sequentially** (pre-check, determinism, then each
dataset; references from the cache) → `Verdict` → Hint System through the
`hint_counter` Callable (verdict + SQL, returns `hint_counted`) → EventBus
`submit` → `verdict_given` → Dialogue (`DialogueFeedback` only), Progression
(PASS / UNAVAILABLE), Constraint Challenges → `Verdict` returned to the
controller (ADR-0010 §3; no `await` after `grade()`). Missing/extra rows travel **only** inside the
`submit` event to the recorder (grader rule 11; enforced by the event's field
schema — ADR-0004). While a submit is in flight a second Run/Submit is
refused by the controller; a newer **Run** may start while an older Run is in
flight, and the older result is discarded (ADR-0002 §6). `hint_counted` comes
back through an injected `hint_counter` Callable (ADR-0004 §2).

### Event path

Every system emits through `EventBus.emit_event(event_name, puzzle_id, data)`
(`puzzle_id: Variant`, `null` when no puzzle applies). The bus validates
`event_name` against the catalogue (playtest-log rule 4), stamps `t_ms` and
`wall` (Clock) and emits `event_recorded` for the recorder. Gameplay
(Progression ← PASS, Workbench ← Restart — ADR-0010) uses **producer-owned
typed signals connected in `GameplayWiring`**, not the bus; the Hint System gets
each verdict only through the grader's `hint_counter` Callable (ADR-0004 §2) —
the bus is the record, not the control path.
This keeps gameplay working when the recorder is disabled (release) or stopped
(write failure).

### Gameplay signal flows

The contract is ADR-0010 §4 (signal catalogue — names, payloads and owners are
binding); this is a summary. Every connection is made once, in
`GameplayWiring.connect_all(services)`; synchronous answers use injected
Callables (`hint_counter`, `draft_is_empty`).

- **Verdict fan-out**: `verdict_given(Verdict)` → Progression (PASS /
  UNAVAILABLE; ignores challenge verdicts), Dialogue (`DialogueFeedback` only),
  Constraint Challenges (challenge verdicts), Onboarding (Guided "start over").
  The Workbench gets the full `Verdict` as the return of `await submit()`.
- **`request_opened` vs `request_shown`**: `request_opened` is the state change
  to `Open` (logged `request_open`) → Hint, Constraint Challenges (offer expiry),
  Dialogue (side messages only). `request_shown` is the workbench displaying the
  request (after the PASS hold, after the briefing, or when the player opens a
  side / replay; never while challenge mode is open) → Workbench, Dialogue
  (request line), Hint (`shown(p)`), Store Manual (page unlock), Onboarding.
- **Briefing end → first request**: `shift_started` → Dialogue briefing →
  `briefing_finished` → Progression opens the first main request and the side
  requests; on Day One's Morning the main request waits for the onboarding answer.
- **Onboarding answer**: Onboarding `line_requested` ("Ever used SQL?") →
  Dialogue renders the choice → `choice_made` → Onboarding →
  `sql_question_answered(knows_sql)` → Progression (1-1 opens).
- **Restart**: the chapter-list view confirms (IP-18), then calls
  `ShiftProgression.request_restart(puzzle_id)` → logs `request_restart`
  (`draft_was_empty` from the `draft_is_empty` Callable) → `request_restarted` →
  Workbench controller (draft, Run, verdict, per-cause counters, "↷ Leave it for
  Kenji"), Hint System, Onboarding, Dialogue (drops `skip.offer`). Each resets only
  its own state; Constraint Challenges is not a consumer (CC 6c).
- **Challenge mode**: `request_passed` → Constraint Challenges →
  `challenge_offered` (merged into the pass-line bubble) → `choice_made` (Try it /
  Later) → `challenge_mode_changed(open, puzzle_id)` → Hint (hidden, `active_time`
  paused), Dialogue (tickets dimmed), Workbench (banner, own draft), Progression
  (shift never advances while open); `challenge_resolved` → Dialogue, Progression;
  `challenge_offer_expired` → Dialogue.
- **Reaction queue** (ADR-0010 §5): Dialogue enqueues every character line and
  flushes once per synchronous batch with `call_deferred`, ordered by priority —
  verdict / error reaction and pass line (a challenge offer merges into it) →
  first-Submit explainer → onboarding "start over" → `skip.offer` → `skip.accept`.
  Same-frame line order never depends on signal connection order.
- **Input activity** (ADR-0010 §7): `InputActivity` reads `root.window_input`;
  the Hint System pulls `last_input_ms()` and `Clock.is_focused()`; its pause comes
  from its own state (`challenge_mode_changed`, `request_shown`).

### Boot order

`ServicesFactory.build` (ADR-0006 §2): BuildFlavour → Clock + FocusListener
→ GameConfig → StringTable → Settings → EventBus (+ PlaytestRecorder) →
SqlSandbox → PuzzleRepository → HintSystem → HiddenDataGrader(`hint_counter`
bound to the Hint System) → ContentVerifier → `await verify_all(false)` →
other feature systems → `GameplayWiring.connect_all(services)` (ADR-0010 §1)
→ InputActivity (last child of `Main`) → play scenes. Wiring runs after
verification, so nothing the verifier does can reach a gameplay consumer.

Notes: `GameConfig` validation errors are fatal in dev, defaults + `push_error`
in playtest/release (ADR-0007 §1). The verifier keeps up to `verify_parallelism`
executions in flight (default 6; ≈ 200 for Chapter 1 ≈ 0.6 s at 60 fps,
ADR-0003) and calls the grader's side-effect-free `grade()`.

### Save/load

None at MVP (progression rule 13: session-only). Progression, Hint, Challenge and
Manual state must stay plain data (dictionaries / typed records, no node
references) so the VS Save/Load ADR can serialise it without refactoring.

## API Boundaries

Pseudocode in GDScript. Exact types and names are fixed by the ADRs; these are
the shapes the ADRs start from.

```gdscript
# --- SqlSandbox (Foundation) — ADR-0002 ---
class_name SqlRequest  # RefCounted
var sql: String
var dataset: ResolvedDataset      # schema + rows, from PuzzleRepository
var mode: StringName              # &"query" (MVP) | &"scratch" (Alpha) | &"modify" (Alpha)

class_name SqlResult   # RefCounted, immutable after creation
var status: StringName            # &"ok" | &"error"
var error_kind: StringName        # EMPTY, MULTI_STATEMENT, NOT_A_QUERY, NOT_ALLOWED,
                                  # UNSUPPORTED, SQL_ERROR, TIMEOUT, CONTENT_ERROR
var error_text: String
var build_message: String         # CONTENT_ERROR only; log-bound
var columns: PackedStringArray
var column_count: int             # also for zero rows
var rows: Array[Array]            # positional
var truncated: bool
var rows_changed: int             # scratch writes only
var elapsed_ms: float

# Async; the result is always delivered on the main thread.
# Guarantees: never blocks the frame thread; TIMEOUT within limit + 50 ms;
# every request uses a fresh DB (query mode); never voices or judges.
func execute(request: SqlRequest) -> SqlResult   # awaitable coroutine

# Pure, synchronous, main-thread safe.
func tokenize(sql: String) -> Array[SqlToken]   # SqlToken {kind, text}

# Internally: execute() awaits a per-request completion object that the
# runner's _process poll completes (ADR-0001 §3, ADR-0002 §4).

# --- PuzzleRepository (Foundation) — ADR-0003 ---
func get_chapter(id: StringName) -> ChapterDef
func get_puzzle(id: StringName) -> PuzzleDef        # null if withheld
func load_state(id: StringName) -> StringName       # &"loaded" | &"withheld"
func resolve_dataset(puzzle: PuzzleDef, dataset_id: StringName) -> ResolvedDataset
func reference_result(puzzle: PuzzleDef, dataset_id: StringName) -> SqlResult  # cached

# --- EventBus (Foundation) — ADR-0004 ---
func emit_event(event_name: StringName, puzzle_id: Variant, data: Dictionary) -> void
# Invariant: event_name ∈ catalogue and data has exactly the declared fields,
# else the event is rejected and counted. Never throws into gameplay.
signal event_recorded(record: Dictionary)

# --- HiddenDataGrader (Core) — ADR-0010 §3 ---
func grade(puzzle: PuzzleDef, sql: String, counters: CauseCounters) -> Verdict   # awaitable; no side effects (verifier, tests)
func submit(puzzle: PuzzleDef, sql: String, counters: CauseCounters) -> Verdict  # awaitable; player path: grade → hint_counter → submit event → verdict_given
func run_match(puzzle: PuzzleDef, visible_result: SqlResult) -> bool
```

**Invariants callers must respect:** a Submit is exclusive (no Run or Submit
while one is in flight); a newer Run may start while an older Run is in flight
and the older result is discarded by sequence number (ADR-0002 §6); no caller reads hidden-dataset rows except the grader
and the verifier; `SqlResult` and `PuzzleDef` are treated as immutable.

**Engine type check:** `RefCounted`, `PackedStringArray`, typed `Array[...]`,
`StringName`, signals, `await` — all pre-4.3, LOW risk. Typed-return overrides
(4.7) apply only if these classes override engine virtuals (they should not).

## ADR Audit

v1 snapshot: no ADRs existed when this document was written. Current state:
see `docs/architecture/architecture-review-2026-10-15.md` (5 ADRs reviewed,
2 blocking conflicts fixed, all 5 Accepted) and
`docs/architecture/requirements-traceability.md`.
Written 2026-10-16: **ADR-0007 Tuning config, string tables and session
settings** (`GameConfig` + `ConfigSchema`, own `StringTable`, `Settings`) and
**ADR-0010 Gameplay signal contracts** (signal catalogue, `grade()` / `submit()`
split, reaction queue, Restart, `InputActivity`), both re-reviewed, amended and **Accepted** the same day.
ADR-0005 is not written (pending the Windows spike); ADR-0008 and ADR-0009 are
planned.

## Required ADRs

Numbering is provisional (`/architecture-decision` assigns the final number).

### Must have before coding starts (Foundation)

| # | ADR | Decides | Covers | Needs first |
|---|---|---|---|---|
| **ADR-0001** | **Sandbox execution and timeout mechanism** | Where execution runs and how `TIMEOUT` is enforced without an interrupt API. Candidates: (a) worker thread, abandon on timeout, discard its result; (b) persistent helper process (headless Godot + godot-sqlite) killed and respawned on timeout; (c) step cap — needs `sqlite3_progress_handler`, which godot-sqlite does not expose → a GDExtension fork (same as sandbox OQ1 option (a)); (d) MVP mitigations only (reject `RECURSIVE`, outer `LIMIT`). Must be proven against **SB-18** and **SB-19** | TR-sandbox-005, -006 | **Spike** on 4.7.2: per-thread `SQLite` object safety, abandoned-thread CPU cost, helper-process start + round-trip latency, kill/respawn time |
| **ADR-0002** | **Sandbox API and lexer contract** | `SqlRequest`/`SqlResult` shapes, async delivery, error kinds, the `tokenize` contract and token kinds, statement splitting by the hand lexer vs SQLite's `sqlite3_complete` (sandbox OQ2 — not exposed by godot-sqlite either), scratch-mode hooks for Alpha | TR-sandbox-001…004, -007, -008; TR-hint-002; TR-challenge-001; TR-grader-001 | ADR-0001's delivery model (thread vs process changes how rows cross the boundary) |
| **ADR-0003** | **Puzzle data format, loader and content verifier** | On-disk format (JSON vs `.tres` vs SQL + manifest — puzzle OQ1), dataset override resolution, canonical serialisation for the content hash, verifier runtime: **Godot headless** (same SQLite as the game) vs Python (`ch1.py` lineage) — puzzle OQ2, and where the manual/hint/ghost-text CI checks live | TR-puzzle-001…006, TR-grader-002, TR-manual-001, TR-onboarding-001 | ADR-0002 (verifier uses the sandbox) |
| **ADR-0004** | **Event bus and Playtest Log** | Catalogue as declared schema (names + fields), rejection of undeclared events, bus vs direct signals (bus = record, signals = control), JSONL writer and flush policy, build flavours (dev / playtest / release via feature tags), F9 facilitator input, report tool runtime | TR-playtest-001…005, TR-grader-004, TR-workbench-005, TR-puzzle-005 | — |
| **ADR-0005** | **Platform, display and performance baseline** | Viewport 1280×720 + stretch `canvas_items` / `expand` / `fractional` stated explicitly, `Window.min_size` 1280×720; **renderer** (Forward+ today; Compatibility is the candidate for a 2D UI game — broadest GPU support, no D3D12/Vulkan requirement); 64 MB texture ceiling and < 500 draw calls as budgets; **target PC** for the 200/300 ms budgets (grader OQ7); Windows `.dll` result | TR-platform-001, -002, TR-sandbox-009, TR-grader-005, TR-workbench-004 | **Windows `.dll` spike** on 4.7.2 (export + run SB-01…12 on Windows) |
| **ADR-0006** | **Composition root and service wiring** | One root scene builds the Foundation services and injects them (coding standard: DI over singletons); which, if any, are autoloads; injectable `Clock` for fake-clock tests | TR-hint-001, TR-progression-001; testability of all | — |

### Should have before the relevant system is built

| # | ADR | Before | Covers |
|---|---|---|---|
| ADR-0007 | Tuning config, string tables and session settings — **Accepted** 2026-10-16 (`docs/architecture/adr-0007-tuning-config-string-tables-and-settings.md`) | First Dialogue / Hint story | TR-config-001, TR-dialogue-001, -005, TR-onboarding-002 |
| ADR-0010 | Gameplay signal contracts — **Accepted** 2026-10-16 (`docs/architecture/adr-0010-gameplay-signal-contracts.md`) | First story that emits or consumes a cross-system signal | TR-grader-006, -007, TR-challenge-003, TR-dialogue-006, TR-hint-003 |
| ADR-0008 | Workbench editor: `CodeEdit` setup, SQL highlighting, keyboard map and dual-focus handling, IME commit, `ui_scale` via Theme | First Workbench story (after the IME probe, QW OQ4) | TR-workbench-001…004 |
| ADR-0009 | Counter strip rendering: 320×30 `SubViewport`, palette-LUT `canvas_item` shader, integer ×k placement, `strip_to_ui()` | First strip / Dialogue presentation story | TR-dialogue-003 |

### Can defer

- Save/Load serialisation format (Vertical Slice — Save/Load & Settings GDD)
- Audio bus layout (Vertical Slice — Audio GDD)
- Localisation pipeline beyond the English string table (post-VS)
- Back Room scratch-DB size cap (Alpha — Back Room GDD, sandbox OQ5)

### Technical Setup tasks that are not ADRs

| Task | Feeds | Note |
|---|---|---|
| Windows godot-sqlite `.dll` spike on 4.7.2 | ADR-0005, ADR-0001 | Needs a Windows machine (or a Windows export run there); the dev machine is Linux |
| ADR-0001 timeout spike | ADR-0001 | Throwaway, in `prototypes/` |
| `project.godot`: viewport 1280×720, `scale_mode`, `min_size`, renderer | ADR-0005 | One edit once ADR-0005 is Accepted |
| `/test-setup` — install gdUnit4, `tests/unit/`, `tests/integration/`, CI | all | `commands.test` already written; fails until installed |
| `commands.build` — create `export_presets.cfg` (Linux + Windows Desktop) and set it via `/settings` | ADR-0005 | Export templates for 4.7.2 required |

## Architecture Principles

1. **Nothing the player types can freeze or damage the game.** All SQL
   execution is off the frame thread, bounded in time, on a throwaway database
   (Pillar 3).
2. **One SQLite, one verdict.** The game, the content verifier and CI run the
   same sandbox code on the same godot-sqlite build, so "verified" means the
   same thing everywhere (puzzle L-04, Pillar 1).
3. **Hidden data flows one way: into the grader and out to the log only.** No
   API returns hidden rows or counts to a presentation module (grader rule 11).
4. **Data-driven and injectable.** Every tuning value and every player-facing
   string comes from data files; every service is injected, and time comes from
   an injectable clock, so each GDD's Logic ACs run headless in gdUnit4.
5. **Events record; signals control.** Gameplay never depends on the Playtest
   Log being on.

## Open Questions

| ID | Question | Blocks | Resolution path |
|---|---|---|---|
| AQ-01 | Is one godot-sqlite `SQLite` object per worker thread safe on 4.7.2, and what does an abandoned thread cost? | ADR-0001 | Timeout spike |
| AQ-02 | Helper-process latency: start-up and per-request round trip of a headless child Godot with godot-sqlite | ADR-0001 | Timeout spike |
| AQ-03 | Which machine is the target PC (grader OQ7)? | ADR-0005, SB-20, AC-26 | Developer decision |
| AQ-04 | Forward+ vs Compatibility renderer for a 2D UI game on Steam | ADR-0005 | ADR-0005 (measure start-up and frame time on both) |
| AQ-05 | Does the godot-sqlite v4.9 Windows `.dll` load and pass SB-01…12 on 4.7.2? | ADR-0005, Windows builds | Windows spike |
| AQ-06 | `H_table` uses the constant 720; with `expand` aspect the logical height can exceed 720 (QW OQ8) | ADR-0008 | `/ux-design` + ADR-0008 |
| AQ-07 | IME composition and AccessKit exposure in `CodeEdit` (QW OQ3, OQ4) — NOT SOURCEABLE | ADR-0008 | IME / AccessKit probe |
