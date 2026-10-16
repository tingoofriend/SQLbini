# ADR-0010: Gameplay Signal Contracts

## Status
Accepted

## Date
2026-10-16

## Last Verified
2026-10-16 (amended after `/architecture-review` 2026-10-16: X2 `grade()`/`submit()`, E1 `root.window_input`, S1–S10, E7, E8; developer decision on the first-Submit explainer order)

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
Ten MVP systems react to each other at runtime (verdicts, Restart, briefing end,
challenge mode, skip offers, coach-mark triggers), and the GDDs describe these
links per system but never as one contract, leaving ownership, payloads and
same-frame ordering ambiguous. Each producer declares typed, past-tense signals;
`ServicesFactory` connects every gameplay signal in one wiring function;
synchronous answers use injected `Callable`s; same-frame ordering is never left
to connection order — the Dialogue reaction queue collects the lines of one synchronous chain and
flushes them in a fixed priority.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core (scripting / signals) |
| **Knowledge Risk** | LOW — typed signals, `Signal.connect(Callable)`, `call_deferred`, `_input`, `RefCounted` are pre-4.3 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md` (string-based `connect` deprecated), `current-best-practices.md` (lambda capture by value, typed-return overrides, 4.7 input device IDs); ADR-0004, ADR-0006; `docs/registry/architecture.yaml` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (1) The order in which one signal calls its connections is **not relied on** (Godot's call order across connections is NOT SOURCEABLE in `docs/engine-reference/godot/`); a unit test proves every multi-consumer fan-out gives the same result in both connection orders. (2) `InputActivity` on `root.window_input` sees key, mouse-button and wheel events with `CodeEdit` focused **and** with an embedded dialog / popup open (probed 2026-10-16: `_input` sees nothing while a dialog is open, `root.window_input` does) — re-check in the first workbench build with an IME composition active. (3) One submit's lines flush as one batch (probed 2026-10-16: deferred calls queued inside a `_process`-poll-resumed coroutine flush together after the poll returns) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0004 (events record, signals control; the `hint_counter` Callable exception), ADR-0006 (`ServicesFactory`, `Clock`, `setup(services)`, one-way ownership), ADR-0007 (`StringTable` ids for `statement_key` and `line_requested`) |
| **Enables** | Grader, Workbench, Hint, Constraint Challenges, Progression, Dialogue, Store Manual and Onboarding stories that react to another system |
| **Blocks** | First story of any of those epics that emits or consumes a cross-system signal |
| **Ordering Note** | String ids and line text come from ADR-0007; this ADR fixes only who tells whom what and when. ADR-0003's `ContentVerifier` calls `grade()` (§3) |

## Context

### Problem Statement
The MVP GDDs define about 36 runtime interactions between systems
(architecture review 2026-10-15, TR-grader-006/007, TR-challenge-003,
TR-dialogue-006, TR-hint-003). ADR-0004 decided that gameplay control uses typed
signals, not the event bus, but no ADR fixes the signal set. The GDD sweep found
ten ambiguities: the grader → Dialogue payload for errors; the grader's return
to the Workbench; the source of the hint input-activity feed and pause; the
owner of the onboarding suppression window; the Manual → Onboarding unlock link;
the Restart subscriber list and order; push vs pull for "draft is empty"; the
challenge-mode event's consumers; who captures the "Ever used SQL?" answer; and
the PASS relay to Constraint Challenges. One same-frame ordering rule (RD-19:
the FAIL line first, then Kenji's skip offer) inverts the natural call order:
the Hint System latches `exhausted` while the grader is still building the
verdict, before the verdict reaches Dialogue.

### Constraints
- ADR-0004: gameplay never subscribes to `event_recorded`; the log must be optional.
- ADR-0006: no autoloads; services built by `ServicesFactory`; one-way ownership (no `RefCounted` cycles); time from `Clock`.
- Naming: signals snake_case, past tense (`naming.signals`).
- One developer: the wiring must be readable in one place.

### Requirements
- Every cross-system link has one owner, one typed payload and one direction.
- Consumers never depend on the order in which Godot calls connections.
- The RD-19 / Progression rule 7a line order holds even when producers fire in the "wrong" order.
- The Dialogue never receives hidden-data details or raw text for `CONTENT_ERROR` / `TOO_MANY_ROWS` (grader rule 11, Dialogue rule 2).

## Decision

### 1. Mechanism: producer-owned typed signals, wired in one place
- Each producer declares its signals with typed parameters on its own class.
- **`GameplayWiring.connect_all(services)`**, called once by `ServicesFactory`
  after every service exists, makes every gameplay connection with
  `signal.connect(callable)`. No system connects to another system's signal
  itself, so the full graph is one readable function (and one test fixture).
- Scenes (Workbench view, panels) connect to the systems they are given in
  `setup(services)`; that is presentation, not gameplay control.
- **Synchronous answers** (a value the caller needs before it continues) use an
  injected `Callable` bound by `ServicesFactory` (ADR-0004 §2 pattern), never a
  signal and never a stored reference to the other system.

### 2. Payload records
```gdscript
class_name Verdict extends RefCounted          # immutable after creation (grader)
var puzzle_id: StringName
var kind: StringName       # &"PASS" | &"FAIL" | &"SUBMIT_ERROR" | &"UNAVAILABLE"
var cause: StringName      # FAIL only; &"generic" when no trap explains the diffs
var level: int             # FAIL only (1 at MVP)
var statement_key: StringName   # FAIL only: neutral statement id (text from StringTable, ADR-0007)
var error_kind: StringName # SUBMIT_ERROR only (sandbox error kinds, TOO_MANY_ROWS)
var error_text: String     # SUBMIT_ERROR: the sandbox's error_text (SQLite text for SQL_ERROR,
                           # the fixed message for the other kinds); "" for TOO_MANY_ROWS
