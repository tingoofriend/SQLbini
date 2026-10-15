# PROTOTYPE - NOT FOR PRODUCTION
# Question: What happens to the process when the game quits (or a new thread starts) while an abandoned worker is still inside SQLite? Memory growth of an abandoned ORDER BY? (ADR-0001)
# Date: 2026-10-15
extends SceneTree

const C := preload("res://common.gd")
# 8-way join: ~24x24 = 576x longer than the 6-way one (minutes). ORDER BY variant forces a sort buffer.
const HUGE_SQL := "SELECT COUNT(*) FROM products a, products b, products c, products d, products e, products f, products g, products h"
const SORT_SQL := "SELECT a.name || b.name || c.name || d.name || e.name AS k FROM products a, products b, products c, products d, products e ORDER BY k DESC"

var th: Thread
var t0 := 0
var mode := ""

func _initialize() -> void:
	mode = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "quit"
	th = Thread.new()
	th.start(C.execute.bind(SORT_SQL if mode == "sort" else HUGE_SQL))
	t0 = Time.get_ticks_usec()
	print("mode=%s start rss=%.0f MB" % [mode, OS.get_static_memory_usage() / 1e6])

func _process(_d: float) -> bool:
	var el := (Time.get_ticks_usec() - t0) / 1000.0
	if mode == "sort":
		if int(el) % 1000 < 10:
			print("  %.0f ms static_mem=%.0f MB alive=%s" % [el, OS.get_static_memory_usage() / 1e6, th.is_alive()])
		if not th.is_alive():
			var r: Dictionary = th.wait_to_finish()
			print("  sort finished %.0f ms rows=%d (fetch capped at 5001)" % [el, r.rows])
			return true
		return el > 20000.0
	if el > 200.0:
		print("  quitting with worker still alive=%s at %.0f ms" % [th.is_alive(), el])
		return true
	return false
