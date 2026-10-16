# UX Spec: Shift Flow (Shift Screen, Payslip / End of Day, Chapter List)

> **Status**: In Design (v1 draft — awaiting `/ux-review`)
> **Author**: tingoofriend + Claude (`/ux-design shift-flow`, autonomous)
> **Last Updated**: 2026-10-16
> **Journey Phase(s)**: between shifts (clock-out, start of a shift), returning to a skipped request, session end at MVP
> **Platform Target**: PC (Windows, Linux), 1280×720 logical canvas; keyboard + mouse, keyboard-first
> **Template**: UX Spec
> **Sources**: `design/gdd/shift-and-chapter-progression.md` (owner; rules 6–13, States, UI Req 1–6, PR-11/15/16), `constraint-challenges.md` (marks, rule 6b), `onboarding-first-shift.md` (options panel), `design/art/art-bible.md` 3.3, 4.5, 7; `design/ux/interaction-patterns.md`; `design/ux/query-workbench.md`; `design/accessibility-requirements.md`

---

## Purpose & Player Need

Three small paper screens frame the work. The **payslip** closes a shift with a
calm, rewarding summary and a natural place to stop; the **shift screen** is
where a shift starts (or resumes after *Stop for today*); the **chapter list**
lets the player see the whole day and return to any request — replay a pass,
reopen a skipped one, or restart. The player arrives wanting to know "how did
that shift go, and what's next?" or "let me go back to that one". Without them
the player would have no sense of progress and no way back to a skipped
request (Progression rules 8, 12).

---

## Player Context on Arrival

- **Payslip:** just finished the last main request of a shift (PASS, skip or
  unavailable) — relieved, maybe proud; the counter strip has just shown the
  pass / `skip.accept` hold.
- **Shift screen:** chose *Stop for today* (MVP: stays in the session) or
  opened it from the workbench's Shift button to look around.
- **Chapter list:** curious or determined to return to a request; never
  pressured.
- *Assumption:* no player journey map (Open Question 1).

---

## Navigation Position

Workbench ⇄ these screens. All three replace the **work surface only** (the
area under the zone rule); the counter strip stays on top, so the store, the
time of day and Tanaka's briefing remain continuous (Claude decision).

```
Workbench ──(last main resolved)──► Payslip ──Next shift──► Shift briefing (strip) ──► Workbench
                                       │                       ▲
                                       └──Stop for today──► Shift screen ──Continue──┘
Workbench ──Shift button──► Shift screen ──Chapter list──► Chapter list ──Open / Replay / Reopen──► Workbench
                                   ▲                              │ Restart (inline confirm)
                                   └──────────── Back ────────────┘
After the Closing shift: Payslip ──► End of day ──► Shift screen (chapter complete)
```

---

## Entry & Exit Points

| Entry Source | Trigger | Player carries this context |
|---|---|---|
| Workbench | Shift's last main request passed / skipped / unavailable → `shift_clocked_out` (after the hold) | Shift results |
| Workbench | Shift button (strip tab cluster) | Open request id (kept) |
| Payslip | *Stop for today* | Session progress (MVP: kept until quit) |
| Shift screen | "Chapter list" | — |

| Exit Destination | Trigger | Notes |
|---|---|---|
| Next shift briefing (workbench, strip bubble) | Payslip *Next shift* / shift screen *Continue* | First main request opens when the briefing ends (rule 11) |
| End of day | Payslip after the Closing shift | Replaces *Next shift* (rule 6) |
| Workbench (a request) | Chapter list Open / Replay / Reopen | Keeps the request's draft, counters, hints (rule 12) |
| Workbench (open request) | Shift screen *Back to work* (when a request is open) | Nothing changes |
| Quit | Window close | MVP: progress lost — stated on *Stop for today* note |

---

## Layout Specification

### Information Hierarchy
1. **Payslip:** each request's outcome (glyph + word) → challenges cleared → wage → the two choices.
2. **Shift screen:** current shift + requests done / total → the next action (Continue / Back to work) → chapter list → options.
3. **Chapter list:** shift groups → each request's state and challenge mark → row actions.

### Layout Zones
Work surface = x 16–1264, y 142–704 (as the workbench). Each screen is one
centred paper object on the `paper` frame; nothing else on the work surface.

| Screen | Object (art bible 3.3) | Rect at `ui_scale` 1.0 | Grows at higher `ui_scale` |
|---|---|---|---|
| Payslip | Receipt, wider; zigzag bottom; wage under a dashed tear rule | 480 × up to 540, centred | Taller; scrolls inside the receipt above the buttons at 2.0 |
| End of day | Same receipt form, a second receipt below the payslip's position | 480 × up to 540 | As above |
| Shift screen | Paper card with the shift name as title | 560 × 360, centred | Taller |
| Chapter list | Clipboard (clip at top centre), shift-by-shift checklist | 720 × 540, centred | List scrolls; actions stay on the focused row |

