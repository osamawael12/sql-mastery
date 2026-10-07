/*==============================================================================
    SQL Mastery
    Chapter 11: Indexes and Query Performance
    File: examples.sql
    Database: SQLMastery
    Schema: training

    Topics:
    - Existing index inspection
    - Clustered and nonclustered indexes
    - Index seeks and scans
    - Composite indexes
    - INCLUDE columns
    - Covering indexes
    - Key lookups
    - SARGability
    - Date filtering
    - LIKE patterns
    - Implicit conversions
    - Execution plans
    - STATISTICS IO
    - STATISTICS TIME
    - Statistics
    - Join indexing
    - Filtered indexes
    - Unique indexes
    - Indexes for ORDER BY / GROUP BY
    - Window-function access patterns
    - Index maintenance
    - Fragmentation
    - Query optimization workflow

    IMPORTANT:
    The SQLMastery training tables are intentionally small.

    SQL Server may choose scans even when useful indexes exist because
    scanning a tiny table can be cheaper than seeking through an index.

    Therefore:
    - Focus on understanding the mechanics.
    - Inspect actual execution plans.
    - Measure logical reads.
    - Do not assume Seek = good and Scan = bad.

    Experimental indexes created by this file are removed near the end.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    1. BASELINE TABLE SIZES
==============================================================================*/

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM training.customers

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM training.products

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM training.orders

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM training.order_items;
GO

/*
    The training dataset is small.

    This matters because SQL Server's optimizer chooses plans based on cost.

    Reading an entire five-row table can be cheaper than navigating through
    another index structure.
*/


/*==============================================================================
    2. INSPECT EXISTING INDEXES
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.index_id,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint,
    i.is_disabled
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
    3. INSPECT INDEX COLUMNS
==============================================================================*/

/*
    sys.index_columns describes which columns belong to each index.

    key_ordinal:
        Position inside the index key.

    is_included_column:
        1 means the column was added using INCLUDE.
*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
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
    4. CLUSTERED INDEX VS HEAP
==============================================================================*/

/*
    index_id meanings include:

        0 = Heap
        1 = Clustered index
       >1 = Nonclustered index
*/

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
    5. PRIMARY KEY ACCESS
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
    If product_id is supported by the primary key/clustered index,
    SQL Server has an efficient access structure for this lookup.

    On the tiny training table, inspect the execution plan rather than
    assuming exactly which physical operator SQL Server will choose.
*/


/*==============================================================================
    6. ENABLE PERFORMANCE MEASUREMENT
==============================================================================*/

/*
    STATISTICS IO:
        Displays page-level I/O information in Messages.

    STATISTICS TIME:
        Displays CPU and elapsed-time information.

    Results on this tiny dataset will be very small.
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/*==============================================================================
    7. SELECT * VS SELECTING REQUIRED COLUMNS
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
    On five rows, the performance difference may be irrelevant.

    At scale, avoiding unnecessary columns can:

    - reduce data transfer
    - reduce row width
    - reduce memory usage
    - make covering indexes easier
*/


/*==============================================================================
    8. CREATE A SIMPLE NONCLUSTERED INDEX
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


/*==============================================================================
    9. QUERY SUPPORTED BY SIMPLE INDEX
==============================================================================*/

SELECT
    order_id,
    customer_id
FROM training.orders
WHERE customer_id = 1;
GO

/*
    Inspect the execution plan.

    SQL Server may use IX_orders_customer.

    However, with only a few rows, a scan may still be cheaper.
*/


/*==============================================================================
    10. INDEX SEEK VS INDEX SCAN
==============================================================================*/

/*
    Selective lookup concept:

        WHERE customer_id = 1

    Broad query concept:

        no filtering

    A seek is often attractive for selective access.
    A scan can be perfectly appropriate when most rows are required.
*/

SELECT
    order_id,
    customer_id
FROM training.orders
WHERE customer_id = 1;
GO

