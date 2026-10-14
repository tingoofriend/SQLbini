# PROTOTYPE - NOT FOR PRODUCTION
# Question: What does one sandbox execution (fresh DB + 34 rows + view + PRAGMA + fetch) cost on this machine?
# Date: 2026-10-14
extends SceneTree

func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ch1.json"))
	var rows: Array = data["visible"] + data["edge"]
	var sql := "SELECT name, shelf, stock FROM products WHERE stock > 0 AND (expiry_date < '2026-03-02' OR (category = 'Deli' AND expiry_date = '2026-03-02'))"
	var times: Array = []
	for n in 200:
		var t := Time.get_ticks_usec()
		var db := SQLite.new()
		db.path = ":memory:"
		db.verbosity_level = SQLite.QUIET
		db.open_db()
		db.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, price INTEGER NOT NULL, cost INTEGER NOT NULL, stock INTEGER NOT NULL, expiry_date TEXT, shelf TEXT NOT NULL);")
		db.query("BEGIN")
		for i in rows.size():
			var r: Array = rows[i]
			db.query_with_bindings("INSERT INTO products VALUES (?,?,?,?,?,?,?,?);", [i + 1, r[0], r[1], int(r[2]), int(r[3]), int(r[4]), r[5], r[6]])
		db.query("COMMIT")
		db.query("CREATE TEMP VIEW _q AS " + sql)
		db.query("PRAGMA temp.table_info(_q)")
		var cols: int = db.query_result.size()
		db.query("PRAGMA query_only = 1")
		db.query("SELECT * FROM temp._q LIMIT 5001")
		db.close_db()
		times.append((Time.get_ticks_usec() - t) / 1000.0)
	times.sort()
	print("executions=200 p50=%.2fms p95=%.2fms max=%.2fms" % [times[100], times[189], times[199]])
	quit()
