-- Run after P1 schema + sample data. Product 3 has stock 5.
SET search_path = naijamart;

\echo '--- A. COMMIT: place an order for 2 units of product 3 ---'
BEGIN;
  INSERT INTO orders(customer_id, status, total_amount) VALUES (1,'paid',64000) RETURNING order_id \gset
  INSERT INTO order_items VALUES (:order_id, 3, 2, 32000);
  UPDATE inventory SET stock_qty = stock_qty - 2 WHERE product_id = 3;
COMMIT;
SELECT product_id, stock_qty FROM inventory WHERE product_id = 3;

\echo '--- B. ROLLBACK: order for 10 units fails the stock CHECK, nothing is saved ---'
SELECT count(*) AS orders_before FROM orders;
BEGIN;
  INSERT INTO orders(customer_id, status, total_amount) VALUES (2,'paid',320000);
  UPDATE inventory SET stock_qty = stock_qty - 10 WHERE product_id = 3;
ROLLBACK;
SELECT count(*) AS orders_after FROM orders;
SELECT product_id, stock_qty FROM inventory WHERE product_id = 3;
