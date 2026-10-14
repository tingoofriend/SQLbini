# Chapter 1 "First Shift" — Puzzle Design

_Last updated: 2026-10-14 · All answers and trap queries verified against SQLite (`ch1.py`)_

## Overview
- **In-game date**: 2026-03-02 (Mon), the player's first shift at SQLbini Ekimae
- **Learning goals**: `SELECT`, choosing columns, `WHERE`, comparison operators (`=`, `<`, `<=`), `AND` / `OR` / `IN`, `BETWEEN`, `LIKE`, `IS NULL`, (side) `DISTINCT`, computed columns with `AS`
- **Structure**: 11 main puzzles (the last is a boss) + 2 side puzzles
- **Tables**: just `products` (a messy ledger left by the previous part-timer; normalized in Chapter 7)

## Table

```sql
CREATE TABLE products (
    id          INTEGER PRIMARY KEY,
    name        TEXT    NOT NULL,
    category    TEXT    NOT NULL,   -- Noodles, Drinks, Dairy, Snacks, Ice Cream, Deli, Household (+hidden: Misc)
    price       INTEGER NOT NULL,   -- selling price (yen, tax included)
    cost        INTEGER NOT NULL,   -- wholesale cost (yen)
    stock       INTEGER NOT NULL,   -- units on hand
    expiry_date TEXT,               -- 'YYYY-MM-DD', NULL if none
    shelf       TEXT    NOT NULL    -- shelf location (A1, C2 ...)
);
```

## Test datasets
| Dataset | Contents | Shown to player |
|---|---|---|
| Visible | 24 products | Yes |
| Hidden A | Visible + 10 edge-case rows | No |
| Hidden B | Hidden A reversed, new ids, a few values changed (Shoyu Cup Ramen stock 3, Potato Chips ¥140, Cola ¥200) | No |

**Design principle**: most trap answers **pass on the visible data and fail on hidden data**. The game teaches the difference between "matching what you see" and "understanding the condition". On failure the game shows which rows were missing or extra, and the requester reacts.

### Hidden A edge rows
| Product | Trap it targets |
|---|---|
| Udon Cup (Noodles) | No 'Ramen' in the name → blocks `LIKE '%Ramen%'` guesses |
| Lemon Soda (Drinks, ¥200, stock 3) | `< 200`, `< 3` boundary mistakes |
| Corn Puff Stick (Snacks, ¥40) | `AND` / `OR` precedence |
| Choco Banana Ice Bar | `LIKE 'Banana%'` only matches the start |
| Coffee Milk (expires today) | Treating today's expiry as already expired |
| Cheese Sticks (expires 3/8, stock 0) | Using `>` / `<` instead of `BETWEEN` |
| Hamburg Bento (Deli, expires today, stock 2) | Boss: deli disposal rule |
| Fried Rice Bento (Deli, expires today, stock 0) | Boss: missing parentheses |
| Salmon Onigiri (expired, stock 0) | Boss: forgetting the stock rule |
| Vinyl Umbrella (Misc, no expiry) | Blocks `category = 'Household'` guesses |

## Puzzle list

| # | Title | Core concept | Traps |
|---|---|---|---|
| 1-1 | Open the Ledger | `SELECT *` | (tutorial) |
| 1-2 | New Price Tags | choosing columns | all columns |
| 1-3 | Noodle Aisle Check | `WHERE =` | guessing by name, hardcoded ids |
| 1-4 | Time to Reorder | `<=` | less than vs. at most |
| 1-5 | Under 200 Yen | `AND` | missed boundary |
| 1-6 | Snack Run | `OR` / `IN` | **AND/OR precedence** |
| 1-7 | Past Expiry | date comparison | included today |
| 1-8 | Expiring This Week | `BETWEEN` | excluded both ends |
| 1-9 | That Banana Thing | `LIKE '%..%'` | matched start only |
| 1-10 | No Expiry Date | `IS NULL` | `= NULL`, guessing by category |
| 1-11 | [Boss] First Disposal List | combined conditions, parentheses | missing parentheses, forgot stock rule |
| S-1 | [Side] Category List | `DISTINCT` | duplicates |
| S-2 | [Side] Profit per Item | computed column, `AS` | separate columns |

## Puzzle details

### 1-1 Open the Ledger
> **Manager**: Welcome aboard! First things first, pull up the whole product ledger for me.
```sql
SELECT * FROM products;
```
Tutorial: run button, result panel, schema browser.

### 1-2 New Price Tags
> **Manager**: We need fresh price tags. Just the product name and price, please.
```sql
SELECT name, price FROM products;
```
- Trap `SELECT *` → fails immediately on visible data. "You want the wholesale cost printed on the price tags?"

