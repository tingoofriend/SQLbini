# Decision Log — SQLbini

One line per decision, newest last within each section. **By**: `User` = the
developer chose it (often from options Claude offered — "rec." marks the
recommended option); `Claude` = decided by Claude under `modes.automation:
autonomous` and recorded for review. Details live in the linked document.

Started 2026-10-15 (session 8) from `production/session-state/active.md`,
gate reports and GDD review logs; earlier entries are reconstructed from those.

## Scope and schedule

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-14 | Back Room moved from MVP to Alpha (Chapter 2) — Chapter 1 players cannot write `INSERT` yet | MVP 12 → 11 systems | User | `design/gdd/systems-index.md` |
| 2026-10-14 | Grader failure feedback levels 2–3 (clause highlight, counter-example) deferred to Vertical Slice; MVP ships level 1 only | Smaller MVP grader and content cost | User (scope-check FAIL +67%) | `systems-index.md`, `hidden-data-grader.md` |
| 2026-10-14 | Not applied: merging hints into feedback, shrinking constraint challenges, minimal versions of new systems | Scope kept | User | `systems-index.md` |
| 2026-10-14 | Constraint Challenges `max_chars` type deferred to Alpha; MVP = keyword rules (`forbid` / `require`) | Smaller MVP | User | `constraint-challenges.md` rule 3 |
| 2026-10-14 | MVP re-baselined to ~11 weeks (7–18), confidence Low | Schedule | `/estimate` | `game-concept.md` Scope Tiers |
| 2026-10-15 | MVP re-estimated after architecture v1 + ADR-0001…0003: **≈ 84 focused days ≈ 17 weeks remaining (58–131 days, 12–26 weeks)**, confidence Low (no velocity data); scope unchanged; accepted as the new baseline | +≈ 8 weeks vs the old implementation share; biggest risk: Workbench + Dialogue UI (CodeEdit IME, dual focus, AccessKit — NOT SOURCEABLE) | User | `/estimate` 2026-10-15 (session 8) |

