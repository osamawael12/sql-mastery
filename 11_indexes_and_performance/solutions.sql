/*==============================================================================
    SQL Mastery
    Chapter 11: Indexes and Query Performance
    File: solutions.sql
    Database: SQLMastery
    Schema: training

    Notes:
    - Training tables are intentionally small.
    - SQL Server may correctly choose scans even after creating indexes.
    - Use Actual Execution Plans for plan-analysis exercises.
    - Experimental indexes are removed near the end.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - TABLE SIZES
==============================================================================*/

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM training.customers

UNION ALL

SELECT 'products', COUNT(*)
FROM training.products

UNION ALL

SELECT 'orders', COUNT(*)
FROM training.orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM training.order_items;
GO

/*
    Tiny tables can make performance experiments misleading because scanning
    a handful of pages can be cheaper than navigating an additional index.

    Production-scale data can therefore produce very different plans.
*/


/*==============================================================================
    SOLUTION 2 - INSPECT EXISTING INDEXES
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.index_id,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id;
GO


/*==============================================================================
    SOLUTION 3 - INDEX COLUMNS
==============================================================================*/

SELECT
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    c.name AS column_name,
    ic.key_ordinal,
    ic.is_included_column,
    ic.is_descending_key
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = i.object_id
   AND ic.index_id = i.index_id
INNER JOIN sys.columns AS c
    ON c.object_id = ic.object_id
   AND c.column_id = ic.column_id
WHERE i.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id,
    ic.is_included_column,
    ic.key_ordinal,
    c.column_id;
GO


/*==============================================================================
    SOLUTION 4 - HEAP OR CLUSTERED?
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(t.object_id) AS schema_name,
    t.name AS table_name,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM sys.indexes AS i
            WHERE i.object_id = t.object_id
              AND i.index_id = 1
        )
        THEN 'Has clustered index'
        ELSE 'Heap'
    END AS storage_type
FROM sys.tables AS t
WHERE t.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY t.name;
GO


/*==============================================================================
    SOLUTION 5 - PRIMARY KEY LOOKUP
==============================================================================*/

SELECT
    product_id,
    product_name,
    price,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO

/*
    Inspect the Actual Execution Plan to see the operator selected in your
    environment.

    A primary key usually provides an efficient access path, but the optimizer
    still chooses physical operators based on the table, indexes, statistics,
    data size, and estimated cost.
*/


/*==============================================================================
    SOLUTION 6 - STATISTICS IO
==============================================================================*/

SET STATISTICS IO ON;
GO

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders;
GO

SET STATISTICS IO OFF;
GO

/*
    Logical reads are especially useful when comparing I/O work between
    semantically equivalent queries.
*/


/*==============================================================================
    SOLUTION 7 - STATISTICS TIME
==============================================================================*/

SET STATISTICS TIME ON;
GO

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
FROM training.order_items;
GO

SET STATISTICS TIME OFF;
GO

/*
    One elapsed-time measurement is not enough because results can vary due to:

    - cache state
    - compilation
    - concurrent workload
    - CPU scheduling
    - I/O state

    Use repeated, controlled measurements.
*/


/*==============================================================================
    SOLUTION 8 - SELECT * VS REQUIRED COLUMNS
==============================================================================*/

SELECT *
FROM training.orders
WHERE customer_id = 1;
GO

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
GO

/*
    Selecting only required columns can:

    1. Reduce data transferred.
    2. Reduce row width and memory requirements.
    3. Make covering indexes easier.
    4. Make the intended contract clearer.
*/


/*==============================================================================
    SOLUTION 9 - SIMPLE NONCLUSTERED INDEX
==============================================================================*/

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
GO

CREATE INDEX IX_orders_customer
ON training.orders(customer_id);
GO

SELECT
    order_id,
    customer_id
FROM training.orders
WHERE customer_id = 1;
GO

/*
    A scan does not prove the index is badly designed.

    On this tiny table, scanning can simply have a lower estimated cost.
*/


/*==============================================================================
    SOLUTION 10 - SEEK VS SCAN
==============================================================================*/

/*
    1. Index Seek

       SQL Server navigates to a relevant key/range in an index.


    2. Index Scan

       SQL Server reads a broader portion of an index, potentially all of it.


    3. Seek != automatically good.

       A seek returning millions of rows can still perform enormous work.

       Scan != automatically bad.

       If almost every row is needed, scanning may be optimal.


    4. Example:

       SELECT *
       FROM training.orders;

       Since every row is required, scanning is natural.
*/


