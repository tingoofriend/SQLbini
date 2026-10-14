# Game Concept: SQLbini

*Created: 2026-10-14*
*Status: Draft*
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
| **Session Length** | 30–60 min (one shift = 3–5 puzzles) |
| **Monetization** | Premium; Chapter 1 as a free demo (Steam Next Fest) |
| **Estimated Scope** | Medium (6–9 months, solo, first game) — see Scope Tiers |
| **Comparable Titles** | Human Resource Machine, TIS-100, SQL Murder Mystery (web) |

---

## Core Fantasy

You are the part-timer who **actually understands the condition**. On your
first shift you fall for every trap — "under 200 yen" missed the 200-yen
drink, the snack list let a ¥40 corn stick sneak in. By closing time you check
the boundaries before the manager has to ask. And you did it *your* way: no
one handed you the answer query; the store's data simply proved yours right.

The skill is real. What you learn writing a disposal list for Manager Tanaka is
the same SQL you would use at a job.

---

## Unique Hook

**It's like Human Resource Machine, AND ALSO the language you learn is real
SQL that works outside the game — graded by hidden datasets, so any correct
query counts and no "looks right" query survives.**

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
  before submitting, because the hidden data has taught them it matters.
- Players **rewrite a cleared puzzle a second way** to beat a constraint
  challenge, discovering that `IN`, `OR`, and `BETWEEN` overlap.
- Players **iterate rapidly** — run, look, tweak — treating the visible data
  as a free scratchpad.
- Experienced SQL users **compete with themselves** on query length and clause
  count.

### Core Mechanics (Systems we build)

1. **Query workbench** — SQL editor + instant run against the visible dataset
   (embedded SQLite), with result table, target-result comparison, and schema
   browser.
2. **Hidden-data grader** — on submit, the player's query and the reference
   query run against hidden datasets; results compared as a multiset (column
   count + rows, order ignored unless the puzzle requires `ORDER BY`); failures
   show missing/extra rows.
