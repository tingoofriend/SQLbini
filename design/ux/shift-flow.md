# UX Spec: Shift Flow (Shift Screen, Payslip / End of Day, Chapter List)

> **Status**: In Design — revised after /ux-review 2026-10-16, re-review pending
> **Author**: tingoofriend + Claude (`/ux-design shift-flow`, autonomous; revision decisions by the developer, 2026-10-16)
> **Last Updated**: 2026-10-16
> **Journey Phase(s)**: between shifts (clock-out, start of a shift), returning to a skipped request, session end at MVP
> **Platform Target**: PC (Windows, Linux), 1280×720 logical canvas; keyboard + mouse, keyboard-first (no gamepad, no touch — `technical-preferences.md`)
> **Template**: UX Spec
> **Sources**: `design/gdd/shift-and-chapter-progression.md` (owner; rules 6–13, States, UI Req 1–6, PR-11/13/15/16/19), `constraint-challenges.md` (rules 5, 6–6c; UI Req 3–4), `onboarding-first-shift.md` (options panel, UI Req 4), `design/art/art-bible.md` 3.3, 4.4, 4.5, 7; `design/ux/interaction-patterns.md`; `design/ux/query-workbench.md`; `design/accessibility-requirements.md`; ADR-0006, ADR-0007, ADR-0010

---

## Purpose & Player Need

Three small paper screens frame the work. The **payslip** closes a shift with a
calm, rewarding summary and a natural place to stop; the **shift screen** is
where a shift starts (or resumes after *Stop for today*); the **chapter list**
lets the player see the whole day and return to any request — replay a pass,
reopen a skipped one, try a dare, or restart. The player arrives wanting to know
"how did that shift go, and what's next?" or "let me go back to that one".
Without them the player would have no sense of progress and no way back to a
skipped request (Progression rules 8, 12).

---

## Player Context on Arrival

- **Payslip:** just finished the last main request of a shift (PASS, skip or
  unavailable) — relieved, maybe proud; the counter strip has just shown the
  pass / `skip.accept` hold.
- **End of day:** finished the Closing shift; the day is over.
- **Shift screen:** chose *Stop for today* (MVP: stays in the session), came back
  from End of day, or opened it from the strip's Shift menu to look around.
- **Chapter list:** curious or determined to return to a request; never
  pressured.
- *Assumption:* no player journey map (Open Question 1).

---

## Navigation Position

Workbench ⇄ these screens. All replace the **work surface only** (the area under
the zone rule); the counter strip stays on top, so the store, the time of day
and Tanaka's briefing remain continuous (Claude decision).

```
Workbench ──(last main resolved, hold ends)──► Payslip ──Next shift──► Shift briefing (strip) ──► Workbench
                                                  │                         ▲
                                                  └──Stop for today──► Shift screen ──Continue──┘
Workbench ──Shift menu──► Shift screen / Chapter list / Options (on the shift screen)
Shift screen ──Chapter list──► Chapter list ──Resume / Replay / Reopen / Try the dare──► Workbench
      ▲                              │ Restart (inline confirm, stays on the list)
      └──────────── Back (Esc) ──────┘
After the Closing shift: Payslip ──End of day──► End of day ──Back to the store──► Shift screen (Chapter complete)
```

