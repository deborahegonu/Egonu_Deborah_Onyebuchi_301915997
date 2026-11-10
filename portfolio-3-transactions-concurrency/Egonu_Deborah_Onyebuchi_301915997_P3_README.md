# Portfolio 3: Transactions and concurrency

**NaijaMart (simulated Lagos e-commerce platform)** · Deborah Onyebuchi Egonu · Student ID 301915997

## Files
- `Egonu_Deborah_Onyebuchi_301915997_P3_Transactions.sql`: commit and rollback examples.
- `Egonu_Deborah_Onyebuchi_301915997_P3_SessionA.sql`, `Egonu_Deborah_Onyebuchi_301915997_P3_SessionB.sql`: two sessions competing for the last unit of a product.

## A. Commit and rollback (atomicity)
```text
--- A. COMMIT: place an order for 2 units of product 3 ---
BEGIN
INSERT 0 1
INSERT 0 1
UPDATE 1
COMMIT
 product_id | stock_qty 
------------+-----------
          3 |         3
(1 row)

--- B. ROLLBACK: order for 10 units fails the stock CHECK, nothing is saved ---
 orders_before 
---------------
             4
(1 row)

BEGIN
INSERT 0 1
psql:portfolio-3-transactions-concurrency/Egonu_Deborah_Onyebuchi_301915997_P3_Transactions.sql:16: ERROR:  new row for relation "inventory" violates check constraint "inventory_stock_qty_check"
DETAIL:  Failing row contains (3, -7, 2026-11-10 07:00:27.922117+00).
ROLLBACK
 orders_after 
--------------
            4
(1 row)

 product_id | stock_qty 
------------+-----------
          3 |         3
(1 row)
```
The first transaction inserts the order, the order line and reduces stock from 5 to 3 as one unit, then commits. The second tries to take 10 units; the `CHECK (stock_qty >= 0)` constraint fails, so the whole transaction is rolled back: the order count stays at 4 and stock stays at 3.

## B. Concurrency problem: overselling
Two sessions each read stock = 1, wait two seconds, then both accept an order.
```text
Session 1: session sees stock = 1 -> accepts order
Session 2: session sees stock = 1 -> accepts order

orders_accepted = 2   (for a product with only 1 unit)
```
This is a lost update: both transactions decided from the same stale read.

## C. Control mechanism: row locking with `SELECT ... FOR UPDATE`
```text
Session 1: session sees stock = 1 -> accepts order
Session 2: session sees stock = 0 -> REJECTS order

orders_accepted = 1
```
Session 2 blocked on the lock until Session 1 committed, then saw the updated stock and refused the order. An alternative is `SERIALIZABLE` isolation with a retry when PostgreSQL reports a serialization failure.

## Notes
- Default isolation in PostgreSQL is READ COMMITTED, which allows the lost update in section B.
- Deadlocks are avoided by always updating rows in the same order (for example ascending `product_id`).

## Screenshots to capture
`screenshots/Egonu_Deborah_Onyebuchi_301915997_P3_CommitRollback.png` and `screenshots/Egonu_Deborah_Onyebuchi_301915997_P3_ConcurrencyResult.png` (two terminals side by side).