/*==============================================================================
    SOLUTION 11 - COVERING INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_cover'
)
BEGIN
    DROP INDEX IX_orders_customer_cover
    ON training.orders;
END;
GO

CREATE INDEX IX_orders_customer_cover
ON training.orders(customer_id)
INCLUDE
(
    order_date,
    order_status
);
GO

SELECT
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
GO

/*
    The index contains:

        customer_id    -> search key
        order_date     -> included output
        order_status   -> included output

    Therefore all explicitly referenced columns are available from this index.
*/


/*==============================================================================
    SOLUTION 12 - KEY LOOKUP
==============================================================================*/

/*
    A Key Lookup retrieves columns missing from a nonclustered index by
    accessing the corresponding clustered-index row.

    Few lookups can be efficient.

    Large numbers of repeated lookups can become expensive because the second
    structure must be accessed repeatedly.

    INCLUDE can sometimes place required output columns in the nonclustered
    index and make the query covering.
*/


/*==============================================================================
    SOLUTION 13 - COMPOSITE INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_date'
)
BEGIN
    DROP INDEX IX_orders_customer_date
    ON training.orders;
END;
GO

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
GO

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1
  AND order_date >= '20250101'
ORDER BY order_date;
GO


/*==============================================================================
    SOLUTION 14 - LEFTMOST KEY
==============================================================================*/

SELECT
    order_id,
    order_date
FROM training.orders
WHERE customer_id = 1;
GO

SELECT
    order_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101';
GO

/*
    The index ordering begins with customer_id.

    SQL Server can naturally navigate based on customer_id.

    Searching only by order_date does not constrain the leading key, so the
    same direct composite-key navigation is generally unavailable.

    SQL Server could still scan the index if useful.
*/


/*==============================================================================
    SOLUTION 15 - COMPOSITE COLUMN ORDER
==============================================================================*/

/*
    Query 1:

        customer_id = equality
        order_date  = range

    (customer_id, order_date) is a natural design because SQL Server can
    first locate the customer's key range and then the desired dates.


    Query 2:

        order_date >= ...

    If date is the primary access predicate, an index beginning with
    order_date is more naturally aligned.

    Index design should represent the important workload, not one universal rule.
*/


/*==============================================================================
    SOLUTION 16 - SARGABLE DATE FILTER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20260101';
GO


/*==============================================================================
    SOLUTION 17 - MONTH FILTER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20250201';
GO


/*==============================================================================
    SOLUTION 18 - HALF-OPEN DATE RANGE
==============================================================================*/

/*
    Half-open ranges avoid needing to know the final representable time value
    of the last day.

        >= '20250101'
        <  '20250201'

    naturally includes every January timestamp while excluding February.

    This is robust for date/time types with time components.
*/


/*==============================================================================
    SOLUTION 19 - DATE INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_order_date'
)
BEGIN
    DROP INDEX IX_orders_order_date
    ON training.orders;
END;
GO

CREATE INDEX IX_orders_order_date
ON training.orders(order_date)
INCLUDE
(
    customer_id,
    order_status
);
GO

SET STATISTICS IO ON;
GO

/* Non-SARGable */
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE YEAR(order_date) = 2025;
GO

/* SARGable */
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20260101';
GO

SET STATISTICS IO OFF;
GO

/*
    On larger data, the second predicate provides SQL Server with a direct
    order_date range.

    The tiny training table may still produce similar reads/plans.
*/


/*==============================================================================
    SOLUTION 20 - LIKE SEARCHES
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.customers')
      AND name = 'IX_customers_name'
)
BEGIN
    DROP INDEX IX_customers_name
    ON training.customers;
END;
GO

CREATE INDEX IX_customers_name
ON training.customers(customer_name)
INCLUDE
(
    customer_id,
    city
);
GO

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE customer_name LIKE 'A%';
GO

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE customer_name LIKE '%a%';
GO

/*
    'A%' provides a known prefix and therefore a natural starting range
    in a standard B-tree index.

    '%a%' has no known starting prefix.
*/


