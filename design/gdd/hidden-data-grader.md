# Hidden-Data Grader

> **Status**: Approved
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-15 (wording: `TOO_MANY_ROWS` on any visible run, from the Dialogue re-review 6c; earlier: re-review fixes: rule 7a, neutral statements; earlier: cross-GDD review fixes; art-bible sync 2026-10-14)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 1 — The Condition, Not the Screen; Pillar 2 — Your Query, Your Way

## Summary

The Hidden-Data Grader decides whether a submitted query is correct by running it
and the reference query on the visible data and on two or more hidden datasets
the player never sees, and comparing the results. A pass means the query holds
on any day's data; a fail returns one cause and a plain-language symptom in the
requester's voice — never a hidden row. It is the mechanism behind Pillars 1
and 2: any query that meets the condition passes, and hardcoded or
boundary-careless queries fail.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `SQL Execution Sandbox, Puzzle Definition & Datasets`

## Overview

The Hidden-Data Grader decides whether a submitted query is correct. When the
player presses **Submit**, it runs the player's query and the puzzle's reference
query on the visible dataset and on every hidden dataset, compares the results,
and returns a verdict: **pass**, **fail** with a cause, or **submit error** (or
**unavailable** when the puzzle's own data is broken — rule 9a). On a
fail it chooses what the requester says — a plain-language symptom tied to the
kind of mistake ("You let in something that isn't a snack"), escalating in
specificity over repeated fails — and it never reveals a hidden row. For the
player, the grader is the moment of truth that turns "it looked right" into
"it holds on any day's data"; it is the mechanism behind both the freedom of
Pillar 2 (any query that meets the condition passes) and the rigour of Pillar 1
(hardcoded or boundary-careless queries fail). Without it, the game is a SQL
console with a target table — the trap, the "aha" and the core fantasy all live
here. Engine and data-access choices (how SQLite is called, how results are
shaped) are not specified here → they become ADRs.

## Detailed Design

### Core Rules

**Datasets**

1. Every puzzle grades on an ordered list of datasets: `visible` first, then
   two or more hidden datasets. The visible dataset is the one the player sees
   and runs against; hidden datasets are never shown.
2. Every puzzle with at least one tagged trap declares a **key column** (e.g.
   `name` in `products`) that identifies a source row. The reference result
   must contain exactly one output column with that name; its index is the
   puzzle's **key position**, fixed at load from the sandbox's column names.
   The player's result is read at the same position (column names are ignored,
   column order is significant — rule 16). At least one hidden dataset must be
   **hardcode-proof**: the set of key values in the reference result on it
   differs from the visible answer's key values that exist in it
   (`hardcode_proof`, `puzzle-definition-and-datasets.md` Formulas). A query that lists the visible answer's names therefore
   fails on that dataset — it misses a row it has never seen, or keeps a row
   whose data changed. (Traps whose cause is a built-in one — `columns`,
   `order`, `generic` — need no tags; see `puzzle-definition-and-datasets.md`
   rule 4.) The loader checks this (Edge Cases).
3. Every row that a trap's mistake gets wrong is **tagged** in the puzzle data
   with that trap's id, on every dataset where it is wrong — visible included
   (e.g. the ¥200 Lemon Soda row carries `trap: boundary_200`). Tags are
   content, owned by Puzzle Definition & Datasets; the grader only reads them.
4. The grader validates a puzzle when it is loaded (see Edge Cases) and refuses
   to grade a puzzle that breaks rules 2–3.

**Submitting**

5. A submit takes the player's SQL text, the puzzle, and a **per-cause failure
   counter set supplied by the caller**. This rule is authoritative: for a main
   puzzle the caller passes the puzzle's counter set; in challenge mode it passes
   the per-challenge set (`constraint-challenges.md` rule 9.2). The grader reads
   and increments only the set it was given (rule 13).
6. **Pre-check.** The SQL is handed to the SQL Execution Sandbox once on the
   visible dataset. If the sandbox rejects it — syntax error, more than one
   statement, a statement that is not read-only in a query puzzle, or a timeout —
   or the result exceeds the row cap (Formulas), the verdict is **SUBMIT_ERROR**.
   A submit error carries the sandbox's `error_kind` and `error_text`, or — for a
   result over the cap — the grader-level kind `TOO_MANY_ROWS` (Request &
   Reaction Dialogue voices it; the workbench strip shows the `error_text`), and
   **does not count as a failed attempt**: a typo is not a misunderstanding
   (Pillar 3). A `CONTENT_ERROR` is not a pre-check rejection: it leads to
   UNAVAILABLE (rule 9a).
7. **Determinism check.** The player's query is run twice on the visible
   dataset — the pre-check run (rule 6) counts as the first. If the two results differ, the verdict is **FAIL** with cause
   `nondeterministic` (e.g. `RANDOM()`). The same check runs on the reference at
   puzzle load (Edge Cases).
7a. **Visible re-runs end like the pre-check.** If any later run of the
   player's query on the **visible** dataset — the determinism run (rule 7) or
   the visible grading run (rule 8) — returns a sandbox error (incl. `TIMEOUT`)
   or a `truncated` result, the verdict is **SUBMIT_ERROR** with that run's
   `error_kind` / `error_text` (or `TOO_MANY_ROWS`), not counted, exactly as if
   the pre-check had failed. Visible data is the player's own, so its error
   text leaks nothing, and a query timing out near the limit on one of three
   identical runs is not a misunderstanding (Pillar 3).
8. **Grading.** For each dataset in order, the player's query runs in a fresh
   database built from that dataset (the sandbox owns isolation) and is compared
   with the reference result for that dataset using the result-match rule
   (Formulas). **Reference results are cached** per puzzle and dataset for the
   session — references are deterministic and verified at load — so a submit
   costs `2 + D` sandbox executions (`sql-execution-sandbox.md`). All datasets
   are evaluated — no early exit — so the cause classification sees every
   failure, **except a `TIMEOUT` on a hidden dataset**, which stops grading at
   once with FAIL (`generic`), counted (a visible-run `TIMEOUT` is rule 7a).
