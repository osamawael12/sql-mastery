# SQL Mastery — Learning Notes

## Purpose

This document is the condensed learning notebook for the entire SQL Mastery repository.

It is designed for:

- Fast revision
- Connecting concepts between chapters
- Remembering common traps
- Reviewing business-SQL definitions
- Preparing before exercises, projects, and interviews

The main principle throughout the repository is:

> Correctness first. Grain second. Validation third. Performance after measurement.

---

# 1. Repository Data Model

Database:

```sql
USE SQLMastery;
GO
```

Schema:

```text
training
```

Core tables:

```text
customers
products
orders
order_items
```

Relationships:

```text
customers
    1
    |
    | customer_id
    |
    N
orders
    1
    |
    | order_id
    |
    N
order_items
    N
    |
    | product_id
    |
    1
products
```

Join conditions:

```sql
c.customer_id = o.customer_id

o.order_id = oi.order_id

p.product_id = oi.product_id
```

Always understand these relationships before building analytical queries.

---

# 2. Start With Result Grain

Before writing SQL, complete this sentence:

> One output row represents one ______.

Examples:

```text
customer
order
product
category
month
customer-month
product-month
cohort-age
```

Many SQL mistakes are grain mistakes rather than syntax mistakes.

---

# 3. Why Grain Matters

Suppose:

```text
Order 100
    Item A
    Item B
    Item C
```

Joining:

```text
orders
->
order_items
```

turns one order into three joined rows.

Therefore:

```sql
COUNT(o.order_id)
```

could count three rows.

If the requirement is number of orders, you may need:

```sql
COUNT(DISTINCT o.order_id)
```

or pre-aggregation at order grain.

---

# 4. Basic SELECT Pattern

```sql
SELECT
    column_1,
    column_2
FROM schema.table
WHERE condition
ORDER BY column_1;
```

Prefer explicit columns over:

```sql
SELECT *
```

when you know what the query requires.

---

# 5. Logical Query Processing

A useful conceptual order is:

```text
FROM / JOIN
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
ORDER BY
TOP
```

This explains many SQL behaviors.

For example, a SELECT alias normally cannot be referenced directly by `WHERE` in the same query level because `WHERE` is conceptually processed earlier.

---

# 6. Filtering

Comparison operators:

```text
=
<>
!=
>
>=
<
<=
```

Examples:

```sql
WHERE price >= 100
```

```sql
WHERE city = 'Cairo'
```

```sql
WHERE order_status <> 'Cancelled'
```

---

# 7. AND / OR

Be careful with precedence.

Instead of relying on memory:

```sql
WHERE city = 'Cairo'
   OR city = 'Giza'
  AND is_active = 1
```

make intent explicit:

```sql
WHERE
(
    city = 'Cairo'
    OR city = 'Giza'
)
AND is_active = 1;
```

Parentheses improve correctness and readability.

---

# 8. IN

Instead of:

```sql
WHERE city = 'Cairo'
   OR city = 'Giza'
   OR city = 'Alexandria'
```

use:

```sql
WHERE city IN
(
    'Cairo',
    'Giza',
    'Alexandria'
);
```

---

# 9. BETWEEN

`BETWEEN` is inclusive.

```sql
WHERE price BETWEEN 100 AND 500
```

means:

```sql
price >= 100
AND price <= 500
```

Be cautious with datetime ranges.

For dates with time values, half-open ranges are usually clearer.

---

# 10. Date Filtering

Prefer:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20250201'
```

for January 2025.

This is generally better than:

```sql
WHERE YEAR(order_date) = 2025
  AND MONTH(order_date) = 1
```

Benefits include:

- Clear period boundaries
- Handles time components
- Usually more SARGable

---

# 11. LIKE

Examples:

```sql
WHERE customer_name LIKE 'A%'
```

starts with A.

```sql
WHERE customer_name LIKE '%a'
```

ends with a.

```sql
WHERE customer_name LIKE '%med%'
```

contains med.

A leading wildcard generally prevents direct B-tree navigation to a known prefix.

---

# 12. NULL

NULL does not mean:

```text
zero
empty string
false
```

Correct:

```sql
WHERE city IS NULL
```

```sql
WHERE city IS NOT NULL
```

Incorrect:

```sql
WHERE city = NULL
```

---

# 13. Three-Valued Logic

SQL uses:

```text
TRUE
FALSE
UNKNOWN
```

A comparison involving NULL often evaluates to UNKNOWN.

`WHERE` retains TRUE rows.

This is especially important for:

```text
NOT IN
NULL comparisons
outer joins
```

---

# 14. ORDER BY

```sql
ORDER BY price ASC
```

```sql
ORDER BY price DESC
```

Multiple columns:

```sql
ORDER BY
    completed_revenue DESC,
    customer_id ASC;
