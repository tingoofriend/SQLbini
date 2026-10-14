# Review Log: shift-and-chapter-progression

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 3 | Recommended: 6
Summary: The chapter/shift/request structure, forward-only progress, star-vs-complete split and the Chapter 1 layout (matches `design/levels/chapter-1-puzzles.md`: 11 mains, 1-11 boss, S-1/S-2) are clear and testable; Formulas is rightly omitted (no tuned numeric rules). Three defects block: rule 7's "never stuck" guarantee rests on the Hint System's fails-only `exhausted`, which syntax-error-only players never reach; the chapter-list "restart" that the grader, hints and onboarding all depend on is not defined here; and the post-PASS constraint offer conflicts with "no menus between puzzles".
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rule 7: skip is reachable only via `exhausted` (FAIL-only) — a zero-SQL player producing SUBMIT_ERRORs or not submitting has no exit; contradicts the rule and the concept's "skippable puzzles prevent hard stops" — fix jointly with Hint System
- [BLOCKING] Rule 12 / UI Req 4: chapter list offers replay/reopen only, but grader (counter reset, AC-22), Hint System (rule 8, HS-10) and Onboarding (OB-16) require a "restart from the chapter menu" — define the action, which states it is available in, and what it resets (never a `Passed` state)
- [BLOCKING] Rule 11 / PR-15 vs `constraint-challenges.md` rule 6 / CC-01: "no intervening menu" vs the Try it / Later offer after PASS; define the flow (offer placement, return after a challenge) here as flow owner
- [RECOMMENDED] Rule 6 / Edge Cases (MVP no save): *Stop for today* discards the whole chapter on quit at MVP — hide or relabel it at MVP, or plan playtests as one sitting
- [RECOMMENDED] Rule 9 terminology: star called the "mastery reward", but the concept defines *mastered* as every constraint challenge cleared — rename or align
- [RECOMMENDED] States: transition into the next shift's first request (on *Next shift*) and resume after *Stop for today* within a session are missing
- [RECOMMENDED] Edge Cases: withheld request "skipped automatically for ordering" collides with the `Skipped` state — say "passed over" / `Unavailable`
- [RECOMMENDED] OQ 3: concept's 30–60 min shift vs 3–4 puzzles × ~5 min (15–20 min) — a concept-level mismatch to resolve at the playtest, noted
- [RECOMMENDED] Dependencies statuses stale; Player Fantasy and Tuning Knobs absent (advisory at `standard`; shift size, wage are content knobs)
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md 2feda659a976e3f06fc7a1ce81325f0b94a5dbea
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review; user decisions: hint time path, Restart defined here, inline challenge offer): BLOCKING skip guarantee fixed — rule 7 now rests on `exhausted`'s time path (hint rule 11). BLOCKING restart fixed — rule 12a Restart on the chapter list (resets grader counters, hints, draft, 1-1 prefill; never progress), PR-18. BLOCKING flow fixed — rule 11 states the inline offer is not a menu; challenge mode pauses the shift (PR-15, PR-20). Also fixed: MVP *Stop for today* keeps progress in-session with a note (rule 6, PR-19), next-shift transitions, "full-clear" star vs concept's "mastered", withheld requests "passed over", new edge cases, stale statuses, Tuning Knobs section. Not done: OQ 3 shift length (playtest); Player Fantasy (advisory). Re-review pending in a fresh session.
