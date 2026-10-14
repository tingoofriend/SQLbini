# Puzzle Definition & Datasets

> **Status**: In Review
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-14 (2026-10-14 cross-GDD review fixes)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 1 — The Condition, Not the Screen; Pillar 4 — Real Store, Real SQL

## Summary

Puzzle Definition & Datasets is the data format and content pipeline for every
SQLbini puzzle: the request, the store's tables, the visible and hidden datasets,
the reference answer, the traps with their tagged rows and feedback, and
alternative correct answers. Its content verifier proves each puzzle is fair —
correct answers pass, each trap is caught where intended — before it can ship.
Players never see it; they feel it as requests that sound real and hidden data
that knows which boundary they forgot.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `None (implements the Hidden-Data Grader contract)`

## Overview

The Puzzle Definition & Datasets system is the data format and the content
pipeline for every puzzle in SQLbini. A puzzle definition holds everything the
game needs to present, run and grade one request: who asks and what they say,
the table schema, the visible dataset the player works with, two or more hidden
datasets built to catch misunderstandings, the reference answer, the traps with
their tagged rows and feedback lines, alternative correct answers used to prove
the grader is fair, and any constraint challenge. Players never see this system
directly — they feel it as requests that sound like a real store and as hidden
data that always seems to know which boundary they forgot. It exists because
SQLbini's quality is mostly content quality: every puzzle is hand-built, and a
mistake in a hidden dataset either lets a wrong query pass (Pillar 1 breaks) or
fails a right one (Pillar 2 breaks). The system therefore includes a **content
verifier** — the successor of `prototypes/sqlbini-web/ch1.py` — that proves each
puzzle is fair before it ships. The on-disk file format and loader technology
are not specified here → they become an ADR.

## Detailed Design

### Core Rules

**Chapters own the store; puzzles own the question**

1. A **chapter definition** holds what all its puzzles share: chapter id, the
   in-game "today" date, the **schema** (tables and typed columns), the **base
   visible dataset**, the **base hidden datasets**, and its **shifts** (name,
   briefing line, flavour wage — `shift-and-chapter-progression.md`). In Chapter 1 all 13
   puzzles share one `products` table, one visible dataset and hidden sets A and
   B — the content pattern `ch1.py` already proved.
2. A **puzzle definition** holds what is specific to one request. A puzzle uses
   its chapter's datasets unless it declares an override (rule 5).

**Puzzle fields** (all data-driven; none hardcoded)

| Field | Required | Owner of meaning | Notes |
|---|---|---|---|
| `id`, `chapter`, `shift`, `order` | yes | Shift & Chapter Progression | e.g. `1-5`, chapter 1, shift 2, position 1 |
| `kind` | yes | Grader / Modify Puzzle Grading | `query` (MVP) or `modify` (Alpha) |
| `flags` | yes | Progression | `tutorial`, `side`, `boss` (any combination). `boss` must agree with Progression's position rule (the last main request of the last shift, `shift-and-chapter-progression.md` rule 1); the verifier rejects a mismatch |
| `title` | yes | Workbench | Short, store-flavoured |
| `request` | yes | Request & Reaction Dialogue | `speaker` id + `line`; written to the trap philosophy (rule 9) |
| `reference_sql` | yes | Grader | The canonical answer; must be deterministic |
| `key_column` | yes when tagged traps exist | Grader | `table.column` that identifies a source row, e.g. `products.name`; values unique per table. The reference result must have exactly one output column with this column's name — its index is the **key position** (grader rule 2) |
| `ordered`, `order_cols` | yes | Grader | `ordered` true only if `reference_sql` has a top-level `ORDER BY`; each `order_cols` entry is a column of the reference result and appears in that `ORDER BY`, in the same order |
| `traps` | yes (≥ 1 unless `tutorial`) | Grader | List of traps — rule 4 |
| `trap_priority` | yes when traps exist | Grader | Ordered list of trap ids for cause selection |
| `alt_valid` | yes (≥ 1 unless `tutorial`) | Content verifier | Other correct queries; must pass every dataset (rule 11) |
| `hints` | yes | Hint System | Two hint texts, step 1 and step 2; optional per-puzzle unlock overrides (`hint1_fails`, `hint1_minutes`, …) |
| `pass_reaction` | yes | Request & Reaction Dialogue | The requester's line on PASS |
| `manual_pages` | yes | Store Manual | List of Store Manual page ids (`manual.<slug>`) this request unlocks when opened (Store Manual rule 5); may be empty |
| `prefill_sql` | no | this system (read by Onboarding, Store Manual, Progression) | Text placed in the editor when the request opens or is restarted; always written with a trailing `;`. 1-1: `SELECT * FROM products;`. Onboarding uses it for 1-1, the Store Manual exempts it from its CI check, Progression's Restart (rule 12a) restores it |
| `constraint` | no | Constraint Challenges | `{type: max_chars / forbid / require, value, offer_line, witness_sql, unlock_after?}` — `unlock_after` optional (a later main puzzle id, `constraint-challenges.md` rule 2a); validated by `constraint-challenges.md` rule 12 |
| `datasets_override` | no | this system | Puzzle-specific dataset changes (rule 5) |
| `content_status` | yes | this system | `draft` / `verified` / `playtested` / `locked` (States) |