### 1-3 Noodle Aisle Check
> **Manager**: Let's tidy the noodle aisle. Give me the name, price, and stock of everything in Noodles.
```sql
SELECT name, price, stock FROM products WHERE category = 'Noodles';
```
- Trap `name LIKE '%Ramen%'` → fails on visible data too (Spicy Yakisoba)
- Trap `id IN (1,2,3,4)` → passes visible, fails hidden. The first puzzle that teaches **hardcoding doesn't work**
- Manager: "The ledger changes every day. Give me an answer that's always right, not just right today."

### 1-4 Time to Reorder
> **Manager**: Anything with 3 or fewer units left needs a reorder. Name and stock, please.
```sql
SELECT name, stock FROM products WHERE stock <= 3;
```
- Trap `stock < 3` → misses items with exactly 3 in hidden data

### 1-5 Under 200 Yen
> **Customer**: Excuse me, which drinks are 200 yen or less?
```sql
SELECT name, price FROM products WHERE category = 'Drinks' AND price <= 200;
```
- Trap `price < 200` → misses Lemon Soda (¥200) in hidden data

### 1-6 Snack Run
> **Customer**: Can you show me snacks or ice cream that cost 150 yen or more? Something filling.
```sql
SELECT name, price FROM products
WHERE category IN ('Snacks', 'Ice Cream') AND price >= 150;
```
- Trap `category = 'Snacks' OR category = 'Ice Cream' AND price >= 150`
  → `AND` binds first, so the ¥40 Corn Puff Stick sneaks in
- The key lesson of Chapter 1. On failure, visualize the evaluation order by drawing the implicit parentheses

### 1-7 Past Expiry
> **Manager**: Find everything that's already past its expiry date as of today (2026-03-02). Items expiring today can still be sold.
```sql
SELECT name, expiry_date FROM products WHERE expiry_date < '2026-03-02';
```
- Trap `<=` → includes Coffee Milk (expires today) in hidden data
- Briefly explain why 'YYYY-MM-DD' strings compare correctly; date functions come in later chapters

### 1-8 Expiring This Week
> **Manager**: Anything expiring this week (March 2 to 8) gets a discount sticker.
```sql
SELECT name, expiry_date FROM products
WHERE expiry_date BETWEEN '2026-03-02' AND '2026-03-08';
```
- Trap `> '2026-03-02' AND < '2026-03-08'` → misses both end dates
- Teaches that `BETWEEN` is inclusive

### 1-9 That Banana Thing
> **Mrs. Sato**: Oh dear, there was something with banana in it... I can't remember the name. Where is it?
```sql
SELECT name, shelf FROM products WHERE name LIKE '%Banana%';
```
- Trap `LIKE 'Banana%'` → misses Choco Banana Ice Bar in hidden data
- The shelf column lets the player walk Mrs. Sato to the right spot

### 1-10 No Expiry Date
> **Kenji**: Some items have a blank expiry date. Which ones are those?
```sql
SELECT name, category FROM products WHERE expiry_date IS NULL;
```
- Trap `= NULL` → zero rows. "NULL means 'no value', so you can't compare it with equals."
- Trap `category = 'Household'` → misses the Vinyl Umbrella (Misc) in hidden data

### 1-11 [Boss] First Disposal List
> **Manager**: Before you clock out, make the disposal list. Anything past expiry goes, and Deli items go even if they expire today. Skip anything with zero stock. Name, shelf, stock.
```sql
SELECT name, shelf, stock FROM products
WHERE stock > 0
  AND (expiry_date < '2026-03-02'
       OR (category = 'Deli' AND expiry_date = '2026-03-02'));
```
- Trap missing parentheses → passes visible, includes the zero-stock Fried Rice Bento in hidden data
- Trap no `stock > 0` → fails on visible data too (Strawberry Yogurt)
- Combines everything from Chapter 1. Clearing it pays the first wage and unlocks Chapter 2

### S-1 [Side] Category List
> **HQ**: Please reply with the list of product categories your store carries.
```sql
SELECT DISTINCT category FROM products;
```

### S-2 [Side] Profit per Item
> **Manager**: I wonder how much we make per item. Show the name and margin (price minus cost).
```sql
SELECT name, price - cost AS margin FROM products;
```
- Foreshadows Chapter 3 aggregation (margin × units sold = profit)

## Verification
`python3 ch1.py`: all 13 reference answers pass all 3 datasets; all 16 trap answers are caught exactly where designed.

## Open questions
- Is string comparison for dates fine in Chapter 1, or introduce `date('now')`-style functions early?
- Keep ignoring column names when comparing results? (S-2 could require `AS margin` for teaching purposes)
- Efficiency metric: character count vs. token count vs. `EXPLAIN QUERY PLAN` cost
