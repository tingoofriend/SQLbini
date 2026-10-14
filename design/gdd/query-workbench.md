# Query Workbench

> **Status**: In Design
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 3 — Fast Hands, Cheap Mistakes; Pillar 2 — Your Query, Your Way

## Summary

The Query Workbench is SQLbini's main screen: request, SQL editor, schema
browser, and the player's result beside the target. Run is instant, free and
never graded — it marks which of your rows match the target on today's data —
while Submit is a separate, deliberate act that the hidden-data grader judges.
It carries Pillar 3's write-run-see-fix loop and keeps it honest: a good Run
reads "looks right today (not checked)", never a pass.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `SQL Execution Sandbox, Puzzle Definition & Datasets, Hidden-Data Grader`

## Overview

The Query Workbench is the screen the player spends almost all of SQLbini on:
the request at the top, an SQL editor, the store's tables in a schema browser,
and two result tables — what the player's query returns and what the requester
wants — side by side. The player writes, presses **Run** to see their result on
today's data instantly and as often as they like, and presses **Submit** when
they believe the query holds on any day's data. The workbench owns the
moment-to-moment loop of Pillar 3 — write, run, see, fix — and makes it legible:
which of your rows match the target, which are extra, which are missing, and
why an error happened, all without ever implying that a good Run is a pass. It
hosts the entry points of neighbouring systems (Back Room, hints, store manual)
but does not own them. It is built on Godot's `CodeEdit` (proven in the spike);
widget structure and theming → become ADRs and the `/ux-design` spec.

## Detailed Design

### Core Rules

**What is on screen** (one puzzle at a time)

1. **Request bar** — the requester's portrait, name and request line (Request &
   Reaction Dialogue supplies the text), and the puzzle title.
2. **Editor** — an SQL editor with syntax highlighting (keywords, strings,
   numbers, comments), line numbers, undo/redo, and auto-closing of brackets and
   quotes (a setting; on by default in Chapter 1).
3. **Schema browser** — the chapter's tables with their columns and types,
   collapsible. Clicking a table or column name inserts it at the editor cursor
   (keyboard: select + Enter).
4. **Your result** — the player's last Run on the active data (visible dataset,
   or the Back Room's scratch data when the Back Room tab is active).
5. **Target** — the reference result on the visible dataset, computed (never
   stored — Puzzle Definition rule 3). Always shown for the visible dataset, not
   for the Back Room.
6. **Feedback area** — the latest Run note, Submit verdict or error (Hidden-Data
   Grader Visual/Audio), plus entry points: **Hint** (Hint System), **Manual**
   (Store Manual), **Back Room** tab (Back Room — shown from Chapter 2 only;
   in Chapter 1 the tab and its shortcut are absent).

**Run**

7. **Run** executes the editor text through the SQL Execution Sandbox in `query`
   mode on the visible dataset (or `scratch` mode in the Back Room tab). It is
   free, unlimited and never graded.
8. After a Run on the visible dataset the workbench shows:
   - the result table, with the **row count** ("3 rows"; "0 rows" — never a
     blank panel);
   - **row marks against the target**, by multiset matching with the grader's
     `canon` equality: each of your rows that matches a target row is marked
     ✓; each surplus row is marked **+ extra**; each target row with no match
     is marked **− missing** in the Target table. Marks use glyph + text, never
     colour alone;
   - a **column check**: if the column count differs, one line ("You returned
     3 columns; the request needs 2") replaces the row marks;
   - the grader's **match bit** as the Run note "Looks right today (not
     checked)" when every row and column matches — **never** a pass, stamp,
     tick or green.
   All of this uses only the visible dataset, which the player can already see,
   so it reveals nothing hidden (Pillar 1 holds).
9. Run results stay until the next Run. Editing the text marks them **stale**:
   the tables dim, a "Stale — run again" tag appears in their header, and the
   row marks and Run note are hidden (they describe the previous text).

**Submit**

10. **Submit** sends the editor text to the Hidden-Data Grader. It is a separate,
    labelled button with its own shortcut, placed apart from Run. Submit is
    always available (a failed submit costs nothing — Pillar 3).
