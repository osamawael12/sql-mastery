/*
============================================================
SQL MASTERY
07 - SET OPERATIONS

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - UNION
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 2 - UNION ALL
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 3 - UNION CUSTOMER / PRODUCT NAMES
   ========================================================== */

SELECT
    customer_name AS entity_name
FROM training.customers

UNION

SELECT
    product_name
FROM training.products;
GO


/* ==========================================================
   EXERCISE 4 - UNION ALL ENTITIES
   ========================================================== */

SELECT
    customer_id AS entity_id,
    customer_name AS entity_name,
    'Customer' AS entity_type
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name,
    'Product'
FROM training.products;
GO


/* ==========================================================
   EXERCISE 5 - ORDER FINAL RESULT
   ========================================================== */

SELECT
    customer_id AS entity_id,
    customer_name AS entity_name,
    'Customer' AS entity_type
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name,
    'Product'
FROM training.products

ORDER BY
    entity_type ASC,
    entity_name ASC;
GO


/* ==========================================================
   EXERCISE 6 - EXPLICIT CAST
   ========================================================== */

SELECT
    CAST(customer_id AS VARCHAR(20)) AS entity_id,
    customer_name AS entity_name,
    'Customer' AS entity_type
FROM training.customers

UNION ALL

SELECT
    CAST(product_id AS VARCHAR(20)),
    product_name,
    'Product'
FROM training.products;
GO


/* ==========================================================
   EXERCISE 7 - COMPLETED / PENDING
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


/* ==========================================================
   EXERCISE 8 - INTERSECT
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 9 - INTERSECT + DETAILS
   ========================================================== */

;WITH TargetCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    INTERSECT

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM TargetCustomers AS tc

INNER JOIN training.customers AS c
    ON tc.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 10 - EXCEPT
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

EXCEPT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 11 - EXCEPT + CUSTOMER DETAILS
   ========================================================== */

;WITH TargetCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.city
FROM TargetCustomers AS tc

INNER JOIN training.customers AS c
    ON tc.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 12 - CUSTOMERS WITHOUT ORDERS
   ========================================================== */

SELECT
    customer_id
FROM training.customers

EXCEPT

SELECT
    customer_id
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 13 - CUSTOMERS WITHOUT ORDERS - DETAILS
   ========================================================== */

;WITH CustomersWithoutOrders AS
(
    SELECT
        customer_id
    FROM training.customers

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
)
SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM CustomersWithoutOrders AS x

INNER JOIN training.customers AS c
    ON x.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 14 - REVERSE EXCEPT
   ========================================================== */

SELECT
    customer_id
FROM training.orders

EXCEPT

SELECT
    customer_id
FROM training.customers;
GO


/*
Expected:

Normally no rows.

orders.customer_id has a Foreign Key to:

training.customers(customer_id)

so an order should not reference a non-existing customer.
*/


/* ==========================================================
   EXERCISE 15 - PRODUCTS NEVER ORDERED
   ========================================================== */

SELECT
    product_id
FROM training.products

EXCEPT

SELECT
    product_id
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 16 - UNSOLD PRODUCT DETAILS
   ========================================================== */

