# Accessibility Requirements: SQLbini

> Authoring guidance: .claude/docs/templates/guidance/accessibility-requirements-guide.md (load per-section as you author — do not read entirely).

> **Status**: Committed
> **Author**: tingoofriend + Claude (`/ux-design accessibility`, autonomous; tier and MVP reduced-motion choice by the developer, 2026-10-16)
> **Last Updated**: 2026-10-16
> **Accessibility Tier Target**: **Standard** (+ reduced motion, + full keyboard operation)
> **Platform(s)**: PC — Windows and Linux desktop (Steam). Keyboard + mouse only; no gamepad, no touch; Steam Deck is not a target (no physical keyboard)
> **External Standards Targeted**:
> - WCAG 2.1 Level AA for text and non-text contrast, resize text (1.4.4), use of colour (1.4.1), three flashes (2.3.1), keyboard (2.1.1) — AAA 7:1 target for body and editor text (art bible 4.4)
> - AbleGamers CVAA Guidelines — not applicable (no communication features); used as a checklist only
> - Xbox Accessibility Guidelines (XAG) — No (not an Xbox title)
> - PlayStation Accessibility (Sony Guidelines) — No
> - Apple / Google Accessibility Guidelines — N/A
> **Accessibility Consultant**: None engaged
> **Linked Documents**: `design/gdd/systems-index.md`, `design/ux/interaction-patterns.md`, `design/art/art-bible.md` (4.4–4.7, 7.2, 7.5–7.9), `design/gdd/query-workbench.md`, `design/gdd/request-and-reaction-dialogue.md`, `design/gdd/onboarding-first-shift.md`

> **Why this document exists**: Per-screen accessibility annotations belong in
> UX specs. This document captures the project-wide accessibility commitments,
> the feature matrix across all systems, the test plan, and the audit history.
> If a feature conflicts with a commitment made here, this document wins —
> change the feature, not the commitment, unless the developer approves a
> formal revision.
>
> **When to update**: After each `/gate-check` pass, after any accessibility
> audit, and whenever a new game system is added to `systems-index.md`.

---

## Accessibility Tier Definition

### Tier Definitions

| Tier | Core Commitment | Typical Effort |
|------|----------------|----------------|
| **Basic** | Critical player-facing text is readable at standard resolution. No feature requires color discrimination alone. Volume controls exist for music, SFX, and voice independently. The game is completable without photosensitivity risk. | Low — primarily design constraints |
| **Standard** | All of Basic, plus: full input remapping on all platforms, subtitle support with speaker identification, adjustable text size, at least one colorblind mode, and no timed input that cannot be extended or toggled. | Medium — requires dedicated implementation work |
| **Comprehensive** | All of Standard, plus: screen reader support for menus, mono audio option, difficulty assist modes, HUD element repositioning, reduced motion mode, and visual indicators for all gameplay-critical audio. | High — requires platform API integration and significant UI architecture |
| **Exemplary** | All of Comprehensive, plus: full subtitle customization (font, size, color, background, position), high contrast mode, cognitive load assist tools, tactile/haptic alternatives for all audio-only cues, and external third-party accessibility audit. | Very High — requires dedicated accessibility budget and specialist consultation |

### This Project's Commitment

**Target Tier**: **Standard**, with two features elevated from Comprehensive.
The commitment applies to the **Vertical Slice (Steam Next Fest demo) and every
later release**. The MVP playtest build ships the subset marked *MVP* in the
tables below (its options panel is Onboarding's minimal panel).

**Rationale**: SQLbini is a reading- and typing-heavy puzzle game with no time
pressure: the player reads a request, types SQL and studies two data grids. The
untimed loop removes the motor barriers of action games, but the barriers that
remain are visual (dense monospace text, data grids, colour-coded row marks),
motor through the keyboard (every action is a typed or chorded key), and
cognitive (SQL itself, hidden-data feedback). Standard covers these directly —
text scaling, remapping, no colour-only information, no timed input — and most
of it is already designed into approved GDDs and the art bible, so the cost is
mainly implementation of the Vertical Slice Accessibility Options system.
Comprehensive's screen-reader commitment would hinge on `CodeEdit` exposing its
text to AccessKit in Godot 4.7, which is unverified (NOT SOURCEABLE), and would
add an estimated 2–3 weeks for a one-person team. Dropping to Basic would save
only days (text scaling and keyboard operation are already designed) while
excluding low-vision and one-handed keyboard players.

**Features explicitly in scope (beyond tier baseline)**:
- **Reduced motion mode** (Comprehensive) — the art bible already makes motion
  optional (7.6) and several GDDs specify reduced-motion behaviour. **MVP: a
  toggle in Onboarding's minimal options panel** (developer decision 2026-10-16;
  closes onboarding OQ4 and art-bible R-04).
