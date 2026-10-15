# Test Infrastructure

**Engine**: Godot 4.7.2 (GDScript) + godot-sqlite v4.9
**Test Framework**: GdUnit4 v6.2.2 — `addons/gdUnit4/` (from the official tag
`https://github.com/godot-gdunit-labs/gdUnit4/archive/refs/tags/v6.2.2.tar.gz`,
SHA-256 `53ba53c23328d8f30205acc2f7ffe3d663773847d09b8f48edab1df6a5950571`)
**CI**: `.github/workflows/tests.yml`
**Setup date**: 2026-10-16

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system tests (real services via ServicesFactory, ADR-0006)
  smoke/          # Critical path test list for /smoke-check gate
```

```
production/qa/
  evidence/       # Screenshot logs and manual test sign-off records
```

> **Manual evidence lives under `production/qa/evidence/`, not `tests/`** — that
> is where every consumer reads it.

## Running Tests

```bash
godot --headless --path . --import    # once after a fresh clone (builds .godot/ class cache)
godot --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode
```

Exit codes: **0** all passed · **100** a test failed · **101** all passed but a
test leaked nodes (wrap nodes in `auto_free`) · 103/104 gdUnit4 could not run ·
105 a test script does not parse. `No test cases found` with exit 0 is **not** a
pass. The two `ERROR:` lines about `127.0.0.1:0` are expected. Reports go to
`reports/` (gitignored).

The editor plugin is optional for the CLI. To use the inspector dock:
Project → Project Settings → Plugins → GdUnit4 ✓ (requires Godot ≥ 4.5).

## Project rules that shape tests

- **No autoloads** (ADR-0006 rule 4): `tests/unit/test_infra/` asserts the
  project registers none. gdUnit4 v6.2.2 adds none (source checked, 2026-10-16).
- **Scene tests set up first** (ADR-0006): `scene_runner(instance)` accepts an
  instance, so call `setup(services)` before passing it in; wrap it in
  `auto_free(...)` — the runner frees only scenes it loaded by path.
- **Time comes from `FakeClock`** in tests (ADR-0006 §5); never assert on wall time.
- **SB-18 / SB-19** (sandbox timeout, ADR-0001) are integration tests with a
  real query; they must not wait on abandoned worker threads at teardown, and the
  quit-time "Thread destroyed without completion" warning is expected.

## Test Naming

- File `[system]_[feature]_test.gd`, function `test_[scenario]_[expected]`
  — `sandbox_lexer_test.gd` → `test_unterminated_string_runs_to_end()`
- One subdirectory per system: `tests/unit/sandbox/`, `tests/integration/grader/`.

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `production/qa/evidence/` |
| UI | Retained screenshot of each screen touched | `production/qa/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging. The content verifier job
(`tools/ci/verify_content.gd`, ADR-0003) is added with the Puzzle Definition epic.
