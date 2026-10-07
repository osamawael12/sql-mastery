/*==============================================================================
    SQL Mastery
    Practice Exercises - Intermediate
    File: solutions.sql
    Database: SQLMastery
    Schema: training
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - CUSTOMER ORDER COUNTS
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 2 - CUSTOMER STATUS COUNTS
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status = 'Completed' THEN 1 ELSE 0 END)
        AS completed_orders,
    SUM(CASE WHEN o.order_status = 'Pending' THEN 1 ELSE 0 END)
        AS pending_orders,
    SUM(CASE WHEN o.order_status = 'Cancelled' THEN 1 ELSE 0 END)
        AS cancelled_orders
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 3 - CUSTOMERS WHO NEVER ORDERED
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    c.signup_date
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 4 - CUSTOMERS WITH COMPLETED ORDERS
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
      AND o.order_status = 'Completed'
)
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 5 - ORDERED BUT NEVER COMPLETED
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
)
AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 6 - ALL CUSTOMERS WITH COMPLETED REVENUE
==============================================================================*/

WITH CustomerMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
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
    COALESCE(cm.completed_orders, 0) AS completed_orders,
    COALESCE(cm.completed_revenue, 0) AS completed_revenue
FROM training.customers AS c
LEFT JOIN CustomerMetrics AS cm
    ON cm.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 7 - ALL PRODUCTS WITH SALES
==============================================================================*/

WITH ProductSales AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    COALESCE(ps.units_sold, 0) AS units_sold,
    COALESCE(ps.completed_revenue, 0) AS completed_revenue
FROM training.products AS p
LEFT JOIN ProductSales AS ps
    ON ps.product_id = p.product_id
ORDER BY p.product_id;
GO


/*==============================================================================
    SOLUTION 8 - UNSOLD PRODUCTS
==============================================================================*/

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
)
ORDER BY p.product_id;
GO


/*==============================================================================
    SOLUTION 9 - REPEAT CUSTOMERS
==============================================================================*/

WITH CompletedOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
    HAVING COUNT(*) >= 2
)
SELECT
    co.customer_id,
    c.customer_name,
    co.completed_orders
FROM CompletedOrders AS co
INNER JOIN training.customers AS c
    ON c.customer_id = co.customer_id
ORDER BY
    co.completed_orders DESC,
    co.customer_id;
GO


/*==============================================================================
    SOLUTION 10 - REPEAT CUSTOMER REVENUE
==============================================================================*/

WITH CustomerMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.completed_orders,
    cm.completed_revenue
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
WHERE cm.completed_orders >= 2
ORDER BY
    cm.completed_orders DESC,
    cm.completed_revenue DESC;
GO


/*==============================================================================
    SOLUTION 11 - CUSTOMER AVERAGE ORDER VALUE
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id
),
CustomerMetrics AS
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders,
        SUM(order_value) AS completed_revenue
    FROM OrderValues
    GROUP BY customer_id
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.completed_orders,
    cm.completed_revenue,
    1.0 * cm.completed_revenue
        / NULLIF(cm.completed_orders, 0) AS average_order_value
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY cm.customer_id;
GO


/*==============================================================================
    SOLUTION 12 - ORDER-LEVEL DATASET
==============================================================================*/

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date
ORDER BY o.order_id;
GO


/*==============================================================================
    SOLUTION 13 - ABOVE-AVERAGE ORDERS
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_value
FROM OrderValues
WHERE order_value >
(
    SELECT AVG(1.0 * order_value)
    FROM OrderValues
)
ORDER BY order_value DESC;
GO


/*==============================================================================
    SOLUTION 14 - CUSTOMER'S ABOVE-AVERAGE ORDERS
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),
Compared AS
(
    SELECT
        *,
        AVG(1.0 * order_value) OVER
        (
            PARTITION BY customer_id
        ) AS customer_average_order_value
    FROM OrderValues
)
SELECT
    customer_id,
    order_id,
    order_date,
    order_value,
    customer_average_order_value
FROM Compared
WHERE order_value > customer_average_order_value
ORDER BY
    customer_id,
    order_value DESC;
GO


/*==============================================================================
    SOLUTION 15 - PRODUCTS ABOVE GLOBAL AVERAGE PRICE
==============================================================================*/

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
ORDER BY
    price DESC,
    product_id;
GO


/*==============================================================================
    SOLUTION 16 - PRODUCTS ABOVE CATEGORY AVERAGE PRICE
==============================================================================*/

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


