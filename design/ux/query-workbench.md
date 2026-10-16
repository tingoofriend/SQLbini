# UX Spec: Query Workbench

> **Status**: In Design — revised after /ux-review 2026-10-16, re-review pending
> **Author**: tingoofriend + Claude (`/ux-design query-workbench`, autonomous; layout choices by the developer 2026-10-16)
> **Last Updated**: 2026-10-16 (revision after `/ux-review`: error strip under the editor, verdict clears on edit, Shift menu, focus order, Restart / skip-button lifetimes, ADR-0010 signals)
> **Journey Phase(s)**: every request of every shift (≈ 90% of play time); Day One Morning (1-1…1-3) in its Guided variant
> **Platform Target**: PC (Windows, Linux), 1280×720 logical canvas (`canvas_items` stretch, `expand` aspect — ADR-0005 pending); keyboard + mouse, keyboard-first
> **Template**: UX Spec
> **Sources**: `design/gdd/query-workbench.md` (owner), `request-and-reaction-dialogue.md`, `hint-system.md`, `store-manual.md`, `constraint-challenges.md`, `onboarding-first-shift.md`, `shift-and-chapter-progression.md`, `hidden-data-grader.md`, `playtest-log.md`; `design/art/art-bible.md` 3.3, 4, 7; `design/ux/interaction-patterns.md` (IP-xx); `design/accessibility-requirements.md`; ADR-0004 §4, ADR-0006, ADR-0007, ADR-0010
> **Shared definition**: the strip's **Shift button and menu** are defined identically here and in `design/ux/shift-flow.md` (IP-22).

---

## Purpose & Player Need

The player arrives wanting to **answer one customer's request with a query that
is right for every day of the store, not just today**. The workbench lets them
read the request, write SQL, run it on today's visible data as often as they
like, compare their result with the target, and submit it to be checked on
hidden data. It must make the condition (the request) and the data (the two
grids) the clearest things on screen, make a Run cost nothing, and make it
impossible to mistake a matching Run for a pass (Pillar 1). If it were hard to
use, the game would turn from "think about the condition" into "fight the UI".

---

## Player Context on Arrival

- **First time:** Day One, after Tanaka's briefing and the "Ever used SQL
  before?" question; many players have never written SQL (concept MVP target:
  zero-SQL players). They are curious and slightly anxious; the Guided variant
  (coach marks, prefilled 1-1, ghost text in 1-3) carries them.
- **Every other time:** the player has just finished a request (PASS reaction,
  skip, or picking a request from the chapter list) and a new customer steps
  up. Calm, untimed, focused — the "evening-shift" mood of the art bible.
- They arrive voluntarily by continuing the shift; nothing on this screen is
  timed.
- *Assumption:* no player journey map exists (`design/player-journey.md`);
  arrival states above are inferred from the GDDs (Open Question 1).

---

## Navigation Position

Game start → (boot loading) → shift screen → **Query Workbench** (one request at
a time) → payslip at clock-out → next shift. Alternate entry: chapter list →
replay / reopen / restart a request → workbench. In the MVP there is no main
menu (Game Shell is Vertical Slice); the workbench is the screen the player
lives in, and the shift screen / payslip / chapter list are its satellites,
reached through the strip's **Shift menu** (IP-22).

---

## Entry & Exit Points

| Entry Source | Trigger | Player carries this context |
|---|---|---|
| Boot | Content verified (≈ 0.6 s loading state), new session | Day One, Morning; Guided variant if first launch |
| Shift screen | Shift starts → Tanaka's briefing in the bubble, then the first main request is displayed (`request_shown`, Dialogue rule 3c) | Shift id, side tickets (opened when the briefing ends) |
| Previous request | PASS hold ends / Kenji's `skip.accept` hold ends → `request_shown` for the next request | Next request id; challenge offer ticket if unanswered |
| Chapter list | Replay, Reopen (left for later) or Restart a request | That request's session draft; after Restart its `prefill_sql` or empty (ADR-0010 §6) |
| Challenge offer | "Try it" on the PASS offer or a ticket | Challenge mode, draft seeded from the last passing query (CC rule 6c) |

| Exit Destination | Trigger | Notes |
|---|---|---|
| Next request (same screen) | PASS hold ends; skip accepted | Draft of the finished request kept for the session |
| Payslip | Last main request of the shift resolved → clock-out | Progression owns timing |
| Shift screen / chapter list / options | Shift menu (IP-22), Ctrl+Shift+S | Draft kept; nothing is lost; unavailable in challenge mode |
| Main request | Leave challenge mode | CC rule 6a; returns to the open main request, or the shift screen when none |
| Quit | Window close / code quit | Playtest builds write `session_end` (ADR-0004); session-only state is lost at MVP (no save) |

---

## Layout Specification

### Information Hierarchy

