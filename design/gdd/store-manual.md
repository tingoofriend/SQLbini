# Store Manual

> **Status**: Approved
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-15 (re-review 6c fix: `watch_out` carries a `rule_tag`, no conditional `watch_out`, `trap_rules` CI check; earlier: 2026-10-14 cross-GDD review fixes; art-bible sync 2026-10-14)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 4 — Real Store, Real SQL (anti-pillar: NOT a textbook)

## Summary

The Store Manual is an in-world binder of notes left by the previous part-timer:
one short page per SQL idea — what it does, its shape, one example on the store's
own data, and the one thing people get wrong. Pages appear the first time a
request needs them and are always one key away, but the game never pushes the
player to read them. It is the zero-SQL player's syntax path that keeps the
"no lectures" promise.

> **Quick reference** — Layer: `Presentation` · Priority: `MVP` · Key deps: `Puzzle Definition & Datasets, Shift & Chapter Progression, Query Workbench`

## Overview

The Store Manual answers the question a zero-SQL player has before any trap can
teach them anything: *how do I even write this?* It is a binder behind the
counter — "Notes from the last part-timer" — with a page per SQL concept the
chapter uses (`SELECT`, `WHERE`, comparisons, `AND`/`OR`, `IN`, `BETWEEN`,
`LIKE`, `NULL`, `DISTINCT`, `AS`). Each page is short and concrete, written in a
friendly coworker's voice, with a real example on the `products` table. Pages
unlock when a request first needs them, so the binder grows with the player, and
the Manual button lights up quietly when a new page arrives. Reading is always
the player's choice: no page is forced open, there are no quizzes, and nothing is
scored — the concept's anti-pillar "NOT a textbook" allows a reference the player
chooses to open, never a lecture. Without it, the zero-SQL condition in the MVP
playtest (clear 1-1 to 1-3 without outside help) has no way to pass.

## Detailed Design

### Core Rules

**Pages**

