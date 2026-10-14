# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can godot-sqlite v4.9 meet the Hidden-Data Grader's sandbox contract (column count for 0 rows, duplicate names, one statement, read-only, runaway queries)?
# Date: 2026-10-14
extends SceneTree

func fresh() -> SQLite:
	var db := SQLite.new()
	db.path = ":memory:"
	db.verbosity_level = SQLite.QUIET
	db.open_db()
	db.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price INTEGER);")
	db.query("INSERT INTO products VALUES (1,'Cola',216),(2,'Tea',160);")
	return db

func show(label: String, db: SQLite, ok: bool) -> void:
	print("%-34s ok=%s err=%s result=%s" % [label, ok, db.error_message, db.query_result])

func _init() -> void:
	var db := fresh()
	# 1. zero rows: plain query loses columns
	show("plain 0 rows", db, db.query("SELECT name, price FROM products WHERE 1=0"))
	# 2. view approach for column metadata
	show("view create 0 rows", db, db.query("CREATE TEMP VIEW v AS SELECT name, price FROM products WHERE 1=0"))
	show("pragma table_info(v)", db, db.query("PRAGMA temp.table_info(v)"))
	# 3. duplicate names
	db.query("DROP VIEW temp.v")
	show("plain dup names", db, db.query("SELECT name, name, price FROM products"))
	show("view dup names", db, db.query("CREATE TEMP VIEW v AS SELECT name, name, price FROM products"))
	show("pragma dup", db, db.query("PRAGMA temp.table_info(v)"))
	show("select * from view dup", db, db.query("SELECT * FROM temp.v"))
	db.query("DROP VIEW temp.v")
	# 4. multi-statement
	db = fresh()
	show("multi stmt plain", db, db.query("SELECT 1; DROP TABLE products"))
	show("after multi: table still?", db, db.query("SELECT COUNT(*) AS n FROM products"))
	db = fresh()
	show("multi stmt in view", db, db.query("CREATE TEMP VIEW v AS SELECT 1; DROP TABLE products"))
	show("after view multi: table?", db, db.query("SELECT COUNT(*) AS n FROM products"))
	# 5. non-select in view
	db = fresh()
	show("update in view", db, db.query("CREATE TEMP VIEW v AS UPDATE products SET price=0"))
	# 6. trailing semicolon / comment
	show("view trailing ;", db, db.query("CREATE TEMP VIEW v2 AS SELECT name FROM products;"))
	show("view trailing comment", db, db.query("CREATE TEMP VIEW v3 AS SELECT name FROM products -- hi"))
	show("view with CTE", db, db.query("CREATE TEMP VIEW v4 AS WITH c AS (SELECT name FROM products) SELECT * FROM c"))
	# 7. query_only
	db = fresh()
	db.query("PRAGMA query_only = 1")
	show("insert under query_only", db, db.query("INSERT INTO products VALUES (3,'X',1)"))
	show("temp view under query_only", db, db.query("CREATE TEMP VIEW v AS SELECT name FROM products"))
	# 8. runaway recursive CTE bounded by outer LIMIT
	db = fresh()
	var t := Time.get_ticks_msec()
	var ok := db.query("WITH RECURSIVE c(x) AS (SELECT 1 UNION ALL SELECT x+1 FROM c) SELECT x FROM c LIMIT 5001")
	print("recursive+LIMIT ok=%s rows=%d ms=%d" % [ok, db.query_result.size(), Time.get_ticks_msec() - t])
	# 9. type of values
	db = fresh()
	db.query("SELECT 198 AS i, 198.0 AS r, NULL AS n, '1' AS s, 7/2 AS d")
	var row: Dictionary = db.query_result[0]
	for k in row: print("type %s = %s (%s)" % [k, row[k], type_string(typeof(row[k]))])
	quit()
