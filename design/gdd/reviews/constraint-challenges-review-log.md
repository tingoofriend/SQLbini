# Review Log: constraint-challenges

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 6
Summary: The token-based rule check (literals, quoted identifiers incl. `[…]`, comments skipped — matches the sandbox lexer), the spacing-proof canonical length and the witness/reference content gate are strong and testable. Two defects block: 1-4's `require(BETWEEN)` is offered right after 1-4, four puzzles before `BETWEEN` is taught (1-8) and before its manual page unlocks — against the GDD's own "substitute the player already knows" guidance, and it confounds the MVP "starts a challenge when offered" signal; and the post-PASS offer prompt contradicts Progression's "next request arrives with no intervening menu" (rule 11, PR-15), with the return flow after Try it / Cleared / leaving undefined.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rule 1 / Formulas Chapter 1 set: 1-4 `require(BETWEEN)` offered before `BETWEEN` is taught (1-8) or its manual page unlocks; keep it `Hidden` until 1-8 is passed (offer then), or choose another rule for 1-4
- [BLOCKING] Core Rule 6 vs `shift-and-chapter-progression.md` rule 11 / PR-15: offer prompt is an intervening menu; also undefined — where the player goes after Try it → Cleared or leaving, and offer vs clock-out order when a shift's last main request carries a challenge (none in Chapter 1, possible later) — resolve jointly with Progression
- [RECOMMENDED] Overview: "start a challenge unprompted" vs rule 6 (Try it on the offer counts) — the concept's threshold reads "unprompted when offered"; state which Playtest Log source counts
- [RECOMMENDED] Core Rule 9: effect of challenge-mode FAIL on the grader's per-cause counters / feedback escalation and on hint counters of an already-PASSED puzzle is unspecified
- [RECOMMENDED] States: replay of a `Cleared` challenge (attempting while Cleared, leaving) not in the table; "per save" header vs MVP per-session
- [RECOMMENDED] Rule 3 `max_chars`: unused in MVP yet specified and tested (CC-04/05) — consider deferring implementation to the first chapter that uses it (scope-check FAIL context); keep the formula
- [RECOMMENDED] Dependencies / Cross-References: "Designed (pending review)" statuses stale
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`; Game Feel covers fantasy; recommended `N` slack of +4 is a knob)
Reviewed-Content-Hash: design/gdd/constraint-challenges.md 5353ffe16ab9773ac400667df05a378c06413a81
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review; user decisions: inline non-blocking offer; 1-4 opens silently after 1-8): BLOCKING 1-4 fixed — new optional `unlock_after` (rule 2a; 1-4 `unlock_after: 1-8`; verifier check; CC-15; field added to `puzzle-definition-and-datasets.md`). BLOCKING flow fixed — offer attached inline to the PASS reaction, next request arrives at once, ignored offer counts as Later (rule 6); return to the open main request after challenge mode (rule 6a, CC-16); Progression rule 11 / PR-15 amended. Also fixed: "unprompted when offered" wording, separate per-challenge counters (rule 9, CC-17), Cleared replay states, per-session at MVP, stale statuses, Tuning Knobs section. Not done: deferring `max_chars` implementation (scope suggestion left to the user); Player Fantasy (advisory). Re-review pending in a fresh session.
Follow-up (2026-10-14, user decision): `max_chars` implementation deferred to Alpha — rule 3, rule 8 live count, CC-04 and the `max_chars` part of CC-05 marked Alpha; MVP verifier rejects `max_chars` constraints (CC-12). Formula kept.

## Review — 2026-10-14 (re-review, session 6b, fresh session) — Verdict: APPROVED
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 6
Summary: Both prior blockers are resolved: 1-4's `require(BETWEEN)` opens silently after 1-8 via `unlock_after` (rule 2a, CC-15, Puzzle Def field), and the offer is inline in the PASS reaction with an offer ticket and expiry, matching Progression rule 11 / PR-15 and Dialogue rule 3a / RD-17. Cross-review B3 is fixed (UI Req 4 and CC-02 follow rule 6a). Challenge-mode rules agree across Hint rule 12, CC rules 6a/6b/11, Progression rule 11 / PR-20: Hint button hidden ("No hints for dares."), main request stays Open with its hint clock paused, return to the open main request; challenge FAILs use the per-challenge counter set (grader rule 5/13).
Prior verdict resolved: Yes (2026-10-14 blockers 1–2)
Findings:
- [RECOMMENDED] Open Questions 2: "MVP reuses the base puzzle's hints" contradicts rule 11 (no hints in challenge mode) — reword as "MVP: none"
- [RECOMMENDED] Core Rule 9 / States: an UNAVAILABLE verdict in challenge mode is not listed (expected: stays `Attempting`, nothing counted)
- [RECOMMENDED] Core Rule 6a: editor content on Try it (base draft vs separate challenge draft) and whether it survives leaving is unstated
- [RECOMMENDED] Core Rule 9.3 / Visual: on PASS + rule broken, whether the PASS stamp lands, and the sticky note's exact text vs the voiced `challenge.rule_broken` line (avoid repeating "uses {keyword}" in both)
- [RECOMMENDED] Dependencies / Cross-References: upstream statuses "In Review" — Grader, Puzzle Def, Sandbox, Workbench are Approved
- [RECOMMENDED] Player Fantasy absent (advisory at `standard`)
Reviewed-Content-Hash: design/gdd/constraint-challenges.md 944b238e205c64aed6450f9ebbe147139b0f41fa
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
