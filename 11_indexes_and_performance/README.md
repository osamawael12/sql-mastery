# Indexes and SQL Performance
# Chapter 11 — Indexes and Query Performance

## Overview

Writing a query that returns the correct result is only part of SQL mastery.

As data grows, we also need to understand:

- How SQL Server finds rows
- Why some queries are fast and others are slow
- How indexes work
- Clustered vs nonclustered indexes
- Index seeks vs index scans
- Key lookups
- Covering indexes
- Composite indexes
- Included columns
- SARGability
- Execution plans
- Statistics
- Cardinality estimation
- Query cost
- Logical reads
- Index maintenance
- Over-indexing
- Query optimization workflow

This chapter focuses on practical SQL Server performance analysis rather than blindly adding indexes.

Database used throughout:

```sql
USE SQLMastery;
GO
```

Primary schema:

```text
training
```

Core tables:

```text
training.customers
training.products
training.orders
training.order_items
```

---

# 1. Why Performance Matters

A query may work perfectly with 100 rows and perform badly with 100 million rows.

Performance becomes increasingly important as:

- Tables grow
- More users access the system
- Reports become more complex
- Joins involve larger datasets
- Aggregations process more rows
- Applications require lower latency
- Concurrent workloads increase

Optimization is therefore not simply about making SQL "shorter."

The real goal is usually:

> Reduce unnecessary work while preserving correctness.

---

# 2. How SQL Server Executes a Query

When SQL Server receives a query, it does not simply read the SQL text from top to bottom and execute it literally.

At a high level:

```text
SQL Query
    |
    v
Parser / Binder
    |
    v
Query Optimizer
    |
    v
Execution Plan
    |
    v
Execution Engine
    |
    v
Result
```

The query optimizer considers possible strategies and selects an execution plan based on estimated cost.

Examples of decisions include:

- Which table to access first
- Whether to scan or seek
- Which index to use
- Which join algorithm to use
- Whether sorting is required
- Whether an aggregation needs additional operators

---

# 3. What Is an Index?

An index is a database structure designed to make certain data-access patterns more efficient.

A useful analogy is the index at the back of a book.

Without an index, finding a topic may require reading the whole book.

With an index, you can often navigate much more directly to the relevant location.

SQL Server indexes can help with operations such as:

```sql
WHERE
JOIN
ORDER BY
GROUP BY
```

But an index is not free.

Indexes require:

- Disk/storage space
- Maintenance
- Additional work during INSERT
- Additional work during UPDATE
- Additional work during DELETE

So the goal is not:

> Create as many indexes as possible.

The goal is:

> Create useful indexes for important access patterns.

---

# 4. Heap vs Clustered Table

A SQL Server table can be stored as:

```text
Heap
```

or have a:

```text
Clustered Index
```

A heap is a table without a clustered index.

A clustered index organizes the table's data pages according to the clustered index key structure.

A table can have only one clustered index because the table's rows themselves are organized through that structure.

---

# 5. Clustered Index

A clustered index determines the primary index structure through which the table data is stored and accessed.

A common example is a primary key implemented as a clustered index:

```sql
CREATE TABLE dbo.example
(
    id INT IDENTITY(1,1)
        CONSTRAINT PK_example PRIMARY KEY CLUSTERED,

    name VARCHAR(100)
);
```

A table can have:

```text
At most one clustered index
```

A good clustered key is often:

- Narrow
- Stable
- Unique or close to unique
- Frequently useful for access
- Preferably increasing for many common OLTP designs

However, clustered key selection depends on the workload.

---

# 6. Nonclustered Index

A table can have multiple nonclustered indexes.

Example:

```sql
CREATE INDEX IX_customers_city
ON training.customers(city);
```

This creates a separate index structure useful for queries involving `city`.

For example:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE city = 'Cairo';
```

SQL Server may choose the new index if the optimizer estimates it to be beneficial.

---

# 7. Index Seek

An Index Seek means SQL Server can navigate into an index to find a relevant key range rather than reading the entire structure.

Conceptually:

```text
Index
 |
 +-- Cairo
 +-- Giza
 +-- Mansoura
 +-- Alexandria
