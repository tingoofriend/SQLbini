# Architecture Review Report

Date: 2026-10-16 (session 10, fresh session — not the authoring session of ADR-0007/0010)
Mode: full (workflow `standard`: architecture doc + critical ADRs)
Engine: Godot 4.7.2 + godot-sqlite v4.9
GDDs Reviewed: 11 MVP GDDs (+ `systems-index.md`, `game-concept.md`)
ADRs Reviewed: 7 — ADR-0001, 0002, 0003, 0004, 0006 (**Accepted**, amended in session 9 — amendments re-verified); ADR-0007, 0010 (**Proposed**). ADR-0005 not written (pending Windows spike) — left blank.
Inputs: `docs/architecture/architecture.md` v1 (partially refreshed in session 9); prior report `architecture-review-2026-10-15.md`; three parallel reviewers — amendment/consistency check (general-purpose), GDD cross-check of ADR-0007/0010 (general-purpose), engine second opinion with probes on 4.7.2 headless (godot-specialist)
Freshness (Phase 1a): 5 ADRs CHANGED, 2 NEW, 6 GDDs CHANGED since the 2026-10-15 receipt → full re-run.

Reviewed-Content-Hash: docs/architecture/adr-0001-sandbox-execution-and-timeout.md 9e1e6b5f332470e359089994eb04e78a8c7957fc
Reviewed-Content-Hash: docs/architecture/adr-0002-sandbox-api-and-lexer-contract.md 51275f76cedf2640bf14397791d1bf8fef35caff
Reviewed-Content-Hash: docs/architecture/adr-0003-puzzle-data-format-loader-and-verifier.md ee32f5547a72482e2a82e0fd0c53a24a4d4f529c
Reviewed-Content-Hash: docs/architecture/adr-0004-event-bus-and-playtest-log.md db3884eb45703b3234858a7140e420fb233da1c9
Reviewed-Content-Hash: docs/architecture/adr-0006-composition-root-and-service-wiring.md d7aac1861495da01d3bb456b36682d3c9cf09f83
Reviewed-Content-Hash: docs/architecture/adr-0007-tuning-config-string-tables-and-settings.md 4200013ca8f5e5c0d6061cc4dcfbbe7a7dc1315c
Reviewed-Content-Hash: docs/architecture/adr-0010-gameplay-signal-contracts.md f210cd0c1c0bc196e779993ac0861093378b4543
Reviewed-Content-Hash: design/gdd/constraint-challenges.md 08aaf80ef9f7f6e505b5948f94234510431dcbd7
Reviewed-Content-Hash: design/gdd/game-concept.md fcc25438d2f80d0e301bee354565231148c8513a
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-10-14.md b945695f1fca955e9984269fd1b88a66e001171a
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-10-15.md 9d62946c0c9b4a8fc3d6e8de8541bd411831e4b7
Reviewed-Content-Hash: design/gdd/hidden-data-grader.md b0c7b45ab1352f9209ad68b112050dcbee2310ac
Reviewed-Content-Hash: design/gdd/hint-system.md 652abb3afba2d4039434c325fa05f33d1ef754f0
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md e1e5cf999de6e399936b6036aa1924e1b3f6db0b
Reviewed-Content-Hash: design/gdd/playtest-log.md 2f1c452da227d683b587ab7df2e58e41d17ef0f8
Reviewed-Content-Hash: design/gdd/puzzle-definition-and-datasets.md b7a9bce7d327a7d8ac9aefed30b83a86e0ef44ab
Reviewed-Content-Hash: design/gdd/query-workbench.md c202045394f149427868256c23f450cd8822d4bf
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md c54ef902635ee876e6c4f620ceec549ccf55057f
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md d5a7faf214f48548bf27d63aa43309fac11cd9bf
Reviewed-Content-Hash: design/gdd/sql-execution-sandbox.md 68cd06d8c26c9ccc06be2a753ffead91ea00bed4
Reviewed-Content-Hash: design/gdd/store-manual.md 9e4063a0ea449c2756df0abcad0f6144e2b4858f
Reviewed-Content-Hash: design/gdd/systems-index.md 1e0f24f9f194db1d3ac90df901c1d1714bcc4b84

