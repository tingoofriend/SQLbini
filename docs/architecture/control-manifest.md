# Control Manifest

> **Engine**: Godot 4.7.2 (GDScript) + godot-sqlite v4.9 (GDExtension)
> **Last Updated**: 2026-10-17
> **Manifest Version**: 2026-10-17
> **ADRs Covered**: ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0006 (Accepted 2026-10-15; text amendments 2026-10-16), ADR-0007, ADR-0010 (Accepted 2026-10-16)
> **ADRs Not Covered**: ADR-0005 (platform, display, performance baseline — not written; pending the Windows godot-sqlite spike); ADR-0008 (workbench editor), ADR-0009 (counter strip) — planned, not written
> **Status**: Active — regenerate with `/create-control-manifest update` when ADRs change
> **TD-MANIFEST**: skipped — Lean mode

`Manifest Version` is the date this manifest was generated. Story files embed
this date when created. `/story-readiness` compares a story's embedded version
to this field to detect stories written against stale rules. Always matches
`Last Updated` — they are the same date, serving different consumers.

This manifest is a programmer's quick-reference extracted from all Accepted ADRs,
technical preferences, and engine reference docs. For the reasoning behind each
rule, see the referenced ADR.

**Layer map** (`docs/architecture/architecture.md`): Foundation = SqlSandbox
(+ SqlLexer, ExecutionRunner), PuzzleRepository, EventBus, GameConfig,
StringTable, Clock, BuildFlavour, composition root. Core = HiddenDataGrader,
WorkbenchController, ContentVerifier. Feature = Hint, Constraint Challenges,
Progression, Dialogue, Store Manual, Onboarding, PlaytestRecorder.
Presentation = WorkbenchView, counter strip, panels, screens. Settings (ADR-0007)
and InputActivity (ADR-0010 §7) are Foundation services built by `ServicesFactory`.

> **Gaps this manifest cannot cover yet:** platform/display/renderer/budgets
> and export settings incl. `include_text_server_data` (ADR-0005), `CodeEdit`
> editor setup, chord handling, IME and AccessKit (ADR-0008 — note the
> 2026-10-17 probe: a focused `CodeEdit` consumes Ctrl+Enter, Ctrl+Shift+Enter
> and Ctrl+M before `_shortcut_input`, `prototypes/codeedit-shortcut-probe-2026-10-17/`),
> counter-strip rendering (ADR-0009). Stories touching those areas stay blocked
> until the ADR exists and is Accepted.

---

## Foundation Layer Rules

*Applies to: sandbox, puzzle repository, event bus, clock, build flavour, composition root (engine init)*

### Required Patterns

**Sandbox execution (ADR-0001)**
- **Run the statement check (lexer, sandbox rules 5–9) synchronously on the main thread; a rejected request never starts a thread** — source: ADR-0001
- **Start a new dedicated `Thread` per accepted execution; the worker creates its own `SQLite` object, builds the DB, runs view / metadata / fetch, closes the DB and returns plain data** — source: ADR-0001
- **Copy request data into the worker; return the result through `wait_to_finish()`; share no `SQLite` object, row array or result between threads while the worker runs** — source: ADR-0001
- **Poll every in-flight execution once per frame in `ExecutionRunner._process`: finished → `wait_to_finish()` + deliver; elapsed ≥ `exec_time_limit` → deliver `TIMEOUT` at once and move the thread to the graveyard** — source: ADR-0001
- **Reap the graveyard every frame: join a thread with `wait_to_finish()` only when `is_alive()` is false** — source: ADR-0001
- **Deliver exactly one result per request (TIMEOUT or the real one, never both)** — source: ADR-0001
- **Measure elapsed time and the timeout from the injected `Clock.now_ms()` from request receipt** — source: ADR-0001, ADR-0006
- **Set `process_mode = PROCESS_MODE_ALWAYS` on the runner node** (a paused tree stops `_process` otherwise) — source: ADR-0001
- **The worker `Callable` is a static function (or bound to a `RefCounted`); build the returned Dictionary/Array inside the thread; call `close_db()` on every exit path** — source: ADR-0001
- **Dev builds log a warning when `abandoned_count()` exceeds 2** — source: ADR-0001
- **Scratch mode (Alpha): a timed-out scratch DB is never reused; rebuild it from the visible dataset** — source: ADR-0001

