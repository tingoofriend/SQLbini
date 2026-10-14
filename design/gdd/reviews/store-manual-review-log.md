# Review Log: store-manual

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: S
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 5
Summary: A tight, well-bounded reference system: opt-in only, never auto-opens, unlocks by `manual_keywords`, and its contracts with Puzzle Definition, Progression, Hints, Onboarding and the Playtest Log all line up. One rule is unsatisfiable as written: rule 4 ("no page example may pass any puzzle") collides with the tutorial puzzles — 1-1's reference is `SELECT * FROM products`, the only natural example for "Reading the ledger" (`SELECT`, `FROM`, `*`, single table, nothing else taught yet), and "Picking columns" faces the same squeeze with 1-2 (`SELECT name, price FROM products`). SM-15 would fail on the first page or force a contrived example for the zero-SQL player at the very moment the manual matters most.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rule 4 / SM-15 vs Chapter 1 1-1 (`SELECT * FROM products`) and 1-2: the first page cannot show `*` on the one table without solving 1-1 — decide an exemption (e.g. tutorial-flagged puzzles excluded, since 1-1 is prefilled), or define "solve" as matching the reference on the visible dataset of a non-tutorial puzzle, and state which examples Chapter 1 will use
- [RECOMMENDED] Core Rules 1 and 3 vs Chapter 1 1-8 / 1-10: the rule's own `watch_out` examples ("BETWEEN includes both ends", "`= NULL` never matches; use `IS NULL`") are exactly the traps of the puzzles that unlock those pages, contradicting rule 3's "never … its answer" — decide now (e.g. a page's `watch_out` must not restate the trap of the puzzle that first unlocks it, or accept 1-8 / 1-10 as teaching puzzles) rather than only in OQ 1
- [RECOMMENDED] Core Rule 8 / States: "selecting a page marks it read" but the Playtest Log has only `manual_open {page}` — state whether that event fires on panel open, page select, or both (needed for OQ 1's "with and without the page read" comparison)
- [RECOMMENDED] Core Rule 8 vs Query Workbench Interactions ("manual overlay"): the side panel covers Your result / Target while open — confirm with the workbench (and the hint panel "beside the editor") that the two panels never stack, and that a player can read a page and compare results without closing it (or accept it)
- [RECOMMENDED] Formulas absent — correctly advisory (no numeric rules); Player Fantasy and Tuning Knobs absent (advisory at `standard`; Game Feel covers the fantasy)
- [RECOMMENDED] Header / Dependencies / Cross-References: Status "In Design" and "Designed (pending review)" are stale (index: Designed; puzzle definition, progression, workbench, hints are In Review)
Reviewed-Content-Hash: design/gdd/store-manual.md d415000cade3195f19b5cbe0492c1718d73ad2c3
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