```

Add deterministic tie breakers when exact row selection matters.

---

# 15. TOP

SQL Server syntax:

```sql
SELECT TOP (10)
    ...
FROM ...
ORDER BY completed_revenue DESC;
```

Using `TOP` without a meaningful `ORDER BY` does not mean "top" in a business sense.

---

# 16. Aggregates

Main aggregate functions:

```text
COUNT
SUM
AVG
MIN
MAX
```

Examples:

```sql
COUNT(*)
```

```sql
SUM(quantity)
```

```sql
AVG(price)
```

```sql
MIN(order_date)
```

```sql
MAX(order_date)
```

---

# 17. COUNT(*) vs COUNT(column)

```sql
COUNT(*)
```

counts rows.

```sql
COUNT(city)
```

counts non-NULL city values.

They are not always the same.

---

# 18. COUNT(DISTINCT)

Useful after one-to-many joins:

```sql
COUNT(DISTINCT o.order_id)
```

It can protect order counts from order-item multiplication.

Do not use it blindly as a substitute for understanding grain.

---

# 19. GROUP BY

Example:

```sql
SELECT
    category,
    COUNT(*) AS products,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

Every non-aggregated SELECT expression generally needs to be represented in the grouping logic.

---

# 20. WHERE vs HAVING

Use `WHERE` for row filtering:

```sql
WHERE order_status = 'Completed'
```

Use `HAVING` for group filtering:

```sql
HAVING COUNT(*) >= 2
```

Example:

```sql
SELECT
    customer_id,
    COUNT(*) AS completed_orders
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

---

# 21. Revenue Formula

Repository standard:

```sql
SUM
(
    oi.quantity * oi.unit_price
)
```

for:

```sql
o.order_status = 'Completed'
```

Use transaction:

```text
order_items.unit_price
```

not current:

```text
products.price
```

for historical revenue.

---

# 22. Units Sold

Repository standard:

```sql
SUM(oi.quantity)
```

for Completed orders.

Do not confuse:

```sql
COUNT(*)
```

with number of units.

One row can represent a quantity greater than one.

---

# 23. INNER JOIN

Returns matching rows.

```sql
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
```

---

# 24. LEFT JOIN

Keeps all left-side rows.

```sql
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
```

Useful for:

```text
customers with zero orders
products with zero sales
```

---

# 25. LEFT JOIN Filter Trap

Problem:

```sql
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
```

Customers without matching orders receive NULL right-side columns, then the `WHERE` condition removes them.

Possible approach:

```sql
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
   AND o.order_status = 'Completed'
```

or aggregate Completed activity first.

---

# 26. FULL OUTER JOIN

Useful for reconciliation where unmatched rows on both sides matter.

Conceptually:

```text
matches
+
left-only rows
+
right-only rows
```

---

# 27. CROSS JOIN

Cartesian product:

```sql
FROM A
CROSS JOIN B
```

If:

```text
A = 5 rows
B = 10 rows
```

result:

```text
50 rows
```

Use intentionally.

---

# 28. CASE

```sql
CASE
    WHEN stock_quantity = 0
        THEN 'Out of Stock'
    WHEN stock_quantity <= 5
        THEN 'Critical'
    WHEN stock_quantity <= 10
        THEN 'Low'
    ELSE 'Healthy'