1. The manual is a list of **pages**, each defined in data: `id` (`manual.<slug>`,
   e.g. `manual.between`) — the key puzzles use in their `manual_pages` list
   (Puzzle Definition) — `title`, the SQL keyword(s) or operators it covers
   (display only, not an unlock key), `body` (2–4 short sentences), `shape` (the syntax
   pattern, e.g. `SELECT columns FROM table WHERE condition`), one `example`
   query on the chapter's visible data with a one-line note of what it returns,
   and an optional `watch_out` line (the common mistake, stated as a fact —
   e.g., on a later chapter's page, "BETWEEN includes both ends") with its
   required `rule_tag` (a short id for the SQL rule the line states, e.g.
   `between_inclusive`; rule 3a).
2. Chapter 1 pages (MVP):

| Page | Covers | First needed by |
|---|---|---|
| Reading the ledger | `SELECT`, `FROM`, `*` | 1-1 |
| Picking columns | column lists, `,` | 1-2 |
| Filtering rows | `WHERE`, `=`, text in quotes | 1-3 |
| Comparing numbers and dates | `<`, `<=`, `>`, `>=`, `<>`; dates as `'YYYY-MM-DD'` | 1-4 |
| More than one condition | `AND`, `OR`, parentheses | 1-5 |
| A list of values | `IN` | 1-6 |
| A range | `BETWEEN … AND …` | 1-8 |
| Looking for part of a word | `LIKE`, `%`, `_` | 1-9 |
| Empty values | `NULL`, `IS NULL`, `IS NOT NULL` | 1-10 |
| No duplicates | `DISTINCT` | S-1 |
| Calculated columns | arithmetic, `AS` | S-2 |

   Which puzzle unlocks which page comes from each puzzle's `manual_pages` —
   a list of page ids (`manual.<slug>`), possibly empty (Puzzle Definition);
   the table is the Chapter 1 default. Page ids are used so pages with no
   keyword ("Picking columns", comparison operators) can still be unlocked.
3. Pages tell the truth about SQL (Pillar 4) — `watch_out` lines state real
   rules (e.g., outside Chapter 1, "`= NULL` never matches; use `IS NULL`"). Traps still bite because
   requests are written in natural language and the player must apply the rule
   to what the customer *means* (trap philosophy). Pages never mention a
   specific puzzle, its data, or its answer.
3a. **No `watch_out` pre-solves a Chapter 1 trap.** A page's `watch_out` must
   not state the rule a Chapter 1 trap tests. Such a line is simply **omitted**
   in Chapter 1 (there is no conditional `watch_out` at MVP). In particular,
   the "More than one condition" (AND/OR) page carries **no precedence
   `watch_out`** (the 1-6 and 1-11 traps), "A range" none on inclusive ends
   (1-8) and "Empty values" none on `= NULL` (1-10). The check is mechanical:
   the manual's content data holds `trap_rules` — a map from every Chapter 1
   trap id (Puzzle Definition) to the `rule_tag` of the rule it tests, written
   by the content author alongside the trap — and CI fails if any Chapter 1
   page's `watch_out.rule_tag` is one of those tags, or if a Chapter 1 trap id
   has no `trap_rules` entry.
4. **Examples never solve a puzzle.** No page example, run as a player's query,
   may pass any puzzle in the game (content CI check, like the Hint System's).
   **One exception:** a puzzle whose `prefill_sql` (Puzzle Definition) is its
   reference is exempt, since its answer is already on screen (1-1,
   `SELECT * FROM products;` — `onboarding-first-shift.md` rule 2); the CI
   check keys on that field, not on a puzzle id. This lets "Reading the ledger"
   show the plain `SELECT * FROM products;`. Every other
   puzzle, including tutorial 1-2, is checked — so "Picking columns" uses a
   list other than 1-2's (e.g. `SELECT name, category FROM products`).

**Unlocking and opening**

5. A page unlocks the first time the player opens a request whose
   `manual_pages` contains its id (Shift & Chapter Progression reports the open).
   Unlocked pages stay unlocked for the session (and, from Vertical Slice, the
   save).
6. A newly unlocked page lights a small, silent indicator on the Manual button
   ("1 new page"). While an Onboarding coach mark is showing (Guided mode) the
   indicator is suppressed and appears once no mark is showing (workbench
   rule 6). The manual **never opens by itself**; Onboarding points at the
   button on 1-3 ("Filtering rows"), and a hint may name a page, but opening is always the
   player's action (button or Ctrl+M).
7. Locked pages appear in the index as titles marked "later" with no content, so
   the player can see the binder will grow.
8. The manual opens as a **side panel over the right (results) column**, so the
   editor and the request stay visible while reading. It shows an index of pages
   and the selected page; selecting a page marks it read. Ctrl+M toggles it from
   anywhere; Esc closes it when the panel has focus (in the editor, Esc keeps
   its workbench meaning). A page link in a hint opens the manual only when the
   player clicks it.
9. **Copy example to editor**: a page's example can be inserted at the editor
   caret (never replacing the player's text). Because examples never solve a
   puzzle (rule 4), this is a learning aid, not an answer key.

**Never a textbook**

10. No quizzes, no required reading, no completion tracking shown to the player,
    no score or reward for reading. Reading is logged only in the Playtest Log.

### States and Transitions

Per page, per session: `Locked → Unlocked (new)` (a request needing it is
opened) `→ Unlocked (read)` (the page is viewed). The Manual button shows the new-
page indicator while any page is `Unlocked (new)` and no coach mark is showing.

The panel: `Closed ↔ Open` (button, Ctrl+M; Esc closes). Opening never changes
the workbench state; the editor keeps its text and caret.

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Manual | `manual_pages` (page ids) per puzzle; `prefill_sql` (rule 4 exemption); chapter schema (for examples) | Puzzle Definition |
| Shift & Chapter Progression | Progression → Manual | "request opened" events | Progression |
| Query Workbench | Workbench hosts | Manual button, Ctrl+M, side panel over the results column, copy-to-editor | Workbench |
| Hint System | Hints → Manual | Hint text may name a page; a page link opens it | Hint System |
| Onboarding: First Shift | Onboarding → Manual | Highlights the Manual button on 1-3 ("Filtering rows"); coach-mark visibility suppresses the new-page indicator | Onboarding |
| Request & Reaction Dialogue | Dialogue → Manual | The previous part-timer's voice is a writing guide, not a speaker | Dialogue |
| Content verifier | Verifier → Manual | Rule 4 check on every example | Puzzle Definition |
| Playtest Log | Manual → Log | Page unlocked, opened, example copied | Manual |
| Save/Load (VS) | Manual → Save | Unlocked pages | Save/Load |

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If a puzzle's `manual_pages` lists an id with no page**: content validation fails for that puzzle (the manual cannot back it up). An empty `manual_pages` is valid (the puzzle unlocks nothing).
- **If a page unlocks while a coach mark is showing** (1-1 "Reading the ledger" in Guided mode): the page is `Unlocked (new)` at once, but the indicator waits until no mark is showing.
- **If two puzzles unlock the same page**: it unlocks once, on the first.
- **If the player opens a side request first** (S-1 before 1-6): its pages unlock then; order does not matter.
- **If the player copies an example while text is selected in the editor**: the example is inserted at the caret, not replacing the selection.
- **If the player copies an example and submits it unchanged**: it fails the grader like any wrong query (rule 4 guarantees it cannot pass).
- **If a page's example query errors on the chapter schema**: content validation fails (examples must run).
- **If the manual is open when a request changes**: it stays open on the same page; new pages unlock as usual.
- **If the player never opens the manual**: nothing changes; no reminder appears after the indicator.
- **If text scale is high** (`ui_scale` 2.0): the side panel scrolls; it never covers the editor.

## Dependencies

**Upstream (hard):**

| System | GDD | What the Manual needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | `manual_pages`; `prefill_sql`; chapter schema | In Review |
| Shift & Chapter Progression | `design/gdd/shift-and-chapter-progression.md` | Request-opened events | In Review |
| Query Workbench | `design/gdd/query-workbench.md` | Host: button, Ctrl+M, side panel, copy to editor | In Review |

**Soft:** Hint System (page links), Onboarding (1-3 highlight; coach-mark
visibility), Request & Reaction Dialogue (writing voice), Playtest Log,
Save/Load (VS).

**Bidirectionality:** puzzle definition, progression, workbench, hints,
onboarding and dialogue list the Store Manual ✓.

## Visual/Audio Requirements

*`art-director` not consulted — Lean mode. Synced to the art bible
(`design/art/art-bible.md`) 2026-10-14; the bible is authoritative for visuals
where they differ.*

- A ring binder (ring holes down the left edge) with **printed IBM Plex Sans
  SemiBold page titles** — no handwriting or display face; the "worn binder"
  feel comes from the shape, not the lettering (art bible 3.3, 7.2) — and
  **clean body text** (IBM Plex Sans, `body` 16 px base × `ui_scale`) — no
  handwriting or pixel fonts for anything the player must read; ≥ 4.5:1 contrast.
- `shape` and `example` in the editor's monospace (IBM Plex Mono, art bible 7.2), on the plain editor background
  colours (code looks like code).
- `watch_out` lines on a small sticky note (`sticky` yellow `#F8E38A`) with a
  "!" glyph and the word "Watch out" (not colour alone; art bible 3.3, 4.2).
- Locked pages: title in `ink_muted` `#5E544B` (6.55:1 on paper; never a lighter
  grey) + "later" label; new pages: a small `accent` indigo tab + "new" (art
  bible 4.2).
- Sound: a soft page turn on open; silence on unlock.

## Game Feel

Opening the manual should feel like glancing at a coworker's notes taped behind
the counter — instant, while still holding your pen. It never interrupts, never
grades, and always gives you something you can try right away.

## UI Requirements

1. Manual button with new-page indicator (glyph + word) on the workbench; Ctrl+M.
2. Side panel over the right column: index (unlocked / later) and selected page;
   keyboard navigation (arrows, Enter), Esc closes.
3. Copy example to editor (button; keyboard reachable) inserts at the caret.
4. Never covers the editor or the counter scene.

> **📌 UX Flag — Store Manual**: include the manual panel in the Query Workbench
> UX spec (`/ux-design`, Pre-Production).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/game-concept.md` | Overview, Rule 10 | Core Mechanic #6 store manual; anti-pillar "NOT a textbook" (reference allowed) | Source of intent |
| `design/gdd/puzzle-definition-and-datasets.md` | Rules 2, 4, 5 | `manual_pages` field (page ids); `prefill_sql` field | In Review |
| `design/gdd/onboarding-first-shift.md` | Rules 4, 6 | 1-1 prefill; Manual-button coach mark on 1-3; indicator suppression | In Review |
| `design/gdd/hint-system.md` | Rule 6 | Hints may name a page; same "never solves a puzzle" CI pattern | In Review |
| `design/gdd/query-workbench.md` | Rules 8–9 | Manual button, Ctrl+M, panel placement | In Review |
| `design/levels/chapter-1-puzzles.md` | Rule 2 | Learning goals per Chapter 1 puzzle | Level design |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Workbench, hint, progression and puzzle-
definition behaviour is covered in their own GDDs. Datasets: `visible`,
`hidden_a`, `hidden_b` (`prototypes/sqlbini-web/ch1.py`; `manual_pages` and
`prefill_sql` are added during Chapter 1 migration). [UI] = retained screenshot in
`production/qa/evidence/`.*

**Pages and unlocking**
- **SM-01 [Logic]** GIVEN page data, WHEN loaded, THEN each page has `id` (`manual.<slug>`), `title`, keyword(s), `body` (2–4 sentences), `shape`, `example` with a one-line result note, optional `watch_out` with a `rule_tag`; a page missing a required field, or a `watch_out` without a `rule_tag`, fails validation.
- **SM-02 [Content-CI]** GIVEN Chapter 1 data, THEN exactly the 11 pages of Core Rule 2 exist and every id in each puzzle's `manual_pages` resolves to one of them (1-1 → `manual.reading-the-ledger`, 1-2 → Picking columns, 1-4 → Comparing numbers and dates, 1-5 → More than one condition, 1-6 → A list of values, 1-8 → A range, S-1 → No duplicates, S-2 → Calculated columns — slugs are content data).
- **SM-03 [Logic]** GIVEN a fresh session, WHEN 1-1 is first opened, THEN "Reading the ledger" is Unlocked (new) and every other page is Locked.
- **SM-04 [Logic]** GIVEN S-1 opened before 1-6, THEN "No duplicates" unlocks at once, and opening the remaining requests in any order ends with the same unlocked set; a page shared by two puzzles unlocks once, on the first.
- **SM-05 [Logic]** GIVEN an unlocked page, WHEN later requests open or change, THEN it stays unlocked for the session; selecting it moves it from new to read.
- **SM-06 [UI]** GIVEN a page unlocks, THEN the Manual button shows a glyph + "1 new page", silently; the indicator clears only when no page is Unlocked (new); GIVEN a coach mark showing, THEN the indicator is hidden and appears when the mark is gone.

**Opening and the panel**
- **SM-07 [Integration]** GIVEN a scripted full Chapter 1 run (11 main + S-1 + S-2), THEN the panel is never Open unless the script presses the button, Ctrl+M or a hint's page link; Onboarding highlights do not open it.
- **SM-08 [UI]** GIVEN locked pages, THEN the index shows greyed titles with "later" and no body, shape or example, even when selected.
- **SM-09 [UI]** GIVEN the panel open at `ui_scale` 1.0 and 2.0, THEN it covers only the right (results) column; the editor and counter scene are uncovered; it scrolls at 2.0.
- **SM-10 [Integration]** GIVEN editor text, a selection and a caret, WHEN the panel opens and closes, THEN text, selection and caret are identical.
- **SM-11 [Integration]** GIVEN Closed, Ctrl+M opens; GIVEN Open, Ctrl+M closes, and Esc closes when the panel has focus; Esc in the editor does not close it; an open panel stays on its page across a request change.
- **SM-12 [UI]** GIVEN the panel, THEN arrows move through the index, Enter selects, and every control (including copy) is keyboard reachable.
- **SM-13 [Integration]** GIVEN a caret, WHEN copy is pressed, THEN the example is inserted at the caret; GIVEN a selection, THEN it is kept and nothing is replaced.

**Content checks**
- **SM-14 [Content-CI]** Every `example` runs without error on the chapter schema.
- **SM-15 [Content-CI]** Every `example`, submitted as a player query, passes no puzzle except one whose `prefill_sql` is its reference (1-1, rule 4); in particular "Picking columns" does not pass 1-2.
- **SM-16 [Content-CI]** Every id in every puzzle's `manual_pages` has a page; a missing page fails validation.
- **SM-22 [Content-CI]** GIVEN the Chapter 1 pages and `trap_rules`, THEN every Chapter 1 trap id (all 15) has a `trap_rules` entry, and no Chapter 1 page's `watch_out.rule_tag` equals any `trap_rules` tag (rule 3a); a fixture page whose `watch_out` carries `and_or_precedence` while 1-6's trap maps to it fails the check.
- **SM-17 [Content-CI]** A scan of all page text finds no puzzle id (`1-1` … `S-2`) and no puzzle's reference query.

**Never a textbook; presentation; log**
- **SM-18 [Integration]** The UI offers no quiz, score, reward, completion count or reminder; a run that never opens the manual shows nothing beyond the indicator.
- **SM-19 [Integration]** The Playtest Log records unlock, open and copy events with page id.
- **SM-20 [UI]** A `watch_out` line renders on a sticky note with a "!" glyph and the words "Watch out".
- **SM-21 [UI]** Body text uses a non-handwriting, non-pixel font at or above the workbench body size, ≥ 4.5:1; `shape` and `example` are monospace on the editor background.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Do `watch_out` lines blunt the traps (e.g. "BETWEEN includes both ends" before 1-8)? Rule 3a already bars stating a trap's rule before its puzzle is passed; playtest whether that is enough. Compare first-submit fail rates with and without the page read (Playtest Log). | game-designer | Zero-SQL + some-SQL playtest |
| 2 | Should the manual offer a small search/filter once later chapters add many pages? | ux-designer | Chapter 3 design |
| 3 | Voice of the previous part-timer — name, personality, a mystery hook? | narrative-director | Character bios |
