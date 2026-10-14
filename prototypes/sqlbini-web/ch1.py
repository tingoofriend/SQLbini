"""SQLbini - Chapter 1 "First Shift": dataset, puzzle definitions, and verifier.

Run `python3 ch1.py` to check that every reference answer passes all datasets
and every trap answer fails where it is designed to fail.
Run `python3 ch1.py --json > ch1.json` to export data for the prototype.
"""
import json
import sqlite3
import sys
from collections import Counter

TODAY = "2026-03-02"  # in-game date of Chapter 1 (Monday)

SCHEMA = """
CREATE TABLE products (
    id          INTEGER PRIMARY KEY,
    name        TEXT    NOT NULL,
    category    TEXT    NOT NULL,
    price       INTEGER NOT NULL,   -- selling price (yen, tax included)
    cost        INTEGER NOT NULL,   -- wholesale cost (yen)
    stock       INTEGER NOT NULL,   -- units on hand
    expiry_date TEXT,               -- 'YYYY-MM-DD', NULL if none
    shelf       TEXT    NOT NULL    -- shelf location
);
"""

# (name, category, price, cost, stock, expiry_date, shelf)
VISIBLE = [
    ("Shoyu Cup Ramen",       "Noodles",   198, 120, 24, "2026-09-30", "A1"),
    ("Miso Cup Ramen",        "Noodles",   214, 130, 18, "2026-08-15", "A1"),
    ("Tonkotsu Cup Ramen",    "Noodles",   248, 150,  2, "2026-07-01", "A2"),
    ("Spicy Yakisoba",        "Noodles",   235, 145, 12, "2026-10-10", "A2"),
    ("Mineral Water 500ml",   "Drinks",    110,  40, 40, "2027-02-01", "C1"),
    ("Cola 500ml",            "Drinks",    216, 110, 15, "2026-12-31", "C1"),
    ("Green Tea 500ml",       "Drinks",    160,  80,  1, "2026-11-30", "C1"),
    ("Canned Coffee",         "Drinks",    140,  65,  9, "2026-06-30", "C2"),
    ("Energy Drink",          "Drinks",    248, 130,  6, "2026-09-01", "C2"),
    ("Banana Milk",           "Dairy",     158,  85,  8, "2026-03-05", "D1"),
    ("Milk 200ml",            "Dairy",     120,  60,  5, "2026-03-01", "D1"),
    ("Strawberry Yogurt",     "Dairy",     148,  80,  0, "2026-02-27", "D1"),
    ("Potato Chips (Salted)", "Snacks",    168,  90, 11, "2026-08-20", "B1"),
    ("Banana Chips",          "Snacks",    178,  95,  7, "2026-07-11", "B1"),
    ("Rice Crackers",         "Snacks",    198, 110,  4, "2026-06-05", "B2"),
    ("Soda Ice Bar",          "Ice Cream",  86,  45, 20, "2027-03-01", "F1"),
    ("Vanilla Cone",          "Ice Cream", 178,  90, 10, "2027-03-01", "F1"),
    ("Mochi Ice",             "Ice Cream", 150,  75,  0, "2027-01-15", "F1"),
    ("Karaage Bento",         "Deli",      498, 300,  4, "2026-03-03", "E1"),
    ("Tuna Mayo Onigiri",     "Deli",      140,  80,  6, "2026-02-28", "E1"),
    ("Tonkatsu Bento",        "Deli",      550, 330,  1, "2026-03-04", "E1"),
    ("Wet Wipes",             "Household", 165,  80, 13, None,         "G1"),
    ("Toothbrush",            "Household", 250, 120,  2, None,         "G1"),
    ("AA Batteries 2-pack",   "Household", 330, 200,  0, None,         "G2"),
]

