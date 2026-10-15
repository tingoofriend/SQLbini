<!-- PROTOTYPE - NOT FOR PRODUCTION -->
# Spike: sandbox timeout without an interrupt API (ADR-0001)

**Hypothesis.** A sandbox execution can be time-limited on Godot 4.7.2 +
godot-sqlite v4.9 (no interrupt / progress-handler API) so that the caller gets
`TIMEOUT` within `exec_time_limit` + 50 ms and the frame never blocks
(`sql-execution-sandbox.md` rule 15, SB-18, SB-19).

**Status:** concluded 2026-10-15 (Linux, i7-1360P laptop, 16 logical cores).

## How to run

```
godot --headless --path . --import            # once
godot --headless --path . -s res://thread_probe.gd
godot --headless --path . -s res://quit_probe.gd -- quit
godot --headless --path . -s res://quit_probe.gd -- sort
godot --headless --path . -s res://process_probe.gd
```

Fixture: 24-row `products`; long query = 6-way self-join `COUNT(*)` (24⁶ ≈ 191M
combinations); `limit` = 100 ms (the GDD default).

## Findings

| Question | Option | Result |
|---|---|---|
| One `SQLite` object per worker thread works? | (a) thread | **Yes** — 8 concurrent threads, each with its own in-memory DB, all correct (short query: 2 cols, 4 rows) |
| TIMEOUT latency | (a) thread | Detected at **104 ms** (limit + 4 ms, frame polling) |
| Frame impact | (a) thread | Max frame gap **7.1 ms** with 7 abandoned threads burning |
| Short queries while threads are abandoned | (a) thread | Unaffected: p95 7.0 ms with 1 or 7 abandoned (≈ frame polling; the execution itself is < 1 ms) |
| Life of an abandoned query | (a) thread | 6-way join finishes in **1.4–2.0 s**; an 8-way join would run ≈ 576× longer (minutes) and keep one core busy |
| Quit while a worker is inside SQLite | (a) thread | Process exits in **0.4 s**, exit 0, warnings only ("Thread object destroyed without completion", 1 leaked ObjectDB) |
| Memory of an abandoned `ORDER BY` over 8M rows | (a) thread | Finishes in 6.1 s; max RSS **113 MB** (baseline ≈ 106 MB) — SQLite's sorter does not balloon |
| Helper process start | (b) process | **147 ms** to READY (headless Godot + godot-sqlite) |
| Round trip, short query | (b) process | p50 **0.50 ms**, p95 0.69 ms (stdin/stdout lines, 100 µs polling) |
| TIMEOUT + kill + respawn | (b) process | TIMEOUT at 100.0 ms; `OS.kill` 3.8 ms; respawn 144 ms → next request can wait up to ≈ 150 ms |
| Value types over the pipe | (b) process | JSON turns integers into floats (`cols=2.0`); TEXT/number survive, but int64 > 2⁵³ and BLOB need a typed encoding (e.g. `var_to_bytes`) |
| Step cap / `sqlite3_interrupt` | (c) fork | **Not probed** — needs a godot-sqlite fork (godot-cpp + SCons, Linux + Windows builds) |

## Observations for the ADR (not a verdict)

- (a) meets SB-18 and SB-19 as measured. Its cost: an abandoned query keeps a
  core busy until SQLite finishes, which for a many-way join can be minutes.
- (b) makes TIMEOUT a clean kill, at the cost of a second ≈ 100 MB process, a
  typed IPC encoding, a ≈ 150 ms respawn after each TIMEOUT, and two unverified
  points: running the exported game binary with `-s` as its own helper, and
  `OS.execute_with_pipe` behaviour on Windows (NOT SOURCEABLE in
  `docs/engine-reference/godot/` — only its 4.4 `blocking` parameter is recorded).
- (a) and (c) compose: with a fork exposing `sqlite3_interrupt` (thread-safe in
  SQLite), the main thread could interrupt the worker instead of abandoning it,
  with no change to the sandbox API.
- Engine notes observed on 4.7.2: `Thread`, `Thread.is_alive`, `wait_to_finish`,
  `OS.execute_with_pipe(path, args, false)`, `FileAccess.get_buffer` on the pipe,
  `OS.kill`, `OS.read_string_from_stdin()` (no argument) all worked as used here.
  The `MainLoop._process` override returns `bool` explicitly (4.7 typed-return rule).
- `godot --headless --path . --import` aborted (core dump) on the first run in this
  folder and did not affect the probes; not investigated.
