# ADR-0007: Tuning Config, String Tables and Session Settings

## Status
Accepted

## Date
2026-10-16

## Last Verified
2026-10-16 (amended after `/architecture-review` 2026-10-16: E3, E4, E5, A1–A7, A12, developer decision on invalid per-puzzle overrides)

## Decision Makers
tingoofriend (developer) + Claude (`/architecture-decision`, autonomous mode, lean review)

## Summary
Every gameplay value must come from data files with load-time validation, every
player-facing string from a string table with defined missing-id behaviour, and
a few player settings must be shared by the presentation systems before
Save/Load exists. Tuning lives in typed JSON files read through a schema-driven
`GameConfig` (reject or clamp per key), strings in English JSON string tables
read by an own `StringTable` (not Godot's `TranslationServer` at MVP), and
session settings in a plain-data `Settings` service with one change signal.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7.2 |
| **Domain** | Core (data / I/O), Localization |
| **Knowledge Risk** | LOW — `JSON`, `FileAccess` reads, `String.format`, signals are pre-4.3. Grapheme counting uses `TextServer` (see Verification) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md`, `modules/ui.md` (4.5 live translation preview); ADR-0003 (JSON + typed conversion), ADR-0004 (BuildFlavour, report tool), ADR-0006 (composition root), ADR-0010 (settings consumers) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (0) Probed 2026-10-16 on 4.7.2 headless (godot-specialist): the primary TextServer is the Advanced one (ICU / HarfBuzz / Graphite built in); `TextServerManager.get_primary_interface().string_get_character_breaks(text, language).size()` counts grapheme clusters — "삼각김밥" 4, "e\u0301" 1, a family ZWJ emoji 1, "abc" 3, "" 0; `String.format` leaves a missing `{key}` as-is and substitutes sequentially (a value containing `{b}` is substituted again); with no Translation registered, resolved text is unchanged, but a registered Translation whose key matches a label's text **does** re-translate it (auto-translate is live). (1) Grapheme counting in an **exported** build — run the combining-mark and ZWJ-emoji cases at the first export, with `include_text_server_data` decided by ADR-0005 (see Risks) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0003 (JSON loading with typed conversion, ContentVerifier check modules), ADR-0004 (BuildFlavour for missing-id behaviour; report tool reads the config file), ADR-0006 (services built by `ServicesFactory`) |
| **Enables** | Dialogue, Hint, Onboarding, Workbench and Store Manual stories that read tuning or show text; ADR-0004 §5 `--config`; the minimal options panel (onboarding UI Req 4) |
| **Blocks** | First Dialogue / Hint story (string ids, tuning); any story reading a tuning knob |
| **Ordering Note** | VS Save/Load serialises `Settings`; VS localisation may move strings to `TranslationServer` (Alternative 1) without changing ids |

## Context

### Problem Statement
Every GDD lists tuning knobs as "data file" values with ranges, and some state
load-time behaviour (Hint "rejected at load … clamped with a warning", HS-14;
sandbox SB-17 `exec_time_limit` clamp; workbench font clamps). Dialogue rule 9
requires string tables keyed by id with a missing id shown as `[id]` in dev and a
generic line in release, logged, and lengths counted in grapheme clusters; RD-12
forbids player-facing literals in code. Onboarding UI Req 4 needs a session-only
options panel (coach marks, reduced motion), and `ui_scale`, `reveal_cps` and
reduced motion are read by several presentation systems. TR-config-001,
TR-dialogue-001/004/005 and TR-onboarding-002 have no ADR (architecture review
2026-10-15).

### Constraints
- Godot parses every JSON number as `float` (ADR-0003 probe).
- English only through the Vertical Slice; localisation later (dialogue rule 9).
- No save at MVP (Progression rule 13); VS Save/Load must serialise settings.
- The Python report tool must read `idle_cutoff_s` from the same file the game uses (ADR-0004 §5).
- No autoloads; services from `ServicesFactory` (ADR-0006).

### Requirements
- One validation rule per key: type, default, safe range, and whether an out-of-range value is **rejected** or **clamped**.
- Puzzle-level overrides of tuning values (e.g. hint thresholds per puzzle) validated by the same rules.
- Missing string id behaviour by build flavour; `{name}` substitution; grapheme lengths for authoring checks.

## Decision

### 1. Tuning config: typed JSON per system + a schema in code
```
assets/data/config/
  sandbox.json      # exec_time_limit_ms
  grader.json       # grader_row_cap (owned by the grader, read by sandbox fetch_limit and workbench strip)
  hint.json         # hint1_fails, hint2_fails, stuck_fails, *_minutes, idle_cutoff_s, …
  dialogue.json     # hold_base, read_cps, hold_min, hold_max, reaction_grace, reveal_cap, …
  workbench.json    # editor_font_px, table_font_px, …
  settings.json     # defaults of the player settings (§3), incl. reveal_cps
assets/data/content/config/content.json   # ADR-0003 content thresholds incl. feedback_max_level, verify_parallelism
```
Each key has **one** home file: `reveal_cps` is a player setting (default in
`settings.json`, value in `Settings`), `feedback_max_level` is a content
threshold (`content.json`, puzzle-def Tuning Knobs).
- `GameConfig` holds a **schema table in code** (`ConfigSchema`): per key
  `{type, default, min, max, on_invalid: &"reject" | &"default", on_out_of_range: &"clamp" | &"reject", nonpositive_to_default: bool}`
  copied from the owning GDD's Tuning Knobs / Formulas (the GDD is the source;
  a test compares the schema with a list exported from the GDD tables).
- Load: `JSON.new().parse()` → convert each value through its declared type
  (ADR-0003 §2 rules: `int` must be integral) → apply the key's rule:
  - **Invalid** (wrong type, non-integral int, a hard rule such as
    `*_fails < 1`): in **dev** builds a load error naming file + key (fatal for
    the boot — the developer fixes it); in **playtest/release** the default is
    used and an error is pushed (`push_error`) — never a crash.
  - **Out of the safe range but valid**: clamped, with a warning naming the key
    (HS-14 "clamped to 4 / 30 / 15 with a warning"; workbench QW-24).
  - **Keys with `nonpositive_to_default`** (e.g. `exec_time_limit_ms`, SB-17:
    0 → 100): a value ≤ 0 uses the default with a warning in every flavour —
    never a dev load error; a positive out-of-range value is still clamped.
- **Per-puzzle overrides** (e.g. `hint1_fails` on a puzzle) are validated with
  the same `ConfigSchema` entry. **CI** (ContentVerifier check module, ADR-0003
  §4) fails on an invalid override, so it cannot ship. **At load** an invalid
  override is ignored — the global value is used and an error is pushed — and
  the puzzle stays playable (developer decision 2026-10-16: a hint threshold
  never withholds a puzzle); an out-of-range one is clamped with a warning.
- `GameConfig` exposes **typed getters** per system (`config.hint.hint1_fails`),
  immutable after load. No system reads JSON itself.
- Unknown keys in a file are reported (dev warning, CI failure) — a typo never
  silently falls back to a default.

### 2. String tables: own `StringTable` over English JSON
```
assets/data/strings/en/
  dialogue.json     # "fail.generic": "…", "error.TIMEOUT": "…", "skip.offer": "…"
  ui.json           # "workbench.run": "Run", "hint.locked": "Hint · locked", …
  grader.json       # neutral statement keys (grader rule 12)
  onboarding.json   # "onboarding.ghost.1-2", coach-mark labels, opening question
  manual.json       # page bodies (or kept in manual/pages.json — see guideline)
```
- Ids are dotted segments of `[A-Za-z0-9_-]` — the GDD id families keep their
  own spelling (`fail.generic`, `error.SQL_ERROR`, `error.CONTENT_ERROR`,
  `skip.offer`, `challenge.clear`, `onboarding.ghost.1-2`); one flat JSON object
  per file; ids are unique across files (CI check).
- `StringTable.text(id: StringName, args: Dictionary = {}) -> String` returns
  the string with `{name}` placeholders filled from `args` (single pass, see below).
- **Missing id** (dialogue rule 9, RD-12): dev → `"[" + id + "]"`; playtest /
  release → the generic line for the id's family, by first segment
  (`fail.*` → `fail.generic`, `error.*` → `error.generic`, `skip.*` /
  `challenge.*` / `system.*` → `<family>.generic`, anything else → `ui.missing`); in every flavour the miss is reported once per id with
  `push_warning` (dev) / `push_error` (others). A missing generic line is a CI
  failure.
- **Puzzle- and chapter-authored text** (requests, puzzle lines, hints, shift
  briefings) stays in the content JSON (ADR-0003) and is read through `PuzzleRepository`; `StringTable` resolves
  `puzzle:<id>:<field>` ids to it so every line has one id for the log
  (`line_shown {line_id}`).
- **Grapheme length** `StringTable.grapheme_len(text) -> int` =
  `TextServerManager.get_primary_interface().string_get_character_breaks(text, "").size()`
  (probed) — used by authoring checks and the
  `reaction_hold` formula's `len`. Constraint Challenges' `canonical_length`
  (Alpha) is defined in code points and keeps `String.length()`. Bubble **paging** stays measured layout
  (dialogue rule 10, ADR-0008), not counts.
- Godot's `TranslationServer` / `tr()` are **not used** at MVP; Controls get
  their text already resolved from `StringTable` (no translation keys in
  scenes), and `Main` itself sets `auto_translate_mode = AUTO_TRANSLATE_MODE_DISABLED`
  (children inherit — probed for Controls, Windows and `CanvasLayer` children; the
  recorder's corner label sits outside any UI root) so a later Translation can
  never re-translate resolved text.
- `text()` does **its own single-pass `{name}` substitution** — it scans the
  template once and never rescans an inserted value. `String.format` is not used:
  it has no escape syntax (`"{{a}}"` → `{X}`) and its result depends on the
  dictionary order when a value contains `{other}` (probed 2026-10-16). In dev
  builds `text()` warns when a `{name}` in the template has no argument.
- CI (ContentVerifier check module, ADR-0003): every id referenced by content and
  by code exists; RD-12 scan — no string literal is passed to a text-bearing
  property or a Dialogue line API in `src/` (except ids and test code).

### 3. Session settings: plain-data `Settings` service
```gdscript
class_name Settings extends RefCounted
signal setting_changed(key: StringName)
var ui_scale: float          # 1.0–2.0 step 0.25 (VS; MVP default from settings.json)
var reduced_motion: bool     # MVP toggle (onboarding UI Req 4)
var coach_marks: bool        # MVP toggle
var reveal_cps: float        # 0 or 20–120, the stored player value (dialogue Formulas)
func effective_reveal_cps() -> float  # 0 while reduced_motion, else reveal_cps (stored value kept)
func set_value(key: StringName, value: Variant) -> void   # validates with ConfigSchema, emits setting_changed
func to_dict() -> Dictionary                             # for VS Save/Load
func from_dict(d: Dictionary) -> void
```
- Built by `ServicesFactory` from `settings.json` defaults; lives for the
  session (no save at MVP; Save/Load VS uses `to_dict` / `from_dict`).
- Consumers read values and connect to `setting_changed` (presentation wiring,
  ADR-0010 §1). Reduced motion applies at once: running motions jump to their end.
- Onboarding's minimal options panel writes through `set_value`; Accessibility
  Options (VS) adds `ui_scale`, remapping and volumes the same way.

### Architecture Diagram
```
assets/data/config/*.json ──► GameConfig (ConfigSchema: type/default/range/reject|clamp) ──► typed getters
          ▲ (same file)                       │ per-puzzle overrides validated by ContentVerifier
          └── tools/playtest-report --config  │
assets/data/strings/en/*.json ──► StringTable.text(id, args) ──► Dialogue, Workbench view, Onboarding, Manual, Hint
puzzle JSON (ADR-0003) ─────────► StringTable ("puzzle:<id>:<field>")
settings.json defaults ──► Settings (session) ──setting_changed──► presentation systems
```

### Key Interfaces
`GameConfig` typed getters (immutable); `ConfigSchema` entries;
`StringTable.text(id, args) -> String`, `StringTable.grapheme_len(text) -> int`;
`Settings` (§3).

### Implementation Guidelines
- Must read every gameplay value through `GameConfig` getters; no literal tuning value in `src/` (constants only for true invariants such as the `2` in `2 + D`).
- Must define each key's type, default, range and reject/clamp rule in `ConfigSchema`, matching the owning GDD; a GDD change to a knob updates the schema in the same change.
- Must convert JSON numbers through the declared type before use (ADR-0003 §2).
- Must treat an invalid value as a dev load error and a playtest/release default + `push_error`; never crash a player build on config.
- Must clamp valid out-of-range values with a warning naming the key.
- Must report unknown keys.
- Must resolve every player-facing string through `StringTable.text`; no player-facing literal in `src/` (RD-12 scan).
- Must not use `tr()` / `TranslationServer` at MVP; keep ids stable so a later move to `TranslationServer` keeps them.
- Must count lengths for authoring checks and `reaction_hold` with `grapheme_len`, never `String.length()` (exception: Constraint Challenges' `canonical_length`, defined in code points).
- Must substitute `{name}` placeholders with `StringTable.text`'s single-pass routine; never `String.format` on player-facing text.
- Must read the reveal speed through `Settings.effective_reveal_cps()` so reduced motion never overwrites the stored value.
- Must not use `assert()` for config or string validation (stripped in release builds); use explicit checks.
- Missing-id and config reports use `push_warning` / `push_error`, which reach Godot's log file in every build; they are not playtest-log events (none is declared in `playtest-log.md` rule 4).
- Must keep `Settings` plain data (no node references) with `to_dict` / `from_dict`.
- The Python report tool must read `idle_cutoff_s` from `assets/data/config/hint.json` (ADR-0004 §5).

## Alternatives Considered

### Alternative 1: Godot `TranslationServer` with CSV / PO string files
- **Description**: Strings in a CSV imported as `Translation`; `tr(id)` everywhere; Controls auto-translate.
- **Pros**: Built-in localisation pipeline; editor live translation preview (4.5).
- **Cons**: `tr()` returns the key on a miss, so the dev/release missing-id rule needs a wrapper anyway; puzzle text in JSON would sit outside it; adds an import step and a second text format for an English-only MVP.
- **Rejection Reason**: Not needed until localisation; the own table keeps one format (JSON) and stable ids, so migrating later is a file conversion, not a code change.

### Alternative 2: Godot `ConfigFile` (.cfg) or `.tres` resources for tuning
- **Description**: Typed values without the JSON float problem.
- **Pros**: Native types; inspector editing for `.tres`.
- **Cons**: A second data format next to ADR-0003's JSON; the Python report tool cannot read `.tres` and reads Godot-variant `.cfg` poorly.
- **Rejection Reason**: One format with one typed loader is simpler; the float problem is already solved by ADR-0003 §2.

### Alternative 3: Validation inside each system
- **Description**: Each system checks its own knobs.
- **Pros**: Local.
- **Cons**: Eleven copies of reject/clamp logic; inconsistent messages; per-puzzle overrides checked differently from globals.
- **Rejection Reason**: One `ConfigSchema` gives one behaviour and one test.

## Consequences

### Positive
- Every knob from every GDD has one validated source; HS-14 and SB-17 become schema tests.
- Missing strings never crash and are visible in dev.
- Settings are ready for VS Save/Load without refactoring.

### Negative
- The schema duplicates GDD tables (mitigated by a comparison test).
- Localisation later needs a migration (Alternative 1).

## Risks
- **Schema drift from GDD knobs.** Mitigation: a test that lists each GDD Tuning Knobs key and fails if `ConfigSchema` lacks it or the range differs.
- **Grapheme counts silently wrong in an exported build.** The Advanced TextServer reads ICU support data (`icudt_godot.dat`); the project setting `internationalization/locale/include_text_server_data` defaults to false, and without the data counts can fall back to code points (Dummy server: "éab" → 4, family emoji → 5). The failure is a wrong number, not a missing API. Mitigation: ADR-0005 decides `include_text_server_data` (≈ 4 MB) or proves the export without it; the combining-mark and emoji cases run in the exported build ("삼각김밥" cannot detect it).
- **A dev load error blocks a playtest build** if a dev-only file slips in. Mitigation: ContentVerifier runs the config validation in CI too.

*Engine validation (godot-specialist, 2026-10-16, probed on 4.7.2 headless): no blocking findings; grapheme API and auto-translate behaviour verified; advisories folded in — disable auto-translate on the UI root, escape braces in format args and warn on unresolved placeholders, no `assert()` for validation, `push_*` reach the log file in release. TD-ADR skipped — lean mode.*

*Architecture review 2026-10-16 (fresh session, godot-specialist second opinion): `String.format` cannot escape → single-pass substitution (E3); auto-translate off on `Main` (E5); export ICU data risk (E4); id families and `exec_time_limit_ms ≤ 0 → default` aligned with the GDDs (A1, A2); one home per key (A4, A5); invalid per-puzzle override → global value at load, CI failure (developer decision).*

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| all MVP GDDs | Tuning Knobs: every gameplay value from data files with load-time range validation | `GameConfig` + `ConfigSchema` (§1) — TR-config-001 |
| hint-system.md | Rejected at load / clamped with a warning; HS-14 | Per-key reject/clamp rules; per-puzzle overrides: CI failure, global value at load |
| sql-execution-sandbox.md | Formulas `exec_time_limit` clamp; SB-17 | `nonpositive_to_default` (0 → 100), positive values clamped |
| request-and-reaction-dialogue.md | Rule 9: string tables by id, missing id `[id]` dev / generic release, logged; grapheme lengths | `StringTable` (§2) — TR-dialogue-001 |
| request-and-reaction-dialogue.md | RD-12: no player-facing literals in dialogue code | CI scan (§2) — TR-dialogue-005 |
| request-and-reaction-dialogue.md | Rule 10 / RD-11: measured paging | Paging stays layout-measured; `grapheme_len` for authoring — TR-dialogue-004 (partial; layout in ADR-0008) |
| onboarding-first-shift.md | UI Req 4: session-only coach marks + reduced motion toggles | `Settings` (§3) — TR-onboarding-002 |
| query-workbench.md | `ui_scale`, font knobs (14–24) | `Settings.ui_scale`, schema ranges |
| playtest-log.md | Report tool uses `idle_cutoff_s` | Same `hint.json` read by the tool (ADR-0004 §5) — TR-playtest-006 |

## Performance Implications
- **CPU**: config and strings parsed once at boot (a few KB).
- **Memory**: negligible.
- **Load Time**: < 10 ms expected; included in boot before the verifier.
- **Network**: none.

## Migration Plan
No production code exists. Strings and tuning values for Chapter 1 are written
into these files as their systems are built; the Chapter 1 content migration
(ADR-0003) moves puzzle text into puzzle JSON.

## Validation Criteria
- HS-14, SB-17 and QW-24 pass as `ConfigSchema` unit tests.
- A schema-vs-GDD comparison test passes.
- RD-12 scan and the missing-id tests pass in dev and release flavours.
- `grapheme_len("삼각김밥") == 4` and a combining-mark / emoji case counts one cluster each — in the editor and in the first exported build.
- `text("{a} {b}", {"a": "{b}", "b": "X"}) == "{b} X"` in both dictionary orders (single pass).
- `exec_time_limit_ms = 0` loads as 100 with a warning in a dev build (SB-17).

## Related
- ADR-0003 — JSON format, typed conversion, ContentVerifier
- ADR-0004 — BuildFlavour, report tool `--config`
- ADR-0006 — composition root
- ADR-0008 (planned) — measured bubble paging and editor text layout
- ADR-0010 — `setting_changed` consumers wired as presentation
- `docs/architecture/architecture-review-2026-10-16.md` — E3, E4, E5, A1–A7, A12
- GDDs: every MVP GDD's Tuning Knobs; `request-and-reaction-dialogue.md` rules 9–10; `onboarding-first-shift.md` UI Req 4
