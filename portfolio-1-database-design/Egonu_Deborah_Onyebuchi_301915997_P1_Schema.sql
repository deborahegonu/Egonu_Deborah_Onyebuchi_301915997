-- NaijaMart: PostgreSQL schema (3NF)
DROP SCHEMA IF EXISTS naijamart CASCADE;
CREATE SCHEMA naijamart;
SET search_path = naijamart;

CREATE TABLE customers (
  customer_id BIGSERIAL PRIMARY KEY,
  full_name   TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  phone       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE addresses (
  address_id  BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
  street      TEXT NOT NULL,
  city        TEXT NOT NULL,
  state       TEXT NOT NULL
);
CREATE TABLE categories (
  category_id BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE
);
CREATE TABLE products (
  product_id  BIGSERIAL PRIMARY KEY,
  category_id BIGINT NOT NULL REFERENCES categories(category_id),
  sku         TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  price       NUMERIC(12,2) NOT NULL CHECK (price > 0)
);
CREATE TABLE inventory (
  product_id BIGINT PRIMARY KEY REFERENCES products(product_id) ON DELETE CASCADE,
  stock_qty  INTEGER NOT NULL CHECK (stock_qty >= 0),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE orders (
  order_id     BIGSERIAL PRIMARY KEY,
  customer_id  BIGINT NOT NULL REFERENCES customers(customer_id),
  status       TEXT NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending','paid','shipped','delivered','cancelled')),
  total_amount NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE order_items (
  order_id   BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(product_id),
  quantity   INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
  PRIMARY KEY (order_id, product_id)
);
CREATE TABLE payments (
  payment_id BIGSERIAL PRIMARY KEY,
  order_id   BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  method     TEXT NOT NULL CHECK (method IN ('card','transfer','ussd','wallet')),
  status     TEXT NOT NULL CHECK (status IN ('initiated','successful','failed','refunded')),
  amount     NUMERIC(14,2) NOT NULL CHECK (amount > 0)
);
CREATE TABLE deliveries (
  delivery_id  BIGSERIAL PRIMARY KEY,
  order_id     BIGINT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
  address_id   BIGINT NOT NULL REFERENCES addresses(address_id),
  status       TEXT NOT NULL CHECK (status IN ('processing','in_transit','delivered','failed')),
  delivered_at TIMESTAMPTZ
);
-- Business rule: a customer may have at most one open (pending) order at a time
CREATE UNIQUE INDEX one_pending_order_per_customer ON orders(customer_id) WHERE status = 'pending';
