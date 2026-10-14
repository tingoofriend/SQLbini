# Hint System

> **Status**: In Review
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14 (2026-10-14 cross-GDD review fixes)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 3 — Fast Hands, Cheap Mistakes; Pillar 1 — The Condition, Not the Screen

## Summary

The Hint System gives a stuck player two authored, free nudges per puzzle —
step 1 points at the idea, step 2 at the shape of the answer, never the query
itself. Steps unlock only after a real try (a couple of failed submits or a few
minutes of active play, sooner on Chapter 1's first puzzles) and open only when
the player asks. It keeps zero-SQL players from hard stops without handing out
the "aha" that Pillar 1 promises.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Puzzle Definition & Datasets, Hidden-Data Grader, Query Workbench`

## Overview

The Hint System gives a stuck player two authored nudges per puzzle, on request.
Step 1 points at the idea the request turns on ("Read the request again — does
'under 200' include 200?"); step 2 narrows it to the shape of the answer without
writing the query ("You need two conditions joined with AND; the price one must
decide what happens to something priced exactly 200"). Hints are free, never forced on the player, and unlock
only after the player has had a real try — a couple of wrong answers or a few
minutes on the puzzle — so the "aha" of Pillar 1 is something the player earns rather than
reads. It is distinct from the grader's failure feedback: feedback reacts to
*what a submit got wrong*; hints help *a player who doesn't know where to start
or how to continue*. Without it, zero-SQL players hit hard stops (the concept's
top design risk) and quit.

## Detailed Design

### Core Rules

**Content**

1. Every puzzle carries two hint texts in its definition (`hints` field, Puzzle
   Definition & Datasets): **step 1** and **step 2**. Both are written in the
   voice of a helper character (Kenji by default) and follow these authoring
   rules:
   - **Step 1 — the idea.** Names the concept or the part of the request that
     matters, as a question or pointer. May name a store-manual page ("See the
     manual: Comparing numbers and dates"). Never names a column value from hidden data.
   - **Step 2 — the shape.** Describes the structure of a correct query in words
     (which clauses, which kind of condition, what the boundary must do). **Never
     contains a complete runnable query and never quotes the reference query.**
   - Both are jargon-light; step 2 may use SQL keywords the player has already met.
2. Tutorial puzzles (flag `tutorial`) have hints like any other puzzle; their
   unlock rules are relaxed (rule 5).

**Unlocking**

3. The **Hint** button is always visible on the workbench. Before step 1 is
   unlocked it shows how to unlock it ("Hint available after 2 wrong answers
   or 3 minutes" at defaults — a wrong answer is a FAIL verdict; SUBMIT_ERRORs
   do not count), never a lock with no explanation.
4. **Step 1 unlocks** when either the player has submitted and failed at least
   `hint1_fails` times on this puzzle, or has spent `hint1_minutes` of active
   time on it (Formulas). SUBMIT_ERRORs do not count as fails (the grader does
   not count them either). A puzzle may override these thresholds in its data
   (e.g. 1-3 unlocks sooner — Formulas; 1-1 and 1-2 are `tutorial`).
4a. **Counted FAILs (distinct-query rule).** A FAIL counts toward hint unlocking
   (rules 4, 5) and `exhausted` (rule 11) only if its normalized query text
   differs from the previous **counted** FAIL on that puzzle. Normalization:
   collapse whitespace, case-insensitive outside string literals, ignore a
   trailing `;`. The query text comes from the Grader with each verdict.
   Resubmitting the same failing query therefore never advances a step. The
   grader's own escalation counters are unaffected, and the time paths are
   unchanged. "Fails" in this document means counted FAILs.
5. **Step 2 unlocks** when step 1 has been *viewed* and then either another
   `hint2_fails` failed submits occur or `hint2_minutes` more active time passes.
   On tutorial puzzles both steps are available from the start.
6. Unlocking never shows the hint. The player chooses to open it (Hint button or
   Ctrl+H). A small, silent indicator marks that a new step is available.
   Unlocking may happen on the same submit that escalates the grader's
   feedback; the two never merge — feedback changes its text, the hint only
   lights its indicator.

**Cost and consequences**

7. Hints are **free**: no score, wage, achievement lock or efficiency penalty
   (Pillar 3). Whether a hint was used is recorded only in the Playtest Log.
8. Once opened, a step stays readable for the rest of the session on that
   puzzle — unless the puzzle is restarted from the chapter list (Progression rule 12a), which resets
   everything (Edge Cases).

**Relationship with grader feedback**

9. Hints and failure feedback are separate. Feedback (Hidden-Data Grader) reacts
   to the last submit's cause, in the requester's voice. Hints are fixed per
   puzzle, in the helper's voice, and do not change with the cause.
10. When both are on screen, feedback sits by the result and the hint in its own
    panel; neither replaces the other.

**Stuck players**

11. After step 2 has been viewed and either `stuck_fails` further failed submits
    occur or `exhausted_minutes` more active time passes, the Hint System
    reports **exhausted** for that puzzle (only while the puzzle is not yet
    PASSED; nothing after a PASS latches it). The time path guarantees an exit
    for a player who only produces SUBMIT_ERRORs or never submits — at defaults
    any player reaches `exhausted` after 3 + 3 + 5 = 11 active minutes. What the game offers
    then (skipping the request, a requester's line) is owned by Shift & Chapter
    Progression; the Hint System never reveals the answer.

**Challenge mode**

12. Submits in challenge mode (Constraint Challenges) never change hint state:
    the base puzzle is already PASSED, its hints stay as they were, and
    challenge FAILs do not count toward any unlock. In challenge mode the Hint
    button is **hidden** and the hint area shows "No hints for dares." (an
    exception to rule 3). While challenge mode is open, the open main request's
    `active_time` does not accrue (paused) and its hint state does not change;
    it resumes when challenge mode is left.

### States and Transitions

Per puzzle, per session:

| State | Meaning | Event | To |
|---|---|---|---|
| `Locked` | No step available; button shows the unlock condition | `hint1_fails` fails or `hint1_minutes` active time (tutorial: at once) | `Step1Ready` |
| `Step1Ready` | Step 1 available, unread; indicator shown | Player opens hint | `Step1Read` |
| `Step1Read` | Step 1 shown | `hint2_fails` more fails or `hint2_minutes` more time (tutorial: at once) | `Step2Ready` |
| `Step2Ready` | Step 2 available, unread; indicator shown | Player opens hint | `Step2Read` |
| `Step2Read` | Both steps readable | `stuck_fails` more fails or `exhausted_minutes` more active time (not PASSED) | `Exhausted` (event to Progression) |
| any | | Puzzle PASSED | unchanged (hints stay readable) |
| any | | Puzzle restarted from the chapter list (Progression rule 12a; Restart event) | `Locked` (counters reset, as in the grader) |
| any | | Challenge mode open | unchanged; `active_time` paused (rule 12) |

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Hints | `hints` (step 1, step 2), `flags.tutorial` | Puzzle Definition |
| Hidden-Data Grader | Grader → Hints | Each submit's verdict + the submitted query text (FAIL counts if distinct, rule 4a; SUBMIT_ERROR does not) | Grader |
| Query Workbench | Workbench hosts | Hint button, Ctrl+H, hint panel, "new step" indicator | Workbench |
| Store Manual | Hints → Manual | Optional manual page link in a step | Store Manual |
| Shift & Chapter Progression | Hints ↔ Progression | `exhausted` event per puzzle (Hints → Progression); Restart event (rule 12a) broadcast by Progression, subscribed to by the Hint System (Progression → Hints); challenge-mode open/closed | Progression decides what to offer |
| Onboarding: First Shift | Onboarding → Hints | Coach-mark showing flag: while a coach mark is showing (Guided mode), the "new step" indicator is suppressed; it appears when no coach mark is showing | Onboarding |
| Playtest Log | Hints → Log | Unlock, open and exhausted events with timestamps | Hint System |
| Request & Reaction Dialogue | Dialogue → Hints | Helper character's portrait/name | Dialogue |

## Formulas

*Proposed by `systems-designer` (2026-10-14). All thresholds are data-driven
(global defaults, overridable per puzzle — except `idle_cutoff_s`, which is
global-only).*

The **active_time** formula is defined as:

`active_time = Σ(frames) dt × focused × [now − last_input_t ≤ idle_cutoff_s]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| dt | float (s) | 0–0.25 (clamped) | calculated | Frame delta |
| focused | bool | 0 / 1 | calculated | Game window focused and not paused |
| last_input_t | float (s) | ≥ 0 | calculated | Last key, click or scroll in the workbench, manual or hint panel |
| idle_cutoff_s | int (s) | 30–300 (default 90) | data file (global only, not per-puzzle overridable) | Idle time after which the clock stops |

**Output Range:** 0 → ∞ seconds, per puzzle per session, reset on restart. 90 s
tolerates reading and thinking; below 30 s it starves honest thinkers.
**Example:** the player types, then sits idle 200 s with the window focused →
90 s credited, 110 s not.

The **hint1_unlocked** formula is defined as:

`hint1_unlocked = tutorial ∨ fails ≥ hint1_fails ∨ active_time ≥ 60 × hint1_minutes`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| fails | int | 0 → ∞ | calculated | **Counted** FAIL verdicts on this puzzle (rule 4a: a FAIL counts only if its normalized query text differs from the previous counted FAIL's; SUBMIT_ERROR excluded) |
| hint1_fails | int | 1–4 (default 2) | data file | Fails needed for step 1 |
| hint1_minutes | float | 1–8 (default 3) | data file | Active minutes needed for step 1 |
| tutorial | bool | 0 / 1 | data file | Puzzle flag |

**Output Range:** boolean. 0 is rejected at load (step 1 before any try breaks
"earn the aha"); above 4 fails / 8 min risks hard stops. 3 min ≈ 65% of the
~4.6 min average puzzle (unmeasured), so it fires only for slower players.
*Note:* the ~4.6 min/puzzle assumption conflicts with the concept's 5–15 min per
puzzle; pending playtest timings (Open Question 1).
**Per-puzzle override:** 1-3 — the first non-tutorial puzzle of the zero-SQL
gate (1-1 and 1-2 are `tutorial`) — uses `hint1_fails = 1`, `hint1_minutes = 2`.
**Example:** 1 fail and 3.5 active minutes → true (by time).

The **hint2_unlocked** formula is defined as:

`hint2_unlocked = tutorial ∨ (step1_viewed ∧ (fails − fails_at_v1 ≥ hint2_fails ∨ active_time − time_at_v1 ≥ 60 × hint2_minutes))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| fails_at_v1, time_at_v1 | int, float | ≥ 0 | calculated | Snapshots of `fails` and `active_time` when step 1 was first opened |
| hint2_fails | int | 1–4 (default 2) | data file | Further fails for step 2 |
| hint2_minutes | float | 1–8 (default 3) | data file | Further active minutes for step 2 |

**Output Range:** boolean. Fastest path at defaults: 4 fails, or 2 fails + step 1
+ 2 more fails.
**Example:** step 1 opened at 2 fails, 5.0 min → at 3 fails, 8.5 min → true (by time).

The **exhausted** formula is defined as:

`exhausted = ¬passed ∧ step2_viewed ∧ (fails − fails_at_v2 ≥ stuck_fails ∨ active_time − time_at_v2 ≥ 60 × exhausted_minutes)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| fails_at_v2, time_at_v2 | int, float | ≥ 0 | calculated | Snapshots of `fails` and `active_time` when step 2 was first opened |
| stuck_fails | int | 2–6 (default 3) | data file | Fails after step 2 before reporting `exhausted` |
| exhausted_minutes | float | 2–15 (default 5) | data file | Further active minutes after step 2 before reporting `exhausted` |
| passed | bool | 0 / 1 | calculated | The puzzle has been PASSED this session |

**Output Range:** boolean, latched; the event is sent to Progression once. The
time path counts `active_time`, which grows while the player types and submits
SUBMIT_ERRORs, so a player who never produces a FAIL still reaches `exhausted`.
5 min is longer than the time path to step 2 (3 min) because after step 2 the
player has the shape of the answer; below 2 min the skip arrives before the hint
is tried.
**Examples:** step 2 opened at 6 fails → `exhausted` at fail 9. Defaults, 0
FAILs (syntax errors only), each step opened as soon as it unlocks: step 1 at
180 s, step 2 at 360 s → `exhausted` at 660 s.

**Grader interaction:** from Vertical Slice the grader escalates feedback per
cause (levels 1,1,2,2,3 at k = 2, counting every FAIL) while hints count only
distinct-query FAILs (rule 4a), so the two cannot
be aligned and are not offset; rule 6 keeps them visually separate. At MVP the
grader ships level 1 only, so an unlock never coincides with an escalation.

**Rejected at load:** any `*_fails` < 1 or non-integer; any `*_minutes` ≤ 0;
any non-numeric value. **Clamped (with a warning):** values that are valid but
outside the stated ranges (e.g. `hint1_fails = 5` → 4, `idle_cutoff_s = 20` → 30,
`exhausted_minutes = 30` → 15).

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the player passes a puzzle without opening any hint**: hints stay locked or unread; nothing is recorded but the Playtest Log events. No "you didn't need hints" message.
- **If the player passes, then reopens the puzzle**: hints already opened stay readable; unlock progress is kept for the session.
- **If the player keeps the game open but idle**: idle time does not count towards the time unlock (Formulas `active_time`).
- **If the player alternates between two puzzles**: each puzzle has its own counters and timers; time on one does not unlock the other.
- **If a submit is a SUBMIT_ERROR** (syntax error, multiple statements): it does not count as a fail for unlocking, matching the grader; the time paths still advance, so a player who only produces errors still unlocks both steps and reaches `exhausted` (rule 11).
- **If the player never submits**: the same time paths apply; opening each step when it unlocks, the player reaches `exhausted` after 11 active minutes at defaults.
- **If the player is in challenge mode**: hint state does not change, the Hint button is hidden ("No hints for dares."), and the open main request's `active_time` is paused until challenge mode is left (rule 12).
- **If the player fails repeatedly with different causes**: every counted FAIL (rule 4a) counts for unlocking, whatever the cause.
- **If the player resubmits the same failing query** (or one differing only in whitespace, keyword case or a trailing `;`): only the first counts (rule 4a); junk resubmits such as `SELECT 1` ×7 advance no step. A FAIL that differs from the previous counted FAIL counts even if it repeats an older one (A, B, A → 3 counted).
- **If a SUBMIT_ERROR falls between two identical FAILs**: it does not reset the comparison; the second FAIL is compared with the previous counted FAIL and does not count.
- **If a puzzle's step 1 or step 2 text is missing**: the puzzle fails content validation (both are required); if such a puzzle reaches runtime anyway, the missing step shows "No hint for this one" rather than an empty panel, and the other step still works.
- **If step 2 is opened and the player then passes**: no penalty, no change to efficiency stats or achievements.
- **If the puzzle is a boss**: same rules; whether a boss can be skipped after `exhausted` is Progression's decision.
- **If the player restarts the puzzle from the chapter list** (Progression rule 12a): unlock state resets to `Locked`, counters to 0; already-read text is hidden again (consistent with the grader's counter reset).

## Dependencies

**Upstream (hard):**

| System | GDD | What the Hint System needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | `hints` (step 1, step 2), `flags.tutorial` | In Review |
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | Submit verdicts (FAIL vs SUBMIT_ERROR) + submitted query text (rule 4a) | In Review |
| Query Workbench | `design/gdd/query-workbench.md` | Host: button, shortcut, panel, indicator | In Review |

**Downstream:** Shift & Chapter Progression (consumes `exhausted`), Playtest Log
(events). **Soft:** Store Manual (page links in hint text), Request & Reaction
Dialogue (helper character identity), Onboarding: First Shift (coach-mark flag
suppresses the "new step" indicator), Shift & Chapter Progression (Restart event,
challenge-mode open/closed — the Hint↔Progression coupling is a runtime cycle).

**Bidirectionality:** the grader, puzzle definition, workbench, progression,
constraint challenge and onboarding GDDs list the Hint System ✓.

## Tuning Knobs

Global defaults live in a data file; each is overridable per puzzle in its
`hints` field, **except `idle_cutoff_s`, which is global-only** (Playtest Log
reads the same global value). Ranges and rationale are in Formulas.

**Boss 1-11 (pending):** the boss should get a per-puzzle override with longer
`hint1_minutes` / `exhausted_minutes` than the defaults; the values are to be set
from zero-SQL playtest timings (Open Question 1; Progression OQ1). No number is
fixed yet — 1-11 uses the defaults until then.

| Knob | Default | Safe range | Affects |
|---|---|---|---|
| `hint1_fails` / `hint1_minutes` | 2 / 3 | 1–4 / 1–8 | How soon the first nudge appears (earlier: less earned "aha"; later: hard-stop risk) |
| `hint2_fails` / `hint2_minutes` | 2 / 3 | 1–4 / 1–8 | Gap between the idea and the shape |
| `stuck_fails` / `exhausted_minutes` | 3 / 5 | 2–6 / 2–15 | How soon Progression offers the skip |
| `idle_cutoff_s` | 90 | 30–300 | How much thinking time counts as active (global-only; shared with Playtest Log) |

## Visual/Audio Requirements

*`art-director` not consulted — Lean mode (hint visuals are not central to play).
Review in `/art-bible`.*

- The hint panel is a **folded note from the helper** (store paper as UI),
  opened from the Hint button; it sits beside the editor and never covers the
  editor or the result tables.
- Step 1 and step 2 are visibly separate (two folds of the same note), each with
  a label ("Hint 1 — the idea", "Hint 2 — the shape").
- The "new step available" indicator is a small dot + text on the Hint button —
  no flashing, no sound, no animation beyond a single fade (none under reduced
  motion).
- Audio: a soft paper-unfold sound when a hint is opened; silence on unlock.

## Game Feel

Hints should feel like a coworker leaning over, not a solution sheet. The player
always asks — the game never interrupts. Unlocking is silent; opening is quick
(one key, no confirmation). Reading a hint costs nothing, so a stuck player
never has a reason to quit instead of asking.

## UI Requirements

1. Hint button always visible on the workbench, with its unlock condition shown
   while locked ("Available after 2 wrong answers or 3 minutes" — from the puzzle's
   actual thresholds).
2. Ctrl+H opens/closes the hint panel; reachable by keyboard focus.
3. Indicator for a newly available step: glyph + word, not colour alone.
4. Hint text at the workbench `table_font_px` or larger; ≥ 4.5:1 contrast.

> **📌 UX Flag — Hint System**: covered by the Query Workbench UX spec
> (`/ux-design` in Pre-Production).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/puzzle-definition-and-datasets.md` | Core Rule 1 | `hints` field, tutorial flag | In Review |
| `design/gdd/hidden-data-grader.md` | Core Rules 4–5, 9 | FAIL vs SUBMIT_ERROR counting; feedback vs hint separation; counter reset on restart | In Review |
| `design/gdd/query-workbench.md` | UI Requirements | Hint button, Ctrl+H, panel placement | In Review |
| `design/gdd/shift-and-chapter-progression.md` | Core Rules 8, 11, 12 | Restart action and event (rule 12a); consumer of `exhausted` (rule 7); challenge mode keeps the main request Open | In Review |
| `design/gdd/onboarding-first-shift.md` | Interactions | Indicator suppressed while a coach mark shows | In Review |
| `design/gdd/request-and-reaction-dialogue.md` | Core Rule 1 | Kenji is the hint voice (cast) | In Review |
| `design/gdd/constraint-challenges.md` | Core Rule 12 | Challenge-mode submits leave hint state unchanged | In Review |
| `design/gdd/game-concept.md` | Overview | Zero-SQL risk; "hints and skippable puzzles prevent hard stops" | Source of intent |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Tests use a fake clock, fake input, a
scripted fake grader and a fake Progression sink — no real waiting. Ctrl+H
opening the panel is covered by workbench QW-19. [UI] = retained screenshot in
`production/qa/evidence/`.*

- **HS-01 [UI]** GIVEN 1-5 (defaults) in `Locked`, WHEN captured, THEN the Hint button reads "Hint available after 2 wrong answers or 3 minutes"; on 1-3 (override) "after 1 wrong answer or 2 minutes"; the text comes from the puzzle's thresholds, never a bare lock.
- **HS-02 [Logic]** GIVEN 1-5, WHEN FAIL, SUBMIT_ERROR ×3, then FAIL (different cause), THEN `Locked` until the second FAIL and `Step1Ready` on it.
- **HS-03 [Logic]** GIVEN focus and an input every 10 s, WHEN the fake clock reaches 179.9 s THEN `Locked`; at 180.0 s THEN `Step1Ready`.
- **HS-04 [Logic]** GIVEN one input then 200 s idle with focus THEN `active_time` = 90; GIVEN 60 s unfocused or paused (even with input) THEN +0; GIVEN a single 2 s frame THEN +0.25; GIVEN scrolling in the hint panel THEN it counts as input.
- **HS-05 [Logic]** GIVEN step 1 first opened at 2 fails / 300 s, WHEN 1 more FAIL and the clock reaches 479.9 s THEN `Step1Read`; at 480.0 s or at a 4th fail THEN `Step2Ready`; GIVEN step 1 unlocked but never opened, WHEN 4 more FAILs THEN step 2 stays locked.
- **HS-06 [Logic]** GIVEN a `tutorial` puzzle, WHEN it loads, THEN both steps are available at 0 fails / 0 s and the locked label never shows.
- **HS-07 [Logic]** GIVEN 1-3 (override, not tutorial) THEN 1 FAIL or 120 s unlocks step 1; GIVEN 1-1 and 1-2 (`tutorial`) THEN both steps are available at load (HS-06); 1-4 uses the defaults.
- **HS-08 [Integration]** GIVEN the FAIL that unlocks a step also escalates the grader's feedback, THEN the hint panel stays closed, no sound plays, the indicator appears, and the feedback text changes on its own; opening the hint plays the unfold sound once.
- **HS-09 [Integration]** GIVEN step 2 opened then PASS, THEN wage, efficiency stats and achievement eligibility equal a no-hint PASS with the same submits; the Playtest Log holds unlock/open events with timestamps; no player-facing text mentions hint use.
- **HS-10 [Logic]** GIVEN step 1 read, WHEN the player passes, leaves and returns in the session, THEN step 1 is still readable and counters are kept; WHEN restarted from the chapter list, THEN `Locked`, fails, `active_time` and snapshots are 0, and the text is hidden.
- **HS-11 [Logic]** GIVEN step 2 first opened at 6 fails, THEN fails 7–8 do not trigger `exhausted`, fail 9 does, and the Progression fake receives exactly one event, still one after fails 10–12; GIVEN the puzzle already PASSED, THEN further fails or time never trigger it.
- **HS-17 [Logic]** GIVEN 1-5 at defaults, an input every 10 s, only SUBMIT_ERRORs (0 FAILs) and each step opened as soon as it unlocks, THEN step 1 unlocks at 180.0 s, step 2 at 360.0 s, `exhausted` is false at 659.9 s and true at 660.0 s with exactly one Progression event; GIVEN the same with no submits at all, THEN the same times.
- **HS-18 [Integration]** GIVEN 1-6 PASSED and challenge mode active, WHEN 5 challenge FAILs occur over 10 active minutes, THEN hint state, `fails` and the snapshots are unchanged; the Hint button is hidden and the hint area reads "No hints for dares."; GIVEN 1-7 open with `active_time` = 100 s when challenge mode opens, WHEN 10 active minutes pass in challenge mode and it is left, THEN 1-7's `active_time` is still 100 s and its hint state unchanged.
- **HS-19 [Logic]** GIVEN 1-5 at defaults, WHEN FAILs are submitted with texts `SELECT 1`, `select  1;`, `SELECT 1` THEN `fails` = 1 and the state is `Locked`; WHEN a FAIL `SELECT 2` follows THEN `fails` = 2 and `Step1Ready`; GIVEN `SELECT * FROM t WHERE name = 'A'` then `… = 'a'` (both FAIL) THEN both count (case inside string literals is kept); the grader received and counted all 4 FAILs of the first sequence regardless.
- **HS-12 [Content-CI]** GIVEN a puzzle with step 1 or step 2 empty or missing, THEN content validation marks it invalid; GIVEN a fixture that bypasses validation, THEN the missing step shows "No hint for this one" and the other step still works.
- **HS-13 [Content-CI]** For every puzzle: (a) no hint contains the reference query (whitespace and case normalised); (b) no code span in a hint, run as the player's query, **passes** the puzzle (matches the reference on every dataset); (c) step 1 names no value that appears only in hidden datasets.
- **HS-14 [Logic]** GIVEN `hint1_fails` 0 or 1.5, `stuck_fails` "3", `hint2_minutes` 0 or −1, or `exhausted_minutes` 0, WHEN loaded, THEN each is rejected and the error names the key; GIVEN `hint1_fails = 5`, `idle_cutoff_s = 20` or `exhausted_minutes = 30`, THEN clamped to 4 / 30 / 15 with a warning.
- **HS-15 [Integration]** GIVEN the panel is open, WHEN Ctrl+H is pressed THEN it closes; the Hint button is reachable by keyboard focus and Enter opens it.
- **HS-16 [UI]** GIVEN `Step1Ready` and an open panel, WHEN captured, THEN the indicator is glyph + word (legible in greyscale); hint text ≥ `table_font_px` with ≥ 4.5:1 contrast; the panel covers neither the editor nor the result tables; the folds are labelled "Hint 1 — the idea" and "Hint 2 — the shape"; with reduced motion, no fade.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Are the default unlock thresholds right? Measure from the zero-SQL playtest logs: time-to-first-submit and how many players open hints before failing. | game-designer (playtest) | Zero-SQL playtest |
| 2 | ~~Should the helper be Kenji for every hint, or the character most fitting the request?~~ **Answered** by the Request & Reaction Dialogue cast: Kenji is the voice of every hint. | narrative-director | Resolved 2026-10-14 |
| 3 | ~~When `exhausted`, what does Progression offer?~~ **Answered** in `shift-and-chapter-progression.md` rule 7: Kenji offers to take the request (skip), for every main request including the boss; skipping forgoes only the chapter star. | game-designer | Resolved 2026-10-14 |
| 4 | ~~A player who never submits never becomes `exhausted`?~~ **Resolved** (design review 2026-10-14): time path `exhausted_minutes` (default 5) after step 2 — rule 11; tune from playtest logs. | game-designer | Resolved 2026-10-14 |
| 6 | Boss 1-11 needs a per-puzzle override (longer `hint1_minutes` / `exhausted_minutes`); set the values from playtest timings, which also settle the ~4.6 min vs 5–15 min per-puzzle conflict (Formulas). See Progression OQ1. | game-designer (playtest) | Zero-SQL playtest |
| 5 | The locked label's counts ("1 wrong answer" / "2 wrong answers") need a localisation-safe plural rule. | localization-lead | Before localisation |
