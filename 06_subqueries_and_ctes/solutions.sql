/*
============================================================
SQL MASTERY
06 - SUBQUERIES AND CTEs

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - ABOVE AVERAGE PRICE
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 2 - HIGHEST PRICE
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 3 - LOWEST PRICE
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 4 - SUBQUERY IN SELECT
   ========================================================== */

SELECT
    product_name,
    price,
    (
        SELECT AVG(price)
        FROM training.products
    ) AS overall_average_price
FROM training.products;
GO


/* ==========================================================
   EXERCISE 5 - DIFFERENCE FROM AVERAGE
   ========================================================== */

SELECT
    product_name,
    price,

    (
        SELECT AVG(price)
        FROM training.products
    ) AS overall_average_price,

    price -
    (
        SELECT AVG(price)
        FROM training.products
    ) AS difference_from_average

FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 6 - IN SUBQUERY
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
);
GO


/* ==========================================================
   EXERCISE 7 - COMPLETED ORDER CUSTOMERS
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 8 - CANCELLED ORDER CUSTOMERS
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
);
GO


/* ==========================================================
   EXERCISE 9 - NOT IN
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM training.orders
);
GO


/* ==========================================================
   EXERCISE 10 - EXISTS
   ========================================================== */

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


/* ==========================================================
   EXERCISE 11 - EXISTS WITH CONDITION
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 12 - NOT EXISTS
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 13 - NO COMPLETED ORDERS
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 14 - PRODUCTS THAT WERE ORDERED
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 15 - PRODUCTS NEVER ORDERED
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 16 - COMPLETED ORDER PRODUCTS
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   EXERCISE 17 - NEVER IN COMPLETED ORDER
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   EXERCISE 18 - CORRELATED ORDER COUNT
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS order_count

FROM training.customers AS c
ORDER BY order_count DESC;
GO


/* ==========================================================
   EXERCISE 19 - CORRELATED COMPLETED COUNT
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    ) AS completed_order_count

FROM training.customers AS c
ORDER BY completed_order_count DESC;
GO


/* ==========================================================
   EXERCISE 20 - LATEST ORDER
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT MAX(o.order_date)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS latest_order_date

FROM training.customers AS c
ORDER BY latest_order_date DESC;
GO


/* ==========================================================
   EXERCISE 21 - ABOVE CATEGORY AVERAGE
   ========================================================== */

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
)
ORDER BY
    p.category,
    p.price DESC;
GO


/* ==========================================================
   EXERCISE 22 - DISPLAY CATEGORY AVERAGE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,

    (
        SELECT AVG(p2.price)
        FROM training.products AS p2
        WHERE p2.category = p.category
    ) AS category_average_price

FROM training.products AS p
ORDER BY
    p.category,
    p.price DESC;
GO


/* ==========================================================
   EXERCISE 23 - DERIVED TABLE
   ========================================================== */

SELECT
    totals.order_id,
    totals.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   EXERCISE 24 - FILTER DERIVED TABLE
   ========================================================== */

SELECT
    totals.order_id,
    totals.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
WHERE totals.order_value >= 3000
ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   EXERCISE 25 - JOIN DERIVED TABLE
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_status,
    totals.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
    ON o.order_id = totals.order_id

ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   EXERCISE 26 - COMPLETED HIGH-VALUE ORDERS
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    totals.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
    ON o.order_id = totals.order_id

WHERE o.order_status = 'Completed'
  AND totals.order_value >= 3000

ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   EXERCISE 27 - FIRST CTE
   ========================================================== */

;WITH ExpensiveProducts AS
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
FROM ExpensiveProducts
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 28 - ORDER TOTALS CTE
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 29 - FILTER CTE RESULT
   ========================================================== */

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
GO


/* ==========================================================
   EXERCISE 30 - CTE + JOIN
   ========================================================== */

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
    o.order_date,
    o.order_status,
    ot.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   EXERCISE 31 - MULTIPLE CTEs
   ========================================================== */

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

INNER JOIN OrderTotals AS ot
    ON co.order_id = ot.order_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   EXERCISE 32 - CTE DEPENDS ON CTE
   ========================================================== */

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
SELECT
    order_id,
    order_value
FROM HighValueOrders
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 33 - CUSTOMER COMPLETED REVENUE
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   EXERCISE 34 - HIGH-VALUE CUSTOMERS
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

WHERE cr.revenue >= 3000
ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   EXERCISE 35 - PRODUCT PERFORMANCE CTE
   ========================================================== */