## Look and presentation

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-14 | Mood: slightly aesthetic, cozy — evening-shift warm konbini | Palette, type, audio direction | User (idea #1) | `design/ideas-backlog.md`, `design/art/art-bible.md` |
| 2026-10-14 | Requests shown as pixel-art NPCs + speech bubble in a 120 px counter strip, plus a message log (hybrid) | Sprites + strip scene | User (idea #2) | `request-and-reaction-dialogue.md`, art bible |
| 2026-10-14 | Counter strip fixed at 120 px at every `ui_scale`; only bubble text scales | Layout | User | `active.md` notes |
| 2026-10-14 | Bubble ≈ 510 px inside the strip zone map; long lines page | Layout | User | art bible §7 |

## Game rules (GDD reviews 6a–6g)

| Date | Decision | By | Source |
|---|---|---|---|
| 2026-10-14 | Grader neutral notes fixed per cause, never authored per puzzle | User | `hidden-data-grader.md` rule 12 |
| 2026-10-14 | Visible re-run errors → SUBMIT_ERROR, not counted | User | grader rule 7a |
| 2026-10-14 | TOO_MANY_ROWS strip text = label + "{grader_row_cap}+ rows — too many to compare" | User | `query-workbench.md` rule 13 |
| 2026-10-15 | Coach-mark Done conditions scoped to their puzzle | User | `onboarding-first-shift.md` rule 7a |
| 2026-10-15 | Challenge draft seeded from the last passing query, kept for the session; no hints in challenge mode | User | `constraint-challenges.md` rule 6c |
| 2026-10-15 | Repeated UNAVAILABLE on a main request → Kenji's skip offer at once; accept → `Unavailable` (resolves the request) | User | `shift-and-chapter-progression.md` rule 7a |
| 2026-10-15 | First main request and side requests open when the shift briefing ends | User | Progression, Dialogue rule 3c |
| 2026-10-15 | Day One order: briefing → "Ever used SQL?" → 1-1 | User | Dialogue rule 3c |
| 2026-10-15 | Wording-only mismatches are recommendations, not re-review blockers | User | review logs |

## Process and gates

| Date | Decision | By | Source |
|---|---|---|---|
| 2026-10-14 | Gate Concept → Systems Design passed on accepted CONCERNS | User | `production/gate-checks/2026-10-14-concept-to-systems-design-rerun.md` |
| 2026-10-15 | Gate Systems Design → Technical Setup passed on accepted CONCERNS; open accepted risks: zero-SQL playtest undated, concept not re-reviewed, only MVP + Demo committed | User | `production/gate-checks/2026-10-15-systems-design-to-technical-setup.md` |
| 2026-10-15 | Keep `modes.automation: autonomous`; questions must state game/schedule impact in plain words | User | session 8 |

## Architecture (session 8)

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-15 | Workbench split into Controller (logic) + View (UI); Playtest Log split into EventBus + Recorder; Foundation services GameConfig, StringTable, Clock, BuildFlavour | Code structure only | Claude | `docs/architecture/architecture.md` |
| 2026-10-15 | First ADR = sandbox timeout (rec.) | Order | User | — |
| 2026-10-15 | Windows godot-sqlite `.dll` spike deferred to just before ADR-0005 (not the rec.) | Windows risk stays open until then | User | — |
| 2026-10-15 | Sandbox timeout = worker thread per query, abandoned on timeout (rec.); fork with interrupt is the upgrade path | ≈ +1–2 days vs +1–2 weeks for alternatives; extreme queries burn a core for minutes | User | ADR-0001 |
| 2026-10-15 | Hand-written SQL lexer (no alternative available); `await execute()` API; typed result classes; unterminated literals tokenized to end of text | Code structure only | Claude | ADR-0002 |
| 2026-10-15 | Puzzle content in JSON (chapter file + one file per puzzle); verifier in GDScript on the game's own sandbox for CI and load; Python `ch1.py` retired | No game impact; avoids duplicate verifier work | Claude | ADR-0003 |
| 2026-10-15 | Register ADR stances in `docs/registry/architecture.yaml` | Bookkeeping | User | — |
| 2026-10-15 | Start a decision log (this file) | Bookkeeping | User | — |
| 2026-10-15 | `/estimate` accepted; `game-concept.md` / `systems-index.md` schedule wording updated | Docs | User | — |
| 2026-10-15 | Build flavours dev / playtest / release from feature tags; EventBus validates the catalogue; JSONL recorder flushes per event; report tool in Python | Code structure only | Claude | ADR-0004 |
| 2026-10-15 | F9 facilitator note recorded as a separate `help_note {note}` event (GDD gap: `help_given` is written at once, the note comes later) | Playtest log format only | User (rec.) | ADR-0004, `playtest-log.md` rule 7 |
| 2026-10-15 | One composition root builds all services and hands them to each screen; no gameplay autoloads; all time from an injectable Clock | Code structure only; makes timed rules testable instantly | Claude | ADR-0006 |

## Architecture review and acceptance (session 9)

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-15 | `/architecture-review` (session 9): FAIL — 2 blocking cross-ADR issues (verifier ownership cycle; boot ≈ 3.3 s not 0.1 s), both fixed by ADR text | No game impact | Claude (review) | `docs/architecture/architecture-review-2026-10-15.md` |
| 2026-10-15 | TR registry: keep the 44 provisional IDs, add 16 (60 total) | Bookkeeping | Claude | `docs/architecture/tr-registry.yaml` |
| 2026-10-15 | ADR-0001 amended, then **Accepted** (rec.) | Sandbox work can start | User | ADR-0001 |
| 2026-10-15 | Sandbox GDD worst-case submit formula corrected to include frame delivery and last-set timeout (rec.); ≈ 310 ms at target ceilings, re-check with ADR-0005 | No rule change; GDD Formulas only | User | `sql-execution-sandbox.md` Formulas |
| 2026-10-15 | ADR-0002 amended (Run supersede, per-request await, extensions off), then **Accepted** (rec.) | Matches workbench GDD | User | ADR-0002 |
| 2026-10-15 | ADR-0003 amended (separate verifier, 6 queries in flight, non-puzzle checks CI-only, id-list check), then **Accepted** (rec.) | Boot ≈ 0.6 s instead of ≈ 3.3 s | User | ADR-0003 |
| 2026-10-15 | Accept ADR-0006 before ADR-0004 (ADR-0004 uses its Clock) | Order only | Claude (rec.), user agreed | — |
| 2026-10-15 | ADR-0006 amended (verifier wiring, tick-sampled rule time, `@abstract` row), then **Accepted** (rec.) | No game impact | User | ADR-0006 |
| 2026-10-15 | ADR-0004 amended (`hint_counter` Callable, log closes on quit only, `event_name`, report `--config`), then **Accepted** (rec.) | Log keeps post-chapter play | User | ADR-0004 |
| 2026-10-15 | Implementation details inside the amendments (sequence numbers, `verify_parallelism` = 6, `Main.quit_game()`, setters on the repository) | Code structure only | Claude | ADRs 0002–0006 |
| 2026-10-15 | New should-have ADR-0010 Gameplay signal contracts proposed | One more ADR before the Grader/Hint/Dialogue stories | Claude (review) | review report |
| 2026-10-16 | Install gdUnit4 **v6.2.2** from the official GitHub tag into `addons/gdUnit4/`; CI via `gdUnit4-action@v1` pinned to Godot 4.7.2 and the committed addon (rec.) | No game impact; tests run on every push | User | `tests/README.md` |
| 2026-10-16 | Example tests double as ADR-0006 checks (no autoloads; `scene_runner` with a set-up instance) | Bookkeeping | Claude | ADR-0006 Verification |
| 2026-10-16 | Accessibility tier **Standard + reduced motion + full keyboard** (rec.); screen reader best effort, colourblind palette mode replaced by "no colour-only information" | VS Accessibility Options must implement remapping + `ui_scale`; no extra MVP work beyond the toggle | User | `design/accessibility-requirements.md` |
| 2026-10-16 | MVP reduced motion = toggle in Onboarding's minimal options panel (rec.) | ≈ half a day at MVP | User | onboarding OQ4, art bible R-04 |
| 2026-10-16 | Interaction pattern library v1 (IP-01…IP-21) drafted from GDDs + art bible; details such as "offers never steal focus", "one side panel at a time", Restart confirmation wording | UI behaviour only, inside GDD rules | Claude | `design/ux/interaction-patterns.md` |
| 2026-10-16 | Onboarding minimal options panel holds "Coach marks" + "Reduced motion"; onboarding OQ4 resolved (rec.) | GDD text aligned | User | `onboarding-first-shift.md` UI Req 4 |
| 2026-10-16 | Hint panel opens in the Manual's slot over the grids, one side panel at a time (rec.) | Results hidden while reading a hint; receipt stays visible | User | `design/ux/query-workbench.md` |
| 2026-10-16 | No dedicated visible-data view; data read by Run; `visible_rows_max` stays 30 (rec.) | No extra work; revisit after zero-SQL playtest | User | workbench OQ7, puzzle-def OQ6 |
| 2026-10-16 | Locked hint: tab "Hint · locked", unlock condition in the panel (rec.) | — | User | hint OQ7 |
| 2026-10-16 | Editor/table base font range narrowed 14–32 → 14–24 (max 48 px at 2.0) (rec.) | Defaults unchanged | User | workbench OQ9, QW-24 |
| 2026-10-16 | `H_table` uses the logical viewport height `h_view`; receipt grows by shrinking Target (≥ 2 rows); "Leave it for Kenji" on the receipt; tab cluster ≥ 1.5 moves Log into the Shift menu (provisional); opening question takes focus | Layout only | Claude | `design/ux/query-workbench.md` |
| 2026-10-16 | Apply the UX decisions to the GDDs, art bible and registry (rec.) | Docs aligned | User | — |
| 2026-10-16 | ADR-0010: producer-owned typed signals wired in one `GameplayWiring`; Dialogue reaction queue fixes same-frame line order; `InputActivity` node feeds hint idle time | Code structure only; no rule change | Claude | ADR-0010 (Proposed) |
| 2026-10-16 | ADR-0007: typed JSON config with per-key reject/clamp; own English JSON string table (not `TranslationServer` at MVP); session `Settings` service | Localisation later needs a file conversion, not code change | Claude | ADR-0007 (Proposed) |
| 2026-10-16 | Shift-flow screens replace the work surface only; the counter strip stays visible | Layout only | Claude | `design/ux/shift-flow.md` |
| 2026-10-16 | Renderer spike on Linux (data only; renderer choice left to ADR-0005 after the Windows run) | — | Claude | `prototypes/renderer-spike-2026-10-16/` |


## Architecture re-review and acceptance (session 10)

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-16 | `/architecture-review` (session 10): CONCERNS — no conflict among Accepted ADRs; ADR-0007/0010 need amendments; 3 engine issues probed (dialogs block `_input` and F9; `String.format` cannot escape) | No game impact | Claude (review) | `docs/architecture/architecture-review-2026-10-16.md` |
| 2026-10-16 | First-Submit explainer shows after the verdict reaction (rec.) | Player sees the result first | User | ADR-0010 §5 |
| 2026-10-16 | Invalid per-puzzle hint override: CI failure, global value at load, puzzle never withheld (rec.) | A typo in a hint number cannot remove a puzzle | User | ADR-0007 §1 |
| 2026-10-16 | Amend ADR-0007, then **Accepted** (rec.) | Dialogue / Hint / config stories unblocked | User | ADR-0007 |
| 2026-10-16 | Amend ADR-0010 + text fixes to ADR-0001…0006 + architecture.md v2, then ADR-0010 **Accepted** (rec.) | Cross-system stories unblocked | User | ADR-0010 |
| 2026-10-16 | Amendment details: `grade()`/`submit()` split, `request_opened`/`request_shown`, challenge signals, `line_requested`, input and F9 via `root.window_input`, F9 note only without an open dialog, own `{name}` substitution, `verify_parallelism` in `content.json` | Code structure only; F9 during a dialog records the help marker without a note | Claude | ADRs 0003, 0004, 0006, 0007, 0010 |
| 2026-10-16 | Workbench SUBMIT_ERROR strip sits directly under the editor (GDD placement), not on the receipt (rec.) | Error read next to the query; editor a line or two shorter; UX spec changes, GDD unchanged | User | `/ux-review` query-workbench S1 |
| 2026-10-16 | Verdict stamp and strip clear on any editor edit (GDD rule 12) (rec.) | No stale PASS beside an edited query; UX spec + IP-08 change | User | `/ux-review` query-workbench S2 |
| 2026-10-16 | After the Closing shift: shift screen shows "Chapter complete" with the chapter list as its action (no *Stop for today*) (rec.) | Replays/challenges stay reachable; UX spec only | User | `/ux-review` shift-flow S3 |
| 2026-10-16 | Shift button disabled in challenge mode with a visible reason ("Leave the dare first") (rec.) | UX specs (shift-flow + workbench) | User | `/ux-review` shift-flow S5 |
| 2026-10-16 | Shift-flow spec follows the GDD for cross-shift challenge clears (separate payslip line), side requests + dare start on the chapter list, all-unavailable payslip note; "unavailable" mark = word only, no en dash (rec. for OQ2) | Spec catches up with Approved GDD rules; GDD Visual wording "– unavailable" → recommendation | Claude | `/ux-review` shift-flow |
| 2026-10-16 | Restart is started from the chapter-list view (Progression rule 12a), not the Workbench view — ADR-0010 §6 / architecture.md wording corrected | Wording only | Claude | shift-flow revision |

## UX re-review (session 10b)

| Date | Decision | Impact | By | Source |
|---|---|---|---|---|
| 2026-10-17 | `/ux-review` ×3: query-workbench NEEDS REVISION (3 blocking: Options vs IP-22, F9 note on close vs ADR-0004 §4, missing GDD states), shift-flow NEEDS REVISION (1: cleared dare replay), interaction-patterns NEEDS REVISION (3: no Animation/Sound tables, IP-13 reveal keys, IP-20 replay); all session-10 blockers resolved | Specs stay In Design | Claude (review) | this session |
| 2026-10-17 | Fix the blockers now; light check of the changed parts as session 11 step 0, then Approved (rec.) | ≈ 20–30 min in session 11; no extra session | User | — |
| 2026-10-17 | Boot failure screen: Quit only, no retry (rec.) | No extra work | User | `query-workbench.md` States |
| 2026-10-17 | A Run of unchanged text keeps the FAIL note / stamp and adds the tally note beside it — follows GDD rule 12 (rec.) | IP-08 wording; no GDD change | User | `query-workbench.md`, IP-08 |
| 2026-10-17 | Keep the CodeEdit shortcut probe in `prototypes/codeedit-shortcut-probe-2026-10-17/` (rec.) | Evidence for ADR-0008 | User | probe README |
| 2026-10-17 | Spec fixes: Options via the shift screen; F9 note written on any close; states Request shown again / Target unavailable / Verdict for previous text / Zero rows / Over display cap; order line = GDD text "! Rows match; order differs"; Submit-exclusive kept; cleared dare replayable from the chapter list; withheld side requests have no row; Animation + Sound Standards tables; IP-13 reveal = same inputs as paging; no tooltips | UX specs only | Claude | the three specs |
| 2026-10-17 | Probe finding: a focused CodeEdit consumes Ctrl+Enter, Ctrl+Shift+Enter and Ctrl+M before `_shortcut_input`; Ctrl+Shift+S is free | ADR-0008 must take these chords first; no game change | Claude (probe) | probe README |
