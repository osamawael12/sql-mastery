# 04 - Joins

## Objective

Learn how to combine related data from multiple tables using SQL JOINs.

By the end of this chapter, you should understand:

- Why JOINs are needed
- Primary Key and Foreign Key relationships
- Table aliases
- Qualified column names
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- CROSS JOIN
- Joining more than two tables
- One-to-Many relationships
- Many-to-Many relationships
- Finding unmatched rows
- JOINs with filtering
- JOINs with aggregation
- Row multiplication
- COUNT after JOIN
- Business analysis across multiple tables

---

# Learning Database

```text
SQLMastery
```

# Learning Schema

```text
training
```

---

# Tables Used

This chapter uses the core data model:

```text
customers
orders
order_items
products
```

Relationship:

```text
customers
    1
    |
    +----< orders
              1
              |
              +----< order_items >----+
                                      |
                                      1
                                  products
```

Foreign Keys:

```text
orders.customer_id
    -> customers.customer_id

order_items.order_id
    -> orders.order_id

order_items.product_id
    -> products.product_id
```

---

# 1. Why JOINs?

So far, queries have mostly worked with one table at a time.

For example:

```sql
SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders;
```

This shows:

```text
order_id
customer_id
order_date
```

But a business user may want:

```text
order_id
customer_name
order_date
```

The customer name is stored in another table:

```text
training.customers
```

A JOIN combines the related rows.

---

# 2. Relationship Between Customers and Orders

`customers` contains:

```text
customer_id
customer_name
email
...
```

`orders` contains:

```text
order_id
customer_id
order_date
...
```

The relationship is:

```text
customers.customer_id
        =
orders.customer_id
```

This is the condition used to join the tables.

---

# 3. Primary Key and Foreign Key

A Primary Key identifies a row.

Example:

```text
customers.customer_id
```

A Foreign Key points to a row in another table.

Example:

```text
orders.customer_id
```

Relationship:

```text
customers.customer_id
        PK
         |
         |
         v
orders.customer_id
        FK
```

Understanding these relationships is essential for writing correct JOINs.

---

# 4. Basic JOIN Syntax

General syntax:

```sql
SELECT
    ...
FROM table1
JOIN table2
    ON table1.key = table2.key;
```

Example:

```sql
SELECT
    training.orders.order_id,
    training.customers.customer_name
FROM training.orders
JOIN training.customers
    ON training.orders.customer_id =
       training.customers.customer_id;
```

This works, but repeatedly writing full table names becomes difficult to read.

Table aliases solve that problem.

---

# 5. Table Aliases

Aliases give tables shorter names inside a query.

Example:

```sql
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
```

Now:

```text
o = orders
c = customers
```

A complete query:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
```

Table aliases are extremely common in real SQL.

---

# 6. Qualified Column Names

When multiple tables are involved, prefix columns with their table aliases.

Prefer:

```sql
SELECT
    o.order_id,
    c.customer_name
```

instead of:

```sql
SELECT
    order_id,
    customer_name
```

This improves readability and prevents ambiguity.

For example, both `customers` and `orders` contain:

```text
customer_id
```

Writing:

```sql
SELECT customer_id
```

can become ambiguous.

Use:

```sql
c.customer_id
```

or:

```sql
o.customer_id
```

---

# 7. INNER JOIN

`INNER JOIN` returns rows where the JOIN condition matches in both tables.

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
```

Conceptually:

```text
customers       orders
    match   <->   match
```

Only matched rows are returned.

---

# 8. JOIN vs INNER JOIN

In SQL Server:

```sql
JOIN
```

normally means:

```sql
INNER JOIN
```

These are equivalent:

```sql
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
```

and:

```sql
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
```

Using `INNER JOIN` can make the join type explicit.

---

# 9. INNER JOIN Example

Question:

```text
Which customer placed each order?
```

Query:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```

Now the result contains descriptive customer information instead of only `customer_id`.

---

# 10. One-to-Many JOIN

The relationship between customers and orders is:

```text
customers 1 ----< orders
```

One customer can have multiple orders.

Suppose:

```text
Ahmed
```

has 2 orders.

After joining, Ahmed appears twice:

```text
Ahmed | Order 1
Ahmed | Order 3
```

This is correct.

A JOIN does not guarantee one output row per customer.

The result grain depends on the relationship.

---

# 11. What Is Result Grain?

The grain describes what one output row represents.

Example:

```sql
SELECT
    o.order_id,
    c.customer_name
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
```

One result row represents:

```text
one order
```

because each order belongs to one customer.

Understanding the grain becomes essential when JOINs and aggregation are combined.

---

# 12. LEFT JOIN

`LEFT JOIN` keeps every row from the left table.

Matching rows from the right table are added when they exist.

If there is no match, right-side columns become `NULL`.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
```

All customers are preserved.