```

For:

```sql
WHERE city = 'Cairo'
```

SQL Server may be able to navigate directly to the relevant part of the index.

A seek is often efficient, but:

> Seek does not automatically mean fast.

A seek returning millions of rows can still be expensive.

---

# 8. Index Scan

An Index Scan means SQL Server reads a larger portion of an index, potentially all of it.

A scan is not automatically bad.

For example:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers;
```

If most or all rows are required, scanning can be the correct strategy.

Therefore:

```text
Seek = not automatically good
Scan = not automatically bad
```

Always consider the amount of work and the query requirement.

---

# 9. Table Scan

A heap may require a Table Scan when SQL Server needs to inspect its rows.

For large tables and selective predicates, this may become expensive.

Execution plans help identify when scans occur and why.

---

# 10. Selectivity

Selectivity describes how strongly a predicate reduces the number of rows.

For example:

```sql
WHERE order_id = 100
```

may return one row.

That is highly selective.

But:

```sql
WHERE order_status = 'Completed'
```

may return a large percentage of the table.

That predicate may have low selectivity.

Index usefulness often depends heavily on selectivity.

---

# 11. Composite Indexes

An index can contain multiple key columns.

Example:

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders(customer_id, order_date);
```

This can be useful for:

```sql
WHERE customer_id = 1
  AND order_date >= '2025-01-01'
```

Column order matters.

The index:

```text
(customer_id, order_date)
```

is not equivalent to:

```text
(order_date, customer_id)
```

---

# 12. Leftmost Key Principle

For an index:

```sql
(customer_id, order_date)
```

SQL Server can commonly use its ordered key structure efficiently for predicates beginning with:

```sql
customer_id
```

Examples:

```sql
WHERE customer_id = 1
```

and:

```sql
WHERE customer_id = 1
  AND order_date >= '2025-01-01'
```

But this query:

```sql
WHERE order_date >= '2025-01-01'
```

cannot generally seek into that index based on the second key alone in the same way.

This is why composite index column order matters.

---

# 13. Equality Before Range

A common composite-index design pattern is:

```text
Equality columns
then
Range columns
```

Example query:

```sql
WHERE customer_id = 1
  AND order_date >= '2025-01-01'
```

Potential index:

```sql
(customer_id, order_date)
```

Here:

```text
customer_id = equality
order_date  = range
```

This is a useful heuristic, not an absolute rule.

Index design should consider the entire workload.

---

# 14. Included Columns

Sometimes columns are needed by the query output but are not good index key columns.

SQL Server supports:

```sql
INCLUDE
```

Example:

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders(customer_id, order_date)
INCLUDE (order_status);
```

Here:

```text
Index keys:
customer_id
order_date

Included column:
order_status
```

Included columns can help an index cover a query without making every output column part of the key.

---

# 15. Covering Index

A covering index contains everything SQL Server needs for a query.

Suppose the query is:

```sql
SELECT
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
```

An index such as:

```sql
CREATE INDEX IX_orders_customer_cover
ON training.orders(customer_id)
INCLUDE (order_date, order_status);
```

may cover the query.

SQL Server may not need to access another structure to retrieve missing columns.

---

# 16. Key Lookup

Suppose a nonclustered index helps SQL Server find qualifying rows, but the query needs additional columns not present in that index.

SQL Server may perform a:

```text
Key Lookup
```

Conceptually:

```text
Nonclustered Index
        |
        v
Find matching row references
        |
        v
Clustered Index
        |
        v
Retrieve missing columns
```

For a small number of rows, this can be efficient.

For many rows, repeated lookups can become expensive.

---

# 17. Index Design Trade-Off

Suppose we have:

```sql
SELECT
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
```

Index:

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id);
```

This may locate the customer efficiently, but SQL Server may need lookups for:

```text
order_date
order_status
```

A possible alternative:

```sql
CREATE INDEX IX_orders_customer
ON training.orders(customer_id)
INCLUDE (order_date, order_status);
```

But adding included columns also makes the index larger.

Optimization always involves trade-offs.

---

# 18. SARGability

SARG stands roughly for:

```text
Search ARGument
```

A SARGable predicate allows SQL Server to use an index efficiently for searching.

Example:

```sql
WHERE order_date >= '2025-01-01'
```

This is generally SARGable.

---

# 19. Non-SARGable Predicate

This pattern can prevent efficient index navigation:

```sql
WHERE YEAR(order_date) = 2025
```

SQL Server may need to evaluate:

```sql
YEAR(order_date)
```

for many rows.

A more index-friendly form is:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20260101'
```

