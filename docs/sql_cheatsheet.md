# SQL Mastery — T-SQL Cheat Sheet

Quick-reference guide for Microsoft SQL Server / T-SQL.

Examples use:

```sql
USE SQLMastery;
GO
```

Core tables:

```text
training.customers
training.products
training.orders
training.order_items
```

---

# 1. SELECT

```sql
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers;
```

Aliases:

```sql
SELECT
    customer_name AS name,
    signup_date AS joined_date
FROM training.customers;
```

---

# 2. DISTINCT

```sql
SELECT DISTINCT
    city
FROM training.customers;
```

Use when duplicate removal is actually required.

---

# 3. WHERE

```sql
SELECT *
FROM training.products
WHERE price > 100;
```

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

---

# 4. AND / OR / NOT

```sql
SELECT *
FROM training.products
WHERE price >= 100
  AND stock_quantity > 0;
```

```sql
SELECT *
FROM training.customers
WHERE city = 'Cairo'
   OR city = 'Giza';
```

Prefer parentheses when conditions become mixed:

```sql
WHERE
(
    city = 'Cairo'
    OR city = 'Giza'
)
AND is_active = 1;
```

---

# 5. IN

```sql
SELECT *
FROM training.customers
WHERE city IN
(
    'Cairo',
    'Giza',
    'Alexandria'
);
```

---

# 6. BETWEEN

Inclusive:

```sql
SELECT *
FROM training.products
WHERE price BETWEEN 100 AND 500;
```

Equivalent:

```sql
WHERE price >= 100
  AND price <= 500
```

---

# 7. LIKE

Starts with:

```sql
WHERE customer_name LIKE 'A%'
```

Ends with:

```sql
WHERE customer_name LIKE '%a'
```

Contains:

```sql
WHERE customer_name LIKE '%med%'
```

Single-character wildcard:

```sql
WHERE customer_name LIKE 'A_'
```

---

# 8. NULL

```sql
WHERE city IS NULL
```

```sql
WHERE city IS NOT NULL
```

Never use:

```sql
WHERE city = NULL
```

---

# 9. ORDER BY

```sql
SELECT *
FROM training.products
ORDER BY price ASC;
```

```sql
SELECT *
FROM training.products
ORDER BY
    category ASC,
    price DESC;
```

---

# 10. TOP

```sql
SELECT TOP (5)
    product_id,
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

With ties:

```sql
SELECT TOP (5) WITH TIES
    product_id,
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

---

# 11. COUNT

Rows:

```sql
SELECT COUNT(*)
FROM training.customers;
```

Non-NULL values:

```sql
SELECT COUNT(city)
FROM training.customers;
```

Distinct:

```sql
SELECT COUNT(DISTINCT city)
FROM training.customers;
```

---

# 12. SUM

```sql
SELECT
    SUM(stock_quantity) AS total_stock
FROM training.products;
```

Transaction value:

```sql
SELECT
    SUM(quantity * unit_price) AS value
FROM training.order_items;
```

---

# 13. AVG / MIN / MAX

```sql
SELECT
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products;
```

---

# 14. GROUP BY

```sql
SELECT
    category,
    COUNT(*) AS products,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

---

# 15. HAVING

```sql
SELECT
    customer_id,
    COUNT(*) AS completed_orders
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

Remember:

```text
WHERE  -> rows
HAVING -> groups
```

---

# 16. INNER JOIN

```sql
SELECT
    o.order_id,
    c.customer_name
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id;
```

---

# 17. LEFT JOIN

```sql
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id;
```

Keeps all customers.

---

# 18. RIGHT JOIN

```sql
SELECT
    c.customer_name,
    o.order_id
FROM training.customers AS c
RIGHT JOIN training.orders AS o
    ON o.customer_id = c.customer_id;
```

Often rewritten as a LEFT JOIN for readability.

---

# 19. FULL OUTER JOIN

```sql
SELECT
    ...
FROM A
FULL OUTER JOIN B
    ON A.id = B.id;
```

Returns:

```text
matches
left-only
right-only
```

---

# 20. CROSS JOIN

```sql
SELECT
    c.customer_name,
    p.product_name
FROM training.customers AS c
CROSS JOIN training.products AS p;
```