That includes customers who have never placed an order.

---

# 13. INNER JOIN vs LEFT JOIN

`INNER JOIN`:

```text
Return matched rows only.
```

`LEFT JOIN`:

```text
Return every left-side row,
plus matching right-side rows.
```

Question:

```text
Show customers who placed orders.
```

Use:

```text
INNER JOIN
```

Question:

```text
Show all customers, including customers with no orders.
```

Use:

```text
LEFT JOIN
```

The required business result determines the join type.

---

# 14. Finding Unmatched Rows

A common pattern is:

```text
Find customers who never placed an order.
```

Use a LEFT JOIN:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

Why?

Customers without an order still survive the `LEFT JOIN`.

Their order columns become:

```text
NULL
```

Therefore:

```sql
WHERE o.order_id IS NULL
```

identifies unmatched customers.

This is often called an anti-join pattern.

---

# 15. RIGHT JOIN

`RIGHT JOIN` preserves every row from the right table.

Example:

```sql
SELECT
    c.customer_name,
    o.order_id
FROM training.orders AS o
RIGHT JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
```

Conceptually this can usually be rewritten as a LEFT JOIN by reversing the table order.

For readability, many teams prefer LEFT JOIN.

Example:

```sql
SELECT
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
```

These express the idea more naturally:

```text
Keep all customers.
```

---

# 16. FULL OUTER JOIN

`FULL OUTER JOIN` preserves rows from both sides.

It returns:

```text
Matched rows

Unmatched left rows

Unmatched right rows
```

Syntax:

```sql
SELECT
    ...
FROM table1 AS a
FULL OUTER JOIN table2 AS b
    ON a.key = b.key;
```

With strong Foreign Key constraints, some unmatched situations may be impossible in the training database, but understanding the join type is still useful.

---

# 17. CROSS JOIN

`CROSS JOIN` creates every possible combination of rows.

Example:

```sql
SELECT
    c.customer_name,
    p.product_name
FROM training.customers AS c
CROSS JOIN training.products AS p;
```

If there are:

```text
5 customers
5 products
```

the result contains:

```text
5 * 5 = 25 rows
```

This is called a Cartesian product.

Use `CROSS JOIN` intentionally.

---

# 18. Accidental Cartesian Products

A missing or incorrect join condition can produce far more rows than expected.

For example, a Cartesian combination between:

```text
5 customers
5 products
```

creates:

```text
25 combinations
```

Larger production tables can create millions or billions of combinations.

Always understand the relationship being joined.

---

# 19. Joining Orders and Order Items

Relationship:

```text
orders.order_id
    =
order_items.order_id
```

Query:

```sql
SELECT
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
```

One order can have multiple order items.

Therefore an order may appear on multiple rows.

---

# 20. Joining Order Items and Products

Relationship:

```text
order_items.product_id
    =
products.product_id
```

Query:

```sql
SELECT
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.order_items AS oi
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id;
```

Now the query returns `product_name` instead of only `product_id`.

---

# 21. Joining Three Tables

We can move through the data model:

```text
customers
    ->
orders
    ->
order_items
```

Example:

```sql
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
```

One result row now represents:

```text
one order-item line
```

not one customer and not one order.

---

# 22. Joining Four Tables

Full sales detail:

```sql
SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id;
```

Now we can see:

```text
Who bought
What product
In which order
When
How many units
At what price
```

This is the foundation of sales analysis.

---

# 23. Many-to-Many Relationship

Orders and products have a many-to-many relationship.

```text
One order can contain many products.

One product can appear in many orders.
```

The relationship is resolved by:

```text
order_items
```

Model:

```text
orders
   1
   |
   +----< order_items >----+
                           |
                           1
                       products
```

To connect orders to products:

```sql
FROM training.orders AS o
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id
```

---

# 24. JOIN with WHERE

JOINs can be combined with filtering.

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed';
```

The JOIN combines tables.

The WHERE clause filters the resulting logical rows.

---

# 25. Completed Sales Detail

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';
```

This allows business filtering across related tables.

---

# 26. Calculated Columns After JOIN

We can calculate line revenue:

```text
quantity * unit_price
```

Example:

```sql
SELECT
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM training.orders AS o
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id;
```

---

# 27. JOIN + GROUP BY

JOINs become very powerful when combined with aggregation.

Question:

```text
How many orders did each customer place?
```

Query:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;
```

The `LEFT JOIN` preserves customers with zero orders.

---

# 28. Why COUNT(o.order_id), Not COUNT(*)?

This distinction is extremely important with LEFT JOIN.

Consider a customer with no orders.

After the LEFT JOIN, SQL still produces a customer row with:

```text
o.order_id = NULL
```

If we use:

```sql
COUNT(*)
```

that preserved row is counted.

The customer may incorrectly appear to have:

```text
1 order
```

Instead:

```sql
COUNT(o.order_id)
```

ignores the NULL order ID.

Correct:

```sql
COUNT(o.order_id) AS order_count
```

This produces:

```text
0
```

for customers with no orders.

---

# 29. Customer Spending

Question:

```text
How much has each customer spent?
```

We need:

```text
customers
orders
order_items
```

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name;
```