**Sandbox API and lexer (ADR-0002)**
- **Public API: `await sandbox.execute(SqlRequest) -> SqlResult` (always exactly one result, on the main thread) and pure synchronous `tokenize(sql) -> Array[SqlToken]`** — source: ADR-0002
- **Type and field names `SqlRequest`, `SqlResult`, `SqlToken`, `ResolvedDataset`, `TableSpec` are binding for all epics** — source: ADR-0002
- **Each request awaits its own per-request completion object (a small `RefCounted` with its own `done(result)` signal)** — source: ADR-0002
- **Rejected requests `return` their `SqlResult` directly; accepted ones connect to the runner before the worker starts; the callback reaches the main thread only from the runner's `_process` poll** — source: ADR-0002
- **`SqlLexer` is the only place SQL text is scanned; the statement check and `tokenize` share it** — source: ADR-0002
- **`tokenize` is total (never errors); whitespace emits no token; unterminated `STRING` / `QUOTED_IDENT` / `/* COMMENT` run to the end of the text with `terminated = false`** — source: ADR-0002
- **Match keywords only on `WORD` tokens, case-insensitively (`text.to_upper()`)** — source: ADR-0002
- **Worker steps in `query` mode: `:memory:` DB, `verbosity_level = QUIET` → `CREATE TABLE` + rows via `query_with_bindings` in one transaction (failure → `CONTENT_ERROR`, SQLite message in `build_message`) → `CREATE TEMP VIEW _q AS <sql>` (failure → `SQL_ERROR`) → `PRAGMA temp.table_info(_q)` → `PRAGMA query_only = 1` → `SELECT * FROM temp._q LIMIT grader_row_cap + 1`** — source: ADR-0002
- **Convert each row Dictionary to a positional `Array` by reading `columns` in order** — source: ADR-0002
- **More than `grader_row_cap` rows → cut to the cap, `truncated = true`** — source: ADR-0002
- **The worker receives plain Dictionaries/Arrays, never `RefCounted`; the main thread fills typed fields with `.assign()`** — source: ADR-0002
- **`SqlResult` fields are plain `var`s without custom setters; `SqlResult`, `SqlToken`, `ResolvedDataset` are immutable after creation** — source: ADR-0002
- **Leave godot-sqlite's extension loading disabled (SB-09 guards it)** — source: ADR-0002
- **`SqlSandbox` is long-lived (owned by the composition root) and never freed with a request in flight** — source: ADR-0002, ADR-0006
- **Format any player-facing row-cap text from `grader_row_cap`** — source: ADR-0002

**Puzzle content and repository (ADR-0003)**
- **Content is JSON under `assets/data/content/`: `chapters/<ch>/chapter.json` (ordered puzzle-id list, schema, base datasets, hidden datasets as ops, shifts) + `chapters/<ch>/puzzles/<id>.json` (one puzzle per file, stem = `id`, case-sensitive) + `manual/pages.json` + `config/content.json`** — source: ADR-0003
- **Open each puzzle by the id list in `chapter.json`; never rely on directory listing** — source: ADR-0003
- **Rows are positional arrays in schema column order; datasets are a base plus ordered ops (`add`, `remove`, `set`, `reverse`, `renumber`)** — source: ADR-0003
- **Parse with `JSON.new().parse()` (for `get_error_line()`), then convert every value through its declared type: `INTEGER` → `int` (integral, |x| < 2⁵³), `REAL` → `float`, `TEXT` → `String`, `null` only where allowed; a mismatch is a dataset build failure** — source: ADR-0003
- **Content hash = `JSON.stringify(to_canonical(), "", true, true).sha256_text()`, computed only by `PuzzleRepository.content_hash`; `to_canonical()` returns `String` keys and plain values only, excludes `content_status` and `content_hash`, includes resolved datasets** — source: ADR-0003
- **`PuzzleRepository` holds no verifier, grader or sandbox; only `ContentVerifier` calls `set_load_state` / `set_reference_result`** — source: ADR-0003, ADR-0006
- **Export presets include `assets/data/content/*.json` via an include filter** — source: ADR-0003

**Event bus and build flavour (ADR-0004)**
- **`BuildFlavour` resolves once at boot from feature tags: `editor` → dev; else `dev` tag → dev (warn if `playtest` too); else `playtest` tag → playtest; else release** — source: ADR-0004
- **Every log event goes through `EventBus.emit_event(event_name, puzzle_id, data)` with names and fields exactly as `playtest-log.md` rule 4 / `EventCatalog`** — source: ADR-0004
- **The bus rejects (does not dispatch) an undeclared name, a missing / undeclared / wrongly typed field, counts it in `undeclared_events`, and warns in dev** — source: ADR-0004
- **The bus stamps `{t_ms, wall, session, build, event, puzzle, content_hash, data}`; `t_ms` from `Clock.now_ms()`, `wall` from `Clock.wall_iso()`** — source: ADR-0004, ADR-0006
- **A new event is declared in its GDD, `playtest-log.md` rule 4 and `EventCatalog` together** — source: ADR-0004

