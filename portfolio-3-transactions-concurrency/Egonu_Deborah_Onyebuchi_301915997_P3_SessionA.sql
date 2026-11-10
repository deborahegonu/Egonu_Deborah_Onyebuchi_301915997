-- Session A: buys the last unit of product 1 using SELECT ... FOR UPDATE.
-- Prepare: UPDATE naijamart.inventory SET stock_qty = 1 WHERE product_id = 1;
SET search_path = naijamart;
BEGIN;
SELECT stock_qty FROM inventory WHERE product_id = 1 FOR UPDATE;   -- 1. A locks the row
-- (pause here, start Session B, run its SELECT ... FOR UPDATE: it will WAIT)
UPDATE inventory SET stock_qty = stock_qty - 1 WHERE product_id = 1;
COMMIT;                                                            -- 2. B is released