9. **Verdict.** **PASS** if the results match on every dataset, visible
   included; otherwise **FAIL**. A hidden-dataset result the sandbox marks
   `truncated` (over `R_cap`) is a mismatch: `m_i = false`, cause `generic`,
   counted as a FAIL, with no detail shown.
9a. **UNAVAILABLE.** If the sandbox reports `CONTENT_ERROR` for any dataset
   (visible or hidden) during a submit, the submit is abandoned and the verdict
   is **UNAVAILABLE**: no state or counter change, payload `{verdict:
   UNAVAILABLE}` with no `error_text`, and the event is reported as a content
   bug. It is never a verdict on the player.

**Choosing the cause of a failure**

10. For a FAIL the grader picks exactly one cause, checking in this order and
    stopping at the first that applies:
    1. `nondeterministic` — rule 7.
    2. `columns` — the column count differs from the reference on any dataset.
    3. `order` — the puzzle is ordered (Formulas) and the rows match as a
       multiset but not as a list.
    4. **trap** — compute the rows that are missing from or extra in the
       player's result on each failing dataset (internally only). Each such row
       has a **key**: its value at the key position (rule 2). A row
       **inherits the trap tags** that the puzzle puts on that key in that
       dataset; a row whose key is not a tagged key value — for example because
       the player's column at the key position holds something else — inherits
       nothing. The cause is a trap only if the differences are **fully
       explained**: (a) every missing and extra row on every failing dataset
       inherits at least one tag, and (b) no key appears among both the missing
       and the extra rows of the same dataset (that is a row whose *values*
       are wrong, not a row wrongly kept or dropped). Then the cause is the
       collected tag that appears first in the puzzle's **trap priority
       list**. Otherwise the cause is `generic`: naming a trap the player did
       not fall into would mislead them more than the generic line.
    5. `generic` — anything else: the result differs on rows no trap anticipated.
11. The missing/extra row lists are used only for rule 10.4 and for the Playtest
    Log (which is developer-facing). **Nothing derived from them reaches the
    player or dialogue — not the rows, not their counts, not which hidden dataset
    failed.** Showing a hidden row lets the player special-case it and defeats
    Pillar 1.

**Feedback**

12. Each cause maps to authored feedback in the puzzle data, one text per level:
    - **Level 1 — symptom**: plain language, no SQL jargon, in the requester's
      voice ("Something in your list isn't a snack." / "A customer at exactly
      ¥200 got turned away.").
    - **Level 2 — clause**: points at the part of the query that is wrong
      (Vertical Slice).
    - **Level 3 — counter-example**: an authored *synthetic* row shown to the
      player as a concrete case the query mishandles (Vertical Slice); from
      Chapter 2 the player can also add it in the Back Room.
    `columns`, `order`, `nondeterministic` and `generic` have built-in feedback
    shared by all puzzles; trap causes need per-puzzle text.
    **Where it shows:** the requester's voiced line (Request & Reaction
    Dialogue, from the feedback key) appears only in the counter-scene bubble;
    the workbench note carries the grader's neutral level-1 symptom statement
    until the next edit. The same sentence is never shown in both places.
    Neutral statements are **fixed per cause, owned by the grader, and never
    authored per puzzle** (decision 2026-10-14); every trap tag shares one:

    | Cause | Neutral statement (note) |
    |---|---|
    | `columns` | "The columns don't match what was asked." |
    | `order` | "The right rows, but not in the order asked." |
    | `nondeterministic` | "The result isn't the same every time it runs." |
    | any trap tag | "Some rows are wrong on at least one day's data." |
    | `generic` | "The result doesn't hold on every day's data — check what each column holds, and their order." |

    Puzzle-specific detail lives only in the voiced line. Statements never say
    "other shelves" or "other days" alone: a FAIL can come from the visible
    dataset too (rule 9; trap tags sit on visible rows). The column-content
    and column-order advice for `generic` appears **only** on this note,
    never in the voiced `fail.generic` line (Request & Reaction Dialogue
    rule 2, built-in `fail` lines).
13. Each FAIL increments the counter for its cause in the counter set the
    caller supplied (rule 5) — the puzzle's set for a main puzzle, the
    per-challenge set in challenge mode. The
    feedback level for a fail is computed from that count (Formulas). **At MVP
    the maximum level is 1**; levels 2–3 ship with the Vertical Slice (scope-check
    2026-10-14).
14. A **PASS** returns the pass event; the requester's reaction and any rewards
    are owned by Request & Reaction Dialogue and Shift & Chapter Progression.

**Run (not Submit)**

15. **Run** is not grading. When the player presses Run, the workbench shows the
    player's result on the visible dataset next to the target. The grader
    provides one bit for that view — whether the result matches the target on
    the visible dataset — which the workbench presents as "matches on today's
    data", **never as a pass**. Hidden datasets are never touched by Run.

**What the grader does not judge**

16. Column names and aliases are ignored; column **order** is significant.
17. Query style, length and clause choice do not affect the verdict. Efficiency
    and constraint rules are separate systems that run after a PASS.

### States and Transitions

Per puzzle, for the current play session:

| State | Meaning | Transition | To |
|---|---|---|---|
| `UNSOLVED` | Not yet submitted | Submit, sandbox rejects | `SUBMIT_ERROR` |
| `UNSOLVED` | | Submit, any dataset mismatch | `FAILED(cause, level)` |
| `UNSOLVED` | | Submit, all datasets match | `PASSED` |
| `SUBMIT_ERROR` | Last submit could not run | Submit (same outcomes as `UNSOLVED`) | `SUBMIT_ERROR` / `FAILED` / `PASSED` |
| `FAILED(cause, level)` | Last submit failed; counter for `cause` in the caller-supplied set (rule 5) incremented | Submit (same outcomes as `UNSOLVED`) | `SUBMIT_ERROR` / `FAILED` / `PASSED` |
| `PASSED` | Puzzle cleared | Further submits are graded but cannot un-clear the puzzle | `PASSED` |
| any | | Submit, a dataset reports `CONTENT_ERROR` (verdict UNAVAILABLE, rule 9a) | unchanged; no counter change |