### ASCII Wireframe
```
Payslip (Afternoon)                    Chapter list — Day One
┌──────────────────────────┐          ┌──────────────── ◖clip◗ ─────────────────┐
│ PAYSLIP · Afternoon      │          │ Day One · 2026-03-02            ★ —     │
│ ─────────────────────────│          │ Morning                                 │
│ 1-4 Cheap snacks  ✓ passed ★ cleared│ │  1-1 First order    ✓ passed   [Replay]│
│ 1-5 Drinks < ¥200 ↷ left for later  │ │  1-2 …              ✓ passed   [Replay]│
│ 1-6 …             ✓ passed ☆        │ │ Afternoon                               │
│ 1-7 …             – unavailable     │ │  1-5 Drinks < ¥200  ↷ left for later   │
│ S-1 HQ email      ✓ passed          │ │                     [Reopen] [Restart] │
│ - - - - - - - - - - - - -│          │  1-6 …  ✓ passed  ☆ dare available      │
│ Wage            ¥3,000   │          │ Closing                                 │
│ [■ Next shift] [Stop for today]     │ │  1-8 …              ◌ locked            │
└╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱┘          │                       [Back  Esc]       │
                                       └─────────────────────────────────────────┘
```
(◌ is illustrative; the locked state is the word "locked" with no new glyph —
see Component Inventory.)

### Component Inventory

| Screen | Component | Content | Interactive | Pattern |
|---|---|---|---|---|
| Payslip | Title | "PAYSLIP · {shift}" (stamp-style label) | No | — |
| Payslip | Request rows | id, short title, outcome glyph + word (✓ passed / ↷ left for later / – unavailable), ★ challenge cleared this shift; side requests listed after mains | No | IP-07 |
| Payslip | Wage line | "Wage ¥3,000" (content value, flavour only) under a dashed tear rule | No | — |
| Payslip | Buttons | *Next shift* (primary, focused) / *Stop for today*; after Closing: *End of day* replaces *Next shift* | Yes | IP-19 |
| Payslip | MVP note | Under *Stop for today*: "Progress is kept until you close the game — saving comes in a later build." | No | — |
| End of day | Summary | Chapter complete (✓ / not yet), star (★ / —), requests left for later (count + list), challenges cleared after the final clock-out | No | IP-07 |
| End of day | Button | *Back to the store* → shift screen | Yes | IP-19 |
| Shift screen | Title + progress | "Day One · Afternoon", "3 / 4 requests done" | No | — |
| Shift screen | Primary action | *Continue* (starts the next shift's briefing) or *Back to work* (a request is open) | Yes | IP-19 |
| Shift screen | Secondary | *Chapter list*, *Options* (minimal options panel, IP-21) | Yes | IP-21 |
| Chapter list | Header | Chapter name + date; chapter star ★ or "—" (word "not yet" in the accessible name) | No | IP-07 |
| Chapter list | Shift groups | Morning / Afternoon / Closing headings | No | — |
| Chapter list | Request rows | id, title, state glyph + word: "locked", "open", "✓ passed", "↷ left for later", "– unavailable"; challenge "★ dare cleared" / "☆ dare available"; "(current)" on the open request | Yes | IP-20 |
| Chapter list | Row actions | Open (open), Replay (passed), Reopen (left for later / unavailable), Restart (open / skipped / passed) | Yes | IP-20, IP-18 |
| Chapter list | Back | *Back* (Esc) → shift screen | Yes | IP-03 |

**Glyph note:** "locked" and "open" use words only — no glyph exists for them in
the art-bible vocabulary, and IP-07 forbids new glyphs without an art-bible row.
The GDD's "– unavailable" uses an en dash, which the vocabulary does not list
(Open Question 2).

---

## States & Variants

| State / Variant | Trigger | What Changes |
|---|---|---|
| Payslip — mid-chapter | Clock-out of Morning / Afternoon | *Next shift* primary |
| Payslip — last shift | Clock-out of Closing | *End of day* replaces *Next shift*; strip sign flips to "Closed" |
| End of day — complete & starred | All main passed | ★ stamp lands on the chapter card (180 ms, final state under reduced motion) |
| End of day — complete, not starred | Some left for later | "★ —" and the list of left-for-later requests with *Reopen* hint |
| Shift screen — after Stop for today | *Stop for today* | *Continue* primary; MVP note visible |
| Shift screen — mid-shift | Shift button from the workbench | *Back to work* primary; progress count |
| Chapter list — challenge mode open | Opened during a dare | Not reachable: the Shift button is disabled in challenge mode (shift never advances, CC 6) — *Leave challenge* first |
| Chapter list — Restart confirm | Restart on a row with a non-empty draft | Inline confirm (IP-18) |
| Chapter list — withheld puzzle | Content check failed | Row shows "unavailable"; no actions |
| `ui_scale` ≥ 1.5 | Setting | Receipts taller; chapter list scrolls; row actions stack under the row |

---

## Interaction Map

| Component | Action | Input | Immediate feedback | Outcome |
|---|---|---|---|---|
| Payslip *Next shift* | Activate | Enter (focused by default) / click | — | `shift_started` → briefing in the strip; workbench |
| Payslip *Stop for today* | Activate | Tab + Enter / click | — | Shift screen (MVP) |
| Payslip *End of day* | Activate | Enter / click | — | End of day receipt |
| Shift screen *Continue* / *Back to work* | Activate | Enter / click | — | Briefing / workbench |
| Shift screen *Chapter list* | Activate | Tab + Enter / click | — | Chapter list |
| Shift screen *Options* | Activate | Tab + Enter / click | Panel appears | Minimal options panel |
| Chapter list rows | Move | Up / Down | Focus ring on row | — |
| Row action | Activate | Tab into row + Enter / click | — | Workbench with that request; `request_open` (Progression) |
| Restart | Activate | Enter / click | Inline confirm (if draft non-empty) | `request_restarted`; `request_restart {state, draft_was_empty}` |
| Back | Leave | Esc / click | — | Shift screen |

---

## Data Requirements

| Data | Source (owner) | Read / write |
|---|---|---|
| Chapter, shifts, request ids / titles / order | PuzzleRepository (Puzzle Definition) | Read |
| Request states, shift state, chapter complete / starred | Shift & Chapter Progression | Read |
| Challenge marks | Constraint Challenges | Read |
| Wage per shift | Puzzle Definition (chapter content) | Read |
| Draft-empty for Restart | Workbench via `draft_is_empty` (ADR-0010) | Read (through Progression) |
| Text | StringTable (ADR-0007) | Read |

---

## Events Fired

Owned by Progression (`playtest-log.md` rule 4): `request_open` (on Open /
Replay / Reopen), `request_restart {state, draft_was_empty}`, `shift_clockout`,
`chapter_complete {starred}`. Gameplay signals per ADR-0010: `request_opened`,
`request_restarted`, `shift_started`, `shift_clocked_out`.

---

## Transitions & Animations

Screens swap in place on the work surface (0 ms); the strip's shift palette
crossfade (300 ms) happens on the shift-start card only; the chapter ★ stamp
uses the stamp motion (180 ms). Under reduced motion all are final states. A
soft receipt-printer sound on the payslip (Audio, VS).

---

## Input Method Completeness Checklist

- [x] Every action reachable with Tab / arrows / Enter / Esc; the primary button is focused on arrival.
- [x] Esc: closes the chapter list (→ shift screen) and the options panel; does nothing on the payslip (both answers matter, IP-19).
- [x] No timed input; nothing auto-advances from these screens.
- [x] Mouse targets ≥ 32 × `ui_scale` px.

---

## Accessibility

Tier Standard + reduced motion + keyboard. Glyph + word for every state;
pass green only on "✓ passed", vermilion only on ★; "locked"/"open" are words;
contrast per art bible 4.4; AccessKit names: rows read "1-5 Drinks under 200
yen, left for later, dare available"; receipts are not live regions (the player
navigates them).