;WITH ProductPerformance AS
(
    SELECT
        oi.product_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    pp.order_count,
    pp.units_sold,
    pp.revenue
FROM ProductPerformance AS pp

INNER JOIN training.products AS p
    ON pp.product_id = p.product_id

ORDER BY pp.revenue DESC;
GO


/* ==========================================================
   EXERCISE 36 - CUSTOMER METRICS CTE
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN o.order_id
            END
        ) AS cancelled_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cm.total_orders,
    cm.completed_orders,
    cm.cancelled_orders
FROM CustomerMetrics AS cm

INNER JOIN training.customers AS c
    ON cm.customer_id = c.customer_id

ORDER BY cm.total_orders DESC;
GO


/* ==========================================================
   EXERCISE 37 - FILTER CUSTOMER METRICS
   ========================================================== */

;WITH CustomerMetrics AS
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
    c.customer_id,
    c.customer_name,
    cm.total_orders,
    cm.completed_orders
FROM CustomerMetrics AS cm

INNER JOIN training.customers AS c
    ON cm.customer_id = c.customer_id

WHERE cm.total_orders >= 2
  AND cm.completed_orders >= 1

ORDER BY cm.total_orders DESC;
GO


/* ==========================================================
   EXERCISE 38 - ABOVE-AVERAGE ORDER COUNT
   ========================================================== */

;WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM training.orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    co.order_count
FROM CustomerOrders AS co

INNER JOIN training.customers AS c
    ON co.customer_id = c.customer_id

WHERE co.order_count >
(
    SELECT
        AVG(1.0 * order_count)
    FROM CustomerOrders
)

ORDER BY co.order_count DESC;
GO


/* ==========================================================
   EXERCISE 39 - ABOVE-AVERAGE CUSTOMER REVENUE
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

WHERE cr.revenue >
(
    SELECT AVG(revenue)
    FROM CustomerRevenue
)

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   EXERCISE 40 - ORDER VALUE ABOVE AVERAGE
   ========================================================== */

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
WHERE order_value >
(
    SELECT AVG(order_value)
    FROM OrderTotals
)
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 41 - ACTIVE CUSTOMERS WITHOUT ORDERS
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM training.customers AS c
WHERE c.is_active = 1
  AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   EXERCISE 42 - CUSTOMERS WHO BOUGHT ACCESSORIES
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.customer_id = c.customer_id
      AND p.category = N'Accessories'
);
GO


/* ==========================================================
   EXERCISE 43 - NEVER BOUGHT ELECTRONICS
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.customer_id = c.customer_id
      AND p.category = N'Electronics'
);
GO


/* ==========================================================
   EXERCISE 44 - COMPLETED BUT NEVER CANCELLED
   ========================================================== */

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
   EXERCISE 45 - PRE-AGGREGATION
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        COUNT(*) AS line_count,
        SUM(quantity) AS total_units,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.customer_name,
    o.order_status,
    ot.line_count,
    ot.total_units,
    ot.order_value
FROM OrderTotals AS ot

INNER JOIN training.orders AS o
    ON ot.order_id = o.order_id

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   EXERCISE 46 - THINK ABOUT SCALAR SUBQUERIES
   ========================================================== */

/*
Answer:

1. No, not if the subquery returns more than one row.

2. The = operator expects one scalar value.

   A subquery returning multiple rows cannot be used
   as a single scalar value.

   SQL Server will produce an error such as:

   "Subquery returned more than 1 value."

3. Depending on the business requirement:

   IN

   EXISTS

   could be appropriate.

   A JOIN may also be appropriate when columns from
   the related rows are required.
*/


/* ==========================================================
   EXERCISE 47 - THINK ABOUT EXISTS
   ========================================================== */

/*
Answer:

1. EXISTS tests whether the subquery produces at
   least one matching row.

2. SELECT 1 is commonly used because the actual
   selected value is not important to EXISTS.

3. No.

   EXISTS only needs to determine whether a
   qualifying row exists.
*/


/* ==========================================================
   EXERCISE 48 - NOT IN AND NULL
   ========================================================== */

/*
Answer:

SQL uses three-valued logic.

If a NOT IN list/subquery contains NULL, comparisons
involving that unknown value can cause the condition
to evaluate to UNKNOWN rather than TRUE.

This can result in rows not being returned even when
that seems surprising.

For relationship absence checks, a common robust
pattern is:

    NOT EXISTS
    (
        SELECT 1
        FROM ...
        WHERE inner_key = outer_key
    )
*/


/* ==========================================================
   EXERCISE 49 - CTE SCOPE
   ========================================================== */

/*
Answer:

1. No.

2. ProductData exists only for the statement
   immediately following the CTE definition.

   Once that statement finishes, the CTE is
   out of scope.

3. No.

   A CTE is not a permanent table.
*/


/* ==========================================================
   EXERCISE 50 - CTE vs PERFORMANCE
   ========================================================== */

/*
Answer:

1. No.

   Using a CTE does not guarantee a faster query.

2. The main reasons here are:

   - Query organization
   - Readability
   - Naming intermediate results
   - Breaking complex logic into stages
   - Making result grain easier to reason about

3. When performance matters, examine the actual
   query behavior and execution plan, together with
   data volume, indexes, predicates, join strategy,
   statistics, and other relevant factors.
*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER REVENUE BENCHMARK
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id)
            AS completed_orders,

        SUM(oi.quantity * oi.unit_price)
            AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
),
RevenueBenchmark AS
(
    SELECT
        AVG(revenue) AS average_revenue
    FROM CustomerRevenue
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.completed_orders,
    cr.revenue,
    rb.average_revenue,

    cr.revenue - rb.average_revenue
        AS difference_from_average

FROM CustomerRevenue AS cr

CROSS JOIN RevenueBenchmark AS rb

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

WHERE cr.revenue > rb.average_revenue

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   CHALLENGE 2 - PRODUCT CATEGORY BENCHMARK
   ========================================================== */