/*==============================================================================
    SOLUTION 17 - CUSTOMER WITH HIGHEST COMPLETED REVENUE
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
    cr.customer_id,
    c.customer_name,
    cr.completed_revenue
FROM CustomerRevenue AS cr
INNER JOIN training.customers AS c
    ON c.customer_id = cr.customer_id
WHERE cr.completed_revenue =
(
    SELECT MAX(completed_revenue)
    FROM CustomerRevenue
);
GO


/*==============================================================================
    SOLUTION 18 - PRODUCT WITH HIGHEST COMPLETED REVENUE
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    pr.product_id,
    p.product_name,
    pr.completed_revenue
FROM ProductRevenue AS pr
INNER JOIN training.products AS p
    ON p.product_id = pr.product_id
WHERE pr.completed_revenue =
(
    SELECT MAX(completed_revenue)
    FROM ProductRevenue
);
GO


/*==============================================================================
    SOLUTION 19 - CATEGORIES ABOVE AVERAGE CATEGORY REVENUE
==============================================================================*/

WITH CategoryRevenue AS
(
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
)
SELECT
    category,
    completed_revenue
FROM CategoryRevenue
WHERE completed_revenue >
(
    SELECT AVG(1.0 * completed_revenue)
    FROM CategoryRevenue
)
ORDER BY completed_revenue DESC;
GO


/*==============================================================================
    SOLUTION 20 - FIRST COMPLETED ORDER DATE
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_completed_order_date
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 21 - LATEST COMPLETED ORDER DATE
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS latest_completed_order_date
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 22 - CUSTOMER LIFETIME SUMMARY
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)
SELECT
    ov.customer_id,
    c.customer_name,
    MIN(ov.order_date) AS first_completed_order_date,
    MAX(ov.order_date) AS latest_completed_order_date,
    COUNT(*) AS completed_orders,
    SUM(ov.order_value) AS completed_revenue
FROM OrderValues AS ov
INNER JOIN training.customers AS c
    ON c.customer_id = ov.customer_id
GROUP BY
    ov.customer_id,
    c.customer_name
ORDER BY ov.customer_id;
GO


/*==============================================================================
    SOLUTION 23 - CUSTOMER SPAN DAYS
==============================================================================*/

WITH CustomerMetrics AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_completed_order_date,
        MAX(order_date) AS latest_completed_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.first_completed_order_date,
    cm.latest_completed_order_date,
    DATEDIFF
    (
        DAY,
        cm.first_completed_order_date,
        cm.latest_completed_order_date
    ) AS customer_span_days
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY cm.customer_id;
GO


/*==============================================================================
    SOLUTION 24 - COMPLETED ORDER SEQUENCE
==============================================================================*/

SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY
            order_date ASC,
            order_id ASC
    ) AS purchase_number
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    purchase_number;
GO


/*==============================================================================
    SOLUTION 25 - LATEST COMPLETED ORDER PER CUSTOMER
==============================================================================*/

WITH RankedOrders AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        order_status,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date DESC,
                order_id DESC
        ) AS rn
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 26 - FIRST COMPLETED ORDER PER CUSTOMER
==============================================================================*/

WITH RankedOrders AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        order_status,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date ASC,
                order_id ASC
        ) AS rn
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 27 - PREVIOUS COMPLETED ORDER
==============================================================================*/

SELECT
    customer_id,
    order_id,
    order_date,
    LAG(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY
            order_date,
            order_id
    ) AS previous_order_date
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 28 - DAYS SINCE PREVIOUS ORDER
==============================================================================*/

WITH OrderHistory AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS previous_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF
    (
        DAY,
        previous_order_date,
        order_date
    ) AS days_since_previous_order
FROM OrderHistory
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 29 - NEXT COMPLETED ORDER
==============================================================================*/

SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY
            order_date,
            order_id
    ) AS next_order_date
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 30 - PRODUCT REVENUE RANKING
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    pr.product_id,
    p.product_name,
    pr.completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY pr.completed_revenue DESC
    ) AS revenue_rank
FROM ProductRevenue AS pr
INNER JOIN training.products AS p
    ON p.product_id = pr.product_id
ORDER BY
    revenue_rank,
    pr.product_id;
GO


/*==============================================================================
    SOLUTION 31 - CATEGORY REVENUE RANKING
==============================================================================*/

WITH CategoryRevenue AS
(
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
)
SELECT
    category,
    completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY completed_revenue DESC
    ) AS revenue_rank
FROM CategoryRevenue
ORDER BY
    revenue_rank,
    category;
GO