SELECT
    order_id,
    customer_id
FROM training.orders;
GO


/*==============================================================================
    11. COVERING INDEX CONCEPT
==============================================================================*/

SELECT
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
GO

/*
    IX_orders_customer contains customer_id as the key.

    Depending on the clustered key and query requirements, SQL Server
    may require access to another structure for columns not available
    from the nonclustered index.

    We can create a covering index using INCLUDE.
*/


/*==============================================================================
    12. CREATE COVERING INDEX
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
    The index now contains everything required by this query:

        Search key:
            customer_id

        Output:
            order_date
            order_status

    This is the basic idea behind a covering index.
*/


/*==============================================================================
    13. KEY LOOKUP CONCEPT
==============================================================================*/

/*
    A nonclustered index might identify rows efficiently but not contain
    every requested column.

    SQL Server can then use a Key Lookup against the clustered index.

    For a small number of matching rows, lookups may be efficient.

    For many rows:

        Seek
        +
        thousands/millions of Key Lookups

    can become expensive.

    Look for Key Lookup operators in actual execution plans.
*/


/*==============================================================================
    14. COMPOSITE INDEX
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


/*==============================================================================
    15. COMPOSITE INDEX QUERY
==============================================================================*/

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1
  AND order_date >= '20250101'
ORDER BY order_date;
GO

/*
    Index key:

        customer_id
        order_date

    Predicate:

        customer_id = equality
        order_date  = range

    This is a common useful composite-index pattern.
*/


/*==============================================================================
    16. LEFTMOST KEY PRINCIPLE
==============================================================================*/

SELECT
    order_id,
    order_date
FROM training.orders
WHERE customer_id = 1;
GO

/*
    IX_orders_customer_date can naturally support customer_id because
    customer_id is the leading key.
*/


SELECT
    order_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101';
GO

/*
    This predicate does not constrain the leading customer_id key.

    The same composite index cannot generally seek directly by its second
    key in the same way.

    That does NOT mean the index is completely unusable.

    SQL Server could scan it if that is useful.
*/


/*==============================================================================
    17. COLUMN ORDER MATTERS
==============================================================================*/

/*
    These indexes support different access patterns:

        (customer_id, order_date)

    versus:

        (order_date, customer_id)

    There is no universal best ordering.

    Index key order should reflect actual workload patterns.
*/


/*==============================================================================
    18. INDEX SUPPORTING ORDER BY
==============================================================================*/

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1
ORDER BY order_date;
GO

/*
    IX_orders_customer_date stores entries according to:

        customer_id
        then order_date

    For one customer, SQL Server may be able to obtain rows already
    ordered by order_date without a separate Sort.
*/


/*==============================================================================
    19. DESCENDING KEY EXAMPLE
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_date_desc'
)
BEGIN
    DROP INDEX IX_orders_customer_date_desc
    ON training.orders;
END;
GO

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
GO

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1
ORDER BY order_date DESC;
GO


/*==============================================================================
    20. SARGABLE DATE FILTER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20260101';
GO

/*
    The raw column participates directly in range comparisons.

    This is SARGable.
*/


/*==============================================================================
    21. NON-SARGABLE DATE FILTER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE YEAR(order_date) = 2025;
GO

/*
    SQL Server must evaluate YEAR(order_date).

    On a large indexed table this can prevent efficient direct navigation
    into an order_date index.
*/


/*==============================================================================
    22. CREATE DATE INDEX
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


/*==============================================================================
    23. COMPARE DATE FILTER FORMS
==============================================================================*/

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
    On this tiny dataset the logical reads may be identical or nearly identical.

    With large tables, the SARGable form often gives SQL Server more efficient
    index-access options.
*/


/*==============================================================================
    24. MONTH FILTER: NON-SARGABLE VS SARGABLE
==============================================================================*/

/* Less index-friendly */
SELECT
    order_id,
    order_date