END
```

`CASE` is an expression, not flow-control syntax.

---

# 29. Conditional Aggregation

Very useful:

```sql
SUM
(
    CASE
        WHEN order_status = 'Completed' THEN 1
        ELSE 0
    END
) AS completed_orders
```

Can produce multiple metrics in one grouped query.

---

# 30. COALESCE

Returns the first non-NULL expression:

```sql
COALESCE(completed_revenue, 0)
```

Useful after LEFT JOIN aggregation.

---

# 31. ISNULL

SQL Server-specific:

```sql
ISNULL(completed_revenue, 0)
```

Similar common use to `COALESCE`, but type/nullability behavior can differ.

---

# 32. NULLIF

Useful for safe division:

```sql
100.0 * profit
/ NULLIF(revenue, 0)
```

When revenue is zero, denominator becomes NULL rather than causing division-by-zero.

---

# 33. Integer Division

Be careful with:

```sql
1 / 2
```

when both operands are integers.

Force decimal arithmetic when needed:

```sql
1.0 * numerator / denominator
```

---

# 34. CAST and CONVERT

```sql
CAST(value AS DECIMAL(10, 2))
```

```sql
CONVERT(VARCHAR(10), order_date, 120)
```

Use conversions intentionally.

---

# 35. TRY_CAST / TRY_CONVERT

Useful for potentially bad input:

```sql
TRY_CAST('123' AS INT)
```

returns:

```text
123
```

while:

```sql
TRY_CAST('abc' AS INT)
```

returns NULL for a supported conversion that fails.

---

# 36. String Functions

Common examples:

```text
CONCAT
UPPER
LOWER
LTRIM
RTRIM
LEN
LEFT
RIGHT
SUBSTRING
REPLACE
```

Example:

```sql
CONCAT(customer_name, ' - ', city)
```

---

# 37. Date Functions

Useful SQL Server date functions:

```text
YEAR
MONTH
DAY
DATEPART
DATENAME
DATEADD
DATEDIFF
EOMONTH
DATEFROMPARTS
```

Month-start pattern:

```sql
DATEFROMPARTS
(
    YEAR(order_date),
    MONTH(order_date),
    1
)
```

---

# 38. Subquery

Example:

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
);
```

The inner query produces a value used by the outer query.

---

# 39. Scalar Subquery

A scalar subquery must return one value.

Example:

```sql
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
)
```

If it returns multiple rows where one value is required, SQL Server raises an error.

---

# 40. IN Subquery

```sql
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
)
```

Useful for membership tests.

---

# 41. EXISTS

```sql
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
)
```

Great for existence requirements.

The selected `1` is conventional; the existence of a row is what matters.

---

# 42. NOT EXISTS

Useful for anti-joins:

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

This finds customers with no orders.

---

# 43. NOT IN and NULL

Be careful:

```sql
WHERE x NOT IN
(
    SELECT nullable_column
    FROM ...
)
```

If NULL appears in the set, three-valued logic can produce unexpected results.

For anti-join logic, `NOT EXISTS` is often clearer/safer.

---

# 44. Correlated Subquery

References the outer query:

```sql
SELECT
    c.customer_id
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

---

# 45. Derived Table

```sql
SELECT *
FROM
(
    SELECT
        customer_id,
        COUNT(*) AS orders
    FROM training.orders
    GROUP BY customer_id
) AS x;
```

A derived table requires an alias.

---

# 46. CTE

```sql
WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS orders
    FROM training.orders
    GROUP BY customer_id
)
SELECT *
FROM CustomerOrders;
```

CTEs are excellent for organizing multi-stage analytical logic.

---

# 47. CTE Scope

A CTE exists for the single statement immediately following it.

It is not a permanent object.

---

# 48. Multiple CTEs

```sql
WITH A AS
(
    ...
),
B AS
(
    ...
),
C AS
(
    ...
)
SELECT ...
FROM C;
```

This is useful for building readable analytical pipelines.

---

# 49. CTE Does Not Mean Materialization

A CTE does not automatically create temporary stored data.

It is primarily a query-expression construct.

For performance, inspect the actual execution plan.

---

# 50. UNION

Combines compatible result sets and removes duplicates.

```sql
SELECT ...
UNION
SELECT ...;
```

---

# 51. UNION ALL

Combines compatible results and preserves duplicates.

```sql
SELECT ...
UNION ALL
SELECT ...;
```

When duplicate removal is not required, `UNION ALL` avoids that work.

---

# 52. INTERSECT

Returns distinct rows appearing in both sets.

```text
A ∩ B
```

---

# 53. EXCEPT

Returns distinct rows in the first set but not the second.

```text
A - B
```

Direction matters.

---

# 54. Set Operation Requirements

Branches should have:

```text
same number of columns
compatible types by position
semantically aligned columns
```

`ORDER BY` normally applies to the final combined result.

---

# 55. Window Functions

Window functions calculate across related rows while preserving row detail.

General syntax:

```sql
function(...) OVER
(
    PARTITION BY ...
    ORDER BY ...
)
```

---

# 56. PARTITION BY

Restarts the window calculation per group.

Example:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
)
```

