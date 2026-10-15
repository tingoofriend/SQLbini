# Architecture Review Report

Date: 2026-10-15 (session 9, fresh session — not the authoring session)
Mode: full (workflow `standard`: architecture doc + critical ADRs)
Engine: Godot 4.7.2 + godot-sqlite v4.9
GDDs Reviewed: 11 MVP GDDs (+ `systems-index.md`, `game-concept.md`)
ADRs Reviewed: 5 — ADR-0001, 0002, 0003, 0004, 0006 (all **Proposed**); ADR-0005 does not exist yet (written after the Windows spike)
Inputs: `docs/architecture/architecture.md` v1; GDD sweep (general-purpose agent); engine consultation (godot-specialist, probes on 4.7.2 headless)

Reviewed-Content-Hash: docs/architecture/adr-0001-sandbox-execution-and-timeout.md 5eb7fded9bc049bb94fc2ba873ea302971c49772
Reviewed-Content-Hash: docs/architecture/adr-0002-sandbox-api-and-lexer-contract.md de233cba2b71aed6302fb2a70a3bcd715deead0b
Reviewed-Content-Hash: docs/architecture/adr-0003-puzzle-data-format-loader-and-verifier.md c29958ad06ec3a4c62f4da754be9671a54164d04
Reviewed-Content-Hash: docs/architecture/adr-0004-event-bus-and-playtest-log.md 2668c861e4822b04a1d9a7a6b89ed20a20f818eb
Reviewed-Content-Hash: docs/architecture/adr-0006-composition-root-and-service-wiring.md 82079ec0cc1308f4954a89e335065dc89dd1830c
Reviewed-Content-Hash: design/gdd/constraint-challenges.md 08aaf80ef9f7f6e505b5948f94234510431dcbd7
Reviewed-Content-Hash: design/gdd/game-concept.md fcc25438d2f80d0e301bee354565231148c8513a
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-10-14.md b945695f1fca955e9984269fd1b88a66e001171a
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-10-15.md 9d62946c0c9b4a8fc3d6e8de8541bd411831e4b7
Reviewed-Content-Hash: design/gdd/hidden-data-grader.md b0c7b45ab1352f9209ad68b112050dcbee2310ac
Reviewed-Content-Hash: design/gdd/hint-system.md 1a7bcad9e91074684e307f479836c8153e56b2fb
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md a69550704a2835d3e2f9656237cacfe46c58315f
Reviewed-Content-Hash: design/gdd/playtest-log.md 2f1c452da227d683b587ab7df2e58e41d17ef0f8
Reviewed-Content-Hash: design/gdd/puzzle-definition-and-datasets.md 27907b1056dea6db142c2576ec84f592a7d14faf
Reviewed-Content-Hash: design/gdd/query-workbench.md c274c881dd9e8f46d04b3644aeaae6e122cfe9ec
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md c54ef902635ee876e6c4f620ceec549ccf55057f
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md 6a2fa711796367133fe6817422aab051ca220dac
Reviewed-Content-Hash: design/gdd/sql-execution-sandbox.md 378913e2aee9fd6c9d7369ae8a5df2bfcbcf49ac
Reviewed-Content-Hash: design/gdd/store-manual.md 9e4063a0ea449c2756df0abcad0f6144e2b4858f
Reviewed-Content-Hash: design/gdd/systems-index.md 1e0f24f9f194db1d3ac90df901c1d1714bcc4b84

---

## Traceability Summary

Total requirements: **60** (44 provisional from `architecture.md` v1 kept with their IDs + 16 new from this review)

| Status | Count |
|---|---|
| ✅ Covered (Accepted ADR) | 0 |
| 🟡 Covered (Proposed ADR) | 28 |
| ⚠️ Partial | 9 |
| ❌ Gap | 20 |
| ➖ No ADR needed (pure logic, GDD formula is the spec) | 2 |
| ⏸ Deferred (VS Save/Load) | 1 |

