# Art Bible: SQLbini

> **Status**: Draft
> **Owned By**: art-director
> **Last Updated**: 2026-10-14
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-10-14 — lean mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**Direction: "Behind the Counter" (revised: evening shift)**

**One-line visual rule**: *Everything looks like it belongs behind a konbini counter in the evening: warm paper, wood and cardboard around the work, with the data on top of it all and always legible.*

SQLbini has two registers, and the rule governs both. The **world** is a 320×30 native-pixel counter strip shown at ×4 integer scale (1280×120 px, nearest filtering), with NPCs and a speech bubble. The **work surface** is the SQL editor and result tables, which are undecorated, high-contrast and set in non-pixel fonts. The world carries warmth and character. The work surface carries the data. They share one palette family, so the player reads them as one store.

### Supporting principles

**1. Data reads first** *(serves Pillar 1: The Condition, Not the Screen)*
The player must read the condition and the data exactly, because that is the whole puzzle. Any decoration that costs legibility is removed. Text contrast is at least 4.5:1 (`contrast_min`) in every theme and state. Glyphs, borders and focus rings are at least 3:1.
*Design test*: when a decorative texture, pixel flourish or accent colour competes with a result row or query character, choose **the plain, high-contrast version**.

**2. Store paper as UI** *(serves Pillar 4: Real Store, Real SQL)*
The interface is made of objects a konbini actually has. Results print as receipt paper, errors arrive as sticky notes, passes get a hanko-style stamp, and shelf labels name the tables. This keeps every request and every result feeling like store business rather than edu-software. The paper stays flat and undecorated wherever SQL text or tables sit on it.
*Design test*: when a UI element needs a frame or container, choose **the paper or object a konbini would use**, not a generic panel.

