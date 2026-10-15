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

## Review — 2026-10-15 (re-review after cross-GDD review fixes, fresh session) — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; fresh session, not the authoring session — each doc reviewed by a read-only subagent, blocking items verified against the text in the main session)
Blocking items: 2 | Recommended: 6
Summary: Prior blockers (never-stuck skip, inline offer) resolved and Restart rule 12a matches grader/hint/onboarding; cross-review resolutions (Day One, S5 challenge-mode state, offer expiry, prefill owner, Onboarding in tables) are in. Two contract gaps remained: Restart had no Query Workbench side, and Kenji's accept line / side-request messages had no Dialogue kind or string id.
Prior verdict resolved: Partly (2 of 3; Restart missing its Workbench side)
Findings:
- [BLOCKING] Core Rules 12a / Interactions (Workbench): Restart resets draft/result but the Workbench never subscribes; confirmation reads a draft state no interface provides
- [BLOCKING] Core Rules 5, 7 / Interactions (Dialogue): side-request messages and Kenji's accept line have no Dialogue kind, string id or end rule (S4 boss skip → payslip depends on it)
- [RECOMMENDED] Edge Cases: repeated UNAVAILABLE leaves the request Open with only the 11-min exhausted path out
- [RECOMMENDED] Edge Cases: "Try it" on a shift's last main request — CC rule 6a return target and clock-out timing undefined
- [RECOMMENDED] Bidirectionality: Progression↔Challenges runtime coupling not named; CC row owner disagrees with CC :173
- [RECOMMENDED] Core Rules 7: "further fails" → "counted FAILs (hint rule 4a)"
- [RECOMMENDED] Edge Cases: empty-chapter star when every main is withheld (incl. the boss)
- [RECOMMENDED] Playtest Log: Restart not logged (no request_restart) although it resets hint state
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md 4f000605792334e14db84b598e743753353ec3f8
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-15, after the review; user decisions): rule 12a + Workbench row — the Query Workbench subscribes to Restart (resets draft to prefill/empty, clears last result and verdict, reports draft-empty for the confirmation; workbench rule 14, edge case, QW-30); rules 5, 7 + Dialogue row — side-request messages = `side` line in the message log + strip ticket, Kenji's `skip.offer` / `skip.accept` defined in Dialogue rule 3b (accept holds like a pass line, then next request or clock-out); PR-18, PR-21 updated. Status stays In Review; re-review in a fresh session.

## Review — 2026-10-15 (re-review, session 6c-2, fresh session) — Verdict: APPROVED
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 2
Summary: Both 6c blockers are resolved and agree with the partner docs. Restart (rule 12a) is now a broadcast the Query Workbench subscribes to — workbench rule 14, its Interactions row, the "If Progression restarts a puzzle" edge case and QW-30 reset the draft to empty/`prefill_sql`, clear the last result and verdict, and report draft-empty for the confirmation, matching PR-18. Kenji's `skip.offer` / `skip.accept` and the `side` kind are defined in Dialogue rule 3b (kind table, PassReaction state, Interactions row, RD-21) and match rules 5 and 7 and PR-21 (accept holds for `reaction_hold`, edits/Run do not end it, then next request or clock-out).
Prior verdict resolved: Yes (6c blockers 1–2)
Findings:
- [RECOMMENDED] Dependencies / Cross-References: statuses stale — Puzzle Definition, Grader, Hint System and Constraint Challenges are Approved
- [RECOMMENDED] Earlier 6c recommendations still open (repeated UNAVAILABLE, "Try it" on a shift's last main, empty-chapter star, Restart not logged — queued for 6d); not escalated
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md 9558b1a078e366f42f6a4c097e4f64070fec5cdd
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084

## Review — 2026-10-15 (re-review 6e of the 6d rule changes, fresh session) — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 3
Summary: The 6d changes are in and agree with Dialogue, Hint, Workbench and Playtest Log: rule 7a (UNAVAILABLE → Kenji's offer queued after `error.CONTENT_ERROR`, `Unavailable` excluded from completion and star, reopenable, `request_unavailable {source: submit}`), rule 9, rule 11 (briefing gates the first request), rule 12a `request_restart`, PR-17, PR-22. One gap: the state machine and rules 4/6 still resolve a main request only on passed/skipped, so a rule 7a accept would leave the next request `Locked` and never clock out; the payslip had no unavailable mark; the States table still opened a shift's first main on *Next shift* instead of at the end of the briefing.
Prior verdict resolved: Yes (6c-2 APPROVED; 6d recommendations — repeated UNAVAILABLE, Restart logging — applied)
Findings:
- [BLOCKING] Core Rules 4, 6, 10 / States (Locked row, per shift, per chapter) / PR-02, PR-04, PR-11: `Unavailable` (rule 7a) not a resolving state; payslip mark undefined; first main of a shift opens on *Next shift*, not at briefing end (rule 11)
- [RECOMMENDED] Core Rule 12a / States: Restart scope omits `Unavailable` (a reopened unavailable request cannot be restarted)
- [RECOMMENDED] Core Rule 7a: when the "Leave it for Kenji" button disappears after a declined UNAVAILABLE offer (e.g. after Restart) is unstated
- [RECOMMENDED] Playtest Log (cross-check): `puzzle_active_time` ends at `request_pass` / `request_skip` only — `request_unavailable {source: submit}` not an end event
Reviewed-Content-Hash: design/gdd/shift-and-chapter-progression.md fe2e0afccffb0b512d85ef06a5da0e6eb5ff1d4f
Reviewed-Content-Hash: design/registry/entities.yaml 9bfe3fd10be0643425af7af9514ee5e77a2e56f2
Revised in-session (2026-10-15, after the review; user decision "resolve like Skipped + payslip mark"): rules 4, 6 and 7a, rule 10 payslip marks (passed / left for later / unavailable), States Locked row (previous main passed / skipped / unavailable; first main opens when the shift's briefing ends), per-shift and per-chapter lines, Visual "– unavailable" in `ink_muted`, PR-02, PR-04, PR-11; rule 5 + Dialogue row — side messages arrive when the briefing ends, Dialogue → Progression briefing-end signal (with the Dialogue 6e fix). Status → In Review; re-review in a fresh session.