Gaps by owner:
- **ADR-0005 (pending Windows spike)** — TR-sandbox-009, TR-grader-005, TR-platform-001, TR-platform-002, TR-playtest-007, and with ADR-0008 TR-workbench-004. Marked as a deliberate gap: ADR-0005 waits for the Windows godot-sqlite `.dll` spike (user decision, session 8).
- **ADR-0007 (planned)** — TR-config-001, TR-dialogue-001, TR-dialogue-005, TR-onboarding-002, with ADR-0008 TR-dialogue-004.
- **ADR-0008 (planned)** — TR-workbench-001, -002, -003, -007, TR-onboarding-003.
- **ADR-0009 (planned)** — TR-dialogue-003.
- **No ADR planned** — TR-hint-003, TR-dialogue-006, TR-playtest-006 → see Required ADRs (new ADR-0010, ADR-0004/0006 amendments).

Citation corrections applied to the provisional rows (registry `source` field): TR-workbench-002 (focus ring = UI Req 4 / QW-20), TR-progression-001 (session-only = r.13), TR-dialogue-002 (reduced motion = r.5), TR-platform-001 (concept says PC/Steam; Windows + Linux from sandbox OQ4 / prefs), TR-challenge-001 (`max_chars` is Alpha, MVP = forbid/require).

## Traceability Matrix

See `docs/architecture/requirements-traceability.md` (same table).

---

## Cross-ADR Conflicts

### 🔴 C1 — ADR-0003 vs ADR-0006: ContentVerifier ownership cycle and layer inversion (BLOCKING)
Type: State / Dependency
- ADR-0003 §4 + Key Interfaces: `PuzzleRepository.verify_all()` (Foundation) runs `puzzle_valid` with the real `HiddenDataGrader` (Core) and `SqlSandbox`.
- ADR-0006 §3: `HiddenDataGrader.new(sandbox, puzzles, bus)`; one-way ownership — "no mutual RefCounted references" (probed leak). Its diagram never injects the sandbox into the repository.
- Impact: if the repository holds the grader, repository ↔ grader is a RefCounted cycle that leaks; Foundation depends on Core; the grader reads a reference cache that `verify_all` is still filling.
- Resolution (recommended): `ContentVerifier` becomes its own object built by `ServicesFactory` with `(repo, sandbox, grader)`; it pushes load states and the reference cache into the repository through setters; the repository holds nothing upstream. State how cause selection gets references during verification (verifier computes reference results first, then traps). Edits: ADR-0003 §4 / Key Interfaces / diagram; ADR-0006 §2 diagram + boot order; `architecture.md` boot order and Module Ownership.

### 🔴 C2 — ADR-0001 vs ADR-0003 / ADR-0006: per-frame delivery breaks the boot-time claim (BLOCKING)
Type: Performance
- ADR-0001 §3: every result is delivered from the runner's next `_process` poll → a sequential `await execute()` costs ≥ 1 frame regardless of the 0.4 ms SQL time.
- ADR-0003 Performance/Consequences and ADR-0006 Performance: "≈ 200 sequential executions ≈ 0.1 s at boot".
- Reality (godot-specialist): ≈ 200 frames ≈ **3.3 s** at 60 Hz vsync (≈ 13 s at ~50 puzzles); headless CI ≈ 6.6 ms/frame ≈ 1.3 s. Grader submit pays 2 + D frames (≈ 83 ms at D = 3, 60 fps; double at 30 fps).
- Resolution (recommended): the verifier keeps N requests in flight (ADR-0002 §6 already allows concurrency; cap N ≈ 4–8 threads) and the numbers are corrected in ADR-0003/0006. Alternative: a batch call (several statements per worker) — changes ADR-0002's API, so it would have to be decided before the Sandbox epic. Add to ADR-0001: "delivery = limit + one frame".

### 🟠 C3 — ADR-0002 §6 vs `query-workbench.md` (States, Edge Cases, QW-12/16): Run supersede
Type: Integration contract (GDD ↔ ADR)
- ADR-0002 §6 (+ `architecture.md` Submit flow): "Callers keep at most one request in flight per workbench".
- Workbench GDD: "A second Run while one is in flight replaces it (the older result is discarded)".
- Resolution (recommended, ADR side — GDD unchanged): the controller tags each Run with a sequence number, may start a newer Run while an older one is still running, and discards any result that is not the newest; Submit stays exclusive. Requires **N1** (one awaitable per request).