/*==============================================================================
    SOLUTION 21 - FUNCTION ON SEARCH COLUMN
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.customers')
      AND name = 'IX_customers_city'
)
BEGIN
    DROP INDEX IX_customers_city
    ON training.customers;
END;
GO

CREATE INDEX IX_customers_city
ON training.customers(city)
INCLUDE
(
    customer_id,
    customer_name
);
GO

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city = 'Cairo';
GO

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE UPPER(city) = 'CAIRO';
GO

/*
    The first predicate compares the raw column directly.

    The second applies a function to the stored values and is generally
    less SARGable for a normal index on city.

    Case-sensitivity semantics depend on collation, so do not rewrite merely
    for performance without preserving correctness.
*/


/*==============================================================================
    SOLUTION 22 - ISNULL AND SARGABILITY
==============================================================================*/

/*
    ISNULL(city, '') transforms the search column before comparison.

    A normal index stores the original city values, not the transformed
    expression, so direct key navigation can become harder.

    A rewrite must preserve the required treatment of NULL values.
    Faster but semantically different SQL is not an optimization.
*/


/*==============================================================================
    SOLUTION 23 - IMPLICIT CONVERSION
==============================================================================*/

/*
    An implicit conversion occurs when SQL Server automatically converts one
    data type so an operation can compare/process values.

    Type mismatches can:

    - add CPU work
    - affect estimates
    - interfere with efficient index access in some cases

    Parameters should normally match target column types.

    Execution plans can expose conversion expressions and warnings.
*/


/*==============================================================================
    SOLUTION 24 - FOREIGN KEY INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.order_items')
      AND name = 'IX_order_items_order'
)
BEGIN
    DROP INDEX IX_order_items_order
    ON training.order_items;
END;
GO

CREATE INDEX IX_order_items_order
ON training.order_items(order_id)
INCLUDE
(
    product_id,
    quantity,
    unit_price
);
GO

SELECT
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_id = 1;
GO

/*
    No.

    SQL Server does not automatically create a nonclustered index merely
    because a FOREIGN KEY was defined.
*/


/*==============================================================================
    SOLUTION 25 - PRODUCT AGGREGATION INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.order_items')
      AND name = 'IX_order_items_product'
)
BEGIN
    DROP INDEX IX_order_items_product
    ON training.order_items;
END;
GO

CREATE INDEX IX_order_items_product
ON training.order_items(product_id)
INCLUDE (quantity);
GO

SELECT
    product_id,
    SUM(quantity) AS units_sold
FROM training.order_items
GROUP BY product_id
ORDER BY product_id;
GO

/*
    product_id and quantity are both available in the index, so the aggregation
    does not require another structure merely to retrieve these referenced values.
*/


/*==============================================================================
    SOLUTION 26 - STATUS INDEX SELECTIVITY
==============================================================================*/

/*
    Low cardinality means there are relatively few distinct values.
    It does not tell us how evenly the rows are distributed.

    Example:

        Completed = 99.9%
        Pending   = 0.1%

    Pending is highly selective even though order_status has low cardinality.

    Distribution and workload matter.
*/


/*==============================================================================
    SOLUTION 27 - STATUS + DATE INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_status_date'
)
BEGIN
    DROP INDEX IX_orders_status_date
    ON training.orders;
END;
GO

CREATE INDEX IX_orders_status_date
ON training.orders
(
    order_status,
    order_date
)
INCLUDE (customer_id);
GO

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE order_status = 'Completed'
  AND order_date >= '20250101'
ORDER BY order_date;
GO

/*
    order_status supplies an equality predicate.

    Within that status, order_date supplies a range and useful ordering.
*/


/*==============================================================================
    SOLUTION 28 - FILTERED INDEX
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.products')
      AND name = 'IX_products_active_category'
)
BEGIN
    DROP INDEX IX_products_active_category
    ON training.products;
END;
GO

CREATE INDEX IX_products_active_category
ON training.products(category)
INCLUDE
(
    product_name,
    price,
    stock_quantity
)
WHERE is_active = 1;
GO

SELECT
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE is_active = 1
  AND category = 'Electronics';
GO

/*
    In a dataset containing inactive rows, the filtered index stores only
    the qualifying active subset and can therefore be smaller.
*/


/*==============================================================================
    SOLUTION 29 - UNIQUE INDEX
==============================================================================*/

/* Check duplicates */
SELECT
    email,
    COUNT(*) AS row_count