11. The first time a player submits in the game, the manager says one line that
    explains the difference ("Run checks today's shelf. Submit is me checking it
    holds every day.") — diegetic, once, skippable.
12. The verdict (PASS stamp, FAIL note, SUBMIT_ERROR strip) is rendered as the
    grader's Visual/Audio section specifies and stays until the editor text
    changes.

**Errors**

13. A sandbox error (on Run or Submit) shows a strip at the editor: the voiced
    line from Request & Reaction Dialogue, and beneath it SQLite's original
    message in monospace (`no such column: prise`). If the message names a token
    (`near "FORM"`, `no such column: prise`) and that token appears in the
    editor, its first occurrence is underlined.

**Editing and input**

14. Each puzzle keeps its own draft text; switching puzzles and returning
    restores it for the session (persistence across sessions is Save/Load,
    Vertical Slice).
15. Keyboard-first: every action is reachable without the mouse.

| Action | Default shortcut |
|---|---|
| Run | Ctrl+Enter |
| Submit | Ctrl+Shift+Enter |
| Next pane (request → editor → schema → results → feedback) | F6 (Shift+F6 back) |
| Leave the editor (so Tab moves focus) | Esc |
| Hint / Manual / Back Room | Ctrl+H / Ctrl+M / Ctrl+B |

    Inside the editor, Tab indents. All shortcuts are remappable (Accessibility
    Options, Vertical Slice).
16. The editor accepts text from an active IME (Korean and Japanese layouts),
    including composition; SQL keywords are ASCII but string literals may hold
    any Unicode.
17. Text size and contrast follow the readability rules in Formulas; pass/fail,
    match marks and errors always carry a glyph and a word.

**What the workbench does not do**

18. No autocomplete at MVP (Open Question 2). No grading of its own — the match
    marks come from visible data only and are never a verdict. No hidden data,
    ever.

### States and Transitions

Per open puzzle:

| State | Meaning | Event | To |
|---|---|---|---|
| `Editing` | Player typing; last results (if any) stale — dimmed, marks hidden | Run | `Running` |
| `Editing` | | Submit | `Submitting` |
| `Running` | Sandbox request in flight (input stays live) | Result | `ShowingRun` |
| `Running` | | Error | `ShowingError` |
| `ShowingRun` | Result, marks, Run note visible | Edit | `Editing` (results stale) |
| `ShowingError` | Error strip visible | Edit | `Editing` (strip cleared) |
| `Submitting` | Grader request in flight; Submit disabled to avoid double submit | Verdict | `ShowingVerdict` |
| `ShowingVerdict` | Stamp / note / strip visible | Edit | `Editing` (verdict cleared) |
| any | | Run or Submit | `Running` / `Submitting` |

Run and Submit never block typing. A second Run while one is in flight replaces
it (the older result is discarded).

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Workbench | Title, request, schema, visible dataset, `reference_sql` (to compute the target) | Puzzle Definition |
| SQL Execution Sandbox | Workbench → Sandbox → Workbench | Run requests (`query`/`scratch`); result or error (`columns`, `rows`, `error_kind`, `error_text`) | Sandbox |
| Hidden-Data Grader | Workbench → Grader → Workbench | Submit (SQL text) → verdict, cause, level; Run match bit | Grader |
| Request & Reaction Dialogue | Dialogue → Workbench | Request line, voiced feedback and error lines, the one-time Submit line | Dialogue |
| Back Room | Workbench hosts | A tab that switches Run to `scratch` mode and shows the Back Room's controls | Back Room |
| Hint System | Workbench hosts | Hint button; hint text panel | Hint System |
| Store Manual | Workbench hosts | Manual button; manual overlay | Store Manual |
| Constraint Challenges | Workbench hosts | Shows the active constraint (e.g. "≤ 60 characters") and a live character count | Constraint Challenges |
| Shift & Chapter Progression | Progression → Workbench | Which puzzle is open; PASS moves the shift on | Progression |
| Playtest Log | Workbench → Log | Every Run and Submit with timestamps, edits between them | Workbench |
| Onboarding: First Shift | Onboarding → Workbench | Prefilled text, highlighted elements in 1-1 to 1-3 | Onboarding |
| Accessibility Options (VS) | Options → Workbench | Text scale, contrast theme, shortcut remapping, reduced motion | Accessibility Options |

## Formulas

*Proposed by `systems-designer` (2026-10-14); layout heights re-derived for the
two-column layout in Visual/Audio.*

The **row_marks** formula is defined as:

`key(r) = (canon(c_1), …, canon(c_n))`; for each distinct key k:
`m_k = min(cnt_P(k), cnt_T(k))` — the first `m_k` player rows with key k (in
returned order) are **✓ match**, the rest **+ extra**; the first `m_k` target rows
with key k are paired, the rest **− missing**. No marks if `cols(P) ≠ cols(T)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P, T | row lists | P: 0–`R_cap`; T: 0–`visible_rows_max` | calculated | Player result and target, both on the visible dataset |
| canon | function | — | constant | The grader's `canon` (`hidden-data-grader.md`) |
| cnt_P(k), cnt_T(k) | int | 0–5000 | calculated | How many rows have key k |
| m_k | int | 0–min(cnt_P, cnt_T) | calculated | Pairs for key k |

**Output Range:** one mark per row; `|P| = ✓ + extra`, `|T| = ✓ + missing`.
Because `canon` equality is an equivalence, greedy pairing is a maximum matching —
unique and order-independent. Marks ignore row order (ordered puzzles add one
line instead). Values are compared by position, so a column-order swap shows as
extra/missing. Linear time with a hash on the key.
**Example (1-5):** target Mineral Water 500ml 110 / Green Tea 500ml 160 / Canned
Coffee 140. `… price < 200` on visible → 3 ✓, 0 extra, 0 missing. `SELECT name,
price FROM products WHERE category = 'Drinks'` → 3 ✓, + extra Cola 500ml 216 and
Energy Drink 248; summary "3 ✓ · 2 + extra · 0 − missing". A 3-column result
against the 2-column target → only "You returned 3 columns; the request needs 2".

The **run_note** formula is defined as:

`run_note = (data = visible) ∧ ¬stale ∧ result_match(P_visible, T)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| data | enum | visible / scratch | calculated | Where the last Run ran |
| stale | bool | — | calculated | True after any edit since the Run |
| result_match | bool | — | calculated | The grader's visible match bit (includes order for ordered puzzles) — called, never reimplemented |

**Output Range:** boolean; true shows "Looks right today (not checked)". Never
shown for Back Room runs. It predicts nothing about hidden data.
**Example:** 1-5 `… price < 200` → note shown (and the submit will still FAIL on
hidden data — that is the game). The 5-row drinks query → no note.

The **readability** constants are defined as:

`row_px = round(1.5 × table_font_px × ui_scale)`;
`H_table = 0.40 × (720 − 56 − 32) − 48`;
`rows_visible = floor(H_table / row_px)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| editor_font_px | int | 14–32 (default 18) | data file | Editor font size at 1280×720 |
| table_font_px | int | 14–32 (default 16) | data file | Result-table and schema font size |
| ui_scale | float | 1.0–2.0, step 0.25 (default 1.0) | data file | Multiplies all fonts (Accessibility Options) |
| contrast_min | float | 4.5 | constant | WCAG AA minimum for text in every theme and state; glyphs, borders and focus rings ≥ 3:1 |
| H_table | int (px) | ≈ 205 | calculated | Height of one result table body: 40% of the area under the 56 px request bar and 32 px of margins, minus 48 px for header and count line |

**Output Range:** at defaults `row_px = 24`, `rows_visible = 8`; at `ui_scale =
2.0`, `row_px = 48`, `rows_visible = 4`. The 14 px floor keeps CJK text in string
literals legible; 18/16 keeps the editor one step above the tables. Chapter 1's
24 visible rows need scrolling in a full `SELECT *`; that is accepted.
**Example:** 1-5 at defaults: target 3 rows and the 5-row drinks result both fit
without scrolling.

The **display_rows_max** formula is defined as:

`rendered_rows = min(|P|, display_rows_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| display_rows_max | int | 50–500 (default 200) | data file | Rows built as visible table rows |
| \|P\| | int | 0–5000 | calculated | Rows returned by the sandbox |

**Output Range:** 0–200 rendered rows; the count line always gives the true count
("1,000 rows — showing the first 200"); marks and the summary are computed over
all rows. The target (≤ 30 rows) is never cut. A sandbox `truncated` result
shows "5,000+ rows — too many to compare" and no marks.
**Example:** `SELECT * FROM products` on visible → 24 rendered. A cross join of
576 rows → 200 rendered, summary over all 576.

No timing constant is needed: stale marking is instant, and superseded Runs are
discarded by request order.

## Edge Cases

*Drafted without specialists — Lean mode.*

**Run and results**
- **If the player presses Run with an empty editor**: the sandbox returns `EMPTY`; the strip says "Nothing to run yet" with the manager's line; nothing else changes.
- **If Run returns zero rows**: the table shows "0 rows" and every target row is marked "− missing" (when column counts match).
- **If the column count differs from the target**: no row marks; one line states both counts ("You returned 3 columns; the request needs 2").
- **If the player's columns are in a different order from the target** (same count): row marks compare by position, so rows show "+ extra" / "− missing"; the column headers of both tables stay visible so the swap can be seen.
- **If the result has more rows than `display_rows_max`**: rows beyond it are paged or virtualised (Formulas); the row count is still exact (up to 5,000, then "5,000+ rows — too many").
- **If the result is truncated by the sandbox (over 5,000 rows)**: shown as "5,000+ rows — too many to compare"; no row marks; Submit would be a SUBMIT_ERROR.
- **If the player runs again while a Run is in flight**: the older result is discarded; only the newest is shown.
- **If the puzzle is ordered** (Chapter 2+): row marks ignore order; when every row matches but the order differs, one line says "Rows match; order differs" and the Run note is hidden (it requires order too).
- **If both the player's result and the target have zero rows** (same column count): "0 rows", no marks, and the Run note appears — correct, but content should avoid zero-row targets on the visible dataset (Puzzle Definition reports them).
- **If every row matches on visible data**: the Run note "Looks right today (not checked)" appears — never a stamp, tick or the word "pass". This is the single most important rule of the screen.

**Submit**
- **If the player submits text they have never run**: allowed (Pillar 3); the verdict is shown as usual.
- **If the player double-presses Submit**: the second press is ignored while `Submitting`.
- **If the player edits while `Submitting`**: the verdict, when it arrives, is still shown but marked as "for the previous text" and cleared on the next edit.
- **If a SUBMIT_ERROR occurs**: the strip appears at the editor (never in the result area), with SQLite's original message beneath the voiced line.

**Editing**
- **If an error message names a token that appears several times**: only the first occurrence is underlined.
- **If an error message names no token** (e.g. `incomplete input`): no underline; the strip alone explains it.
- **If an IME composition is in progress when Run is pressed**: the composition is committed first, then Run executes the committed text.
- **If the player pastes very long text** (over 10,000 characters): accepted; Run proceeds; the sandbox rules apply unchanged.
- **If the player leaves and reopens a puzzle in the same session**: the draft text, last Run result and last verdict are restored.

**Back Room tab**
- **If the Back Room tab is active**: Run uses the scratch data; the Target table and row marks are hidden (the target is defined only for the visible dataset); a label "Back Room — practice data" is always visible so scratch results are never mistaken for the real shelf.
- **If the player submits from the Back Room tab**: Submit always grades the editor text against visible + hidden data, exactly as from the main view.

## Dependencies

**Upstream (hard):**

| System | GDD | What the workbench needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Title, request, schema, visible dataset, `reference_sql` | Designed (pending review) |
| SQL Execution Sandbox | `design/gdd/sql-execution-sandbox.md` | `query`/`scratch` results and errors | Designed (pending review) |
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | Submit verdicts; `canon` for row marks; Run match bit | Designed (pending review) |

**Hosted / soft dependencies** (the workbench shows their entry points; it works
without them): Back Room, Hint System, Store Manual, Constraint Challenges,
Request & Reaction Dialogue (text), Onboarding: First Shift, Accessibility
Options (VS) — none has a GDD yet.

**Downstream:** Playtest Log (consumes Run/Submit events), Audio (VS — UI sounds),
Shift & Chapter Progression (reacts to PASS via the grader).

**Bidirectionality:** the grader, puzzle definition and sandbox GDDs list the
Query Workbench ✓. The hosted systems must list it when designed.

## Visual/Audio Requirements

*Provisional — input from `art-director` (2026-10-14) against the draft "Behind
the Counter" anchor; no art bible yet. Grader outcome visuals (stamp, sticky
note, jammed strip, pencil tally) are defined in `hidden-data-grader.md` and not
redefined here.*

**Critique of the spike screen** (to fix): grey-on-grey panels and dim row text
fail contrast; the data grids look like the lowest-priority objects on screen —
the opposite of "data reads first"; buttons have no hierarchy; the "extra" mark
is plain red text without a glyph.

**Layout at 1280×720** (16 px margins; final spec in `/ux-design`)
- **Request bar** (top, ~56 px): store-paper themed — a cream order slip with the
  requester's line; Hint / Manual / Back Room as small tabs at its right edge.
- **Left column (~46% width):** editor (~62% of the column height), Run / Submit
  row directly under it (Run and Submit separated — UI Requirement 2), schema
  browser beneath as a "shelf" strip (~120 px, collapsible).
- **Right column (~54%):** "Your result" above "Target" (~40% height each),
  feedback strip below (a receipt).
- **Paper-themed:** frame, request bar, feedback receipt, grader stamp/note.
  **Plain, matte, high-contrast:** the editor and both grids — no texture, no
  rotation, opaque cards with a thin paper-tone border.

**Editor and grids**
- Editor: dark ink-navy background (≈ #1E2230), warm off-white text (≈ #F2EEE4),
  monospace; ligatures off (SQL glyphs must not change).
- Grid values monospace, numbers right-aligned; body text contrast ≥ 7:1; header
  in a distinct paper-tone band; zebra rows ≤ 8% luminance difference.
- **Syntax roles differ by weight and luminance, not hue alone** (safe for
  deuteranopia/protanopia): keyword bold + blue; string orange; number teal;
  identifier default; comment italic + dimmed. No red/green pairs.
- **Row marks** in a fixed left gutter (~90 px), always glyph + word (+ tint as
  a third channel): "✓ match" (no tint); "+ extra" (amber tint + left bar);
  "− missing" (blue-violet tint, dashed outline, ghost row). Never red/green.
- **Stale state:** a "Stale — run again" header tag, marks hidden, tables visibly
  de-emphasised (reduced opacity or italic — art bible decides) while all
  remaining text stays ≥ 4.5:1 (Formulas `contrast_min`).

**Schema browser:** each table is a shelf-label card (table name header) with
column chips beneath, each chip showing a type letter/glyph. Hover/focus
underlines with an "insert" hint; click or Enter inserts at the caret and the
inserted text flashes briefly (none under reduced motion). Minimum target 32 px;
fully keyboard reachable.

**Audio intent** (sparse; audio-director owns detail): Run — a soft register
tick (outcome sounds belong to the grader); typing — silent by default (an
optional very quiet key tap, off by default); pane switch — a faint paper slide.

**Anti-patterns:** grey-on-grey; paper texture behind data; rotated or skewed
grids; colour-only marks; pure red/green diffs; animated backgrounds;
proportional fonts for values; ligatures that alter SQL; hover-only affordances;
redefining the grader's stamp, note or strip.

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible
> is approved, run `/asset-spec system:query-workbench` to produce per-asset
> visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

The workbench should feel like a fast terminal behind a calm counter (Pillar 3).

- **Instant Run**: result, row marks and note within **200 ms at p95** of the key
  press (grader Game Feel); measured sandbox cost is ~0.37 ms, so the budget is
  almost entirely UI. No spinner below 200 ms; above it, a quiet "checking…" label.
- **Never blocked**: typing, scrolling and pane switching stay live during Run
  and Submit; no modal dialogs on errors.
- **Cheap mistakes**: errors appear beside the editor in one beat, with the exact
  SQLite text one glance away; nothing to dismiss.
- **Readable, not decorative**: the editor and tables are the calmest, most
  legible things on screen (see Visual/Audio); decoration lives on the frame.
- **The one weighty moment** is the PASS stamp (grader Visual/Audio). Run is
  deliberately light.

## UI Requirements

This system *is* the main gameplay screen; its full screen-level spec belongs to
`/ux-design` (Pre-Production). Requirements that spec must satisfy:

1. All regions in Core Rules 1–6 visible at 1280×720 without overlap; schema
   browser collapsible; result tables scroll independently.
2. Run and Submit are visually and spatially distinct; Submit is never adjacent
   to Run in a way a single mis-click hits the other.
3. Row marks (✓ / + extra / − missing), the order line, the Run note and every
   verdict carry a glyph **and** a word; nothing relies on colour alone.
4. Full keyboard operation (Core Rule 15) with a visible keyboard-focus ring
   distinct from mouse hover (Godot 4.6 dual focus).
5. Text scaling and contrast per Formulas; editor and table fonts monospace.
6. A persistent "Back Room — practice data" label whenever the Back Room tab is active.
7. Screen-reader labels for regions, buttons, row marks and verdicts (AccessKit;
   compatibility with `CodeEdit` unverified — Open Question 3).

> **📌 UX Flag — Query Workbench**: This system has UI requirements. In Phase 4
> (Pre-Production), run `/ux-design` to create a UX spec for the workbench screen
> **before** writing epics. Stories that reference UI should cite
> `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hidden-data-grader.md` | Core Rules 8–12, Visual/Audio | `canon`, match bit, verdict visuals, "Run never passes" | Designed (pending review) |
| `design/gdd/sql-execution-sandbox.md` | Core Rules 7, 13 | Modes, result shape, `error_kind`/`error_text`, `R_cap` truncation | Designed (pending review) |
| `design/gdd/puzzle-definition-and-datasets.md` | Core Rules 1–5 | Puzzle fields; target computed from `reference_sql`; `visible_rows_max` | Designed (pending review) |
| `design/gdd/game-concept.md` | Overview, Rules 8, 11 | Pillars 2–3; concept review findings (Run vs Submit, row-diff marking, onboarding) | Source of intent |
| `docs/engine-reference/godot/modules/ui.md` | UI Requirements 4, 7 | Dual focus (4.6), AccessKit (4.5), FoldableContainer (4.5) | Verified for 4.6, not re-verified for 4.7 |
| `prototypes/sqlbini-spike-2026-10-14/` | Overview | `CodeEdit` with SQL highlighting proven | Evidence |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grading outcomes and verdict visuals are in
`hidden-data-grader.md` (AC-01…26); sandbox behaviour in
`sql-execution-sandbox.md` (SB-01…21). Fixture: puzzle 1-5 on the visible
dataset, target Mineral Water 500ml 110 / Green Tea 500ml 160 / Canned Coffee 140.
[UI] = a retained screenshot in `production/qa/evidence/`.*

**Screen and Run**
- **QW-01 [UI]** GIVEN a puzzle open at 1280×720 with default settings, WHEN the screen is captured, THEN the request bar, editor, schema browser, Your result, Target and feedback area (with Hint / Manual / Back Room) are all visible without overlap; the schema browser collapses; the two tables scroll independently.
- **QW-02 [Logic]** GIVEN any editor text, WHEN Run is pressed, THEN the sandbox is called in `query` mode (`scratch` with the Back Room tab active), no grader verdict is produced, and a row count is shown ("3 rows").
- **QW-03 [Logic]** GIVEN 1-5, WHEN `… price < 200` is run, THEN 3 ✓, 0 + extra, 0 − missing.
- **QW-04 [Logic]** GIVEN 1-5, WHEN `SELECT name, price FROM products WHERE category = 'Drinks'` is run, THEN 3 ✓ plus + extra Cola 500ml 216 and Energy Drink 248, and the summary reads "3 ✓ · 2 + extra · 0 − missing".
- **QW-05 [Logic]** GIVEN results with duplicate keys or reordered rows, WHEN `row_marks` is computed, THEN pairing is order-independent, `|P| = ✓ + extra`, `|T| = ✓ + missing`, and marks cover all rows, not only rendered ones.
- **QW-06 [Logic]** GIVEN a 3-column result against the 2-column target, THEN only "You returned 3 columns; the request needs 2" is shown and no marks; GIVEN the same columns in swapped order, THEN rows show + extra / − missing and both headers stay visible.
- **QW-07 [Logic]** GIVEN a query returning no rows, THEN "0 rows" is shown (never a blank panel) and every target row is − missing.
- **QW-08 [Logic]** THEN "Looks right today (not checked)" appears if and only if the data is visible, the result is not stale, and the grader's match bit is true — absent for the drinks query, in the Back Room, and on an ordered puzzle whose order differs ("Rows match; order differs").
- **QW-09 [Logic]** GIVEN every workbench-owned string on the Run note, mark and order-line paths, WHEN scanned, THEN none contains "pass", "correct" or "OK"; no stamp, tick or green appears on Run.
- **QW-10 [Integration]** GIVEN a shown Run, WHEN the text is edited, THEN marks and the Run note hide, the "Stale — run again" tag shows, and the tables are de-emphasised.
- **QW-11 [UI]** GIVEN the stale screen, WHEN captured, THEN all text is ≥ 4.5:1, glyphs and borders ≥ 3:1, and the tag is glyph + word.
- **QW-12 [Integration]** GIVEN a Run already in flight (stub sandbox with a delay), WHEN Run is pressed again, THEN only the newer result is shown and the older is discarded.
- **QW-13 [Performance]** GIVEN ≥ 100 Runs of 1-5 queries, THEN key press → result, marks and note ≤ 200 ms at p95; typing, scrolling and pane switching stay live during Run and Submit; GIVEN a stub delay of 300 ms, THEN a "checking…" label appears after 200 ms.

**Submit and errors**
- **QW-14 [Integration]** GIVEN the editor text, WHEN Submit is pressed, THEN the grader is called (separately from Run); a second press while `Submitting` is ignored; never-run text is accepted; Submit and Run are not adjacent such that one mis-click hits the other.
- **QW-15 [Integration]** GIVEN a fresh profile, WHEN the player submits for the first time, THEN the manager's Run-vs-Submit line appears once and is skippable; it does not appear on later submits.
- **QW-16 [Integration]** GIVEN the player edits while `Submitting`, WHEN the verdict arrives, THEN it is shown labelled "for the previous text" and clears on the next edit.
- **QW-17 [Integration]** GIVEN `SELECT prise FROM products`, WHEN Run is pressed, THEN a strip beside the editor shows the voiced line and `no such column: prise` in monospace, and the first `prise` is underlined; GIVEN an error naming no token, THEN no underline; a SUBMIT_ERROR uses the same strip, never the result area.

**Editing and input**
- **QW-18 [Logic]** GIVEN two puzzles, WHEN the player switches away and back in the session, THEN the draft, last result and last verdict are restored.
- **QW-19 [Integration]** THEN Ctrl+Enter runs, Ctrl+Shift+Enter submits, F6 / Shift+F6 cycle the five panes in order, Esc leaves the editor, Ctrl+H / M / B open Hint / Manual / Back Room, and Tab indents while the editor has focus.
- **QW-20 [UI]** GIVEN keyboard focus on each pane, WHEN captured, THEN a focus ring is visible, distinct from hover, ≥ 3:1.
- **QW-21 [Integration]** GIVEN an in-progress Korean or Japanese IME composition, WHEN Run is pressed, THEN the composition is committed and the committed text is executed. *(May be manual-only until Open Question 4 is resolved.)*
- **QW-22 [Integration]** GIVEN a schema table or column clicked (or selected + Enter), THEN its name is inserted at the caret, with a brief flash unless reduced motion is on.

**Scale and limits**
- **QW-23 [Logic]** GIVEN a 576-row cross join, THEN 200 rows render, the count reads "576 rows — showing the first 200", and marks cover all 576; GIVEN a truncated sandbox result, THEN "5,000+ rows — too many to compare" and no marks.
- **QW-24 [Logic]** GIVEN default settings, THEN `editor_font_px = 18`, `table_font_px = 16`, `row_px = 24`, `rows_visible = 8`; at `ui_scale = 2.0`, `rows_visible = 4`; fonts outside 14–32 and scale outside 1.0–2.0 (step 0.25) are clamped.

**Back Room tab**
- **QW-25 [UI]** GIVEN the Back Room tab active, THEN "Back Room — practice data" is always visible, the Target table and marks are hidden, and the Run note is absent.
- **QW-26 [Integration]** GIVEN the Back Room tab active, WHEN Submit is pressed, THEN the grader grades the editor text against visible + hidden data, identically to the main view.

*Not covered here:* screen-reader labels (UI Requirement 7) until Open Question 3
is resolved; the Hint panel and constraint character count belong to their own
GDDs.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Do row marks on visible data make puzzles too easy — does a player stop thinking once every row is ✓? The hidden-data trap still decides, but the zero-SQL playtest should watch whether players submit straight after an all-✓ Run and how they react to the FAIL. | game-designer (playtest) | Zero-SQL playtest |
| 2 | Autocomplete (keywords, table/column names): helps zero-SQL players, works against "the skill is real". `CodeEdit` has a completion API (untried). MVP: none; decide for Vertical Slice, possibly as a setting on by default in Chapter 1. | game-designer + ux-designer | Vertical Slice |
| 3 | Does `CodeEdit` expose its text and caret to screen readers via AccessKit in Godot 4.7? | ui-programmer / accessibility-specialist | Before the accessibility requirements doc |
| 4 | Korean/Japanese IME composition inside `CodeEdit` on Windows and Linux — verify early (the developer types Korean). | ui-programmer | First workbench prototype |
| 5 | Should the Target table be hideable (an "expert" mode where the player works only from the request)? | game-designer | After Chapter 1 playtest |
