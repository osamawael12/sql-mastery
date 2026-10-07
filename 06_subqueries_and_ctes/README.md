# 06 - Subqueries and CTEs

## Objective

Learn how to break complex SQL problems into smaller queries using:

- Scalar Subqueries
- Multi-row Subqueries
- IN with Subqueries
- EXISTS
- NOT EXISTS
- Correlated Subqueries
- Derived Tables
- Common Table Expressions (CTEs)
- Multiple CTEs
- Aggregation inside CTEs
- CTEs with JOINs
- CTEs for business analysis

These techniques make complex analytical queries easier to build, understand, and maintain.

---

# Learning Database

```text
SQLMastery
```

# Learning Schema

```text
training
```

# Tables Used

```text
training.customers
training.products
training.orders
training.order_items
```

Core relationship:

```text
customers
    |
    +----< orders
              |
              +----< order_items >---- products
```

---

# 1. What Is a Subquery?

A subquery is a query inside another query.

Example:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
);
```

The inner query calculates:

```text
average product price
```

The outer query returns:

```text
products above that average
```

---

# 2. Inner Query and Outer Query

Consider:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
);
```

Inner query:

```sql
SELECT AVG(price)
FROM training.products;
```

Outer query:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price > ...;
```

Conceptually:

```text
1. Calculate the average price
2. Compare each product against that value
```

---

# 3. Scalar Subquery

A scalar subquery returns exactly one value.

Example:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
);
```

This subquery:

```sql
SELECT AVG(price)
FROM training.products
```

returns one value.

Therefore it can be used with:

```text
=
<>
>
>=
<
<=
```

---

# 4. Scalar Subquery in SELECT

A subquery can also appear in the SELECT list.

Example:

```sql
SELECT
    product_name,
    price,
    (
        SELECT AVG(price)
        FROM training.products
    ) AS overall_average_price
FROM training.products;
```

The overall average appears beside every product.

---

# 5. Comparing Against MAX

Find products with the highest price:

```sql
SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price =
(
    SELECT MAX(price)
    FROM training.products
);
```

Unlike:

```sql
TOP (1)
```

this naturally returns all products tied at the maximum price.

---

# 6. Comparing Against MIN

```sql
SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price =
(
    SELECT MIN(price)
    FROM training.products
);
```

This returns the cheapest product or products.

---

# 7. Multi-Row Subqueries

Not every subquery returns one value.

Example:

```sql
SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed';
```

This may return multiple rows.

Therefore this is not suitable:

```sql
customer_id =
(
    multi-row subquery
)
```

Instead, operators such as `IN` may be appropriate.

---

# 8. IN with a Subquery

Question:

```text
Which customers have a Completed order?
```

Query:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
);
```

The subquery returns a set of customer IDs.

The outer query finds customers whose ID belongs to that set.

---

# 9. NOT IN with a Subquery

Conceptually:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM training.orders
);
```

This can find customers without orders when the subquery column is guaranteed not to contain NULL.

However, `NOT IN` has an important NULL trap.

---

# 10. NOT IN and NULL

Suppose a subquery returns:

```text
1
2
NULL
```

Then:

```sql
value NOT IN (1, 2, NULL)
```

can evaluate to UNKNOWN rather than TRUE for values you expected to return.

For this reason, when testing absence against another table:

```text
NOT EXISTS
```

is often safer and clearer.

---

# 11. EXISTS

`EXISTS` checks whether a subquery returns at least one row.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

Meaning:

```text
Return the customer if at least one matching order exists.
```

---

# 12. Why SELECT 1 in EXISTS?

Inside `EXISTS`, SQL cares whether a row exists.

It does not need actual column output.

Therefore this common pattern is used:

```sql
EXISTS
(
    SELECT 1
    FROM ...
    WHERE ...
)
```

The `1` is not the value being compared.

It simply expresses:

```text
Does a matching row exist?
```

---

# 13. EXISTS with Business Conditions

Find customers with at least one Completed order:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);
```

---

# 14. NOT EXISTS

`NOT EXISTS` returns outer rows for which no matching subquery row exists.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

This returns customers with no orders.

---

# 15. NOT EXISTS for Business Questions

Question:

```text
Which customers have never placed a Completed order?
```

Query:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);
```

This includes:

```text
Customers with no orders

Customers with orders but no Completed orders
```

---

# 16. Correlated Subquery

A correlated subquery refers to a column from the outer query.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

The inner query references:

```sql
c.customer_id
```

from the outer query.

That makes it correlated.

---

# 17. Correlated Scalar Subquery

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS order_count
FROM training.customers AS c;
```

For each customer, the subquery calculates that customer's order count.

---

# 18. Correlated Aggregate Example

Question:

```text
How many Completed orders does each customer have?
```

```sql
SELECT
    c.customer_id,
    c.customer_name,
    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    ) AS completed_order_count
FROM training.customers AS c;
```

Every customer remains in the result.

---

# 19. Subquery vs JOIN

Many problems can be solved in multiple ways.

Using `EXISTS`:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

Using JOIN:

```sql
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
```

Both can answer:

```text
Which customers have orders?
```

But they express different intent.

`EXISTS` asks:

```text
Does a matching row exist?
```

A JOIN combines rows from both tables.

---

# 20. Avoid Unnecessary JOIN Multiplication

Suppose you only need to answer:

```text
Does this customer have an order?
```

A JOIN may create multiple result rows for customers with multiple orders.

Then you may need:

```sql
DISTINCT
```

`EXISTS` naturally expresses the existence test without returning the child rows.

---

# 21. Products That Were Ordered

Using EXISTS:

```sql
SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.product_id = p.product_id
);
```

---

# 22. Products Never Ordered

```sql
SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.product_id = p.product_id
);
```

This is a clean anti-join pattern.

---

# 23. Nested Business Logic

Question:

```text
Which products appeared in Completed orders?
```

One approach:

```sql
SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
);
```

The subquery itself can contain JOINs.

---

# 24. Derived Tables

A derived table is a subquery inside the `FROM` clause.

Example:

```sql
SELECT
    x.order_id,
    x.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS x;
```

The subquery creates a temporary logical result.

The outer query reads from it like a table.

---

# 25. Derived Table Requires an Alias

In SQL Server, a derived table needs an alias.

Correct:

```sql
FROM
(
    SELECT ...
) AS x
```

The alias allows the outer query to reference its columns.

---

# 26. Filtering an Aggregated Derived Table

Question:

```text
Which orders are worth at least 3000?
```

```sql
SELECT
    x.order_id,
    x.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS x
WHERE x.order_value >= 3000
ORDER BY x.order_value DESC;
```

This is an alternative to using `HAVING`.

---

# 27. Joining a Derived Table

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    totals.order_value
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
JOIN
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
    ON o.order_id = totals.order_id;
```

The derived table first reduces `order_items` to:

```text
one row per order
```

Then the result is joined.

---

# 28. Pre-Aggregation Before JOIN

Pre-aggregation can help control result grain.

Instead of immediately joining detailed `order_items`, first create:

```text
one row per order
```

Example:

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id;
```

Then join that summarized result to `orders`.

This reduces accidental row multiplication.

---

# 29. What Is a CTE?

CTE means:

```text
Common Table Expression
```

A CTE creates a named query result that can be referenced by the statement immediately following it.

Basic syntax:

```sql
WITH cte_name AS
(
    SELECT ...
)
SELECT *
FROM cte_name;
```

---

# 30. Basic CTE

Example:

```sql
WITH ExpensiveProducts AS
(
    SELECT
        product_id,
        product_name,
        price
    FROM training.products
    WHERE price >= 5000
)
SELECT
    product_id,
    product_name,
    price
FROM ExpensiveProducts;
```

---

# 31. CTE Scope

A CTE normally exists only for the single statement immediately following it.

Example:

```sql
WITH ExpensiveProducts AS
(
    SELECT *
    FROM training.products
)
SELECT *
FROM ExpensiveProducts;
```

After that statement finishes, you cannot run:

```sql
SELECT *
FROM ExpensiveProducts;
```

as a separate statement.

A CTE is not a permanent table.

---

# 32. Semicolon Before WITH

In T-SQL, it is good practice to begin a CTE with:

```sql
;WITH
```

Example:

```sql
;WITH ProductData AS
(
    SELECT
        product_id,
        product_name
    FROM training.products
)
SELECT *
FROM ProductData;
```

The semicolon ensures the previous T-SQL statement is terminated before `WITH`.

---

# 33. CTE with Aggregation

Example:

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    order_id,
    order_value
FROM OrderTotals
ORDER BY order_value DESC;
```