FROM training.customers
GROUP BY email
HAVING COUNT(*) > 1;
GO


/* Inspect indexes containing email */
SELECT
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_unique_constraint,
    i.is_primary_key
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = i.object_id
   AND ic.index_id = i.index_id
INNER JOIN sys.columns AS c
    ON c.object_id = ic.object_id
   AND c.column_id = ic.column_id
WHERE i.object_id = OBJECT_ID('training.customers')
  AND c.name = 'email'
ORDER BY i.index_id;
GO

/*
    Creating another index can be redundant if an existing unique constraint
    or unique index already provides the required uniqueness/access path.
*/


/*==============================================================================
    SOLUTION 30 - OVER-INDEXING
==============================================================================*/

/*
    Every additional index consumes:

    - storage
    - cache space
    - write I/O
    - transaction-log work
    - maintenance effort

    INSERT, UPDATE, and DELETE may need to maintain multiple structures.

    Similar indexes should not be removed blindly because differences in:

        key order
        INCLUDE columns
        filters
        uniqueness
        index size
        workload usage

    can make superficially similar indexes serve different purposes.
*/


/*==============================================================================
    SOLUTION 31 - INDEX WRITE COST
==============================================================================*/

/*
    When an indexed value changes, SQL Server must maintain all relevant
    physical structures as part of the transaction.

    This can involve:

    - changing the base clustered/heap row
    - removing old nonclustered entries
    - adding new nonclustered entries
    - additional page I/O
    - additional transaction-log records
    - more locking/latching/resource work

    More read optimization can therefore mean more write cost.
*/


/*==============================================================================
    SOLUTION 32 - INSPECT STATISTICS
==============================================================================*/

SELECT
    s.stats_id,
    s.name AS statistics_name,
    s.auto_created,
    s.user_created,
    s.no_recompute
FROM sys.stats AS s
WHERE s.object_id = OBJECT_ID('training.orders')
ORDER BY s.stats_id;
GO


/*==============================================================================
    SOLUTION 33 - STATISTICS PROPERTIES
==============================================================================*/

SELECT
    s.name AS statistics_name,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled,
    sp.steps,
    sp.modification_counter
FROM sys.stats AS s
CROSS APPLY sys.dm_db_stats_properties
(
    s.object_id,
    s.stats_id
) AS sp
WHERE s.object_id = OBJECT_ID('training.orders')
ORDER BY s.name;
GO

/*
    Statistics describe data distribution and help the optimizer estimate
    cardinality.

    Better estimates help SQL Server compare possible execution strategies.
*/


/*==============================================================================
    SOLUTION 34 - STATISTICS VS INDEX
==============================================================================*/

/*
    Index:
        A physical access structure useful for retrieving/ordering data.

    Statistics:
        Metadata describing data distribution for cardinality estimation.

    They are related but are not the same thing.

    Yes, SQL Server can maintain statistics that do not correspond to a
    user-created index.
*/


/*==============================================================================
    SOLUTION 35 - ESTIMATED VS ACTUAL ROWS
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
GO

/*
    Enable Actual Execution Plan and compare estimated and actual rows.

    The optimizer chooses operators, join order, memory requirements, and
    access paths using estimates.

    Large estimation errors can therefore contribute to inappropriate plans.
*/


/*==============================================================================
    SOLUTION 36 - JOIN ALGORITHMS
==============================================================================*/

/*
    Nested Loops:
        Repeatedly finds matching rows on the inner side.
        Often useful when the outer input is small and inner lookup is efficient.

    Hash Match:
        Builds/probes a hash structure.
        Often useful for larger equality joins on unsorted inputs.

    Merge Join:
        Walks appropriately ordered inputs together.
        Can be efficient when both sides have useful ordering.

    None is universally best.
*/


/*==============================================================================
    SOLUTION 37 - SORT OPERATOR
==============================================================================*/

SELECT
    customer_id,
    order_status,
    order_date
FROM training.orders
ORDER BY
    order_status,
    customer_id,
    order_date;
GO

/*
    SQL Server may require a Sort when the required ordering is not naturally
    supplied by another operator/index.

    Sorting is legitimate work.

    Large sorts can become expensive due to CPU, memory requirements, and
    potential tempdb spills.
*/


/*==============================================================================
    SOLUTION 38 - MEMORY GRANTS AND SPILLS
==============================================================================*/

