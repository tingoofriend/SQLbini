# Ideas Backlog

Ideas, thoughts and requests the developer raises at any time, captured so they
survive between sessions and reach the right pipeline step. Check this file at
the start of each design step (`/design-system`, `/art-bible`, `/ux-design`,
chapter design) and pull in what applies.

| # | Date | Idea (developer's words, summarized) | Related system / doc | Target step | Scope impact | Status |
|---|------|--------------------------------------|----------------------|-------------|--------------|--------|
| 1 | 2026-10-14 | Overall mood: slightly **aesthetic, cozy**. | Visual Identity Anchor (`game-concept.md`), art bible, audio direction | `/art-bible` (Systems Design, before Technical Setup gate); audio-director at Audio GDD | None on systems; shapes palette/typography/music. Mostly compatible with "Behind the Counter" (store paper, quiet calm) — pushes it warmer and softer than "cool fluorescent neutrals" | deferred → `/art-bible` |
| 2 | 2026-10-14 | *Not final:* instead of (or alongside) a chat-message window, show requests via **pixel-art NPCs with speech bubbles** at the counter. | Request & Reaction Dialogue (#9), Query Workbench layout (request bar), art bible | `/design-system request-and-reaction-dialogue` (offer as an option there); `/art-bible` (pixel art vs illustrated) | Medium — adds character sprites (+ a few expressions each) and a counter scene; layout must keep the editor/tables dominant (data reads first) | **applied** (2026-10-14, user chose the hybrid): ~120 px pixel-art counter scene + speech bubble + message log — `request-and-reaction-dialogue.md`, `query-workbench.md` layout; pixel-art style still to be fixed in `/art-bible` |

Status values: `new` · `applied` (name where) · `deferred` (to which step) · `declined` (why).