Returns every customer/product combination.

---

# 21. LEFT JOIN WITH FILTER

Keep all customers while matching only Completed orders:

```sql
SELECT
    c.customer_id,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
   AND o.order_status = 'Completed';
```

Be careful with:

```sql
WHERE o.order_status = 'Completed'
```

after a LEFT JOIN, because unmatched rows can disappear.

---

# 22. CASE

```sql
SELECT
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 5 THEN 'Critical'
        WHEN stock_quantity <= 10 THEN 'Low'
        ELSE 'Healthy'
    END AS stock_status
FROM training.products;
```

---

# 23. CONDITIONAL AGGREGATION

```sql
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM
    (
        CASE
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders
FROM training.orders
GROUP BY customer_id;
```

---

# 24. COALESCE

```sql
SELECT
    customer_name,
    COALESCE(city, 'Unknown') AS city
FROM training.customers;
```

Multiple fallbacks:

```sql
COALESCE(value1, value2, value3, 'Fallback')
```

---

# 25. ISNULL

SQL Server-specific:

```sql
ISNULL(city, 'Unknown')
```

---

# 26. NULLIF

Safe division:

```sql
SELECT
    100.0 * @Profit
    / NULLIF(@Revenue, 0);
```

Returns NULL instead of dividing by zero.

---

# 27. CAST

```sql
SELECT
    CAST(price AS INT)
FROM training.products;
```

```sql
CAST(value AS DECIMAL(12, 2))
```

---

# 28. CONVERT

```sql
SELECT
    CONVERT(VARCHAR(10), order_date, 120)
FROM training.orders;
```

---

# 29. TRY_CAST / TRY_CONVERT

```sql
SELECT TRY_CAST('123' AS INT);
```

```sql
SELECT TRY_CAST('abc' AS INT);
```

Failed supported conversion returns NULL.

---

# 30. CONCAT

```sql
SELECT
    CONCAT(customer_name, ' - ', city)
FROM training.customers;
```

---

# 31. STRING FUNCTIONS

```sql
UPPER(customer_name)
LOWER(customer_name)
LEN(customer_name)
LTRIM(customer_name)
RTRIM(customer_name)
LEFT(customer_name, 3)
RIGHT(customer_name, 3)
SUBSTRING(customer_name, 2, 5)
REPLACE(customer_name, 'a', 'x')
```

---

# 32. DATE PARTS

```sql
YEAR(order_date)
MONTH(order_date)
DAY(order_date)
```

```sql
DATEPART(MONTH, order_date)
```

```sql
DATENAME(MONTH, order_date)
```

---

# 33. DATEADD

```sql
DATEADD(DAY, 7, order_date)
```

```sql
DATEADD(MONTH, 1, order_date)
```

```sql
DATEADD(YEAR, -1, order_date)
```

---

# 34. DATEDIFF

```sql
DATEDIFF
(
    DAY,
    start_date,
    end_date
)
```

---

# 35. EOMONTH

```sql
SELECT EOMONTH(GETDATE());
```

Returns the final day of the month.

---

# 36. DATEFROMPARTS

```sql
DATEFROMPARTS(2025, 1, 1)
```

Month-start from an existing date:

```sql
DATEFROMPARTS
(
    YEAR(order_date),
    MONTH(order_date),
    1
)
```

---

# 37. DATE RANGE

Recommended pattern:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20250201'
```

Prefer half-open date ranges.

---

# 38. SCALAR SUBQUERY

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

---

# 39. IN SUBQUERY

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

---

# 40. EXISTS

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

---

# 41. NOT EXISTS

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

Useful for anti-joins.

---

# 42. DERIVED TABLE

```sql
SELECT
    x.customer_id,
    x.completed_orders
FROM
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) AS x;
```

---

# 43. CTE

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

---

# 44. MULTIPLE CTEs

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

---

# 45. UNION

Removes duplicates:

```sql
SELECT customer_id
FROM A

UNION

SELECT customer_id
FROM B;
```

---

# 46. UNION ALL

Preserves duplicates:

```sql
SELECT customer_id
FROM A

UNION ALL

