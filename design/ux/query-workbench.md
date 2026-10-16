# UX Spec: Query Workbench

> **Status**: In Design (v1 draft — awaiting `/ux-review`)
> **Author**: tingoofriend + Claude (`/ux-design query-workbench`, autonomous; layout choices by the developer 2026-10-16)
> **Last Updated**: 2026-10-16
> **Journey Phase(s)**: every request of every shift (≈ 90% of play time); Day One Morning (1-1…1-3) in its Guided variant
> **Platform Target**: PC (Windows, Linux), 1280×720 logical canvas (`canvas_items` stretch, `expand` aspect — ADR-0005 pending); keyboard + mouse, keyboard-first
> **Template**: UX Spec
> **Sources**: `design/gdd/query-workbench.md` (owner), `request-and-reaction-dialogue.md`, `hint-system.md`, `store-manual.md`, `constraint-challenges.md`, `onboarding-first-shift.md`, `shift-and-chapter-progression.md`, `hidden-data-grader.md`, `playtest-log.md`; `design/art/art-bible.md` 3.3, 4, 7; `design/ux/interaction-patterns.md` (IP-xx); `design/accessibility-requirements.md`

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
lives in, and the shift screen / payslip / chapter list are its satellites.

---

## Entry & Exit Points

| Entry Source | Trigger | Player carries this context |
|---|---|---|
| Boot | Content verified (≈ 0.6 s loading state), new session | Day One, Morning; Guided variant if first launch |
| Shift screen | Shift starts → Tanaka's briefing in the bubble, then the first main request opens (Dialogue rule 3c) | Shift id, side tickets (arrive when the briefing ends) |
| Previous request | PASS reaction ends / Kenji's skip accepted | Next request id; challenge offer ticket if unanswered |
| Chapter list | Replay, Reopen (left for later) or Restart a request | That request's session draft (or empty after Restart) |
| Challenge offer | "Try it" on the PASS offer or a ticket | Challenge mode, draft seeded from the last passing query (CC rule 6c) |

| Exit Destination | Trigger | Notes |
|---|---|---|
| Next request (same screen) | PASS reaction ends; skip accepted | Draft of the finished request kept for the session |
| Payslip | Last main request of the shift resolved → clock-out | Progression owns timing |
| Shift screen / chapter list | Chapter-list button (from the shift tab of the strip) | Draft kept; nothing is lost |
| Main request | Leave challenge mode | CC rule 6a; returns to the open main request, or the shift screen when none |
| Quit | Window close / code quit | Playtest builds write `session_end` (ADR-0004); session-only state is lost at MVP (no save) |

---

## Layout Specification

### Information Hierarchy

