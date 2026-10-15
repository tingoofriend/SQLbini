# ADR-0001: Sandbox Execution and Timeout Mechanism

## Status
Accepted

## Date
2026-10-15

## Last Verified
2026-10-15

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
The SQL Execution Sandbox must enforce `exec_time_limit` and never block the
frame thread, but godot-sqlite v4.9 has no interrupt or progress-handler API.
Each execution runs on its own worker `Thread` with its own `SQLite` object; the
main thread watches the clock, delivers `TIMEOUT` at the limit, and abandons the
worker — its result is discarded and the thread is joined only after SQLite
returns.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 + godot-sqlite v4.9 (GDExtension) |
| **Domain** | Core (threading) |
| **Knowledge Risk** | MEDIUM — threading APIs after 4.3 are NOT SOURCEABLE in `docs/engine-reference/godot/`; the surface used here is pre-4.3 and was exercised on 4.7.2 in the spike |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md` (no threading entries); `prototypes/sandbox-timeout-spike-2026-10-15/README.md`; `prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md` |
| **Post-Cutoff APIs Used** | None. Used: `Thread.new/start/is_alive/wait_to_finish`, `Callable.bind`, `Time.get_ticks_usec` (all pre-4.3). 4.7 typed-return rule applies to any `_process` override that returns a value |
| **Verification Required** | (1) Re-run the spike's `thread_probe.gd` and `quit_probe.gd` on Windows with the godot-sqlite `.dll` (Windows spike, before ADR-0005). (2) SB-18 and SB-19 as gdUnit4 integration tests on both platforms. (3) Re-run on every godot-sqlite upgrade |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None |
| **Enables** | ADR-0002 (Sandbox API and lexer contract — fixes the async delivery model it must expose); ADR-0003 (the content verifier runs executions through this runner) |
| **Blocks** | Sandbox epic (all stories implementing `sql-execution-sandbox.md` rule 15); Grader submit pipeline (async) |
| **Ordering Note** | Back Room (Alpha) scratch mode must follow the scratch rule below; revisit in the Back Room GDD |

## Context

### Problem Statement
`sql-execution-sandbox.md` rule 15 requires (a) that no execution runs on the
frame thread and (b) that the caller receives `TIMEOUT` within
`exec_time_limit` + 50 ms (SB-18), with the frame staying ≤ 16.6 ms throughout
(SB-19). godot-sqlite v4.9 exposes no `sqlite3_interrupt`, progress handler or
busy callback (spike 2026-10-14), so a running statement cannot be stopped from
GDScript. The residual slow case is an aggregate, `GROUP BY`, `DISTINCT` or
`ORDER BY` over a many-way join (rule 15); unbounded recursion is already
rejected (rule 9) and streaming results are cut by the outer `LIMIT` (rule 12).

### Constraints
- No native-code toolchain in the MVP plan (a godot-sqlite fork is +1–2 weeks).
- `exec_time_limit` = clamp(50–150 ms, default 100) — Formulas.
- Run p95 ≤ 200 ms and Submit p95 ≤ 300 ms (grader AC-26); one execution ≈ 0.4 ms on the dev laptop.
- Windows + Linux desktop; the Windows `.dll` is not yet tested (AQ-05).

### Requirements
- TIMEOUT within limit + 50 ms; the next request succeeds.
- Frame time unaffected by any query, including abandoned ones.
- Each `query`-mode execution keeps its own fresh database (rule 2).
- The mechanism must not change the sandbox's public API if it is later replaced by a real interrupt.

## Decision

**Thread per execution, abandon on timeout.**

1. The statement check (lexer, rules 5–9) runs **synchronously on the main
   thread** — it is pure GDScript and takes microseconds. Rejected requests
   never start a thread.
2. Each accepted execution starts a **new `Thread`**. The worker function
   creates its own `SQLite` object, builds the database, runs the view /
   metadata / fetch steps, closes the database and returns a plain result
   value. **No `SQLite` object, dataset row array or result is shared between
   threads while the worker runs**: the request is copied in, the result is
   returned by `wait_to_finish()`.
3. A sandbox-owned node on the main thread checks every in-flight execution
   once per frame (`_process`):
   - worker finished → `wait_to_finish()`, wrap the value in `SqlResult`,
     deliver it to the caller;
   - elapsed ≥ `exec_time_limit` → deliver a `TIMEOUT` result at once, move the
     `Thread` to the **graveyard**, and ignore whatever it later returns.
   Frame polling bounds the detection delay to one frame (≤ 16.6 ms at 60 fps;
   spike: limit + 4 ms), inside the 50 ms margin. The guarantee is therefore
   **limit + one frame**: it stays inside SB-18's 50 ms above ≈ 20 fps, and a
   main-thread stall (e.g. a scene load) delays it by the stall. The same poll
   delivers successful results, so every execution costs at least one frame of
   latency; callers that run many executions (the content verifier) keep
   several in flight instead of awaiting them one by one (ADR-0003).
   The runner node uses `process_mode = PROCESS_MODE_ALWAYS` (probed on 4.7.2:
   a paused tree stops `_process` on default nodes, which would stop delivery,
   TIMEOUT and reaping).
4. The graveyard is reaped every frame: a thread whose `is_alive()` is false is
   joined with `wait_to_finish()` and dropped. Graveyard threads are never
   joined while alive (that would block the frame).
5. **Quit does not wait for the graveyard.** The process exits with abandoned
   workers still inside SQLite (spike: exit 0 in 0.4 s; Godot prints a
   "Thread destroyed without completion" warning, which is expected).
6. **Scratch mode (Alpha).** A scratch database that times out is not reused:
   its `SQLite` object stays with the abandoned worker, and the sandbox rebuilds
   the scratch database from the visible dataset (the Back Room's "reset"). The
   Back Room GDD must state this player-facing consequence.

### Architecture Diagram

```
 caller (Workbench / Grader / Verifier)
   │ execute(request)            ▲ SqlResult (main thread, same frame or later)
   ▼                             │
 SqlSandbox ── lexer check (main, sync) ──► error result ─┘
   │ accepted
   ▼
 ExecutionRunner (Node, main thread)        ┌──────────── worker Thread ───────────┐
   in_flight: [{thread, started_us, cb}] ──►│ SQLite.new() → build → view → PRAGMA │
   _process():                              │ → query_only → fetch → close_db()    │
     done?    → wait_to_finish → deliver    │ return plain Dictionary              │
     ≥ limit? → deliver TIMEOUT,            └──────────────────────────────────────┘
                move thread → graveyard
   graveyard: reap when !is_alive()
