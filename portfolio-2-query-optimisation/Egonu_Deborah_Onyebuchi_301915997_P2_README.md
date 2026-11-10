# Portfolio 2: Query processing and optimisation

**NaijaMart (simulated Lagos e-commerce platform)** · Deborah Onyebuchi Egonu · Student ID 301915997

## Files
- `Egonu_Deborah_Onyebuchi_301915997_P2_Queries.sql`: four queries on the sample data (join, aggregate, window function, anti-join).
- `Egonu_Deborah_Onyebuchi_301915997_P2_Optimisation.sql`: loads 200,000 synthetic orders (600,000 order lines), records plans before and after indexing.
- `plans.txt`: raw EXPLAIN ANALYZE output from my run

## Queries on the sample data
```text
 order_id |   full_name   |          product          | quantity | unit_price 
----------+---------------+---------------------------+----------+------------
        1 | Ngozi Adeyemi | Tecno Spark 20            |        1 |  145000.00
        1 | Ngozi Adeyemi | Ankara Shirt              |        1 |   15000.00
        2 | Tunde Bakare  | Database Systems Concepts |        2 |   32000.00
        3 | Amina Yusuf   | Ankara Shirt              |        1 |   15000.00
(4 rows)

 category |  revenue  
----------+-----------
 Phones   | 145000.00
 Books    |  64000.00
 Fashion  |  15000.00
(3 rows)

 state |   full_name   |   spend   | rank_in_state 
-------+---------------+-----------+---------------
 FCT   | Amina Yusuf   |  15000.00 |             1
 Lagos | Ngozi Adeyemi | 160000.00 |             1
 Lagos | Tunde Bakare  |  64000.00 |             2
(3 rows)

  sku   |    name    
--------+------------
 PH-002 | Phone Case
(1 row)
```
Q1 joins four tables. Q2 sums paid, shipped and delivered revenue per category. Q3 ranks customers by spend inside each state with `rank() OVER (PARTITION BY ...)`. Q4 uses `NOT EXISTS` to find the product that has never been ordered (PH-002 Phone Case).

## Optimisation
Two indexes were added after the baseline plans: `idx_orders_customer_created ON orders(customer_id, created_at)` and `idx_order_items_product ON order_items(product_id)`. PostgreSQL does not index foreign-key columns automatically, which is why both queries began with sequential scans.

| Query | Plan before | Time before | Plan after | Time after |
|---|---|---|---|---|
| One customer's orders in 90 days | Parallel Seq Scan, 66,666 rows removed per worker | 19.570 ms | Bitmap Index Scan on the composite index | 0.067 ms |
| Units sold per product (correlated subquery) | Seq Scan of order_items 2,000 times | 30,002 ms | Bitmap Index Scan per product | 328 ms |

### Plans (before)
```text
QUERY PLAN                                        
-----------------------------------------------------------------------------------------
 Gather (actual time=11.305..19.550 rows=1 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   Buffers: shared hit=3441
   ->  Parallel Seq Scan on orders (actual time=4.287..5.841 rows=0 loops=3)
         Filter: ((customer_id = 4321) AND (created_at > (now() - '90 days'::interval)))
         Rows Removed by Filter: 66666
         Buffers: shared hit=3441
 Planning:
   Buffers: shared hit=42
 Planning Time: 0.248 ms
 Execution Time: 19.570 ms
(12 rows)
```
### Plans (after)
```text
QUERY PLAN                                            
--------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on orders (actual time=0.053..0.055 rows=1 loops=1)
   Recheck Cond: ((customer_id = 4321) AND (created_at > (now() - '90 days'::interval)))
   Heap Blocks: exact=1
   Buffers: shared hit=4 read=3
   ->  Bitmap Index Scan on idx_orders_customer_created (actual time=0.041..0.041 rows=1 loops=1)
         Index Cond: ((customer_id = 4321) AND (created_at > (now() - '90 days'::interval)))
         Buffers: shared hit=3 read=3
 Planning:
   Buffers: shared hit=22 read=1
 Planning Time: 0.262 ms
 Execution Time: 0.067 ms
(11 rows)
```

## Performance analysis
Without an index, the planner has to read every row of `orders` to find one customer's few rows, so cost grows with table size. The composite index on (customer_id, created_at) lets it jump to the customer and then filter by date, which cut execution time by roughly 290 times (19.570/0.067 ≈ 292). For the subquery, the index removed the repeated full scans, giving about a 90 times (30,002/328 ≈ 91) speed-up; rewriting it as a join with GROUP BY would be faster still. The trade-off is that every index uses disk space and makes inserts and updates slightly slower, so only indexes matching real query patterns should be created.

Timings come from a single run on my own machine (PostgreSQL 16 in Docker) and will differ on other machines; the plan shapes (Seq Scan to Index Scan) are what matter.

## Screenshots
`screenshots/Egonu_Deborah_Onyebuchi_301915997_P2_QueryResults.png` and `screenshots/Egonu_Deborah_Onyebuchi_301915997_P2_IndexComparison.png`. Full output is in `plans.txt`
