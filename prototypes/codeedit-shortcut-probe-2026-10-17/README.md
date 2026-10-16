# CodeEdit shortcut probe (2026-10-17)

Throwaway probe for the workbench chords (IP-01, IP library OQ1, workbench UX
spec OQ8). Evidence for ADR-0008 (workbench editor). Run on Linux, Godot
4.7.2.stable, headless, default InputMap.

**Hypothesis:** a focused `CodeEdit` leaves the workbench chords to a shortcut
layer. **Status:** concluded (Linux) — false for 3 of 8 chords; Windows and IME
still to probe.

```
godot --headless --path prototypes/codeedit-shortcut-probe-2026-10-17 -s probe.gd   # default InputMap matches
godot --headless --path prototypes/codeedit-shortcut-probe-2026-10-17 -s probe2.gd  # focused CodeEdit: consumed? text changed?
godot --headless --path prototypes/codeedit-shortcut-probe-2026-10-17 -s probe3.gd  # which callbacks still see the key
```

## Results

| Chord | Default action matched | Focused `CodeEdit` | Reaches `_shortcut_input` |
|---|---|---|---|
| Ctrl+Shift+S (Shift menu) | none | not consumed | yes |
| Ctrl+Enter (Run) | `ui_text_newline_blank` | **consumed — inserts a newline** | **no** (only `_input`) |
| Ctrl+Shift+Enter (Submit) | `ui_text_newline_above` | **consumed — inserts a line above** | **no** (only `_input`) |
| Ctrl+M (Manual) | `ui_focus_mode` | **consumed** (no text change) | **no** (only `_input`) |
| Ctrl+H (Hint) | none | not consumed | yes |
| Ctrl+L (Log) | `ui_filedialog_focus_path` (FileDialog only) | not consumed | yes |
| F6 / Shift+F6 (panes) | none | not consumed | — (F6 probed in probe2) |
| Esc (leave editor) | none | not consumed | — |

## Consequence

Handling the chords in `_shortcut_input` (IP-01's first note) does not work for
Run, Submit and Manual while the editor has focus. ADR-0008 must either take
them in `_input` (before GUI input) or remove those events from
`ui_text_newline_blank`, `ui_text_newline_above` and `ui_focus_mode` in the
project InputMap. Not yet probed: IME composition active; Windows OS layer
(session 11).