The second version places the raw indexed column directly in a range predicate.

---

# 20. Why Date Ranges Matter

Instead of:

```sql
WHERE MONTH(order_date) = 1
  AND YEAR(order_date) = 2025
```

prefer:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20250201'
```

This pattern is also safer for `datetime` values because it avoids assumptions about the time portion.

---

# 21. Leading Wildcards

This predicate:

```sql
WHERE customer_name LIKE 'Ah%'
```

may be able to use an appropriate index efficiently.

But:

```sql
WHERE customer_name LIKE '%med'
```

or:

```sql
WHERE customer_name LIKE '%hme%'
```

normally cannot navigate a standard B-tree index directly to the starting point because the beginning of the value is unknown.

Leading wildcards can therefore make searches less index-friendly.

---

# 22. Functions on Indexed Columns

Be cautious with patterns such as:

```sql
WHERE UPPER(city) = 'CAIRO'
```

or:

```sql
WHERE YEAR(order_date) = 2025
```

or:

```sql
WHERE ISNULL(city, '') = 'Cairo'
```

Applying a function to the indexed column can make a predicate non-SARGable.

Sometimes query rewrites, computed columns, or different indexing strategies are appropriate.

---

# 23. Implicit Conversions

Data type mismatches can hurt performance.

For example, comparing columns and parameters with incompatible types may cause SQL Server to perform an implicit conversion.

This can:

- Increase CPU work
- Hurt cardinality estimation
- Prevent an efficient seek in some cases

Use appropriate and consistent data types whenever possible.

---

# 24. Execution Plans

An execution plan shows how SQL Server intends to execute, or actually executed, a query.

In SSMS you can use:

```text
Display Estimated Execution Plan
```

or:

```text
Include Actual Execution Plan
```

The plan can reveal operators such as:

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

---

# 25. Estimated vs Actual Execution Plan

An estimated plan is generated without executing the query.

An actual execution plan is collected when the query executes and includes runtime information.

Actual plans are especially useful for comparing:

```text
Estimated rows
vs
Actual rows
```

Large differences can signal estimation problems.

---

# 26. Reading an Execution Plan

Graphical SQL Server plans are typically read from:

```text
Right to left
```

and:

```text
Top to bottom
```

But do not focus only on the operator with the highest displayed percentage.

Also inspect:

- Actual rows
- Estimated rows
- Number of executions
- Predicates
- Seek predicates
- Warnings
- Memory behavior
- Sorts
- Lookups
- Scans
- Join strategy

---

# 27. Estimated Rows vs Actual Rows

Suppose SQL Server estimates:

```text
10 rows
```

but actually processes:

```text
1,000,000 rows
```

The optimizer selected its plan using the estimate.

A large estimation error can contribute to a poor execution strategy.

Possible causes include:

- Outdated statistics
- Data skew
- Complex predicates
- Correlated data
- Parameter sensitivity
- Non-SARGable expressions

---

# 28. Statistics

Statistics describe the distribution of data.

SQL Server uses statistics to estimate how many rows query operators are likely to process.

Good estimates help the optimizer choose between strategies such as:

```text
Index Seek
Index Scan
Nested Loops
Hash Join
Merge Join
```

Indexes generally have statistics on their key columns, and SQL Server may also create column statistics automatically depending on configuration.

---

# 29. Statistics Are Not Indexes

Indexes and statistics are related but different.

An index:

```text
Provides a physical access structure
```

Statistics:

```text
Provide information used for cardinality estimation
```

SQL Server can therefore have useful statistics without having an index that directly supports a query.

---

# 30. SET STATISTICS IO

One of the most useful tools for query-performance analysis is:

```sql
SET STATISTICS IO ON;
```

Example:

```sql
SET STATISTICS IO ON;

SELECT *
FROM training.orders;