This currently includes order-item values from all order statuses.

Business logic may require completed orders only.

---

# 30. Completed Customer Spending

For recognized completed sales:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC;
```

Notice that defining the business metric matters as much as writing valid SQL.

---

# 31. Product Performance

Question:

```text
How many units of each product appear in order items?
```

Now that JOINs are available, we can return product names:

```sql
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units
FROM training.products AS p
JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_units DESC;
```

---

# 32. Product Revenue

```sql
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS sales_value
FROM training.products AS p
JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY sales_value DESC;
```

Again, whether cancelled orders should count depends on the business definition.

---

# 33. Row Multiplication

JOINs can multiply rows.

Suppose:

```text
Customer Ahmed
    Order 1
        Item A
        Item B

    Order 2
        Item C
```

Joining:

```text
customers
orders
order_items
```

produces:

```text
Ahmed | Order 1 | Item A
Ahmed | Order 1 | Item B
Ahmed | Order 2 | Item C
```

Ahmed appears three times.

This is expected because the result grain is:

```text
one order-item line
```

---

# 34. Why Row Multiplication Matters

Suppose you join customers to orders to order_items and write:

```sql
COUNT(o.order_id)
```

This may count order-item rows rather than unique orders.

An order containing three items appears three times.

If the business question is:

```text
How many different orders did each customer place?
```

you may need:

```sql
COUNT(DISTINCT o.order_id)
```

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name;
```

Always check the grain before counting.

---

# 35. COUNT After JOIN

These can answer different questions:

```sql
COUNT(*)
COUNT(o.order_id)
COUNT(DISTINCT o.order_id)
COUNT(oi.order_item_id)
SUM(oi.quantity)
```

Possible meanings:

```text
COUNT(*)
    Result rows

COUNT(o.order_id)
    Non-NULL order IDs across result rows

COUNT(DISTINCT o.order_id)
    Different orders

COUNT(oi.order_item_id)
    Order-item lines

SUM(oi.quantity)
    Units
```

Choosing the correct metric is essential.

---

# 36. LEFT JOIN and WHERE Trap

Consider:

```sql
SELECT
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed';
```

Although the syntax contains a LEFT JOIN, the `WHERE` condition rejects rows where:

```text
o.order_status = NULL
```

Therefore customers with no orders disappear.

For this specific result, it can behave similarly to an INNER JOIN.

---

# 37. Filtering the Right Table in ON

Sometimes you want:

```text
All customers,
plus their Completed orders if they have any.
```

Then place the right-table filter in `ON`:

```sql
SELECT
    c.customer_name,
    o.order_id,
    o.order_status
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed';
```

Now every customer is preserved.

This distinction is very important.

---

# 38. ON vs WHERE with LEFT JOIN

These are not always equivalent.

Query A:

```sql
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
```

Customers without completed orders are removed.

Query B:

```sql
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
```

All customers remain.

The location of the condition changes the result.

---

# 39. Find Customers Without Completed Orders

This is a useful pattern:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
WHERE o.order_id IS NULL;
```

This means:

```text
Keep all customers.

Try to match Completed orders only.

Then keep customers where no such order matched.
```

---

# 40. LEFT JOIN Aggregation

Count completed orders per customer while keeping all customers:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS completed_order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_order_count DESC;
```

Customers with no completed orders correctly receive:

```text
0
```

---

# 41. Product Sales Including Unsold Products

If we use INNER JOIN:

```sql
FROM products p
JOIN order_items oi
```

products with no order items disappear.

To keep all products:

```sql
SELECT
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) AS order_line_count
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name;
```

Unsold products receive:

```text
0
```

for `order_line_count`.

---

# 42. NULL Totals with LEFT JOIN

Consider:

```sql
SUM(oi.quantity)
```

For a product with no matching order items, the result may be:

```text
NULL
```

rather than:

```text
0
```

Later we will study null-handling functions in more detail.

In SQL Server, a common solution is:

```sql
COALESCE(SUM(oi.quantity), 0)
```

Example:

```sql
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS total_units
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name;
```

For now, understand the reason for the `NULL`.

---

# 43. Joining on the Correct Keys

Correct:

```sql
ON o.customer_id = c.customer_id
```

Incorrect logic could be:

```sql
ON o.order_id = c.customer_id
```

SQL Server may accept an incorrect relationship if the data types are compatible.

Valid SQL syntax does not guarantee correct business logic.

Always know:

```text
What relationship am I joining?
```

---

# 44. Do Not Join on Descriptive Text When a Key Exists

