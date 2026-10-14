# Shift & Chapter Progression

> **Status**: In Design
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14
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
2. Chapter 1 ("First Shift", 2026-03-02) is laid out as:

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
   available when the current one is **passed** or **left for later** (rule 7).
5. Side requests are offered as messages (HQ email, a question from the manager)
   when their shift starts. They are optional, can be opened any time during the
   chapter, and never block anything.
6. A shift **ends** when all its main requests are passed or left for later. The
   player then **clocks out**: the payslip screen (rule 10) is shown and the
   game offers *Next shift* or *Stop for today*. Stopping is the natural session
   end. After the **last** shift, the payslip is followed by an *End of day*
   summary (chapter complete / starred, requests left for later) instead of
   *Next shift*.

**Leaving a request for later (no hard stops)**

7. When the Hint System reports a request **exhausted** (both hints read, then
   further fails), Kenji offers to take it: "Want me to handle this one? You can
   come back to it anytime." Accepting marks the request **left for later**
   (`skipped`) and moves on. This applies to every main request, **the boss
   included** — a zero-SQL player is never stuck behind one puzzle.
8. A skipped request stays in the chapter list and can be reopened at any time;
   passing it later turns it into **passed**. Skipping costs nothing beyond the
   chapter star (rule 9).

**Finishing a chapter**

9. A chapter is **complete** when every main request is passed or skipped; the
   next chapter then unlocks (Chapter 2 is outside the MVP). A chapter earns its
   **star** (★) only when every main request is **passed** — the mastery reward
   that skipping forgoes. Side requests and constraint challenges never affect
   completion or the star. Progress only moves forward: a `Passed` request never
   reverts and a star is never revoked.

**The payslip**

10. At clock-out the payslip lists the shift's requests with their marks
    (passed / left for later), constraint challenges cleared, and a fixed
    **wage** in yen for the shift (a content value per shift — Chapter 1: ¥3,000
    per shift). The wage is **flavour only**: it is never spent, saved up, or
    used to unlock anything (anti-pillar: not a management sim).

**Between requests**

11. Each shift starts with a short briefing line from the manager (Request &
    Reaction Dialogue). Between requests the next requester's message arrives
    immediately — no menus between puzzles.
12. The **chapter list** (opened from the shift screen) shows every request of the
    chapter with its state, its challenge mark, and lets the player replay any
    passed request or reopen a skipped one. Replays never change progress
    except turning skipped into passed.

**Persistence**

13. At MVP, progress lasts for the play session. Saving progress across sessions
    — at least at every pass, skip and clock-out — is Save/Load & Settings
    (Vertical Slice).

### States and Transitions

**Per request:**

| State | Meaning | Event | To |
|---|---|---|---|
| `Locked` | An earlier main request in the shift is not yet passed/skipped | Previous main request passed or skipped | `Open` |
| `Open` | Available in the workbench | Grader PASS | `Passed` |
| `Open` | | Hint `exhausted` → player accepts Kenji's offer | `Skipped` |
| `Skipped` | Left for later | Reopened and passed | `Passed` |
| `Passed` | Done | Replay | `Passed` |

Side requests start `Open` when their shift starts and are never `Skipped`.

**Per shift:** `NotStarted → InProgress` (first request opened) `→ ClockedOut`
(all main requests passed or skipped; payslip shown).

