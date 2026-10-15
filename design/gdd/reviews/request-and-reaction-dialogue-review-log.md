# Review Log: request-and-reaction-dialogue

## Review — 2026-10-14 — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 2 | Recommended: 7
Summary: The four formulas are sound and their examples re-compute exactly (`bubble_chars_max` 146/48/40, `reaction_hold` 2.5–6.0 s, `did_you_mean` thresholds), the no-leak boundary is clean, and the hybrid counter scene is well specified for art. Two cross-system defects block: the PASS sequence is undefined — Progression delivers the next request at once, so the pass reaction (and the constraint offer that Constraint Challenges attaches to it, with inline Try it / Later buttons "in the message log", an overlay that is closed by default) is overwritten before it can be read or answered, which also breaks the MVP "starts a challenge unprompted when offered" measurement; and the error-template table does not match the sandbox's `error_kind` enum (no `NOT_ALLOWED`, no `CONTENT_ERROR` — a content bug would be voiced as the player's mistake) and keys a template on an "unterminated string" message SQLite never emits (it reports `unrecognized token`).
Prior verdict resolved: First review
Findings:
- [BLOCKING] States and Transitions / Rule 2 `offer` vs Progression rule 11 and Constraint Challenges rule 6: PASS → next request "at once" leaves no defined time on screen for the pass line, and the offer's Try it / Later buttons live in the (closed) message log — define the PASS sequence (pass line held until `reaction_hold` / click, offer and its buttons in the bubble, then the next request) jointly with Progression and Challenges
- [BLOCKING] Core Rule 6 vs sandbox `error_kind`: templates missing for `NOT_ALLOWED` and `CONTENT_ERROR` (must never blame the player — e.g. "Sorry, the ledger's smudged — not your fault"); "unterminated string" pattern should be `unrecognized token` (sandbox edge case)
- [RECOMMENDED] Edge Cases (first bullet) and States table: "edits → returns at once" contradicts Rule 3's `reaction_grace` (1.0 s) and RD-03 — align
- [RECOMMENDED] Rule 2 `fail`: the built-in lines for `columns` / `order` / `nondeterministic` / `generic` are owned here (grader rule 10) but not written or listed; grader requires `generic` to include "check what each column holds" — add them (or their string ids and required content)
- [RECOMMENDED] Rule 6 / UI Req 5: the bubble (2 lines, 146 chars) cannot also hold the raw SQLite message — state that the raw text lives in the workbench error strip (rule 13) and the bubble carries the gloss only
- [RECOMMENDED] Rule 3 / Formulas `bubble_chars_max`: at `ui_scale` 1.5–2.0 a page holds 40–48 chars, so a typical request becomes 3–4 pages and "one glance away" fails — add a request length budget (e.g. ≤ 146 chars) or a persistent full-request view
- [RECOMMENDED] Formulas `did_you_mean`: `names` is "the chapter's column names" — use the open puzzle's schema (puzzles carry their own schema)
- [RECOMMENDED] AC RD-02: tests a trap key "at level 2" — MVP `feedback_max_level` is 1 (registry); test level 1 and mark level 2 as Vertical Slice
- [RECOMMENDED] Header / Dependencies / Cross-References: Status "In Design" and "Designed (pending review)" are stale (index: Designed; grader, sandbox, workbench, progression, challenges are In Review); `reaction_grace` and `len` for paged lines (whole line or last page?) not in the Formulas tables; Player Fantasy and Tuning Knobs absent (advisory at `standard`; Game Feel and the Formulas ranges partly cover them)
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md 787ea01eb650554bc222fee52b41a3f89120c86a
Reviewed-Content-Hash: design/registry/entities.yaml 4d2eb289795d0ce9b9f686786ff036a3aa6c5e83
Revised in-session (2026-10-14, after the review; user decisions: pass line held then next request, guidance in coach-mark labels): BLOCKING PASS sequence fixed — rule 3a + `PassReaction` state: pass + offer line with Try it / Later held for `reaction_hold` (click / Enter ends early; edits and Run do not), then the next request; an unanswered offer becomes an offer ticket on the strip until it expires (RD-17); Progression rule 11 / PR-15 and Constraint Challenges rule 6 aligned. BLOCKING error templates fixed — every sandbox `error_kind` has a template incl. `NOT_ALLOWED` and `CONTENT_ERROR` (Kenji, never blames the player); `unrecognized token` replaces "unterminated string" (RD-09). Also fixed: opening question as a `system` line before 1-1, guidance never in the bubble (RD-18); edge-case grace contradiction; built-in fail lines and required content; raw text lives in the error strip; `did_you_mean` uses the puzzle's schema; RD-02 at level 1; `reaction_grace` and paged `len` in Formulas; stale statuses. Not done: request length budget at high `ui_scale`, Player Fantasy / Tuning Knobs (advisory). Re-review pending in a fresh session.

