# Shift & Chapter Progression

> **Status**: In Review
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-15 (re-review 6e: NEEDS REVISION → revised — `Unavailable` resolves a main request in rules 4, 6, States, PR-02/PR-04, payslip mark; first main opens when the briefing ends; side messages after the briefing; earlier: cross-review 6d: rule 7a UNAVAILABLE → Kenji's offer / Unavailable state, request_restart logged, briefing opens the first request, PR-22 (rule changes); OQ1 G2 note, statuses; earlier: 2026-10-15: re-review 6c fixes: Workbench subscribes to Restart; `skip.offer` / `skip.accept` and side-request messages contracted with Dialogue; earlier: 2026-10-14 cross-GDD review fixes; art-bible sync 2026-10-14)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 4 — Real Store, Real SQL; Pillar 3 — Fast Hands, Cheap Mistakes

## Summary

Shift & Chapter Progression structures a play session: a chapter is one in-game
day, a shift is 3–5 requests ending with a payslip, and a request is one puzzle.
It orders requests, decides completion (every main request passed or left for
later) and the mastery star (every main request passed), and defuses hard stops:
once hints are exhausted, Kenji can take any request — the boss included — so the
player always keeps going. Rewards are narrative and cosmetic, never an economy.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Puzzle Definition & Datasets, Hidden-Data Grader, Hint System`

## Overview

Shift & Chapter Progression is the structure of a play session: a **chapter** is
one in-game day at the SQLbini Ekimae branch with its own new SQL concepts, a
**shift** is a run of 3–5 requests ending with clocking out, and a **request** is
one puzzle. It decides which request comes next, when a chapter is done, what
"finished" and "skipped" mean, and what the player sees between requests — the
manager's morning briefing, the payslip at the end of a shift. It is where the
concept's session loop lives ("one shift fits an evening; clocking out is the
natural stopping point") and where the zero-SQL risk is defused: a player who is
truly stuck can hand a request to Kenji and keep going, so no single puzzle ends
the game. The player grows in knowledge, not power, so progression rewards are
narrative and cosmetic — a payslip, stamps, a chapter star — never an economy
(anti-pillar). There are no numeric balancing rules; shift composition and wage
amounts are content values.

## Detailed Design

### Core Rules

**Structure**

1. A **chapter** is one in-game day (its "today" date and schema come from the
   chapter definition in Puzzle Definition & Datasets). A chapter has 2–4
   **shifts**; a shift has 3–5 **main** requests, in a fixed order, and may offer
   **side** requests. The last main request of the last shift is the chapter's
   **boss**.
2. Chapter 1 ("Day One", 2026-03-02) is laid out as (the Onboarding: First
   Shift system covers its Morning shift, 1-1 to 1-3):

| Shift | Main requests | Side requests offered | Notes |
|---|---|---|---|
| Morning | 1-1, 1-2, 1-3 | — | 1-1 and 1-2 are `tutorial` |
| Afternoon | 1-4, 1-5, 1-6, 1-7 | S-1 (HQ email) | 1-4 and 1-6 carry constraint challenges |
| Closing | 1-8, 1-9, 1-10, 1-11 (boss) | S-2 (manager's question) | 1-8 carries a constraint challenge |

   The exact split is level-design content; this table is the MVP default.
3. Order and grouping live in each puzzle's data (`chapter`, `shift`, `order`,
   `flags`); this system only interprets them.

**Moving through a shift**

4. Main requests arrive one at a time, in order. The next main request becomes
   available when the current one is **passed**, **left for later** (rule 7) or
   left as **unavailable** (rule 7a).
5. Side requests are offered as messages (HQ email, a question from the manager)
   when their shift's briefing ends (rule 11) — a `side` line in the message log plus a message
   ticket on the counter strip, never replacing the bubble's request
   (`request-and-reaction-dialogue.md` rule 3b). They are optional, can be opened any time during the
   chapter, and never block anything.
6. A shift **ends** when all its main requests are passed, left for later or
   left as unavailable (rule 7a; withheld ones are passed over). The
   player then **clocks out**: the payslip screen (rule 10) is shown and the
   game offers *Next shift* or *Stop for today*. Stopping is the natural session
   end. At MVP (no saving) *Stop for today* returns to the shift screen and
   keeps progress until the game is quit, with a one-line note: "Progress is kept
   until you close the game — saving comes in a later build." From Vertical
   Slice it saves and exits to the title (Save/Load & Settings). After the **last** shift, the payslip is followed by an *End of day*
   summary (chapter complete / starred, requests left for later) instead of
   *Next shift*.

**Leaving a request for later (no hard stops)**

7. When the Hint System reports a request **exhausted** (both hints read, then
   further fails **or further active time** — `hint-system.md` rule 11), Kenji
   offers to take it: "Want me to handle this one? You can
   come back to it anytime." Accepting marks the request **left for later**
   (`skipped`) and moves on. This applies to every main request, **the boss
   included** — a zero-SQL player is never stuck behind one puzzle. Because
   `exhausted` has a time path, this holds for a player who only produces
   syntax errors or never submits: at hint defaults the offer can appear after
   11 active minutes. The offer still requires both hints to have been opened —
   the skip comes after asking for help, never instead of it. When the
   skip is accepted, Kenji's accept line (`skip.accept`; the offer itself is `skip.offer`,
   both Dialogue rule 3b) holds like a pass line for its `reaction_hold`, then
   the next main request opens — or, on the boss (or any shift's last main
   request), the shift clocks out and the payslip is
   shown (rule 6). The location of the persistent "Leave it for Kenji" button
   is deferred to `/ux-design`.
7a. **A request the store can't check.** When the grader returns UNAVAILABLE
    on a main request (a dataset failed to build — a content bug, so it
    repeats), Kenji's `skip.offer` is queued right after his
    `error.CONTENT_ERROR` line (Dialogue Edge Cases, queue) — without
    `exhausted` and without hints. Accepting marks the request
    **unavailable**: like a withheld request it is excluded from completion and
    the star and shows "unavailable" on the chapter list and the payslip
    (rule 10), never `Skipped`;
    the Playtest Log records `request_unavailable {source: submit}`;
    `skip.accept` and the move to the next request (or clock-out) follow as in
    rule 7. It can still be reopened from the chapter list, and a later PASS
    turns it into `Passed`. Declining keeps it `Open`, and the "Leave it for
    Kenji" button stays on that request (as in rule 7); every later
    UNAVAILABLE offers again. Side requests and challenge-mode submits get no
    offer (side requests never block; `constraint-challenges.md` rule 9).
8. A skipped request stays in the chapter list and can be reopened at any time;
   passing it later turns it into **passed**. Skipping costs nothing beyond the
   chapter star (rule 9).

**Finishing a chapter**

9. A chapter is **complete** when every main request is passed or skipped
   (unavailable ones — withheld, or left under rule 7a — are excluded); the
   next chapter then unlocks (Chapter 2 is outside the MVP). A chapter earns its
   **star** (★) only when every main request is **passed** — the full-clear
   reward that skipping forgoes. (The concept's *mastered* — every constraint
   challenge cleared — is a separate, later notion for Achievements, Vertical
   Slice; the star does not track it.) Side requests and constraint challenges never affect
   completion or the star. Progress only moves forward: a `Passed` request never
   reverts and a star is never revoked.

**The payslip**

10. At clock-out the payslip lists the shift's requests with their marks
    (passed / left for later / unavailable — rule 7a), constraint challenges cleared during that shift
    (a clear after the final clock-out shows on the End of day screen only —
    `constraint-challenges.md` rule 6b), and a fixed
    **wage** in yen for the shift (a content value per shift — Chapter 1: ¥3,000
    per shift). The wage is **flavour only**: it is never spent, saved up, or
    used to unlock anything (anti-pillar: not a management sim).

**Between requests**

11. Each shift starts with a short briefing line from the manager (Request &
    Reaction Dialogue rule 3c); the shift's first main request opens when the
    briefing ends (on Day One's Morning shift, after Onboarding's "Ever used SQL
    before?" answer). Between requests the next requester's message arrives
    as soon as the PASS reaction ends — after `reaction_hold` (2.5–6 s), or at
    once on a click / Enter (`request-and-reaction-dialogue.md` rule 3a) — with
    no menus between puzzles. A constraint challenge offer is not a menu: it is
    shown inline with the PASS reaction, never waits for an answer, and moves to
    an offer ticket on the counter strip if unanswered
    (`constraint-challenges.md` rules 6–6b). While challenge mode is
    open the shift does not advance; the open main request (already `Open`,
    its `request_open` fired) stays `Open`, and its hint clock is paused
    (`hint-system.md` rule 12). Leaving challenge mode returns to the open main
    request.
12. The **chapter list** (opened from the shift screen) shows every request of the chapter with its
    state, its challenge mark, and lets the player replay any passed request or
    reopen a skipped one — both keep the request's draft, counters and hints.
    Replays never change progress except turning skipped into passed.
12a. **Restart** — also on the chapter list, for any request that is `Open`,
    `Skipped` or `Passed`. It resets that request's working state: grader
    per-cause counters to 0, Hint System to `Locked` (counters, snapshots and
    `exhausted` cleared), the editor draft to empty (or to the puzzle's
    `prefill_sql` when it has one — 1-1's `SELECT * FROM products;`, Puzzle
    Definition), the result panel cleared. Restart is broadcast as an event;
    the Hint System, the grader and the Query Workbench subscribe to it to
    reset their state (the Workbench resets the draft as above and clears that
    puzzle's last Run result and last verdict). It never changes progress: a
    `Passed` request stays `Passed`, a `Skipped` one stays `Skipped`, and the
    challenge state, manual pages and Playtest Log history are kept. Each
    confirmed Restart is logged as `request_restart {state, draft_was_empty}`
    (`playtest-log.md` rule 4). When the
    draft is non-empty (the Workbench reports whether that puzzle's draft is
    empty), Restart asks once ("Start this request over? Your
    query will be cleared.") with **Restart** / **Cancel**.

**Persistence**

13. At MVP, progress lasts for the play session. Saving progress across sessions
    — at least at every pass, skip and clock-out — is Save/Load & Settings
    (Vertical Slice).

### States and Transitions

**Per request:**

| State | Meaning | Event | To |
|---|---|---|---|
| `Locked` | An earlier main request in the shift is not yet passed / skipped / unavailable, or (first main of a shift) the shift's briefing has not ended | Previous main request passed, skipped or unavailable (rule 7a); for the first main of a shift, its briefing ends (rule 11) — after *Next shift* (or the shift screen's continue after *Stop for today*; on a new game, after Onboarding's question) | `Open` |
| `Open` | Available in the workbench | Grader PASS | `Passed` |
| `Open` | | Hint `exhausted` → player accepts Kenji's offer | `Skipped` |
| `Open` | | Grader UNAVAILABLE → player accepts Kenji's offer (rule 7a) | `Unavailable` |
| `Skipped` | Left for later | Reopened and passed | `Passed` |
| `Unavailable` | Left because a dataset failed to build; excluded from completion and star | Reopened and passed | `Passed` |
| `Passed` | Done | Replay | `Passed` |
| `Open` / `Skipped` / `Passed` | | Restart (rule 12a) | unchanged (working state reset) |

Side requests start `Open` when their shift starts and are never `Skipped`.

**Per shift:** `NotStarted → InProgress` (first request opened) `→ ClockedOut`
(all main requests passed, skipped or unavailable; payslip shown). From
`ClockedOut`, *Next shift* starts the next shift's briefing, and its first main
request opens when the briefing ends (rule 11), moving it to `InProgress`;
*Stop for today* returns to the shift screen, whose continue action does the
same later in the session.

**Per chapter:** `Locked → InProgress → Complete` (all main passed/skipped;
unavailable ones excluded — rule 9) and, independently, `Starred` (all main
passed, unavailable ones excluded).

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Progression | `chapter`, `shift`, `order`, `flags` (tutorial, side, boss), chapter "today", shift wage | Puzzle Definition |
| Hidden-Data Grader | Grader ↔ Progression | Grader → Progression: PASS and UNAVAILABLE events (UNAVAILABLE → Kenji's offer, rule 7a). Progression → Grader: Restart event (rule 12a) | Grader (verdicts); Progression (Restart) |
| Hint System | Hints ↔ Progression | `exhausted` per request (Hints → Progression); Restart event broadcast by Progression, subscribed to by the Hint System (Progression → Hints) — a runtime cycle | Hint System (`exhausted`); Progression (Restart) |
| Constraint Challenges | both | Base PASS triggers the offer; challenge marks on the chapter list; a clear shows on the payslip of the shift in which it is cleared (after the final clock-out: End of day screen only — `constraint-challenges.md` rule 6b) | Constraint Challenges |
| Query Workbench | Progression ↔ Workbench | Progression → Workbench: which request is open; the Restart event (rule 12a — the Workbench resets that puzzle's draft to empty or `prefill_sql` and clears its last Run result and verdict). Workbench → Progression: whether a puzzle's draft is empty (for the Restart confirmation) | Progression (event); Workbench (draft state) |
| Request & Reaction Dialogue | Progression → Dialogue | Shift briefing, Kenji's skip offer and accept line (`skip.offer`, `skip.accept`), side-request messages when the briefing ends (`side` kind) — all Dialogue rule 3b; Dialogue → Progression: end of the briefing (Dialogue rule 3c — opens the shift's first main request) and end of the `skip.accept` hold | Progression owns timing; Dialogue owns the lines |
| Store Manual | Progression → Manual | Request opened (manual pages unlock by the request's `manual_pages`) | Store Manual |
| Onboarding: First Shift | Progression → Onboarding | Request opened for 1-1 to 1-3 (Morning shift of Day One); Restart returns 1-1's `prefill_sql` (coach marks do not replay) | Onboarding |
| Save/Load & Settings (VS) | Progression → Save | Request, shift, chapter states | Save/Load |
| Game Shell & Screen Flow (VS) | Shell → Progression | Start / continue chapter | Game Shell |
| Achievements (VS) | Progression → Achievements | Chapter complete / starred events | Achievements |
| Playtest Log | Progression → Log | Request opened/passed/skipped/unavailable/restarted, shift clock-out, chapter complete, with timestamps | Progression |

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the player never opens a hint**: `exhausted` cannot latch and Kenji never offers; the Hint button's unlock indicator is the way forward (by design — the skip follows asking for help).
- **If the player restarts an exhausted request before accepting the offer**: the offer and the "Leave it for Kenji" button disappear until the request is exhausted again.
- **If the player restarts a `Skipped` request**: it stays `Skipped` until passed; hints start `Locked` again.
- **If a constraint offer is pending when the shift's last main request is passed**: clock-out proceeds; the offer counts as Later (`constraint-challenges.md` rule 6) and the challenge stays `Available` in the chapter list.
- **If the player declines Kenji's offer**: the request stays `Open`; the offer can be accepted later from a "Leave it for Kenji" button that stays visible on that request while it is `exhausted`.
- **If the boss is skipped**: the chapter can still complete (rule 9) but cannot be starred; the payslip and chapter list show "left for later".
- **If every main request of a shift is skipped**: the shift still clocks out normally; the payslip lists them as left for later. No scolding line.
- **If the player reopens a skipped request and passes it after the chapter is complete**: it becomes `Passed`; if that was the last skipped main request, the chapter becomes `Starred` immediately.
- **If the player quits the game (MVP, no save)** — mid-shift or after *Stop for today*: progress is lost; on relaunch the chapter starts at the Morning shift. *Stop for today* warns about this (rule 6). (Vertical Slice Save/Load fixes this.)
- **If the player opens a side request mid-shift**: allowed; the main request's draft and state are kept (workbench draft restore).
- **If a side request is never opened**: no effect on completion, star or wage.
- **If a request is withheld by content validation** (invalid data): it is passed over for ordering (never marked `Skipped`), shown as "unavailable" in the chapter list, and excluded from completion and star checks; the Playtest Log records `request_unavailable {source: content_check}`. (A request whose dataset fails to build at Submit time is handled by rule 7a.)
- **If two shifts' requests are reordered in data**: order is taken from the data; no hardcoded sequence.
- **If a replayed passed request is failed**: no effect on its `Passed` state (same as the grader rule).
- **If every main request of a shift is unavailable** (withheld): the shift clocks out at once with a note on the payslip; the log records it.
- **If a side request is invalid**: it is not offered at all (no message), and the log records it.

## Dependencies

**Upstream (hard):**

| System | GDD | What Progression needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Ordering fields, flags, chapter "today", shift wage | Approved — shift wage is a chapter field |
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | PASS events | Approved |
| Hint System | `design/gdd/hint-system.md` | `exhausted` events | Approved |

**Soft / hosted:** Constraint Challenges (offer after PASS; marks), Request &
Reaction Dialogue (briefings, Kenji's offer, side messages), Query Workbench
(open request), Store Manual (unlock by `manual_pages`), Onboarding: First
Shift (Morning shift requests; Restart prefill), Playtest Log.

**Downstream (VS):** Save/Load & Settings, Game Shell & Screen Flow, Achievements.

**Bidirectionality:** the grader, puzzle definition, hint system, constraint
challenges, dialogue, store manual, onboarding and playtest log list Shift &
Chapter Progression ✓. Restart (rule 12a) is the action the grader (counter
reset), Hint System (rule 8; subscribes to the Restart event) and Onboarding
(OB-16) refer to. Hint↔Progression is a runtime cycle (`exhausted` one way,
Restart the other), carried by events.

## Tuning Knobs

No balance formulas; these are content values in the chapter definition.

| Knob | Default (Ch1) | Safe range | Affects |
|---|---|---|---|
| Shifts per chapter | 3 | 2–4 | Number of natural stopping points per chapter |
| Main requests per shift | 3 / 4 / 4 | 3–5 | Shift length (target set by OQ 3 after the playtest) |
| Shift wage | ¥3,000 | any; flavour only | Payslip text (never read by logic — PR-12) |
| Skip timing | from `hint-system.md` (`stuck_fails`, `exhausted_minutes`) | — | How soon Kenji's offer appears |

## Visual/Audio Requirements

*Optional for `Progression` systems; `art-director` not consulted — Lean mode.
Synced to the art bible (`design/art/art-bible.md`) 2026-10-14; the bible is
authoritative for visuals where they differ.*

- **Shift briefing:** a short line from the manager over the store at the time of
  day (morning light, afternoon, closing) — the time of day is the shift's
  visual signature. The light changes only by the strip's palette swap, on the
  shift-start card: a 300 ms crossfade, instant under reduced motion (art bible
  2.1, 7.6).
- **Payslip:** a printed receipt (store paper as UI) listing the shift's requests
  with glyph + word marks (✓ passed in pass green `#245A30`, ↷ left for later in
  `ink_muted` `#5E544B`, – unavailable in `ink_muted`, ★ challenge cleared in vermilion `#C23B18`; art bible
  4.2, 4.5) and the wage line under a dashed tear rule; a soft receipt-printer
  sound.