Each customer gets their own sequence.

---

# 57. Window ORDER BY vs Final ORDER BY

This:

```sql
ROW_NUMBER() OVER
(
    ORDER BY revenue DESC
)
```

defines ranking logic.

This:

```sql
ORDER BY customer_id
```

defines final result display order.

They serve different purposes.

---

# 58. ROW_NUMBER

```text
1
2
3
4
```

Every row gets a unique sequence number within its partition.

Useful when exactly one row must be selected.

---

# 59. RANK

With ties:

```text
1
2
2
4
```

Ranks have gaps.

---

# 60. DENSE_RANK

With ties:

```text
1
2
2
3
```

No rank gaps.

---

# 61. Deterministic Tie Breakers

If exactly one latest order is required:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY
        order_date DESC,
        order_id DESC
)
```

Without `order_id`, equal order dates can make the selected row non-deterministic.

---

# 62. LAG

Previous row value:

```sql
LAG(revenue) OVER
(
    ORDER BY revenue_month
)
```

Useful for growth calculations.

---

# 63. LEAD

Next row value:

```sql
LEAD(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
)
```

Useful for next-event analysis.

---

# 64. Running Total

```sql
SUM(monthly_revenue) OVER
(
    ORDER BY revenue_month
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
)
```

Explicit `ROWS` framing makes running-total intent clear.

---

# 65. Percent of Total

```sql
100.0 * customer_revenue
/ NULLIF
(
    SUM(customer_revenue) OVER (),
    0
)
```

No self-join to a total query is necessary.

---

# 66. NTILE

```sql
NTILE(4) OVER
(
    ORDER BY revenue DESC
)
```

Divides rows into approximately equal groups.

It does not guarantee equal revenue in each group.

---

# 67. Top N Per Group

Pattern:

```sql
WITH ProductRevenue AS
(
    -- one row per category/product
),
Ranked AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM ProductRevenue
)
SELECT *
FROM Ranked
WHERE revenue_rank <= 3;
```

First establish correct grain, then rank.

---

# 68. Latest Row Per Group

Pattern:

```sql
WITH Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date DESC,
                order_id DESC
        ) AS rn
    FROM training.orders
)
SELECT *
FROM Ranked
WHERE rn = 1;
```

---

# 69. Business Revenue Definition

Default repository definition:

```text
Completed revenue =
SUM(quantity * unit_price)
on Completed orders
```

Important:

```text
unit_price = transaction price
products.price = current product price
```

---

# 70. Completed Order Count

If already at order grain:

```sql
COUNT(*)
```

can be correct.

After joining to order items:

```sql
COUNT(DISTINCT o.order_id)
```

may be necessary.

Always know the current grain.

---

# 71. Average Order Value

Concept:

```text
Completed Revenue
-----------------
Completed Orders
```

Safely:

```sql
1.0 * completed_revenue
/ NULLIF(completed_orders, 0)
```

---

# 72. Repeat Customer

Repository definition:

```text
>= 2 Completed orders
```

Not:

```text
>= 2 order_items
```

Not:

```text
>= 2 units
```

---

# 73. Profit

Estimated gross profit:

```sql
SUM
(
    oi.quantity
    * (oi.unit_price - p.cost)
)
```

for Completed sales.

---

# 74. Historical Profit Caveat

Revenue uses historical transaction price.

Cost uses:

```text
current products.cost
```

because transaction-time cost is not stored.

Therefore historical profit is:

```text
Estimated Gross Profit
```

not exact accounting profit.

---

# 75. Gross Margin

```text
Gross Profit
------------
Revenue
```

Percentage:

```sql
100.0 * gross_profit
/ NULLIF(revenue, 0)
```

---

# 76. RFM

```text
R = Recency
F = Frequency
M = Monetary
```

Repository definitions:

```text
Recency:
days since latest Completed order

Frequency:
distinct Completed orders

