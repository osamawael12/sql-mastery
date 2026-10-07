# SQL Mastery — Interview Questions

This document is a practical SQL Server / T-SQL interview review covering concepts from fundamentals through business analytics, transactions, and query performance.

Examples assume:

```sql
USE SQLMastery;
GO
```

and the core schema:

```text
training.customers
training.products
training.orders
training.order_items
```

---

# 1. What is SQL?

SQL stands for Structured Query Language.

It is used to interact with relational databases for tasks such as:

- Querying data
- Inserting data
- Updating data
- Deleting data
- Defining database objects
- Managing transactions
- Controlling permissions

Microsoft SQL Server uses an SQL dialect called T-SQL.

---

# 2. What is T-SQL?

T-SQL stands for Transact-SQL.

It extends standard SQL with SQL Server-specific features such as:

```text
Variables
TRY/CATCH
THROW
Stored procedures
Functions
TOP
IDENTITY
Window functions
Transaction features
```

---

# 3. What is a relational database?

A relational database organizes data into relations, commonly represented as tables.

Tables contain:

```text
Rows
Columns
```

Relationships between tables are typically established using keys.

---

# 4. What is a primary key?

A primary key uniquely identifies each row in a table.

Important properties:

```text
Unique
NOT NULL
```

Example:

```sql
customer_id INT PRIMARY KEY
```

A table has one primary-key constraint, although that key may contain multiple columns.

---

# 5. What is a foreign key?

A foreign key establishes referential integrity between tables.

Example relationship:

```text
orders.customer_id
    ->
customers.customer_id
```

It helps prevent child rows from referencing nonexistent parent keys.

---

# 6. Does a foreign key automatically create an index in SQL Server?

No.

SQL Server does not automatically create a supporting nonclustered index simply because a foreign key exists.

Foreign-key columns are often good index candidates, but indexes should be designed based on workload requirements.

---

# 7. What is a UNIQUE constraint?

A UNIQUE constraint enforces uniqueness for a column or combination of columns.

Example:

```sql
email VARCHAR(255) UNIQUE
```

Unlike a primary key, a table can have multiple UNIQUE constraints.

---

# 8. What is a CHECK constraint?

A CHECK constraint restricts allowed values.

Example:

```sql
CHECK (stock_quantity >= 0)
```

or:

```sql
CHECK
(
    order_status IN
    (
        'Pending',
        'Completed',
        'Cancelled'
    )
)
```

---

# 9. What is NOT NULL?

`NOT NULL` requires a column to contain a value rather than SQL NULL.

Example:

```sql
product_name VARCHAR(200) NOT NULL
```

---

# 10. What does NULL mean?

NULL represents a missing, unknown, or not-applicable value.

It is not equivalent to:

```text
0
''
FALSE
```

Correct:

```sql
WHERE city IS NULL
```

Incorrect:

```sql
WHERE city = NULL
```

---

# 11. What is three-valued logic?

SQL predicates can evaluate to:

```text
TRUE
FALSE
UNKNOWN
```

Comparisons involving NULL frequently produce UNKNOWN.

A `WHERE` clause keeps rows where its predicate evaluates to TRUE.

---

# 12. What does SELECT do?

`SELECT` retrieves data.

Example:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers;
```

---

# 13. Why avoid SELECT *?

`SELECT *` can:

- Return unnecessary columns
- Increase network transfer
- Increase row width
- Make covering indexes harder
- Make application dependencies less explicit

Prefer selecting only required columns.

---

# 14. What is DISTINCT?

`DISTINCT` removes duplicate result rows.

Example:

```sql
SELECT DISTINCT city
FROM training.customers;
```

Do not use `DISTINCT` merely to hide incorrect join logic.

---

# 15. WHERE vs HAVING?

`WHERE` filters rows before aggregation.

`HAVING` filters groups after aggregation.

Example:

```sql
SELECT
    customer_id,
    COUNT(*) AS orders
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2;
```

---

# 16. What is GROUP BY?

`GROUP BY` creates groups of rows so aggregate functions can calculate one result per group.

Example:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

---

# 17. COUNT(*) vs COUNT(column)?

`COUNT(*)` counts rows.

`COUNT(column)` counts non-NULL values in that column.

Example:

```sql
SELECT
    COUNT(*) AS rows,
    COUNT(city) AS rows_with_city
FROM training.customers;
```

---

# 18. What does COUNT(DISTINCT column) do?

It counts distinct non-NULL values.

Example:

```sql
SELECT
    COUNT(DISTINCT customer_id)