var challenge: bool        # graded in challenge mode
# Never: per_dataset, missing/extra counts, hidden rows (grader rule 11)

class_name DialogueFeedback extends RefCounted  # what Dialogue may see
var puzzle_id: StringName  # the puzzle whose speaker / authored feedback applies
var source: StringName     # &"run" | &"submit" (Run errors are Kenji's, Dialogue rule 2)
var kind: StringName       # Verdict.kind; &"RUN_ERROR" for a Run that returned an error
var cause: StringName
var level: int
var error_kind: StringName
var error_text: String     # blank for CONTENT_ERROR, TOO_MANY_ROWS and UNAVAILABLE; otherwise
                           # the sandbox text unchanged (RD-09)
var challenge: bool        # challenge-mode verdict → challenge lines, never pass_reaction
static func from_verdict(v: Verdict) -> DialogueFeedback
static func from_run_result(puzzle_id: StringName, r: SqlResult) -> DialogueFeedback  # null when r is OK
```
`DialogueFeedback` is the single union for the GDD's "`{verdict, cause, level}`
only" payload and the error case `{error_kind, error_text}` on Run or Submit
(resolves ambiguity 1). None of its fields is hidden data. The Workbench receives
the full `Verdict` as the return of `await grader.submit(...)` (it is the caller —
resolves ambiguity 2); the neutral statement is shown from `statement_key` via
the StringTable.

### 3. Grading vs submitting (inside `HiddenDataGrader`)
- **`grade(puzzle, sql, counters) -> Verdict`** (awaitable) — executions
  (ADR-0002) and cause selection only. **No side effects**: no `hint_counter`
  call, no event, no signal. The `ContentVerifier` (ADR-0003 §4) calls `grade()`
  for traps and alternative answers, several at once (each `grade()` awaits its
  own executions; `verify_parallelism` bounds how many run concurrently).
- **`submit(puzzle, sql, counters) -> Verdict`** — the player path, in this order:
  1. `var verdict := await grade(...)`.
  2. `hint_counted = hint_counter.call(verdict, sql)` — the Hint System counts the
     submit and may latch `exhausted` here (it emits `hints_exhausted`; see §5).
  3. `bus.emit_event(&"submit", …, {…, hint_counted})` — the log record.
  4. `verdict_given.emit(verdict)` — gameplay fan-out.
  5. `return verdict` to the Workbench controller.

  Steps 2–5 contain **no `await`**, and neither does `hint_counter`,
  `emit_event` or any handler of `verdict_given` / `hints_exhausted` before it
  enqueues its line — this is what keeps one submit's lines in one batch (§5,
  probed).

### 4. Signal catalogue (MVP)

| Producer | Signal (typed) | Consumers | Notes / GDD |
|---|---|---|---|
| HiddenDataGrader | `verdict_given(verdict: Verdict)` | Progression (PASS, UNAVAILABLE; **ignores `challenge = true`**), Dialogue (via `DialogueFeedback.from_verdict`), Constraint Challenges (challenge verdicts), Onboarding (Guided "start over" after a Submit error), Audio (VS) | grader r.14, AC-18, RD-05; SCP 7a; ONB Edge Cases |
| WorkbenchController | `run_started(puzzle_id: StringName)` | Dialogue (a Run ends a reaction at once — Dialogue Edge Cases) | RRD 3 |
| WorkbenchController | `run_finished(puzzle_id: StringName, result_ok: bool, rows_match: bool, feedback: DialogueFeedback)` | Onboarding (`1-1.run`; Guided "start over" after a Run error), Dialogue (Kenji's Run-error reaction from `feedback`; `null` when the Run was OK) | QW 13, RRD 2 / 6, ONB 7a |
| WorkbenchController | `submit_started(puzzle_id: StringName)` | Onboarding (`1-1.run` / `1-1.submit` Done), Constraint Challenges (offer expiry on the next request's first Submit, CC 6) | ONB 7a, CC 6 |
| WorkbenchController | `draft_edited(puzzle_id: StringName, text: String)` | Dialogue (edit after `reaction_grace` ends a reaction), Onboarding (`1-2.schema`: a column name appears in `text`), `InputActivity` backup stamp (§7) | RRD 3, ONB 7a |
| WorkbenchController | `line_requested(line_id: StringName, puzzle_id: StringName)` | Dialogue (the one-time first-Submit explainer, QW 11) | QW 11, RRD 2 `system` |
| Hint System | `hints_exhausted(puzzle_id: StringName)` | Progression (Kenji's skip offer) | HS 11 |
| Shift & Chapter Progression | `request_opened(puzzle_id: StringName, kind: StringName)` | Hint (state exists, `shown(p)` still false), Constraint Challenges (offer expiry), Dialogue (**side** requests only: the side message arrives — RRD 3b) | State change to `Open`, logged `request_open`: a main when the previous one resolves (PR-02) or its briefing ends; sides when the briefing ends (PR-03) |
| Shift & Chapter Progression | `request_shown(puzzle_id: StringName, kind: StringName)` | Workbench (loads the puzzle), Dialogue (request line), Hint (`shown(p)`), Store Manual (page unlock on first open — SM 5), Onboarding (marks, window) | The workbench displays the request: after the PASS hold (RRD 3a, SCP 11), after the briefing, or when the player opens it (side, replay); never while challenge mode is open (CC 6b, PR-20) |
| Shift & Chapter Progression | `request_passed(puzzle_id: StringName)` | Constraint Challenges (offer), Dialogue (pass line timing via its queue) | CC 6 — Progression relays the base PASS (resolves ambiguity 10) |
| Shift & Chapter Progression | `request_restarted(puzzle_id: StringName)` | Workbench controller (draft, Run, verdict, per-cause counters, "↷ Leave it for Kenji" button), Hint System, Onboarding, Dialogue | SCP 12a, SCP Edge Cases — see §6 (resolves ambiguity 6) |
| Shift & Chapter Progression | `skip_offered(puzzle_id: StringName, source: StringName)` / `skip_accepted(puzzle_id: StringName)` | Dialogue (`skip.offer` / `skip.accept` lines), Workbench (shows / hides "↷ Leave it for Kenji") | SCP 7, 7a; RRD 3b |
| Shift & Chapter Progression | `shift_started(shift_id: StringName)` / `shift_clocked_out(shift_id: StringName)` | Dialogue (briefing), Onboarding (window closes at Morning clock-out), Workbench, Constraint Challenges (an unanswered offer expires at clock-out = Later) | SCP, RRD 3c, CC 6 |
| Request & Reaction Dialogue | `briefing_finished(shift_id: StringName)` | Progression (opens the first main request — on Day One's Morning only after `sql_question_answered`; sides open), Onboarding (Day One: asks "Ever used SQL?") | RRD 3c, ONB 1, SCP 11 |
| Request & Reaction Dialogue | `hold_finished(line_kind: StringName, puzzle_id: StringName)` | Progression (`skip.accept` / pass hold end → `request_shown` of the next request, or clock-out) | RRD 3a, 3b |
| Request & Reaction Dialogue | `choice_made(line_id: StringName, choice_id: StringName)` | Onboarding (opening question), Constraint Challenges (Try it / Later), Progression (Leave it for Kenji / Keep trying) | Dialogue renders, owners decide (resolves ambiguity 9) |
| Onboarding | `sql_question_answered(knows_sql: bool)` | Progression (1-1 opens after the answer on Day One) | ONB 1, SCP 11 |
| Onboarding | `guided_window_changed(open: bool)` | Workbench view (hides Hint/Manual "new" indicators while open) | ONB 7 — systems keep their indicator state; the view hides it (resolves ambiguity 4) |
| Onboarding | `line_requested(line_id: StringName, puzzle_id: StringName)` | Dialogue (the "Ever used SQL?" question with its choices; Guided "start over" line) | ONB 1, Edge Cases; RRD 2 `system` |
| Store Manual | `page_unlocked(page_id: StringName, puzzle_id: StringName)` | Onboarding (`1-3.manual` mark), Workbench view ("new") | SM 5, OB-11 (resolves ambiguity 5) |
| Store Manual | `manual_opened(page_id: StringName)` | Onboarding (`1-3.manual` Done) | ONB 7a |
| Constraint Challenges | `challenge_offered(puzzle_id: StringName, challenge_id: StringName)` | Dialogue (offer line + Try it / Later, **in the pass-line bubble**) | CC 6, RRD 3a |
| Constraint Challenges | `challenge_offer_expired(puzzle_id: StringName)` | Dialogue (offer ticket removed from the strip) | CC 6 (next request's first Submit, clock-out) |
| Constraint Challenges | `challenge_mode_changed(open: bool, puzzle_id: StringName)` | Hint (button hidden, `active_time` paused), Dialogue (tickets dimmed), Workbench (banner, own draft), Progression (shift never advances while open) | CC 6–6b, HS 12 (resolves ambiguity 8) |
| Constraint Challenges | `challenge_resolved(puzzle_id: StringName, challenge_id: StringName, cleared: bool, keyword: StringName)` | Dialogue (`challenge.clear` / `challenge.rule_broken`), Progression (challenge mark on the payslip and chapter list) | CC 9.3, SCP 10, 12 |

Ambiguity 7 (draft is empty) is a **pull**: Progression receives
`draft_is_empty: Callable` (`func(puzzle_id) -> bool`) bound to the Workbench
controller. The grader's `hint_counter: Callable` is the other synchronous
answer (ADR-0004 §2).

`line_requested` is declared by each producer that owns a one-off line
(Workbench, Onboarding); the line id's family (ADR-0007 §2) gives Dialogue the
speaker and kind. A producer never sends text, only an id.

### 5. Reaction queue — same-frame ordering owned by Dialogue
Dialogue does not show a line the moment a signal arrives. Every incoming line
request (verdict / Run-error reaction, pass line, explainer, start-over line,
skip offer, `skip.accept`, side message, request line) is **enqueued**; the
queue is flushed with `call_deferred`, and lines from the same **batch** are
ordered by a fixed priority. A batch is everything enqueued by one synchronous
emit chain (e.g. all of `submit`'s steps after its last `await`); the flush runs
at the next deferred-call flush. Lines enqueued by signals that the flush itself
causes form a **new batch in the same frame** — priority is not applied across
batches, so a producer whose line must follow another (Progression's
`skip_offered` after `hints_exhausted`) emits it **synchronously** in the same
chain, never deferred:

1. Error / verdict reaction (`DialogueFeedback`) and the pass line — a
   `challenge_offered` in the same batch **merges into the pass-line bubble**
   (one combined `reaction_hold`, RRD 3a, RD-17); it is not a separate line
2. The one-time first-Submit explainer (developer decision 2026-10-16: the
   verdict reaction first, then the explainer)
3. Onboarding "start over" line
4. `skip.offer`
5. `skip.accept`

Lines of priority 2–5 queue **behind** the line before them and show after its
hold (RD-19, Progression rule 7a: FAIL or `error.CONTENT_ERROR` first, then
`skip.offer`). Within one priority the newest replaces older. A new batch
replaces every line of an older batch that is not yet shown (Dialogue Edge
Cases "only the newest shows"); a dropped `skip.offer` loses only its line —
the "↷ Leave it for Kenji" button stays (Progression state). This removes any
dependence on whether `hints_exhausted` (step 2 of §3) arrives before
`verdict_given` (step 4).

### 6. Restart
`request_restarted` consumers each reset **only their own state** and never read
another consumer's state during the reset, so their order does not matter:
- Workbench controller — draft ← `prefill_sql` or empty, last Run result,
  verdict, the main request's per-cause counter set (grader rule 5: counters are
  caller-supplied; the GDDs' "the grader resets on Restart" means this set), and
  the "↷ Leave it for Kenji" button; its `restart()` is this handler;
- Hint System — Locked, counters, rule 4a comparison, `exhausted`;
- Onboarding — no replay of marks;
- Dialogue — drops a queued or shown `skip.offer` (SCP Edge Cases).

Constraint Challenges is **not** a consumer: challenge drafts and their counter
sets are untouched (CC 6c). Progression's entry point is
`ShiftProgression.request_restart(puzzle_id)`, called by the Workbench view after
the confirmation; it logs `request_restart {state, draft_was_empty}` with
`draft_was_empty` from the `draft_is_empty` Callable, called before emitting.

### 7. Input activity (hint `last_input_t`) and pause
An **`InputActivity`** node — the **last child** of `Main` (Foundation, built by
`ServicesFactory`, `process_mode = PROCESS_MODE_ALWAYS`) — records
`last_input_ms = clock.now_ms()` from **`get_tree().root.window_input`** for
`InputEventKey`, `InputEventMouseButton`, wheel and `InputEventPanGesture`
(touchpad scroll) events while a play scene is active. It does **not** use
`_input`: with an embedded dialog or popup open (AcceptDialog, the `CodeEdit`
context menu — `gui_embed_subwindows` is on by default) the main tree's `_input`
receives nothing, while `root.window_input` still does (probed 2026-10-16). It
consumes nothing, ignores `KEY_F9` explicitly (facilitator key) and branches on
event type, never `event.device`. The Hint System reads `last_input_ms()` and
`clock.is_focused()`; its "paused" factor comes from its own state, set by
`challenge_mode_changed` and `request_shown` (a request not shown → paused).
No system pushes an activity feed (resolves ambiguity 3); the Workbench's
`draft_edited` also stamps activity, as a backup for IME composition input that
may not arrive as `InputEventKey`.

### Architecture Diagram
```
                      ServicesFactory → GameplayWiring.connect_all(services)
                                         (the only place gameplay signals are connected)

 ContentVerifier ──await grade()──► HiddenDataGrader   (no side effects)
 Workbench ──await submit()──► HiddenDataGrader ──hint_counter.call()──► HintSystem ─hints_exhausted─┐
     ▲   returns Verdict            │ emit_event("submit") → EventBus (record)                        ▼
     │                              └─verdict_given(Verdict)─► Progression ──skip_offered──► Dialogue
     │                                                    ├──► Dialogue (DialogueFeedback) ─┐   ▲
     │                                                    └──► Challenges                  ▼   │
     │                                                                      ReactionQueue (flush deferred,
     │ draft_is_empty (Callable) ◄── Progression ─request_*──► Workbench/Hint/Manual/Onboarding/Challenges
     │                                                                      priority order)
 InputActivity (root.window_input) ──last_input_ms()──► HintSystem ◄── challenge_mode_changed ── Challenges
 Workbench / Onboarding ──line_requested──► Dialogue ◄── challenge_offered / _resolved ── Challenges
