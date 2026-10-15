# PROTOTYPE - NOT FOR PRODUCTION
# Question: Godot 4.7.2 JSON number types, sort_keys stringify, sha256 for the content hash (ADR-0003)
# Date: 2026-10-15
extends SceneTree

func _initialize() -> void:
	var d: Variant = JSON.parse_string('{"b": 198, "a": 1.5, "c": null, "n": 9007199254740993, "s": "x\\ny"}')
	for k in d: print("%s -> %s (%s)" % [k, d[k], type_string(typeof(d[k]))])
	print("sorted: ", JSON.stringify(d, "", true))
	print("sorted full_precision: ", JSON.stringify(d, "", true, true))
	print("int stringify: ", JSON.stringify({"z": 198, "y": 198.0}, "", true))
	print("sha256: ", "abc".sha256_text())
	quit()
