# SQL Execution Sandbox

> **Status**: Approved (design review 2026-10-14)
> **Author**: tingoofriend + Claude (design-system, autonomous)
> **Last Updated**: 2026-10-15 (wording: `TOO_MANY_ROWS` on any visible run, from the Dialogue re-review 6c; earlier: 2026-10-14 cross-GDD review fixes)
> **Last Verified**: 2026-10-14
> **Implements Pillar**: Pillar 3 — Fast Hands, Cheap Mistakes; Pillar 4 — Real Store, Real SQL

## Summary

The SQL Execution Sandbox runs every query in the game — Run, Submit, the Back
Room and the content verifier — on a throwaway SQLite database built from a
puzzle's data, and returns every column (even for zero rows), positional rows,
or a clear error. It lets the player type real SQL and get SQLite's real answer
(Pillar 4) while guaranteeing that no typo, `DROP TABLE` or runaway query can
damage data or freeze the game (Pillar 3). Its rules are grounded in probes of
godot-sqlite v4.9 on Godot 4.7.2.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Puzzle Definition & Datasets`

## Overview

The SQL Execution Sandbox runs every piece of SQL in the game — the player's
Run, the Back Room's test rows, the grader's checks on hidden data, and the
content verifier — against a throwaway SQLite database built from a puzzle's
dataset, and returns a result the rest of the game can trust: every column
(even when there are no rows), every row as an ordered list of values, or a
clear error. It is what makes Pillar 4 real — the player types genuine SQLite
SQL and gets SQLite's genuine answer — and what keeps Pillar 3 safe: a mistake,
a typo, a `DROP TABLE` or a runaway query can never damage the store's data,
another puzzle, or the game. Players never see the sandbox; they feel it as
"Run" always answering quickly and nothing ever breaking. Its design is
grounded in a probe of godot-sqlite v4.9 on Godot 4.7.2
(`prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md`, addendum), which found that
the library executes every `;`-separated statement and offers no way to
interrupt a query — both shape the rules below. How the time limit is enforced
→ becomes an ADR.

## Detailed Design

### Core Rules

**Requests**

1. Every call is an **execution request**: SQL text, a dataset (schema +
   resolved rows from Puzzle Definition & Datasets), and a **mode**:
   - `query` — the player's Run and Submit, and reference queries. One
     read-only `SELECT`/`WITH` statement.
   - `scratch` — the Back Room. One `SELECT`, `WITH`, `INSERT`, `UPDATE` or
     `DELETE` statement against that puzzle's scratch database (rule 4).
   - `modify` — Alpha (Modify Puzzle Grading); defined by that GDD.
2. **Isolation.** In `query` mode each request builds a fresh in-memory database
   from the dataset and destroys it afterwards. Nothing persists between
   requests, datasets or puzzles, so no statement can affect another run.
3. Values are returned as SQLite gives them — INTEGER as integer, REAL as float,
   NULL as null, TEXT as string, BLOB as a byte array (`X'00FF'` → `[0, 255]`,
   probed) — with no conversion; comparison is the grader's job (`canon`).
   Integer division stays integer (`7/2 = 3`). No Chapter 1–4 schema has a BLOB
   column; a player-made BLOB value compares unequal to any TEXT or number.
4. **Scratch database.** The Back Room owns one scratch database per open puzzle,
   built by the sandbox from the visible dataset. It persists while the puzzle is
   open, is rebuilt on "reset", and is destroyed when the puzzle closes. It is
   never used for grading.
4a. **No extensions.** The sandbox never calls godot-sqlite's
   `enable_load_extension` or `load_extension`; SQLite's default then refuses
   the SQL function (`SELECT load_extension('x')` → `not authorized`, probed).

**Statement check** (all modes, before anything runs)

5. The SQL text is scanned by a lexer that understands string literals (`'…'`
   with `''` escapes), quoted identifiers (`"…"`, `[…]`, `` `…` ``) and comments
   (`-- …`, `/* … */`). An unterminated `/* …` runs to the end of the text, as
   in SQLite (probed). Trailing whitespace, comments and **one** trailing `;`
   are allowed.
5a. **Lexer contract.** The sandbox owns the lexer and exposes it to other
   systems as `tokenize(sql) -> Array of {kind, text}`, with `kind` one of
   `WORD`, `NUMBER`, `STRING`, `QUOTED_IDENT`, `COMMENT`, `PUNCT`. Keyword
   matching — here (rules 6–9) and in Constraint Challenges' rule checks — uses
   `WORD` tokens only, compared case-insensitively, so a keyword inside a string,
   quoted identifier or comment never matches.
6. If anything other than whitespace or comments follows a `;`, the request is
   rejected as `MULTI_STATEMENT` **without executing anything**. (godot-sqlite
   executes every `;`-separated statement — the probe showed `SELECT 1; DROP
   TABLE products` dropping the table.)
7. Empty text (only whitespace/comments) is rejected as `EMPTY`.
8. The statement's **verb** decides what is allowed. The verb is the first
   keyword, except after `WITH`: then it is the first keyword at parenthesis
   depth 0 after the CTE list (`WITH x AS (SELECT 1) DELETE …` → `DELETE`).
   - `query` mode: verb `SELECT` only; anything else (incl. `VALUES`, `INSERT`,
     `UPDATE`, `DELETE`) → `NOT_A_QUERY`.
   - `scratch` mode: verb `SELECT`, `INSERT`, `UPDATE` or `DELETE`; anything
     else (`CREATE`, `DROP`, `ALTER`, `ATTACH`, `PRAGMA`, …) → `NOT_ALLOWED`.
9. **Unsupported at MVP:** `WITH RECURSIVE` → `UNSUPPORTED`. Chapters 1–4 never
   need it, and an unbounded recursive query can hang the game (rule 15).

**Running a query** (`query` mode; `SELECT` in `scratch` mode works the same)

10. The statement is wrapped as a temporary view: `CREATE TEMP VIEW _q AS <sql>`.
    SQLite rejects any non-query statement here, so the wrapper also enforces
    read-only.
11. The column list is read from the view's metadata (`PRAGMA
    temp.table_info(_q)`): the **column count is known even when the result has
    zero rows**, and duplicate output names are made unique by SQLite
    (`name`, `name:1`) so no column is lost.
12. The database is then switched to read-only (`PRAGMA query_only = 1`) and the
    rows are fetched with `SELECT * FROM temp._q LIMIT fetch_limit`
    (Formulas). Rows are returned as positional lists in column order.
13. If more than `grader_row_cap` rows exist, the result is marked `truncated`;
    the grader treats that as too many rows (its `rows_ok`: `TOO_MANY_ROWS` on
    any visible run — pre-check, determinism or visible grading run, grader
    rules 6 and 7a — a `generic` mismatch on a hidden dataset).
14. Write statements in `scratch` mode run directly (no view), then report the
    number of rows changed (read with `SELECT changes()` — godot-sqlite has no
    changes method; probed). A `RETURNING` clause is ignored: only
    `rows_changed` is reported. A `SELECT` in `scratch` mode uses rules 10–13 and
    afterwards switches `query_only` back off **and then** drops the temporary
    view — in that order, because `DROP VIEW` under `query_only` fails ("attempt
    to write a readonly database", probed) — on every exit path, including a
    fetch error, so the persistent scratch database accepts the next write.

**Time limit**

15. Every execution has a budget of `exec_time_limit` (Formulas). Exceeding it
    returns `TIMEOUT` and the game stays responsive. Two requirements hold
    **whatever enforcement mechanism is chosen**, and from the first
    implementation: (a) execution never runs on the frame thread, so no query
    can freeze rendering or input; (b) the caller receives `TIMEOUT` within
    `exec_time_limit` + 50 ms (SB-18). **godot-sqlite v4.9 has no interrupt
    API**, so *how* (b) is met — and what happens to the still-running work — is
    the enforcement ADR (Open Question 1), a prerequisite for implementing this
    rule. Rules 9 and 12 reduce how often the limit is hit: unbounded recursion
    is rejected, and the outer `LIMIT` stops streaming results early (the probe:
    5,001 rows of an infinite recursion in 9 ms). The residual case is any
    query that must consume a huge intermediate result before its first output
    row — an aggregate, `GROUP BY`, `DISTINCT` or `ORDER BY` over a many-way join.
    It needs no `ORDER BY`: on 24 rows a 5-way self-join `COUNT(*)` took 55 ms
    and each extra join multiplies the cost by ~24 (2026-10-14 review probe).

**Result**

16. Every request returns one result:

| Field | Meaning |
|---|---|
| `status` | `ok` or `error` |
| `error_kind` | `EMPTY`, `MULTI_STATEMENT`, `NOT_A_QUERY`, `NOT_ALLOWED`, `UNSUPPORTED`, `SQL_ERROR`, `TIMEOUT`, `CONTENT_ERROR` (the dataset itself failed to build — a content bug, never the player's fault) — only when `status = error` |
| `error_text` | SQLite's original message for `SQL_ERROR` (e.g. `no such column: prise`); a fixed message otherwise — for `CONTENT_ERROR` always the fixed message "content error", never the build message |
| `build_message` | `CONTENT_ERROR` only: the dataset build's own message. It reaches the Playtest Log only as the optional `build_message` field of the `run` event (`CONTENT_ERROR`) and the `submit` event (UNAVAILABLE); it never reaches the player (it can name hidden keys) |
| `columns` | Output column names in order (SQLite-uniquified) |
| `column_count` | Number of output columns — present even for zero rows |
| `rows` | List of rows; each row a list of values in column order |
| `truncated` | `true` if more than `grader_row_cap` rows exist |
| `rows_changed` | `scratch` writes only |
| `elapsed_ms` | Monotonic wall time from receiving the request to returning the result, including the statement check and database build |

17. The sandbox never judges correctness, never voices errors (Request &
    Reaction Dialogue does), and never decides what counts as a failed attempt
    (the grader does).

### States and Transitions

A `query`-mode request is stateless: `received → checked → built → viewed →
fetched → returned`, and any step can end in `error`; the database is destroyed
in every case.

The scratch database (Back Room) has a lifecycle:

| State | To | When |
|---|---|---|
| `none` | `ready` | Puzzle opened (built from the visible dataset) |
| `ready` | `ready` | Any scratch request (writes change it) |
| `ready` | `ready` | "Reset" — rebuilt from the visible dataset |
| `ready` | `none` | Puzzle closed |

### Interactions with Other Systems

| System | Direction | Data | Owner of the interface |
|---|---|---|---|
| Hidden-Data Grader | Grader → Sandbox → Grader | Request (`query` mode, dataset id) → result (rule 16) | Grader stated the contract; this GDD implements it |
| Puzzle Definition & Datasets | Puzzle → Sandbox | Schema + resolved dataset rows | Puzzle Definition |
| Query Workbench | Workbench → Sandbox → Workbench | Run: `query` mode on visible; result table, errors | Sandbox |
| Back Room | Back Room → Sandbox → Back Room | `scratch` requests; scratch DB lifecycle (create, reset, destroy) | Back Room calls; Sandbox owns the DB |
| Request & Reaction Dialogue | Sandbox → (via Grader/Workbench) → Dialogue | `error_kind` + `error_text` to voice | Dialogue |
| Content verifier | Verifier → Sandbox | Same `query` mode as the game, so CI and the game agree | Puzzle Definition |
| Constraint Challenges | Challenges → Sandbox | `tokenize(sql)` (rule 5a) for `forbid`/`require` keyword checks and the live check | Sandbox |
| Playtest Log | Sandbox → (via Workbench / Grader) → Log | `build_message` on `CONTENT_ERROR`, reaching the log **only** as the optional `build_message` field of the `run` event (Run hit `CONTENT_ERROR`) and of the `submit` event (verdict UNAVAILABLE) | Playtest Log |
| Efficiency Stats (VS) | Sandbox → Stats | `elapsed_ms` (if the efficiency metric uses execution cost) | Efficiency Stats |
| Modify Puzzle Grading (Alpha) | extends | `modify` mode and final-state readout | Modify Puzzle Grading |

## Formulas

*Proposed by `systems-designer` (2026-10-14); the measured cost is from the
spike note addendum.*

The **fetch_limit** formula is defined as:

`fetch_limit = grader_row_cap + 1`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| grader_row_cap | int | 1,000–50,000 (default 5000) | data file (registry `grader_row_cap`; the grader's `R_cap`) | Largest result the grader accepts |
| fetch_limit | int | `grader_row_cap + 1` | calculated | Outer `LIMIT` in rule 12 |

**Output Range:** `grader_row_cap + 1`. Fetching exactly `grader_row_cap` rows
could not tell "exactly the cap" from "more"; the extra row proves overflow. It
is discarded, `rows` is cut to `grader_row_cap` and `truncated = true`. The extra
row is never exposed. No string or check hardcodes the default; player-facing
text is formatted from the value ("{grader_row_cap}+ rows").
**Example (default 5000):** a query yielding 12,000 rows → 5001 fetched, 5000
returned, `truncated = true`; exactly 5,000 rows → 5,000 returned,
`truncated = false`.

The **exec_time_limit** formula is defined as:

`exec_time_limit = clamp(exec_time_limit_ms, 50, 150)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| exec_time_limit_ms | int (ms) | 50–150 (default 100) | data file | Tunable wall-time limit for one execution; ≤ 0 falls back to the default |

**Output Range:** 50–150 ms. The floor (2 × `exec_cost_target_ms`) keeps slow
machines from timing out valid queries; the ceiling leaves ≥ 50 ms of the 200 ms
Run budget for the UI. A Run that ends in `TIMEOUT` is **exempt** from the 200 ms
Run budget (delivery may take up to `exec_time_limit` + 50 ms; the workbench
shows "checking…" meanwhile); the budget applies to Runs that complete. It caps a *single* execution; the submit budget is the sum
over executions (below). **Unenforced until the enforcement ADR lands** (rule 15,
Open Question 1) — whatever the mechanism, execution must not run on the frame
thread, so a hang never freezes the UI.
**Example:** default 100 ms; a query still running at 100 ms returns `TIMEOUT`.

The **executions_per_submit** formula is defined as:

`executions_per_submit = 2 + D` (reference results cached per puzzle and dataset)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| D | int | ≥ 3 | data file | Datasets per puzzle: visible + ≥ 2 hidden (Chapter 1: 3) |
| 2 | int | 2 | constant | Grader pre-check and determinism re-run, both on visible |

**Output Range:** 5 at D = 3; 7 at D = 5. Without the reference cache it would be
`2 + 2D` (8 and 12). References are deterministic and verified at load, so the
grader caches them (key: puzzle id + dataset id, held for the session) —
`hidden-data-grader.md` rule 8.
**Example:** Chapter 1, D = 3 → 2 + 3 = 5 executions.

The **submit_time_budget** formula is defined as:

`submit_time = executions_per_submit × exec_cost + overhead ≤ 300 ms`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| exec_cost | float (ms) | measured | calculated | p95 cost of one execution (build DB, view, `PRAGMA`, fetch) |
| exec_cost_target_ms | int (ms) | 25 (hard ceiling 30) | constant | Target p95 on the target PC |
| overhead | int (ms) | 60 | constant | Reserved for grader comparison, cause selection and UI |

**Output Range:** at the target, 5 × 25 + 60 = 185 ms ≤ 300 ✓; even uncached,
8 × 25 + 60 = 260 ms ✓. **Measured:** p95 0.37 ms per execution on an i7-1360P
laptop → 5 × 0.37 ≈ 2 ms of sandbox time per submit. The target is deliberately
loose for the yet-unnamed target PC and larger later chapters.
**Example:** Chapter 1 on the dev laptop: ≈ 2 ms sandbox + overhead.

**Worst case — a query that times out only on hidden data.** The grader stops at
the first `TIMEOUT` and returns FAIL(`generic`) without running the remaining
datasets (`hidden-data-grader.md` rule 8): pre-check + determinism + visible ≈ 3 × 25
+ 100 = **175 ms** at the targets. Without the early stop, two hidden timeouts
would take ≈ 275 ms — no margin. Without enforcement at all, unbounded.

## Edge Cases

*Drafted without `systems-designer` — Lean mode. Entries marked (probed) were
observed on Godot 4.7.2 + godot-sqlite v4.9.*

**Statement check**
- **If the text is `SELECT name FROM products;` (one trailing `;`)**: allowed; runs normally (probed).
- **If the text is `SELECT 1; DROP TABLE products`**: `MULTI_STATEMENT`; nothing runs (godot-sqlite would otherwise run both — probed).
- **If a `;` appears inside a string literal or comment** (`WHERE name = 'a;b'`, `-- note; more`): not a separator; allowed.
- **If the text ends with a `-- comment` and no newline**: allowed (probed).
- **If a `/* …` comment is never closed** (`SELECT 1 /* ; DROP TABLE products`): the comment runs to the end of the text, as in SQLite (probed); no separator is found and the query runs as `SELECT 1`.
- **If a string literal is unterminated** (`WHERE name = 'Cola`): the lexer cannot find a statement end; the text is passed to SQLite and returns `SQL_ERROR` with SQLite's message (`unrecognized token`), not `MULTI_STATEMENT`.
- **If the first keyword is lower-case or preceded by comments** (`/* x */ select …`): keywords are case-insensitive and leading comments are skipped.
- **If the player writes `VALUES (1), (2)` alone**: `NOT_A_QUERY` in `query` mode (first keyword not `SELECT`/`WITH`). Allowed inside a `WITH` or `INSERT`.
- **If `WITH` is followed by `UPDATE`/`DELETE`** (`WITH x AS (…) DELETE FROM products`) in `query` mode: the verb is `DELETE` (rule 8) → `NOT_A_QUERY`, rejected before execution.
- **If the text contains `RECURSIVE` only inside a string or comment**: not rejected; the lexer ignores literals and comments.

**Results**
- **If the result has zero rows**: `column_count` and `columns` still come from the view metadata (probed).
- **If two output columns share a name** (`SELECT name, name`): returned as `name`, `name:1`; `column_count = 2` (probed).
- **If an output column name itself looks uniquified** (`SELECT name AS "name:1", name`): SQLite's renaming keeps them distinct; values are read by column position, never by name.
- **If the result exceeds `grader_row_cap` rows**: the fetch stops at `fetch_limit`; `truncated = true`; the rows returned are not used for grading.
- **If the query has an `ORDER BY`**: rows are returned in that order through the view — observed in 4 probe cases, not formally guaranteed by SQLite; acceptance criterion SB-08 guards it.
- **If a value is REAL and integral** (`198.0`): returned as float `198.0`; no conversion (the grader's `canon` equates it with 198).
- **If a column has no name** (`SELECT price * 2`): SQLite names it from the expression; the name is display-only.

**Errors and limits**
- **If SQLite reports an error** (`no such column: prise`): `SQL_ERROR` with SQLite's exact text, which Request & Reaction Dialogue can show beneath its voiced line.
- **If execution exceeds `exec_time_limit`**: `TIMEOUT` within the limit + 50 ms; the frame never blocks (rule 15). The residual case is an aggregate, `GROUP BY`, `DISTINCT` or `ORDER BY` over a many-way join (rule 15); how the limit is enforced is Open Question 1.
- **If the dataset fails to build** (a schema/data error): `CONTENT_ERROR` with the fixed `error_text` "content error"; the build message goes only in `build_message` (Playtest Log / content-bug report), never to the player, because it can name hidden keys. The grader returns UNAVAILABLE (`hidden-data-grader.md` rule 9a), not a player failure. The content verifier should have caught it first.

**Scratch database**
- **If the player deletes every row in the Back Room**: allowed; "reset" restores the visible dataset.
- **If the player tries `DROP TABLE products` in the Back Room**: `NOT_ALLOWED`; the scratch DB is unchanged.
- **If the player inserts a row that breaks a constraint** (duplicate `id`, `NULL` name): `SQL_ERROR` with SQLite's message (`UNIQUE constraint failed: products.id`, probed); the scratch DB is unchanged.
- **If the player keeps growing the scratch table** (`INSERT INTO products SELECT * FROM products` repeated): each run is bounded by `exec_time_limit`; a size cap for the scratch DB is for the Back Room GDD (Alpha, Open Question 5).
- **If the puzzle closes**: the scratch DB is destroyed; reopening builds a fresh one.

## Dependencies

**Upstream (hard):**

| System | GDD | What the sandbox needs | Status |
|---|---|---|---|
| Puzzle Definition & Datasets | `design/gdd/puzzle-definition-and-datasets.md` | Schema (typed columns, keys) and resolved dataset rows | In Review |

**Engine / library:** godot-sqlite v4.9 (GDExtension, `compatibility_minimum = "4.7"`).
Behaviour this GDD relies on is recorded in the spike note addendum.

**Downstream:**

| System | Nature | What they consume |
|---|---|---|
| Hidden-Data Grader | hard | `query`-mode results (rule 16) — implements the grader's stated contract |
| Query Workbench | hard | Run results and errors |
| Back Room | hard | `scratch` mode and scratch DB lifecycle |
| Request & Reaction Dialogue | soft | `error_kind`, `error_text` (via Grader / Workbench) |
| Content verifier (Puzzle Definition) | hard | Same `query` mode as the game |
| Constraint Challenges | hard | `tokenize(sql)` lexer contract (rule 5a) |
| Playtest Log | soft | `build_message`, only via the optional field on the `run` event (`CONTENT_ERROR`) and the `submit` event (UNAVAILABLE) |
| Efficiency Stats (VS) | soft | `elapsed_ms` |
| Modify Puzzle Grading (Alpha) | hard | `modify` mode |

**Bidirectionality:** `hidden-data-grader.md`, `puzzle-definition-and-datasets.md`,
`query-workbench.md`, `request-and-reaction-dialogue.md` and
`constraint-challenges.md` list this system ✓.
Back Room, Efficiency Stats and Modify Puzzle Grading have no GDD yet.

## Visual/Audio Requirements

None — the sandbox has no presentation. Errors are voiced by Request & Reaction
Dialogue and shown by the Query Workbench.

## Game Feel

The sandbox is the reason Run feels instant (Pillar 3): one execution costs
about **0.33 ms (p50) / 0.37 ms (p95)** on Chapter 1 data on a development laptop
(spike note addendum), far inside the grader's 200 ms Run and 300 ms Submit
budgets. Nothing the player types may freeze the game: rules 6, 9, 12 and 15 exist
so that a mistake costs a message, never a hang.

## UI Requirements

None. The sandbox supplies `error_kind`, `error_text`, `columns` and `rows`; the
Query Workbench decides how they are shown.

## Cross-References

| This document references | Where | What | Status |
|---|---|---|---|
| `design/gdd/hidden-data-grader.md` | Overview, Core Rules 10–16, Formulas | Contract implemented here (column count for zero rows, no collapsed names, errors, timeout); rule 8 reference caching and stop-on-`TIMEOUT` | In Review |
| `design/gdd/puzzle-definition-and-datasets.md` | Core Rules 1–2, Dependencies | Schema and resolved datasets; content verifier uses `query` mode | In Review |
| `prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md` | Overview, Core Rules 6, 10–12, 15, Game Feel | godot-sqlite v4.9 behaviour probed on Godot 4.7.2 | Evidence |
| `design/registry/entities.yaml` | Formulas | `grader_row_cap` (5000) | Registered |

## Acceptance Criteria

*Drafted with `qa-lead` (2026-10-14). Grading outcomes are covered by
`hidden-data-grader.md` AC-01…26. Fixture: the Chapter 1 `products` table on the
visible dataset unless stated (e.g. Cola 500ml, price 216). SB-02, -03 (`UPDATE`),
-07, -09 and -08's first case were observed in the spike probes.*

**Statement check**
- **SB-01 [Logic]** GIVEN `query` mode, WHEN the text is `SELECT name FROM products;`, `SELECT name FROM products -- note`, or `/* x */ select name FROM products`, THEN `status = ok`; a `;` inside `'a;b'`, `-- n; m`, `"…"`, `[…]` or a backtick identifier is not a separator; GIVEN `SELECT 1 /* ; DROP TABLE products` (unterminated comment) THEN it runs as `SELECT 1` and `products` still has 24 rows.
- **SB-02 [Logic]** GIVEN `SELECT 1; DROP TABLE products`, `SELECT 1;;` or `SELECT 1; SELECT 2`, WHEN checked, THEN `MULTI_STATEMENT` and nothing executes; a following request still counts 24 rows in `products`; `SELECT 1; -- end` is allowed.
- **SB-03 [Logic]** GIVEN `""`, `"   "` or `"-- only"` THEN `EMPTY`; GIVEN `VALUES (1)`, `UPDATE products SET price = 0` or `WITH x AS (SELECT 1) DELETE FROM products` in `query` mode THEN `NOT_A_QUERY` and nothing changes.
- **SB-04 [Logic]** GIVEN `WITH RECURSIVE c(x) AS (…) SELECT x FROM c` in any letter case THEN `UNSUPPORTED` and nothing executes; GIVEN `SELECT 'RECURSIVE'` or a `-- RECURSIVE` comment THEN it runs.
- **SB-05 [Logic]** GIVEN `SELECT name FROM products WHERE name = 'Cola` (unterminated) THEN `SQL_ERROR`, not `MULTI_STATEMENT`.

**Isolation and results**
- **SB-06 [Integration]** GIVEN two consecutive `query` requests where the first is rejected or errors, WHEN the second runs, THEN it sees all 24 rows; each request used a distinct database instance and none remains open afterwards.
- **SB-07 [Logic]** GIVEN `SELECT name, price FROM products WHERE 1 = 0` THEN `rows = []`, `column_count = 2`, `columns = ["name", "price"]`; GIVEN `SELECT name, name FROM products` THEN `columns = ["name", "name:1"]` and each row has 2 values read by position; GIVEN `SELECT name AS "name:1", name FROM products` THEN the two columns stay distinct.
- **SB-08 [Integration]** GIVEN `SELECT name, price FROM products ORDER BY price DESC, name` (and the same with a `WHERE` and with ties) THEN `rows` equal, row for row, a direct non-view SQLite run of the same query. Re-run on every godot-sqlite upgrade.
- **SB-09 [Logic]** GIVEN `SELECT 198 AS i, 198.0 AS r, NULL AS n, '1' AS s, 7/2 AS d, X'00FF' AS b` THEN the types are int, float, null, string, int (`d = 3`) and byte array (`[0, 255]`); GIVEN `SELECT load_extension('x')` THEN `SQL_ERROR` with `not authorized`.
- **SB-10 [Logic]** GIVEN `grader_row_cap = 5000` (default) and a query producing exactly 5,000 rows THEN 5,000 rows and `truncated = false`; GIVEN 5,001 or 12,000 rows THEN `len(rows) = 5000`, `truncated = true`, the 5,001st row is not exposed, and exactly 5,001 rows were requested.
- **SB-11 [Logic]** GIVEN `SELECT prise FROM products` THEN `SQL_ERROR` and `error_text` is exactly SQLite's message `no such column: prise`.
- **SB-12 [Logic]** GIVEN a dataset whose build fails (a type error in a row) THEN `CONTENT_ERROR`, never `SQL_ERROR`; `error_text` is exactly "content error" and the build message appears only in `build_message`.

**Scratch mode**
- **SB-13 [Logic]** GIVEN `scratch` mode THEN `SELECT`, `WITH … SELECT`, `INSERT`, `UPDATE` and `DELETE` succeed; `UPDATE products SET stock = 0` returns `rows_changed = 24`; `DROP TABLE products`, `CREATE …`, `ALTER …`, `ATTACH …` and `PRAGMA …` return `NOT_ALLOWED` with data unchanged; `UPDATE …; DELETE …` returns `MULTI_STATEMENT`.
- **SB-14 [Integration]** GIVEN a scratch `UPDATE`, then a `SELECT`, then another `UPDATE`, THEN the `SELECT` sees the first change and the second `UPDATE` succeeds (no leftover view, `query_only` switched back off); the same holds when the `SELECT` fails during fetch; `UPDATE … RETURNING id` reports `rows_changed` only.
- **SB-15 [Logic]** GIVEN a scratch `INSERT` with a duplicate `id` or a NULL `name` THEN `SQL_ERROR` with SQLite's text, and `COUNT(*)` is unchanged.
- **SB-16 [Integration]** GIVEN `DELETE FROM products` then "reset" THEN the scratch table equals the visible dataset; GIVEN the puzzle is closed and reopened THEN the scratch database is fresh; no scratch change is visible to `query` mode.

**Time limit**
- **SB-17 [Logic]** GIVEN `exec_time_limit_ms` = 0, 10, 100, 999 THEN the effective limit is 100, 50, 100, 150.
- **SB-18 [Integration]** GIVEN a query that runs longer than the limit (an `ORDER BY` over a huge cross join) THEN `TIMEOUT` is returned within limit + 50 ms and the next request succeeds; such a Run is exempt from the 200 ms Run budget (the workbench shows "checking…"), which applies only to Runs that complete. *Checkable once the enforcement ADR lands (Open Question 1).*
- **SB-19 [Integration]** GIVEN the SB-18 query, and separately a 6-way self-join `SELECT COUNT(*) FROM products a, products b, products c, products d, products e, products f`, started from the Workbench THEN the frame time stays ≤ 16.6 ms (60 fps) throughout (execution is not on the frame thread). Checkable from the first implementation — it does not wait for the ADR.

**Performance**
- **SB-20 [Performance]** GIVEN 200 executions of puzzle 1-11's reference on the target PC THEN p95 ≤ 25 ms (hard ceiling 30 ms); dev-laptop baseline p95 ≈ 0.37 ms. Run end-to-end ≤ 200 ms; Submit (5 executions at D = 3) ≤ 300 ms. *Target PC to be named (grader Open Question 7).*
- **SB-21 [Logic]** GIVEN any request THEN `elapsed_ms` is reported and is ≥ the time spent in SQLite for that request.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | **How is `exec_time_limit` enforced** when godot-sqlite has no interrupt API? Options: (a) add `sqlite3_interrupt` / a progress handler to a fork of godot-sqlite (GDExtension work; upstream PR possible); (b) run each execution on a worker thread and abandon it on timeout (the thread keeps burning CPU until it ends); (c) keep MVP mitigations only (reject `RECURSIVE`, outer `LIMIT`) and accept the residual `ORDER BY`-over-huge-join risk. Whatever is chosen, execution must not block the frame thread. | technical-director → ADR (`godot-gdextension-specialist` for (a)) | Technical Setup |
| 2 | Is the hand-written statement lexer (rule 5) enough, or should the sandbox use SQLite's own `sqlite3_complete` / prepare-tail through the extension to split statements exactly as SQLite does? | technical-director → ADR | Technical Setup |
| 3 | Does `SELECT * FROM temp._q` always preserve the view's `ORDER BY`? **Observed yes** in 4 probe cases (DESC, multi-key, GROUP BY, LIMIT — spike note addendum), but SQLite does not formally guarantee it. Keep AC SB-08 as a regression test on every godot-sqlite upgrade; fallback if it ever fails: re-apply the ordered puzzle's `order_cols` in the outer query. | systems-designer | Before the first ordered puzzle (Chapter 2) |
| 4 | Windows build of godot-sqlite v4.9 is untested; all probes ran on Linux. | technical-director | Early Systems Design (gate concern) |
| 5 | Should the Back Room allow `CREATE TEMP TABLE` for advanced players? Currently `NOT_ALLOWED`. | game-designer | Back Room GDD |
