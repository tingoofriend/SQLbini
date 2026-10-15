# Cross-GDD Review Report

Date: 2026-10-15 (session 6d)
Mode: `since-last-review` (baseline `gdd-cross-review-2026-10-14.md`) — every
system GDD changed since the baseline, so the scope equals a full review;
consistency + design theory + scenarios; workflow tier `standard`
GDDs Reviewed: 11 of 11 present
Not read: none (Phase 3 read Puzzle Definition and Sandbox by search only; Phase 2 read both in full)
Also read: `game-concept.md`, `systems-index.md`, `design/registry/entities.yaml`
Systems Covered: Hidden-Data Grader, Puzzle Definition & Datasets, SQL Execution
Sandbox, Query Workbench, Hint System, Constraint Challenges, Shift & Chapter
Progression, Request & Reaction Dialogue, Store Manual, Onboarding: First Shift,
Playtest Log

**Baseline check:** B1–B3 and W1, W3–W7, W9–W13, W18–W23, S2, S3, S5, D2, D4,
D5, D7 still agree across documents. D1 holds only partly (G2), D6 partly (G1).

---

### Consistency Issues

#### Blocking
None.

#### Warnings
- ⚠️ **W-N1 Challenge-mode open/closed event: two owners.** `hint-system.md` Interactions named Constraint Challenges (Grader row) and Progression (Progression row, Downstream); Progression never claims it; Hint had no Constraint Challenges row. **Resolved (user): Constraint Challenges owns it** — hint-system.md fixed.
- ⚠️ **W-N2 Progression ↔ Workbench runtime coupling undeclared** (Restart, workbench rule 14 / draft-empty flag). Workbench Dependencies listed Progression as downstream only; systems-index Circular Dependencies lacked it. Fixed in both.
- ⚠️ **W-N3 Puzzle Definition omitted the Workbench as a `prefill_sql` reader.** Fixed.
- ⚠️ **W-N4 systems-index: Hint System's Sandbox lexer dependency missing** (Sandbox bottleneck count 7 → 8). Fixed.
- ⚠️ **W-N5 TOO_MANY_ROWS strip text: two owners.** Grader rule 6 / UI Req 4 said the strip shows `error_text`; Workbench rule 13 says no sandbox text, workbench string "{grader_row_cap}+ rows — too many to compare". **Resolved (user): Workbench is right** — grader rule 6, UI Req 4, Interactions; Dialogue Interactions, RD-09 fixed (TOO_MANY_ROWS carries no `error_text`).
- ⚠️ **W-N6 Sandbox edge case still had Dialogue showing SQLite text** (`sql-execution-sandbox.md` Edge Cases). Fixed (workbench strip shows it; bubble voices a gloss).
- ⚠️ **W-N7 Registry `grader_row_cap` note too broad** (hidden-only overflow is FAIL `generic`, not TOO_MANY_ROWS). Fixed.

#### Known 6d queue (from 6a–6c-3 reviews) — all applied
1. Grader Interactions / AC-19 and Playtest Log rule 4a cite hint rule 4a for `hint_counted` → **4b**.
2. Stale "In Review" statuses → **Approved** in Dependencies / Cross-References — present in **all 11** GDDs (not only the five listed), all fixed; Onboarding bidirectionality note updated.
3. Store Manual OQ1 rewritten for rule 3a (no conditional `watch_out`, `trap_rules` CI).
4. Sandbox rule 5a, Interactions, Downstream and bidirectionality list the Hint System as a `tokenize` consumer.
5. Constraint Challenges OQ2 (no hints in challenge mode); **rule 6c challenge draft** and **UNAVAILABLE in rule 9** (user decisions below).
6. Playtest Log rule 4a: `{mark}` = Onboarding rule 7a id; `manual_* {page}` = `manual.<slug>`; `hint_counted` cites rule 4b.
7. Dialogue rule 6: the "original text always shown" exception covers `TOO_MANY_ROWS`.
8. Progression: **rule 7a** repeated UNAVAILABLE; **`request_restart`** logged (user decisions below).
9. Onboarding: submit-before-run edge case (`1-1.run` was shown; `1-1.submit` is never shown); **`1-3.manual` when the Manual is already open** (user decision). The "workbench rule 15" citation in onboarding rule 7 is **correct** (Esc precedence is inside workbench rule 15); the stale citation was the reverse one — workbench Cross-References citing onboarding "rule 15" (→ rules 1, 2, 3, 6, 7) and store manual citing onboarding "Rules 4, 6" (→ 2, 4, 7, 7a). Both fixed.

#### Info (not fixed — carry forward)
- I4 Indicator-suppression edge direction differs between Hint / Store Manual / Onboarding Interactions rows (Onboarding → X vs Manual → Onboarding).
- I5 Workbench rules 1 / 6 / UI Req 1 do not say the Hint tab is hidden in challenge mode (Hint rule 12 and CC rule 11 do).
- I6 Dialogue state table: `PassReaction` names clock-out only after `skip.accept`, not after a normal PASS on a shift's last main request.
- I7 Concept / index challenge examples ("use BETWEEN", "no IN") omit the third Chapter 1 challenge; concept's "page per SQL keyword" predates `manual_pages`; row-cap string shortened in `query-workbench.md` UI and `sql-execution-sandbox.md` Formulas.
- Store Manual Summary still promises "the one thing people get wrong" although Chapter 1 omits trap-rule `watch_out` lines.

---

### Game Design Issues

#### Blocking
None.

