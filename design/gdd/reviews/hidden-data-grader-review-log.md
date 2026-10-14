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

## Review — 2026-10-14 (re-review, fresh session after cross-GDD review 6b244c0) — Verdict: NEEDS REVISION
Scope signal: L
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 4
Summary: All three prior blockers stay resolved (fully-explained trap attribution, key position by reference output name, `hardcode_proof`), and the cross-GDD resolutions are in: UNAVAILABLE (rule 9a, state table, AC-28, UI 6), `TOO_MANY_ROWS`, hidden `truncated`, caller-supplied counter sets, `hint_counted`/`build_message`, AC-03 error text. Two defects remained: the `generic` neutral statement contradicted Edge Cases and Dialogue (both demanded the same column-order sentence while rule 12 forbids repeating a sentence; "on other shelves" is false for visible-data FAILs), and an error/TIMEOUT on a visible re-run after a passing pre-check had no verdict.
Prior verdict resolved: Yes (2026-10-14 blockers 1–3)
Findings:
- [BLOCKING] Core Rules 12 / Edge Cases "Result shape": `generic` column-order advice required on note and bubble vs "never the same sentence twice"; neutral statements say "other shelves" though FAILs include visible — fixed (user: advice on the note only): new trap/generic statements, Dialogue rule 2 `fail.generic` no longer carries the advice
- [BLOCKING] Core Rules 7–8 / submit_verdict `e`: determinism or visible grading run erroring/timing out after a passing pre-check undefined — fixed (user: SUBMIT_ERROR, not counted): rule 7a, rule 8 TIMEOUT scoped to hidden, Edge Case, `e` widened, AC-29
- [RECOMMENDED] Interactions (Sandbox row): stale "timed-out flag"; missing `truncated`, `CONTENT_ERROR`, `build_message` — fixed
- [RECOMMENDED] Acceptance Criteria AC-19: no check of `hint_counted` — fixed
- [RECOMMENDED] Core Rules 6: CONTENT_ERROR not excluded from pre-check rejections — fixed (→ rule 9a)
- [RECOMMENDED] Player Fantasy absent (advisory at standard) — not done
Reviewed-Content-Hash: design/gdd/hidden-data-grader.md 99356d3f25de253287cd49d94d48cef48792c02f
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-14, after the review): both blockers and three recommended items fixed from user decisions; also edited `request-and-reaction-dialogue.md` rule 2 (`fail.generic`). Status stays In Review; re-review in a fresh session.
