# Architecture Traceability Index
Last Updated: 2026-10-15
Engine: Godot 4.7.2 + godot-sqlite v4.9
Source review: `docs/architecture/architecture-review-2026-10-15.md` (+ post-review ADR amendments and acceptance, same day) · IDs: `docs/architecture/tr-registry.yaml`

## Coverage Summary
- Total requirements: 60
- Covered by an Accepted ADR: 33 (55%)
- Covered by a Proposed ADR: 0
- Partial: 5
- Gaps: 19 (of which 6 wait on ADR-0005, pending the Windows spike)
- No ADR needed: 2 · Deferred (VS): 1

## ADR Status
| ADR | Title | Status |
|---|---|---|
| ADR-0001 | Sandbox execution and timeout | Accepted (2026-10-15, amended after review) |
| ADR-0002 | Sandbox API and lexer contract | Accepted (2026-10-15, amended after review) |
| ADR-0003 | Puzzle data format, loader and verifier | Accepted (2026-10-15, amended after review) |
| ADR-0004 | Event bus and playtest log | Accepted (2026-10-15, amended after review) |
| ADR-0005 | Platform, display and performance baseline | **Not written — pending Windows godot-sqlite `.dll` spike** |
| ADR-0006 | Composition root and service wiring | Accepted (2026-10-15, amended after review) |
| ADR-0007 / 0008 / 0009 | Config + strings / Workbench editor / Counter strip | Planned |
| ADR-0010 | Gameplay signal contracts | Proposed by this review |

