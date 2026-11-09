-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. duplicate customer pk. Expected: pk_customers, SQLSTATE 23505.
INSERT INTO portfolio."customers" ("customer_id", "email", "display_name", "created_at")
VALUES (101, 'unique.customer@example.test', 'Ari Stone', '2026-10-22T10:00:00Z');

-- 2. duplicate customer email. Expected: uq_customers_0, SQLSTATE 23505.
INSERT INTO portfolio."customers" ("customer_id", "email", "display_name", "created_at")
VALUES (501, 'maya.chen@example.test', 'Ari Stone', '2026-10-22T10:05:00Z');

-- 3. null customer email. Expected: email, SQLSTATE 23502.
INSERT INTO portfolio."customers" ("customer_id", "email", "display_name", "created_at")
VALUES (502, NULL, 'Nia Reed', '2026-10-22T10:10:00Z');

-- 4. duplicate product pk. Expected: pk_products, SQLSTATE 23505.
INSERT INTO portfolio."products" ("product_id", "sku", "title", "unit_price", "active")
VALUES (201, 'MUG-RED-03', 'Red Ceramic Mug', 15, TRUE);

-- 5. duplicate product sku. Expected: uq_products_0, SQLSTATE 23505.
INSERT INTO portfolio."products" ("product_id", "sku", "title", "unit_price", "active")
VALUES (503, 'MUG-BLUE-01', 'Another Blue Mug', 16, TRUE);

-- 6. duplicate order pk. Expected: pk_orders, SQLSTATE 23505.
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status")
VALUES (301, 102, '2026-10-22T10:15:00Z', 'shipped');

-- 7. invalid order customer. Expected: fk_orders_0, SQLSTATE 23503.
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status")
VALUES (504, 999, '2026-10-22T10:20:00Z', 'paid');

-- 8. invalid order status. Expected: order_status_allowed, SQLSTATE 23514.
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status")
VALUES (505, 101, '2026-10-22T10:25:00Z', 'pending');

-- 9. duplicate open order customer. Expected: one_open_order_per_customer, SQLSTATE 23505.
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status")
VALUES (506, 101, '2026-10-22T10:30:00Z', 'open');

-- 10. duplicate order item pk. Expected: pk_order_items, SQLSTATE 23505.
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price")
VALUES (401, 302, 201, 1, 13.75);

-- 11. duplicate order product pair. Expected: uq_order_items_0, SQLSTATE 23505.
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price")
VALUES (507, 301, 201, 1, 13.75);

-- 12. invalid item order. Expected: fk_order_items_0, SQLSTATE 23503.
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price")
VALUES (508, 999, 202, 1, 8.25);

-- 13. invalid item product. Expected: fk_order_items_1, SQLSTATE 23503.
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price")
VALUES (509, 302, 999, 1, 8.25);

-- 14. nonpositive item quantity. Expected: positive_item_values, SQLSTATE 23514.
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price")
VALUES (510, 302, 201, 0, 13.75);
