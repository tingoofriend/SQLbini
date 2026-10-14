# PROTOTYPE - NOT FOR PRODUCTION
# Question: Can Godot 4.7.2 + godot-sqlite grade SQLbini Chapter 1 queries with the same verdicts as ch1.py?
# Date: 2026-10-14
extends RefCounted

const SCHEMA := "CREATE TABLE products (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, price INTEGER NOT NULL, cost INTEGER NOT NULL, stock INTEGER NOT NULL, expiry_date TEXT, shelf TEXT NOT NULL);"
const COLS := ["name", "category", "price", "cost", "stock", "expiry_date", "shelf"]
const DATASETS := ["visible", "hidden_a", "hidden_b"]

var data: Dictionary


func _init(p_data: Dictionary) -> void:
	data = p_data


## Rows for each dataset, mirroring ch1.datasets(): [rows, id_offset].
func _dataset_rows(dataset: String) -> Array:
	var visible: Array = data["visible"]
	var edge: Array = data["edge"]
	match dataset:
		"visible":
			return [visible, 1]
		"hidden_a":
			return [visible + edge, 1]
		_:
			var changes: Dictionary = data["hiddenBChanges"]
			var all_rows: Array = visible + edge
			all_rows.reverse()
			var rows: Array = []
			for r: Array in all_rows:
				var row := r.duplicate()
				var change: Dictionary = changes.get(row[0], {})
				for col: String in change:
					row[COLS.find(col)] = change[col]
				rows.append(row)
			return [rows, 101]


## Fresh in-memory DB per run, so UPDATE/DELETE/DROP can't corrupt later runs.
func _open(dataset: String) -> SQLite:
	var db := SQLite.new()
	db.path = ":memory:"
	db.verbosity_level = SQLite.QUIET
	db.open_db()
	db.query(SCHEMA)
	var spec := _dataset_rows(dataset)
	var rows: Array = spec[0]
	var offset: int = spec[1]
	for i in rows.size():
		var r: Array = rows[i]
		var bindings: Array = [i + offset, r[0], r[1], int(r[2]), int(r[3]), int(r[4]), r[5], r[6]]
		db.query_with_bindings("INSERT INTO products VALUES (?,?,?,?,?,?,?,?);", bindings)
	return db


## Runs sql on a dataset. Returns {ok, error, columns, rows}.
func run(dataset: String, sql: String) -> Dictionary:
	var db := _open(dataset)
	var ok := db.query(sql)
	var result := {"ok": ok, "error": db.error_message if not ok else "", "columns": [], "rows": []}
	if ok:
		var res: Array = db.query_result
		if res.size() > 0:
			result["columns"] = (res[0] as Dictionary).keys()
		for row: Dictionary in res:
			result["rows"].append(row.values())
	db.close_db()
	return result


## Multiset of rows keyed by their serialized values (column names ignored).
static func _bag(rows: Array) -> Dictionary:
	var bag := {}
	for row: Array in rows:
		var k := JSON.stringify(row)
		bag[k] = bag.get(k, 0) + 1
	return bag


## Same rule as ch1.check(): same column count + same rows, order ignored.
func check(answer_sql: String, player_sql: String) -> Dictionary:
	var out := {}
	for ds: String in DATASETS:
		var a := run(ds, answer_sql)
		var p := run(ds, player_sql)
		out[ds] = p["ok"] and a["columns"].size() == p["columns"].size() and _bag(a["rows"]) == _bag(p["rows"])
	return out


## Missing / extra rows of the player's result vs the answer on one dataset.
func diff(dataset: String, answer_sql: String, player_sql: String) -> Dictionary:
	var a := _bag(run(dataset, answer_sql)["rows"])
	var p := _bag(run(dataset, player_sql)["rows"])
	var missing: Array = []
	var extra: Array = []
	for k: String in a:
		for _i in maxi(0, a[k] - p.get(k, 0)):
			missing.append(k)
	for k: String in p:
		for _i in maxi(0, p[k] - a.get(k, 0)):
			extra.append(k)
	return {"missing": missing, "extra": extra}
