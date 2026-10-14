# Concept Prototype Report: SQLbini

> **Date**: 2026-10-14
> **Prototype Path**: HTML
> **Concept File**: design/gdd/game-concept.md

---

## Hypothesis

"If players — including SQL beginners — write, run, and submit queries against
konbini requests graded on hidden data, they will find the loop satisfying
enough to finish Chapter 1 — evidenced by testers completing Chapter 1 and
choosing to continue."

---

## Riskiest Assumption Tested

- **Design**: that hidden-data grading turns a failed submit into an "aha"
  rather than frustration (Pillar 1). **Not exercised** — no tester failed a
  hidden-data check, so the moment never occurred.
- **Design**: that players with no SQL can get started. **Not tested** — every
  tester had some SQL experience.
- **Technical** (answered separately): Godot 4.7.2 + godot-sqlite + CodeEdit can
  host and grade the puzzles — **YES**, see
  `prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md`.

---

## Approach

The web prototype was built before the studio project (sql.js + Chapter 1 data
from `ch1.py`, 11 main + 2 side puzzles) and copied in unchanged.

**Path chosen:** HTML
**Reason for path:** Logic puzzle — timing and feel are not the hypothesis;
clarity and the solve loop are.

**Shortcuts taken (intentional):**
- No art, audio, or character portraits; requests as plain text
- No hints, rewind, or constraint challenges
- Runs in a browser, sql.js from a CDN

---

## Result

Reported by the developer after an in-person session (no observation log was kept):

- **Testers**: 2–3, all with **some SQL experience**
- **Completion**: all finished **Chapter 1**
- **Stuck points**: none reported
- **Hidden-data failures**: **none** — no tester ever passed visible data and
  then failed a hidden dataset
- **Retention**: all said they were **willing to play more**
- **Self-report**: "interesting" (흥미롭다)
- Developer's read: Chapter 1 was manageable for them — "챕터 1이어서 할만했었던듯"

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | HTML |
| Iterations to playable | N/A |
| Prototype duration | Built pre-studio; one playtest session |
| Playtesters | 2–3 external (friends/acquaintances), some SQL experience |
| Feel assessment | No friction reported; difficulty felt manageable; no hidden-data failures |
| Hypothesis verdict | PARTIALLY CONFIRMED |

---

## Recommendation: PROCEED (conditional)

Every tester finished Chapter 1 without getting stuck and wanted to continue,
so the core write-run-submit loop holds attention and the interface is clear —
nothing in the result argues for a pivot. But the session did not test the
game's differentiator: with zero hidden-data failures, the "matches the screen
but not the condition" lesson (Pillar 1) never fired, and with no zero-SQL
testers the biggest design risk in the concept is still open. Proceed to design,
carrying both as explicit conditions.

**Conditions carried forward**
1. **Trap difficulty** — Chapter 1 traps did not catch players with some SQL.
   The puzzle GDD must make at least the key traps (1-6 AND/OR, 1-11
   parentheses) bite for that audience, and define how often a player should
   expect a hidden-data failure.
2. **Zero-SQL playtest** — before the demo build, test with 1–2 people who have
   never written SQL; keep an observation log this time.

---

## If Proceeding

- **Core tuning values discovered:** none measured. Qualitative: Chapter 1
  difficulty is comfortable — possibly too comfortable — for players with some SQL.
- **Assumptions confirmed:** the request → query → result loop is understandable
  without explanation; players want more after Chapter 1.
- **Assumptions disproved:** "most trap answers pass on the visible data and
  fail on hidden data" (chapter-1-puzzles.md) assumed players would write those
  traps; these testers did not.
- **Emergent mechanics:** none observed.

**Next steps:**
1. `/design-review design/gdd/game-concept.md`
2. `/gate-check`
3. `/map-systems`
4. `/design-system [mechanic]` (use learnings in Tuning Knobs and Formulas sections)

---

## Lessons Learned

- **What assumptions were broken by actually building this?**
  That the visible-pass / hidden-fail trap would be the common experience. For
  testers with some SQL it never happened.
- **What surprised us that didn't show up in the brainstorm?**
  Zero stuck points across the whole chapter — the difficulty floor may be too low
  for the "Challenge & Mastery" goal chosen in the brainstorm.
- **What would we test differently next time?**
  Recruit at least one zero-SQL tester; keep a timestamped observation log;
  record which queries testers actually submitted, so trap coverage can be measured.

---

> *Prototype code location: `prototypes/sqlbini-web/`*
> *This code is throwaway. Never refactor into production.*
