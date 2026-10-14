# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does the Godot grader give the same per-dataset verdicts as ch1.py for every answer and trap?
# Date: 2026-10-14
# Run: godot --headless --path . -s res://verify.gd
extends SceneTree


func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ch1.json"))
	var expected: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/expected.json"))
	var grader = load("res://grader.gd").new(data)
	var checked := 0
	var mismatches := 0
	for p: Dictionary in data["puzzles"]:
		var exp_p: Dictionary = expected[p["id"]]
		var cases: Array = [["answer", p["answer"], exp_p["answer"]]]
		for t: Dictionary in p["traps"]:
			cases.append(["trap[%s]" % t["name"], t["sql"], exp_p["traps"][t["name"]]])
		for c: Array in cases:
			var got: Dictionary = grader.check(p["answer"], c[1])
			var same := true
			for ds: String in got:
				same = same and got[ds] == c[2][ds]
			checked += 1
			if not same:
				mismatches += 1
			print("%-5s %-32s %s  godot=%s python=%s" % [p["id"], c[0], "MATCH" if same else "DIFF ", got, c[2]])
	print("\nchecked %d · mismatches %d" % [checked, mismatches])
	quit(0 if mismatches == 0 else 1)