/*==============================================================================
    SOLUTION 32 - CUSTOMER REVENUE RANKING
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
    cr.customer_id,
    c.customer_name,
    cr.completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY cr.completed_revenue DESC
    ) AS revenue_rank
FROM CustomerRevenue AS cr
INNER JOIN training.customers AS c
    ON c.customer_id = cr.customer_id
ORDER BY
    revenue_rank,
    cr.customer_id;
GO


/*==============================================================================
    SOLUTION 33 - PRODUCT RANK WITHIN CATEGORY
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
)
SELECT
    category,
    product_id,
    product_name,
    completed_revenue,
    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY completed_revenue DESC
    ) AS category_rank
FROM ProductRevenue
ORDER BY
    category,
    category_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 34 - TOP 2 PRODUCTS PER CATEGORY
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),
Ranked AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY completed_revenue DESC
        ) AS category_rank
    FROM ProductRevenue
)
SELECT
    category,
    product_id,
    product_name,
    completed_revenue,
    category_rank
FROM Ranked
WHERE category_rank <= 2
ORDER BY
    category,
    category_rank,
    product_id;
GO

/*
    DENSE_RANK preserves ties.

    This means more than two products can be returned for a category
    when products tie within the top two revenue ranks.
*/


/*==============================================================================
    SOLUTION 35 - MONTHLY COMPLETED REVENUE
==============================================================================*/

