# Playtest Log

> **Status**: In Review
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14 (2026-10-14 cross-GDD review fixes; art-bible sync 2026-10-14)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Supports all pillars by measuring them (MVP Definition thresholds in `game-concept.md`)

## Summary

The Playtest Log records what testers actually do in a playtest build — every
Run and Submit with its query, every verdict, hint, skip, manual page and
challenge — to a local file, and a small report tool turns those files into the
numbers the concept's MVP thresholds ask for. It exists because the first
playtest kept no log and could not answer whether the traps bite. It is off in
release builds, never sends anything over the network, and shows a visible
"recording" label whenever it is on.

> **Quick reference** — Layer: `Polish` · Priority: `MVP` · Key deps: `Hidden-Data Grader, Query Workbench, Hint System`

## Overview

The concept's MVP Definition is a table of measurable claims — players finish
Chapter 1 without outside help, start a constraint challenge when offered, fail
1-6 or 1-11 on their first submit, clear 1-1 to 1-3 with zero SQL — and the
concept prototype report admits the first playtest recorded none of it. The
Playtest Log is the instrument: every system already designed names the events
it sends here (grader submits and verdicts with per-dataset results, workbench
runs with their SQL, hint unlocks and opens, skips, manual pages, onboarding
marks, challenge offers). The log writes them, in order, with timestamps, to one
file per session on the tester's machine, tagged with an anonymous tester id and
group ("zero-SQL" / "some-SQL") that the facilitator enters. A facilitator key
marks the moments the tester received outside help — the one thing the game
cannot detect. A report tool (developer-side, in `tools/`) reads the files and
prints the threshold table. Players of the released game never meet this system.

## Detailed Design

### Core Rules

**When it is on**

1. The log runs only in builds with the **playtest flag** on. In release builds it
   is compiled in but disabled and writes nothing. When on, a small "● Recording
   playtest" label is always visible in a screen corner.
2. At the start of a playtest session the facilitator enters a **tester id**
   (free text, e.g. `T1` — no names) and a **group** (`zero-SQL` / `some-SQL` /
   `other`). Both are written to the session header.

**What is recorded**

3. Each event is one line in a JSON Lines file: `t_ms` (since session start, from
   a monotonic clock), `wall` (ISO time, for ordering sessions), `session`,
   `build`, `event`, `puzzle` (id, when relevant), `content_hash` (the puzzle's
   content hash, so a log is tied to the exact puzzle version — Puzzle Definition
   States), and an event-specific `data` object.
4. The event catalogue below is **canonical**: it is the union of what each
   system sends, and each sending GDD uses these exact names (their ACs cite
   this rule). The MVP catalogue:

| Source | Events (data) |
|---|---|
| Session | `session_start {tester, group, build}`, `session_end`, `help_given {note}` (facilitator key) |
| Query Workbench | `run {sql, dataset: visible/scratch, ok, error_kind, rows, match: bool, build_message?}`, `edit_burst {chars_changed}` (edits between actions, coalesced) |
| Hidden-Data Grader | `submit {sql, verdict, cause, level, per_dataset, missing_count, extra_count, hint_counted: bool, build_message?}` |
| Hint System | `hint_unlock {step}`, `hint_open {step}`, `hint_exhausted` |
| Shift & Chapter Progression | `request_open`, `request_pass`, `request_skip`, `request_unavailable`, `shift_clockout`, `chapter_complete {starred}` |
| Constraint Challenges | `challenge_offer`, `challenge_try`, `challenge_later` (also written when an unanswered offer expires), `challenge_start {source}`, `challenge_attempt {verdict, rule_met}`, `challenge_clear` |
| Store Manual | `manual_unlock {page}`, `manual_open {page}`, `manual_copy {page}` |
| Onboarding | `sql_question {answer}`, `mark_shown/done/dismissed {mark}` |
| Request & Reaction Dialogue | `line_shown {line_id, kind, speaker}` (canonical form: the puzzle id travels in the common `puzzle` field, never a `puzzle_id` data field), `log_opened`, `line_skipped` |

   A system adds an event by declaring it in its GDD and here; the log rejects
   (and counts) undeclared event names rather than writing free-form data.
