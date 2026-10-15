# ADR-0002: Sandbox API and Lexer Contract

## Status
Proposed

## Date
2026-10-15

## Last Verified
2026-10-15

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
Every system that runs SQL (Workbench, Grader, content verifier, later the Back
Room) and every system that inspects SQL text (Constraint Challenges, Hint
System) needs one stable contract with the SQL Execution Sandbox. The sandbox
exposes an awaitable `execute(SqlRequest) -> SqlResult` built on ADR-0001's
worker runner, and a pure, synchronous `tokenize(sql) -> Array[SqlToken]` from a
hand-written lexer that also performs the statement check.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 + godot-sqlite v4.9 (GDExtension) |
| **Domain** | Core |
| **Knowledge Risk** | LOW — pure GDScript (`RefCounted`, typed arrays, `StringName`, signals, `await`), all pre-4.3. godot-sqlite calls are those probed on 4.7.2 in the 2026-10-14 spike |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md`; `prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md` (API surface, view wrapper, `PRAGMA table_info`, `query_only`, value types); ADR-0001 |
| **Post-Cutoff APIs Used** | None. The 4.7 typed-return rule applies only if a class here overrides an engine virtual (none should) |
| **Verification Required** | SB-07 (zero-row columns, duplicate names — row keys probed 2026-10-15, see §5) and SB-08 (order through the view) re-run on every godot-sqlite upgrade; the version of SQLite bundled in godot-sqlite v4.9 is NOT SOURCEABLE here — do not rely on SQLite features newer than the spike exercised (e.g. `STRICT` tables) without a probe |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (Sandbox execution and timeout — the runner this API delivers through) |
| **Enables** | ADR-0003 (content verifier and reference cache call `execute`); Hint System and Constraint Challenges stories (`tokenize`); Grader submit pipeline |
| **Blocks** | Sandbox epic; Grader epic; Workbench Run story; Hint rule 4a story; Constraint Challenges rule-check story |
| **Ordering Note** | `ResolvedDataset` is produced by PuzzleRepository (ADR-0003); this ADR fixes only the shape the sandbox consumes |

## Context

### Problem Statement
`sql-execution-sandbox.md` rules 1–17 define what the sandbox does; the
architecture (`docs/architecture/architecture.md`, API Boundaries) sketched a
shape. Before the Sandbox, Grader, Workbench, Hint and Constraint Challenges
epics start, the exact public types, the async calling convention and the lexer
contract must be fixed — five systems implement against them. Sandbox Open
Question 2 also asks whether statement splitting should use SQLite's own
`sqlite3_complete` / prepare-tail instead of a hand-written lexer.

### Constraints
- godot-sqlite v4.9 exposes no `sqlite3_complete`, no prepare/step API and no
  column metadata (spike `probe_api.gd`); it returns rows as Dictionaries keyed
  by column name, and executes every `;`-separated statement.
- Execution is off the frame thread and may end in `TIMEOUT` (ADR-0001).
- Hint rule 4a and CC `has_keyword` require whitespace to produce **no** token
  and keywords to be matched on `WORD` tokens only.
- CC's live check tokenizes text while the player is typing — unterminated
  literals and comments are normal input (sandbox review recommendation, 6a).

### Requirements
- Column count and names for zero-row results; duplicate names kept (rules 10–11).
- Positional rows; values exactly as SQLite returns them (rule 3).
- One result per request, delivered on the main thread.
- `tokenize` usable synchronously from UI code at typing speed.

## Decision

### 1. Statement splitting: hand-written lexer (resolves sandbox Open Question 2)
The sandbox owns a GDScript lexer, `SqlLexer`. It is the **only** place SQL text
is scanned; the statement check (rules 5–9) and `tokenize` (rule 5a) share it.
SQLite's `sqlite3_complete` is unavailable without a godot-sqlite fork (the same
fork rejected for MVP in ADR-0001), and the temp-view wrapper (rule 10) already
lets SQLite itself reject anything that is not a single query.

### 2. Lexer contract

```gdscript
class_name SqlToken extends RefCounted
var kind: StringName     # &"WORD" | &"NUMBER" | &"STRING" | &"QUOTED_IDENT" | &"COMMENT" | &"PUNCT"
var text: String         # exact source text of the token, quotes/comment markers included
var start: int           # character offset in the source (for editor underlines/highlights)
var terminated: bool     # false only for an unterminated STRING, QUOTED_IDENT or /* COMMENT
```

`kind` and `text` are the GDD contract (`{kind, text}`); `start` and
`terminated` are additions that no consumer is required to read.

Lexing rules (one pass, left to right; whitespace separates tokens and is never
emitted):

| Input | Token |
|---|---|
| `'…'` with `''` escapes; also `X'…'` / `x'…'` (blob literal) as one token | `STRING` |
| `"…"` with `""` escapes, `[…]`, `` `…` `` | `QUOTED_IDENT` |
| `-- …` to end of line (or end of text); `/* … */` | `COMMENT` |
| Digits, with optional `.` fraction and `e`/`E` exponent; leading `.5`; `0x…` hex | `NUMBER` |
| Letter or `_` followed by letters, digits, `_`, `$` (Unicode letters included) | `WORD` |
| `<=` `>=` `<>` `!=` `==` `\|\|` as one token; any other single character | `PUNCT` |

**Unterminated input** (`'Cola`, `"name`, `/* …`): the token runs to the end of
the text with `terminated = false`. Nothing after it is tokenized. This is total:
`tokenize` never fails and never returns an error, for any input.