`GRADING` is transient (the submit is in progress); Run never changes state.
The puzzle's failure counters reset only when the puzzle is restarted from the
chapter list (Progression rule 12a); the per-challenge set's lifetime is owned
by Constraint Challenges.

### Interactions with Other Systems

| System | Direction | Data | Owner of the interface |
|---|---|---|---|
| SQL Execution Sandbox | Grader → Sandbox → Grader | In: SQL text, dataset id, mode (`query`). Out (`sql-execution-sandbox.md` rule 16): `status`, `error_kind` (incl. `TIMEOUT`, `CONTENT_ERROR`), `error_text`, `build_message` (CONTENT_ERROR only, log-bound), **`column_count` (also for zero rows)**, `columns`, rows as positional value lists, `truncated` | Grader states the contract; Sandbox GDD implements it |
| Puzzle Definition & Datasets | Puzzle → Grader | Reference SQL, key column (key position = the reference output column of that name), ordered flag, datasets (visible + ≥2 hidden, ≥1 hardcode-proof), row trap tags per dataset (visible included), trap priority list, per-trap feedback texts (levels 1–3), puzzle kind (query / modify) | Grader states required fields; Puzzle Definition GDD implements them |
| Query Workbench | Workbench → Grader | Submit (SQL text); Run match bit (visible only) | Workbench |
| Hint System | Grader → Hints | The verdict only, carrying the submitted query text (hint rule 4a counts a FAIL only if its normalized text differs from the previous counted FAIL) — not cause, level or counters; Hints returns `hint_counted` for the `submit` log event | Grader |
| Request & Reaction Dialogue | Grader → Dialogue | Verdict + feedback key (cause, level), or `{error_kind, error_text}` (a sandbox kind or `TOO_MANY_ROWS`); UNAVAILABLE carries no `error_text`; **never row data** | Grader |
| Shift & Chapter Progression | Grader → Progression | PASS event (puzzle id) | Grader |
| Constraint Challenges | Constraints → Grader | Calls grade first, supplying the per-challenge counter set (rule 5); applies its rule only on PASS | Constraint Challenges |
| Playtest Log | Grader → Log | The grader emits the `submit` event for every submit: verdict (incl. UNAVAILABLE, with optional `build_message`), cause, level, per-dataset pass/fail, missing/extra row counts (log only), and `hint_counted: bool` (value supplied by the Hint System's counting rule, hint rule 4a) | Grader |
| Efficiency Stats (VS) | Grader → Stats | PASS event with the passing SQL | Grader |
| Modify Puzzle Grading (Alpha) | extends Grader | Replaces the result comparison with final-database-state comparison for modify puzzles | Modify Puzzle Grading |
| Audio (VS) | Grader → Audio | Verdict event | Grader |

## Formulas

*Proposed by `systems-designer` (2026-10-14).*

The **value_equal** formula is defined as:

`value_equal(a, b) = (canon(a) == canon(b))`

where `canon(NULL) = ("N")`; `canon(x: INTEGER) = ("n", x)`;
`canon(x: REAL) = ("n", r)` with `r = round_half_even(x, D_real)`, then
`r = int(r)` if `r` is integral and `|r| < 2^53`, `-0.0 → 0`, `±Inf → ("n", "±inf")`;
`canon(s: TEXT) = ("t", utf8_bytes(s))`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| a, b | NULL / INTEGER / REAL / TEXT | any SQLite value | calculated | One cell from the player's result and the reference result at the same position |
| D_real | int | 6 | constant | Decimal places kept for REAL values |
| 2^53 | int | fixed | constant | Largest magnitude at which an integral REAL is converted to INTEGER |

**Output Range:** boolean. NULL equals only NULL (never 0 or `''`); `1` equals
`1.0`; a number never equals text (`1 ≠ '1'`); TEXT is byte-exact — no case
folding, no trimming — because case and trailing-space traps are part of the
trap philosophy. A canonical form (not a pairwise epsilon) keeps equality
transitive and hashable for multisets. Integer division follows SQLite, so
`price/2 ≠ price/2.0` for odd prices; the request text decides which is wanted.
Differences below 5e-7 are invisible — far below any yen or ratio in the data.
**Example:** `(165-80)/2 = 42` vs `(165-80)/2.0 = 42.5` → not equal.
`78/198.0 = 0.393939…` canonicalises to `0.393939`, equal to the player's
`ROUND(78/198.0, 6)`. `canon(198) = canon(198.0)`.

The **result_match** formula is defined as:

`result_match(P, R) = (cols(P) == cols(R)) ∧ (ordered ? tie_list_eq(P, R) : ms(P) == ms(R))`

where `ms(X)` is the multiset of rows, each row a tuple of `canon(cell)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cols(X) | int | 1–N | calculated | Column count reported by the sandbox, **including for zero-row results** |
| ordered | bool | true / false | data file | Puzzle flag; true only when the reference has a top-level `ORDER BY` (the loader warns if flag and SQL disagree) |
| order_cols | int[] | indices < cols(R) | data file | Result columns that form the reference's sort key; required when `ordered` |
| tie_list_eq | bool | true / false | calculated | The sequence of sort keys in P equals that in R, and each run of equal keys has an equal multiset of rows |

**Output Range:** boolean. Zero-row results match only if both are empty and
column counts agree. Duplicates count. Column names are ignored; column order
is significant. Ties in an ordered puzzle never penalise a different
tie-break order. Chapter 1 has no ordered puzzles.
**Example:** 1-5 on hidden A: R = {(Mineral Water 500ml, 110), (Green Tea 500ml,
160), (Canned Coffee, 140), (Lemon Soda, 200)}; a player's `price < 200` returns
the first three → multisets differ → `false`. S-1 with `SELECT category` (no
`DISTINCT`): 24 rows vs 7 → `false`.

The **submit_verdict** formula is defined as:

`V = UNAVAILABLE if c; else SUBMIT_ERROR if e; else FAIL(nondeterministic) if ¬det; else PASS if ⋀(i ∈ D) m_i; else FAIL(cause)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | bool | true / false | calculated | A dataset (visible or hidden) reported `CONTENT_ERROR` during this submit (rule 9a) |
| e | bool | true / false | calculated | Any run of the player's query on visible (pre-check, determinism run, visible grading run — rules 6, 7a) failed: sandbox error, timeout, more than one statement, not read-only, or rows over `R_cap` (kind `TOO_MANY_ROWS`) |
| det | bool | true / false | calculated | `result_match(P_run1, P_run2)` on visible, under the puzzle's `ordered` flag |
| D | list | 3–6 datasets | data file | Visible plus ≥ 2 hidden (≥ 1 hardcode-proof) |
| m_i | bool | true / false | calculated | `result_match` on dataset i; an error, timeout or `truncated` result of the player's query on a hidden dataset gives `m_i = false` (cause `generic`) |
| cause | enum | see Core Rules 10 | calculated | First applicable of `columns`, `order`, trap tag, `generic` |

**Output Range:** {SUBMIT_ERROR, PASS, FAIL(cause), UNAVAILABLE}. Only FAIL
increments a per-cause counter; UNAVAILABLE changes no state.
**Example:** 1-5, `price < 200`: visible `true`, hidden A `false` (Lemon Soda
¥200 missing), hidden B `false` (Lemon Soda and Cola, set to ¥200, missing) →
`FAIL(boundary_200)`.

The **feedback_level** formula is defined as:

`feedback_level(n) = min(L_max, 1 + floor((max(n, 1) − 1) / max(k, 1)))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n | int | 1–∞ | calculated | Failed submits on this puzzle with this cause, including the current one |
| k | int | 1–4 (default 2) | data file | Fails per feedback level |
| L_max | int | 1–3 | config (registry `feedback_max_level`) | Highest level shipped: 1 at MVP, 3 at Vertical Slice |

**Output Range:** 1 to `L_max`. At `L_max = 3, k = 2`: level 1 for fails 1–2,
level 2 for 3–4, level 3 from 5. At MVP (`L_max = 1`) always 1. `k ≤ 0` is
clamped to 1; non-integer `k` is rejected at config load; above `k = 4`, level 3
needs 9+ fails and is effectively unreachable.
**Example:** third `boundary_200` fail on 1-5 with `k = 2, L_max = 3`:
`1 + floor(2 / 2) = 2`. At MVP: `min(1, 2) = 1`.

The **rows_ok** formula is defined as:

`rows_ok(X) = (|rows(X)| ≤ R_cap)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| R_cap | int | 1,000–50,000 (default 5,000) | data file (registry `grader_row_cap`) | Maximum rows the grader compares |

**Output Range:** boolean. A player result over the cap on any visible
run — the pre-check, the determinism run or the visible grading run (rule 7a) — sets `e` (SUBMIT_ERROR kind `TOO_MANY_ROWS`, not counted); it stops
runaway cross joins from stalling grading. Over the cap on a hidden dataset
only: `m_i = false`, cause `generic`, counted (rule 9). A reference over the
cap fails puzzle validation at load.
**Example:** `SELECT * FROM products a, products b` on visible returns
24 × 24 = 576 rows ≤ 5,000 → graded, fails as `generic`.

## Edge Cases

*Drafted without `systems-designer` — Lean mode (Section E is not a high-risk
section). Several entries come from the systems-designer's Formulas input and
the 2026-10-14 design review.*

**Player input**
- **If the submitted text is empty or only whitespace/comments**: SUBMIT_ERROR
  (`EMPTY`; the line is Dialogue template `error.EMPTY`), not counted.
- **If the text holds more than one statement** (`SELECT …; DROP …`):
  SUBMIT_ERROR from the sandbox, not counted; nothing executes.
- **If a query puzzle receives a non-read-only statement** (`UPDATE`, `DELETE`,
  `INSERT`, `DROP`, `ATTACH`, any `PRAGMA`): SUBMIT_ERROR, not counted;
  no dataset is modified.
- **If the player's query runs past the sandbox time limit**: SUBMIT_ERROR on the
  visible pre-check (not counted); on a hidden dataset only, grading stops at once
  (remaining datasets are not run) with FAIL `generic` (counted) — the query does
  not hold on that data.
- **If the pre-check succeeds but the determinism run or the visible grading
  run errors, times out or is `truncated`** (e.g. a query close to
  `exec_time_limit`): SUBMIT_ERROR with that run's kind, not counted (rule 7a).
- **If the player's query errors only on a hidden dataset** (e.g. a cast that
  fails on a hidden value): `m_i = false`, cause `generic`, counted. The error
  text is **not** shown (it could describe hidden data).