```

### Key Interfaces
`Verdict`, `DialogueFeedback` (§2); `HiddenDataGrader.grade()` / `submit()` (§3); the signal catalogue (§4) — names, parameter
types and owners are binding for all epics; `GameplayWiring.connect_all(services)`;
`draft_is_empty: Callable`, `hint_counter: Callable`; `InputActivity.last_input_ms() -> float`.

### Implementation Guidelines
- Must declare every gameplay signal on its producer with typed parameters, named snake_case past tense, exactly as §4.
- Must connect gameplay signals only in `GameplayWiring.connect_all`; a system must never connect itself to another system's signal or hold a reference to a consumer.
- Must use `signal.connect(callable)`; never string-based `connect`; lambdas used as handlers must not rely on reassigning captured locals.
- Must never depend on the order in which one signal calls its connections; a consumer must reset or react using only its own state and the payload.
- Must deliver a synchronous answer only through an injected `Callable` (`hint_counter`, `draft_is_empty`).
- Must never pass a service as a `Callable.bind()` argument — bound arguments are held strongly and can recreate an ADR-0006 reference cycle (bound methods themselves do not keep their target alive).
- Must call `grade()`, never `submit()`, from anything that is not the player's Submit (verifier, tests of cause selection).
- Must reach every enqueue of one submit without an `await` (§3 steps 2–5, `hint_counter`, `emit_event`, handlers of `verdict_given` / `hints_exhausted`); an `await` there splits the batch.
- Must route every character line through the Dialogue reaction queue; the queue flushes via `call_deferred` per batch in the §5 priority; a line that must follow another in the same submit must be enqueued in the same synchronous chain.
- Must never rely on the relative order of `call_deferred` calls from different objects.
- Every consumer must be strongly owned by `Services` (a signal connection does not keep its target alive — probed); handlers must be bound methods, not lambdas capturing a consumer.
- Every handler must declare typed parameters — emit arguments are not type-checked at the emit site; the typed handler is the guard (probed).
- Must give Dialogue only `DialogueFeedback`, never a `Verdict` or hidden-data detail; `error_text` only for `SQL_ERROR`.
- Must treat `Verdict` and `DialogueFeedback` as immutable after creation.
- Must emit gameplay signals in addition to, never instead of, the log events of `playtest-log.md` rule 4 (the EventBus records; signals control — ADR-0004).
- `InputActivity` must read `root.window_input` (not `_input`), must be the last child of `Main`, must not consume events and must branch on event type, never `event.device` (4.7).
- Progression must ignore verdicts with `challenge = true`.
- Payload ids are `StringName`; records are `RefCounted`; no `Node` in any payload.
- A new cross-system link requires an edit to §4 (this ADR or its successor), the owning GDD's Interactions table and `GameplayWiring` together.

## Alternatives Considered

### Alternative 1: A central typed signal hub (`GameplaySignals` object holding every signal)
- **Description**: One injected `RefCounted` declares all gameplay signals; producers emit on it, consumers connect to it.
- **Pros**: One file lists every signal; no wiring function.
- **Cons**: Producers and consumers both depend on a global-feeling hub; any system can emit any signal (ownership invisible); tests must reset hub state.
- **Rejection Reason**: Ownership per GDD (each GDD names the owner of its event) would not be enforced by the code.

### Alternative 2: Systems connect themselves in `setup` / `_init`
- **Description**: Each consumer receives the producers it needs and connects in its own setup.
- **Pros**: No central wiring function.
- **Cons**: The graph is spread over ten files; consumers hold producer references (more cycle risk under ADR-0006); hard to see the RD-19 ordering problem.
- **Rejection Reason**: One readable wiring function is worth one extra file for a one-person team.

### Alternative 3: Rely on signal connection order for same-frame ordering
- **Description**: Connect Dialogue last so it hears the verdict before the offer, etc.
- **Pros**: No queue.
- **Cons**: Connection call order is NOT SOURCEABLE for 4.7; the RD-19 inversion comes from call nesting (`hint_counter` runs before `verdict_given`), which no connection order fixes.
- **Rejection Reason**: Fragile and does not solve the actual inversion.

### Alternative 4: Use the EventBus for control
- **Rejection Reason**: Rejected by ADR-0004 (Principle 5 — events record, signals control).

## Consequences

### Positive
- Every cross-system link is listed once (§4) and connected once (`GameplayWiring`).
- RD-19 / rule 7a ordering is guaranteed by the queue, not by call timing.
- Ten GDD ambiguities are resolved without changing a game rule.
- Integration tests can build the full graph through `ServicesFactory` and assert line order with a `FakeClock`.

### Negative
- A deferred-call delay (same frame) before a character line appears — invisible next to `reaction_hold` timing; outcome objects on the work surface are not delayed.
- `GameplayWiring` must be edited with every new link.
- Two Callables and two payload classes to maintain.

## Risks
- **A consumer kept alive only by a connection** is freed and its signals silently go nowhere (probed). Mitigation: ownership rule in the guidelines; `GameplayWiring` asserts each consumer is a `Services` field.
- **Input in popups / subwindows** — sourced 2026-10-16: the main tree's `_input` receives nothing while an embedded dialog or popup is open. Mitigation: `InputActivity` reads `root.window_input` (probed: receives events with a dialog open); `draft_edited` backup; check in the first workbench build. A non-embedded (native) window would need its own `window_input` connection — none is planned at MVP.
- **A consumer secretly depends on another's reset** (Restart). Mitigation: §6 rule + a test that runs Restart with connections in reversed order.
- **Queue starvation / a line never shown** if a flush is skipped. Mitigation: the queue re-arms its deferred flush on every enqueue; RD-19 and rule 7a integration tests.
- **`InputActivity` misses IME composition input** (composition events may not be `InputEventKey` on every platform — NOT SOURCEABLE). Mitigation: also stamp activity from the Workbench's `draft_edited`; verify with the IME probe (ADR-0008).
- **Payload drift** from GDD wording (e.g. a GDD later adds a field). Mitigation: §4 is the contract; GDD edits that add fields must update this ADR (Implementation Guidelines).

*Engine validation (godot-specialist, 2026-10-16, probed on 4.7.2 headless): no blocking findings; advisories folded in — connections do not keep targets alive (ownership rule), deferred flush is per synchronous chain not per frame (batch wording, synchronous `skip_offered`), `call_deferred` order across objects not relied on, F9 filtered explicitly, pan gesture counted, `PROCESS_MODE_ALWAYS`, typed handlers as the type guard, `match` → `rows_match`. TD-ADR skipped — lean mode.*

*Architecture review 2026-10-16 (fresh session): verifier side effects split out (`grade()`), `root.window_input` for activity, GDD links completed (Run errors, challenge signals, `request_shown`, explainer, Onboarding and side lines, Restart consumers); deferred-flush batch confirmed by probe on condition of no `await` before enqueue.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| hidden-data-grader.md | Rule 14 / AC-18: verdict to Workbench, Dialogue, Progression; never hidden details to presentation | `Verdict` return + `verdict_given`; `DialogueFeedback` (§2–4) — TR-grader-007 |
| request-and-reaction-dialogue.md | Rules 2, 6, RD-09: Kenji voices Run errors; `error_text` passes unchanged except CONTENT_ERROR / TOO_MANY_ROWS | `run_started`, `run_finished(…, feedback)`, `DialogueFeedback.source`, `error_text` rule (§2, §4) |
| constraint-challenges.md | Rules 6, 9.3: offer, expiry, clear / rule broken; Progression marks | `challenge_offered`, `challenge_offer_expired`, `challenge_resolved`; offer merged into the pass bubble (§4, §5) — TR-challenge-003 |
| shift-and-chapter-progression.md / constraint-challenges.md | PR-02, PR-20, CC 6b: next request `Open` at PASS, shown after the hold; side requests `Open` at briefing end, Manual unlock on first open | `request_opened` (state) vs `request_shown` (display) (§4) |
| query-workbench.md | Rule 11: one-time first-Submit explainer | `line_requested`; priority 2, after the verdict reaction (§5) |
| hint-system.md / hidden-data-grader.md | Hint rule 4b: `hint_counted` before the `submit` event | §3 pipeline order with `hint_counter` — TR-grader-006 |
| hint-system.md | Formulas `active_time`: `last_input_t`, focused, not paused | `InputActivity` + Clock + own pause state (§7) — TR-hint-003 |
| request-and-reaction-dialogue.md | Edge Cases queue, RD-19: FAIL line then `skip.offer` | Reaction queue (§5) — TR-dialogue-006 |
| shift-and-chapter-progression.md | Rule 7a: `error.CONTENT_ERROR` then `skip.offer` | Reaction queue priority (§5) |
| constraint-challenges.md | Rules 6–6b, Hint rule 12: challenge mode open/closed to Hint, Dialogue, Workbench, Progression | `challenge_mode_changed` (§4) — TR-challenge-003 |
| shift-and-chapter-progression.md | Rule 12a: Restart reset of Workbench, Grader counters, Hint; confirmation when the draft is non-empty | `request_restarted` + `draft_is_empty` Callable (§4, §6) |
| request-and-reaction-dialogue.md | Rule 3c: briefing end opens the first main request; side messages after | `briefing_finished` (§4) |
| onboarding-first-shift.md | Rule 1: answer to "Ever used SQL?" opens 1-1; rule 7 suppression window; rule 7a mark Done triggers | `choice_made` → `sql_question_answered`; `guided_window_changed`; Workbench / Manual signals (§4) |
| store-manual.md | Rule 5: unlock on first open of a request listing the page | `request_opened` → `page_unlocked` (§4) |
| query-workbench.md | Rule 14: Restart reset; draft-empty state | §6, `draft_is_empty` |

## Performance Implications
- **CPU**: negligible — a few signal emissions per player action; one deferred flush per batch with lines pending.
- **Memory**: two small records per submit.
- **Load Time**: none (wiring is one function at boot).
- **Network**: none.

## Migration Plan
No production code exists. The first story of the Grader or Workbench epic
creates `Verdict`, `DialogueFeedback` and `GameplayWiring`; each later epic adds
its rows to `connect_all`.

## Validation Criteria
- RD-19 and Progression rule 7a integration tests (FakeClock) pass with `GameplayWiring` connections in forward and reversed order.
- A Restart test asserts identical post-Restart state in both connection orders.
- HS-03/HS-04 pass with `InputActivity` fed by synthetic `InputEventKey` and a `FakeClock`; an integration test with an `AcceptDialog` open still stamps activity.
- `ContentVerifier.verify_all` emits no `verdict_given`, no `submit` event and no `hint_counter` call (test with spies).
- A first Submit that FAILs shows the FAIL line, then the explainer; a PASS with a challenge offer shows one bubble.
- A test asserts `DialogueFeedback.from_verdict` drops `error_text` for `CONTENT_ERROR` and `TOO_MANY_ROWS`.

## Related
- ADR-0004 — events record, signals control; `hint_counter` exception
- ADR-0006 — `ServicesFactory`, `Clock`, one-way ownership
- ADR-0007 — string ids for lines and statements
- `docs/architecture/architecture-review-2026-10-15.md` — C4, TR-grader-006/007, TR-challenge-003, TR-dialogue-006, TR-hint-003
- `docs/architecture/architecture-review-2026-10-16.md` — X1–X3, S1–S10, E1, E7, E8
- GDDs: hidden-data-grader, hint-system, request-and-reaction-dialogue, shift-and-chapter-progression, constraint-challenges, onboarding-first-shift, store-manual, query-workbench