### 3. Statement check (rules 5–9) on top of the tokens
`SqlLexer.check(tokens, mode) -> StringName` returns `&""` (accepted) or an
`error_kind`:
1. No tokens other than `COMMENT` → `EMPTY`.
2. A `;` `PUNCT` followed by any non-`COMMENT` token → `MULTI_STATEMENT`
   (exactly one trailing `;` allowed).
3. A `STRING` or `QUOTED_IDENT` with `terminated = false` → **accepted** and
   passed to SQLite, which returns `SQL_ERROR` (`unrecognized token`) — the
   GDD's edge case. An unterminated `/* …` is a comment to the end, as in SQLite.
4. Verb = first `WORD`, or after `WITH` the first `WORD` at parenthesis depth 0
   after the CTE list; `WITH RECURSIVE` (both `WORD`s) → `UNSUPPORTED`;
   mode rules → `NOT_A_QUERY` / `NOT_ALLOWED` (rule 8).

The check runs synchronously on the main thread; a rejected request never
starts a worker (ADR-0001 §1).

### 4. Execution API

```gdscript
class_name SqlRequest extends RefCounted
var sql: String
var dataset: ResolvedDataset   # immutable; produced by PuzzleRepository (ADR-0003)
var mode: StringName           # &"query" (MVP) | &"scratch" (Alpha) | &"modify" (Alpha)

class_name ResolvedDataset extends RefCounted
var id: StringName                     # e.g. &"visible", &"hidden_a"
var tables: Array[TableSpec]           # create order
# TableSpec: name, columns [{name, sql_type, not_null, primary_key}], rows: Array[Array] (positional, typed values)

class_name SqlResult extends RefCounted   # immutable once delivered
var status: StringName          # &"ok" | &"error"
var error_kind: StringName      # &"" when ok
var error_text: String
var build_message: String       # CONTENT_ERROR only — never shown to the player
var columns: PackedStringArray  # SQLite-uniquified (`name`, `name:1`)
var column_count: int           # == columns.size(), also for zero rows
var rows: Array[Array]          # positional, column order; ≤ grader_row_cap
var truncated: bool
var rows_changed: int           # scratch writes only; else 0
var elapsed_ms: float           # receipt → delivery

class_name SqlSandbox extends Node
## Awaitable. Always returns exactly one SqlResult, on the main thread.
func execute(request: SqlRequest) -> SqlResult
## Pure and synchronous; safe to call every keystroke.
func tokenize(sql: String) -> Array[SqlToken]
```

Callers write `var result: SqlResult = await sandbox.execute(request)`. Internally
`execute` runs the check (§3), then hands a static worker function and a copy of
the request data to `ExecutionRunner.run` (ADR-0001) and awaits its completion
signal. Error-only results (`EMPTY`, `MULTI_STATEMENT`, …) still go through
`await` so callers have one code path.

### 5. Inside the worker (`query` mode)
1. `SQLite.new()`, `path = ":memory:"`, `verbosity_level = QUIET`, `open_db()`.
2. Build: `CREATE TABLE` per `TableSpec` (columns, `NOT NULL`, `PRIMARY KEY` from
   the spec), then rows with `query_with_bindings` inside one `BEGIN`/`COMMIT`.
   Any failure → `CONTENT_ERROR`, `error_text = "content error"`, the SQLite
   message in `build_message` (rule 16, SB-12).
3. `CREATE TEMP VIEW _q AS <sql>`; failure → `SQL_ERROR` with
   `error_message` verbatim.
