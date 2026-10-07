/*
============================================================
SQL MASTERY
07 - SET OPERATIONS

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- UNION
- UNION ALL
- INTERSECT
- EXCEPT
- Duplicate Handling
- Column Compatibility
- Source Labels
- CTEs with Set Operations
- Set Operations vs JOIN / EXISTS
- Business Set Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. UNION

   Unique customers appearing in Completed
   OR Cancelled orders.
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
   2. UNION ALL

   Keep all matching rows.
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
   3. UNION vs UNION ALL

   Compare the number of returned rows.
   ========================================================== */

;WITH UnionResult AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    COUNT(*) AS union_row_count
FROM UnionResult;
GO


;WITH UnionAllResult AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION ALL

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    COUNT(*) AS union_all_row_count
FROM UnionAllResult;
GO


/* ==========================================================
   4. COMBINE CUSTOMER AND PRODUCT NAMES

   Set operations can combine different source tables
   when the output shape is compatible.
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
   5. UNION ALL CUSTOMER AND PRODUCT NAMES
   ========================================================== */

SELECT
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    product_name
FROM training.products;
GO


/* ==========================================================
   6. ADD A SOURCE LABEL

   This makes the origin of each row clear.
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
    entity_type,
    entity_name;
GO


/* ==========================================================
   7. EXPLICIT TYPE ALIGNMENT

   CAST can make the desired output schema explicit.
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
FROM training.products

ORDER BY entity_type, entity_name;
GO


/* ==========================================================
   8. OUTPUT COLUMN NAMES

   Final names come from the first SELECT.
   ========================================================== */

SELECT
    customer_id AS entity_id,
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name
FROM training.products

ORDER BY entity_name;
GO


/* ==========================================================
   9. COMPLETE ROW DEDUPLICATION

   UNION considers the complete selected row.
   ========================================================== */

SELECT
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Cancelled'

ORDER BY customer_id, order_status;
GO


/* ==========================================================
   10. ORDER EVENTS WITH UNION ALL

   Preserve all matching order rows.
   ========================================================== */

SELECT
    order_id,
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    order_id,
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Cancelled'

ORDER BY order_id;
GO


/* ==========================================================
   11. INTERSECT

   Customers who have BOTH:

   - Completed order
   - Cancelled order
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
   12. INTERSECT + CUSTOMER DETAILS

   First identify IDs, then enrich with customer data.
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
   13. EXCEPT

   Customers with Completed orders
   but NO Cancelled orders.
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
   14. EXCEPT + CUSTOMER DETAILS
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
   15. EXCEPT DIRECTION MATTERS

   Customers without orders.
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
   16. REVERSE EXCEPT

   customer IDs from orders that do not exist
   in customers.

   Because a Foreign Key exists, this should
   normally return no rows.
   ========================================================== */

SELECT
    customer_id
FROM training.orders

EXCEPT

SELECT
    customer_id
FROM training.customers;
GO


/* ==========================================================
   17. CUSTOMERS WITHOUT ORDERS - DETAILS
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
    c.email,
    c.city
FROM CustomersWithoutOrders AS x

INNER JOIN training.customers AS c
    ON x.customer_id = c.customer_id;
GO


/* ==========================================================
   18. EXCEPT vs NOT EXISTS

   EXCEPT version:
   ========================================================== */

SELECT
    customer_id
FROM training.customers

EXCEPT

SELECT
    customer_id
FROM training.orders;
GO


/*
NOT EXISTS version:
*/

SELECT
    c.customer_id
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   19. PRODUCTS NEVER ORDERED - EXCEPT
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
   20. PRODUCTS NEVER ORDERED - DETAILS
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
   21. PRODUCTS IN COMPLETED ORDERS

   Build the first product set.
   ========================================================== */

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   22. PRODUCTS IN CANCELLED ORDERS
   ========================================================== */

SELECT
    oi.product_id
FROM training.order_items AS oi

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Cancelled';
GO


/* ==========================================================
   23. PRODUCTS IN BOTH COMPLETED AND CANCELLED ORDERS
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
   24. PRODUCTS IN COMPLETED BUT NOT CANCELLED
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
   25. ENRICH PRODUCT SET RESULT
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
   26. CTEs AS NAMED SETS
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
   27. NAMED SETS + EXCEPT
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
   28. UNIQUE CUSTOMERS IN EITHER GROUP
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
   29. CUSTOMER GROUP MEMBERSHIP

   DISTINCT within each source group prevents
   duplicates caused by multiple orders of
   the same status.

   UNION ALL preserves membership in both groups.
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

ORDER BY customer_id, group_name;
GO


/* ==========================================================
   30. SEGMENTATION REPORT WITH CUSTOMER NAMES
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
   31. AGGREGATION BEFORE UNION ALL

   Vertical order-status metrics.
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
   32. SYSTEM SUMMARY

   Combine counts from different tables.
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
   33. BUSINESS METRICS WITH DIFFERENT AGGREGATES
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
   34. COMPLETED VS CANCELLED VALUE

   Vertical financial metric report.
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
   35. UNION ALL INSIDE A CTE
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
   36. AGGREGATE SET-OPERATION RESULTS
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
   37. UNION vs CONDITIONAL AGGREGATION

   Vertical format:
   ========================================================== */

SELECT
    'Completed' AS order_status,
    COUNT(*) AS order_count
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    'Cancelled',
    COUNT(*)
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/*
Horizontal format using conditional aggregation:
*/