;WITH UnsoldProducts AS
(
    SELECT
        product_id
    FROM training.products

    EXCEPT

    SELECT
        product_id
    FROM training.order_items
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM UnsoldProducts AS u

INNER JOIN training.products AS p
    ON u.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   EXERCISE 17 - PRODUCTS IN BOTH ORDER GROUPS
   ========================================================== */

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

INTERSECT

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 18 - COMPLETED BUT NOT CANCELLED PRODUCTS
   ========================================================== */

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

EXCEPT

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 19 - PRODUCT DETAILS
   ========================================================== */

;WITH TargetProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    EXCEPT

    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Cancelled'
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM TargetProducts AS tp

INNER JOIN training.products AS p
    ON tp.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   EXERCISE 20 - NAMED SETS
   ========================================================== */

;WITH CompletedCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    customer_id
FROM CompletedCustomers

INTERSECT

SELECT
    customer_id
FROM CancelledCustomers;
GO


/* ==========================================================
   EXERCISE 21 - NAMED SETS + EXCEPT
   ========================================================== */

;WITH CompletedCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    customer_id
FROM CompletedCustomers

EXCEPT

SELECT
    customer_id
FROM CancelledCustomers;
GO


/* ==========================================================
   EXERCISE 22 - NAMED SETS + UNION
   ========================================================== */

;WITH CompletedCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    customer_id
FROM CompletedCustomers

UNION

SELECT
    customer_id
FROM CancelledCustomers;
GO


/* ==========================================================
   EXERCISE 23 - GROUP MEMBERSHIP
   ========================================================== */

SELECT DISTINCT
    customer_id,
    'Completed' AS group_name
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT DISTINCT
    customer_id,
    'Cancelled'
FROM training.orders
WHERE order_status = 'Cancelled'

ORDER BY
    customer_id,
    group_name;
GO


/* ==========================================================
   EXERCISE 24 - MEMBERSHIP WITH CUSTOMER NAMES
   ========================================================== */

;WITH CustomerGroups AS
(
    SELECT DISTINCT
        customer_id,
        'Completed' AS group_name
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION ALL

    SELECT DISTINCT
        customer_id,
        'Cancelled'
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    cg.customer_id,
    c.customer_name,
    cg.group_name
FROM CustomerGroups AS cg

INNER JOIN training.customers AS c
    ON cg.customer_id = c.customer_id

ORDER BY
    c.customer_name,
    cg.group_name;
GO


/* ==========================================================
   EXERCISE 25 - VERTICAL ORDER METRICS
   ========================================================== */

SELECT
    'Completed Orders' AS metric,
    COUNT(*) AS metric_value
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    'Cancelled Orders',
    COUNT(*)
FROM training.orders
WHERE order_status = 'Cancelled'

UNION ALL

SELECT
    'Pending Orders',
    COUNT(*)
FROM training.orders
WHERE order_status = 'Pending';
GO


/* ==========================================================
   EXERCISE 26 - SYSTEM SUMMARY
   ========================================================== */

SELECT
    'Customers' AS metric,
    COUNT(*) AS metric_value
FROM training.customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM training.products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM training.orders

UNION ALL

SELECT
    'Order Items',
    COUNT(*)
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 27 - BUSINESS METRIC SUMMARY
   ========================================================== */

SELECT
    'Total Orders' AS metric,
    CAST(COUNT(*) AS DECIMAL(18,2)) AS metric_value
FROM training.orders

UNION ALL

SELECT
    'Total Units',
    CAST(SUM(quantity) AS DECIMAL(18,2))
FROM training.order_items

UNION ALL

SELECT
    'Gross Order Item Value',
    CAST(
        SUM(quantity * unit_price)
        AS DECIMAL(18,2)
    )
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 28 - ORDER STATUS VALUE
   ========================================================== */

SELECT
    'Completed Value' AS metric,
    SUM(oi.quantity * oi.unit_price) AS metric_value
FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

UNION ALL

SELECT
    'Cancelled Value',
    SUM(oi.quantity * oi.unit_price)
FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Cancelled';
GO


/* ==========================================================
   EXERCISE 29 - SET OPERATION INSIDE CTE
   ========================================================== */

;WITH CombinedEntities AS
(
    SELECT
        customer_id AS entity_id,
        customer_name AS entity_name,
        'Customer' AS entity_type
    FROM training.customers

    UNION ALL

    SELECT
        product_id,
        product_name,
        'Product'
    FROM training.products
)
SELECT
    entity_id,
    entity_name,
    entity_type
FROM CombinedEntities
ORDER BY
    entity_type,
    entity_name;
GO


/* ==========================================================
   EXERCISE 30 - AGGREGATE SET RESULT
   ========================================================== */

;WITH CombinedEntities AS
(
    SELECT
        'Customer' AS entity_type
    FROM training.customers

    UNION ALL

    SELECT
        'Product'
    FROM training.products
)
SELECT
    entity_type,
    COUNT(*) AS entity_count
FROM CombinedEntities
GROUP BY entity_type
ORDER BY entity_type;
GO


/* ==========================================================
   EXERCISE 31 - COMPLETED ONLY SEGMENT
   ========================================================== */

;WITH CompletedOnly AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(c.city, N'Unknown') AS display_city
FROM CompletedOnly AS x

INNER JOIN training.customers AS c
    ON x.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 32 - BOTH GROUPS SEGMENT
   ========================================================== */

;WITH BothGroups AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    INTERSECT

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    c.customer_id,
    c.customer_name
FROM BothGroups AS x

INNER JOIN training.customers AS c
    ON x.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 33 - NO ORDERS SEGMENT
   ========================================================== */

;WITH NoOrders AS
(
    SELECT
        customer_id
    FROM training.customers

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
)
SELECT
    c.customer_id,
    c.customer_name
FROM NoOrders AS x

INNER JOIN training.customers AS c
    ON x.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   EXERCISE 34 - PRODUCT SET LABELS
   ========================================================== */

SELECT DISTINCT
    product_id,
    'Ordered' AS group_name
FROM training.order_items

UNION ALL

SELECT
    product_id,
    'Active'
FROM training.products
WHERE is_active = 1

ORDER BY
    product_id,
    group_name;
GO


/* ==========================================================
   EXERCISE 35 - COMPLETED PRODUCT DETAILS
   ========================================================== */

;WITH CompletedProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
)
SELECT DISTINCT
    p.product_id,
    p.product_name,
    p.category
FROM CompletedProducts AS cp

INNER JOIN training.products AS p
    ON cp.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   EXERCISE 36 - SHARED PRODUCT DETAILS
   ========================================================== */

;WITH CompletedProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
),
CancelledProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Cancelled'
),
SharedProducts AS
(
    SELECT product_id
    FROM CompletedProducts

    INTERSECT

    SELECT product_id
    FROM CancelledProducts
)
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM SharedProducts AS sp

