# ADR-0004: Event Bus and Playtest Log

## Status
Accepted

## Date
2026-10-15

## Last Verified
2026-10-15

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
Eight MVP systems must report events to the Playtest Log with one canonical
catalogue, without gameplay ever depending on the log, and the log must be on
only in playtest builds. A Foundation `EventBus` validates every event against
a declared catalogue and stamps common fields; a `PlaytestRecorder` subscribes
and appends JSON Lines with a flush per event; the build flavour (dev /
playtest / release) comes from export-preset feature tags; the offline report
tool is a stdlib-only Python script.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core (events, file I/O), Input (F9), UI (setup prompt, corner label) |
| **Knowledge Risk** | MEDIUM — `FileAccess.store_*` return `bool` since 4.4 (the writer depends on it); input focus is dual since 4.6 (F9 note field returns keyboard focus); rest pre-4.3 |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (4.4 `FileAccess.store_*` → `bool`; 4.7 input device IDs), `deprecated-apis.md`, `current-best-practices.md`, `modules/input.md`, `modules/ui.md` (4.6 dual focus); ADR-0001…0003 |
| **Post-Cutoff APIs Used** | `FileAccess.store_line` / `store_string` returning `bool` (4.4). Dual-focus behaviour of `grab_focus()` (4.6: keyboard focus only) |
| **Verification Required** | (0) godot-specialist probes 2026-10-15 on 4.7.2 / Linux: kill -9 after 5 flushed lines left all 5 on disk; on a write error (`ulimit -f`) `store_line` returned `true` while `get_error()` was non-`OK`; making the folder or file read-only after `open` did **not** break the open handle; `open` in a read-only folder fails (error 12); `OS.has_feature("editor")` is true in editor runs, false in exported debug builds. (1) PL-07 on Windows. (2) PL-08 must inject a failing writer (permission flips after `open` do not fail an open handle on Linux). (3) Custom feature tags from an export preset are visible to `OS.has_feature()` in the exported build (pre-4.3 behaviour; confirm at the first export, ADR-0005) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0003 (`content_hash` on every event). ADR-0006 (composition root) is assumed for wiring but not required to accept this ADR |
| **Enables** | Every system story that emits a declared event; puzzle load states that depend on the build flavour (ADR-0003); the zero-SQL playtest |
| **Blocks** | Playtest Log epic; `tools/playtest-report`; any story whose AC asserts a log event |
| **Ordering Note** | Export presets with the `playtest` feature tag are created with ADR-0005 |

## Context

### Problem Statement
`playtest-log.md` defines a canonical event catalogue (rule 4) that eight GDDs
cite, a JSON Lines file per session written with a flush per event (rules 3, 8,
9), a playtest flag that is off in release builds (rule 1), an F9 facilitator
key (rule 7) and an offline report tool (rule 10). Its Open Question 1 leaves
the file format and writer technology to an ADR. Separately, Puzzle Definition
needs the same build flavour to decide which content is `withheld` (dev builds
allow drafts; playtest and release builds do not). Architecture Principle 5
says events record and signals control: gameplay must work identically with
the recorder off.

### Constraints
- Undeclared events are rejected and counted, and the count is written at
  `session_end` (`undeclared_events`, PL-04).
- Hidden-dataset details appear only in this file (grader rule 11).
- No network, no OS user name, hostname or paths (rule 5, PL-05, PL-09).
- A write failure never affects gameplay (rule 8, PL-08).
- `t_ms` is monotonic; `wall` is ISO time (rule 3, PL-03).

## Decision

### 1. Build flavour
`BuildFlavour` (Foundation) resolves once at boot:
- `release` — exported build with neither tag;
- `playtest` — exported build with the custom feature tag `playtest`;
- `dev` — running from the editor (`OS.has_feature("editor")`) or an export with the `dev` tag.

Read with `OS.has_feature()`. Precedence: `editor` → `dev`; else `dev` tag →
`dev` (a build carrying both `dev` and `playtest` is a preset error — `dev`
wins and a warning is printed); else `playtest` tag → `playtest`; else
`release`. Exported debug templates do **not** report `editor` (probed), so an
exported dev build needs the custom `dev` tag. Puzzle load states (ADR-0003) and the recorder
both read `BuildFlavour`; nothing else checks feature tags directly.