Monetary:
Completed revenue
```

---

# 77. RFM Reference Date

Use:

```text
one day after latest Completed order
```

rather than `GETDATE()`.

Concept:

```sql
DATEADD
(
    DAY,
    1,
    MAX(order_date)
)
```

This keeps historical analysis deterministic.

---

# 78. RFM Scoring Direction

For Recency:

```text
lower days = better
```

For Frequency:

```text
higher = better
```

For Monetary:

```text
higher = better
```

When using `NTILE`, choose ordering carefully so score 5 consistently means stronger.

---

# 79. Cohort

Repository cohort:

```text
Month of first Completed order
```

Represent as month-start date.

---

# 80. Customer-Month Activity

Use:

```sql
SELECT DISTINCT
    customer_id,
    activity_month
```

because multiple orders in one month still represent one active customer-month for retention analysis.

---

# 81. Cohort Age

```sql
DATEDIFF
(
    MONTH,
    cohort_month,
    activity_month
)
```

```text
0 = cohort month
1 = next month
2 = two months later
```

---

# 82. Cohort Retention

```text
Active cohort customers at age N
--------------------------------
Original cohort size
```

This compares activity back to the acquisition cohort.

---

# 83. Consecutive-Month Retention

Different question:

> Of customers active this month, how many are active next month?

Do not call this cohort retention.

---

# 84. Right-Censoring

If the dataset ends in June, June customers cannot be classified as failing to return in July if July is not observed.

No future data:

```text
!=
```

observed future inactivity.

---

# 85. Churn Definitions

Possible churn definitions:

```text
No next-month activity
30 days inactive
90 days inactive
Explicit subscription cancellation
```

A query cannot define churn correctly until the business definition is clear.

---

# 86. Funnel

Default repository funnel:

```text
Registered
    ->
Placed Any Order
    ->
Completed Customer
    ->
Repeat Customer
```

Expected:

```text
Registered >= Ordered >= Completed >= Repeat
```

Use this as a sanity check.

---

# 87. Funnel Conversion

Step conversion:

```text
Current Stage
-------------
Previous Stage
```

Overall conversion:

```text
Current Stage
-------------
Registered
```

---

# 88. Metric Reconciliation

Calculate important totals through independent paths.

Example revenue:

```text
Transaction revenue
Order-level revenue summed again
Customer-level revenue summed again
```

Expected:

```text
all totals equal
```

Reconciliation catches grain and join errors.

---

# 89. Transaction Basics

```sql
BEGIN TRANSACTION;

-- changes

COMMIT TRANSACTION;
```

or:

```sql
BEGIN TRANSACTION;

-- changes

ROLLBACK TRANSACTION;
```

---

# 90. ACID

```text
Atomicity
Consistency
Isolation
Durability
```

Atomicity:

```text
all required transaction work succeeds or fails together
```

Consistency:

```text
valid state -> valid state
```

Isolation:

```text
rules governing concurrent transaction visibility
```

Durability:

```text
committed work survives recovery
```

---

# 91. Transaction Error Pattern

```sql
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- work

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

Memorize the reasoning, not just the syntax.

---

# 92. XACT_STATE

Possible values:

```text
 1 = active and committable
 0 = no transaction
-1 = active but uncommittable
```

Cleanup:

```sql
IF XACT_STATE() <> 0
    ROLLBACK;
```

---

# 93. @@TRANCOUNT

Shows transaction nesting count in the session:

```sql
SELECT @@TRANCOUNT;
```

Nested SQL Server transactions are not independent transactions.

---

# 94. Savepoint

```sql
SAVE TRANSACTION MySavepoint;
```

Later:

```sql
ROLLBACK TRANSACTION MySavepoint;
```

This can undo work after the savepoint without automatically discarding all earlier work.

---

# 95. THROW

Custom business error:

```sql
THROW 50001, 'Insufficient inventory.', 1;
```

Rethrow original error inside CATCH:

```sql
THROW;
```

---

# 96. @@ROWCOUNT

Check immediately after the relevant statement:

```sql
UPDATE ...

IF @@ROWCOUNT = 0
    THROW 50001, 'Update failed.', 1;
```

Subsequent statements can change `@@ROWCOUNT`.

---

# 97. SCOPE_IDENTITY

After an IDENTITY insert:

```sql
INSERT INTO training.orders (...);

SET @OrderId =
    CONVERT(INT, SCOPE_IDENTITY());
```

Useful for inserting dependent rows.

---

# 98. Atomic Inventory Update

Prefer:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;
```

Then:

```sql
IF @@ROWCOUNT = 0
    THROW 50001, 'Insufficient stock.', 1;
