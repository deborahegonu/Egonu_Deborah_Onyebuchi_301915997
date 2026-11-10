-- Each statement is deliberately invalid and must be REJECTED. Valid data stays unchanged.
SET search_path = naijamart;
CREATE TEMP TABLE test_log(no int, test text, outcome text);
DO $$
DECLARE t record; n int := 0;
BEGIN
  FOR t IN SELECT * FROM (VALUES
    ('duplicate customer email',        $q$INSERT INTO customers(full_name,email) VALUES ('X','ngozi@example.test')$q$),
    ('null customer name',              $q$INSERT INTO customers(full_name,email) VALUES (NULL,'a@example.test')$q$),
    ('address for missing customer',    $q$INSERT INTO addresses(customer_id,street,city,state) VALUES (999,'s','c','st')$q$),
    ('duplicate SKU',                   $q$INSERT INTO products(category_id,sku,name,price) VALUES (1,'PH-001','Dup',100)$q$),
    ('zero price',                      $q$INSERT INTO products(category_id,sku,name,price) VALUES (1,'ZZ-1','Free',0)$q$),
    ('negative price',                  $q$INSERT INTO products(category_id,sku,name,price) VALUES (1,'ZZ-2','Neg',-5)$q$),
    ('negative stock',                  $q$UPDATE inventory SET stock_qty = -1 WHERE product_id = 1$q$),
    ('invalid order status',            $q$INSERT INTO orders(customer_id,status) VALUES (1,'lost')$q$),
    ('order for missing customer',      $q$INSERT INTO orders(customer_id,status) VALUES (999,'paid')$q$),
    ('second pending order, same customer', $q$INSERT INTO orders(customer_id,status) VALUES (3,'pending')$q$),
    ('zero quantity',                   $q$INSERT INTO order_items VALUES (2,1,0,145000)$q$),
    ('duplicate order line',            $q$INSERT INTO order_items VALUES (1,1,1,145000)$q$),
    ('invalid payment method',          $q$INSERT INTO payments(order_id,method,status,amount) VALUES (1,'cash','failed',10)$q$),
    ('second delivery for one order',   $q$INSERT INTO deliveries(order_id,address_id,status) VALUES (1,1,'processing')$q$)
  ) AS x(name, stmt) LOOP
    n := n + 1;
    BEGIN
      EXECUTE t.stmt;
      INSERT INTO test_log VALUES (n, t.name, 'ACCEPTED (unexpected)');
    EXCEPTION WHEN OTHERS THEN
      INSERT INTO test_log VALUES (n, t.name, 'REJECTED: ' || SQLERRM);
    END;
  END LOOP;
END $$;
SELECT * FROM test_log ORDER BY no;
SELECT (SELECT count(*) FROM customers) AS customers, (SELECT count(*) FROM products) AS products,
       (SELECT count(*) FROM orders) AS orders, (SELECT count(*) FROM order_items) AS order_items;
