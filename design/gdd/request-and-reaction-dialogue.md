# Request & Reaction Dialogue

> **Status**: In Review
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14 (2026-10-14 cross-GDD review fixes)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 4 — Real Store, Real SQL; Pillar 3 — Fast Hands, Cheap Mistakes

## Summary

Request & Reaction Dialogue is how SQLbini's people speak: requests arrive from
someone at the counter, and passes, fails and SQL errors come back in their
voice — with SQLite's real message beneath every SQL error (content errors
show none), and never a hidden row. It is shown as a small cozy pixel-art counter scene with a speech bubble
above the workbench, plus a message log, and keeps the current request always
one glance away. Typos get a "did you mean" when a close name exists.

> **Quick reference** — Layer: `Presentation` · Priority: `MVP` · Key deps: `Puzzle Definition & Datasets, Hidden-Data Grader, SQL Execution Sandbox, Query Workbench`

## Overview

Request & Reaction Dialogue is how SQLbini's people talk to the player. Every
puzzle arrives as something a person at the counter needs — Manager Tanaka's
disposal list, Mrs. Sato's half-remembered banana snack, an HQ email — and every
outcome comes back in their voice: a pleased line on a pass, a plain-language
symptom on a fail, a friendly gloss on an SQL error with SQLite's real message
underneath. It is what turns a SQL exercise into a shift at a konbini (Pillar 4)
and what keeps mistakes cheap and human (Pillar 3). The player sees it in a
small pixel-art **counter scene** at the top of the workbench: the current
speaker stands at the counter with a speech bubble, and a message log keeps
every line of the shift for rereading (the developer's chosen "hybrid"
presentation, 2026-10-14). The mood is aesthetic and cozy. Exact pixel-art style
is set in `/art-bible`.

## Detailed Design

### Core Rules

**Cast (MVP)**

1. Speakers are data: id, display name, sprite set and a short voice blip.
   Chapter 1 uses:

| Speaker | Role | Sprite set (MVP) |
|---|---|---|
| Manager Tanaka | Gives most requests, shift briefings, the first-submit explainer | neutral · pleased · puzzled |
| Kenji | Coworker; voice of hints, Run errors, `CONTENT_ERROR` and the "leave it for me" skip offer; also a requester (1-10) | neutral · pleased · puzzled |
| Mrs. Sato | Elderly regular (1-9) | neutral · pleased · puzzled |
| Customer (generic) | Walk-in requests (1-5, 1-6) | neutral · pleased · puzzled |
| HQ | Emails (S-1); no sprite — a printed email/fax slip in the bubble's place | — |

**Kinds of line**

2. Every line the player reads in the counter scene has a kind and a source:

