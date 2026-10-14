# Game Concept: SQLbini

*Created: 2026-10-14*
*Status: Draft — revised 2026-10-14 after `/design-review` (NEEDS REVISION) and the concept playtest; 2026-10-14 cross-GDD review fixes*
*Source draft: `prototypes/sqlbini-web/original-design-draft.md`; Chapter 1 puzzles: `design/levels/chapter-1-puzzles.md` (verified by `prototypes/sqlbini-web/ch1.py`)*

---

## Elevator Pitch

> It's a coding puzzle game where you solve customer and manager requests with
> **real SQL** during part-time shifts at a struggling Japanese konbini. Any
> query that truly meets the condition counts — but hidden test data catches
> answers that only match what's on screen.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Puzzle — programming puzzle (Zachtronics / Human Resource Machine lineage) |
| **Platform** | PC (Steam) |
| **Target Audience** | Mastery-driven puzzle players and practical SQL learners (see Target Player Profile) |
| **Player Count** | Single-player |
| **Session Length** | 30–60 min (one shift = 3–5 puzzles) — *pending playtest: Chapter 1's 3 / 4 / 4 split at ~4.6 min/puzzle gives ≈ 15–18 min per shift; see `shift-and-chapter-progression.md` Open Question 3* |
| **Monetization** | Premium; Chapter 1 as a free demo (Steam Next Fest) |
| **Estimated Scope** | Medium (6–9 months, solo, first game) — see Scope Tiers |
| **Comparable Titles** | Human Resource Machine, TIS-100, SQL Murder Mystery (web) |

---

## Core Fantasy

You are the part-timer who **actually understands the condition**. On your
first day (Chapter 1, "Day One") you fall for every trap — a customer asked for drinks "under 200",
and you had to decide whether the ¥200 lemon soda counts; the snack list let a
¥40 corn stick sneak in; the "no expiry date" list missed the umbrella filed
under Misc. By closing time you check the boundaries before the manager has to
ask — and from Chapter 2, once you can write `INSERT`, you test them yourself in
the back room. And you did it *your* way: no
one handed you the answer query; the store's data simply proved yours right.

The skill is real. What you learn writing a disposal list for Manager Tanaka is
the same SQL you would use at a job.

> **Unvalidated assumption.** This fantasy needs players to actually fall for a
> trap and then understand why. In the first playtest (2–3 players with some SQL
> experience) **nobody failed a hidden-data check** and no zero-SQL player was
> tested — see `prototypes/sqlbini-web/REPORT.md`. Two conditions follow:
> (1) puzzle design must make the key traps (1-6 AND/OR, 1-11 parentheses) bite
> players who already know some SQL; (2) a zero-SQL playtest with an observation
> log is required before the demo build. Thresholds are in the MVP Definition.

**Trap philosophy.** A trap must test *understanding of the condition*, not
careful reading. Requests use natural store language ("under 200", "this week",
"the ones without a date") and do not spell out the boundary; the character's
reaction resolves the ambiguity after a submit. Traps come from what the data
*means* — NULLs, duplicates, letter case, trailing spaces, items filed in an
unexpected category, boundary values — not from operator wording the request
already gave away. Chapter 1's current requests (1-4, 1-5, 1-7, 1-8) state their
boundaries explicitly and must be rewritten to this rule in level design.

---

## Unique Hook

**It's like Human Resource Machine, AND ALSO the language you learn is real
SQL that works outside the game — graded by hidden datasets, so any query that
meets the condition counts, and the hidden data is designed so that hardcoded or
boundary-careless queries fail.**

The hidden-data grading is the hook's mechanism, not a backend detail: it is
what lets the game accept every valid solution (freedom) while still refusing
hardcoded or boundary-careless ones (mastery).

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 7 | Crisp instant feedback on run; receipt-print / stamp sounds on pass |
| **Fantasy** (make-believe, role-playing) | 4 | The konbini part-timer role; requests come from people in the store |
| **Narrative** (drama, story arc) | 5 | Light chat-message story; characters react to your results |
| **Challenge** (obstacle course, mastery) | 1 | Trap-laden conditions, hidden-data grading, chapter bosses, constraint challenges |
| **Fellowship** (social connection) | N/A | Single-player; no social systems in scope |
| **Discovery** (exploration, secrets) | 2 | The "aha" when a hidden row reveals what you misunderstood; finding a second valid solution |
| **Expression** (self-expression, creativity) | 3 | Any valid query counts; constraint challenges reward alternative solutions |
| **Submission** (relaxation, comfort zone) | 6 | The steady rhythm of a shift; no timers, no penalty for running queries |