- **If the result exceeds `R_cap` rows**: on any visible run (the pre-check, or
  the determinism or visible grading run, rule 7a), SUBMIT_ERROR
  `TOO_MANY_ROWS`, not counted; on a hidden dataset only (sandbox `truncated`),
  `m_i = false`, cause `generic`, counted as a FAIL, with no detail shown.
- **If the query uses `RANDOM()` or another non-deterministic construct and the
  two visible runs differ**: FAIL `nondeterministic`, counted. If the runs happen
  to agree on visible but differ on hidden data, the multiset comparison decides;
  an unordered puzzle accepts `ORDER BY RANDOM()` because row order is ignored.

**Result shape**
- **If both results have zero rows and equal column counts**: match.
- **If the player returns zero rows with a different column count from a
  zero-row reference**: no match, cause `columns`.
- **If the player selects duplicate column names** (`SELECT name, name`): they
  count as two columns; the sandbox must not collapse them (contract in
  Dependencies).
- **If the player returns the right values in a different column order**: no
  match (column order is significant, rule 16). The column count is equal, so the
  cause is not `columns`; it falls to trap tags or `generic`. The grader's
  neutral `generic` statement on the note therefore includes "check what each
  column holds, and their order" (rule 12 table); Dialogue's voiced
  `fail.generic` line does not repeat it.
- **If the player's column count is right but the result is identical to the
  reference on visible and wrong on hidden data with no tagged rows involved**:
  cause `generic`.