INNER JOIN training.products AS p
    ON sp.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   EXERCISE 37 - COMPLETED-ONLY PRODUCT DETAILS
   ========================================================== */

;WITH CompletedProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
),
CancelledProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Cancelled'
),
CompletedOnly AS
(
    SELECT product_id
    FROM CompletedProducts

    EXCEPT

    SELECT product_id
    FROM CancelledProducts
)
SELECT
    p.product_id,
    p.product_name,
    p.category
FROM CompletedOnly AS x

INNER JOIN training.products AS p
    ON x.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   EXERCISE 38 - SEGMENT COUNTS
   ========================================================== */

;WITH NoOrders AS
(
    SELECT customer_id
    FROM training.customers

    EXCEPT

    SELECT customer_id
    FROM training.orders
),
CustomerSegments AS
(
    SELECT DISTINCT
        customer_id,
        'Completed Buyer' AS segment
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION ALL

    SELECT DISTINCT
        customer_id,
        'Cancelled Buyer'
    FROM training.orders
    WHERE order_status = 'Cancelled'

    UNION ALL

    SELECT
        customer_id,
        'No Orders'
    FROM NoOrders
)
SELECT
    segment,
    COUNT(*) AS customer_count
FROM CustomerSegments
GROUP BY segment
ORDER BY customer_count DESC;
GO


/* ==========================================================
   EXERCISE 39 - THINK ABOUT UNION
   ========================================================== */

/*
Answer:

1.

1
2
3
4

2. 4 rows.

3. UNION combines the two results and removes
   duplicate rows.

Values 2 and 3 occur in both inputs but appear only
once in the final result.
*/


/* ==========================================================
   EXERCISE 40 - THINK ABOUT UNION ALL
   ========================================================== */

/*
Answer:

1.

1
2
3
2
3
4

2. 6 rows.

3. UNION ALL appends all source rows without
   performing duplicate elimination.
*/


/* ==========================================================
   EXERCISE 41 - THINK ABOUT INTERSECT
   ========================================================== */

/*
Answer:

2
3

These are the values appearing in both sets.
*/


/* ==========================================================
   EXERCISE 42 - THINK ABOUT EXCEPT
   ========================================================== */

/*
Answer:

1. A EXCEPT B:

   1

2. B EXCEPT A:

   4

3. EXCEPT means:

   rows in the first set that do not appear
   in the second set.

Therefore direction changes the meaning.
*/


/* ==========================================================
   EXERCISE 43 - COLUMN MATCHING
   ========================================================== */

/*
Answer:

1. Position.

2. The second SELECT places:

       product_name

   in the position corresponding to:

       customer_id

   and:

       product_id

   in the position corresponding to:

       customer_name

   The output schema is logically misaligned and may
   also cause a conversion error due to data type
   precedence.

3. It should be:

       SELECT
           product_id,
           product_name
       FROM training.products
*/


/* ==========================================================
   EXERCISE 44 - UNION vs JOIN
   ========================================================== */

/*
Answer:

1. JOIN

2. SET OPERATION

3. SET OPERATION
   Specifically INTERSECT.

4. JOIN

5. SET OPERATION
   Specifically EXCEPT.
*/