4a. **Field notes.** `submit` is emitted by the Hidden-Data Grader only (the
   Workbench emits `run`, never `submit`); `verdict` is PASS, FAIL,
   SUBMIT_ERROR or UNAVAILABLE. `run.dataset` names the dataset the Run used
   (`visible` / `scratch`), distinct from the common `data` object. `run.match`
   is the boolean visible-data match bit (true = the Run's result matches the
   reference on the visible dataset; false otherwise or when not applicable).
   `submit.hint_counted` is true when the FAIL counted toward hint unlocking
   (Hint System rule 4a — its normalized query text differs from the previous
   counted FAIL's); false for every other submit. `build_message` is present
   only on a `run` whose `error_kind` is CONTENT_ERROR or a `submit` whose
   verdict is UNAVAILABLE: it carries the sandbox's dataset build message, and
   this log (and the content-bug report built from it) is the **only** place it
   appears — it never reaches the player. First-Run and first-pass times are
   computed by the report from `run` and `request_pass` (Formulas); there are no
   `first_run` / `first_pass` events.
5. **Player SQL is recorded verbatim** on Run and Submit — it is the evidence for
   "do the traps bite?". Nothing else the tester types is recorded, and no system
   information beyond the build id (no OS user name, hostname or paths). The
   facilitator's setup answers and F9 notes are the only other typed text.
6. Hidden-dataset details (per-dataset results, missing/extra counts) are recorded
   **only here**; this file is developer-facing and is never shown in game
   (Hidden-Data Grader rule 11).

**Facilitator help**

7. The facilitator presses **F9** whenever they help the tester (answer a
   question, point at something). The log writes `help_given` for the current
   puzzle at once. F9 also opens a small one-line note field; typing a note is
   optional, and Enter or Esc closes it and returns keyboard focus to the editor
   (if no key is pressed within 5 s it closes by itself). This is how "without
   outside help" is measured.

**Writing safely**

8. Events are appended and flushed one at a time, so a crash loses at most the
   event being written. A write failure (disk full, permission) disables the log
   for the session, shows "Recording stopped" in the corner label, and never
   affects gameplay.
9. Files go to the user data folder: `playtest-logs/<session>.jsonl`. Nothing is
   sent over the network; collecting files is a manual step after the session.

**Report**

10. A developer tool `tools/playtest-report` reads a folder of session files and
    prints, per tester and per group, the metrics in Formulas and the concept's
    MVP threshold table with met / missed / insufficient data for each claim —
    observations, not a verdict on the game (the developer reads them in
    `/playtest-report`). Usage: `tools/playtest-report <folder>`; output is a
    Markdown report; times in seconds to one decimal, rates to two decimals.

### States and Transitions

Per session: `Disabled` (release build, or playtest flag off) · `AwaitingSetup`
(tester id + group prompt) → `Recording` → `Ended` (quit or `session_end`), or
`Recording → Stopped` (write failure; gameplay continues).

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Every MVP system (table, rule 4) | System → Log | Declared events | Each system declares; Log records |
| Puzzle Definition & Datasets | Puzzle → Log | Puzzle id and content hash | Puzzle Definition |
| Game build configuration | Build → Log | Playtest flag, build id | Build pipeline (→ ADR) |
| `tools/playtest-report` | Log files → tool | JSONL session files | Playtest Log |
| `/playtest-report` skill | Tool output → report | Metric table for the written playtest report | Developer |

## Formulas

*Proposed by `systems-designer` (2026-10-14); two choices aligned with other
GDDs: idle gaps are **capped** at the cutoff (as the Hint System's
`active_time` does), and "finish Chapter 1" **allows in-game skips** (the design
offers them; only outside help breaks the claim) while "can start" requires
passes.*

**Shared definitions.** A *tester stream* is all of a tester's sessions merged in
`wall` order; `T(e)` is cumulative play time (session gaps count 0). A *real
verdict* is a `submit` with verdict PASS or FAIL; a SUBMIT_ERROR or UNAVAILABLE
is never one. A
*pass* on p is a `request_pass` on p.

The **time_to_first_run** formula is defined as:

`time_to_first_run = T(first run) − T(first request_open)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T(first run) | int (ms) | ≥ 0 | data file | Time of the tester's first `run` |
| T(first request_open) | int (ms) | ≥ 0 | data file | Time the first request opened |

**Output Range:** ≥ 0 s; null if the tester never ran. (`time_to_first_pass` is
the same with `request_pass`, null if the tester never passed. The two are
independent: a tester may pass before any Run — Onboarding lets 1-1 be
submitted unrun (OB-06) — so `time_to_first_pass` can be smaller. Both are
computed here from `run` and `request_pass`; no system sends a dedicated
first-run or first-pass event.)
**Example:** request opened at 12 s, first Run at 47 s → 35 s.

The **puzzle_active_time** formula is defined as:

`puzzle_active_time(p) = Σ min(gap_i, idle_cutoff_s)` over consecutive events from the first `request_open(p)` to the first `request_pass(p)` or `request_skip(p)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| gap_i | float (s) | ≥ 0 | calculated | Time between consecutive events in the window |
| idle_cutoff_s | int (s) | 30–300 (default 90) | data file | Longest gap credited as active — the same **global** config value the Hint System reads (global-only, never per-puzzle) |

**Output Range:** 0 to the window length; "unsettled" (excluded from medians) if
p was opened but never passed or skipped. Every recorded event, including
`edit_burst`, counts as a point in the gap sequence.
**Example:** events at 0, 20, 50, 200, 230 s (pass) → 20 + 30 + 90 + 30 = 170 s.

The **first_submit_failed** formula is defined as:

`first_submit_failed(p) = (verdict of the first real-verdict submit on p) = FAIL`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| submits(p) | ordered list | 0–n | data file | `submit` events on p |

**Output Range:** true / false / null (no real verdict on p). SUBMIT_ERRORs before
it are skipped, matching the grader (they are not attempts).
**Example:** SUBMIT_ERROR, FAIL, PASS on 1-6 → true.

The **cleared_without_help** formula is defined as:

`cleared_without_help(tester, P) = ∀p ∈ P: pass(p) ∧ no help_given with puzzle = p before that pass`

**Output Range:** boolean; a skip is not a clear; a `help_given` with no puzzle
counts for no puzzle.
**Example:** P = {1-1, 1-2, 1-3}, all passed, the only `help_given` on 1-4 → true.

The **finished_chapter_without_help** formula is defined as:

`finished_chapter_without_help(tester) = chapter_complete ∧ no help_given on a Chapter 1 puzzle before that puzzle was passed or skipped`

**Output Range:** boolean. In-game skips are allowed (predicate unchanged). The
report always prints the claim together with each tester's **skip count** and
whether the **boss (1-11) was skipped** (side metric, e.g. "finished — 1 skip,
boss skipped"), and the Finish row of the threshold table shows, beside the
count, how many of the testers counted had ≥ 1 skip and how many skipped the
boss.
**Example:** chapter complete, 1-11 left for Kenji, no F9 presses → true (1 skip,
boss skipped).

The **started_challenge_when_offered** formula is defined as:

`started_challenge_when_offered(tester) = ∃ challenge_offer o, ∃ challenge_try or challenge_start{source = offer} after o with no help_given between them`

**Output Range:** true / false / null (never offered — excluded). "Next chapter"
starts are reported as `n/a` (no Chapter 2 in the MVP). `challenge_later` alone is
not a start.
**Example:** offer, then Try 40 s later, no help → true.

The **boss_skip_rate**, **hint_before_first_fail** and **run_then_fail** formulas are defined as:

`boss_skip_rate = testers with request_skip(1-11) / testers who opened 1-11`
`hint_before_first_fail(p) = count(hint_open on p before the first FAIL on p)`
`run_then_fail(p) = matching visible Runs whose next real verdict on p is FAIL / matching visible Runs followed by a real verdict on p`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| run.match | bool | true / false | data file | Visible-data match bit of a Run (a *matching visible Run* has `dataset = visible` and `match = true`) |

**Output Range:** rates 0–1 or null (empty denominator, printed "no data", never
0%); counts ≥ 0.
**Example:** three matching visible Runs each followed by a submit, two of them FAIL →
`run_then_fail` = 0.67 (how often the visible data misleads — the core "aha").

The **threshold_claims** formula is defined as:

`claim_met(c) = count(testers in group g with predicate true) ≥ bar(c)`, with
`bar(c) = ceil(ratio(c) × eligible testers in g)` and the ratios 2/3 (Finish, Traps
bite, Can start) and 4/6 (Wants more) — the concept's bars for 3 + 3 testers,
kept as proportions for larger groups

| Claim | Group | Predicate | Bar (from the concept) |
|---|---|---|---|
| Finish | zero-SQL and some-SQL, each | `finished_chapter_without_help` (reported with skip count and boss-skipped flag) | 2/3 in each (≥ 2 of 3) |
| Wants more | both groups | `started_challenge_when_offered` | 4/6 (≥ 4 of 6) |
| Traps bite | some-SQL | `first_submit_failed(1-6) ∨ first_submit_failed(1-11)` | 2/3 (≥ 2 of 3) |
| Can start | zero-SQL | `cleared_without_help(tester, {1-1, 1-2, 1-3})` | 2/3 (≥ 2 of 3) |

**Output Range:** counts ("2/3"), then `met` / `missed` / `insufficient data`
(fewer than 3 eligible testers in a group, or fewer than 6 for "Wants more").
Null predicates are excluded and shown as n/a; group `other` is excluded from
claims but kept in puzzle metrics.
**Example:** some-SQL results true, false, false → 1 of 3, bar 2 → `missed`;
results true, null, null → 1 eligible → `insufficient data`.

**Degenerate inputs:** a crashed session ends at its last event (flagged); a
tester whose group changes between sessions keeps the first group (flagged); a
puzzle whose `content_hash` changes is split per hash and mixed-hash testers are
excluded from claims on it.

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the build is a release build**: no prompt, no label, no file — verified by searching the user data folder after a release-build session.
- **If the facilitator leaves the tester id blank**: `anonymous` plus a short random suffix; group `other`.
- **If the game crashes**: the file ends at the last flushed event; the report treats a session without `session_end` as ended at its last event and flags it.
- **If the tester plays two sessions**: two files with the same tester id; the report merges them in `wall` order.
- **If a puzzle's content changes between sessions**: `content_hash` differs; the report splits that puzzle's metrics by hash and warns.
- **If F9 is pressed with no puzzle open**: `help_given` with `puzzle: null`.
- **If an undeclared event name is sent**: not written; a counter `undeclared_events` is written at `session_end`.
- **If the tester types something sensitive into the editor**: it is recorded (SQL is recorded verbatim) — the playtest consent note (UI Requirement 1) tells testers this.

## Dependencies

**Upstream (hard):** every MVP system that declares events — Hidden-Data Grader,
Query Workbench, Hint System, Shift & Chapter Progression, Constraint
Challenges, Store Manual, Onboarding, Request & Reaction Dialogue — and Puzzle
Definition (content hash). All In Review; each lists the
Playtest Log in its Interactions ✓.

**Upstream (soft):** SQL Execution Sandbox — its `build_message` reaches this
log only as the optional field on `run` (CONTENT_ERROR) and `submit`
(UNAVAILABLE), carried by the Workbench and the Grader; the Sandbox emits no
events of its own.

**Downstream:** `tools/playtest-report`, the `/playtest-report` skill, and the
concept's MVP threshold table.

## Visual/Audio Requirements

None in game beyond the corner label ("● Recording playtest" / "Recording
stopped"), glyph + words, ≥ 4.5:1, never over the editor or tables. The ● is
**`ink`, not red** — red is reserved for the Submit verdict (art bible 4.5, 4.6).

## UI Requirements

1. Setup prompt (playtest builds only): tester id, group, and a one-line consent
   note ("This session records your actions and the SQL you type, on this
   computer only").
2. Corner label while recording.
3. F9 help marker with an optional note field: it holds focus only while open
   (the facilitator should press F9 when the tester's hands are off the
   keyboard) and returns it to the editor on Enter, Esc or 5 s idle (rule 7).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/game-concept.md` | Overview, Rule 10, Formulas | MVP Definition threshold table | Source of intent |
| `prototypes/sqlbini-web/REPORT.md` | Overview | First playtest kept no log | Evidence |
| All MVP GDDs in `design/gdd/` | Rule 4 | Their declared events (must use the canonical names) | In Review |
| `design/gdd/hidden-data-grader.md` | Rule 6 | Hidden details may appear only in this developer-facing log | In Review |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Other GDDs assert that their own events are
sent; these cover the log and the report tool. [UI] = retained screenshot in
`production/qa/evidence/`.*

**Recording**
- **PL-01 [Integration]** GIVEN a release build, WHEN a full session is played and quit, THEN no setup prompt or corner label appears and a listing of `playtest-logs/` before and after is identical.
- **PL-02 [UI]** GIVEN the playtest flag, WHEN the game starts, THEN the prompt shows a tester id field, a group choice (`zero-SQL` / `some-SQL` / `other`) and the consent note; afterwards "● Recording playtest" stays in a corner, never over the editor or tables, ≥ 4.5:1; a blank id is recorded as `anonymous-<suffix>`, group `other`.
- **PL-03 [Logic]** GIVEN a recording session, THEN every line parses as JSON with `t_ms, wall, session, build, event, puzzle, content_hash, data`; the first line is `session_start {tester, group, build}`; `t_ms` never decreases even if the system clock is set back.
- **PL-04 [Logic]** GIVEN an undeclared event name sent twice, THEN no line is written for it and `session_end.data.undeclared_events = 2`.
- **PL-05 [Integration]** GIVEN the tester runs and submits `SELECT 'é' -- "x"`, THEN `data.sql` equals the editor text byte for byte on both events; the file contains no OS user name, hostname or path, and the tester id only in `session_start`.
- **PL-06 [UI]** GIVEN a FAIL submit, THEN the file holds `per_dataset`, `missing_count`, `extra_count`, and the in-game verdict shows none of them.
- **PL-07 [Integration]** GIVEN N events flushed and the process killed, THEN the file holds ≥ N lines and every complete line parses.
- **PL-08 [Integration]** GIVEN the log folder made read-only mid-session, THEN the label reads "Recording stopped", nothing more is written, Run and Submit still work, no error dialog, and frame time stays within the 16.6 ms budget.
- **PL-09 [Integration]** GIVEN a full session, THEN the only file written is `playtest-logs/<session>.jsonl` and no network socket is opened.
- **PL-17 [Integration]** GIVEN 1-5 open, WHEN the tester submits FAIL `SELECT 1`, then FAIL `select 1;`, then FAIL `SELECT 2`, THEN three `submit` lines (all from the grader, none from the workbench) carry `hint_counted` true, false, true; GIVEN a visible Run whose result matches, THEN `run.dataset = "visible"` and `run.match = true`; GIVEN a dataset that fails to build, THEN the `run` (error_kind CONTENT_ERROR) or `submit` (verdict UNAVAILABLE) line carries `build_message`, and no other line, and no in-game text, contains it; no `first_run` / `first_pass` lines are ever written.
- **PL-10 [Integration]** GIVEN 1-4 open, F9 writes `help_given {puzzle: 1-4}` at once; with no puzzle open, `puzzle: null`; after Enter, Esc or 5 s idle in the note field, the editor has keyboard focus again.

**Report tool** (`tools/playtest-report <folder>`, fixture logs)
- **PL-11 [Tool]** THEN `time_to_first_run` = 35.0 s; `puzzle_active_time` = 170.0 s (events 0, 20, 50, 200, 230 s; cap 90); `first_submit_failed(1-6)` = true for SUBMIT_ERROR, FAIL, PASS; `cleared_without_help` = true when the only help is on 1-4; `finished_chapter_without_help` = true with 1 skip and no help (printed with "1 skip, boss skipped" when the skip is 1-11), false with help on 1-5 before its pass; `started_challenge_when_offered` = true for offer → Try with no help, null when never offered; `boss_skip_rate` = 0.50; `run_then_fail` = 0.67; an empty denominator prints "no data", never 0%.
- **PL-12 [Tool]** THEN Finish (zero-SQL) 3 true → `met`, printed with how many of the 3 had ≥ 1 skip and how many skipped the boss; Traps bite (some-SQL) 1 true, 2 false → `missed`; Can start with 2 eligible testers → `insufficient data`; null predicates n/a; a group of 6 uses bar 4 for 2/3 claims.
- **PL-13 [Tool]** GIVEN two sessions with one tester id, THEN they merge in `wall` order with the gap counted as 0; a changed group keeps the first and is flagged.
- **PL-14 [Tool]** GIVEN 1-6 under two `content_hash` values, THEN its metrics split per hash with a warning and mixed-hash testers are excluded from claims on 1-6.
- **PL-15 [Tool]** GIVEN a session without `session_end`, THEN it ends at its last event and is flagged "crashed".
- **PL-16 [Tool]** GIVEN an `other`-group tester, THEN they appear in puzzle metrics and in no claim count.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | File format and writer technology (Godot `FileAccess` JSONL; flush cost) | technical-director → ADR | Technical Setup |
| 2 | Should a later opt-in, anonymised analytics system for the released game reuse this event catalogue? (Out of MVP scope.) | analytics-engineer | Post-launch planning |
| 3 | Should the web prototype (`prototypes/sqlbini-web`) get the same logging for a quick re-test before the engine build exists? | developer | Before the zero-SQL playtest |
