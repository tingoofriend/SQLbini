<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Can Godot 4.7.2 + CodeEdit + godot-sqlite run and grade SQLbini Chapter 1 puzzles? -->
<!-- Date: 2026-10-14 -->

# SQLbini Query-Workbench Spike

**Hypothesis**: Godot 4.7.2 with `CodeEdit` and godot-sqlite v4.9 can host the
SQL workbench and grade Chapter 1 with the same verdicts as `../sqlbini-web/ch1.py`.

**Status**: Concluded — YES. See `SPIKE-NOTE.md`.

## How to run
This folder is its own Godot project (the root project ignores it).

```bash
cd prototypes/sqlbini-spike-2026-10-14
godot --headless --path . --import          # first run only
godot --headless --path . -s res://verify.gd  # grader parity vs ch1.py
godot --path .                                # workbench window
```

Workbench keys: **Ctrl+Enter** runs on visible data, **Ctrl+Shift+Enter** submits
(hidden datasets). Pick a puzzle from the dropdown.

`data/ch1.json` comes from `python3 ../sqlbini-web/ch1.py --json`;
`data/expected.json` holds ch1.py's per-dataset verdicts for every answer and trap.

## Findings
See `SPIKE-NOTE.md`. Linux x86_64 only (godot-sqlite binary).