---

## Traceability Summary

Total requirements: **60** (registry IDs unchanged; no new TR-IDs — every new finding maps to an existing requirement)

| Status | Count | Change vs 2026-10-15 addendum |
|---|---|---|
| ✅ Covered (Accepted ADR) | 33 | — |
| 🟡 Covered (Proposed ADR — 0007 / 0010) | 10 | +10 |
| ⚠️ Partial | 2 | −3 |
| ❌ Gap | 12 | −7 |
| ➖ No ADR needed | 2 | — |
| ⏸ Deferred (VS Save/Load) | 1 | — |

🟡 rows: TR-grader-007, TR-challenge-003, TR-hint-003, TR-dialogue-006 (ADR-0010); TR-config-001, TR-dialogue-001, TR-dialogue-005, TR-onboarding-001, TR-onboarding-002 (ADR-0007); TR-playtest-006 (ADR-0004 + 0007). They become ✅ only when ADR-0007 / 0010 are accepted — and both need the amendments below first.

Matrix: `docs/architecture/requirements-traceability.md`.

## Coverage Gaps (no ADR)

| TR-ID | Requirement | Suggested ADR | Engine risk |
|---|---|---|---|
| TR-sandbox-009, TR-grader-005 | Query p95 ≤ 25 ms; Submit p95 ≤ 300 ms / Run ≤ 200 ms on the target PC | ADR-0005 (blank — after Windows spike) | MEDIUM |
| TR-platform-001 | Windows + Linux; godot-sqlite `.dll` loads on 4.7.2 | ADR-0005 (blank) | HIGH |
| TR-platform-002 | 64 MB 2D textures, < 500 draw calls, 60 fps | ADR-0005 (blank) | MEDIUM |
| TR-playtest-007 | Build id source | ADR-0005 (blank) | LOW |
| TR-workbench-004 | `ui_scale` via Theme fonts | ADR-0005 + ADR-0008 | MEDIUM |
| TR-workbench-001/002/003/007, TR-onboarding-003 | CodeEdit editor, keyboard-first, IME, AccessKit, coach-mark anchoring | ADR-0008 (planned; IME probe first) | HIGH (IME, AccessKit) |
| TR-dialogue-003 | Counter strip SubViewport | ADR-0009 (planned) | LOW |

Partial: TR-workbench-008 (per-puzzle session state as plain data — architecture.md only), TR-dialogue-004 (grapheme counting in ADR-0007; measured paging needs ADR-0008).

---

## Session-9 amendments — verification

| Finding (2026-10-15) | Status now | Note |
|---|---|---|
| C1 verifier ownership | ✅ in ADRs · ⚠️ architecture.md | ADR-0003 §4, ADR-0006 diagram correct. architecture.md layer map (l.131-132) and ownership rows (l.178-179) still put the verifier in the repository; control manifest says Core. |
| C2 boot time | ✅ mostly | ADR-0001 l.212 still says "≈ 200, sequential". **New gap:** how 6 executions are in flight while `puzzle_valid` uses the grader's sequential `submit` is unstated — and see X2. |
| C3 Run supersede | ✅ ADR-0002 · ⚠️ architecture.md l.305 | "one in-flight execute per workbench" left in API section |
| C4 `hint_counted` | ✅ | ADR-0004 §2, ADR-0010 §3 |
| C5 Clock time | ✅ | |
| C6 `session_end` | ✅ | |
| C7 tick rule time | ✅ | |
| A1, A5, N1, N3, N4, N5 | ✅ | |
| N2 `event_name` | ⚠️ | ADR-0004 l.94 "If `name` is not…"; architecture.md l.231/295 still `emit_event(name, puzzle_id: StringName…)` |
| Other: CI-only checks, id list vs `order`, extensions off, 175 ms | ✅ | `submit_worst` recomputed: ≈ 243 ms (D = 3) / ≈ 310 ms at ceilings — matches the GDD |
| architecture.md stale items | ⚠️ | `SqlRequest.mode` lacks `modify` (l.264); "delivered via call_deferred" (l.206, ADR-0001 uses the `_process` poll); data flows (Restart, briefing end, verdict fan-out, challenge mode, onboarding answer) still only in ADR-0010; StringTable row l.182 says `tr()` + EventBus (ADR-0007 says neither); header lists ADR-0001…0006 only |