FROM training.orders
WHERE YEAR(order_date) = 2025
  AND MONTH(order_date) = 1;
GO


/* More index-friendly */
SELECT
    order_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20250201';
GO


/*==============================================================================
    25. WHY HALF-OPEN DATE RANGES ARE USEFUL
==============================================================================*/

/*
    Prefer:

        >= start
        < next_period

    rather than attempting:

        <= end_of_day

    Example:

        >= '20250101'
        <  '20250201'

    This pattern works naturally with date/time values that can include
    a time component.
*/


/*==============================================================================
    26. LIKE AND INDEX ACCESS
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


/* Potentially searchable prefix */
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE customer_name LIKE 'A%';
GO


/* Leading wildcard */
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE customer_name LIKE '%a%';
GO

/*
    A normal B-tree index can navigate efficiently from a known prefix.

    With a leading wildcard, SQL Server does not know where matching values
    begin in the ordered index.
*/


/*==============================================================================
    27. FUNCTION ON SEARCH COLUMN
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


/* Potentially SARGable */
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city = 'Cairo';
GO


/* Function applied to indexed/search column */
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE UPPER(city) = 'CAIRO';
GO

/*
    Function-wrapped columns can prevent efficient search access.

    Note:
    Exact behavior can also depend on collation and query semantics.
*/


/*==============================================================================
    28. ISNULL ON SEARCH COLUMN
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE ISNULL(city, '') = 'Cairo';
GO

/*
    Wrapping city in ISNULL can make the predicate harder to seek efficiently.

    Do not rewrite predicates without considering NULL semantics.

    Correctness comes first.
*/


/*==============================================================================
    29. IMPLICIT CONVERSIONS
==============================================================================*/

/*
    Keep parameter/data types aligned with underlying columns.

    Example concept:

        INT column compared with an appropriately typed INT parameter

    is preferable to introducing unnecessary incompatible conversions.

    Execution plans can expose implicit conversion warnings in some cases.
*/

DECLARE @ProductId INT = 1;

SELECT
    product_id,
    product_name
FROM training.products
WHERE product_id = @ProductId;
GO


/*==============================================================================
    30. INDEX FOR A FOREIGN KEY / JOIN COLUMN
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


/*==============================================================================
    31. JOIN QUERY
==============================================================================*/

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
    Useful access paths can exist on both sides:

        orders.order_id
        order_items.order_id

    Foreign keys do not inherently guarantee a supporting nonclustered
    index exists on the child column.
*/


/*==============================================================================
    32. PRODUCT JOIN INDEX
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
INCLUDE
(
    order_id,
    quantity,
    unit_price
);
GO

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_in_order_items
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY p.product_id;
GO


/*==============================================================================
    33. INDEX SUPPORTING GROUP BY
==============================================================================*/

SELECT
    product_id,
    SUM(quantity) AS units_sold
FROM training.order_items
GROUP BY product_id
ORDER BY product_id;
GO

/*
    IX_order_items_product contains:

        product_id as key
        quantity as INCLUDE

    It therefore contains the values needed for this aggregation.

    Depending on the plan, the ordering of product_id can also help
    aggregation processing.
*/


/*==============================================================================
    34. REVENUE QUERY
==============================================================================*/

SELECT
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id
ORDER BY o.customer_id;
GO

/*
    Questions to ask before adding another index:

    - What percentage of orders are Completed?
    - How many rows exist?
    - How many items per order?
    - Which predicates are selective?
    - Which indexes already exist?
    - Is this query frequent enough to optimize?
*/


/*==============================================================================
    35. INDEX FOR STATUS + DATE ACCESS PATTERN
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
INCLUDE
(
    customer_id
);
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


/*==============================================================================
    36. LOW-CARDINALITY COLUMN WARNING
==============================================================================*/