/*
    Operators such as:

        Sort
        Hash Join
        Hash Aggregate

    can require execution memory.

    A memory grant is memory reserved for such query execution needs.

    If insufficient, an operator can write intermediate work to tempdb.
    This is commonly called a spill.

    Bad cardinality estimates can cause SQL Server to underestimate required
    memory and therefore contribute to spills.
*/


/*==============================================================================
    SOLUTION 39 - WINDOW FUNCTION ACCESS PATTERN
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY
            order_date DESC,
            order_id DESC
    ) AS rn
FROM training.orders;
GO

/*
    A possible access/order pattern is:

        (customer_id, order_date DESC, order_id DESC)

    Whether such an index is worthwhile depends on the broader workload.
*/


/*==============================================================================
    SOLUTION 40 - LATEST ORDER PER CUSTOMER
==============================================================================*/

WITH RankedOrders AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status,
        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date DESC,
                o.order_id DESC
        ) AS rn
    FROM training.orders AS o
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;
GO

/*
    order_id provides a deterministic tie breaker when multiple orders share
    the same order_date.
*/


/*==============================================================================
    SOLUTION 41 - CTE PERFORMANCE
==============================================================================*/

/*
    No.

    A CTE does not inherently materialize its result.

    It is primarily a named query expression.

    Whether the final plan is efficient depends on the complete query,
    estimates, indexes, data, and optimizer decisions.

    "I used a CTE" is therefore not performance evidence.
*/


/*==============================================================================
    SOLUTION 42 - EXISTS VS JOIN
==============================================================================*/

/* Version A */
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
GO


/* Version B */
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id;
GO

/*
    EXISTS directly expresses:

        return the customer if a matching order exists

    The JOIN naturally creates one row per matching customer/order pair and
    may therefore require duplicate elimination to restore customer grain.
*/


/*==============================================================================
    SOLUTION 43 - DISTINCT ANTI-PATTERN
==============================================================================*/

SELECT
    product_id,
    product_name,
    category
FROM training.products;
GO

/*
    product_id is unique, so two rows containing the same product_id cannot
    represent duplicate result rows.

    DISTINCT is therefore unnecessary for this projection.
*/


/*==============================================================================
    SOLUTION 44 - RESULT GRAIN
==============================================================================*/

WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(cr.completed_revenue, 0) AS completed_revenue
FROM training.customers AS c
LEFT JOIN CustomerRevenue AS cr
    ON cr.customer_id = c.customer_id
ORDER BY c.customer_id;
GO

/*
    Final grain:
        one row per customer

    orders -> order_items is one-to-many, so the raw joined intermediate
    result is effectively at order-item grain.

    Aggregation restores one row per customer before the final join.
*/


/*==============================================================================
    SOLUTION 45 - PRE-AGGREGATION
==============================================================================*/

