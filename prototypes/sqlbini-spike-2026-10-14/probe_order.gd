# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does SELECT * FROM a temp view preserve the view's ORDER BY (incl. DESC, multi-key, with LIMIT) in godot-sqlite v4.9?
# Date: 2026-10-14
extends SceneTree

func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ch1.json"))
	var rows: Array = data["visible"] + data["edge"]
	var cases := [
		"SELECT name, price FROM products ORDER BY price DESC, name",
		"SELECT name, stock FROM products ORDER BY stock, name DESC",
		"SELECT category, COUNT(*) AS n FROM products GROUP BY category ORDER BY n DESC, category",
		"SELECT name, price FROM products ORDER BY price LIMIT 7",
	]
	for sql in cases:
		var db := SQLite.new()
		db.path = ":memory:"
		db.verbosity_level = SQLite.QUIET
		db.open_db()
		db.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, category TEXT, price INTEGER, cost INTEGER, stock INTEGER, expiry_date TEXT, shelf TEXT);")
		for i in rows.size():
			var r: Array = rows[i]
			db.query_with_bindings("INSERT INTO products VALUES (?,?,?,?,?,?,?,?);", [i + 1, r[0], r[1], int(r[2]), int(r[3]), int(r[4]), r[5], r[6]])
		db.query(sql)
		var direct: Array = []
		for row: Dictionary in db.query_result: direct.append(row.values())
		db.query("CREATE TEMP VIEW _q AS " + sql)
		db.query("PRAGMA query_only = 1")
		db.query("SELECT * FROM temp._q LIMIT 5001")
		var via: Array = []
		for row: Dictionary in db.query_result: via.append(row.values())
		print("%-5s %s" % ["SAME" if direct == via else "DIFF", sql])
	quit()