**Composition root and clock (ADR-0006)**
- **`src/main.tscn` (`Main`) is the only composition root: build services in boot order via `ServicesFactory.build(flavour, clock)`, await `ContentVerifier.verify_all(false)` behind a loading state, then `setup(services)` each play scene before `add_child`** — source: ADR-0006
- **Boot order (`ServicesFactory.build`): BuildFlavour → Clock + FocusListener → GameConfig → StringTable → Settings → EventBus (+ PlaytestRecorder) → SqlSandbox → PuzzleRepository → HintSystem → HiddenDataGrader (`hint_counter` bound to the Hint System) → ContentVerifier → `await verify_all(false)` → other feature systems → `GameplayWiring.connect_all(services)` → InputActivity (last child of `Main`) → play scenes** — source: ADR-0006, ADR-0010 §1
- **Gameplay signals are connected only after `verify_all`, so nothing the verifier does reaches a gameplay consumer** — source: ADR-0006, ADR-0010
- **Seed `FocusListener` at boot from `DisplayServer.window_is_focused()` (focus notifications only report changes); verify on desktop, not headless** — source: ADR-0006
- **Services are built only by `ServicesFactory` (game and integration tests share it)** — source: ADR-0006
- **`RefCounted` systems take dependencies in `_init(...)`; scene scripts expose `setup(services: Services) -> void`; depend on the narrowest type needed** — source: ADR-0006
- **Ownership is one-way: `Main` / `ServicesFactory` own services; no service holds the `Services` container; upstream notification by signal or `WeakRef`** — source: ADR-0006
- **Every time-dependent rule reads the injected `Clock` (`now_ms`, `is_focused`, `wall_iso`); accumulated rule time samples `Clock.now_ms()` once per tick, clamps per rule, and adds only while the rule's conditions hold** — source: ADR-0006
- **`FocusListener` uses `process_mode = PROCESS_MODE_ALWAYS`** — source: ADR-0006
- **Assert non-null dependencies in `_ready` / `setup` (debug builds)** — source: ADR-0006
- **Signals between systems use typed `signal.connect(callable)`** — source: ADR-0006