3. The **target result** the workbench shows is not stored: it is computed by
   running `reference_sql` on the visible dataset, so it can never drift from
   the reference. A puzzle file that contains a stored target field is rejected
   at load.

**Traps**

4. A trap has: `id` (stable, e.g. `boundary_200`); a designer `note` (what
   misunderstanding it catches); `trap_sql` — one representative wrong query
   that makes this mistake, used only by the verifier; `expected_cause` — the
   cause the grader should report for `trap_sql` (defaults to the trap's own
   `id`; may be a built-in cause — `columns`, `order` or `generic` — for traps
   such as "selected every column" or "kept duplicates", which need no tags);
   `tagged_keys` — per dataset, **visible included**, the key values of *every*
   row the mistake wrongly keeps or drops on that dataset (required only when
   `expected_cause` is the trap id; the grader names a trap only when the
   differences are fully explained by tags — grader rule 10.4). A mistake that
   changes a row's *values* rather than its membership cannot be tagged; its
   `expected_cause` is `generic`; `caught_by` —
   the hidden datasets expected to fail `trap_sql`; and `feedback` — for a
   tagged trap, level-1 text (required), level-2 and level-3 texts (optional
   until Vertical Slice; level 3 is a synthetic counter-example row the player
   can add in the Back Room (Alpha, Chapter 2+), never a hidden row). An untagged trap carries no
   feedback: the grader reports a built-in cause and shows that cause's shared
   feedback.
5. **Dataset overrides.** A dataset is defined as a base plus operations:
   `add` rows, `remove` rows by key, `set` column values by key, `reverse` the
   row order, and `renumber(start = N)` — which assigns ids N, N+1, … in the
   current row order. Chapter hidden sets are themselves defined this
   way from the visible base (Chapter 1: hidden A = visible + 10 edge rows;
   hidden B = A reversed, new ids, 3 values changed). A puzzle may append
   operations for its own needs; it never edits the chapter's base.
6. Every puzzle grades on **visible + ≥ 2 hidden datasets**. If the puzzle has
   at least one **tagged trap** (`expected_cause` = its own id), at least one
   hidden dataset must be **hardcode-proof** (Formulas; Hidden-Data Grader,
   rule 2): the reference answer on it is not just the visible answer's names —
   it adds a row the visible data lacks (Lemon Soda) or drops a visible answer
   whose data changed (Potato Chips at ¥140 in B). Tags may sit on any row,
   visible-origin rows included (1-11 tags Strawberry Yogurt).

**Data realism (Pillar 4)**

7. Values follow the store: prices in tax-included integer yen; dates as
   `'YYYY-MM-DD'` text; product and chain names fictional; categories in the
   chapter's vocabulary. Hidden edge rows must be things a konbini could
   plausibly stock (Lemon Soda at ¥200, a Vinyl Umbrella under Misc) — never
   obviously artificial rows like `'TEST_ROW'`.
8. A visible dataset is small enough to read on screen: at most
   `visible_rows_max` rows per table (Formulas).

**Writing requests (trap philosophy)**

9. Requests use natural store language and **do not spell out the boundary**
   ("drinks under 200" — not "200 yen or less"); the requester's pass or fail
   reaction resolves the ambiguity. Traps come from what the data *means* —
   NULLs, duplicates, letter case, trailing spaces, items filed in an
   unexpected category, boundary values. This cannot be machine-checked; it is
   a review checklist item (rule 13). Chapter 1 requests 1-4, 1-5, 1-7 and 1-8
   currently state their boundaries and must be rewritten.