/*
    order_status might contain only a few possible values:

        Pending
        Completed
        Cancelled

    A low-cardinality column is not automatically a bad index key.

    Its usefulness depends on distribution and workload.

    Example:

        If 99.9% of rows are Completed,
        filtering Completed is not very selective.

        If only 0.1% are Pending,
        filtering Pending can be highly selective.

    Distribution matters.
*/


/*==============================================================================
    37. FILTERED INDEX
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
    The filtered index stores only active products.

    Filtered indexes can be very useful when a workload repeatedly accesses
    a specific subset of a table.
*/


/*==============================================================================
    38. UNIQUE INDEX CONCEPT
==============================================================================*/

/*
    Unique indexes combine:

        data integrity
        +
        access structure

    Before creating a unique index, always verify duplicates do not exist.
*/

SELECT
    email,
    COUNT(*) AS duplicate_count
FROM training.customers
GROUP BY email
HAVING COUNT(*) > 1;
GO

/*
    Example only:

        CREATE UNIQUE INDEX UX_customers_email
        ON training.customers(email);

    We do not create it automatically here because the schema may already
    enforce email uniqueness through another object or constraint.

    Avoid redundant indexes.
*/


/*==============================================================================
    39. CHECK EXISTING EMAIL INDEXES/CONSTRAINTS
==============================================================================*/

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


/*==============================================================================
    40. COVERING VS WIDE INDEXES
==============================================================================*/

/*
    INCLUDE is useful, but this does NOT mean:

        INCLUDE every column

    Very wide indexes:

    - consume more disk
    - consume more memory
    - increase write cost
    - increase maintenance work

    Cover important queries intentionally.
*/


/*==============================================================================
    41. INDEX WRITE COST
==============================================================================*/

/*
    Consider:

        UPDATE training.products
        SET category = ...
        WHERE ...

    If category participates in several indexes, SQL Server must maintain
    those indexes as part of the change.

    Every index has a cost.

    We intentionally do not modify training data in this demonstration.
*/


/*==============================================================================
    42. OVER-INDEXING EXAMPLE
==============================================================================*/

/*
    Imagine orders had all these indexes:

        (customer_id)
        (customer_id, order_date)
        (customer_id, order_status)
        (customer_id, order_date, order_status)
        (order_status)
        (order_status, order_date)
        (order_date)

    Some may support distinct workloads.

    Others may overlap excessively.

    Do not create indexes individually without considering the complete
    index portfolio of the table.
*/


/*==============================================================================
    43. INSPECT CURRENT EXPERIMENTAL ORDERS INDEXES
==============================================================================*/

SELECT
    i.index_id,
    i.name,
    i.type_desc,
    i.is_unique,
    i.has_filter,
    i.filter_definition
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('training.orders')
ORDER BY i.index_id;
GO

/*
    Notice how quickly indexes accumulate during experiments.

    In a production system, each additional index should justify its cost.
*/


/*==============================================================================
    44. STATISTICS ASSOCIATED WITH A TABLE
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
    45. STATISTICS PROPERTIES
==============================================================================*/

/*
    sys.dm_db_stats_properties provides metadata such as:

        last_updated
        rows
        rows_sampled
        modification_counter
*/

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


/*==============================================================================
    46. VIEW STATISTICS DETAILS
==============================================================================*/

/*
    DBCC SHOW_STATISTICS can show:

        Header
        Density Vector
        Histogram

    Example:

        DBCC SHOW_STATISTICS
        (
            'training.orders',
            'IX_orders_order_date'
        );

    Uncomment and run after the index has been created.
*/

/*
DBCC SHOW_STATISTICS
(
    'training.orders',
    'IX_orders_order_date'
);
GO
*/


/*==============================================================================
    47. ESTIMATED VS ACTUAL ROWS
==============================================================================*/

/*
    Enable Actual Execution Plan in SSMS and run:
*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = 1;
GO

/*
    Inspect:

        Estimated Number of Rows
        Actual Number of Rows

    Accurate cardinality estimates help SQL Server choose appropriate plans.
*/


