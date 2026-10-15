# ADR-0003: Puzzle Data Format, Loader and Content Verifier

## Status
Accepted

## Date
2026-10-15

## Last Verified
2026-10-15

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
Every puzzle, chapter dataset and content check must live in text files that the
game and CI read identically, and the content verifier must reach the same
verdict in both places. Content is authored as JSON (one chapter file plus one
file per puzzle) and loaded through a schema-typed GDScript loader; the content
verifier is GDScript running on the game's own sandbox, invoked headless in CI
and at game load, with a SHA-256 content hash over a canonical, type-normalized
serialisation.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 + godot-sqlite v4.9 |
| **Domain** | Core (data / I/O) |
| **Knowledge Risk** | LOW — `JSON`, `FileAccess` reads, `DirAccess`, `String.sha256_text()` are pre-4.3. MEDIUM only for writes (`FileAccess.store_*` returns `bool` since 4.4) — this ADR reads content and writes only the CI report |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.4 `FileAccess.store_*`), `deprecated-apis.md`, `current-best-practices.md` (headless `-s` runs, `--import` before CI); ADR-0001, ADR-0002; `prototypes/sandbox-timeout-spike-2026-10-15/probe_json.gd` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (0) godot-specialist probes 2026-10-15 on 4.7.2: a `RefCounted` passed to `JSON.stringify` prints its instance id; default float printing keeps ~15 significant digits (`full_precision` needed); `-s` SceneTree scripts get autoloads, `_process` on nodes under `root`, `await` and `quit(code)` exit codes. (1) Probed 2026-10-15 on 4.7.2: `JSON.parse_string` returns **every number as `float`** (`198` → `198.0`; `9007199254740993` → `9007199254740992.0`); `JSON.stringify(data, "", true)` sorts keys and prints an `int` as `198`, a `float` as `198.0`; `"abc".sha256_text()` matches the standard SHA-256. (2) Exported builds must include the JSON files (export include filter) — verify in the first export (ADR-0005) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002 (the verifier and reference cache run SQL through `SqlSandbox.execute`); ADR-0001 transitively |
| **Enables** | Chapter 1 content migration (puzzle Open Question 3); Grader, Workbench, Hint, Challenges, Progression, Dialogue, Manual and Onboarding stories that read puzzle data; ADR-0004 (content hash in log events) |
| **Blocks** | Puzzle Definition epic; Chapter 1 migration; content CI job |
| **Ordering Note** | The build flavour that decides `loaded` vs `withheld` comes from ADR-0004; until then, treat every build as a developer build |

## Context