4. `PRAGMA temp.table_info(_q)` → `columns`, `column_count`.
5. `PRAGMA query_only = 1`; `SELECT * FROM temp._q LIMIT <grader_row_cap + 1>`.
6. Rows: each Dictionary from `query_result` is converted to a positional
   `Array` by reading `columns` in order — never by Dictionary iteration order.
   Probed 2026-10-15 (`prototypes/sandbox-timeout-spike-2026-10-15/probe_keys.gd`):
   the Dictionary keys equal the `PRAGMA table_info` names in every case —
   duplicates (`name`, `name:1`, `name:2`), case variants (`NAME` → `name:1`),
   empty aliases (`""`, `:1`), aliases containing `:` and expression names —
   and NULL values keep their key.
   More than `grader_row_cap` rows → cut to the cap, `truncated = true`.
7. `close_db()` on every exit path; return a plain Dictionary. The main thread
   wraps it in `SqlResult`.

`TIMEOUT` is produced by the runner (ADR-0001), never by the worker.

### 6. Calling rules
- The sandbox accepts concurrent requests (each has its own thread and
  database). **Callers** keep at most one request in flight per workbench; the
  grader awaits its `2 + D` executions sequentially.
- A caller that no longer needs a result (the puzzle was closed mid-submit)
  ignores it after `await`; the sandbox never cancels.
- Nothing but the grader and the content verifier may send a hidden dataset.

### Architecture Diagram

```
Workbench / Grader / Verifier ── await execute(SqlRequest) ──► SqlSandbox
Hint / Challenges / Workbench ── tokenize(sql) (sync) ───────► SqlLexer
                                                                  │ check()
                                                     rejected ◄───┤
                                                                  ▼ accepted
                                                    ExecutionRunner (ADR-0001)
                                                                  │ worker: §5 steps 1–7
                                                                  ▼
                                               SqlResult on the main thread
```

### Key Interfaces
See §2 and §4. Type names (`SqlRequest`, `SqlResult`, `SqlToken`,
`ResolvedDataset`, `TableSpec`) and field names are binding for all epics.

### Implementation Guidelines
- Must scan SQL text only through `SqlLexer`; no other module may split, search or regex player SQL for keywords.
- Must match keywords only on `WORD` tokens, case-insensitively (`text.to_upper()`).
- `tokenize` must be total (no error path) and must not allocate a `SQLite` object.
- Must read row values by the `columns` list, never by Dictionary iteration order.
- Must never put the dataset build message in `error_text`; `build_message` must reach only the Playtest Log.
- Must not convert values (int/float/null/String/PackedByteArray stay as SQLite returns them); comparison is the grader's `canon`.
- Must treat `SqlResult`, `SqlToken` and `ResolvedDataset` as immutable after creation.
- Must format any player-facing row-cap text from `grader_row_cap`, never a literal.
- Must not use SQLite features beyond those probed on godot-sqlite v4.9 (e.g. `STRICT` tables) without a new probe.
- Must never emit the completion signal before the caller's `await` is registered: rejected requests `return` their `SqlResult` directly; accepted ones connect to the runner before the worker starts, and the runner's callback reaches the main thread only from its `_process` poll (ADR-0001), never from the worker.
- `SqlSandbox` must be long-lived (owned by the composition root, ADR-0006) and never freed while a request is in flight; a caller freed while awaiting is safe and simply never resumes.
- The worker must receive plain Dictionaries/Arrays (a copy of the request), never `RefCounted` objects; the main thread must fill typed fields with `.assign()` (`rows.assign(value.rows)`), not direct assignment of an untyped array.
- `SqlResult` fields must be plain `var`s with no custom setters (the 4.7 packed-array element-assignment change then cannot matter).

## Alternatives Considered

### Alternative 1: Statement splitting via SQLite (`sqlite3_complete` / prepare-tail)
- **Description**: Let SQLite decide statement boundaries exactly.
- **Pros**: Identical to SQLite's own tokenizer in every corner case.
- **Cons**: Not exposed by godot-sqlite v4.9; needs the native fork ADR-0001 deferred. `tokenize` would still need a GDScript lexer for the synchronous UI path.
- **Rejection Reason**: Unavailable at MVP; the view wrapper already makes SQLite reject non-queries, so a lexer miss cannot run a second statement in `query` mode.

### Alternative 2: Callback / job-object API instead of `await`
- **Description**: `execute(request, on_done: Callable)` or a returned `SqlJob` with a `completed` signal.
- **Pros**: Explicit; a job object could be cancelled.
- **Cons**: The grader's sequential `2 + D` pipeline becomes nested callbacks; there is no cancellation to offer (ADR-0001 cannot stop a query).
- **Rejection Reason**: `await` keeps the grader's verdict pipeline linear and readable; the runner keeps the callback internally.

