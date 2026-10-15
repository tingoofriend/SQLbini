# Smoke Test: Critical Paths

**Purpose**: Run these 10-15 checks in under 15 minutes before any QA hand-off.
**Run via**: `/smoke-check` (which reads this file)
**Update**: Add new entries when new core systems are implemented.

## Core Stability (always run)

1. Game launches (boot loading state → first screen) without crash
2. A Chapter 1 request can be opened from the chapter list
3. The workbench responds to keyboard input without freezing (type, Run, Submit)

## Core Mechanic (update per sprint)

<!-- Add the primary mechanic for each sprint here as it is implemented -->
4. [Primary mechanic — update when first core system is implemented, e.g. "Run on 1-1 shows the result table; Submit on the prefill passes 1-1"]
5. A runaway query returns TIMEOUT and the next Run works (ADR-0001 — include in the first exported-build smoke check)

## Data Integrity

6. Content verifier: no Chapter 1 puzzle is withheld in a playtest build (ADR-0003)
7. Playtest build writes `user://playtest-logs/<session>.jsonl` and ends with `session_end` on quit (ADR-0004)

## Performance

8. No visible frame rate drops on target hardware (60 fps target) while queries run
9. No memory growth over 5 minutes of play (once core loop is implemented)
