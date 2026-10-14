<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Can Godot 4.7.2 + CodeEdit + godot-sqlite run and grade SQLbini Chapter 1 puzzles? -->
<!-- Date: 2026-10-14 -->

# Spike Note: Query Workbench on Godot 4.7.2

## Question tested
Can we run SQLbini's Chapter 1 puzzles in **Godot 4.7.2** using **`CodeEdit` +
godot-sqlite**, with hidden-data grading that matches `prototypes/sqlbini-web/ch1.py`
verdict-for-verdict?

## Result: YES

| Check | Outcome | Evidence |
|---|---|---|
| godot-sqlite loads on 4.7.2 | **YES** — v4.9 (2026-08-09, "Update to Godot 4.7.1"), `compatibility_minimum = "4.7"`, Linux x86_64 binary loads | `godot --headless --path . -s res://verify.gd` runs queries |
| Grader parity with `ch1.py` | **28 / 28 match** (13 answers + 15 traps × 3 datasets) | `verify.gd` output: `checked 28 · mismatches 0` |
| Parity test can fail | **YES** — flipping one expected verdict gives `mismatches 1`, exit 1 | mutation run, then restored |
| CodeEdit as SQL editor | **YES** — `CodeHighlighter` colors keywords / strings / numbers; line numbers; Ctrl+Enter run, Ctrl+Shift+Enter submit | `shot-1-6-trap.png`, `shot-1-6-pass.png` |
| Hidden-data feedback | **YES** — 1-6 AND/OR trap passes visible, fails hidden A/B, reports `extra ["Corn Puff Stick",40]` | `shot-1-6-trap.png` |
| Nested project isolation | Root project prints "Detected another project.godot … will be ignored" | root `--import` output |

## Limitations found (inputs for the grader / workbench GDDs)
- **Column count is unknown for zero-row results.** godot-sqlite returns rows as
  Dictionaries, so an empty result has no columns. `ch1.py` uses
  `cursor.description` and would fail "0 rows, wrong column count"; this
  grader would pass it. Not hit by any Chapter 1 case, but must be solved
  (e.g. `PRAGMA`/`EXPLAIN`-based column inspection, or a wrapper query).
- **Duplicate column names collapse** (`SELECT name, name` → one key) because
  rows are Dictionaries. Same root cause.
- Editor: long lines are clipped (enable wrapping or a wider editor); no
  autocomplete yet (`CodeEdit` has a code-completion API — not tried).
- Feedback shows only the first failing dataset, and rows as raw JSON — needs
  the character-voiced presentation from the concept.
- Only the Linux binary was copied in; Windows (`.dll`) is in the same v4.9
  release for when Steam builds start.
- Doc discrepancy: `02_chapter1_puzzles.md` says 16 trap answers; `ch1.py` defines **15**.

## What to do next
**Add to the plan.** The Godot + godot-sqlite + CodeEdit stack is viable for
production. Carry the two Dictionary-row limitations into the grader's GDD
(`/design-system`) and an ADR on the SQLite integration
(`/architecture-decision`). This spike does **not** answer whether the game is
fun — that is the web-prototype playtest.

## Addendum 2026-10-14 — sandbox contract probe (`probe_api.gd`, `probe_sandbox.gd`, `probe_sandbox2.gd`)

Run on Godot 4.7.2 + godot-sqlite v4.9 to ground the SQL Execution Sandbox GDD.

| Question | Result |
|---|---|
| API surface | `query`, `query_with_bindings`, `query_result`, `read_only`, `create_function`, import/export, … — **no interrupt / progress-handler / column-metadata method** |
| Column count for a zero-row result | Plain `query` → `[]`, columns lost. **`CREATE TEMP VIEW v AS <sql>` + `PRAGMA temp.table_info(v)` returns every column** (name, declared type) even for 0 rows |
| Duplicate column names | Plain `query` collapses `SELECT name, name, price` to 2 keys. Through the view, SQLite renames to `name`, `name:1`, `price`; `SELECT * FROM v` keeps all 3 |
| Multiple statements | **godot-sqlite executes every statement**: `SELECT 1; DROP TABLE products` dropped the table — also when wrapped in `CREATE VIEW … AS SELECT 1; DROP …`. Must be rejected before execution |
| Non-SELECT in a query puzzle | `CREATE TEMP VIEW v AS UPDATE …` → syntax error (the view wrapper enforces "one SELECT/WITH") |
| Trailing `;`, trailing `-- comment`, `WITH` CTE inside the view | All accepted |
| `PRAGMA query_only = 1` | Blocks `INSERT` **and** `CREATE TEMP VIEW`; set it *after* creating the view, then `SELECT * FROM v` works and writes fail |
| Unbounded recursive CTE + outer `LIMIT 5001` | Returns 5,001 rows in 9 ms (streaming) |
| Unbounded recursive CTE with `ORDER BY` | **Hangs** — killed by a 15 s external timeout. With no interrupt API, a time limit needs another mechanism (ADR) |
| Value types | INTEGER → `int`, REAL → `float`, NULL → `null`, TEXT → `String`; `7/2` → 3 (integer division preserved) |
| Cost of one execution (`probe_cost.gd`: fresh DB, 34 rows inserted in a transaction, temp view, `PRAGMA table_info`, `query_only`, fetch with `LIMIT 5001`; 200 runs of puzzle 1-11's reference) | **p50 0.33 ms, p95 0.37 ms, max 0.82 ms** on an Intel i7-1360P laptop (not the yet-unnamed target PC) |
| `ORDER BY` through the view (`probe_order.gd`: DESC, multi-key, GROUP BY + ORDER BY, ORDER BY + LIMIT on Chapter 1 data) | **Order identical** to the direct query in all 4 cases — observed, not a formal SQLite guarantee |