SELECT customer_id
FROM B;
```

---

# 47. INTERSECT

```sql
SELECT customer_id
FROM A

INTERSECT

SELECT customer_id
FROM B;
```

Returns distinct values existing in both.

---

# 48. EXCEPT

```sql
SELECT customer_id
FROM A

EXCEPT

SELECT customer_id
FROM B;
```

Returns values in A but not B.

---

# 49. ROW_NUMBER

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY
        order_date DESC,
        order_id DESC
)
```

Unique sequence per partition.

---

# 50. RANK

```sql
RANK() OVER
(
    ORDER BY revenue DESC
)
```

Ties create gaps:

```text
1, 2, 2, 4
```

---

# 51. DENSE_RANK

```sql
DENSE_RANK() OVER
(
    ORDER BY revenue DESC
)
```

Ties without gaps:

```text
1, 2, 2, 3
```

---

# 52. NTILE

```sql
NTILE(4) OVER
(
    ORDER BY revenue DESC
)
```

Splits rows into approximately equal-sized groups.

---

# 53. WINDOW SUM

Total:

```sql
SUM(revenue) OVER ()
```

Partition total:

```sql
SUM(revenue) OVER
(
    PARTITION BY category
)
```

---

# 54. RUNNING TOTAL

```sql
SUM(revenue) OVER
(
    ORDER BY revenue_month
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
)
```

---

# 55. PERCENT OF TOTAL

```sql
100.0 * revenue
/ NULLIF
(
    SUM(revenue) OVER (),
    0
)
```

---

# 56. LAG

```sql
LAG(revenue) OVER
(
    ORDER BY revenue_month
)
```

Previous row value.

---

# 57. LEAD

```sql
LEAD(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
)
```

Next row value.

---

# 58. FIRST_VALUE

```sql
FIRST_VALUE(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
)
```

---

# 59. LAST_VALUE

Be explicit about frame:

```sql
LAST_VALUE(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND UNBOUNDED FOLLOWING
)
```

Default frame behavior can make `LAST_VALUE` surprising.

---

# 60. TOP N PER GROUP

```sql
WITH RankedProducts AS
(
    SELECT
        category,
        product_id,
        revenue,
        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM ...
)
SELECT *
FROM RankedProducts
WHERE revenue_rank <= 3;
```

---

# 61. LATEST ROW PER GROUP

```sql
WITH RankedOrders AS
(
    SELECT
        o.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date DESC,
                order_id DESC
        ) AS rn
    FROM training.orders AS o
)
SELECT *
FROM RankedOrders
WHERE rn = 1;
```

---

# 62. TRANSACTION REVENUE

Repository definition:

```sql
SELECT
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
```

---

# 63. COMPLETED ORDER COUNT

After joining to order items:

```sql
COUNT(DISTINCT o.order_id)
```

Do not count order-item rows as orders.

---

# 64. AVERAGE ORDER VALUE

```sql
1.0 * completed_revenue
/ NULLIF(completed_orders, 0)
```

---

# 65. REPEAT CUSTOMERS

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

Definition:

```text
>= 2 Completed orders
```

---

# 66. ESTIMATED PROFIT

```sql
SUM
(
    oi.quantity
    * (oi.unit_price - p.cost)
)
```

Historical caveat:

```text
products.cost = current cost
```

so historical profit is estimated.

---

# 67. GROSS MARGIN

```sql
100.0 * estimated_gross_profit
/ NULLIF(revenue, 0)
```

---

# 68. RFM BASE

```sql
WITH ReferenceDate AS
(
    SELECT
        DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    ...
```

Definitions:

```text
Recency   = days since latest Completed order
Frequency = distinct Completed orders
Monetary  = Completed revenue
```

---

# 69. COHORT MONTH

```sql
DATEFROMPARTS
(
    YEAR(MIN(order_date)),
    MONTH(MIN(order_date)),
    1
)
```

based on first Completed order.

---

# 70. CUSTOMER-MONTH ACTIVITY

```sql
SELECT DISTINCT
    customer_id,
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS activity_month
FROM training.orders
WHERE order_status = 'Completed';
```

---

# 71. COHORT AGE

