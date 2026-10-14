# Review Log: playtest-log

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 6
Summary: A strong instrument: the threshold claims map one-to-one onto the concept's MVP table (bars 2/3 and 4/6 re-check, `ceil` scaling to 6 testers holds), the formula examples re-compute (`puzzle_active_time` 170 s, `run_then_fail` 0.67), privacy and release-build isolation are testable, and the facilitator F9 key covers the one thing the game cannot detect. One contract defect blocks: rule 4 rejects undeclared event names, yet the catalogue does not match what sibling GDDs declare — Constraint Challenges CC-13 sends `offer_shown`, `try` / `later` and `cleared` (log: `challenge_offer`, `challenge_try` / `challenge_later`, `challenge_clear`) and Progression PR-17 logs unavailable requests (no event here) — so as written the "Wants more" claim would be computed from dropped events.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rule 4 catalogue vs `constraint-challenges.md` CC-13 and `shift-and-chapter-progression.md` PR-17: event names differ (`offer_shown`/`try`/`later`/`cleared` vs `challenge_offer`/`challenge_try`/`challenge_later`/`challenge_clear`) and `request_unavailable` is missing; with reject-undeclared, "Wants more" becomes unmeasurable — make this table the single canonical catalogue and align both GDDs to it
- [RECOMMENDED] Formulas `time_to_first_run`: "`time_to_first_pass` is ≥ `time_to_first_run` or null" is false — Onboarding allows submitting 1-1 before any Run (OB-06), giving a pass with no prior run; drop the inequality and define the null-run case
- [RECOMMENDED] Core Rule 7 vs UI Req 3: F9 "opens a note field … Enter or Esc returns focus to the editor" vs "never steals focus from the editor" — contradictory; and with a shared keyboard, a tester typing within the 5 s window would type into the note field — specify focus and the auto-close behaviour
- [RECOMMENDED] Formulas `puzzle_active_time`: shares `idle_cutoff_s` with the Hint System, but the hint's `active_time` also excludes unfocused / paused time, which the log never records — the two "active times" will disagree; either log focus / pause events or rename the log metric
- [RECOMMENDED] Formulas `run_then_fail`: `run.match` is `all / partial / none`, while the registry's `result_match` (the visible match bit) is boolean — state how the workbench derives the enum
- [RECOMMENDED] Rule 4 table, Dialogue row: RD-16 sends `line_shown {…, puzzle_id}` — fine via the common `puzzle` field, but say so to avoid a duplicate key
- [RECOMMENDED] Header / Dependencies / Cross-References: Status "In Design" and "All Designed (pending review)" are stale (seven upstream GDDs are In Review); Player Fantasy and Tuning Knobs absent (advisory at `standard`; `idle_cutoff_s` is the only knob and is in Formulas)
Reviewed-Content-Hash: design/gdd/playtest-log.md cd5809a5a49b3d65307674013f9a6a00127f06f5
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review): BLOCKING catalogue fixed — rule 4's table is canonical; Constraint Challenges CC-13 now uses `challenge_offer` / `challenge_try` / `challenge_later` / `challenge_attempt` / `challenge_clear` (an expired offer logs `challenge_later`), and `request_unavailable` is added and named in Progression edge case and PR-17. Also fixed: `time_to_first_pass` inequality removed (pass before any Run is possible); F9 focus rule made consistent; Dialogue's puzzle id via the common field; stale statuses. Not done: focus/pause events vs the hint's `active_time`, `run.match` enum derivation (recommended). Re-review pending in a fresh session.

## Review — 2026-10-15 (re-review after cross-GDD review fixes, fresh session) — Verdict: APPROVED
Scope signal: M
Specialists: none (lean mode; fresh session, not the authoring session — each doc reviewed by a read-only subagent, blocking items verified against the text in the main session)
Blocking items: 0 | Recommended: 3
Summary: The prior blocker (catalogue vs sibling event names) is resolved — CC-13 and PR-17 now match. Every applicable cross-review resolution is in: W13 (common puzzle field, boolean run.match, run.dataset), W23 (16.6 ms, SB-19 aligned), D2 (skip count + boss skip beside the Finish claim), W24 (global idle_cutoff_s), B1 (UNAVAILABLE, build_message log-only, Sandbox soft upstream), B2 (manual page ids), D1 (hint_counted). Upstream event names all match the catalogue; MVP thresholds match the concept.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Core Rules 4a: hint_counted cites Hint System rule 4a; the owning rule is 4b (add "false for challenge-mode submits")
- [RECOMMENDED] Formulas puzzle_active_time: edit_burst emission timing unstated; no focus events — gaps can misread long typing (carried over)
- [RECOMMENDED] Core Rules 4: "their ACs cite this rule" only partly true (workbench, HS-09, SM-19, grader AC-19)
- [NICE-TO-HAVE] manual_* {page} = manual.<slug>; {mark} = Onboarding rule 7a mark id; time-to-first-submit formula (Hint OQ1); help_given puzzle in challenge mode; Tuning Knobs pointer
Reviewed-Content-Hash: design/gdd/playtest-log.md 6d2bd175fd353f50e98845e47344f1d536b3e8cb
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