/*==============================================================================
    48. JOIN ALGORITHMS
==============================================================================*/

/*
    Common SQL Server join algorithms:

        Nested Loops
        Hash Match
        Merge Join

    The optimizer chooses based on costs and estimates.

    Do not force a particular join simply because one algorithm sounds faster.
*/

SELECT
    o.order_id,
    c.customer_name
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id;
GO

/*
    On tiny tables, the selected algorithm may not match what SQL Server
    chooses for the same logical query with millions of rows.
*/


/*==============================================================================
    49. NESTED LOOPS CONCEPT
==============================================================================*/

/*
    Nested Loops often works well when:

        outer input is small
        +
        inner input has efficient lookup access

    Conceptually:

        for each outer row
            find matching inner rows
*/


/*==============================================================================
    50. HASH JOIN CONCEPT
==============================================================================*/

/*
    Hash Match joins are often useful for larger unsorted equality joins.

    Conceptually:

        build hash structure
        +
        probe hash structure

    Hash operations require memory and can spill to tempdb if the memory
    grant is insufficient.
*/


/*==============================================================================
    51. MERGE JOIN CONCEPT
==============================================================================*/

/*
    Merge Join can be efficient when both inputs are appropriately ordered
    on their join keys.

    Existing indexes can sometimes provide that ordering.
*/


/*==============================================================================
    52. SORT OPERATOR
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
    If no useful index provides this order, SQL Server may need a Sort.

    Sorts are not automatically problems.

    A large expensive Sort or one spilling to tempdb deserves investigation.
*/


/*==============================================================================
    53. WINDOW FUNCTION AND INDEX ORDER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date DESC, order_id DESC
    ) AS order_sequence
FROM training.orders;
GO

/*
    Window functions commonly need ordering.

    An index beginning with:

        customer_id,
        order_date DESC

    may support part of the access/order requirement.

    The exact plan depends on the full query and tie-breaking requirements.
*/


/*==============================================================================
    54. LATEST ORDER PER CUSTOMER
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


/*==============================================================================
    55. CTE DOES NOT AUTOMATICALLY MATERIALIZE
==============================================================================*/

/*
    A CTE is primarily a named query expression.

    This:

        WITH x AS (...)
        SELECT ...
        FROM x;

    does not mean SQL Server automatically writes x into a temporary table.

    Always inspect the actual plan instead of assuming CTE materialization.
*/


/*==============================================================================
    56. EXISTS EXAMPLE
==============================================================================*/

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

/*
    EXISTS clearly expresses:

        Return customer if at least one matching order exists.

    Do not assume EXISTS is always physically faster than JOIN.

    SQL Server can transform logically equivalent query forms.
*/


/*==============================================================================
    57. JOIN VERSION OF EXISTENCE QUERY
==============================================================================*/

SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id;
GO

/*
    This query can produce duplicate customer rows before DISTINCT because
    one customer can have many orders.

    EXISTS naturally matches the existence requirement and does not require
    duplicate removal for that reason.

    Choose the query form that correctly communicates the result semantics.
*/


/*==============================================================================
    58. DISTINCT IS NOT A JOIN FIX
==============================================================================*/

/*
    Do not use DISTINCT merely to hide duplicate rows caused by an incorrect
    join.

    Always ask:

        What is the intended result grain?
        Why were duplicates produced?
*/


/*==============================================================================
    59. PRE-AGGREGATION EXAMPLE
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
    Pre-aggregation establishes one row per order before the join.

    This can sometimes reduce work in large analytical queries.

    But never assume it is faster without measuring the resulting plan.
*/


/*==============================================================================
    60. PARAMETERIZED QUERY
==============================================================================*/

DECLARE @CustomerId INT = 1;

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = @CustomerId;
GO

