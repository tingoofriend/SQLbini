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
