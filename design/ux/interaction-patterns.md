# Interaction Pattern Library

> **Status**: In Design (v1 — drafted from the approved GDDs and the art bible; no screen spec exists yet)
> **Author**: tingoofriend + Claude (`/ux-design patterns`, autonomous)
> **Last Updated**: 2026-10-16
> **Template**: Interaction Pattern Library
> **Input**: Keyboard + mouse only (PC); keyboard-first — every pattern must be fully operable without the mouse
> **Accessibility tier**: Standard + reduced motion + full keyboard (`design/accessibility-requirements.md`)

---

## Overview

SQLbini has one main screen (the Query Workbench under the 120 px counter strip)
plus a few paper screens (shift screen, payslip, chapter list, options panel).
The same handful of interactions repeats everywhere: typing, chorded shortcuts,
a result appearing, a note appearing, a panel opening beside the work. This
library fixes how each of those behaves once, so every screen spec references a
pattern instead of re-deciding it.

Rules every pattern inherits:

1. **Keyboard first.** Every action has a key path; mouse is an alternative.
   Keyboard focus is always visible (solid indigo ring with paper gap, never
   animated) and hover never draws indigo (Godot 4.6 dual focus; art bible 7.5).
2. **Text is never late.** Text-bearing objects appear in their final position
   at full opacity on the first frame; motion (≤ 200 ms) moves decoration only;
   reduced motion replaces every motion with its final state (art bible 7.6).
3. **Glyph + word, never colour alone.** Every state uses one glyph from the
   art-bible 3.3 vocabulary plus a word; the accessible name is the word.
4. **The work is never covered.** Nothing opens over the editor or the counter
   strip; panels use the results column (Store Manual UI Req 4).
5. **Motion never gates input.** Typing, scrolling and pane switching stay live
   during any animation, Run or Submit; a new event jumps a running animation to
   its end.
6. **Sizes from tokens.** Spacing from the 4 px scale, text from the art-bible
   7.2 sizes × `ui_scale`, minimum target 32 × `ui_scale` px.

---

## Pattern Catalog

| ID | Pattern | Category | One line |
|---|---|---|---|
| IP-01 | Chorded shortcut with visible label | Input | Every action has a default chord, shown on its control |
| IP-02 | Pane cycling (F6) | Navigation | F6 / Shift+F6 move focus between the workbench regions |
| IP-03 | Esc precedence | Navigation | One Esc rule for overlays, coach marks and leaving the editor |
| IP-04 | Run vs Submit pair | Input | Two commit actions that can never be confused |
| IP-05 | Insert at caret | Input | Clicking a schema chip or "Copy example" inserts text where the caret is |
| IP-06 | Ghost text in an empty editor | Input / Onboarding | A greyed "shape" example that Tab accepts and typing removes |
| IP-07 | Glyph + word state label | Feedback | The single way any state is shown |
| IP-08 | Outcome object appears in place | Feedback | Receipt, tally note, sticky note, error strip, stamp |
| IP-09 | Pending and superseded results | Feedback | "checking…" after 200 ms; a newer Run discards the older result |
| IP-10 | "New" indicator | Feedback | Something unlocked: glyph + word on its button, never a pulse |
| IP-11 | Result / target grid | Data display | Positional table with a mark gutter, tints, ghost rows, NULL boxes |
| IP-12 | Inline SQL token in prose | Data display | Any value the player might type is set in mono on a header run |
| IP-13 | Paged speech bubble | Dialogue | Measured pages, static ▸, any key completes the reveal |
| IP-14 | Inline offer in the bubble | Dialogue / Choice | Two buttons inside the bubble, never a modal; unanswered → ticket |
| IP-15 | Side panel over the results column | Overlay | Manual and hint open beside the editor; Esc closes, focus returns |
| IP-16 | Full overlay with scrim | Overlay | Message log: scrim, focus trapped inside, Esc / same key closes |
| IP-17 | Coach mark | Onboarding | Dashed ring + paper tag + "Got it", scoped to its puzzle |
| IP-18 | Inline one-line confirmation | Choice | Confirm a destructive action in place (Restart with a draft) |
| IP-19 | Paper screen with two choices | Navigation / Choice | Payslip: a receipt with a primary and a secondary action |
| IP-20 | Clipboard checklist | Navigation / Data display | Chapter list: rows with state marks and row actions |
| IP-21 | Options toggle | Settings | On/off row in the minimal options panel |

---