## Full Matrix
| TR-ID | GDD | Source | Requirement | ADR | Status | Note |
|---|---|---|---|---|---|---|
| TR-sandbox-001 | sql-execution-sandbox.md | r.2 | Fresh in-memory DB per `query` request, destroyed after | 0001, 0002 | ✅ Covered (Accepted) |  |
| TR-sandbox-002 | sql-execution-sandbox.md | r.5-9 | Lexer-based statement check before execution: one statement, EMPTY, verb rules, `WITH RECURSIVE` rejected | 0002 | ✅ Covered (Accepted) |  |
| TR-sandbox-003 | sql-execution-sandbox.md | r.5a | `tokenize(sql) -> Array of {kind, text}` exposed to Hints and Challenges | 0002 | ✅ Covered (Accepted) |  |
| TR-sandbox-004 | sql-execution-sandbox.md | r.10-13 | Temp-view wrapper, column metadata for zero rows, positional rows, `fetch_limit = grader_row_cap + 1`, `truncated` | 0002 | ✅ Covered (Accepted) |  |
| TR-sandbox-005 | sql-execution-sandbox.md | r.15, SB-19 | Execution never on the frame thread; frame <= 16.6 ms during any query | 0001 | ✅ Covered (Accepted) |  |
| TR-sandbox-006 | sql-execution-sandbox.md | r.15, SB-18 | `TIMEOUT` delivered within `exec_time_limit` + 50 ms; next request succeeds | 0001 | ✅ Covered (Accepted) | Guarantee = limit + one frame; runner PROCESS_MODE_ALWAYS (ADR-0001 amended) |
| TR-sandbox-007 | sql-execution-sandbox.md | r.16 | Result record (status, error_kind, error_text, build_message, columns, column_count, rows, truncated, rows_changed, elapsed_ms) | 0002 | ✅ Covered (Accepted) |  |
| TR-sandbox-008 | sql-execution-sandbox.md | r.4, r.14 | Scratch DB lifecycle (Alpha - Back Room); API must not preclude it | 0001, 0002 | ✅ Covered (Accepted) | Alpha |
| TR-sandbox-009 | sql-execution-sandbox.md | SB-20 | p95 <= 25 ms per execution on the target PC | 0005 (planned) | ❌ Gap |  |
| TR-sandbox-010 | sql-execution-sandbox.md | r.4a, SB-09 | SQLite extensions are never enabled (`load_extension` -> `not authorized`) | 0002 | ✅ Covered (Accepted) | ADR-0002 s5 step 1 (amended 2026-10-15) |
| TR-puzzle-001 | puzzle-definition-and-datasets.md | r.1-2 | Chapter definition (schema, base datasets, shifts) + puzzle definitions; text, diffable, data-driven | 0003 | ✅ Covered (Accepted) |  |
| TR-puzzle-002 | puzzle-definition-and-datasets.md | r.5 | Dataset overrides (`add`/`remove`/`set`/`reverse`/`renumber`) resolved at load | 0003 | ✅ Covered (Accepted) |  |
| TR-puzzle-003 | puzzle-definition-and-datasets.md | r.10-14, L-04 | Content verifier (`puzzle_valid`) runs identically in CI and at game load | 0003 | ✅ Covered (Accepted) | C1/C2 fixed: separate ContentVerifier, 6 in flight (ADR-0003 amended) |
| TR-puzzle-004 | puzzle-definition-and-datasets.md | States, L-01, L-06 | Content hash over a canonical serialisation, excluding `content_status` and the hash | 0003 | ✅ Covered (Accepted) |  |
| TR-puzzle-005 | puzzle-definition-and-datasets.md | States | Runtime `loaded`/`withheld` by build flavour (dev allows all; playtest/release only verified+) | 0003, 0004 | ✅ Covered (Accepted) |  |
| TR-puzzle-006 | puzzle-definition-and-datasets.md | r.3 | Target result computed from `reference_sql`, never stored | 0003 | ✅ Covered (Accepted) |  |
| TR-puzzle-007 | puzzle-definition-and-datasets.md | HS-13, SM-14..17, CC-11/12, OB-18 | Non-puzzle content checks (hints, manual, challenges, ghost text) run in CI, with a defined load-time scope and result | 0003 | ✅ Covered (Accepted) | ADR-0003 s4: CI only; game load runs puzzle checks + hash (amended) |
| TR-grader-001 | hidden-data-grader.md | r.5-9a | Submit pipeline: pre-check, determinism, per-dataset grading, early stop on hidden TIMEOUT, UNAVAILABLE | 0001, 0002 | ✅ Covered (Accepted) |  |
| TR-grader-002 | hidden-data-grader.md | r.8 | Reference results cached per puzzle + dataset for the session | 0003 | ✅ Covered (Accepted) |  |
| TR-grader-003 | hidden-data-grader.md | Formulas | `canon` / `result_match` / `tie_list_eq` - pure functions, unit-testable | - (GDD formulas are the spec) | ➖ No ADR needed |  |
| TR-grader-004 | hidden-data-grader.md | r.11 | Missing/extra rows never reach player or Dialogue - only the log | 0004 | ✅ Covered (Accepted) |  |
| TR-grader-005 | hidden-data-grader.md | AC-26 | Submit p95 <= 300 ms, Run p95 <= 200 ms on the target PC | 0005 (planned) | ❌ Gap | Frame-quantised delivery: see sandbox Formulas `submit_worst` |
| TR-grader-006 | hidden-data-grader.md | r.4b (hint), grader Interactions | Grader gets `hint_counted` back from the Hint System synchronously before it emits `submit` | 0004 | ✅ Covered (Accepted) | ADR-0004 s2: injected `hint_counter` Callable (amended) |
| TR-grader-007 | hidden-data-grader.md | r.14, AC-18, RD-05 | Typed verdict fan-out to Workbench, Dialogue (`{verdict, cause, level}` only), Progression, Hints, Challenges | 0004 | ⚠️ Partial | 'Typed signals' named, contract not specified -> ADR-0010 (proposed) |
| TR-workbench-001 | query-workbench.md | r.1-6 | `CodeEdit` editor with SQL highlighting, schema browser, result vs target tables at 1280x720 | 0008 (planned) | ❌ Gap |  |
| TR-workbench-002 | query-workbench.md | r.15, UI Req 4, QW-20 | Keyboard-first: every action has a shortcut; F6 pane cycle; focus ring | 0008 (planned) | ❌ Gap |  |
| TR-workbench-003 | query-workbench.md | r.16 | IME composition committed before Run | 0008 (planned) | ❌ Gap |  |
| TR-workbench-004 | query-workbench.md | Formulas | `ui_scale` 1.0-2.0 through Theme font sizes, not `content_scale_factor` | 0005, 0008 (planned) | ❌ Gap |  |
| TR-workbench-005 | query-workbench.md | r.14 | Reacts to Restart (draft, last Run result, verdict reset) | 0004 | ✅ Covered (Accepted) |  |
| TR-workbench-006 | query-workbench.md | States, QW-12, QW-16 | A newer Run supersedes one in flight; the older result is discarded | 0002 | ✅ Covered (Accepted) | ADR-0002 s6: sequence-numbered Runs (amended) |
| TR-workbench-007 | query-workbench.md | UI Req 7, OQ3 | Screen-reader labels through AccessKit, including `CodeEdit` | 0008 (planned) | ❌ Gap |  |
| TR-workbench-008 | query-workbench.md | r.14, QW-18; CC r.6c | Per-puzzle session state (draft, last result, verdict, challenge draft, counters, hint state) kept as plain serialisable data | 0006 | ⚠️ Partial | Stated in architecture.md Save/load, not in an ADR |
| TR-hint-001 | hint-system.md | Formulas, HS-03, HS-04 | `active_time` from clamped per-frame time x window focus x shown x idle cutoff, not paused; fake-clock testable | 0006 | ✅ Covered (Accepted) | ADR-0006 s5: Clock-sampled ticks, clamp, pause from owner state (amended) |
| TR-hint-002 | hint-system.md | r.4a-4b | Distinct-query counting via `tokenize` normalization; returns `hint_counted` | 0002 | ✅ Covered (Accepted) |  |
| TR-hint-003 | hint-system.md | Formulas (`last_input_t`, not paused) | Input-activity feed from workbench, manual and hint panel, plus a pause state | none | ❌ Gap | -> ADR-0006 amendment or ADR-0010 |
| TR-challenge-001 | constraint-challenges.md | r.3-5 | `forbid`/`require` keyword checks on `WORD` tokens (MVP); `canonical_length` for `max_chars` is Alpha | 0002 | ✅ Covered (Accepted) |  |
| TR-challenge-002 | constraint-challenges.md | r.9.2 | Per-challenge counter set supplied to the grader | - (GDD spec) | ➖ No ADR needed |  |
| TR-challenge-003 | constraint-challenges.md | r.6-6b, hint r.12 | Challenge-mode open/closed event consumed by Hints, Dialogue, Workbench, Progression | 0004 | ⚠️ Partial | -> ADR-0010 (proposed) |
| TR-progression-001 | shift-and-chapter-progression.md | r.1-12a, r.13 | Request/shift/chapter state machine; Restart event; session-only persistence at MVP | 0006 | ✅ Covered (Accepted) |  |
| TR-progression-002 | shift-and-chapter-progression.md | r.13 | No save at MVP; VS Save/Load must be able to serialise this state | deferred (VS Save/Load ADR) | ⏸ Deferred |  |
| TR-dialogue-001 | request-and-reaction-dialogue.md | r.9 | String tables keyed by id; missing id -> `[id]` in dev, generic line in release, logged | 0007 (planned) | ❌ Gap |  |
| TR-dialogue-002 | request-and-reaction-dialogue.md | Formulas, r.5 | Reveal / hold timers (`reaction_hold`, `reveal_cps`), reduced motion | 0006 | ✅ Covered (Accepted) | Reveal end gates the hold timer, so reveal time must also read Clock |
| TR-dialogue-003 | request-and-reaction-dialogue.md | art bible 8 | Counter strip: 320x30 `SubViewport`, Nearest, palette shader, integer xk, `strip_to_ui()` | 0009 (planned) | ❌ Gap |  |
| TR-dialogue-004 | request-and-reaction-dialogue.md | r.10, RD-11 | Measured bubble paging from laid-out text metrics at runtime (graphemes, r.9) | 0007 / 0008 (planned) | ❌ Gap |  |
| TR-dialogue-005 | request-and-reaction-dialogue.md | RD-12 | CI scan: no player-facing string literals in dialogue code | 0007 (planned) | ❌ Gap |  |
| TR-dialogue-006 | request-and-reaction-dialogue.md | Edge Cases, RD-19 | Cross-system reaction queue (e.g. FAIL then `skip.offer` in the same frame) | none | ❌ Gap | -> ADR-0010 (proposed) |
| TR-manual-001 | store-manual.md | r.1-4 | Page data; CI: examples never pass a puzzle, `watch_out.rule_tag` not in Chapter 1 `trap_rules` | 0003 | ✅ Covered (Accepted) |  |
| TR-onboarding-001 | onboarding-first-shift.md | r.7a, OB-18 | Puzzle-scoped coach marks; ghost-text CI check | 0003 | ⚠️ Partial | Ghost text lives in string tables (ADR-0007, planned) |
| TR-onboarding-002 | onboarding-first-shift.md | UI Req 4, OQ4; dialogue r.5 | Session-only settings (reduced motion, coach marks, `ui_scale`) read by every presentation system | none | ❌ Gap | -> ADR-0007 (planned) scope |
| TR-onboarding-003 | onboarding-first-shift.md | OB-15 | Coach-mark rings follow their targets across resize and `ui_scale` | 0008 (planned) | ❌ Gap |  |
| TR-playtest-001 | playtest-log.md | r.3-4 | Canonical event catalogue; undeclared events rejected and counted | 0004 | ✅ Covered (Accepted) |  |
| TR-playtest-002 | playtest-log.md | r.8-9 | Append + flush per event to `user://playtest-logs/<session>.jsonl`; write failure stops the log, never gameplay | 0004 | ✅ Covered (Accepted) |  |
| TR-playtest-003 | playtest-log.md | r.1 | Playtest flag: compiled in, disabled in release; recording label | 0004 | ✅ Covered (Accepted) |  |
| TR-playtest-004 | playtest-log.md | r.7 | F9 facilitator key + note field returning focus to the editor | 0004 | ✅ Covered (Accepted) |  |
| TR-playtest-005 | playtest-log.md | r.10 | `tools/playtest-report` reads JSONL and prints the threshold table | 0004 | ✅ Covered (Accepted) |  |
| TR-playtest-006 | playtest-log.md | Formulas (`idle_cutoff_s`) | Report tool knows the game's `idle_cutoff_s` (reads config or the log) | 0004 | ⚠️ Partial | ADR-0004 s5 `--config`; config file format is ADR-0007 (planned) |
| TR-playtest-007 | playtest-log.md | r.3 (`build`) | Source of the build id written on every event | 0005 (planned) | ❌ Gap |  |
| TR-platform-001 | game-concept.md | concept (PC/Steam), sandbox OQ4, prefs | Windows + Linux desktop (Steam); godot-sqlite `.dll` must load on 4.7.2 | 0005 (planned) | ❌ Gap |  |
| TR-platform-002 | game-concept.md | art bible 8.9 | Total 2D texture memory <= 64 MB; < 500 draw calls; 60 fps | 0005 (planned) | ❌ Gap |  |
| TR-config-001 | *.md (all Tuning Knobs) | all Tuning Knobs | Every gameplay value from data files with load-time range validation | 0007 (planned) | ❌ Gap |  |


## Known Gaps
| TR-ID | Suggested ADR |
|---|---|
| TR-sandbox-009, TR-grader-005, TR-platform-001, TR-platform-002, TR-playtest-007 | ADR-0005 (after Windows spike) |
| TR-workbench-004 | ADR-0005 + ADR-0008 |
| TR-workbench-001, -002, -003, -007, TR-onboarding-003 | ADR-0008 |
| TR-dialogue-004 | ADR-0007 / ADR-0008 |
| TR-config-001, TR-dialogue-001, TR-dialogue-005, TR-onboarding-002 | ADR-0007 |
| TR-dialogue-003 | ADR-0009 |
| TR-hint-003, TR-dialogue-006 | ADR-0010 (new) |
| TR-playtest-006 | ADR-0007 (config file format; ADR-0004 §5 reads it) |

## Superseded Requirements
None.
