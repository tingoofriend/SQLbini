# Review Log: game-concept

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: L
Specialists: none (lean mode; reviewed by the same session that authored the document — no independent reviewer)
Blocking items: 3 | Recommended: 4
Summary: The concept template is complete and the pillars are coherent, but the document predates the engine decision and the playtest, and its core fantasy depends on a "fell for the trap" moment no tester experienced. The submit-feedback design (missing/extra rows) also leaks hidden-dataset rows, which undermines Pillar 1.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Technical Considerations / Open Questions / Next Steps / Status: stale — engine shown as "Undecided", the fun question and playtest shown as open, Next Steps lists finished work, Status still Draft
- [BLOCKING] Core Fantasy / Key Dynamics / Flow State: assume players fall for the visible-pass/hidden-fail trap; playtest (prototypes/sqlbini-web/REPORT.md) had zero hidden-data failures and no zero-SQL tester
- [BLOCKING] Core Mechanics #2 / Pillar 1: showing exact missing/extra rows from hidden datasets leaks the hidden data, letting players special-case it (seen in spike screenshot: extra Corn Puff Stick,40)
- [RECOMMENDED] Core Identity vs Core Loop: session/puzzle timings disagree (3–5 puzzles per 30–60 min shift; 5–15 min per puzzle; demo 13 puzzles ≈ 1 hour)
- [RECOMMENDED] Scope Tiers: 37 further puzzles with hand-built hidden edge cases plus modify/rewind in about 4–6 months is unreviewed (PR-SCOPE skipped in lean mode)
- [RECOMMENDED] Pillar 2: "any query that meets the condition is correct" needs a definition — correctness here means passing a finite set of hidden datasets
- [RECOMMENDED] Inspiration / Market: comparable-title claims were not researched; no Steam competitor check done
Reviewed-Content-Hash: design/gdd/game-concept.md 6d6b1c0592667425c927e39d6c3fa2ab2cc5fde8
Reviewed-Content-Hash: design/registry/entities.yaml 216ffa67ed4d5d24548df37b2ce899fcba892285

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: L
Specialists: game-designer, systems-designer, ux-designer, qa-lead, creative-director (senior)
Blocking items: 6 | Recommended: 4
Summary: Pillars, hook and anti-pillars hold. Most specialist BLOCKING items belong to later system GDDs (grader, hints/UX, verification, puzzle content). Six concept-level issues remain; the most important is that the Core Fantasy's example contradicts Chapter 1, whose requests spell out their boundaries — likely why no tester failed a hidden-data check.
Prior verdict resolved: Partly — the 3 prior blockers were addressed; new concept-level issues found by independent review
Findings:
- [BLOCKING] Core Fantasy: example ("under 200 yen" missed the 200-yen drink) contradicts puzzle 1-5 ("200 yen or less"); add trap philosophy (natural store language, data-semantic traps)
- [BLOCKING] Key Dynamics: "players probe boundaries themselves" has no mechanic — reword or commit to a throwaway scratch-data copy
- [BLOCKING] Unique Hook: "no looks-right query survives" overclaims vs Pillar 2's finite approximation
- [BLOCKING] Core Mechanics #2 / Flow: feedback needs an escalating-specificity principle; Run must never show a pass state
- [BLOCKING] MVP Definition / Core Fantasy conditions: hypothesis and conditions not measurable — add thresholds and fallbacks (3 zero-SQL + 3 some-SQL testers, observed log)
- [BLOCKING] Target Player vs Anti-Pillars: zero-SQL audience has no syntax path under "NOT a textbook" — narrow audience or allow an in-world reference
- [RECOMMENDED] Core Identity vs Core Loop: session length 30–60 vs 30–120 min
- [RECOMMENDED] Visual Identity Anchor: colour philosophy should state "never colour alone"
- [RECOMMENDED] Scope Tiers: Alpha still unreviewed — flag producer scope review
- [RECOMMENDED] technical-preferences.md Platform Notes: "IME-free ASCII" note is wrong for Korean/Japanese layouts
Reviewed-Content-Hash: design/gdd/game-concept.md 8f0e4ddef819adbdfe448ecc514c941d77505fda
Reviewed-Content-Hash: design/registry/entities.yaml 216ffa67ed4d5d24548df37b2ce899fcba892285