SELECT
    DATEFROMPARTS
    (
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS revenue_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    DATEFROMPARTS
    (
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 36 - MONTHLY RUNNING REVENUE
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER
    (
        ORDER BY revenue_month
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue
FROM MonthlyRevenue
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 37 - MONTH-OVER-MONTH REVENUE
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    revenue_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER
    (
        ORDER BY revenue_month
    ) AS previous_revenue
FROM MonthlyRevenue
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 38 - MONTHLY REVENUE GROWTH
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
GrowthBase AS
(
    SELECT
        revenue_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER
        (
            ORDER BY revenue_month
        ) AS previous_revenue
    FROM MonthlyRevenue
)
SELECT
    revenue_month,
    monthly_revenue,
    previous_revenue,
    monthly_revenue - previous_revenue AS revenue_change,
    100.0 * (monthly_revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) AS growth_pct
FROM GrowthBase
ORDER BY revenue_month;
GO

/*
    LAG compares existing rows.

    Missing calendar months should be generated explicitly if the business
    requires true month-to-month calendar comparison.
*/


/*==============================================================================
    SOLUTION 39 - MONTHLY REVENUE SHARE
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER () AS total_revenue,
    100.0 * monthly_revenue
        / NULLIF(SUM(monthly_revenue) OVER (), 0) AS revenue_share_pct
FROM MonthlyRevenue
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 40 - CUSTOMER REVENUE SHARE
==============================================================================*/

WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS customer_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    cr.customer_id,
    c.customer_name,
    cr.customer_revenue,
    SUM(cr.customer_revenue) OVER () AS total_revenue,
    100.0 * cr.customer_revenue
        / NULLIF(SUM(cr.customer_revenue) OVER (), 0)
        AS revenue_share_pct
FROM CustomerRevenue AS cr
INNER JOIN training.customers AS c
    ON c.customer_id = cr.customer_id
ORDER BY
    cr.customer_revenue DESC,
    cr.customer_id;
GO


/*==============================================================================
    SOLUTION 41 - CUMULATIVE CUSTOMER REVENUE SHARE
==============================================================================*/

WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS customer_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
Metrics AS
(
    SELECT
        customer_id,
        customer_revenue,
        SUM(customer_revenue) OVER () AS total_revenue,
        SUM(customer_revenue) OVER
        (
            ORDER BY
                customer_revenue DESC,
                customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue
    FROM CustomerRevenue
)
SELECT
    m.customer_id,
    c.customer_name,
    m.customer_revenue,
    m.cumulative_revenue,
    100.0 * m.cumulative_revenue
        / NULLIF(m.total_revenue, 0)
        AS cumulative_revenue_pct
FROM Metrics AS m
INNER JOIN training.customers AS c
    ON c.customer_id = m.customer_id
ORDER BY
    m.customer_revenue DESC,
    m.customer_id;
GO


/*==============================================================================
    SOLUTION 42 - CUSTOMER REVENUE QUARTILES
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
),
Quartiles AS
(
    SELECT
        customer_id,
        completed_revenue,
        NTILE(4) OVER
        (
            ORDER BY
                completed_revenue DESC,
                customer_id
        ) AS revenue_quartile
    FROM CustomerRevenue
)
SELECT
    q.customer_id,
    c.customer_name,
    q.completed_revenue,
    q.revenue_quartile
FROM Quartiles AS q
INNER JOIN training.customers AS c
    ON c.customer_id = q.customer_id
ORDER BY
    q.revenue_quartile,
    q.completed_revenue DESC;
GO


/*==============================================================================
    SOLUTION 43 - PRODUCT REVENUE PERCENT OF CATEGORY
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS product_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),
Metrics AS
(
    SELECT
        *,
        SUM(product_revenue) OVER
        (
            PARTITION BY category
        ) AS category_revenue
    FROM ProductRevenue
)
SELECT
    category,
    product_id,
    product_name,
    product_revenue,
    category_revenue,
    100.0 * product_revenue
        / NULLIF(category_revenue, 0)
        AS category_revenue_share_pct
FROM Metrics
ORDER BY
    category,
    product_revenue DESC;
GO


/*==============================================================================
    SOLUTION 44 - ORDER REVENUE PERCENT OF CUSTOMER
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.customer_id,
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        o.order_id
),
Metrics AS
(
    SELECT
        *,
        SUM(order_value) OVER
        (
            PARTITION BY customer_id
        ) AS customer_revenue
    FROM OrderValues
)
SELECT
    customer_id,
    order_id,
    order_value,
    customer_revenue,
    100.0 * order_value
        / NULLIF(customer_revenue, 0)
        AS order_share_of_customer_revenue_pct
FROM Metrics
ORDER BY
    customer_id,
    order_value DESC;
GO


/*==============================================================================
    SOLUTION 45 - CUSTOMER'S LARGEST ORDER
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        o.order_id,
        o.order_date
),
Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_value DESC,
                order_date DESC,
                order_id DESC
        ) AS rn
    FROM OrderValues
)
SELECT
    r.customer_id,
    c.customer_name,
    r.order_id,
    r.order_date,
    r.order_value
FROM Ranked AS r
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY r.customer_id;
GO


/*==============================================================================
    SOLUTION 46 - GLOBAL TOP 3 ORDERS
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)
SELECT TOP (3)
    order_id,
    customer_id,
    order_date,
    order_value
FROM OrderValues
ORDER BY
    order_value DESC,
    order_id;
GO


/*==============================================================================
    SOLUTION 47 - ORDERS ABOVE GLOBAL AVERAGE
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),
Metrics AS
(
    SELECT
        *,
        AVG(1.0 * order_value) OVER () AS average_order_value
    FROM OrderValues
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_value,
    average_order_value
FROM Metrics
WHERE order_value > average_order_value
ORDER BY order_value DESC;
GO


/*==============================================================================
    SOLUTION 48 - CUSTOMER CATEGORY REVENUE
==============================================================================*/

SELECT
    o.customer_id,
    c.customer_name,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.customer_id,
    c.customer_name,
    p.category
ORDER BY
    o.customer_id,
    category_revenue DESC;
GO


/*==============================================================================
    SOLUTION 49 - CUSTOMER FAVORITE CATEGORY
==============================================================================*/

WITH CustomerCategory AS
(
    SELECT
        o.customer_id,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS category_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        p.category
),
Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                category_revenue DESC,
                category ASC
        ) AS rn
    FROM CustomerCategory
)
SELECT
    r.customer_id,
    c.customer_name,
    r.category AS favorite_category,
    r.category_revenue
FROM Ranked AS r
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
WHERE r.rn = 1
ORDER BY r.customer_id;
GO


/*==============================================================================
    SOLUTION 50 - PRODUCT DISTINCT BUYERS
==============================================================================*/

SELECT
    p.product_id,
    p.product_name,
    COUNT(DISTINCT o.customer_id) AS distinct_buyers
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON oi.product_id = p.product_id
INNER JOIN training.orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    distinct_buyers DESC,
    p.product_id;
GO


/*==============================================================================
    SOLUTION 51 - CUSTOMER PRODUCT DIVERSITY
==============================================================================*/

SELECT
    o.customer_id,
    c.customer_name,
    COUNT(DISTINCT oi.product_id) AS distinct_products,
    COUNT(DISTINCT p.category) AS distinct_categories
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.customer_id,
    c.customer_name
ORDER BY o.customer_id;
GO


/*==============================================================================
    SOLUTION 52 - PRODUCT PAIRS
==============================================================================*/

WITH CompletedOrderProducts AS
(
    SELECT DISTINCT
        oi.order_id,
        oi.product_id
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
)
SELECT
    a.product_id AS product_id_1,
    b.product_id AS product_id_2,
    COUNT(*) AS orders_together
FROM CompletedOrderProducts AS a
INNER JOIN CompletedOrderProducts AS b
    ON b.order_id = a.order_id
   AND b.product_id > a.product_id
GROUP BY
    a.product_id,
    b.product_id
ORDER BY
    orders_together DESC,
    product_id_1,
    product_id_2;
GO


/*==============================================================================
    SOLUTION 53 - SET OPERATION: CUSTOMERS WITH ANY ORDER
==============================================================================*/

SELECT customer_id
FROM training.orders
GROUP BY customer_id
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 54 - COMPLETED OR PENDING CUSTOMERS
==============================================================================*/

SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


/*==============================================================================
    SOLUTION 55 - COMPLETED AND PENDING CUSTOMERS
==============================================================================*/

SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


/*==============================================================================
    SOLUTION 56 - COMPLETED BUT NEVER CANCELLED
==============================================================================*/

SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

EXCEPT

SELECT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/*==============================================================================
    SOLUTION 57 - UNION VS UNION ALL
==============================================================================*/

SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO


SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT customer_id
FROM training.orders
WHERE order_status = 'Pending';
GO

/*
    UNION removes duplicate result rows.

    UNION ALL preserves every source row.

    Therefore repeated customers, whether repeated inside a branch or
    across branches, can produce a larger UNION ALL result.
*/


/*==============================================================================
    SOLUTION 58 - COMPLETED ORDER VALUE BY MONTH
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.order_id,
        o.order_date
)
SELECT
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS revenue_month,
    COUNT(*) AS completed_orders,
    SUM(order_value) AS monthly_revenue,
    AVG(1.0 * order_value) AS average_order_value
FROM OrderValues
GROUP BY
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 59 - MONTHLY UNIQUE CUSTOMERS
==============================================================================*/

SELECT
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY activity_month;
GO


/*==============================================================================
    SOLUTION 60 - NEW CUSTOMER MONTH
==============================================================================*/

SELECT
    customer_id,
    DATEFROMPARTS
    (
        YEAR(MIN(order_date)),
        MONTH(MIN(order_date)),
        1
    ) AS first_completed_month
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 61 - CUSTOMER-MONTH ACTIVITY
==============================================================================*/

SELECT DISTINCT
    customer_id,
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS activity_month
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    activity_month;
GO


/*==============================================================================
    SOLUTION 62 - NEW VS RETURNING ACTIVITY
==============================================================================*/

WITH Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
FirstMonth AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS first_completed_month
    FROM Activity
    GROUP BY customer_id
)
SELECT
    a.customer_id,
    a.activity_month,
    CASE
        WHEN a.activity_month = f.first_completed_month
            THEN 'New'
        ELSE 'Returning'
    END AS customer_type
FROM Activity AS a
INNER JOIN FirstMonth AS f
    ON f.customer_id = a.customer_id
ORDER BY
    a.activity_month,
    a.customer_id;
GO


/*==============================================================================
    SOLUTION 63 - MONTHLY NEW VS RETURNING COUNTS
==============================================================================*/

WITH Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
FirstMonth AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS first_completed_month
    FROM Activity
    GROUP BY customer_id
)
SELECT
    a.activity_month,
    SUM
    (
        CASE
            WHEN a.activity_month = f.first_completed_month THEN 1
            ELSE 0
        END
    ) AS new_customers,
    SUM
    (
        CASE
            WHEN a.activity_month > f.first_completed_month THEN 1
            ELSE 0
        END
    ) AS returning_customers,
    COUNT(*) AS active_customers