**3. Warm, quiet, and fast** *(serves Pillar 3: Fast Hands, Cheap Mistakes)*
The mood is slightly aesthetic and cozy: soft evening light, a calm store, no neon chaos. Because running a query is instant and free, the visual feedback must be quick and light too. Ambience never delays or hides feedback on the player's action.
*Design test*: between more atmosphere or motion and faster, calmer feedback, choose **faster feedback**. Motion exists only to answer a player action (or the game's direct response to one). Documented exceptions are listed once, in Section 7.6: the idle eye blink, the 300 ms between-shift palette crossfade and the skippable bubble typewriter; all are off under reduced motion.

### Colour guardrails (carried into Section 4)

The base is warm cream receipt paper, wood and cardboard browns, and soft lamp-amber light. One fictional chain accent colour provides brand identity. Green and red are reserved for the Submit verdict (pass/fail); grid row marks (match/extra/missing) use neither, so a matching Run can never look like a PASS. Colour is never the only signal: every state also carries a glyph and a word. Japanese flavour (いらっしゃいませ on the sign) stays in decoration only, and all gameplay text is English.

### What changed from the concept anchor

- The one-line rule changed from "Every UI element looks like something you'd find behind a konbini counter" to the evening-shift version above. It now names the warm materials and covers the two registers (pixel world strip plus clean work surface).
- "Quiet fluorescent calm" was replaced by "Warm, quiet, and fast", anchored to Pillar 3; its test prefers faster feedback over atmosphere.
- The colour philosophy changed from "off-white receipt paper and cool fluorescent neutrals" to warm cream, wood/cardboard and lamp-amber neutrals, and adds the 4.5:1 text and 3:1 non-text contrast floors.
- "Data reads first" and "Store paper as UI" keep their wording; each now names its pillar (1 and 4), and "Store paper as UI" adds the rule that paper stays flat under SQL text. The green/red reservation is narrowed to the Submit verdict only (rows used it before; see Section 4.5). The accent colour, never-colour-alone and the Japanese-in-decoration-only rule are unchanged.

## 2. Mood & Atmosphere

Mood in SQLbini comes from two things only: **the shift sets the light, and the game state sets the scene.** Both live in the 1280×120 counter strip and in a few paper accent objects. The work surface (editor, result grids, fonts, UI colours) looks the same in every shift and state. This is the visual form of Principle 1 (Data reads first): a player who has learned where to look and how the data looks never has to re-learn it because the time of day changed. Dialogue AC RD-14 already tests this ("editor colours are identical in all three").

Section 1 calls the identity "evening shift". The warm materials and lamp-amber warmth hold throughout, and the Closing shift is the signature look used for key art and the store page. Morning and Afternoon are lighter variations of the same warm store, not different places.

### 2.1 Shift lighting (Chapter 1, "Day One")

The light changes only through a palette swap on the strip (Section 4.3), never through repainted art. The swap happens on the shift-start card, between shifts, as a 300 ms crossfade, or instantly under reduced motion. During a shift the light never changes, so nothing ambient competes with a query.

| Shift | Requests | Time of day | Light character | Colour temperature | Strip contrast | Descriptors |
|---|---|---|---|---|---|---|
| **Morning** | 1-1 to 1-3 (onboarding) | ~7–10 am | Pale yellow sun through the window, lamp off. Flat, even light with soft cool-grey shadows | Neutral-cool (~5500 K feel); shadows lean blue-grey | Lowest. High-key, values bunched near the top | fresh, unhurried, open, gentle |
| **Afternoon** | 1-4 to 1-7 + S-1 | ~1–4 pm | Hazy daylight, lamp on but weak. Warm neutral, the "default store" | Warm-neutral (~4500 K) | Medium. Wood and cardboard read clearly | steady, busy-but-calm, familiar, warm |
| **Closing** | 1-8 to 1-11 (boss) + S-2 | ~7–10 pm | The amber lamp is the key light, the window is dusk blue, and long cast shadows cross the back wall | Warm key (~2700 K lamp) against a cool window (~8000 K dusk), a complementary warm/cool split | Highest. A lamp pool around the speaker, with the edges falling off | intimate, golden, quiet, focused, a little wistful |

The warm/cool split in Closing is the one deliberate colour drama in the game. It uses complementary contrast (amber against dusk blue), so the scene feels like evening without lowering the strip's overall value much. The speaker niche always stays lit (Section 3.2).

### 2.2 Game states

Energy is on a 1–5 scale (1 = still, 5 = the most motion and contrast the game ever uses; nothing goes past 3). The "mood carrier" is the element that has to change for the state to read as distinct. Everything else stays still.

| State | Emotional target | Strip: scene (light = current shift) | Descriptors | Energy | Mood carrier |
|---|---|---|---|---|---|
| **Chapter list / title** | "My shift sheet." Calm choice, no pressure | Empty counter, nobody in the niche, lit for the next shift to be played. After End of day, the sign shows "Closed" | still, orderly, inviting | 1 | Empty niche + clipboard (paper) |
| **Shift start (briefing)** | Clocking in. Small readiness, "here's today" | Palette swaps to the new shift. Tanaka in the niche, square reaction bubble style for the briefing line | settling-in, friendly, clear | 2 | The light change itself (the only moment it happens) + Tanaka |
| **Request arrives** | Curiosity: "what do they need?" | Requester enters the niche (whole-pixel 4-frame step-in, instant under reduced motion). The square ticket bubble appears with its REQUEST tab | expectant, personal, concrete | 2 | Ticket bubble shape + a new silhouette |
| **Working in the editor** (baseline, ~90% of play time) | Absorbed focus. The store waits for you | Requester holds a neutral pose in the niche. The only idle change is a 1-frame blink about every 4 s (no breathing bob; none under reduced motion) | hushed, patient, steady | 1 | The *absence* of change. The lamp-amber caret is the only "light" on the work surface |
| **Run result** | Quick private check: "let me look" | **Strip does not change.** Run is the player's scratchpad, so nobody at the counter reacts | brisk, light, private | 1 | Result receipt + pencil tally note ("≈ Looks right today (not checked)") |
| **SQL error** (Run or Submit) | "Oops, try again." Cheap mistake (Pillar 3), never alarm | On Run: Kenji leans into the side slot (puzzled lean). On Submit: the requester goes to the puzzled pose. Light unchanged | low-stakes, wry, helpful | 2 | Jammed register strip at the editor (ink only, ⚠, dashed jagged edge) |
| **Hint open** | A coworker leaning over, not an answer key | Kenji in the side slot, neutral-helpful pose | warm, supportive, quiet | 1 | Folded note beside the editor, with Kenji's rounded name tag |
| **Submit PASS** | Closure and quiet pride: "done right" | Requester switches to the pleased pose (instant swap). No light change, flash or particles | satisfying, dry, earned | 3 (the peak) | Vermilion hanko stamp + green "✓ ACCEPTED" line |
| **Submit FAIL / trap** | Curiosity, not punishment: "huh, what did I miss?" (Pillar 1) | Requester switches to the puzzled pose with the "?" tick. Light unchanged | puzzled, intrigued, fair | 2 | Sticky note (yellow) with "? Not accepted" tab. **No stamp** |
| **Constraint challenge** (offer, attempt, clear) | A playful dare from a coworker | Offer: requester pleased plus a small rounded offer bubble. Attempt: the strip stays at baseline | playful, light, optional | 2 | Paper rule tag above the editor; on clear, a smaller star hanko next to the PASS stamp |
| **Boss request (1-11)** | Focused stakes at day's end, still cozy | Closing light. Tanaka in the niche; a deeper lamp pool is already part of the Closing palette (no extra effect) | focused, golden, serious-but-kind | 2 | The Closing light + the manager as requester |
| **End of shift / payslip** | A soft, rewarding pause, "a good place to stop" | Niche empties and the door bell sprite rests. After the Closing shift the sign flips to "Closed" (a 1-frame sprite swap) | content, unwinding, cozy | 1 | Payslip receipt (✓ / ↷ / ★ lines, wage) |
| **Onboarding first shift** (Morning, 1-1 to 1-3) | A friendly manager beside you on day one: one thing at a time | Morning light, Tanaka in the niche. Lowest strip contrast in the game | gentle, guided, reassuring | 1 | Dashed-ink coach ring + paper tag with Tanaka's name tag |
| **Message log / manual open** (overlay) | A glance at notes, then back to work | Strip unchanged under a 50% ink scrim (log), or uncovered (manual sits beside the work) | reference, calm | 1 | Ledger roll / ring binder paper |

### 2.3 Rules that keep states distinct and the work constant

- **Distinctness comes from the strip and the paper accents only:** which silhouette is in the niche or side slot, its pose, the bubble shape (square ticket vs rounded), one prop state (sign, door bell), and which outcome object appears. No two adjacent states share the same carrier.
- **Forbidden as mood carriers:** tinting, dimming, vignetting or texturing the editor or grids; screen shake, flashes, particles, confetti; any light change during a shift; any change on Run beyond the receipt and tally note.
- **Motion budget:** state changes are instant swaps or ≤ 200 ms moves, and each one answers a player action (Principle 3). The exceptions (between-shift palette crossfade, character blink, bubble typewriter) are listed in Section 7.6. There is no breathing bob, and the bubble's "▸" paging chevron is static.
- **The Closing shift may be darker in the strip, never under text.** The speech bubble, tabs and log button are opaque UI-layer paper, and the shift palette never touches them.
- **Visual mood the audio should match** (audio owns the actual audio choices): Morning reads airy and bright, Afternoon steady, Closing hushed and golden. A PASS should feel dry and final, a FAIL soft and curious.

## 3. Shape Language

The shape language uses three families with fixed meanings:

| Family | Means | Where |
|---|---|---|
| **Square-cornered rectangle** (0–2 px radius) | Printed store business: data, rules, official paper | Editor, grids, receipts, tickets, shelf labels, sticky notes, register strip, clipboard, binder, buttons |
| **Rounded shape** (≥ 8 px radius) | A person talking or feeling | Reaction bubbles, speaker name tags, the challenge offer bubble |
| **Circle / star seal** | Approval, completion | Hanko stamp (PASS), star hanko (challenge clear), ★ chapter star. **Nothing else on the work surface is circular** |

This grammar serves Pillar 4 (Real Store, Real SQL): the player reads "paper the store prints" and "a person talking" before reading a word. It serves Pillar 1: a seal can only mean an accepted Submit, so no other UI shape can be mistaken for success.

### 3.1 Character silhouettes (counter strip, 30 px tall)

**Philosophy.** Every character must be identifiable as a solid ink silhouette at native resolution (24×28 bust, 1× scale), the same shape test used for fighting-game rosters. Each one has **one distinguishing trait that breaks the silhouette outline**, plus a different head-top height (≥ 3 px apart), so the cast reads by shape and height before colour or face pixels. Face detail is 3–5 pixels and never carries identity on its own. Staff (Tanaka, Kenji) wear the chain-indigo apron. Customers never do, so "store vs public" is a colour block readable at a glance, backed by the shape trait.

| Character | Shape family | One distinguishing trait (breaks the silhouette) | Head-top row (native y) | Posture | Pillar link |
|---|---|---|---|---|---|
| **Manager Tanaka** | Rectangles: square shoulders, flat-top short grey hair | **Clipboard** held at the chest, sticking out past the shoulder line. It echoes the chapter-list clipboard: he owns the shift sheet | y = 1 (tallest) | Upright, centred | P4: a real manager with a real shift sheet |
| **Kenji** | Triangles / diagonals | **Spiky hair tuft** (2–3 px triangle off the crown) | y = 4 | Leaning about 2 px off vertical, the only diagonal body in the cast | P3: quick, helpful, the voice of cheap mistakes and hints |
| **Mrs. Sato** | Circles | **Round hair bun** (5×4 px) on top of the head, rounded cardigan shoulders | y = 10 (shortest) | Slightly stooped, soft curves | P4: a believable regular with half-remembered requests |
| **Customer** (generic) | Plain neutral oval/rectangle | **Cap with brim**, a 1-px horizontal bar sticking out past the forehead line | y = 7 | Upright, slightly off-centre | P4: "anyone who walks in". Neutral by design, palette-variant only |
| **HQ** | Paper (rectangle) | **No body.** A 32×20 printed slip propped on the counter in the niche: perforated (zigzag) top edge plus a small stamp mark | — | Static | P4 / Principle 2: HQ *is* paper, so it speaks in the UI's own language |

**Expressions are silhouette changes, not face-pixel changes** (dialogue GDD):

| Expression | Silhouette change |
|---|---|
| Neutral | Base pose |
| Pleased | Head up 1 px, shoulders up 1 px, eyes closed into arcs |
| Puzzled | Head tilt (top shifts 1–2 px sideways) + a 3×5 "?" tick above the head |

Swaps are instant. **Outline**: ink-brown, **1 native px** (= 4 screen px at ×4) for every character. A 2-native-px outline would take about a third of a 24-px-wide bust and swallow the traits above.

### 3.2 Environment geometry (320×30 strip)

The strip is built from **horizontals**: counter top, shelf lines, the lower edge of the noren. Horizontal lines read as stable and calm (Principle 3: quiet), and they repeat the horizontal rows of the result grids below, so the two registers share a rhythm. Verticals are limited to the window frame, the lamp cord and the back-room door jamb. **The only diagonals in the environment are the Closing-shift cast shadows.** That makes them the shift's signature and keeps every other shift calm.

**Zone map (native px, left → right):**

| x range | Zone | Rule |
|---|---|---|
| 0–31 | Window (time of day) | Never behind a speaker or bubble. Its dusk-blue value fails contrast against the outline (Section 4.4) |
| 34–59 | Side slot (Kenji's lean-in) | Plain wall behind; no shelves |
| 64–103 | **Speaker niche** + hanging lamp above | Plain wall panel only. No props behind a head or shoulders, so silhouettes always sit on a light, flat field |
| 104–231 | Shelves of tins and ledgers (mostly behind the bubble) | Small repeated rectangles (tins 3×4, ledgers 2×6). At most 3 value steps near the bubble |
| 232–319 | Back-room door with vermilion noren; UI tabs and log button sit over it | Low detail, so the cream UI tags sit on a quiet field |
| y 22–29 | Counter (top highlight row at y 22) | Covers the lower part of every bust |

The counter is the strongest horizontal and the strip's base. It visually "holds up" the conversation, as the editor holds up the work below.

### 3.3 UI shape grammar (work surface and UI layer)

Every container is a konbini object (Principle 2 / Pillar 4). The surfaces that hold SQL text or table data are flat, axis-aligned and untextured (Principle 1). **No element that carries text is ever rotated.** "Angled" or "torn" paper is drawn as a cut corner or edge, not as rotation. The one exception is the hanko stamp, which may sit at ±3°: its lettering is decorative, and the "✓ ACCEPTED" line beside it carries the meaning.

| Object | Shape | Signature detail | Carries |
|---|---|---|---|
| **Request ticket** (bubble) | Square-cornered rectangle | Notched ticket-stub edge + "REQUEST" tab | The condition the player must meet |
| **Reaction bubble** | Rounded rectangle (8–10 px radius) + tail | Speaker's rounded name tag; static "1/3 ▸" paging (the chevron does not blink) | A person's reaction |
| **Result receipt** | Tall rectangle | Zigzag (perforated) bottom edge | Run/Submit feedback; PASS stamp lands here |
| **Payslip** | Same receipt form, wider | Wage line under a dashed tear rule | End-of-shift summary |
| **Sticky note** | Square | One folded-corner triangle at top-right + a top tab label | FAIL (grader), "watch out" (manual), "not within the challenge". Its meaning is in the tab word, not the paper |
| **Hanko stamp** | **Circle** (PASS) / **star** (challenge clear) | Double ring, ✓ inside, "OK / 合格" lettering (decorative Japanese) | Acceptance only |
| **Pencil tally note** (Run) | Small rectangle, **dotted** outline | "≈" glyph, graphite colour | "Looks right today (not checked)". Never a circle, tick-stamp or green |
| **Jammed register strip** (error) | Narrow rectangle | Jagged dashed border + ⚠ | SQLite error text, monospace |
| **Shelf label** (schema browser) | Wide, short rectangle | 2 px darker "price-rail" band on top | Table name; column chips beneath |
| **Column chip** | Small square tag | Type letter at the left | Column name. Square, not a rounded pill (rounded = people) |
| **Folded note** (hint) | Rectangle split by a centre fold line | Two panels "Hint 1 — the idea" / "Hint 2 — the shape" | Kenji's hint |
| **Clipboard** (chapter list) | Rectangle | Clip at top centre | Shift checklist |
| **Ring binder** (manual) | Rectangle | Ring holes down the left edge | Manual pages |
| **Rule tag** (challenge) | Small rectangle | Eyelet hole + string at the left | "No OR", "≤ 60 characters" |
| **Coach mark** | Rounded-rect ring following the target + a paper tag | **Dashed** ink line (solid is reserved for focus) | Onboarding guidance |
| **Buttons** | Rectangles, 2 px radius | Submit = the only filled-accent (indigo) button; Run = outlined paper | Actions |

**Glyph vocabulary.** Each glyph has exactly one meaning and always comes with a word:

| Glyph | Meaning |
|---|---|
| ✓ | Satisfied / accepted |
| ? | Not accepted / puzzled |
| + | Extra row |
| − | Missing row |
| ⚠ | Error |
| ≈ | Looks right on today's data (unchecked) |
| ↷ | Left for later |
| ★ / ☆ | Challenge cleared / challenge not met |
| ! | Watch out |
| ● | Recording (playtest builds) |

### 3.4 Hero vs supporting shapes

| Tier | Shapes | Treatment | Why |
|---|---|---|---|
| **Hero** | Editor block and the two result grids | Largest areas, plainest shapes, highest contrast (13–15:1), no decoration | Pillar 1: the condition and the data *are* the game |
| **Moment hero** (appears after an action) | Stamp, sticky note, register strip, tally note | Small, but the only new shape on screen at that moment; placed beside the data, never over it | Pillar 3: feedback is read instantly because nothing else moved |
| **Strip hero** | The speaker silhouette + bubble | On a plain lit niche; the bubble is the only large paper in the strip | Pillar 4: a person with a reason |
| **Supporting** | Shelves, tins, window, lamp, noren, counter | Small repeated rectangles, ≤ 3 value steps, low contrast against each other | Warmth without competing (Principle 3) |
| **Tertiary** | Tabs, log button, shelf labels, chips | Small paper tags, consistent 2 px ink borders | Always findable, never loud |

## 4. Color System

The palette has two parts that share one family. The **world palette** is the indexed 16-colour strip, swapped per shift. The **work-surface palette** is fixed and theme-controlled. Ink-brown, receipt cream, chain indigo and hanko vermilion are exactly the same hex in both, which is what makes the strip and the work surface read as one store (Section 1). Shift colours never reach the UI layer.

### 4.1 Core palette (identity colours)

| Name | Hex | Meaning in this world |
|---|---|---|
| **Receipt Cream** | `#F7F1E3` | Paper. Anything you read from that isn't code |
| **Ink Brown** | `#2B2420` | Printing. All text on paper, all outlines |
| **Counter Wood** | `#9A6B45` | The store's warmth (strip only) |
| **Lamp Amber** | `#F2C46D` | Evening light. In the UI it appears only as the editor caret: the lamp is where you are working |
| **Chain Indigo** | `#2F4B7C` | The fictional chain's brand: aprons, sign, focus ring, Submit button. "The store's action" |
| **Hanko Vermilion** | `#C23B18` | The seal of approval. Stamps only on the work surface |
| **Back-Office Navy** | `#1E2230` | The editor: a dark window into the store's database |

Pass green and fail red are **semantic signal colours, not identity colours**. Both are reserved for the Submit verdict: they appear only in verdict text, and row marks use neither (4.5).

### 4.2 Work-surface / UI palette

| Token | Hex | Use |
|---|---|---|
| `paper` | `#F7F1E3` | UI frame, receipts, bubbles, tags, hint note, binder pages |
| `card` | `#FFFCF5` | Result-grid card background (lifts data above the frame) |
| `zebra` | `#F8F3E9` | Alternate grid rows (7.7% relative luminance below `card`, within the GDD's ≤ 8%) |
| `header` | `#E8DCC4` | Grid header band, shelf-label rail |
| `ink` | `#2B2420` | Body text on paper, outlines, coach ring, error strip text and border |
| `ink_muted` | `#5E544B` | Secondary text, pencil tally (graphite), ↷, locked manual titles, **stale tables** |
| `border` | `#7D6D5C` | 1 px borders on every paper object, grid cards and Run button. Paper on paper is otherwise invisible |
| `editor_bg` | `#1E2230` | Editor |
| `editor_text` | `#F2EEE4` | Identifiers, default code, selected text |
| `syn_keyword` | `#8DB4FF` | Keywords, **bold** |
| `syn_string` | `#F0A866` | String literals |
| `syn_number` | `#6CD3C3` | Numeric literals |
| `syn_comment` | `#9DA3B4` | Comments, *italic* (cool grey) |
| `ghost` | `#A89A7C` | Onboarding ghost text, *italic* (warm khaki) + "shape" label. Hue keeps it apart from comments |
| `selection` | `#44557C` | Editor selection fill. Text inside switches to `editor_text` (Godot `font_selected_color`) |
| `caret` | `#F2C46D` | Editor caret (Lamp Amber) |
| `focus` | `#2F4B7C` | 2 px solid focus ring, always drawn on paper with a 2 px `paper` gap from the component |
| `accent` | `#2F4B7C` | Submit fill, hint "new step" dot, manual "new" tab |
| `pass` | `#245A30` | "✓ ACCEPTED" line; ✓ passed on payslip and chapter list |
| `fail` | `#A3263A` | The FAIL note's tab word "? Not accepted" only |
| `stamp` | `#C23B18` | Hanko stamp, star hanko, ★ on payslip and chapter card |
| `sticky` | `#F8E38A` | Sticky-note paper (FAIL, watch-out, not-within-challenge) |
| `extra_tint` | `#F7E2B0` | "+ extra" row fill |
| `extra_bar` | `#A86A12` | "+ extra" 3 px left bar and "+" glyph |
| `missing_tint` | `#E4E0F3` | "− missing" ghost-row fill |
| `missing_line` | `#5D4F9C` | "− missing" dashed outline and "−" glyph |
| match | none | "✓ match" rows get **no tint**. The ✓ glyph and word are in `ink_muted` in the gutter |
| `scrim` | `#2B2420` @ 50% | Behind the message log (the log panel itself is opaque `paper`) |

**Stale results** (this decides the workbench GDD's open choice): table text switches to `ink_muted`, row marks and tints are hidden, and a "Stale — run again" tag appears. **No opacity reduction**, because opacity makes contrast depend on the background. **No italic**, because italic is reserved for comments and ghost text. Worst stale pair: 6.67:1.

### 4.3 World palette: 16 indices (+ transparent), swapped per shift

Every sprite and tile is painted with these 16 indices. A shift swaps the hex behind each index. Indices 0, 10 and 13 are **fixed** (ink outline and the two brand colours stay recognisable in every light). Index 8 is the **Closing-only cast-shadow trick**: it equals the wall in Morning and Afternoon, so the long diagonal shadows are only visible at Closing, with no extra art. Maximum: **16 colours per frame**, plus transparency.

| # | Role | Morning | Afternoon | Closing |
|---|---|---|---|---|
| 0 | Outline ink (fixed) | `#2B2420` | `#2B2420` | `#2B2420` |
| 1 | Deep shade / dark hair | `#4A4550` | `#4A3A30` | `#3A2A2A` |
| 2 | Wood dark (shelves) | `#6B5446` | `#6E4E36` | `#5E3E2A` |
| 3 | Wood mid (counter) | `#9C7D62` | `#9A6B45` | `#8E5A35` |
| 4 | Cardboard / tan | `#CDB08A` | `#C49A6C` | `#C08A55` |
| 5 | Highlight cream / white hair | `#FAF6EA` | `#F7F1E3` | `#F8DDB0` |
| 6 | Wall (niche, side slot) | `#E9E4D2` | `#E6D6B8` | `#D7B27E` |
| 7 | Wall form shade / grey hair | `#BDB9AC` | `#C9B48F` | `#A9845A` |
| 8 | Cast shadow (Closing only) | `#E9E4D2` (= wall) | `#E6D6B8` (= wall) | `#8C6B4A` |
| 9 | Terracotta (tins, floor tile) | `#B86A4E` | `#B5603F` | `#A34E30` |
| 10 | Vermilion (fixed): noren, sign | `#C23B18` | `#C23B18` | `#C23B18` |
| 11 | Olive (labels, plant) | `#7E8A55` | `#7D7F45` | `#6A6532` |
| 12 | Window sky | `#CFE3EE` | `#D9E2D8` | `#3E4F78` (dusk blue) |
| 13 | Chain indigo (fixed): aprons, sign | `#2F4B7C` | `#2F4B7C` | `#2F4B7C` |
| 14 | Skin | `#EBC3A5` | `#E8B996` | `#E2A877` |
| 15 | Light source (sun / lamp glow) | `#F6EBB0` | `#F2D79A` | `#F5A94A` |

Morning shadows (indices 1 and 7) lean cool grey-violet, and Closing's lean warm brown. That shift of shadow temperature is what makes the time of day legible, even more than the window.

### 4.4 Contrast verification (WCAG 2.x)

Ratios verified by script 2026-10-14 (WCAG 2.x relative luminance).

**Text pairs.** Floor 4.5:1 (`contrast_min`); target 7:1 for body and editor text.

| Foreground | Background | Ratio | Status |
|---|---|---|---|
| `ink` #2B2420 | `paper` #F7F1E3 | 13.55 | ≥ 7 ✓ |
| `ink` | `card` #FFFCF5 | 14.90 | ≥ 7 ✓ |
| `ink` | `zebra` #F8F3E9 | 13.80 | ≥ 7 ✓ |
| `ink` | `header` #E8DCC4 | 11.24 | ≥ 7 ✓ |
| `ink` | `sticky` #F8E38A | 11.88 | ≥ 7 ✓ |
| `ink` | `extra_tint` #F7E2B0 | 11.96 | ≥ 7 ✓ |
| `ink` | `missing_tint` #E4E0F3 | 11.81 | ≥ 7 ✓ |
| `editor_text` #F2EEE4 | `editor_bg` #1E2230 | 13.66 | ≥ 7 ✓ |
| `syn_keyword` #8DB4FF | `editor_bg` | 7.62 | ≥ 7 ✓ |
| `syn_string` #F0A866 | `editor_bg` | 7.91 | ≥ 7 ✓ |
| `syn_number` #6CD3C3 | `editor_bg` | 8.85 | ≥ 7 ✓ |
| `syn_comment` #9DA3B4 | `editor_bg` | 6.28 | ≥ 4.5 ✓ (deliberately below 7: comments are de-emphasised) |
| `ghost` #A89A7C | `editor_bg` | 5.71 | ≥ 4.5 ✓ (deliberately dimmer than code) |
| `editor_text` | `selection` #44557C | 6.39 | ≥ 4.5 ✓ (below 7 only while selected) |
| `ink_muted` #5E544B | `paper` | 6.55 | ≥ 4.5 ✓ |
| `ink_muted` | `card` | 7.20 | ≥ 7 ✓ |
| `ink_muted` | `zebra` (stale rows) | 6.67 | ≥ 4.5 ✓ |
| `ink_muted` | `header` | 5.43 | ≥ 4.5 ✓ |
| `ink_muted` | `sticky` | 5.74 | ≥ 4.5 ✓ |
| `ink_muted` | `missing_tint` (ghost-row values) | 5.71 | ≥ 4.5 ✓ |
| `pass` #245A30 | `paper` | 7.23 | ≥ 7 ✓ |
| `pass` | `card` | 7.94 | ≥ 7 ✓ |
| `fail` #A3263A | `sticky` | 5.65 | ≥ 4.5 ✓ |
| `fail` | `paper` | 6.44 | ≥ 4.5 ✓ |
| `stamp` #C23B18 | `paper` (stamp lettering, ★) | 4.74 | ≥ 4.5 ✓ (narrow margin; do not lighten) |
| `stamp` | `card` | 5.21 | ≥ 4.5 ✓ |
| `paper` #F7F1E3 | `accent` #2F4B7C (Submit label) | 7.71 | ≥ 7 ✓ |
| `accent` | `paper` ("new" tab text) | 7.71 | ≥ 7 ✓ |

**Non-text pairs** (glyphs, borders, focus): floor 3:1.

| Element | Against | Ratio | Status |
|---|---|---|---|
| `border` #7D6D5C | `paper` | 4.42 | ✓ |
| `border` | `card` | 4.86 | ✓ |
| `border` | `header` | 3.67 | ✓ |
| `border` (sticky-note edge) | `sticky` | 3.88 | ✓ |
| `focus` #2F4B7C | `paper` | 7.71 | ✓ |
| `focus` | `card` | 8.47 | ✓ |
| `focus` | `sticky` | 6.76 | ✓ |
| `paper` gap (around the editor's focus ring) | `editor_bg` | 14.05 | ✓ |
| `caret` #F2C46D | `editor_bg` | 9.72 | ✓ |
| `extra_bar` #A86A12 | `extra_tint` | 3.48 | ✓ |
| `extra_bar` | `card` | 4.33 | ✓ |
| `missing_line` #5D4F9C | `missing_tint` | 5.31 | ✓ |
| `missing_line` | `card` | 6.69 | ✓ |
| `stamp` ring | `paper` | 4.74 | ✓ |
| `ink` coach ring / zone rule / UI-tag borders | `paper` | 13.55 | ✓ |
| Strip outline (idx 0) | Wall (idx 6), Morning / Afternoon / Closing | 11.99 / 10.67 / 7.67 | ✓ |
| Strip outline | Wall shade (idx 7), Closing | 4.46 | ✓ |
| Strip outline | Cast shadow (idx 8), Closing | 3.14 | ✓ (narrow margin) |

**Known low-contrast pairs** (below 3:1, or stamp lettering below 4.5:1), and the placement rules that keep them from ever touching:

| Pair | Ratio | Rule that prevents the problem |
|---|---|---|
| `focus` vs `editor_bg` | 1.82 | The ring is never drawn directly on the editor; it always sits on a 2 px paper gap |
| `caret` amber vs `paper` | 1.45 | Lamp Amber is never used on paper in the UI; caret only |
| `card` vs `paper` | 1.10 | Grid cards always carry the `border` |
| `sticky` vs `paper` | 1.14 | Sticky notes always carry the `border` |
| `stamp` vs `extra_tint` | 4.19 | The stamp never sits on a row tint or over a grid. It lands on the result receipt (`paper`, 4.74) |
| `selection` fill vs `editor_bg` | 2.14 | Text selection is a text state, not a boundary or glyph, so the 3:1 rule is not applied. The selected text itself stays at 6.39:1. Raising the fill to 3:1 would push the selected text down to about 4.5:1, so legibility of the text wins (Principle 1) |
| Strip outline vs dusk window (idx 12, Closing) | 1.89 | The window sits at x 0–31; no speaker or bubble overlaps it |
| Strip outline vs dark shelves (idx 2, Closing) | 1.60 | Shelves never sit behind a head or shoulders; the niche and side slot are plain wall |

### 4.5 Semantic colour rules

| Colour | Means | Appears | Never appears |
|---|---|---|---|
| **Pass green** | The grader accepted a Submit | "✓ ACCEPTED" printed line under the stamp; ✓ passed on payslip and chapter list | Run feedback, match rows, live challenge checks, the strip |
| **Fail red** | The grader did not accept a Submit | The FAIL sticky note's tab word "? Not accepted" (text weight only) | Fills, X marks, rows, errors, the strip, playtest label |
| **Hanko vermilion** | Sealed / approved | Stamps, star hanko, ★; in the strip as noren and sign (decoration) | Any text label, warnings, errors, fail states, row tints |
| **Chain indigo** | The store's own controls and identity | Focus ring, Submit, "new" markers, aprons, sign | Outcome signals |
| **Sticky yellow** | "A note for you: look here" (neutral attention) | FAIL note paper, manual watch-out, not-within-challenge note | Pass states |
| **Amber / blue-violet** | Extra / missing rows | Grid row marks | Anywhere else |

**Why green and red stay out of the grid (Pillar 1).** Green and red are reserved for the Submit verdict, and row marks use neither. After a Run, the grids are compared against today's visible target. If matching rows lit up green, a fully matching Run would look like a PASS, which is exactly the "visible result = correct" belief the hidden-data grader exists to break. Red rows next to green rows would also be the worst colourblind pair in the densest part of the screen. Errors (Run or Submit) are **ink only**: a dashed jagged strip and ⚠. Making them red would make the cheapest mistake in the game look like the most serious one (Pillar 3).

**Keeping FAIL apart from the vermilion stamp.** Vermilion `#C23B18` (hue ~12°, an orange-red) and fail red `#A3263A` (hue ~350°, a darker crimson) are about 22° apart in hue and differ in luminance by 1.36:1. Colour alone is not enough, especially for protan and deutan players, who see both as brown. So the separation is mainly structural:
1. **Form exclusivity.** Vermilion only ever appears as a seal shape (circle or star) on the work surface. Fail red only ever appears as a short text label on a rectangular tab. A FAIL never contains a circle, a seal or a filled red area.
2. **Object exclusivity.** A stamp is only ever placed on a PASS. A FAIL is a sticky note, and nothing is stamped (grader GDD).
3. **Position.** The stamp lands on the result receipt; the FAIL note sits beside the result.
4. **Glyph and word.** ✓ and ACCEPTED vs ? and Not accepted.
5. **Strip.** Vermilion may decorate the strip (noren, sign); fail red never appears there. A red-ish thing in the world is never a verdict.

### 4.6 Colourblind risk pairs and required backup cues

| Signal pair | At-risk vision | Backup cue (required) |
|---|---|---|
| PASS green vs FAIL red | Protan, deutan | Never shown together. PASS = circle stamp + "✓ ACCEPTED"; FAIL = sticky note + "? Not accepted", no stamp. Also distinct sounds (audio-director) |
| Vermilion stamp vs fail red | Protan, deutan | Seal shape vs text tab (4.5) |
| Pass green vs ink text | Protan, deutan | ✓ glyph + the word "ACCEPTED" / "passed" |
| Extra amber vs missing blue-violet | Tritan | "+ extra" vs "− missing" in the gutter; solid left bar vs dashed outline; missing rows are ghost rows |
| Extra-row amber vs sticky-note yellow | All (similar hue) | Different objects: a full-width grid row with a bar vs a separate note with a folded corner and a tab word |
| `syn_keyword` blue vs `syn_number` teal | Deutan, tritan | Keywords are bold; numbers are right-aligned in grids; luminance differs (0.46 vs 0.54) |
| `syn_comment` vs `ghost` | All (both dim) | Comments start with `--`; ghost text carries the "shape" label and disappears on typing |
| Focus ring vs coach ring | All | Solid indigo vs dashed ink + paper tag |
| Chapter list / payslip states | All | ✓ passed, ↷ left for later, ★ challenge cleared, ☆ challenge available: always glyph + word |
| Playtest recording | All | Ink "●" + "Recording playtest" (no red; red is reserved) |
| Staff vs customer in the strip | Any | Silhouette trait + height (3.1); the indigo apron is a third cue, not the only one |

### 4.7 Themes

**MVP ships one theme**: a light paper workspace with the dark Back-Office Navy editor, as specified here. **A full dark theme and a high-contrast theme are deferred to Accessibility Options (Vertical Slice)**, the "contrast theme" option in `query-workbench.md` Dependencies. Each new theme must:
- re-run every pair in 4.4 against `contrast_min` (text ≥ 4.5:1, non-text ≥ 3:1);
- keep the semantic rules in 4.5 and every glyph-and-word backup;
- leave the counter strip's world palette unchanged (themes recolour the UI layer only).

## 5. Character Design Direction

SQLbini's cast is small: four drawn people and one piece of paper, all seen as 24×28 busts in a 30-px strip. Character design here means one thing: **who is talking has to be clear in under a second, from shape alone, without slowing down reading the data.** Section 3.1 sets the silhouettes. This section sets who is shown and who is not, how the cast groups into classes, how poses and expressions behave, and what detail survives at 1 native px = 4 screen px.

### 5.1 The player character: never shown

**Decision: the player has no sprite.** The player is the person on the near side of the counter. The counter strip is their view across it, and the work surface (editor, grids, paper) is their hands and their desk.

Why:
- **The work surface already is the player's body.** Typing, Run and Submit are the player's actions, and their results land on paper beside the data (Section 3.4). A player sprite in the strip would be a second, decorative version of the player, and it would compete with the one that does the work (Principle 1).
- **Motion budget.** A visible player would need to react to Run, Submit and stamping. Every one of those reactions would be motion that only repeats feedback already shown on the work surface. Section 2.3 bans exactly that.
- **Strip space.** A 30-px-tall strip has room for one speaker, one side-slot coworker and a bubble. A fourth body would push the cast out of the plain niche (Section 3.2).
- **Anyone can be the part-timer.** With no sprite, there is no gender, age or skin tone to pick, and no character creator to build (scope).

How the player is still present, without a body:
- **NPCs look at the camera.** Every bust faces the viewer, eyes on the player, so each request is addressed to *you*.
- **Indigo is your apron.** Chain Indigo marks staff aprons in the strip and the Submit button on the work surface (Section 4.5: "the store's action"). Pressing Submit is acting in the store's colour, as staff.
- **Paper is addressed to you.** The payslip, the clipboard shift sheet and the stamped receipt are the player's records (Principle 2).

Rejected: hands at the counter edge (adds motion per action and needs skin and sleeve choices); a reflection in the Closing window (cute, but it shows the player and puts detail in the zone that already has the weakest contrast, Section 4.4).

### 5.2 Telling the cast apart at a glance

There are four **classes**: staff, regulars, walk-in customers and HQ. Each class owns a visual marker that no other class uses, and each person inside a class has their own silhouette trait (3.1). This matters most while a **request** is showing: the request ticket has a REQUEST tab but no name tag (only reaction bubbles carry the rounded name tag, 3.3), so at request time the sprite alone says who is asking.

| Class | Members (Ch. 1) | Class marker (exclusive) | Shape family | Where they appear |
|---|---|---|---|---|
| **Staff** | Tanaka, Kenji | Chain-indigo apron (idx 13) covering at least 40% of the visible torso, plus a 2×1 cream name badge (idx 5) at left chest | Rectangles / diagonals (store-like, "printed") | Niche (as requester or briefer); **side slot is staff-only** (Kenji) |
| **Regulars** | Mrs. Sato | A personal clothing colour that stays the same in every appearance, plus a rounded personal trait (bun). No apron, no cap | Circles / soft curves (people) | Niche only |
| **Walk-in customers** | Customer (generic) | **The cap with brim.** Every generic walk-in wears one and no named character does | Plain neutral oval / rectangle | Niche only, 2 px off-centre |
| **HQ** | HQ | No body. A printed 32×20 slip propped on the counter | Paper rectangle (Section 3) | Niche, sitting low on the counter |

**Read order** (what the eye uses first → last). Each step backs up the one before, so colour is never the only cue:

1. **Position**: side slot = Kenji, always. A low paper rectangle on the counter = HQ.
2. **Silhouette trait**: clipboard, spiky tuft, round bun, cap brim (3.1).
3. **Colour block**: an indigo apron means staff; no indigo on the torso means the public.
4. **Head height and posture**: upright / leaning / stooped / off-centre.
5. **Name tag** on reaction bubbles (UI layer), and the voice blip (audio-director).

**Class rules for future characters** (Alpha+ cast must pass these before any art starts):
- A new character's trait must break the outline in a place no current trait uses (chest, crown, top of head, brim line are taken).
- Caps belong to generic walk-ins. Aprons belong to staff. A named regular never wears either.
- No character uses vermilion (idx 10) on clothes. In the world, red-ish means store decoration (noren, sign), never a person (Section 4.5, item 5).
- No character's largest clothing mass uses the wall indices (6, 7). Busts must never blend into the plain niche.

### 5.3 Pose and expression style

**Base posture carries personality. Expressions are small, temporary changes on top of it.** All busts face the front, with the body turned at most one-eighth toward the bubble side. Hands are mostly hidden behind the counter. The one exception is Tanaka's clipboard, held by two skin-coloured 2-px blocks at the chest.

| Pose / state | Target | Silhouette change (3.1) | Face pixels | Timing |
|---|---|---|---|---|
| **Neutral** | Attentive, listening, looking at you | Base pose | Eyes 1×2 or 1×1 ink, no mouth or a 1–2 px idx 1 mouth | Held. About 90% of play |
| **Blink** | Alive, never busy | None | Eyes become a 1-px horizontal line | 1 frame, about 120 ms, every 3.5–4.5 s (jittered so the niche speaker and Kenji never blink in sync). **Neutral only.** Off under reduced motion |
| **Pleased** | Dry satisfaction, "thanks, that's right" | Head up 1 px, shoulders up 1 px | Eyes become closed arcs (3-px ∩ shapes) | Instant swap on PASS / offer |
| **Puzzled** | Curious, "hm?", never upset | Head tilt (top shifts 1–2 px sideways) + 3×5 "?" tick | Eyes unchanged | Instant swap on FAIL / Submit error / Kenji's Run error |
| **Step-in** | Someone arrives at the counter | Whole-pixel horizontal slide into the anchor, with a 1-px shoulder dip on the step frame | Neutral face | 4 frames × 50 ms = 200 ms. Instant under reduced motion |

**Rules:**
- **No in-between frames.** An expression change is one swap, with no tween, squash or easing. A 1-px change at ×4 is a 4-screen-px jump, which is easy to see without animation.
- **There is no talking animation.** Text reveal and the blip show speech. The mouth never flaps.
- **Step-in direction tells where someone comes from.** Customers and regulars come from the left, the storefront side (offsets −6, −4, −2, 0 px). Staff come from the right, the back-room side (+6, +4, +2, 0). Same drawings, different offsets, never flipped. Exit plays the same sequence backwards (instant under reduced motion).
- **Kenji's lean-in** to the side slot is 2 frames over 100 ms: the step frame at −2 px, then the target pose at 0. He never crosses x = 32, so he never overlaps the window.
- **The "?" tick** is one shared overlay sprite. Every puzzled tilt leans **left**, away from the bubble tail, and the tick sits on that side at native y 0–4, 1 px clear of the outline, between the head and the lamp (6.3). On short characters (Sato, Customer) that is above the head. On Tanaka (head top y = 2) it is beside the crown. See the decision flagged with this draft.
- **No horizontal flipping, rotation or scaling of any sprite** (5.4). Light is painted from the upper left (window and lamp are both left of the niche, Section 6), so a flipped sprite would be lit from the wrong side.

### 5.4 "LOD" at 1 native px = 4 screen px

There are no LOD levels. Each character exists at exactly one resolution, and the camera never moves. "LOD" here means **what detail is allowed to exist at that one size.** At ×4, each native pixel is a 4×4 block, so every pixel is a deliberate, visible mark.

**What a bust has to work with:** the drawing is 24×28. The counter (y 22–29) covers its lower part, so only about 14 rows (Sato) to 20 rows (Tanaka) of each bust are ever visible. The head is about 8–9 px wide and the face is about 6×5 px.

| Survives (allowed to carry meaning) | Does not survive (texture at most, never identity) |
|---|---|
| The silhouette trait (at least 3 px breaking the outline) | Fingers, jewellery, glasses frames, buttons |
| Hair mass and head-top shape | Any text on badges or clothes |
| One large colour block per garment (apron, cardigan, shirt) | Patterns finer than 2 px (stripes, checks, prints) |
| Eyes (1–2 px each, 2–3 px apart), the pleased arc, the tilt | Eyebrows as a separate feature; nose detail beyond 1 shade pixel |
| A 2×1 name badge (staff marker as a *colour fleck*, not text) | Facial expressions made only from mouth or eyebrow pixels |

**The 2×2 rule:** any feature smaller than 2×2 native px is texture, not identity. Identity lives in features of 3 px or more that change the outline. **Face detail is 3–5 px total** (two eyes plus at most one mouth or shade pixel) and never carries identity alone (3.1).

**Pixel discipline (all characters, all frames):**
- **1-native-px ink outline (idx 0), closed, on the outside only** (3.1). Interior lines (collar, apron edge, hair parting) use the darker shade of the local material, never idx 0. Eyes are the only interior idx-0 pixels. This keeps the face the darkest point inside the bust.
- **Flat shading with at most three values per material** (light, base, shade). Light comes from the upper left. No pillow shading, no gradients.
- **No anti-aliasing, no sub-pixel positions, no partial alpha.** Every pixel is one of the 16 indices or fully transparent. There are no spare indices for AA anyway, and soft edges would break the palette swap (Section 4.3).
- **No mixels.** Every strip pixel is exactly a 4×4 screen block. Sprites are never drawn at a different scale, rotated (the ±3° hanko is UI layer, not strip), or placed off the whole-pixel grid. The bubble, tick label text and name tags are UI layer (crisp fonts), so they are not pixel art and do not mix densities.
- **Index budget per character:** 0 (outline) + at most 6 more, for example 1 dark hair, 5 or 7 light or grey hair, 13 apron (staff only), 14 skin, 4 skin shade, plus one clothing index. Fewer indices make the bust read more clearly against the strip.
- **Any larger character art** (title, key art, store page) is a separate drawing at its own resolution. It never upscales strip sprites (Section 9 / Alpha+).

**Legibility tests** (every frame must pass all three before handoff):
1. **Ink test:** fill the bust solid idx 0 at 1× and check that the right character name comes to mind (3.1).
2. **Greyscale test:** desaturate the strip in each of the three shift palettes and check that the bust still separates from the niche wall and from Kenji.
3. **Glance test:** show the full 1280×720 frame for 1 s and check that the class (staff, regular, customer or HQ) can be named.

### 5.5 Per-character sheet spec

Each person needs **5 drawings**. The neutral bust fits inside 24×28. Frames are exported on a shared **26×30 canvas** (full strip height, 1 px margin each side) so pleased (head up) and puzzled (tilt) frames share one anchor and swaps never jitter. Provisional file names follow `[category]_[name]_[variant]`; Section 8 sets the final convention.

| Frame | Name (provisional) | Used for |
|---|---|---|
| Neutral | `chr_<id>_neutral.png` | Request, working baseline, hint (Kenji), step-in end frame |
| Neutral blink | `chr_<id>_neutral_blink.png` | Idle blink |
| Pleased | `chr_<id>_pleased.png` | PASS, offer, challenge clear |
| Puzzled | `chr_<id>_puzzled.png` | FAIL, Submit error, Run error (Kenji), rule broken |
| Step | `chr_<id>_step.png` | Frames 1 and 3 of step-in / exit, frame 1 of Kenji's lean-in |

| Asset | Drawings | Exports | Notes |
|---|---|---|---|
| Manager Tanaka | 5 | 5 | Clipboard is part of every frame; head top y = 1 |
| Kenji | 5 | 5 | The same frames are used in the niche (requester, 1-10) and the side slot; he always leans toward the niche, away from the window |
| Mrs. Sato | 5 | 5 | Bun is part of every frame |
| Customer (generic) | 5 | 15 | 3 colourways (A/B/C) remap the cap, shirt and hair indices. Chapter 1 needs 2 (1-5, 1-6); the 3rd prevents back-to-back repeats later |
| HQ slip | 1 | 1 | `chr_hq_slip.png`, 32×20, perforated top edge + stamp mark. No expressions |
| "?" tick | 1 | 1 | `chr_shared_tick_puzzled.png`, 3×5, shared overlay |
| **Total** | **22** | **32** | |

Dev-build fallback for a missing sprite (RD-01: "shows the printed slip"): use the HQ slip *without* its stamp mark, so a missing asset never reads as HQ speaking.

## 6. Environment Design Language

The environment is one place: the inside of a small neighbourhood konbini, seen across its counter in a 320×30 native strip. Its job is to be **warm, believable and quiet**. It tells the player where they are and what time it is, then gets out of the way of the characters and the data. Every rule below exists to protect two things: the characters stay the clearest thing in the strip (Section 5), and the strip never pulls focus from the work surface (Principle 1).

### 6.1 Architectural style: a small, worn, cozy branch

**The building.** An older two-storey corner shop on a residential side street. It was a family shop before it joined a small regional chain, and it still shows that: the chain's colours sit on top of an older wooden interior. The ceiling is low, the walls are warm plaster, the counter is old solid wood, the shelves are wooden, and a cloth noren hangs over the back-room doorway. It is a konbini in function (shelves, register, part-time shifts) but a neighbourhood shop in feel. It is not a bright, white, fluorescent flagship store. (The backstory is a visual brief only; narrative may override the history, but the materials stay.)

| Material | Where | Indices | Character |
|---|---|---|---|
| Plaster wall | Niche, side slot, behind shelves | 6 base, 7 form shade, 8 Closing cast shadow | Flat, warm, the "paper" of the world |
| Old wood | Counter (3), shelves and frames (2) | 2, 3, 4 (top highlight) | Rounded-off edges, a few 1-px nicks |
| Cardboard / tins | Shelf stock | 4, 9, 11 | Small repeated rectangles |
| Cloth | Noren | 10 (+ 9 for one mended patch) | Flat panels with vertical slits |
| Glass | Window | 12 sky, 15 light patch, 1/7 outside silhouettes | No reflections, no glare streaks |

**The fictional chain.** Working name: **[CHAIN NAME — TBD]** (owned by the user / narrative; art only needs the name to fit the sign and the title card).
- **Colours:** Chain Indigo `#2F4B7C` is the brand (aprons, sign, the store's controls). Hanko Vermilion `#C23B18` is the accent (noren, the sign's small mark). Both are fixed indices (13, 10) and never shift with the light.
- **Logo mark (strip size, at most 7×5 px):** an indigo rectangle crossed by two cream horizontal bars, like a shelf or a stack of receipts. It is built from rectangles because rectangles mean store business (Section 3). **It is not a circle and has no dot.** A round red or vermilion mark would read as a hanko, and the seal means approval only.
- **Avoid real chain trade dress:** no tricolour stripes, no milk-can mark, no green/blue horizontal bands, no logo with one bold letter on a coloured band. Indigo + vermilion on cream wood should feel closer to a traditional shop curtain than to a 24-hour chain fascia.
- **Japanese flavour stays decorative:** at 30 px, kana cannot be legible. The sign's open face and the noren carry **abstract kana-like strokes** (2–3 px marks). Legible いらっしゃいませ belongs to the title / key art (Section 7 / 9), never to gameplay text.

### 6.2 Texture philosophy: flat, indexed, hand-placed

**The strip is flat-shaded pixel art painted with 16 role indices** (Section 4.3), at most 16 colours per frame plus transparency.

Why flat and indexed:
- **The light is the palette.** Shifts swap the hex behind each index (Section 2.1). That only works if each pixel is a *role* ("wall", "wall shade", "light source") and not a hand-mixed colour. A painterly blend or a gradient would turn muddy in two of the three shifts.
- **Legibility at ×4.** Each pixel is a 4×4 screen block. Noise and fine texture read as grain right next to the dialogue bubble, which Section 3.2 limits to 3 value steps.
- **Solo scope.** One set of art serves three shifts, and flat colour is fast to draw and easy to fix.

**Rules:**
- **At most three values per material** (highlight, base, shade). Light comes from the **upper left**: the window (x 0–31) and the lamp (left edge of the niche) are both left of the speaker, so one painted light direction holds in every shift.
- **No dithering in the MVP.** At ×4, a checkerboard reads as a visible 4-px pattern, not a blend. Under a palette swap, the two dithered indices can move apart and create a stripe that is only visible in one shift. Value changes are made by switching index on a hard edge.
- **Texture is hand-placed clusters of 2–3 px, used sparingly.** Wood grain is an occasional 2–3 px horizontal dash in idx 2 on idx 3 (at most 1 per 8 px of counter). Plaster has no texture. Cloth texture is the noren slits.
- **No outlines on environment props.** Only characters (and the HQ slip) get the idx-0 ink outline (5.4). Props use their own darkest shade (usually idx 2) as an edge. **This is the main figure/ground rule:** the only near-black closed shapes in the strip are people, so the eye finds them first.
- **No anti-aliasing, no gradients, no pillow shading, no glow or bloom.** Light pools are flat areas of idx 15 or a lighter wall index with hard edges.
- **Index 8 paints only over wall.** Closing cast-shadow pixels (idx 8) may only replace wall pixels (idx 6). In Morning and Afternoon idx 8 equals the wall, so a shadow pixel painted over a prop would punch a wall-coloured hole in it.
- **Cast shadows are hard-edged diagonals at a clean 1:2 step** (1 px across per 2 px down), running down and to the right, away from the lamp and window. They fall only in the shelf and door zones and never reach the niche or side slot (which keeps away the narrow 3.14:1 outline-on-shadow pair in Section 4.4).

### 6.3 Prop density by zone

Density follows the zone map (Section 3.2). It is highest where nothing is spoken (the window), lowest where a person or UI sits. **Near the bubble the strip is busy enough to read as a shop and no busier.**

| Zone (native x) | Purpose | Allowed props | Density limit | Value / index limit |
|---|---|---|---|---|
| **Window** 0–31 | Time of day, storefront | Window frame (2/3), sill; outside: a utility pole + 1-px wires as silhouettes (1/7); light patch on the sill (15); the **Open/Closed sign** hanging inside the glass; the **door bell** at the top of the frame; at most 1 sill item (potted plant, 11) | The densest zone, but at most 4 distinct props | Any world indices; the sign and bell must stay readable against dusk blue (6.4) |
| **Gap** 32–33 | Frame post | Wall / frame only | — | — |
| **Side slot** 34–59 | Kenji's lean-in | **Plain wall.** Panel seam lines in idx 7 at the edges only | 0 props | Wall indices 6/7 only; no idx 8 shadows |
| **Speaker niche** 64–103 | The speaker | **Plain wall panel.** Hanging lamp shade at x 64–70, y 0–3 (left edge of the niche, clear of every head; the bust anchors at x 72–95). Lamp pool = lighter wall, flat | 1 prop (the lamp), never behind a head or shoulders | Wall 6/7, lamp 2/15. No idx 8 |
| **Shelves** 104–231 | "This is a shop", mostly behind the bubble | 2–3 horizontal shelf boards (idx 2); tins 3×4, ledgers 2×6, receipt-roll boxes, cardboard cartons | Items in groups of 3–5 with 1-px gaps, then a 4–8 px empty run. **At most 60% of each shelf length filled.** At most 6 items per 32 px | **At most 3 value steps:** dark (2), mid (3 / 9 / 11), light (4 / 6). No idx 0, 5 or 13 here |
| **Back-room door** 232–319 | Quiet field under the UI tabs and log button | Door frame, the vermilion noren (upper part, flat panels + slits, one mended patch), plain door or wall below | Large flat areas; at most 2 props besides the noren | At most 3 values; UI tags carry their own ink border (3.3) |
| **Counter** y 22–29 | Base of the strip | Top highlight row (y 22, idx 4); one horizontal seam on the front; 1-px nicks. **Counter-top props** (register, tray) rise at most 4 px above y 22 and only where x < 32 or x > 103 | Front stays plain within x 34–103 | Wood 2/3/4 |

**Not in the strip, on purpose:**
- **No wall clock.** Light tells the time; a dial would invite reading exact times, add a circle to the scene and need per-shift art.
- **No readable text** on posters, labels or price tags. They are 2–3 px scribbles and blocks. Readable text belongs to the UI layer.
- **No circles in props.** The only rounded shapes in the strip are people (Sato's bun, shoulders), which keeps Section 3's grammar of round = person or seal.

**Character legibility check against this density:** every character must pass the greyscale test (5.4) against the plain niche and side-slot wall in all three shifts. No character's main clothing mass may use the wall indices 6 or 7 (5.2). The idx-0 outline is used only on characters, so they are the strongest edges in the strip in every shift (outline vs wall: 11.99 / 10.67 / 7.67, Section 4.4).

### 6.4 Environmental storytelling (no text)

The strip tells three stories without words: **what time it is, whether the store is open, and that this store is struggling but loved.** All of it is static (no ambient motion, Section 2.3) and changes only between shifts, or as a single sprite swap that answers a game event.

**Chapter 1 ("Day One"), MVP:**

| Story | How it is shown | Mechanism |
|---|---|---|
| **Shift / time of day** | Sky colour (idx 12: pale blue → hazy → dusk blue); sunlight patch on the sill (idx 15); outside pole and wires going from soft grey to dark silhouette; lamp pool on the niche wall at Closing; diagonal cast shadows across the shelves and door at Closing only (idx 8) | Palette swap only (Section 4.3). No repainted art |
| **Open / closed** | The sign in the window: **Open face** = cream plate (idx 5) with the indigo chain mark and abstract kana strokes. **Closed face** = cream plate with "CLOSED" in a 3×5 pixel face in idx 1 | 1-frame sprite swap after the Closing shift (2.2). The plate is **cream on both faces**, because an indigo plate would disappear against the Closing dusk window (indigo vs dusk blue are almost the same value). The pixel lettering is decorative; the chapter list and payslip carry the state |
| **Someone arrived** | The door bell at the top of the window frame shows its "rung" frame (tilted 1 px) during a step-in, then "rest" | 2-frame prop, synced to the 200 ms step-in; always "rest" under reduced motion |
| **Struggling, but cared for** | Gaps on the shelves (60% fill cap); one strip of tape across a corner of the window glass; a hand-made "staff wanted" paper (blank blocks) on the door wall, which is how the player got the job; a mended patch on the noren (idx 9); 1-px nicks on the counter edge | Static art. **At most 1 wear detail per 32 px, never in the niche or side slot.** "Loved, not dirty": no grime, stains, cobwebs or broken lights |

**Alpha+ hooks (not Chapter 1; listed so the art does not block them):**
- **Store recovery by chapter:** shelves fill up, the window tape is gone, the "staff wanted" paper is replaced by a staff photo. These are cosmetic chapter swaps only and are not tied to any economy, which would break the anti-pillar "NOT a store-management sim".
- **The back room:** from Chapter 2, when the player writes `INSERT` test rows in the back room, the noren could show as held aside. This needs its own design.
- **Seasonal decoration** in the window zone (one prop slot reserved).
- **New regulars** must pass Section 5.2's class rules.
- **Larger key art / title illustration** of the store front (Section 9).

All Alpha+ changes must keep the zone limits in 6.3. The niche and side slot stay plain in every chapter.

## 7. UI/HUD Visual Direction

The UI is the game. About 90% of play time is spent reading the editor and two result grids, so this section mostly sets **legibility rules**, and the konbini look is limited to the containers. All sizes are **base logical px at the 1280×720 canvas and `ui_scale` 1.0**. Wherever a size scales, the effective size is base × `ui_scale` (7.6). How the base canvas maps to the physical window (`canvas_items` stretch, oversampling, integer scaling of the strip) is specified in Section 8.

### 7.1 Screen-space layout, store-object skin

SQLbini has **no diegetic HUD**. Nothing is placed in world space or follows a camera. The layout is a fixed screen-space arrangement owned by `/ux-design`: the strip on top, the editor column on the left, the results column on the right. Section 1's two registers map onto three render layers:

| Layer | What | Rendering | Scales with `ui_scale`? |
|---|---|---|---|
| **World** (pixel art) | The 320×30 counter strip: room, NPCs, sign, door bell | Native pixels ×4 → 1280×120, nearest filtering, whole-pixel positions. **The only pixel art in the game** | **Never.** Fixed at 120 px (`strip_h`) |
| **UI over the world** | Speech bubble, offer ticket, message-log button, Hint / Manual / Back Room tabs | Opaque screen-resolution paper with a 2 px `ink` border and crisp live text, drawn above the strip. Never baked into the pixel art, never transparent over it, never tinted by the shift palette (2.3) | Text and padding only. The strip and the bubble frame stay fixed |
| **Work surface** | Editor, grids, schema shelf, receipt, notes, stamp, panels, coach marks | Flat screen-resolution shapes (StyleBoxes, procedural edges, a few illustrative sprites; Section 8), anti-aliased, **not pixel art**: no pixel grid, no dithering, no nearest-filtered upscaling | Yes (7.6) |

**The bubble rect (user decision, 2026-10-14).** The bubble keeps the Section 3.2 zone map. It spans from the right edge of the speaker niche (x ≈ 104 native, 416 px) to the left edge of the tab cluster (x ≈ 232 native, 928 px), which makes it **≈ 510 × 80 px**. It never covers the niche, the side slot, the window or the tab cluster. The dialogue GDD re-derives `bubble_w` and `bubble_chars_max` from this rect. Pages are split by **measured laid-out text width and height** in the real rect at the current `ui_scale`, never by character count alone. A page never overflows or clips. Rough capacity with Plex Sans at 18 px base: about 2 lines × 49 characters at 1.0, 1 line × about 32 at 1.5, and 1 line × about 24 at 2.0. Larger text means more pages, never a bigger bubble. How the tabs lay out at `ui_scale` ≥ 1.5 is decided in `/ux-design`. Art constraint: tabs may grow leftward over the shelf zone (the bubble shrinks to match), but never over the niche, the side slot or a speaker.

**Store objects in screen space.** Each container is drawn as the konbini object from 3.3, using its **outline detail only** (zigzag edge, folded corner, ring holes, notch). There is **no texture, grain, halftone, fibre or "worn" overlay under any text**: not only under SQL and tables, but under bubbles, tags, notes, receipts, the log and the binder too. Paper is flat fills plus borders. One soft drop shadow (`ink` at 12%, offset 0 / 2 px, blur 4 px) is allowed on floating paper only (sticky notes, open panels, the coach-mark tag) to separate it from the frame. It is never used on the editor, the grids or the receipt body.

**The zone boundary.** A 4 px `ink` rule with a 2 px `paper` line under it runs the full width under the strip (dialogue GDD). No pixel art goes below it, and no work-surface element goes above it except the UI-over-world items listed in the table.

**Detail rules that keep the shape grammar (Section 3) intact at screen scale:**
- The ticket bubble's notch is a **square or V cut** (6×6 px), never a semicircle, because only seals are circular.
- Fixed decoration sizes: receipt zigzag 8 px tooth pitch × 4 px depth, sticky-note folded corner a 12 px triangle, ring holes 6×10 px **rounded rectangles** (not circles), rule-tag eyelet a 6 px square with a 2 px radius.
- These sizes **do not scale** with `ui_scale`. They identify the object, carry no information and are not interactive. Because they stay small, they cost no extra space at 2.0, so they are never simplified.
- **Text safe area:** every paper object has a content rect that excludes its decoration (zigzag, notch, fold, ring-hole column, eyelet and string, shelf-label rail, jagged strip border). Padding = decoration depth + 8 px × `ui_scale`. Text wraps inside the content rect and never runs under a decoration.

### 7.2 Typography

#### Families (decided 2026-10-14)

All faces are SIL Open Font License 1.1 and bundled with the game. **System font fallback is off** (Section 8), so no glyph ever comes from the player's OS.

| Role | Family | Weights shipped | Used for |
|---|---|---|---|
| **Code / data (mono)** | **IBM Plex Mono** | Regular, Italic, Bold | Editor, result and target grids, column-chip names, error-strip text, manual `shape` / `example`, ghost text, and **every inline SQL token in prose** (7.2 rules) |
| **UI / body (sans)** | **IBM Plex Sans** | Regular, SemiBold, Bold | Bubble, receipts, notes, hint, manual body, buttons, tabs, labels, row-mark words, payslip, chapter list, titles |
| **CJK fallback** | **IBM Plex Sans KR**, then **IBM Plex Sans JP** | Regular, Bold. **Not subset**, because players type arbitrary text | Hangul, kana and kanji in player-typed string literals, data values and IME composition, on both chains above |
| **Glyph fallback** | **SQLbini Glyphs** (custom, 7.3) | One weight | The 3.3 glyph vocabulary, first in every fallback chain |
| **Display** | **None.** Titles use Plex Sans Bold | — | Shift-start card, chapter-list header, payslip header |

**Why Plex.** It was drawn as one superfamily across mono, sans and Korean/Japanese, so a Hangul string literal inside a Latin query shares stroke weight and proportions instead of looking pasted in. That matters because the editor accepts Korean and Japanese IME input (workbench rule 16). The tone, engineered and slightly mechanical, reads as "printed by the register" and suits receipts and shelf labels without decoration. Its x-height (about 0.52 em in Sans and Mono) clears the 0.5 em floor, so 14 px reads as 14 px. The mono face has no programming ligatures. **To verify on import:** Plex Sans KR must cover all 11,172 Hangul syllables needed for free IME input. If it does not, add Noto Sans KR (OFL) as the next fallback.

**Font rules (each can be checked on a screenshot):**
- **No pixel font for anything the player must read**: no request, reaction, label, number, code, data, tab, button, name tag, page counter or settings text. No functional text is baked into a texture or sprite either, so it stays live text that scales, is read by AccessKit and stays sharp. Pixel lettering exists only inside the strip art (the いらっしゃいませ sign, the Open/Closed sign) and is decorative. Its meaning, if any, is always carried elsewhere in real text.
- **No handwriting or display face** for functional text. The store-manual binder's headings are printed Plex SemiBold. The "worn binder" feel comes from its shape (ring holes), not its lettering.
- **Real weights and italics only.** No synthetic bold, italic or skew. Mono Italic (comments, ghost text) keeps the Regular advance width, so columns stay aligned.
- **Mono features:** `liga = 0`, `calt = 0`, `dlig = 0`. No smart quotes or automatic replacement anywhere; auto-closed brackets and quotes insert straight ASCII. Use the Plex Mono **dotted or slashed zero** stylistic set (ss03 or ss04, whichever the technical-artist confirms reads more clearly at 14 px).
- **Mono glyph test sheet** (screenshot at 14 and 18 px; every pair must be distinct): `0O 1lI 5S 8B 2Z rn m ' ` " , . ; : - − – _ ( ) [ ] { }`.
- **Inline SQL in prose.** Any identifier, literal or value the player might type, wherever it appears (bubble, hint note, manual, sticky note), is set in Plex Mono at the surrounding text size, in `ink`, on a `header`-filled 2 px-radius run with 2 px horizontal padding (`ink` on `header` 11.24:1). Requests quote values the player must reproduce exactly, and the sans is not trusted to separate 0/O or 1/l/I.
- **Numerals:** mono is tabular by nature. Wherever the sans sets aligned numbers (payslip wage, count line, "3 ✓ · 2 + extra · 0 − missing", chapter list), enable `tnum`. Grid numbers are right-aligned, text left-aligned, and headers align with their column's content.
- **Rendering** (details in Section 8): dynamic raster fonts with oversampling, **not MSDF**; grayscale anti-aliasing (no LCD subpixel); light hinting; subpixel positioning auto. No text shadow, glow or outline on the work surface. Text sits on flat fills only.
- **Case:** sentence case everywhere. ALL CAPS only for ≤ 2-word paper labels that imitate printed stamps or tabs ("REQUEST", "ACCEPTED", "ERROR"), set in SemiBold with +5% tracking.

#### Size hierarchy (base px; effective = base × `ui_scale`)

| Token | Base px | Weight | Line height | Face | Used for | Source |
|---|---|---|---|---|---|---|
| `display` | 32 | Bold | 1.2 | Sans | Shift-start card title, chapter-list day header | This bible |
| `title` | 20 | SemiBold | 1.3 | Sans | Panel titles: manual page, hint note, log, payslip, receipt header | This bible |
| `editor` | 18 (`editor_font_px`) | Regular; keywords **Bold**; comments and ghost *Italic* | 1.4 | Mono | Editor | Workbench knob 14–32 |
| `bubble` | 18 (`font_px`) | Regular | 1.25 | Sans | Request and reaction bubble, offer ticket | Dialogue knob 16–20 |
| `body` | 16 | Regular | 1.45 | Sans | Receipt lines, sticky-note text, hint, manual body, message log, coach-mark label, Run note, payslip lines, Run / Submit labels (SemiBold) | Hint UI Req 4; manual "body size or larger" |
| `table` | 16 (`table_font_px`) | Regular; header **SemiBold** | 1.5 (= `row_px`) | Mono | Grid cells and header, column chips, error-strip text | Workbench knob 14–32 |
| `mark` | 16 (= `table_font_px`) | SemiBold | 1.5 | Sans | Row-mark words in the gutter ("✓ match", "+ extra", "− missing") | Tied to `table`, because a mark belongs to its row |
| `label` | 14 | SemiBold (tabs, name tags, tab words) / Regular (meta) | 1.2 | Sans | Tabs, name tags, count line, "Stale — run again", "shape" label, rule tags, "1/3 ▸", "new" / "later", shortcut hints, "Esc: leave editor" | This bible |
| **Minimum readable** | **14** | — | — | Any | **Nothing that carries meaning is below 14 px base**, CJK included. Effective floors: 14 / 16 / 18 at 1.0, 21 / 24 / 27 at 1.5, 28 / 32 / 36 at 2.0 (label / table / editor and bubble) | Workbench Formulas |

- **The knob clamp applies to the base value only.** `editor_font_px` and `table_font_px` are clamped to 14–32 before scaling. The effective size is base × `ui_scale` and is not clamped again, so the editor is 36 px at 2.0. A 32 px base at 2.0 reaches 64 px, which layout must survive or the knob range must narrow (systems-designer to clarify QW-24).
- **Hierarchy comes from size, weight and the `header` band, never from lowering contrast** below the 4.4 floors. At every scale the editor stays at least one step (≥ 2 px base) above the tables.
- **Paragraph measure** in the manual, hint and log is ≤ 80 characters per line where layout allows, at line height 1.4–1.5. The bubble is exempt because it holds at most 2 lines.
- **Count-line budget:** the grid header row (`row_px`) plus the count line (`label`, ≤ 24 px with padding) fit the workbench's `48 × ui_scale` allowance in `H_table`.

#### CJK and Japanese flavour

- **いらっしゃいませ**, **Open / Closed** (sign) and **"OK / 合格"** (hanko) are **drawn art, not font text**, and are hidden from screen readers. The sign lettering is hand-placed pixels inside the strip (index 5 or 10 on index 13). The hanko lettering is drawn into the stamp sprite, which is screen-resolution art, not pixel art. The stamp's meaning is carried by the printed "✓ ACCEPTED" line (3.3).
- All gameplay text is English (Section 1). CJK appears in fonts only when the player or the data puts it there. Han characters fall back to Plex Sans KR first, then JP. A Japanese reader may see Korean-style forms for a few Han characters, which is accepted at MVP.
- CJK glyphs sit on the same baseline at about full width (≈ 1 em, against 0.6 em for a mono column). **Column alignment in the editor is not guaranteed for CJK text.** Grids are unaffected because cells align independently.

### 7.3 Data rendering: states that must be told apart

| State | Rendering | Contrast |
|---|---|---|
| **SQL `NULL`** | The word `NULL` in mono `ink_muted`, inside a 1 px **solid** `border` box (0 px radius, 2 px inset). Solid because dotted (unchecked) and dashed (missing, coach mark, error) already have meanings, and not italic because italic is reserved | `ink_muted` ≥ 5.43:1 on every grid fill (5.79:1 on `extra_tint`); box `border` 3.91:1 on `extra_tint`, ≥ 3.67 elsewhere |
| **Empty string `''`** | `""` in mono `ink_muted`, no box | As above |
| **The text `'NULL'`** | Plain `ink` text | ≥ 11.8:1 |
| **Leading / trailing spaces** | Only if the grader's `canon` treats them as different (open question for the grader owner). If it does, show a visible-space marker in `ink_muted` at the edges of the value. The marker glyph is added to 3.3 when decided | — |
| **Row tint vs zebra** | A marked row's tint **replaces** zebra (never stacked). The tint and the `extra_bar` run across the gutter and the cells, and stay continuous while cells scroll horizontally | 4.4 |
| **Missing ghost row** | Dashed `missing_line` outline, **2 px**, dash and gap ≥ 4 px | 5.31:1 |
| **Error token in the editor** | **2 px wavy underline** in `editor_text`, offset below the descenders (never cutting `g j p q y _`). Not red (reserved for the verdict), not Lamp Amber (caret only), not dashed (dashed means the error strip's border on paper) | 13.66:1 on `editor_bg` |
| **Caret** | 2 px Lamp Amber bar, **steady, never blinking** (the lamp does not flicker; this also removes a looping motion) | 9.72:1; visible over `selection` |
| **Selection** | `selection` fill, text switches to `editor_text` (4.2) | **Known limitation:** fill vs `editor_bg` is 2.14:1, so low-vision players may misjudge the extent of a selection. Accepted for the MVP theme. The VS high-contrast theme must raise the fill to ≥ 3:1 **and** keep selected text ≥ 4.5:1 |

### 7.4 Iconography

**Decision: the 3.3 glyph vocabulary is real Unicode text, drawn in a custom fallback font.** Strings stay plain Unicode ("✓ match"), so the string tests can search them (QW-09). Glyphs take their colour from the text and scale with `ui_scale`. They are drawn once in one style instead of being taken from whatever font has the code point; with system fallback off, ⚠ ★ ✓ can never turn into **colour emoji**. Accessibility: each glyph + word pair is read once by AccessKit, using the word only ("Extra row", not "plus extra"). `/ux-design` sets the accessible names.

| Glyph | Code point | Source | Note |
|---|---|---|---|
| ✓ | U+2713 | SQLbini Glyphs | Monoline tick |
| ? + ! | ASCII | Plex | The text face's own |
| − | U+2212 (minus, **not** U+002D) | SQLbini Glyphs | Same width as +; distinct from hyphen and en dash in the test sheet |
| ⚠ | U+26A0 | SQLbini Glyphs | Outline triangle with a solid "!". Never a filled yellow triangle |
| ≈ | U+2248 | SQLbini Glyphs | Pencil-like: same stroke, looser waves |
| ↷ | U+21B7 | SQLbini Glyphs | |
| ★ / ☆ | U+2605 / U+2606 | SQLbini Glyphs | 5-point star, filled vs outline at the same size |
| ● | U+25CF | SQLbini Glyphs | x-height solid circle; "Recording playtest" only. Too small to read as a seal |
| ▸ | U+25B8 | SQLbini Glyphs | Bubble paging only, and **static** (2.3). Not reused as a focus or pane marker |

**Drawing spec** (technical-artist builds the font; FontForge, OFL):
- 1000-unit em, with Plex Sans metrics (ascender, descender, x-height), so glyphs sit on the baseline next to Plex text.
- **Monoline stroke of 90 units**, matching Plex Sans SemiBold stems (≈ 1.4 px at 16 px, 2.9 px at 32 px), with square caps and mitre joins (printed, not handwritten). ★ and ● are filled; everything else is stroked.
- Glyph height = cap height (≈ 0.7 em). Advance width 0.75–0.9 em.
- **Colour comes from the surrounding text** (≥ 4.5:1, above the 3:1 non-text floor), except where 4.2 says otherwise: `extra_bar` "+", `missing_line` "−", `pass` ✓ on ACCEPTED, `stamp` ★.

**No drawn icon set at MVP.** Every button and tab is a **word**, optionally led by a vocabulary glyph. There are no icon-only buttons, no hamburger, gear or book icons, and no new glyph without a new 3.3 row (one glyph, one meaning). The only illustrative marks are the hanko stamp (72 px), the star hanko (44 px), the chapter-card ★ and the HQ slip. They are fixed-size, non-interactive sprites (SVG preferred, 2× PNG fallback; Section 8). The stamp has a reserved landing spot on the receipt that never overlaps "✓ ACCEPTED", verdict text or data. Its inner ✓ stays ≥ 14 px tall and ≥ 3:1.

### 7.5 Focus and state visuals

- **Keyboard focus ring:** solid `focus` indigo with a `paper` gap, both **round(2 × `ui_scale`) px** (2 px at 1.0; it scales because it is an accessibility signal, unlike decorative strokes). It is drawn on every focusable control and **never directly on** `editor_bg`, pixel art (any shift), or the vermilion noren (indigo vs vermilion ≈ 1.5:1). Every focusable item keeps ≥ 4 px × `ui_scale` of clear space so the ring never touches a neighbour.
- **Hover ≠ focus** (dual focus): hover darkens the border or underlines the label and never draws indigo. A coach ring (dashed `ink`) and a focus ring (solid indigo) can share a target: focus ring inside, coach ring outside, both fully visible.
- **Strip focus:** when the counter scene has focus, the ring goes around the **bubble paper**, never around pixel art.
- **Focused pane (F6 cycling):** the pane's header shows a 4 px `focus` bar at its left edge and its title switches from SemiBold to Bold, a shape cue as well as a colour cue. "▸" is **not** used for this; it is reserved for paging.
- **Run vs Submit:** Run is outlined paper and Submit is the only filled-indigo button (3.3). A focused Run's indigo ring is accepted (low risk, because fill, label and position differ).

### 7.6 UI motion

**The motion rule.** Motion happens only in answer to a player action or to the game's direct response to one: Run, Submit, edit, click or key, opening or closing, or the next request arriving after the player moves on. Every such motion is **≤ 200 ms** and **moves decoration only, never text**. **Every text-bearing object appears in its final position at full opacity on its first frame**, so no verdict, note, error, Run note or panel text ever waits on an animation. **Under reduced motion, every motion is replaced by its final state.**

**The complete list of exceptions** (supersedes the two-item list in 2.3 for UI purposes):
1. **Shift palette crossfade:** 300 ms, strip only, on the shift-start card. Not action-sized. Instant under reduced motion.
2. **Idle eye blink:** 1 frame about every 4 s, strip only. Not triggered by an action. Off under reduced motion.
3. **Bubble typewriter reveal:** this is text, revealed over up to `reveal_cap` (1.0 s) per `reveal_time`. Any key or click completes it, the full line goes to AccessKit at once, it never applies to verdict or error text, and `reveal_cps` is forced to 0 under reduced motion.

| Event | Motion | Duration | Easing | Reduced motion |
|---|---|---|---|---|
| Run result (receipt, rows, marks, count) | **None.** No print-out scroll, no row-by-row reveal | 0 | — | Same |
| Pencil tally note, "checking…" | None; static text, no spinner | 0 | — | Same |
| **PASS stamp lands** | "✓ ACCEPTED" appears on frame 1. The stamp sprite scales 1.12 → 1.0 with opacity 0 → 1 (120 ms), then settles 2 px down and back (60 ms). Its ±3° angle is fixed | 180 | Drop ease-in (quad), settle ease-out (quad); **no overshoot, bounce or spring** | Stamp in its final state |
| Star hanko (challenge clear) | Same as the stamp, starting 60 ms after it | 180 | As above | Final state |
| **FAIL sticky note** | **Appears in place** | 0 | — | Same |
| Error / jammed register strip | **Appears in place** | 0 | — | Same |
| Panel open / close (hint note, manual binder, message log) | Panel appears and disappears in place; only the log's scrim fades 0 → 50% | 120 open / 90 close (scrim only) | Ease-out / ease-in (cubic) | Instant |
| Hint "new step" indicator | Dot and word appear in place | 0 | — | Same |
| **Coach mark appears** | Label tag appears in place. The dashed ring starts 4 px outset and settles onto its target with a fade (one pulse, once) | 200 | Ease-out (cubic) | Ring in its final state |
| Schema click-to-insert | Inserted text gets a `selection` fill that fades out; the text stays still | 200 | Ease-out | None (QW-22) |
| Hover, press, focus | Instant colour swaps; a pressed button moves 1 px down; **the focus ring is never animated** | 0 | — | Same |
| NPC step-in (strip) | 4 whole-pixel sprite frames at 50 ms | 200 | Stepped | Instant |
| Expression change, sign flip (strip) | Sprite swap | 0 | — | Same |

**Further rules:**
- **One outcome object animates at a time.** The star hanko follows the stamp by 60 ms. A bubble reaction never waits on a work-surface animation, because they run independently.
- **Easings allowed:** linear, quad and cubic in/out. Moves ≤ 12 px. Nothing scales above 1.12.
- **No looping or blinking anything** on the work surface or the UI over the strip: no caret blink, no chevron blink, no pulsing badges. Nothing flashes, and no area changes luminance as a whole (WCAG 2.3.1 is met with margin).
- **Motion never gates input.** Typing, scrolling and pane switching stay live. A new event jumps any running animation to its final state.
- **Reduced motion** must be reachable at MVP, either as a toggle in Onboarding's minimal options panel or by following the OS preference (handed to `/ux-design` and Onboarding). The information shown is identical with and without motion.

### 7.7 Spacing and grid

- **Base unit 4 px, layout rhythm 8 px.** Spacing tokens: `s1` 4 · `s2` 8 · `s3` 12 · `s4` 16 · `s6` 24 · `s8` 32. No other values on the work surface. (The strip uses native pixels, not this scale.)
- **Outer margins and gutters between regions: 16 px**, fixed.
- **Inside paper objects:** 8 px vertical × 12 px horizontal padding, plus the decoration depth on decorated edges (7.1 safe area).
- **Grids:** cell padding ≥ 0.5 em horizontal (8 px at 16 px), text vertically centred, no clipped descenders. Row height = `row_px`. Row-mark gutter fixed at the left. `header` band for the header row.
- **Strokes:** 1 px `border` on paper objects and grid cards. 2 px `ink` on the bubble and UI tags. **Dotted and dashed strokes ≥ 2 px with dash and gap ≥ 4 px** (tally note, missing rows, coach ring, register strip), so they read as broken lines and stay ≥ 3:1. 4 px zone rule. Always whole pixels.
- **Corner radius:** square family 0–2 px, rounded family ≥ 8 px (Section 3), nothing in between.
- **Sticky notes** are square as a minimum aspect only: they grow taller to fit the longest level-1 statement at 2.0. **The hint's folded note** stacks its two panels (horizontal fold) when a panel would drop below about 30 characters per line (expected at ≥ 1.5). The fold line never crosses text.
- **Alignment:** baselines line up across a row of paper objects. Objects snap to the 4 px grid.

### 7.8 How `ui_scale` affects everything

`ui_scale` (1.0–2.0, step 0.25) is a **text-legibility setting, not a zoom**. It is applied to theme font sizes, not to the window's content scale (Section 8). **Anything that holds or surrounds text grows with the text; anything decorative or structural stays fixed.** Scaled values are rounded to whole pixels.

| Scales (× `ui_scale`, rounded) | Stays fixed |
|---|---|
| Every font size in 7.2, and the minimum readable size with them | **The strip: 120 px, ×4 pixel art, every sprite** |
| Glyphs (they are text) | **The bubble frame (≈ 510×80) and its position**; only its text grows, so it pages sooner |
| `row_px`, grid header row, count line (`48 × ui_scale`), cell padding | Outer margins (16 px) and region proportions |
| Row-mark gutter (≈ 90 × `ui_scale`); data columns scroll horizontally under a frozen header and gutter at ≥ 1.5 | Decorative strokes (1 / 2 / 4 px) and dash patterns |
| Focus ring and its gap; clear space around focusables | Decorative edge details (zigzag, fold, notch, ring holes, eyelet) |
| Padding inside text-bearing objects (+ the fixed decoration depth); button and tab heights; minimum targets (32 × `ui_scale`); Run–Submit separation | Stamp (72 px) and star-hanko (44 px) sprites; their meaning is in the text line, which scales |
| Tab labels in the strip (layout at ≥ 1.5 decided in `/ux-design`) | Drop shadow; motion distances and durations |

**Accepted costs at 2.0:** a result grid shows 2 rows and scrolls (workbench; `/ux-design` may add an "expand results" toggle), and a request takes more bubble pages (about 24 characters per page). Art adds nothing to the strip that would need more height.

### 7.9 Readability requirements (testable)

Each requirement below constrains the visual direction and is checked against a retained screenshot in `production/qa/evidence/` (IDs from the ux-designer's review, kept for traceability).

| ID | Requirement | Check |
|---|---|---|
| T-01 / T-02 | Functional text ≥ 14 px base; effective floors 14 / 16 / 18 at 1.0, 21 / 24 / 27 at 1.5, 28 / 32 / 36 at 2.0 | Captures at 1.0, 1.5 and 2.0 |
| T-04 | Body and mono x-height ≥ 0.5 em (Plex ≈ 0.52) | Font spec |
| T-05 | No pixel font and no texture-baked text for functional text | Asset review; AccessKit reads every label |
| T-07 | Text crisp at 1920×1080 and 2560×1440 windows | Captures |
| M-01 | Inline SQL tokens in prose are mono on the `header` run | Hint and request captures with a column name and a value |
| M-02 / M-03 | Mono glyph test sheet distinct at 14 and 18 px; no ligatures or substitutions | Glyph-sheet capture; type `!= <= >= -- '' ""` and check code points |
| M-04 | Comment and ghost italic keep column alignment | Capture |
| M-05 / M-06 | `'삼각김밥'` and `'おにぎり'` render without tofu; ✓ ⚠ ≈ ↷ ★ ☆ never as emoji (machine with Noto Color Emoji installed) | Captures on Windows and Linux |
| M-07 / M-08 | Error underline 2 px wavy `editor_text`, clear of descenders; caret 2 px, steady | `no such column: prise` capture |
| G-01 / G-04 / G-07 | Alignment rules; tint replaces zebra; 2 px dashed ghost rows; NULL / `''` / `'NULL'` distinct | Captures of 1-5 marks and a NULL fixture |
| F-01 / F-03 / F-04 / F-05 | Focus ring sizes, gap and placement rules; hover ≠ focus; pane bar; bubble ring in the strip (Closing shift) | QW-20 at 1.0 and 2.0 |
| P-01 / P-02 / P-05 / P-06 | No text under any decoration at 2.0 with the longest strings; sticky grows; hint fold stacks | Captures at 2.0 |
| P-03 / P-08 | No texture under any text; strip UI opaque paper, untouched by the shift palette | Closing capture with contrast probe |
| P-04 | Stamp never overlaps text; drawn at screen resolution with linear filtering | PASS capture |
| P-07 | Dotted and dashed strokes ≥ 2 px, dash and gap ≥ 4 px, ≥ 3:1 | Zoomed capture |
| R-01 | Verdict, Run note, error and panel text legible in final position on the first frame | Frame capture after Submit |
| R-02 / R-03 / R-06 | Reduced motion makes everything instant; nothing loops or flashes; chevron static | Frame captures with the toggle on |
| S-01 / S-03 | Bubble pages measured, never clipped (40 W-heavy characters at 2.0); nothing is carried only by pixels | RD-11 at 2.0; greyscale capture |
| H-04 | Decorations are not interactive and never intercept clicks | Click-through test |

**Handed to `/ux-design`** (interaction and layout, not visual direction): G-02 (row-height formula, already in the workbench), G-03 (sticky header, stale tag and count line while scrolling), G-05 / G-06 (gutter and horizontal scroll behaviour), G-08 (trailing spaces; needs the grader owner), G-09 (matching column widths across the two grids), F-02 layout, F-06 ("Esc: leave editor" label), F-07 (focus not obscured), F-08 (shortcuts shown on controls, styled as `label` in `ink_muted`), F-09 (overlay focus trap), H-01 to H-03 (hit targets, Run–Submit separation of ≥ 24 px × `ui_scale`, the whole bubble as one target), R-04 (reduced-motion toggle at MVP), R-05 (typewriter and AT), S-02 / S-04 (paging discoverability; strip verified at 2.0), A-01 to A-06 (AccessKit roles, live regions, decorative items hidden, one read per glyph + word pair, `CodeEdit` exposure, grid exposure), and the tab layout at ≥ 1.5 including where the locked Hint condition text goes. S-05 (integer strip scaling on non-16:9 windows) is in Section 8.

### 7.10 Art direction vs readability: conflicts decided

| Conflict | Decision | Why |
|---|---|---|
| Pixel lettering for the cozy world vs legible text | Pixel lettering only inside strip art, decorative. All readable text is Plex | Principle 1; dyslexic and second-language readers |
| Paper texture for the "store paper" feel vs flat surfaces | No texture under any text. Objectness comes from outline details | Textures shift contrast locally; Principle 2's flat-paper rule, extended to all text |
| Handwritten binder headings (store-manual GDD) vs legible titles | Printed Plex SemiBold. No display or handwriting face | Page titles are navigation |
| Torn or angled sticky note (grader GDD) vs no rotated text | Cut corner, no rotation (3.3); appears in place | Only the stamp may tilt, and it carries no required text |
| A tactile slide-in for notes and panels vs reading on the first frame | Text-bearing objects appear in place; only decoration (stamp, coach ring, insert fill, scrim) moves | Pillar 3; feedback is read in one beat |
| Emoji-style glyphs vs one glyph language | Custom glyph font, system fallback off | Emoji bring colour and style the semantic rules (4.5) forbid |
| An 880 px bubble (dialogue GDD) vs the strip zone map | Zone map kept; bubble ≈ 510 px; measured paging (user decision) | Keeps the niche and tab zones; more pages at large text is the accepted cost |
| Decorations shrinking work space at 2.0 vs object identity | Decorations fixed and small, with text safe areas; no simplification needed | They cost the same few px at every scale |
| A printing-receipt animation on Run vs the 200 ms result budget | Results appear instantly. Only the PASS stamp has weight | Pillar 3; workbench p95 budget |
| Blinking caret (editor convention) vs no looping motion | Steady Lamp Amber caret | 2.3's motion budget; the lamp is steady |
| Selection-fill contrast (2.14:1) vs selected-text legibility | Text legibility wins at MVP; recorded as a known limitation for the VS high-contrast theme | 4.4 decision; low-vision concern recorded |

## 8. Asset Standards

Section 8 sets how art is made, named, stored, imported and shown in Godot 4.7.2. It merges the art-direction rules with the technical-artist's engine constraints. Engine claims carry the technical-artist's evidence tags: **[ER]** means documented in `docs/engine-reference/godot/`. **[CR]** means the member exists in the installed 4.7.2 class reference, but its behaviour has not been confirmed by a prototype. **[UNVERIFIED]** means training data only and must be verified before anyone relies on it.

Two asset families follow two different rules, matching the two registers in Section 1:

| Family | What | Rule |
|---|---|---|
| **Strip art** (pixel) | Characters, the HQ slip, the "?" tick, environment layers and props | Authored at native 1× using only the 16 world indices (4.3). Shown through a palette shader at the largest whole multiple that fits the strip slot. Nearest filtering, binary alpha, whole-pixel positions |
| **UI art** (paper) | Paper objects, hanko stamps, glyphs | Vector or procedural first. Rasters only for illustrative marks. Colours from 4.2 only. Never carries functional text |

### 8.1 File formats

| Asset | Source (kept in the repo) | Runtime file | Notes |
|---|---|---|---|
| Strip sprites and layers | Aseprite `.aseprite`, **Indexed colour mode**, palette slots 0–15 in exact 4.3 order | **Index-map PNG** made by the pipeline script (8.7). RGBA, `R = idx × 17`, G = B = 0, A = 0 or 255 | Index maps are generated output and are never edited by hand. Opened outside the game they look dark red. In the editor they look correct because the shader runs there |
| World palette | `pal_world_[shift].gpl` + `.hex` (artist swatches) | `pal_world_shifts_lut.png`, 16×3 (one row per shift: Morning, Afternoon, Closing) | All three are **generated from the 4.3 table** by the same script. The art bible is the source of truth, so a mismatch is a bug in the file |
| UI palette | `pal_ui.gpl` + `.hex` | none | Reference for drawing UI marks. The runtime colours live in the Godot Theme, built from the 4.2 tokens |
| Paper bodies and borders | none | Theme `StyleBoxFlat` | Receipts, tickets, sticky notes, labels, chips, buttons and bubbles. Vector and crisp at every scale and in every theme (4.7) |
| Paper signature edges | none | Procedural `_draw()` polygons | Zigzag perforation, ticket notch, folded corner, ring holes, eyelet, dashed tear rule. Hand-drawn nine-patch PNGs are an opt-in exception only (8.10) |
| Illustrative marks | `.svg` master | SVG imported as `DPITexture` ([CR]; behaviour [UNVERIFIED], so prototype it first), fallback PNG at 2× | Hanko, star hanko, clipboard clip, binder rings if drawn |
| Glyphs ✓ ? + − ⚠ ≈ ↷ ★ ☆ ! ● | — | Font text | Glyphs come from a bundled **symbol fallback font**, never from images or the OS (8.8) |
| Fonts | — | OFL `.ttf` / `.otf`, dynamic raster `FontFile` | Body, mono, symbol and **Korean + Japanese fallback** families are all bundled, with `OFL.txt` beside each. The families themselves are chosen in Section 7 |

### 8.2 Naming convention

Files are **snake_case**, lower-case ASCII with no spaces (`project.yaml` → `naming.files`). The pattern is `[prefix]_[subject]_[variant]_[frame].[ext]`. Leave out any part that does not apply.

| Prefix | Category | Examples |
|---|---|---|
| `chr_` | Character frames and overlays | `chr_tanaka_neutral.png`, `chr_tanaka_neutral_blink.png`, `chr_customer_b_puzzled.png`, `chr_hq_slip.png`, `chr_shared_tick_puzzled.png` |
| `env_` | Strip layers and props | `env_strip_back.png`, `env_strip_counter.png`, `env_sign_closed.png`, `env_door_bell_rung.png`, `env_strip_ext_left.png` (later) |
| `ui_` | Illustrative UI marks | `ui_hanko_pass.svg`, `ui_hanko_star.svg`, `ui_clipboard_clip.svg`, `ui_hanko_pass_2x.png` (fallback only) |
| `pal_` | Palettes and the shift LUT | `pal_world_closing.gpl`, `pal_world_shifts_lut.png`, `pal_ui.hex` |
| `font_` | Font files, renamed on import | `font_[family]_regular.ttf`, `font_[family]_bold.ttf` |

- **Frame and variant names** match Section 5.5: `neutral`, `neutral_blink`, `pleased`, `puzzled`, `step`. Customer colourways are letters placed after the subject (`chr_customer_a_…`, `_b_`, `_c_`).
- **Suffixes**: `_2x` only on a UI raster that really ships at 2×. `_9p` on any opt-in nine-patch. Strip art never has a size or shift suffix, because it has one size and the shader does the shifts.
- **The source file and the export share a basename**, so a reviewer can find the source by name alone. One `.aseprite` file per character holds all five frames as **tags with the same names**, and each tag exports one PNG.
- Section 5.5 uses the `chr_` prefix (renamed from its provisional `char_`, 2026-10-14).

### 8.3 Folder layout

```text
assets/
├── art/
│   ├── characters/     chr_*.png (index maps)
│   ├── environment/    env_*.png (index maps)
│   ├── ui/             ui_*.svg / ui_*_2x.png
│   ├── palettes/       pal_*.gpl / .hex / pal_world_shifts_lut.png
│   └── source/         .gdignore: *.aseprite, indexed-PNG exports, *.svg masters
│       ├── characters/
│       ├── environment/
│       └── ui/
└── fonts/
    └── [family]/       font_*.ttf / .otf + OFL.txt
tools/asset-pipeline/   index-map + LUT generator (reads source/, writes art/)
```

The `.gdignore` in `art/source/` stops Godot from scanning or exporting source files. The folders inside each category are flat, which suits an MVP of about 45 files (8.9).

### 8.4 Resolution and display scaling

| Tier | Assets | Authored at | Shown at |
|---|---|---|---|
| **Strip native** | All strip art | 1× native px (strip 320×30) | `k × k` physical px per native px, where `k = max(1, floor(4·s))` |
| **UI logical** | StyleBoxes, procedural edges | Logical px of the 1280×720 base | `s` (fractional) × layout; fonts × `ui_scale` |
| **UI vector / 2×** | Illustrative marks | SVG, or PNG at 2× the logical display size | Linear filtering (+ mipmaps for the 2× PNG) |

**Strip art is never pre-scaled.** A sprite exported at ×4 breaks the index maps, uses 16× the memory, and invites sub-native "fixes" that show up as off-grid pixels.

**Display chain** (engine constraint, [CR]):
- The project uses stretch mode `canvas_items` with aspect `expand` and `fractional` scale, so the UI and fonts render at the full physical resolution with `s = min(W/1280, H/720)`.
- The strip renders into a **320×30 `SubViewport`**, shown in a `TextureRect` with Nearest filtering and the palette shader, at `k = floor(4·s)` physical px per native px. The top-left corner snaps to a whole physical pixel.
- UI elements placed over the strip (bubble, tail, tabs, log button) are positioned through one `strip_to_ui()` helper. They never use hard-coded 1280-based coordinates.

**"120 px" means a 120-logical-px slot.** The GDD's `strip_h` is the slot. The art sits inside it at integer ×k, flush at the top. Any leftover height (less than 1 native px × s) goes into the 4 px ink rule under the strip. Floor, never round up: rounding up would crop the window zone at x 0–31. Results at common sizes:
- **Exact fit:** 1280×720 (×4), 1600×900 (×5), 1920×1080 (×6), 2560×1440 (×8), 3840×2160 (×12).
- **Bleed:** 1366×768, 1440×900 and 1536×864 stay at ×4 and leave 86–256 physical px of side bleed. 21:9 screens bleed 640–880 px.

**Side bleed decision.** For the MVP, the strip is centred and the side bands are filled with the **paper-and-ink frame**. This takes zero art and puts no pixel art at a non-integer scale. **Later polish:** tileable left and right extension columns (`env_strip_ext_left/right`) made from wall, shelf line and counter rows, with at most 3 value steps (3.2), while the window, niche and door stay at fixed x around a centred 320-px core.

**Minimum window** is 1280×720 logical (`Window.min_size`). Below that size the editor font falls under the 18 px readability floor.

**`ui_scale` is applied through Theme font sizes**, not `Window.content_scale_factor`. The latter would rescale the strip. Borders, edges and margins stay in logical px. Only text grows, and containers grow through layout.

### 8.5 "LOD": none, deliberately

SQLbini has no LOD tiers, and adding any would be a defect (see also 5.4):
- **The camera never moves or zooms.** No asset is ever seen "far away". Integer ×k is magnification, never reduction.
- **Pixel art does not survive reduction.** Identity rides on 1-px features (the cap brim, Kenji's tuft, the 1-px pleased lift). A reduced version averages them away.
- **So mipmaps are off for all strip art.** Mipmaps are the engine's LOD, and with index maps they would also blend two indices into a third, wrong one.
- **The legibility tests in 5.4 replace LOD.** The ink, greyscale and glance tests at native 1× are the detail budget.
- **Accessibility scaling is text scaling.** `ui_scale` never calls for a higher-detail art tier.

### 8.6 Character and environment frames

**Characters follow Section 5.5.**
- Each person has **5 drawings**: `neutral`, `neutral_blink`, `pleased`, `puzzled`, `step`.
- Each frame is exported as its own PNG on a shared **26×30 canvas**: full strip height, with 1 px margin each side around the 24×28 bust. Every frame shares one anchor, so swaps never jitter. Each person's head-top row is drawn where it sits in the strip (5.5).
- Totals: **22 drawings, 32 PNGs**. Customer has 3 colourways (A/B/C) that remap the cap, shirt and hair indices. Colourways never use idx 13 (staff) or idx 10.
- HQ slip: 32×20, 1 frame. "?" tick: 3×5, one shared overlay, placed by per-character data (5.3).
- **Blink is neutral-only.** Pleased has its eyes closed already, and puzzled does not blink (5.3).
- **Step-in and lean-in are offsets, not extra drawings.** Step-in uses offsets −6/−4/−2/0 (customers) or +6/+4/+2/0 (staff) with `step` on frames 1 and 3. Kenji's lean-in uses `step` at −2, then the target pose. The animation keys are whole native px with Discrete interpolation. There is no flipping, rotation or scaling.
- **No breathing-bob frames, 1 px outline.** The dialogue GDD §Visual (provisional) still lists a 2-frame bob, a 2 px outline and a blinking "▸". Sections 2.3, 3.1 and 5.3 replace all three. No asset is made for them.

**Environment.**
- Layers are exported as **full 320×30 canvases** so they sit at (0, 0): `env_strip_back` (wall, shelves, window, lamp, door, noren, Closing cast shadows in idx 8) and `env_strip_counter` (foreground, drawn over the busts).
- State props are separate sprites at positions set in data: `env_sign_open` / `env_sign_closed`, and `env_door_bell_rest` / `env_door_bell_rung`.
- Props have no outline (6.2).
- **The strip has no legible text** (6.1, 6.3). The sign carries abstract kana-like strokes.

### 8.7 Palette swap: indexed shader (decided)

**Method: index maps + one palette shader + a 16×3 LUT.**
- One `canvas_item` shader on the strip's display TextureRect reads `index = round(R · 15)` and looks up `LUT[index, shift]`.
- The 300 ms between-shift crossfade is `mix(row_from, row_to, blend)`. Under reduced motion, `blend` goes straight to 1.
- The shader itself belongs to `godot-shader-specialist`.

Why this method:
- Each asset has one file.
- Tuning a shift's hex values is a one-file edit, with no re-export.
- The fixed indices (0, 10, 13) and the Closing-only idx-8 shadow work without extra art.
- A future shift or colourway is one LUT row.

**Pipeline** (`tools/asset-pipeline/`):
1. The artist draws in Indexed mode and exports an **indexed PNG** into `art/source/`.
2. The script reads the **raw palette indices** with Pillow in `P` mode, **not RGB**, and writes the RGBA index map into `art/`.
3. The same script generates the LUT and the `.gpl` / `.hex` files from the 4.3 table.
4. The script **reports** (observations, not verdicts) any pixel using a slot above 15 or with partial alpha.

**Two authoring traps the pipeline must handle:**
- **Aseprite's index 0 transparency.** Aseprite treats palette entry 0 as transparent by default, but 4.3 index 0 is the ink outline. Each source must set its transparent colour to a separate entry (or rely on layer alpha), and the script must take transparency from alpha, never from "index 0". Otherwise every outline disappears.
- **Equal hex in Morning and Afternoon.** idx 8 (cast shadow) has the same hex as idx 6 (wall) in both palettes. If an artist draws in Afternoon colours, a shadow pixel cannot be told apart from wall, and an RGB-reading tool would write the wrong index. That is why the script reads indices. **Draw and preview in the Closing palette**, the only one where all 16 slots look different, and check the other two before export. idx 8 may only replace wall pixels (6.2).

**Strip node rules** (they protect the indices): no rotation, scaling, `modulate`, `Light2D` or `CanvasModulate` inside the strip, and binary alpha only. Any future fade happens inside the shader, never by alpha-blending sprites.

### 8.8 Import and export settings

**Governing rule: the pixel the artist placed is the pixel the player sees.** Every setting that could change a pixel between Aseprite and the screen is off.

| | Strip index maps and LUT | UI 2× PNG fallback | SVG marks |
|---|---|---|---|
| `compress/mode` | **Lossless**. Never VRAM or lossy, because any block compression corrupts indices | Lossless | — |
| `mipmaps/generate` | **off** | on (the hanko rotates ±3°) | per prototype |
| `process/fix_alpha_border` | off | on | — |
| `process/premult_alpha` | off | off | — |
| `detect_3d/compress_to` | Disabled | Disabled | — |
| Filter (set on the node) | Nearest (SubViewport default + TextureRect) | Linear Mipmap | Linear |

- **Aseprite export**: 100% scale, no resampling, no dithering, no colour-profile conversion. Strip art is 1-bit alpha with no anti-aliasing (5.4, 6.2).
- **Project-wide defaults stay as they are**: Linear texture filter, 2D snapping off, `snap_controls_to_pixels` on. Nearest filtering and pixel snapping are switched on **inside the strip SubViewport only**, so fonts and SVGs do not shimmer.
- **StyleBoxFlat**: `anti_aliasing = false` on square paper (0–2 px radius), so borders land on whole pixels. `true` on rounded people-shapes (8 px radius and up).
- **Fonts**:
  - Dynamic raster, no MSDF. Oversampling on. Grayscale anti-aliasing, **no LCD subpixel**. Light hinting, set explicitly. Subpixel positioning Auto. No mipmaps.
  - Mono faces use `liga = calt = dlig = 0`, so ligatures never change SQL glyphs.
  - **`allow_system_fallback = off`**. OS fallback can draw ✓ ⚠ ★ as colour emoji, which breaks the one-glyph-one-meaning rule (3.3) and makes screenshots non-deterministic.
  - Every chain ends with the bundled **symbol font**, then **Korean and Japanese fallbacks**. Players type Hangul and kana into string literals, so these faces cannot be subset. They cost about 5–20 MB on disk and use no VRAM until a glyph is drawn.
- **No functional text in images.** Every request, reaction, label, tab word, glyph and number is a live text node: crisp at every `ui_scale`, translatable, and readable by screen readers. The only lettering baked into art is the hanko's decorative "OK / 合格". Its meaning is carried by the "✓ ACCEPTED" line (3.3).
- **No baked light, shadow or tint** in any sprite beyond its indices. Light belongs to the shift palette (2.1).

### 8.9 Budgets and size limits

The project sets no `performance.*` keys. The fallback values are 60 fps / 16.6 ms and fewer than 500 draw calls. The texture figures below are **proposed and pending `technical-director` confirmation**.

| Budget | Estimate | Proposed ceiling |
|---|---|---|
| Strip art (32 character PNGs at 26×30, layers, props, LUT) | about 0.2 MB | 1 MB |
| UI textures (stamps and marks) | under 2 MB | 8 MB |
| Font glyph caches | 1–10 MB (CJK typing at high `s` is the peak) | 32 MB |
| Render targets beyond the swapchain (strip SubViewport) | about 38 KB | 1 MB |
| **Total 2D texture memory** | under 15 MB | **≤ 64 MB (proposed)** |
| Draw calls | about 10 (strip) + 50–150 (UI) | < 500 |

**Size limits:**
- Strip background: exactly 320×30 (plus extensions later).
- Character frames: 26×30. HQ slip: 32×20. Tick: 3×5.
- Any strip texture: 512² or smaller. UI textures: 1024² or smaller. Nothing above 2048 on either axis.
- Any texture over 1 MB of VRAM needs a stated reason.

**No atlases.** Batching gains nothing at this asset count. Watch two draw-call costs on the work-surface side, not art: one `Label` per grid cell, and bold/regular switching in syntax highlighting.

### 8.10 Art preference vs technical limit

| Topic | Art preference | Technical limit | Trade-off chosen |
|---|---|---|---|
| Palette swap | One source per asset; the 4.3 table is what the game draws | Index maps look red on disk, and indices need binary alpha with no modulate | **Index maps + shader + 16×3 LUT** (8.7). Editor preview is correct through the shader |
| Strip always 1280×120 across the full width | Never a mixel, never cropped (1.0, 5.4) | Whole-pixel scaling at fractional `s` leaves side bleed on 1366, 1440, 1536, 1680 and 21:9 windows | **Integer ×k in a 120-logical-px slot, centred. Paper/ink frame fills the bleed in the MVP**; tileable side extensions are later polish |
| Hand-drawn paper edges | Paper reads as real store paper (Principle 2) | Texture nine-patch margins magnify ×s, so they go soft above s ≈ 1.5 | **StyleBoxFlat + procedural edges.** Hand-drawn nine-patch (`_9p`) only where grain is wanted, accepting softness, unless `DPITexture` proves it can fix this |
| Smooth 1 px paper borders | Clean edges | At fractional `s` an anti-aliased 1 px border blurs to 1.5 px | AA off for square paper (crisp, slightly uneven); AA on for rounded people-shapes |
| Clean ✓ ⚠ ★ glyphs | One glyph, one meaning (3.3) | OS fallback can draw colour emoji | **Bundled symbol font + KR/JP fallbacks; system fallback off** |
| Index 0 = ink outline | The outline must never be keyed out | Aseprite makes index 0 transparent by default | Transparency is a separate entry or comes from alpha, enforced by the script (8.7) |

### 8.11 Verification and per-asset review

**Evidence for the Visual gate**, retained in `production/qa/evidence/`. The scripts report observations only.
- **Integer-scale capture** at 1280×720, 1366×768 and 1920×1080 (plus 2560×1440 if available). The script reports whether every native strip pixel is a uniform `k × k` block.
- **Palette capture**, one per shift. The script reports any strip pixel that is not one of that shift's 16 hex values.
- **Import audit**: lists any strip asset with lossy or VRAM compression, mipmaps on, or a slot above 15.
- **Font check** on Windows and Linux: `✓ ⚠ ≈ ↷ ★ ☆` plus Hangul in a string literal, with no emoji and no tofu (empty boxes).

**Per-asset checklist** (art-director sign-off before commit):
1. Name and folder match 8.2 / 8.3, and a source with the same basename exists in `art/source/`.
2. Strip art is native size and uses slots 0–15 only, with at most 7 indices per character (5.4). Alpha is binary. idx 8 sits only over wall.
3. A character frame is on the 26×30 canvas with the shared anchor and passes the ink, greyscale and glance tests (5.4).
4. Previewed in all three shifts. The outline still reads on the Closing wall shade and cast shadow (4.4).
5. UI art uses 4.2 colours only and contains no functional text.

**Required follow-ups (not art-bible rules):**
- **`project.godot` lacks `display/window/size/viewport_width` / `viewport_height` = 1280 / 720.** Without them the base is 1152×648 and the strip draws at ×4.44. Fix this before any strip work. The owner is whoever owns `project.godot`.
- The dialogue GDD §Visual needs an edit to drop the bob, the 2 px outline and the blinking chevron (8.6).
- The 64 MB texture ceiling needs `technical-director` confirmation, and so does the renderer choice: Forward+ vs Compatibility both work for this art.
- Prototype `DPITexture` (one stamp at s = 1, 1.5 and 3) and the RGBA8 index round-trip ([UNVERIFIED]) before the first art handoff.

## 9. Reference Direction

Five references, each pointing at a different part of the game. Each one gives a specific technique, not a general look, and each has a stated line not to cross. Two inform the strip, one the staging, two the work surface.

| # | Reference | Serves | Take this | Avoid / diverge |
|---|---|---|---|---|
| 1 | **Waneella** (pixel artist; animated Japanese street and shop scenes at dusk and night) | Strip: light | Warm interior light against a cool dusk exterior, made from **flat, hard-edged light shapes**: a lamp pool and window patch as solid areas of one lighter colour, not gradients. This is the Closing shift's amber/dusk split (2.1) | Her ambient animation (rain, flicker, drifting smoke), dense street detail and neon signage. Our strip is static during a shift (2.3), has ≤ 3 values near the bubble (6.3) and has no glow |
| 2 | **Yasujirō Ozu**, e.g. *Tokyo Story* (1953) | Strip: staging | The **fixed, frontal, low camera**: a still set that people step into and out of, with frames inside the frame (doorway, noren). Mood comes from who is present, not from camera moves. That is our niche/side-slot rule (2.2) | Period nostalgia: sepia, black-and-white or mid-century props. The store is present-day and lived-in, not a memory |
| 3 | **Papers, Please** (Lucas Pope, 2013) | Work surface: objects | **Paperwork as the interface.** Each document type is recognisable by its outline, and the stamp *is* the verdict. This is Principle 2 (receipt, sticky note, hanko) | Its grim palette, cramped desk clutter, overlapping drag-and-drop papers and pixel-font document text. Our papers sit in fixed slots, are warm and flat, and carry live Plex text (7.2) |
| 4 | **Swiss / International Typographic Style**, e.g. Josef Müller-Brockmann's *Grid Systems in Graphic Design* (1981) | Work surface: type and grid | Hierarchy built **only from size, weight and alignment on a strict grid**: flush-left text, right-aligned numerals, generous fixed gutters. This is how 7.2 and 7.7 rank information without lowering contrast | The poster side of the style: huge diagonal type, dramatic asymmetry, red/black shock colour. Our work surface is quiet, and red belongs to FAIL only |
| 5 | **Thermal register receipts** (real Japanese konbini receipts) | Work surface: data print | The printed-data idiom: one mono column, dense tabular lines, a bold total, ruled separators, a torn top and bottom. This is the result receipt and the payslip | Real receipt *defects* and *branding*: faded grey thermal ink, curl, low contrast and any real chain's logo or layout. Ours is crisp `ink` on cream at ≥ 4.5:1, with the fictional chain only (6.1) |

**Notes**
- **What the references share** is restraint: still frames, flat light, information carried by structure. The game uses none of them for mood in the editor. The work surface stays the same in every shift (Section 2).
- **Not references, on purpose:** VA-11 Hall-A and cyberpunk neon pixel scenes (the wrong temperature and energy), terminal green-on-black programming-game UIs such as TIS-100 (cold, and they fight the cream paper), and real chain store fronts (trade dress, 6.1).
- **Key art and title** (Alpha+, 6.4) may go further in detail and use legible いらっしゃいませ, but they keep references 1 and 2: flat light shapes and a fixed frontal view of the counter.
- **Check:** a reviewer who knows a reference should be able to name the borrowed technique, not mistake the screen for that work. If a frame could pass as a still from one of these works, apply that row's "avoid" column.

