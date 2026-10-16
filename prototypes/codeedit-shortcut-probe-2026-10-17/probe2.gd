extends SceneTree
var ce: CodeEdit
var seen := {}
func _init():
	ce = CodeEdit.new()
	ce.size = Vector2(400, 300)
	root.add_child(ce)
	root.window_input.connect(func(e): pass)
	process_frame.connect(_run, CONNECT_ONE_SHOT)
func _run():
	await process_frame
	ce.grab_focus()
	var chords = {
		"Ctrl+Shift+S": [KEY_S, true, true], "Ctrl+Enter": [KEY_ENTER, true, false],
		"Ctrl+Shift+Enter": [KEY_ENTER, true, true], "F6": [KEY_F6, false, false],
		"Ctrl+M": [KEY_M, true, false], "Ctrl+H": [KEY_H, true, false],
		"Ctrl+L": [KEY_L, true, false], "Esc": [KEY_ESCAPE, false, false],
	}
	for name in chords:
		var c = chords[name]
		ce.text = "SELECT 1"
		ce.set_caret_column(8)
		var before = ce.text
		var ev := InputEventKey.new()
		ev.keycode = c[0]; ev.physical_keycode = c[0]; ev.ctrl_pressed = c[1]; ev.shift_pressed = c[2]; ev.pressed = true
		root.push_input(ev)
		var handled = root.is_input_handled()
		await process_frame
		print(name, " -> text changed: ", ce.text != before, " | handled: ", handled, " | text=", JSON.stringify(ce.text))
	quit()