FROM training.orders;
```

This is especially useful when joins can repeat an entity.

---

# 19. What does SUM() do?

`SUM()` adds numeric values.

Example:

```sql
SELECT
    SUM(quantity * unit_price) AS order_item_value
FROM training.order_items;
```

---

# 20. What is the difference between SUM and AVG?

`SUM()` returns the total.

`AVG()` returns the arithmetic mean of non-NULL values.

Be careful with business grain.

For example, average order value should generally be:

```text
total order revenue / number of orders
```

not necessarily:

```sql
AVG(quantity * unit_price)
```

because that averages order lines rather than orders.

---

# 21. INNER JOIN vs LEFT JOIN?

`INNER JOIN` returns matching rows from both sides.

`LEFT JOIN` keeps every row from the left side and adds matching right-side rows when available.

Example:

```sql
SELECT
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id;
```

Customers without orders remain.

---

# 22. What is a RIGHT JOIN?

A RIGHT JOIN keeps every row from the right table and matching rows from the left.

Many developers prefer rewriting it as a LEFT JOIN with table order reversed for consistency/readability.

---

# 23. What is a FULL OUTER JOIN?

It returns:

```text
matched rows
+
unmatched left rows
+
unmatched right rows
```

It can be useful for reconciliation problems.

---

# 24. What is a CROSS JOIN?

A CROSS JOIN returns the Cartesian product.

If table A contains 5 rows and B contains 10 rows:

```text
5 × 10 = 50 rows
```

Use it intentionally.

---

# 25. What is row multiplication?

One-to-many joins can repeat rows from the "one" side.

Example:

```text
1 order
3 order items
```

After joining:

```text
3 rows
```

This can cause incorrect counts or sums if the intended result grain is not understood.

---

# 26. Why is result grain important?

Result grain describes what one row represents.

Examples:

```text
One row per customer
One row per order
One row per product
One row per customer-month
```

Defining grain before writing complex SQL prevents many analytical errors.

---

# 27. What is the ON vs WHERE LEFT JOIN trap?

Consider:

```sql
SELECT ...
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed';
```

The `WHERE` condition removes NULL right-side rows and therefore removes customers without matching Completed orders.

Depending on the requirement, the filter may need to be:

```sql
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
   AND o.order_status = 'Completed'
```

or applied in a pre-aggregated subquery/CTE.

---

# 28. What is CASE?

`CASE` provides conditional expressions.

Example:

```sql
CASE
    WHEN stock_quantity = 0 THEN 'Out of Stock'
    WHEN stock_quantity <= 10 THEN 'Low'
    ELSE 'Healthy'
END
```

---

# 29. COALESCE vs ISNULL?

Both can replace NULL values.

Example:

```sql
COALESCE(city, 'Unknown')
```

and:

```sql
ISNULL(city, 'Unknown')
```

Differences include:

- `COALESCE` is standard SQL and accepts multiple arguments.
- `ISNULL` is SQL Server-specific and accepts two arguments.
- Data-type/nullability behavior can differ.

Do not assume they are interchangeable in every context.

---

# 30. What is NULLIF?

`NULLIF(a, b)` returns NULL when `a = b`; otherwise it returns `a`.

It is useful for safe division:

```sql
revenue / NULLIF(order_count, 0)
```

---

# 31. CAST vs CONVERT?

Both perform explicit data-type conversion.

Example:

```sql
CAST(price AS INT)
```

SQL Server's `CONVERT` also supports style arguments for some conversions:

```sql
CONVERT(VARCHAR(10), order_date, 120)
```

---

# 32. TRY_CAST and TRY_CONVERT?

They return NULL when a supported conversion fails instead of raising a normal conversion error.

Example:

```sql
TRY_CAST('abc' AS INT)
```

returns NULL.

---

# 33. Why can functions in WHERE hurt performance?

Example:

```sql
WHERE YEAR(order_date) = 2025
```

Applying a function to a searchable column can make efficient index navigation harder.

Prefer a SARGable range:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20260101'
```

---

# 34. Why use half-open date ranges?

Prefer:

```sql
order_date >= '20250101'
AND order_date < '20250201'
```

rather than constructing an end-of-day timestamp.

Half-open ranges work cleanly with date/time precision and are usually index-friendly.

---

# 35. What is a subquery?

A subquery is a query nested inside another query.

Example:

```sql
SELECT *
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
);
```

---

# 36. What is a correlated subquery?

A correlated subquery references values from the outer query.

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

---

