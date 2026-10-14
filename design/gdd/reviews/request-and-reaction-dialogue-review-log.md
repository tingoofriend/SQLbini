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
