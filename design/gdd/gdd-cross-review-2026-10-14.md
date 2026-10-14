# Cross-GDD Review Report

Date: 2026-10-14
Mode: full (consistency + design theory + scenarios), workflow tier `standard`
GDDs Reviewed: 11 of 11 present
Not read: none
Also read: `game-concept.md`, `systems-index.md`, `design/registry/entities.yaml`,
`design/levels/chapter-1-puzzles.md`, `prototypes/sqlbini-web/ch1.py` (data only, not run)
Systems Covered: Hidden-Data Grader, Puzzle Definition & Datasets, SQL Execution
Sandbox, Query Workbench, Hint System, Constraint Challenges, Shift & Chapter
Progression, Request & Reaction Dialogue, Store Manual, Onboarding: First Shift,
Playtest Log

Registry: 11 of 11 entries checked (2 formulas, 9 constants); every value matches
its source GDD. `referenced_by` lists are incomplete; entities/items are empty.
Balance data (`assets/data/**`, `design/balance/**`) absent — no data-level
balance pass was possible (outside this skill's scope).

---

### Consistency Issues

#### Blocking (must resolve before architecture begins)

🔴 **B1 — CONTENT_ERROR: three player-facing behaviours, one leaks hidden data**
`hidden-data-grader.md:368-372` shows a fixed "can't check this one right now"
line with no hidden-data detail; `request-and-reaction-dialogue.md:131` voices
Kenji's "ledger is smudged" line **and shows the raw text**;
`sql-execution-sandbox.md:285` returns "the build message", which can name hidden
keys (`puzzle-definition-and-datasets.md:441-443`). The grader's `submit_verdict`
enum (`:257`) has no outcome for an abandoned submit, but the workbench state
machine expects a verdict (`query-workbench.md:158`).
**Resolution (user, 2026-10-14):** Kenji's line is canonical; no raw text reaches
the player (build message → log / content-bug report only); sandbox returns a
fixed `error_text`; grader gains an `UNAVAILABLE` outcome. Fix: grader, sandbox,
dialogue, workbench.

🔴 **B2 — `manual_keywords` contract cannot map non-keyword pages**
`puzzle-definition-and-datasets.md:71` defines "SQL keywords"; the Store Manual
unlocks pages from it (`store-manual.md:82-83`) but pages such as "Picking
columns" (`,`) and comparison operators have no keyword.
**Resolution (user):** replace with `manual_pages` — a list of page ids
(`manual.<slug>`). Fix: puzzle-definition, store-manual, registry.

🔴 **B3 — Leaving challenge mode returns to two different places**
`constraint-challenges.md:90-95` (rule 6a), CC-16 and
`shift-and-chapter-progression.md:121-122` return to the open main request;
`constraint-challenges.md:336` (UI Requirement 4) and CC-02 (`:365`) return to the
base puzzle view. **Resolution:** rule 6a is authoritative; fix UI Req 4 and CC-02.

#### Warnings (should resolve, but won't block)

Interface contracts
- ⚠️ W1 "Too many rows" SUBMIT_ERROR has no key on the Grader→Dialogue interface (`hidden-data-grader.md:290`, `sql-execution-sandbox.md:133-143`, `request-and-reaction-dialogue.md:130`, RD-05).
- ⚠️ W2 Hidden-dataset `truncated` result undefined in grading (`hidden-data-grader.md:254`, `sql-execution-sandbox.md:277`).
- ⚠️ W3 Challenge-mode fail counters: grader rule 5 (caller supplies counters) vs rule 13 / state table (grader keeps per-puzzle counts) vs `constraint-challenges.md:105-109`.
- ⚠️ W4 Constraint Challenges assumes a sandbox token API (`constraint-challenges.md:69-72,200`) that the sandbox does not define (`sql-execution-sandbox.md:70-74`); CC missing from sandbox downstream.
- ⚠️ W5 Fail/error text drawn twice with different lifetimes (grader sticky note `:435-441`, workbench strip `query-workbench.md:109-112`, bubble `request-and-reaction-dialogue.md:82-87,113-116`). **Resolution (user):** bubble = voiced line (temporary); note/strip = neutral symptom or SQLite original text, until edit; no line duplicated.
- ⚠️ W6 Empty-editor Run: four texts, two speakers (`query-workbench.md:279`, `request-and-reaction-dialogue.md:61,125`, `hidden-data-grader.md:303`, `onboarding-first-shift.md:85`). Dialogue owns templates.
- ⚠️ W7 Esc meaning while a coach mark shows (`onboarding-first-shift.md:98` vs `query-workbench.md:127`).
- ⚠️ W8 Hint panel has no layout slot (`hint-system.md:272-274` vs `query-workbench.md:352-356`; manual panel covers results, `store-manual.md:92-93`) → `/ux-design`.
- ⚠️ W9 Store Manual says Onboarding marks the Manual button on 1-1; Onboarding does it on 1-3 (`store-manual.md:87,124` vs `onboarding-first-shift.md:69-71`).
- ⚠️ W10 1-1 prefill has no data owner (`onboarding-first-shift.md:52`, `store-manual.md:72-76`, `shift-and-chapter-progression.md:131`).
- ⚠️ W11 Challenge clear / rule-broken lines have no string id; interface direction reversed (`request-and-reaction-dialogue.md:172` vs `constraint-challenges.md:158`).
- ⚠️ W12 Constraint offer location: UI Req 1 says message log (`constraint-challenges.md:333`) vs bubble + ticket (rule 6, dialogue rule 3a).
- ⚠️ W13 Playtest `line_shown` carries `puzzle_id` in RD-16 but the canonical catalogue uses the common `puzzle` field (`playtest-log.md:71`); `run.match` enum all/partial/none vs boolean match bit; `run.data` collides with the common `data` object.

Dependencies / index
- ⚠️ W14 systems-index Depends-On column disagrees with 8 GDDs (Sandbox, Workbench, Hint, Challenges, Progression, Dialogue, Store Manual, Playtest Log); bottleneck/leaf lists stale.
- ⚠️ W15 Index states "no runtime cycles"; Hint↔Progression (exhausted / Restart) and Progression↔Challenges exist.
- ⚠️ W16 Onboarding's bidirectionality ✓ is false for Hint System; Onboarding missing from Puzzle Definition and Progression interaction tables; Store Manual missing from Dialogue's.
- ⚠️ W17 systems-index counts (11 vs 12 MVP systems, "4–6 weeks" vs ~11 weeks) and one-line summaries stale ("no failure possible in 1-1").

Knobs / formulas / ACs
- ⚠️ W18 `R_cap` is a knob in the grader (1,000–50,000) but hardcoded 5000 in sandbox and workbench strings.
- ⚠️ W19 Sandbox TIMEOUT delivery (limit 150 + 50 ms) consumes the whole 200 ms Run budget.
- ⚠️ W20 QW-15 (first submit shows explainer on fresh profile) vs OB-05 (Guided: explainer on 1-2, not 1-1).
- ⚠️ W21 Workbench MVP ACs QW-01/19/25/26 require Chapter 2 / Back Room (Alpha).
- ⚠️ W22 Grader AC-03 expects "raw SQLite text" where the sandbox returns fixed messages.
- ⚠️ W23 Frame budget 16.6 ms (PL-08) vs ≤ 33 ms (SB-19).
- ⚠️ W24 `idle_cutoff_s` defined in Hint and Playtest Log; Hint makes every knob per-puzzle overridable.

Concept / registry / terminology
- ⚠️ W25 Concept stale: challenge examples ('no OR', 'under 60 characters'; `game-concept.md:141`, also index `:30`); "passing shows efficiency stats" (`:187`); "MVP includes the back room" (`:418`); "the day's wage" (`:193`).
- ⚠️ W26 Shift length: concept 30–60 min per shift vs Progression 3/4/4 split at ~4.6 min/puzzle (≈ 15–18 min) — Progression OQ3.
- ⚠️ W27 "First Shift" names both Chapter 1 (3 shifts) and the Onboarding system (Morning shift). **Resolution (user):** Chapter 1 → "Day One".
- ⚠️ W28 "Cause hint" (concept, level doc) collides with the Hint System; use "cause feedback".
- ⚠️ W29 Registry `referenced_by` incomplete (`result_match`, `feedback_level`, `grader_row_cap`, `visible_rows_max`, `feedback_max_level`, `contrast_min`, `feedback_fails_per_level`); cross-doc constants unregistered (`idle_cutoff_s`, Run/Submit budgets, `strip_h`, `rows_visible`, `reaction_hold`, `ui_scale`, `hardcode_proof` formula).
- ⚠️ W30 `visible_rows_max` 30 has three statuses (registry "UX must confirm", Puzzle Def OQ 6, Workbench "accepted"); root cause: no dedicated visible-data view → `/ux-design` (scope decision for the user).
- ⚠️ W31 Status headers/columns stale (grader and puzzle-def "In Design"; several Cross-Reference status cells "Designed").

Info (selected): 16 vs 15 traps — **15 is correct** (`chapter-1-puzzles.md:175` miscount; closes Puzzle Def OQ 5); grader "chapter menu" vs "chapter list"; Hint cites "Progression rule 12" for Restart (is 12a); grader PRAGMA wording vs sandbox (all PRAGMA rejected); hint example manual page name; boss defined by position and by flag; Onboarding `first_run`/`first_pass` events duplicate Playtest formulas; Kenji also a requester (1-10); level-3 rows "Vertical Slice" vs Back Room Alpha; constraint "parameter" vs `value`; offer-expiry wording; minor `;` and "Ever used SQL (before)?" variance; registry `feedback_level` note overstates Hint's input; cast/trap ids not registered.

---

### Game Design Issues

#### Blocking
None.

#### Warnings
- ⚠️ D1 (3c) **Junk submits reach Kenji's skip in ~7 submits, boss included** — every FAIL counts for hint unlocking (`hint-system.md:232`); `SELECT 1` fails. **Resolution (user):** a FAIL counts toward hint unlocking / `exhausted` only when its query text differs from the previous counted FAIL's.
- ⚠️ D2 (3a) Playtest "Finish" claim counts skipped puzzles (`playtest-log.md:193-196`) — report skip count beside the claim.
- ⚠️ D3 (3e) Hint thresholds tuned to ~4.6 min/puzzle while concept says 5–15 min; boss 1-11 uses defaults → per-puzzle override for 1-11 (Progression OQ1).
- ⚠️ D4 (3e/3f) Manual `watch_out` on the AND/OR page could pre-solve the 1-6/1-11 traps measured by "Traps bite".
- ⚠️ D5 (3b) Fail moment shows 6–7 active regions (see W5 resolution).
- ⚠️ D6 (3b) First minute of 1-1: coach mark + hint indicator + manual "new" indicator at once.
- ⚠️ D7 (3c/3b) Challenge mode: hints frozen but label promises unlocking.

Info: wage unresponsive to performance (Progression OQ2 / Dialogue OQ2 defer to each other); no return hook at MVP (acceptable for playtest); 1-3 hardcode lesson unlikely to trigger; onboarding line "Looks right. Hand it to me — Submit" models Run-then-Submit habit; Kenji's boss skip weakens the competence fantasy (accepted trade-off). Pillar alignment: every GDD declares pillars; no anti-pillar violations.

---

### Cross-System Scenario Issues

Scenarios walked: 5
1. First minute, zero-SQL player, 1-1
2. Failed Submit → grader → dialogue → hint → log → exhausted → Kenji offer
3. SQL error on Run → sandbox `error_kind` → dialogue + raw
4. Boss 1-11 fail/skip → progression → wage
5. Constraint challenge after clearing 1-6

#### Blockers
None.

#### Warnings
- ⚠️ S2 — Grader, Hint, Progression, Dialogue: a FAIL that also latches `exhausted` sends the `fail` line and Kenji's `offer` in one frame; "only the newest is shown" (`request-and-reaction-dialogue.md:274`) loses one. Queue: fail line, then offer.
- ⚠️ S3 — Workbench, Dialogue: EMPTY speaker/text conflict (W6).
- ⚠️ S5 — Challenges, Progression, Dialogue, Hint: which request the bubble shows in challenge mode, and whose hint `active_time` accrues, are undefined; typing during a PASS hold races auto-advance.
- ⚠️ S1 — Onboarding, Hint, Manual: three "new" signals at once (D6).

#### Info
- S1: unclear whether `request_open` (manual/hint unlocks) fires before or after "Ever used SQL?"; Tanaka's "start over" line has no channel.
- S2: Kenji's persistent skip button has no location.
- S4: transition from accepting the boss skip to the payslip undefined.
- S5: offer expiry "another request is opened" read literally expires on 1-7's automatic arrival; payslip line for a challenge cleared in a later shift undefined.

---

### GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| hidden-data-grader.md | B1 UNAVAILABLE outcome; W1–W3, W5, W18, W22 | Consistency | Blocking |
| sql-execution-sandbox.md | B1 fixed error_text; W4 lexer tokens; W18–W19, W23 | Consistency | Blocking |
| request-and-reaction-dialogue.md | B1 no raw text; W1, W5–W6, W11, W13, S2 queue | Consistency | Blocking |
| puzzle-definition-and-datasets.md | B2 manual_pages; W10 prefill field | Consistency | Blocking |
| store-manual.md | B2 manual_pages; W9 | Consistency | Blocking |
| constraint-challenges.md | B3 return target; W4, W11–W12, D7 | Consistency | Blocking |
| query-workbench.md | B1, W5–W7, W18, W20–W21, W30 | Consistency | Warning |
| hint-system.md | D1 distinct-query rule; W24, D7, S5 | Design Theory | Warning |
| shift-and-chapter-progression.md | W27 Day One; S5 challenge-mode state; W15 | Consistency | Warning |
| onboarding-first-shift.md | W6–W7, W16, D6 | Consistency | Warning |
| playtest-log.md | W13, W23, D2 | Consistency | Warning |
| game-concept.md | W25–W28 | Consistency | Warning |
| systems-index.md | W14–W17 | Consistency | Warning |

---

### Verdict: FAIL

Three blocking consistency issues (B1–B3). All have user-chosen resolutions
(2026-10-14) and are being applied in the same session; the affected GDDs then
need fresh-session `/design-review` before Approved.

### If FAIL — required actions before re-running:
1. B1 — grader: add `UNAVAILABLE` verdict (no state/counter change, no error text); sandbox: fixed `error_text` for CONTENT_ERROR, build message to log only; dialogue: Kenji line, no raw text; workbench: handle `UNAVAILABLE`.
2. B2 — puzzle-definition: `manual_keywords` → `manual_pages` (page ids); store-manual rules 1, 5 and SM-02 updated; registry updated.
3. B3 — constraint-challenges: UI Requirement 4 and CC-02 follow rule 6a.

### Deferred to `/ux-design` (scope decisions — ask before adding)
- Hint panel layout slot (W8) and one rule for manual vs hint overlays.
- A dedicated visible-data view vs "read the shelf by Run" (W30).

---

### Resolution (same session, 2026-10-14)

All three blockers and the warnings listed above were fixed in-session from the
user-approved decisions (shared fix spec C1–C27). Additional decisions:
- Neutral FAIL-note statements are fixed per cause and owned by the grader
  (`hidden-data-grader.md` rule 12 table); every trap tag shares one; nothing
  authored per puzzle.
- systems-index Status stays **In Review** for all 11 GDDs (not Needs Revision):
  fixes are applied; each GDD still needs a fresh-session `/design-review`.
- Playtest Log lists the Sandbox as a soft upstream (`build_message` route).

Still open (by design): hint panel slot and visible-data view → `/ux-design`;
"Leave it for Kenji" button location → `/ux-design`; boss 1-11 hint override and
shift length → playtest timings (Progression OQ1/OQ3, Hint OQ6); wage
responsiveness → Progression OQ2.

Verdict as recorded: **FAIL** (at review time). Re-run `/review-all-gdds
since-last-review` after the fresh-session re-reviews to confirm the fixes.
