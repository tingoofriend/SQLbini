# Review Log: sql-execution-sandbox

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: L
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 7
Summary: The contract is sound and its spike claims hold: every addendum claim was re-run on Godot 4.7.2 + godot-sqlite v4.9 (probe_api/sandbox/cost/order) and matched — zero-row columns and `name:1` via temp view + PRAGMA, multi-statement executing, view rejecting UPDATE, query_only, recursive+LIMIT streaming, value types, order through the view; cost re-measured p95 0.19 ms (doc 0.37 ms, same order). One blocker: the time-limit section contradicts itself on frame-thread blocking and understates the residual runaway case — an extra probe showed a non-recursive 5-way self-join `COUNT(*)` takes 55 ms on 24 rows (a 6-way ≈ 1.3 s), no `ORDER BY` needed.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 15 / Formulas exec_time_limit / Edge Cases / SB-19: "execution must not run on the frame thread" vs "may block the frame for its full duration" until the ADR — state the MVP minimum (off-frame execution regardless of ADR option) and widen the residual risk from "ORDER BY over a huge cross join" to any aggregate/sort/DISTINCT over a large self-join (probe: 5-way COUNT 55 ms, ~24× per extra join)
- [RECOMMENDED] Core Rule 14: as written (drop view, then switch query_only off) fails — DROP VIEW under query_only returns "attempt to write a readonly database" (probed); swap the order and require cleanup on every exit path, incl. fetch errors
- [RECOMMENDED] Core Rule 5 / Edge Cases: unterminated `/* …` comment — SQLite accepts it as a comment to end of input (probed); the lexer must match, add an SB-01 case
- [RECOMMENDED] Core Rule 3 / SB-09: BLOB unspecified — `X'00FF'` returns a byte array (probed); define it or reject it for canon
- [RECOMMENDED] Security: the API exposes `enable_load_extension`/`load_extension`; add a rule never to enable it and an AC that `SELECT load_extension('x')` → SQL_ERROR "not authorized" (probed default)
- [RECOMMENDED] Core Rule 14 / Result: scratch `rows_changed` source unnamed (godot-sqlite has no changes() method; `SELECT changes()` works — probed) and `… RETURNING` output unspecified (returns rows — probed); scratch DB has no size cap (`INSERT … SELECT` doubling) — Alpha, settle in Back Room GDD
- [RECOMMENDED] Dependencies / Cross-References: stale — Workbench and Dialogue GDDs exist and list the sandbox; Puzzle Definition and Grader are In Review, not "pending review"; header Status "In Design" vs index "Designed"
- [RECOMMENDED] Tuning Knobs absent (advisory at standard) — `exec_time_limit_ms`, `R_cap`, `exec_cost_target_ms` live only in Formulas
Reviewed-Content-Hash: design/gdd/sql-execution-sandbox.md 1aa504ee8d92087f897ac8221df068b8e7b000d5
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review): BLOCKING rule 15 fixed (off-frame execution and TIMEOUT-within-limit+50 ms required from the first implementation; residual widened to aggregate/GROUP BY/DISTINCT/ORDER BY over many-way joins; SB-19 adds a 6-way self-join, not ADR-gated). Also fixed: rule 14 order (query_only off, then DROP VIEW, every exit path), `changes()`, RETURNING ignored; unterminated `/* …` (rule 5, SB-01); BLOB (rule 3, SB-09); rule 4a no extensions (SB-09); stale dependency statuses; scratch growth edge case. Not done: Tuning Knobs section (advisory). Re-review pending in a fresh session.