**Tuning config, strings and settings (ADR-0007)**
- **Tuning lives in typed JSON per system under `assets/data/config/` (`sandbox.json`, `grader.json`, `hint.json`, `dialogue.json`, `workbench.json`, `settings.json`); content thresholds incl. `feedback_max_level` and `verify_parallelism` (4–8, default 6) in `assets/data/content/config/content.json`; each key has exactly one home file** — source: ADR-0007 §1, ADR-0003
- **`GameConfig` validates every key with a `ConfigSchema` entry `{type, default, min, max, on_invalid, on_out_of_range, nonpositive_to_default}` copied from the owning GDD; a GDD knob change updates the schema in the same change; a test compares schema and GDD tables** — source: ADR-0007 §1
- **Load: `JSON.new().parse()` → convert through the declared type (ADR-0003 §2) → invalid value = dev load error (fatal boot) / playtest + release default + `push_error`; valid but out of range = clamp + warning naming the key; `nonpositive_to_default` keys (e.g. `exec_time_limit_ms`): ≤ 0 → default + warning in every flavour** — source: ADR-0007 §1
- **Per-puzzle overrides use the same `ConfigSchema` entry: CI fails on an invalid one; at load an invalid override is ignored (global value + `push_error`, puzzle stays playable), an out-of-range one is clamped** — source: ADR-0007 §1
- **Unknown keys are reported (dev warning, CI failure)** — source: ADR-0007 §1
- **`GameConfig` exposes immutable typed getters per system (`config.hint.hint1_fails`); no system reads JSON itself** — source: ADR-0007 §1
- **Strings: English JSON tables `assets/data/strings/en/*.json`, one flat object per file; ids are dotted `[A-Za-z0-9_-]` segments, unique across files (CI); GDD id families keep their spelling (`fail.generic`, `error.SQL_ERROR`, `skip.offer`, `onboarding.ghost.1-2`)** — source: ADR-0007 §2
- **`StringTable.text(id, args = {})` fills `{name}` placeholders in one pass (never rescans an inserted value); dev warns on a `{name}` without an argument** — source: ADR-0007 §2
- **Missing id: dev → `"[" + id + "]"`; playtest / release → the family's generic line by first segment (`fail.*` → `fail.generic`, `error.*` → `error.generic`, `skip.*` / `challenge.*` / `system.*` → `<family>.generic`, else `ui.missing`); reported once per id (`push_warning` dev / `push_error` others); a missing generic line is a CI failure** — source: ADR-0007 §2
- **Puzzle- and chapter-authored text stays in content JSON; `StringTable` resolves `puzzle:<id>:<field>` ids through `PuzzleRepository`** — source: ADR-0007 §2
- **Grapheme length = `TextServerManager.get_primary_interface().string_get_character_breaks(text, "").size()` via `StringTable.grapheme_len` — for authoring checks and `reaction_hold`'s `len`** — source: ADR-0007 §2
- **`Settings` (RefCounted, plain data): `ui_scale`, `reduced_motion`, `coach_marks`, `reveal_cps`, `effective_reveal_cps()`, `set_value()` (validates with `ConfigSchema`, emits `setting_changed(key)`), `to_dict()` / `from_dict()`; built from `settings.json` defaults; session-only at MVP** — source: ADR-0007 §3
- **Config and missing-id reports use `push_warning` / `push_error` (they reach Godot's log file in every build); they are not playtest-log events** — source: ADR-0007
- **The Python report tool reads `idle_cutoff_s` from `assets/data/config/hint.json`** — source: ADR-0007, ADR-0004 §5

**Input activity (ADR-0010 §7)**
- **`InputActivity` is the last child of `Main`, `process_mode = PROCESS_MODE_ALWAYS`; records `last_input_ms = clock.now_ms()` from `get_tree().root.window_input` for `InputEventKey`, mouse button, wheel and `InputEventPanGesture` while a play scene is active; consumes nothing; ignores `KEY_F9`; branches on event type** — source: ADR-0010 §7

### Forbidden Approaches
- **Never run SQL on the frame thread** — would freeze the game (sandbox rule 15) — source: ADR-0001
- **Never call `wait_to_finish()` on a thread that `is_alive()`, nor `OS.delay_*` / any blocking wait on the main thread** — blocks the frame — source: ADR-0001
- **Never touch one `SQLite` object from two threads, pass a `SQLite` object into a worker, or emit signals / touch nodes from a worker** — source: ADR-0001
- **Never use `WorkerThreadPool` for queries** — an abandoned query would hold a pool slot for minutes — source: ADR-0001
- **Never use a persistent helper process for execution** — rejected: 147 ms spawn/respawn, JSON loses int types, Windows unverified — source: ADR-0001 (Alt. 1)
- **Never await one shared runner signal for several requests** — concurrent awaits would get the wrong result — source: ADR-0002
- **Never split, search or regex player SQL outside `SqlLexer`** — source: ADR-0002
- **Never read row values by Dictionary iteration order** — source: ADR-0002
- **Never put the dataset build message in `error_text`; `build_message` reaches only the Playtest Log** — source: ADR-0002
- **Never convert SQLite values in the sandbox** (comparison is the grader's `canon`) — source: ADR-0002
- **Never return results as untyped Dictionaries or use a callback/job API for `execute`** — source: ADR-0002 (Alt. 2, 3)
- **Never use SQLite features not probed on godot-sqlite v4.9 (e.g. `STRICT` tables) without a new probe** — source: ADR-0002
- **Never pass a raw `JSON.parse_string` number to SQLite, the grader or the hash** — Godot parses every JSON number as `float` — source: ADR-0003
- **Never pass an object (`RefCounted`, `StringName`) to `JSON.stringify` for hashing** — it prints the instance id — source: ADR-0003
- **Never store a target result in content; the loader rejects it** — source: ADR-0003
- **Never use `.tres` resources, SQL scripts + manifest, YAML, or a Python verifier for content** — source: ADR-0003 (Alts. 1–4)
- **Never check feature tags outside `BuildFlavour`** — source: ADR-0004
- **Never register gameplay systems as autoloads or reach a service by node path / `get_node("/root/…")`** (tooling autoloads from addons are allowed; gdUnit4 adds none) — source: ADR-0006
- **Never call `Time.*` outside `RealClock`; never drive a rule from `_process` `delta`** — source: ADR-0006
- **Never create mutual strong references between `RefCounted` services** — they leak — source: ADR-0006
- **Never wait on `Main.ready`** — `_ready` returns at its first `await` — source: ADR-0006
- **Never pass a service as a `Callable.bind()` argument** — bound arguments are held strongly and recreate a reference cycle — source: ADR-0006, ADR-0010
- **Never read a literal tuning value in `src/`** (constants only for true invariants such as the `2` in `2 + D`) — source: ADR-0007
- **Never use `assert()` for config or string validation** — stripped in release builds — source: ADR-0007
- **Never crash a player build on config** — invalid values fall back to the default — source: ADR-0007
- **Never use `.cfg` / `.tres` for tuning, or validate knobs inside each system** — one format, one schema — source: ADR-0007 (Alts. 2, 3)
- **Never read input activity in `_input`** — blind while an embedded dialog or popup is open — source: ADR-0010 §7

### Performance Guardrails
- **SqlSandbox**: TIMEOUT delivered within `exec_time_limit` (50–150 ms, default 100) + one frame; inside SB-18's 50 ms margin above ≈ 20 fps — source: ADR-0001
- **SqlSandbox**: frame ≤ 16.6 ms during any query, including abandoned ones (SB-19) — source: ADR-0001
- **SqlSandbox**: each result arrives on the next frame poll — budget ≥ one frame (≈ 16.7 ms at 60 fps) per sequential execution — source: ADR-0001
- **SqlSandbox**: one result ≤ `grader_row_cap` (5,000) rows; `tokenize` O(n), safe per keystroke — source: ADR-0002
- **Boot**: content verification ≈ 200 executions for Chapter 1 ≈ 0.6 s at 60 fps with 6 in flight; re-measure per chapter and on the target PC — source: ADR-0003, ADR-0006

---

## Core Layer Rules

*Applies to: Hidden-Data Grader, Workbench controller (draft / Run / Submit), Content Verifier*

### Required Patterns
- **The grader awaits its `2 + D` executions sequentially and stops at the first hidden `TIMEOUT`** — source: ADR-0002, ADR-0001
- **Only the grader and the content verifier may send a hidden dataset** — source: ADR-0002
- **The grader receives `hint_counted` through an injected `hint_counter: Callable` (`func(verdict, sql) -> bool`) in `_init`, bound by `ServicesFactory` to the Hint System, which is built first (stub returning `false` until the Hint epic)** — source: ADR-0004, ADR-0006
- **`HiddenDataGrader.grade(puzzle, sql, counters) -> Verdict` (awaitable) has no side effects: no `hint_counter`, no event, no signal** — source: ADR-0010 §3
- **`HiddenDataGrader.submit(...)` is the player path, in order: `await grade()` → `hint_counted = hint_counter.call(verdict, sql)` → `bus.emit_event(&"submit", …, {…, hint_counted})` → `verdict_given.emit(verdict)` → `return verdict`; steps 2–5 contain no `await`** — source: ADR-0010 §3
- **Per-cause counters are caller-supplied: the Workbench controller owns the main request's counter set and resets it on `request_restarted`; challenge counter sets are untouched by Restart** — source: ADR-0010 §6
- **`Verdict` fields: `puzzle_id`, `kind` (`PASS` / `FAIL` / `SUBMIT_ERROR` / `UNAVAILABLE`), `cause`, `level`, `statement_key`, `error_kind`, `error_text` (`""` for `TOO_MANY_ROWS`), `challenge`; immutable after creation; never `per_dataset`, missing/extra counts or hidden rows** — source: ADR-0010 §2
- **The Workbench controller receives the full `Verdict` as the return of `await grader.submit(...)` and shows the neutral statement from `statement_key` via `StringTable`** — source: ADR-0010 §2
- **Workbench controller declares `run_started(puzzle_id)`, `run_finished(puzzle_id, result_ok, rows_match, feedback: DialogueFeedback)` (`feedback` null when the Run was OK), `submit_started(puzzle_id)`, `draft_edited(puzzle_id, text)`, `line_requested(line_id, puzzle_id)` (first-Submit explainer); it answers `draft_is_empty(puzzle_id)` through the injected Callable** — source: ADR-0010 §4
- **Hidden-dataset details (`per_dataset`, `missing_count`, `extra_count`) appear only in `submit` event data; no API returns hidden rows or counts to a presentation module** — source: ADR-0004
- **Workbench controller: stamp each Run with an increasing sequence number; a new Run may start while an older one runs; discard any result that is not the newest** — source: ADR-0002
- **Workbench controller: a Submit is exclusive — refuse Run and Submit while one is in flight** — source: ADR-0002
- **A caller that no longer needs a result ignores it after `await`; the sandbox never cancels** — source: ADR-0002
- **`var result: SqlResult = await sandbox.execute(request)` — always typed** — source: ADR-0002
- **ContentVerifier is built by `ServicesFactory` with `(repository, sandbox, grader, parallelism)` after the grader (`parallelism` = `verify_parallelism` from `content.json`); it computes every reference result first, then runs trap / `alt_valid` checks through `grade()`, never `submit()`** — source: ADR-0003, ADR-0010 §3
- **ContentVerifier keeps up to `verify_parallelism` executions in flight (default 6, range 4–8)** — source: ADR-0003
- **ContentVerifier CI check modules also validate per-puzzle config overrides and string ids (every id referenced by content and code exists; RD-12 literal scan of `src/`)** — source: ADR-0007
- **ContentVerifier runs `puzzle_valid` + chapter checks (incl. id list vs `order`) + hash at game load; manual / hint / ghost-text / challenge checks run in CI only (`verify_all(true)`)** — source: ADR-0003
- **Report observations and true/false checks only — never a score** — source: ADR-0003
- **CI entry `godot --headless --path . -s res://tools/ci/verify_content.gd` after `--import`, under an outer `timeout` and `set -o pipefail`; exit codes from `quit(code)`** — source: ADR-0003

### Forbidden Approaches
- **Never await verifier executions one by one** — ≈ 3.3 s boot instead of ≈ 0.6 s — source: ADR-0003
- **Never let any script other than `ContentVerifier` decide content validity** — "one SQLite, one verdict" — source: ADR-0003
- **Never route a gameplay reaction through `event_recorded`** — source: ADR-0004 (Alt. 2)
- **Never call `submit()` from anything but the player's Submit** (verifier, cause-selection tests use `grade()`) — source: ADR-0010
- **Never put an `await` between `grade()`'s return and the last enqueue of a submit's lines** — it splits the reaction batch — source: ADR-0010 §3, §5

### Performance Guardrails
- **Submit**: p95 ≤ 300 ms, Run p95 ≤ 200 ms on the target PC (grader AC-26; target PC pending ADR-0005); worst case `submit_worst` per `sql-execution-sandbox.md` Formulas — source: ADR-0001
- **Content load**: ≈ 0.4 ms per execution on the dev laptop, off the frame thread — source: ADR-0003

---

## Feature Layer Rules

*Applies to: Hint, Constraint Challenges, Progression, Dialogue, Store Manual, Onboarding, Playtest Recorder*

### Required Patterns
- **Hint normalization and Constraint Challenges keyword rules use only `tokenize` output (`WORD` tokens, case-insensitive)** — source: ADR-0002
- **Gameplay control between systems uses typed signals; one-way notifications stay signals; a synchronous answer uses an injected `Callable` (`hint_counter`, `draft_is_empty`) — never a signal or a stored reference** — source: ADR-0004, ADR-0006, ADR-0010
- **Each producer declares its gameplay signals with typed parameters, snake_case past tense, exactly as the ADR-0010 §4 catalogue (names, parameter types and owners are binding)** — source: ADR-0010
- **Connect gameplay signals only in `GameplayWiring.connect_all(services)`; every consumer is a strongly owned `Services` field; handlers are bound methods with typed parameters** — source: ADR-0010
- **Payload ids are `StringName`; records are `RefCounted`; no `Node` in a payload** — source: ADR-0010
- **Every consumer reacts using only its own state and the payload; multi-consumer fan-outs are tested in both connection orders** — source: ADR-0010
- **Progression ignores verdicts with `challenge = true`** — source: ADR-0010 §4
- **`request_opened` is the state change to `Open`; `request_shown` is the display — the Workbench loads a puzzle only on `request_shown`; nothing is shown while challenge mode is open** — source: ADR-0010 §4
- **Dialogue receives only `DialogueFeedback` (`from_verdict` / `from_run_result`); `error_text` is passed only for `SQL_ERROR`-style sandbox text, blank for `CONTENT_ERROR`, `TOO_MANY_ROWS` and `UNAVAILABLE`** — source: ADR-0010 §2
- **Every character line goes through the Dialogue reaction queue: enqueue, flush with `call_deferred` per synchronous batch, priority 1 verdict / error reaction and pass line (a same-batch `challenge_offered` merges into the pass bubble) → 2 first-Submit explainer → 3 onboarding start-over → 4 `skip.offer` → 5 `skip.accept`; lower priorities queue behind; newest replaces older within a priority; a new batch drops unshown lines of older batches; the queue re-arms its flush on every enqueue** — source: ADR-0010 §5
- **A line that must follow another in the same submit is enqueued in the same synchronous chain (Progression emits `skip_offered` synchronously after `hints_exhausted`)** — source: ADR-0010 §5
- **A dropped `skip.offer` loses only its line; the "↷ Leave it for Kenji" button state stays with Progression** — source: ADR-0010 §5
- **Restart: the chapter-list view calls `ShiftProgression.request_restart(puzzle_id)` after its IP-18 confirmation; Progression logs `request_restart {state, draft_was_empty}` (from `draft_is_empty`, called before emitting) and emits `request_restarted`; consumers (Workbench controller, Hint, Onboarding, Dialogue) reset only their own state; Constraint Challenges is not a consumer** — source: ADR-0010 §6
- **The Hint System reads `InputActivity.last_input_ms()` and `clock.is_focused()`; its pause comes from its own state set by `challenge_mode_changed` and `request_shown`; the Workbench's `draft_edited` also stamps activity (IME backup)** — source: ADR-0010 §7
- **Gameplay signals are emitted in addition to, never instead of, the `playtest-log.md` rule 4 log events** — source: ADR-0010, ADR-0004
- **A new cross-system link edits ADR-0010 §4 (or its successor), the owning GDD's Interactions table and `GameplayWiring` together** — source: ADR-0010
- **Read the dialogue reveal speed through `Settings.effective_reveal_cps()`; count `reaction_hold` length with `StringTable.grapheme_len`** — source: ADR-0007
- **Every system emits its log events only through `EventBus.emit_event`; gameplay behaves identically with the recorder absent** — source: ADR-0004
- **Hint `active_time` and Dialogue hold / reveal timers read `Clock` (tick-sampled, clamped per rule); gameplay pause comes from Progression / Challenges state, not `Clock`** — source: ADR-0006
- **Progression, Hint, Challenge and Manual state stays plain data (no node references) so VS Save/Load can serialise it** — source: architecture.md, ADR-0006
- **PlaytestRecorder exists only when `BuildFlavour == playtest` (or dev with a debug toggle); states `AwaitingSetup → Recording → Ended` / `Recording → Stopped`** — source: ADR-0004
- **Recorder file `user://playtest-logs/<session>.jsonl` (`session` = UTC `YYYYMMDD-HHMMSS-<4 hex>`); create the folder with `DirAccess.make_dir_recursive_absolute()`; open once with `FileAccess.WRITE`; `open` failure → `Stopped`, gameplay starts normally** — source: ADR-0004
- **Per event: `store_line(JSON.stringify(record))` → `flush()` → check `get_error()` (authoritative) and the `bool` return; failure → close, `Stopped`, "Recording stopped"; never retry or raise** — source: ADR-0004
- **Write through a small `LogSink` interface (real `FileAccess` sink; failing / in-memory sink in tests)** — source: ADR-0004
- **`session_end {undeclared_events}` only on quit — window close and every code-initiated quit through `Main.quit_game()`; never at chapter end** — source: ADR-0004
- **Report tool `tools/playtest-report/playtest_report.py`: Python 3 stdlib only, prints Markdown; reads tuning such as `idle_cutoff_s` from the game's config file (`--config`); tests with `unittest` + fixtures** — source: ADR-0004

### Forbidden Approaches
- **Never write to the log file directly from a system, or depend on the logger existing** — source: ADR-0004 (Alt. 1)
- **Never connect a system to another system's signal from its own `setup` / `_init`, or hold a reference to a consumer** — source: ADR-0010 (Alt. 2)
- **Never use a central `GameplaySignals` hub** — ownership would be invisible — source: ADR-0010 (Alt. 1)
- **Never rely on the order in which one signal calls its connections, or on the relative order of `call_deferred` calls from different objects** — NOT SOURCEABLE for 4.7 and does not fix the RD-19 inversion — source: ADR-0010 (Alt. 3)
- **Never give Dialogue a `Verdict` or any hidden-data detail** — source: ADR-0010
- **Never use a lambda capturing a consumer as a handler** — a connection does not keep its target alive — source: ADR-0010
- **Never record OS user name, hostname, paths, or anything typed outside the editor, setup prompt and F9 note** — source: ADR-0004
- **Never move the writer to a background thread unless the PL-08 frame check fails on the target PC** — source: ADR-0004 (Alt. 3)
- **Never ship a release export preset with the `playtest` or `dev` tag** — source: ADR-0004

### Performance Guardrails
- **Recorder**: one validated `JSON.stringify` + line + `flush()` per event on the main thread, at human event rates; if PL-08's frame check fails, move to a dedicated writer thread with the same format — source: ADR-0004
- **Signals / reaction queue**: a few emissions per player action and one deferred flush per batch with lines pending; two small records per submit — source: ADR-0010

---

## Presentation Layer Rules

*Applies to: WorkbenchView, panels, counter strip, screens, playtest UI*

### Required Patterns
- **Handle F9 from `get_tree().root.window_input` (works with `CodeEdit` focused and with an embedded dialog open): `InputEventKey`, `keycode == KEY_F9`, `pressed and not echo`; consuming it is not relied on; ignore F9 while the note field is open** — source: ADR-0004 §4
- **F9 emits `help_given` at once (puzzle or `null`); opens the one-line note field only when `get_tree().root.get_embedded_subwindows().is_empty()` (with a dialog open, the marker is recorded without a note); Enter, Esc or 5 s without a key closes it; a non-empty note becomes a separate `help_note {note}`; return keyboard focus with a deferred `grab_focus()` on the editor** — source: ADR-0004 §4
- **Recorder corner label "● Recording playtest" / "Recording stopped" on a top `CanvasLayer`, ink not red, clear of the editor and tables** — source: ADR-0004
- **Scene scripts expose `setup(services)` and are set up before entering the tree; tests pass a set-up instance to `scene_runner` wrapped in `auto_free`** — source: ADR-0006
- **Use `SqlToken.start` offsets for editor underlines and highlights** — source: ADR-0002
- **Input is blocked by the boot loading state until `verify_all(false)` completes** — source: ADR-0006
- **Every player-facing string comes from `StringTable.text(id, args)`; Controls receive resolved text (no translation keys in scenes)** — source: ADR-0007 §2
- **`Main` sets `auto_translate_mode = AUTO_TRANSLATE_MODE_DISABLED` (children inherit); the recorder's corner label sits outside any UI root** — source: ADR-0007 §2
- **Presentation reads `Settings` values and connects to `setting_changed`; reduced motion applies at once (running motions jump to their end); the options panel writes through `Settings.set_value`** — source: ADR-0007 §3
- **Views connect to the systems they get in `setup(services)` (presentation wiring, not gameplay control); the Workbench view reacts to `request_shown`, never `request_opened`; it hides Hint / Manual "new" while `guided_window_changed(true)` (systems keep their indicator state)** — source: ADR-0010 §1, §4

### Forbidden Approaches
- **Never identify input by `event.device`** (4.7 device IDs) — branch on event type — source: ADR-0004, `current-best-practices.md`
- **Never read hidden-dataset details from the bus in UI** — source: ADR-0004
- **Never put a player-facing string literal in `src/`** (RD-12 CI scan; ids and test code excepted) — source: ADR-0007
- **Never use `tr()` / `TranslationServer` at MVP; keep ids stable for a later move** — source: ADR-0007 (Alt. 1)
- **Never use `String.format` on player-facing text** — no escape syntax, order-dependent rescans — source: ADR-0007 §2
- **Never count authoring or `reaction_hold` lengths with `String.length()`** (exception: Constraint Challenges' `canonical_length`, code points) — source: ADR-0007
- **Never page the bubble by character counts** — paging is measured layout (ADR-0008) — source: ADR-0007

---

## Global Rules (All Layers)

### Naming Conventions
| Element | Convention | Example | Source |
|---------|-----------|---------|--------|
| Classes | PascalCase | `HiddenDataGrader` | `naming.classes` in project.yaml |
| Variables | snake_case | `hidden_datasets` | `naming.variables` in project.yaml |
| Signals/Events | snake_case, past tense | `query_submitted` | `naming.signals` in project.yaml |
| Files | snake_case matching the class | `hidden_data_grader.gd` | `naming.files` in project.yaml |
| Scenes | snake_case matching the file | `query_workbench.tscn` | `naming.scenes` in project.yaml |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RESULT_ROWS` | `naming.constants` in project.yaml |
| Tests | file `[system]_[feature]_test.gd`, function `test_[scenario]_[expected]` | `sandbox_lexer_test.gd` | `.claude/rules/test-standards.md` |
| Log events | names exactly as `playtest-log.md` rule 4 | `request_restart` | ADR-0004 |

### Performance Budgets
| Target | Value | Source |
|--------|-------|--------|
| Framerate | 60 fps | technical-preferences.md (project.yaml has no `performance` block) |
| Frame budget | 16.6 ms | technical-preferences.md |
| Draw calls | < 500 (2D UI) | technical-preferences.md |
| Memory ceiling | TO BE CONFIGURED — 64 MB 2D texture ceiling proposed (art bible 8.9), pending ADR-0005 | technical-preferences.md |

### Approved Libraries / Addons
- **godot-sqlite v4.9** (GDExtension, `compatibility_minimum = "4.7"`) — the game's only SQL engine — source: ADR-0001, ADR-0002 (technical-preferences.md lists none yet)
- **gdUnit4 v6.2.2** (`addons/gdUnit4/`, official tag) — tests only — source: `tests/README.md`, ADR-0006 verification
- **Python 3 standard library** — `tools/playtest-report` only — source: ADR-0004

### Forbidden APIs (Godot 4.7.2)
Filtered for this project (2D UI game, no physics, animation trees, navigation or 3D):
- `yield()` → use `await signal` — since 4.0
- `connect("signal", obj, "method")` / string-based `connect()` → `signal.connect(callable)` — since 4.0
- `instance()` / `PackedScene.instance()` → `instantiate()` — since 4.0
- `OS.get_ticks_msec()` → `Time.get_ticks_msec()` — since 4.0 (and only inside `RealClock`, ADR-0006)
- `duplicate()` for nested resources → `duplicate_deep()` — since 4.5
- `$NodePath` in `_process()` → cached `@onready var`
- Untyped `Array` / `Dictionary` where a type is known → `Array[Type]`, typed variables
- `DisplayServer.AccessibilityLiveMode` → `AccessibilityServer.AccessibilityLiveMode` — 4.7
- `RichTextLabel.UPDATE_WIDTH_IN_PERCENT`, `width_in_percent` / `height_in_percent` → `UPDATE_WIDTH_UNIT`, `width_unit` / `height_unit` — 4.7
- Source: `docs/engine-reference/godot/deprecated-apis.md`, `breaking-changes.md`
- Unresolved for this project: 3D, physics, animation and navigation rows of that file are omitted as not applicable.

### Cross-Cutting Constraints
- **Overrides of typed engine virtuals must return on every path** (4.7) — source: ADR-0006, `current-best-practices.md`
- **Do not compare `event.device` to `0`; use `InputEvent.DEVICE_ID_MOUSE` / `DEVICE_ID_KEYBOARD` or branch on event type** (4.7) — source: `current-best-practices.md`
- **Lambdas capture locals by value; share state through a Dictionary / Array / object** — source: `current-best-practices.md`
- **`@abstract` for interface base classes (e.g. `Clock`); abstract methods have no body** (4.5) — source: ADR-0006, `current-best-practices.md`
- **Check the `bool` result of every `FileAccess.store_*` call** (4.4) and `get_error()` after writes — source: ADR-0004, `breaking-changes.md`
- **Every gameplay value comes from `GameConfig`; every player-facing string from `StringTable`** — source: ADR-0007, coding standards, architecture.md Principle 4
- **Grapheme counts in an exported build depend on ICU data (`internationalization/locale/include_text_server_data`, decided by ADR-0005); run the combining-mark and ZWJ-emoji cases at the first export** — source: ADR-0007 (Risks)
- **Doc comments on every public API; public methods unit-testable via injection** — source: `.claude/docs/coding-standards.md`
- **Tests: run `godot --headless --path . --import` before the gdUnit4 command; exit 0 pass, 100 fail, 101 orphan leak; "No test cases found" is not a pass** — source: `tests/README.md`, `current-best-practices.md`
- **Re-run SB-07/SB-08/SB-18/SB-19 on every godot-sqlite upgrade** — source: ADR-0001, ADR-0002
- **Anything NOT SOURCEABLE in `docs/engine-reference/godot/` (threading APIs after 4.3, `CodeEdit` changes 4.4–4.7, `Thread.PRIORITY_LOW`, AccessKit + `CodeEdit`, signal connection call order, IME composition events) must be probed before a story relies on it** — source: architecture.md, ADR-0001, ADR-0010
