# Constraint Challenges

> **Status**: In Design
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 2 — Your Query, Your Way; Pillar 1 — The Condition, Not the Screen

## Summary

Constraint Challenges are optional dares on puzzles the player has already
cleared — "no OR", "use BETWEEN", "≤ N characters" — that must still pass the
hidden-data grader. They turn Pillar 2's "any correct query counts" into play,
give players who are ahead a ceiling without blocking anyone, and feed the MVP's
"starts a challenge when offered" signal. Chapter 1 ships three keyword
challenges; rules are judged on lexer tokens and spacing-proof canonical length.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Hidden-Data Grader, Puzzle Definition & Datasets, SQL Execution Sandbox, Query Workbench`

## Overview

A Constraint Challenge is an optional second go at a puzzle the player has
already cleared, with one rule attached — "no `OR`", "under 60 characters",
"use `BETWEEN`". The query must still pass the hidden-data grader *and* obey the
rule, which pushes the player to find a different valid solution and discover
that `IN`, `OR` and `BETWEEN` overlap, or that a shorter condition says the same
thing. It is where Pillar 2's "any query that meets the condition counts" turns
into play, and where players who are ahead find a ceiling without blocking
anyone behind them. It is also one of the MVP's measured signals: the concept's
playtest table asks whether players start a challenge unprompted. The rules are
judged on the query text with a tokenizer that ignores string literals and
comments, so `'COLOR'` never counts as `OR`.

## Detailed Design

### Core Rules

**Which puzzles**

1. A puzzle has at most **one** constraint challenge, defined in its data
   (`constraint` field, Puzzle Definition & Datasets). Chapter 1 ships three
   (Formulas → Chapter 1 set): 1-4 `require(BETWEEN)`, 1-6 `forbid(IN)`,
   1-8 `forbid(BETWEEN)`. Puzzles without one are unaffected.
2. A constraint has a **type**, its **parameter**, a requester **offer line**,
   and a **witness query** — a query that passes the puzzle and obeys the rule,
   proving the challenge is solvable (rule 12).

**Rule types (MVP)**

3. `max_chars(N)` — the query's **canonical length** (Formulas) is at most N.
   Canonical length ignores spacing, so squeezing whitespace never helps. Not
   used in Chapter 1, whose queries can only be shortened by spacing; reserved
   for later chapters where a shorter *form* exists.
4. `forbid(K…)` — none of the listed SQL keywords appears as a keyword token
   (e.g. `forbid(OR)`, `forbid(IN, OR)`).
5. `require(K…)` — every listed keyword appears as a keyword token (e.g.
   `require(BETWEEN)`).
   Keywords are matched on tokens produced by the same lexer as the SQL
   Execution Sandbox (string literals, quoted identifiers and comments are
   skipped; matching is case-insensitive).

**Offering and attempting**

6. The challenge becomes available when the base puzzle is **PASSED**. Right
   after the pass, the requester (or Kenji) offers it in one line ("Bet you
   can't do it without OR.") with two choices: **Try it** / **Later**. It never
   blocks progress; the shift continues either way. Choosing **Try it** counts
   as starting a challenge for the MVP playtest threshold ("starts a constraint
   challenge … when offered"); the log records whether the start came from the
   offer or the chapter list.
7. A challenge can also be started any time later from the puzzle in the chapter
   list (a "challenge" mark shows which puzzles have one).
8. In challenge mode the workbench shows the rule and a **live check** under the
   editor: for `max_chars`, the current canonical count ("54 / 60"); for
   `forbid`/`require`, which listed keywords are present. The live check reads
   the text only — it is not a verdict.
9. On **Submit** in challenge mode:
   1. The query is graded by the Hidden-Data Grader exactly as a normal submit.
   2. If the grader says FAIL or SUBMIT_ERROR, that verdict is shown as usual
      (feedback, counters) and the challenge is not cleared.
   3. If the grader says PASS, the rule is checked. Met → **challenge cleared**.
      Broken → "Right answer, but not within the challenge" with which part of
      the rule was broken (e.g. "uses OR"); not cleared, no fail counted.
10. Clearing a challenge marks the puzzle in the chapter list and plays the
    challenge stamp (Visual/Audio). There is no wage, no progression gate and no
    penalty for skipping; Achievements (Vertical Slice) may count clears.
11. Hints in challenge mode are the base puzzle's hints (no challenge-specific
    hints at MVP).

**Content validation**

12. The content verifier checks every constraint: its **witness query must PASS
    the puzzle on every dataset and obey the rule**, and the base
    `reference_sql` must **not** obey it (otherwise the challenge is no different
    from the puzzle). A constraint failing either check makes the puzzle invalid.
    The verifier also rejects `forbid` of `SELECT`, `FROM`, `WHERE` or `AND`, an
    empty keyword list, and `max_chars` with N < 1.

### States and Transitions

Per puzzle with a constraint, per save:

| State | Meaning | Event | To |
|---|---|---|---|
| `Hidden` | Base puzzle not yet PASSED | Base PASS | `Offered` |
| `Offered` | Offer line shown | Try it | `Attempting` |
| `Offered` | | Later | `Available` |
| `Available` | Mark in the chapter list | Start from chapter list | `Attempting` |
| `Attempting` | Challenge mode in the workbench | Submit → PASS + rule met | `Cleared` |
| `Attempting` | | Submit → PASS + rule broken, or FAIL / SUBMIT_ERROR | `Attempting` |
| `Attempting` | | Leave the puzzle | `Available` |
| `Cleared` | Challenge stamp in the chapter list | Replay (optional) | `Cleared` |

Cross-session persistence of `Available`/`Cleared` belongs to Save/Load (Vertical
Slice); at MVP the state lasts for the session.

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Puzzle Definition & Datasets | Puzzle → Challenges | `constraint` (type, parameter, offer line, witness query) | Puzzle Definition |
| Hidden-Data Grader | Challenges → Grader → Challenges | Normal grading of the challenge submit; rule check only after PASS | Grader |
| SQL Execution Sandbox | Challenges → Sandbox lexer | Tokens (keywords; literals/comments skipped) | Sandbox |
| Query Workbench | Workbench hosts | Rule banner, live check, challenge-mode submit outcome | Workbench |
| Shift & Chapter Progression | Progression → Challenges | Base PASS event; chapter-list marks | Progression |
| Request & Reaction Dialogue | Dialogue → Challenges | Offer line, clear reaction | Dialogue |
| Achievements (VS) | Challenges → Achievements | Clear events | Achievements |
| Playtest Log | Challenges → Log | Offer shown, Try/Later, attempts, clears (MVP threshold "starts a challenge unprompted") | Challenges |
| Content verifier | Verifier → Challenges | Rule 12 checks | Puzzle Definition |

## Formulas

*Proposed by `systems-designer` (2026-10-14). Witness queries and lengths were
re-run against `prototypes/sqlbini-web/ch1.py` (all three witnesses match the
reference on visible, hidden A and hidden B).*

The **canonical_length** formula is defined as:

`canonical_length(q) = codepoints(join_canonical(tokens(strip_comments(q))))`

where `join_canonical` writes the tokens separated by exactly one space — no
space before `,` `)` `;` or after `(` — and drops one trailing `;`. String
literals and quoted identifiers are kept verbatim.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| q | string | any | calculated | Editor text (CRLF treated as LF) |
| tokens | list | 0–n | calculated | Sandbox lexer output (keywords, identifiers, literals, operators, punctuation) |
| result | int | 0 → ∞ | calculated | Unicode code points |

**Output Range:** 0 for empty or comment-only text. Keyword and identifier case
do not change the length; aliases and `AS` count. Spacing — including around
operators (`price>=150` vs `price >= 150`) — never changes it, so the only way to
get shorter is a shorter *form*. The live count and the submit check use this
same function.
**Example (1-6):** the reference and a whitespace-squeezed copy have the same
canonical length; plain whitespace lengths were 91 and 88, which is why a
spacing-sensitive count was rejected.

The **has_keyword** formula is defined as:

`has_keyword(q, K) = ∃ t ∈ tokens(q): t.kind = WORD ∧ upper(t.text) = K`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tokens(q) | list | 0–n | calculated | Lexer output; literals, quoted identifiers and comments are never `WORD` |
| K | string | uppercase keyword | data file | e.g. `OR`, `IN`, `BETWEEN` |

**Output Range:** boolean; whole-token match, so `ORDER`, `INTEGER` or `color`
never match `OR` / `IN`. `NOT IN` contains `IN` (`forbid(IN)` bans it —
intended); `BETWEEN a AND b` contains `AND`.
**Example:** `WHERE name = 'COLOR' -- or` → no `OR`; `category IN (…)` → `IN`.

**Authoring guidance:** only forbid a keyword with a substitute the player
already knows (`OR` ↔ `IN`, `BETWEEN` ↔ `>=` / `<=`); never forbid `SELECT`,
`FROM`, `WHERE` or `AND`. The verifier rejects a `forbid` of any keyword the
witness needs.

The **rule_met** formula is defined as:

`rule_met(q, c) = canonical_length(q) ≤ N` (max_chars) `| ∀K ∈ c.K: ¬has_keyword(q, K)` (forbid) `| ∀K ∈ c.K: has_keyword(q, K)` (require)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| N | int | ≥ 1 | data file | Character cap for `max_chars` |
| c.K | set of keywords | non-empty | data file | Keywords for `forbid` / `require` |

**Output Range:** boolean. An empty `c.K` or `N < 1` is a content error.
**Example:** `forbid(IN)` on the 1-6 reference → false (`IN` present).

The **challenge_cleared** formula is defined as:

`challenge_cleared = (grader_verdict = PASS) ∧ rule_met(q, c)`

**Output Range:** boolean; `rule_met` is evaluated only after a PASS (Core Rule 9).
**Example:** 1-6 with `WHERE (category = 'Snacks' OR category = 'Ice Cream') AND
price >= 150` under `forbid(IN)` → PASS and no `IN` → cleared.

The **content_valid** formula is defined as:

`content_valid = witness_passes ∧ rule_met(witness, c) ∧ ¬rule_met(reference_sql, c)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| witness_passes | bool | — | calculated | The witness matches the reference on every dataset |
| N (max_chars) | int | `canonical_length(witness) ≤ N < canonical_length(reference)` | data file | Recommended `N ≥ canonical_length(witness) + 4` to leave room for other solutions |

**Output Range:** boolean; false ⇒ the puzzle is invalid (Core Rule 12).

**Chapter 1 set** (witnesses verified against `ch1.py`):

| Puzzle | Rule | Witness (passes all datasets) | Reference breaks the rule because |
|---|---|---|---|
| 1-4 | `require(BETWEEN)` | `SELECT name, stock FROM products WHERE stock BETWEEN 0 AND 3` | it uses `stock <= 3` |
| 1-6 | `forbid(IN)` | `SELECT name, price FROM products WHERE (category = 'Snacks' OR category = 'Ice Cream') AND price >= 150` | it uses `IN`; the witness also revisits 1-6's AND/OR parentheses trap |
| 1-8 | `forbid(BETWEEN)` | `SELECT name, expiry_date FROM products WHERE expiry_date >= '2026-03-02' AND expiry_date <= '2026-03-08'` | it uses `BETWEEN` |

Rejected for Chapter 1: `max_chars` on any puzzle (only spacing could shorten
them); 1-9 `forbid(LIKE)` (the only witness is a hardcoded name list, which
breaks Pillar 1); S-1 `forbid(DISTINCT)` (needs `GROUP BY`, not taught yet).

## Edge Cases

*Drafted without specialists — Lean mode.*

- **If a forbidden keyword appears only inside a string literal, quoted identifier or comment** (`WHERE name = 'OR'`, `-- no OR here`): not a violation (tokenizer skips them).
- **If a keyword is part of a longer identifier** (`color`, `store`, `INSERTED_AT`): not a match — only whole keyword tokens count.
- **If the player uses an equivalent construct** (`NOT IN` under `forbid(OR)`, `>=` and `<=` instead of a required `BETWEEN`): `forbid` judges only the listed keywords, so `NOT IN` is fine under `forbid(OR)`; `require(BETWEEN)` is not met by `>=`/`<=`. The requester's line on a broken rule names the missing or forbidden keyword.
- **If the query passes the grader but breaks the rule**: "Right answer, but not within the challenge"; no grader fail is counted, hint counters unchanged, base puzzle stays PASSED.
- **If the query meets the rule but FAILs the grader**: the normal FAIL feedback; the rule's live check still shows "met".
- **If the player submits in challenge mode from the Back Room tab (Chapter 2+)**: graded exactly as a normal challenge submit.
- **If whitespace or comments are added to shorten or pad the text**: they do not count (`canonical_length`).
- **If the player clears the challenge, then replays it**: allowed; state stays `Cleared`.
- **If a puzzle's witness query does not pass, or the reference already obeys the rule**: the puzzle is invalid in content verification (rule 12); at runtime the challenge is not offered.
- **If the player chooses "Later"**: the challenge stays `Available` in the chapter list with no further prompts — re-passing the base puzzle does not show the offer again.

## Dependencies

**Upstream (hard):**

| System | GDD | What this system needs | Status |
|---|---|---|---|
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | Verdict on the challenge submit; "constraint runs only after a PASS" (grader rule 17) | Designed (pending review) |
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | `constraint` field; verifier hook for rule 12 | Designed (pending review) — field extended by this GDD |
| SQL Execution Sandbox | `design/gdd/sql-execution-sandbox.md` | Lexer tokens | Designed (pending review) |
| Query Workbench | `design/gdd/query-workbench.md` | Rule banner, live check, outcome display | Designed (pending review) |

**Soft:** Shift & Chapter Progression (base PASS event, chapter-list marks),
Request & Reaction Dialogue (offer and reaction lines), Achievements (VS),
Playtest Log.

**Bidirectionality:** grader, puzzle definition and workbench list Constraint
Challenges ✓.

## Visual/Audio Requirements

*`art-director` not consulted — Lean mode (challenge visuals extend the grader's
established stamp language). Review in `/art-bible`.*

- **Rule banner** above the editor in challenge mode: a small paper tag with the
  rule ("No OR", "≤ 60 characters"), glyph + word.
- **Live check** under the editor: "54 / 60" or "OR — not used ✓" in the
  workbench's table font; changes are instant, never animated.
- **Challenge cleared:** a second, smaller stamp beside the puzzle's PASS stamp
  (e.g. a star-shaped hanko), with a short soft stamp sound at least 6 dB
  quieter (peak) than the main PASS sound, so the base puzzle remains the main
  event.
- **"Right answer, but not within the challenge":** the requester's sticky note
  style (not a fail), naming the broken part.
- The chapter list shows a challenge mark (available) and a challenge stamp
  (cleared) — glyph + word, not colour alone.

## Game Feel

A challenge should feel like a playful dare from a coworker, not homework:
optional, offered once, never nagging. The live check makes the rule a puzzle
you can feel out while typing (watch "54 / 60" drop as you simplify), and the
outcome is immediate on submit like any other puzzle. Breaking the rule after a
correct answer is good news delivered gently ("right answer — just not within
the dare"), never a fail.

## UI Requirements

1. Offer prompt after PASS with **Try it** / **Later**, keyboard reachable.
2. Challenge mode banner and live check in the workbench (glyph + word, ≥ 4.5:1).
3. Chapter list marks: available / cleared.
4. Leaving challenge mode returns the workbench to the base puzzle view.

> **📌 UX Flag — Constraint Challenges**: include the challenge banner, live
> check and chapter-list marks in the Query Workbench and chapter-select UX
> specs (`/ux-design`, Pre-Production).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hidden-data-grader.md` | Core Rule 9 | Grading first; rule 17 "constraint rules run after a PASS" | Designed (pending review) |
| `design/gdd/sql-execution-sandbox.md` | Core Rules 4–5 | Lexer (literals, identifiers, comments) | Designed (pending review) |
| `design/gdd/puzzle-definition-and-datasets.md` | Core Rules 1–2, 12 | `constraint` field; content verifier | Designed (pending review) |
| `design/gdd/query-workbench.md` | Core Rule 8, UI | Banner and live check host | Designed (pending review) |
| `design/gdd/game-concept.md` | Overview | Pillar 2; MVP threshold "starts a constraint challenge unprompted" | Source of intent |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grader verdicts, workbench Submit/Run and
dataset checks are covered in their own GDDs. Fixtures from
`prototypes/sqlbini-web/ch1.py`. [UI] = retained screenshot in
`production/qa/evidence/`.*

- **CC-01 [Integration]** GIVEN 1-6 not yet passed, WHEN Submit returns PASS, THEN the offer line appears once with **Try it** / **Later**, both keyboard reachable; **Later** lets the shift continue with no further prompt and the chapter list shows the challenge mark; **Try it** opens challenge mode. GIVEN 1-5 (no constraint), WHEN it passes, THEN no offer appears.
- **CC-02 [Integration]** GIVEN `Available`, WHEN started from the chapter list, THEN `Attempting` with the banner; leaving returns to `Available` and the base workbench view. GIVEN `Hidden`, THEN no mark and no way to start. GIVEN **Later** and then a re-pass of the base puzzle, THEN no second offer.
- **CC-03 [Logic]** `has_keyword(q, OR)` is false for `name = 'COLOR'`, `-- or`, `[OR]`, `ORDER BY`, `color`; `has_keyword(q, IN)` is false for `INTEGER`; `has_keyword(q, OR)` is true for lower-case `or` used as an operator; `NOT IN (…)` is true for `IN`.
- **CC-04 [Logic]** For the 1-6 reference, `canonical_length` is unchanged by squeezed whitespace, added tabs/newlines, CRLF, lower-case keywords, `price>=150` vs `price >= 150`, an added `-- x` or `/* x */`, and one trailing `;`; comment-only text gives 0; adding `AS p` makes it longer; changing the case of a string literal is counted.
- **CC-05 [Logic]** `max_chars(N)` is true at canonical length N and false at N + 1; `forbid(IN, OR)` is false if either is present; `require(BETWEEN)` is false for `>= … <=` and true for `BETWEEN`.
- **CC-06 [Logic]** GIVEN a corpus of ≥ 20 queries, THEN the live check's per-keyword result and count equal the `rule_met` inputs at submit.
- **CC-07 [Integration]** GIVEN 1-6 under `forbid(IN)`: (a) the AND/OR precedence-trap query → normal FAIL with counter and feedback, the live check still shows "IN — not used", and the rule check is not called; (b) `SELEC …` → normal SUBMIT_ERROR; (c) the reference → "Right answer, but not within the challenge — uses IN", grader and hint counters unchanged, base stays PASSED, state stays `Attempting`; (d) the witness → `Cleared`.
- **CC-08 [Logic]** GIVEN 1-4 under `require(BETWEEN)`, WHEN the reference is submitted, THEN the message names the missing `BETWEEN`.
- **CC-09 [Integration]** GIVEN `Cleared`, WHEN replayed and the rule is broken, THEN the state stays `Cleared`.
- **CC-10 [UI]** Retained screenshots for 1-4, 1-6 and 1-8 show: banner and live check as glyph + word at ≥ 4.5:1; the rule-broken message in sticky-note style, not a fail stamp; a cleared puzzle with the smaller challenge stamp beside the PASS stamp; chapter-list marks for available vs cleared distinguishable without colour.
- **CC-11 [Content-CI]** For each Chapter 1 witness (1-4, 1-6, 1-8), THEN it passes on visible, hidden A and hidden B and obeys its rule, and the reference breaks the rule.
- **CC-12 [Content-CI]** Each of these makes the puzzle invalid and the challenge is not offered at runtime: a witness failing one dataset; a reference that obeys the rule; empty keyword list; `max_chars(0)`; `forbid(AND)` on 1-6.
- **CC-13 [Integration]** The Playtest Log records `offer_shown`, `try` / `later`, `challenge_start {source: offer | chapter_list}`, each attempt `{verdict, rule_met}`, and `cleared`, with puzzle id and timestamp.
- **CC-14 [Audio]** The challenge-clear stamp sound's peak is ≥ 6 dB below the PASS stamp's peak (measured on the exported audio assets; audio lead signs off).

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Is the challenge offer right after the PASS too pushy, or exactly when curiosity peaks? Measure Try/Later rates in the playtest log. | game-designer (playtest) | MVP playtest |
| 2 | Should challenges have their own hints (step 1 only)? MVP reuses the base puzzle's hints. | game-designer | After MVP playtest |
| 3 | Efficiency stats (VS) — does a `max_chars` challenge duplicate the efficiency metric? Decide when the efficiency metric is chosen. | systems-designer | Efficiency Stats GDD |