Prefer:

```sql
ON o.customer_id = c.customer_id
```

Do not invent relationships like:

```sql
ON c.customer_name = ...
```

Names and descriptions may:

```text
Repeat
Change
Contain spelling differences
```

Keys exist to identify and relate records reliably.

---

# 45. Aliasing Conventions

Short, predictable aliases improve readability.

Examples:

```text
c   customers
o   orders
oi  order_items
p   products
```

Example:

```sql
SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    oi.quantity
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id;
```

---

# 46. Business Example - Customer Orders

Question:

```text
Show every order with the customer's name.
```

Query:

```sql
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date;
```

---

# 47. Business Example - Sales Detail

Question:

```text
Show the detailed contents of completed orders.
```

Query:

```sql
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
ORDER BY
    o.order_id,
    p.product_name;
```

---

# 48. Business Example - Customer Revenue

Question:

```text
Which customers generated the most completed revenue?
```

Query:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY revenue DESC;
```

---

# 49. Business Example - Product Performance

Question:

```text
Which products generated the most completed sales value?
```

Query:

```sql
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.products AS p
JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
JOIN training.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY revenue DESC;
```

---

# 50. Business Example - Customers with No Orders

```sql
SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

This is a common retention, activation, and marketing query pattern.

---

# 51. Business Example - Products Never Ordered

```sql
SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;
```

This finds products with no matching order items.

---

# 52. Result Grain Checklist

Before aggregating a joined result, ask:

```text
What does one row represent after the JOIN?
```

Possible grains:

```text
One customer

One order

One order-item line

One product

One customer-product combination
```

Then ask:

```text
What do I want to count?
```

For example:

```text
Rows?
Distinct orders?
Order lines?
Units?
Customers?
Products?
```

This prevents many analytical mistakes.

---

# 53. JOIN Checklist

Before writing a JOIN:

```text
1. What business question am I answering?

2. Which tables contain the required columns?

3. How are those tables related?

4. What are the PK and FK columns?

5. Which table should be preserved?

6. Do I need INNER JOIN or LEFT JOIN?

7. What should one result row represent?

8. Could the JOIN multiply rows?

9. If I aggregate, am I counting rows or entities?

10. Are filters on the right side of a LEFT JOIN
    supposed to remove unmatched rows?
```

---

# 54. Common Mistakes

Common JOIN mistakes include:

```text
Joining on the wrong columns

Forgetting the join condition

Using INNER JOIN when unmatched rows are required

Using COUNT(*) after a LEFT JOIN when COUNT(key) is needed

Counting orders after joining to order_items without DISTINCT

Filtering the right side of a LEFT JOIN in WHERE unintentionally

Assuming one JOIN means one output row per original entity

Using descriptive text instead of keys

Not qualifying ambiguous column names
```

---

# 55. Logical Query Processing with JOIN

For the concepts learned so far, think approximately:

```text
1. FROM / JOIN / ON
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. DISTINCT
7. ORDER BY
8. TOP
```

JOINs are conceptually part of building the source rowset before `WHERE`.

This becomes important when reasoning about LEFT JOIN behavior.

---

# 56. Final Mental Model

The core model now becomes:

```text
customers
    |
    | customer_id
    v
orders
    |
    | order_id
    v
order_items
    |
    | product_id
    v
products
```

When asked:

```text
Who purchased which products?
```

follow the path:

```text
customers
-> orders
-> order_items
-> products
```

When asked:

```text
How much did each customer spend?
```

follow:

```text
customers
-> orders
-> order_items
-> SUM(quantity * unit_price)
```

When asked:

```text
How many orders did each customer place?
```

you may only need:

```text
customers
-> orders
```

Do not JOIN tables that are unnecessary for the question.

---

# Chapter Summary

After completing this chapter, you should understand:

```text
INNER JOIN
LEFT JOIN
RIGHT JOIN
FULL OUTER JOIN
CROSS JOIN

ON

Table aliases
Qualified columns

Primary Key / Foreign Key joins

One-to-Many joins
Many-to-Many joins

Multiple JOINs

Finding unmatched rows

JOIN + WHERE

JOIN + GROUP BY

JOIN + HAVING

COUNT after JOIN

COUNT(DISTINCT ...)

Row multiplication

LEFT JOIN filtering behavior

Result grain
```

---

# Chapter Files

```text
04_joins/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to answer questions such as:

```text
Which customer placed each order?

What products are inside each order?

Who purchased each product?

How many orders did each customer place?

Which customers have never ordered?

Which products have never been ordered?

How much has each customer spent?

Which products sold the most units?

Which products generated the most revenue?

How do LEFT JOIN filters change the result?

Why can JOINs cause duplicate-looking rows?
```

The key principle is:

```text
Before counting or aggregating a JOIN,
understand what one joined row represents.
```