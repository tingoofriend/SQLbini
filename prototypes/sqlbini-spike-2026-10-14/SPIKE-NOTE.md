<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Can Godot 4.7.2 + CodeEdit + godot-sqlite run and grade SQLbini Chapter 1 puzzles? -->
<!-- Date: 2026-10-14 -->

# Spike Note: Query Workbench on Godot 4.7.2

## Question tested
Can we run SQLbini's Chapter 1 puzzles in **Godot 4.7.2** using **`CodeEdit` +
godot-sqlite**, with hidden-data grading that matches `prototypes/sqlbini-web/ch1.py`
verdict-for-verdict?

## Result: YES

| Check | Outcome | Evidence |
|---|---|---|
| godot-sqlite loads on 4.7.2 | **YES** — v4.9 (2026-08-09, "Update to Godot 4.7.1"), `compatibility_minimum = "4.7"`, Linux x86_64 binary loads | `godot --headless --path . -s res://verify.gd` runs queries |
| Grader parity with `ch1.py` | **28 / 28 match** (13 answers + 15 traps × 3 datasets) | `verify.gd` output: `checked 28 · mismatches 0` |
| Parity test can fail | **YES** — flipping one expected verdict gives `mismatches 1`, exit 1 | mutation run, then restored |
| CodeEdit as SQL editor | **YES** — `CodeHighlighter` colors keywords / strings / numbers; line numbers; Ctrl+Enter run, Ctrl+Shift+Enter submit | `shot-1-6-trap.png`, `shot-1-6-pass.png` |
| Hidden-data feedback | **YES** — 1-6 AND/OR trap passes visible, fails hidden A/B, reports `extra ["Corn Puff Stick",40]` | `shot-1-6-trap.png` |
| Nested project isolation | Root project prints "Detected another project.godot … will be ignored" | root `--import` output |

## Limitations found (inputs for the grader / workbench GDDs)
- **Column count is unknown for zero-row results.** godot-sqlite returns rows as
  Dictionaries, so an empty result has no columns. `ch1.py` uses
  `cursor.description` and would fail "0 rows, wrong column count"; this
  grader would pass it. Not hit by any Chapter 1 case, but must be solved
  (e.g. `PRAGMA`/`EXPLAIN`-based column inspection, or a wrapper query).
- **Duplicate column names collapse** (`SELECT name, name` → one key) because
  rows are Dictionaries. Same root cause.
- Editor: long lines are clipped (enable wrapping or a wider editor); no
  autocomplete yet (`CodeEdit` has a code-completion API — not tried).
- Feedback shows only the first failing dataset, and rows as raw JSON — needs
  the character-voiced presentation from the concept.
- Only the Linux binary was copied in; Windows (`.dll`) is in the same v4.9
  release for when Steam builds start.
- Doc discrepancy: `02_chapter1_puzzles.md` says 16 trap answers; `ch1.py` defines **15**.

## What to do next
**Add to the plan.** The Godot + godot-sqlite + CodeEdit stack is viable for
production. Carry the two Dictionary-row limitations into the grader's GDD
(`/design-system`) and an ADR on the SQLite integration
(`/architecture-decision`). This spike does **not** answer whether the game is
fun — that is the web-prototype playtest.