```

### Key Interfaces

```gdscript
# Internal to SqlSandbox (public API shape is ADR-0002's).
class_name ExecutionRunner extends Node

## Starts `work` (a Callable returning a Dictionary) on a new worker thread.
## Calls `on_done(value: Dictionary, timed_out: bool)` on the main thread
## exactly once: with the worker's value, or with timed_out = true at the limit.
func run(work: Callable, limit_ms: float, on_done: Callable) -> void

## Number of abandoned workers still inside SQLite (diagnostics only).
func abandoned_count() -> int
```

### Implementation Guidelines
- Must run every SQLite call of an execution on that execution's worker thread; must never touch a `SQLite` object from two threads.
- Must never call `wait_to_finish()` on a thread that `is_alive()` on the main thread.
- Must never call `OS.delay_*` or any blocking wait on the main thread to wait for a query.
- Must create the `SQLite` object inside the worker, not pass one in.
- Must return plain data (Dictionary / Array / primitives) from the worker; must not emit signals or touch nodes from the worker.
- Must deliver exactly one result per request (TIMEOUT or the real one, never both).
- Must measure elapsed time from the injected `Clock.now_ms()` (ADR-0006; `RealClock` uses `Time.get_ticks_usec()`) from request receipt (`elapsed_ms`, rule 16), for both `elapsed_ms` and the timeout check, so SB-17/18 logic is unit-testable with a fake clock; SB-18 itself stays an integration test with a real query.
- The runner node must set `process_mode = PROCESS_MODE_ALWAYS`.
- Dev builds must log a warning when `abandoned_count()` exceeds 2.
- The worker `Callable` must be a static function (or bound to a `RefCounted`), never a method of a `Node` that can be freed while the worker runs.
- The worker must build its returned Dictionary/Array entirely inside the thread and must call `close_db()` on every exit path, including after a late result nobody will read.
- Must use dedicated `Thread`s, not `WorkerThreadPool`: an abandoned query would occupy a pool slot for seconds to minutes and starve engine tasks.
- Test teardown must not wait on the graveyard; the quit-time "Thread destroyed without completion" / leaked-ObjectDB warnings are expected and must not be treated as test failures.

## Alternatives Considered

### Alternative 1: Persistent helper process, killed on timeout
- **Description**: A second headless Godot process with godot-sqlite executes requests over stdin/stdout; on timeout the game kills and respawns it.
- **Pros**: Timeout is a real stop — no CPU left burning; crash isolation.
- **Cons**: Spike: 147 ms start, 144 ms respawn after every TIMEOUT, ≈ 100 MB extra RSS, JSON turned integers into floats (needs a typed encoding for int64/BLOB); running the exported binary as its own helper and `OS.execute_with_pipe` on Windows are unverified (NOT SOURCEABLE). ≈ +1 week.
- **Rejection Reason**: Cost and unverified platform behaviour for a case (many-way join) the MVP's Chapter 1 never needs; the thread option meets SB-18/19 as measured.

### Alternative 2: godot-sqlite fork exposing `sqlite3_interrupt` / progress handler ("step cap")
- **Description**: Add an interrupt binding to a fork; keep worker threads but stop the statement instead of abandoning it.
- **Pros**: Clean cancellation; no burning core.
- **Cons**: C++ toolchain (godot-cpp, SCons), Linux + Windows builds, re-merge on every upstream release; ≈ +1–2 weeks.
- **Rejection Reason**: Not needed for MVP. It composes with this decision (same runner, `abandon` becomes `interrupt`), so it stays the upgrade path.

### Alternative 3: MVP mitigations only (reject `RECURSIVE`, outer `LIMIT`)
- **Description**: No time limit; rely on rules 9 and 12.
- **Pros**: No code.
- **Cons**: A many-way join aggregate still hangs; if it ran on the main thread the game would freeze.
- **Rejection Reason**: Violates sandbox rule 15 (a) and (b), SB-18, SB-19.

## Consequences

### Positive
- SB-18 and SB-19 are met with plain GDScript and no extra process (spike: TIMEOUT at limit + 4 ms; max frame gap 7.1 ms with 7 abandoned workers).
- Every execution is isolated by construction (new thread, new database).
- The public sandbox API is identical whether the stop is "abandon" or a future "interrupt".

### Negative
- An abandoned query keeps one CPU core busy until SQLite finishes — 1.4–2.0 s for a 6-way join on 24 rows, minutes for an 8-way join. Repeated runs of such a query stack up.
- Quit prints a thread warning when a worker is still alive.
- A timed-out scratch database is lost and rebuilt (Alpha).

## Risks
- **CPU burn from repeated pathological queries** (e.g. a player re-running an 8-way join). Mitigation: dev-build warning above 2 abandoned workers; the Playtest Log's `run` events with `error_kind = TIMEOUT` show how often it happens. **Revisit trigger:** if playtests show TIMEOUTs in real play, or a worker alive > 60 s in dev, schedule Alternative 2 before the Vertical Slice.
- **godot-sqlite thread behaviour on Windows** is untested. Mitigation: Windows spike re-runs the thread probes before ADR-0005.
- **godot-sqlite upgrades** may change threading behaviour (it is third-party). Mitigation: SB-18/SB-19 integration tests re-run on every upgrade.
- **Low-end target PC** (not yet named, AQ-03): fewer cores make a burning worker more visible. Mitigation: measure on the target PC once named (ADR-0005); try `Thread.PRIORITY_LOW` for workers there — its effect on 4.7 is NOT SOURCEABLE, so measure before relying on it.
- **Export builds and the editor's Stop button** with live workers are untested (the spike ran from the editor binary on Linux). Mitigation: include a TIMEOUT run in the first exported-build smoke check.

*Engine validation (godot-specialist, 2026-10-15): no blocking findings; minor notes folded into Implementation Guidelines and Risks above. TD-ADR skipped — lean mode.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| sql-execution-sandbox.md | Rule 15 (a): execution never runs on the frame thread | Every accepted execution runs on a worker thread; the lexer check is the only main-thread work |
| sql-execution-sandbox.md | Rule 15 (b) / SB-18: `TIMEOUT` within `exec_time_limit` + 50 ms; next request succeeds | Per-frame watchdog on the main thread delivers TIMEOUT within one frame of the limit; a new request uses a new thread and database |
| sql-execution-sandbox.md | SB-19: frame ≤ 16.6 ms during the SB-18 query and a 6-way self-join | Main thread never waits on a worker; spike max frame gap 7.1 ms |
| sql-execution-sandbox.md | Rule 2: fresh database per `query` request | Database created and closed inside each worker |
| sql-execution-sandbox.md | Open Question 1 | Resolved: option (b), worker thread abandoned on timeout |
| hidden-data-grader.md | Rule 8: stop grading at the first hidden `TIMEOUT`; Submit p95 ≤ 300 ms | Runner delivers TIMEOUT within limit + one frame, so the grader's early stop bounds the worst case (timeout on the last hidden set): ≈ 243 ms at D = 3 at the measured cost, ≈ 310 ms at the target ceilings (sandbox Formulas `submit_worst`, corrected 2026-10-15) |
| query-workbench.md | QW-13: typing, scrolling and pane switching stay live during Run and Submit | Main thread is never blocked by an execution |

## Performance Implications
- **CPU**: ≈ 0.4 ms per execution on a worker (spike); thread start is negligible at this rate. Abandoned workers consume a core each until SQLite returns.
- **Latency**: each result arrives on the next frame poll — ≥ one frame (≈ 16.7 ms at 60 fps, ≈ 6.6 ms headless) per sequential execution (architecture review 2026-10-15, C2).
- **Memory**: per execution, one in-memory database (Chapter 1 ≈ tens of KB); an abandoned `ORDER BY` over 8M rows peaked at 113 MB RSS (≈ +7 MB over baseline).
- **Load Time**: none at start-up beyond the content verifier's executions (≈ 200, sequential, off the frame thread).
- **Network**: none.

## Migration Plan
No production code exists. The spike code in `prototypes/sandbox-timeout-spike-2026-10-15/` is not migrated; the runner is rewritten to production standards under the Sandbox epic.

## Validation Criteria
- SB-17 (limit clamp) — unit test with a fake clock.
- SB-18 — integration test: a query running longer than the limit returns `TIMEOUT` within limit + 50 ms, and the next request returns the correct 24-row count.
- SB-19 — integration test: frame time ≤ 16.6 ms while the SB-18 query and a 6-way self-join run.
- Same tests pass on Windows (Windows spike, ADR-0005).

## Related
- `docs/architecture/architecture.md` — Required ADRs, AQ-01, AQ-02
- `design/gdd/sql-execution-sandbox.md` — rules 2, 9, 12, 15; SB-17…19; Open Question 1
- `design/gdd/hidden-data-grader.md` — rule 8, AC-26
- `prototypes/sandbox-timeout-spike-2026-10-15/README.md` — measurements
- ADR-0002 (planned) — public sandbox API built on this runner