**Per chapter:** `Locked → InProgress → Complete` (all main passed/skipped) and,
independently, `Starred` (all main passed).

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Progression | `chapter`, `shift`, `order`, `flags` (tutorial, side, boss), chapter "today", shift wage | Puzzle Definition |
| Hidden-Data Grader | Grader → Progression | PASS events | Grader |
| Hint System | Hints → Progression | `exhausted` per request | Hint System |
| Constraint Challenges | both | Base PASS triggers the offer; challenge marks on the chapter list and payslip | Constraint Challenges |
| Query Workbench | Progression → Workbench | Which request is open | Progression |
| Request & Reaction Dialogue | Progression → Dialogue | Shift briefing, Kenji's skip offer, side-request messages | Dialogue |
| Store Manual | Progression → Manual | Request opened (manual pages unlock by the request's keywords) | Store Manual |
| Save/Load & Settings (VS) | Progression → Save | Request, shift, chapter states | Save/Load |
| Game Shell & Screen Flow (VS) | Shell → Progression | Start / continue chapter | Game Shell |
| Achievements (VS) | Progression → Achievements | Chapter complete / starred events | Achievements |
| Playtest Log | Progression → Log | Request opened/passed/skipped, shift clock-out, chapter complete, with timestamps | Progression |

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the player declines Kenji's offer**: the request stays `Open`; the offer can be accepted later from a "Leave it for Kenji" button that stays visible on that request while it is `exhausted`.
- **If the boss is skipped**: the chapter can still complete (rule 9) but cannot be starred; the payslip and chapter list show "left for later".
- **If every main request of a shift is skipped**: the shift still clocks out normally; the payslip lists them as left for later. No scolding line.
- **If the player reopens a skipped request and passes it after the chapter is complete**: it becomes `Passed`; if that was the last skipped main request, the chapter becomes `Starred` immediately.
- **If the player quits mid-shift (MVP, no save)**: progress is lost; on relaunch the chapter starts at the Morning shift. (Vertical Slice Save/Load fixes this.)
- **If the player opens a side request mid-shift**: allowed; the main request's draft and state are kept (workbench draft restore).
- **If a side request is never opened**: no effect on completion, star or wage.
- **If a request is withheld by content validation** (invalid data): it is skipped automatically for ordering purposes, shown as "unavailable" in the chapter list, and excluded from completion and star checks; the Playtest Log records it.
- **If two shifts' requests are reordered in data**: order is taken from the data; no hardcoded sequence.
- **If a replayed passed request is failed**: no effect on its `Passed` state (same as the grader rule).
- **If every main request of a shift is unavailable** (withheld): the shift clocks out at once with a note on the payslip; the log records it.
- **If a side request is invalid**: it is not offered at all (no message), and the log records it.

## Dependencies

**Upstream (hard):**

| System | GDD | What Progression needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Ordering fields, flags, chapter "today", shift wage | Designed (pending review) — shift wage is a new chapter field |
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | PASS events | Designed (pending review) |
| Hint System | `design/gdd/hint-system.md` | `exhausted` events | Designed (pending review) |

**Soft / hosted:** Constraint Challenges (offer after PASS; marks), Request &
Reaction Dialogue (briefings, Kenji's offer, side messages), Query Workbench
(open request), Store Manual (unlock by keywords), Playtest Log.

**Downstream (VS):** Save/Load & Settings, Game Shell & Screen Flow, Achievements.

**Bidirectionality:** the grader, puzzle definition, hint system and constraint
challenges list Shift & Chapter Progression ✓.

## Visual/Audio Requirements

*Optional for `Progression` systems; `art-director` not consulted — Lean mode.
Mood direction "aesthetic, cozy" is in `design/ideas-backlog.md` (#1) for the art
bible.*

- **Shift briefing:** a short line from the manager over the store at the time of
  day (morning light, afternoon, closing) — the time of day is the shift's
  visual signature.
- **Payslip:** a printed receipt (store paper as UI) listing the shift's requests
  with glyph + word marks (✓ passed, ↷ left for later, ★ challenge cleared) and
  the wage line; a soft receipt-printer sound.
- **Chapter list:** a shift-by-shift checklist on a clipboard; states use glyph +
  word, never colour alone.
- **Chapter star:** a single small ★ stamp on the chapter card — no fanfare.

## Game Feel

A shift should feel like a calm, satisfying work session: requests keep arriving
without menus in between, and clocking out is a soft, rewarding pause — a good
place to stop for the night. Being stuck never feels like a wall: Kenji's offer
arrives as a friendly coworker, and the request waits in the list without
judgement. Mastery is visible (the star) but never required to keep going.

## UI Requirements

1. Shift screen: current shift name, requests done / total, access to the chapter list.
2. Kenji's offer: **Leave it for Kenji** / **Keep trying**, keyboard reachable; the "Leave it for Kenji" button stays on an exhausted request.
3. Payslip after each shift with **Next shift** / **Stop for today**.
4. Chapter list: every request with state (locked / open / passed / left for later / unavailable), challenge mark, replay/reopen action.
5. All states glyph + word; ≥ 4.5:1 contrast.

> **📌 UX Flag — Shift & Chapter Progression**: In Pre-Production, run
> `/ux-design` for the shift screen, payslip and chapter list before writing
> epics.

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hint-system.md` | Core Rule 7 | `exhausted` event; Open Question 3 answered here (skip any main request incl. boss) | Designed (pending review) |
| `design/gdd/constraint-challenges.md` | Rules 2, 9–10 | Chapter 1 challenge puzzles; challenges never affect completion | Designed (pending review) |
| `design/gdd/puzzle-definition-and-datasets.md` | Rules 1, 3 | Ordering fields, flags, chapter definition | Designed (pending review) |
| `design/gdd/game-concept.md` | Overview, Rules 9–10 | Session loop, "skippable puzzles prevent hard stops", anti-pillar (no economy) | Source of intent |
| `design/levels/chapter-1-puzzles.md` | Rule 2 | Chapter 1 request list | Level design |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grading, hint unlocking/exhausted
latching, constraint challenges and workbench behaviour are covered in their own
GDDs. [UI] = retained screenshot in `production/qa/evidence/`.*

**Structure and flow**
- **PR-01 [Integration]** GIVEN Chapter 1 data, WHEN the chapter loads, THEN Morning = 1-1…1-3, Afternoon = 1-4…1-7 + S-1, Closing = 1-8…1-11 (1-11 boss) + S-2, and 1-1/1-2 are tutorial; GIVEN `order` or `shift` changed in data, THEN the new order is used with no code change.
- **PR-02 [Logic]** GIVEN a shift with ≥ 3 main requests, WHEN one is `Open`, THEN later mains are `Locked`; WHEN it becomes passed or skipped, THEN the next becomes `Open`.
- **PR-03 [Logic]** GIVEN a shift's side request is unopened, WHEN all its mains are passed/skipped, THEN the shift still clocks out; side requests are `Open` from shift start, can be opened any time, and are never `Skipped`.
- **PR-04 [Logic]** GIVEN every main in a shift passed or skipped, WHEN the last one resolves, THEN the shift is `ClockedOut` — also when all were skipped, with no scolding line.

**Skip and reopen**
- **PR-05 [Integration]** GIVEN a request `exhausted`, WHEN Kenji's offer appears, THEN "Leave it for Kenji" sets `Skipped` and opens the next main; "Keep trying" keeps it `Open` and the "Leave it for Kenji" button stays on it; before exhaustion, neither offer nor button appears.
- **PR-06 [Logic]** GIVEN any main request including boss 1-11 is exhausted, WHEN the player accepts, THEN it is `Skipped`.
- **PR-07 [Logic]** GIVEN a `Skipped` request, WHEN reopened and the grader reports PASS, THEN `Passed`; replaying a `Passed` request and failing leaves it `Passed`.

**Completion, star, wage**
- **PR-08 [Logic]** GIVEN all mains passed or skipped THEN `Complete`; all passed THEN also `Starred`; ≥ 1 skipped THEN not starred; a skipped boss still allows `Complete`.
- **PR-09 [Logic]** GIVEN `Complete` with one skipped main, WHEN it is passed, THEN `Starred` is set immediately; once set, no later event revokes it.
- **PR-10 [Logic]** GIVEN any combination of side requests and challenges cleared, THEN completion, star and wage are unchanged.
- **PR-11 [UI]** GIVEN clock-out, THEN the payslip lists each request with glyph + word (✓ passed, ↷ left for later), ★ for challenges cleared, and a ¥3,000 wage line (Chapter 1), with Next shift / Stop for today keyboard reachable; after the last shift, End of day replaces Next shift.
- **PR-12 [Logic / code review]** GIVEN any state, THEN the wage value is read only by the payslip display (no spend, save or unlock reads).

**Invalid data, persistence, UI, log**
- **PR-13 [Integration]** GIVEN a withheld main request, THEN ordering skips it, the chapter list shows "unavailable", it is excluded from completion and star, and it is logged; GIVEN a withheld side request, THEN it is not offered and is logged; GIVEN all mains of a shift withheld, THEN the shift clocks out at once with a note.
- **PR-14 [Integration]** GIVEN the player quits mid-shift at MVP, WHEN relaunched, THEN the chapter starts at Morning with progress reset.
- **PR-15 [UI]** GIVEN each shift start THEN a briefing line is shown; GIVEN a PASS THEN the next request arrives with no intervening menu.
- **PR-16 [UI]** GIVEN the chapter list, THEN each request shows glyph + word for locked / open / passed / left for later / unavailable, plus a challenge mark and a replay/reopen action, at ≥ 4.5:1, never colour alone.
- **PR-17 [Integration]** GIVEN opens, passes, skips, unavailable requests, clock-outs and chapter completion, THEN each is written to the Playtest Log with a timestamp.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Does allowing a boss skip undermine the chapter's climax? Watch skip rates on 1-11 in the zero-SQL playtest; fallback: boss skip only after a longer exhaust threshold. | game-designer | Zero-SQL playtest |
| 2 | Is the payslip's wage meaningful as flavour, or confusing without a use? (Game-designer review flagged "wage has no use".) Alternative: replace the yen amount with a manager's comment. | game-designer + narrative-director | Request & Reaction Dialogue GDD |
| 3 | Shift split for Chapter 1 (3 / 4 / 4) — confirm with playtest timings (target 30–60 min per shift is long for 3–4 puzzles of ~5 min). | level design | Zero-SQL playtest |
