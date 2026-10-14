# Review Log: hidden-data-grader

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: L
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 3 | Recommended: 4
Summary: The grading model, `canon`/`result_match` and the no-leak rule are sound and the ACs are concrete. Three contract defects with Puzzle Definition blocked implementation: trap-cause attribution named traps the player did not fall into, the key column's position in a result was undefined while column names are ignored, and the disjoint rule could not be met by puzzles whose traps also hit visible-origin rows (1-10, 1-11). All three were revised in the same session; re-review pending.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 10.4 / Edge Cases / AC-17: any tagged missing row picked the trap cause, so unrelated wrong queries got trap feedback (1-5 `category = 'Snacks'` → "¥200 customer turned away") — fixed: trap only when every differing row is tagged and no key is both missing and extra; else `generic`; AC-17 rewritten, AC-27 added
- [BLOCKING] Core Rules 2, 10.4: "result contains the key column" undefined when column names are ignored — fixed: key position = the reference output column named like `key_column` (exactly one), same index in the player result
- [BLOCKING] Core Rules 2 / Edge Cases / AC-02(d): disjoint rule unsatisfiable when a trap's tags include visible-origin rows (1-10 `null_compare`, 1-11 `stock_rule` incl. Strawberry Yogurt) — fixed: replaced by `hardcode_proof` on reference key sets (all 13 Ch1 puzzles satisfy it); tags now per dataset incl. visible
- [RECOMMENDED] Dependencies / Cross-References / Open Questions 1–2: stale "not yet designed" status — fixed, bidirectionality verified
- [RECOMMENDED] Edge Cases: no handling for sandbox `CONTENT_ERROR` — fixed (submit abandoned, not counted, content bug reported)
- [RECOMMENDED] Open Question 7 cited AC-25 (is AC-26); `L_max` vs registry `feedback_max_level` naming — fixed
- [RECOMMENDED] Tuning Knobs absent (advisory at standard) — added
Reviewed-Content-Hash: design/gdd/hidden-data-grader.md 3087b9df7ba693771e5b83178a934aeb54700363
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
