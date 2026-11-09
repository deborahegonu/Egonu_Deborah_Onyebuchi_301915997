# E-commerce Platform — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| customer_id | orders records (list) |
| --- | --- |
| 101 | [301] |
| 102 | [302] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| orders.order_id | orders.customer_id | orders.status | customers.customer_id | customers.email |
| --- | --- | --- | --- | --- |
| 301 | 101 | open | 101 | maya.chen@example.test |
| 302 | 102 | paid | 102 | leo.park@example.test |

Key: order_id.

## 2NF: depend on the whole key

The declared candidate keys do not introduce a partial dependency here, so the 1NF rows stay unchanged at this step.

## orders_example

| orders.order_id | orders.customer_id | orders.status | customers.customer_id | customers.email |
| --- | --- | --- | --- | --- |
| 301 | 101 | open | 101 | maya.chen@example.test |
| 302 | 102 | paid | 102 | leo.park@example.test |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## customers

| customer_id | email | display_name | created_at |
| --- | --- | --- | --- |
| 101 | maya.chen@example.test | Maya Chen | 2026-10-12T09:30:00+00:00 |
| 102 | leo.park@example.test | Leo Park | 2026-10-13T14:15:00+00:00 |

## products

| product_id | sku | title | unit_price | active |
| --- | --- | --- | --- | --- |
| 201 | MUG-BLUE-01 | Blue Ceramic Mug | 14.5 | true |
| 202 | NOTE-GREEN-02 | Green Notebook | 8.25 | true |

## orders

| order_id | customer_id | created_at | status |
| --- | --- | --- | --- |
| 301 | 101 | 2026-10-20T11:00:00+00:00 | open |
| 302 | 102 | 2026-10-21T20:45:00+00:00 | paid |

## order_items

| order_item_id | order_id | product_id | quantity | unit_price |
| --- | --- | --- | --- | --- |
| 401 | 301 | 201 | 2 | 13.75 |
| 402 | 302 | 202 | 3 | 8.25 |

## Dependencies

- customers: (customer_id) → email, display_name, created_at
- products: (product_id) → sku, title, unit_price, active
- orders: (order_id) → customer_id, created_at, status
- order_items: (order_item_id) → order_id, product_id, quantity, unit_price

Joining the decomposed sample tables reproduces the original 2 example rows. The design assumes the declared keys describe the relevant business dependencies.
