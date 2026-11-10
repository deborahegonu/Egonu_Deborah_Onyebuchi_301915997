-- Benchmark on synthetic data: 20,000 customers, 2,000 products, 200,000 orders, 600,000 order lines.
SET search_path = naijamart;
TRUNCATE deliveries, payments, order_items, orders, inventory, products, categories, addresses, customers RESTART IDENTITY CASCADE;
INSERT INTO categories(name) SELECT 'Category ' || g FROM generate_series(1,10) g;
INSERT INTO products(category_id, sku, name, price)
  SELECT 1 + g % 10, 'SKU-' || g, 'Product ' || g, round((500 + random()*49500)::numeric, 2) FROM generate_series(1,2000) g;
INSERT INTO customers(full_name, email) SELECT 'Customer ' || g, 'c' || g || '@example.test' FROM generate_series(1,20000) g;
INSERT INTO addresses(customer_id, street, city, state) SELECT g, g || ' Test Street', 'Ikeja', 'Lagos' FROM generate_series(1,20000) g;
INSERT INTO orders(customer_id, status, created_at)
  SELECT 1 + floor(random()*20000)::int,
         (ARRAY['paid','shipped','delivered','cancelled'])[1 + floor(random()*4)::int],
         now() - (random()*365 || ' days')::interval
  FROM generate_series(1,200000);
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
  SELECT o.order_id, p.product_id, 1 + floor(random()*3)::int, p.price
  FROM orders o CROSS JOIN generate_series(1,3) k
  JOIN products p ON p.product_id = ((o.order_id*7 + k*131) % 2000) + 1;
UPDATE orders o SET total_amount = s.t FROM (SELECT order_id, sum(quantity*unit_price) t FROM order_items GROUP BY order_id) s WHERE s.order_id = o.order_id;
ANALYZE;

\echo '=== BEFORE: one customer''s recent orders ==='
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING ON) SELECT * FROM orders WHERE customer_id = 4321 AND created_at > now() - interval '90 days';
\echo '=== BEFORE: units sold per product (correlated subquery) ==='
EXPLAIN (ANALYZE, COSTS OFF, TIMING ON) SELECT p.product_id, (SELECT sum(quantity) FROM order_items oi WHERE oi.product_id = p.product_id) FROM products p;

CREATE INDEX idx_orders_customer_created ON orders(customer_id, created_at);
CREATE INDEX idx_order_items_product ON order_items(product_id);
ANALYZE;

\echo '=== AFTER: one customer''s recent orders ==='
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING ON) SELECT * FROM orders WHERE customer_id = 4321 AND created_at > now() - interval '90 days';
\echo '=== AFTER: units sold per product (correlated subquery) ==='
EXPLAIN (ANALYZE, COSTS OFF, TIMING ON) SELECT p.product_id, (SELECT sum(quantity) FROM order_items oi WHERE oi.product_id = p.product_id) FROM products p;
