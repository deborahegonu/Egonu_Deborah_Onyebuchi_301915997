# Portfolio 4: NoSQL and advanced data models

**NaijaMart (simulated Lagos e-commerce platform)** · Deborah Onyebuchi Egonu · Student ID 301915997

## Model
The **product catalogue** moves to MongoDB (document model) and **shopping carts and sessions** to Redis (key-value). Orders, payments and stock stay in PostgreSQL because they need ACID guarantees (polyglot persistence).

### MongoDB product document
```json
{ "sku": "PH-001", "name": "Tecno Spark 20", "category": "Phones", "price": 145000,
  "attributes": { "ram_gb": 8, "storage_gb": 128, "colour": "Black" },
  "reviews": [ { "user": "Ada", "rating": 5 }, { "user": "Tunde", "rating": 4 } ] }
```
A phone, a shirt and a book have different attributes. In the relational model that needs many nullable columns or an attribute table with joins; in a document it is one record. Reviews are embedded because they are read together with the product.

### Redis
```text
HSET cart:customer:1 PH-001 2 SH-001 1     # cart as a hash
EXPIRE cart:customer:1 1800                # abandoned carts disappear after 30 minutes
HGETALL cart:customer:1
SET session:abc123 "customer:1" EX 3600    # login session
ZINCRBY bestsellers 3 PH-001               # sorted-set leaderboard
ZREVRANGE bestsellers 0 4 WITHSCORES
```

## How to run
```bash
mongosh naijamart Egonu_Deborah_Onyebuchi_301915997_P4_MongoDB.js
redis-cli      # paste the commands above
```

## What the script shows
1. Documents with different attribute sets in one collection.
2. Filtering on a nested field (`attributes.ram_gb`).
3. An aggregation pipeline for average rating per category.
4. `$push` to add a review without a join or schema change.
5. `explain("executionStats")` to confirm the compound index on category and price is used.

Schema validation (`$jsonSchema`) keeps the flexibility but still requires sku, name, category and price, and a minimum price of 1.

## Suitability
| Need | Fit |
|---|---|
| Varying product attributes | Documents handle this naturally |
| Fast catalogue reads | One document read, no joins |
| Money and stock updates | Not suited: use PostgreSQL transactions |
| Carts that expire | Redis TTL |

## Status
Run with MongoDB 7 and Redis 7 in Docker; output in the screenshots.”

## Screenshots
 `screenshots/Egonu_Deborah_Onyebuchi_301915997_P4_DocumentsAndQueries_1.png`, `screenshots/Egonu_Deborah_Onyebuchi_301915997_P4_DocumentsAndQueries_2.png`, and `screenshots/Egonu_Deborah_Onyebuchi_301915997_P4_RedisCommands.png`
