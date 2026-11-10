SET search_path = naijamart;
-- Q1. Orders with customer and products (join of four tables)
SELECT o.order_id, c.full_name, p.name AS product, oi.quantity, oi.unit_price
FROM orders o JOIN customers c USING (customer_id)
JOIN order_items oi USING (order_id) JOIN products p USING (product_id)
ORDER BY o.order_id, p.product_id;

-- Q2. Revenue per category (aggregation), paid/shipped/delivered orders only
SELECT cat.name AS category, sum(oi.quantity*oi.unit_price) AS revenue
FROM order_items oi JOIN orders o USING (order_id)
JOIN products p USING (product_id) JOIN categories cat USING (category_id)
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY cat.name ORDER BY revenue DESC;

-- Q3. Customer ranking by spend within each state (window function)
SELECT a.state, c.full_name, sum(o.total_amount) AS spend,
       rank() OVER (PARTITION BY a.state ORDER BY sum(o.total_amount) DESC) AS rank_in_state
FROM customers c JOIN addresses a USING (customer_id) JOIN orders o USING (customer_id)
GROUP BY a.state, c.full_name ORDER BY a.state, rank_in_state;

-- Q4. Products never ordered (anti-join)
SELECT p.sku, p.name FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id);