## Patterns

### IP-01 Chorded shortcut with visible label

**Category**: Input
**Used In**: Workbench (Run, Submit, Hint, Manual, Back Room, Log), every screen with a primary action

**Description**: Every action has a default key chord (workbench rule 15) and a
clickable control. The control shows its chord as a small label so players learn
the keys without a manual.

**Specification**:
- Defaults (workbench rule 15): Run `Ctrl+Enter`, Submit `Ctrl+Shift+Enter`,
  Hint `Ctrl+H`, Manual `Ctrl+M`, Back Room `Ctrl+B` (Chapter 2+), Log `Ctrl+L`,
  panes `F6` / `Shift+F6`, leave editor `Esc`.
- The chord label sits after the button word in the `label` style, `ink_muted`
  (art bible F-08), e.g. "Run  Ctrl+Enter". It reflects the current binding
  (VS remapping) — never a hard-coded string.
- Chords work from any focus inside the workbench, including the editor;
  `CodeEdit` must not consume them (implementation: handle in
  `_shortcut_input` / shortcut context — ADR-0008).
- Matching by key event type and keycode, never by `event.device` (4.7 device-ID
  change, ADR-0004 §4 precedent).
- While an overlay (IP-16) is open, workbench chords are inactive except the
  one that closes it.
- AccessKit: the button's name is the word; the chord is its description.

**When to Use**: Every repeated action on the workbench.
**When NOT to Use**: One-off choices (IP-14, IP-19) — they use Tab/Enter on
visible buttons, no chord.

---

### IP-02 Pane cycling (F6)

**Category**: Navigation
**Used In**: Workbench

**Description**: The workbench has five regions; F6 moves keyboard focus to the
next one in a fixed order so keyboard players never Tab through dozens of
controls.

**Specification**:
- Order (workbench rule 15): counter strip (bubble) → editor → schema browser →
  results → feedback; `Shift+F6` reverses; wraps around.
- Focus lands on the region's first control, or the last focused control in it
  if it had one this session.
- The focused region's header shows a 4 px `focus` bar at its left edge and its
  title switches SemiBold → Bold (art bible 7.5). The strip region's ring goes
  around the bubble paper, never around pixel art.
- Inside a region, Tab / Shift+Tab move between controls; arrows move inside
  lists and grids.
- AccessKit: each region is a named landmark ("Request", "SQL editor",
  "Shelves (schema)", "Results", "Feedback").

**When to Use**: The workbench and any future multi-region screen.
**When NOT to Use**: Single-column screens (payslip, chapter list) — Tab order is enough.

---

### IP-03 Esc precedence

**Category**: Navigation
**Used In**: Workbench, overlays, coach marks

**Description**: Esc always does the most local thing first, so it is never
ambiguous.

**Specification** (workbench rule 15, first match wins):
1. Focus inside an open overlay or panel (IP-15, IP-16) → close it; focus returns
   to the control that opened it.
2. Focus on a shown coach mark (IP-17) → dismiss that mark.
3. Focus in the editor → leave the editor (focus moves to the editor's region
   frame, so Tab moves on). A shown coach mark stays.
- Esc never closes the game, never discards a draft and never cancels a Run or
  Submit.
- The editor shows the hint "Esc: leave editor" in `label` style while it has
  focus (art bible F-06).

**When to Use**: Every dismissible surface.
**When NOT to Use**: Never bind Esc to a destructive action.

---

### IP-04 Run vs Submit pair

**Category**: Input
**Used In**: Workbench (and challenge mode)

**Description**: Run checks the query on today's visible data and never shows a
pass; Submit grades it on hidden data. They must never be confused by eye, hand
or key.

**Specification**:
- Run = outlined paper button; Submit = the only filled-indigo button in the
  game (art bible 3.3).
- Separated by ≥ 24 × `ui_scale` px and never adjacent in a way one mis-click
  hits the other (workbench UI Req 2, H-02).
- Different chords (IP-01); Submit adds Shift.
- While a Submit is in flight, both are disabled (IP-09); the disabled state
  shows the word "checking…", not only a dimmed fill.
- Run's result never uses green, a stamp or the word "accepted" (Pillar 1;
  art bible 4.5).

**When to Use**: Only for the Run/Submit pair.
**When NOT to Use**: Do not reuse the filled-indigo style for any other button.

---

### IP-05 Insert at caret

**Category**: Input
**Used In**: Schema browser (table and column chips), Store Manual "Copy example"