```sql
DATEDIFF
(
    MONTH,
    cohort_month,
    activity_month
)
```

---

# 72. SAFE TRANSACTION TEMPLATE

```sql
SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    -- changes

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO
```

---

# 73. TRANSACTION START / COMMIT / ROLLBACK

```sql
BEGIN TRANSACTION;
```

```sql
COMMIT TRANSACTION;
```

```sql
ROLLBACK TRANSACTION;
```

---

# 74. TRANSACTION STATE

```sql
SELECT
    @@TRANCOUNT AS transaction_count,
    XACT_STATE() AS transaction_state;
```

`XACT_STATE()`:

```text
 1 = active and committable
 0 = none
-1 = active but uncommittable
```

---

# 75. SAVEPOINT

```sql
BEGIN TRANSACTION;

UPDATE ...;

SAVE TRANSACTION StepOne;

UPDATE ...;

ROLLBACK TRANSACTION StepOne;

ROLLBACK TRANSACTION;
```

---

# 76. THROW

Custom error:

```sql
THROW 50001, 'Business rule failed.', 1;
```

Rethrow:

```sql
THROW;
```

---

# 77. @@ROWCOUNT

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;

IF @@ROWCOUNT = 0
    THROW 50001, 'Insufficient stock.', 1;
```

Check immediately.

---

# 78. SCOPE_IDENTITY

```sql
INSERT INTO training.orders
(
    customer_id,
    order_date,
    order_status
)
VALUES
(
    @CustomerId,
    GETDATE(),
    'Pending'
);

SET @OrderId =
    CONVERT(INT, SCOPE_IDENTITY());
```

---

# 79. ATOMIC INVENTORY UPDATE

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;
```

Then check:

```sql
IF @@ROWCOUNT = 0
    THROW 50001, 'Insufficient stock or product not found.', 1;
```

---

# 80. ISOLATION LEVEL

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

Options:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SNAPSHOT
SERIALIZABLE
```

---

# 81. CURRENT SESSION OPTIONS

```sql
DBCC USEROPTIONS;
```

Can display the current isolation level.

---

# 82. CREATE NONCLUSTERED INDEX

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id);
```

---

# 83. COMPOSITE INDEX

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders
(
    customer_id,
    order_date
);
```

Column order matters.

---

# 84. INCLUDE

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders
(
    customer_id,
    order_date
)
INCLUDE
(
    order_status
);
```

---

# 85. FILTERED INDEX

```sql
CREATE INDEX IX_products_active_category
ON training.products(category)
WHERE is_active = 1;
```

---

# 86. UNIQUE INDEX

```sql
CREATE UNIQUE INDEX UX_customers_email
ON training.customers(email);
```

Check existing constraints/indexes first.

---

# 87. DROP INDEX

```sql
DROP INDEX IX_orders_customer
ON training.orders;
```

Safe check:

```sql
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer'
)
BEGIN
    DROP INDEX IX_orders_customer
    ON training.orders;
END;
```

---

# 88. INSPECT INDEXES

```sql
SELECT
    i.index_id,
    i.name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key
FROM sys.indexes AS i
WHERE i.object_id =
    OBJECT_ID('training.orders');
```

---

# 89. INSPECT INDEX COLUMNS

```sql
SELECT
    i.name AS index_name,
    c.name AS column_name,
    ic.key_ordinal,
    ic.is_included_column
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = i.object_id
   AND ic.index_id = i.index_id
INNER JOIN sys.columns AS c
    ON c.object_id = ic.object_id
   AND c.column_id = ic.column_id
WHERE i.object_id =
    OBJECT_ID('training.orders')
ORDER BY
    i.index_id,
    ic.key_ordinal;
```

---

# 90. SARGABLE DATE PREDICATE

Prefer:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20260101'
```

Instead of:

```sql
WHERE YEAR(order_date) = 2025
```

---

# 91. STATISTICS IO

```sql
SET STATISTICS IO ON;

SELECT ...
FROM ...;

SET STATISTICS IO OFF;
```

Check logical reads in Messages.

---

# 92. STATISTICS TIME

```sql
SET STATISTICS TIME ON;

SELECT ...
FROM ...;

