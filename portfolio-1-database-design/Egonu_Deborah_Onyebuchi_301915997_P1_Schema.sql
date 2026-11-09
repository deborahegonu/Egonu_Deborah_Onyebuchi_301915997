-- E-commerce Platform: tables, keys and business constraints.
-- Run once in a fresh PostgreSQL database.
BEGIN;
SET LOCAL standard_conforming_strings = on;
CREATE SCHEMA portfolio;
CREATE TABLE portfolio."customers" (
  "customer_id" bigint NOT NULL,
  "email" text NOT NULL,
  "display_name" text NOT NULL,
  "created_at" timestamptz NOT NULL,
  CONSTRAINT "pk_customers" PRIMARY KEY ("customer_id"),
  CONSTRAINT "uq_customers_0" UNIQUE ("email")
);
CREATE TABLE portfolio."products" (
  "product_id" bigint NOT NULL,
  "sku" text NOT NULL,
  "title" text NOT NULL,
  "unit_price" numeric(18,2) NOT NULL,
  "active" boolean NOT NULL,
  CONSTRAINT "pk_products" PRIMARY KEY ("product_id"),
  CONSTRAINT "uq_products_0" UNIQUE ("sku")
);
CREATE TABLE portfolio."orders" (
  "order_id" bigint NOT NULL,
  "customer_id" bigint NOT NULL,
  "created_at" timestamptz NOT NULL,
  "status" text NOT NULL,
  CONSTRAINT "pk_orders" PRIMARY KEY ("order_id")
);
CREATE TABLE portfolio."order_items" (
  "order_item_id" bigint NOT NULL,
  "order_id" bigint NOT NULL,
  "product_id" bigint NOT NULL,
  "quantity" bigint NOT NULL,
  "unit_price" numeric(18,2) NOT NULL,
  CONSTRAINT "pk_order_items" PRIMARY KEY ("order_item_id"),
  CONSTRAINT "uq_order_items_0" UNIQUE ("order_id", "product_id")
);
ALTER TABLE portfolio."orders" ADD CONSTRAINT "fk_orders_0" FOREIGN KEY ("customer_id") REFERENCES portfolio."customers" ("customer_id");
ALTER TABLE portfolio."order_items" ADD CONSTRAINT "fk_order_items_0" FOREIGN KEY ("order_id") REFERENCES portfolio."orders" ("order_id");
ALTER TABLE portfolio."order_items" ADD CONSTRAINT "fk_order_items_1" FOREIGN KEY ("product_id") REFERENCES portfolio."products" ("product_id");
ALTER TABLE portfolio."orders" ADD CONSTRAINT "order_status_allowed" CHECK (("status" = 'open') OR ("status" = 'paid') OR ("status" = 'shipped') OR ("status" = 'cancelled'));
CREATE UNIQUE INDEX "one_open_order_per_customer" ON portfolio."orders" ("customer_id") WHERE ("status" = 'open');
ALTER TABLE portfolio."order_items" ADD CONSTRAINT "positive_item_values" CHECK (("quantity" > 0) AND ("unit_price" >= 0));
COMMIT;
