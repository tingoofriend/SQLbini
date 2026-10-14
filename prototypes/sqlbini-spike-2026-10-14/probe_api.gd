# PROTOTYPE - NOT FOR PRODUCTION
# Question: What does godot-sqlite v4.9 expose that the SQL Execution Sandbox GDD can rely on?
# Date: 2026-10-14
extends SceneTree

func _init() -> void:
	var names: Array = []
	for m in ClassDB.class_get_method_list("SQLite", true):
		names.append(m["name"])
	names.sort()
	print("METHODS: ", ", ".join(names))
	var props: Array = []
	for p in ClassDB.class_get_property_list("SQLite", true):
		props.append(p["name"])
	print("PROPS: ", ", ".join(props))
	quit()