SET STATISTICS IO OFF;
```

The Messages output contains information such as logical reads.

---

# 31. Logical Reads

Logical reads indicate pages SQL Server needed to access from the buffer cache for an operation.

When comparing equivalent queries, reducing unnecessary logical reads is often a useful optimization goal.

For example:

```text
Query A: 25,000 logical reads
Query B:    200 logical reads
```

If both queries are semantically equivalent, Query B may be doing much less I/O work.

But no single metric should be interpreted in isolation.

---

# 32. SET STATISTICS TIME

SQL Server also provides:

```sql
SET STATISTICS TIME ON;
```

This can show CPU and elapsed-time information.

Example:

```sql
SET STATISTICS TIME ON;

SELECT *
FROM training.orders;

SET STATISTICS TIME OFF;
```

Timing can vary between executions, so benchmark carefully.

---

# 33. Cold Cache vs Warm Cache

The first execution of a query and later executions can behave differently.

Reasons include:

- Data may already be in memory
- Execution plans may already be cached
- Compilation may already have occurred

Do not draw strong conclusions from a single timing measurement.

---

# 34. Avoid SELECT * When Unnecessary

Instead of:

```sql
SELECT *
FROM training.orders
WHERE customer_id = 1;
```

prefer selecting only what the application needs:

```sql
SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
```

Benefits can include:

- Less data transferred
- Smaller memory requirements
- More opportunities for covering indexes
- Clearer query intent

---

# 35. Filter Early — But Understand the Optimizer

SQL is declarative.

You describe the result rather than manually specifying every physical execution step.

The optimizer can push predicates and rearrange operations.

Therefore, performance tuning is not simply about writing a `WHERE` clause "earlier" in the text.

Use execution plans and measurements rather than relying on visual SQL ordering alone.

---

# 36. Indexes for JOIN Columns

Join columns are common index candidates.

For example:

```sql
training.orders.customer_id
training.order_items.order_id
training.order_items.product_id
```

These columns participate in relationships and joins.

However:

> A foreign key does not automatically mean SQL Server creates a supporting nonclustered index for it.

Foreign-key columns are often worth evaluating for indexing.

---

# 37. Indexes for Filtering

Frequently filtered columns may be good candidates.

Example:

```sql
WHERE customer_id = @CustomerId
```

Potential index:

```sql
(customer_id)
```

But indexing low-selectivity columns blindly can be inefficient.

For example:

```sql
is_active
```

may contain only:

```text
0
1
```

A standalone index on a low-cardinality column may or may not help depending on data distribution and query patterns.

---

# 38. Filtered Indexes

SQL Server supports filtered indexes.

Example:

```sql
CREATE INDEX IX_products_active
ON training.products(category)
WHERE is_active = 1;
```

A filtered index stores only rows satisfying its filter.

This can be useful when queries repeatedly target a well-defined subset of rows.

Filtered indexes are workload-specific and require careful matching between query predicates and the filter.

---

# 39. Unique Indexes

A unique index enforces uniqueness and provides an access path.

Example:

```sql
CREATE UNIQUE INDEX UX_customers_email
ON training.customers(email);
```

This can serve two purposes:

```text
Integrity
+
Performance
```

Whether this specific index is appropriate depends on the existing schema and constraints.

Always inspect existing keys/indexes before creating duplicates.

---

# 40. Finding Existing Indexes

SQL Server catalog views can inspect indexes.

Example:

```sql
SELECT
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('training.orders');
```

For deeper inspection, combine views such as:

```text
sys.indexes
sys.index_columns
sys.columns
```

---

# 41. Duplicate and Redundant Indexes

Suppose a table has:

```text
Index A: (customer_id)