- **Full keyboard operation** (beyond "remapping") — every action reachable
  without the mouse, visible keyboard focus distinct from hover, F6 pane cycling
  (`query-workbench.md` rule 15, UI Req 4). Typing SQL is the core action.
- **IME input** in the editor (Korean / Japanese composition, workbench rule 16)
  and bundled CJK fonts — players type their own data values.
- **AccessKit screen-reader labels — best effort, not a commitment**: labels
  for regions, buttons, row marks and verdicts are added where Godot controls
  support them (workbench UI Req 7); not gated until the `CodeEdit` probe
  (Open Question 1).

**Features explicitly out of scope** (each also in Known Intentional Limitations):
- A palette-swap **colourblind mode** — replaced by a stricter commitment: no
  information is carried by colour alone anywhere (art bible 4.5–4.6), verified
  with a simulator. A mode is added only if testing finds a pair that fails.
- **Screen-reader support as a commitment** (menus and editor).
- **Subtitles / captions** — there is no voiced dialogue; every line is text.
- **Mono audio, directional-audio indicators** — no positional or
  gameplay-critical audio; every sound duplicates a visual.
- **Difficulty sliders** — difficulty is the SQL itself; the Hint System and
  "Leave it for Kenji" (skip) are the assists.

---

## Visual Accessibility

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Minimum text size — all functional text | Standard (MVP) | Work surface, bubble, panels, payslip, chapter list | Designed | Base ≥ 14 px at 1280×720; effective floors 14 / 16 / 18 at `ui_scale` 1.0 (art bible 7.9 T-01/T-02). Editor 18 px, tables 16 px, bubble 18 px base. No pixel font or texture-baked text for anything the player must read (T-05). |
| Text resize | Standard (VS; MVP default 1.0) | All UI text | Designed | `ui_scale` 1.0–2.0, step 0.25 (`query-workbench.md` Formulas) — WCAG 1.4.4 200%. Text-legibility setting, not a zoom: text-bearing objects grow, decoration and the 120 px counter strip stay fixed (art bible 7.8). Accepted cost at 2.0: result grids show 2 rows and scroll; bubbles page sooner. |
| Text contrast — UI text | Standard (MVP) | All UI text | Designed, verified by script | ≥ 4.5:1 floor, 7:1 target for body and editor text; every pair listed and verified in art bible 4.4. Known low-contrast pairs never touch (placement rules, 4.4). |
| Non-text contrast | Standard (MVP) | Glyphs, borders, focus ring, row-mark bars, dashed strokes | Designed | ≥ 3:1 (art bible 4.4); dotted/dashed strokes ≥ 2 px with dash and gap ≥ 4 px (7.7). |
| Bubble / dialogue text | Standard (MVP) | Counter-strip bubble, message log | Designed | Opaque paper bubble, `ink` on `card` 14.9:1 — exceeds the 7:1 subtitle guidance; the strip palette never tints UI paper (P-08). |
| Colour as only indicator | Basic (MVP) | All UI and gameplay | Designed | Every signal carries glyph + word (workbench rule 17, art bible 4.6). Audit table below. |
| Colourblind support | Standard — **substituted** | All colour-coded UI | Designed | No palette mode; structural backups instead (see out-of-scope and Known Intentional Limitations). Verified per screen with a protan / deutan / tritan simulator and a greyscale capture (S-03). |
| Motion reduction | Comprehensive → in scope (MVP toggle) | All UI motion, strip idle blink, typewriter, shift crossfade | Designed | Under reduced motion every motion is replaced by its final state; information identical (art bible 7.6, R-02/R-03). Toggle in the minimal options panel at MVP; moves to Accessibility Options at VS. |
| Flash / strobe safety | Basic (MVP) | Whole game | Designed | Nothing loops, blinks or flashes on the work surface; no whole-area luminance change (art bible 7.6 — WCAG 2.3.1 met with margin). No caret blink. No photosensitivity warning screen needed; re-check if VS audio/VFX adds any. |
| Keyboard focus visibility | Standard (MVP) | Every focusable control | Designed | Solid indigo ring with paper gap, round(2 × `ui_scale`) px, never animated; hover ≠ focus (Godot 4.6 dual focus); focused pane bar (art bible 7.5, QW-20). |
| High contrast / dark theme | Comprehensive | UI layer | Deferred (VS Accessibility Options, art bible 4.7) | Not part of the Standard commitment; if added, every 4.4 pair is re-run. |
| Brightness / gamma | Basic | — | N/A | 2D flat UI with no lighting; the light paper theme is fixed. Listed in Known Intentional Limitations. |
| Glyph rendering | Standard (MVP) | Mono code and data | Designed | Mono glyph test sheet distinct at 14 and 18 px; slashed/dotted zero; no ligatures; CJK without tofu; ✓ ⚠ ≈ ↷ ★ ☆ never rendered as emoji (art bible 7.9 M-02…M-06). |

