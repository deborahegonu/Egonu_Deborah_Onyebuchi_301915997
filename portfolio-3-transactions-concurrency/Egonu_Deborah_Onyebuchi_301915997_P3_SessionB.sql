-- Session B: tries to buy the same last unit at the same time.
SET search_path = naijamart;
BEGIN;
SELECT stock_qty FROM inventory WHERE product_id = 1 FOR UPDATE;   -- BLOCKS until A commits
-- B now sees stock_qty = 0, so the application must refuse the order:
ROLLBACK;
-- Without FOR UPDATE both sessions read 1, both decrement, and the unit is sold twice (lost update).
