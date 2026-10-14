# SQLbini — Game Design Draft

_Last updated: 2026-10-14 · Summary of brainstorming decisions_

## Pitch
You start a part-time job at a struggling Japanese convenience store (konbini) and keep it running by solving requests with real SQL queries. A **coding puzzle game** for Steam.

## Decisions so far
| Item | Decision |
|---|---|
| Platform / form | Commercial Steam game (fun first, should not feel like edu-software) |
| Setting | **Japanese konbini** (fictional chain "SQLbini", Ekimae branch) |
| Base language | **English** (localization later) |
| Audience | Broad: complete SQL beginners to experienced users |
| Genre focus | **Puzzle-first** (Zachtronics-style); store management is story and backdrop |
| SQL engine | Embedded SQLite, so what players learn works in real life |

## Setting notes
- Konbini staples drive the data: onigiri, bento, cup noodles, canned coffee, vinyl umbrellas
- Prices in yen, tax included (e.g. onigiri ¥140, bento ¥498)
- Deli items (bento, onigiri) are disposed of on their expiry day — a real konbini rule that becomes a puzzle rule
- Cast: Manager Tanaka (store manager), Kenji (coworker), Mrs. Sato (elderly regular), customers, HQ emails
- Light Japanese flavor in UI (e.g. いらっしゃいませ on the sign), but all gameplay text is English
- All product and chain names are generic or fictional (no real brands)

## References
- TIS-100, Shenzhen I/O: programming puzzles + solution-efficiency histograms
- Human Resource Machine: approachable framing for beginners
- Papers, Please: turning dull paperwork into tense gameplay

## Anatomy of a puzzle
1. A request arrives (manager / customer / HQ messages)
2. Explore the database (tables and the visible data)
3. Write and run a query (compare with the target result)
4. **Hidden test datasets** verify the answer automatically, blocking hardcoding and boundary mistakes
5. Efficiency stats as histograms (query length, execution cost, clauses used)

### Grading
- Compare column count + result rows as a multiset (order ignored until puzzles that require `ORDER BY`)
- Column names are not compared (aliases are free)

## Puzzle types
- Query: produce the target result table
- Modify: use `UPDATE` / `DELETE` to reach a target DB state
- Detective: find a culprit or cause hidden in the data
- Debug: fix a broken query left by the previous part-timer
- Design: create tables that satisfy requirements
- Constraint: extra rules such as "no `JOIN`"

## Chapter plan (draft)
| Ch | Title | Core concepts | New tables |
|---|---|---|---|
| 1 | First Shift | `SELECT`, `WHERE`, comparison/logic, `LIKE`, `NULL` | products |
| 2 | Stocktaking | `ORDER BY`, `LIMIT`, `INSERT`, `UPDATE`, `DELETE` | (products extended) |
| 3 | Closing the Register | aggregates, `GROUP BY`, `HAVING` | sales, sale_items |
| 4 | Point Card Members | `JOIN` | customers |
| 5 | The Night Shift Mystery | subqueries, detective puzzles | employees, shifts |
| 6 | Second Store | window functions, multi-store analysis | stores |
| 7 | Called to HQ | schema design, normalization, indexes, transactions | (player-designed) |

- The messy single-table ledger of Chapter 1 gets normalized by the player in Chapter 7
- Some puzzles inside a chapter can be skipped (prevents players getting stuck and quitting)

## Beginner / expert support
**Beginners**
- Error messages rewritten in the manager's voice ("There's no column called 'prise'. Did you mean 'price'?")
- Two-step hints, result preview before submitting
- "Rewind" to undo data-changing mistakes

**Experts**
- Efficiency leaderboards, constraint challenges
- Sandbox mode (free analysis of the whole store DB)
- Hidden missions (spotting anomalies in the data)

## Story
- Told through chat messages; puzzle results feed back into the dialogue
- Running mystery: "Stock keeps disappearing on the night shift" → solved with queries from Chapter 5 on

## Steam-specific features
- Humorous achievements ("UPDATE without WHERE")
- Leaderboards / efficiency histograms
- Steam Workshop: player-made databases and missions
- Chapter 1 as a demo → Steam Next Fest for wishlists

## Files (all in this folder)
| File | Contents |
|---|---|
| `01_game_design.md` | This document |
| `02_chapter1_puzzles.md` | Chapter 1 puzzle design |
| `ch1.py` | Chapter 1 data, puzzles, verifier, JSON export |
| `prototype.template.html` | Web prototype source (`__DATA__` is replaced with `python3 ch1.py --json`) |

Playable prototype: https://claude.ai/artifact/Y3guutrTppJpMVf43SyKTC

## Next steps
- [x] Chapter 1 puzzle design and verification
- [x] Web puzzle-screen prototype (sql.js)
- [x] Switch setting to Japanese konbini, base language English
- [ ] Playtest the prototype, tune difficulty and feedback lines
- [ ] Choose engine (Unity / Godot) and SQLite integration
- [ ] Chapter 2 puzzle design
- [ ] Characters and world bible (Manager Tanaka, Kenji, Mrs. Sato)
