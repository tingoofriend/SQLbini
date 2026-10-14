# Review Log: query-workbench

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 7
Summary: The Run-vs-Submit model, row marks and "never a pass on Run" rule are strong and testable; the 1-5 fixture matches `ch1.py`. The 120 px counter scene is reflected in the layout formula at defaults (H_table = 0.40 × 568 − 48 = 179 → rows_visible 7 ✓), but not at ui_scale > 1 (the dialogue GDD scales the strip, the workbench keeps 120 px) and not in Core Rule 6 / QW-01, which still place the entry points in the feedback area.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas readability / QW-24: H_table fixes the strip at 120 px and the 48 px header at all ui_scale, but `request-and-reaction-dialogue.md` scales the strip with ui_scale (×6 at 1.5, RD-13) — at 2.0 the strip is 240 px and rows_visible is ≤ 2, not 3; also a ×8 strip (2560 px) cannot fit a 1280 px width — fix jointly with Dialogue
- [BLOCKING] Core Rule 6 / QW-01 / QW-19: entry points are in the feedback area (rule 6, QW-01) vs tabs at the counter scene's right edge (Visual/Audio); QW-01 and QW-19 require Back Room / Ctrl+B, which rule 6 removes in Chapter 1 — QW-01 cannot pass on a Chapter 1 puzzle
- [RECOMMENDED] Edge Cases vs Formulas display_rows_max: "paged or virtualised" vs "showing the first 200" — pick one
- [RECOMMENDED] Edge Cases: no Run handling for TIMEOUT, MULTI_STATEMENT (likely for beginners with two queries), NOT_A_QUERY, UNSUPPORTED or CONTENT_ERROR (target fails to compute)
- [RECOMMENDED] Formulas readability: header/count 48 px and margins do not scale with ui_scale; define which layout parts scale
- [RECOMMENDED] Core Rule 15: pane list still names "request" — now the counter scene
- [RECOMMENDED] Dependencies / Cross-References: stale — hosted systems (Hint, Manual, Constraint Challenges, Dialogue, Onboarding) have GDDs and list the workbench; upstream are In Review
- [RECOMMENDED] QW-13: p95 ≤ 200 ms needs the target PC named (grader OQ 7), as SB-20
- [RECOMMENDED] Tuning Knobs absent (advisory at standard); puzzle-definition OQ 6 (24–30 visible rows in a 7-row panel) stays open — workbench accepts scrolling
Reviewed-Content-Hash: design/gdd/query-workbench.md 5340f8929b4fea66cb5acc7562af2df61cc59c4c
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review; user chose a fixed 120 px strip): BLOCKING ui_scale fixed — `strip_h = 120` at every ui_scale, header scales, rows_visible 7/5/4/3/2 at 1.0–2.0 (QW-24); `request-and-reaction-dialogue.md` updated to match (strip never rescales, bubble text does: capacity 146/48/40; RD-11, RD-13, UI Req 1). BLOCKING entry points fixed — tabs in the counter scene (rules 1, 6), QW-01 captures Ch1 and Ch2, QW-19 Ctrl+B Ch2 only. Also fixed: display_rows_max wording, Run sandbox-rejection and CONTENT_ERROR edge cases, pane list, Tab vs onboarding ghost text, stale dependencies/bidirectionality. Not done: Tuning Knobs section (advisory), QW-13 target PC (grader OQ 7). Re-review pending in a fresh session.

## Review — 2026-10-14 (re-review, session 6b, fresh session) — Verdict: APPROVED
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 7
Summary: Both prior blockers are resolved: the counter scene is a fixed 120 px strip at every `ui_scale` (H_table 179→131, rows_visible 7/5/4/3/2 recomputed and correct), and the Hint / Manual / Back Room tabs live in the counter scene with Back Room absent in Chapter 1 (QW-01, QW-19 split MVP/Alpha). Cross-review resolutions are in: UNAVAILABLE (rule 12, state table, Edge Cases, QW-27), bubble/note-strip split (rules 12–13, no duplicated line), `grader_row_cap` strings (QW-29), `prefill_sql`, Esc precedence, QW-15 onboarding. Note/strip text matches the grader's 6a changes (rule 12 neutral table, rule 7a visible re-run SUBMIT_ERROR).
Prior verdict resolved: Yes (2026-10-14 blockers 1–2)
Findings:
- [RECOMMENDED] Core Rule 13: `TOO_MANY_ROWS` strip text undefined (grader re-review rec.) — fixed in-session (user decision): label + "{grader_row_cap}+ rows — too many to compare", same string as the Run count line; QW-17 extended
- [RECOMMENDED] Dependencies / Cross-References: upstream statuses "In Review" — Puzzle Def, Sandbox, Grader are now Approved
- [RECOMMENDED] Interactions (Constraint Challenges row): "canonical character count" live check is Alpha (`max_chars` deferred)
- [RECOMMENDED] States: UNAVAILABLE → `Editing` dims the previous Run as stale although "nothing else changes"; the strip's lifetime in `Editing` is unstated (until next edit?)
- [RECOMMENDED] Challenge mode: which draft the editor shows on Try it (base puzzle draft vs separate challenge draft) is unstated here and in Constraint Challenges
- [RECOMMENDED] QW-13: p95 target PC still unnamed (grader OQ 7)
- [RECOMMENDED] Tuning Knobs and Player Fantasy absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/query-workbench.md f9b54012f0ba6079e078d65be3fe1483cf50b4bd
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