**Shift button:** the strip's Shift button is the **IP-22 Strip menu**
(developer decision 2026-10-16; same definition as `query-workbench.md`) — not
re-specified here. In short: items **Shift screen**, **Chapter list**,
**Options**, and **Log** when `ui_scale` ≥ 1.5 (plus Back Room per IP-22);
opened by click, Enter or `Ctrl+Shift+S`; in challenge mode disabled with the
visible words "Leave the dare first" (the player leaves with the editor
header's *Leave challenge*, CC rule 6a). IP-22 also fixes this spec's
paper-screen behaviour: *Options* opens the shift screen with the options panel
open, the current screen's item reads "(here)", and the button is inert on the
payslip and End of day.

---

## Entry & Exit Points

| Entry Source | Trigger | Player carries this context |
|---|---|---|
| Workbench | Last main request of the shift resolved; its pass or `skip.accept` hold ends (`hold_finished`) → Progression clocks out → `shift_clocked_out` | Shift results |
| Workbench | Every main of the shift withheld → clock-out at once (Progression edge case, PR-13) | Shift results + note |
| Workbench | Shift menu (IP-22; `Ctrl+Shift+S`) → Shift screen / Chapter list / Options | The shown request (kept) |
| Payslip | *Stop for today* | Session progress (MVP: kept until quit) |
| End of day | *Back to the store* | Chapter complete |
| Shift screen | *Chapter list* | — |

| Exit Destination | Trigger | Notes |
|---|---|---|
| Next shift briefing (workbench, strip bubble) | Payslip *Next shift* / shift screen *Continue* | First main request opens when the briefing ends (rule 11, `briefing_finished`) |
| End of day | Payslip *End of day* after the Closing shift | Replaces *Next shift* (rule 6) |
| Workbench (a request) | Chapter list Resume / Replay / Reopen | Keeps the request's draft, counters, hints (rule 12) |
| Workbench (challenge mode) | Chapter list *Try the dare* | CC rule 6a: returns to the open main request, or to the shift screen when none |
| Workbench (shown request) | Shift screen *Back to work* | Nothing changes |
| Quit | Window close | MVP: progress lost — stated by the shift screen's MVP note (PR-19) |

---

## Layout Specification

### Information Hierarchy
1. **Payslip:** each request's outcome (glyph + word) → dares cleared → wage → the two choices.
2. **End of day:** chapter complete → star → requests left for later → dares cleared after the final clock-out → the one button.
3. **Shift screen:** shift name + requests done / total → the next action → chapter list → options.
4. **Chapter list:** shift groups → each request's state and dare mark → row actions.

### Layout Zones
Work surface = x 16–1264, y 142–704 (as the workbench). Each screen is one
centred paper object on the `paper` frame; nothing else on the work surface
except the options panel (below).

| Screen | Object (art bible 3.3) | Rect at `ui_scale` 1.0 | Grows at higher `ui_scale` |
|---|---|---|---|
| Payslip | Receipt, wider; zigzag bottom; wage under a dashed tear rule | 480 × up to 540, centred | Taller; the rows area becomes a scroll container above the buttons (buttons never scroll) |
| End of day | Same receipt form | 480 × up to 540 | As above |
| Shift screen | Paper card with the shift name as title | 560 × 360, centred | Taller |
| Options panel | Second paper card beside the shift screen card (the pair centred together, 16 px apart) | 320 × up to 360 | At `ui_scale` ≥ 1.5 the panel replaces the shift screen card in place until closed |
| Chapter list | Clipboard (clip at top centre), shift-by-shift checklist | 720 × 540, centred | The rows area scrolls; actions stack under the focused row |

### ASCII Wireframe
```
Payslip (Afternoon)                         Chapter list — Day One
┌───────────────────────────────┐          ┌──────────────── ◖clip◗ ──────────────────┐
│ PAYSLIP · Afternoon           │          │ Day One · 2026-03-02       not starred yet│
│ ──────────────────────────────│          │ Morning                                  │
│ 1-4 Cheap snacks   ✓ passed   │          │  1-1 First order   ✓ passed   [Replay]   │
│ 1-5 Drinks < ¥200  ↷ left for later      │  1-2 …             ✓ passed   [Replay]   │
│ 1-6 …              ✓ passed   │          │ Afternoon                                │
│ 1-7 …              unavailable│          │  1-5 Drinks < ¥200 ↷ left for later      │
│ S-1 HQ email       ✓ passed   │          │                    [Reopen] [Restart]    │
│ Dares cleared                 │          │  1-6 …  ✓ passed  ☆ dare available       │
│   ★ 1-4 Cheap snacks          │          │         [Replay] [Try the dare] [Restart]│
│ - - - - - - - - - - - - - - - │          │  S-1 HQ email (side) open   [Resume]     │
│ Wage                 ¥3,000   │          │ Closing                                  │
│ [■ Next shift] [Stop for today]          │  1-8 …             locked                │
└╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱┘          │                       [Back  Esc]        │
                                            └──────────────────────────────────────────┘
```
(Only ✓ ↷ ★ ☆ appear as glyphs; "locked", "open" and "unavailable" are words
only — IP-07. The payslip shows ★ only in the *Dares cleared* block.)

### Component Inventory

| Screen | Component | Content | Interactive | Pattern |
|---|---|---|---|---|
| Payslip | Title | "PAYSLIP · {shift}" (stamp-style label) | No | — |
| Payslip | Request rows | id, short title, outcome: "✓ passed" / "↷ left for later" / "unavailable" (word only); side requests listed after mains | No (inside the scroll container) | IP-07 |
| Payslip | Dares cleared | Heading "Dares cleared" + one line per challenge cleared **during this shift**, including challenges on earlier shifts' requests ("★ {id} {title}") — fed by `challenge_resolved` (CC rule 6b, Progression rule 10). Absent when none | No | IP-07 |
| Payslip | All-unavailable note | When every main of the shift was withheld: "None of this shift's requests could be checked today. The store has noted it." (PR-13) | No | — |
| Payslip | Wage line | "Wage ¥3,000" (content value, flavour only) under a dashed tear rule | No | — |
| Payslip | Buttons | *Next shift* (primary, focused) / *Stop for today*; after Closing: *End of day* only (developer decision 2026-10-16) | Yes | IP-19 |
| End of day | Summary | "✓ Chapter complete"; star "★ starred" or the words "not starred yet"; requests left for later (count + list + "Reopen them from the chapter list."); "Dares cleared" for clears after the final clock-out (CC rule 6b) | No | IP-07 |
| End of day | Button | *Back to the store* → shift screen | Yes | IP-19 (one choice) |
| Shift screen | Title + progress | "Day One · {shift}" + "{done} / {total} requests done" (counting rule below); or "Day One · Chapter complete" | No | — |
| Shift screen | Primary action | *Continue* / *Back to work* / *Chapter list* per the precedence rule below | Yes | IP-19 |
| Shift screen | Secondary | *Chapter list* (when not primary), *Options* (IP-21 panel), *Back to work* (when not primary) | Yes | IP-21 |
| Shift screen | MVP note | "Progress is kept until you close the game — saving comes in a later build." (Progression rule 6, PR-19) | No | — |
| Chapter list | Header | Chapter name + date; "★ starred" or the words "not starred yet" | No | IP-07 |
| Chapter list | Shift groups | Morning / Afternoon / Closing headings | No | — |
| Chapter list | Request rows (mains, then that shift's side requests marked "(side)") | id, title, state: "locked", "open", "✓ passed", "↷ left for later", "unavailable"; dare mark "★ dare cleared" / "☆ dare available"; "(current)" on the shown request | Yes (rows focusable) | IP-20 |
| Chapter list | Row actions | see Row actions table | Yes | IP-20, IP-18 |
| Chapter list | Back | *Back* (Esc) → shift screen | Yes | IP-03 |

**Row actions** (Progression rules 7a, 8, 12, 12a; CC rules 5, 6a):

| Row state | Actions |
|---|---|
| locked | none (row focusable, reads "locked") |
| open (main or side) | *Resume*, *Restart* |
| ✓ passed | *Replay*, *Try the dare* (only with "☆ dare available"), *Restart* |
| ↷ left for later | *Reopen*, *Restart* |
| unavailable — left under rule 7a | *Reopen* (a later PASS makes it passed) |
| unavailable — withheld by the content check | none; accessible description "can't be opened in this build" |

Side requests are never left for later (Progression States).

**Glyph note (closes Open Question 2):** "unavailable", "locked" and "open" are
words only, in `ink_muted` for "unavailable" — no en dash, because no glyph for
it exists in art bible 3.3 and a dash would read as "− missing row" (IP-07: one
glyph, one meaning). The chapter "not starred yet" is likewise words only (no
"—"). The GDD's "– unavailable" wording (visual requirements, PR-11) is a GDD
wording follow-up, not changed here.

---

## Shift Screen Rules

**Counting rule for "{done} / {total} requests done":** `total` = main requests
of the named shift (withheld ones included); `done` = mains passed, left for
later or unavailable (withheld included). Side requests are not counted.

**Which shift is named:** the shift `InProgress`; when the last started shift is
`ClockedOut`, the next shift ("{done}" = 0); after the Closing shift,
"Chapter complete".

**Primary action precedence** (first match wins; the others stay as secondary
buttons in the order listed):
1. Chapter complete → *Chapter list* primary; *Back to work* secondary only if a request is shown in the workbench. No *Continue*, no *Stop for today* (developer decision 2026-10-16).
2. Last started shift `ClockedOut` → *Continue* primary (starts the next shift's briefing), even if a request was reopened from the chapter list; *Back to work* secondary when a request is shown.
3. Shift `InProgress` → *Back to work* primary (returns to the shown request, or to the briefing if it is still running).

---

## States & Variants

| State / Variant | Trigger | What Changes |
|---|---|---|
| Payslip — mid-chapter | Clock-out of Morning / Afternoon | *Next shift* primary, *Stop for today* secondary |
| Payslip — last shift | Clock-out of Closing | *End of day* is the only button; strip sign flips to "Closed" |
| Payslip — no dares cleared | No `challenge_resolved(cleared)` this shift | *Dares cleared* block absent |
| Payslip — all mains skipped | Every main left for later | Lists them as left for later; no scolding line |
| Payslip — all mains withheld | Content check withheld every main | Clock-out at once; all-unavailable note above the wage (PR-13) |
| End of day — starred | All mains passed (unavailable excluded) | "★ starred"; ★ stamp lands on the chapter card (180 ms; final state under reduced motion) |
| End of day — not starred | Some mains left for later | "not starred yet" + the left-for-later list with the Reopen hint |
| Shift screen — after Stop for today | *Stop for today* | Names the next shift; *Continue* primary; MVP note |
| Shift screen — mid-shift | Shift menu from the workbench | *Back to work* primary; progress count |
| Shift screen — ClockedOut, request reopened | Reopen/Replay from the list after a clock-out | *Continue* primary, *Back to work* secondary (precedence 2) |
| Shift screen — chapter complete | After End of day | "Day One · Chapter complete", star line; *Chapter list* primary |
| Shift screen — options open | *Options* or Shift menu → Options | Options panel beside the card (replaces it at ≥ 1.5); focus in the panel |
| Chapter list — challenge mode | — | Not reachable: Shift button disabled with "Leave the dare first" (IP-22) |
| Chapter list — Restart confirm | Restart on a row with a non-empty draft | Inline confirm (IP-18) |
| Chapter list — withheld puzzle | Content check failed | Row "unavailable", no actions |
| Loading / error | — | None: every screen is built synchronously from Progression state on its signal; no async fetch, no loading state. A missing string id follows ADR-0007 (dev `[id]`, release generic) |
| `ui_scale` ≥ 1.5 | Setting | Receipts taller with a scrolling rows area; chapter list scrolls; row actions stack under the row; options panel replaces the card |

---

## Focus Order, Strip Controls and Esc

On these screens there are two focus regions, **Paper** (work surface) and
**Request** (the strip), per IP-02's paper-screen rule: F6 / Shift+F6 move
between them; Tab cycles inside the current region and wraps. Focus never
starts in the strip. Esc follows IP-03 (steps 4–6 cover these screens).

| Screen | Focus on arrival | Tab order (paper) | Esc |
|---|---|---|---|
| Payslip | *Next shift* (or *End of day*) | Primary → *Stop for today* → rows scroll container (Tab stop only when it scrolls) | Nothing (IP-19) |
| End of day | *Back to the store* | Button → summary scroll container (when it scrolls) | Nothing |
| Shift screen | Primary action | Primary → secondary buttons in precedence order → *Chapter list* → *Options* | *Back to work* if a request is shown; otherwise nothing |
| Options panel | First toggle | Toggles (IP-21) | Closes the panel; focus returns to *Options* (or to the Shift button when opened from the menu) |
| Chapter list | The "(current)" row, else the first non-locked row | Focused row → its actions → *Back* | Precedence (IP-03): inline confirm open → Cancel; else → shift screen, focus on its *Chapter list* button |

**Scroll containers (keyboard reach at `ui_scale` 2.0):** the payslip / End of
day rows area is a focusable scroll container: Up/Down scroll a line,
PageUp/PageDown a page, Home/End to the ends; focus ring around the area. In
the chapter list, rows are focusable: Up/Down move a row and scroll it into
view; PageUp/PageDown move a page of rows; Home/End go to the first/last row.

**Strip controls per screen:**

| Strip control | Payslip / End of day | Shift screen / Chapter list |
|---|---|---|
| Bubble | Empty (no line) until the next briefing; nothing to page | Shows the shown request's ticket when one exists, else empty |
| Shift button / menu (IP-22) | Inert (the receipt needs an answer); `Ctrl+Shift+S` does nothing | Active; the current screen's item disabled "(here)" |
| Hint, Manual tabs (Ctrl+H, Ctrl+M) | Inert | Inert (no results column; they act again on the workbench) |
| Log tab / Ctrl+L | Active (IP-16 overlay; focus returns) | Active |
| Side-request tickets | Visible, inert | Active: activating one = *Resume* on that side request |
| Unanswered dare-offer ticket | Removed at clock-out — the offer expires as Later (CC rule 6); the dare stays "☆ dare available" in the chapter list | — |

Inert controls are skipped by Tab and show no hover; they keep their look.

---

## Interaction Map

| Component | Action | Input | Immediate feedback | Outcome |
|---|---|---|---|---|
| Payslip *Next shift* | Activate | Enter (focused on arrival) / click | — | Progression starts the shift → `shift_started` → briefing in the strip; workbench |
| Payslip *Stop for today* | Activate | Tab + Enter / click | — | Shift screen (MVP) |
| Payslip *End of day* | Activate | Enter / click | — | End of day receipt |
| End of day *Back to the store* | Activate | Enter / click | — | Shift screen (chapter complete) |
| Shift screen *Continue* | Activate | Enter / click | — | `shift_started` → briefing; workbench |
| Shift screen *Back to work* | Activate | Enter / Esc / click | — | Workbench, unchanged |
| Shift screen *Chapter list* | Activate | Enter / click | — | Chapter list |
| Shift screen *Options* | Activate | Enter / click | Panel appears | Minimal options panel (IP-21) |
| Chapter list rows | Move | Up / Down / PageUp / PageDown / Home / End | Focus ring on row | — |
| *Resume* / *Replay* / *Reopen* | Activate | Tab into row + Enter / click | — | Workbench with that request (`request_shown`) |
| *Try the dare* | Activate | Tab into row + Enter / click | — | Constraint Challenges starts challenge mode (start source: chapter list, CC rule 5); return per CC rule 6a |
| *Restart* | Activate | Tab into row + Enter / click | Inline confirm if the draft is non-empty (Cancel focused) | `ShiftProgression.request_restart(puzzle_id)`; stays on the list, focus back on the row's *Restart* |
| Confirm *Cancel* | Cancel | Enter / Esc / click | Confirm closes | Nothing changes; focus back on *Restart* |
| *Back* | Leave | Esc / click | — | Shift screen |
| Shift button | Open menu | Enter / `Ctrl+Shift+S` / click | Menu under the button, focus on its first item (IP-22) | Chosen screen |
| Shift button (challenge mode) | — | — | Disabled, shows "Leave the dare first" on its second line; stays focusable; chord does nothing (IP-22) | — |

Opening a request other than the next one from the chapter list expires an
unanswered dare offer (CC rule 6) — Constraint Challenges handles it on
`request_shown`.

---

## Data Requirements

| Data | Source (owner) | Read / write | Update trigger | When missing |
|---|---|---|---|---|
| Chapter, shifts, request ids / titles / order, side flag | PuzzleRepository (Puzzle Definition) | Read | Static per session | Withheld request → "unavailable" row |
| Request states, shift state, chapter complete / starred | Shift & Chapter Progression | Read | On `request_opened`, `shift_started`, `shift_clocked_out`, state changes; screens rebuild when shown | — |
| Dare marks and per-shift clears | Shift & Chapter Progression, recorded from `challenge_resolved` (owner of challenge state: Constraint Challenges) | Read | On `challenge_resolved(cleared = true)` | No challenge → no mark; no clears → block absent |
| Wage per shift | Puzzle Definition (chapter content, PR-12: display only) | Read | Static | Line hidden (content verifier should reject) |
| Draft-empty for Restart | Workbench via the `draft_is_empty` Callable (ADR-0010 §4, injected by the composition root — ADR-0006) | Read | Queried when Restart is activated | Treated as non-empty (confirm shown) |
| Text | StringTable (ADR-0007) | Read | — | ADR-0007 missing-id rule |

No UI element owns game state.

---

## Events and Signals

Per ADR-0010; this spec's screens emit no gameplay signals themselves.

- **Clock-out:** Dialogue `hold_finished(line_kind, puzzle_id)` for the last
  main's pass or `skip.accept` hold → Progression clocks out →
  `shift_clocked_out(shift_id)` → payslip shown.
- **Next shift / Continue:** Progression → `shift_started(shift_id)` → Dialogue
  briefing → `briefing_finished(shift_id)` → Progression opens the first main
  (`request_opened`, state) and shows it (`request_shown`); side requests open.
- **Resume / Replay / Reopen:** Progression emits `request_shown(puzzle_id, kind)`
  (display only; `request_opened` is a state change to `Open` and is not
  emitted by these actions).
- **Dare marks:** `challenge_resolved(puzzle_id, challenge_id, cleared, keyword)`
  → Progression records the clear against the shift in progress (or "after
  final clock-out") → payslip *Dares cleared*, End of day, chapter-list mark.
- **Restart:** the **chapter-list view** owns the confirmation: it queries
  `draft_is_empty`, shows IP-18 when non-empty, then calls
  `ShiftProgression.request_restart(puzzle_id)`, which logs
  `request_restart {state, draft_was_empty}` and emits
  `request_restarted(puzzle_id)`. Cancel calls nothing and logs nothing.
- **Playtest Log** (Progression, `playtest-log.md` rule 4): `shift_clockout`,
  `chapter_complete {starred}`, `request_restart {…}`.

---

## Transitions & Animations

Screens swap in place on the work surface (0 ms); the strip's shift palette
crossfade (300 ms) happens on the shift-start card only; the chapter ★ stamp
uses the stamp motion (180 ms). Under reduced motion all are final states. A
soft receipt-printer sound on the payslip (Audio, VS) duplicates nothing
informational.

---

## Input Method Completeness Checklist

- [x] Every action reachable with Tab / arrows / Enter / Esc / F6; the primary button is focused on arrival (focus table above).
- [x] Esc per screen defined (focus table); never destructive (IP-03).
- [x] Scrolling content reachable by keyboard at `ui_scale` 2.0 (focusable scroll containers).
- [x] No timed input; nothing auto-advances from these screens.
- [x] Mouse targets ≥ 32 × `ui_scale` px; payslip buttons separated ≥ 16 px (IP-19); hover never draws indigo.

---

## Accessibility

Tier Standard + reduced motion + full keyboard. Glyph + word for every state;
"locked", "open", "unavailable", "not starred yet" are words only. Contrast (art
bible 4.4): `ink` on `card` 14.9:1; `ink_muted` 6.55:1 on `paper`, 7.20:1 on
`card`; `pass` (✓ passed) 7.23:1 / 7.94:1; `stamp` ★ 4.74:1 / 5.21:1 (narrow;
do not lighten). Text sizes from art bible 7.2, never below the 14 px floor at
`ui_scale` 1.0 (T-01). Pass green only on "✓ passed", vermilion only on ★.
AccessKit (best effort): rows read "1-5 Drinks under 200 yen, left for later,
dare available"; on arrival each screen's title is announced once with the
focused button ("Payslip, Afternoon. Next shift, button"); receipts are not live
regions.

---

## Localization Considerations

All titles, states, buttons and notes come from `StringTable.text(id, args)`
(ADR-0007 §2), with `{name}` placeholders filled by its single-pass routine —
never `String.format`. Ids below are illustrative; the namespace follows
ADR-0007. Request titles come from puzzle content (`puzzle:<id>:title`).

| Id (illustrative) | English | Args | Max (graphemes) |
|---|---|---|---|
| `shift_flow.payslip.title` | PAYSLIP · {shift} | `shift` | 28 |
| `shift_flow.payslip.dares_cleared` | Dares cleared | — | 20 |
| `shift_flow.payslip.wage` | Wage {amount} | `amount` (formatted yen) | 24 |
| `shift_flow.payslip.note_all_unavailable` | None of this shift's requests could be checked today. The store has noted it. | — | 110 (wraps) |
| `shift_flow.shift.progress` | {done} / {total} requests done | `done`, `total` | 28 |
| `shift_flow.shift.mvp_note` | Progress is kept until you close the game — saving comes in a later build. | — | 110 (wraps) |
| `shift_flow.state.*` | locked / open / passed / left for later / unavailable | — | 18 each |
| Buttons (`shift_flow.btn.*`) | Next shift, Stop for today, End of day, Back to the store, Continue, Back to work, Chapter list, Options, Resume, Replay, Reopen, Try the dare, Restart, Cancel, Back | — | 18 each |
| `shift_flow.shift_button.disabled` | Leave the dare first | — | 22 |

Yen amounts use tabular numerals. Rows must fit +40% text at 1.0: wrap the
title, never the state word; buttons grow in height, not by truncation.

---

## Acceptance Criteria

- **UX-SF-01 [UI]** At `ui_scale` 1.0 and 2.0, the payslip shows every main and side request of the shift with "✓ passed", "↷ left for later" or "unavailable", a "Dares cleared" block when a dare was cleared during the shift (including one on an earlier shift's request), and "Wage ¥3,000"; *Next shift* has focus; capture retained.
- **UX-SF-02 [UI]** After the Closing shift the payslip shows only *End of day*; End of day shows "✓ Chapter complete", "★ starred" or "not starred yet", the left-for-later list, and dares cleared after the final clock-out; *Back to the store* leads to a shift screen titled "Chapter complete" with *Chapter list* focused and no *Continue*.
- **UX-SF-03 [UI]** The chapter list shows main and side rows with the five state words, the dare mark, and the row actions in the Row actions table; Up/Down + Tab + Enter opens a request; Esc returns to the shift screen with focus on *Chapter list*.
- **UX-SF-04 [UI]** Restart on a row with a non-empty draft shows "Start this request over? Your query will be cleared." with Cancel focused; Esc cancels and the list stays open; with an empty draft it restarts at once; the player stays on the list.
- **UX-SF-05 [UI]** In challenge mode the Shift button is disabled and shows the visible words "Leave the dare first"; `Ctrl+Shift+S` does nothing; outside challenge mode the menu lists Shift screen, Chapter list, Options (and Log at `ui_scale` ≥ 1.5).
- **UX-SF-06 [UI]** After *Stop for today* the shift screen names the next shift, shows the MVP note, and *Continue* starts that shift's briefing; after reopening a request from the list, *Continue* is still primary and *Back to work* secondary.
- **UX-SF-07 [UI]** A shift whose mains were all withheld clocks out at once and the payslip shows the all-unavailable note.
- **UX-SF-08 [Manual, keyboard-only]** With the mouse unplugged, at `ui_scale` 1.0 and 2.0: clock out, read every payslip row (scrolling with PageDown), stop, open the chapter list, reopen a request, restart one, open options and return; focus is always visible and never lands on an inert strip control.
- **UX-SF-09 [Manual, reduced motion]** With reduced motion on, the ★ stamp and shift crossfade appear as final states on the first frame; nothing moves.
- **UX-SF-10 [Manual, greyscale]** Greyscale and protan/deutan/tritan captures of the payslip and chapter list: every state and dare mark is identifiable from glyph or word alone.
- **UX-SF-11 [Performance]** Each screen is fully drawn on the first rendered frame after its trigger (signal or button), at 1280×720 on the minimum-spec PC; no loading state appears.

---

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | No player journey map — arrival states inferred | ux-designer | Before the next `/ux-review` |
| 2 | ~~"– unavailable" en dash~~ — **Resolved 2026-10-16:** word only, `ink_muted`; GDD wording follow-up (PR-11, visual requirements) | Progression owner | GDD revision |
| 3 | Is the wage line worth keeping vs a manager comment (Progression OQ 2)? | Progression owner | After MVP playtest |
| 4 | ~~Side tickets on the shift screen~~ — **Resolved 2026-10-16:** side requests are rows in the chapter list; tickets stay active in the strip | — | — |
| 5 | ~~Pattern-library additions~~ — **Resolved 2026-10-16:** IP-02 (two regions), IP-03 (steps 4–6), IP-19 (one-choice variant, shift screen), IP-20 (side rows, *Resume*, *Try the dare*), IP-22 (Shift menu, paper-screen behaviour); paper card and shift-start card remain library Gaps | ux-designer | — |
| 6 | ADR-0010 names the Workbench view as the caller of `ShiftProgression.request_restart`; this spec gives the chapter-list confirmation to the chapter-list view | technical-director | ADR-0010 text amendment |
