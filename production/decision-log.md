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