**Content verifier** (successor of `ch1.py`; runs in CI and on load)

10. The verifier builds every dataset, then checks every puzzle against the
    Hidden-Data Grader's validation rules and the rules below. A puzzle that
    fails any check cannot reach `verified` and is withheld from play. **CI
    fails** when a puzzle at `verified` or later is invalid; failures of `draft`
    puzzles are reported but do not fail CI. The same checks run in CI and at
    game load, so the two must agree on every puzzle.
11. **Fairness to correct answers (Pillar 2):** every `alt_valid` query must
    PASS — match the reference on every dataset.
12. **Traps are caught as designed (Pillar 1):** for each trap, `trap_sql` must
    FAIL; the grader's chosen cause for it must equal the trap's
    `expected_cause`; and the hidden datasets where it fails must equal
    `caught_by` (which may not be empty).
13. **Review checklist** (human, before `playtested`): request does not spell
    out the boundary; at least one trap passes the visible dataset and fails a
    hidden one (the core "aha" shape); edge rows are plausible; level-1 feedback
    is jargon-free and in the requester's voice.
14. Per puzzle, the verifier's report lists each check's result (true/false)
    and observations — trap count, how many traps pass visible, dataset sizes,
    which datasets catch each trap, and warnings. It gives no score or rating.
    Optional lint **warnings** (never failures) flag non-integer prices, dates
    not in `YYYY-MM-DD`, and names containing `TEST`.

### States and Transitions

**Content lifecycle** (per puzzle, stored in `content_status`). When a puzzle
reaches `verified`, its **content hash** is stored with the status. The hash
covers every field of the puzzle definition **except `content_status` and the
stored hash itself**, plus the puzzle's resolved datasets (chapter schema, base
datasets and the puzzle's overrides) — so changing the status never changes
the hash, and any edit to content or data does. Field order and whitespace in
the file do not count (the hash is taken over a canonical serialisation; format
→ ADR, Open Question 1). CI and the game loader recompute it; a different hash
means the puzzle was edited and is treated as `draft` until re-verified. The
Playtest Log records this same hash.

| State | Meaning | To | When |
|---|---|---|---|
| `draft` | Being written | `verified` | Content verifier passes every check (rules 10–12) |
| `verified` | Machine-checked | `playtested` | A Playtest Log entry exists for this puzzle id at the current content hash, and a review-checklist record (rule 13) is filed with it |
| `verified` / `playtested` / `locked` | | `draft` | Any edit to the puzzle or to its chapter's datasets |
| `playtested` | Played and reviewed | `locked` | Chapter content lock |
| `locked` | Shipping content | `draft` | Only by an explicit unlock (any edit) |

**Runtime load state** (per puzzle, per launch): `loaded` if the puzzle passes
the grader's validation rules at load **and** its effective status is allowed
in this build; `withheld` otherwise — it does not appear in play and the reason
is reported. Developer builds allow every status; playtest and release builds
allow only `verified` or later with a matching hash (a `draft` puzzle never
reaches a tester).

### Interactions with Other Systems

| System | Reads | Owner of the interface |
|---|---|---|
| Hidden-Data Grader | `reference_sql`, `key_column`, `ordered`/`order_cols`, datasets, `traps` (tagged keys, feedback), `trap_priority`, `kind` | Grader (contract in `hidden-data-grader.md`) |
| SQL Execution Sandbox | Schema + resolved dataset rows to build a fresh database | Sandbox |
| Query Workbench | `title`, `request`, schema (for the schema browser), visible dataset, target result (computed) | Workbench |
| Back Room | Visible dataset (to copy); level-3 synthetic rows (Alpha, Chapter 2+) | Back Room |
| Hint System | `hints` | Hint System |
| Constraint Challenges | `constraint` | Constraint Challenges |
| Shift & Chapter Progression | `id`, `chapter`, `shift`, `order`, `flags` (`boss` checked against its position rule), chapter "today", shift wage and briefing; `prefill_sql` for Restart | Progression |
| Request & Reaction Dialogue | `request` (incl. `speaker` ids), `pass_reaction`, trap `feedback` texts, shift briefings | Dialogue |
| Store Manual | `manual_pages`; `prefill_sql` (exempt from its CI check) | Store Manual |
| Onboarding: First Shift | `tutorial` flags (1-1, 1-2); `prefill_sql` (1-1) | Onboarding |
| Playtest Log | `id` and a content version (hash) so logs can be tied to the exact puzzle | Playtest Log |
| Modify Puzzle Grading (Alpha) | A future `target_state` field for `modify` puzzles | Modify Puzzle Grading |