Index B: (customer_id, order_date)
```

Index A might be redundant for some workloads.

But not always.

The smaller index could still provide benefits due to:

- Smaller size
- Lower I/O
- Different INCLUDE columns
- Different uniqueness
- Different filtering
- Different workload requirements

Never remove an index based only on superficial similarity.

---

# 42. Over-Indexing

Too many indexes can hurt write performance.

Consider an INSERT.

SQL Server may need to update:

```text
Table / clustered structure
Index 1
Index 2
Index 3
Index 4
...
```

More indexes can mean:

- More write I/O
- More storage
- More memory pressure
- More maintenance
- More potential locking work

Indexing is a read/write trade-off.

---

# 43. UPDATE Cost

An UPDATE can be particularly expensive when it changes an indexed column.

For example:

```sql
UPDATE training.products
SET category = 'Accessories'
WHERE product_id = 1;
```

If `category` participates in multiple indexes, SQL Server may need to maintain all affected index structures.

---

# 44. DELETE Cost

DELETE operations also require removal of relevant index entries.

Indexes accelerate many reads, but writes must maintain them.

This is why a heavily transactional system requires careful index design.

---

# 45. Index Fragmentation

Over time, index pages can become fragmented depending on workload and page splits.

SQL Server provides maintenance operations such as:

```text
REORGANIZE
REBUILD
```

However, blindly rebuilding every index on a schedule is not a performance strategy.

Maintenance should be based on:

- Workload
- Index size
- Fragmentation characteristics
- Storage
- Edition/version features
- Maintenance windows

---

# 46. Fill Factor

Fill factor controls how full SQL Server makes index leaf pages during index creation or rebuild.

Lower fill factors leave more free space for future inserts/updates but require more pages.

Trade-off:

```text
More free space
    ->
Potentially fewer page splits

but

More pages
    ->
Potentially more I/O and storage
```

There is no universal best fill factor.

---

# 47. Indexes and ORDER BY

An appropriate index can sometimes provide rows in the required order and avoid a separate Sort.

Example:

```sql
SELECT
    order_id,
    order_date
FROM training.orders
WHERE customer_id = 1
ORDER BY order_date;
```

Potential index:

```sql
(customer_id, order_date)
```

This can support both filtering and ordering.

---

# 48. Indexes and GROUP BY

Indexes can sometimes help aggregation by:

- Reducing rows before aggregation
- Providing useful ordering
- Covering required columns

But an index does not automatically make every `GROUP BY` fast.

The full query and data distribution matter.

---

# 49. Sort Operators

A Sort may appear for:

```sql
ORDER BY
GROUP BY
DISTINCT
window functions
merge joins
```

Sorting large datasets can consume significant:

- CPU
- Memory
- tempdb resources if spilling occurs

Execution plan warnings can help identify problematic sorts.

---

# 50. Memory Grants

Some operators require memory, including:

- Sort
- Hash Join
- Hash Aggregate

SQL Server estimates how much memory the query needs.

Bad row estimates can lead to:

```text
Too-small grant
    -> possible spills

Too-large grant
    -> wasted memory / reduced concurrency
```

This is another reason cardinality estimation matters.

---

# 51. Spills to tempdb

When an operation such as a Sort or Hash does not have enough memory, it may spill work to `tempdb`.

Spills can significantly increase query cost.

Actual execution plans can expose spill warnings.

A spill is a symptom to investigate, not a command to immediately add an index.

---

# 52. Join Algorithms

SQL Server commonly uses:

```text
Nested Loops
Hash Match
Merge Join
```

No algorithm is universally best.

The optimizer chooses based on factors such as:

- Estimated row counts
- Index availability
- Data ordering
- Join predicates
- Relative input sizes

---

# 53. Nested Loops

Nested Loops can work well when:

- One input is small
- The other side has efficient indexed access
- Few rows require repeated lookups

Conceptually:

```text
For each row from input A
    find matching rows in input B
```

---

# 54. Hash Join

Hash joins are often useful for larger unsorted inputs and equality joins.

Conceptually:

```text
Build hash structure from one input
Probe it using the other input
```

Hash operations can require significant memory.

Insufficient memory can contribute to tempdb spills.

---

# 55. Merge Join

Merge Join can be efficient when both inputs are appropriately ordered by the join keys.

Conceptually:

```text
Sorted A
+
Sorted B
    ->