/*
    On real datasets, different parameter values can have dramatically
    different selectivity.

    Parameter-sensitive plan behavior becomes important when one reusable
    plan is not appropriate for every parameter value.
*/


/*==============================================================================
    61. RECOMPILE HINT - DEMONSTRATION ONLY
==============================================================================*/

/*
    OPTION (RECOMPILE) tells SQL Server to compile a plan for this execution.

    This can help some parameter-sensitive workloads but adds compilation cost.

    It is not something to add to every query.
*/

DECLARE @CustomerId INT = 1;

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE customer_id = @CustomerId
OPTION (RECOMPILE);
GO


/*==============================================================================
    62. INDEX HINT - SYNTAX DEMONSTRATION
==============================================================================*/

/*
    SQL Server allows explicit index hints.

    Example:

        SELECT ...
        FROM training.orders WITH (INDEX(IX_orders_customer_date))
        WHERE customer_id = 1;

    Avoid forcing indexes unless you have a strong, measured reason.

    Forced plans can become poor choices as data distributions and indexes change.
*/


/*==============================================================================
    63. MISSING INDEX SUGGESTIONS
==============================================================================*/

/*
    Actual execution plans can contain missing-index suggestions.

    Treat them as clues, not commands.

    Before creating a suggested index ask:

        Does a similar index already exist?
        Can it be merged with another index?
        How often is this query executed?
        What is the write cost?
        How wide is the proposed index?
        Does the suggestion help the overall workload?
*/


/*==============================================================================
    64. INDEX USAGE STATISTICS
==============================================================================*/

/*
    sys.dm_db_index_usage_stats can show operations such as:

        user_seeks
        user_scans
        user_lookups
        user_updates

    IMPORTANT:

    These counters reset under conditions such as SQL Server restarts and
    database lifecycle events. They are not permanent history.
*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
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


/*==============================================================================
    65. PHYSICAL INDEX STATISTICS
==============================================================================*/

/*
    sys.dm_db_index_physical_stats can expose fragmentation/page information.

    Small indexes are not meaningful fragmentation-tuning targets.
*/

SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
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


/*==============================================================================
    66. REORGANIZE VS REBUILD
==============================================================================*/

/*
    Syntax examples:

        ALTER INDEX IX_orders_customer_date
        ON training.orders
        REORGANIZE;


        ALTER INDEX IX_orders_customer_date
        ON training.orders
        REBUILD;

    Do not rebuild indexes blindly based on a simplistic fragmentation threshold.

    Consider:

        index size
        page count
        workload
        storage
        transaction log impact
        edition/version capabilities
        maintenance window
*/


/*==============================================================================
    67. FILL FACTOR
==============================================================================*/

/*
    Example syntax:

        CREATE INDEX IX_example
        ON dbo.SomeTable(SomeColumn)
        WITH (FILLFACTOR = 90);

    Lower fill factor leaves more free space on index pages after build.

    That may reduce some page splitting workloads but increases index size.

    There is no universal best fill factor.
*/


/*==============================================================================
    68. STATISTICS UPDATE
==============================================================================*/

/*
    SQL Server normally manages statistics automatically when appropriate.

    Manual syntax includes:

        UPDATE STATISTICS training.orders;

    or:

        UPDATE STATISTICS training.orders IX_orders_order_date;

    Do not automatically update every statistic constantly.

    Statistics maintenance should be workload-driven.
*/


/*==============================================================================
    69. EXECUTION PLAN CHECKLIST
==============================================================================*/

/*
    When examining an Actual Execution Plan, inspect:

    1. Actual rows vs estimated rows
    2. Number of executions
    3. Seek predicates
    4. Residual predicates
    5. Scans
    6. Key lookups
    7. Sorts
    8. Hash operations
    9. Warnings
    10. Memory grants
    11. Spills to tempdb
    12. Join algorithms
    13. Missing-index suggestions

    Do not focus exclusively on the displayed cost percentage.
*/