This is conceptually similar to a derived table, but the named structure can improve readability.

---

# 34. CTE + Filtering

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    order_id,
    order_value
FROM OrderTotals
WHERE order_value >= 3000
ORDER BY order_value DESC;
```

---

# 35. CTE + JOIN

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.customer_name,
    o.order_status,
    ot.order_value
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id
ORDER BY ot.order_value DESC;
```

---

# 36. Why CTEs Are Useful

CTEs are useful for:

```text
Breaking large queries into stages

Naming intermediate results

Improving readability

Pre-aggregating data

Separating business logic

Avoiding deeply nested derived tables
```

They do not automatically make a query faster.

The main benefit is often clarity and structure.

---

# 37. Multiple CTEs

A query can define multiple CTEs.

Syntax:

```sql
;WITH FirstCTE AS
(
    ...
),
SecondCTE AS
(
    ...
)
SELECT ...
```

Notice:

```text
WITH appears once

CTEs are separated by commas
```

---

# 38. Multiple CTE Example

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id,
        order_date
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    co.order_id,
    co.customer_id,
    co.order_date,
    ot.order_value
FROM CompletedOrders AS co
JOIN OrderTotals AS ot
    ON co.order_id = ot.order_id;
```

---

# 39. CTE Depending on an Earlier CTE

A later CTE can reference an earlier CTE.

Example:

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
HighValueOrders AS
(
    SELECT
        order_id,
        order_value
    FROM OrderTotals
    WHERE order_value >= 3000
)
SELECT *
FROM HighValueOrders;
```

This creates a pipeline:

```text
Raw data
-> Order totals
-> High-value orders
-> Final result
```

---

# 40. CTE Pipeline Thinking

Complex business questions can be decomposed into stages.

For example:

```text
Stage 1:
Calculate value of every order.

Stage 2:
Keep Completed orders.

Stage 3:
Connect orders to customers.

Stage 4:
Aggregate customer revenue.

Stage 5:
Keep high-value customers.
```

CTEs allow these stages to be named.

---

# 41. Customer Revenue with CTEs