# Hidden test A: the visible rows plus edge cases that catch common mistakes
EDGE_ROWS = [
    ("Udon Cup",              "Noodles",   180, 110, 10, "2026-09-01", "A1"),  # no 'Ramen' in the name
    ("Lemon Soda",            "Drinks",    200, 100,  3, "2026-10-01", "C2"),  # exactly 200 yen, exactly 3 in stock
    ("Corn Puff Stick",       "Snacks",     40,  22,  9, "2026-08-01", "B2"),  # cheap snack (AND/OR precedence trap)
    ("Choco Banana Ice Bar",  "Ice Cream", 130,  65,  5, "2027-02-01", "F1"),  # 'Banana' in the middle
    ("Coffee Milk",           "Dairy",     150,  80,  4, "2026-03-02", "D1"),  # expires today (still sellable)
    ("Cheese Sticks",         "Dairy",     210, 110,  0, "2026-03-08", "D2"),  # last day of the week, out of stock
    ("Hamburg Bento",         "Deli",      520, 310,  2, "2026-03-02", "E1"),  # deli expiring today (boss rule)
    ("Fried Rice Bento",      "Deli",      480, 290,  0, "2026-03-02", "E1"),  # deli expiring today, 0 stock (parentheses trap)
    ("Salmon Onigiri",        "Deli",      160,  90,  0, "2026-02-25", "E1"),  # expired, 0 stock
    ("Vinyl Umbrella",        "Misc",      550, 330,  6, None,         "G2"),  # no expiry but not Household
]

# Hidden test B: shuffled order, different ids, a few changed values (blocks hardcoding)
HIDDEN_B_CHANGES = {
    "Shoyu Cup Ramen":       {"stock": 3},
    "Potato Chips (Salted)": {"price": 140},
    "Cola 500ml":            {"price": 200},
}
COLS = ["name", "category", "price", "cost", "stock", "expiry_date", "shelf"]


def build(rows, id_offset=1):
    con = sqlite3.connect(":memory:")
    con.executescript(SCHEMA)
    con.executemany(
        "INSERT INTO products VALUES (?,?,?,?,?,?,?,?)",
        [(i + id_offset, *r) for i, r in enumerate(rows)],
    )
    return con


def hidden_b_rows():
    rows = []
    for r in reversed(VISIBLE + EDGE_ROWS):
        r = list(r)
        for col, val in HIDDEN_B_CHANGES.get(r[0], {}).items():
            r[COLS.index(col)] = val
        rows.append(tuple(r))
    return rows


def datasets():
    return {
        "visible": build(VISIBLE),
        "hidden_a": build(VISIBLE + EDGE_ROWS),
        "hidden_b": build(hidden_b_rows(), id_offset=101),
    }


def run(con, sql):
    cur = con.execute(sql)
    return len(cur.description), Counter(cur.fetchall())


def check(answer_sql, player_sql, dbs):
    """Pass/fail per dataset: same column count + same rows (order ignored)."""
    out = {}
    for name, con in dbs.items():
        try:
            out[name] = run(con, answer_sql) == run(con, player_sql)
        except sqlite3.Error:
            out[name] = False
    return out