# 37. EXISTS vs IN?

`EXISTS` asks whether at least one matching row exists.

`IN` compares a value with a set of values.

SQL Server may optimize both effectively depending on the query.

Choose based primarily on correct semantics and clarity.

---

# 38. What is the NOT IN + NULL problem?

If the subquery used by `NOT IN` contains NULL, SQL's three-valued logic can make results surprising.

For anti-joins, `NOT EXISTS` is often safer when NULL can occur.

Example:

```sql
WHERE NOT EXISTS
(
    SELECT 1
    FROM ...
    WHERE ...
)
```

---

# 39. What is a derived table?

A derived table is a subquery in the `FROM` clause.

Example:

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

---

# 40. What is a CTE?

CTE stands for Common Table Expression.

Example:

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

It helps structure complex queries.

---

# 41. Does a CTE automatically materialize data?

No.

A CTE is primarily a named query expression.

SQL Server can integrate it into the broader execution plan.

Do not assume:

```text
CTE = temporary stored result
```

---

# 42. CTE vs temporary table?

A CTE:

- Exists for one statement
- Primarily organizes query logic
- Does not inherently materialize

A temporary table:

```sql
#TempTable
```

- Materializes rows in tempdb
- Can be reused across statements in its scope
- Can be indexed
- Can be useful for breaking complex processing into phases

Neither is universally faster.

---

# 43. UNION vs UNION ALL?

`UNION` combines results and removes duplicates.

`UNION ALL` combines results and preserves duplicates.

Because duplicate removal requires additional work, `UNION ALL` can be more efficient when deduplication is not required.

---

# 44. What does INTERSECT do?

`INTERSECT` returns distinct rows found in both result sets.

Conceptually:

```text
A ∩ B
```

---

# 45. What does EXCEPT do?

`EXCEPT` returns distinct rows found in the first set but not the second.

Conceptually:

```text
A - B
```

---

# 46. What requirements do SQL set operations have?

The queries must have:

- Same number of output columns
- Corresponding columns with compatible types
- Semantically meaningful column alignment

Column names are generally taken from the first query.

---

# 47. What is a window function?

A window function calculates across related rows without collapsing them into one row per group.

Example:

```sql
SUM(revenue) OVER ()
```

Unlike `GROUP BY`, the detail rows can remain.

---

# 48. GROUP BY vs window aggregate?

`GROUP BY` collapses rows.

Example:

```sql
SELECT
    customer_id,
    SUM(amount)
FROM ...
GROUP BY customer_id;
```

Window functions retain row grain:

```sql
SUM(amount) OVER
(
    PARTITION BY customer_id
)
```

---

# 49. ROW_NUMBER vs RANK vs DENSE_RANK?

`ROW_NUMBER()`:

```text
1, 2, 3, 4
```

Every row gets a unique sequence number.

`RANK()` with ties:

```text
1, 2, 2, 4
```

`DENSE_RANK()` with ties:

```text
1, 2, 2, 3
```

Choose based on business tie rules.

---

# 50. How do you get Top N per group?

Typical pattern:

```sql
WITH Ranked AS
(
    SELECT
        ...,
        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS rn
    FROM ...
)
SELECT *
FROM Ranked
WHERE rn <= 3;
```

Aggregate to the correct grain before ranking when necessary.

---

# 51. What does LAG do?

`LAG()` accesses a previous row within a window.

Example:

```sql
LAG(monthly_revenue) OVER
(
    ORDER BY revenue_month
)
```

Useful for growth calculations.

---

# 52. What does LEAD do?

`LEAD()` accesses a following row.

Example:

```sql
LEAD(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date
)
```

---

# 53. What is a running total?

Example:

```sql
SUM(monthly_revenue) OVER
(
    ORDER BY revenue_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

It accumulates values through the current row.

---

# 54. Why specify ROWS in a running total?

Explicit window frames make intended behavior clear.

For example:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

operates by physical rows in the ordered window.

Default frame behavior can differ, especially around ties.

---

# 55. What does NTILE do?

`NTILE(n)` divides ordered rows into approximately equal-sized groups.

Example:

```sql
NTILE(4) OVER
(
    ORDER BY revenue DESC
)
```

can create customer revenue quartiles.

It distributes rows, not equal amounts of revenue.

---

# 56. What is transaction revenue in this project?

Completed transaction revenue is:

```sql
SUM(oi.quantity * oi.unit_price)
```

where:

```sql
o.order_status = 'Completed'
```

`order_items.unit_price` is used because it represents transaction price.

---

# 57. Why not use products.price for historical revenue?

`products.price` represents the current product/catalog price.

It may change.

Historical revenue should use the price stored with the transaction:

```text
order_items.unit_price
```

---

# 58. How do you calculate average order value?

First identify the correct order grain.

Conceptually:

```text
Completed Revenue
-----------------
Completed Orders
```

Do not accidentally calculate average line-item value.

---

# 59. What is a repeat customer?

In this repository:

```text
Customer with at least 2 distinct Completed orders
```

Business definitions can differ, so document the definition.

---

# 60. What is RFM?

RFM means:

```text
Recency
Frequency
Monetary
```

Here:

```text
Recency = days since latest Completed order
Frequency = distinct Completed order count
Monetary = Completed revenue
```

---

# 61. Why not use GETDATE() for historical RFM data?

Using the current real-world date can make a historical training dataset appear artificially stale.

A reproducible reference date is:

```text
one day after the dataset's latest Completed order
```

---

# 62. What is a customer cohort?

A customer cohort is commonly defined by acquisition period.

In this repository:

```text
Month of first Completed order
```

---

# 63. What is cohort age?

```sql
DATEDIFF
(
    MONTH,
    cohort_month,
    activity_month
)
```

Meaning:

```text
0 = acquisition month
1 = next month
2 = two months later
```

---

# 64. Why deduplicate customer-month activity?

Retention normally counts active customers, not orders.

Five orders by one customer in a month still represent:

```text
one active customer in that month
```

---

# 65. Cohort retention vs consecutive-month retention?

Cohort retention asks:

> How many customers from a specific acquisition cohort remain active at each cohort age?

Consecutive-month retention asks:

> Of customers active this month, how many are active next month?

They answer different questions.

---

# 66. What is right-censoring?

Right-censoring occurs when future behavior cannot be observed because the dataset ends.

If June is the last month available, a June customer cannot fairly be labeled:

```text
not retained in July
```

when July data does not exist.

---

# 67. What is churn?

There is no universal churn definition.

Examples:

```text
No activity for 30 days
No activity for 90 days
No next-month purchase
Subscription cancellation
```

The business definition must be explicit.

---

# 68. What is a funnel?

A funnel measures progression through ordered stages.

Repository example:

```text
Registered
Placed Any Order
Completed Customer
Repeat Customer
```

Expected:

```text
Registered >= Ordered >= Completed >= Repeat
```

---

# 69. What is estimated gross profit here?

```text
Revenue - Estimated Cost
```

or:

```sql
SUM
(
    quantity * (unit_price - products.cost)
)
```

for Completed sales.

---

# 70. Why is historical gross profit only estimated?

The schema stores transaction-time selling price but not transaction-time cost.

Current:

```text
products.cost
```

may differ from the cost that existed when the order occurred.

---

# 71. What is a transaction?

A database transaction groups operations into a logical unit of work.

The intended outcome is generally:

```text
all succeed
or
all fail
```

---

# 72. What does BEGIN TRANSACTION do?

It starts an explicit transaction:

```sql
BEGIN TRANSACTION;
```

Changes remain part of that transaction until it is committed or rolled back.

---

# 73. COMMIT vs ROLLBACK?

`COMMIT` makes successful transactional changes permanent.

`ROLLBACK` undoes transactional changes that have not been committed.

---

# 74. What is ACID?

ACID stands for:

```text
Atomicity
Consistency
Isolation
Durability
```

---

# 75. What is Atomicity?

The transaction behaves as one unit.

For an order workflow:

```text
create order
insert item
reduce stock
```

should not leave only part of the required operation completed.

---

# 76. What is Consistency?

A transaction should move the database between valid states.

Consistency is supported by:

- Constraints
- Data types
- Foreign keys
- Application/business rules
- Correct transactional logic

---

# 77. What is Isolation?

Isolation determines how concurrent transactions observe/interact with one another.

It affects phenomena such as:

```text
Dirty reads
Non-repeatable reads
Phantom reads
Blocking
```

---

# 78. What is Durability?

After a successful commit, SQL Server's logging/recovery mechanisms ensure committed data survives failures according to its durability guarantees.

---

# 79. What is autocommit?

Without an explicit active transaction, SQL Server normally treats each individual modification statement as its own transaction.

Successful statements are automatically committed.

---

# 80. What is @@TRANCOUNT?

`@@TRANCOUNT` returns the number of active `BEGIN TRANSACTION` levels in the current session.

Example:

```sql
SELECT @@TRANCOUNT;
```

---

# 81. Are SQL Server nested transactions independent?

No.

Multiple `BEGIN TRANSACTION` calls increment `@@TRANCOUNT`, but inner transactions are not independent durable units.

An inner `COMMIT` normally just decrements `@@TRANCOUNT`.

Only the outermost commit actually commits the transaction.

---

# 82. What is a savepoint?

A savepoint marks a point inside a transaction:

```sql
SAVE TRANSACTION MySavepoint;
```

You can roll back to it:

```sql
ROLLBACK TRANSACTION MySavepoint;
```

without necessarily rolling back all earlier transaction work.

---

# 83. What is XACT_STATE()?

It indicates transaction state:

```text
 1 = active and committable
 0 = no active transaction