## Review — 2026-10-15 (re-review after cross-GDD review fixes and 6a rule 2 change, fresh session) — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; fresh session, not the authoring session — each doc reviewed by a read-only subagent, blocking items verified against the text in the main session)
Blocking items: 1 | Recommended: 5
Summary: Prior blockers (PASS sequence, error templates) resolved; B1 (Kenji line, no raw text, UNAVAILABLE), W1, W5 bubble/note split, W6, W11–W13, S2 queue and the Store Manual row are all in. 6a rule 2 is correct: fail.generic carries no column-content/order advice (only the grader's neutral note does). One contract gap: Progression's side-request messages and Kenji's accept line had no kind or string id.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Core Rules 2 / Interactions (Progression): side-request messages and Kenji's skip accept line have no kind, string id or placement (Progression rules 5, 7 send them)
- [RECOMMENDED] Core Rules 6 error table: TOO_MANY_ROWS row said "visible pre-check" only; grader rule 7a/AC-29 also give it from the determinism / visible grading run (fixed in-session, with grader Formulas/Edge Case and sandbox rule 13 wording)
- [RECOMMENDED] Core Rules 6 / UI Req 5 / RD-09: "SQLite's original message always shown" — TOO_MANY_ROWS has no SQLite text (workbench fixed text); add to the exception
- [RECOMMENDED] Formulas len: PASS+offer timed on combined text vs "paged line timed on its last page"; buttons placement when the bubble is full at ui_scale 2.0
- [RECOMMENDED] Acceptance Criteria: no AC asserts fail.generic contains no column advice (RD-20 only checks non-duplication)
- [RECOMMENDED] States: fail → queued offer (S2) not modelled in the state table
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md fd1c405fd5510bccd9a8911dc1494f53b79f7f3b
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084
Revised in-session (2026-10-15, after the review; user decision "ids + log delivery"): rule 2 kinds — `offer` gains built-in `skip.offer` / `skip.accept` (Kenji), new `side` kind; new rule 3b (skip.accept holds like a pass line, then next request or clock-out; side-request messages = message log + strip message ticket, never the bubble); PassReaction state, Progression row, RD-21. TOO_MANY_ROWS row now "any visible run — pre-check, determinism or visible grading run (grader rules 6, 7a)". Status stays In Review; re-review in a fresh session.

## Review — 2026-10-15 (re-review, session 6c-2, fresh session) — Verdict: APPROVED
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 0 | Recommended: 3
Summary: The 6c blocker is resolved: `skip.offer` / `skip.accept` are built-in Kenji lines under the `offer` kind with required content, the new `side` kind delivers side requests to the message log plus a strip ticket (never the bubble), and rule 3b, the PassReaction state, the Progression row and RD-21 match Progression rules 5, 7, 11 and PR-21 (accept holds for `reaction_hold`; edits/Run do not end it; then next request or clock-out). The TOO_MANY_ROWS row ("any visible run") now agrees with grader rules 6/7a, Formulas `e` and its Edge Case, sandbox rule 13 and workbench rule 13. The 6a rule 2 change (column advice only on the grader's neutral note) still holds.
Prior verdict resolved: Yes (6c blocker: skip lines and side messages)
Findings:
- [RECOMMENDED] Dependencies / Cross-References: statuses stale — Puzzle Definition, Grader, Sandbox, Workbench, Constraint Challenges Approved (Progression Approved this session)
- [RECOMMENDED] Core Rule 6 / UI Req 5: "SQLite's original message always shown" exception still omits TOO_MANY_ROWS (fixed workbench text, no SQLite text) — already queued for 6d
- [RECOMMENDED] UI Req 1 / rule 3b: offer ticket and side-message ticket can both sit at the strip's right edge — placement for /ux-design (not blocking)
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md 4522ef4468cfdfb8d608f5cdb21e3a62e2fcb9f4
Reviewed-Content-Hash: design/registry/entities.yaml 0a8f21f0d31f4321478b519974332fc321281084

## Review — 2026-10-15 (re-review 6e of the 6d rule changes, fresh session) — Verdict: NEEDS REVISION
Scope signal: M
Specialists: none (lean mode; independent session — not the authoring session)
Blocking items: 1 | Recommended: 4
Summary: Rule 3c / `Briefing` state (Day One order briefing → "Ever used SQL before?" → 1-1), dimmed side tickets in challenge mode (rule 3b, matches CC rule 6c), the UNAVAILABLE offer queue exception (matches Progression rule 7a) and TOO_MANY_ROWS with no `error_text` (rule 6, RD-09) are in. One gap: side-request messages arrived at shift start, i.e. during the briefing; opening that ticket left no way to end the briefing, and the first main request opens only when the briefing ends — a possible hard stop. The briefing-end signal to Progression was also missing from both Interactions tables.
Prior verdict resolved: Yes (6c-2 APPROVED)
Findings:
- [BLOCKING] Core Rules 3b × 3c / Interactions (Progression): side ticket openable during `Briefing` → briefing never ends, first main stays Locked; no briefing-end signal
- [RECOMMENDED] Core Rule 2 (bubble vs strip, `error` kind row) / UI Req 5: TOO_MANY_ROWS exception missing (rule 6 is right)
- [RECOMMENDED] States: the state while Onboarding's "Ever used SQL before?" line holds the bubble (between `Briefing` and `Request`) is unnamed
- [RECOMMENDED] Core Rule 3c: initial keyboard focus during the briefing (Enter/Space need the counter scene focused) → /ux-design
- [RECOMMENDED] Info carried from 6d not re-raised (start-over line queue, Restart subscription, PassReaction clock-out row)
Reviewed-Content-Hash: design/gdd/request-and-reaction-dialogue.md 57152491bdd8e8ec0d2484f8b7d48bc1e528b91d
Reviewed-Content-Hash: design/registry/entities.yaml 9bfe3fd10be0643425af7af9514ee5e77a2e56f2
Revised in-session (2026-10-15, after the review; user decision "tickets after the briefing ends"): rule 3b — side messages arrive when the shift's briefing ends, never during it; rule 3c — Dialogue tells Progression when the briefing ends (first main opens, side messages arrive); Progression Interactions row; RD-21 (briefing end), RD-22 (Afternoon/S-1 case); wording: TOO_MANY_ROWS exception in rule 2 and UI Req 5. Status → In Review; re-review in a fresh session.