---

## Localization Considerations

Titles, states and buttons from StringTable; request titles from puzzle
content; yen amounts formatted with tabular numerals; rows must fit +40% text
at 1.0 (wrap the title, never the state word).

---

## Acceptance Criteria

- **UX-SF-01 [UI]** Payslip at 1.0 and 2.0 shows every main and side request of the shift with glyph + word, ★ for challenges cleared that shift and the wage line; *Next shift* focused; capture retained (PR-11).
- **UX-SF-02 [UI]** After the Closing shift the payslip offers *End of day*; the End of day receipt shows complete / star / left-for-later list.
- **UX-SF-03 [UI]** Chapter list rows show the five states and the challenge mark as glyph + word / word; Up/Down + Enter opens a request; Esc returns to the shift screen (PR-16).
- **UX-SF-04 [UI]** Restart on a row with a non-empty draft shows "Start this request over? Your query will be cleared." with Cancel focused; with an empty draft it restarts at once.
- **UX-SF-05 [UI]** In challenge mode the Shift button is disabled with the accessible description "Leave the dare first".
- **UX-SF-06 [UI]** *Stop for today* shows the MVP progress note and *Continue* resumes with the next shift's briefing.

---

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | No player journey map — arrival states inferred | ux-designer | Before `/ux-review` |
| 2 | "– unavailable" uses an en dash not in the art-bible glyph vocabulary; add a row or use the word only? | art-director + Progression owner | `/ux-review` |
| 3 | Is the wage line worth keeping vs a manager comment (Progression OQ 2)? | Progression owner | After MVP playtest |
| 4 | Should the shift screen also show side tickets still open? | ux-designer | `/ux-review` |