SET STATISTICS TIME OFF;
```

Provides CPU and elapsed-time information.

---

# 93. INSPECT STATISTICS

```sql
SELECT
    stats_id,
    name,
    auto_created,
    user_created
FROM sys.stats
WHERE object_id =
    OBJECT_ID('training.orders');
```

---

# 94. STATISTICS PROPERTIES

```sql
SELECT
    s.name,
    p.last_updated,
    p.rows,
    p.rows_sampled,
    p.modification_counter
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_properties
(
    s.object_id,
    s.stats_id
) AS p
WHERE s.object_id =
    OBJECT_ID('training.orders');
```

---

# 95. INDEX USAGE

```sql
SELECT
    i.name,
    us.user_seeks,
    us.user_scans,
    us.user_lookups,
    us.user_updates
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON us.database_id = DB_ID()
   AND us.object_id = i.object_id
   AND us.index_id = i.index_id
WHERE i.object_id =
    OBJECT_ID('training.orders');
```

Remember: DMV counters are not permanent history.

---

# 96. INDEX PHYSICAL STATS

```sql
SELECT
    i.name,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    OBJECT_ID('training.orders'),
    NULL,
    NULL,
    'LIMITED'
) AS ips
INNER JOIN sys.indexes AS i
    ON i.object_id = ips.object_id
   AND i.index_id = ips.index_id;
```

Do not evaluate fragmentation without considering page count.

---

# 97. REBUILD / REORGANIZE

```sql
ALTER INDEX IX_example
ON dbo.SomeTable
REORGANIZE;
```

```sql
ALTER INDEX IX_example
ON dbo.SomeTable
REBUILD;
```

Do not perform maintenance blindly.

---

# 98. OPTION (RECOMPILE)

```sql
SELECT
    ...
FROM training.orders
WHERE customer_id = @CustomerId
OPTION (RECOMPILE);
```

Useful in some parameter-sensitive situations, but adds compilation work.

---

# 99. QUERY OPTIMIZATION LOOP

```text
1. Verify correctness
2. Identify result grain
3. Capture baseline
4. Inspect Actual Execution Plan
5. Check logical reads
6. Check CPU/time
7. Compare estimated vs actual rows
8. Identify unnecessary work
9. Make one targeted change
10. Measure again
11. Verify correctness again
12. Evaluate broader workload impact
```

---

# 100. COMMON PERFORMANCE WARNINGS

Watch for:

```text
Non-SARGable predicates
Implicit conversions
Unnecessary SELECT *
Unnecessary DISTINCT
Large Key Lookup counts
Unexpected scans
Large Sorts
Hash/Sort spills
Poor cardinality estimates
Missing join predicates
Excessive row multiplication
Over-indexing
Long transactions
Blocking
```

Do not diagnose from operator names alone.

---

# 101. LOGICAL PROCESSING ORDER

Approximate conceptual order:

```text
FROM
JOIN / ON
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
ORDER BY
TOP
```

Useful for understanding aliases, filtering, aggregation, and joins.

---

# 102. DATA QUALITY CHECKS

Orphan orders:

```sql
SELECT o.*
FROM training.orders AS o
LEFT JOIN training.customers AS c
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;
```

Invalid quantity:

```sql
SELECT *
FROM training.order_items
WHERE quantity <= 0;
```

Negative stock:

```sql
SELECT *
FROM training.products
WHERE stock_quantity < 0;
```

Duplicate email:

```sql
SELECT
    email,
    COUNT(*) AS occurrences
FROM training.customers
GROUP BY email
HAVING COUNT(*) > 1;
```

---

# 103. REVENUE RECONCILIATION

Direct:

```sql
SUM(quantity * unit_price)
```

should reconcile with:

```text
SUM(order revenue)
SUM(customer revenue)
SUM(product revenue)
```

when every method uses the same Completed transaction set.

---

# 104. CUSTOMER FUNNEL

Definitions:

```text
Registered
    >=
Placed Any Order
    >=
Completed Customer
    >=