| Kind | Source of the text | Speaker |
|---|---|---|
| `request` | Puzzle `request` (Puzzle Definition); in challenge mode, the challenge puzzle's request (`constraint-challenges.md`) | Puzzle's requester |
| `pass` | Puzzle `pass_reaction` | Requester (pleased) |
| `fail` | Grader feedback key (cause, level) → the trap's authored feedback, or the built-in line for `columns` / `order` / `nondeterministic` / `generic` | Requester (puzzled) |
| `error` | Sandbox `error_kind` (or the grader's `TOO_MANY_ROWS`) + `error_text` → an error template (rule 6, string id `error.<KIND>`) | On **Run**: Kenji (looking over your shoulder); on **Submit**: the requester (puzzled); `CONTENT_ERROR` / `UNAVAILABLE`: always Kenji |
| `briefing` | Shift briefing (chapter definition) | Manager Tanaka |
| `offer` | Constraint offer line (appended to the pass line in the bubble, with **Try it** / **Later** buttons — rule 3a; offer ticket if unanswered; also recorded in the message log); Kenji's skip offer | Requester / Kenji |
| `challenge` | Built-in `challenge.clear` and `challenge.rule_broken` (slot `{keyword}`), reported by Constraint Challenges | Requester (pleased / puzzled) |
| `system` | One-time explainers (first Submit); the new-game "Ever used SQL before?" question, shown once **before** 1-1's request with two choice buttons (`onboarding-first-shift.md` rule 1); Tanaka's one-time "start over" line (Guided only, `onboarding-first-shift.md` Edge Cases) | Manager Tanaka |

   Hints are shown in the Hint System's own panel (Kenji's voice), not in the
   bubble, so they never displace the request. Onboarding's step-by-step
   guidance ("Press Run…") is shown in the **coach-mark label** next to its
   target with Tanaka's name tag, not in the bubble (`onboarding-first-shift.md`
   rule 7), so the request stays in the bubble throughout 1-1 to 1-3.

   Built-in `fail` lines (string ids `fail.columns`, `fail.order`,
   `fail.nondeterministic`, `fail.generic`) are owned here. Required content:
   `columns` says the list has the wrong number of columns; `order` says the
   rows are right but in the wrong order; `nondeterministic` says the answer
   changes each time it is run; `generic` says some rows are wrong and must
   include "check what each column holds and in which order" (Hidden-Data
   Grader Edge Cases, "Result shape"). None names a row, value or count.

   Built-in challenge lines (string ids `challenge.clear`,
   `challenge.rule_broken`) are owned here too; Constraint Challenges reports
   the clear or the broken rule (with `{keyword}`, e.g. `IN`) and this system
   voices it. Required content: `clear` is the requester's pleased reaction to
   a dare done; `rule_broken` says "Right answer, but not within the
   challenge — uses {keyword}".

   **Bubble vs. note/strip (no sentence in both).** The bubble carries the
   **voiced line only** and is temporary (it returns to the request after
   `reaction_hold`). The non-voiced text lives in the workbench and persists
   until the next edit: on FAIL, the grader's neutral level-1 symptom statement
   in the note; on errors, the error label plus SQLite's original `error_text`
   (or the sandbox's fixed message) in the strip (workbench rule 13).

**The counter scene and the request**

3. The current puzzle's **request is always one glance away**: the bubble shows
   the request by default; a reaction (pass, fail, error, offer) temporarily
   replaces it and the bubble returns to the request after `reaction_hold`
   (Formulas), or on a click on the speaker or the next Run, or on an editor
   edit once the reaction has been fully visible for at least
   `reaction_grace` (1.0 s) — so typing never wipes a line before it can be read.
   Returning to the request removes only the voiced line; the workbench note
   or strip keeps the non-voiced text until the next edit (rule 2). In
   challenge mode the "request" is the challenge puzzle's request.
3a. **After a PASS** the sequence is: the pass line (plus the constraint offer
   line and its **Try it** / **Later** buttons, when Constraint Challenges offers
   one) stays in the bubble for `reaction_hold` of the combined line, timed from
   when it is fully visible; a click on the speaker or bubble, or Enter/Space
   with the counter scene focused, ends it early. Editor edits and Run do **not**
   end a pass line (the passed puzzle's draft is kept). Only then does the next
   request arrive (Shift & Chapter Progression rule 11) — no menu, no wait for
   an answer. An offer still unanswered at that moment moves to a small
   **offer ticket** at the right of the counter strip (glyph + "Challenge?",
   opens the same two buttons) until it expires under `constraint-challenges.md`
   rule 6 (first Submit on the next request, another request opened, or
   clock-out); then it is removed and counts as **Later**. The pass and offer
   lines are also in the log.
4. The **message log** (button in the counter scene, shortcut Ctrl+L) lists every
   line of the current shift with speaker name and kind, newest at the bottom,
   for rereading. Nothing is ever lost from the log during a shift.
5. Text appears with an optional typewriter reveal (`reveal_cps`, Formulas); a
   click on the bubble, or Enter/Space while the counter scene has keyboard
   focus, shows the whole line at once (and stops its voice blips). Typing in
   the editor does not affect the reveal and is never delayed by it. Reveal is
   off when reduced motion is on. Page advance uses the same inputs; in the
   editor, Enter is always a newline.

**Errors in a person's voice (Pillar 4)**

6. SQL errors are glossed by templates keyed on the sandbox `error_kind`, or
   the grader's SUBMIT_ERROR kind `TOO_MANY_ROWS`, or the grader verdict
   `UNAVAILABLE` (and, for `SQL_ERROR`, on SQLite's message). Each template has
   the string id `error.<KIND>` (e.g. `error.EMPTY`, `error.CONTENT_ERROR`);
   other systems cite the id, never the text. **SQLite's original message is
   always shown beneath** in monospace — in the workbench's error strip
   (workbench rule 13) — **except** for `CONTENT_ERROR` / `UNAVAILABLE`, where
   no raw text reaches the player. The bubble carries the voiced gloss only.
   Speaker: on Run, Kenji; on Submit, the requester (rule 2). Every
   `error_kind` has a template. MVP templates:

| Error pattern (string id) | Voiced gloss (example) |
|---|---|
| `no such column: X` | "There's no column called 'X'." + "Did you mean 'Y'?" when a close match exists (Formulas) |
| `no such table: X` | "We don't have a 'X' shelf — the ledger is called 'products'." (closest table name) |
| `near "X": syntax error` | "Something's off near 'X'." |
| `incomplete input` / `unrecognized token` (e.g. an unterminated string, sandbox edge case) | "Looks like the sentence stops halfway — a missing quote or bracket?" |
| `EMPTY` (`error.EMPTY`) | "You haven't written anything yet." |
| `MULTI_STATEMENT` | "One request at a time, please — just one query." |
| `NOT_A_QUERY` | "I only need a list — no changing the ledger." |
| `NOT_ALLOWED` | "That's not something we do from the register." |
| `UNSUPPORTED` | "That's more than we need today." |
| `TIMEOUT` | "That's taking forever — is something repeating?" |
| `TOO_MANY_ROWS` (grader SUBMIT_ERROR: over `grader_row_cap` rows on the visible pre-check) | "That's far too long a list." |
| `CONTENT_ERROR` on Run, or grader verdict `UNAVAILABLE` on Submit (`error.CONTENT_ERROR`) | Kenji: "Sorry — the ledger itself is smudged. Not your fault; this one's on us." (never the requester's puzzled face; **no raw text is shown** — the build message goes only to the Playtest Log / content-bug report) |
| any other `SQL_ERROR` | "Hmm, the register didn't like that." (raw message beneath) |

7. Voiced errors never claim more than the raw message supports, and never
   mention hidden data. `CONTENT_ERROR` / `UNAVAILABLE` is a content bug
   (sandbox, grader), so its line never implies the player made a mistake and
   no raw or build text is shown with it.

**Reactions never leak (Pillar 1)**

8. `fail` lines come only from the feedback key (cause, level); this system never
   receives rows, counts or dataset names (Hidden-Data Grader rule 11).

**Text**

9. All player-facing text lives in string tables keyed by id (English base;
   localisation later). Puzzle-authored lines are referenced by puzzle id. A
   missing id shows `[id]` in development builds and the generic line in release
   builds, and is logged. Lengths (`len`) count grapheme clusters.
10. Lines are short: a bubble holds at most `bubble_chars_max` characters; longer
    lines are split into pages the player advances.

### States and Transitions

The counter scene, per open puzzle:

| State | Bubble shows | Event | To |
|---|---|---|---|
| `Request` | The request (speaker neutral) | Pass / fail / error / offer arrives | `Reaction` |
| `Reaction` | The reaction (speaker pleased / puzzled) | `reaction_hold` elapses, Run, click on speaker, or editor edit after `reaction_grace` | `Request` |
| `PassReaction` | Pass line (+ offer line and buttons) | `reaction_hold` elapses, or click / Enter / Space on the counter scene (edits and Run do not end it) | `Request` (next request, new speaker); an unanswered offer → offer ticket (rule 3a) |
| any | | Message log opened | unchanged (log overlays the editor area, closes with Esc / Ctrl+L) |

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Dialogue | `request`, `pass_reaction`, trap feedback texts, speaker ids, chapter shift briefings | Puzzle Definition |
| Hidden-Data Grader | Grader → Dialogue | Verdict + feedback key `{verdict, cause, level}` only; `{verdict: UNAVAILABLE}` (no error text); SUBMIT_ERROR as `{error_kind, error_text}` incl. `TOO_MANY_ROWS` | Grader |
| SQL Execution Sandbox | Sandbox → (Workbench) → Dialogue | `error_kind`, `error_text`; schema names for "did you mean" | Sandbox |
| Query Workbench | Workbench hosts | Counter scene strip, message-log overlay | Workbench |
| Shift & Chapter Progression | Progression → Dialogue | Shift briefing, next request, Kenji's skip offer | Progression |
| Constraint Challenges | Challenges → Dialogue | Challenges reports: offer (shown with the pass line in the bubble; offer ticket if unanswered — rule 3a; recorded in the log), clear, rule broken `{keyword}`, and challenge mode open/closed (the bubble then shows the challenge puzzle's request). Dialogue voices them via `challenge.clear` / `challenge.rule_broken` | Challenges owns the events; Dialogue owns the lines |
| Hint System | Dialogue → Hints | Kenji's identity (portrait, name) for the hint panel | Dialogue |
| Store Manual | Dialogue → Manual | The previous part-timer's voice as a writing guide for pages; no speaker in the scene | Dialogue |
| Onboarding: First Shift | Onboarding → Dialogue | The "Ever used SQL before?" `system` line and its two choices; Tanaka's one-time "start over" `system` line (Guided only); guidance itself is in coach-mark labels, not the bubble | Onboarding |
| Audio (VS) | Dialogue → Audio | Voice blip per line, speaker id | Audio |
| Playtest Log | Dialogue → Log | Lines shown, log opened, lines skipped | Dialogue |

## Formulas

*Proposed by `systems-designer` (2026-10-14). Bubble font raised from 16 to 18 px
to match the art-director's readability guidance; `did_you_mean` examples and
bubble capacity were re-computed by script.*

The **reaction_hold** formula is defined as:

`reaction_hold = clamp(hold_base + len / read_cps, hold_min, hold_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| len | int | 1 – `bubble_chars_max` | calculated | Characters of the voiced line's last page (a paged line is timed on its last page; for a PASS, the pass line plus any offer line); the raw SQLite message is excluded |
| reaction_grace | float (s) | 0.5–2.0 (default 1.0) | data file | Minimum fully-visible time before an editor edit may dismiss a reaction (rule 3) |
| hold_base | float (s) | 0.5–2.0 (default 1.0) | data file | Time to notice the change |
| read_cps | float | 12–30 (default 20) | data file | Reading speed, characters per second (~240 wpm) |
| hold_min, hold_max | float (s) | 1.5–4 / 4–10 (default 2.5 / 6.0) | data file | Clamps |

**Output Range:** 2.5–6.0 s at defaults. The timer starts when the whole line is
visible (after reveal or skip; on the last page of a paged line) and only
controls the automatic return to the request — any edit, Run or click on the
speaker returns at once. The line stays in the log.
**Example:** "There's no column called 'prise'. Did you mean 'price'?" (55 chars)
→ 1.0 + 55 / 20 = 3.75 s.

The **reveal_time** formula is defined as:

`reveal_time = (reveal_cps = 0) ? 0 : min(len / reveal_cps, reveal_cap)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| reveal_cps | float | 0 or 20–120 (default 45) | data file (setting) | Typewriter speed; 0 = instant; forced to 0 under reduced motion |
| reveal_cap | float (s) | 0.5–2.0 (default 1.0) | data file | Longest any page may take to reveal |
| len | int | 1 – `bubble_chars_max` | calculated | Characters on the page |

**Output Range:** 0 to `reveal_cap` seconds; long pages speed up rather than
drag. Reveal never blocks input; any key or click completes it.
**Example:** 1-5 "Excuse me, which drinks are under 200?" (38 chars) → 38 / 45 ≈ 0.84 s.

The **bubble_chars_max** formula is defined as:

`bubble_chars_max = max(40, floor(lines × chars_per_line × wrap_eff))`, with
`chars_per_line = floor((bubble_w − 2 × pad_x) / (glyph_w × font_px × ui_scale))` and
`lines = floor((bubble_h − 2 × pad_y) / (1.25 × font_px × ui_scale))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| bubble_w, bubble_h | int (px) | 880, 80 (logical, inside the 120 px strip) | data file | Bubble size |
| pad_x, pad_y | int (px) | 12, 8 | data file | Padding |
| font_px | int | 18 (range 16–20) | data file | Bubble font size — the workbench body family |
| glyph_w | float (em) | 0.55 | constant | Average glyph advance — verify against the chosen font |
| wrap_eff | float | 0.8–0.9 (default 0.85) | constant | Word-wrap waste |
| ui_scale | float | 1.0–2.0, step 0.25 (default 1.0) | data file | Text scale (Accessibility Options); the strip and bubble do not scale |

**Output Range:** at defaults `chars_per_line = 86`, `lines = 2`,
**`bubble_chars_max = 146`**. The strip stays 120 px (pixel art ×4) at every
`ui_scale` (2026-10-14 review — a scaled ×6/×8 strip would exceed the 1280 px
width and cost the result tables rows); only the bubble text grows, so capacity
falls: `ui_scale` 1.5 → 1 line × 57 chars → **48**; 2.0 → 1 line × 43 chars →
**40** (the floor). Larger text therefore means more pages, never a taller strip. Pages split greedily at the last space
before the limit (a single over-long word is hard-split);
`pages ≥ ceil(len / bubble_chars_max)`.
**Example:** the 38-char 1-5 request is one page; a 260-char boss briefing is
two pages ("1/2 ▸").

The **did_you_mean** formula is defined as:

`did_you_mean(X, names) = argmin over n ∈ names of (d(n), schema_index(n)) subject to d(n) = DL(lower(X), lower(n)) ≤ t(X)`; null if none qualifies;
`t(X) = min(|X| ≤ 4 ? 1 : 2, |X| − 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| X | string | 0–64 chars | calculated | The unknown name from the SQLite message (quotes and any `alias.` prefix stripped) |
| names | list | schema order | data file | The open puzzle's column names (`no such column`) or table names (`no such table`), from its schema |
| DL | int | ≥ 0 | calculated | Damerau-Levenshtein distance (a transposition counts 1) |
| t | int | 0–2 | calculated | Threshold, smaller for short names |

**Output Range:** one name or null; ties go to the earlier schema name; one-letter
names never get a suggestion. With a single table, `no such table` always names
it (`products`); the threshold applies only when a chapter has several tables.
**Example (Chapter 1 columns):** `prise` → `price` (1); `pirce` → `price`
(transposition, 1); `catagory` → `category` (1); `nam` → `name` (1); `stok` →
`stock` (1); `shelfs` → `shelf` (1); `product` → `products` (1, table);
`expiry` → none (`expiry_date` is 5 away) — the gloss omits "Did you mean".

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If the player Runs while a reaction is showing, or edits once it has been fully visible for `reaction_grace`**: the bubble returns to the request at once; the reaction stays in the log. An earlier edit does not dismiss it (rule 3). A pass line is not dismissed by edits or Run (rule 3a).
- **If a CONTENT_ERROR occurs on Run, or a Submit returns `UNAVAILABLE`** (a dataset failed to build): Kenji's apology line (`error.CONTENT_ERROR`), never the requester's puzzled reaction; **no raw or build text is shown** — the build message reaches only the Playtest Log / content-bug report.
- **If the player answers the offer ticket after the next request arrived**: Try it / Later behave exactly as in the bubble (`constraint-challenges.md` rule 6a).
- **If several reactions arrive quickly** (repeated submits): only the newest is shown; all are in the log. **Exception — queue:** when a FAIL line and Kenji's skip `offer` arrive together (the FAIL that latches `exhausted`), neither replaces the other: the fail line shows first, then the offer after the fail line's `reaction_hold` (or earlier if the fail line is dismissed by rule 3).
- **If challenge mode is open**: the bubble's request is the challenge puzzle's request; on leaving, it returns to whatever `constraint-challenges.md` rule 6a opens.
- **If a reaction arrives while the player is reading a paged request**: the reaction replaces it; returning to the request starts at page 1.
- **If a puzzle's requester has no sprite** (HQ, or a missing asset): a printed slip replaces the speaker; text behaviour is unchanged.
- **If an error message matches no template**: the generic line ("the register didn't like that") with the raw message beneath.
- **If `did_you_mean` finds no close name**: the gloss is given without a suggestion — never a wrong guess.
- **If the misspelled name is a SQL keyword** (`SELEC`): it is a syntax error, not a column error; the `near "X"` template applies.
- **If a line is longer than one bubble page**: paged with a "1/3 ▸" marker; Enter / click advances; the log shows the whole line.
- **If reduced motion is on**: no typewriter, no idle sprite motion; text appears whole.
- **If audio is muted**: voice blips are silent; nothing depends on hearing them.
- **If the message log is opened mid-shift**: it overlays the workbench below the counter scene; the editor keeps its text and caret; Esc closes it.

## Dependencies

**Upstream (hard):**

| System | GDD | What Dialogue needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Request, pass reaction, trap feedback, speaker ids, shift briefings | In Review |
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | Feedback key `{verdict, cause, level}` | In Review |
| SQL Execution Sandbox | `design/gdd/sql-execution-sandbox.md` | `error_kind`, `error_text`, schema names | In Review |
| Query Workbench | `design/gdd/query-workbench.md` | Hosts the counter scene and log (layout updated 2026-10-14) | In Review |

**Soft:** Shift & Chapter Progression (briefings, skip offer), Constraint
Challenges (offer / clear / rule-broken events), Hint System (Kenji's
identity), Store Manual (writing voice), Onboarding (opening question, "start
over" line), Audio (VS — blips), Playtest Log.

**Bidirectionality:** grader, sandbox, workbench, progression, hints,
constraint challenges, store manual and onboarding list Request & Reaction
Dialogue ✓.

## Visual/Audio Requirements

*Provisional — input from `art-director` (2026-10-14) for the developer's chosen
hybrid presentation and "aesthetic, cozy" mood (`design/ideas-backlog.md` #1,
#2). No art bible yet; confirm in `/art-bible`.*

**Counter scene (pixel art)**
- Native strip **320 × 30 px**, integer-scaled **×4** to 1280 × 120 at every
  `ui_scale` (the strip never rescales; only bubble text does); nearest-
  neighbour filtering, whole-pixel positions, no sub-pixel camera motion.
- Palette: one shared **16-colour warm ramp** (cream, tan, terracotta, olive,
  dusk blue, dark ink-brown). The editor and tables keep their own neutral
  high-contrast UI palette; a 4 px ink-brown rule with a paper-cream border
  separates the two zones. Scene colours never tint the editor.
- **Lighting by shift** via palette swap (not repainted art): Morning — pale
  yellow window light, cool shadows; Afternoon — neutral warm; Closing — amber
  lamp, dusk-blue window, longer shadows.
- Contents: counter in front; shelves of tins and ledgers behind; a window at one
  edge showing the time of day; a hanging lamp; speaker centre-left, right side
  clear for the message-log button and the Hint / Manual / Back Room tabs. Calm and low-detail — at most three value
  steps near the bubble.

**Characters**
- **24 × 28 px** busts behind the counter, 2 px ink-brown outline for everyone.
- Expressions **neutral / pleased / puzzled** differ in silhouette (head tilt,
  shoulders, a "?" tick), not only face pixels.
- Idle: 2-frame breathing bob every ~1.2 s, blink every ~4 s. Reduced motion:
  static neutral frame; expression changes are instant swaps.
- **HQ** has no face: a 32 × 20 px printed slip on the counter (perforated edge,
  stamp mark) — the "store paper" language.

**Speech bubble** (a UI-layer element, not baked into the pixel scene, so text is
crisp at 1280 × 720)
- Cream paper panel, 2 px ink border, tail to the speaker.
- **Clean sans/slab at 18–20 px** — the workbench's body family. **No pixel fonts
  for any functional text** (readability for dyslexic and second-language
  readers). Ink on cream ≥ 7:1.
- **Request** = square ticket-style bubble with a notched edge and a "REQUEST" tab;
  **reaction** = rounded bubble with the speaker's name tag. The sprite's
  expression also changes for reactions.
- Paging: "1/3" counter and a "▸" chevron (blinking; static under reduced motion).

**Message log**
- A ledger / receipt-roll panel over the workbench with a dimmed scrim; same paper
  and ink; entries grouped by speaker, requests in the ticket style and
  reactions in the rounded style; 16–18 px; Esc closes; focus stays in the log
  while open.

**Audio intent** (audio-director owns detail)
- Per-character voice blips: soft plucked / marimba-like, distinct pitch and
  rhythm per character; HQ gets a dry printer tick. Optional, with a volume
  setting; silent when a line is shown instantly.
- Shift ambience: Morning — soft birds, shop door bell; Afternoon — quiet hum,
  wall clock; Closing — low lamp buzz, distant crickets.

**Main risk and anti-patterns**
- The cozy strip competing with the data for attention. Keep it at 120 px, keep
  motion minimal, and never let pixel art, dithering or texture bleed into the
  editor or tables.
- Mixed pixel density: no non-integer scaling or rotation of sprites.
- Also avoid: colour-only speaker or outcome cues; bobbing that cannot be turned
  off; dark "cozy" lighting under text; blurry upscaled UI.

> 📌 **Asset Spec** — after the art bible is approved, run
> `/asset-spec system:request-and-reaction-dialogue` for sprites, scene and
> bubble assets.

## Game Feel

The counter should feel like a warm little shop window above a calm desk: people
drop by, say what they need, react with a small expression change, and the
request never disappears from view. Reactions are brief and kind — a fail reads
like a customer gently pointing out a problem, never a buzzer. Text never makes
the player wait: reveal is instant on any key, and typing in the editor is never
blocked.

## UI Requirements

1. Counter scene strip (120 px at every `ui_scale`) across the top of the
   workbench; speaker, bubble, the offer ticket when one is pending (rule 3a), message-log button, and the workbench's Hint /
   Manual / Back Room tabs at its right edge; never overlaps the editor or
   result tables.
2. The current request is readable with at most one action (rule 3).
3. Message log: Ctrl+L / button; scrollable; speaker name + kind label per line;
   Esc closes; keyboard reachable.
4. Bubble text ≥ 4.5:1 contrast (blocking; 7:1 is the target); request vs reaction distinguished
   by bubble shape and label, not colour alone; paging marker "1/3 ▸".
5. Raw SQLite error always visible beneath an error gloss (with the workbench's
   error strip), except `CONTENT_ERROR` / `UNAVAILABLE`, which show no raw text
   (rule 6).

> **📌 UX Flag — Request & Reaction Dialogue**: the counter scene and message log
> belong in the Query Workbench UX spec (`/ux-design`, Pre-Production).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hidden-data-grader.md` | Rules 2, 8 | Feedback key; never row data (grader rule 11) | In Review |
| `design/gdd/sql-execution-sandbox.md` | Rule 6 | `error_kind` set and `error_text` | In Review |
| `design/gdd/query-workbench.md` | Overview, UI | Counter scene replaces the 56 px request bar; Ctrl+L; error strip | In Review, updated for this GDD |
| `design/gdd/shift-and-chapter-progression.md` | Rule 2 | Briefings; Kenji's skip offer | In Review |
| `design/gdd/constraint-challenges.md` | Rule 2 | Offer / clear / not-within-challenge lines | In Review |
| `design/ideas-backlog.md` | Overview | #1 aesthetic/cozy mood; #2 pixel-art NPCs + speech bubbles (applied) | Developer ideas |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Not repeated here: grader payload keys
(grader AC-18), the first-Submit explainer (QW-15) and the error strip with raw
text (QW-17). Fixtures use stub grader / sandbox / progression and a fake clock;
defaults: `hold_base` 1.0, `read_cps` 20, clamps 2.5 / 6.0, `reveal_cps` 45,
`reveal_cap` 1.0, `reaction_grace` 1.0.*

**Cast and kinds**
- **RD-01 [Logic]** GIVEN the Chapter 1 cast data, THEN Tanaka, Kenji, Mrs. Sato and Customer each have id, name, neutral / pleased / puzzled sprites and a blip, and HQ has none; a speaker added only in data renders with no code change; a missing sprite shows the printed slip with unchanged text behaviour.
- **RD-02 [Integration]** GIVEN a puzzle requested by Mrs. Sato, WHEN each kind arrives, THEN request → her `request`, neutral; pass → `pass_reaction`, pleased; fail with a trap key at level 1 → that trap's level-1 text, puzzled (level 2 at Vertical Slice, `feedback_max_level` 1 in MVP); fail with `columns` / `order` / `nondeterministic` / `generic` → the built-in line; a Run error → Kenji, puzzled; a Submit error → Sato, puzzled; briefing and system lines → Tanaka; skip offer → Kenji; hint text never reaches the bubble.

**Request one action away**
- **RD-03 [Integration]** GIVEN `reveal_cps` 0 and the 55-char "prise" gloss shown at t = 0, THEN the reaction shows at 3.74 s and the request at 3.75 s (4.75 s with `reveal_cps` 45); a Run or a speaker click at 0.5 s returns the request at once; an editor edit at 0.5 s does not, an edit at 1.1 s does; three reactions within 1 s → only the newest shows, all three logged; a reaction during page 2 of a request → the return opens page 1.
- **RD-04 [Logic]** `reaction_hold` = 2.5 s at len 1, 3.75 s at 55, 6.0 s at 146; for a paged line the timer starts on the last page.

**No leak**
- **RD-05 [Logic / code review]** Dialogue entry points accept only `{verdict, cause, level}` (verdict may be `UNAVAILABLE`, with no error text), `{error_kind, error_text}` (where `error_kind` is a sandbox kind or the grader's `TOO_MANY_ROWS`), challenge events `{clear}` / `{rule_broken, keyword}`, schema names and line ids — no row, count or dataset type; the same key against different hidden datasets gives identical text.

**Log and reveal**
- **RD-06 [Integration]** GIVEN 5 lines shown, WHEN Ctrl+L, THEN 5 entries, newest at the bottom, each with speaker name and kind label, paged lines whole; Tab stays inside the log; Esc or Ctrl+L closes it; the editor's text and caret are unchanged; the button is keyboard reachable.
- **RD-07 [Logic]** Reveal = 0.844 s for 38 chars and 1.0 s (cap) for 146; 0 at `reveal_cps` 0 or under reduced motion; a bubble click, or Enter/Space with the counter scene focused, completes the line in that frame.
- **RD-08 [Integration]** GIVEN a reveal in progress, WHEN "abc" is typed in the editor, THEN "abc" is inserted in the same frame as with no dialogue showing, the reveal continues, and Enter in the editor inserts a newline.

**Errors and suggestions**
- **RD-09 [Logic]** Sandbox stubs `no such column`, `no such table`, `near "X"`, `incomplete input`, `unrecognized token`, `EMPTY`, `MULTI_STATEMENT`, `NOT_A_QUERY`, `NOT_ALLOWED`, `UNSUPPORTED`, `TIMEOUT`, `CONTENT_ERROR` and a grader `TOO_MANY_ROWS` SUBMIT_ERROR each map to their template (`error.<KIND>`) with `error_text` passed through unchanged; every `error_kind` in the sandbox enum has a template; `CONTENT_ERROR` on Run and a grader `UNAVAILABLE` verdict on Submit both give `error.CONTENT_ERROR`, spoken by Kenji with no puzzled requester sprite, and **no raw or build text is passed to the strip or the bubble**; a Run error is spoken by Kenji and a Submit error by the requester; an unknown message → the generic line; `SELEC name …` → the `near` template.
- **RD-10 [Logic]** `did_you_mean`: prise, pirce, PRISE and `p.prise` → price; catagory → category; nam → name; stok → stock; shelfs → shelf; table `product` → products; expiry → null (no "Did you mean"); "p" → null; with names [cat, cut], cot → cat, and reversed → cut.

**Text**
- **RD-11 [Logic]** A 300-char line → 3 pages, each ≤ 146 chars, split at spaces; a 160-char word is hard-split; marker "1/3 ▸"; `bubble_chars_max` = 146 at defaults, 48 at `ui_scale` 1.5 and 40 at 2.0.
- **RD-12 [Logic / CI scan]** No player-facing string literal in dialogue code paths; every line resolves through a string-table id or puzzle id; a missing id shows `[id]` in dev builds and the generic line in release, and is logged.

**Presentation and audio**
- **RD-13 [UI]** Retained screenshots at `ui_scale` 1.0 and 1.5: scene at ×4 and 120 px in both (only the bubble text larger at 1.5) with nearest filtering (no blurred pixels); a non-pixel body font in the bubble; bubble contrast ≥ 4.5:1 (blocking; 7:1 target reported); in greyscale, request (ticket, REQUEST tab) and reaction (rounded, name tag) are distinguishable, and the three expressions differ by silhouette.
- **RD-14 [UI]** Morning, Afternoon and Closing screenshots use the same sprite assets with a palette swap; editor colours are identical in all three.
- **RD-15 [Audio]** Each revealed line plays its speaker's blip (HQ: printer tick) at the blip-volume setting; no blip at volume 0, muted, `reveal_cps` 0 or reduced motion; blips stop the moment a reveal is completed early.
- **RD-17 [Integration]** GIVEN `reveal_cps` 0 and a PASS with a 40-char pass line and a 40-char offer line, THEN the bubble holds both with Try it / Later for 5.0 s (1.0 + 80 / 20), and only then does the next request appear; an editor edit or Run at 1.5 s does not end it; a click at 1.5 s does; with no answer, the offer ticket shows on the strip and still opens Try it / Later until the first Submit on the new request, then disappears and `challenge_later` is logged; a PASS with no offer behaves the same with no ticket.
- **RD-18 [Integration]** GIVEN onboarding Guided in 1-1 to 1-3, THEN the bubble shows the request whenever no reaction is showing and guidance appears only in coach-mark labels; on a new game, the "Ever used SQL before?" line with its two buttons is shown before 1-1's request.
- **RD-16 [Integration]** The Playtest Log records `line_shown {line_id, kind, speaker}`, `log_opened` and `line_skipped` (a reveal completed early), each with a timestamp and the common `puzzle` field.
- **RD-19 [Integration]** GIVEN a FAIL that latches `exhausted` (stub progression sends Kenji's skip offer in the same frame), THEN the fail line shows first and the offer only after the fail line's `reaction_hold`; both are logged, in that order.
- **RD-20 [Integration]** GIVEN a FAIL, THEN the bubble shows only the voiced fail line and the workbench note shows only the grader's neutral symptom statement — no sentence appears in both; GIVEN a Run error, THEN the bubble shows only the gloss and the strip only the label + `error_text`. GIVEN challenge mode open, THEN the bubble's request is the challenge puzzle's; a stub clear / rule-broken event `{keyword: IN}` shows `challenge.clear` / `challenge.rule_broken` with "IN".

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Pixel-art style specifics (resolution, palette) and how it sits with the clean paper UI | art-director | `/art-bible` |
| 2 | Is the flavour wage on the payslip worth keeping, or should the manager's end-of-shift comment replace it? **Shift & Chapter Progression owns this decision (Progression OQ 2)**; Dialogue only writes whatever line Progression asks for. | Progression owner (narrative-director consulted) | Writing Chapter 1 lines |
| 3 | Do voiced error glosses help zero-SQL players read SQLite's raw messages over time, or do they skip the raw text? Watch in playtest. | game-designer | Zero-SQL playtest |
| 4 | Character bios and voice guide for Tanaka, Kenji, Mrs. Sato | narrative-director / writer | Before Chapter 1 line writing |