**Description**: The player can put a name or example into the editor without
typing it, without losing their place.

**Specification**:
- Click, or select + Enter, inserts the text at the editor caret (QW-22,
  Store Manual UI Req 3); if the editor has a selection, it is replaced.
- Focus stays where it was (the chip / button), so several names can be inserted
  in a row; the editor caret moves to the end of the insertion.
- Inserted text gets a `selection` fill that fades out over 200 ms; none under
  reduced motion. The text never moves.
- Inserted identifiers are inserted bare (no quoting) unless the name needs
  quoting under the sandbox lexer rules.
- Logged as an edit like typing (edit-burst coalescing in the Workbench).

**When to Use**: Any "put this into my query" action.
**When NOT to Use**: Never overwrite the whole draft (that is Restart, IP-18).

---

### IP-06 Ghost text in an empty editor

**Category**: Input / Onboarding
**Used In**: Workbench on onboarding puzzles (1-3), per `onboarding-first-shift.md`

**Description**: A dim example of the query's shape shows in an empty editor and
disappears as soon as the player types.

**Specification**:
- Mono Italic in `ghost` colour (5.71:1 on `editor_bg`), with the label "shape"
  so it is never mistaken for a comment (art bible 4.6).
- Visible only while the editor is empty; the first typed character removes it.
- Tab in an empty editor with ghost text accepts it (inserts it as real text);
  elsewhere Tab indents (workbench rule 15).
- Not submitted, not run, not logged as SQL; AccessKit reads it as placeholder
  text ("Example shape: …").

**When to Use**: Onboarding puzzles that define ghost text.
**When NOT to Use**: Never pre-fill real text this way (prefill is real text).

---

### IP-07 Glyph + word state label

**Category**: Feedback
**Used In**: Everywhere a state is shown (verdicts, row marks, chapter list, payslip, hint indicator, challenge live check, playtest label)

**Description**: The single way to show a state: one glyph with one meaning plus
a word.

**Specification**:
- Glyph vocabulary is fixed (art bible 3.3/7.4): ✓ satisfied/accepted, ?
  not accepted, + extra row, − missing row, ⚠ error, ≈ looks right today
  (unchecked), ↷ left for later, ★/☆ challenge cleared / not met, ! watch out,
  ● recording, ▸ bubble paging only.
- Glyph first, then the word, same size and colour as the word (glyphs are text
  in the SQLbini Glyphs fallback font, never emoji).
- AccessKit reads the word only ("Extra row", not "plus extra row").
- No new glyph without a new art-bible 3.3 row.

**When to Use**: Any state the player must tell apart.
**When NOT to Use**: Decoration — decorative marks carry no glyph.

---

### IP-08 Outcome object appears in place

**Category**: Feedback
**Used In**: Workbench feedback column (Run result receipt + tally note, FAIL sticky note, error strip, PASS stamp, star hanko)

**Description**: Each Run or Submit produces one new paper object beside the
data; it is the only new shape on screen at that moment.

**Specification**:
- Objects: result receipt (Run/Submit feedback), pencil tally note "≈ Looks
  right on today's data" (Run match, never green), FAIL sticky note
  "? Not accepted" + level-1 statement, jammed register strip "⚠ …" with
  SQLite text, PASS stamp + "✓ ACCEPTED", star hanko (challenge).
- All text appears in final position on frame 1. Only the stamp and star hanko
  animate (≤ 180 ms, no bounce); star follows stamp by 60 ms; reduced motion →
  final state.
- Placed beside the grids, never over data; the stamp has a reserved landing
  spot on the receipt.
- The previous outcome object is replaced, not stacked; the message log keeps the
  history (IP-16).
- Outcome text is announced through an AccessKit live region (polite), once.
- Persists until the next Run/Submit, Restart or puzzle change — never
  auto-dismissed.

**When to Use**: Results of player actions on the work surface.
**When NOT to Use**: Characters' reactions — those belong in the bubble (IP-13).

---

### IP-09 Pending and superseded results

**Category**: Feedback
**Used In**: Workbench Run and Submit

**Description**: Results normally arrive within a frame or two; when they do
not, the player sees a static pending word, and a newer Run always wins.

**Specification**:
- If no result arrives within 200 ms, the feedback column shows the static text
  "checking…" (no spinner, no animation; workbench Game Feel, art bible 7.6).
