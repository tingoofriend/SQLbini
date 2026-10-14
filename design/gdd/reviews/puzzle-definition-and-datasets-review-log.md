# Review Log: puzzle-definition-and-datasets

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 3
Summary: The chapter/puzzle split, override operations, verifier checks and lifecycle are well specified and the ACs are fixture-backed. It shared the grader's contract defects (disjoint rule vs. tagging every row a mistake gets wrong; undefined key position), and its content hash was circular because the status and hash live in the hashed file. Both revised in the same session, together with the grader; re-review pending.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rules 4, 6 / Formulas disjoint, H, K / V-H: contract conflict with the grader (1-10 and 1-11 could never be valid; key position undefined) — fixed with the grader: `hardcode_proof`, tags per dataset incl. visible, key position by reference output name
- [BLOCKING] States (content hash): hash over "the puzzle" included `content_status` and the stored hash — fixed: excluded, canonical serialisation, Playtest Log uses the same hash; L-06 added
- [RECOMMENDED] Formulas visible_rows_max: rationale assumed 10–12 rows on screen; workbench shows 7 — fixed, Open Question 6 added
- [RECOMMENDED] States (runtime load): `draft` puzzles could reach testers — fixed: playtest/release builds load only `verified`+ with matching hash; L-07 added
- [RECOMMENDED] Tuning Knobs absent (advisory at standard) — added
Reviewed-Content-Hash: design/gdd/puzzle-definition-and-datasets.md c57799275338fe04cb2173fd0312ca5e36142384
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
