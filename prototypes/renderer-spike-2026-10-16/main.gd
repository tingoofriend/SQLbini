## Builds a workbench-like 2D UI (strip SubViewport, CodeEdit, two grids of labels,
## panels) and measures time to first frame, mean/p95 frame time, draw calls and
## video memory. Prints one JSON line, then quits.
extends Control

const FRAMES := 600
var _frame_times: Array[float] = []
var _last_us: int = 0
var _first_frame_ms: float = -1.0

func _ready() -> void:
	var strip := SubViewportContainer.new()
	strip.position = Vector2(0, 0)
	strip.size = Vector2(1280, 120)
	strip.stretch = true
	strip.stretch_shrink = 4
	strip.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(strip)
	var vp := SubViewport.new()
	vp.size = Vector2i(320, 30)
	strip.add_child(vp)
	for i in 40:
		var r := ColorRect.new()
		r.color = Color(randf(), randf(), randf())
		r.position = Vector2(i * 8, (i % 5) * 5)
		r.size = Vector2(6, 6)
		vp.add_child(r)
	var editor := CodeEdit.new()
	editor.position = Vector2(16, 142)
	editor.size = Vector2(567, 316)
	editor.text = "SELECT name, price\nFROM products\nWHERE category = 'drink'\n  AND price < 200\nORDER BY price;\n".repeat(4)
	editor.gutters_draw_line_numbers = true
	add_child(editor)
	for g in 2:
		var grid := GridContainer.new()
		grid.columns = 4
		grid.position = Vector2(599, 142 + g * 235)
		add_child(grid)
		for row in 8:
			for col in 4:
				var l := Label.new()
				l.text = "cell %d,%d ✓ match" % [row, col] if col == 0 else str(randi() % 1000)
				grid.add_child(l)
	for p in 6:
		var panel := Panel.new()
		panel.position = Vector2(16 + p * 200, 620)
		panel.size = Vector2(180, 80)
		add_child(panel)
	_last_us = Time.get_ticks_usec()

func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	if _first_frame_ms < 0.0:
		_first_frame_ms = Time.get_ticks_msec()
	else:
		_frame_times.append((now - _last_us) / 1000.0)
	_last_us = now
	if _frame_times.size() >= FRAMES:
		_report()

func _report() -> void:
	var sorted := _frame_times.duplicate()
	sorted.sort()
	var total := 0.0
	for t in _frame_times:
		total += t
	var out := {
		"method": ProjectSettings.get_setting("rendering/renderer/rendering_method"),
		"driver": RenderingServer.get_current_rendering_driver_name(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"first_frame_ms_since_start": _first_frame_ms,
		"mean_frame_ms": total / _frame_times.size(),
		"p95_frame_ms": sorted[int(sorted.size() * 0.95)],
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"video_mem_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"texture_mem_mb": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0,
		"static_mem_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
	}
	print("RESULT ", JSON.stringify(out))
	get_tree().quit(0)