### Color-as-Only-Indicator Audit

| Location | Color Signal | What It Communicates | Non-Color Backup | Status |
|----------|-------------|---------------------|-----------------|--------|
| Submit result | Pass green / fail red | Accepted vs not accepted | Never shown together; PASS = circle stamp + "✓ ACCEPTED"; FAIL = sticky note + "? Not accepted", no stamp (art bible 4.6) | Resolved (design) |
| Result grid rows | Amber / blue-violet | Extra vs missing row | "+ extra" / "− missing" in the gutter; solid bar vs dashed outline; missing rows are ghost rows | Resolved (design) |
| Stamp vs FAIL | Vermilion / fail red | Sealed vs failed | Seal shape vs text tab; object and position exclusivity (4.5) | Resolved (design) |
| Syntax highlighting | Keyword blue / number teal / string orange | Token kind | Keywords bold; numbers right-aligned in grids; luminance differs; highlighting is a convenience, never required | Resolved (design) |
| Comment vs ghost text | Both dim | Comment vs onboarding example | `--` prefix; ghost text labelled "shape" and disappears on typing | Resolved (design) |
| Focus ring vs coach ring | Indigo / ink | Keyboard focus vs onboarding mark | Solid vs dashed + paper tag | Resolved (design) |
| Chapter list / payslip states | Green / neutral | Passed / left for later / challenge | ✓ passed, ↷ left for later, ★ cleared, ☆ available — glyph + word | Resolved (design) |
| Hint "new step" | Indigo | New hint available | Dot + word (HS-16) | Resolved (design) |
| Error / jammed strip | Ink only | Run or Submit error | ⚠ + dashed jagged strip + text (no red) | Resolved (design) |
| Staff vs customer in the strip | Indigo apron | Who is speaking | Silhouette trait + height + name tag on reactions | Resolved (design) |
| Playtest recording label | Ink | Recording on | "●" + "Recording playtest" | Resolved (design) |

---

