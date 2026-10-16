extends SceneTree
func _init():
	var chords = {
		"Ctrl+Shift+S": [KEY_S, true, true],
		"Ctrl+Enter": [KEY_ENTER, true, false],
		"Ctrl+Shift+Enter": [KEY_ENTER, true, true],
		"F6": [KEY_F6, false, false],
		"Shift+F6": [KEY_F6, false, true],
		"Ctrl+H": [KEY_H, true, false], "Ctrl+M": [KEY_M, true, false],
		"Ctrl+L": [KEY_L, true, false], "Ctrl+B": [KEY_B, true, false],
	}
	for name in chords:
		var c = chords[name]
		var ev := InputEventKey.new()
		ev.keycode = c[0]; ev.ctrl_pressed = c[1]; ev.shift_pressed = c[2]; ev.pressed = true
		var hits := []
		for a in InputMap.get_actions():
			if InputMap.event_is_action(ev, a, true):
				hits.append(a)
		print(name, " -> ", hits)
	quit()