- **End of day:** after the Closing shift the strip's sign flips to "Closed" (a
  1-frame sprite swap), and the chapter list shows it afterwards (art bible 2.2).
- **Chapter list:** a shift-by-shift checklist on a clipboard; states use glyph +
  word (same glyphs and colours as the payslip; ☆ challenge available), never
  colour alone (art bible 3.3, 4.6).
- **Chapter star:** a single small ★ stamp on the chapter card — no fanfare.

## Game Feel

A shift should feel like a calm, satisfying work session: requests keep arriving
without menus in between, and clocking out is a soft, rewarding pause — a good
place to stop for the night. Being stuck never feels like a wall: Kenji's offer
arrives as a friendly coworker, and the request waits in the list without
judgement. Mastery is visible (the star) but never required to keep going.

## UI Requirements

1. Shift screen: current shift name, requests done / total, access to the chapter list.
2. Kenji's offer: **Leave it for Kenji** / **Keep trying**, keyboard reachable; the "Leave it for Kenji" button stays on an exhausted request (its location is deferred to `/ux-design`).
3. Payslip after each shift with **Next shift** / **Stop for today**.
4. Chapter list: every request with state (locked / open / passed / left for later / unavailable), challenge mark, replay/reopen and restart actions.
5. All states glyph + word; ≥ 4.5:1 contrast.
6. Restart on the chapter list (rule 12a), with a one-line confirmation when the draft is non-empty.

