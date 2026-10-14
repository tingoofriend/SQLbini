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
Revised in-session (2026-10-14, after the review; user decisions: time path for `exhausted`): BLOCKING exhausted fixed — `exhausted_minutes` (default 5, range 2–15) after step 2, so SUBMIT_ERROR-only and never-submitting players reach the skip at 11 active minutes at defaults (rule 11, Formulas, HS-17, OQ 4 resolved). BLOCKING tutorial 1-2 fixed — override is 1-3 only; HS-01 uses 1-3, HS-07 covers 1-1/1-2 as tutorial. Also fixed: Overview wording, "wrong answers" label, MVP note on grader levels, challenge mode never changes hint state (rule 12, HS-18), restart via Progression rule 12a, stale statuses, Tuning Knobs section added. Not done: Player Fantasy (advisory). Re-review pending in a fresh session.

## Review — 2026-10-14 (re-review, session 6b, fresh session) — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 5
Summary: Both prior blockers are resolved: `exhausted` has the `exhausted_minutes` time path (HS-17: 180/360/660 s checks out) and the per-puzzle override is 1-3 only with 1-1/1-2 tutorial (HS-01, HS-07). Rule 4a (distinct-query counting) matches the grader and Playtest Log, and challenge-mode rules (hidden button, paused main-request clock) match Constraint Challenges and Progression. One blocker: the grader and Playtest Log say the Hint System returns `hint_counted` for the `submit` event, but the Hint GDD — the owner of the value — never defines it (cross-review resolution not carried into the owning doc).
Prior verdict resolved: Yes (2026-10-14 blockers 1–2)
Findings:
- [BLOCKING] Core Rules 4a / Interactions / Acceptance Criteria: `hint_counted` contract missing — grader Interactions and `playtest-log.md` rule 4a rely on Hints returning it; Hint doc has no rule, no Grader ← Hints direction, no AC
- [RECOMMENDED] Core Rule 4a: normalization undefined for comments and quoted identifiers — base it on the sandbox `tokenize`
- [RECOMMENDED] Formulas `active_time`: no "this puzzle is shown" term — per-puzzle accrual and the challenge-mode pause are stated only in prose
- [RECOMMENDED] Core Rule 3 / UI Req 1: "always visible" without the challenge-mode exception
- [RECOMMENDED] Dependencies / Cross-References: upstream statuses "In Review" — Puzzle Def, Grader, Workbench Approved
- [RECOMMENDED] Player Fantasy absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/hint-system.md 394a085cd717f2725d70f437ec75e408a349ce90
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-14, after the review; user decisions: define `hint_counted` in the Hint doc, apply the recommended items too): BLOCKING fixed — new rule 4b (`hint_counted` true only for a counted FAIL outside challenge mode; false for uncounted FAILs, PASS, SUBMIT_ERROR, UNAVAILABLE, challenge submits), Grader row now Grader ↔ Hints, Playtest Log row names the events, HS-19 checks the returned values. Also fixed: rule 4a normalization on `tokenize` tokens (comments dropped, WORD case-insensitive, others verbatim; HS-19 comment case), `active_time(p)` gains `shown(p)`, rule 3 / UI Req 1 challenge exception, statuses → Approved, Sandbox listed as soft lexer dependency. Grader and Playtest Log unchanged. Not done: Player Fantasy (advisory); sandbox doc does not yet list the Hint System as a `tokenize` consumer (add at 6d). Status stays In Review; re-review in a fresh session.
