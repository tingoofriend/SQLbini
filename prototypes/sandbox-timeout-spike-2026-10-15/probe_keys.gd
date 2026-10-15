# PROTOTYPE - NOT FOR PRODUCTION
# Question: query_result Dictionary keys for duplicate / colon / empty names via the temp view; NULL keys; BLOB bindings (ADR-0002)
# Date: 2026-10-15
extends SceneTree

const C := preload("res://common.gd")

func run(db: SQLite, sql: String) -> void:
	db.query("DROP VIEW IF EXISTS temp._q")
	var ok := db.query("CREATE TEMP VIEW _q AS " + sql)
	db.query("PRAGMA temp.table_info(_q)")
	var names: Array = []
	for r in db.query_result: names.append(r["name"])
	db.query("SELECT * FROM temp._q LIMIT 2")
	var rows: Array = db.query_result
	var keys: Array = rows[0].keys() if rows.size() > 0 else []
	var vals: Array = []
	if rows.size() > 0:
		for k in keys: vals.append("%s:%s" % [type_string(typeof(rows[0][k])), rows[0][k]])
	print("%s\n   ok=%s pragma=%s\n   keys=%s vals=%s" % [sql, ok, names, keys, vals])

func _initialize() -> void:
	var db := C.fresh_db()
	run(db, "SELECT name, name, price FROM products")
	run(db, "SELECT name AS \"name:1\", name FROM products")
	run(db, "SELECT name, name AS \"name:1\", name FROM products")
	run(db, "SELECT price * 2, price*2 FROM products")
	run(db, "SELECT NULL AS n, '' AS e, name FROM products")
	run(db, "SELECT name AS \"\", price AS \"\" FROM products")
	run(db, "SELECT name, NAME, Name FROM products")
	run(db, "SELECT X'00FF' AS b")
	db.query("CREATE TABLE t (b BLOB, n TEXT)")
	var okb := db.query_with_bindings("INSERT INTO t VALUES (?, ?)", [PackedByteArray([0, 255]), null])
	db.query("SELECT b, n FROM t")
	print("binding blob/null ok=%s row=%s types=%s,%s" % [okb, db.query_result, type_string(typeof(db.query_result[0]["b"])), type_string(typeof(db.query_result[0]["n"]))])
	quit()