Repeat Customer
```

Repeat:

```text
>= 2 Completed orders
```

---

# 105. QUICK DEBUGGING GUIDE

Too many rows?

```text
Check join cardinality.
Check missing join predicates.
Check result grain.
```

Missing rows?

```text
Check INNER vs LEFT JOIN.
Check WHERE filters after LEFT JOIN.
Check NULL behavior.
```

Numbers too high?

```text
Check row multiplication.
Check COUNT(*) after detail joins.
Check duplicated revenue.
```

Wrong dates?

```text
Check inclusive/exclusive boundaries.
Check time components.
Check missing calendar periods.
```

Wrong anti-join result?

```text
Check NOT IN + NULL.
Consider NOT EXISTS.
```

---

# 106. SQL STYLE

Prefer:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
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

Useful habits:

```text
Meaningful aliases
Qualified join columns
Consistent indentation
One selected column per line for complex queries
Meaningful CTE names
Comments explaining business reasoning
```

---

# 107. BUSINESS SQL CHECKLIST

Before finalizing an analytical query:

```text
[ ] What does one result row represent?

[ ] Which statuses qualify?

[ ] Can any join multiply rows?

[ ] Am I counting entities or detail rows?

[ ] Does revenue use order_items.unit_price?

[ ] Should zero-activity entities remain?

[ ] Do NULL values need special treatment?

[ ] Can the denominator be zero?

[ ] Are date boundaries correct?

[ ] Is a deterministic tie breaker required?

[ ] Am I confusing missing future data with churn?

[ ] Is historical profit clearly labeled estimated?

[ ] Can the result be reconciled another way?
```

---

# 108. TRANSACTION CHECKLIST

```text
[ ] Do these changes need to succeed/fail together?

[ ] Is SET XACT_ABORT ON appropriate?

[ ] Is TRY/CATCH present?

[ ] Is XACT_STATE() checked during cleanup?

[ ] Is THROW used to preserve/raise errors?

[ ] Is @@ROWCOUNT captured immediately?

[ ] Is inventory validation atomic?

[ ] Is the transaction kept short?

[ ] Are external waits outside the DB transaction where possible?

[ ] Is deadlock retry behavior considered by the application?
```

---

# 109. PERFORMANCE CHECKLIST

```text
[ ] Is the query correct first?

[ ] Is result grain correct?

[ ] Do I have a baseline?

[ ] Did I inspect Actual Execution Plan?

[ ] Did I inspect logical reads?

[ ] Are estimates close to actual rows?

[ ] Are predicates SARGable?

[ ] Are data types aligned?

[ ] Are lookups actually expensive?

[ ] Is a scan actually doing excessive work?

[ ] Does a similar index already exist?

[ ] Will the proposed index increase write cost?

[ ] Am I relying blindly on a missing-index suggestion?

[ ] Did I measure again after the change?
```

---

# Final Memory Rules

Remember these:

```text
WHERE filters rows.
HAVING filters groups.

GROUP BY collapses rows.
Window functions preserve rows.

INNER JOIN keeps matches.
LEFT JOIN can preserve unmatched left rows.

COUNT(*) counts rows.
COUNT(column) ignores NULL.
COUNT(DISTINCT x) counts distinct non-NULL x.

UNION removes duplicates.
UNION ALL preserves duplicates.

ROW_NUMBER gives unique sequence.
RANK leaves gaps after ties.
DENSE_RANK does not.

LAG looks backward.
LEAD looks forward.

Revenue uses transaction unit_price.
Profit is estimated if historical cost is unavailable.

BEGIN TRANSACTION starts explicit transaction work.
COMMIT makes it permanent.
ROLLBACK undoes it.

Seek is not automatically good.
Scan is not automatically bad.

Indexes improve some reads but increase write cost.

CTEs are not automatically materialized.
DISTINCT is not a join repair tool.

Missing future data is not proof of churn.

Correctness first.
Define grain.
Validate.
Reconcile.
Measure.
Optimize.
Measure again.
```

---

# One-Line SQL Problem-Solving Framework

```text
Business Question
    -> Definition
    -> Grain
    -> Tables
    -> Joins
    -> Filters
    -> Aggregation
    -> Analytics
    -> NULL/Date Handling
    -> Validation
    -> Performance Measurement
```

That sequence is the core of the SQL Mastery repository.