## Formulas

*Proposed by `systems-designer` (2026-10-14). Grader formulas (`result_match`,
`rows_ok`, `R_cap`) are referenced, not redefined — see `hidden-data-grader.md`.*

The **hardcode_proof** formula is defined as:

`hardcode_proof(d) = keys(ref(d)) ≠ (keys(ref(visible)) ∩ K_d)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d | dataset id | the puzzle's hidden datasets | data file | Hidden dataset under test |
| keys(ref(x)) | set of text | 0 – rows in x | calculated | Values at the key position in the reference result on dataset x |
| K_d | set of text | rows in d | calculated | `key_column` values present in dataset d |

**Output Range:** boolean. `true` means a query that lists the visible answer's
names (`WHERE name IN (…)`) fails on d. Independent of tags. Only evaluated
when the puzzle has tagged traps (rule 6).
**Example (1-5, key `name`):** visible answer {Mineral Water 500ml, Green Tea
500ml, Canned Coffee}; reference on A adds Lemon Soda → proof. **1-6:** A adds
no snack ≥ ¥150, but in B Potato Chips (Salted) costs ¥140 and drops out of the
reference → B is proof. **1-10:** A adds Vinyl Umbrella → proof, although its
`null_compare` tags include visible rows.

The **puzzle_valid** formula is defined as:

`puzzle_valid(p) = H ∧ R ∧ A ∧ T ∧ F ∧ K ∧ O ∧ V ∧ C`

- `H = |hidden| ≥ 2 ∧ (no tagged traps ∨ ∃h ∈ hidden: hardcode_proof(h))`
- `R = ∀d ∈ D: ref runs without error ∧ ref is deterministic on d ∧ rows_ok(ref(d))`
- `A = ∀a ∈ alt_valid: ∀d ∈ D: result_match(a(d), ref(d))`
- `T = ∀t ∈ traps: fails(t.trap_sql) ∧ cause(t.trap_sql) = t.expected_cause ∧ caught(t) = t.caught_by ∧ t.caught_by ≠ ∅`
- `F = ∀t ∈ traps: t.id ∈ trap_priority ∧ (t untagged ∨ (t.tagged_keys ≠ ∅ ∧ t.feedback[1..feedback_max_level] all ≠ ""))`
- `K = no tagged traps ∨ (exactly one output column of ref is named like key_column)`
- `O = ordered ⇒ (ref has a top-level ORDER BY ∧ order_cols valid)`
- `V = ∀ table: |visible rows| ≤ visible_rows_max`
- `C = tutorial ∈ flags ∨ (|traps| ≥ traps_min ∧ |alt_valid| ≥ alt_min)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| D | list | visible + 2–5 hidden | data file | All datasets of the puzzle (after overrides) |
| caught(t) | set | ⊆ hidden | calculated | Hidden datasets on which `t.trap_sql` fails |
| expected_cause | enum | trap id / `columns` / `order` / `generic` | data file | Defaults to the trap's id |
| traps_min | int | 1–3 (default 1) | data file | Minimum traps per non-tutorial puzzle |
| alt_min | int | 1–3 (default 1; 2 recommended for bosses) | data file | Minimum `alt_valid` queries per non-tutorial puzzle |

**Output Range:** boolean. `false` ⇒ the puzzle stays `draft` and is `withheld`
at runtime. Warnings (an `ORDER BY` with `ordered = false`; a REAL near a
rounding boundary; a zero-row reference; a hidden set equal to visible) never
enter the conjunction.
**Example (1-5):** H — A is hardcode-proof ✓. R — reference returns 3 / 4 / 5 rows on
visible / A / B ✓. T — `price < 200` passes visible, fails A and B, cause
`boundary_200`, `caught_by = {A, B}` ✓. K — `name` is selected ✓. Valid once tags,
feedback and `alt_valid` are authored.

The **visible_rows_max** constant is defined as:

`visible_rows_max = 30`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| visible_rows_max | int | 24–40 (default 30) | data file | Maximum rows per visible table |

