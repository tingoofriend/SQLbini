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