/*==============================================================================
    70. PERFORMANCE BASELINE TEMPLATE
==============================================================================*/

/*
    A useful baseline process:

        SET STATISTICS IO ON;
        SET STATISTICS TIME ON;

        -- Run query with Actual Execution Plan enabled.

        SELECT ...
        FROM ...
        WHERE ...;

        SET STATISTICS IO OFF;
        SET STATISTICS TIME OFF;

    Record:

        logical reads
        CPU time
        elapsed time
        actual rows
        estimated rows
        execution plan
        parameters
*/


/*==============================================================================
    71. BASELINE A BUSINESS QUERY
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
ORDER BY completed_revenue DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/*==============================================================================
    72. QUERY TUNING IS NOT ONLY INDEXING
==============================================================================*/

/*
    Potential improvements can come from:

        - better predicates
        - correct joins
        - fewer returned columns
        - removing unnecessary DISTINCT
        - better indexes
        - better statistics
        - better result grain
        - reducing unnecessary sorting
        - avoiding implicit conversions
        - pre-aggregation where appropriate
        - improving transaction/concurrency design

    "Add an index" is not a complete tuning methodology.
*/


/*==============================================================================
    73. BAD PATTERN: FUNCTION-BASED DATE FILTER
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE CONVERT(VARCHAR(10), order_date, 120) >= '2025-01-01';
GO

/*
    Converting the column during filtering generally makes efficient range
    access harder.

    Compare against direct date predicates.
*/


/*==============================================================================
    74. BETTER DIRECT DATE PREDICATE
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE order_date >= '20250101';
GO


/*==============================================================================
    75. BAD PATTERN: UNNECESSARY DISTINCT
==============================================================================*/

SELECT DISTINCT
    product_id,
    product_name,
    category
FROM training.products;
GO

/*
    product_id is already unique.

    DISTINCT cannot remove duplicates from a result containing a unique
    product_id.

    Therefore it is logically unnecessary here.
*/


/*==============================================================================
    76. BETTER VERSION
==============================================================================*/

SELECT
    product_id,
    product_name,
    category
FROM training.products;
GO


/*==============================================================================
    77. RESULT GRAIN AND PERFORMANCE
==============================================================================*/

/*
    Suppose we want:

        one row per customer

    Joining:

        customer
        -> orders
        -> order_items

    creates a lower-grain intermediate result:

        one row per order item

    We must understand this before aggregation.

    Incorrect grain can create:

        incorrect calculations
        unnecessary row multiplication
        unnecessary CPU/memory/I/O
*/


/*==============================================================================
    78. BUSINESS QUERY WITH EXPLICIT GRAIN
==============================================================================*/

WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(cr.revenue, 0) AS completed_revenue
FROM training.customers AS c
LEFT JOIN CustomerRevenue AS cr
    ON cr.customer_id = c.customer_id
ORDER BY
    completed_revenue DESC,
    c.customer_id;
GO


/*==============================================================================
    79. FREQUENCY MATTERS
==============================================================================*/

/*
    Optimization priority should consider workload frequency.

    Example:

        Query A:
            500 ms
            once per month

        Query B:
            50 ms
            1,000,000 times per day

    Query B may consume far more total system resources.

    Tune the workload, not merely the slowest-looking isolated query.
*/


/*==============================================================================
    80. CONCURRENCY MATTERS
==============================================================================*/

/*
    Query performance and Chapter 10 are connected.

    A query can become operationally expensive because it:

        holds locks too long
        blocks other sessions
        consumes excessive memory
        runs too frequently
        generates excessive I/O

    Performance tuning is system-level work, not merely stopwatch tuning.
*/


/*==============================================================================
    81. SHOW ALL EXPERIMENTAL INDEXES
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.has_filter,
    i.filter_definition
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
    82. CLEAN UP EXPERIMENTAL INDEXES

    The repository should not permanently accumulate indexes merely because
    examples.sql was executed.
==============================================================================*/