WITH OrderRevenue AS
(
    SELECT
        oi.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM training.order_items AS oi
    GROUP BY oi.order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    r.order_revenue
FROM training.orders AS o
INNER JOIN OrderRevenue AS r
    ON r.order_id = o.order_id
WHERE o.order_status = 'Completed'
ORDER BY o.order_id;
GO

/*
    Pre-aggregation can reduce many detail rows into a smaller intermediate
    result before later operations.

    It is not automatically faster because SQL Server may transform query
    operations itself, and aggregation also has a cost.
*/


/*==============================================================================
    SOLUTION 46 - PARAMETER SENSITIVITY
==============================================================================*/

/*
    Dataset A has similar cardinality for each parameter.

    Dataset B is highly skewed:

        Customer 1 -> 3 rows
        Customer 2 -> 5,000,000 rows

    An efficient strategy for three rows may not be ideal for five million.

    This relates to parameter sensitivity and commonly discussed
    parameter-sniffing/cached-plan behavior.
*/


/*==============================================================================
    SOLUTION 47 - OPTION (RECOMPILE)
==============================================================================*/

DECLARE @CustomerId INT = 1;

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = @CustomerId
OPTION (RECOMPILE);
GO

/*
    RECOMPILE allows optimization for the current execution/parameter values.

    The trade-off is additional compilation work and reduced plan reuse.

    Therefore it should be applied only when justified by measured behavior.
*/


/*==============================================================================
    SOLUTION 48 - MISSING INDEX SUGGESTIONS
==============================================================================*/

/*
    Before creating the suggested index, ask:

    1. Does a similar existing index already provide most/all of this access path?
    2. Could an existing index be adjusted instead?
    3. How frequent and important is the query?
    4. What write/storage cost would this index add?
    5. Is the proposed index excessively wide?
    6. Could it be consolidated with another useful index?
    7. Does real before/after measurement confirm the benefit?

    Missing-index suggestions are evidence, not automatic instructions.
*/


/*==============================================================================
    SOLUTION 49 - INDEX HINTS
==============================================================================*/

/*
    An index hint forces optimizer behavior that may make sense under today's
    data and become inappropriate later.

    Changes in:

        table size
        data distribution
        indexes
        statistics
        workload

    can alter the best access strategy.

    First investigate query design, SARGability, estimates, statistics,
    indexes, and the actual execution plan.
*/


/*==============================================================================
    SOLUTION 50 - INDEX USAGE STATISTICS
==============================================================================*/

SELECT
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    COALESCE(us.user_seeks, 0) AS user_seeks,
    COALESCE(us.user_scans, 0) AS user_scans,
    COALESCE(us.user_lookups, 0) AS user_lookups,
    COALESCE(us.user_updates, 0) AS user_updates
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON us.database_id = DB_ID()
   AND us.object_id = i.object_id
   AND us.index_id = i.index_id
WHERE i.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
  AND i.index_id > 0
ORDER BY
    table_name,
    i.index_id;
GO

/*
    DMV counters reset under conditions including SQL Server restarts and
    other database lifecycle events.

    They are not permanent workload history.
*/


/*==============================================================================
    SOLUTION 51 - INDEX FRAGMENTATION
==============================================================================*/

SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) AS ips
INNER JOIN sys.indexes AS i
    ON i.object_id = ips.object_id
   AND i.index_id = ips.index_id
WHERE ips.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id;
GO

/*
    A tiny index may have a high fragmentation percentage while containing
    almost no pages.

    Percentage alone therefore does not imply meaningful performance impact.
*/


/*==============================================================================
    SOLUTION 52 - REORGANIZE VS REBUILD
==============================================================================*/

/*
    REORGANIZE:
        Incrementally reorganizes leaf-level index pages.

    REBUILD:
        Recreates the index structure.

    A simplistic percentage rule ignores factors such as:

        page count
        actual index size
        workload
        storage
        logging
        maintenance windows
        SQL Server version/edition/features

    Small indexes often do not justify fragmentation maintenance at all.
*/


/*==============================================================================
    SOLUTION 53 - FILL FACTOR
==============================================================================*/

/*
    Fill factor controls how full index leaf pages are made during creation
    or rebuild.

    Lower fill factor leaves more free space.

    This can help some workloads that would otherwise produce page splits.

    But more free space means more pages, potentially increasing:

        storage
        memory consumption
        logical reads

    Therefore there is no universal best value.
*/


/*==============================================================================
    SOLUTION 54 - PERFORMANCE BASELINE
==============================================================================*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    completed_revenue DESC,
    c.customer_id;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/*
    In addition to IO/time, capture:

        - actual execution plan
        - parameters
        - row count
        - estimated vs actual rows
        - relevant indexes
        - query text
        - representative workload conditions

    COUNT(DISTINCT o.order_id) protects order count from the one-to-many
    order_items join.
*/


/*==============================================================================
    SOLUTION 55 - FREQUENCY VS SINGLE EXECUTION
==============================================================================*/

/*
    Query B can have dramatically greater total impact.

        50 ms * 1,000,000 executions

    can consume much more aggregate system capacity than a 500 ms query
    running once per month.

    Tuning priorities should consider total workload cost and business impact.
*/


/*==============================================================================
    SOLUTION 56 - PERFORMANCE VS CONCURRENCY
==============================================================================*/

/*
    A query can be quick individually but harmful at scale if it:

    - acquires locks that block other sessions
    - executes extremely frequently
    - consumes substantial aggregate CPU
    - requires large concurrent memory grants
    - produces heavy I/O
    - creates resource contention

    Production performance is a system property, not merely isolated latency.
*/


/*==============================================================================
    SOLUTION 57 - OPTIMIZATION REVIEW
==============================================================================*/