## Motor Accessibility

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Full keyboard operation | In scope (MVP) | Every action and screen | Designed | Workbench rule 15 shortcut table (Run Ctrl+Enter, Submit Ctrl+Shift+Enter, F6 / Shift+F6 panes, Esc leaves the editor, Ctrl+H/M/B/L); chapter list, payslip, offers and coach marks keyboard reachable (Progression UI Req 2–4, CC UI Req 1, Onboarding UI Req 1–2). Esc precedence fixed (workbench rule 15). |
| Full input remapping | Standard (VS) | Every default shortcut | Planned | All shortcuts remappable in Accessibility Options (workbench rule 15). Conflict warning; no two actions on one chord; persisted by Save/Load & Settings (VS). Ordinary text input (typing SQL) is not remapped — the OS keyboard layout applies. |
| Input method switching | Standard | — | N/A | Keyboard + mouse only; both work at all times, no prompt switching. |
| One-hand operation | Standard (audit) | Chorded shortcuts | Planned | Default chords are two-key (Ctrl+Enter, Ctrl+Shift+Enter). Every chord has a clickable button, and remapping (VS) allows a single key. Typing SQL itself needs a keyboard — inherent. |
| Hold-to-press alternatives | Standard | — | N/A | The game has no hold inputs. |
| Rapid input alternatives | Standard | — | N/A | No mashing or sustained rapid input. |
| Input timing / timed input | Standard (MVP) | Whole game | Designed | **No timed input anywhere**: no request expires, no puzzle is timed, Kenji's skip offer waits for an answer. The hint unlock timer only adds help (`active_time`, paused when unfocused). The F9 note field (playtest builds, facilitator only) closes after 5 s idle — not a player feature. |
| Hit targets | Standard (MVP) | Mouse targets | Designed | Minimum 32 × `ui_scale` px; Run–Submit separation ≥ 24 × `ui_scale` px and never adjacent so one mis-click hits the other (workbench UI Req 2, art bible H-01…H-03); the whole bubble is one target. |
| IME composition | In scope (MVP) | Editor | Designed | Korean/Japanese composition committed before Run (workbench rule 16); ADR-0008 + IME probe before the first Workbench story. |
| Aim assist / movement / platforming | — | — | N/A | No aiming, movement or traversal. |
| HUD element repositioning | Comprehensive | — | Out of scope | Fixed layout; panels never cover the editor (Store Manual UI Req 4). |

---

## Cognitive Accessibility

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Difficulty options | Standard — **substituted** | Puzzle difficulty | Designed | No sliders: two-step hints on request (Hint System), Kenji's skip offer after hints are exhausted (Progression), the Store Manual as syntax reference, and onboarding for zero-SQL players. Fixed parameter (SQL correctness on hidden data) is the game's core (Pillar 1). |
| Pause anywhere | Basic (MVP) | All states | Designed | Nothing advances without the player except reaction holds (cosmetic) and the hint timer (paused when the window loses focus). The player can leave at any moment; no state punishes idle time. |
| Tutorial persistence | Standard (MVP) | Onboarding, manual, coach marks | Designed | Store Manual always reachable (Ctrl+M), message log keeps every line of the shift (Ctrl+L), coach marks can be re-enabled in the options panel; ghost text shows the query "shape". |
| Objective clarity | Standard (MVP) | Current request | Designed | The current request stays in the bubble / request ticket and in the message log; the target grid shows the expected visible result; ≤ 1 key (Ctrl+L) to the full text. |
| Reading time | Standard (MVP) | Auto-dismissing text | Designed with exception | Reactions return to the request after `reaction_hold` (2.5–6.0 s, data-driven). Actionable feedback never auto-dismisses: the FAIL note, Run note, error strip and verdict persist on the work surface, and every line stays in the message log. Exception noted in Known Intentional Limitations. Typewriter: any key completes it; off under reduced motion. |
| Visual indicators for audio | Standard (VS) | All SFX | Designed | Every sound (bubble blips, stamp, fail) duplicates a visual event; nothing is audio-only (audit below). |
| Cognitive load per system | Comprehensive | Per system | Partial (matrix below) | Not committed; the matrix records the main load per system. |
| Navigation assists | Standard | — | N/A | No world navigation; the chapter list shows every request and its state. |
| No information only in time | In scope (MVP) | Feedback | Designed | Text-bearing objects appear in final position on frame 1 (art bible 7.6, R-01). |

---

## Auditory Accessibility

