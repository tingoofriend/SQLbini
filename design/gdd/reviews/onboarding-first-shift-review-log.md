# Review Log: onboarding-first-shift

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: S
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 7
Summary: The scaffolding is well judged — one coach mark at a time, nothing timed or blocking, a guaranteed first PASS, ghost text that is a shape and never an answer, and a clean opt-out — and the hint, puzzle-definition and playtest-log contracts match. One defect blocks, at the concept's top-risk moment: Tanaka's guidance lines and the opening question are said to appear "in Tanaka's bubble", but the Dialogue state machine has no kind or state for them — the bubble holds the request and only reactions replace it temporarily — so whether a coach line hides the 1-2 request ("name and price") from a zero-SQL player, how long it stays, and how the two-choice question is rendered are all undefined.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 1, 7 / Visual ("normal speech bubble") vs `request-and-reaction-dialogue.md` rule 2 and States: no line kind or state for guidance lines or the "Ever used SQL?" two-choice question — define jointly with Dialogue where they show (bubble vs coach-mark label vs log), their priority against the request (the request must stay one glance away in 1-1 to 1-3), and when they clear
- [RECOMMENDED] Rule 3 / OB-22: clicking `name` then `price` yields `SELECT nameprice FROM products` — nothing in the scaffolding (ghost text, coach line, click-to-insert) tells a zero-SQL player to type ", "; add an auto-separator on the second column insert, or a coach line after the first insert, or the comma in the shape
- [RECOMMENDED] Rule 6 / OB-18: ghost text has no data owner (not a Puzzle Definition field) and its scope after 1-3 is unstated (rule 5 ends coach marks only) — say which puzzles show it and where the strings live
- [RECOMMENDED] Rule 1 / Rule 2: with "Yes, I know SQL", is 1-1 still prefilled, and does the workbench first-submit explainer then show on 1-1? Unspecified (OB-04/OB-05 cover Guided only)
- [RECOMMENDED] UI Req 4: the MVP "minimal options panel" holding the coach-mark toggle has no owning MVP system (Save/Load & Settings is Vertical Slice) — name the owner, and say whether the Ask answer persists between sessions before Save/Load exists
- [RECOMMENDED] Cross-References: `store-manual.md` "Rule 4" should be rules 5–6 (rule 4 is "examples never solve a puzzle"); conversely `query-workbench.md` cites this GDD's "Core Rules 11, 15", which do not exist (rules 2 and 6) — fix the workbench reference
- [RECOMMENDED] Interactions (Hint System row) / Rule 5: "early unlocks on 1-1 to 1-3" — per the revised Hint System, 1-1/1-2 are `tutorial` (both steps at once) and the override is 1-3 only; restate
- [RECOMMENDED] Header / Dependencies / Cross-References: Status "In Design" and "Designed (pending review)" are stale; Player Fantasy and Tuning Knobs absent (advisory at `standard`; Game Feel covers the fantasy; no numeric rules, so Formulas is correctly absent)
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md d52a9d9b17909a35dd111a4c5af5bbbe53a69e9d
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review; user decisions: guidance in coach-mark labels, auto comma): BLOCKING fixed — guidance lines live in the coach-mark label with Tanaka's name tag and never in the bubble, which keeps the request; the opening question is a Dialogue `system` line with two buttons shown before 1-1's request (rules 1, 7, Visual, OB-23; Dialogue rule 2 / RD-18). Also fixed: workbench auto-separator makes 1-2 two clicks and no typing (rule 3, OB-22, workbench rule 3 / QW-22); ghost text scope and data owner (1-2, 1-3 only); "Yes" mode keeps 1-1's prefill and shows the explainer on 1-1 (OB-02); minimal options panel owned by Onboarding; hint row and cross-references (store manual rules 4–6, workbench now cites rules 2, 3, 6); stale statuses. Re-review pending in a fresh session.

## Review — 2026-10-15 (re-review after cross-GDD review fixes, fresh session) — Verdict: NEEDS REVISION
Scope signal: S
Specialists: none (lean mode; fresh session, not the authoring session — each doc reviewed by a read-only subagent, blocking items verified against the text in the main session)
Blocking items: 1 | Recommended: 7
Summary: Prior blocker (guidance/question lines without a Dialogue kind) resolved; Day One naming, W6, W7 Esc, W16, W20, W9, W10, D6, S1 and the first_run/first_pass removal are in. One blocker: the coach marks and their ids were never enumerated, and the 1-2 Run/Submit condition read two ways.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Core Rules 3, 7 / OB-13: no enumerated mark list or mark ids (Playtest Log {mark} undefined); "used it once on their own" for 1-2 Run/Submit is ambiguous
- [RECOMMENDED] Edge Cases: "start over" line after an error loses to Dialogue's newest-wins rule; needs a queue exception
- [RECOMMENDED] Edge Cases / OB-07: start-over trigger ("error/feedback") vs Run-error-only AC
- [RECOMMENDED] Core Rules 6: Tab result on 1-3 ghost text unspecified (OB-09 covers 1-2 only)
- [RECOMMENDED] Interactions: Hint row direction "—" vs hint :154; Store Manual row direction vs manual :136
- [RECOMMENDED] Dependencies: bidirectionality note stale (Puzzle Definition now lists Onboarding; Progression, Playtest Log omitted)
- [RECOMMENDED] Partner citations stale: workbench :481 "rule 15", store manual :217 "Rules 4, 6"
- [RECOMMENDED] OB-19 "never writes editor text" vs rule 6 Tab/click materialisation
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md 924fc9d35924c9799db8a01a6760ee4780c4bb96
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-15, after the review; user decision "table + 1-2 schema only"): rule 7a table of the four Guided marks (`1-1.run`, `1-1.submit`, `1-2.schema`, `1-3.manual`) with target, label and Done condition — the mark id is the Playtest Log `{mark}` value; 1-2 has only the schema mark; unopened puzzle's mark stays Pending; States, the submit-before-run edge case and OB-13 updated. Status stays In Review; re-review in a fresh session.