Merge matching keys
```

An index may provide the needed order and avoid an extra Sort.

---

# 56. Parameter Sensitivity

A query may perform differently for different parameter values.

Example:

```sql
WHERE customer_id = @CustomerId
```

Perhaps:

```text
Customer 1 -> 5 rows
Customer 2 -> 5,000,000 rows
```

One cached plan may not be equally suitable for both cases.

This broad class of issues is commonly discussed under parameter sensitivity/parameter sniffing topics.

Do not assume every slow parameterized query is caused by parameter sniffing; diagnose it with plans and runtime evidence.

---

# 57. Query Plan Cache

SQL Server can cache execution plans and reuse them.

This avoids recompiling every query every time.

Plan reuse is generally valuable, but sometimes cached plans can become inappropriate due to:

- Parameter sensitivity
- Data distribution changes
- Statistics changes
- Schema/index changes

Plan cache behavior is an advanced optimization topic.

---

# 58. Missing Index Suggestions

Execution plans may contain missing-index suggestions.

These can be useful clues.

They are not commands.

Do not automatically create every suggested index.

Missing-index suggestions generally do not fully account for:

- Existing similar indexes
- Write cost
- Storage
- Index consolidation
- Broader workload needs
- All possible indexing strategies

Treat them as evidence, not final design decisions.

---

# 59. Query Hints

SQL Server supports hints such as:

```text
INDEX
FORCESEEK
HASH JOIN
LOOP JOIN
RECOMPILE
```

Hints can sometimes solve specific problems.

But forcing optimizer behavior without understanding the underlying issue can make performance less stable.

Prefer fixing:

- Query design
- Indexing
- Statistics
- SARGability
- Data model issues

before forcing plans unnecessarily.

---

# 60. Index Hints

Example syntax:

```sql
SELECT ...
FROM training.orders WITH (INDEX(index_name))
WHERE ...;
```

This tells SQL Server to use a specific index.

This should generally be avoided in basic tuning because data and workloads change.

An index that is good today may not be good tomorrow.

---

# 61. Query Optimization Is Measurement-Driven

A productive tuning workflow looks like:

```text
1. Identify a real slow/expensive query
2. Establish a baseline
3. Inspect the execution plan
4. Inspect logical reads
5. Inspect row estimates
6. Identify unnecessary work
7. Form a hypothesis
8. Make one targeted change
9. Measure again
10. Verify correctness
11. Evaluate impact on the broader workload
```

Avoid optimizing from intuition alone.

---

# 62. Baseline Before Optimization

Before changing a query or index, record:

- Query text
- Parameters
- Execution plan
- Logical reads
- CPU time
- Elapsed time
- Row count
- Relevant indexes

Without a baseline, you may not know whether your change actually improved anything.

---

# 63. Correctness Comes First

These two queries are not comparable merely because one is faster if they return different results.

Performance tuning must preserve:

```text
Business meaning
+
Correct result
```

Never change query semantics just to reduce execution time unless the business requirement itself changes.

---

# 64. Small Training Tables Warning

The `SQLMastery` training tables are intentionally small.

With only a few rows, SQL Server may correctly choose a scan even when an index exists.

For example:

```text
Scanning 5 rows
```

may be cheaper than navigating an index.

Therefore, do not interpret a scan on this training database as proof that an index is bad.

The examples teach mechanics and analysis techniques.

Real performance behavior becomes much clearer with larger datasets.

---

# 65. Testing Indexes Safely

Before creating an index, inspect whether it already exists.

Example:

```sql
SELECT
    i.name,
    i.type_desc
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('training.orders');
```

When creating experimental indexes, use clear names:

```text
IX_orders_customer_date
IX_order_items_product
IX_products_category_price
```

And clean them up when the experiment is complete if they are not intended to remain.

---

# 66. DROP INDEX

Syntax:

```sql
DROP INDEX IX_orders_customer_date
ON training.orders;
```

For training examples, check existence first when appropriate:

```sql
IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_orders_customer_date'
      AND object_id = OBJECT_ID('training.orders')
)
BEGIN
    DROP INDEX IX_orders_customer_date
    ON training.orders;
END;
```

---

# 67. Index Creation Is DDL

Remember that:

```sql
CREATE INDEX
DROP INDEX
ALTER INDEX
```

are schema/index operations.

Do not treat production index changes casually.

Large index operations can consume:

- CPU
- Memory
- I/O
- Transaction log space
- Time
- Locks/resources

Production changes require planning.

---

# 68. Practical Example: Customer Orders

Query:

```sql
SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1
ORDER BY order_date DESC;
```

Potential index:

```sql
CREATE INDEX IX_orders_customer_date
ON training.orders(customer_id, order_date DESC)
INCLUDE (order_status);
```

This index may support:

```text
Filtering by customer
+
Ordering by date
+
Returning order_status
```

Whether SQL Server chooses it still depends on cost and table size.

---

# 69. Practical Example: Product Sales

Query:

```sql
SELECT
    product_id,
    SUM(quantity) AS units_sold