Example:

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CustomerRevenue AS
(
    SELECT
        co.customer_id,
        SUM(ot.order_value) AS revenue
    FROM CompletedOrders AS co
    JOIN OrderTotals AS ot
        ON co.order_id = ot.order_id
    GROUP BY co.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM CustomerRevenue AS cr
JOIN training.customers AS c
    ON cr.customer_id = c.customer_id
ORDER BY cr.revenue DESC;
```

Each CTE has a clear purpose.

---

# 42. Why Pre-Aggregation Helps Reasoning

Without pre-aggregation:

```text
orders
JOIN order_items
```

produces one row per order item.

With:

```text
OrderTotals
```

we first reduce `order_items` to:

```text
one row per order
```

Then joining to orders preserves a simpler grain:

```text
one row per order
```

This makes later calculations easier to reason about.

---

# 43. Product Performance CTE

```sql
;WITH ProductSales AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.order_items AS oi
    JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    ps.units_sold,
    ps.revenue
FROM ProductSales AS ps
JOIN training.products AS p
    ON ps.product_id = p.product_id
ORDER BY ps.revenue DESC;
```

---

# 44. CTE vs Derived Table

Derived table:

```sql
SELECT *
FROM
(
    SELECT ...
) AS x;
```

CTE:

```sql
;WITH x AS
(
    SELECT ...
)
SELECT *
FROM x;
```

Both can represent intermediate query results.

CTEs often become easier to read when:

```text
There are multiple stages

Intermediate results need meaningful names

Nested subqueries become difficult to follow
```

---

# 45. CTE vs Temporary Table

A CTE is not the same as a temporary table.

CTE:

```text
Logical query expression
Scoped to one statement
Does not automatically materialize/store a reusable dataset
```

Temporary table:

```text
Created as an actual temporary database object
Can be referenced across multiple statements in its scope
Can have indexes
```

Temporary tables are covered later when appropriate.

---

# 46. CTE Does Not Mean Cached Result

A common misconception is:

```text
The CTE runs once and stores the result automatically.
```

Do not assume that.

A CTE primarily provides a named query expression.

SQL Server's optimizer determines how the overall query is executed.

---

# 47. EXISTS vs IN

Both can sometimes answer the same question.

IN:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
);
```

EXISTS:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

`EXISTS` often expresses relationship existence naturally.

Performance depends on the actual query, data, indexes, and execution plan; do not rely on simplistic rules such as "EXISTS is always faster."

---

# 48. NOT EXISTS vs NOT IN

For anti-matching logic, prefer understanding the NULL behavior.

Potential issue:

```sql
WHERE id NOT IN
(
    SELECT nullable_column
    FROM ...
)
```

If the subquery contains NULL, results may be surprising.

`NOT EXISTS` avoids that specific NULL-list problem:

```sql
WHERE NOT EXISTS
(
    SELECT 1
    FROM ...
    WHERE inner.key = outer.key
)
```

---

# 49. Above-Average Products

Business question:

```text
Which products cost more than the overall average?
```

```sql
SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
)
ORDER BY price DESC;
```

Classic scalar subquery pattern.

---

# 50. Customers Above Average Order Count

This problem needs multiple stages.

First calculate order count per customer:

```sql
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY customer_id;
```

Then calculate the average of those customer counts.

A CTE makes this easier:

```sql
;WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM training.orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    order_count
FROM CustomerOrders
WHERE order_count >
(
    SELECT AVG(1.0 * order_count)
    FROM CustomerOrders
);
```

The same CTE can be referenced from the outer query and its scalar subquery within the single statement.

---

# 51. Why 1.0 * order_count?

`order_count` is an integer.

Using:

```sql
AVG(order_count)
```

can produce integer-oriented type behavior depending on the expression type.

Using:

```sql
AVG(1.0 * order_count)
```

forces decimal arithmetic.

This preserves a more useful average.

---

# 52. Comparing Within a Category

A correlated subquery can compare each product against the average of its own category.

```sql
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM training.products AS p
WHERE p.price >
(
    SELECT AVG(p2.price)
    FROM training.products AS p2
    WHERE p2.category = p.category
);
```

This is different from comparing to the overall average.

For each product:

```text
Find average price of that product's category

Compare product price against that average
```

---

# 53. Correlation Matters

Inside:

```sql
WHERE p2.category = p.category
```

`p2` belongs to the inner query.

`p` belongs to the outer query.

That relationship makes the subquery correlated.

---

# 54. Customers Whose Spending Exceeds a Threshold

Using a CTE:

```sql
;WITH CustomerSpending AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS spending
    FROM training.orders AS o
    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cs.spending
FROM CustomerSpending AS cs
JOIN training.customers AS c
    ON cs.customer_id = c.customer_id
WHERE cs.spending >= 3000
ORDER BY cs.spending DESC;
```

---

# 55. CTE with Conditional Aggregation

CTEs can contain the transformations learned in Chapter 05.

```sql
;WITH CustomerOrderMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT *
FROM CustomerOrderMetrics;
```

---

# 56. Layered Business Logic

Suppose we want:

```text
Customers with:
- At least 2 orders
- At least 1 Completed order
```

We can first calculate metrics:

```sql
;WITH CustomerOrderMetrics AS
(
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders
    FROM training.customers AS c
    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT
    customer_id,
    total_orders,
    completed_orders
FROM CustomerOrderMetrics
WHERE total_orders >= 2
  AND completed_orders >= 1;
```

The final filter becomes simple because the complex metrics already have names.

---

# 57. Naming CTEs

Prefer names that explain what the result represents.

Good:

```text
OrderTotals
CompletedOrders
CustomerRevenue
ProductSales
MonthlyRevenue
```

Less useful:

```text
cte1
cte2
data
x
```

Clear naming is especially important in multi-stage analytical queries.

---

# 58. Common Mistake - Scalar Subquery Returns Multiple Rows

Incorrect:

```sql
WHERE customer_id =
(
    SELECT customer_id
    FROM training.orders
)
```

If multiple customer IDs are returned, SQL Server raises an error.

Possible alternatives include:

```text
IN
EXISTS
JOIN
```

depending on the intended logic.

---

# 59. Common Mistake - Forgetting Correlation

Suppose the goal is:

```text
Count each customer's orders.
```

Correct:

```sql
SELECT
    c.customer_name,
    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS order_count
FROM training.customers AS c;
```

Without:

```sql
WHERE o.customer_id = c.customer_id
```

the subquery would count all orders for every customer.

---

# 60. Common Mistake - Using a CTE Outside Its Scope

This works:

```sql
;WITH X AS
(
    SELECT *
    FROM training.products
)
SELECT *
FROM X;
```

This later standalone query does not:

```sql
SELECT *
FROM X;
```

The CTE's scope has ended.

---

# 61. Common Mistake - Multiple WITH Keywords

Incorrect concept:

```sql
WITH A AS (...)
WITH B AS (...)
SELECT ...
```

Correct:

```sql
;WITH A AS
(
    ...
),
B AS
(
    ...
)
SELECT ...
```

---

# 62. Common Mistake - CTE Without Final Statement

A CTE must be followed by a statement that uses it.

Do not stop at:

```sql
;WITH OrderTotals AS
(
    SELECT ...
)
```

Follow it immediately with the query:

```sql
SELECT *
FROM OrderTotals;
```

---

# 63. Subquery / CTE Selection Guide

Use a scalar subquery when you need:

```text
One value used in a comparison
```

Example:

```text
Products above average price
```

Use EXISTS when you need:

```text
Does a related row exist?
```

Example:

```text
Customers with Completed orders
```

Use NOT EXISTS when you need:

```text
No related row exists
```

Example:

```text
Customers without orders
```

Use a derived table when:

```text
A compact intermediate result fits naturally in FROM
```

Use a CTE when:

```text
The problem has clear stages
The intermediate result deserves a name
The query is becoming hard to read
```

These are guidelines, not absolute rules.

---

# 64. Business Problem Decomposition

Question:

```text
Which customers generated more Completed revenue
than the average revenue among customers who generated
Completed revenue?
```

Break it down:

```text
1. Calculate Completed revenue per customer.

2. Calculate average customer revenue.

3. Keep customers above that average.

4. Join customer IDs to customer names.

5. Sort highest revenue first.
```

CTE:

```sql
;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM CustomerRevenue AS cr
JOIN training.customers AS c
    ON cr.customer_id = c.customer_id
WHERE cr.revenue >
(
    SELECT AVG(revenue)
    FROM CustomerRevenue
)
ORDER BY cr.revenue DESC;
```

This combines:

```text
CTE
JOIN
Aggregation
Scalar subquery
```

---

# 65. Final Mental Model

Subquery:

```text
A query inside another query.
```

Scalar subquery:

```text
Returns one value.
```

IN:

```text
Check membership in a set.
```

EXISTS:

```text
Does at least one related row exist?
```

NOT EXISTS:

```text
Does no related row exist?
```

Correlated subquery:

```text
Inner query references the outer query.
```

Derived table:

```text
Subquery used in FROM.
```

CTE:

```text
Named query expression used by the following statement.
```

Multiple CTEs:

```text
Named stages in a larger query.
```

---

# Chapter Summary

After completing this chapter, you should understand:

```text
Scalar Subqueries

Multi-row Subqueries

Subqueries in WHERE

Subqueries in SELECT

IN with Subqueries

NOT IN and NULL risks

EXISTS

NOT EXISTS

Correlated Subqueries

Derived Tables

Pre-Aggregation

CTEs

CTE Scope

Multiple CTEs

CTE Pipelines

CTE + JOIN

CTE + GROUP BY

CTE + Conditional Aggregation

CTE + Scalar Subquery

Above-average analysis

Existence analysis

Anti-join analysis
```

---

# Chapter Files

```text
06_subqueries_and_ctes/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to answer questions such as:

```text
Which products are priced above average?

Which products are above their category average?

Which customers have Completed orders?

Which customers have never ordered?

Which products have never been ordered?

How many orders does each customer have
using a correlated subquery?

Which orders exceed a value threshold?

How can detailed rows be pre-aggregated before joining?

How can a complex business query be divided into stages?

Which customers generate above-average revenue?
```

Most importantly, you should start thinking about a complicated SQL problem as a pipeline:

```text
Raw tables
    ->
Filter
    ->
Transform
    ->
Aggregate
    ->
Combine
    ->
Filter metrics
    ->
Final report
```

That way of thinking becomes increasingly important in the advanced chapters.