**Output Range:** The Query Workbench shows `rows_visible = 7` rows at the
default 24 px row height (`query-workbench.md`, with the 120 px counter scene),
so 30 rows is about four screens of scrolling and Chapter 1's 24 rows about
three and a half. Below 24, all of Chapter 1 is withheld; above 40, the player
scrolls through data they are meant to read, against Pillar 3. Whether 24–30
rows read comfortably in a 7-row panel is a playtest question (Open Question 6).
**Example:** Chapter 1 has 24 ≤ 30 → V holds with 6 rows to spare.

The **authoring_effort** formula is defined as (*informational — for scope
planning, never a validity check*):

`E(p) = E_req + T × (E_trap + E_fb × L_max) + A × E_alt`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| T | int | 0–5 | data file | Trap count |
| A | int | 0–4 | data file | `alt_valid` count |
| L_max | int | 1–3 | data file | `feedback_max_level` |
| E_req, E_trap, E_fb, E_alt | int (minutes) | 20, 15, 5, 5 | constant | Guessed per-item authoring minutes — not measured |

**Output Range:** ≥ 20 minutes per puzzle.
**Example (1-11, T = 2, A = 2):** at `L_max = 1`: 20 + 2 × 20 + 10 = 70 min; at
`L_max = 3`: 90 min. Chapter 1 at A = 2, `L_max = 1` ≈ 11 hours over 13 puzzles —
excluding the request rewrites and playtesting. Replace the guesses with
measured times after migrating Chapter 1.

## Edge Cases

*Drafted without `systems-designer` — Lean mode (Section E is not a high-risk
section).*

**Datasets**
- **If a dataset operation targets a key that does not exist** (`remove`/`set` on
  an unknown name): the dataset fails to build; the verifier reports the
  operation and every puzzle using that dataset is withheld.
- **If an `add` operation introduces a key that already exists in the dataset**:
  build fails (keys must be unique per table within a dataset).
- **If a puzzle override changes a row a chapter-level trap of another puzzle
  depends on**: no effect on the other puzzle — overrides apply only to the
  puzzle that declares them.
- **If a chapter's base dataset is edited**: every puzzle in that chapter returns
  to `draft` and must be re-verified (States).
- **If a value's type does not match its column** (text in an INTEGER price):
  build fails. SQLite's type affinity would accept it silently; the verifier
  must not.
- **If a hidden dataset is identical to the visible one**: valid but useless —
  the verifier reports it (rule 14) and that set can never be hardcode-proof.

**Traps and answers**
- **If `trap_sql` passes every dataset**: the trap is not caught → puzzle invalid
  (the hidden data does not do its job).
- **If `trap_sql` fails but the grader's chosen cause differs from the trap's
  `expected_cause`**: invalid — the tags, `trap_priority` or `expected_cause`
  are wrong.
- **If a puzzle's only traps are untagged** (`expected_cause` is `columns`,
  `order` or `generic` — e.g. S-1 "kept duplicates"): no `key_column` and no
  hardcode-proof set are required; ≥ 2 hidden datasets still are. Hardcoding is still
  caught when a hidden set adds values the visible set lacks (S-1: the Misc
  category exists only in hidden A).
- **If `trap_sql` fails on a different set of datasets than `caught_by`**: invalid
  — the author's model of the trap is wrong; fix the data or the declaration.
- **If an `alt_valid` query fails any dataset**: invalid — a correct answer
  would be rejected (Pillar 2). The fix is the data or the reference, never
  removing the `alt_valid` entry to make the check pass.
- **If two traps tag the same key on the same dataset**: allowed; `trap_priority`
  decides which cause is reported.
- **If a trap's level-2 or level-3 feedback is missing**: allowed while
  `feedback_max_level` is 1 (MVP); invalid once it is raised to 3.
- **If the reference result has zero rows on some dataset**: allowed (e.g. a
  "no expired items today" check), but the verifier reports it, because a
  zero-row target makes several wrong queries look right on that dataset.

**Authoring**
- **If a puzzle is marked `tutorial`**: traps and `alt_valid` may be empty; all
  other rules apply. Only 1-1 and 1-2 in Chapter 1 qualify.