/* ==========================================================
   EXERCISE 45 - CHOOSE THE SET OPERATOR
   ========================================================== */

/*
Answer:

1. UNION

2. UNION ALL

3. INTERSECT

4. EXCEPT
*/


/* ==========================================================
   EXERCISE 46 - DUPLICATE ROW MEANING
   ========================================================== */

/*
Answer:

No.

These rows:

    1 | Completed
    1 | Cancelled

are different complete rows.

Set duplicate comparison considers all selected
column positions, not just customer_id.
*/


/* ==========================================================
   EXERCISE 47 - OUTPUT COLUMN NAMES
   ========================================================== */

/*
Answer:

1. entity_id

2. entity_name

The first SELECT determines the final output
column names.
*/


/* ==========================================================
   EXERCISE 48 - UNION vs UNION ALL PERFORMANCE
   ========================================================== */

/*
Answer:

1. UNION removes duplicates.

2. UNION ALL appends rows without duplicate elimination.

3. UNION may require additional processing to identify
   and eliminate duplicate rows.

4. No.

   The operator must match the business requirement.

   If unique combined rows are required, UNION may
   be correct.

   If all rows must be preserved, UNION ALL is correct.
*/


/* ==========================================================
   EXERCISE 49 - NULL THINKING
   ========================================================== */

/*
Answer:

In a normal SQL predicate:

    NULL = NULL

does not evaluate to TRUE.

It evaluates to UNKNOWN.

However, set operations that perform distinctness
comparison can treat rows with corresponding NULL
values as duplicates for purposes of UNION,
INTERSECT, and EXCEPT.

Do not confuse normal equality semantics with
set-operation duplicate comparison.
*/


/* ==========================================================
   EXERCISE 50 - MULTIPLE SOLUTIONS
   ========================================================== */

/*
Answer:

1. LEFT JOIN + IS NULL

2. NOT EXISTS

3. EXCEPT

Example ideas:

LEFT JOIN:

    customers
    LEFT JOIN orders
    WHERE order_id IS NULL


NOT EXISTS:

    WHERE NOT EXISTS (...)


EXCEPT:

    customer IDs
    EXCEPT
    order customer IDs
*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER SET CLASSIFICATION
   ========================================================== */