**Cause selection**
- **If the failing rows carry tags of several traps** (e.g. 1-11 with both the
  missing-parentheses and the stock-rule mistake): the cause is the tag that
  comes first in the puzzle's trap priority list; only that trap's counter
  increases. Fixing it surfaces the next one on the following submit.
- **If a tagged trap row appears in the diff on one dataset and the other
  datasets fail on untagged rows**: `generic` — the difference is not fully
  explained by tags (rule 10.4), so the player made a mistake no trap names.
  E.g. 1-5 with `category = 'Snacks'`: Lemon Soda (tagged) is missing, but so
  are untagged drinks and untagged snacks are extra → `generic`, never "a
  customer at exactly ¥200 got turned away".
- **If a key appears among both the missing and the extra rows of a dataset**
  (the row is there but a value is wrong, e.g. 1-10 with `SELECT name, shelf`
  instead of `name, category`): `generic`, even when that key is tagged. A
  trap names a row wrongly kept or dropped; a wrong value is a different
  mistake. Puzzle authors use `expected_cause: generic` for such mistakes.
- **If the player's column at the key position does not hold keys** (e.g.
  `SELECT category, price` where the reference is `name, price`): the extra
  rows inherit nothing, so the cause is `generic`.
- **If the cause changes between submits**: each cause has its own counter, so a
  new mistake starts at level 1 even after repeated fails of another cause.

**Puzzle data (validated when the puzzle is loaded; a failing puzzle is
withheld from play and reported in the content verifier)**
- **If a puzzle has fewer than two hidden datasets, or has tagged traps but no
  hardcode-proof hidden dataset** (rule 2): invalid.
- **If a puzzle has tagged traps but its reference result does not have exactly
  one output column named like the key column**: invalid (no key position, so
  rows could not inherit tags).
- **If the sandbox reports `CONTENT_ERROR` for a dataset during a submit** (the
  dataset itself failed to build): verdict UNAVAILABLE (rule 9a) — not a verdict
  on the player. The submit is abandoned with no state or counter change; the
  payload carries no `error_text`; the player hears Kenji's content-error line
  (Dialogue template `error.CONTENT_ERROR`) with no raw or hidden-data text; and
  the event is reported as a content bug (the sandbox's `build_message` goes to
  the Playtest Log only). The content verifier should have caught it first.
- **If the reference query errors, times out, exceeds `R_cap`, or gives different
  results on two runs on any dataset**: invalid.
- **If `ordered` is true but the reference has no top-level `ORDER BY`, or
  `order_cols` is missing / out of range**: invalid. If the reference has a
  top-level `ORDER BY` but `ordered` is false: warning, graded unordered.
- **If a trap tag on a row has no feedback text for level 1**: invalid.
- **If a REAL in a reference result lies within 1e-9 of a 6-decimal rounding
  boundary**: warning (two equal values could canonicalise differently).

**Session**
- **If the player submits again after PASS**: graded normally; the puzzle stays
  cleared whatever the result (constraint challenges rely on this).
- **If the player restarts the puzzle from the chapter list (Progression rule
  12a)**: per-cause counters reset to 0.

## Dependencies

**Upstream — this system cannot function without them (hard):**

| System | GDD | What the grader needs | Status |
|---|---|---|---|
| SQL Execution Sandbox | `design/gdd/sql-execution-sandbox.md` | Run one read-only statement on a named dataset in a fresh database; return ok/error, **column count even for zero rows**, rows as positional value lists (duplicate column names preserved), error text, timed-out flag | In Review — `sql-execution-sandbox.md` rule 16 implements it (`column_count`, `columns`, `truncated`, `CONTENT_ERROR`) |
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Reference SQL; key column; ordered flag; visible + ≥2 hidden datasets with ≥1 hardcode-proof set; trap tags per dataset (`tagged_keys`, visible included); trap priority list; per-trap feedback texts for levels 1–3; puzzle kind | In Review — `puzzle-definition-and-datasets.md` implements it |

**Downstream — systems that depend on this one:**

| System | Nature | What they consume |
|---|---|---|
| Query Workbench | hard | Submit result; Run match bit |
| Hint System | hard | The verdict (and the submitted query text for distinct-query counting) |
| Constraint Challenges | hard | PASS before any constraint is checked; grades against the per-challenge counter set it supplies |
| Shift & Chapter Progression | hard | PASS events |
| Request & Reaction Dialogue | hard | Feedback key (cause, level) or `{error_kind, error_text}` (incl. `TOO_MANY_ROWS`); UNAVAILABLE |
| Playtest Log | hard | `submit` event per submit incl. per-dataset results, `hint_counted`, UNAVAILABLE verdicts (with `build_message`) |
| Efficiency Stats (VS) | soft | PASS event with the SQL |
| Audio (VS) | soft | Verdict events |
| Modify Puzzle Grading (Alpha) | hard | Extends this grader for `UPDATE`/`DELETE` puzzles |

**Bidirectionality:** verified 2026-10-14 (design review) — the Sandbox, Puzzle
Definition, Query Workbench, Hint System, Constraint Challenges, Shift & Chapter
Progression, Request & Reaction Dialogue and Playtest Log GDDs all list
*Hidden-Data Grader* with the interface stated here. Efficiency Stats, Audio and
Modify Puzzle Grading have no GDD yet; each must list it when written.

## Tuning Knobs

All values are data-driven; none is hardcoded in the grader.

| Knob | Default | Safe range | Affects | Source |
|---|---|---|---|---|
| `feedback_fails_per_level` (`k`) | 2 | 1–4 | How fast feedback escalates per cause; above 4, level 3 is effectively unreachable | `feedback_level`; registry |
| `feedback_max_level` (`L_max`) | 1 (MVP) / 3 (VS) | 1–3 | Highest feedback level shown; raising it requires level-2/3 texts in every puzzle | `feedback_level`; registry |
| `grader_row_cap` (`R_cap`) | 5,000 | 1,000–50,000 | Largest result graded; protects grading time from cross joins | `rows_ok`; registry |
| `D_real` | 6 | 4–9 | REAL precision in `canon`; lower hides real differences, higher exposes float noise | `value_equal` |
| Submit / Run budget | 300 / 200 ms p95 | — (fixed targets) | Responsiveness (Game Feel) | Game Feel; AC-26 |