New inconsistencies introduced by the amendments (text only):
- ADR-0006 §3 `HiddenDataGrader.new(sandbox, puzzles, bus)` (3 args) vs its diagram (4 args, `hint_counter`).
- ADR-0004 Depends On still says ADR-0006 "not required", but it uses `Clock.wall_iso()`.
- "(planned)" links to now-Accepted ADRs: ADR-0001 l.229, 0002 l.311, 0003 l.318, 0004 l.291-292; ADR-0010 calls ADR-0007 "planned".

## Cross-ADR Conflicts

No 🔴 blocking conflict between Accepted ADRs. The items below involve the two Proposed ADRs and must be resolved in their text before acceptance.

### 🟠 X1 — ADR-0007 / ADR-0010 vs ADR-0006: `Services` and boot order lack the new services
Type: Dependency / Integration
- ADR-0007 §3 and ADR-0010 §1, §7 build `Settings`, `InputActivity` and call `GameplayWiring.connect_all` from `ServicesFactory`; ADR-0006 `Services` (l.68-81), its diagram, architecture.md boot order (l.241-246) and the manifest list none of them.
- Order problem: `hint_counter` is passed into the grader's `_init` (ADR-0004 §2), so the Hint System must exist **before** the grader.
- Resolution: amend ADR-0006 §2 + diagram (and architecture.md): Flavour → Clock/FocusListener → GameConfig → StringTable → Settings → EventBus → InputActivity (last child of `Main`) → Sandbox → Repository → Hint → Grader(hint_counter) → ContentVerifier → other features → `GameplayWiring.connect_all` (after `verify_all`) → scenes.

### 🟠 X2 — ADR-0010 §3 vs ADR-0003 §4: verification would fire gameplay side effects at boot
Type: Integration contract
- ADR-0003 runs `puzzle_valid` "using the real HiddenDataGrader"; the grader has only `submit()`. ADR-0010 §3 makes `submit()` call `hint_counter`, emit the `submit` log event and `verdict_given`.
- Impact: boot would count hint submits, log ≈ 200 fake submits and fan verdicts out to Progression/Dialogue.
- Resolution: split `grade(puzzle, sql, counters) -> Verdict` (pure: executions + cause selection, no side effects; usable concurrently by the verifier — also answers the C2 "6 in flight" gap) from `submit()` = `grade()` + §3 steps 2-5. Edit ADR-0010 §3; one-line note in ADR-0003 §4.

### 🟠 X3 — ADR-0010 vs ADR-0007 / architecture.md: dependency and wording drift
- ADR-0010 uses `StringTable` (`statement_key`) but does not list ADR-0007 in Depends On; calls it "planned". No cycle (ADR-0007 does not depend on 0010).
- ADR-0004 §2 / architecture.md l.234 "Hint ← verdict by signal" — in ADR-0010 the Hint System receives the verdict only through `hint_counter` (not a `verdict_given` consumer).
- ADR-0004 (Accepted) types `hint_counter` with `Verdict`, defined in Proposed ADR-0010 — note "defined by ADR-0010".
- Registry `docs/registry/architecture.yaml` lists ADR-0007/0010 stances as `active` while the ADRs are Proposed.