> **📌 UX Flag — Shift & Chapter Progression**: In Pre-Production, run
> `/ux-design` for the shift screen, payslip and chapter list before writing
> epics.

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hint-system.md` | Core Rule 7 | `exhausted` event (fails or time path, hint rule 11); Open Question 3 answered here (skip any main request incl. boss) | Approved |
| `design/gdd/constraint-challenges.md` | Rules 2, 9–10 | Chapter 1 challenge puzzles; challenges never affect completion | Approved |
| `design/gdd/puzzle-definition-and-datasets.md` | Rules 1, 3, 12a | Ordering fields, flags, chapter definition; `prefill_sql` | Approved |
| `design/gdd/onboarding-first-shift.md` | Rule 12a, Interactions | Restart returns 1-1's `prefill_sql` (OB-16); Morning shift of Day One | Approved |
| `design/gdd/game-concept.md` | Overview, Rules 9–10 | Session loop, "skippable puzzles prevent hard stops", anti-pillar (no economy) | Source of intent |
| `design/levels/chapter-1-puzzles.md` | Rule 2 | Chapter 1 request list | Level design |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grading, hint unlocking/exhausted
latching, constraint challenges and workbench behaviour are covered in their own
GDDs. [UI] = retained screenshot in `production/qa/evidence/`.*

**Structure and flow**
- **PR-01 [Integration]** GIVEN Chapter 1 data, WHEN the chapter loads, THEN Morning = 1-1…1-3, Afternoon = 1-4…1-7 + S-1, Closing = 1-8…1-11 (1-11 boss) + S-2, and 1-1/1-2 are tutorial; GIVEN `order` or `shift` changed in data, THEN the new order is used with no code change.
- **PR-02 [Logic]** GIVEN a shift with ≥ 3 main requests, WHEN one is `Open`, THEN later mains are `Locked`; WHEN it becomes passed, skipped or unavailable (rule 7a), THEN the next becomes `Open`. GIVEN *Next shift* chosen, THEN the new shift's first main stays `Locked` while its briefing shows and becomes `Open` when the briefing ends.
- **PR-03 [Logic]** GIVEN a shift's side request is unopened, WHEN all its mains are passed/skipped, THEN the shift still clocks out; side requests are `Open` from shift start, can be opened any time, and are never `Skipped`.
- **PR-04 [Logic]** GIVEN every main in a shift passed, skipped or unavailable, WHEN the last one resolves, THEN the shift is `ClockedOut` — also when all were skipped, with no scolding line, and when the last main was left as unavailable (rule 7a).

**Skip and reopen**
- **PR-05 [Integration]** GIVEN a request `exhausted`, WHEN Kenji's offer appears, THEN "Leave it for Kenji" sets `Skipped` and opens the next main; "Keep trying" keeps it `Open` and the "Leave it for Kenji" button stays on it; before exhaustion, neither offer nor button appears.
- **PR-06 [Logic]** GIVEN any main request including boss 1-11 is exhausted, WHEN the player accepts, THEN it is `Skipped`.
- **PR-07 [Logic]** GIVEN a `Skipped` request, WHEN reopened and the grader reports PASS, THEN `Passed`; replaying a `Passed` request and failing leaves it `Passed`.

**Completion, star, wage**
- **PR-08 [Logic]** GIVEN all mains passed or skipped THEN `Complete`; all passed THEN also `Starred`; ≥ 1 skipped THEN not starred; a skipped boss still allows `Complete`.
- **PR-09 [Logic]** GIVEN `Complete` with one skipped main, WHEN it is passed, THEN `Starred` is set immediately; once set, no later event revokes it.
- **PR-10 [Logic]** GIVEN any combination of side requests and challenges cleared, THEN completion, star and wage are unchanged.
- **PR-11 [UI]** GIVEN clock-out, THEN the payslip lists each request with glyph + word (✓ passed, ↷ left for later, – unavailable), ★ for challenges cleared, and a ¥3,000 wage line (Chapter 1), with Next shift / Stop for today keyboard reachable; after the last shift, End of day replaces Next shift.
- **PR-12 [Logic / code review]** GIVEN any state, THEN the wage value is read only by the payslip display (no spend, save or unlock reads).

**Invalid data, persistence, UI, log**
- **PR-13 [Integration]** GIVEN a withheld main request, THEN ordering skips it, the chapter list shows "unavailable", it is excluded from completion and star, and it is logged; GIVEN a withheld side request, THEN it is not offered and is logged; GIVEN all mains of a shift withheld, THEN the shift clocks out at once with a note.
- **PR-14 [Integration]** GIVEN the player quits mid-shift at MVP, WHEN relaunched, THEN the chapter starts at Morning with progress reset.
- **PR-15 [UI]** GIVEN each shift start THEN a briefing line is shown; GIVEN a PASS THEN the next request arrives when the PASS reaction ends (`reaction_hold`, or a click) with no intervening menu — also on 1-6, where the constraint offer is inline in the PASS reaction (no modal) and the next request arrives whether or not it was answered.
- **PR-16 [UI]** GIVEN the chapter list, THEN each request shows glyph + word for locked / open / passed / left for later / unavailable, plus a challenge mark and a replay/reopen action, at ≥ 4.5:1, never colour alone.
- **PR-18 [Integration]** GIVEN 1-5 `Open` with 2 FAILs, step 1 read and a draft, WHEN Restart is chosen and confirmed, THEN grader counters are 0, hints `Locked`, the draft empty, the result panel and last verdict cleared, and the request still `Open`; GIVEN a `Passed` or `Skipped` request, WHEN restarted, THEN its progress state is unchanged; GIVEN 1-1, WHEN restarted, THEN the prefill returns; GIVEN an empty draft, THEN no confirmation is asked; **Cancel** changes nothing.
- **PR-19 [Logic]** GIVEN the Morning shift `ClockedOut`, THEN 1-4 is `Locked` until *Next shift* (or continue after *Stop for today*), then `Open`; GIVEN *Stop for today* at MVP, THEN the shift screen shows the "Progress is kept until you close the game" note and progress is intact.
- **PR-20 [Integration]** GIVEN 1-6's challenge in challenge mode while 1-7 is `Open`, THEN 1-7 stays `Open` (its `request_open` logged once, before challenge mode), its hint `active_time` does not grow, and no shift advances until challenge mode is left, after which 1-7 is shown.
- **PR-21 [Integration]** GIVEN boss 1-11 exhausted, WHEN the player accepts Kenji's offer, THEN Kenji's `skip.accept` line is shown for its `reaction_hold` (an edit or Run does not end it), then the Closing shift clocks out, the payslip lists 1-11 as left for later, and End of day follows.
- **PR-17 [Integration]** GIVEN opens, passes, skips, unavailable requests, clock-outs and chapter completion, THEN each is written to the Playtest Log with a timestamp as `request_open`, `request_pass`, `request_skip`, `request_unavailable {source}`, `shift_clockout`, `chapter_complete` (`playtest-log.md` rule 4); GIVEN a confirmed Restart, THEN `request_restart {state, draft_was_empty}` is written; a cancelled Restart writes nothing.
- **PR-22 [Integration]** GIVEN main request 1-5 `Open` and a stub grader returning UNAVAILABLE, WHEN the player submits, THEN Kenji's `error.CONTENT_ERROR` line shows, then `skip.offer` (no hints opened, not `exhausted`); WHEN accepted, THEN 1-5 is `Unavailable`, `request_unavailable {source: submit}` is logged, the next request opens after `skip.accept`, and the chapter can still be `Complete` and `Starred` with 1-5 unavailable; WHEN declined, THEN 1-5 stays `Open` and the next UNAVAILABLE offers again. GIVEN a side request or challenge mode, THEN UNAVAILABLE makes no offer.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Does allowing a boss skip undermine the chapter's climax? Watch skip rates on 1-11 in the zero-SQL playtest; fallback: boss skip only after a longer exhaust threshold — the planned per-puzzle hint override for 1-11 (`hint-system.md` Tuning Knobs, OQ 6). Accepted risk (cross-review 6d, G2): alternating two junk queries (`SELECT 1` / `SELECT 2`) passes the distinct-query rule and reaches the offer in ~7 submits — compare time-to-skip with `boss_skip_rate` in the playtest. | game-designer | Zero-SQL playtest |
| 2 | Is the payslip's wage meaningful as flavour, or confusing without a use? (Game-designer review flagged "wage has no use".) Alternative: replace the yen amount with a manager's comment. **Progression owns this question** (Request & Reaction Dialogue defers to it). | game-designer + narrative-director | Zero-SQL playtest |
| 3 | Shift split for Chapter 1 (3 / 4 / 4) — confirm with playtest timings (target 30–60 min per shift is long for 3–4 puzzles of ~5 min). Stays open; the game concept points here for shift length. | level design | Zero-SQL playtest |
