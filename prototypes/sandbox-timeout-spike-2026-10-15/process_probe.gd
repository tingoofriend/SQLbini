# PROTOTYPE - NOT FOR PRODUCTION
# Question: Option (b) — spawn cost, round trip, kill + respawn of a helper Godot process. (ADR-0001)
# Date: 2026-10-15
extends SceneTree

const C := preload("res://common.gd")
const LIMIT_MS := 100.0

var proc := {}
var buf := ""

func spawn() -> float:
	var t := Time.get_ticks_usec()
	proc = OS.execute_with_pipe(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "-s", "res://worker.gd"], false)
	buf = ""
	while true:
		var l := read_line()
		if l == "READY": break
		if (Time.get_ticks_usec() - t) > 10_000_000: return -1.0
		OS.delay_usec(200)
	return (Time.get_ticks_usec() - t) / 1000.0

func read_line() -> String:
	var f: FileAccess = proc.stdio
	var chunk := f.get_buffer(65536)
	if chunk.size() > 0:
		buf += chunk.get_string_from_utf8()
	var i := buf.find("\n")
	if i < 0: return ""
	var l := buf.substr(0, i).strip_edges()
	buf = buf.substr(i + 1)
	return l

func request(id: int, sql: String, limit_ms: float) -> Dictionary:
	var t := Time.get_ticks_usec()
	var f: FileAccess = proc.stdio
	f.store_line(JSON.stringify({"id": id, "sql": sql}))
	f.flush()
	while true:
		var l := read_line()
		if l.begins_with("{"):
			var r: Dictionary = JSON.parse_string(l)
			r["rt"] = (Time.get_ticks_usec() - t) / 1000.0
			return r
		if (Time.get_ticks_usec() - t) / 1000.0 >= limit_ms:
			return {"timeout": true, "rt": (Time.get_ticks_usec() - t) / 1000.0}
		OS.delay_usec(100)
	return {}

func _initialize() -> void:
	print("spawn #1: %.1f ms ready" % spawn())
	var rts: Array = []
	for i in 50:
		var r := request(i, C.SHORT_SQL, 1000)
		if i == 0: print("  first: ok=%s cols=%s rows=%s worker ms=%.2f" % [r.ok, r.cols, r.rows, r.ms])
		rts.append(r.rt)
	print("  50 short round trips: p50 %.2f p95 %.2f max %.2f ms" % [C.p(rts, .5), C.p(rts, .95), C.p(rts, 1.0)])
	var r := request(99, C.LONG_SQL, LIMIT_MS)
	print("  long: %s at %.1f ms" % ["TIMEOUT" if r.has("timeout") else "done", r.rt])
	var tk := Time.get_ticks_usec()
	OS.kill(proc.pid)
	var killed := (Time.get_ticks_usec() - tk) / 1000.0
	var sp := spawn()
	print("  kill %.2f ms, respawn %.1f ms → TIMEOUT-to-ready %.1f ms" % [killed, sp, killed + sp])
	var r2 := request(100, C.SHORT_SQL, 1000)
	print("  after respawn: ok=%s rows=%s rt=%.2f ms; old pid running=%s" % [r2.ok, r2.rows, r2.rt, OS.is_process_running(proc.pid)])
	proc.stdio.store_line("QUIT"); proc.stdio.flush()
	quit()