FROM Activity AS a
INNER JOIN FirstMonth AS f
    ON f.customer_id = a.customer_id
GROUP BY a.activity_month
ORDER BY a.activity_month;
GO


/*==============================================================================
    SOLUTION 64 - CUSTOMER ORDER GAP SUMMARY
==============================================================================*/

WITH History AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS previous_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
Gaps AS
(
    SELECT
        customer_id,
        DATEDIFF
        (
            DAY,
            previous_order_date,
            order_date
        ) AS gap_days
    FROM History
    WHERE previous_order_date IS NOT NULL
)
SELECT
    customer_id,
    AVG(1.0 * gap_days) AS average_days_between_orders,
    MIN(gap_days) AS minimum_days_between_orders,
    MAX(gap_days) AS maximum_days_between_orders
FROM Gaps
GROUP BY customer_id
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 65 - CATEGORY PRODUCT COUNT + SALES
==============================================================================*/

WITH CategoryProducts AS
(
    SELECT
        category,
        COUNT(*) AS total_products
    FROM training.products
    GROUP BY category
),
CategorySales AS
(
    SELECT
        p.category,
        COUNT(DISTINCT p.product_id) AS products_with_completed_sales,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.products AS p
    INNER JOIN training.order_items AS oi
        ON oi.product_id = p.product_id
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
)
SELECT
    cp.category,
    cp.total_products,
    COALESCE(cs.products_with_completed_sales, 0)
        AS products_with_completed_sales,
    COALESCE(cs.completed_revenue, 0) AS completed_revenue
FROM CategoryProducts AS cp
LEFT JOIN CategorySales AS cs
    ON (cs.category = cp.category)
    OR (cs.category IS NULL AND cp.category IS NULL)
ORDER BY cp.category;
GO


/*==============================================================================
    SOLUTION 66 - ACTIVE PRODUCTS WITH NO COMPLETED SALES
==============================================================================*/

SELECT
    p.product_id,
    p.product_name,
    p.category
FROM training.products AS p
WHERE p.is_active = 1
AND NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
)
ORDER BY p.product_id;
GO