-1 = active but uncommittable
```

Common cleanup:

```sql
IF XACT_STATE() <> 0
    ROLLBACK TRANSACTION;
```

---

# 84. What does SET XACT_ABORT ON do?

```sql
SET XACT_ABORT ON;
```

causes many runtime errors to terminate and roll back the transaction automatically.

It is commonly used with explicit transactions and TRY/CATCH.

---

# 85. What is a robust transaction template?

```sql
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- database changes

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

---

# 86. What does THROW do?

`THROW` raises an error.

Example:

```sql
THROW 50001, 'Insufficient inventory.', 1;
```

Inside `CATCH`, plain:

```sql
THROW;
```

rethrows the original error.

---

# 87. What is @@ROWCOUNT?

It contains the number of rows affected by the immediately preceding statement.

Example:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;

IF @@ROWCOUNT = 0
    THROW 50001, 'Insufficient stock.', 1;
```

Capture/check it immediately because subsequent statements can change it.

---

# 88. What is SCOPE_IDENTITY()?

It returns the most recent identity generated in the current scope.

Example:

```sql
INSERT INTO training.orders (...);

DECLARE @OrderId INT =
    CONVERT(INT, SCOPE_IDENTITY());
```

It is commonly used to capture a newly inserted parent key.

---

# 89. Why is this inventory UPDATE safer?

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;
```

The stock validation and modification occur atomically in one statement.

A separate:

```text
SELECT stock
application check
UPDATE stock
```

can introduce a race between the read and modification.

---

# 90. What is a dirty read?

A dirty read occurs when one transaction reads another transaction's uncommitted change.

If that change is later rolled back, the reader observed data that never became committed state.

---

# 91. Which isolation level allows dirty reads?

```text
READ UNCOMMITTED
```

It provides weak isolation and can observe uncommitted changes.

---

# 92. What is a non-repeatable read?

A transaction reads one row twice and sees different committed values because another transaction changed the row between those reads.

---

# 93. What is a phantom read?

A transaction repeats a predicate query and sees new or missing matching rows because another transaction inserted/deleted qualifying data.

---

# 94. What are common SQL Server isolation levels?

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SNAPSHOT
SERIALIZABLE
```

---

# 95. What is SQL Server's common default isolation level?

Typically:

```text
READ COMMITTED
```

Database options such as `READ_COMMITTED_SNAPSHOT` can alter how READ COMMITTED obtains consistent reads.

---

# 96. What is blocking?

Blocking occurs when one session waits because another session holds an incompatible lock/resource.

Blocking is a normal concurrency mechanism, although excessive blocking can become a performance problem.

---

# 97. What is a deadlock?

A deadlock occurs when sessions form a circular dependency.

Example:

```text
Transaction A holds Product 1 and waits for Product 2.