1. **The request** (what is being asked) — bubble / request ticket.
2. **The editor** (the player's query) — largest, calmest surface.
3. **Your result vs Target** — the two grids, compared row by row.
4. **The latest outcome** — Run note, error strip, FAIL note or PASS stamp.
5. **Schema** — tables and columns to insert.
6. **Help entries** — Hint, Manual, Log tabs; "new" indicators.
7. **Chrome** — shift name, chapter-list button, playtest label.

### Layout Zones

The approved GDD layout (workbench Visual/Audio "Layout at 1280×720") is kept;
this spec fixes the numbers. Logical px at 1280×720, `ui_scale` 1.0; outer margin
and gutters 16 px (art bible 7.7).

| Zone | Rect (x, y, w, h) | Contents |
|---|---|---|
| **Z1 Counter strip** | 0, 0, 1280, 120 (fixed at every `ui_scale`) | Pixel-art scene; bubble ≈ 416–928 × 80 px; tab cluster x 936–1264 |
| Zone rule | 0, 120, 1280, 6 | 4 px `ink` + 2 px `paper` (art bible 7.1) |
| **Z2 Left column** | 16, 142, 567, 562 | Editor header + editor (≈ 62%), Run/Submit row, schema shelf (≈ 120 px, collapsible) |
| **Z3 Right column** | 599, 142, 665, 562 | "Your result" grid, "Target" grid, feedback receipt |

Z2 vertical split at 1.0: editor header 28 · editor 316 · gap 8 · Run/Submit row
40 · gap 8 · schema shelf 146 (header 26 + chips 120) → 562. Collapsing the shelf
gives its height to the editor.

Z3 vertical split at 1.0: each grid block = header 24 + body `H_table` 179 + count
line 24 = 227; gap 8 between blocks; feedback receipt = remaining height
(≈ 92 px at 1.0). **`H_table` uses the actual logical viewport height** `h_view`
instead of the constant 720 (resolves workbench OQ8; a 16:10 window gains rows):
`H_table = 0.40 × (h_view − strip_h − 32) − 48 × ui_scale`.

**Feedback receipt growth (Claude decision):** the receipt is at least 92 px and
grows to fit up to 3 lines of its outcome text; the space comes from the
**Target** grid body, which shrinks down to a floor of 2 rows (the grid
scrolls). Beyond that the receipt text scrolls inside the receipt. Your result
never shrinks for feedback.

### ASCII Wireframe

```
 0                                     416                     928        1264 1280
 ┌──────────────────────────────────────────────────────────────────────────────┐ 0
 │ [window] [speaker]  ┌ REQUEST 1-5 · Cheap drinks ─────────┐ ┌──────┬───────┐│
 │  pixel   niche      │ "Show me the drinks under ¥200…"    │ │◂Shift│ Log   ││
 │  art                │                              1/2 ▸  │ ├──────┼───────┤│
 │                     └─────────────────────────────────────┘ │ Hint │Manual ││
 │                                                              └──────┴───────┘│ 120
 ╞══════════════════════════════════════════════════════════════════════════════╡ 126
 │ ┌ SQL editor ───────────── Esc: leave editor ┐ ┌ Your result ─── Stale? ──┐ │ 142
 │ │ 1  SELECT name, price                      │ │ mark   │ name    │ price │ │
 │ │ 2  FROM products                           │ │ ✓ match│ Cola    │   150 │ │
 │ │ 3  WHERE category = 'drink'                │ │ + extra│ Tea     │   210 │ │
 │ │ 4  _                                       │ │ …                         │ │
 │ │                                            │ │ 3 ✓ · 1 + extra · 0 − miss│ │
 │ │                                            │ ├ Target ──────────────────┤ │
 │ │                                            │ │ name    │ price           │ │
 │ │                                            │ │ Cola    │   150           │ │
 │ └────────────────────────────────────────────┘ │ …                         │ │
 │ [ Run  Ctrl+Enter ]      ⟷ ≥24px     [■ Submit Ctrl+Shift+Enter ]       │ │
 │ ┌ Shelves (schema) ─────────────────── [−] ┐ ┌ receipt ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲ ┐ │
 │ │ ▭ products: [I id] [T name] [I price]…   │ │ ≈ Looks right on today's  │ │
 │ │ ▭ sales: …                               │ │   data (not checked)      │ │
 │ └──────────────────────────────────────────┘ └───────────────────────────┘ │ 704
 └──────────────────────────────────────────────────────────────────────────────┘ 720
```

(Tab cluster shown as a 2 × 2 grid at `ui_scale` 1.0–1.25; Back Room tab from
Chapter 2 makes it 2 × 3 → see Tab cluster below. "◂Shift" = the shift /
chapter-list button. Not to scale.)

### Component Inventory

| Zone | Component | Type | Content | Interactive | Pattern |
|---|---|---|---|---|---|
| Z1 | Speaker sprite | Pixel art | Current speaker | No (decorative, AccessKit hidden) | — |
| Z1 | Bubble / request ticket | Paper text panel | Request (ticket, "REQUEST 1-5 · title" tab) or reaction (rounded, name tag); paging "1/2 ▸" | Yes (click / Enter / Space pages) | IP-13 |
| Z1 | Inline offer buttons | Buttons in bubble | Try it / Later; Leave it for Kenji / Keep trying; Day One "Ever used SQL?" choices | Yes | IP-14 |
| Z1 | Shift button | Tab | "Shift" — opens the shift screen / chapter list | Yes | IP-01 |
| Z1 | Log tab | Tab | "Log" (Ctrl+L) | Yes | IP-16 |
| Z1 | Hint tab | Tab | "Hint" + state word: "locked" / "new" / "open" (Ctrl+H); hidden in challenge mode | Yes | IP-10, IP-15 |
| Z1 | Manual tab | Tab | "Manual" + "new" (Ctrl+M) | Yes | IP-10, IP-15 |
| Z1 | Back Room tab | Tab | "Back Room" (Ctrl+B), Chapter 2+ | Yes | Alpha |
| Z1 | Ticket slot | Paper tickets | Side requests and unanswered offers (dimmed in challenge mode) | Yes | IP-14 |
| Z2 | Editor header | Label row | "SQL editor", challenge rule tag when active, "Esc: leave editor" while focused | No | IP-03 |
| Z2 | Editor | `CodeEdit` | Draft; line numbers; highlighting; ghost text (Guided) | Yes | IP-06 |
| Z2 | Run button | Outlined button | "Run  Ctrl+Enter" | Yes | IP-04 |
| Z2 | Submit button | Filled indigo button | "Submit  Ctrl+Shift+Enter" | Yes | IP-04 |
| Z2 | Schema shelf | Collapsible list | Shelf label per table; column chips with type letter | Yes | IP-05 |
| Z3 | Your result grid | Grid | Last Run result with mark gutter, count line; "Stale — run again" tag | Yes (scroll, cell cursor) | IP-11 |
| Z3 | Target grid | Grid | Reference on visible data | Yes (scroll, cell cursor) | IP-11 |
| Z3 | Feedback receipt | Paper panel | Tally note / error strip / FAIL note / PASS stamp + "✓ ACCEPTED" / TOO_MANY_ROWS text / "checking…" | Partial (Leave it for Kenji button) | IP-08, IP-09 |
| Z3 | "↷ Leave it for Kenji" | Secondary text button | Appears on the receipt of an exhausted request (Progression UI Req 2) | Yes | IP-14 |
| Z3 | Side panel (Manual / Hint) | Overlay over the two grids | Ring binder or folded note | Yes | IP-15 |
| Overlay | Message log | Full overlay + scrim | Every line of the shift | Yes | IP-16 |
| Overlay | Coach mark | Ring + tag + "Got it" | Guided marks on Run, Submit, schema shelf, Manual tab | Yes | IP-17 |
| Overlay | Minimal options panel | Panel | "Coach marks", "Reduced motion" toggles | Yes | IP-21 |
| Corner | Playtest label | Label | "● Recording playtest" / "Recording stopped" (playtest builds) | No | IP-07 |

**Tab cluster at higher `ui_scale`** (art bible 7.1; resolves the "≥ 1.5" hand-off):
- 1.0–1.25: 2 columns × 2 rows (3 rows with Back Room), each tab one word + state word.
- ≥ 1.5: tabs show short words only ("Shift", "Hint", "Manual", "Back Room");
  each tab's state (locked / new) is a 6 px indigo dot + the state word in its
  accessible description; the **Log** entry moves into the Shift button's menu
  so at most 3 tabs (4 with Back Room) are visible; the cluster grows leftward
  over the shelf zone and the bubble shrinks to match — never below 360 px wide
  and never over the speaker niche (provisional; verify by capture at 1.5 and
  2.0 — Open Question 3). Ctrl+L still opens the log at every scale.

**Locked Hint** (resolves Hint OQ7, developer decision): the tab reads
"Hint · locked"; Ctrl+H or clicking opens the hint panel, which shows the
condition ("Available after 2 wrong answers or 3 minutes" — from the puzzle's
thresholds) and the progress so far; the same sentence is the tab's accessible
description.

**Hint panel slot** (resolves workbench OQ6, developer decision): the hint
panel opens in the **same slot as the Manual** — over the two grids in the right
column; one side panel at a time. **The feedback receipt stays visible** below
the panel (Claude decision), so the player can read the FAIL note and the hint
together.

**No dedicated visible-data view** (resolves workbench OQ7, developer decision):
the player reads today's shelf by running a query (`SELECT * FROM products`);
`visible_rows_max` stays 30 (Puzzle Definition), so a full table scrolls in
the result grid. Revisit only if the zero-SQL playtest shows players stuck on
"what is in the table" (Open Question 2).

---

## States & Variants

| State / Variant | Trigger | What Changes |
|---|---|---|
| Loading | Boot verification (≈ 0.6 s) | Full paper screen "Opening the store…", input blocked, no spinner (gap in IP library) |
| Briefing | Shift start | Bubble shows Tanaka's `briefing` (paged); editor read-only, empty, placeholder "The first order comes after the briefing"; focus on the bubble (Enter/Space pages) |
| Opening question (Day One) | After the first briefing | Bubble: "Ever used SQL before?" with two inline choices; **focus moves to the first choice** (nothing else to do yet); then 1-1 opens |
| Request open (default) | Request opens | Ticket bubble; editor focused with the request's draft (or prefill on 1-1); grids empty with "Run to see your result" in `ink_muted`; Target shown |
| Guided (Day One Morning) | Onboarding rule 7 | Coach marks per rule 7a; ghost text on 1-3; hint/manual "new" suppressed during the suppression window |
| Checking | No result 200 ms after Run/Submit | Receipt shows "checking…" (static) |
| Run result | Run returns `ok` | Your result filled with marks + count line; tally note "≈ Looks right on today's data (not checked)" when it matches |
| Stale | Draft edited after a Run | "Stale — run again" header tag; marks/tints hidden; grid text `ink_muted` (no opacity, no italic) |
| Run / Submit error | Sandbox error | Jammed register strip "⚠ …" with SQLite text (mono); error token wavy-underlined in the editor; grids keep the last result marked Stale |
| TOO_MANY_ROWS | Visible run above `grader_row_cap` | Receipt strip text "{grader_row_cap}+ rows — too many to compare" (workbench rule 13); no grid fill |
| Submitting | Submit pressed | Run and Submit disabled with "checking…"; typing stays live |
| FAIL | Grader FAIL | Sticky note "? Not accepted" + level-1 statement on the receipt; reaction in the bubble |
| PASS | Grader PASS | Stamp lands on the receipt + "✓ ACCEPTED"; pass reaction + optional challenge offer in the bubble |
| Exhausted | Hint `exhausted` → Kenji's offer | Offer in the bubble (IP-14); after it, "↷ Leave it for Kenji" on the receipt |
| UNAVAILABLE | Content error at Submit | Kenji's line; the request may be left (Progression rule 7a); no raw error text |
| Challenge mode | "Try it" | Rule tag in the editor header ("Dare: no `IN`") + live check "✓ rule met" / "☆ not yet"; Hint tab hidden and the hint area reads "No hints for dares."; side tickets dimmed; "Leave challenge" button in the editor header |
| Side panel open | Ctrl+H / Ctrl+M | Panel over the grids; receipt visible |
| Log open | Ctrl+L | Scrim + log; workbench inert until closed |
| Options open | Shift button → "Options" | Minimal options panel (IP-21) |
| `ui_scale` ≥ 1.5 | Setting (VS; MVP default 1.0) | Grids scroll horizontally under frozen header + gutter; tab cluster variant; bubble pages sooner |
| Chapter 2+ | Chapter | Back Room tab present; "Back Room — practice data" label while active (Alpha) |

---

## Interaction Map

| Component | Action | Input | Immediate feedback | Outcome |
|---|---|---|---|---|
| Editor | Type / edit | Keys, IME | Text; highlighting | Draft updated; grids go Stale; `edit_burst` coalesced |
| Editor | Leave | Esc | Focus ring on the editor frame | Tab moves to the next control (IP-03) |
| Editor (Guided 1-3) | Accept ghost | Tab in empty editor | Ghost becomes text | Draft = shape example |
| Run | Run query | Ctrl+Enter / click | "checking…" only if > 200 ms | Result grid + marks + tally note or error; `run` event; a newer Run supersedes an older one (IP-09) |
| Submit | Submit | Ctrl+Shift+Enter / click | Buttons disabled, "checking…" | Verdict on the receipt; reaction in the bubble; `submit` event (grader) |
| Schema chip | Insert name | Click / Enter | `selection` fade on inserted text | Name at the caret, with the auto-separator rule (workbench rule 3) |
| Schema shelf | Collapse / expand | Click [−] / Enter on header | Shelf folds | Editor gains height |
| Bubble | Page / complete reveal | Click; Enter / Space with strip focus | Next page | `line_shown` per line |
| Inline offer | Choose | Tab + Enter / click | Choice highlighted | Challenge starts / later; skip / keep trying |
| Hint tab | Open / close | Ctrl+H / click | Panel appears in place | `hint_open {step}`; locked → condition text |
| Manual tab | Open / close | Ctrl+M / click | Binder appears | `manual_open {page}`; Copy example → IP-05, `manual_copy` |
| Log tab | Open / close | Ctrl+L / click | Scrim + log | `log_opened` |
| Shift button | Open shift screen / chapter list / options | Click / Enter | Screen change | Draft kept |
| Grid | Move cell / scroll | Arrows, PgUp/PgDn, Home/End, wheel | Focus ring on cell | — |
| Coach mark | Dismiss | "Got it" / Esc with mark focused | Mark removed | `mark_dismissed`; Done on target action → `mark_done` |
| Panes | Cycle | F6 / Shift+F6 | Pane focus bar | Focus moves (IP-02) |
| Leave it for Kenji | Skip request | Click / Enter | Kenji's accept line | `request_skip`; next request or clock-out |
| Leave challenge | Exit dare | Click / Enter | — | Main request (CC rule 6a) |
| Playtest F9 | Help marker | F9 (facilitator) | Note field | `help_given`, `help_note` (ADR-0004) |

---

## Data Requirements

| Data | Source (owner) | Read / write |
|---|---|---|
| Current request, speaker, line, kind, pages | Request & Reaction Dialogue | Read |
| Draft per puzzle, last Run result, last verdict, Stale flag | WorkbenchController (Workbench) | Read/write |
| Puzzle title, schema, visible dataset, prefill, ghost text | PuzzleRepository (Puzzle Definition), StringTable | Read |
| Target result (visible) | Reference cache (ADR-0003) via grader | Read |
| Run result + match bit | SqlSandbox + `run_match` (grader) | Read |
| Verdict, cause, level, statement key | Hidden-Data Grader | Read — never missing/extra counts or hidden rows (grader rule 11) |
| Hint state (locked/ready/open/exhausted), thresholds | Hint System | Read |
| Manual pages and "new" | Store Manual | Read |
| Challenge mode, rule, live check | Constraint Challenges (tokens from `tokenize`) | Read |
| Open request, Restart, shift state | Shift & Chapter Progression | Read (signals) |
| Coach marks state, suppression window | Onboarding | Read |
| `ui_scale`, fonts, reduced motion, coach marks toggle | GameConfig / options (session-only at MVP) | Read |

---

## Events Fired

All through `EventBus.emit_event` with the canonical names of `playtest-log.md`
rule 4 (ADR-0004). Owned by the Workbench: `run {sql, dataset, ok, error_kind,
rows, match, build_message?}` and `edit_burst {chars_changed}`. Triggered from
this screen but owned elsewhere: `submit` (grader), `hint_open` (Hint),
`manual_open` / `manual_copy` (Manual), `challenge_try` / `challenge_later` /
`challenge_start` (Challenges), `request_skip` (Progression), `sql_question` and
`mark_*` (Onboarding), `line_shown` / `log_opened` / `line_skipped` (Dialogue).
Gameplay reactions use typed signals, never the bus (ADR-0004 §2).

---

## Transitions & Animations

Per art bible 7.6 and IP rules: Run result, tally note, FAIL note, error strip,
panels and "new" indicators appear in place (0 ms); PASS stamp 180 ms and star
hanko +60 ms; log scrim 120/90 ms; schema insert fade 200 ms; coach-mark settle
200 ms once; NPC step-in 200 ms stepped; shift palette crossfade 300 ms (strip
only). Under reduced motion every one is its final state. Nothing loops or
blinks; the caret is steady. No transition delays input.

---

## Input Method Completeness Checklist

- [x] Every action has a keyboard path (Interaction Map) and a mouse path, except
      typing and F9 (keyboard only by nature).
- [x] Every focusable control shows the focus ring; hover never draws indigo.
- [x] F6 pane order covers every region; Esc precedence defined (IP-02, IP-03).
- [x] No hold, no rapid input, no timed input.
- [x] Chord labels shown on controls and update with remapping (VS).
- [ ] IME composition committed before Run — verify (workbench OQ4, ADR-0008).
- [ ] `CodeEdit` does not swallow Ctrl+Enter / F6 — verify (IP library OQ1).
- [x] Gamepad / touch: not supported (accessibility requirements, Known Intentional Limitations).

---

## Accessibility

Tier: Standard + reduced motion + full keyboard (`design/accessibility-requirements.md`).
- Text sizes and contrast per art bible 4.4 / 7.9; base fonts editor 18 / tables
  16 / bubble 18; **base range narrowed to 14–24** (developer decision; resolves
  workbench OQ9: 24 × 2.0 = 48 px max effective).
- Glyph + word on every mark, verdict, tab state and live check (IP-07).
- Run vs Submit separation ≥ 24 × `ui_scale` px; minimum target 32 × `ui_scale` px.
- AccessKit (best effort): landmarks for the five panes; grid role with headers;
  verdict and error in a polite live region; strip art hidden; the bubble line is
  announced whole on arrival (typewriter is visual only).
- Reduced motion toggle in the minimal options panel at MVP.

---

## Localization Considerations

- All player-facing text from StringTable ids (dialogue rule 9); no literals in
  UI code (RD-12 scan).
- Bubble paging is measured per language and `ui_scale`; tabs and buttons must
  fit +40% text length (German-style) at 1.0 — the tab cluster variant (≥ 1.5)
  is the fallback.
- Data values and SQL keywords are never translated; CJK fallback fonts bundled.
- Chord labels use the platform key names (Ctrl, Shift, Enter).

---

## Acceptance Criteria

- **UX-QW-01 [UI]** At 1280×720, `ui_scale` 1.0: all zones Z1–Z3 visible without overlap; editor ≥ 300 px tall; each grid shows 7 rows; capture retained.
- **UX-QW-02 [UI]** At `ui_scale` 1.5 and 2.0: no clipped text; grids scroll horizontally under frozen header + gutter; tab cluster variant; bubble ≥ 360 px wide; captures retained.
- **UX-QW-03 [UI]** Keyboard only: Day One 1-1…1-3 completed (opening question, coach marks, Run, Submit, Manual, Hint) without the mouse; focus visible at every step.
- **UX-QW-04 [UI]** Manual and Hint open in the same slot over the grids; opening one closes the other; the feedback receipt stays visible; neither covers the editor or strip.
- **UX-QW-05 [UI]** Locked Hint tab reads "Hint · locked"; Ctrl+H shows the unlock condition with the puzzle's thresholds.
- **UX-QW-06 [UI]** A FAIL with a 3-line statement grows the receipt and shrinks Target to ≥ 2 rows; Your result keeps its height.
- **UX-QW-07 [Logic]** `H_table` uses the logical viewport height: at 1280×800 logical (16:10, `expand`), `rows_visible` at 1.0 = floor((0.40 × (800 − 152) − 48) / 24) = 8.
- **UX-QW-08 [UI]** Reduced motion on: stamp, coach ring, typewriter, NPC step-in and shift crossfade appear in final state (frame capture).
- **UX-QW-09 [UI]** An exhausted request shows "↷ Leave it for Kenji" on the receipt after the offer; Enter on it skips.
- **UX-QW-10 [UI]** Challenge mode: rule tag + live check glyph + word in the editor header; Hint tab hidden; "No hints for dares." in the hint area; side tickets dimmed.

---

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | No player journey map — arrival states inferred from GDDs | ux-designer | Before `/ux-review` |
| 2 | Do zero-SQL players need a data view after all (workbench OQ7, decided "no")? | ux-designer | Zero-SQL playtest |
| 3 | Tab cluster at ≥ 1.5: does moving Log into the Shift menu read well, or should tabs scroll? Verify by capture | ux-designer + art-director | First strip/workbench build |
| 4 | Feedback receipt height at 2.0 with a long FAIL statement — enough with Target at 2 rows? | ux-designer | Capture at 2.0 |
| 5 | Shift screen, payslip and chapter list need their own specs (Progression UX Flag) | ux-designer | Before Progression epics |