SELECT
    SUM(
        CASE
            WHEN order_status = 'Completed'
                THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) AS cancelled_orders

FROM training.orders;
GO


/* ==========================================================
   38. COMPLETED CUSTOMERS EXCEPT CANCELLED
   vs
   EXISTS + NOT EXISTS
   ========================================================== */

-- Set operation version:

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


-- EXISTS version:

SELECT
    c.customer_id
FROM training.customers AS c

WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)

AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Cancelled'
);
GO


/* ==========================================================
   39. PRODUCTS ORDERED OR ACTIVE

   Demonstrates UNION between different logical sets
   that share the same entity key.
   ========================================================== */

SELECT
    product_id
FROM training.order_items

UNION

SELECT
    product_id
FROM training.products
WHERE is_active = 1;
GO


/* ==========================================================
   40. PRODUCT SET WITH SOURCE LABELS

   A product can appear in multiple groups.
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

ORDER BY product_id, group_name;
GO


/* ==========================================================
   41. CUSTOMERS IN COMPLETED OR PENDING GROUPS
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
   42. CUSTOMERS IN BOTH COMPLETED AND PENDING
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


/* ==========================================================
   43. COMPLETED BUT NOT PENDING
   ========================================================== */

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

EXCEPT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


/* ==========================================================
   44. BUSINESS QUESTION

   Customers who have:
   - Completed order
   - No Cancelled order

   Then display descriptive information.
   ========================================================== */

;WITH EligibleCustomers AS
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
    COALESCE(c.city, N'Unknown') AS city,
    c.signup_date
FROM EligibleCustomers AS ec

INNER JOIN training.customers AS c
    ON ec.customer_id = c.customer_id

ORDER BY c.customer_name;
GO


/* ==========================================================
   45. BUSINESS QUESTION

   Products sold in Completed orders but never
   appearing in Cancelled orders.
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
TargetProducts AS
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
    p.category,
    p.price
FROM TargetProducts AS tp

INNER JOIN training.products AS p
    ON tp.product_id = p.product_id

ORDER BY p.product_name;
GO


/* ==========================================================
   46. BUSINESS QUESTION

   Products that appeared in BOTH Completed
   and Cancelled orders.
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
    ON sp.product_id = p.product_id;
GO


/* ==========================================================
   47. BUSINESS SEGMENT MEMBERSHIP

   Create one row per customer/group membership.
   ========================================================== */

;WITH CustomerSegments AS
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
    FROM training.customers

    EXCEPT

    SELECT
        customer_id,
        'No Orders'
    FROM training.orders
)
SELECT *
FROM CustomerSegments
ORDER BY
    customer_id,
    segment;
GO


/*
Important:

The final branch above demonstrates set-shape thinking,
but mixing EXCEPT into labeled membership logic can become
hard to read.

For real business work, prefer a clearer named-set structure
when the logic becomes complex.
*/


/* ==========================================================
   48. CLEARER NO-ORDER SEGMENT
   ========================================================== */

;WITH CustomersWithoutOrders AS
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
    FROM CustomersWithoutOrders
)
SELECT
    cs.customer_id,
    c.customer_name,
    cs.segment
FROM CustomerSegments AS cs

INNER JOIN training.customers AS c
    ON cs.customer_id = c.customer_id

ORDER BY
    c.customer_name,
    cs.segment;
GO


/* ==========================================================
   49. SET RESULT + AGGREGATION

   Count customers in each segment.

   A customer may belong to multiple segments.
   ========================================================== */

;WITH CustomersWithoutOrders AS
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
    FROM CustomersWithoutOrders
)
SELECT
    segment,
    COUNT(*) AS customer_count
FROM CustomerSegments
GROUP BY segment
ORDER BY customer_count DESC;
GO


/* ==========================================================
   50. FINAL BUSINESS EXAMPLE

   Build a set-based customer classification report.

   Groups:

   A:
       Completed customers

   B:
       Cancelled customers

   Derive:

   - Completed Only
   - Both Completed and Cancelled
   - No Orders
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
    COALESCE(c.city, N'Unknown') AS city,
    fs.segment
FROM FinalSegments AS fs

INNER JOIN training.customers AS c
    ON fs.customer_id = c.customer_id

ORDER BY
    fs.segment,
    c.customer_name;
GO


/* ==========================================================
   FINAL RECAP

   UNION
       Combine rows and remove duplicates.

   UNION ALL
       Combine rows and preserve duplicates.

   INTERSECT
       Return rows common to both sets.

   EXCEPT
       Return rows in the first set but not
       the second.


   REQUIREMENTS:

   - Same number of output columns
   - Compatible data types
   - Columns align by position


   REMEMBER:

   A EXCEPT B
       is NOT the same as
   B EXCEPT A


   JOIN:

       Combines related columns horizontally.

   SET OPERATION:

       Combines or compares rows vertically.


   BUSINESS THINKING:

   A OR B
       -> UNION

   Append A + B
       -> UNION ALL

   A AND B
       -> INTERSECT

   A BUT NOT B
       -> EXCEPT


   SET OPERATIONS CAN WORK WITH:

   - CTEs
   - JOINs
   - Aggregation
   - CASE
   - Subqueries
   - Business segmentation

============================================================
END OF EXAMPLES
============================================================
*/