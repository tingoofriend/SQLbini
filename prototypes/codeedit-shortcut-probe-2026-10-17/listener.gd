extends Node
var log := []
func _input(e):
	if e is InputEventKey and e.pressed: log.append("_input")
func _shortcut_input(e):
	if e is InputEventKey and e.pressed: log.append("_shortcut_input")
func _unhandled_key_input(e):
	if e is InputEventKey and e.pressed: log.append("_unhandled_key_input")