/*==============================================================================
    SOLUTION 67 - ACTIVE CUSTOMERS WITH NO COMPLETED ORDER
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE c.is_active = 1
AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 68 - CUSTOMER SEGMENT
==============================================================================*/

WITH OrderMetrics AS
(
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
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    CASE
        WHEN COALESCE(om.total_orders, 0) = 0
            THEN 'Never Ordered'

        WHEN COALESCE(om.completed_orders, 0) = 0
            THEN 'Ordered But Never Completed'

        WHEN om.completed_orders = 1
            THEN 'One-Time Completed Customer'

        ELSE 'Repeat Customer'
    END AS customer_segment
FROM training.customers AS c
LEFT JOIN OrderMetrics AS om
    ON om.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 69 - SEGMENT SUMMARY
==============================================================================*/

WITH OrderMetrics AS
(
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
    GROUP BY customer_id
),
Segments AS
(
    SELECT
        c.customer_id,
        CASE
            WHEN COALESCE(om.total_orders, 0) = 0
                THEN 'Never Ordered'
            WHEN COALESCE(om.completed_orders, 0) = 0
                THEN 'Ordered But Never Completed'
            WHEN om.completed_orders = 1
                THEN 'One-Time Completed Customer'
            ELSE 'Repeat Customer'
        END AS customer_segment
    FROM training.customers AS c
    LEFT JOIN OrderMetrics AS om
        ON om.customer_id = c.customer_id
),
Summary AS
(
    SELECT
        customer_segment,
        COUNT(*) AS customer_count
    FROM Segments
    GROUP BY customer_segment
)
SELECT
    customer_segment,
    customer_count,
    100.0 * customer_count
        / NULLIF(SUM(customer_count) OVER (), 0) AS customer_pct
FROM Summary
ORDER BY
    customer_count DESC,
    customer_segment;
GO


/*==============================================================================
    SOLUTION 70 - CITY CUSTOMER METRICS
==============================================================================*/

WITH CustomerFlags AS
(
    SELECT
        c.customer_id,
        c.city,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
            )
            THEN 1
            ELSE 0
        END AS has_order,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
                  AND o.order_status = 'Completed'
            )
            THEN 1
            ELSE 0
        END AS has_completed_order
    FROM training.customers AS c
)
SELECT
    city,
    COUNT(*) AS registered_customers,
    SUM(has_order) AS customers_with_any_order,
    SUM(has_completed_order) AS completed_customers
FROM CustomerFlags
GROUP BY city
ORDER BY city;
GO


/*==============================================================================
    SOLUTION 71 - CITY COMPLETED REVENUE
==============================================================================*/

WITH CityCustomers AS
(
    SELECT
        city,
        COUNT(*) AS registered_customers
    FROM training.customers
    GROUP BY city
),
CityRevenue AS
(
    SELECT
        c.city,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.customers AS c
    INNER JOIN training.orders AS o
        ON o.customer_id = c.customer_id
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.city
)
SELECT
    cc.city,
    cc.registered_customers,
    COALESCE(cr.completed_revenue, 0) AS completed_revenue
FROM CityCustomers AS cc
LEFT JOIN CityRevenue AS cr
    ON (cr.city = cc.city)
    OR (cr.city IS NULL AND cc.city IS NULL)
ORDER BY cc.city;
GO


/*==============================================================================
    SOLUTION 72 - ESTIMATED PRODUCT PROFIT
==============================================================================*/

WITH ProductMetrics AS
(
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * p.cost) AS estimated_cost
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS estimated_gross_profit,
    100.0 * (revenue - estimated_cost)
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct
FROM ProductMetrics
ORDER BY product_id;
GO

/*
    products.cost is current cost rather than transaction-time historical cost.
*/


/*==============================================================================
    SOLUTION 73 - CATEGORY PROFIT
==============================================================================*/

WITH CategoryMetrics AS
(
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * p.cost) AS estimated_cost
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category
)
SELECT
    category,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS estimated_gross_profit,
    100.0 * (revenue - estimated_cost)
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct
FROM CategoryMetrics
ORDER BY
    estimated_gross_profit DESC,
    category;
GO


/*==============================================================================
    SOLUTION 74 - PRODUCT REVENUE VS PROFIT RANK
==============================================================================*/

