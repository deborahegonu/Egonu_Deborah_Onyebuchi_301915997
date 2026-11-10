# Normalisation (NaijaMart)

## Unnormalised starting point
`orders_flat(order_id, order_date, customer_name, customer_email, product_names, category_names, quantities, prices, payment_method, delivery_status)` where `product_names`, `quantities` and `prices` hold several values in one row.

## First normal form (1NF)
Every field must hold one value. Repeating product groups are split so each order line is its own row.

| order_id | customer_email | product | category | qty | price |
|---|---|---|---|---|---|
| 1 | ngozi@example.test | Tecno Spark 20 | Phones | 1 | 145000 |
| 1 | ngozi@example.test | Ankara Shirt | Fashion | 1 | 15000 |

## Second normal form (2NF)
The key is (order_id, product_id). Product name, category and price depend only on `product_id`, and customer details depend only on `order_id`. These partial dependencies are removed into `products`, `orders` and `customers`.

## Third normal form (3NF)
Category name depends on `category_id`, which depends on `product_id` (a transitive dependency). It moves to `categories`. Customer name and email depend on `customer_id`, not on the order, so they live in `customers`.

## Deliberate denormalisation
`order_items.unit_price` and `orders.total_amount` repeat information that could be calculated. They are kept so a past order always shows the price the customer actually paid.
