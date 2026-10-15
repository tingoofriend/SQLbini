# PROTOTYPE - NOT FOR PRODUCTION
# Question: Option (a) — run each execution on a worker thread and abandon it on timeout. Is it safe, and what does it cost? (ADR-0001)
# Date: 2026-10-15
extends SceneTree

const LIMIT_MS := 100.0
const C := preload("res://common.gd")

var graveyard: Array[Thread] = []   # abandoned threads, joined only once they finish
var phase := 0
var t0 := 0
var job: Thread
var job_started := 0
var max_frame_ms := 0.0
var last_frame_us := 0
var short_lat: Array = []
var abandoned_started := {}   # Thread -> start usec

func start_job(sql: String) -> Thread:
	var th := Thread.new()
	th.start(C.execute.bind(sql))
	return th

func _initialize() -> void:
	print("cores=%d" % OS.get_processor_count())
	t0 = Time.get_ticks_usec()
	last_frame_us = t0

func reap() -> void:
	for th in graveyard.duplicate():
		if not th.is_alive():
			var r: Dictionary = th.wait_to_finish()
			print("  abandoned thread finished after %.0f ms (ok=%s rows=%d)" % [(Time.get_ticks_usec() - abandoned_started[th]) / 1000.0, r.ok, r.rows])
			graveyard.erase(th)

func _process(_delta: float) -> bool:
	var now := Time.get_ticks_usec()
	max_frame_ms = maxf(max_frame_ms, (now - last_frame_us) / 1000.0)
	last_frame_us = now
	reap()
	match phase:
		0:  # one long query, abandon at LIMIT
			print("phase 0: long query on worker, limit %d ms" % LIMIT_MS)
			job = start_job(C.LONG_SQL); job_started = now; phase = 1
		1:
			var el := (now - job_started) / 1000.0
			if not job.is_alive():
				print("  long query finished before limit?! %.1f ms" % el); phase = 2
			elif el >= LIMIT_MS:
				print("  TIMEOUT detected on main thread at %.1f ms (limit+%.1f)" % [el, el - LIMIT_MS])
				graveyard.append(job); abandoned_started[job] = job_started
				job = null
				phase = 2
		2:  # 30 short executions while the abandoned one burns, one at a time
			if short_lat.size() < 30:
				if job == null or not job.is_alive():
					if job != null:
						var r: Dictionary = job.wait_to_finish()
						short_lat.append((now - job_started) / 1000.0)
						if short_lat.size() == 1: print("  first short result: ok=%s cols=%d rows=%d" % [r.ok, r.cols, r.rows])
					job = start_job(C.SHORT_SQL); job_started = now
			else:
				print("  30 short runs during 1 abandoned: p50 %.2f ms p95 %.2f ms max %.2f ms (round trip incl. frame polling)" % [C.p(short_lat, .5), C.p(short_lat, .95), C.p(short_lat, 1.0)])
				short_lat.clear(); job = null; phase = 3
		3:  # pile up 6 more abandoned long queries (repeated timeouts)
			for i in 6:
				var th := start_job(C.LONG_SQL)
				graveyard.append(th); abandoned_started[th] = now
			print("phase 3: %d abandoned threads alive" % graveyard.size())
			phase = 4
		4:
			if short_lat.size() < 30:
				if job == null or not job.is_alive():
					if job != null:
						job.wait_to_finish(); short_lat.append((now - job_started) / 1000.0)
					job = start_job(C.SHORT_SQL); job_started = now
			else:
				print("  30 short runs during %d abandoned: p50 %.2f ms p95 %.2f ms max %.2f ms" % [graveyard.size(), C.p(short_lat, .5), C.p(short_lat, .95), C.p(short_lat, 1.0)])
				print("  max frame gap so far %.2f ms" % max_frame_ms)
				phase = 5
		5:
			if graveyard.is_empty():
				print("all abandoned threads joined; total %.1f s; max frame gap %.2f ms" % [(now - t0) / 1e6, max_frame_ms])
				return true
	return false
