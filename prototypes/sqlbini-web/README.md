<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Is the write → run → submit loop with hidden-data grading fun, including for SQL beginners? -->
<!-- Date: 2026-10-14 (copied into the repo from ../05.SQLbini/) -->

# SQLbini Web Prototype (concept prototype)

**Hypothesis**: Players — including SQL beginners — find the write-run-submit
loop with hidden-data grading satisfying enough to finish Chapter 1 and want a
constraint challenge afterwards (`design/gdd/game-concept.md` → MVP).

**Status**: Built; **playtest pending**.

## How to run
- Open `prototype.html` in a browser (sql.js loads from a CDN).
- Rebuild after editing data: `python3 ch1.py --json` and substitute it for
  `__DATA__` in `prototype.template.html`.
- Verify puzzle data: `python3 ch1.py` → `Verification: PASSED`.

## Files
| File | Contents |
|---|---|
| `ch1.py` | Chapter 1 datasets, puzzles, verifier, JSON export |
| `prototype.template.html` / `prototype.html` | Web puzzle screen (sql.js) |
| `original-design-draft.md` | The pre-studio design draft |

Chapter 1 puzzle design: `design/levels/chapter-1-puzzles.md`.

## Playtest protocol
1–2 people who don't know SQL. Give no explanation; watch silently. Afterwards
ask only: "What was confusing?"

## Findings
_Pending playtest._