/*
    Issues to investigate:

    1. SELECT * retrieves unnecessary columns if the application needs only four.
    2. DISTINCT may be unnecessary because order_id is unique.
    3. YEAR(order_date) is non-SARGable compared with a direct date range.
    4. ORDER BY may require sorting depending on available indexes.
*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20260101'
ORDER BY order_date;
GO


/*==============================================================================
    SOLUTION 58 - INDEX DESIGN CHALLENGE
==============================================================================*/

/*
    Query:

        customer_id = equality
        order_date  = range
        ORDER BY order_date DESC

    One reasonable candidate:
*/

/*
CREATE INDEX IX_orders_customer_date_desc
ON training.orders
(
    customer_id,
    order_date DESC
)
INCLUDE
(
    order_status
);
*/

/*
    Why?

    customer_id:
        Leading key supports the equality predicate.

    order_date:
        Second key supports the date range and requested ordering.

    order_status:
        Needed in the output, but not required as a search key, so INCLUDE
        is reasonable.

    order_id:
        If order_id is the clustered key, SQL Server normally carries the
        clustered key in nonclustered indexes, so inspect the real schema
        before unnecessarily adding it.

    This is a candidate design. Measurements on representative production
    data are still required.
*/


/*==============================================================================
    SOLUTION 59 - PERFORMANCE TUNING WORKFLOW
==============================================================================*/

/*
    1. Identify an important query/workload.
       Optimize work that matters.

    2. Verify correctness.
       Know the intended business result and grain.

    3. Capture a baseline.
       Save IO, time, plan, parameters, and row counts.

    4. Inspect the Actual Execution Plan.
       Understand what SQL Server actually did.

    5. Inspect logical reads and resource usage.
       Quantify database work.

    6. Compare estimated vs actual rows.
       Find major cardinality-estimation problems.

    7. Identify the likely bottleneck.
       Do not change several unrelated things at once.

    8. Make one targeted change.
       Example: SARGable rewrite or index adjustment.

    9. Measure again.
       Compare against the same baseline.

    10. Verify correctness again.

    11. Evaluate broader impact.
        Consider writes, storage, concurrency, and other queries.
*/


/*==============================================================================
    SOLUTION 60 - FINAL PERFORMANCE CHALLENGE
==============================================================================*/

/*
    Final grain:

        One row per active customer.

    A useful design is to aggregate Completed order-item data before joining
    back to customers.
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

WITH CompletedCustomerMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
        MAX(o.order_date) AS latest_completed_order_date
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(m.completed_orders, 0) AS completed_orders,
    COALESCE(m.completed_revenue, 0) AS completed_revenue,
    m.latest_completed_order_date
FROM training.customers AS c
LEFT JOIN CompletedCustomerMetrics AS m
    ON m.customer_id = c.customer_id
WHERE c.is_active = 1
ORDER BY
    completed_revenue DESC,
    c.customer_id;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/*
    Relevant access columns include:

        customers.is_active
        customers.customer_id
        orders.customer_id
        orders.order_status
        orders.order_id
        order_items.order_id

    Before proposing anything, inspect current indexes:
*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id;
GO

/*
    Possible large-dataset candidates might include designs such as:

        orders:
            (order_status, customer_id)
            INCLUDE (order_date)

        order_items:
            (order_id)
            INCLUDE (quantity, unit_price)

    But the best order index depends heavily on:

        status selectivity
        workload
        existing indexes
        table size
        query frequency
        alternative access patterns

    Why COUNT(DISTINCT o.order_id)?

    One order can contain multiple order_items.

    After the join, one order can therefore appear multiple times.
    COUNT(o.order_id) would count joined lines, not distinct orders.

    Write cost:

    Every additional index consumes storage and must be maintained by
    INSERT/UPDATE/DELETE operations.

    Why doesn't this tiny dataset prove the indexes are optimal?

    Cost decisions with a few rows are fundamentally different from those
    involving millions or billions of rows. Representative data and workload
    measurements are required.
*/


/*==============================================================================
    SOLUTION 61 - CLEAN UP EXPERIMENTAL INDEXES
==============================================================================*/

/* orders */

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer'
)
    DROP INDEX IX_orders_customer ON training.orders;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_cover'
)
    DROP INDEX IX_orders_customer_cover ON training.orders;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_date'
)
    DROP INDEX IX_orders_customer_date ON training.orders;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_order_date'
)
    DROP INDEX IX_orders_order_date ON training.orders;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_status_date'
)
    DROP INDEX IX_orders_status_date ON training.orders;
