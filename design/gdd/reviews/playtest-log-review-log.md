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