- **Run supersede** (workbench States, QW-12/16; ADR-0002 §6): a new Run while
  one is in flight starts at once; the older result is discarded when it arrives
  and never shown.
- **Submit is exclusive**: while a Submit is in flight, Run and Submit are
  disabled (IP-04); typing stays live.
- TIMEOUT arrives as an error strip (IP-08) within the time limit + one frame.

**When to Use**: Any asynchronous query result.
**When NOT to Use**: Synchronous UI (opening panels) — no pending state.

---

### IP-10 "New" indicator

**Category**: Feedback
**Used In**: Hint button (step unlocked), Manual button (new page), strip tabs

**Description**: Tells the player something became available without demanding
attention.

**Specification**:
- Indigo dot + the word "new" on the button or tab (art bible `accent`); no
  pulse, no blink, no badge counter (art bible 7.6).
- Cleared when the player opens the thing it points to.
- Suppressed during Onboarding's Guided suppression window
  (`onboarding-first-shift.md` rule 7).
- AccessKit: appended to the button description ("new step available").

**When to Use**: Newly unlocked help or content.
**When NOT to Use**: Outcomes (IP-08) or urgent errors.

---

### IP-11 Result / target grid

**Category**: Data display
**Used In**: Workbench results column (player result and visible target), Back Room (Alpha)

**Description**: The game's hero element: two positional tables compared row by
row, read at a glance.

**Specification**:
- Positional columns in result order; numbers right-aligned, text left-aligned,
  headers aligned with their column; tabular numerals; mono `table` font.
- Fixed left gutter (≈ 90 × `ui_scale` px) with row marks "✓ match", "+ extra",
  "− missing"; a marked row's tint replaces zebra; extra rows have a solid
  `extra_bar`; missing rows are 2 px dashed ghost rows (art bible 7.3).
- `NULL` in a solid 1 px box; `''` as `""`; the text `'NULL'` plain.
- Header row and gutter are frozen; body scrolls vertically; data columns scroll
  horizontally under the frozen header and gutter at `ui_scale` ≥ 1.5 (art bible
  7.8). Column widths match between the two grids (G-09).
- A count line under each grid: "3 ✓ · 2 + extra · 0 − missing" (tabular).
- Keyboard: arrows move a cell cursor; PageUp/PageDown scroll; Home/End jump to
  first/last row; the cursor is the focus ring on the cell.
- TOO_MANY_ROWS shows the strip text owned by the Workbench (rule 13), not a
  grid.
- AccessKit: grid role with row/column headers; the gutter mark is read as the
  row's first cell ("Extra row").

**When to Use**: Any query result or target table.
**When NOT to Use**: Prose lists (manual index, chapter list) — use IP-20.

---

### IP-12 Inline SQL token in prose

**Category**: Data display
**Used In**: Bubble, hint note, manual, sticky note, chapter list

**Description**: Any identifier, literal or value the player might type, inside
prose, is set so 0/O and 1/l/I are never confused.

**Specification**:
- IBM Plex Mono at the surrounding size, `ink`, on a `header`-filled 2 px-radius
  run with 2 px horizontal padding (11.24:1) (art bible 7.2, M-01).
- Never broken across lines when ≤ 24 characters; longer runs may wrap at
  spaces only.
- The value is copied exactly from content (never re-cased or re-quoted).

**When to Use**: Every value the player must reproduce exactly.
**When NOT to Use**: Ordinary prose words.

---

### IP-13 Paged speech bubble