T = TODAY
# (id, title, request "Speaker: line", answer, [(trap name, trap sql, should pass visible?)])
PUZZLES = [
    ("1-1", "Open the Ledger",
     "Manager: Welcome aboard! First things first, pull up the whole product ledger for me.",
     "SELECT * FROM products", []),
    ("1-2", "New Price Tags",
     "Manager: We need fresh price tags. Just the product name and price, please.",
     "SELECT name, price FROM products",
     [("All columns", "SELECT * FROM products", False)]),
    ("1-3", "Noodle Aisle Check",
     "Manager: Let's tidy the noodle aisle. Give me the name, price, and stock of everything in Noodles.",
     "SELECT name, price, stock FROM products WHERE category = 'Noodles'",
     [("Guessing by name", "SELECT name, price, stock FROM products WHERE name LIKE '%Ramen%'", False),
      ("Hardcoded ids", "SELECT name, price, stock FROM products WHERE id IN (1,2,3,4)", True)]),
    ("1-4", "Time to Reorder",
     "Manager: Anything with 3 or fewer units left needs a reorder. Name and stock, please.",
     "SELECT name, stock FROM products WHERE stock <= 3",
     [("Less than vs. at most", "SELECT name, stock FROM products WHERE stock < 3", True)]),
    ("1-5", "Under 200 Yen",
     "Customer: Excuse me, which drinks are 200 yen or less?",
     "SELECT name, price FROM products WHERE category = 'Drinks' AND price <= 200",
     [("Missed the boundary", "SELECT name, price FROM products WHERE category = 'Drinks' AND price < 200", True)]),
    ("1-6", "Snack Run",
     "Customer: Can you show me snacks or ice cream that cost 150 yen or more? Something filling.",
     "SELECT name, price FROM products WHERE category IN ('Snacks', 'Ice Cream') AND price >= 150",
     [("AND/OR precedence", "SELECT name, price FROM products WHERE category = 'Snacks' OR category = 'Ice Cream' AND price >= 150", True)]),
    ("1-7", "Past Expiry",
     f"Manager: Find everything that's already past its expiry date as of today ({T}). Items expiring today can still be sold.",
     f"SELECT name, expiry_date FROM products WHERE expiry_date < '{T}'",
     [("Included today", f"SELECT name, expiry_date FROM products WHERE expiry_date <= '{T}'", True)]),
    ("1-8", "Expiring This Week",
     "Manager: Anything expiring this week (March 2 to 8) gets a discount sticker.",
     "SELECT name, expiry_date FROM products WHERE expiry_date BETWEEN '2026-03-02' AND '2026-03-08'",
     [("Excluded both ends", "SELECT name, expiry_date FROM products WHERE expiry_date > '2026-03-02' AND expiry_date < '2026-03-08'", True)]),
    ("1-9", "That Banana Thing",
     "Mrs. Sato: Oh dear, there was something with banana in it... I can't remember the name. Where is it?",
     "SELECT name, shelf FROM products WHERE name LIKE '%Banana%'",
     [("Matched the start only", "SELECT name, shelf FROM products WHERE name LIKE 'Banana%'", True)]),
    ("1-10", "No Expiry Date",
     "Kenji: Some items have a blank expiry date. Which ones are those?",
     "SELECT name, category FROM products WHERE expiry_date IS NULL",
     [("Compared with = NULL", "SELECT name, category FROM products WHERE expiry_date = NULL", False),
      ("Guessing by category", "SELECT name, category FROM products WHERE category = 'Household'", True)]),
    ("1-11", "[Boss] First Disposal List",
     f"Manager: Before you clock out, make the disposal list. Anything past expiry goes, and Deli items go even if they expire today ({T}). Skip anything with zero stock. Name, shelf, stock.",
     f"SELECT name, shelf, stock FROM products WHERE stock > 0 AND (expiry_date < '{T}' OR (category = 'Deli' AND expiry_date = '{T}'))",
     [("Missing parentheses", f"SELECT name, shelf, stock FROM products WHERE stock > 0 AND expiry_date < '{T}' OR category = 'Deli' AND expiry_date = '{T}'", True),
      ("Forgot the stock rule", f"SELECT name, shelf, stock FROM products WHERE expiry_date < '{T}' OR (category = 'Deli' AND expiry_date = '{T}')", False)]),
    # Side puzzles
    ("S-1", "[Side] Category List",
     "HQ: Please reply with the list of product categories your store carries.",
     "SELECT DISTINCT category FROM products",
     [("Duplicates included", "SELECT category FROM products", False)]),
    ("S-2", "[Side] Profit per Item",
     "Manager: I wonder how much we make per item. Show the name and margin (price minus cost).",
     "SELECT name, price - cost AS margin FROM products",
     [("Separate columns", "SELECT name, price, cost FROM products", False)]),
]


def export_json():
    return json.dumps({
        "today": TODAY,
        "visible": VISIBLE,
        "edge": EDGE_ROWS,
        "hiddenBChanges": HIDDEN_B_CHANGES,
        "puzzles": [{"id": p[0], "title": p[1], "ask": p[2], "answer": p[3],
                     "traps": [{"name": t[0], "sql": t[1]} for t in p[4]]} for p in PUZZLES],
    }, ensure_ascii=False)


def verify():
    dbs = datasets()
    ok = True
    for pid, title, _, ans, traps in PUZZLES:
        res = check(ans, ans, dbs)
        nrows = {k: sum(run(c, ans)[1].values()) for k, c in dbs.items()}
        print(f"{pid:5} {title:28} answer {'OK' if all(res.values()) else 'FAIL'}  rows {nrows}")
        for tname, tsql, should_pass_visible in traps:
            r = check(ans, tsql, dbs)
            hidden_fail = not (r["hidden_a"] and r["hidden_b"])
            good = hidden_fail and r["visible"] == should_pass_visible
            ok &= good
            print(f"      trap[{tname}] {r} -> {'OK' if good else '!!'}")
    print("\nVerification:", "PASSED" if ok else "PROBLEMS FOUND")
    return ok


if __name__ == "__main__":
    if "--json" in sys.argv:
        print(export_json())
    else:
        sys.exit(0 if verify() else 1)
