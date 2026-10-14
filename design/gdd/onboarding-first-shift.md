# Onboarding: First Shift

> **Status**: Approved
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-15 (re-review 6c-3: APPROVED; earlier: re-review 6c-2 fix: coach-mark Done conditions scoped to their own puzzle; earlier: re-review 6c fix: coach-mark table with mark ids, 1-2 has only the schema mark; earlier: 2026-10-14 cross-GDD review fixes; art-bible sync 2026-10-14)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 3 — Fast Hands, Cheap Mistakes; Pillar 4 — Real Store, Real SQL

## Summary

Onboarding: First Shift gets a player who has never written SQL from a blank
screen to a passed request in the first minute, inside the story: Manager Tanaka
walks them through 1-1 to 1-3 with a prefilled query, a single highlighted
action at a time, click-to-insert column names and a faint example shape in the
empty editor. It teaches Run versus Submit by doing, never by lecturing, and it
steps out of the way completely for players who say they already know SQL.

> **Quick reference** — Layer: `Polish` · Priority: `MVP` · Key deps: `Query Workbench, Request & Reaction Dialogue, Store Manual`

## Overview

The concept's top design risk is a zero-SQL player bouncing off a blank editor in
the first minute; the MVP playtest requires two of three such players to clear
1-1 to 1-3 without outside help. Onboarding is the answer. It is not a separate
tutorial level: it is the Morning shift of Chapter 1, "Day One" (1-1 to 1-3),
lightly scaffolded.
Tanaka's lines carry the instructions, one **coach mark** at a time highlights
the thing to do next (Run, Submit, a column in the schema browser, the Manual
button), and the scaffolding retreats as soon as the player has done each thing
once. Nothing is skippable in a way that blocks, nothing is timed, and the
player can type freely throughout. A player who picks "I already know SQL" at
the start gets the same puzzles with no coach marks. There are no numeric
balancing rules in this system.

## Detailed Design

### Core Rules

**Who gets it**

