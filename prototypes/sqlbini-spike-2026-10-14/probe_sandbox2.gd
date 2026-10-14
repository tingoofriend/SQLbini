# PROTOTYPE - NOT FOR PRODUCTION
# Question: query_only after view creation; does an ORDER BY over an unbounded recursive CTE hang (no interrupt API)?
# Date: 2026-10-14
extends SceneTree

func _init() -> void:
	var db := SQLite.new()
	db.path = ":memory:"
	db.verbosity_level = SQLite.QUIET
	db.open_db()
	db.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT, price INTEGER);")
	db.query("INSERT INTO products VALUES (1,'Cola',216),(2,'Tea',160);")
	db.query("CREATE TEMP VIEW v AS SELECT name FROM products")
	db.query("PRAGMA query_only = 1")
	print("select view under query_only: ", db.query("SELECT * FROM temp.v LIMIT 5001"), " ", db.query_result)
	print("insert under query_only: ", db.query("INSERT INTO products VALUES (3,'X',1)"))
	print("starting unbounded ORDER BY ...")
	var t := Time.get_ticks_msec()
	db.query("PRAGMA query_only = 0")
	var ok := db.query("CREATE TEMP VIEW w AS WITH RECURSIVE c(x) AS (SELECT 1 UNION ALL SELECT x+1 FROM c) SELECT x FROM c ORDER BY x DESC")
	ok = db.query("SELECT * FROM temp.w LIMIT 5001")
	print("finished?! ok=%s ms=%d" % [ok, Time.get_ticks_msec() - t])
	quit()