GO


/* customers */

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.customers')
      AND name = 'IX_customers_name'
)
    DROP INDEX IX_customers_name ON training.customers;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.customers')
      AND name = 'IX_customers_city'
)
    DROP INDEX IX_customers_city ON training.customers;
GO


/* order_items */

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.order_items')
      AND name = 'IX_order_items_order'
)
    DROP INDEX IX_order_items_order ON training.order_items;
GO

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.order_items')
      AND name = 'IX_order_items_product'
)
    DROP INDEX IX_order_items_product ON training.order_items;
GO


/* products */

IF EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.products')
      AND name = 'IX_products_active_category'
)
    DROP INDEX IX_products_active_category ON training.products;
GO


/*==============================================================================
    SOLUTION 62 - FINAL INDEX AUDIT
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_primary_key,
    i.is_unique,
    i.is_unique_constraint
FROM sys.indexes AS i
WHERE i.object_id IN
(
    OBJECT_ID('training.customers'),
    OBJECT_ID('training.products'),
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id;
GO


/*==============================================================================
    FINAL THEORY CHECK - ANSWERS
==============================================================================*/

/*
    1. Why is a scan not automatically bad?

       If a query needs most/all rows, sequentially reading the relevant
       structure can be the cheapest strategy.


    2. Why is a seek not automatically good?

       A seek can still retrieve an enormous number of rows and trigger
       expensive lookups or downstream processing.


    3. What makes a predicate SARGable?

       It allows SQL Server to use searchable index key/range conditions
       efficiently rather than transforming every candidate column value.


    4. Why does composite index key order matter?

       The index is ordered according to its key sequence, which determines
       useful navigation patterns.


    5. What does INCLUDE do?

       It stores additional non-key columns at the leaf level so queries can
       retrieve them without making them search keys.


    6. What is a covering index?

       An index containing the columns required to satisfy a query without
       needing another structure for missing values.


    7. What is a Key Lookup?

       An additional access to the clustered index to retrieve columns missing
       from a selected nonclustered index.


    8. Why do statistics matter?

       They help SQL Server estimate cardinality and compare plan strategies.


    9. Why do estimated vs actual rows matter?

       Large estimation errors can lead to inappropriate join algorithms,
       access paths, memory grants, and operator choices.


    10. What are logical reads?

        Reads of database pages from SQL Server's buffer cache required by
        query execution.


    11. Why can too many indexes hurt performance?

        They consume storage and must be maintained during data modifications.


    12. Why not follow missing-index suggestions blindly?

        They do not represent a complete workload-aware index strategy and
        may overlap existing indexes or impose excessive write cost.


    13. Why aren't query hints normally the first tuning tool?

        They restrict optimizer choices and can age poorly as data/workloads
        change.


    14. Why does result grain matter?

        Incorrect or unnecessarily detailed intermediate grain can multiply
        rows, increase processing, and produce incorrect calculations.


    15. Most important optimization loop:

        Measure
            ->
        Understand
            ->
        Change
            ->
        Measure again
*/


/*==============================================================================
    CHAPTER 11 COMPLETE

    You have now covered:

    - Clustered indexes
    - Nonclustered indexes
    - Heaps
    - Index seeks
    - Index scans
    - Composite indexes
    - Key ordering
    - INCLUDE
    - Covering indexes
    - Key lookups
    - SARGability
    - Date-range filtering
    - LIKE search behavior
    - Implicit conversions
    - Execution plans
    - Estimated vs actual rows
    - SQL Server statistics
    - STATISTICS IO
    - STATISTICS TIME
    - Logical reads
    - Join algorithms
    - Sorts
    - Memory grants
    - tempdb spills
    - Filtered indexes
    - Unique indexes
    - Over-indexing
    - Index write cost
    - Fragmentation
    - Fill factor
    - Index usage DMVs
    - Parameter sensitivity
    - Query hints
    - Missing-index suggestions
    - Performance baselining
    - Workload-aware optimization

    Core principle:

        Measure
            ->
        Understand
            ->
        Change
            ->
        Measure again

    Chapter 11 and the numbered SQL learning chapters are now complete.
==============================================================================*/