WITH ProductMetrics AS
(
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM
        (
            oi.quantity * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_gross_profit,
    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank,
    DENSE_RANK() OVER
    (
        ORDER BY estimated_gross_profit DESC
    ) AS gross_profit_rank
FROM ProductMetrics
ORDER BY
    revenue_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 75 - MONTHLY ESTIMATED PROFIT
==============================================================================*/

WITH MonthlyMetrics AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * p.cost) AS estimated_cost
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    revenue_month,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS estimated_gross_profit,
    100.0 * (revenue - estimated_cost)
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct
FROM MonthlyMetrics
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 76 - CUSTOMER KPI REPORT
==============================================================================*/

WITH OrderMetrics AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM
        (
            CASE
                WHEN order_status = 'Completed' THEN 1
                ELSE 0
            END
        ) AS completed_orders,
        MIN
        (
            CASE
                WHEN order_status = 'Completed' THEN order_date
            END
        ) AS first_completed_order_date,
        MAX
        (
            CASE
                WHEN order_status = 'Completed' THEN order_date
            END
        ) AS latest_completed_order_date
    FROM training.orders
    GROUP BY customer_id
),
Revenue AS
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
    COALESCE(om.total_orders, 0) AS total_orders,
    COALESCE(om.completed_orders, 0) AS completed_orders,
    COALESCE(r.completed_revenue, 0) AS completed_revenue,
    om.first_completed_order_date,
    om.latest_completed_order_date
FROM training.customers AS c
LEFT JOIN OrderMetrics AS om
    ON om.customer_id = c.customer_id
LEFT JOIN Revenue AS r
    ON r.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 77 - CUSTOMER REVENUE RECONCILIATION
==============================================================================*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0)
            AS direct_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS customer_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
CustomerTotal AS
(
    SELECT
        COALESCE(SUM(customer_revenue), 0) AS customer_level_revenue
    FROM CustomerRevenue
)
SELECT
    d.direct_revenue,
    c.customer_level_revenue,
    d.direct_revenue - c.customer_level_revenue AS difference
FROM Direct AS d
CROSS JOIN CustomerTotal AS c;
GO


/*==============================================================================
    SOLUTION 78 - ORDER REVENUE RECONCILIATION
==============================================================================*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0)
            AS direct_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
OrderRevenue AS
(
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
),
OrderTotal AS
(
    SELECT
        COALESCE(SUM(order_revenue), 0) AS order_level_revenue
    FROM OrderRevenue
)
SELECT
    d.direct_revenue,
    ot.order_level_revenue,
    d.direct_revenue - ot.order_level_revenue AS difference,
    CASE
        WHEN d.direct_revenue = ot.order_level_revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM Direct AS d
CROSS JOIN OrderTotal AS ot;
GO


/*==============================================================================
    SOLUTION 79 - FIX THE BROKEN QUERY
==============================================================================*/

/*
    Problems:

    1. WHERE o.order_status = 'Completed' removes customers without matching
       Completed orders after the LEFT JOIN.

    2. COUNT(o.order_id) counts joined order-item rows, not necessarily orders.

    3. products.price is the current catalog price, not transaction price.

       Revenue should use:
           order_items.unit_price

    4. products does not need to be joined for transaction revenue.

    A clean solution is to aggregate Completed metrics first.
*/

WITH CompletedMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
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
    COALESCE(cm.completed_orders, 0) AS completed_orders,
    COALESCE(cm.completed_revenue, 0) AS completed_revenue
FROM training.customers AS c
LEFT JOIN CompletedMetrics AS cm
    ON cm.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 80 - INTERMEDIATE FINAL CHALLENGE
==============================================================================*/