| Feature | Target Tier | Scope | Status | Implementation Notes |
|---------|-------------|-------|--------|---------------------|
| Subtitles for all spoken dialogue | Basic | — | N/A — all text | There is no voice; every line is printed in the bubble with a speaker name tag on reactions and kept in the message log with speaker name and kind (RD-06). |
| Speaker identification | Standard (MVP) | Bubble, log | Designed | Speaker shown at the counter (sprite) + name tag on reactions + speaker name in the log; not colour-coded. |
| Closed captions for SFX | Comprehensive | — | N/A | No gameplay-critical SFX without a visual (audit below). |
| Mono audio | Comprehensive | — | Out of scope | No positional audio. |
| Independent volume controls | Basic (VS) | Music / SFX / blips | Planned | Audio GDD (VS): at least music, SFX and bubble-blip volume; blip volume 0 = no blips (RD-15). |
| Directional audio indicators | Comprehensive | — | N/A | No directional audio. |
| Hearing-aid compatibility | Standard (VS) | Cues | Planned | No cue carries information only through sound, so frequency range is not critical; the Audio GDD keeps verdict sounds in the mid range. |

### Gameplay-Critical SFX Audit

| Sound Effect | What It Communicates | Visual Backup | Caption Required | Status |
|-------------|---------------------|--------------|-----------------|--------|
| PASS stamp sound | Submit accepted | Stamp + "✓ ACCEPTED" on frame 1 | No | Resolved (design) |
| FAIL sound | Submit not accepted | Sticky note + "? Not accepted" | No | Resolved (design) |
| Error / register jam | Run or Submit error | ⚠ jammed strip with text | No | Resolved (design) |
| Bubble blip / HQ printer tick | A line is being revealed | The line itself | No | Resolved (design) |
| New request arrives | Next customer at the counter | NPC step-in + bubble text | No | Resolved (design) |

---

## Platform Accessibility API Integration

| Platform | API / Standard | Features Planned | Status | Notes |
|----------|---------------|-----------------|--------|-------|
| Xbox (GDK) | XAG | — | N/A | Not a target. |
| PlayStation 5 | Sony guidelines | — | N/A | Not a target. |
| Steam (PC) | Steam Input | — | N/A | No controller support; in-game keyboard remapping (VS) is the remapping path. |
| iOS / Android | VoiceOver / TalkBack | — | N/A | No mobile release. |
| PC (Screen Reader) | AccessKit (Godot 4.5+) → NVDA / Windows Narrator / Orca | Accessible names and roles for regions, buttons, tabs, row marks and verdicts; live region for verdict and error text; decorative strip art hidden; one announcement per glyph + word pair (art bible A-01…A-06) | Best effort (not committed) | `CodeEdit` exposure to AccessKit in 4.7 is NOT SOURCEABLE (workbench OQ3) — probe with ADR-0008. `Control.accessibility_live` type changed to `AccessibilityServer.AccessibilityLiveMode` in 4.7 (`architecture.md` HIGH-risk table). |

---

## Per-Feature Accessibility Matrix

