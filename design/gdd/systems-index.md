# Systems Index: SQLbini

> **Status**: Draft
> **Created**: 2026-10-14
> **Last Updated**: 2026-10-14 (design review: Grader + Puzzle Definition NEEDS REVISION → revised, In Review; earlier: Grader, Puzzle Definition, Sandbox, Workbench, Hints, Constraint Challenges, Progression, Dialogue, Store Manual, Onboarding, Playtest Log designed — all MVP GDDs written)
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

SQLbini is a single-player programming puzzle game: the player reads a konbini
request, writes real SQL, runs it on visible data, probes boundaries in a
throwaway back room (from Chapter 2), and submits for grading on hidden datasets. Its mechanical
scope is narrow and deep — no physics, combat or economy — so almost every
system serves one loop (read → write → run → submit → feedback) and the content
pipeline that feeds it. The four pillars drive the split: *The Condition, Not the
Screen* (Pillar 1) lives in the grader and the puzzle datasets; *Your Query, Your
Way* (Pillar 2) in the grader's comparison rules and constraint challenges; *Fast
Hands, Cheap Mistakes* (Pillar 3) in the sandbox and workbench; *Real Store, Real
SQL* (Pillar 4) in the sandbox (real SQLite) and the request/reaction layer.

**Systems, briefly**
- **Hidden-Data Grader** — compares the player's result to the reference on every hidden dataset and chooses the escalating failure feedback (symptom → clause highlight → synthetic counter-example), never revealing hidden rows. MVP ships level 1 (symptom + generic fallback); levels 2–3 are Vertical Slice (scope-check 2026-10-14). The heart of Pillars 1 and 2; designed first because it fixes the feedback design, the back room's scope and the content cost of every puzzle.
- **Puzzle Definition & Datasets** — the data format for a puzzle: request, schema, visible and hidden datasets (incl. a hardcode-proof set), reference answer, traps with per-level feedback, alternative valid answers, constraint rules. Everything else reads it; the `ch1.py` verifier pattern becomes its validation pipeline.
- **SQL Execution Sandbox** *(inferred)* — runs any SQL safely: fresh in-memory database per run, one statement, read-only for query puzzles, timeout, captured SQLite errors, and a result shape that keeps column count for zero-row results (the spike's open limitation).
- **Query Workbench** — the screen the player lives in: editor (`CodeEdit`), instant run, result vs. target, schema browser; Run never shows a pass state.
- **Back Room** — a per-puzzle scratch copy of the visible data where the player inserts test rows; never graded, reset per puzzle. **Alpha (Chapter 2+)** — Chapter 1 players cannot yet write `INSERT` (decision 2026-10-14).
- **Hint System** — two-step hints, offered on request after failed submits; consumes the grader's failure state.
- **Constraint Challenges** — optional re-runs of a cleared puzzle with a rule ("no `OR`", "under 60 characters"); needs a tokenizer that ignores string literals.
- **Shift & Chapter Progression** — puzzles grouped into shifts and chapters, unlocks, the boss rule, skip rules, the end-of-shift wage.
- **Request & Reaction Dialogue** — chat messages from Manager Tanaka, Kenji, Mrs. Sato and HQ; voices pass/fail feedback and SQLite errors (with the raw error always available beneath).
- **Store Manual** — the in-world reference binder; a page per keyword, unlocked on first need. The zero-SQL syntax path.
- **Onboarding: First Shift** *(inferred)* — the 1-1 to 1-3 flow for zero-SQL players: prefilled query, click-to-insert schema, no failure possible in 1-1.
- **Playtest Log** *(inferred)* — records every run, submit, hint and help request with timestamps; required to measure the MVP thresholds in the concept.
- **Save/Load & Settings** *(inferred)*, **Game Shell & Screen Flow** *(inferred)*, **Efficiency Stats**, **Audio** *(inferred)*, **Accessibility Options** *(inferred)*, **Achievements** — the demo layer (Vertical Slice).
- **Modify Puzzle Grading** — `UPDATE`/`DELETE` puzzles graded by final database state, with rewind (Alpha, Chapter 2+).

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Hidden-Data Grader | Gameplay | MVP | In Review | design/gdd/hidden-data-grader.md | SQL Execution Sandbox, Puzzle Definition & Datasets |
| 2 | Puzzle Definition & Datasets | Core | MVP | In Review | design/gdd/puzzle-definition-and-datasets.md | — |
| 3 | SQL Execution Sandbox (inferred) | Core | MVP | Designed | design/gdd/sql-execution-sandbox.md | — |
| 4 | Query Workbench | Gameplay | MVP | Designed | design/gdd/query-workbench.md | SQL Execution Sandbox, Puzzle Definition & Datasets |
| 5 | Back Room | Gameplay | Alpha | Not Started | — | SQL Execution Sandbox, Puzzle Definition & Datasets, Query Workbench |
| 6 | Hint System | Gameplay | MVP | Designed | design/gdd/hint-system.md | Puzzle Definition & Datasets, Hidden-Data Grader |
| 7 | Constraint Challenges | Gameplay | MVP | Designed | design/gdd/constraint-challenges.md | Puzzle Definition & Datasets, Hidden-Data Grader |
| 8 | Shift & Chapter Progression | Progression | MVP | Designed | design/gdd/shift-and-chapter-progression.md | Puzzle Definition & Datasets, Hidden-Data Grader |
| 9 | Request & Reaction Dialogue | Narrative | MVP | Designed | design/gdd/request-and-reaction-dialogue.md | Puzzle Definition & Datasets, Hidden-Data Grader, SQL Execution Sandbox |
| 10 | Store Manual | Narrative | MVP | Designed | design/gdd/store-manual.md | Puzzle Definition & Datasets, Shift & Chapter Progression |
| 11 | Onboarding: First Shift (inferred) | Meta | MVP | Designed | design/gdd/onboarding-first-shift.md | Query Workbench, Request & Reaction Dialogue, Store Manual |
| 12 | Playtest Log (inferred) | Meta | MVP | Designed | design/gdd/playtest-log.md | Hidden-Data Grader, Query Workbench, Hint System |
| 13 | Save/Load & Settings (inferred) | Persistence | Vertical Slice | Not Started | — | Shift & Chapter Progression |
| 14 | Game Shell & Screen Flow (inferred) | UI | Vertical Slice | Not Started | — | Shift & Chapter Progression, Save/Load & Settings |
| 15 | Efficiency Stats | Progression | Vertical Slice | Not Started | — | SQL Execution Sandbox, Hidden-Data Grader |
| 16 | Audio (inferred) | Audio | Vertical Slice | Not Started | — | Query Workbench, Hidden-Data Grader, Request & Reaction Dialogue |
| 17 | Accessibility Options (inferred) | Meta | Vertical Slice | Not Started | — | Query Workbench, Game Shell & Screen Flow |
| 18 | Achievements | Progression | Vertical Slice | Not Started | — | Shift & Chapter Progression, Efficiency Stats |
| 19 | Modify Puzzle Grading | Gameplay | Alpha | Not Started | — | SQL Execution Sandbox, Puzzle Definition & Datasets, Hidden-Data Grader |

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | Foundation systems everything depends on | SQL execution sandbox, puzzle data format |
| **Gameplay** | The systems that make the game fun | Grader, workbench, back room, hints, constraint challenges, modify grading |
| **Progression** | How the player grows over time | Shifts/chapters, efficiency stats, achievements |
| **Persistence** | Save state and continuity | Save/load, settings |
| **UI** | Player-facing information displays | Game shell and screen flow |
| **Audio** | Sound and music systems | Store ambience, feedback SFX, light music |
| **Narrative** | Story and dialogue delivery | Request & reaction dialogue, store manual |
| **Meta** | Systems outside the core game loop | Onboarding, playtest log, accessibility options |

Economy is omitted: the anti-pillars exclude store-management systems, and the
wage is a narrative beat, not a currency.

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Without these, you can't test "is this fun?" | First playable prototype (Chapter 1) | Design FIRST |
| **Vertical Slice** | Required for one complete, polished area. Demonstrates the full experience. | Steam Next Fest demo (Chapter 1, final art/audio) | Design SECOND |
| **Alpha** | All features present in rough form. Complete mechanical scope, placeholder content OK. | Chapters 1–3 | Design THIRD |
| **Full Vision** | Polish, edge cases, nice-to-haves, and content-complete features. | Chapters 1–4 release | Design as needed |

> **Back Room moved to Alpha** (2026-10-14, user decision): Chapter 1 players
> cannot write `INSERT` yet, so the Back Room opens with Chapter 2. MVP now holds
> 11 systems. The design order keeps it at position 5 but it is no longer MVP.
>
> **Scope note** (map-systems, 2026-10-14): MVP holds 12 of 19 systems, including
> three added by the 2026-10-14 concept revision (Back Room, Store Manual, and the
> escalating feedback inside the Grader) plus the inferred Playtest Log the MVP
> thresholds need. The concept's "4–6 weeks" MVP estimate predates these; run
> `/scope-check` before designing beyond the Grader (accepted risk in
> `production/gate-checks/2026-10-14-concept-to-systems-design-rerun.md`).
> PR-SCOPE skipped — Lean mode.
>
> **Scope-check 2026-10-14: FAIL (+67% MVP items vs. the brainstorm baseline).**
> Applied: feedback levels 2–3 deferred to Vertical Slice. Not applied (user
> choice): merging hints into feedback, shrinking constraint challenges,
> minimal-version limits on the new systems. MVP timeline still needs `/estimate`.

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **Puzzle Definition & Datasets** — every other system reads a puzzle; its format is the contract for content authoring and for the `ch1.py`-style verifier.
2. **SQL Execution Sandbox** — every query the player writes (Run, Back Room, Submit) goes through it; it owns safety, timeouts and the result shape.

### Core Layer (depends on foundation)

1. **Hidden-Data Grader** — depends on: SQL Execution Sandbox, Puzzle Definition & Datasets
2. **Query Workbench** — depends on: SQL Execution Sandbox, Puzzle Definition & Datasets

### Feature Layer (depends on core)

1. **Back Room** — depends on: SQL Execution Sandbox, Puzzle Definition & Datasets, Query Workbench
2. **Hint System** — depends on: Puzzle Definition & Datasets, Hidden-Data Grader
3. **Constraint Challenges** — depends on: Puzzle Definition & Datasets, Hidden-Data Grader
4. **Shift & Chapter Progression** — depends on: Puzzle Definition & Datasets, Hidden-Data Grader
5. **Efficiency Stats** — depends on: SQL Execution Sandbox, Hidden-Data Grader
6. **Save/Load & Settings** — depends on: Shift & Chapter Progression
7. **Modify Puzzle Grading** — depends on: SQL Execution Sandbox, Puzzle Definition & Datasets, Hidden-Data Grader

### Presentation Layer (depends on features)

1. **Request & Reaction Dialogue** — depends on: Puzzle Definition & Datasets, Hidden-Data Grader, SQL Execution Sandbox (error text)
2. **Store Manual** — depends on: Puzzle Definition & Datasets, Shift & Chapter Progression
3. **Game Shell & Screen Flow** — depends on: Shift & Chapter Progression, Save/Load & Settings
4. **Audio** — depends on: Query Workbench, Hidden-Data Grader, Request & Reaction Dialogue

### Polish Layer (depends on everything)

1. **Onboarding: First Shift** — depends on: Query Workbench, Request & Reaction Dialogue, Store Manual
2. **Playtest Log** — depends on: Hidden-Data Grader, Query Workbench, Hint System
3. **Accessibility Options** — depends on: Query Workbench, Game Shell & Screen Flow
4. **Achievements** — depends on: Shift & Chapter Progression, Efficiency Stats

**Bottlenecks** (most dependents): Puzzle Definition & Datasets (9), Hidden-Data
Grader (8), SQL Execution Sandbox (6), Query Workbench (5). A design change in any
of these ripples widely.

**Leaf systems** (nothing depends on them — lower risk, can be designed late):
Back Room, Constraint Challenges, Onboarding, Playtest Log, Accessibility Options,
Achievements, Audio, Modify Puzzle Grading.

---

## Recommended Design Order

The Grader is designed **before** its two foundation dependencies, deliberately:
it decides what a puzzle must contain (traps, per-level feedback, hardcode-proof
datasets, alternative answers) and what the sandbox must return (column count for
zero rows, error capture). Puzzle Definition and the Sandbox are then written
against the Grader's stated contract. This is the order the gate re-run's
accepted risks call for.

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Hidden-Data Grader | MVP | Core | systems-designer, game-designer | L |
| 2 | Puzzle Definition & Datasets | MVP | Foundation | systems-designer, level-designer | M |
| 3 | SQL Execution Sandbox | MVP | Foundation | systems-designer, godot-specialist | M |
| 4 | Query Workbench | MVP | Core | ux-designer, game-designer | M |
| 5 | Back Room | Alpha | Feature | game-designer | S |
| 6 | Hint System | MVP | Feature | game-designer, ux-designer | S |
| 7 | Constraint Challenges | MVP | Feature | systems-designer | S |
| 8 | Shift & Chapter Progression | MVP | Feature | game-designer | M |
| 9 | Request & Reaction Dialogue | MVP | Presentation | narrative-director, writer | M |
| 10 | Store Manual | MVP | Presentation | writer, ux-designer | S |
| 11 | Onboarding: First Shift | MVP | Polish | ux-designer | S |
| 12 | Playtest Log | MVP | Polish | qa-lead, analytics-engineer | S |
| 13 | Save/Load & Settings | Vertical Slice | Feature | game-designer | S |
| 14 | Efficiency Stats | Vertical Slice | Feature | systems-designer | S |
| 15 | Game Shell & Screen Flow | Vertical Slice | Presentation | ux-designer | S |
| 16 | Audio | Vertical Slice | Presentation | audio-director, sound-designer | M |
| 17 | Accessibility Options | Vertical Slice | Polish | accessibility-specialist, ux-designer | M |
| 18 | Achievements | Vertical Slice | Polish | game-designer | S |
| 19 | Modify Puzzle Grading | Alpha | Feature | systems-designer | M |

---

## Circular Dependencies

- **None at runtime.**
- **Design-time coupling: Hidden-Data Grader ↔ Puzzle Definition & Datasets** —
  the grader needs fields the puzzle format must provide (traps, feedback levels,
  synthetic counter-examples), and the format exists to serve the grader.
  Resolution: the Grader GDD states the contract (required puzzle fields and
  sandbox result shape); the Puzzle Definition GDD implements it. Same for
  Grader ↔ SQL Execution Sandbox.

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| Hidden-Data Grader | Design | The core "aha" is unproven (zero hidden-data failures in the first playtest); hint selection for combined or unanticipated mistakes is undefined | Design first; validate against the MVP thresholds playtest; generic fallback feedback |
| Puzzle Definition & Datasets | Scope | Each puzzle needs hand-built hidden datasets (incl. a hardcode-proof set), traps, 3 feedback levels, synthetic counter-examples and alternative answers — × ~50 puzzles | Per-puzzle Definition of Done; extend the `ch1.py` verifier into a CI gate; `/scope-check` |
| SQL Execution Sandbox | Technical | godot-sqlite returns rows as dictionaries (zero-row column count lost, duplicate names collapse); Windows binary untested; runaway queries need a timeout | Spike follow-up: test the Windows .dll; prototype a column-preserving result path early |
| Onboarding: First Shift | Design | Zero-SQL players untested; "bounce in the first minute" is the concept's top design risk | Zero-SQL playtest (dated before Chapter 1 content locks) |
| Back Room | Scope | New in the 2026-10-14 revision; moved to Alpha (Chapter 2) | Keep to insert/edit/delete on a copy of visible rows |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 19 |
| Design docs started | 11 |
| Design docs reviewed | 2 (both NEEDS REVISION → revised, In Review) |
| Design docs approved | 0 |
| MVP systems designed | 11/11 |
| Vertical Slice systems designed | 0/6 |

---

## Next Steps

- [ ] Run `/scope-check` — re-estimate MVP with the 12 MVP systems (accepted risk)
- [ ] Design the Hidden-Data Grader first (`/design-system hidden-data-grader`)
- [ ] Design remaining MVP-tier systems in the order above
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check technical-setup` when MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production

> Director gates skipped — Lean mode: TD-SYSTEM-BOUNDARY, PR-SCOPE, CD-SYSTEMS.
