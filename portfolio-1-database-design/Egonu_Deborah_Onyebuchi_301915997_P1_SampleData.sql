-- Fictional sample records for E-commerce Platform.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."customers" ("customer_id", "email", "display_name", "created_at") VALUES (101, 'maya.chen@example.test', 'Maya Chen', '2026-10-12T09:30:00Z');
INSERT INTO portfolio."customers" ("customer_id", "email", "display_name", "created_at") VALUES (102, 'leo.park@example.test', 'Leo Park', '2026-10-13T14:15:00+00:00');
INSERT INTO portfolio."products" ("product_id", "sku", "title", "unit_price", "active") VALUES (201, 'MUG-BLUE-01', 'Blue Ceramic Mug', 14.5, TRUE);
INSERT INTO portfolio."products" ("product_id", "sku", "title", "unit_price", "active") VALUES (202, 'NOTE-GREEN-02', 'Green Notebook', 8.25, TRUE);
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status") VALUES (301, 101, '2026-10-20T11:00:00Z', 'open');
INSERT INTO portfolio."orders" ("order_id", "customer_id", "created_at", "status") VALUES (302, 102, '2026-10-21T16:45:00-04:00', 'paid');
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price") VALUES (401, 301, 201, 2, 13.75);
INSERT INTO portfolio."order_items" ("order_item_id", "order_id", "product_id", "quantity", "unit_price") VALUES (402, 302, 202, 3, 8.25);
COMMIT;