## Visual/Audio Requirements

*Input from `art-director` (2026-10-14) against the Visual Identity Anchor
("Behind the Counter"). Synced to the art bible (`design/art/art-bible.md`)
2026-10-14; the bible is authoritative for visuals where they differ.*

Every outcome is distinguished by **shape, text and position**, never colour
alone. Feedback persists until the player next edits the query.

| Outcome | Visual | Motion (reduced motion: appears in final state, no transition) | Audio intent |
|---|---|---|---|
| **PASS** | A hanko stamp (circle, vermilion `#C23B18`, "OK / 合格" + ✓; may sit at ±3°) lands on the result receipt, plus the printed "✓ ACCEPTED" line in pass green `#245A30`, which carries the meaning. The stamp never sits on a row tint or over a grid (art bible 3.3, 4.4, 4.5). | "✓ ACCEPTED" appears on frame 1; only the stamp sprite animates: scale 1.12 → 1.0 with fade-in (120 ms), then a 2 px settle (60 ms) = 180 ms, no overshoot (art bible 7.6) | One soft, dry stamp "ka-chunk" — closure, no fanfare |
| **FAIL** | A sticky note beside the result carrying the grader's **neutral** level-1 symptom statement (rule 12; the requester's voiced line is in the counter-scene bubble only, never repeated here); a square, axis-aligned note on `sticky` yellow `#F8E38A` with a cut folded corner (no rotation; no text is ever rotated) and a "? Not accepted" tab word in fail red `#A3263A` — text only: **no red X, no red fill**. Nothing is stamped (art bible 3.3, 4.2, 4.5). | **Appears in place, 0 ms** (art bible 7.6) | Gentle low "bip" / paper slip — neutral, not punishing |
| **SUBMIT_ERROR** | A jammed register strip at the **editor** (not the result area) carrying the error label ("ERROR") and SQLite's original `error_text` (or the sandbox's fixed message) in monospace; the voiced error line is in the bubble only; dashed jagged border + ⚠ glyph, ink only (art bible 4.5) | **Appears in place, 0 ms** (art bible 7.6) | Short dull printer-jam tick |
| **Run: matches on today's data** | A small pencil tally note, "≈ Looks right today (not checked)", a **dotted rectangle** with the "≈" glyph in graphite (`ink_muted`) — **never a circle**, because circles are reserved for the hanko seal (art bible 3.3). Smaller and lighter than PASS; **wording never contains "pass", "correct" or "OK"; never a stamp; never green.** | None | Faint scanner beep, clearly quieter than the stamp |

**No shake, flash, particles or confetti on any outcome.**

**Principles applied**: *Store paper as UI* (stamp, sticky note, receipt strip);
*Never colour alone* (glyphs and wording carry every state); *Data reads first*
(feedback sits beside, never over, the result and the editor); *Warm,
quiet, and fast* (text on its first frame; only the stamp moves — art bible 1, 7.6).

**Anti-patterns**: PASS — green flash or confetti that says "done" before the
player has thought; FAIL — red X or a hidden-row diff (turns play into
trial-and-error and breaks Pillar 1); SUBMIT_ERROR — raw stack trace or a modal
that hides the editor; Run — any tick or stamp-like mark that reads as a pass.

> 📌 **Asset Spec** — Visual/Audio requirements are defined. After the art bible
> is approved, run `/asset-spec system:hidden-data-grader` to produce per-asset
> visual descriptions, dimensions, and generation prompts from this section.

## Game Feel

Pillar 3 (*Fast Hands, Cheap Mistakes*) sets the feel: submitting should feel
like handing a slip across the counter, not sitting an exam.

- **Responsiveness**: the full submit (pre-check, determinism check, every
  dataset) returns its verdict within **300 ms at p95** on Chapter 1-sized
  data on target PC hardware; Run's match bit within **200 ms at p95**. No
  loading spinner below these bounds.
- **No suspense theatre**: hidden datasets are not "run one by one" on screen.
  The verdict arrives as a single beat (the stamp or the sticky note).
- **Cheap failure**: a FAIL costs nothing but a line of feedback; there is no
  lockout, cooldown or score penalty. A SUBMIT_ERROR does not even count as a
  failed attempt (Core Rules 6).
- **Weight on success**: the PASS stamp is the one moment with physical weight
  (motion + sound, see Visual/Audio). Run never borrows it.
- **Readability over flourish**: feedback lands beside the result and stays
  until the next edit, so the player can reread it while fixing the query.

## UI Requirements

The grader owns no screen of its own; it supplies outcomes that the Query
Workbench renders. The workbench must:

1. Offer **Submit** as a distinct, labelled action from **Run**, with its own
   shortcut; Submit is never triggered by Run.
2. Show the four outcomes exactly as in Visual/Audio — PASS stamp, FAIL sticky
   note, SUBMIT_ERROR strip at the editor, Run tally note — each with a text
   label and glyph, not colour alone.
3. Show **no hidden-dataset information**: no hidden rows, no per-dataset
   pass/fail, no row counts from hidden data. ("Doesn't hold on other days'
   data" is the most the player learns.)
4. Show the error label and the sandbox's `error_text` (SQLite's original
   message, or the fixed message) on the SUBMIT_ERROR strip (Pillar 4); the
   voiced line stays in the bubble.
5. Keep feedback visible until the query text changes.
6. On **UNAVAILABLE**, return to editing and show "Content error — reported" on
   the strip with no raw text; the voiced line is Dialogue's
   `error.CONTENT_ERROR`.