- **If `request.line` contains an explicit operator boundary** ("or less", "at
  least", "between … and …" stated with the bound): not machine-rejected; flagged
  by the review checklist (rule 13).
- **If two puzzles share an `id`**: load fails for the chapter.

## Dependencies

**Upstream:** none — this is a Foundation system. It *implements* contracts
stated by other systems:

| Contract from | GDD | What this system must provide | Status |
|---|---|---|---|
| Hidden-Data Grader | `design/gdd/hidden-data-grader.md` | `reference_sql`, `key_column`, `ordered`/`order_cols`, visible + ≥2 hidden datasets with ≥1 hardcode-proof, trap tags (as `tagged_keys`, per dataset incl. visible), key position, `trap_priority`, feedback levels 1–3, `kind` | In Review — this GDD implements it |

**Downstream — systems that read puzzle data:**

| System | Nature | What they read |
|---|---|---|
| Hidden-Data Grader | hard | Grading fields (above) |
| SQL Execution Sandbox | hard | Schema + resolved datasets |
| Query Workbench | hard | Title, request, schema, visible data, target result |
| Back Room | hard | Visible dataset; level-3 synthetic rows (Alpha, Chapter 2+) |
| Hint System | hard | `hints` |
| Constraint Challenges | hard | `constraint` |
| Shift & Chapter Progression | hard | ids, ordering, flags, chapter "today", shift wage and briefing, `prefill_sql` |
| Request & Reaction Dialogue | hard | `request` (speaker ids), `pass_reaction`, trap feedback, shift briefings |
| Store Manual | soft | `manual_pages`, `prefill_sql` |
| Onboarding: First Shift | soft | `tutorial` flags, `prefill_sql` |
| Playtest Log | soft | id + content version |
| Modify Puzzle Grading (Alpha) | hard | future `target_state` |

**Bidirectionality:** verified 2026-10-14 (design review) — the grader, sandbox,
workbench, hint, constraint, progression, dialogue, store manual, onboarding and
playtest log GDDs list *Puzzle Definition & Datasets*. Back Room and Modify Puzzle
Grading (Alpha) have no GDD yet; each must list it when written.

## Tuning Knobs

All values live in the content config, not in code.

| Knob | Default | Safe range | Affects | Source |
|---|---|---|---|---|
| `visible_rows_max` | 30 | 24–40 | How much visible data a puzzle may show; below 24 withholds Chapter 1 | Formulas; registry |
| `traps_min` | 1 | 1–3 | Minimum traps per non-tutorial puzzle (`C`); higher raises authoring cost (`authoring_effort`) | Formulas |
| `alt_min` | 1 (2 for bosses recommended) | 1–3 | Minimum `alt_valid` answers (`C`); the Pillar 2 fairness proof | Formulas |
| `feedback_max_level` | 1 (MVP) / 3 (VS) | 1–3 | Which feedback levels every tagged trap must author (`F`) | Grader `feedback_level`; registry |

## Visual/Audio Requirements

None — this system is data only. How puzzle content looks on screen is owned by
the Query Workbench (request, schema browser, tables) and Request & Reaction
Dialogue (speaker portraits, lines).

## Game Feel

None directly. The feel it supports: requests that sound like real customers,
and hidden data that seems to "know" the boundary the player forgot. Both are
content-quality targets enforced by the review checklist (rule 13), not by
runtime behaviour.

## UI Requirements

No player-facing UI. Developer-facing output only: the content verifier prints
a per-puzzle report (each check true/false plus observations, no score — rule
14) in CI and on the command line. No in-game editor is planned; puzzles are
authored as text data files (format → ADR).

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hidden-data-grader.md` | Core Rules 2–6, Dependencies, Formulas | Grading contract this format implements; `result_match`, `R_cap`, cause selection | In Review |
| `design/gdd/game-concept.md` | Rules 7, 9, 13 | Trap philosophy, data realism, Pillars 1, 2, 4 | Source of intent |
| `design/levels/chapter-1-puzzles.md` | Rules 1, 5, 9 | Chapter 1 puzzles, edge rows, the four requests to rewrite | Level design (to be migrated into this format) |
| `prototypes/sqlbini-web/ch1.py` | Rules 1, 5, 10–12 | The prototype verifier this pipeline succeeds | Prototype — reference only |
| `design/registry/entities.yaml` | Formulas | `grader_row_cap` (5000) | Registered |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grading behaviour is covered by
`hidden-data-grader.md` AC-01…26 and not repeated. Dataset sizes, B's ids and
changed values, S-1's distinct-category counts and its `GROUP BY` alternative were
re-checked against `prototypes/sqlbini-web/ch1.py`.*

**Fixtures.** Chapter 1 base: visible 24 rows (ids 1–24); hidden A = visible + 10
edge rows (34); hidden B = A reversed, renumbered from 101, with Shoyu Cup Ramen
stock 3, Potato Chips (Salted) ¥140, Cola 500ml ¥200 (34). Puzzle 1-5: reference
`SELECT name, price FROM products WHERE category = 'Drinks' AND price <= 200`; key
`products.name`; trap `boundary_200` with `trap_sql` `… price < 200`, tags A
{Lemon Soda}, B {Lemon Soda, Cola 500ml}, `caught_by` {A, B}; `alt_valid`
`… WHERE category IN ('Drinks') AND NOT price > 200`; `traps_min = alt_min = 1`;
`feedback_max_level = 1`. "Invalid" = the verifier reports the puzzle invalid
and names the failing check.

**Datasets**
- **D-01 [Logic]** GIVEN the Chapter 1 base, WHEN datasets are built, THEN visible / A / B have 24 / 34 / 34 rows; in B, id 101 is Vinyl Umbrella and id 134 is Shoyu Cup Ramen with stock 3; Potato Chips is 140 in B and 168 in A; Cola is 200 in B and 216 in A.
- **D-02 [Logic]** GIVEN a `set` or `remove` on key "Oolong Tea" in A (no such row), WHEN built, THEN the build fails, the report names the operation, and every puzzle using A is withheld.
- **D-03 [Logic]** GIVEN an `add` of a second "Lemon Soda" row to A, WHEN built, THEN the build fails with a duplicate-key error.
- **D-04 [Logic]** GIVEN `set` Cola 500ml `price = 'two hundred'`, WHEN built, THEN the build fails with a type error.
- **D-05 [Logic]** GIVEN puzzle 1-9 with override `remove` Choco Banana Ice Bar on A, WHEN built, THEN 1-9's A has 33 rows, 1-3's A still has 34 rows including that item, and the chapter base file is byte-identical.
- **D-06 [Logic]** GIVEN 1-5, WHEN the target is computed, THEN it has 3 rows (Mineral Water 500ml, Green Tea 500ml, Canned Coffee); WHEN only the visible dataset's Cola price is set to 200, THEN it has 4 rows including Cola; the puzzle file holds no target field, and a file that does is rejected at load.

**puzzle_valid** (1-5 as given is valid; each case changes one thing)
- **V-H [Logic]** GIVEN 1-5, THEN valid (A and B hardcode-proof); WHEN Lemon Soda is removed from A and B and Cola stays ¥216 in B, THEN invalid on H. GIVEN 1-10 with `null_compare` tagging the visible NULL-expiry rows, THEN valid (tags on visible rows do not affect H).
- **V-R [Logic]** WHEN the reference is `… FROM product` (typo), THEN invalid on R.
- **V-A [Logic]** WHEN `alt_valid` is `… price < 200`, THEN invalid on A and the report names that query and {hidden A, hidden B}.
- **V-T [Logic]** WHEN (a) `trap_sql` equals the reference, (b) `expected_cause` is `columns`, (c) `caught_by` is {A}, or (d) `caught_by` is {}, THEN each is invalid on T.
- **V-F [Logic]** WHEN `trap_priority` is `[]`, THEN invalid on F; WHEN `boundary_200` has `tagged_keys` {}, THEN invalid on F; WHEN level-2 text is missing, THEN valid at `feedback_max_level = 1` and invalid at 3.
- **V-K [Logic]** WHEN the reference is `SELECT category, price …` (no `name`), THEN invalid on K.
- **V-O [Logic]** WHEN `ordered: true` with `… ORDER BY price, name` and `order_cols [price, name]`, THEN valid; `ordered: true` with no `ORDER BY` → invalid on O; `ordered: false` with an `ORDER BY` → valid with a warning.
- **V-V [Logic]** WHEN the visible table has 24 or 30 rows, THEN valid; 31 rows → invalid on V.
- **V-C [Logic]** WHEN `traps: []` or `alt_valid: []` on a non-tutorial puzzle, THEN invalid on C.
- **V-S1 [Logic]** GIVEN S-1 with reference `SELECT DISTINCT category FROM products` (7 / 8 / 8 rows), trap `SELECT category FROM products` with `expected_cause: generic`, no key column, no tags, `caught_by` {A, B}, and `alt_valid` `SELECT category FROM products GROUP BY category`, THEN valid; WHEN hidden B is removed, THEN invalid on H.
- **V-TUT [Logic]** GIVEN 1-1 flagged `tutorial` with no traps and no `alt_valid`, THEN valid; WHEN its visible table has 31 rows, THEN invalid on V (the flag waives only C).

**Lifecycle and load**
- **L-01 [Logic]** GIVEN 1-5 `verified` with a stored content hash, WHEN its step-2 hint text is edited, THEN its recomputed hash differs and it is treated as `draft`; WHEN the chapter's visible dataset is edited, THEN all 13 Chapter 1 puzzles are `draft`; an invalid puzzle never becomes `verified`.
- **L-06 [Logic]** GIVEN 1-5 `verified`, WHEN only `content_status` changes to `playtested`, or the file's field order / whitespace changes, THEN the recomputed hash is unchanged; WHEN a dataset override is added, THEN it changes.
- **L-07 [Integration]** GIVEN 1-5 valid but `draft`, WHEN a playtest build launches, THEN 1-5 is withheld with reason "draft"; WHEN a developer build launches, THEN it is playable.
- **L-02 [Integration]** GIVEN 1-5 with `caught_by` {A} (invalid), WHEN the game launches, THEN 1-5 is absent from its shift, the other 12 puzzles are playable, and the log names `1-5` and check `T`.
- **L-03 [Integration]** GIVEN two puzzles with id `1-5`, WHEN the chapter loads, THEN the chapter fails to load with a duplicate-id error.
- **L-04 [Integration]** GIVEN the same content, WHEN the CI verifier and the game loader both run, THEN every puzzle's valid / withheld result is identical. *(Depends on Open Question 2.)*
- **L-05 [Content-CI]** GIVEN a `verified` puzzle that is invalid, WHEN CI runs, THEN CI fails; GIVEN a `draft` puzzle that is invalid, THEN CI reports it and passes.

**Report and content**
- **R-01 [Content-CI]** GIVEN 1-5, WHEN CI runs, THEN the report shows each check true/false, 1 trap, 1 trap passing visible, sizes 24 / 34 / 34, and `boundary_200` caught by {A, B}; warnings (hidden set equal to visible, zero-row reference, `ORDER BY` with `ordered: false`) appear without changing validity; no score or rating appears.
- **R-02 [Content-CI]** GIVEN all 13 migrated Chapter 1 puzzles, WHEN CI runs, THEN every one passes `puzzle_valid`. *(Depends on Open Question 3; Open Question 5 is closed — 15 traps.)*
- **R-04 [Logic]** GIVEN Chapter 1 with `boss` on 1-10 instead of 1-11 (or on both), WHEN loaded, THEN the verifier reports a `boss` flag / position mismatch and the chapter fails verification.
- **R-03 [Logic]** GIVEN a `constraint` missing `type`, `value`, `offer_line` or `witness_sql`, or with a `type` other than `max_chars` / `forbid` / `require`, WHEN loaded, THEN the puzzle is invalid and the report names the missing or bad field (semantic checks are `constraint-challenges.md` CC-11/12).

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | On-disk format and loader: Godot `Resource` (`.tres`), JSON/YAML, or SQL scripts plus a manifest? Must be text, diffable, and readable by both the game and the CI verifier. | technical-director → ADR | Technical Setup |
| 2 | Does the CI verifier run in Godot (same SQLite as the game, via godot-sqlite) or in Python (`ch1.py` lineage, stdlib `sqlite3`)? Running it in Godot avoids engine/version drift between verifier and game. | technical-director → ADR | Technical Setup |
| 3 | Chapter 1 migration: author trap tags, key column, `trap_priority`, level-1 feedback, `alt_valid` and the rewritten requests for all 13 puzzles. Who checks the rewritten 1-4/1-5/1-7/1-8 make players fail on first submit? | level design + zero-SQL playtest | Before Chapter 1 content locks |
| 4 | Should a later chapter's schema (e.g. `sales`, `customers`) be a superset of Chapter 1's `products`, or a fresh store database per chapter? | game-designer | Chapter 2 design |
| 5 | ~~`ch1.py` has 15 traps while `chapter-1-puzzles.md` says 16~~ — closed: 15 is correct; `chapter-1-puzzles.md:175` miscounted (cross-GDD review 2026-10-14). | — | Resolved 2026-10-14 |
| 6 | Do 24–30 visible rows read comfortably in the workbench's 7-row result panel, or should `visible_rows_max` drop (or the panel grow)? Pending `/ux-design` (dedicated visible-data view question, cross-GDD review W30). | ux-designer (`/ux-design`) + playtest | Query Workbench UX spec / first playtest |
