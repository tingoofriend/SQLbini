# Gate Check: Systems Design → Technical Setup

**Date**: 2026-10-15 (session 7)
**Checked by**: gate-check skill
**Config**: workflow standard · review_mode lean · qa.level standard · team.size individual
**Previous gate**: `2026-10-14-concept-to-systems-design-rerun.md` — CONCERNS (risks accepted)

### Required Artifacts: 2/2 present
- [x] `design/gdd/systems-index.md` — 19 systems, 11 MVP; all 11 MVP rows `Approved` (after the 6g check, 2026-10-15)
- [x] All 11 MVP GDDs in `design/gdd/`, each with a review log in `design/gdd/reviews/`; every header `Approved` (index and headers cross-checked)

### Recommended (standard tier): 1/1 present
- [x] Cross-GDD review report — `design/gdd/gdd-cross-review-2026-10-15.md` (6d): CONCERNS, 0 blockers, all warnings resolved in-session; Info items carried forward

### Quality Checks: 6/6 passing
- [x] MVP GDDs pass individual design review at `standard` — `gdd-structure-check.sh`: Overview, Detailed Rules, Edge Cases, Dependencies, Acceptance Criteria present in all 11; Formulas present in the 8 that define numeric rules (Progression, Onboarding, Store Manual state "no numeric rules"); no MAJOR REVISION verdict. Latest verdicts: 6a–6c-3 APPROVED; 6e APPROVED (CC, Onboarding); 6g APPROVED (Progression, Dialogue — light check of the 6f fixes, 0 blockers, 2 wording fixes in place)
- [x] `/review-all-gdds` verdict not FAIL (CONCERNS)
- [x] Cross-GDD issues resolved or explicitly accepted — warnings resolved (6d); Info items explicitly accepted (see Accepted Risks)
- [x] Dependencies mapped (Depends-On column, dependency map, runtime couplings) and bidirectional (6d Phase 2; 6g fixed the Onboarding ↔ Progression row)
- [x] MVP priority tier defined
- [x] No stale GDD references — 6g grep of the changed side-request timing terms across `design/gdd/`: none left

### Artifact-check observations
`artifact-check.sh --phase systems-design`: review-all-gdds PRESENT (2); design-system, design-review, consistency-check NO_CHECK → verified manually (index + headers + review logs above). `project-coherence.sh`: 6 checked, 1 differs (gdUnit4 not installed — `commands.test` cannot run). Uncommitted at check time: the 6g edits (6 files).

### Info items and /ux-design deferrals — gate impact
Not gate blockers (no rule conflict, no implementation stop):
- 6d consistency Info I4–I7 and the Store Manual Summary wording — wording / table-direction only
- 6d scenario Info (start-over line queue, `skip.offer` grace, UNAVAILABLE → Editing dimming / strip lifetime, Dialogue not subscribed to Restart, "Try it" on a shift's last main) and 6e recommendations (Restart scope omits `Unavailable`, "Leave it for Kenji" lifetime, `puzzle_active_time` end events, CC seed owner, onboarding 1-3 indicator)
- `/ux-design` items (counter-strip ticket/button layout, "Leave it for Kenji" location, briefing focus, hint panel slot, visible-data view) — required by the next gate (Technical Setup → Pre-Production)

## Director Panel Assessment

Panel: 2 of 4 (`workflow: standard`). Creative and Art perspectives not consulted.
Raise `modes.rigor` to `full` (or set `modes.workflow: full`) for the complete panel.

Technical Director: READY
  Systems index and dependency layering are enough to architect from (Foundation: Puzzle
  Definition, Sandbox; Core: Grader, Workbench). Sandbox timeout requirement is stated
  (SB rule 15) without fixing the mechanism — correct for this phase. Carry into
  Technical Setup: sandbox-timeout ADR (abandoned worker thread / separate process /
  step cap; prove against SB-18); Windows godot-sqlite .dll spike on 4.7.2; viewport
  1280×720 + 4.7 stretch defaults, renderer, 64 MB texture ceiling as a budget; install
  gdUnit4, set `commands.build`; architecture doc + Foundation ADRs (puzzle data
  format, Sandbox API / lexer contract, Playtest Log event bus).

Producer: CONCERNS
  Design side ready; concerns are schedule baseline and process hygiene, none blocks
  entry. Prior risks: (1) MVP estimate — resolved (scope-check, re-baseline ~11 weeks,
  7–18) but predates the written GDDs; (2) MVP + Demo only — open, accepted by design;
  (3) grader first — resolved; (4) zero-SQL playtest undated — open; (5) concept
  re-review — open (hash 9893a9c ≠ last reviewed 8f0e4dd; last verdicts NEEDS REVISION).
  Also: re-estimate MVP after the first architecture pass; time-box design churn
  (6a–6g re-review cycle); Chapter 1 requests 1-4/1-5/1-7/1-8 still state boundary
  values (rewrite before the playtest).

### Concept-gate accepted risks — status
| # | Risk (2026-10-14) | Status |
|---|---|---|
| 1 | MVP estimate optimistic | Resolved — re-baselined ~11 weeks (7–18); re-estimate recommended after architecture |
| 2 | Only MVP + Demo committed | Open — accepted by design |
| 3 | Grader GDD not ordered first | Resolved — design order #1, designed first |
| 4 | Zero-SQL playtest not dated | Open |
| 5 | Concept last revision not re-reviewed | Open — verified by hash |

### Blockers
None.

### Recommendations
- Commit the 6g edits and this report
- `/design-review design/gdd/game-concept.md` (risk 5) when convenient — fresh session
- Date the zero-SQL playtest; rewrite Chapter 1 requests 1-4/1-5/1-7/1-8 before it
- Technical Setup work: the TD carry-forward list above; then `/estimate` re-run
- Fold the Info / 6e recommendations into `/ux-design` or implementation instead of another review cycle

### Verdict: CONCERNS
Chain-of-Verification: 5 questions checked (3 with tool re-checks: concept content hash,
Approved count in the index, uncommitted state) — verdict unchanged.

### Accepted Risks
Accepted by the user, 2026-10-15, on advancing to Technical Setup:
- Concept's last revision has not been re-reviewed (last verdict NEEDS REVISION; content changed since)
- Zero-SQL playtest is still not dated
- MVP estimate (~11 weeks, 7–18) predates the written GDDs — re-estimate after the first architecture pass
- Only MVP + Demo are committed; Alpha and Full Vision remain unvalidated
- Cross-GDD Info items (6d I4–I7, Store Manual Summary, scenario Info) and the 6e open recommendations are carried forward, not fixed; `/ux-design` deferrals stay with `/ux-design`
- Producer process concern: design churn across 6a–6g — time-box further GDD changes during Technical Setup