**Category**: Dialogue
**Used In**: Counter strip (requests, reactions, briefings, Kenji's lines)

**Description**: A fixed ≈ 510 × 80 px bubble shows one page at a time; larger
text means more pages, never a bigger bubble.

**Specification**:
- Pages split by measured laid-out text width and height in the real rect at the
  current `ui_scale` (dialogue rule 10, RD-11); never clipped.
- Static "1/3 ▸" at the bottom right (the chevron never blinks).
- Advance: click anywhere on the bubble, or Enter / Space while the strip region
  has focus (IP-02). The whole bubble is one target (H-03).
- Typewriter reveal (≤ 1.0 s per page): any key or click completes it; the full
  line goes to AccessKit at once; off under reduced motion; never used for
  verdict or error text.
- Request tickets (square, notched, "REQUEST" tab) stay until the request
  changes; reactions (rounded, name tag) return to the request after
  `reaction_hold` — every line is also kept in the message log (IP-16).

**When to Use**: All character speech.
**When NOT to Use**: System feedback (IP-08) or long reference text (IP-15).

---

### IP-14 Inline offer in the bubble

**Category**: Dialogue / Choice
**Used In**: Challenge offer (Try it / Later), Kenji's skip offer (Leave it for Kenji / Keep trying), Day One opening question

**Description**: A two-way choice offered by a character, inside the bubble, that
never blocks the work.

**Specification**:
- Two buttons inside the bubble under the line; the recommended / safe choice
  ("Later", "Keep trying") is first in Tab order; neither is filled indigo.
- Keyboard: when the offer appears, focus does **not** jump to it (the player may
  be typing); F6 to the strip region, then Tab / Enter.
- Never a modal; the editor stays live.
- **Exception — Day One opening question** ("Ever used SQL before?"): no request
  is open yet, so focus moves to the first choice when it appears; it must be
  answered before 1-1 opens.
- Unanswered when the bubble moves on → the offer remains as a ticket in the
  strip's tab cluster (dialogue rule 3a) / the "Leave it for Kenji" button stays
  on an exhausted request (Progression UI Req 2).
- AccessKit: the line is announced with "2 choices".

**When to Use**: Optional choices voiced by a character.
**When NOT to Use**: Choices that must be answered before play continues (IP-19).

---

### IP-15 Side panel over the results column

**Category**: Overlay
**Used In**: Store Manual (ring binder), Hint (folded note)

**Description**: Reference content opens beside the editor so the player can read
and type at the same time.

**Specification**:
- Covers only the results column; never the editor or the counter strip (Store
  Manual UI Req 4, SM-09). Appears in place (no slide); reduced motion identical.
- Opening (button or chord) moves focus into the panel; Esc or the same chord
  closes it and focus returns to the opener (IP-03).
- Focus is **not** trapped: F6 / clicking the editor leaves the panel open and
  moves focus out (the player types while reading).
- Scrolls at high `ui_scale`; never shrinks text.
- One side panel at a time: opening the manual closes the hint, and vice versa
  (provisional — the hint panel slot is decided in the workbench spec).
- Manual: index (unlocked / later) + page, arrows + Enter; "Copy example" uses
  IP-05.

**When to Use**: Reference or help the player reads while working.
**When NOT to Use**: History (IP-16) or choices (IP-14, IP-19).

---

### IP-16 Full overlay with scrim

**Category**: Overlay
**Used In**: Message log

**Description**: A temporary overlay for reviewing history; the work underneath
is untouched.

**Specification**:
- Scrim fades 0 → 50% (120 ms open / 90 ms close; instant under reduced motion);
  the panel itself appears in place.
- Focus is trapped inside while open (Tab cycles inside; art bible F-09); Esc
  or `Ctrl+L` closes; focus and editor caret return unchanged (RD-06).
- Newest entry at the bottom; opens scrolled to the newest; each entry shows
  speaker name + kind label; paged lines shown whole.

**When to Use**: Short-lived review surfaces.
**When NOT to Use**: Anything the player needs while typing (IP-15).

---

### IP-17 Coach mark

**Category**: Onboarding
**Used In**: Day One Morning (1-1 Run, 1-1 Submit, 1-2 schema, 1-3 manual) per `onboarding-first-shift.md` rule 7a

**Description**: Points at one control with a short instruction until the player
uses it.

**Specification**:
- Dashed 2 px `ink` ring following the target (outside any focus ring) + a paper
  tag with one sentence and a "Got it" button (art bible 4.6, 7.5).
- Ring settles once (200 ms, one pulse); reduced motion → final state; never
  loops.
- Done when the target action happens, "Got it", or Esc with the mark focused;
  scoped to its puzzle (rule 7a).
- Focus does not jump to the mark; the tag is in Tab order after its target.
- Follows its target across resize and `ui_scale` (OB-15).
- Can be turned off and back on in the options panel (IP-21).

**When to Use**: First-time onboarding only.
**When NOT to Use**: Ongoing help — use the hint (IP-15) or manual.

---

### IP-18 Inline one-line confirmation

**Category**: Choice
**Used In**: Restart on the chapter list (when the draft is non-empty)

**Description**: A destructive action asks once, in place, without a modal.

**Specification**:
- The row expands to one line with the GDD's text: "Start this request over?
  Your query will be cleared."  [Restart] [Cancel] (`shift-and-chapter-progression.md`
  rule 12a) — "Cancel" is focused by default.