### 2. EventBus — validate, stamp, dispatch
```gdscript
class_name EventCatalog extends RefCounted
## name -> {required: {field: TYPE_*}, optional: {field: TYPE_*}}; mirrors playtest-log.md rule 4 exactly.
const EVENTS := { &"run": {"required": {...}, "optional": {"build_message": TYPE_STRING}}, ... }

class_name EventBus extends Node
signal event_recorded(record: Dictionary)
func emit_event(event_name: StringName, puzzle_id: Variant, data: Dictionary) -> void
func undeclared_count() -> int
```
(The parameter is `event_name`, not `name`: `EventBus` is a `Node`, and `name`
would shadow `Node.name` — SHADOWED_VARIABLE_BASE_CLASS.)
`emit_event`:
1. If `name` is not in the catalogue, or `data` lacks a required field, has an
   undeclared field, or a field has the wrong type → **not dispatched**;
   `undeclared_events` += 1 (dev builds also push a warning naming the event).
2. Builds the record `{t_ms, wall, session, build, event, puzzle, content_hash, data}`:
   `t_ms` from the injectable `Clock` (monotonic, since session start); `wall`
   from `Clock.wall_iso()` (UTC ISO 8601, ADR-0006); `content_hash` from `PuzzleRepository`
   when `puzzle_id` is set, else `null`.
3. Emits `event_recorded(record)`.

The catalogue is the **only** place event names and fields are declared; a
system that adds an event edits its GDD, `playtest-log.md` rule 4 and
`EventCatalog` together. Gameplay systems never subscribe to `event_recorded`;
they talk through their own typed signals (Hint ← verdict, Progression ← PASS,
Workbench ← Restart).

**One exception — a value the grader needs back (`hint_counted`).** Hint rule
4b requires the grader to receive `hint_counted` for each submit before it
emits the `submit` event, and a signal cannot return a value. The grader
therefore takes a narrow injected `hint_counter: Callable` —
`func(verdict: Verdict, sql: String) -> bool` — in its `_init`, bound by
`ServicesFactory` to the Hint System (ADR-0006). The grader depends on the
callable's shape, not on the Hint type (no Core → Feature dependency). This is
the pattern for any future synchronous answer between systems; one-way
notifications stay signals.

### 3. PlaytestRecorder — append + flush per event
Created only when `BuildFlavour == playtest` (or dev with a debug toggle).
States: `AwaitingSetup → Recording → Ended`, or `Recording → Stopped`.
- Setup prompt (tester id, group, consent note) before the first request opens;
  a blank id becomes `anonymous-<4 hex>`, group `other`.
- File: `user://playtest-logs/<session>.jsonl`, `session` = UTC
  `YYYYMMDD-HHMMSS-<4 hex>`. The folder is created with
  `DirAccess.make_dir_recursive_absolute()`, then the file is opened once with
  `FileAccess.WRITE`. **If `open` returns `null`** (`FileAccess.get_open_error()`
  ≠ `OK`, e.g. a read-only folder), the recorder goes straight to `Stopped` and
  shows "Recording stopped"; gameplay starts normally.
- Per event: `store_line(JSON.stringify(record))`, then `flush()`, then check
  **`get_error()`** — the authoritative failure signal (probed on 4.7.2: on a
  write error `store_line` still returned `true` while `get_error()` was
  non-`OK`); a `false` return is also treated as failure. On failure: close the
  file, go to `Stopped`, show "Recording stopped"; never retry, never raise.
- `session_end` is written **only when the game quits** (`playtest-log.md`
  States: `Ended` on quit) — never at chapter end, because play continues after
  `chapter_complete` (replays, reopened skipped requests, challenge clears —
  CC r.6b). It carries `{undeclared_events: EventBus.undeclared_count()}` and
  closes the file. Both quit paths call it once: the window close
  (`NOTIFICATION_WM_CLOSE_REQUEST`) and every code-initiated quit, which goes
  through one `Main.quit_game()` that ends the session before
  `get_tree().quit()` (a code quit sends no close request). Crashes and
  SIGTERM leave no `session_end`; the report tool flags those (PL-15).
- Corner label "● Recording playtest" / "Recording stopped" on a top
  `CanvasLayer`, positioned clear of the editor and tables (ink, not red).

Writing happens on the main thread: events arrive at human speed (a few per
second at most; `edit_burst` is coalesced by the Workbench), and one line plus
`flush()` is far below a frame. If PL-08's frame check fails on the target PC,
move the writer to a dedicated thread with a queue (same file format).

