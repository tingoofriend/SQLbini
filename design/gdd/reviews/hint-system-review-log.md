# Review Log: hint-system

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 6
Summary: The two-step idea/shape split, the `active_time` idle cap and the FAIL-only counting are precise and well tested (HS-03/04/05 boundary values check out against the formulas). Two defects block: `exhausted` — the only route to Progression's skip — counts FAILs only, so a zero-SQL player stuck in syntax errors (SUBMIT_ERROR) or who never submits can never skip, which is the concept's top risk; and HS-01/HS-07 treat 1-2 as non-tutorial while onboarding, puzzle definition and progression flag it `tutorial`.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas `exhausted` / Core Rule 11 (OQ 4): fails-only latch — SUBMIT_ERROR-only or never-submitting players never reach `exhausted`, so Progression rule 7's "never stuck" guarantee fails; needs a time- or attempt-based fallback (e.g. `exhausted_minutes` after step 2, or SUBMIT_ERRORs counting toward `exhausted` only) decided now, not after the playtest — fix jointly with Progression
- [BLOCKING] Acceptance Criteria HS-01 / HS-07 vs Formulas per-puzzle override: 1-2 is `tutorial` (onboarding rule 2, puzzle-definition, progression rule 2), so its locked label never shows (HS-06) — HS-01's 1-2 example and HS-07's "1-1, 1-2, 1-3 (not tutorial)" cannot pass; restate the override as 1-3 only (1-1/1-2 are tutorial) and use 1-3 in HS-01
- [RECOMMENDED] Overview / Summary vs Core Rule 4: "a failed submit" and "a couple of failed submits" vs default `hint1_fails = 2` — align wording
- [RECOMMENDED] Core Rule 3 / UI Req 1: "after 2 tries" while SUBMIT_ERRORs do not count — a player with three syntax errors still sees "2 tries"; reword ("2 checked answers") or show progress
- [RECOMMENDED] Formulas "Grader interaction": cites feedback levels 1,1,2,2,3 — MVP ships level 1 only (levels 2–3 → Vertical Slice); note the MVP case
- [RECOMMENDED] Core Rules: challenge-mode submits (constraint-challenges rule 9) — do their FAILs advance hint unlocks on an already-PASSED puzzle? Unspecified in both GDDs
- [RECOMMENDED] Core Rule 8 / States: "restart from the chapter menu" relies on an action Progression's chapter list does not define (replay/reopen only)
- [RECOMMENDED] Dependencies / Cross-References: status "Designed (pending review)" is stale — grader, puzzle definition and workbench are In Review; Player Fantasy and Tuning Knobs absent (advisory at `standard`; Game Feel and the Formulas ranges partly cover them)
Reviewed-Content-Hash: design/gdd/hint-system.md 375ea4b799bee5e440b9487a128f97c24cc76604
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