### 🟠 C4 — ADR-0004 typed signals vs `hint-system.md` r.4b: `hint_counted` return
Type: Integration contract
- `architecture.md` / ADR-0004 §2: "Hint ← verdict" travels by typed signal.
- Hint r.4b + grader Interactions: the grader gets `hint_counted` back synchronously and writes it into the `submit` event. A signal cannot return a value.
- Resolution (recommended): the grader receives a narrow injected `Callable` (`hint_counter(verdict, sql) -> bool`) from the composition root, so it does not depend on the Hint type (no layer inversion). Record in ADR-0004 §2 (exception to "signals control") or in ADR-0010.

### 🟡 C5 — ADR-0001 guideline vs ADR-0006 §5: time source (ADVISORY)
ADR-0001: "measure elapsed time with `Time.get_ticks_usec()`" vs ADR-0006: "`Time.*` only inside `RealClock`" (ADR-0001's own next bullet says the clock is injectable). Fix: ADR-0001 → "elapsed from `Clock.now_ms()`".

### 🟡 C6 — ADR-0004 §3 vs `playtest-log.md` States: `session_end` at chapter end
ADR-0004 closes the file "on `NOTIFICATION_WM_CLOSE_REQUEST` **or chapter end**"; the GDD ends the session on quit only, and play continues after `chapter_complete` (replays, skipped requests, challenge clears — CC r.6b). Fix ADR-0004: drop "or chapter end"; also hook code-initiated quits (`get_tree().quit()` sends no close request — engine N4).

### 🟡 C7 — ADR-0006 §5 vs `hint-system.md` Formulas: per-frame `dt`
ADR-0006: "per-frame `delta` may drive animation only, never a rule". Hint `active_time = Σ(frames) dt …` with dt clamped 0–0.25 s, "not paused"; HS-04 asserts a single 2 s frame adds 0.25. `FakeClock.advance()` has no frame notion and `Clock` has no pause. Fix ADR-0006: rule-time is accumulated per tick from `Clock.now_ms()` deltas, clamped by the rule; `FakeClock.advance(ms)` = one tick; pause comes from Progression/Challenges state, not `Clock`. GDD "frame dt" wording becomes a recommendation only.

## ADR Dependency Order

`adr-dep-graph.sh`: 5 ADRs, no `CYCLE`, no `NO_DEPS_SECTION`. One edge is a parse artefact: `adr-0006 -> adr-0001` comes from the prose "None (wires ADR-0001…0004…)"; ADR-0006 declares no dependency. ADR-0004 → ADR-0006 is soft ("assumed for wiring, not required to accept"), but ADR-0004 uses `Clock.wall_iso()` from ADR-0006.

Recommended implementation order:
1. ADR-0001 Sandbox execution and timeout (Foundation, no deps)
2. ADR-0006 Composition root and service wiring (no hard deps)
3. ADR-0002 Sandbox API and lexer (requires ADR-0001)
4. ADR-0003 Puzzle format, loader and verifier (requires ADR-0002)
5. ADR-0004 Event bus and playtest log (requires ADR-0003; soft ADR-0006)
6. ADR-0005 Platform baseline — **pending** (Windows spike); referenced by ADR-0001/0003/0004 verification items

⚠️ All five are Proposed: every downstream ADR is unsafe to implement until its parents are Accepted.

## GDD Revision Flags (Architecture → Design)

No engine-driven flag sets a GDD to Needs Revision. One substantive GDD discrepancy is held for the developer (per session rule, GDDs are not edited directly):

| GDD | Assumption | Reality | Proposed action |
|---|---|---|---|
| sql-execution-sandbox.md Formulas (worst case), mirrored in ADR-0001 GDD table | Hidden TIMEOUT worst case ≈ 3 × 25 + 100 = 175 ms (first hidden set times out) | Timeout can hit the *last* hidden set, and each execution adds ≈ one frame of delivery: D = 3 → ≈ 277 ms; D ≥ 5 → ≈ 327 ms > 300 ms (Submit budget, grader AC-26) | Ask the developer (see session summary). ADR-0001's "≈ 175 ms" is corrected in the ADR regardless |

Wording-only recommendations (GDD not edited) are listed in `production/session-state/active.md` notes.

## Engine Compatibility Issues

Engine: Godot 4.7.2 · ADRs with Engine Compatibility section: 5 / 5 · Deprecated API references: none · Stale version references: none.

Post-cutoff APIs used: `FileAccess.store_*` → `bool` (4.4, ADR-0004), dual focus `grab_focus()` (4.6, ADR-0004), `@abstract` (4.5, ADR-0006). No two ADRs assume different behaviour of the same API.

### Engine Specialist Findings (godot-specialist, 2026-10-15)
- **A1 (advisory)** ADR-0006 "Post-Cutoff APIs Used: None" is wrong — `@abstract` (4.5) is used; probed OK on 4.7.2 (RefCounted + typed abstract method).
- **A2 = C2 (blocking)**, **A4 = C1 (blocking)**, **A3 = C5**.
- **A5 (advisory)** ADR-0001 runner and `FocusListener` must set `process_mode = PROCESS_MODE_ALWAYS` (probed: a paused tree stops `_process`, so TIMEOUT would never fire and awaits would hang). Detection is "limit + one frame": beyond limit + 50 ms below ≈ 20 fps or during a main-thread stall. Minimized/hidden-window throttling NOT SOURCEABLE.
- **N1 (advisory)** ADR-0002 §4: `execute` must await a per-request awaitable (e.g. a small RefCounted with `done(result)`), not one shared runner signal — concurrent requests would all resume on the first emission.
- **N2 (advisory)** ADR-0004: `EventBus extends Node` with `emit_event(name: …)` shadows `Node.name` (SHADOWED_VARIABLE_BASE_CLASS) → rename `event_name`.
- **N3 (advisory)** ADR-0003 diagram says `JSON.parse_string`; §2 (correctly) uses `JSON.new().parse()` for `get_error_line()`.
- **N4 (advisory)** ADR-0004: `session_end` must also run on code-initiated quit (no close-request notification).
- **N5 (advisory)** ADR-0006: scope the "no `Time.*` outside RealClock" grep to `src/` minus `real_clock.gd`.
- Checked, no issue: F9 in `_input` (before GUI — correct), `JSON.stringify` argument order and recursive key sort, `sha256_text`, custom feature tags (deferred to ADR-0005), direct return from `execute` for rejected requests, thread rules, freed-caller `await` never resumes (probed).

## Other ADR Findings (from the GDD sweep)

- ADR-0003: non-puzzle checks (SM-15 every example × every puzzle, HS-13) add ≈ 400–700 executions not counted in the boot estimate, the runtime effect of a failed manual/hint/ghost-text check is undefined, and ghost text lives in string tables (ADR-0007). Recommended: run non-puzzle checks in CI only; at load, only `puzzle_valid` + hash.
- ADR-0003: the ordered puzzle-id list in `chapter.json` must be checked against each puzzle's `order` (chapter checks do not list it).
- ADR-0002 §5: state that SQLite extension loading stays disabled (TR-sandbox-010, SB-09).
- ADR-0001 GDD table: "≈ 175 ms" worst case is stale (see GDD Revision Flags).

## Architecture Document Coverage

- All 11 MVP systems appear in the layer map. VS/Alpha systems (Back Room, Save/Load, Shell, Efficiency Stats, Audio, Accessibility, Achievements, Modify Grading) are absent — expected at `standard` tier; Save/Load, Audio, Back Room are listed under "Can defer".
- Orphaned architecture: `GameConfig`, `StringTable`, `Clock`, `BuildFlavour` have no GDD — justified cross-cutting services (architecture.md "Why this split").
- Stale in `architecture.md` v1 (update when the ADRs are amended): "ADR Audit — No ADRs exist", "0 covered", Clock API (`focused` → `is_focused()`, + `wall_iso()`), `SqlRequest.mode` (+ `modify`), boot order (grader + ContentVerifier wiring, C1), Submit flow "one execution in flight" (C3), TR table now superseded by `tr-registry.yaml`.
- Data flows not shown: Restart, briefing-end signal (Dialogue → Progression), verdict fan-out, challenge-mode open/closed, onboarding → progression answer signal → ADR-0010.

---

## Verdict: **FAIL**

Two blocking cross-ADR issues (C1 ownership/layer, C2 boot-time performance). Both are fixable by amending ADR text (no GDD change). After the amendments the verdict ceiling is **CONCERNS**: all coverage rests on Proposed ADRs, ADR-0005/0007/0008/0009 gaps remain, and 9 requirements are partial.

### Blocking Issues (must resolve before PASS)
1. C1 — move `ContentVerifier` out of `PuzzleRepository` (ADR-0003, ADR-0006, architecture.md).
2. C2 — concurrent verifier executions + corrected boot/submit numbers (ADR-0003, ADR-0006, ADR-0001 note).

### Should fix before the matching ADR is accepted
- ADR-0001: C5 (Clock), A5 (`PROCESS_MODE_ALWAYS`, limit + one frame), stale 175 ms.
- ADR-0002: C3 (Run supersede), N1 (per-request awaitable), extensions off.
- ADR-0003: N3, non-puzzle checks CI-only, id-list vs `order` check.
- ADR-0004: C4 (`hint_counted` callable), C6 + N4 (`session_end`), N2 (`event_name`), playtest-006 (report reads config).
- ADR-0006: A1 (`@abstract` row), C7 (tick-sampled rule time, FakeClock tick, pause), N5.

### Required ADRs (most foundational first)
1. **ADR-0005** Platform, display and performance baseline — after the Windows `.dll` spike (session 10).
2. **ADR-0010 (new)** Gameplay signal contracts — verdict fan-out, `hint_counted`, challenge mode, Restart, briefing end, reaction queue, input-activity feed (TR-grader-006/007, TR-challenge-003, TR-dialogue-006, TR-hint-003) — before the first Grader/Hint/Dialogue story.
3. **ADR-0007** Tuning config, string tables and session settings — before the first Dialogue/Hint story.
4. **ADR-0008** Workbench editor (incl. AccessKit, coach-mark anchoring) — after the IME probe.
5. **ADR-0009** Counter strip rendering — before the first strip story.

---

## Addendum — same day, after the review (ADR amendments and acceptance)

The developer chose "amend, then accept" for each ADR. The amendments are text-only (no GDD rule changed) and close every Blocking and should-fix item above except where noted:

| ADR | Amended | Status |
|---|---|---|
| ADR-0001 | Elapsed time from `Clock.now_ms()` (C5); `PROCESS_MODE_ALWAYS`; guarantee "limit + one frame"; per-frame delivery latency; worst case re-stated (sandbox Formulas `submit_worst`) | Accepted |
| ADR-0002 | Per-request awaitable (N1); sequence-numbered Run supersede, Submit exclusive (C3); extensions never enabled (TR-sandbox-010) | Accepted |
| ADR-0003 | `ContentVerifier` separate object built with (repository, sandbox, grader), setters into the repository, references first (C1); `verify_parallelism` = 6 in flight, boot ≈ 0.6 s (C2); non-puzzle checks CI-only; id list vs `order` check; diagram `JSON.new().parse()` (N3) | Accepted |
| ADR-0006 | `@abstract` post-cutoff row (A1); verifier wiring + load time (C1/C2); tick-sampled rule time, FakeClock tick, pause from owner state (C7); `Time.*` grep scope (N5); `FocusListener` `PROCESS_MODE_ALWAYS`; Depends On wording (no false edge) | Accepted (before ADR-0004, which uses its Clock) |
| ADR-0004 | `event_name` parameter (N2); `hint_counter` Callable exception (C4); `session_end` on quit only, both quit paths (C6, N4); report tool `--config` for `idle_cutoff_s` | Accepted |

GDD change (developer decision): `sql-execution-sandbox.md` Formulas worst case → `submit_worst` (≈ 243 ms at D = 3 measured; ≈ 310 ms at the target ceilings; re-check with ADR-0005).

Post-amendment coverage: 60 requirements — ✅ 33 Accepted, ⚠️ 5 partial, ❌ 19 gaps (6 wait on ADR-0005), ➖ 2, ⏸ 1. Verdict after amendments (not re-run — no fresh review): expected **CONCERNS** (ADR-0005/0007/0008/0009/0010 gaps). Re-run `/architecture-review` in a fresh session after ADR-0005.