| System | Visual Concerns | Motor Concerns | Cognitive Concerns | Auditory Concerns | Addressed | Notes |
|--------|----------------|---------------|-------------------|------------------|-----------|-------|
| Hidden-Data Grader | Verdict legibility; pass/fail colour pair | — | Hidden-data failure is abstract ("why did it fail?") | Verdict sound | Yes | Glyph + word verdicts; level-1 symptom statements; FAIL note persists |
| Puzzle Definition & Datasets | — | — | Request wording precision | — | Partial | Requests quote exact values in mono runs (M-01); 1-4/1-5/1-7/1-8 rewrite before playtest |
| SQL Execution Sandbox | Error text readability | — | SQLite error text is technical | — | Yes | Error strip in ink with ⚠; Dialogue voices a friendly line, raw text on the strip only |
| Query Workbench | Dense grids, monospace, 2 grids side by side at high `ui_scale` | Keyboard-first, chords, IME | Many regions | — | Yes | Rules 15–17, UI Req 1–7; grids scroll at ≥ 1.5 (`/ux-design` workbench spec) |
| Hint System | Indicator, hint text size | Ctrl+H | Unlock condition comprehension | — | Yes | HS-16; unlock text placement → workbench UX spec |
| Constraint Challenges | Live check state | Try it / Later keyboard reachable | Rule wording | — | Yes | Glyph + word live check; never a modal |
| Shift & Chapter Progression | State marks | Keyboard on chapter list, payslip | Skip offer understanding | — | Yes | Glyph + word states; offer never times out |
| Request & Reaction Dialogue | Bubble text size, paging | Click / Enter / Space to page | Reading time of reactions | Blips | Yes, 1 exception | Log keeps every line; reactions auto-return (Known Intentional Limitations) |
| Store Manual | Panel text at 2.0 | Arrows, Enter, Esc | — | — | Yes | Never covers editor; scrolls at 2.0 (SM-09) |
| Onboarding: First Shift | Ghost text, coach ring contrast | Got it / Esc | Zero-SQL players | — | Yes | OB-20 contrast; marks can be turned off and back on |
| Playtest Log | Corner label | F9 (facilitator) | Consent text | — | Yes | Playtest builds only |
| Back Room (Alpha) | "practice data" label | — | Practice vs graded confusion | — | Pending | Persistent label (workbench UI Req 6); Back Room GDD |
| Save/Load & Settings (VS) | — | — | — | — | Pending | Persists `ui_scale`, reduced motion, coach marks, remapping |
| Game Shell & Screen Flow (VS) | Menu text | Keyboard menus | — | — | Pending | Follows this document |
| Efficiency Stats (VS) | Numbers legibility | — | — | — | Pending | — |
| Audio (VS) | — | — | — | All cues duplicated | Pending | Volume sliders; no audio-only cue |
| Accessibility Options (VS) | Hosts `ui_scale`, contrast theme, reduced motion | Hosts remapping | — | — | Pending | Implements the VS part of this document |
| Achievements (VS) | — | — | — | — | Pending | — |
| Modify Puzzle Grading (Alpha) | Before/after state display | — | Rewind comprehension | — | Pending | — |

---

## Accessibility Test Plan

| Feature | Test Method | Test Cases | Pass Criteria | Responsible | Status |
|---------|------------|------------|--------------|-------------|--------|
| Text contrast ratios | Automated — contrast script on palette tokens; screenshot probe for strip-adjacent UI | Every pair in art bible 4.4; Closing-shift capture | Text ≥ 4.5:1 (7:1 target met for body/editor); non-text ≥ 3:1 | ux-designer | Palette done (2026-10-14); captures Not Started |
| Text size and `ui_scale` | Manual — retained captures | Workbench, bubble, manual, hint, payslip, chapter list at 1.0, 1.5, 2.0 with longest strings | No clipped or overlapping text (P-01…P-06); grids scroll, never hide data | ux-designer | Not Started |
| Colour-only audit | Manual — protan/deutan/tritan simulator + greyscale capture | PASS, FAIL, 1-5 row marks, chapter list, hint indicator | Every state identifiable without colour | ux-designer | Not Started |
| Keyboard-only play | Manual — mouse unplugged | Day One Morning (1-1…1-3) incl. opening question, coach marks, manual, hint, Submit, payslip | Completable without the mouse; focus always visible; no focus trap except open overlays | qa-tester | Not Started |
| Reduced motion | Manual — toggle on, frame captures | Stamp, coach mark, typewriter, shift crossfade, NPC step-in, idle blink | Every motion replaced by final state; nothing loops or flashes (R-02, R-03) | ux-designer | Not Started |
| Input remapping (VS) | Manual — rebind every shortcut | All workbench shortcuts | All actions work after rebinding; conflicts warned; persists | qa-tester | Not Started |
| IME | Manual — Korean and Japanese IME on Windows and Linux | `WHERE name = '삼각김밥'` typed with composition, then Ctrl+Enter | Composition committed before Run; no tofu (M-05) | qa-tester | Not Started |
| Screen reader (best effort) | Manual — NVDA (Windows), Orca (Linux) | Workbench regions, Run/Submit, verdict | Recorded as observations, not pass/fail, until committed | ux-designer | Not Started |
| Zero-SQL playtest | User testing | Day One with zero-SQL players | Concept MVP thresholds; reading/comprehension issues logged | producer | Not dated (accepted risk) |

---

## Known Intentional Limitations