### 4. F9 facilitator key
The recorder's `CanvasLayer` handles F9 in `_input()` (before GUI, so it works
while `CodeEdit` has focus), consumes the event, emits `help_given` at once with
the current puzzle (or `null`), and opens a one-line note field. Enter, Esc or
5 s without a key closes it, writes a non-empty note as a separate
`help_note {note}` event (user decision 2026-10-15; `playtest-log.md` rule 7
updated), and calls `grab_focus()` on the editor —
keyboard focus only, which is what is needed (4.6 dual focus). F9 must be
checked by key event type (`InputEventKey`, `keycode == KEY_F9`,
`pressed and not echo`), never by `event.device` (4.7 device-ID change), and
consumed with `get_viewport().set_input_as_handled()`. F9 is ignored while the
note field is open. Focus returns with a deferred `grab_focus()` on the editor
after the note field is hidden.

### 5. Report tool
`tools/playtest-report/playtest_report.py`, Python 3, **standard library only**,
run as `python3 tools/playtest-report/playtest_report.py <folder>`, prints
Markdown. Its tests (PL-11…16) use `unittest` with fixture JSONL files in
`tools/playtest-report/fixtures/`. Values the report needs from the game's
tuning (e.g. `idle_cutoff_s` for `puzzle_active_time`, `playtest-log.md`
Formulas) are read from the same config data file the game reads
(`GameConfig`, ADR-0007), passed with `--config <file>` (default: the repo's
file); the log format is unchanged. Rationale: it is an offline analysis tool
over a text format, not a correctness gate on content (so ADR-0003's "one
SQLite, one verdict" principle does not apply), and Python is faster to write
and run outside the engine.

### Architecture Diagram

```
 Grader, Workbench, Hint, Progression, Challenges, Manual, Onboarding, Dialogue
        │ emit_event(event_name, puzzle_id, data)
        ▼
 EventBus ── catalogue check ──✗──► undeclared_events += 1
        │ ✓ stamp {t_ms (Clock), wall, session, build, puzzle, content_hash (PuzzleRepository)}
        ▼ event_recorded(record)
 PlaytestRecorder (playtest builds only)
        │ store_line + flush per event; false → Stopped
        ▼
 user://playtest-logs/<session>.jsonl ──(copied by hand)──► tools/playtest-report (Python)

 Gameplay control flows through typed signals between systems — never through event_recorded.
```

### Key Interfaces
See §2 (`EventBus.emit_event`, `event_recorded`, `undeclared_count`) and §1
(`BuildFlavour.current() -> StringName`).

### Implementation Guidelines
- Every system must emit log events only through `EventBus.emit_event`, with names and fields exactly as `playtest-log.md` rule 4; must never write to the log file directly.
- Must never subscribe gameplay logic to `event_recorded`; gameplay must behave identically with the recorder absent.
- Must check the `bool` result of every `FileAccess.store_*` call (4.4) and `get_error()`; a failure stops the recorder and never reaches gameplay.
- Must call `flush()` after every line and check `get_error()` after it; must handle `open` failure at session start (→ `Stopped`).
- Must write through a small `LogSink` interface (real `FileAccess` sink in builds, failing/in-memory sink in tests).
- Must never record OS user name, hostname, paths or anything typed outside the editor, setup prompt and F9 note.
- Hidden-dataset details (`per_dataset`, `missing_count`, `extra_count`) may only appear in `submit` event data; no UI may read them from the bus.
- Must not check feature tags outside `BuildFlavour`.
- Release export presets must not carry the `playtest` or `dev` tag.
- Must handle F9 by key type and keycode in `_input`, never by `event.device`.
- `t_ms` must come from the injectable `Clock` so PL-03 runs with a fake clock.

## Alternatives Considered

### Alternative 1: Each system writes to the log itself (no bus)
- **Description**: Systems call a `PlaytestLog.write()` singleton directly.
- **Pros**: Fewer moving parts.
- **Cons**: Catalogue validation and stamping spread across eight systems; a singleton reference everywhere (against the DI standard); gameplay code depends on the logger existing.
- **Rejection Reason**: The bus centralises validation and keeps the logger optional.

### Alternative 2: One bus for both gameplay control and logging
- **Description**: Systems react to each other through `event_recorded`.
- **Pros**: One mechanism.
- **Cons**: Gameplay would depend on catalogue validation and on payload shapes chosen for analysis; turning the log off could change behaviour.
- **Rejection Reason**: Principle 5 — events record, signals control.

### Alternative 3: Writer on a background thread from the start
- **Description**: Queue events to a writer thread.
- **Pros**: Zero file I/O on the main thread.
- **Cons**: More code; harder crash guarantee (queued lines lost on kill, against PL-07).
- **Rejection Reason**: Event rate is human-scale; kept as the fallback if PL-08 shows a frame cost.

### Alternative 4: Report tool in GDScript (headless)
- **Description**: Run the report with `godot --headless -s`.
- **Pros**: One language.
- **Cons**: Slower to iterate, needs the engine to read text files; no correctness reason to share engine code.
- **Rejection Reason**: Python stdlib is simpler for offline analysis.

## Consequences

### Positive
- One catalogue enforced in one place; undeclared names are counted, not written (PL-04).
- Release builds have no recorder object at all, so PL-01 holds by construction.
- The same `BuildFlavour` drives content withholding and logging.

### Negative
- Catalogue changes touch three places (a GDD, `playtest-log.md`, `EventCatalog`).
- A second language (Python) in `tools/`, with its own tests.

## Risks
- **Catalogue drift** between `playtest-log.md` and `EventCatalog`. Mitigation: a unit test that compares the code catalogue with the GDD table (parsed from rule 4) — or, at minimum, a test per event asserting its required fields.
- **Write-failure signal**: the `bool` from `store_line` is not reliable (probed); `get_error()` after each write is. Mitigation: check both; PL-08 uses an injected failing writer behind a small `LogSink` seam, since a real read-only flip after `open` does not fail on Linux. Real ENOSPC and Windows behaviour are not probed.
- **Missing `session_end`** after a crash or forced quit. Mitigation: the report tool already treats it as "crashed" (PL-15).
- **Main-thread flush cost** on a slow disk. Mitigation: PL-08 frame check; fallback per Alternative 3.

*Engine validation (godot-specialist, 2026-10-15, probed on 4.7.2 / Linux): one BLOCKING gap — no path for `open` failing at session start — resolved in §3; minor notes (get_error as the real failure signal, PL-08 needs an injected writer, flavour precedence, F9 echo / handled / ignore-while-open, deferred focus return, make_dir, quit hook) folded in. TD-ADR skipped — lean mode.*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| playtest-log.md | Rule 1 / PL-01: on only with the playtest flag; release writes nothing | `BuildFlavour` from feature tags; recorder created only in playtest (§1, §3) |
| playtest-log.md | Rule 3 / PL-03: common fields, monotonic `t_ms` | EventBus stamping with `Clock` (§2) |
| playtest-log.md | Rule 4 / PL-04: canonical catalogue; undeclared rejected and counted | `EventCatalog` + validation; `session_end.undeclared_events` (§2–3) |
| playtest-log.md | Rules 5–6 / PL-05, PL-06, PL-09: verbatim SQL, no system info, hidden details log-only, no network | Guidelines; recorder writes only the JSONL file |
| playtest-log.md | Rule 7 / PL-10: F9 help marker, focus returns to editor | §4 |
| playtest-log.md | Rules 8–9 / PL-07, PL-08: append + flush per event, failure stops the log only | §3 |
| playtest-log.md | Rule 10 / PL-11…16: report tool | §5 |
| playtest-log.md | Open Question 1 (file format and writer) | Resolved: JSONL via `FileAccess`, flush per event, main thread |
| puzzle-definition-and-datasets.md | Runtime load state by build (dev / playtest / release) | `BuildFlavour` (§1) |
| hidden-data-grader.md | Rule 11: hidden details only in the developer-facing log | Only the `submit` event carries them |
| hint-system.md / hidden-data-grader.md | Hint rule 4b: grader receives `hint_counted` before emitting `submit` | Injected `hint_counter: Callable` (§2 exception) |
| playtest-log.md | States: session ends on quit only; Formulas `idle_cutoff_s` in the report | §3 quit paths; §5 `--config` |

## Performance Implications
- **CPU**: validation + one `JSON.stringify` per event; negligible at human event rates.
- **Memory**: none beyond one open file handle.
- **Load Time**: none (release); a setup prompt in playtest builds.
- **Network**: none.

## Migration Plan
No production code exists.

## Validation Criteria
- PL-01…PL-10 and PL-17 pass (gdUnit4 integration tests with a fake clock where noted).
- PL-11…PL-16 pass as Python `unittest` cases on fixtures.
- A catalogue test fails if a GDD-declared event is missing from `EventCatalog`.

## Related
- ADR-0003 — `content_hash`, build-dependent `withheld`
- ADR-0005 (planned) — export presets with feature tags
- ADR-0006 (planned) — composition root wiring `EventBus`, `Clock`, `BuildFlavour`
- `design/gdd/playtest-log.md` and every GDD that declares events
