SET search_path = naijamart;
INSERT INTO customers(customer_id, full_name, email, phone) VALUES
 (1,'Ngozi Adeyemi','ngozi@example.test','08030000001'),
 (2,'Tunde Bakare','tunde@example.test','08030000002'),
 (3,'Amina Yusuf','amina@example.test','08030000003');
INSERT INTO addresses(address_id, customer_id, street, city, state) VALUES
 (1,1,'12 Allen Avenue','Ikeja','Lagos'),
 (2,2,'5 Ademola Adetokunbo','Victoria Island','Lagos'),
 (3,3,'20 Gwarinpa Estate','Abuja','FCT');
INSERT INTO categories(category_id, name) VALUES (1,'Phones'),(2,'Fashion'),(3,'Books');
INSERT INTO products(product_id, category_id, sku, name, price) VALUES
 (1,1,'PH-001','Tecno Spark 20',145000.00),
 (2,2,'SH-001','Ankara Shirt',15000.00),
 (3,3,'BK-001','Database Systems Concepts',32000.00),
 (4,1,'PH-002','Phone Case',3500.00);
INSERT INTO inventory(product_id, stock_qty) VALUES (1,10),(2,25),(3,5),(4,40);
INSERT INTO orders(order_id, customer_id, status, total_amount, created_at) VALUES
 (1,1,'delivered',160000.00,'2026-10-01 10:00+01'),
 (2,2,'paid',64000.00,'2026-10-05 15:30+01'),
 (3,3,'pending',15000.00,'2026-10-09 09:15+01');
INSERT INTO order_items(order_id, product_id, quantity, unit_price) VALUES
 (1,1,1,145000.00),(1,2,1,15000.00),
 (2,3,2,32000.00),
 (3,2,1,15000.00);
INSERT INTO payments(order_id, method, status, amount) VALUES
 (1,'card','successful',160000.00),
 (2,'transfer','successful',64000.00),
 (3,'ussd','initiated',15000.00);
INSERT INTO deliveries(order_id, address_id, status, delivered_at) VALUES
 (1,1,'delivered','2026-10-04 12:00+01'),
 (2,2,'in_transit',NULL);
SELECT setval(pg_get_serial_sequence('naijamart.customers','customer_id'),3);
SELECT setval(pg_get_serial_sequence('naijamart.addresses','address_id'),3);
SELECT setval(pg_get_serial_sequence('naijamart.categories','category_id'),3);
SELECT setval(pg_get_serial_sequence('naijamart.products','product_id'),4);
SELECT setval(pg_get_serial_sequence('naijamart.orders','order_id'),3);