;WITH CompletedCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
),
CompletedOnly AS
(
    SELECT customer_id
    FROM CompletedCustomers

    EXCEPT

    SELECT customer_id
    FROM CancelledCustomers
),
BothGroups AS
(
    SELECT customer_id
    FROM CompletedCustomers

    INTERSECT

    SELECT customer_id
    FROM CancelledCustomers
),
NoOrders AS
(
    SELECT customer_id
    FROM training.customers

    EXCEPT

    SELECT customer_id
    FROM training.orders
),
FinalSegments AS
(
    SELECT
        customer_id,
        'Completed Only' AS segment
    FROM CompletedOnly

    UNION ALL

    SELECT
        customer_id,
        'Completed and Cancelled'
    FROM BothGroups

    UNION ALL

    SELECT
        customer_id,
        'No Orders'
    FROM NoOrders
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(c.city, N'Unknown') AS display_city,
    fs.segment
FROM FinalSegments AS fs

INNER JOIN training.customers AS c
    ON fs.customer_id = c.customer_id

ORDER BY
    fs.segment,
    c.customer_name;
GO


/* ==========================================================
   CHALLENGE 2 - PRODUCT SET CLASSIFICATION
   ========================================================== */

;WITH CompletedProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
),
CancelledProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Cancelled'
),
CompletedOnly AS
(
    SELECT product_id
    FROM CompletedProducts

    EXCEPT

    SELECT product_id
    FROM CancelledProducts
),
BothStatuses AS
(
    SELECT product_id
    FROM CompletedProducts

    INTERSECT

    SELECT product_id
    FROM CancelledProducts
),
NeverOrdered AS
(
    SELECT product_id
    FROM training.products

    EXCEPT

    SELECT product_id
    FROM training.order_items
),
FinalSegments AS
(
    SELECT
        product_id,
        'Completed Only' AS segment
    FROM CompletedOnly

    UNION ALL

    SELECT
        product_id,
        'Both Statuses'
    FROM BothStatuses

    UNION ALL

    SELECT
        product_id,
        'Never Ordered'
    FROM NeverOrdered
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    fs.segment
FROM FinalSegments AS fs

INNER JOIN training.products AS p
    ON fs.product_id = p.product_id

ORDER BY
    fs.segment,
    p.product_name;
GO


/* ==========================================================
   CHALLENGE 3 - BUSINESS KPI STACK
   ========================================================== */

SELECT
    'Total Customers' AS metric,
    CAST(COUNT(*) AS DECIMAL(18,2)) AS metric_value
FROM training.customers

UNION ALL

SELECT
    'Active Customers',
    CAST(COUNT(*) AS DECIMAL(18,2))
FROM training.customers
WHERE is_active = 1

UNION ALL

SELECT
    'Total Orders',
    CAST(COUNT(*) AS DECIMAL(18,2))
FROM training.orders

UNION ALL

SELECT
    'Completed Orders',
    CAST(COUNT(*) AS DECIMAL(18,2))
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    'Cancelled Orders',
    CAST(COUNT(*) AS DECIMAL(18,2))
FROM training.orders
WHERE order_status = 'Cancelled'

UNION ALL

SELECT
    'Total Units',
    CAST(SUM(quantity) AS DECIMAL(18,2))
FROM training.order_items

UNION ALL

SELECT
    'Completed Revenue',
    CAST(
        SUM(oi.quantity * oi.unit_price)
        AS DECIMAL(18,2)
    )
FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   CHALLENGE 4 - CUSTOMER BEHAVIOR MEMBERSHIPS
   ========================================================== */

;WITH NoOrders AS
(
    SELECT
        customer_id
    FROM training.customers

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
),
CustomerGroups AS
(
    SELECT DISTINCT
        customer_id,
        'Has Completed Order' AS group_name
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION ALL

    SELECT DISTINCT
        customer_id,
        'Has Cancelled Order'
    FROM training.orders
    WHERE order_status = 'Cancelled'

    UNION ALL

    SELECT DISTINCT
        o.customer_id,
        'Bought Electronics'
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE p.category = N'Electronics'

    UNION ALL

    SELECT DISTINCT
        o.customer_id,
        'Bought Accessories'
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE p.category = N'Accessories'

    UNION ALL

    SELECT
        customer_id,
        'No Orders'
    FROM NoOrders
)
SELECT
    cg.customer_id,
    c.customer_name,
    cg.group_name
FROM CustomerGroups AS cg

INNER JOIN training.customers AS c
    ON cg.customer_id = c.customer_id

ORDER BY
    c.customer_name,
    cg.group_name;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL SET OPERATIONS CHALLENGE
   ========================================================== */

;WITH CompletedProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'
),
CancelledProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Cancelled'
),
ActiveProducts AS
(
    SELECT
        product_id
    FROM training.products
    WHERE is_active = 1
),
ActiveCompletedProducts AS
(
    SELECT
        product_id
    FROM ActiveProducts

    INTERSECT

    SELECT
        product_id
    FROM CompletedProducts
),
TargetProducts AS
(
    SELECT
        product_id
    FROM ActiveCompletedProducts

    EXCEPT

    SELECT
        product_id
    FROM CancelledProducts
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity
FROM TargetProducts AS tp

INNER JOIN training.products AS p
    ON tp.product_id = p.product_id

ORDER BY p.price DESC;
GO


/* ==========================================================
   FINAL RECAP

   UNION

       A or B
       Removes duplicate rows.


   UNION ALL

       Append A and B.
       Keeps duplicate rows.


   INTERSECT

       Rows in both A and B.


   EXCEPT

       Rows in A but not B.

       Direction matters.


   SET OPERATION REQUIREMENTS:

       Same number of output columns

       Compatible data types

       Columns align by position


   OUTPUT COLUMN NAMES:

       Come from the first SELECT.


   JOIN vs SET:

       JOIN:
           Combine related columns.

       SET:
           Combine or compare compatible rows.


   BUSINESS TRANSLATION:

       A OR B
           UNION

       Append A + B
           UNION ALL

       A AND B
           INTERSECT

       A BUT NOT B
           EXCEPT


   MULTIPLE TECHNIQUES CAN SOLVE
   THE SAME BUSINESS QUESTION:

       LEFT JOIN + IS NULL

       NOT EXISTS

       EXCEPT


   CHOOSE BASED ON:

       Correctness
       Clarity
       NULL behavior
       Required result shape
       Maintainability
       Measured performance

============================================================
END OF CHAPTER 07
============================================================
*/