### 🟡 X4 — State ownership not registered
Per-cause counters (Workbench controller / Constraint Challenges), hint state, challenge mode, `Settings` have no `state_ownership` entries in `docs/registry/architecture.yaml`; architecture.md gives `WorkbenchController.restart()` with no caller — should be the `request_restarted` handler.

### 🟡 X5 — `verify_parallelism` not data-driven
Constructor default only (ADR-0003 l.209); add to `content.json` and `ConfigSchema` (coding standard: gameplay/tuning values data-driven).

## ADR-0010 vs GDDs (integration contract — ADR text fixes)

All cited GDD rules say what ADR-0010 claims; the gaps are missing links and narrowed payloads.

| # | Finding | Evidence | Fix (ADR) |
|---|---|---|---|
| S1 | `error_text` kept only for `SQL_ERROR`; the sandbox gives a fixed `error_text` for every kind and RD-09 passes it unchanged | sandbox l.148; RD-09 | Blank only for `CONTENT_ERROR`, `TOO_MANY_ROWS`, `UNAVAILABLE` |
| S2 | No path for **Run** errors to Dialogue (Kenji voices Run errors; `did you mean`) | RRD r.2 l.61, r.6; QW r.13 | `run_finished` carries a `DialogueFeedback` (from `SqlResult`) + `source` Run/Submit; add `run_started` (W5: next Run ends a reaction at once) |
| S3 | Constraint Challenges emits nothing: offer line, clear, rule broken, offer expiry; Progression needs clears for the payslip / chapter list | CC 9.3, Interactions; SCP r.10 | Add `challenge_offered`, `challenge_resolved(puzzle_id, cleared, keyword)`, `challenge_offer_expired` |
| S4 | `request_opened` ambiguous: GDDs make the next main `Open` (state, `request_open` logged) at PASS (PR-02, CC 6b, PR-20) but **shown** only after the PASS hold (RRD 3a, SCP 11); side requests `Open` at briefing end but the Manual unlocks on first **open in the workbench** (SM 5) | as cited | Two signals: `request_opened` (state, at PASS / briefing end) and `request_shown` (workbench displays it — consumers Workbench, Dialogue, Manual unlock, Onboarding marks). GDDs already consistent; no GDD change |
| S5 | Challenge offer is in the **same bubble** as the pass line with one combined `reaction_hold` (RD-17), not a priority-3 line after it | RRD 3a, RD-17 | §5: challenge offer merges into the pass line; only `skip.offer` queues behind its line |
| S6 | First-submit explainer (`system` line) and the verdict reaction land in the same batch; order unspecified | QW r.11; RRD r.2 | **GDD gap → developer decision** (see below), then §5 priority |
| S7 | `DialogueFeedback` lacks `puzzle_id` and `challenge` (Dialogue needs the puzzle's speaker/feedback and `challenge.clear` / `rule_broken`); Progression must ignore `challenge` verdicts | CC 9.3; RRD r.2; SCP 7a | Add both fields; state Progression ignores `challenge = true` |
| S8 | Missing consumers/sources: Onboarding needs `briefing_finished` (opening question); Onboarding needs Submit-error verdicts (start-over line); no path for Onboarding's and Progression's `side` lines to Dialogue | ONB r.1, Edge; RRD 3b, 3c; SCP r.5 | Add consumers; add `line_requested(line_id, speaker, kind)` (or per-producer signals) into the reaction queue |
| S9 | Restart: Dialogue (drop queued/shown `skip.offer`) and the Workbench "Leave it for Kenji" button missing | SCP Edge l.235 | §6 add both |
| S10 | Constraint Challenges not a consumer of `shift_clocked_out` (offer expires at clock-out = Later) | CC r.6; SCP Edge | §4 add |
| W1–W8 | Wording: `draft_edited` payload (1-2.schema needs text → Onboarding pulls it); §4/§6 disagree on Challenges as a Restart consumer (CC 6c: untouched); queued `skip.offer` on a new batch; `request_restart` omits `state` | see GDD agent table | ADR wording |

## ADR-0007 vs GDDs

| # | Class | Finding | Fix |
|---|---|---|---|
| A1 | ADR fix | `exec_time_limit_ms` ≤ 0 → default 100 (SB-17), not clamp/fatal | Per-key `≤ 0 → default + warning` rule |
| A2 | ADR fix | Missing-id fallback family `react.*` does not exist; GDD ids are `fail.*`, `error.<KIND>` (uppercase), `skip.*`, `challenge.*`; uppercase KIND and `1-2` break the "lowercase snake_case" id rule | Use the GDD families (`fail.* → fail.generic`, `error.* → error.generic` …); allow `[A-Za-z0-9_-]` segments |
| A3 | **GDD gap → developer decision** | Invalid per-puzzle hint override → ADR withholds the puzzle; Hint GDD says only "rejected at load" | see below |
| A4–A7, A12 | Wording | `grader_row_cap` belongs in `grader.json`; one home each for `reveal_cps`, `feedback_max_level`; exempt CC `canonical_length` (code points) from the grapheme rule; briefing ids are chapter content; reduced motion forces an *effective* `reveal_cps` 0 (stored value kept) | ADR wording |

## Engine Compatibility

Engine: Godot 4.7.2 · ADRs with Engine Compatibility section: 7 / 7 · Deprecated API references: none (string `connect` explicitly forbidden) · Stale version references: none. Post-cutoff APIs: `FileAccess.store_*` → bool (0004), `grab_focus` dual focus (0004), `@abstract` (0006) — no conflicting assumptions.

### Engine Specialist Findings (godot-specialist, probed on 4.7.2 headless, 2026-10-16)
- **E1 (must fix before accepting ADR-0010)** `InputActivity._input` receives **nothing** while an embedded dialog or popup is open (AcceptDialog, CodeEdit context menu — `gui_embed_subwindows` default). Hint idle time would count dialog time as idle. Fix: stamp from `get_tree().root.window_input` (probed: receives events with a dialog open). The ADR's NOT SOURCEABLE risk is now sourced.
- **E2 (amend Accepted ADR-0004)** Same cause: **F9 does not work while any dialog/popup is open** (setup prompt, Restart confirmation, context menu). Fix: handle F9 from `root.window_input`, or accept and note in PL-10.
- **E3 (must fix before accepting ADR-0007)** `String.format` has **no escape syntax** (`"{{a}}"` → `{X}`) and substitutes order-dependently. Fix: `StringTable.text()` does its own single-pass `{name}` substitution; values never rescanned.
- **E4 (advisory, ADR-0007)** Exported builds may lack ICU support data (`internationalization/locale/include_text_server_data` defaults false) → grapheme counts silently become code-point counts (wrong number, not a missing API). Fix: set it true (≈ 4 MB) or prove the export without it; run the combining-mark / emoji cases in the exported build ("삼각김밥" cannot detect it). Goes to ADR-0005's first-export check.
- **E5 (advisory, ADR-0007)** `auto_translate_mode = DISABLED` inherits correctly (Controls, Windows, CanvasLayer children) but must be set on `Main`, not "the root UI node" — the recorder's CanvasLayer is outside it.
- **E6 (advisory, ADR-0006)** Seed `FocusListener` from `DisplayServer.window_is_focused()`; focus notifications only report changes.
- **E7 (advisory, ADR-0010)** Deferred flush confirmed per synchronous chain (probe) — on condition that `submit` steps 2-5 and every handler reach their enqueue **without `await`**; add as a guideline. Put `InputActivity` last under `Main`.
- **E8 (advisory, ADR-0006/0010)** `Callable.bind()` arguments are held **strongly** — binding a service as a bound argument can recreate a RefCounted cycle; add "no service as a bound argument".
- **E9 (advisory, ADR-0002)** For results returned without execution, `execute()` must not emit `done` before awaiting it (caller would hang) — return directly or emit deferred.
- Confirmed OK: 4.7 typed-override return rule (applies to the CI `-s` script's `_process -> bool`), `DEVICE_ID_KEYBOARD` = 16 / branch on event type, `JSON.new().parse()` + all-float numbers, `push_error` in the log file, `PROCESS_MODE_ALWAYS`, limit + one frame, quit paths, per-request awaitable, freed awaiter never resumes.

## GDD Revision Flags (Architecture → Design)

No engine finding contradicts a GDD rule; no GDD is flagged Needs Revision.

Developer decisions (GDD gaps — GDDs not edited):
1. **S6** order of the one-time first-submit explainer vs the verdict reaction.
2. **A3** runtime effect of an invalid per-puzzle hint override (withhold the puzzle vs use the global value).

Wording-only recommendations (GDDs not edited, logged in `production/session-state/active.md`): sandbox r.15 / Formulas / OQ1 (3 options) / OQ2 / SB-18 / Edge "Open Question 1" / r.16 `rows_changed` → ADR-0001/0002; puzzle-def OQ1/OQ2, L-04, "format → ADR" ×2 → ADR-0003; playtest-log OQ1, PL-08 (inject a failing writer), `undeclared_events` malformed fields → ADR-0004; grader OQ2 → ADR-0001, Interactions "dataset id" → `ResolvedDataset`, AC-18/AC-28 payload keys (`kind` vs `verdict`); hint Formulas `Σ(frames) dt` → Clock ticks, `last_input_t` scope; dialogue reveal time reads Clock, "missing id logged" = Godot log; SCP/grader "grader subscribes to Restart" → counters owner; payslip "– unavailable" en dash (shift-flow OQ2); `store-manual.md` l.176 "coach-mark visibility" (said fixed in 6e, still present); GDD Interactions tables could name ADR-0010 signals.

## ADR Dependency Order

`adr-dep-graph.sh`: 7 ADRs, 10 edges, no `CYCLE`, no `NO_DEPS_SECTION`. Missing edge: ADR-0010 → ADR-0007 (soft; add).

1. ADR-0001 Sandbox execution and timeout — Accepted
2. ADR-0006 Composition root — Accepted
3. ADR-0002 Sandbox API + lexer — Accepted (→ 0001)
4. ADR-0003 Puzzle format + verifier — Accepted (→ 0001, 0002)
5. ADR-0004 Event bus + playtest log — Accepted (→ 0003, 0006)
6. ADR-0007 Config + strings + settings — **Proposed** (→ 0003, 0004, 0006)
7. ADR-0010 Gameplay signal contracts — **Proposed** (→ 0004, 0006; add 0007)
8. ADR-0005 Platform baseline — **not written** (blank; Windows spike)

## Architecture Document Coverage

- All 11 MVP systems in the layer map; VS/Alpha systems absent (expected at `standard`).
- Missing from architecture.md: `InputActivity`, `Settings`, `GameplayWiring`; ADR-0007/0010 in the header and ADR audit; the five data flows above; stale rows listed in the amendment table. Recommend an architecture.md v2 pass after ADR-0007/0010 are amended (then regenerate the control manifest).
- Orphans: `GameConfig`, `StringTable`, `Clock`, `BuildFlavour`, `InputActivity` — justified cross-cutting services.

---

## Verdict: **CONCERNS**

No blocking conflict among the Accepted ADRs; Foundation/Core requirements are covered (ADR-0005 gaps are deliberate and wait for the Windows spike). Coverage of 10 requirements rests on Proposed ADRs, and **neither ADR-0007 nor ADR-0010 should be accepted as written**: each needs the amendments below (engine E1/E3, X1–X3, S1–S10, A1–A2).

### Must fix before acceptance
- **ADR-0007**: E3 single-pass substitution; A1 `≤ 0 → default`; A2 id families + id charset; E5 `Main`; E4 risk text; A4–A7, A12 wording; A3 per developer decision.
- **ADR-0010**: X2 `grade()` vs `submit()`; E1 `root.window_input`; S1–S5, S7–S10; S6 per developer decision; E7, E8 guidelines; Depends On ADR-0007.
- **Accepted ADRs (text amendments)**: ADR-0006 `Services` + boot order (X1), 3-vs-4-arg grader, E6, E8; ADR-0004 E2 (F9), l.94 `name`, Depends On 0006, `Verdict` note; ADR-0001 l.212; ADR-0003 `grade()` note + `verify_parallelism` in `content.json`; ADR-0002 E9; "(planned)" links.
- **architecture.md v2** and registry status/ownership (X3, X4).

### Required ADRs
1. ADR-0005 Platform, display and performance baseline — after the Windows spike (session 11).
2. ADR-0008 Workbench editor (CodeEdit, IME, AccessKit, coach-mark anchoring) — after the IME probe.
3. ADR-0009 Counter strip rendering — before the first strip story.

---

## Addendum — same session, after the review (amendments and acceptance)

Developer decisions: first-Submit explainer shows **after** the verdict reaction (S6); an invalid per-puzzle hint override is a **CI failure and uses the global value at load** — the puzzle is never withheld for it (A3); "fix, then accept" for ADR-0007 and ADR-0010; text amendments to the Accepted ADRs and an `architecture.md` v2 pass.

| Document | Amended | Status |
|---|---|---|
| ADR-0007 | Single-pass `{name}` substitution (E3); `nonpositive_to_default` (A1); GDD id families + id charset (A2); per-puzzle override rule (A3); auto-translate off on `Main` (E5); export ICU risk (E4); one home per key (A4, A5); `canonical_length` exception (A6); briefings in content (A7); `effective_reveal_cps()` (A12) | **Accepted** |
| ADR-0010 | `grade()` vs `submit()` (X2); `root.window_input` (E1); payloads with `puzzle_id`, `source`, `challenge`, `error_text` rule (S1, S7); `run_started` / `run_finished(…, feedback)` (S2); challenge signals (S3, S10); `request_opened` vs `request_shown` (S4); offer merged into the pass bubble (S5); explainer priority (S6); `line_requested` + new consumers (S8); Restart consumers (S9, W4); no-`await` batch rule (E7); no service as a bound argument (E8); Depends On ADR-0007 | **Accepted** |
| ADR-0001 / 0002 / 0003 / 0004 / 0006 | Text only: boot order + `Services` (X1), 4-arg grader, FocusListener seed (E6), bound-argument rule (E8); F9 on `root.window_input`, note field only without an open dialog (E2), `event_name`, Depends On ADR-0006, `Verdict` note, "Hint ← verdict" wording; `grade()` in the verifier, `verify_parallelism` in `content.json` (X5); early `done` (E9); "(planned)" links | Accepted (unchanged decisions) |
| `architecture.md` | v2: verifier layer, Run supersede, `event_name`, `SqlRequest.mode`, completion object, StringTable row, `grade()`, Settings / InputActivity / GameplayWiring, gameplay signal flows, boot order | — |
| `docs/registry/architecture.yaml` | State ownership (counters, hint state, challenge mode, settings, request state); `grade`/`submit`, `InputActivity`, single-pass substitution; `DialogueFeedback` signature | — |

Post-acceptance coverage: 60 requirements — ✅ 43 Accepted, ⚠️ 2 partial, ❌ 12 gaps (6 wait on ADR-0005 — blank), ➖ 2, ⏸ 1. Remaining gaps: ADR-0005, ADR-0008, ADR-0009. The control manifest (Manifest Version 2026-10-16) predates ADR-0007/0010 → re-run `/create-control-manifest`.