> **📌 UX Flag — Hidden-Data Grader**: This system has UI requirements. In
> Pre-Production, run `/ux-design` to create a UX spec for the Query Workbench
> screen (which renders these outcomes) **before** writing epics. Stories that
> reference this UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/game-concept.md` | Pillars 1–4, Core Mechanics #2, MVP Definition | Hidden-data grading, "no hidden rows" rule, escalating feedback, MVP level-1 scope | Source of truth for intent |
| `design/gdd/sql-execution-sandbox.md` | Dependencies, Core Rules 6–8 | Sandbox contract (one read-only statement, fresh DB, column count for zero rows, no collapsed duplicate names, timeout, error text) | In Review |
| `design/gdd/puzzle-definition-and-datasets.md` | Core Rules 1–4, 10, 12; Formulas (`ordered`, `order_cols`, `k`, `R_cap`) | Required puzzle fields; `hardcode_proof` | In Review |
| `design/levels/chapter-1-puzzles.md` | Formulas examples | Puzzle 1-5 and S-1 data | Requests 1-4/1-5/1-7/1-8 to be rewritten (trap philosophy) |
| `prototypes/sqlbini-web/ch1.py` | Formulas examples | Datasets used to verify worked examples | Prototype — reference only |
| `prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md` | Dependencies | Zero-row column count and duplicate-name limitations of godot-sqlite | Drives the sandbox contract |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Fixtures use the Chapter 1 datasets from
`prototypes/sqlbini-web/ch1.py`; the pass/fail outcomes of AC-06, -07, -09,
-10 and -14 and the row counts in AC-04 were re-checked against that file.
Trap tags and key columns are not authored yet, so tests add them (provisional,
Open Question 8): key column `name`; 1-5 Lemon Soda (hidden A/B) and Cola
(hidden B) → `boundary_200`; 1-10 NULL-expiry rows on every dataset (visible included) → `null_compare`;
1-11 Fried Rice Bento → `parens` and `stock_rule`, Strawberry Yogurt and Salmon
Onigiri → `stock_rule`.
Logic tests use a stub sandbox where noted. Config: `R_cap = 5000`, `k = 2`,
`L_max = 1` unless stated.*

**Datasets and validation**
- **AC-01 [Logic]** GIVEN puzzle 1-5 with only `visible` + `hidden_a`, WHEN it loads, THEN it is marked invalid and withheld from play; with `hidden_b` added, it loads.
- **AC-02 [Logic]** GIVEN puzzle data where (a) the reference returns more than 5,000 rows, (b) a stub returns two different results for the reference, (c) a trap tag has no level-1 text, or (d) no hidden dataset is hardcode-proof (1-5 with Lemon Soda removed from A and B and Cola left at ¥216 in B), or (e) the reference has no output column named `name`, WHEN it loads, THEN each is invalid.

**Pre-check**
- **AC-03 [Logic]** GIVEN 1-5, WHEN the player submits (a) empty text, (b) `SELEC name FROM products`, (c) `SELECT name FROM products; DROP TABLE products`, or (d) `UPDATE products SET price = 0`, THEN the verdict is SUBMIT_ERROR carrying the sandbox's `error_kind`/`error_text`, every per-cause counter stays 0, and `products` still has 24 rows on `visible`.
- **AC-04 [Logic]** GIVEN 1-5, WHEN the player submits `SELECT * FROM products a, products b, products c` (13,824 rows on visible), THEN the verdict is SUBMIT_ERROR `TOO_MANY_ROWS` and nothing is counted; GIVEN a stub whose result is `truncated` on `hidden_b` only, THEN the verdict is FAIL(`generic`) and it is counted; WHEN they submit `SELECT * FROM products a, products b` (576 rows), THEN it is graded and the verdict is FAIL(`generic`).

**Determinism**
- **AC-05 [Logic]** GIVEN a stub whose two visible runs return different rows, WHEN submitted, THEN the verdict is FAIL(`nondeterministic`) and that counter is 1. GIVEN 1-5 and the reference with `ORDER BY RANDOM()` appended, WHEN submitted, THEN PASS.

**Grading and verdict**
- **AC-06 [Logic]** GIVEN 1-5 and `… AND price < 200`, WHEN submitted, THEN all three datasets are evaluated with results visible = match, hidden A = mismatch, hidden B = mismatch, and the verdict is FAIL(`boundary_200`).
- **AC-07 [Logic]** GIVEN 1-5, WHEN the player submits `… WHERE category IN ('Drinks') AND NOT price > 200`, THEN PASS (a different query with the same result passes).
- **AC-08 [Logic]** GIVEN a stub that errors only on `hidden_b`, WHEN submitted, THEN `hidden_b` counts as a mismatch, the verdict is FAIL(`generic`) and it is counted.

**Result shape and columns**
- **AC-09 [Logic]** GIVEN S-1, WHEN the player submits `SELECT category FROM products` (24 rows vs 7), THEN FAIL.
- **AC-10 [Logic]** GIVEN 1-2, WHEN the player submits `SELECT name AS n, price AS p …` THEN PASS; `SELECT price, name …` THEN FAIL with a cause other than `columns`; `SELECT name, name, price …` THEN FAIL(`columns`) with the sandbox reporting 3 columns.
- **AC-11 [Logic]** GIVEN S-2, WHEN the player submits `SELECT name, price, cost …`, THEN FAIL(`columns`).
- **AC-12 [Logic]** GIVEN a reference and a player query that both return 0 rows, WHEN both have 2 columns THEN they match; WHEN 2 vs 3 columns THEN FAIL(`columns`).

**value_equal**
- **AC-13 [Logic]** GIVEN `canon`, THEN: `198 = 198.0`; `78/198.0 = ROUND(78/198.0, 6)`; `42 ≠ 42.5`; `1 ≠ '1'`; `NULL ≠ 0`; `NULL ≠ ''`; `NULL = NULL`; `'Cola' ≠ 'cola'`; `'Cola' ≠ 'Cola '`; `-0.0 = 0`.

**Cause selection**
- **AC-14 [Logic]** GIVEN 1-10, WHEN the player submits `… WHERE expiry_date = NULL`, THEN FAIL(`null_compare`).
- **AC-15 [Logic]** GIVEN 1-11 and a player query whose differing rows carry both `parens` and `stock_rule`, WHEN the priority list is `[parens, stock_rule]` THEN FAIL(`parens`) and only that counter increases; WHEN the list is reversed THEN FAIL(`stock_rule`).
- **AC-16 [Logic]** GIVEN a synthetic ordered puzzle, WHEN the player returns the same rows in a different order THEN FAIL(`order`); WHEN only rows with equal sort keys are swapped THEN PASS.
- **AC-17 [Logic]** GIVEN 1-5, WHEN the player submits (a) `SELECT category, price FROM products WHERE category = 'Drinks' AND price < 200` (no keys at the key position), or (b) `SELECT name, price FROM products WHERE category = 'Snacks'` (tagged Lemon Soda missing, untagged rows also differ), THEN each verdict is FAIL(`generic`), not FAIL(`boundary_200`).
- **AC-27 [Logic]** GIVEN 1-10, WHEN the player submits `SELECT name, shelf FROM products WHERE expiry_date IS NULL` (every key is both missing and extra), THEN FAIL(`generic`); WHEN they submit `… WHERE expiry_date = NULL`, THEN FAIL(`null_compare`) (AC-14).

**No hidden-row leakage**
- **AC-18 [Integration]** GIVEN AC-06, WHEN the verdict reaches Request & Reaction Dialogue, THEN the payload keys are exactly `{verdict, cause, level}` — no rows, names, counts or per-dataset flags.
- **AC-19 [Integration]** GIVEN AC-06, WHEN the Playtest Log records it, THEN the entry holds per-dataset results `[match, mismatch, mismatch]`, missing/extra counts, and `hint_counted` equal to the value the Hint System's rule 4a returned for that submit (true for a first FAIL; false when the same query is resubmitted, and for every SUBMIT_ERROR and UNAVAILABLE).
- **AC-29 [Logic]** GIVEN 1-5 and a stub whose visible pre-check succeeds but whose determinism run (and, separately, the visible grading run) returns `TIMEOUT`, WHEN submitted, THEN the verdict is SUBMIT_ERROR `TIMEOUT`, every per-cause counter stays 0, and no hidden dataset is run; the same with a `truncated` determinism run gives SUBMIT_ERROR `TOO_MANY_ROWS`.
- **AC-20 [UI]** GIVEN AC-06 and AC-08, WHEN the outcome is rendered, THEN a retained screenshot in `production/qa/evidence/` shows only the neutral symptom statement on the note (and the voiced line in the bubble, not repeated on the note) — no hidden row, count, per-dataset result or hidden-data error text. GIVEN AC-28, THEN the screenshot shows "Content error — reported" with no raw or build text.
- **AC-28 [Logic]** GIVEN a stub that reports `CONTENT_ERROR` on `hidden_b` (and, separately, on `visible`), WHEN the player submits, THEN the verdict is UNAVAILABLE, the payload is exactly `{verdict: UNAVAILABLE}` (no `error_text`), puzzle state and every per-cause counter are unchanged, and a content-bug report is logged.

**feedback_level and counters**
- **AC-21 [Logic]** GIVEN `k = 2, L_max = 3`, THEN levels for n = 1…5 are 1, 1, 2, 2, 3; `k = 0` behaves as 1; `k = 1.5` is rejected at config load; with `L_max = 1`, n = 1, 5 and 100 all give level 1.
- **AC-22 [Logic]** GIVEN two `boundary_200` fails, WHEN a `generic` fail follows, THEN `generic` is level 1 with count 1; WHEN the puzzle is restarted from the chapter list (Progression rule 12a), THEN every counter is 0.

**State**
- **AC-23 [Logic]** GIVEN 1-5 in `PASSED`, WHEN the player submits `… price < 200`, THEN the verdict is FAIL and the puzzle stays `PASSED`.

**Run**
- **AC-24 [Integration]** GIVEN 1-5 and `… price < 200`, WHEN the player presses Run, THEN the match bit is true, the sandbox is called only with `visible`, state and counters are unchanged, and the label contains none of "pass", "correct" or "OK".
- **AC-25 [UI]** GIVEN each outcome, THEN one retained screenshot each shows the PASS stamp, the FAIL note, the SUBMIT_ERROR strip at the editor with the error label and `error_text`, and the Run tally note — each with a text label and a glyph — and feedback stays until the query is edited.

**Performance**
- **AC-26 [Performance]** GIVEN 1-11 on the target PC (Open Question 7), WHEN 100 submits are timed, THEN p95 ≤ 300 ms; WHEN 100 Runs are timed, THEN p95 ≤ 200 ms.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Zero-row column count and duplicate names~~ — answered by `sql-execution-sandbox.md` rules 10–11 (temp view + `PRAGMA table_info`, spike-probed). | — | Resolved 2026-10-14 |
| 2 | Time-limit enforcement: godot-sqlite v4.9 has no interrupt API (`sql-execution-sandbox.md` rule 15); the mechanism is an open ADR. | technical-director → ADR | Before sandbox implementation |
| 3 | Does the Chapter 1 trap rewrite (natural-language requests) actually make players fail on first submit? Thresholds are in `game-concept.md` → MVP Definition. | Developer (playtest) | Zero-SQL + some-SQL playtest, before Chapter 1 content locks |
| 4 | Is level-1 feedback alone enough for zero-SQL players at MVP, given levels 2–3 are deferred? | Developer (playtest) | Same playtest; fallback: pull level 2 into MVP |
| 5 | Should feedback text ever name the dataset as "another day"? (Currently: no per-dataset information at all.) | game-designer | Puzzle Definition GDD |
| 6 | Default `k` (fails per level) = 2 is a guess; tune from playtest logs once levels 2–3 exist. | systems-designer | Vertical Slice |
| 7 | Which machine is the "target PC" for the 300 ms / 200 ms p95 budgets? Until named, AC-26 cannot be checked. | technical-director | Technical Setup (performance ADR) |
| 8 | Trap tags, key columns and priority lists for Chapter 1 are not yet authored (the AC fixtures are provisional). Wording for hidden-only runtime errors is not authored. | Puzzle Definition GDD / level design | Before Chapter 1 content locks |
| 9 | (art bible 2026-10-14) `canon` does not trim (Formulas: trailing-space traps are intended). Should the result grids then show a visible-space marker for leading / trailing spaces (art bible 7.3; the glyph would be added to bible 3.3)? Not decided here. | Grader owner + art-director (`/ux-design` G-08) | `/ux-design` |