WITH OrderMetrics AS
(
    /*
        Grain:
            one row per customer with at least one order.

        No order_items join here, so order counts cannot be multiplied
        by item lines.
    */
    SELECT
        customer_id,
        COUNT(*) AS total_orders,

        SUM
        (
            CASE
                WHEN order_status = 'Completed' THEN 1
                ELSE 0
            END
        ) AS completed_orders,

        SUM
        (
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS cancelled_orders,

        MIN
        (
            CASE
                WHEN order_status = 'Completed' THEN order_date
            END
        ) AS first_completed_order_date,

        MAX
        (
            CASE
                WHEN order_status = 'Completed' THEN order_date
            END
        ) AS latest_completed_order_date

    FROM training.orders
    GROUP BY customer_id
),
CompletedMetrics AS
(
    /*
        Grain:
            one row per customer with Completed transaction activity.
    */
    SELECT
        o.customer_id,
        SUM(oi.quantity) AS completed_units,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
        COUNT(DISTINCT oi.product_id) AS distinct_products_purchased,
        COUNT(DISTINCT p.category) AS distinct_categories_purchased
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
CustomerBase AS
(
    /*
        Driving table is customers, preserving every registered customer.

        Final grain is already one row per customer here.
    */
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        c.is_active,

        COALESCE(om.total_orders, 0) AS total_orders,
        COALESCE(om.completed_orders, 0) AS completed_orders,
        COALESCE(om.cancelled_orders, 0) AS cancelled_orders,

        COALESCE(cm.completed_units, 0) AS completed_units,
        COALESCE(cm.completed_revenue, 0) AS completed_revenue,

        om.first_completed_order_date,
        om.latest_completed_order_date,

        COALESCE(cm.distinct_products_purchased, 0)
            AS distinct_products_purchased,

        COALESCE(cm.distinct_categories_purchased, 0)
            AS distinct_categories_purchased

    FROM training.customers AS c
    LEFT JOIN OrderMetrics AS om
        ON om.customer_id = c.customer_id
    LEFT JOIN CompletedMetrics AS cm
        ON cm.customer_id = c.customer_id
),
Segmented AS
(
    SELECT
        *,
        CASE
            WHEN total_orders = 0
                THEN 'Never Ordered'

            WHEN completed_orders = 0
                THEN 'Ordered But Never Completed'

            WHEN completed_orders = 1
                THEN 'One-Time Completed Customer'

            ELSE 'Repeat Customer'
        END AS customer_segment
    FROM CustomerBase
),
PositiveRevenueRanking AS
(
    /*
        Rank only customers with positive revenue.

        This avoids allowing zero-revenue customers to participate in
        the ranking population.
    */
    SELECT
        customer_id,
        DENSE_RANK() OVER
        (
            ORDER BY completed_revenue DESC
        ) AS revenue_rank
    FROM Segmented
    WHERE completed_revenue > 0
)
SELECT
    s.customer_id,
    s.customer_name,
    s.city,
    s.is_active,

    s.total_orders,
    s.completed_orders,
    s.cancelled_orders,

    s.completed_units,
    s.completed_revenue,

    1.0 * s.completed_revenue
        / NULLIF(s.completed_orders, 0) AS average_order_value,

    s.first_completed_order_date,
    s.latest_completed_order_date,

    s.distinct_products_purchased,
    s.distinct_categories_purchased,

    s.customer_segment,
    pr.revenue_rank

FROM Segmented AS s
LEFT JOIN PositiveRevenueRanking AS pr
    ON pr.customer_id = s.customer_id
ORDER BY
    CASE
        WHEN pr.revenue_rank IS NULL THEN 1
        ELSE 0
    END,
    pr.revenue_rank,
    s.customer_id;
GO


/*------------------------------------------------------------------------------
    FINAL CHALLENGE VALIDATION
------------------------------------------------------------------------------*/

SELECT
    COUNT(*) AS expected_customer_rows
FROM training.customers;
GO

/*
    The final report should return exactly expected_customer_rows rows.

    Additional checks:

    - one row per customer
    - revenue uses order_items.unit_price
    - order counts come from order grain
    - customers without activity remain
    - no Completed orders => NULL first/latest Completed date
    - no Completed revenue => NULL revenue rank
*/


/*==============================================================================
    INTERMEDIATE REVIEW
==============================================================================*/

/*
    1. Result grain

       Define what one output row represents before aggregation.


    2. Row multiplication

       One-to-many joins can duplicate the parent entity.


    3. COUNT(DISTINCT)

       Useful when a joined result repeats an entity but the metric requires
       distinct business entities.


    4. Pre-aggregation

       Establishing the required grain before later joins can make both logic
       and validation much clearer.


    5. EXISTS / NOT EXISTS

       EXISTS:
           at least one qualifying row exists.

       NOT EXISTS:
           no qualifying row exists.


    6. NOT IN + NULL

       NULL in the comparison set can interact with three-valued logic and
       produce surprising anti-join results.


    7. CTE scope

       A CTE exists for the statement immediately following it.


    8. CTE materialization

       A CTE is not automatically a stored temporary result.


    9. UNION vs UNION ALL

       UNION removes duplicates.
       UNION ALL preserves them.


    10. INTERSECT vs EXCEPT

        INTERSECT:
            values in both sets.

        EXCEPT:
            values in first set but not second.


    11. Ranking functions

        ROW_NUMBER:
            unique sequence.

        RANK:
            ties with gaps.

        DENSE_RANK:
            ties without gaps.


    12. Tie breakers

        Required when exactly one deterministic row must be selected.


    13. LAG vs LEAD

        LAG:
            previous row.

        LEAD:
            next row.


    14. Running totals

        Use ordered window SUM with an explicit frame when appropriate.


    15. Percent of total

        Window aggregates often avoid a separate join to a total query.


    16. Top N per group

        Aggregate first, rank inside each group, then filter the ranking.


    17. Customer-month activity

        Multiple orders in one month still represent one active customer-month
        in many retention-style analyses.


    18. unit_price

        Historical transaction revenue comes from order_items.unit_price,
        not current products.price.


    19. Profit

        Current products.cost means historical profit calculations are estimates.


    20. Reconciliation

        Calculating the same metric through multiple grains can expose join,
        filtering, and aggregation errors.
*/


/*==============================================================================
    INTERMEDIATE LEVEL COMPLETE

    Next:
        exercises/advanced/exercises.sql
==============================================================================*/