# PROTOTYPE - NOT FOR PRODUCTION
# Question: Is CodeEdit + godot-sqlite a workable SQL workbench (write → run → submit) in Godot 4.7.2?
# Date: 2026-10-14
# Keys: Ctrl+Enter = Run on visible data · Ctrl+Shift+Enter = Submit (hidden data)
# Screenshot mode: godot --path . -- --shot=res://shot.png [--puzzle=1-6] [--sql="..."] [--submit]
extends Control

const SQL_KEYWORDS := ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "IS", "NULL", "LIKE",
	"BETWEEN", "DISTINCT", "AS", "ORDER", "BY", "LIMIT", "INSERT", "UPDATE", "DELETE", "SET",
	"INTO", "VALUES", "GROUP", "HAVING", "JOIN", "ON", "ASC", "DESC", "COUNT", "SUM", "AVG", "MIN", "MAX"]

var data: Dictionary
var grader
var puzzle: Dictionary

var picker := OptionButton.new()
var request := RichTextLabel.new()
var editor := CodeEdit.new()
var status := RichTextLabel.new()
var your_tree := Tree.new()
var target_tree := Tree.new()


func _ready() -> void:
	data = JSON.parse_string(FileAccess.get_file_as_string("res://data/ch1.json"))
	grader = load("res://grader.gd").new(data)
	_build_ui()
	for p: Dictionary in data["puzzles"]:
		picker.add_item("%s  %s" % [p["id"], p["title"]])
	picker.item_selected.connect(_select)
	var args := _user_args()
	var idx := 0
	for i in data["puzzles"].size():
		if data["puzzles"][i]["id"] == args.get("puzzle", ""):
			idx = i
	picker.select(idx)
	_select(idx)
	if args.has("sql"):
		editor.text = args["sql"]
	if args.has("shot"):
		_run()
		if args.has("submit"):
			_submit()
		for _i in 10:
			await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png(args["shot"])
		get_tree().quit()


func _user_args() -> Dictionary:
	var out := {}
	for a in OS.get_cmdline_user_args():
		var parts := a.trim_prefix("--").split("=", true, 1)
		out[parts[0]] = parts[1] if parts.size() > 1 else true
	return out


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("f4f1ea")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16; root.offset_top = 12; root.offset_right = -16; root.offset_bottom = -12
	add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	picker.custom_minimum_size.x = 320
	top.add_child(picker)
	var run_btn := Button.new(); run_btn.text = "Run  (Ctrl+Enter)"; run_btn.pressed.connect(_run)
	var sub_btn := Button.new(); sub_btn.text = "Submit  (Ctrl+Shift+Enter)"; sub_btn.pressed.connect(_submit)
	top.add_child(run_btn); top.add_child(sub_btn)

	request.bbcode_enabled = true
	request.fit_content = true
	request.add_theme_color_override("default_color", Color("2b2b2b"))
	root.add_child(request)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left)
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.gutters_draw_line_numbers = true
	editor.auto_brace_completion_enabled = true
	editor.add_theme_font_size_override("font_size", 18)
	editor.syntax_highlighter = _sql_highlighter()
	editor.gui_input.connect(_on_editor_input)
	left.add_child(editor)
	status.bbcode_enabled = true
	status.custom_minimum_size.y = 150
	status.add_theme_color_override("default_color", Color("2b2b2b"))
	left.add_child(status)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(right)
	for pair: Array in [["Your result (visible data)", your_tree], ["Target", target_tree]]:
		var l := Label.new(); l.text = pair[0]; l.add_theme_color_override("font_color", Color("2b2b2b"))
		right.add_child(l)
		var t: Tree = pair[1]
		t.hide_root = true
		t.column_titles_visible = true
		t.size_flags_vertical = Control.SIZE_EXPAND_FILL
		right.add_child(t)


func _sql_highlighter() -> CodeHighlighter:
	var h := CodeHighlighter.new()
	for k: String in SQL_KEYWORDS:
		h.add_keyword_color(k, Color("c678dd"))
		h.add_keyword_color(k.to_lower(), Color("c678dd"))
	h.add_color_region("'", "'", Color("98c379"))
	h.add_color_region("--", "", Color("7f848e"), true)
	h.number_color = Color("d19a66")
	h.symbol_color = Color("56b6c2")
	h.function_color = Color("61afef")
	h.member_variable_color = Color("e5e5e5")
	return h


func _on_editor_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and e.keycode == KEY_ENTER and e.ctrl_pressed:
		if e.shift_pressed:
			_submit()
		else:
			_run()
		editor.accept_event()


func _select(i: int) -> void:
	puzzle = data["puzzles"][i]
	var parts: PackedStringArray = (puzzle["ask"] as String).split(": ", true, 1)
	request.text = "[b]%s:[/b] %s" % [parts[0], parts[1]]
	editor.text = "SELECT * FROM products;"
	status.text = ""
	_fill(target_tree, grader.run("visible", puzzle["answer"]))
	your_tree.clear()


func _fill(tree: Tree, res: Dictionary) -> void:
	tree.clear()
	var cols: Array = res["columns"]
	tree.columns = maxi(1, cols.size())
	for c in cols.size():
		tree.set_column_title(c, cols[c])
	var root := tree.create_item()
	for row: Array in res["rows"]:
		var item := tree.create_item(root)
		for c in row.size():
			item.set_text(c, "NULL" if row[c] == null else str(row[c]))


func _run() -> void:
	var res: Dictionary = grader.run("visible", editor.text)
	if not res["ok"]:
		status.text = "[color=#b3261e]SQL error:[/color] %s" % res["error"]
		your_tree.clear()
		return
	_fill(your_tree, res)
	var v: Dictionary = grader.check(puzzle["answer"], editor.text)
	status.text = "Ran on visible data — %d rows. %s" % [res["rows"].size(),
		"[color=#1e7d32]Matches the target.[/color]" if v["visible"] else "Doesn't match the target yet."]


func _submit() -> void:
	var v: Dictionary = grader.check(puzzle["answer"], editor.text)
	var lines: PackedStringArray = []
	for ds: String in v:
		lines.append("%s  %s" % ["[color=#1e7d32]PASS[/color]" if v[ds] else "[color=#b3261e]FAIL[/color]", ds])
	var failed := ""
	for ds: String in v:
		if not v[ds]:
			failed = ds
			break
	if failed == "":
		lines.append("\n[b]Cleared![/b]")
	else:
		var d: Dictionary = grader.diff(failed, puzzle["answer"], editor.text)
		lines.append("\nOn [b]%s[/b]:" % failed)
		for k: String in d["missing"]:
			lines.append("  [color=#b3261e]missing[/color] %s" % k)
		for k: String in d["extra"]:
			lines.append("  [color=#b3261e]extra[/color]   %s" % k)
	status.text = "\n".join(lines)