#### Warnings
- ⚠️ **G1 (3b) "One new signal at a time" broke between coach marks** — suppression lasted only while a mark showed; 1-1's tutorial hints and "Reading the ledger" lit together in 1-1's PASS hold and again after `1-2.schema`. **Resolved (user): Guided suppression window** — indicators suppressed from 1-1's `request_open` until `1-3.manual` is Done/Dismissed, the Morning shift clocks out, or coach marks are turned off (onboarding rule 7, workbench rule 6, store manual rule 6 / States / Edge Case, hint Interactions; OB-24, QW-28).
- ⚠️ **G2 (3c) Alternating two junk queries beats the distinct-query rule** (`SELECT 1` / `SELECT 2` → skip offer in ~7 submits, boss included). **Resolved (user): accepted risk** — any text rule can be gamed; watched via time-to-skip and `boss_skip_rate` (Progression OQ1 note). No rule change.
- ⚠️ **G3 (3c, Vertical Slice) Feedback escalation rewards resubmitting one near-miss query** (level 3 counter-example in `2k` submits). **Resolved (user): deferred to VS** — grader OQ 9.

#### Info
- Counter strip may hold an offer ticket, a side-request ticket and the persistent "Leave it for Kenji" button at once; none has a location → `/ux-design`. Two "Leave it" controls appear at the moment of exhaustion.
- The locked-hint label ("after 2 wrong answers") does not explain that resubmitting the same query does not count.
- Wage is flavour; no exploitable economy (Progression OQ2 still open). No pillar or anti-pillar violations; player fantasies coherent.

---

### Cross-System Scenario Issues

Scenarios walked: 5
1. First minute of 1-1, zero-SQL player
2. Failed Submit → grader → hint → log → `exhausted` → Kenji's offer
3. UNAVAILABLE during Submit (main and challenge mode)
4. Restart mid-request (coach marks, hints, draft)
5. Constraint challenge after a clear (1-6 → Try it → leave)

#### Blockers
None.

#### Warnings
- ⚠️ **G4 Scenario 1 — Dialogue, Progression, Onboarding:** the shift briefing (up to ~4 pages) had no bubble state, no hand-off to the first request, and no order against "Ever used SQL before?". **Resolved (user):** Dialogue rule 3c + `Briefing` state (paged, click/Enter/Space, no timeout; first main request opens when it ends); Day One order briefing → question → 1-1 (Progression rule 11, Onboarding rule 1; RD-22).
- ⚠️ **G5 Scenario 5 — Constraint Challenges, Dialogue:** opening a side-request ticket during challenge mode was undefined (S-1 and 1-6 share the Afternoon shift). **Resolved (user):** tickets dimmed and unclickable in challenge mode (CC rule 6c, Dialogue rule 3b; CC-18, RD-22).
- ⚠️ **Scenario 3 — Progression, Grader, Dialogue (known 6d item):** repeated UNAVAILABLE left only the 11-minute time path out. **Resolved (user):** Progression rule 7a — first UNAVAILABLE on a main request queues Kenji's `skip.offer` after `error.CONTENT_ERROR`; accepting → `Unavailable` (excluded from completion / star, reopenable, `request_unavailable {source: submit}`); no offer on side requests or in challenge mode (PR-22; Dialogue queue exception extended).
- ⚠️ **Scenario 5 — challenge draft (known 6d item). Resolved (user):** own draft per challenge, seeded from the query that last passed the base puzzle, kept for the session, never touches the base draft (CC rule 6c, workbench rule 14; CC-18).
- ⚠️ **Scenario 4 — Restart not logged (known 6d item). Resolved (user):** `request_restart {state, draft_was_empty}` (Progression rule 12a, Playtest Log rule 4; PR-17). Hint Restart row now names the rule 4a comparison as reset.

#### Info (carry forward)
- Tanaka's "start over" line after an error is not in Dialogue's queue exception (newest-wins could replace the error line).
- `skip.offer` is an ordinary Reaction: an edit after `reaction_grace` ends it (the persistent button covers this).
- After UNAVAILABLE, the workbench enters `Editing` ("last results stale — dimmed") though nothing changed; when the "Content error — reported" strip clears is unstated.
- Dialogue does not subscribe to Restart: a `skip.offer` queued behind a fail line could still show after a Restart.
- "Try it" during the PASS hold on a shift's last main request vs "clock-out proceeds; the offer counts as Later" — no Chapter 1 instance; future content.

---

### GDDs Flagged for Revision

None. All findings were applied in-session; status stays **Approved** for all 11
(user instruction: wording/citation fixes are not re-approval items).

**Rule changes made from user decisions** (status kept Approved; listed so a
later `/design-review` can confirm them): Constraint Challenges (rule 6c, rule 9
UNAVAILABLE, CC-18), Shift & Chapter Progression (rule 7a, `Unavailable` state,
rule 9 exclusion, rule 11 briefing, rule 12a log, PR-22), Request & Reaction
Dialogue (rule 3b dimmed tickets, rule 3c / `Briefing` state, queue exception,
RD-22), Onboarding (rule 1 order, rule 7 suppression window, rule 7a `1-3.manual`,
OB-24, OB-25), Query Workbench (rule 6 window, rule 14 challenge draft), Store
Manual (rule 6 / States window), Playtest Log (event catalogue), Hint System
(event owner — interface only).

---

### Verdict: CONCERNS (at review time)

No blocking issues; 7 consistency warnings, 3 design warnings and 2 scenario
warnings, plus the 9-item known queue. All were resolved in-session from user
decisions (2026-10-15); the Info items above stay open.

**All 11 MVP GDDs are Approved** (systems-index and every GDD header).