## Review — 2026-10-15 (re-review, session 6c-2, fresh session) — Verdict: NEEDS REVISION
Scope signal: S
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 3
Summary: The 6c blocker is resolved as asked: rule 7a enumerates the four Guided marks (`1-1.run`, `1-1.submit`, `1-2.schema`, `1-3.manual`) with target, label and Done condition, the ids match the Playtest Log's `mark_shown/done/dismissed {mark}`, and 1-2 has only the schema mark (rule 3, OB-13). One new blocker came from the table: the mark Done conditions had no puzzle scope, so the Edge Case "opens the manual before the 1-3 mark appears" plus rule 8 / States "doing a later target early marks the earlier ones Done" let a player who opens the Manual on 1-1 lose `1-1.run`, `1-1.submit` and `1-2.schema` at once — contradicting the table's "opened on 1-3".
Prior verdict resolved: Yes (6c blocker: mark list and 1-2 condition)
Findings:
- [BLOCKING] Core Rules 7a, 8 / States / Edge Cases / OB-11, OB-13: Done conditions not scoped to their puzzle; the manual edge case and cross-puzzle "later target early" chain contradict the table and can wipe all guidance on 1-1
- [RECOMMENDED] Dependencies / Cross-References: statuses stale — Workbench, Dialogue, Store Manual, Hint System, Puzzle Definition Approved; bidirectionality note says Puzzle Definition "must list" Onboarding
- [RECOMMENDED] Core Rule 7: cites "workbench rule 15" for Esc precedence (carried over from 6c)
- [RECOMMENDED] Earlier 6c recommendations (start-over line queue, OB-07 trigger, 1-3 Tab result, Interactions directions, OB-19 wording) still open; not escalated
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md 44915518f83ceed2d5dc1142c445ad0c1b9dd73a
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-15, after the review; user decision "scope to the puzzle"): rule 7a — Done conditions count only while the mark's own puzzle is open; acting on a later mark's target on an earlier puzzle completes nothing; the only early completion is a Submit on 1-1 before any Run (`1-1.run` Done); `1-2.schema` reads "1-2's editor". Rule 8 and States restricted to the same puzzle; manual edge case split (on 1-1/1-2: nothing Done, 1-3 mark still shows; on 1-3 before the mark: Done, never shown); OB-11, OB-13 updated. Status stays In Review; re-review in a fresh session.

## Review — 2026-10-15 (re-review, session 6c-3, fresh session) — Verdict: APPROVED
Scope signal: S
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 2 new (earlier recommendations carried, not escalated)
Summary: The 6c-2 blocker is resolved: rule 7a's scope paragraph, rule 8 ("marks never complete across puzzles") and States ("same puzzle") agree that Done conditions count only while the mark's own puzzle is open; the single early completion is a Submit on 1-1 before any Run (`1-1.run` Done), consistent across the table, Edge Cases, OB-06 and OB-13. The manual edge case is split correctly (1-1/1-2: nothing Done, 1-3 mark still shows; 1-3 before the mark: Done, never shown) and OB-11/OB-13 test it. Mark ids match the Playtest Log's `mark_shown/done/dismissed {mark}`.
Prior verdict resolved: Yes (6c-2 blocker: puzzle scope of Done conditions)
Findings:
- [RECOMMENDED] Edge Cases (submit before run): "1-1.run is marked Done too, without being shown" — `1-1.run` shows when 1-1 opens; it is `1-1.submit` that is never shown; fix so `mark_shown` for `1-1.run` is not dropped
- [RECOMMENDED] Core Rule 7a (`1-3.manual`): the manual stays open across a request change (store manual Edge Cases); if it is already Open when 1-3 opens, the mark points at the button of an open panel — decide whether "already Open on 1-3" counts as Done
- [RECOMMENDED] Carried: Dependencies / Cross-References stale statuses and bidirectionality note; rule 7 "workbench rule 15"; 6c recommendations (start-over line queue, OB-07 trigger, 1-3 Tab result, Interactions directions, OB-19 wording) — for 6d
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md bc88a71f8ee063db020bd858af6034430b8d24c6
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084

## Review — 2026-10-15 (re-review 6e of the 6d rule changes, fresh session) — Verdict: APPROVED
Scope signal: S
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 2
Summary: Rule 1 order (briefing → question → 1-1, `request_open` after the answer) matches Dialogue rule 3c; the Guided suppression window (rule 7) closes on `1-3.manual` Done/Dismissed, Morning clock-out or coach marks off — a skipped, unavailable or withheld 1-3 still closes it via the Morning clock-out; rule 7a `1-3.manual` Done when the Manual is already open; OB-24/OB-25 testable. Workbench rule 6, store manual rule 6 / States / Edge Case and hint Interactions agree (three stale "coach-mark visibility" phrases in workbench / store manual / hint fixed in-session).
Prior verdict resolved: Yes (6c-3 APPROVED)
Findings:
- [RECOMMENDED] Core Rule 7: on 1-3 the hint "new step" indicator waits for `1-3.manual` Done/Dismissed (pre-6d behaviour too) — watch in the zero-SQL playtest
- [RECOMMENDED] Core Rule 7: whether turning coach marks back on reopens the window is unstated
Reviewed-Content-Hash: design/gdd/onboarding-first-shift.md 70e55a6cbe1d6b32f74827718fe59f260b23100a
Reviewed-Content-Hash: design/registry/entities.yaml 9bfe3fd10be0643425af7af9514ee5e77a2e56f2
