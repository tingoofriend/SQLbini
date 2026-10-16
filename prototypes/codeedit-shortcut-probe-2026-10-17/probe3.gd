extends SceneTree
var ce: CodeEdit
var L
var wl := []
func _init():
	L = load("res://listener.gd").new()
	root.add_child(L)
	ce = CodeEdit.new(); ce.size = Vector2(400,300)
	root.add_child(ce)
	root.window_input.connect(func(e): if e is InputEventKey and e.pressed: wl.append("window_input"))
	process_frame.connect(_run, CONNECT_ONE_SHOT)
func _run():
	await process_frame
	ce.grab_focus()
	for c in [["Ctrl+Enter", KEY_ENTER, true, false], ["Ctrl+Shift+Enter", KEY_ENTER, true, true], ["Ctrl+M", KEY_M, true, false], ["Ctrl+Shift+S", KEY_S, true, true], ["Ctrl+H", KEY_H, true, false]]:
		L.log.clear(); wl.clear()
		var ev := InputEventKey.new()
		ev.keycode = c[1]; ev.physical_keycode = c[1]; ev.ctrl_pressed = c[2]; ev.shift_pressed = c[3]; ev.pressed = true
		root.push_input(ev)
		await process_frame
		print(c[0], " -> ", wl + L.log)
	quit()
