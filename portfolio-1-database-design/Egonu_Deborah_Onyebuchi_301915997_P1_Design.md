# E-commerce Platform — database design

My case study records customers, products, orders, order_items.

## Users

- Customers placing and tracking orders
- Store staff reviewing orders and product sales

## Main operations

- Place an order with product and price snapshots
- Find a customer's orders by status and date
- Summarize paid sales by product
- Benchmark the order-status filter on synthetic data: compare its query plan before and after a B-tree index using 20000 generated orders; record no expected results in this specification

## Entities

| Entity | Information stored |
| --- | --- |
| customers | Stores customer identity and contact details. |
| products | Stores the catalog and current product prices. |
| orders | Stores order status and creation time; customer attributes remain in customers, illustrating normalization across this foreign key. |
| order_items | Stores products in each order with quantity and purchase-time price. |

## customers

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| customer_id | BIGINT | PK | Yes |
| email | TEXT | Unique | Yes |
| display_name | TEXT |  | Yes |
| created_at | TIMESTAMPTZ |  | Yes |
- Unique key: (email).

## products

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| product_id | BIGINT | PK | Yes |
| sku | TEXT | Unique | Yes |
| title | TEXT |  | Yes |
| unit_price | NUMERIC(18,2) |  | Yes |
| active | BOOLEAN |  | Yes |
- Unique key: (sku).

## orders

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| order_id | BIGINT | PK | Yes |
| customer_id | BIGINT | FK | Yes |
| created_at | TIMESTAMPTZ |  | Yes |
| status | TEXT |  | Yes |
- customer_id → customers.customer_id

## order_items

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| order_item_id | BIGINT | PK | Yes |
| order_id | BIGINT | FK | Yes |
| product_id | BIGINT | FK | Yes |
| quantity | INTEGER |  | Yes |
| unit_price | NUMERIC(18,2) |  | Yes |
- order_id → orders.order_id
- product_id → products.product_id
- Unique key: (order_id, product_id).

## Relationships and business rules

- Each customer email identifies at most one customer.
- Each catalog SKU identifies at most one product.
- Every order references an existing customer.
- Order status is limited to open, paid, shipped, or cancelled.
- A partial unique rule permits at most one order per customer where status is open.
- Each order item has a positive quantity and a nonnegative purchase-time unit price.

## Assumptions

- This specification is for e-commerce, not a library case.
- Each entity has a globally unique, single-column primary key; the identifiers use separate namespaces.
- An order item stores the product price at purchase time so later catalog changes do not alter historical sales.
- An order may be open, paid, shipped, or cancelled; at most one open order may exist per customer.
- For the normalization example, orders is the entity with a foreign key: customer details belong to customers and are not repeated on orders.