1. **The request** (what is being asked) — bubble / request ticket.
2. **The editor** (the player's query) — largest, calmest surface.
3. **Your result vs Target** — the two grids, compared row by row.
4. **The latest outcome** — error strip under the editor; Run note, FAIL note or PASS stamp on the receipt.
5. **Schema** — tables and columns to insert.
6. **Help entries** — Hint, Manual, Log tabs; "new" indicators.
7. **Chrome** — Shift button, playtest label.

### Layout Zones

The approved GDD layout (workbench Visual/Audio "Layout at 1280×720") is kept;
this spec fixes the numbers. Logical px at 1280×720, `ui_scale` 1.0; outer margin
and gutters 16 px (art bible 7.7).

| Zone | Rect (x, y, w, h) | Contents |
|---|---|---|
| **Z1 Counter strip** | 0, 0, 1280, 120 (fixed at every `ui_scale`) | Pixel-art scene; bubble ≈ 416–928 × 80 px; tab cluster x 936–1264 |
| Zone rule | 0, 120, 1280, 6 | 4 px `ink` + 2 px `paper` (art bible 7.1) |
| **Z2 Left column** | 16, 142, 567, 562 | Editor header + editor, **error strip (when present)**, Run/Submit row, schema shelf (≈ 120 px, collapsible) |
| **Z3 Right column** | 599, 142, 665, 562 | "Your result" grid, "Target" grid, feedback receipt |

Z2 vertical split at 1.0, no error: editor header 28 · editor 332 · gap 8 ·
Run/Submit row 40 · gap 8 · schema shelf 146 (header 26 + chips 120) → 562
(corrects the earlier 316, which did not sum to 562). Collapsing the shelf gives
its height to the editor.

**Error strip under the editor** (resolves review S1 — developer decision
2026-10-16, GDD placement: workbench rule 13, grader Visual/Audio "at the
editor"): when a Run or Submit error, `TOO_MANY_ROWS` (Submit) or `UNAVAILABLE`
is shown, the jammed register strip sits **between the editor and the Run/Submit
row**, full column width. Height = 8 gap + 48 (label line + one mono line) and
grows to 3 mono lines (+ 24 each); longer text scrolls inside the strip. The
**editor shrinks** by that height (332 → 276 at one line, 228 at three lines);
the Run/Submit row and the shelf never move. The strip appears in place (0 ms)
and is removed on the next edit (see States).

Z3 vertical split at 1.0: each grid block = header 24 + body `H_table` 179 + count
line 24 = 227; gap 8 between blocks; feedback receipt = remaining height
(≈ 92 px at 1.0). **`H_table` uses the actual logical viewport height** `h_view`
instead of the constant 720 (resolves workbench OQ8; a 16:10 window gains rows):
`H_table = 0.40 × (h_view − strip_h − 32) − 48 × ui_scale`.

**Feedback receipt growth (Claude decision; new pattern → IP library Gaps):** the
receipt is at least 92 px and grows to fit up to 3 lines of its outcome text; the
space comes from the **Target** grid body, which shrinks down to a floor of 2 rows
(the grid scrolls). Beyond that the receipt text scrolls inside the receipt. Your
result never shrinks for feedback. The receipt holds the Run tally note, the FAIL
note, the PASS stamp and the "↷ Leave it for Kenji" button — never error text
(that is the strip under the editor).

### ASCII Wireframe

```
 0                                     416                     928        1264 1280
 ┌──────────────────────────────────────────────────────────────────────────────┐ 0
 │ [window] [speaker]  ┌ REQUEST 1-5 · Cheap drinks ─────────┐ ┌──────┬───────┐│
 │  pixel   niche      │ "Show me the drinks under ¥200…"    │ │Shift▾│ Log   ││
 │  art                │                              1/2 ▸  │ ├──────┼───────┤│
 │                     └─────────────────────────────────────┘ │ Hint │Manual ││
 │                                                              └──────┴───────┘│ 120
 ╞══════════════════════════════════════════════════════════════════════════════╡ 126
 │ ┌ SQL editor ───────────── Esc: leave editor ┐ ┌ Your result ─── Stale? ──┐ │ 142
 │ │ 1  SELECT name, prise                      │ │ mark   │ name    │ price │ │
 │ │ 2  FROM products                           │ │ ✓ match│ Cola    │   150 │ │
 │ │ 3  WHERE category = 'drink'                │ │ + extra│ Tea     │   210 │ │
 │ │            ~~~~~ (wavy: error token)       │ │ …                         │ │
 │ └────────────────────────────────────────────┘ │ 4 rows · 3 ✓ · 1 + extra  │ │
 │ ┌ ⚠ ERROR ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲ ┐ │   · 0 − missing           │ │
 │ │ no such column: prise                      │ ├ Target ──────────────────┤ │
 │ └────────────────────────────────────────────┘ │ name    │ price           │ │
 │ [ Run  Ctrl+Enter ]      ⟷ ≥24px     [■ Submit Ctrl+Shift+Enter ]       │ │
 │ ┌ Shelves (schema) ─────────────────── [−] ┐ ┌ receipt ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲ ┐ │
 │ │ ▭ products: [I id] [T name] [I price]…   │ │ ? Not accepted …          │ │
 │ │ ▭ sales: …                               │ │ [↷ Leave it for Kenji]    │ │
 │ └──────────────────────────────────────────┘ └───────────────────────────┘ │ 704
 └──────────────────────────────────────────────────────────────────────────────┘ 720
```

(Error strip shown for illustration; it exists only while an error is shown.
Tab cluster as a 2 × 2 grid at `ui_scale` 1.0–1.25; Back Room tab from Chapter 2
makes it 2 × 3 → see Tab cluster below. "Shift▾" = the Shift button, which opens
the Shift menu. Not to scale.)

### Component Inventory

| Zone | Component | Type | Content | Interactive | Pattern |
|---|---|---|---|---|---|
| Z1 | Speaker sprite | Pixel art | Current speaker | No (decorative, AccessKit hidden) | — |
| Z1 | Bubble / request ticket | Paper text panel | Request (ticket, "REQUEST 1-5 · title" tab) or reaction (rounded, name tag); paging "1/2 ▸" | Yes (click / Enter / Space pages) | IP-13 |
| Z1 | Inline offer buttons | Buttons in bubble | Try it / Later; Leave it for Kenji / Keep trying; Day One "Ever used SQL?" choices | Yes | IP-14 |
| Z1 | Shift button | Tab + menu | "Shift ▾" — opens the Shift menu (Shift screen, Chapter list, Options; + Log at `ui_scale` ≥ 1.5); Ctrl+Shift+S; disabled in challenge mode with the visible words "Leave the dare first" | Yes | IP-22 (new), IP-01 |
| Z1 | Log tab | Tab | "Log" (Ctrl+L); in the Shift menu at ≥ 1.5 | Yes | IP-16 |
| Z1 | Hint tab | Tab | "Hint" + state word: "locked" / "new" / "open" (Ctrl+H); in challenge mode replaced by the label "No hints for dares." | Yes | IP-10, IP-15 |
| Z1 | Manual tab | Tab | "Manual" + "new" (Ctrl+M) | Yes | IP-10, IP-15 |
| Z1 | Back Room tab | Tab | "Back Room" (Ctrl+B), Chapter 2+ | Yes | Alpha |
| Z1 | Ticket slot | Paper tickets | Side requests and unanswered offers (dimmed in challenge mode) | Yes | IP-14 |
| Z2 | Editor header | Label row | "SQL editor"; in challenge mode the rule tag + live check + "Leave challenge" button; "Esc: leave editor" while focused | Partial (Leave challenge) | IP-03, IP-23 (new) |
| Z2 | Editor | `CodeEdit` | Draft; line numbers; highlighting; ghost text (Guided); wavy underline on an error token | Yes | IP-06 |
| Z2 | Error strip | Jammed register strip | "⚠" + error label + `error_text` (mono), or the fixed / row-cap / "Content error — reported" text | No (read-only; live region) | IP-08 |
| Z2 | Run button | Outlined button | "Run  Ctrl+Enter" | Yes | IP-04 |
| Z2 | Submit button | Filled indigo button | "Submit  Ctrl+Shift+Enter" | Yes | IP-04 |
| Z2 | Schema shelf | Collapsible list | Shelf label per table; column chips with type letter | Yes | IP-05 |
| Z3 | Your result grid | Grid | Last Run result with mark gutter; count line (row count + marks, or the column-count / order / row-cap line); "Stale — run again" tag | Yes (one Tab stop, cell cursor) | IP-11 |
| Z3 | Target grid | Grid | Reference on visible data; "− missing" ghost rows | Yes (one Tab stop, cell cursor) | IP-11 |
| Z3 | Feedback receipt | Paper panel | Tally note / FAIL note / PASS stamp + "✓ ACCEPTED" / "checking…" | Partial (Leave it for Kenji button) | IP-08, IP-09 |
| Z3 | "↷ Leave it for Kenji" | Secondary text button | On the receipt of the displayed request from `skip_offered` (see Skip button lifetime) | Yes | IP-14 |
| Z3 | Side panel (Manual / Hint) | Overlay over the two grids | Ring binder or folded note; locked Hint shows its unlock condition | Yes | IP-15 |
| Overlay | Message log | Full overlay + scrim | Every line of the shift | Yes | IP-16 |
| Overlay | Coach mark | Ring + tag + "Got it" | Guided marks on Run, Submit, schema shelf, Manual tab | Yes | IP-17 |
| Overlay | Minimal options panel | Panel | "Coach marks", "Reduced motion" toggles (Onboarding) | Yes | IP-21 |
| Overlay | F9 note field | One-line text field | Facilitator note (playtest builds) | Yes (facilitator) | Gap: single-line input |
| Corner | Playtest label | Label | "● Recording playtest" / "Recording stopped" (playtest builds) | No | IP-07 |

**Shift button and menu** (developer decision 2026-10-16; identical in
`shift-flow.md`; IP-22): the strip's Shift button opens a small menu: **Shift
screen**, **Chapter list**, **Options** (and **Log** when `ui_scale` ≥ 1.5).
Chord **Ctrl+Shift+S** (free in the IP-01 table; `CodeEdit` must not consume it —
IP library OQ1). In challenge mode the Shift button is disabled and shows the
visible words **"Leave the dare first"** on its second line (also its accessible
description); it stays focusable so the reason can be read, and Ctrl+Shift+S does
nothing.

**Tab cluster at higher `ui_scale`** (art bible 7.1; resolves review item 1):
- 1.0–1.25: 2 columns × 2 rows (3 rows with Back Room); each tab shows its word
  and, on a second line, its state word ("locked", "new", "open") with the dot.
- ≥ 1.5: one row of tabs ("Shift", "Hint", "Manual", "Back Room"), each still two
  lines — word + **visible** state word with its 6 px indigo dot (never the dot
  alone; IP-07, IP-10). The **Log** entry moves into the Shift menu. The cluster
  grows leftward and the bubble shrinks to match — never below 360 px wide and
  never over the speaker niche; if the bubble would go below 360 px (expected
  only at 2.0 with Back Room), **Back Room** also moves into the Shift menu.
  Ctrl+L and Ctrl+B work at every scale (Open Question 3: verify by capture).

**Locked Hint** (resolves Hint OQ7, developer decision): the tab reads
"Hint · locked"; Ctrl+H or clicking opens the hint panel, which shows the
condition ("Available after 2 wrong answers or 3 minutes" — from the puzzle's
thresholds) and the progress so far; the same sentence is the tab's accessible
description. (New pattern "locked feature panel" → IP library Gaps.)

**Hint panel slot** (resolves workbench OQ6, developer decision): the hint
panel opens in the **same slot as the Manual** — over the two grids in the right
column; one side panel at a time. **The feedback receipt stays visible** below
the panel (Claude decision), so the player can read the FAIL note and the hint
together.

**Challenge-mode hint area** (CC UI Req 5): the Hint tab is hidden and its slot
in the tab cluster shows the non-interactive label **"No hints for dares."**
(not focusable; read as part of the strip landmark). Ctrl+H does nothing.

**No dedicated visible-data view** (resolves workbench OQ7, developer decision):
the player reads today's shelf by running a query (`SELECT * FROM products`);
`visible_rows_max` stays 30 (Puzzle Definition), so a full table scrolls in
the result grid. Revisit only if the zero-SQL playtest shows players stuck on
"what is in the table" (Open Question 2).

### Focus Order (resolves review item 2, IP library OQ2 and OQ3)

F6 / Shift+F6 cycle the five regions in IP-02 order; inside a region Tab /
Shift+Tab move between the stops below; arrows move inside a grid, list or menu.

| F6 region (landmark) | Tab stops, in order | Notes |
|---|---|---|
| 1. Request (strip) | Bubble → inline offer buttons (safe choice first) → tickets (left → right) → Shift → Log → Hint → Manual → Back Room | Tabs in reading order of the cluster; disabled Shift (challenge) stays a stop |
| 2. SQL editor | Editor → Run → Submit → Leave challenge (challenge mode only) | Run/Submit belong to this region; the error strip is not a stop (live region); Tab in the editor indents, so Esc then Tab reaches Run |
| 3. Shelves (schema) | Collapse toggle → chips in reading order (table by table) | Enter inserts (IP-05); focus stays on the chip |
| 4. Results | Your result grid → Target grid | **Each grid is one Tab stop**; arrows / PgUp / PgDn / Home / End move the cell cursor inside it (IP OQ3: no own pane stop). While a side panel is open this region **is the panel** ("Manual" / "Hint" landmark): its controls replace the covered grids |
| 5. Feedback | Receipt (one read-only stop) → "↷ Leave it for Kenji" (when shown) | The receipt is focusable so its text can be read by keyboard and screen reader |

- **Bubble advance (IP OQ2):** Enter / Space page the bubble only while the strip
  region has focus, or a click on the bubble; **no chord from the editor** —
  Enter there is always a newline, the reveal never delays typing, and every
  line is in the log (Ctrl+L).
- **Focus never jumps** to an offer, a ticket, the skip button or a coach mark
  (IP-14, IP-17); the only automatic moves are the Day One opening question
  (first choice) and the briefing (bubble), when no request is open.
- Overlays: the Shift menu takes focus on its first item; Esc closes it and
  returns to the Shift button. The log traps focus (IP-16). The options panel
  takes focus on its first toggle; Esc returns to the Shift button. A coach
  mark's tag follows its target in Tab order (IP-17).

---

## States & Variants

| State / Variant | Trigger | What Changes |
|---|---|---|
| Loading | Boot verification (≈ 0.6 s) | Full paper screen "Opening the store…", input blocked, no spinner (new pattern → IP library Gaps) |
| Boot: puzzle withheld | `verify_all` marks a puzzle `withheld` (ADR-0003) | Boot continues; that request is "unavailable" on the chapter list (word only, IP-20) and is never displayed; Progression owns the skip |
| Boot failure | No playable content after verification (e.g. the chapter cannot load) | *Provisional:* paper screen "The store can't open today." + "Content error — reported" (no raw text) + **Quit** button (focused, Enter); no retry at MVP (Open Question 6) |
| Briefing | Shift start | Bubble shows Tanaka's `briefing` (paged); editor read-only, empty, placeholder "The first order comes after the briefing"; focus on the bubble (Enter/Space pages) |
| Opening question (Day One) | `line_requested` from Onboarding after the first briefing | Bubble: "Ever used SQL before?" with two inline choices; **focus moves to the first choice** (nothing else to do yet); then 1-1 is displayed |
| Request shown (default) | `request_shown` (display) — not `request_opened` (state only) | Ticket bubble; editor focused with the request's draft (or `prefill_sql` on first draft); grids empty with "Run to see your result" in `ink_muted`; Target shown |
| Reaction | A verdict / Run-error reaction, explainer or start-over line | Rounded bubble + name tag; returns to the request after `reaction_hold`, a click on the speaker, a Run (`run_started`), or an edit once fully visible for `reaction_grace` (Dialogue state table) |
| Pass reaction | PASS (or `skip.accept`) | Pass line (+ challenge offer merged into the same bubble, ADR-0010 §5); ended only by its hold or click / Enter / Space on the strip — edits and Run do not end it; then the next request is displayed |
| Guided (Day One Morning) | Onboarding rule 7, `guided_window_changed(true)` | Coach marks per rule 7a; ghost text on 1-3; Hint/Manual "new" hidden by the view while the window is open |
| Checking | No result 200 ms after Run/Submit | Receipt shows "checking…" (static) |
| Run result | Run returns `ok` | Your result filled with marks; count line "4 rows · 3 ✓ · 1 + extra · 0 − missing"; tally note "≈ Looks right today (not checked)" on the receipt when everything matches |
| Column mismatch | Run `ok`, column count ≠ target | Count line replaced by "You returned 3 columns; the request needs 2" (workbench rule 8); row marks, tints and tally note not shown |
| Order mismatch | *Provisional:* `ordered` puzzle, same rows as the target in a different order | Count line "! Same rows, different order"; ✓ marks stay. Not used in Chapter 1 (no ordered puzzles); exact rule to confirm with the GDD owner (Open Question 7) |
| Stale | Draft edited after a Run | "Stale — run again" header tag; marks/tints and tally note hidden; grid text `ink_muted` (no opacity, no italic) |
| Run error | Sandbox error on Run | Error strip under the editor: "⚠" + label + SQLite `error_text` (mono) or the fixed message; error token wavy-underlined; grids keep the last result marked Stale; Kenji's reaction in the bubble |
| Run TOO_MANY_ROWS | Visible Run above `grader_row_cap` | No grid fill; Your result count line "{grader_row_cap}+ rows — too many to compare" (same string as the Submit strip, workbench rule 13) |
| Submitting | Submit pressed | Run and Submit disabled with "checking…"; typing stays live |
| Submit error | SUBMIT_ERROR (sandbox kinds) | Error strip under the editor as Run error; the requester's reaction in the bubble |
| Submit TOO_MANY_ROWS | SUBMIT_ERROR `TOO_MANY_ROWS` | Error strip: "⚠ Too many rows" + "{grader_row_cap}+ rows — too many to compare"; no `error_text` |
| UNAVAILABLE | Verdict `UNAVAILABLE` | Back to editing; error strip "⚠ Content error — reported" with **no raw text**; Dialogue's `error.CONTENT_ERROR` line in the bubble; the request may be left (Progression rule 7a) |
| FAIL | Grader FAIL | Sticky note "? Not accepted" + level-1 statement (from `statement_key`) on the receipt; reaction in the bubble |
| PASS | Grader PASS | Stamp lands on the receipt + "✓ ACCEPTED"; pass reaction + optional challenge offer in the bubble |
| First Submit explainer | The player's first Submit in the game (1-2's first Submit when onboarding is on; workbench rule 11) | Tanaka's one-time `system` line, queued **after** the verdict reaction and shown after its hold (ADR-0010 §5 priority 2); also in the log |
| Verdict cleared | Any editor edit after a verdict or error | **Stamp, FAIL note and error strip are removed** (developer decision 2026-10-16, review S2; workbench rule 12, grader UI Req 5); the error-token underline goes; Run results go Stale |
| Exhausted / skip offered | `skip_offered` | Kenji's offer in the bubble (IP-14); "↷ Leave it for Kenji" on the receipt (lifetime below) |
| After Restart | `request_restarted` for the displayed request (ADR-0010 §6) | Draft ← `prefill_sql` or empty; grids back to "Run to see your result"; tally note, verdict and error strip removed; skip button hidden; Hint back to Locked; no coach marks replayed; queued or shown `skip.offer` dropped |
| Challenge mode | "Try it", `challenge_mode_changed(true)` | Editor header: rule tag ("Dare: no `IN`") + live check "✓ rule met" / "☆ not yet" + "Leave challenge" button; Hint tab replaced by "No hints for dares."; side tickets dimmed; Shift button disabled ("Leave the dare first"); the challenge's own draft |
| Side panel open | Ctrl+H / Ctrl+M | Panel over the grids; receipt visible |
| Log open | Ctrl+L | Scrim + log; workbench inert until closed |
| Shift menu open | Shift button / Ctrl+Shift+S | Menu under the button; Up/Down, Enter, Esc |
| Options open | Shift menu → "Options" | Minimal options panel (IP-21) |
| `ui_scale` ≥ 1.5 | Setting (VS; at MVP only via `settings.json`) | Grids scroll horizontally under frozen header + gutter; tab cluster variant; bubble pages sooner |
| Chapter 2+ | Chapter | Back Room tab present; "Back Room — practice data" label while active (Alpha) |

**Skip button lifetime** (ADR-0010 §4–§5, Progression UI Req 2): "↷ Leave it
for Kenji" appears on the receipt when `skip_offered` arrives for the displayed
request — even if the `skip.offer` line itself was dropped by the reaction
queue. It stays through Keep trying, edits, Runs, Submits, FAIL notes, side
panels and the "Verdict cleared" state. It is hidden on `skip_accepted`, on
`request_restarted`, while challenge mode is open, and whenever another request
is displayed; it returns when that request is displayed again (Progression
holds the state). It never takes focus; its arrival is announced once in the
polite live region.

**Offer ticket lifetime** (ADR-0010 §4): an unanswered challenge offer stays as a
ticket until it is answered or `challenge_offer_expired` arrives (the next
request's first Submit, or clock-out = Later); then it is removed in place.

---

## Interaction Map

| Component | Action | Input | Immediate feedback | Outcome |
|---|---|---|---|---|
| Editor | Type / edit | Keys, IME | Text; highlighting | Draft updated; grids go Stale; verdict and error strip cleared; `draft_edited`; `edit_burst` coalesced |
| Editor | Leave | Esc | Focus ring on the editor frame | Tab moves to Run (IP-03) |
| Editor (Guided 1-3) | Accept ghost | Tab in empty editor | Ghost becomes text | Draft = shape example |
| Run | Run query | Ctrl+Enter / click | "checking…" only if > 200 ms | `run_started`; result grid + marks + tally note, or error strip; `run_finished`; `run` event; a newer Run supersedes an older one (IP-09); a showing reaction ends |
| Submit | Submit | Ctrl+Shift+Enter / click | Buttons disabled, "checking…" | `submit_started`; verdict on the receipt or error strip; reaction in the bubble; `submit` event (grader) |
| Schema chip | Insert name | Click / Enter | `selection` fade on inserted text | Name at the caret, with the auto-separator rule (workbench rule 3) |
| Schema shelf | Collapse / expand | Click [−] / Enter on toggle | Shelf folds | Editor gains height |
| Bubble | Page / complete reveal | Click; Enter / Space with strip focus | Next page | `line_shown` per line |
| Inline offer | Choose | F6 to the strip, Tab, Enter / click (focus does not jump to it) | Choice highlighted | `choice_made`; challenge starts / later; skip / keep trying |
| Hint tab | Open / close | Ctrl+H / click | Panel appears in place | `hint_open {step}`; locked → condition text |
| Manual tab | Open / close | Ctrl+M / click | Binder appears | `manual_open {page}`; Copy example → IP-05, `manual_copy` |
| Log tab | Open / close | Ctrl+L / click | Scrim + log | `log_opened` |
| Shift button | Open menu | Ctrl+Shift+S / click / Enter | Menu appears in place | Shift screen / chapter list / options (/ log ≥ 1.5); draft kept; disabled in challenge mode |
| Grid | Move cell / scroll | Arrows, PgUp/PgDn, Home/End, wheel | Focus ring on cell | — |
| Coach mark | Dismiss | "Got it" / Esc with mark focused | Mark removed | `mark_dismissed`; Done on target action → `mark_done` |
| Panes | Cycle | F6 / Shift+F6 | Pane focus bar | Focus moves (IP-02) |
| Leave it for Kenji | Skip request | Click / Enter | Kenji's accept line | `choice_made` → Progression; `request_skip`; next request or clock-out |
| Leave challenge | Exit dare | Click / Enter | — | Main request (CC rule 6a) |
| Playtest F9 | Help marker | F9 (facilitator) | One-line note field | See F9 below |

**F9 (playtest builds; ADR-0004 §4):** read from `root.window_input` by key type
and keycode, never `_input` or `event.device`. F9 records `help_given` at once
and opens the note field **only when no embedded subwindow is open** (with a
dialog open it records the marker without the field). F9 is ignored while the
field is open. Enter saves `help_note`; Esc or 5 s idle closes without a note;
either way focus returns to the editor (deferred). Esc here is not "leave
editor". The 5 s idle close is facilitator-only, not player-timed input
(accessibility requirements, Input timing).

---

## Data Requirements

| Data | Source (owner) | Read / write |
|---|---|---|
| Current line, speaker, kind, pages | Request & Reaction Dialogue | Read |
| Draft per puzzle, last Run result, last verdict, Stale flag | WorkbenchController (Workbench) | Read/write |
| Puzzle title, schema, visible dataset, prefill, ghost text | PuzzleRepository (Puzzle Definition), StringTable | Read |
| Target result (visible) | Reference cache (ADR-0003) via grader | Read |
| Run result + match bit | SqlSandbox + `run_match` (grader) | Read |
| `Verdict` (kind, cause, level, `statement_key`, `error_kind`, `error_text`) | Hidden-Data Grader — return of `await grader.submit()` | Read — never missing/extra counts or hidden rows (grader rule 11) |
| Hint state (locked/ready/open/exhausted), thresholds | Hint System | Read |
| Manual pages and "new" | Store Manual (`page_unlocked`) | Read |
| Challenge mode, rule, live check | Constraint Challenges (`challenge_mode_changed`; tokens from `tokenize`) | Read |
| Displayed request, Restart, skip offer, shift state | Shift & Chapter Progression (`request_shown`, `request_restarted`, `skip_offered` / `skip_accepted`, `shift_*`) | Read (signals) |
| Coach marks state, suppression window | Onboarding (`guided_window_changed`) | Read |
| `ui_scale`, `reduced_motion`, `coach_marks`, reveal speed | `Settings` (ADR-0007; session-only at MVP) — typewriter reads `Settings.effective_reveal_cps()` | Read |
| All player-facing text | `StringTable` ids (ADR-0007) | Read |

---

## Events Fired and Signals

**Log events** — through `EventBus.emit_event` with the canonical names of
`playtest-log.md` rule 4 (ADR-0004). Owned by the Workbench: `run {sql, dataset,
ok, error_kind, rows, match, build_message?}` and `edit_burst {chars_changed}`.
Triggered from this screen but owned elsewhere: `submit` (grader), `hint_open`
(Hint), `manual_open` / `manual_copy` (Manual), `challenge_try` /
`challenge_later` / `challenge_start` (Challenges), `request_skip`,
`request_restart` (Progression), `sql_question` and `mark_*` (Onboarding),
`line_shown` / `log_opened` / `line_skipped` (Dialogue), `help_given` /
`help_note` (Playtest Log).

**Gameplay signals** (typed, never the bus — ADR-0004 §2, ADR-0010 §4). Declared
by the WorkbenchController: `run_started(puzzle_id)`, `run_finished(puzzle_id,
result_ok, rows_match, feedback)`, `submit_started(puzzle_id)`,
`draft_edited(puzzle_id, text)`, `line_requested(line_id, puzzle_id)` (the
first-Submit explainer); it answers `draft_is_empty(puzzle_id)` through the
injected Callable. The view reacts to `request_shown` (display — loads the
puzzle), never to `request_opened` (state only; side requests open at briefing
end but are displayed when the player opens them; nothing is displayed while
challenge mode is open).

---

## Transitions & Animations

Per art bible 7.6 and IP rules: Run result, tally note, FAIL note, error strip,
panels, menu and "new" indicators appear in place (0 ms); PASS stamp 180 ms and
star hanko +60 ms; log scrim 120/90 ms; schema insert fade 200 ms; coach-mark
settle 200 ms once; NPC step-in 200 ms stepped; shift palette crossfade 300 ms
(strip only); typewriter at `Settings.effective_reveal_cps()`. Under reduced
motion every one is its final state (`effective_reveal_cps()` = 0 → full line).
Nothing loops or blinks; the caret is steady. No transition delays input.

---

## Input Method Completeness Checklist

- [x] Every action has a keyboard path (Interaction Map) and a mouse path, except
      typing and F9 (keyboard only by nature).
- [x] Every focusable control shows the focus ring; hover never draws indigo.
- [x] F6 pane order and Tab order inside every region defined (Focus Order); Esc precedence defined (IP-02, IP-03).
- [x] No hold, no rapid input, no player-timed input (F9's 5 s idle is facilitator-only).
- [x] Chord labels shown on controls and update with remapping (VS).
- [ ] IME composition committed before Run — verify (workbench OQ4, ADR-0008).
- [ ] `CodeEdit` does not swallow Ctrl+Enter / Ctrl+Shift+S / F6 — verify (IP library OQ1).
- [x] Gamepad / touch: not supported (accessibility requirements, Known Intentional Limitations).

---

## Accessibility

Tier: Standard + reduced motion + full keyboard (`design/accessibility-requirements.md`).
- Text sizes and contrast per art bible 4.4 / 7.9; base fonts editor 18 / tables
  16 / bubble 18; **base range narrowed to 14–24** (developer decision; resolves
  workbench OQ9: 24 × 2.0 = 48 px max effective).
- Key contrast values: text floor 4.5:1, 7:1 target for body and editor text;
  bubble `ink` on `card` 14.9:1; ghost text 5.71:1 on `editor_bg`; inline SQL
  token run 11.24:1; worst Stale pair 6.67:1; non-text (glyphs, focus ring, row
  bars, card border 4.42:1) ≥ 3:1.
- Glyph + word on every mark, verdict, tab state and live check (IP-07), at every
  `ui_scale`; "unavailable" is a word only (IP-07).
- Run vs Submit separation ≥ 24 × `ui_scale` px; minimum target 32 × `ui_scale` px.
- AccessKit (best effort): landmarks for the five regions; grid role with headers;
  verdict, error strip and skip-button arrival in a polite live region; strip art
  hidden; the bubble line is announced whole on arrival (typewriter is visual only).
- Reduced motion toggle in the minimal options panel at MVP (`Settings.reduced_motion`).
- Every state must remain identifiable in a greyscale capture (UX-QW-18).

---

## Localization Considerations

- All player-facing text from StringTable ids (dialogue rule 9); no literals in
  UI code (RD-12 scan).
- Bubble paging is measured per language and `ui_scale`; tabs and buttons must
  fit +40% text length (German-style) at 1.0 — the tab cluster variant (≥ 1.5)
  is the fallback.
- Maximum English lengths (each must still fit at +40%): tab word ≤ 10
  characters, tab state word ≤ 8; button labels ≤ 12 plus the chord; Shift menu
  items ≤ 20; "Leave the dare first" ≤ 22 on two lines; count line ≤ 48; error
  strip label ≤ 24; receipt outcome text ≤ 3 lines before scrolling; placeholder
  texts ≤ 48.
- Data values and SQL keywords are never translated; CJK fallback fonts bundled.
- Chord labels use the platform key names (Ctrl, Shift, Enter).

---

## Acceptance Criteria

- **UX-QW-01 [UI]** At 1280×720, `ui_scale` 1.0: zones Z1–Z3 visible without overlap; editor ≥ 300 px tall with no error strip; each grid shows 7 rows; capture retained.
- **UX-QW-02 [UI]** At `ui_scale` 1.5 and 2.0 (set through `settings.json`): no clipped text; grids scroll horizontally under frozen header + gutter; tabs show a visible state word next to the dot; Log is in the Shift menu; bubble ≥ 360 px wide; captures retained.
- **UX-QW-03 [UI]** Keyboard only: Day One 1-1…1-3 completed (opening question, coach marks, Run, Submit, Manual, Hint) without the mouse; focus visible at every step; F6 and Tab follow the Focus Order table exactly.
- **UX-QW-04 [UI]** Manual and Hint open in the same slot over the grids; opening one closes the other; the feedback receipt stays visible; neither covers the editor or strip.
- **UX-QW-05 [UI]** On a puzzle with a 2-fail / 3-minute threshold, the locked Hint tab reads "Hint · locked" and Ctrl+H shows "Available after 2 wrong answers or 3 minutes".
- **UX-QW-06 [UI]** A FAIL with a 3-line statement grows the receipt and shrinks Target to ≥ 2 rows; Your result keeps its height.
- **UX-QW-07 [Logic]** `H_table` uses the logical viewport height: at 1280×800 logical (16:10, `expand`), `rows_visible` at 1.0 = floor((0.40 × (800 − 152) − 48) / 24) = 8.
- **UX-QW-08 [UI]** Reduced motion on: stamp, coach ring, typewriter, NPC step-in and shift crossfade appear in final state (frame capture).
- **UX-QW-09 [UI]** When the skip is offered, "↷ Leave it for Kenji" appears on the receipt without taking focus; it stays after "Keep trying", an edit, a Run and a FAIL; Enter on it skips; it is gone after the skip and after a Restart of that request.
- **UX-QW-10 [UI]** Challenge mode: rule tag + live check glyph + word in the editor header; "No hints for dares." in place of the Hint tab; side tickets dimmed; Shift button disabled with the visible words "Leave the dare first".
- **UX-QW-11 [UI]** Run `SELECT nme FROM products`: the strip "⚠" + label + "no such column: nme" appears directly under the editor, the editor shrinks, Run/Submit do not move, `nme` is wavy-underlined; typing one character removes the strip and the underline.
- **UX-QW-12 [UI]** After a FAIL, typing one character removes the FAIL note; after a PASS stamp, an edit removes the stamp; Your result shows "Stale — run again" with marks and tally note hidden.
- **UX-QW-13 [UI]** Run a query returning more than `grader_row_cap` rows: no grid fill, count line "{cap}+ rows — too many to compare"; Submit it: the strip under the editor shows "⚠ Too many rows" and the same string, with no SQLite text.
- **UX-QW-14 [UI]** Run a 3-column query on a 2-column request: the count line reads "You returned 3 columns; the request needs 2" and no row marks or tally note are shown.
- **UX-QW-15 [Integration]** Restart 1-1 from the chapter list with a non-empty draft: the editor holds `SELECT * FROM products;`, the grids show "Run to see your result", no verdict, strip or skip button remains.
- **UX-QW-16 [Integration]** First Submit of the game (onboarding off) that FAILs: the FAIL reaction shows first; after its hold Tanaka's explainer shows; both are in the log.
- **UX-QW-17 [Perf]** On the target PC, Run result, marks and tally note appear within 200 ms of Ctrl+Enter at p95 over 100 Runs on 1-5 (TIMEOUT exempt).
- **UX-QW-18 [UI]** Greyscale and protan / deutan / tritan captures of PASS, FAIL, error strip, 1-5 row marks, tab states and the live check: every state identifiable by glyph + word.

---

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | No player journey map — arrival states inferred from GDDs | ux-designer | Before the next `/ux-review` (accepted assumption if still absent) |
| 2 | Do zero-SQL players need a data view after all (workbench OQ7, decided "no")? | ux-designer | Zero-SQL playtest |
| 3 | Tab cluster at ≥ 1.5: do the two-line tabs fit 120 px at 2.0, and does moving Log / Back Room into the Shift menu read well? Verify by capture | ux-designer + art-director | First strip/workbench build |
| 4 | Feedback receipt height at 2.0 with a long FAIL statement — enough with Target at 2 rows? | ux-designer | Capture at 2.0 |
| 5 | Shift screen, payslip and chapter list specs (`shift-flow.md`) must keep the Shift menu definition identical (IP-22) | ux-designer | `shift-flow.md` review |
| 6 | Boot failure screen (no playable content): Quit only, or a retry? Owner GDD (Game Shell is VS) | ux-designer + producer | Before the boot story |
| 7 | "Order line" (workbench UI Req 3) has no defining rule in the GDDs; provisional text "! Same rows, different order". Confirm with the workbench / grader owner before any ordered puzzle ships (none in Chapter 1) | game-designer | Before Chapter 2 content |
| 8 | Ctrl+Shift+S for the Shift menu: confirm `CodeEdit` and the OS do not claim it (IP library OQ1) | ui-programmer | ADR-0008 probe |

**Decisions recorded in this revision (developer decision 2026-10-16):** S1 —
SUBMIT_ERROR / Run error strip directly under the editor in Z2, editor shrinks;
S2 — stamp, FAIL note and error strip clear on any editor edit; Shift button
menu (Shift screen, Chapter list, Options, + Log at ≥ 1.5), Ctrl+Shift+S,
disabled in challenge mode with "Leave the dare first". **Claude decisions:**
grid = one Tab stop with an internal cell cursor (IP OQ3); no editor chord for
bubble paging (IP OQ2); "No hints for dares." in the Hint tab's slot; Back Room
joins the Shift menu when the bubble would go under 360 px. **Note:** ADR-0004
§4 lists "Restart confirmation" as an embedded dialog, while IP-18 keeps it
inline; IP-18 stays inline — the F9 rule works either way.
