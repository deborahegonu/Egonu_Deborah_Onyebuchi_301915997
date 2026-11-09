# E-commerce Platform — SQL queries

## 1. Show related orders, customers, order_items, products records (up to 20).

```sql
SELECT t0."order_id" AS "orders_order_id",
       t0."created_at" AS "orders_created_at",
       t3."customer_id" AS "customers_customer_id",
       t3."email" AS "customers_email",
       t1."order_item_id" AS "order_items_order_item_id",
       t1."quantity" AS "order_items_quantity",
       t2."product_id" AS "products_product_id",
       t2."sku" AS "products_sku"
FROM portfolio."orders" t0
JOIN portfolio."order_items" t1 ON t1."order_id" = t0."order_id"
JOIN portfolio."products" t2 ON t1."product_id" = t2."product_id"
JOIN portfolio."customers" t3 ON t0."customer_id" = t3."customer_id"
ORDER BY t0."order_id", t3."customer_id", t1."order_item_id", t2."product_id"
LIMIT 20;
```

| orders_order_id | orders_created_at | customers_customer_id | customers_email | order_items_order_item_id | order_items_quantity | products_product_id | products_sku |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 301 | 2026-10-20T11:00:00+00:00 | 101 | maya.chen@example.test | 401 | 2 | 201 | MUG-BLUE-01 |
| 302 | 2026-10-21T20:45:00+00:00 | 102 | leo.park@example.test | 402 | 3 | 202 | NOTE-GREEN-02 |

## 2. Find orders records where status matches "open" (up to 20).

```sql
SELECT * FROM portfolio."orders"
WHERE "status" IS NOT DISTINCT FROM 'open'
ORDER BY "order_id"
LIMIT 20;
```

| order_id | customer_id | created_at | status |
| --- | --- | --- | --- |
| 301 | 101 | 2026-10-20T11:00:00+00:00 | open |

## 3. Count order_items records for each order_id (up to 20 groups).

```sql
SELECT "order_id", count(*) AS record_count
FROM portfolio."order_items"
GROUP BY "order_id"
ORDER BY record_count DESC, "order_id" NULLS LAST
LIMIT 20;
```

| order_id | record_count |
| --- | --- |
| 301 | 1 |
| 302 | 1 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 1.091 | 1.091, 1.09, 1.093 | Sort → Seq Scan | 131 |
| After index | 0.186 | 0.212, 0.183, 0.186 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 25 |

The median execution time changed from 1.091 ms to 0.186 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=1.061..1.062 rows=20 loops=1)
  Seq Scan on orders (actual time=0.016..1.025 rows=20 loops=1)
Planning Time: 0.414 ms
Execution Time: 1.091 ms
```

### Before index, run 2

```text
Sort (actual time=1.061..1.063 rows=20 loops=1)
  Seq Scan on orders (actual time=0.016..1.026 rows=20 loops=1)
Planning Time: 0.382 ms
Execution Time: 1.09 ms
```

### Before index, run 3

```text
Sort (actual time=1.063..1.064 rows=20 loops=1)
  Seq Scan on orders (actual time=0.015..1.027 rows=20 loops=1)
Planning Time: 0.387 ms
Execution Time: 1.093 ms
```

### After index, run 1

```text
Sort (actual time=0.165..0.167 rows=20 loops=1)
  Bitmap Heap Scan on orders (actual time=0.028..0.097 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.016..0.016 rows=20 loops=1)
Planning Time: 0.585 ms
Execution Time: 0.212 ms
```

### After index, run 2

```text
Sort (actual time=0.136..0.137 rows=20 loops=1)
  Bitmap Heap Scan on orders (actual time=0.027..0.101 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.015..0.015 rows=20 loops=1)
Planning Time: 0.599 ms
Execution Time: 0.183 ms
```

### After index, run 3

```text
Sort (actual time=0.132..0.134 rows=20 loops=1)
  Bitmap Heap Scan on orders (actual time=0.027..0.095 rows=20 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.014..0.015 rows=20 loops=1)
Planning Time: 0.601 ms
Execution Time: 0.186 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run Egonu_Deborah_Onyebuchi_301915997_P2_Queries.sql, then Egonu_Deborah_Onyebuchi_301915997_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/Egonu_Deborah_Onyebuchi_301915997_P2_QueryResults.png) · [Index comparison](screenshots/Egonu_Deborah_Onyebuchi_301915997_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