```

Validation is part of the modification itself.

---

# 99. Avoid Check-Then-Update Races

Risky conceptual pattern:

```text
SELECT stock
application checks stock
UPDATE stock
```

Stock can change between the SELECT and UPDATE.

Use atomic conditional modifications where practical.

---

# 100. Isolation Levels

Common SQL Server levels:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SNAPSHOT
SERIALIZABLE
```

Stronger isolation is not automatically better.

It is a correctness/concurrency trade-off.

---

# 101. Dirty Read

Reading another transaction's uncommitted change.

Allowed by:

```text
READ UNCOMMITTED
```

The value may later be rolled back.

---

# 102. Non-Repeatable Read

Same row read twice within a transaction, but another transaction changes/commits it between reads.

The two reads return different values.

---

# 103. Phantom Read

The same predicate returns a different set of qualifying rows because another transaction inserted/deleted matching rows.

---

# 104. Blocking

One session waits for another session to release an incompatible resource/lock.

Blocking is not automatically an error.

Excessive blocking is a performance/concurrency problem.

---

# 105. Deadlock

Circular waiting:

```text
A holds resource 1
B holds resource 2

A wants resource 2
B wants resource 1
```

SQL Server chooses a victim and rolls it back.

---

# 106. Reduce Deadlock Risk

Useful practices:

```text
Keep transactions short
Access resources in consistent order
Use appropriate indexes
Touch only required rows
Avoid unnecessary transaction scope
Use retry handling where appropriate
```

---

# 107. Database Transaction vs Business Workflow

Do not hold one SQL transaction open across:

```text
payment provider
human approval
warehouse processing
shipping
delivery
```

Database transactions should generally protect short database operations.

Long-lived workflows persist state and use application/workflow patterns.

---

# 108. Index Basics

An index is an access structure.

It can help:

```text
WHERE
JOIN
ORDER BY
GROUP BY
```

But every index has costs:

```text
storage
memory
INSERT work
UPDATE work
DELETE work
maintenance
```

---

# 109. Clustered Index

A table can have at most one clustered index.

Its leaf level contains the table rows.

---

# 110. Nonclustered Index

Separate index structure.

A table can have multiple nonclustered indexes.

Example:

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id);
```

---

# 111. Heap

A table with no clustered index.

---

# 112. Seek vs Scan

Index Seek:

```text
navigate to relevant key/range
```

Index Scan:

```text
read a broader portion of the index
```

Never use:

```text
Seek = always good
Scan = always bad
```

A scan of five rows is cheap.

A seek returning five million rows can be expensive.

---

# 113. Selectivity

Highly selective:

```sql
WHERE order_id = 100
```

Potentially low selectivity:

```sql
WHERE order_status = 'Completed'
```

depending on data distribution.

Index usefulness depends partly on how many rows qualify.

---

# 114. Composite Index

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders
(
    customer_id,
    order_date
);
```

Key order matters.

---

# 115. Equality + Range Pattern

For:

```sql
WHERE customer_id = @CustomerId
  AND order_date >= @StartDate
```

candidate:

```text
(customer_id, order_date)
```

because:

```text
customer_id = equality
order_date = range
```

This is a useful heuristic, not a universal law.

---

# 116. INCLUDE

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id)
INCLUDE
(
    order_date,
    order_status
);
```

Included columns are stored to help satisfy query output without making them search keys.

---

# 117. Covering Index

An index covers a query when the required information can be obtained from that index without fetching missing columns elsewhere.

Useful, but do not make every index extremely wide.

---

# 118. Key Lookup

SQL Server may:

```text
seek nonclustered index
->
find matching row locator
->
lookup missing columns in clustered index
```

Few lookups may be fine.

Huge numbers of lookups may be expensive.

---

# 119. SARGability

Good:

```sql
WHERE order_date >= '20250101'
```

Less index-friendly:

```sql
WHERE YEAR(order_date) = 2025
```

Prefer direct predicates on searchable columns where semantics allow.

---

# 120. Functions on Search Columns

Watch:

```sql
WHERE UPPER(city) = 'CAIRO'
```

```sql
WHERE YEAR(order_date) = 2025
```

```sql
WHERE ISNULL(city, '') = 'Cairo'
```

Functions can make normal index search access harder.

Any rewrite must preserve semantics.

---

# 121. Implicit Conversions

Keep parameter types aligned with column types.

Implicit conversions can:

```text
consume CPU
affect estimates
interfere with efficient access
```

Inspect execution plans for conversion issues.

---

# 122. Execution Plans

Common operators:

```text
Index Seek
Index Scan
Table Scan
Key Lookup
Nested Loops
Hash Match
Merge Join
Sort
Stream Aggregate
Hash Aggregate
```

Actual plans provide runtime information.

---

# 123. Estimated vs Actual Rows

Big differences are important.

The optimizer selected the plan based on estimated cardinality.

Poor estimates can influence:

```text
join algorithm
memory grant
access method
join order
```

---

# 124. Statistics

Statistics describe data distribution.

They help SQL Server estimate:

```text
how many rows will qualify
```

Statistics are not the same as indexes.

---

# 125. STATISTICS IO

```sql
SET STATISTICS IO ON;