/*------------------------------------------------------------------------------
    orders
------------------------------------------------------------------------------*/

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


IF EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('training.orders')
      AND name = 'IX_orders_customer_date_desc'
)
BEGIN
    DROP INDEX IX_orders_customer_date_desc
    ON training.orders;
END;
GO


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


/*------------------------------------------------------------------------------
    customers
------------------------------------------------------------------------------*/

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


/*------------------------------------------------------------------------------
    order_items
------------------------------------------------------------------------------*/

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


/*------------------------------------------------------------------------------
    products
------------------------------------------------------------------------------*/

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


/*==============================================================================
    83. VERIFY CLEANUP
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
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
    84. FINAL PERFORMANCE CHECKLIST
==============================================================================*/

/*
    Before tuning:

        1. Confirm the query is logically correct.
        2. Understand the intended result grain.
        3. Identify whether the query matters to the workload.
        4. Capture a baseline.


    During analysis:

        5. Inspect Actual Execution Plan.
        6. Inspect logical reads.
        7. Inspect CPU and elapsed time.
        8. Compare estimated vs actual rows.
        9. Look for unnecessary scans/lookups/sorts.
       10. Check predicates for SARGability.
       11. Check data types for implicit conversion.
       12. Inspect existing indexes before creating another one.


    When designing an index:

       13. Consider equality predicates.
       14. Consider range predicates.
       15. Consider JOIN columns.
       16. Consider ORDER BY.
       17. Consider useful INCLUDE columns.
       18. Consider selectivity.
       19. Consider write cost.
       20. Consider overlap with existing indexes.


    After the change:

       21. Run the same workload again.
       22. Compare logical reads.
       23. Compare CPU.
       24. Compare elapsed time.
       25. Compare plans.
       26. Verify the exact same business result.
       27. Consider impact on INSERT/UPDATE/DELETE.
       28. Consider broader workload effects.
*/


/*==============================================================================
    85. KEY TAKEAWAYS
==============================================================================*/

/*
    1. Indexes are access structures, not magic performance switches.

    2. A table can have one clustered index and multiple nonclustered indexes.

    3. Seek does not automatically mean fast.

    4. Scan does not automatically mean slow.

    5. Selectivity strongly influences useful access strategies.

    6. Composite index column order matters.

    7. A common pattern is equality columns followed by range columns.

    8. INCLUDE columns can help create covering indexes.

    9. Key Lookups can be efficient for few rows and expensive for many rows.

    10. SARGable predicates give SQL Server better index-search opportunities.

    11. Prefer direct date ranges over YEAR()/MONTH() filtering when possible.

    12. Leading wildcards are generally difficult for standard B-tree searches.

    13. Avoid unnecessary functions and conversions on searchable columns.

    14. Use Actual Execution Plans to understand real execution behavior.

    15. Compare estimated rows with actual rows.

    16. Statistics help SQL Server estimate cardinality.

    17. SET STATISTICS IO exposes logical-read information.

    18. SET STATISTICS TIME exposes CPU/elapsed-time information.

    19. Join columns and foreign-key columns are worth evaluating for indexes.

    20. A foreign key does not automatically guarantee a supporting index.

    21. Filtered indexes can optimize important subsets of data.

    22. Too many indexes hurt writes and consume resources.

    23. Do not create every missing-index suggestion automatically.

    24. Do not force indexes or join strategies without strong evidence.

    25. CTEs do not automatically materialize intermediate data.

    26. DISTINCT should not be used to hide incorrect joins.

    27. Result grain matters for both correctness and performance.

    28. Small training tables may produce different plans from production data.

    29. Performance tuning must consider concurrency and workload frequency.

    30. The core optimization loop is:

            Measure
              ->
            Understand
              ->
            Change
              ->
            Measure again
*/


/*==============================================================================
    END OF EXAMPLES

    Next file:
        exercises.sql
==============================================================================*/