3. **Request & reaction layer** — puzzles arrive as chat messages from
   characters; pass/fail and error messages are voiced by them (e.g. "There's no
   column called 'prise'. Did you mean 'price'?").
4. **Constraint challenges** — optional re-runs of cleared puzzles with a rule
   ("no `OR`", "under 60 characters") that force a different valid solution.
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
- **Feedback clarity**: Instant result table vs. target on every run; on submit, exactly which rows were missing or extra and a character's reaction explaining the misunderstanding (e.g. 1-6 draws the implicit parentheses of an AND/OR precedence mistake).
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
hidden datasets A and B. Failure shows the missing/extra rows and the
requester's reaction ("Give me an answer that's always right, not just right
today"). Passing shows efficiency stats and unlocks the puzzle's **constraint
challenge**. "One more puzzle" lives in the short gap between requests.

### Session-Level (30-120 minutes)

One shift: 3–5 puzzles, ending with clocking out and receiving the day's
wage. The end of a shift is the natural stopping point. The reason to return
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
- **Mastery**: Unbeaten constraint challenges; personal-best query length and clause count

---

## Game Pillars

### Pillar 1: The Condition, Not the Screen
You pass by understanding the condition, never by matching the visible result.

*Design test*: Choosing between a puzzle that drills syntax and one with a trap
that passes visible data but fails hidden data, we choose **the trap**.

### Pillar 2: Your Query, Your Way
Any query that meets the condition is correct.

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
- **NOT a textbook**: no lectures or quizzes. Concepts are taught through requests and failure feedback; lectures would make it feel like edu-software (Pillar 4).
- **NOT persistent per-player database state between puzzles**: each puzzle starts from known data, otherwise hidden-data grading breaks (Pillars 1 and 2).
- **NOT a simplified SQL dialect**: if it doesn't run in SQLite, it isn't in the game (Pillar 4).

---

## Visual Identity Anchor

*Draft — the AD-CONCEPT-VISUAL gate was skipped (review mode: lean). Confirm or
replace in `/art-bible`.*

**Direction: "Behind the Counter"**

**One-line visual rule**: Every UI element looks like something you'd find
behind a konbini counter.

**Supporting principles**:
1. **Data reads first** — the result table and query are always the most
   legible things on screen. *Design test*: if decoration competes with the
   readability of a result row, the decoration goes.
2. **Store paper as UI** — results print as receipts, errors arrive as sticky
   notes, passes get a hanko-style stamp, shelf labels name the tables.
   *Design test*: when a UI element needs a frame, ask what paper or object in
   a konbini would hold it.
3. **Quiet fluorescent calm** — a clean, softly lit store, never neon chaos.
   *Design test*: between more motion and more calm, choose calm unless it is
   feedback on the player's action.

**Color philosophy**: Off-white receipt paper and cool fluorescent neutrals as
the base; one fictional chain accent color for brand identity; green and red
reserved strictly for pass/fail and matching/missing rows, so color always
carries meaning. Light Japanese flavor (いらっしゃいませ on the sign) in
decoration only — all gameplay text is English.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Human Resource Machine | Approachable framing that teaches programming to non-programmers | A real language instead of an invented one | Proves programming puzzles can reach beginners |
| TIS-100 / Shenzhen I/O | Test datasets that verify solutions; efficiency stats | Warmer setting, lower barrier to entry | Proves a mastery audience for programming puzzles on Steam |
| Zelda: BotW / TotK shrines | Any solution that obeys the rules is valid; "huh, you can do that?" | Rules are SQL semantics, not physics | The designer's own core taste; shapes Pillar 2 |
| Papers, Please | Mundane paperwork made tense and characterful | Puzzle-paced, no time pressure | Proves "boring" work can be the gameplay |
| SQL Murder Mystery (web) | SQL as a game, not a course | Structured puzzles and progression instead of one open case | Shows demand for SQL presented as play |

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
| **Time availability** | 30–60 minute sessions; one shift fits an evening |
| **Platform preference** | PC (Steam) |
| **Current games they play** | Puzzle games (programming puzzles, logic puzzles), cozy narrative games |
| **What they're looking for** | A puzzle game where the skill is real and transfers to work or study |
| **What would turn them away** | Feeling lectured; syntax drills; harsh punishment for mistakes; a fake SQL that doesn't work outside |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Undecided — decide in `/setup-engine`. Key criterion: how cleanly the engine embeds SQLite and supports a text-editor-heavy UI. |
| **Key Technical Challenges** | Embedding SQLite; a responsive SQL editor (highlighting, possibly autocomplete); multi-dataset grading for both query and modify (`UPDATE`/`DELETE`) puzzles; translating SQLite errors into character-voiced messages; enforcing constraint challenges (e.g. detecting `OR` in a query) |
| **Art Style** | 2D, UI-centric, illustrated konbini backdrop |
| **Art Pipeline Complexity** | Low–Medium (custom 2D UI and a few character portraits) |
| **Audio Needs** | Moderate (store ambience, UI feedback sounds, light music) |
| **Networking** | None |
| **Content Volume** | Full vision: ~50 puzzles across 4 chapters, ~6–10 hours; demo: Chapter 1 (13 puzzles, ~1 hour) |
| **Procedural Systems** | None — hand-authored datasets; hidden datasets are hand-designed edge cases |

---

## Risks and Open Questions

### Design Risks
- The game may feel like edu-software despite the puzzle framing — mitigated by Pillar 4's "store request" rule and the no-textbook anti-pillar.
- Typing SQL may exclude players who don't want to type code; a beginner who doesn't know `SELECT` may bounce in the first minute.
- Hidden-data failures may feel unfair if feedback doesn't show *why*; the missing/extra-row display and character reactions must carry the lesson.

### Technical Risks
- SQLite integration and a usable in-game code editor are the two hardest pieces and are engine-dependent.
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
- **Column names**: keep ignoring aliases, or require them where teaching (e.g. S-2 `AS margin`)? — decide in the grader GDD.
- **Is the core loop fun for a non-SQL player?** — answer with a playtest of the existing web prototype before engine work.

---

## MVP Definition

**Core hypothesis**: Players — including SQL beginners — find the
write-run-submit loop with hidden-data grading satisfying enough to finish
Chapter 1 and want a constraint challenge afterwards.

**Required for MVP**:
1. Query workbench: editor, instant run, result vs. target, schema browser (embedded SQLite)
2. Hidden-data grader with missing/extra-row feedback
3. Chapter 1 content: 11 main + 2 side puzzles (already designed and verified)
4. Character-voiced requests, reactions, and rewritten error messages
5. Constraint challenges on a few puzzles
6. Two-step hints

**Explicitly NOT in MVP** (defer to later):
- Steam leaderboards, efficiency histograms against other players
- Steam Workshop, sandbox mode, hidden missions
- Chapters 5–7 (subqueries/night-shift mystery, window functions, schema design)
- Localization (English base only)
- Global "see other players' solutions"

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | Chapter 1 (13 puzzles), placeholder art | Workbench, grader, reactions, hints, a few constraint challenges | 4–6 weeks |
| **Vertical Slice / Demo** | Chapter 1, final art and audio | MVP + polish, achievements; Steam Next Fest demo | +6–8 weeks (~3 months total) |
| **Alpha** | Chapters 1–3 (~35 puzzles), placeholder where needed | + modify puzzles (`UPDATE`/`DELETE`) with rewind, aggregates | +2–3 months |
| **Full Vision** | Chapters 1–4 (~50 puzzles, through `JOIN`), polished | All of the above + full constraint-challenge set | +1–2 months (6–9 months total) |

*Post-launch / sequel candidates*: Chapters 5–7, the night-shift mystery,
leaderboards, Workshop, localization.

---

## Next Steps

- [ ] Get concept approval from creative-director
- [ ] Fill in CLAUDE.md technology stack based on engine choice (`/setup-engine`)
- [ ] Create game pillars document (`/design-review` to validate)
- [ ] **Prototype core idea** (`/prototype [core-mechanic]`) — the web prototype (`prototypes/sqlbini-web/prototype.html`) already exists; playtest it before engine work
- [ ] If prototype PROCEEDS: Decompose concept into systems (`/map-systems`)
- [ ] Design each system (`/design-system [system-name]`) — use prototype learnings in Tuning Knobs and Formulas sections
- [ ] Build vertical slice in Pre-Production (`/vertical-slice`) — validate full game loop before committing to Production
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