FROM training.order_items
GROUP BY product_id;
```

Possible index considerations include:

```text
product_id
quantity
```

For example:

```sql
CREATE INDEX IX_order_items_product
ON training.order_items(product_id)
INCLUDE (quantity);
```

This may provide a narrower structure covering the aggregation.

Again, test rather than assume.

---

# 70. Practical Example: Date Filtering

Less index-friendly:

```sql
SELECT *
FROM training.orders
WHERE YEAR(order_date) = 2025;
```

More SARGable:

```sql
SELECT *
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20260101';
```

If date filtering is an important workload, an index beginning with `order_date` may become useful.

---

# 71. Practical Example: Revenue Query

Business query:

```sql
SELECT
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id;
```

Performance questions include:

- How many orders are Completed?
- Which table should be accessed first?
- Are join columns indexed?
- How selective is `order_status`?
- How many order items exist per order?
- Can useful indexes cover required columns?
- Are row estimates accurate?

There is no universally correct index without understanding the workload and data distribution.

---

# 72. Performance Anti-Patterns

Common anti-patterns include:

```text
SELECT * everywhere
Functions on searchable columns
Unnecessary DISTINCT
Unnecessary sorting
Leading wildcard searches
Implicit conversions
Row-by-row processing when set-based logic is possible
Missing join predicates
Over-indexing
Blind index creation
Blind use of hints
Ignoring execution plans
Optimizing without measuring
```

---

# 73. DISTINCT Is Not a Join Fix

Suppose a bad join creates duplicate rows.

Do not automatically write:

```sql
SELECT DISTINCT ...
```

to hide the problem.

The duplicates may reflect:

- Incorrect join conditions
- Incorrect result grain
- Real one-to-many relationships

Understand why duplicates exist first.

`DISTINCT` also requires additional processing in many cases.

---

# 74. Result Grain Still Matters

Performance tuning does not replace the concepts learned earlier.

Before optimization, know the intended result grain.

Examples:

```text
One row per customer
One row per order
One row per product
One row per customer-month
```

Incorrect grain can produce both incorrect results and unnecessary processing.

---

# 75. Performance and Window Functions

Window functions often require:

```text
Partitioning
Ordering
Sorting
```

For example:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY order_date DESC
)
```

An index such as:

```text
(customer_id, order_date DESC)
```

can sometimes support the access/order pattern.

But the exact benefit depends on the full query.

---

# 76. Pre-Aggregation

Sometimes aggregating before a large join reduces work.

Example idea:

```text
Millions of order_items
    |
Aggregate to order_id
    |
Join smaller result to orders
```

This is not always necessary because SQL Server can transform queries internally.

Still, understanding the grain at every stage can reveal major optimization opportunities.

---

# 77. EXISTS vs JOIN

For existence checks:

```sql
WHERE EXISTS (...)
```

often communicates the requirement clearly.

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

Do not assume `EXISTS` is always faster than a join.

The optimizer can often transform logically equivalent expressions.

Choose clear semantics, then measure.

---

# 78. EXISTS vs IN

Modern SQL Server can often optimize both effectively.

Performance depends on:

- Data
- Nullability
- Indexes
- Query shape
- Estimates

Remember the semantic caveats around:

```sql
NOT IN
```

when NULL values can appear.

Correctness comes before micro-optimization.

---

# 79. CTE Performance

A CTE is primarily a query-expression tool.

It does not automatically materialize results.

Example:

```sql
WITH x AS
(
    SELECT ...
)
SELECT ...
FROM x;
```

Do not assume a CTE automatically stores intermediate rows or makes a query faster.

CTEs improve structure and readability but still need normal performance analysis.

---

# 80. Temporary Results

For complex workloads, intermediate results can sometimes be stored in:

```text
#temporary tables
table variables
```

This can occasionally improve performance by:

- Breaking a complex plan into phases
- Allowing intermediate indexing
- Providing useful statistics behavior depending on object/type/version

But it adds writing and tempdb work.

Use this technique only when measurements justify it.

---

# 81. Performance Tuning Questions

When investigating a query, ask:

```text
What is the intended result grain?

How many rows are being read?

How many rows are returned?

Which predicates are selective?

Are predicates SARGable?

Are join columns indexed appropriately?

Are there expensive lookups?

Are estimates close to actual rows?

Are there Sort or Hash spills?

Is the query returning unnecessary columns?

Are existing indexes redundant?

Will a new index hurt writes?

Is the problem actually concurrency rather than query speed?
```

---

# 82. Performance vs Concurrency

A query can be individually fast but cause system problems if it:

- Holds locks for too long
- Runs extremely frequently
- Consumes too much memory
- Produces blocking
- Uses excessive CPU across many sessions

Performance tuning is therefore broader than reducing one query's elapsed time.

Chapter 10's transaction/concurrency concepts directly connect to this chapter.

---

# 83. Do Not Optimize Everything

Optimization has a cost.

Focus on queries that matter:

- High frequency
- High CPU
- High reads
- Long duration
- User-facing latency
- Blocking impact
- Business-critical reports

A query that runs once a month in two seconds may not deserve the same attention as a query running 10,000 times per minute.

---

# 84. Index Naming Convention

This repository will use names such as:

```text
IX_<table>_<key columns>
```

Examples:

```text
IX_orders_customer_date
IX_orders_status_date
IX_order_items_product
IX_products_category_price
```

For unique indexes:

```text
UX_<table>_<columns>
```

Clear names make schema inspection and maintenance easier.

---

# 85. Training Strategy for This Chapter

Because our base dataset is intentionally small, this chapter will focus on:

1. Inspecting existing indexes
2. Creating temporary experimental indexes
3. Comparing query forms
4. Reading execution-plan concepts
5. Measuring with `STATISTICS IO`
6. Measuring with `STATISTICS TIME`
7. Understanding SARGability
8. Studying composite indexes
9. Studying covering indexes
10. Cleaning up experimental indexes

Some optimizer choices on tiny tables will differ from large production tables.

That is expected.

---

# 86. Core Optimization Principle

Do not think:

```text
Slow query
    ->
Add index
```

Think:

```text
Slow query
    |
    v
Measure
    |
    v
Understand why work is expensive
    |
    v
Choose targeted change
    |
    v
Measure again
```

Sometimes the answer is an index.

Sometimes it is:

- Query rewrite
- Better predicate
- Better schema
- Updated statistics
- Less returned data
- Better transaction design
- Removing an unnecessary operation
- Fixing incorrect joins
- Handling parameter sensitivity

---

# 87. What You Will Practice

By the end of this chapter, you should be able to:

- Explain what an index is
- Distinguish clustered and nonclustered indexes
- Explain seeks and scans
- Understand why scans are not automatically bad
- Design basic composite indexes
- Understand index key ordering
- Use INCLUDE columns
- Explain covering indexes
- Recognize key lookups
- Write SARGable predicates
- Rewrite non-SARGable date filters
- Inspect SQL Server execution plans
- Compare estimated and actual rows
- Use `SET STATISTICS IO`
- Use `SET STATISTICS TIME`
- Explain the role of statistics
- Identify common performance anti-patterns
- Understand index write costs
- Reason about join algorithms
- Recognize spills and memory-grant issues
- Treat missing-index suggestions critically
- Build a measurement-driven optimization workflow

---

# 88. Files in This Chapter

```text
11_indexes_and_performance/
│
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

`examples.sql` will provide executable demonstrations.

`exercises.sql` will contain performance and indexing challenges.

`solutions.sql` will contain complete worked solutions.

---

# 89. Final Principle

The most important lesson in SQL performance tuning is:

> Measure first. Understand the work. Change one thing. Measure again.

An index is a tool, not a universal solution.

A scan is not automatically bad.

A seek is not automatically good.

A shorter query is not automatically faster.

And a faster query is only correct if it still returns the correct business result.

The goal is to help SQL Server perform the least unnecessary work while preserving correctness, maintainability, and system stability.