;WITH CategoryAverages AS
(
    SELECT
        category,
        AVG(price) AS category_average_price
    FROM training.products
    GROUP BY category
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    ca.category_average_price,

    p.price - ca.category_average_price
        AS difference_from_average

FROM training.products AS p

INNER JOIN CategoryAverages AS ca
    ON p.category = ca.category

WHERE p.price > ca.category_average_price

ORDER BY
    p.category,
    difference_from_average DESC;
GO


/* ==========================================================
   CHALLENGE 3 - CUSTOMER PERFORMANCE PIPELINE
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity) AS total_units,
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
CustomerPerformance AS
(
    SELECT
        co.customer_id,

        COUNT(co.order_id)
            AS completed_order_count,

        SUM(ot.total_units)
            AS total_units,

        SUM(ot.order_value)
            AS revenue

    FROM CompletedOrders AS co

    INNER JOIN OrderTotals AS ot
        ON co.order_id = ot.order_id

    GROUP BY co.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cp.completed_order_count,
    cp.total_units,
    cp.revenue
FROM CustomerPerformance AS cp

INNER JOIN training.customers AS c
    ON cp.customer_id = c.customer_id

WHERE cp.revenue >= 1000

ORDER BY cp.revenue DESC;
GO


/* ==========================================================
   CHALLENGE 4 - CUSTOMER BEHAVIOR
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id)
            AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN o.order_id
            END
        ) AS cancelled_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cm.total_orders,
    cm.completed_orders,
    cm.cancelled_orders,

    CASE
        WHEN cm.total_orders = 0
            THEN 'No Orders'

        WHEN cm.completed_orders >= 2
            THEN 'Repeat Customer'

        WHEN cm.completed_orders = 1
            THEN 'Customer'

        ELSE 'No Completed Orders'
    END AS customer_type

FROM CustomerMetrics AS cm

INNER JOIN training.customers AS c
    ON cm.customer_id = c.customer_id

ORDER BY
    cm.total_orders DESC,
    c.customer_name;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL SUBQUERY / CTE CHALLENGE
   ========================================================== */

;WITH ProductPerformance AS
(
    SELECT
        oi.product_id,

        COUNT(DISTINCT o.order_id)
            AS completed_order_count,

        COUNT(DISTINCT o.customer_id)
            AS customer_count,

        SUM(oi.quantity)
            AS units_sold,

        SUM(oi.quantity * oi.unit_price)
            AS revenue

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
),
RevenueBenchmark AS
(
    SELECT
        AVG(revenue) AS average_product_revenue
    FROM ProductPerformance
)
SELECT
    p.product_id,
    p.product_name,
    p.category,

    pp.completed_order_count,
    pp.customer_count,
    pp.units_sold,
    pp.revenue,

    rb.average_product_revenue,

    pp.revenue - rb.average_product_revenue
        AS difference_from_average

FROM ProductPerformance AS pp

CROSS JOIN RevenueBenchmark AS rb

INNER JOIN training.products AS p
    ON pp.product_id = p.product_id

WHERE pp.revenue > rb.average_product_revenue

ORDER BY pp.revenue DESC;
GO


/* ==========================================================
   FINAL RECAP

   SCALAR SUBQUERY

       Returns one value.

       Example:

       WHERE price >
       (
           SELECT AVG(price)
           FROM training.products
       )


   IN

       Tests whether a value belongs to
       a result set.


   EXISTS

       Tests whether at least one matching
       row exists.


   NOT EXISTS

       Tests whether no matching row exists.


   CORRELATED SUBQUERY

       References the outer query.

       Example:

       WHERE o.customer_id = c.customer_id


   DERIVED TABLE

       Subquery inside FROM:

       FROM
       (
           SELECT ...
       ) AS x


   CTE

       ;WITH CTEName AS
       (
           SELECT ...
       )
       SELECT ...
       FROM CTEName;


   MULTIPLE CTEs

       ;WITH A AS
       (
           ...
       ),
       B AS
       (
           ...
       )
       SELECT ...;


   PRE-AGGREGATION

       Convert detailed data:

           many order-item rows

       into:

           one row per order

       before later joins and calculations.


   IMPORTANT:

   Use EXISTS when the question is naturally:

       "Does a related row exist?"


   Use NOT EXISTS when the question is naturally:

       "Does no related row exist?"


   Be careful with:

       NOT IN

   when the subquery can contain NULL.


   CTEs primarily help structure complex queries.

   They do not automatically guarantee:

       faster execution
       caching
       materialization


   ANALYTICAL PIPELINE:

       Raw tables
           ->
       Filter
           ->
       Transform
           ->
       Aggregate
           ->
       Pre-aggregate
           ->
       Join
           ->
       Benchmark
           ->
       Final filter
           ->
       Report

============================================================
END OF CHAPTER 06
============================================================
*/