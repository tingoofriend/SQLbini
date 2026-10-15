# PROTOTYPE - NOT FOR PRODUCTION
# Question: How can a sandbox execution be time-limited when godot-sqlite has no interrupt API? (ADR-0001)
# Date: 2026-10-15
class_name SpikeCommon
extends RefCounted

const SHORT_SQL := "SELECT name, price FROM products WHERE category = 'Drinks' AND price <= 200"
# 24^6 ≈ 191M row combinations — the residual case of sandbox rule 15 (many-way join aggregate).
const LONG_SQL := "SELECT COUNT(*) FROM products a, products b, products c, products d, products e, products f"

static func fresh_db() -> SQLite:
	var db := SQLite.new()
	db.path = ":memory:"
	db.verbosity_level = SQLite.QUIET
	db.open_db()
	db.query("CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, price INTEGER NOT NULL);")
	db.query("BEGIN")
	var cats := ["Drinks", "Snacks", "Deli", "Misc"]
	for i in 24:
		db.query_with_bindings("INSERT INTO products VALUES (?,?,?,?);", [i + 1, "Item %02d" % i, cats[i % 4], 100 + i * 7])
	db.query("COMMIT")
	return db

# One full sandbox-shaped execution: fresh DB, temp view, column metadata, query_only, fetch.
static func execute(sql: String) -> Dictionary:
	var t := Time.get_ticks_usec()
	var db := fresh_db()
	var ok := db.query("CREATE TEMP VIEW _q AS " + sql)
	var cols := 0
	var rows: Array = []
	if ok:
		db.query("PRAGMA temp.table_info(_q)")
		cols = db.query_result.size()
		db.query("PRAGMA query_only = 1")
		ok = db.query("SELECT * FROM temp._q LIMIT 5001")
		rows = db.query_result.duplicate()
	var err: String = db.error_message
	db.close_db()
	return {"ok": ok, "cols": cols, "rows": rows.size(), "err": err, "ms": (Time.get_ticks_usec() - t) / 1000.0}

static func p(arr: Array, q: float) -> float:
	var s := arr.duplicate()
	s.sort()
	return s[clampi(int(ceil(q * s.size())) - 1, 0, s.size() - 1)]