| Feature | Tier Required | Why Not Included | Risk / Impact | Mitigation |
|---------|--------------|-----------------|--------------|------------|
| Colourblind palette mode | Standard | Replaced by "no colour-only information" designed into every signal (art bible 4.5–4.6) | Low — a player who prefers a recoloured palette cannot get one | Simulator + greyscale verification per screen; add a mode if any test fails |
| Screen reader as a commitment (menus + editor) | Comprehensive | `CodeEdit` + AccessKit unverified on 4.7; +2–3 weeks | Blind players cannot reliably play (writing SQL needs the editor read back) | Best-effort labels; probe with ADR-0008; revisit after the probe |
| Reaction lines auto-return to the request after 2.5–6.0 s | Standard ("reading time ≥ 5 s for actionable text") | Reactions are flavour; the actionable feedback persists elsewhere | Low — a slow reader may miss a reaction line | Every line kept in the message log (Ctrl+L); click/Enter controls paging; `hold_*` data-driven |
| High contrast / dark theme | Comprehensive | Deferred to Accessibility Options (VS), not committed | Players needing very high contrast rely on the 7:1 default palette | Art bible 4.7 rules for any added theme |
| Brightness / gamma control | Basic | Flat 2D UI with no lighting | Very low | Fixed high-contrast light theme |
| Difficulty sliders | Standard | Difficulty is the SQL; sliders would break Pillar 1 | Some players may stall on a puzzle | Hints, skip offer, manual, onboarding |
| Gamepad / Steam Deck | — | Typing SQL needs a keyboard | Excludes controller-only play | Stated on the store page |
| `ui_scale` above 2.0 | Standard (200% is the WCAG target) | Layout capacity at 1280×720 | Low | OS-level magnifier still works |

---

## Audit History

| Date | Auditor | Type | Scope | Findings Summary | Status |
|------|---------|------|-------|-----------------|--------|
| 2026-10-14 | art-director + ux-designer (art bible review) | Internal design review | Palette, typography, motion, focus | All text pairs ≥ 4.5:1 (most ≥ 7:1), non-text ≥ 3:1, low-contrast pairs separated by placement rules; reduced motion handed to `/ux-design` | Closed (decisions in art bible 4.4–7.10) |
| 2026-10-16 | Claude (`/ux-design accessibility`) | Tier commitment | All MVP GDDs + art bible | Standard + reduced motion + keyboard; MVP reduced-motion toggle decided | Committed |

---

## External Resources

| Resource | URL | Relevance |
|----------|-----|-----------|
| WCAG 2.1 (Web Content Accessibility Guidelines) | https://www.w3.org/TR/WCAG21/ | Contrast, resize text, keyboard, flashes |
| Game Accessibility Guidelines | https://gameaccessibilityguidelines.com | Game-specific checklist |
| AbleGamers Player Panel | https://ablegamers.org/player-panel/ | User testing with disabled players |
| Colour Blindness Simulator (Coblis) | https://www.color-blindness.com/coblis-color-blindness-simulator/ | Colour-only audit |
| Accessible Games Database | https://accessible.games | Research and examples |

---

## Open Questions

| Question | Owner | Deadline | Resolution |
|----------|-------|----------|-----------|
| 1. Does `CodeEdit` expose its text and caret to screen readers via AccessKit in Godot 4.7? (workbench OQ3) | ui-programmer / accessibility-specialist | ADR-0008 (before the first Workbench story) | — |
| 2. Should reduced motion also follow the OS preference once Settings exist (VS)? Godot 4.7 API for the OS setting NOT SOURCEABLE | ux-designer | Accessibility Options GDD (VS) | MVP: toggle only (decided 2026-10-16) |
| 3. `ui_scale` 2.0 with the 32 px editor base = 64 px effective — narrow the knob range? (workbench OQ9) | systems-designer | Workbench UX spec | — |
| 4. Player journey map (`design/player-journey.md`) does not exist; arrival context for screens is assumed | ux-designer | Before `/ux-review` of the workbench spec | — |
| 5. Is the 2.5 s minimum `reaction_hold` long enough for the zero-SQL group? | ux-designer | Zero-SQL playtest | — |