Transaction B holds Product 2 and waits for Product 1.
```

SQL Server detects the cycle and chooses a deadlock victim.

---

# 98. How can you reduce deadlock risk?

Common techniques:

- Keep transactions short
- Access resources in consistent order
- Use appropriate indexes
- Touch only required rows
- Avoid unnecessary transaction scope
- Use suitable retry logic for deadlock victims

---

# 99. Why keep transactions short?

Long transactions can:

- Hold locks longer
- Increase blocking
- Increase transaction-log pressure
- Increase contention
- Increase deadlock opportunities

Do not hold a database transaction open while waiting unnecessarily for humans or external services.

---

# 100. What is an index?

An index is a database structure that can improve data-access patterns.

It can support operations such as:

```text
WHERE
JOIN
ORDER BY
GROUP BY
```

Indexes consume storage and add write-maintenance cost.

---

# 101. Clustered vs nonclustered index?

A clustered index is the main B-tree structure whose leaf level is the table data.

A table can have at most one clustered index.

A nonclustered index is a separate structure containing index keys plus row locators and optionally included columns.

A table can have multiple nonclustered indexes.

---

# 102. What is a heap?

A heap is a SQL Server table without a clustered index.

---

# 103. What is an Index Seek?

A seek navigates through an index to a relevant key/range rather than reading the entire index.

A seek is not automatically fast.

---

# 104. What is an Index Scan?

A scan reads a broad portion, possibly all, of an index.

A scan is not automatically bad.

If a query needs most rows, scanning may be optimal.

---

# 105. Why isn't "seek good, scan bad" correct?

A seek retrieving millions of rows can be expensive.

A scan of a tiny table can be extremely cheap.

Evaluate:

```text
Rows processed
Pages read
Lookups
CPU
Elapsed time
Workload frequency
```

not operator labels alone.

---

# 106. What is selectivity?

Selectivity describes how strongly a predicate reduces rows.

Example:

```sql
WHERE order_id = 123
```

is often highly selective.

A predicate matching 95% of a table is not.

Selectivity affects index usefulness.

---

# 107. What is a composite index?

An index with multiple key columns.

Example:

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders(customer_id, order_date);
```

Column order matters.

---

# 108. Why does composite index key order matter?

For:

```text
(customer_id, order_date)
```

the structure is ordered first by customer and then by date within customer.

That aligns naturally with:

```sql
WHERE customer_id = @CustomerId
  AND order_date >= @StartDate
```

A query using only `order_date` has a different access pattern.

---

# 109. What is the equality-before-range heuristic?

For:

```sql
WHERE customer_id = @CustomerId
  AND order_date >= @StartDate
```

a useful candidate is:

```text
(customer_id, order_date)
```

because:

```text
customer_id = equality
order_date = range
```

It is a heuristic, not a universal law.

---

# 110. What does INCLUDE do?

`INCLUDE` adds non-key columns to a nonclustered index's leaf level.

