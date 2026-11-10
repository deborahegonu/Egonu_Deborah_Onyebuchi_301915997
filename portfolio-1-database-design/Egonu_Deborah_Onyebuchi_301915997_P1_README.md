# Portfolio 1: Database design and modelling

**NaijaMart (simulated Lagos e-commerce platform)** · Deborah Onyebuchi Egonu · Student ID 301915997

## Files
| File | Purpose |
|---|---|
| Egonu_Deborah_Onyebuchi_301915997_P1_Design.md | case study, users, data, operations, design decisions |
| Egonu_Deborah_Onyebuchi_301915997_P1_ERDiagram.md | ER diagram (Mermaid) with a PNG in `../images/` |
| Egonu_Deborah_Onyebuchi_301915997_P1_Schema.sql | tables, keys, constraints |
| Egonu_Deborah_Onyebuchi_301915997_P1_Normalisation.md | 1NF, 2NF, 3NF walk-through |
| Egonu_Deborah_Onyebuchi_301915997_P1_SampleData.sql | small fictional data set |
| Egonu_Deborah_Onyebuchi_301915997_P1_ConstraintTests.sql | 14 deliberately invalid statements |

## How to run
```bash
createdb naijamart
psql naijamart -f Egonu_Deborah_Onyebuchi_301915997_P1_Schema.sql
psql naijamart -f Egonu_Deborah_Onyebuchi_301915997_P1_SampleData.sql
psql naijamart -f Egonu_Deborah_Onyebuchi_301915997_P1_ConstraintTests.sql
```

## Result
All 14 invalid statements were rejected and the valid rows were unchanged (3 customers, 4 products, 3 orders, 4 order lines).

```text
SET
CREATE TABLE
DO
 no |                test                 |                                                   outcome                                                    
----+-------------------------------------+--------------------------------------------------------------------------------------------------------------
  1 | duplicate customer email            | REJECTED: duplicate key value violates unique constraint "customers_email_key"
  2 | null customer name                  | REJECTED: null value in column "full_name" of relation "customers" violates not-null constraint
  3 | address for missing customer        | REJECTED: insert or update on table "addresses" violates foreign key constraint "addresses_customer_id_fkey"
  4 | duplicate SKU                       | REJECTED: duplicate key value violates unique constraint "products_sku_key"
  5 | zero price                          | REJECTED: new row for relation "products" violates check constraint "products_price_check"
  6 | negative price                      | REJECTED: new row for relation "products" violates check constraint "products_price_check"
  7 | negative stock                      | REJECTED: new row for relation "inventory" violates check constraint "inventory_stock_qty_check"
  8 | invalid order status                | REJECTED: new row for relation "orders" violates check constraint "orders_status_check"
  9 | order for missing customer          | REJECTED: insert or update on table "orders" violates foreign key constraint "orders_customer_id_fkey"
 10 | second pending order, same customer | REJECTED: duplicate key value violates unique constraint "one_pending_order_per_customer"
 11 | zero quantity                       | REJECTED: new row for relation "order_items" violates check constraint "order_items_quantity_check"
 12 | duplicate order line                | REJECTED: duplicate key value violates unique constraint "order_items_pkey"
 13 | invalid payment method              | REJECTED: new row for relation "payments" violates check constraint "payments_method_check"
 14 | second delivery for one order       | REJECTED: duplicate key value violates unique constraint "deliveries_order_id_key"
(14 rows)
```

## Screenshot to capture
`screenshots/Egonu_Deborah_Onyebuchi_301915997_P1_DatabaseResults.png`: the output above in your own terminal.