-- query

SET STATISTICS IO OFF;
```

Pay attention to logical reads when comparing equivalent query alternatives.

---

# 126. STATISTICS TIME

```sql
SET STATISTICS TIME ON;

-- query

SET STATISTICS TIME OFF;
```

Use repeated measurements.

One elapsed-time result is weak evidence.

---

# 127. Cache Effects

First and later executions can differ because:

```text
data may become cached
plan may become cached
compilation may already have occurred
```

Benchmark carefully.

---

# 128. Join Algorithms

Nested Loops:

```text
often useful for small outer input + efficient inner lookup
```

Hash Match:

```text
often useful for larger unsorted equality joins
```

Merge Join:

```text
often useful when inputs are appropriately ordered
```

No algorithm is universally best.

---

# 129. Sorts

Sorts can be required for:

```text
ORDER BY
GROUP BY
DISTINCT
window functions
merge processing
```

A Sort is not automatically a problem.

Investigate large, expensive, or spilling sorts.

---

# 130. Memory Grants

Operators such as:

```text
Sort
Hash Join
Hash Aggregate
```

may require memory grants.

Bad estimates can cause:

```text
too little memory -> spills
too much memory -> wasted capacity
```

---

# 131. tempdb Spills

If an operator cannot complete its work in granted memory, it may spill intermediate data to tempdb.

Look for spill warnings in actual execution plans.

---

# 132. Parameter Sensitivity

Example:

```text
customer 1 -> 3 rows
customer 2 -> 5,000,000 rows
```

A plan suitable for one parameter may be poor for another.

Do not diagnose parameter sensitivity without plan/runtime evidence.

---

# 133. Missing Index Suggestions

Treat as:

```text
clues
```

not:

```text
commands
```

Check:

```text
existing indexes
overlap
write cost
storage
query importance
broader workload
```

---

# 134. Over-Indexing

Every index increases modification cost.

More indexes mean more structures to maintain during:

```text
INSERT
UPDATE
DELETE
```

The goal is useful indexes, not maximum indexes.

---

# 135. Filtered Index

Example:

```sql
CREATE INDEX IX_products_active_category
ON training.products(category)
WHERE is_active = 1;
```

Can be useful when queries repeatedly target a stable subset.

---

# 136. Index Maintenance

Concepts:

```text
REORGANIZE
REBUILD
fragmentation
fill factor
statistics
```

Do not use simplistic maintenance rules without considering index size and workload.

---

# 137. Performance Baseline

Before changing anything, capture:

```text
query text
parameters
actual execution plan
logical reads
CPU
elapsed time
returned rows
existing indexes
```

Without a baseline, improvement is difficult to prove.

---

# 138. Performance Workflow

```text
Measure
    ->
Understand
    ->
Change one targeted thing
    ->
Measure again
```

Then:

```text
verify correctness
evaluate broader impact
```

---

# 139. Don't Tune Syntax by Myth

Avoid assumptions like:

```text
CTE is faster than subquery

EXISTS is always faster than IN

JOIN is always faster than subquery

Seek is always good

Scan is always bad