Example:

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id)
INCLUDE(order_date, order_status);
```

It can help cover a query without adding every output column to the key.

---

# 111. What is a covering index?

An index covers a query when it contains the information required to satisfy the query without retrieving missing columns from another structure.

---

# 112. What is a Key Lookup?

A Key Lookup occurs when SQL Server uses a nonclustered index to find rows, then accesses the clustered index for missing columns.

A few lookups can be cheap.

Large numbers of lookups can become expensive.

---

# 113. What is SARGability?

SARGable predicates allow SQL Server to use searchable index key/range conditions effectively.

Good:

```sql
WHERE order_date >= '20250101'
```

Less index-friendly:

```sql
WHERE YEAR(order_date) = 2025
```

---

# 114. Why can a leading wildcard hurt index searching?

This has a known prefix:

```sql
LIKE 'Ah%'
```

This does not:

```sql
LIKE '%med'
```

A standard B-tree cannot directly navigate to a useful starting key when the prefix is unknown.

---

# 115. What is an implicit conversion?

SQL Server may automatically convert one operand when different data types are compared.

Conversions can:

- Add CPU cost
- Affect estimates
- Interfere with index access in some situations

Parameter and column data types should generally align.

---

# 116. What is an execution plan?

An execution plan describes the physical operations SQL Server uses to execute a query.

Common operators include:

```text
Index Seek
Index Scan
Key Lookup
Nested Loops
Hash Match
Merge Join
Sort
Stream Aggregate
Hash Aggregate
```

---

# 117. Estimated vs actual execution plan?

An estimated plan is created without executing the query.

An actual plan is collected during execution and contains runtime information such as actual row counts.

---

# 118. Why compare estimated vs actual rows?

The optimizer makes decisions based on estimates.

Large differences can contribute to:

- Poor join strategies
- Poor memory grants
- Wrong access strategies
- Unexpected operator behavior

---

# 119. What are SQL Server statistics?

Statistics describe data distribution.

The optimizer uses them for cardinality estimation.

Better estimates help SQL Server compare possible execution strategies.

---

# 120. Statistics vs indexes?

Indexes provide physical access structures.

Statistics primarily provide distribution information for estimates.

They are related but different.

---

# 121. What does SET STATISTICS IO show?

Example:

```sql
SET STATISTICS IO ON;
```

It reports I/O-related information, including logical reads, in Messages.

It is useful for comparing query work.

---

# 122. What are logical reads?

Logical reads are database pages SQL Server accesses from the buffer cache while executing the query.

Reducing unnecessary logical reads can be an important optimization goal.

---

# 123. What does SET STATISTICS TIME show?

```sql
SET STATISTICS TIME ON;
```

provides CPU and elapsed-time information.

Timing should be measured carefully because runtime conditions can vary.

---

# 124. What is a cold vs warm cache?

Cold-cache execution may require more physical I/O.

Warm-cache execution can reuse data already present in memory.

Plan compilation/cache state can also cause first and later executions to differ.

---

# 125. What are common join algorithms?

SQL Server commonly uses:

```text
Nested Loops
Hash Match
Merge Join
```

None is universally best.

---

# 126. When are Nested Loops useful?

Often when:

- Outer input is relatively small
- Inner side has efficient lookup access
- Relatively few matching rows are expected

---

# 127. When is a Hash Join useful?

Often for larger unsorted equality joins.

It builds a hash structure from one input and probes it with the other.

Hash operations can require significant memory.

---

# 128. When can Merge Join be useful?

When both inputs are appropriately ordered on the join keys.

Indexes can sometimes provide the necessary order.

---

# 129. What is a memory grant?

Certain operators request execution memory.

Examples:

```text
Sort
Hash Join
Hash Aggregate
```

SQL Server estimates the amount of memory required.

---

# 130. What is a tempdb spill?

When an operator cannot perform all its work in granted memory, it may write intermediate data to tempdb.

Sort and hash spills can hurt performance.

Actual execution plans can reveal spill warnings.

---

# 131. What is parameter sensitivity?

Different parameter values can require very different optimal execution strategies.

Example:

```text
Customer A -> 2 rows
Customer B -> 5,000,000 rows
```

One reusable plan may not be ideal for both.

---

# 132. What is OPTION (RECOMPILE)?

Example:

```sql
SELECT ...
WHERE customer_id = @CustomerId
OPTION (RECOMPILE);
```

It requests compilation for that execution.

It can help some parameter-sensitive workloads but adds compilation cost.

It should not be used automatically.

---

# 133. Should you automatically create missing-index suggestions?

No.

Missing-index recommendations are clues.

Evaluate:

- Existing indexes
- Overlap
- Query importance
- Read benefit
- Write cost
- Storage
- Full workload impact

---

# 134. What is over-indexing?

Over-indexing means maintaining more indexes than the workload justifies.

Costs include:

```text
Storage
Memory
INSERT cost
UPDATE cost
DELETE cost
Maintenance
Transaction-log work
```

---

# 135. What is a filtered index?

A filtered index indexes only rows matching a predicate.

Example:

```sql
CREATE INDEX IX_products_active_category
ON training.products(category)
WHERE is_active = 1;
```

It can be smaller and more focused for suitable workloads.

---

# 136. Why can an index help ORDER BY?

If the index key ordering matches filtering and requested ordering, SQL Server may be able to return rows in the required order without a separate Sort.

Example candidate:

```text
(customer_id, order_date)
```

for:

```sql
WHERE customer_id = ...
ORDER BY order_date
```

---

# 137. What is index fragmentation?

Index pages can become logically/physically fragmented as data changes.

SQL Server supports operations such as:

```text
REORGANIZE
REBUILD
```

Do not base maintenance decisions solely on fragmentation percentage.

Index size and workload matter.

---

# 138. What is fill factor?

Fill factor controls how full index leaf pages are made during index creation/rebuild.

Lower fill factor leaves more free space but increases page count and storage.

There is no universal ideal value.

---

# 139. Why can DISTINCT be a performance smell?

`DISTINCT` can require duplicate-removal work.

More importantly, it can hide an incorrect join or misunderstood result grain.

First determine why duplicates exist.

---

# 140. EXISTS vs JOIN for existence checks?

If the requirement is:

> Return customers that have at least one order

`EXISTS` expresses that requirement naturally:

```sql
WHERE EXISTS (...)
```

A join can multiply customers when they have multiple orders.

Do not assume one syntax is always physically faster; SQL Server may transform logically equivalent forms.

---

# 141. Why can pre-aggregation help?

If millions of detail rows can be reduced to a smaller grain before later operations, subsequent work may become smaller.

Example:

```text
order_items
    ->
one row per order
    ->