### Key Dynamics (Emergent player behaviors)

- Players start **probing the boundaries themselves** ("is it `<` or `<=`?")
  before submitting — reading the request for its boundary in Chapter 1, and
  from Chapter 2 adding test rows in the back room (see Core Mechanics #1) —
  because the hidden data has taught them it matters.
- Players **rewrite a cleared puzzle a second way** to beat a constraint
  challenge, discovering that `IN`, `OR`, and `BETWEEN` overlap.
- Players **iterate rapidly** — run, look, tweak — treating the visible data
  as a free scratchpad.
- Experienced SQL users **compete with themselves** on query length and clause
  count. *(Depends on Efficiency Stats — Vertical Slice — and length challenges
  (`max_chars`) — Alpha; not available in the MVP.)*

### Core Mechanics (Systems we build)

1. **Query workbench** — SQL editor + instant run against the visible dataset
   (embedded SQLite), with result table, target-result comparison, and schema
   browser. **Run never shows a pass state** — it reports "matches the target
   on today's data" in wording and visuals distinct from a passed submit.
   From **Chapter 2** (when `INSERT`/`UPDATE`/`DELETE` are taught) it includes a
   **back room**: a throwaway copy of the visible data where the player may
   insert, edit, and delete test rows to probe a boundary before submitting. It
   resets per puzzle and is never graded, so it does not violate the
   no-persistent-state anti-pillar. Not in Chapter 1: those players cannot yet
   write `INSERT` (decision 2026-10-14).
6. **Store manual** — an in-world reference binder (left by the previous
   part-timer) with a page per SQL keyword and a short example. Pages unlock the
   first time a puzzle needs that keyword and are always available, never
   pushed at the player. This is the zero-SQL player's syntax path.
2. **Hidden-data grader** — on submit, the player's query and the reference
   query run against hidden datasets; results compared as a multiset (column
   count + rows, order ignored unless the puzzle requires `ORDER BY`).
   **Failure feedback escalates in specificity and never shows hidden rows**:
   (1) first failed submit — a plain-language symptom in a character's voice,
   no jargon ("You let in something that isn't a snack"); (2) repeated fails —
   the offending clause is highlighted in the editor; (3) further fails — an
   authored *synthetic* counter-example row (not a hidden row) shown to the
   player — and, from Chapter 2, addable in the back room. Hidden-dataset rows are never shown, because a visible
   `extra`/`missing` row can be special-cased in the query, defeating Pillar 1.
   **MVP ships level 1 only** (symptom + generic fallback); levels 2–3 are
   Vertical Slice (scope-check 2026-10-14).
   Each trap therefore needs authored feedback at each level, plus a generic
   fallback for wrong queries no trap anticipated (selection rules belong to
   the grader GDD).
3. **Request & reaction layer** — puzzles arrive as chat messages from
   characters; pass/fail and error messages are voiced by them (e.g. "There's no
   column called 'prise'. Did you mean 'price'?").
4. **Constraint challenges** — optional re-runs of cleared puzzles with a rule
   that forces a different valid solution. Chapter 1 ships "use `BETWEEN`" and
   "no `IN`"; length challenges ("under N characters") are Alpha.
5. **Shift progression** — puzzles grouped into shifts and chapters; each
   chapter introduces SQL concepts and ends with a boss puzzle combining them.

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | No single intended answer; constraint challenges and side puzzles are optional | Supporting |
| **Competence** (mastery, skill growth) | Traps you fell for early, you avoid at the boss; constraint clears prove fluency; the skill transfers to real life | Core |
| **Relatedness** (connection, belonging) | Manager Tanaka, Kenji, and Mrs. Sato react to your work | Minimal |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: clearing every puzzle and every constraint challenge; humorous achievements ("UPDATE without WHERE")
- [x] **Explorers** (discovery, understanding systems, finding secrets) — How: understanding *why* a query failed on hidden data; discovering equivalent formulations
- [ ] **Socializers** (relationships, cooperation, community) — Not served in this scope
- [ ] **Killers/Competitors** (domination, PvP, leaderboards) — Personal efficiency stats only; global leaderboards deferred (see MVP)

### Flow State Design

- **Onboarding curve**: First 10 minutes = puzzles 1-1 to 1-3. `SELECT *` with the run button, then choosing columns, then the first `WHERE`. Puzzle 1-3 is the first where a hardcoded answer passes the visible data and fails hidden data — the game's core lesson arrives early, in a low-stakes puzzle.
- **Difficulty scaling**: One new concept per puzzle; each chapter's boss combines all of them. Constraint challenges raise the ceiling for players who are ahead, without blocking players who are not.
- **Feedback clarity**: Instant result table vs. target on every run (never shown as a pass); on submit, feedback that escalates from a plain-language symptom to a highlighted clause to a synthetic counter-example — never the hidden rows (e.g. 1-6 eventually draws the implicit parentheses of an AND/OR precedence mistake).
- **Recovery from failure**: Instant. Running is free and unlimited; a failed submit costs nothing but a reaction line. Two-step hints and skippable puzzles prevent hard stops.

---

## Core Loop

### Moment-to-Moment (30 seconds)

Read the request → glance at the table → write or tweak the query → **run
instantly** → compare the result with the target → tweak again. Running
against visible data is free, unlimited, and immediate. This loop must feel
like a fast terminal, not a test: write, run, see, fix.

### Short-Term (5-15 minutes)

One puzzle. When confident, the player **submits**: the query is graded on
hidden datasets A and B. Failure shows escalating feedback (never the hidden
rows) and the requester's reaction ("Give me an answer that's always right, not just right
today"). Passing unlocks the puzzle's **constraint challenge**, if it has one;
efficiency stats arrive from the Vertical Slice. "One more puzzle" lives in the
short gap between requests.

### Session-Level (30-60 minutes)

One shift: 3–5 puzzles, ending with clocking out and receiving the shift's
wage. *(Shift length pending playtest — ≈ 15–18 min at Chapter 1's 3 / 4 / 4
split; `shift-and-chapter-progression.md` Open Question 3.)* The end of a shift is the natural stopping point. The reason to return
is the next concept unlock and the constraint challenge left unbeaten.

### Long-Term Progression

The player grows in **knowledge**, not power. Each shift introduces an SQL
concept; each chapter boss tests the full set. In the shipped scope the arc
runs from `SELECT` to `JOIN` (Chapters 1–4). The game is "done" when the
final chapter boss falls; it is *mastered* when every constraint challenge is
cleared.

### Retention Hooks

- **Curiosity**: The next concept and the next request; the store's story through chat messages
- **Investment**: Chapter progress; the characters' growing trust in you
- **Social**: None in scope (shareable solutions are a post-launch idea)
- **Mastery**: Unbeaten constraint challenges; personal-best query length and clause count (from Efficiency Stats, Vertical Slice, and `max_chars` challenges, Alpha)

---

## Game Pillars

### Pillar 1: The Condition, Not the Screen
You pass by understanding the condition, never by matching the visible result.

*Design test*: Choosing between a puzzle that drills syntax and one with a trap
that passes visible data but fails hidden data, we choose **the trap**.

### Pillar 2: Your Query, Your Way
Any query that meets the condition is correct. *"Correct" means passing every
hidden dataset for the puzzle — a finite approximation of the condition, so
hidden datasets must be designed to separate understanding from guessing.*

*Design test*: Debating whether a base puzzle should require `IN` rather than
`OR`, we **accept both** — and move any required form into a constraint
challenge.

### Pillar 3: Fast Hands, Cheap Mistakes
Running is instant and free; only submission is graded.

*Design test*: Choosing between a dramatic submit sequence and faster
feedback, we choose **faster feedback**.

### Pillar 4: Real Store, Real SQL
Every request has a konbini reason, and every query is standard SQLite usable
in real life.

*Design test*: Choosing between a fun invented command and real SQL, we choose
**real SQL**; choosing between an abstract puzzle and a request the store
would actually make, we choose **the store's request**.

*Tension by design*: Pillar 1 (engineered traps) pulls against Pillar 4
(realistic requests); Pillar 2 (free solutions) pulls against Pillar 1
(conditions must be understood). The hidden-data grader is where they meet.

### Anti-Pillars (What This Game Is NOT)

- **NOT a store-management sim**: no hiring, pricing, or economy systems. They would compete with the puzzles for attention and blow the scope.
- **NOT a textbook**: no lectures or quizzes. Concepts are taught through requests and failure feedback; lectures would make it feel like edu-software (Pillar 4). A reference the player *chooses* to open — the in-world store manual — is allowed; anything that interrupts play to teach is not.
- **NOT persistent per-player database state between puzzles**: each puzzle starts from known data, otherwise hidden-data grading breaks (Pillars 1 and 2).
- **NOT a simplified SQL dialect**: if it doesn't run in SQLite, it isn't in the game (Pillar 4).

---

## Visual Identity Anchor

*Confirmed and revised in `/art-bible` 2026-10-14 — the full statement, palette
and contrast table live in `design/art/art-bible.md` (Sections 1–4); this is the
summary.*

**Direction: "Behind the Counter" (revised: evening shift)**

**One-line visual rule**: Everything looks like it belongs behind a konbini
counter in the evening: warm paper, wood and cardboard around the work, with the
data on top of it all and always legible.

**Two registers**: a warm pixel-art **world** — a 320×30 native-pixel counter
strip shown at ×4 (1280×120 px, nearest filtering) with NPCs and a speech bubble
— and a clean **work surface** — the SQL editor and result tables, undecorated,
high-contrast, non-pixel fonts. They share one palette family.

**Supporting principles**:
1. **Data reads first** (Pillar 1) — the result table and query are always the
   most legible things on screen; text ≥ 4.5:1 (`contrast_min`), glyphs/borders
   ≥ 3:1. *Design test*: if decoration competes with the readability of a
   result row, the decoration goes.
2. **Store paper as UI** (Pillar 4) — results print as receipts, errors arrive as
   sticky notes, passes get a hanko-style stamp, shelf labels name the tables;
   paper stays flat under SQL text. *Design test*: when a UI element needs a
   frame, ask what paper or object in a konbini would hold it.
3. **Warm, quiet, and fast** (Pillar 3; replaces "Quiet fluorescent calm") — a
   slightly aesthetic, cozy store in soft evening light, never neon chaos, and
   feedback is never slowed by ambience. *Design test*: between more atmosphere
   or motion and faster, calmer feedback, choose faster feedback.

**Color philosophy**: Warm cream receipt paper, wood and cardboard browns and
soft lamp-amber light as the base (replaces "cool fluorescent neutrals"); one
fictional chain accent (indigo) plus hanko vermilion for seals; never colour
alone — every signal also carries a glyph and a word; green and red reserved for
the Submit verdict only (result rows use neither, so a matching Run never looks
like a PASS). Light Japanese flavor (いらっしゃいませ on the sign) in decoration
only — all gameplay text is English.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Human Resource Machine | Approachable framing that teaches programming to non-programmers | A real language instead of an invented one | Proves programming puzzles can reach beginners |
| TIS-100 / Shenzhen I/O | Test datasets that verify solutions; efficiency stats | Warmer setting, lower barrier to entry | Proves a mastery audience for programming puzzles on Steam |
| Zelda: BotW / TotK shrines | Any solution that obeys the rules is valid; "huh, you can do that?" | Rules are SQL semantics, not physics | The designer's own core taste; shapes Pillar 2 |
| Papers, Please | Mundane paperwork made tense and characterful | Puzzle-paced, no time pressure | Proves "boring" work can be the gameplay |
| SQL Murder Mystery (web) | SQL as a game, not a course | Structured puzzles and progression instead of one open case | Shows demand for SQL presented as play |

*Comparable-title claims here come from general knowledge; no Steam competitor research has been done yet (check for existing SQL puzzle games before the store page).*

*Note: the designer has not yet played the Zachtronics titles or Human
Resource Machine. Playing Human Resource Machine before prototyping is
recommended (short, and the closest model for beginner onboarding).*

**Non-game inspirations**: Japanese convenience-store culture (deli disposal
on expiry day, yen pricing, the night shift); the real experience of learning
SQL on the job, where "it worked on my data" is the classic mistake.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18–40 |
| **Gaming experience** | Mid-core puzzle players; some non-gamers motivated by the skill |
| **Time availability** | 30–60 minute sessions; one shift fits an evening (shift length pending playtest — Progression Open Question 3) |
| **Platform preference** | PC (Steam) |
| **Current games they play** | Puzzle games (programming puzzles, logic puzzles), cozy narrative games |
| **What they're looking for** | A puzzle game where the skill is real and transfers to work or study |
| **What would turn them away** | Feeling lectured; syntax drills; harsh punishment for mistakes; a fake SQL that doesn't work outside |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | **Godot 4.7.2 (GDScript)** — decided in `/setup-engine`. `CodeEdit` provides the SQL editor and godot-sqlite v4.9 embeds SQLite; the spike confirmed both work (`prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md`). |
| **Key Technical Challenges** | SQLite integration is proven in the spike, but godot-sqlite returns rows as dictionaries, so a zero-row result has no column count and duplicate column names collapse (**resolved** — `sql-execution-sandbox.md` rules 10–11 read the column list from a temp view, so the count survives zero rows and duplicates are kept); a responsive SQL editor (highlighting works; autocomplete untried); multi-dataset grading for both query and modify (`UPDATE`/`DELETE`) puzzles; translating SQLite errors into character-voiced messages; enforcing constraint challenges (e.g. detecting `OR` in a query) |
| **Art Style** | 2D, UI-centric, illustrated konbini backdrop |
| **Art Pipeline Complexity** | Low–Medium (custom 2D UI and a few character portraits) |
| **Audio Needs** | Moderate (store ambience, UI feedback sounds, light music) |
| **Networking** | None |
| **Content Volume** | Full vision: ~50 puzzles across 4 chapters, ~6–10 hours; demo: Chapter 1 (13 puzzles, ~1 hour; three shifts — see Progression Open Question 3) |
| **Procedural Systems** | None — hand-authored datasets; hidden datasets are hand-designed edge cases |

---

## Risks and Open Questions

### Design Risks
- The game may feel like edu-software despite the puzzle framing — mitigated by Pillar 4's "store request" rule and the no-textbook anti-pillar.
- Typing SQL may exclude players who don't want to type code; a beginner who doesn't know `SELECT` may bounce in the first minute.
- Hidden-data failures may feel unfair if feedback doesn't show *why*; with hidden rows deliberately not shown, the authored cause feedback (level 1) and character reactions must carry the whole lesson.
- Traps may not bite players who already know some SQL (first playtest: zero hidden-data failures) — the core "aha" is unproven; see Core Fantasy.

### Technical Risks
- SQLite integration and the in-game code editor are proven on Godot 4.7.2 by the spike (`prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md`). Resolved: godot-sqlite's dictionary rows (zero-row column count, duplicate column names) — `sql-execution-sandbox.md` rules 10–11. Still open: editor autocomplete is untried; only the Linux binary is verified (the Windows `.dll` is untested).
- Constraint challenges require analyzing query text reliably (tokenizing, not naive string search).
- Modify puzzles need DB-state comparison and a "rewind" mechanism, a different grading path from query puzzles.

### Market Risks
- Programming puzzles are a niche; the "learn real SQL" angle must widen the audience without scaring off puzzle fans.
- First game, solo — no existing audience; the Steam Next Fest demo is the main discovery channel.

### Scope Risks
- The draft's 7-chapter plan exceeds a first-game, months-long timeline; Chapters 5–7 are deferred (see Scope Tiers).
- Each puzzle needs hand-designed hidden edge cases and verification; content cost per puzzle is higher than it looks. The `ch1.py` verifier pattern must scale.

### Open Questions
- **Efficiency metric**: character count vs. token count vs. `EXPLAIN QUERY PLAN` cost — answer by prototyping and playtesting Chapter 1.
- **Dates**: keep string comparison in Chapter 1 or introduce date functions early? — decide during Chapter 2 design.
- **Column names**: keep ignoring aliases, or require them where teaching (e.g. S-2 `AS margin`)? — **Resolved:** names and aliases are ignored, column order is significant (`hidden-data-grader.md` rule 16).
- **Is the core loop fun for a non-SQL player?** — **Partly answered.** Players with some SQL finished Chapter 1 and wanted more; zero-SQL players are untested (needed before the demo).
- **Do the traps bite?** — no hidden-data failure occurred in the first playtest; trap difficulty is an input to the puzzle GDD.
- **Real timings** — Core Identity says 3–5 puzzles per 30–60 min shift and the demo is "13 puzzles, ~1 hour" (~4.6 min each), while a puzzle is described as 5–15 min. Record timings in the next playtest and reconcile (tracked as `shift-and-chapter-progression.md` Open Question 3: 3 / 4 / 4 split ≈ 15–18 min per shift).

---

## MVP Definition

**Core hypothesis**: Players — including SQL beginners — find the
write-run-submit loop with hidden-data grading satisfying enough to finish
Chapter 1 and want a constraint challenge afterwards.

**How it is measured** (next playtest: 3 zero-SQL + 3 some-SQL testers, observed,
with a log of every run, submit, hint use and help request per puzzle, plus
per-puzzle timings). These guide decisions; they are not statistics.

| Claim | Pass if | If missed |
|---|---|---|
| Satisfying enough to finish | ≥ 2 of 3 in *each* group finish Chapter 1 without outside help (in-game skips count toward "Finish"; each tester's skip count and whether the boss was skipped are reported beside the claim — `playtest-log.md`) | Find the puzzle where they stopped; fix onboarding or that puzzle, re-test |
| Wants more | ≥ 4 of 6 start a constraint challenge or the next chapter unprompted when offered | Revisit reward and pacing before the demo |
| Traps bite (condition 1) | ≥ 2 of 3 some-SQL testers fail 1-6 or 1-11 on their first submit | Rewrite those traps to the trap philosophy, or move the first real trap to Chapter 2 |
| Zero-SQL can start (condition 2) | ≥ 2 of 3 zero-SQL testers clear 1-1 to 1-3 without outside help | Redesign 1-1 onboarding (prefilled query, click-to-insert schema) before the demo |

**Prototype status (2026-10-14): PARTIALLY CONFIRMED — PROCEED (conditional).**
Players with some SQL finished Chapter 1 and wanted more; the hidden-data "aha"
and zero-SQL players remain untested (`prototypes/sqlbini-web/REPORT.md`).

**Required for MVP**:
1. Query workbench: editor, instant run, result vs. target, schema browser (embedded SQLite)
2. Hidden-data grader with cause feedback (level 1; no hidden rows shown)
3. Chapter 1 content: 11 main + 2 side puzzles (designed and verified; requests 1-4, 1-5, 1-7, 1-8 to be rewritten to the trap philosophy)
4. Character-voiced requests, reactions, and rewritten error messages
5. Constraint challenges on a few puzzles
6. Failure feedback level 1 (plain-language symptom + generic fallback) and two-step hints — levels 2–3 deferred to Vertical Slice
7. Store manual pages for every Chapter 1 keyword

**Explicitly NOT in MVP** (defer to later):
- Steam leaderboards, efficiency histograms against other players
- Steam Workshop, sandbox mode, hidden missions
- Chapters 5–7 (subqueries/night-shift mystery, window functions, schema design)
- Localization (English base only)
- Global "see other players' solutions"

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | Chapter 1 (13 puzzles), placeholder art | Workbench, grader (feedback level 1), reactions, hints, a few constraint challenges, store manual, onboarding, playtest log | ~11 weeks expected (7–18) in focused full-time days, incl. ~2–3 weeks of design — `/estimate` 2026-10-14, confidence Low (no velocity history; GDDs not yet written) |
| **Vertical Slice / Demo** | Chapter 1, final art and audio | MVP + polish, achievements, failure feedback levels 2–3 (clause highlight, synthetic counter-example); Steam Next Fest demo | +6–8 weeks (~3 months total) |
| **Alpha** | Chapters 1–3 (~35 puzzles), placeholder where needed | + modify puzzles (`UPDATE`/`DELETE`) with rewind, back room, aggregates | +2–3 months |
| **Full Vision** | Chapters 1–4 (~50 puzzles, through `JOIN`), polished | All of the above + full constraint-challenge set | +1–2 months (6–9 months total) |

*Scope has not had an independent producer review (PR-SCOPE was skipped in lean mode). The Alpha and Full Vision tiers — ~37 more puzzles, each with hand-built hidden edge cases, authored cause feedback and verification, plus modify/rewind grading — are the least certain estimates. MVP now also includes the store manual; the back room moved to Alpha (2026-10-14). Run a producer scope review (`/scope-check`) once `/map-systems` has sized the systems.*

*Post-launch / sequel candidates*: Chapters 5–7, the night-shift mystery,
leaderboards, Workshop, localization.

---

## Next Steps

- [x] Engine chosen and configured — Godot 4.7.2, GDScript (`/setup-engine`)
- [x] Concept prototype — web prototype playtested: PROCEED (conditional), see `prototypes/sqlbini-web/REPORT.md`
- [x] Technical spike — godot-sqlite + CodeEdit on 4.7.2: YES
- [ ] `/gate-check` — confirm readiness to advance from Concept
- [x] `/art-bible` — Visual Identity Anchor confirmed and revised warmer (`design/art/art-bible.md`)
- [x] `/map-systems` — decompose the concept into systems (`design/gdd/systems-index.md`)
- [x] `/design-system` for each MVP system — 11 GDDs written; cause feedback (level 1), zero-row column count and duplicate column names are covered (grader, sandbox rules 10–11); trap difficulty for players with some SQL remains a playtest question
- [ ] Zero-SQL playtest with an observation log, recording per-puzzle timings (before the demo)
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`)
- [ ] Plan first milestone (`/sprint-plan new`)
