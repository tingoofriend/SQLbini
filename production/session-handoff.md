# Session Handoff

<!-- Tracked in git (unlike production/session-state/active.md, which is gitignored and
     stays on one machine). Read by tools/session/auto-session.sh / .ps1 to pick the
     next session; Claude rewrites the fields below at the end of every session.
     Field formats are parsed by the scripts — keep "- **Field:** value" on one line. -->

- **Updated:** 2026-10-17 (session 10b)
- **Next prompt:** 11
- **Next machine:** windows
- **Auto-continue:** yes

`Next prompt`: a session id with a file `production/session-prompts/session-<id>-*.md`,
or `auto` for the standing prompt (`session-auto-continue.md`), which works from
the Next step below. `Next machine`: `linux`, `windows` or `any` — the loop stops
on the wrong machine. `Auto-continue`: `no` stops the loop after the current session.

## Next step

Session 11 on a Windows PC (`production/session-prompts/session-11-windows-spike-adr-0005.md`):
(0) light check of the three UX specs revised in 10b, then ask per spec whether
to mark it Approved; (1) Windows spikes — godot-sqlite `.dll`, ADR-0001 thread
probes, PL-07, renderer, exported grapheme counts, CodeEdit chord probe on
Windows; (2) target PC + `submit_worst`; (3) ADR-0005 → `project.godot` + export
presets + `commands.build`; (4) `/architecture-review` coverage →
`/gate-check pre-production`.

## Carry-over (state the next machine cannot read from active.md)

**Stage:** Technical Setup. All 11 MVP GDDs Approved; ADR-0001…0004, 0006, 0007,
0010 Accepted; ADR-0005 not written (Windows spike), ADR-0008 / 0009 planned.
Control manifest version 2026-10-17. Last commit: session 10b.

**/ux-review 2026-10-17 (10b) — what step 0 must check** (all fixed in-session,
specs marked "revised after /ux-review 2026-10-17, light check pending"):
- query-workbench.md: B1 *Options* opens the shift screen with the options panel
  (IP-22); B2 F9 note written as `help_note` on any close (Enter / Esc / 5 s),
  empty writes nothing (ADR-0004 §4, playtest-log rule 7); B3 states Request
  shown again (draft, result, verdict restored), Target unavailable, Verdict for
  previous text (+ Zero rows, Over display cap); verdict kept through a Run of
  unchanged text with the tally note beside it (developer decision); order line
  "! Rows match; order differs"; boot failure Quit only (developer decision);
  UX-QW-19…23.
- shift-flow.md: SB1 *Try the dare* on ☆ and ★ rows (cleared dare replay);
  `challenge_start {source: chapter_list}`; withheld side requests have no row.
- interaction-patterns.md: P1 Animation + Sound Standards tables; P2 IP-13
  reveal completes on the paging inputs only (dialogue rule 5); P3 IP-20 replay;
  IP-01 chord note from the probe; IP-08 restore on return; IP-03 menu; no tooltips.
- Open, not blocking: workbench OQ9 / shift-flow OQ7 — receipt "Leave it for
  Kenji" and chapter-list *Try the dare* have no named call path in ADR-0010.
- Probe `prototypes/codeedit-shortcut-probe-2026-10-17/`: a focused CodeEdit
  consumes Ctrl+Enter, Ctrl+Shift+Enter, Ctrl+M before `_shortcut_input`;
  Ctrl+Shift+S is free (Linux; re-run on Windows in step 0).

**Wording recommendations held (GDDs not edited):** dialogue Formulas / Game
Feel "any key completes the reveal" vs rule 5; `accessibility-requirements.md`
Reading time ("verdict persists", "any key"); workbench GDD r.15 shortcut table
lacks Ctrl+Shift+S; ADR-0010 requirements row says Store Manual unlocks on
`request_opened` while §4 routes `request_shown`.

**Open questions:** zero-SQL playtest not dated; `project.godot` lacks the
1280×720 viewport (fix before strip work); 64 MB texture ceiling + renderer →
ADR-0005.