join
```

But measure the plan; pre-aggregation is not automatically faster.

---

# 142. What is the first thing to do when tuning a slow query?

Establish what the query is supposed to return and capture a baseline.

Record information such as:

```text
Query
Parameters
Actual execution plan
Logical reads
CPU
Elapsed time
Row count
Relevant indexes
```

---

# 143. What is a good tuning workflow?

A practical workflow:

```text
1. Identify important workload
2. Verify correctness
3. Establish baseline
4. Inspect actual plan
5. Inspect logical reads
6. Compare estimated vs actual rows
7. Identify unnecessary work
8. Form a hypothesis
9. Make one targeted change
10. Measure again
11. Verify correctness
12. Evaluate broader workload impact
```

---

# 144. Why shouldn't optimization focus only on query duration?

A query can finish quickly but still:

- Run millions of times
- Consume excessive CPU
- Cause blocking
- Require large memory grants
- Generate excessive reads

Optimization is workload-level analysis.

---

# 145. What are common SQL performance anti-patterns?

Examples:

```text
SELECT * everywhere
Functions on searchable columns
Implicit conversions
Leading wildcard searches
Unnecessary DISTINCT
Incorrect joins
Missing join predicates
Returning unnecessary rows
Blind index creation
Too many indexes
Blind query hints
Ignoring execution plans
Tuning without measurement
```

---

# 146. Query hint or index improvement first?

Normally investigate:

```text
Correctness
Query structure
SARGability
Indexes
Statistics
Cardinality estimates
Data distribution
```

before forcing optimizer decisions with hints.

Hints can become inappropriate as data changes.

---

# 147. Why does business logic matter during optimization?

A query that is twice as fast but returns the wrong revenue is not optimized.

Performance tuning must preserve:

```text
Correct business definition
Correct result grain
Correct NULL behavior
Correct date logic
Correct transaction semantics
```

---

# 148. How would you calculate Completed revenue safely?

```sql
SELECT
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
```

Important decisions:

```text
Completed only
transaction unit_price
correct join
```

---

# 149. How would you find customers who never ordered?

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

`NOT EXISTS` expresses the anti-join requirement directly.

---

# 150. How would you return the latest order per customer?

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

The `order_id` tie breaker makes the choice deterministic when order dates tie.

---

# Practical Interview Checklist

Before a SQL interview, be comfortable explaining and writing examples for:

```text
SELECT / WHERE / ORDER BY
NULL handling
GROUP BY / HAVING
COUNT / SUM / AVG
INNER / LEFT JOIN
Result grain
Row multiplication
CASE
COALESCE / NULLIF
Date ranges
Subqueries
EXISTS / NOT EXISTS
CTEs
UNION / UNION ALL
Window functions
ROW_NUMBER / RANK / DENSE_RANK
LAG / LEAD
Running totals
Top N per group
Revenue analysis
Customer metrics
RFM
Cohorts
Retention
Transactions
TRY/CATCH
ACID
Isolation levels
Blocking / deadlocks
Indexes
SARGability
Execution plans
Statistics
Logical reads
Query tuning
```

---

# Common Interview Mistakes

Avoid statements such as:

```text
"CTEs are faster than subqueries."

"EXISTS is always faster than IN."

"Index seeks are always good."

"Index scans are always bad."

"Every foreign key automatically gets an index."

"More indexes always improve performance."

"READ UNCOMMITTED is a good way to fix blocking."

"DISTINCT fixes duplicate joins."

"LEFT JOIN always keeps all left rows."

"COUNT(*) and COUNT(column) are identical."

"NULL equals NULL."

"YEAR(date_column) is always fine for indexed filtering."

"Revenue should use the current product price."

"One SQL transaction should remain open across an entire business workflow."
```

These statements ignore important context or are incorrect.

---

# Strong Interview Answer Pattern

For many SQL interview questions, a strong explanation follows this structure:

```text
1. Define the concept.
2. Explain why it matters.
3. Give a concise SQL example.
4. Mention an important edge case.
5. Discuss performance only after correctness.
```

For example, if asked about `LEFT JOIN`, do not stop at:

> It returns all rows from the left.

Also explain that a predicate on the right table in `WHERE` can remove NULL-extended rows and change the effective result.

---

# Final Review

A strong SQL developer should be able to reason through this sequence:

```text
What does one output row represent?
        |
        v
Which source tables are required?
        |
        v
What are the relationships?
        |
        v
Which rows qualify?
        |
        v
Could joins multiply entities?
        |
        v
What aggregation is required?
        |
        v
How should NULL and dates behave?
        |
        v
How do I validate the result?
        |
        v
What work is SQL Server performing?
        |
        v
Can that work be reduced safely?
```

SQL interviews increasingly test reasoning rather than memorization.

Knowing syntax matters, but being able to explain correctness, grain, concurrency, and performance trade-offs is what turns syntax knowledge into practical SQL skill.