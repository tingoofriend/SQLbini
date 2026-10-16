# Renderer spike — Forward+ vs Compatibility (2026-10-16)

Throwaway. Input to ADR-0005 (renderer choice, AQ-04). Linux side only; the
Windows run (D3D12 default for Forward+ on 4.6+, OpenGL/ANGLE for Compatibility)
happens with the Windows godot-sqlite spike.

**Machine:** dev laptop, Intel Iris Xe (Raptor Lake-P), 16 threads, Linux
Wayland, Godot 4.7.2.stable. **Scene** (`main.gd`): workbench-like 2D UI at
1280×720 — a 320×30 SubViewport strip ×4 nearest with 40 rects, a CodeEdit with
20 lines, two 8×4 label grids (incl. ✓), six Panels. VSync off, 600 frames.
Renderer switched with `--rendering-method forward_plus | gl_compatibility`.

| Renderer (driver) | Run | Process wall time | First frame (ms since start) | Mean frame | p95 frame | Draw calls | Static mem | Video mem | Texture mem |
|---|---|---|---|---|---|---|---|---|---|
| Forward+ (Vulkan) | 1 (cold cache) | 3625 ms | 1890 | 2.42 ms | 3.69 ms | 45 | 48.7 MB | 25.6 MB | 5.7 MB |
| Forward+ (Vulkan) | 2 | 2628 ms | 1038 | 2.21 ms | 3.32 ms | 45 | 50.1 MB | 25.6 MB | 5.7 MB |
| Forward+ (Vulkan) | 3 | 2724 ms | 935 | 2.46 ms | 3.30 ms | 45 | 50.1 MB | 25.6 MB | 5.7 MB |
| Compatibility (OpenGL 3) | 1 (cold cache) | 3628 ms | 1804 | 2.54 ms | 3.32 ms | 45 | 34.1 MB | 15.6 MB | 7.4 MB |
| Compatibility (OpenGL 3) | 2 | 2428 ms | 929 | 2.11 ms | 2.99 ms | 45 | 34.1 MB | 17.6 MB | 7.4 MB |
| Compatibility (OpenGL 3) | 3 | 2426 ms | 940 | 2.13 ms | 3.00 ms | 45 | 34.1 MB | 17.6 MB | 7.4 MB |

(The JSON's `method` field prints the project setting, not the override; the
`driver` field — vulkan / opengl3 — shows the renderer actually used.)

**Observations (not a verdict):**
- Frame time is far below the 16.6 ms budget on both (≈ 2–2.5 ms mean, ≈ 3–3.7 ms p95); the difference between renderers is within run-to-run noise.
- Compatibility uses ≈ 16 MB less static memory and ≈ 8–10 MB less video memory; texture memory is ≈ 1.7 MB higher (driver accounting).
- Warm start to first frame ≈ 0.93–1.04 s on both; the first (cold) run of each is ≈ 1.8–1.9 s (shader cache).
- Draw calls 45 on both (budget < 500).
- Not measured here: Windows (D3D12 vs OpenGL/ANGLE), weaker GPUs, the real art (palette shader, fonts), `CanvasItem` line AA differences (4.7).

**Run:** `godot --path . --rendering-method <forward_plus|gl_compatibility> --windowed --resolution 1280x720` (prints one `RESULT` JSON line and quits).