- Esc = Cancel. No confirmation when there is nothing to lose (empty draft).
- The destructive button is plain text weight, not red (red = verdict only).

**When to Use**: Actions that discard the player's own text.
**When NOT to Use**: Reversible actions.

---

### IP-19 Paper screen with two choices

**Category**: Navigation / Choice
**Used In**: Payslip (Next shift / Stop for today)

**Description**: A full-screen or centred paper object that waits for one of two
answers.

**Specification**:
- Primary choice first in Tab order and focused on arrival; Enter activates the
  focused button. Esc does nothing here: both answers matter, so the player
  picks one.
- Content appears in final position on frame 1; the receipt form (zigzag edge)
  for the payslip.
- Both buttons ≥ 32 × `ui_scale` px, separated ≥ 16 px.

**When to Use**: Moments that genuinely need an answer before play continues.
**When NOT to Use**: Optional choices during work (IP-14).

---

### IP-20 Clipboard checklist

**Category**: Navigation / Data display
**Used In**: Chapter list (from the shift screen)

**Description**: A vertical list of requests with their state and row actions.

**Specification**:
- One row per request: id, short title, state as glyph + word (locked / open /
  ✓ passed / ↷ left for later / unavailable), challenge mark (★ cleared / ☆
  available).
- Up/Down move between rows; Enter opens; row actions (Replay / Reopen /
  Restart) reachable with Tab inside the focused row; Restart uses IP-18.
- Locked rows are focusable and read "locked" (players can see what is ahead).
- Scrolls at high `ui_scale`; the current request row carries the word
  "(current)" — no extra glyph (IP-07) and not colour alone.

**When to Use**: Lists of items with state and actions.
**When NOT to Use**: Tabular query data (IP-11).

---

### IP-21 Options toggle

**Category**: Settings
**Used In**: Minimal options panel (MVP: "Coach marks", "Reduced motion"); Accessibility Options (VS)

**Description**: A labelled on/off row that takes effect at once.

**Specification**:
- Row: label word + state word ("On" / "Off") + a checkbox shape; the state is
  never shown only by the box fill.
- Space or Enter toggles; Tab moves between rows; Esc closes the panel and
  returns focus.
- Takes effect immediately (reduced motion: any running motion jumps to its
  end); session-only at MVP (Save/Load is VS).
- AccessKit: checkbox role with the label as name.

**When to Use**: Binary settings.
**When NOT to Use**: Ranged settings (`ui_scale`) — slider pattern not yet
defined (Gaps).

---

## Gaps & Patterns Needed

| Gap | Needed by | Note |
|---|---|---|
| Stepped slider (`ui_scale` 1.0–2.0, step 0.25; reveal speed; volumes) | Accessibility Options, Audio (VS) | Must preview text size live without moving the slider under the pointer |
| Key remapping row (press a key, conflict warning) | Accessibility Options (VS) | Conflict rule from accessibility requirements (Motor) |
| Single-line text input (tester id; F9 note) | Playtest Log setup prompt / F9 (playtest builds) | Facilitator-facing; IP-21-like rows + IME support |
| Loading state (boot verification ≈ 0.6 s) | Boot (ADR-0003/0006) | Static paper "Opening the store…", input blocked, no spinner |
| Tab cluster layout at `ui_scale` ≥ 1.5 and locked Hint condition text placement | Workbench / strip spec | Tabs may grow leftward over the shelf zone, never over the niche (art bible 7.1); hint OQ7 |
| Challenge mode banner + live rule check | Workbench spec (CC UI Req 2) | Probably IP-07 + a rule tag object; define in the workbench spec |
| Shift-start card | Progression | 300 ms strip crossfade (art bible exception 1) |
| Back Room tab and "practice data" label | Back Room (Alpha) | Workbench UI Req 6 |

---

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Can `CodeEdit` leave Ctrl+Enter / Ctrl+Shift+Enter / F6 to the shortcut layer without swallowing them, with an IME composition active? (IP-01) | ui-programmer | ADR-0008 / IME probe |
| 2 | Should the bubble advance with Enter / Space only when the strip has focus, or also from the editor with a dedicated chord? (IP-13) | ux-designer | Workbench spec |
| 3 | Grid keyboard: does the cell cursor need its own pane stop, or is it part of "results" (IP-02, IP-11)? | ux-designer | Workbench spec |
| 4 | Player journey map does not exist; arrival context is assumed | ux-designer | Before `/ux-review` |
