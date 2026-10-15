# PROTOTYPE - NOT FOR PRODUCTION
# Question: Option (b) — helper process: one execution per stdin line, JSON result per stdout line. (ADR-0001)
# Date: 2026-10-15
extends SceneTree

const C := preload("res://common.gd")

func _initialize() -> void:
	C.execute("SELECT 1")   # warm the extension
	print("READY")
	while true:
		var line := OS.read_string_from_stdin().strip_edges()
		if line == "" or line == "QUIT":
			break
		var req: Dictionary = JSON.parse_string(line)
		var r := C.execute(req.sql)
		r["id"] = req.id
		print(JSON.stringify(r))
	quit()