### Problem Statement
`puzzle-definition-and-datasets.md` leaves two decisions to an ADR: the on-disk
format and loader (Open Question 1 — "text, diffable, readable by both the game
and the CI verifier"), and whether the verifier runs in Godot or in Python
(Open Question 2). Its acceptance criterion L-04 requires that CI and the game
loader agree on every puzzle, and its States section requires a content hash
over a canonical serialisation that ignores field order, whitespace,
`content_status` and the hash itself. Chapter 1 (13 puzzles, ~11 hours of
authoring) is migrated into this format before the playtest, so the format must
be settled now.

### Constraints
- Godot 4.7.2 parses every JSON number as `float` (probe above).
- There is no YAML parser in Godot without an addon.
- The sandbox runs off the frame thread and is async (ADR-0001, ADR-0002).
- Content checks also exist outside puzzles: Store Manual examples never pass a puzzle and `watch_out.rule_tag` ∉ Chapter 1 `trap_rules` (SM rules 3a–4), hint texts (Hint CI), onboarding ghost text (OB-18).
- One developer authors ~50 puzzles by hand over the project (~13 for MVP).

### Requirements
- Text, diffable, hand-authorable; one puzzle per file so a diff names the puzzle.
- Same parse and same checks in CI and at load (L-04).
- Typed values: INTEGER columns stay `int`, so the sandbox inserts integers and `canon` sees integers.
- Content hash stable under key order and whitespace, changed by any content or data edit (L-01, L-06).
- A machine-readable report with one true/false per check and no score (rule 14).

## Decision

### 1. Format: JSON, one chapter file + one file per puzzle
```
assets/data/content/
  chapters/ch1/chapter.json        # id, today, schema, base datasets, hidden datasets (as ops), shifts
  chapters/ch1/puzzles/1-05.json   # one puzzle per file; file stem = puzzle id
  manual/pages.json                # Store Manual pages + trap_rules (SM rules 1–4)
  config/content.json              # visible_rows_max, traps_min, alt_min, feedback_max_level
```
- **Puzzle list** in `chapter.json`: the ordered puzzle ids of the chapter. The
  loader opens `puzzles/<id>.json` for each listed id and never relies on
  directory listing (unverified inside an exported PCK). The file stem must
  equal `id` exactly (case-sensitive — PCKs are, Windows is not).
- **Schema** in `chapter.json`: tables with typed columns
  (`{"name": "price", "type": "INTEGER", "not_null": true}`), primary key, key
  uniqueness per table.
- **Rows** are positional arrays in schema column order (as `ch1.py` and the
  spike's `ch1.json` already use), so a dataset reads like a table in a diff.
- **Datasets** are a base plus ordered operations (`add`, `remove`, `set`,
  `reverse`, `renumber`) exactly as rule 5; a puzzle's `datasets_override`
  appends operations to a copy.
- **SQL fields** (`reference_sql`, `trap_sql`, `alt_valid`, `prefill_sql`,
  `witness_sql`) are JSON strings; multi-line SQL may be written as an array of
  lines that the loader joins with `\n` (authoring convenience only — the hash
  sees the joined string).
- `content_status` and `content_hash` live in each puzzle file.

### 2. Loader: schema-typed parse, never trust JSON number types
`PuzzleRepository` parses with `JSON.new().parse()` (so a syntax error is
reported with `get_error_line()`), then converts every value
through the declared type before anything else sees it:
- dataset cells by column type: `INTEGER` → `int` (must be integral and
  |x| < 2⁵³, else a build error), `REAL` → `float`, `TEXT` → `String`, `null`
  allowed only where `not_null` is false;
- puzzle fields by a field table (e.g. `order`, `hint1_fails` → `int`).
A type mismatch is a **dataset build failure** (puzzle Edge Cases: "the verifier
must not" accept what SQLite's affinity would) and withholds every puzzle using
that dataset. Output types are the immutable `ChapterDef`, `PuzzleDef`,
`ResolvedDataset` (ADR-0002) records.

### 3. Content hash
`content_hash = JSON.stringify(canonical, "", true, true).sha256_text()` where
`canonical` = `PuzzleDef.to_canonical()` — an explicit `Dictionary` built
**only** from `String` keys and `String` / `int` / `float` / `bool` / `null` /
`Array` / `Dictionary` values (never a `RefCounted`, `StringName` or other
object: `JSON.stringify` prints an object as its instance id, which changes on
every run) — holding the typed puzzle fields (after §2) without
`content_status` and `content_hash`, plus its resolved datasets (schema + every
row of every dataset after all operations). Keys are sorted (`sort_keys`);
`full_precision = true` keeps REAL values distinct beyond 15 digits; `int`
prints as `198`, never `198.0`. Text is hashed as UTF-8 without Unicode
normalization (authors keep one form). Field order
and whitespace in the file therefore never change the hash; any value edit
does. CI and the game compute it with the same function.

### 4. Content verifier: GDScript on the game's sandbox (resolves puzzle Open Question 2)
`ContentVerifier` is ordinary game code, a **separate object** — not part of
`PuzzleRepository` (architecture review 2026-10-15, C1). It sits above the
grader: `ServicesFactory` builds it with `(repository, sandbox, grader)` after
the grader exists. The repository holds no reference to the verifier, the
grader or the sandbox; the verifier pushes its results into the repository
through setters (`set_load_state`, `set_reference_result`). This keeps
ownership one-way (ADR-0006) and the repository free of upward dependencies.

Order inside one run: (1) the reference result of every puzzle × dataset is
computed first and stored in the repository's cache; (2) only then does
`puzzle_valid` run the traps and `alt_valid` queries, so the grader's cause
selection reads references that already exist.

The verifier keeps up to `verify_parallelism` executions in flight (default 6,
range 4–8; ADR-0002 §6 allows concurrency) instead of awaiting them one by one:
the runner delivers each result on the next frame poll (ADR-0001), so a
sequential chain costs one frame per execution.

It runs:
- `puzzle_valid` (H, R, A, T, F, K, O, V, C) using the real `HiddenDataGrader`
  for cause selection and the real `SqlSandbox` for every query;
- chapter checks (duplicate ids, `boss` flag vs position — R-04, constraint
  field shape — R-03, and the ordered puzzle-id list in `chapter.json` agrees
  with each puzzle's `order`);
- **CI only**: the other content checks as separate check modules: Store
  Manual examples and `trap_rules` (SM-14…17), hint-text checks (HS-13),
  onboarding ghost text (OB-18), Constraint Challenges `content_valid`
  (CC-11/12). They add ≈ 400–700 executions and their failure has no runtime
  meaning (the content ships only after CI passes), so the game does not run
  them at load.

Two entry points, one code path:
- **CI**: `godot --headless --path . -s res://tools/ci/verify_content.gd`
  (after `godot --headless --path . --import` on a fresh clone). Runs every
  check module and prints the Markdown report; exit code 1 if any puzzle at
  `verified` or later is invalid or its hash differs, or a non-puzzle check
  fails; 0 otherwise (draft failures are reported, not fatal — L-05).
- **Game load**: the same verifier runs at boot with the puzzle and chapter
  checks and the hash only, its executions on worker threads (ADR-0001), and
  its results decide `loaded` / `withheld` per puzzle and fill the
  **reference-result cache** (puzzle id + dataset id → `SqlResult`, grader rule 8).

`prototypes/sqlbini-web/ch1.py` is retired as a verifier once Chapter 1 is
migrated; it stays in `prototypes/` as a reference only.

### Architecture Diagram

```
assets/data/content/*.json
        │ JSON.new().parse() (numbers arrive as float)
        ▼
PuzzleRepository ── typed conversion (§2) ──► ChapterDef / PuzzleDef / ResolvedDataset
   ▲    │ content_hash (§3)
   │    ▼
   │  ContentVerifier (§4; built with repository, sandbox, grader)
   │    ├─ 1. reference results (≤ verify_parallelism in flight) ──► SqlSandbox
   │    ├─ 2. puzzle_valid via HiddenDataGrader + SqlSandbox; chapter checks
   │    ├─ 3. CI only: manual / hint / ghost-text / challenge checks
   │    └─ report (true/false per check, no score)
   │         │
   └─ set_load_state / set_reference_result (setters; repository holds nothing upstream)
             CI: tools/ci/verify_content.gd (exit 0/1)
             Game: loaded/withheld + reference cache
```

### Key Interfaces

```gdscript
class_name PuzzleRepository extends RefCounted
func load_all(root: String = "res://assets/data/content") -> void        # sync parse + typing
func get_chapter(id: StringName) -> ChapterDef
func get_puzzle(id: StringName) -> PuzzleDef                             # null if withheld
func load_state(id: StringName) -> StringName                            # &"loaded" | &"withheld"
func withheld_reason(id: StringName) -> String
func resolve_dataset(puzzle: PuzzleDef, dataset_id: StringName) -> ResolvedDataset
func reference_result(puzzle: PuzzleDef, dataset_id: StringName) -> SqlResult   # from the cache
func content_hash(puzzle: PuzzleDef) -> String
func set_load_state(id: StringName, state: StringName, reason: String) -> void   # verifier only
func set_reference_result(puzzle_id: StringName, dataset_id: StringName, result: SqlResult) -> void  # verifier only

class_name ContentVerifier extends RefCounted
func _init(repository: PuzzleRepository, sandbox: SqlSandbox, grader: HiddenDataGrader, parallelism: int = 6) -> void
func verify_all(include_ci_checks: bool) -> ContentReport                # awaitable; runs SQL; false at game load

class_name ContentReport extends RefCounted
var puzzles: Dictionary        # id -> {checks: {H: bool, R: bool, …}, observations: Dictionary, warnings: PackedStringArray}
var fatal: bool                # a verified-or-later puzzle is invalid or has a stale hash
func to_markdown() -> String
```

### Implementation Guidelines
- Must convert every JSON number through its declared type before use; must never pass a raw `JSON.parse_string` number to SQLite, the grader or the hash.
- Must keep one puzzle per file, file stem equal to `id`; a mismatch is a load error.
- Must never store a target result in content (rule 3); the loader rejects a file that has one.
- Must compute the content hash only through `PuzzleRepository.content_hash`; CI and game share it.
- Must run every content check (puzzles, manual, hints, ghost text, challenges) through `ContentVerifier`; no separate script, Python or otherwise, may decide validity.
- Must run `verify_all` off the frame thread (via the sandbox) and show a loading state during boot; the frame must not block.
- Must keep up to `verify_parallelism` executions in flight (never one sequential `await` per execution) and compute every reference result before any trap or `alt_valid` check.
- `PuzzleRepository` must not hold the verifier, grader or sandbox; only `ContentVerifier` calls its setters (ADR-0006 one-way ownership).
- Must report observations and true/false checks only — never a score or rating (rule 14).
- Export presets must include `assets/data/content/*.json` via an include filter; whether `.json` is exported by default as a `JSON` resource is NOT SOURCEABLE — keep the filter and confirm in ADR-0005's first export.
- `PuzzleDef`, `ResolvedDataset` and every record that feeds the hash must provide `to_canonical() -> Dictionary` with `String` keys only; never pass an object to `JSON.stringify`.
- Duplicate keys in a JSON object are accepted silently by Godot (last wins); the loader must not rely on it — the content style is one key once (a CI lint may flag it later).
- The CI step must run under an outer `timeout` and `set -o pipefail` (a script error before `quit()` leaves Godot running; a pipe hides the exit code); exit codes come from `quit(code)`.
- Content numbers must fit in 2⁵³ (JSON parse limit); the loader rejects larger integers.

## Alternatives Considered

### Alternative 1: Godot resources (`.tres`) per puzzle
- **Description**: Typed `Resource` subclasses edited in the inspector.
- **Pros**: Native types (no float problem); editor UI for free.
- **Cons**: Noisy diffs (resource ids, escaped multi-line SQL), awkward to hand-author 24-row tables, unreadable by anything outside Godot.
- **Rejection Reason**: Diffability and table readability matter more than an inspector for a one-person, text-first content pipeline.

### Alternative 2: SQL scripts for datasets + a manifest for puzzle metadata
- **Description**: `CREATE TABLE` / `INSERT` files per dataset; JSON/YAML for traps and lines.
- **Pros**: Datasets are plain SQL.
- **Cons**: Two formats; overrides (`remove`, `set`, `renumber` by key) become SQL diffs that are hard to read; still needs a manifest parser.
- **Rejection Reason**: One format is simpler; the override operations of rule 5 are clearer as data.

### Alternative 3: Python verifier (`ch1.py` lineage, stdlib `sqlite3`)
- **Description**: Keep the prototype's verifier and port it to the new format.
- **Pros**: Already exists; fast to iterate; no Godot in CI.
- **Cons**: A second SQLite build and a second grader implementation — the game and CI could disagree (L-04); the load-time check must exist in GDScript anyway.
- **Rejection Reason**: Principle 2 ("one SQLite, one verdict"); GDScript is required at load regardless, so Python would be duplicate work.

### Alternative 4: YAML
- **Description**: Friendlier syntax with comments.
- **Cons**: No built-in Godot parser; an addon adds a dependency and a second parser behaviour to verify.
- **Rejection Reason**: JSON is built in and Python-readable if ever needed.

## Consequences

### Positive
- CI and the game cannot disagree: same parser, same typing, same sandbox, same grader (L-04 by construction).
- Puzzle diffs are per file and tables read as rows.
- The reference cache is filled for free at load.

### Negative
- JSON has no comments; designer notes live in `note` fields.
- CI needs a Godot 4.7.2 binary and an `--import` step (minutes per run on a fresh runner).
- The verifier runs at every game start (≈ 200 executions for Chapter 1; each result arrives on a frame poll, so ≈ 200 / 6 ≈ 34 frames ≈ 0.6 s at 60 fps with `verify_parallelism` = 6 — one-by-one awaiting would be ≈ 3.3 s; grows with content).

## Risks
- **JSON float parsing** silently changes types if a code path skips §2. Mitigation: typed records only; a unit test feeds `198` and asserts `int`; the hash test (L-06) would also catch `198.0`.
- **Boot time grows with content** (~50 puzzles later). Mitigation: measure at each chapter; if it exceeds the boot budget, release builds may verify only the stored hash and run the full check in CI (a new ADR).
- **Exported build misses JSON files.** Mitigation: export include filter + first-export smoke check (ADR-0005).
- **CI runner cost/time** for Godot. Mitigation: cache the Godot binary and `.godot/` import in CI (`/test-setup`).

*Engine validation (godot-specialist, 2026-10-15, probed on 4.7.2): one BLOCKING finding — hashing a typed record object would hash its instance id — resolved by `to_canonical()` (§3); minor notes (full precision, String keys, parse error lines, CI timeout/pipefail, no DirAccess listing, export filter unverified) folded into §1–3 and the guidelines. TD-ADR skipped — lean mode.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| puzzle-definition-and-datasets.md | Rules 1–2: chapter vs puzzle definitions | `chapter.json` + `puzzles/<id>.json` (§1) |
| puzzle-definition-and-datasets.md | Rule 5: dataset overrides (`add`/`remove`/`set`/`reverse`/`renumber`) | Ops lists, resolved by the loader (§1–2) |
| puzzle-definition-and-datasets.md | Rule 3: target never stored | Loader rejects a stored target (guidelines) |
| puzzle-definition-and-datasets.md | Rules 10–14, `puzzle_valid`: verifier in CI and at load, same result (L-04, L-05) | One GDScript `ContentVerifier`, two entry points (§4) |
| puzzle-definition-and-datasets.md | States: content hash over canonical serialisation, excluding status and hash (L-01, L-06) | §3 |
| puzzle-definition-and-datasets.md | Edge case: type mismatch must fail the build | Typed conversion (§2) |
| puzzle-definition-and-datasets.md | Open Questions 1 and 2 | Resolved: JSON + GDScript verifier on the game's sandbox |
| hidden-data-grader.md | Rule 8: reference results cached per puzzle and dataset | Cache filled by `verify_all` at load |
| hidden-data-grader.md | Rule 4 / Edge Cases: validate a puzzle at load, refuse to grade an invalid one | `load_state` = `withheld` |
| store-manual.md | Rules 3a–4: `trap_rules` CI, examples never pass a puzzle | Manual check module in `ContentVerifier` |
| onboarding-first-shift.md | OB-18 ghost-text CI | Ghost-text check module |
| constraint-challenges.md | Rule 12 / `content_valid` | Challenge check module |
| playtest-log.md | Rule 3: `content_hash` on every event | `PuzzleRepository.content_hash` |

## Performance Implications
- **CPU**: load-time verification ≈ (references + alt_valid + traps) × datasets executions — ≈ 200 for Chapter 1, ≈ 0.4 ms each on the dev laptop, on worker threads (≤ 6 at once). CI adds ≈ 400–700 for the non-puzzle checks.
- **Memory**: Chapter 1 content is tens of KB; the reference cache holds one small result per puzzle × dataset.
- **Load Time**: bounded by frame-poll delivery, not SQL: ≈ ⌈200 / 6⌉ frames ≈ 0.6 s at 60 fps for Chapter 1 (≈ 2.3 s at ~50 puzzles — revisit per Risks); headless CI ≈ 6.6 ms per frame. Re-measure on the target PC (ADR-0005). Corrected 2026-10-15 (architecture review C2; the earlier "≈ 0.1 s" ignored per-frame delivery).
- **Network**: none.

## Migration Plan
Chapter 1's data exists in `prototypes/sqlbini-web/ch1.py` and the spike's
`ch1.json`. Migration (puzzle Open Question 3) writes `chapter.json` and 13
puzzle files by hand from those sources plus the new fields (tags, `trap_priority`,
feedback, `alt_valid`, rewritten requests 1-4/1-5/1-7/1-8), all at `draft`, then
promotes each to `verified` when the verifier passes. No prototype code is
migrated.

## Validation Criteria
- D-01…D-06, V-H…V-TUT, L-01…L-07, R-01…R-04 pass as gdUnit4 tests / CI runs.
- L-04: CI report and in-game load states are identical for the same content.
- A unit test asserts that an INTEGER cell `198` loads as `int` and that the hash of a file with reordered keys and extra whitespace is unchanged.

## Related
- ADR-0001, ADR-0002 — sandbox runner and API the verifier uses
- ADR-0004 (planned) — build flavour (`withheld` rules), content hash in log events
- ADR-0005 (planned) — export include filter for JSON
- `design/gdd/puzzle-definition-and-datasets.md`, `hidden-data-grader.md`, `store-manual.md`, `onboarding-first-shift.md`, `constraint-challenges.md`, `playtest-log.md`
- `design/levels/chapter-1-puzzles.md`, `prototypes/sqlbini-web/ch1.py` — Chapter 1 source content
