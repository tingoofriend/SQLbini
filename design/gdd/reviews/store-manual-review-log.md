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
Revised in-session (2026-10-14, after the review; user decision: exempt 1-1 only): BLOCKING rule 4 fixed — puzzles whose editor Onboarding prefills with the reference (1-1) are exempt, so "Reading the ledger" may show `SELECT * FROM products`; 1-2 stays checked and "Picking columns" uses another list (SM-15). Also fixed: stale statuses. Not done: `watch_out` vs 1-8 / 1-10 traps (still OQ 1), `manual_open` event granularity, panel vs results column (recommended). Re-review pending in a fresh session.

## Review — 2026-10-15 (re-review after cross-GDD review fixes, fresh session) — Verdict: NEEDS REVISION
Scope signal: S
Specialists: none (lean mode; fresh session, not the authoring session — each doc reviewed by a read-only subagent, blocking items verified against the text in the main session)
Blocking items: 1 | Recommended: 7
Summary: Prior blocker (rule 4 vs 1-1 prefill) resolved via the prefill_sql exemption; B2 manual_pages, W9 (mark on 1-3), W10, D4 rule 3a, D6 indicator suppression and the playtest events are in. New blocker: rule 3a's "conditional watch_out" had no data contract and SM-22 could not be checked by CI.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Core Rules 3a / SM-22: conditional watch_out has no field, no pass event, no skip rule; SM-22 [Content-CI] not machine-checkable
- [RECOMMENDED] Core Rules 1, 3: example watch_outs ("BETWEEN includes both ends", "= NULL never matches") are the 1-8 / 1-10 traps (fixed in-session: marked as later-chapter examples)
- [RECOMMENDED] Core Rules 8: manual_open {page} granularity (panel open vs page select) unresolved (carried over)
- [RECOMMENDED] Core Rules 6 / SM-06: indicator text hard-coded "1 new page" — specify N
- [RECOMMENDED] SM-02: omits 1-3, 1-9, 1-10 mappings
- [RECOMMENDED] Interactions (Onboarding): Onboarding consumes a "Filtering rows unlocked" signal the Manual does not define; direction/owner disagree
- [RECOMMENDED] Dependencies: Puzzle Definition lists the Manual as soft, Manual lists Puzzle Definition as hard
- [RECOMMENDED] Naming: "Manual button" vs workbench/dialogue "tab"
Reviewed-Content-Hash: design/gdd/store-manual.md b1d4fc095da347bda4d29433752387a98a32365b
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-15, after the review; user decision "drop conditional + rule_tag"): rule 3a — trap-rule watch_outs are omitted in Chapter 1 (no conditional watch_out at MVP; A range / Empty values named); each watch_out carries a required `rule_tag`; manual content data holds `trap_rules` (Chapter 1 trap id → rule_tag); CI fails on a matching tag or an unmapped trap id; SM-01, SM-22 rewritten; rule 1/3 examples marked as later-chapter. Status stays In Review; re-review in a fresh session.