### Alternative 3: Dictionary results instead of `SqlResult`
- **Description**: Return the GDD's field set as a Dictionary.
- **Pros**: No class to maintain.
- **Cons**: Typos in keys fail silently; no static typing for the five consumer epics.
- **Rejection Reason**: Typed classes match the project's static-typing standard and make the contract checkable at parse time.

## Consequences

### Positive
- One lexer serves the statement check, CC keyword rules and Hint normalization — they can never disagree about what a keyword is.
- `tokenize` handles half-typed SQL, so the CC live check needs no special cases.
- The grader pipeline is linear `await` code.

### Negative
- The lexer is hand-written and must track SQLite's tokenizer for the constructs players use; corner cases (nested quotes styles, Unicode identifiers) need tests.
- Every result crosses the thread boundary as a Dictionary and is re-wrapped (negligible at ≤ 5,000 rows).

## Risks
- **Lexer drift from SQLite** (a construct SQLite reads differently). Mitigation: SB-01…05 plus a lexer test table; `query` mode stays safe anyway because the view wrapper rejects anything but one query.
- **Order through the view** is observed, not guaranteed (sandbox OQ3). Mitigation: SB-08 on every godot-sqlite upgrade; fallback per OQ3 before Chapter 2.
- **Coroutine misuse** (a caller forgetting `await` gets a coroutine state, not a result). Mitigation: static typing (`var r: SqlResult = await …`) and a code-review rule.

*Engine validation (godot-specialist, 2026-10-15): one BLOCKING finding — row keys for duplicate column names were unproven — resolved by the 2026-10-15 key probe (§5 step 6); minor notes folded into Implementation Guidelines. BLOB binding and return (`PackedByteArray`) and NULL keys were probed the same day. TD-ADR skipped — lean mode.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| sql-execution-sandbox.md | Rules 1–2: request with SQL, dataset, mode; fresh DB per `query` request | `SqlRequest`; worker builds and closes a DB per execution (§5) |
| sql-execution-sandbox.md | Rules 5–9: lexer-based statement check before execution | `SqlLexer.check` (§3) on the main thread |
| sql-execution-sandbox.md | Rule 5a: `tokenize(sql) -> Array of {kind, text}` | `SqlToken` (§2), whitespace never emitted |
| sql-execution-sandbox.md | Rules 10–13: view wrapper, zero-row columns, positional rows, `fetch_limit`, `truncated` | §5 steps 3–6 |
| sql-execution-sandbox.md | Rule 16: result record | `SqlResult` fields (§4) |
| sql-execution-sandbox.md | Open Question 2 (lexer vs `sqlite3_complete`) | Resolved: hand-written lexer (§1) |
| sql-execution-sandbox.md | Review 6a recommendation: `tokenize` on unterminated literals | Total lexer; `terminated = false` (§2) |
| hidden-data-grader.md | Rules 6–9a: pre-check, determinism, per-dataset runs, `CONTENT_ERROR` → UNAVAILABLE | `await execute` per dataset; `CONTENT_ERROR` from the build step |
| hint-system.md | Rule 4a: normalization on `tokenize` tokens | Token kinds and no whitespace tokens as specified |
| constraint-challenges.md | Rules 4–5, `has_keyword`: WORD tokens only | `kind = WORD` + case-insensitive compare |
| query-workbench.md | Rule 13 / QW-17: underline the first occurrence of the named token | `SqlToken.start` offsets |

## Performance Implications
- **CPU**: lexer O(n) in characters, microseconds for typical queries — safe per keystroke. Execution cost unchanged from the spike (≈ 0.4 ms).
- **Memory**: one result of ≤ 5,000 rows per execution; tokens per keystroke are short-lived.
- **Load Time**: none.
- **Network**: none.

## Migration Plan
No production code exists. Prototype `grader.gd` / probe code is not migrated.

## Validation Criteria
- SB-01…SB-12 and SB-21 pass as gdUnit4 tests against this API.
- A `tokenize` test table covers every row of §2, unterminated inputs, `X'00FF'`, multi-char operators, and Unicode words.
- HS rule 4a and CC `has_keyword` tests use only `tokenize` output.

## Related
- ADR-0001 — execution runner and TIMEOUT
- ADR-0003 (planned) — `ResolvedDataset` producer, content verifier
- `design/gdd/sql-execution-sandbox.md`, `hidden-data-grader.md`, `hint-system.md`, `constraint-challenges.md`, `query-workbench.md`
- `docs/architecture/architecture.md` — API Boundaries