More indexes are always better
```

SQL Server optimization is cost- and workload-based.

---

# 140. Correctness Before Performance

Never change:

```text
business definition
result grain
NULL behavior
date boundaries
transaction semantics
```

merely to obtain a faster-looking execution plan.

A fast wrong result is still wrong.

---

# 141. SQL Problem-Solving Workflow

For a business request:

```text
1. Define the metric.
2. Define final grain.
3. Identify source tables.
4. Identify relationships.
5. Identify qualifying rows.
6. Build correct base data.
7. Aggregate to required grain.
8. Apply analytical calculations.
9. Handle NULL/zero.
10. Validate counts and totals.
11. Reconcile important metrics.
12. Measure performance if necessary.
```

---

# 142. Debugging Wrong Numbers

If revenue/counts look too high, inspect:

```text
join cardinality
row multiplication
incorrect status filters
duplicate source rows
incorrect grain
COUNT(*) after one-to-many joins
```

Start with detail rows before trusting aggregates.

---

# 143. Debugging Missing Rows

If entities disappear unexpectedly, inspect:

```text
INNER JOIN instead of LEFT JOIN
WHERE condition on right side of LEFT JOIN
NULL behavior
date boundaries
status filters
NOT IN with NULL
```

---

# 144. Debugging Duplicate Rows

Ask:

```text
What does each row represent?

Is the relationship one-to-many?

Am I missing a join predicate?

Is the duplicate actually legitimate detail?

Am I using DISTINCT to hide the real issue?
```

---

# 145. Reconciliation Mindset

Important totals should often be reproducible from different grains.

Example:

```text
Direct transaction revenue
=
SUM(order revenue)
=
SUM(customer revenue)
=
SUM(product revenue)
```

when all calculations use the same qualifying transaction set.

If they do not match, investigate.

---

# 146. Validation Queries Are Part of Analytics

Useful checks:

```text
registered >= ordered >= completed >= repeat

stock_quantity >= 0

quantity > 0

transaction revenue = reaggregated revenue

final customer report rows = customer table rows
```

Do not treat validation as optional cleanup.

---

# 147. Comments Should Explain Why

Weak comment:

```sql
-- Join orders
```

The code already says that.

Better comment:

```sql
-- Aggregate to one row per order before customer-level averaging
-- so customers with multi-line orders are not weighted by line count.
```

Document reasoning and business definitions.

---

# 148. Naming CTEs

Prefer meaningful names:

```text
CompletedOrders
OrderRevenue
CustomerRevenue
MonthlyRevenue
CustomerActivity
Cohorts
RankedProducts
```

instead of:

```text
cte1
cte2
x
temp
```

Good names expose the analytical pipeline.

---

# 149. Formatting

Readable SQL helps prevent errors.

Prefer:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name;
```

Consistency matters more than one perfect formatting style.

---

# 150. Core Repository Principles

Keep these rules:

1. Know what one row represents.
2. Understand table relationships before joining.
3. Expect one-to-many joins to multiply rows.
4. Use transaction price for historical revenue.
5. Treat historical profit as estimated without historical cost.
6. Define retention and churn explicitly.
7. Handle dataset boundaries.
8. Use deterministic tie breakers.
9. Protect divisions with `NULLIF`.
10. Preserve zero-activity entities when required.
11. Reconcile critical metrics.
12. Use transactions for atomic database work.
13. Keep transactions short.
14. Design indexes around workloads.
15. Measure before tuning.
16. Validate correctness after tuning.

---

# Fast Mental Checklist

Before submitting a query, ask:

```text
What is the result grain?

Can any join multiply rows?

Am I counting rows or business entities?

Which order statuses qualify?

Am I using historical transaction price?

Should zero-activity entities remain?

Can NULL change the result?

Are my date boundaries correct?

Is the denominator allowed to be zero?

Do I need a deterministic tie breaker?

Can I validate the result another way?

Is the query slow, or am I just assuming it is?
```

---

# Final Learning Map

The repository progression is:

```text
Database Fundamentals
        |
        v
SELECT + Filtering
        |
        v
Aggregation
        |
        v
Joins
        |
        v
Data Transformation
        |
        v
Subqueries + CTEs
        |
        v
Set Operations
        |
        v
Window Functions
        |
        v
Business SQL
        |
        v
Transactions + ACID
        |
        v
Indexes + Performance
        |
        v
Business Challenges
        |
        v
Projects
```

The goal is not to memorize isolated commands.

The goal is to move from:

```text
"I know SQL syntax"
```

to:

```text
"I can define a business problem, model its grain,
write correct SQL, validate the result, and reason
about how SQL Server executes it."
```