1. At the start of a new game, Tanaka asks once: "Ever used SQL before?" —
   **"No, show me around"** (default) or **"Yes, I know SQL"**. The question is
   a Dialogue `system` line in the bubble with the two choices as buttons,
   shown **before** 1-1's request arrives (`request-and-reaction-dialogue.md`
   rule 2), so it never competes with a request. 1-1's `request_open` fires
   only **after** the player answers (so manual / hint unlocks and the Playtest
   Log's time-to-first-Run clock start then). "Yes" turns off coach marks
   and ghost text for the whole game (also a setting); the puzzles (including
   1-1's prefill), hints and manual are unchanged, and the workbench's
   first-submit explainer then shows on 1-1's first submit as usual. The choice
   is logged.

**The scaffolded Morning shift** (coach marks on)

2. **1-1 Open the Ledger** — the editor is **prefilled** from the puzzle's
   `prefill_sql` field (Puzzle Definition owns it; for 1-1,
   `SELECT * FROM products;`, the reference). The prefill is puzzle data, so it
   applies in Guided and Off alike. Steps, one coach mark at a time:
   1. Mark on **Run** — Tanaka: "Press Run (Ctrl+Enter) to see what's on the
      shelves." → the player runs; the ledger appears.
   2. Mark on **Submit** — Tanaka: "Now hand it to me — Submit
      (Ctrl+Shift+Enter)." → submit; with the prefilled text unchanged it
      **passes**, so the first submit of the game is a success. (This line
      replaces the workbench's one-time first-submit explainer, which then
      shows on 1-2's first submit.)
3. **1-2 New Price Tags** — the editor starts **empty** with **ghost text**
   showing the shape `SELECT … FROM products` (see rule 6). Coach mark on the
   **schema browser**: "Click a column to put it in your query." Clicking `name`
   then `price` inserts them at the caret, and the workbench's auto-separator
   adds the `, ` between them (workbench rule 3), giving
   `SELECT name, price FROM products` with nothing typed. 1-2 has **only this
   schema mark**: Run and Submit were taught on 1-1, so no Run or Submit mark
   appears on 1-2 (rule 7a).
4. **1-3 Noodle Aisle Check** — the first `WHERE`. When the request opens, the
   Store Manual's "Filtering rows" page unlocks and a coach mark points at the
   **Manual button**: "New page in the binder — have a look if you need it."
   Ghost text shows `SELECT … FROM products WHERE …`. No other scaffolding: the
   first hidden-data lesson (hardcoded ids fail) is the player's own.
5. After 1-3 coach marks and ghost text end. Hints (both steps at once on the
   `tutorial` puzzles 1-1 and 1-2, and the faster 1-3 override — Hint System
   Formulas) and the manual remain as the support for the rest of
   the game.

**Coach marks and ghost text**

6. **Ghost text** appears only while the editor is empty, disappears on the first
   keystroke or insertion, and returns if the editor is emptied again. It is a
   *shape*, never an answer: it never contains a value, a column chosen for the
   puzzle, or a condition. It is labelled "shape" so it is never mistaken for
   real text, and Run on an empty editor still returns `EMPTY` (Dialogue line
   `error.EMPTY`).
   Pressing **Tab** in the empty editor, or clicking the ghost text,
   **materialises the shape** as real text with the caret in the first blank
   (`SELECT ▮ FROM products`), so a zero-SQL player can build 1-2 from the shape
   and two schema clicks. The shape is still not an answer. Ghost text exists
   only on 1-2 and 1-3; its two strings are Onboarding data (string ids
   `onboarding.ghost.1-2`, `onboarding.ghost.1-3`), not puzzle fields.
7. **Coach marks** (a dismissed mark never reappears; turning coach marks back
   on in settings resumes from the next unfinished step): at most one at a time; a ring around the target plus a
   label holding Tanaka's guidance line (with his name tag). **Guidance is never
   put in the speech bubble** — the bubble keeps the current request (Dialogue
   rule 2); they never block input, never cover
   the editor's text or the result tables, and disappear as soon as the target
   action is done. "Got it", or Esc **while the mark has focus**, dismisses one
   early; with focus in the editor, Esc keeps its workbench meaning (leave the
   editor) and the mark stays (workbench rule 15, Esc precedence). Ring is
   static under reduced motion. While a coach mark is showing, the hint and
   manual "new" indicators are suppressed; they appear once no mark is showing
   (workbench rule 6), so the player meets one new signal at a time.
7a. **The marks.** Guided mode has exactly these four marks, in this order;
   the mark id is the `{mark}` value of the Playtest Log's
   `mark_shown/done/dismissed` events:

| Mark id | Puzzle | Target | Tanaka's label | Done when |
|---|---|---|---|---|
| `1-1.run` | 1-1 | Run button | "Press Run (Ctrl+Enter) to see what's on the shelves." | Any Run on 1-1, or a Submit on 1-1 first (rule 8) |
| `1-1.submit` | 1-1 | Submit button | "Now hand it to me — Submit (Ctrl+Shift+Enter)." | Any Submit on 1-1 |
| `1-2.schema` | 1-2 | Schema browser | "Click a column to put it in your query." | A column name appears in 1-2's editor by any means (Edge Cases) |
| `1-3.manual` | 1-3 | Manual button | "New page in the binder — have a look if you need it." | The Manual panel is opened on 1-3 |

   **Done conditions are scoped to the mark's own puzzle**: they count only
   while that puzzle is open. Doing a later mark's target on an earlier puzzle
   (opening the Manual on 1-1, typing a column name on 1-1) completes nothing,
   and the later mark still shows on its own puzzle. The only early completion
   is within a puzzle: a Submit on 1-1 before any Run marks `1-1.run` Done.
   A mark whose puzzle is never opened in this game (e.g. 1-3 skipped) stays
   `Pending` and is never shown later.
8. Nothing in onboarding is timed; the player may type, run and experiment freely
   at any step, and doing a later step of the same puzzle early simply skips
   that puzzle's earlier marks (rule 7a; marks never complete across puzzles).

**What onboarding never does**

9. It never fills in an answer beyond 1-1's prefill (1-1 is a tutorial whose
   answer *is* `SELECT *`), never auto-runs or auto-submits, never opens the
   manual by itself, and never hides any part of the workbench.

### States and Transitions

Per game: `Ask` → `Guided` ("No, show me around") or `Off` ("Yes, I know SQL"),
changeable later in settings.

Per coach mark (Guided only): `Pending → Shown → Done` (target action performed)
or `→ Dismissed` ("Got it", or Esc with the mark focused). Marks run in the fixed order of the rule 7a table; doing a
later target of the **same puzzle** early marks that puzzle's earlier ones `Done`
(Done conditions count only while the mark's puzzle is open — rule 7a).

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Query Workbench | Onboarding → Workbench | Ghost text; coach-mark anchors (Run, Submit, schema browser, Manual button); coach-mark visibility (the workbench suppresses hint / manual "new" indicators while a mark shows; Esc precedence) | Workbench renders; Onboarding decides |
| Request & Reaction Dialogue | Onboarding → Dialogue | The "Ever used SQL before?" `system` line and its two choices (before 1-1's request); Tanaka's one-time "start over" `system` line (Guided only); guidance lines are rendered in coach-mark labels by Onboarding, never in the bubble | Dialogue renders the lines |
| Store Manual | Manual → Onboarding | "Filtering rows" unlocked on 1-3 → coach mark on the Manual button | Store Manual |
| Hint System | — | `tutorial` puzzles 1-1/1-2 (both steps at once) and the 1-3 override (Hint System Formulas) | Hint System |
| Shift & Chapter Progression | Progression → Onboarding | Which request is open | Progression |
| Puzzle Definition & Datasets | Puzzle → Onboarding | `tutorial` flags (1-1, 1-2); `prefill_sql` (1-1: `SELECT * FROM products;`) | Puzzle Definition |
| Accessibility Options (VS) / Settings | Settings ↔ Onboarding | "Coach marks" on/off; reduced motion | Settings |
| Playtest Log | Onboarding → Log | Answer to "Ever used SQL before?" (`sql_question`), each mark shown/done/dismissed with timestamps. Time to first Run / first PASS are **computed by the Playtest Log's formulas** from `request_open`, `run` and `request_pass` (authoritative); Onboarding emits no `first_run` / `first_pass` events | Onboarding |

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the player edits 1-1's prefilled query before running**: allowed; Run and Submit grade whatever is there; a broken edit gets the normal error/feedback and, **in Guided mode only**, Tanaka adds "You can always start over with the ledger: `SELECT * FROM products;`" once per game, as a one-time `system` line in the **bubble** after the error reaction (Dialogue rule 2; it returns to the request like any reaction).
- **If the player submits 1-1 before running**: allowed; `1-1.submit` is Done and `1-1.run` is marked Done too (rule 8), without being shown.
- **If the player types in 1-2 before clicking the schema browser**: the schema mark is marked Done as soon as a column name appears in the editor by any means.
- **If the player dismisses every coach mark**: onboarding continues silently; no re-prompts.
- **If the player chose "Yes, I know SQL" and later struggles**: hints and the manual work as usual; coach marks can be re-enabled in settings.
- **If the player presses Esc while a coach mark shows and focus is in the editor**: focus leaves the editor; the mark stays (workbench Esc precedence).
- **If a manual page or hint unlocks while a coach mark shows** (e.g. "Reading the ledger" on 1-1): its "new" indicator waits until no mark is showing.
- **If the player restarts 1-1 from the chapter list**: the prefill (`prefill_sql`) returns; coach marks do not replay (they are per game, not per puzzle).
- **If the player opens the manual on 1-1 or 1-2**: nothing is marked Done (rule 7a scope); the 1-1 / 1-2 marks continue and the 1-3 mark still shows when 1-3 opens.
- **If the player opens the manual on 1-3 before its mark is shown** (e.g. Ctrl+M as the request arrives): `1-3.manual` is Done and never shown.
- **If text scale or window size changes while a mark is shown**: the ring follows its target; it never moves over the editor text.

## Dependencies

**Upstream (hard):**

| System | GDD | What Onboarding needs | Status |
|---|---|---|---|
| Query Workbench | `design/gdd/query-workbench.md` | Prefill, ghost text, coach-mark anchors, click-to-insert | In Review |
| Request & Reaction Dialogue | `design/gdd/request-and-reaction-dialogue.md` | Tanaka's lines, the opening question | In Review |
| Store Manual | `design/gdd/store-manual.md` | Unlock event for "Filtering rows" | In Review |

**Soft:** Shift & Chapter Progression, Puzzle Definition (tutorial flags), Hint
System (early unlocks), Settings (VS), Playtest Log.

**Bidirectionality:** workbench, dialogue, store manual and hint system list
Onboarding ✓ (workbench Interactions; dialogue Interactions; manual rule 6;
Hint System Interactions — added 2026-10-14). Puzzle Definition must list
Onboarding as a consumer of `tutorial` and `prefill_sql`.

## Visual/Audio Requirements

*`art-director` not consulted — Lean mode. Synced to the art bible
(`design/art/art-bible.md`) 2026-10-14; the bible is authoritative for visuals
where they differ.*

- Coach mark: a **2 px dashed `ink`** rounded-rect ring around the target (solid
  rings are reserved for focus; 13.55:1 on paper) plus a paper tag with a short
  label (glyph + words). The label tag appears in place on frame 1; the ring
  starts 4 px outset and settles onto the target with a fade in 200 ms, once
  (ease-out); under reduced motion the ring appears in its final state (art
  bible 3.3, 7.5, 7.6).
- Ghost text in the editor: `ghost` `#A89A7C` IBM Plex Mono Italic (5.71:1 on
  the editor background), lighter than real code, with a small "shape" label so
  it is never mistaken for typed text (art bible 4.2, 4.4).
- Tanaka's guidance is in the coach-mark label: paper tag, his name tag, the
  workbench body font ≥ 4.5:1; the speech bubble keeps the request. Only the
  opening question uses the bubble (before any request).
- No tutorial sounds beyond the normal dialogue blips.

## Game Feel

The first minute should feel like a friendly manager standing next to you on
day one: one thing at a time, nothing to read before you can act, and the first
Submit is a success. The scaffolding should disappear before the player notices
they no longer need it.

## UI Requirements

1. Opening question with two keyboard-reachable choices.
2. Coach marks anchored to Run, Submit, schema browser and Manual button; "Got
   it" button; Esc dismisses when the mark has focus (workbench Esc precedence).
3. Ghost text in an empty editor, labelled "shape".
4. Settings toggle "Coach marks" (MVP: in a minimal options panel owned by
   Onboarding, holding only this toggle; the answer and toggle last for the
   session until Save/Load & Settings exists — Vertical Slice).

> **📌 UX Flag — Onboarding**: include coach marks, ghost text and the opening
> question in the Query Workbench UX spec (`/ux-design`, Pre-Production).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/game-concept.md` | Overview | Top design risk (zero-SQL bounce); MVP threshold "≥ 2 of 3 zero-SQL testers clear 1-1 to 1-3 without outside help" | Source of intent |
| `design/gdd/query-workbench.md` | Rules 2–3, 6–7 | Click-to-insert with auto-separator; first-submit explainer (moved to 1-2 when onboarding is on) | In Review |
| `design/gdd/hint-system.md` | Rule 5 | Early unlocks on 1-1 to 1-3 | In Review |
| `design/gdd/store-manual.md` | Rules 4–6 | "Filtering rows" page unlock; 1-1 exemption from the example check | In Review |
| `design/gdd/puzzle-definition-and-datasets.md` | Rule 2 | 1-1 and 1-2 flagged `tutorial` | In Review |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Not repeated: schema click-to-insert
(QW-22), the first-submit explainer itself (QW-15), manual unlocking (SM-xx),
early hint unlocks (HS-07). Fixtures from `prototypes/sqlbini-web/ch1.py`. [UI] =
retained screenshot in `production/qa/evidence/`.*

**Opening question**
- **OB-01 [UI]** GIVEN a new game, WHEN the question appears, THEN "No, show me around" is the default and both choices are keyboard reachable.
- **OB-02 [Logic]** GIVEN "Yes, I know SQL", THEN no coach mark or ghost text appears in 1-1 to 1-3; 1-1 is still prefilled and the first-submit explainer shows on 1-1; puzzles, hints and manual behave as in Guided; the answer is logged.
- **OB-03 [Integration]** GIVEN Off, WHEN coach marks are turned on in settings, THEN marks and ghost text resume from the next unfinished step; turning them off stops them at once.

**1-1**
- **OB-04 [Logic]** GIVEN 1-1 in Guided, THEN the editor equals 1-1's `prefill_sql`, `SELECT * FROM products;` (the reference); the Run mark shows first, then the Submit mark after a Run; GIVEN a new game, THEN 1-1's `request_open` is logged only after the "Ever used SQL before?" answer.
- **OB-05 [Integration]** GIVEN the prefill unchanged, WHEN submitted, THEN PASS; the workbench explainer does not show on 1-1 and shows on 1-2's first submit.
- **OB-06 [Logic]** GIVEN the player submits 1-1 before running, THEN both the Run and Submit marks are Done.
- **OB-07 [Integration]** GIVEN the prefill edited into an error, WHEN run, THEN the normal error appears and Tanaka adds the "start over with `SELECT * FROM products;`" line in the bubble exactly once per game; GIVEN Off, THEN the line never appears.

**1-2 and 1-3**
- **OB-08 [Logic]** GIVEN 1-2 opens, THEN the editor is empty, ghost text shows `SELECT … FROM products`, and the schema mark is active.
- **OB-09 [Logic]** GIVEN the empty 1-2 editor, WHEN Tab is pressed (or the ghost text clicked), THEN the editor contains `SELECT  FROM products` with the caret in the blank.
- **OB-10 [Logic]** GIVEN the schema mark, WHEN a column name appears in the editor by click, typing or paste, THEN the mark is Done.
- **OB-11 [Integration]** GIVEN 1-3 opens, THEN "Filtering rows" unlocks, the Manual-button mark shows, and ghost text shows `SELECT … FROM products WHERE …`; GIVEN the manual was opened on 1-3 before the mark showed, THEN the mark is Done and never shown; GIVEN it was opened only on 1-1 or 1-2, THEN the mark still shows on 1-3.
- **OB-12 [Logic]** GIVEN 1-3 passed, THEN no further marks appear anywhere in the game.

**Mark behaviour**
- **OB-13 [Logic]** Guided mode defines exactly the four marks of rule 7a (`1-1.run`, `1-1.submit`, `1-2.schema`, `1-3.manual`), each logged with that id; at most one is shown at a time, in table order; a Submit on 1-1 before any Run marks `1-1.run` Done; on 1-2 no Run or Submit mark is ever shown. GIVEN Guided at 1-1 with `1-1.run` shown, WHEN the Manual is opened and a column name is typed, THEN `1-1.run` stays shown, no mark becomes Done, and later `1-2.schema` and `1-3.manual` each show when their puzzle opens.
- **OB-14 [Logic]** A shown mark becomes Done on its target action and Dismissed on "Got it" or Esc with the mark focused; Esc with focus in the editor leaves the editor and the mark stays; a dismissed mark never reappears.
- **OB-24 [Integration]** GIVEN a coach mark shown and a manual page or hint unlocking (1-1 "Reading the ledger"), THEN no "new" indicator is visible until no mark is showing, then it appears.
- **OB-15 [UI]** GIVEN a mark shown, THEN typing, Run and clicks still work, the ring never overlaps editor text or result tables, and it follows its target on resize or text scaling.
- **OB-16 [Logic]** GIVEN 1-1 restarted, THEN the prefill returns and no mark replays.

**Ghost text**
- **OB-17 [Logic]** Ghost text shows only while the editor is empty, disappears on the first keystroke or insert, and returns when the editor is emptied; Run on an empty editor still returns `EMPTY`.
- **OB-18 [Content-CI]** Every ghost-text string matches only `SELECT … FROM <table> [WHERE …]` — no value, no column name, no condition.
- **OB-19 [Logic]** Onboarding never auto-runs, auto-submits, opens the manual, or writes editor text itself; in Chapter 1 only 1-1 has a `prefill_sql`.

**Presentation, log, threshold**
- **OB-20 [UI]** Screenshots of each mark, the ghost text with its "shape" label, and the opening question; ghost text ≥ 4.5:1, ring ≥ 3:1; static ring under reduced motion.
- **OB-21 [Integration]** The Playtest Log records the answer and each mark shown / done / dismissed with timestamps; Onboarding emits no `first_run` / `first_pass` events (time to first Run / PASS come from the Playtest Log's formulas).
- **OB-22 [Integration]** A scripted zero-SQL path clears 1-1 by clicks only (Run, Submit) and 1-2 using Tab, two schema clicks and no typed characters.
- **OB-23 [UI]** Screenshots of each 1-1 to 1-3 mark show the request in the bubble and Tanaka's guidance only in the coach-mark label; the new-game screenshot shows the "Ever used SQL before?" question in the bubble before any request.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Is a prefilled 1-1 too trivial for zero-SQL players to feel they did something? Watch time-to-first-Run and reactions. | ux-designer | Zero-SQL playtest |
| 2 | Does the ghost text in 1-3 (`… WHERE …`) help, or does it make players guess syntax instead of opening the manual? | ux-designer | Zero-SQL playtest |
| 3 | Should "Yes, I know SQL" also skip 1-1 and 1-2 (straight to 1-3)? | game-designer | After MVP playtest |
| 4 | (art bible 2026-10-14) Reduced motion must be reachable at MVP (art bible 7.6; UX R-04): add a reduced-motion toggle to the minimal options panel (UI Requirement 4), or follow the OS preference? Not decided here. | Onboarding owner + ux-designer | `/ux-design` |
