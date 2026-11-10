# NaijaMart: design

## Case study
NaijaMart is a simulated Lagos-based online marketplace. **Users:** customers, warehouse staff, delivery agents and administrators. **Major data:** customers, addresses, categories, products, stock, orders, order lines, payments and deliveries. **Key operations:** add products, place an order, update stock, take payment, track delivery, report sales.

## Design decisions
- **Nine tables** in the `naijamart` schema, each describing one thing (3NF).
- **order_items** is a junction table with composite key (order_id, product_id), resolving the many-to-many link between orders and products.
- **unit_price and total_amount are stored on the order** as a price snapshot, so later price changes do not rewrite history. This is a deliberate, documented denormalisation.
- **inventory is separate from products** so frequent stock updates do not lock the product catalogue rows.
- **Constraints enforce business rules in the database:** price > 0, stock >= 0, quantity > 0, status lists, unique email and SKU, one delivery per order.
- **Partial unique index:** a customer can have at most one `pending` order at a time.
