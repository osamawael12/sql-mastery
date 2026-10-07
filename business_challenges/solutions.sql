/*==============================================================================
    SQL Mastery
    Business Challenges
    File: solutions.sql
    Database: SQLMastery
    Schema: training

    Core Definitions:
    - Revenue = Completed order-item value
    - Revenue uses order_items.unit_price
    - Repeat Customer = >= 2 distinct Completed orders
    - Profit uses current products.cost and is therefore estimated historically
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - EXECUTIVE REVENUE KPIs
==============================================================================*/

SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_completed_orders,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue,
    1.0 * SUM(oi.quantity * oi.unit_price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0) AS average_order_value
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO

/*
    Grain: one KPI row.

    COUNT(*) would count order-item rows after the join rather than distinct
    orders.
*/


/*==============================================================================
    SOLUTION 2 - MONTHLY REVENUE
==============================================================================*/

SELECT
    DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1) AS revenue_month,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COUNT(DISTINCT o.customer_id) AS purchasing_customers,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 3 - MONTHLY REVENUE SHARE
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
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
    SOLUTION 4 - MONTH-OVER-MONTH GROWTH
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
GrowthBase AS
(
    SELECT
        revenue_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER
        (
            ORDER BY revenue_month
        ) AS previous_month_revenue
    FROM MonthlyRevenue
)
SELECT
    revenue_month,
    monthly_revenue,
    previous_month_revenue,
    monthly_revenue - previous_month_revenue AS revenue_change,
    100.0 * (monthly_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) AS growth_pct
FROM GrowthBase
ORDER BY revenue_month;
GO

/*
    LAG() compares existing rows.

    If February is missing, a March row can compare with January.
    Production calendar reporting should normally create missing periods using
    a calendar/date dimension or equivalent month series.
*/


/*==============================================================================
    SOLUTION 5 - RUNNING REVENUE
==============================================================================*/

WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
)
SELECT
    revenue_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER
    (
        ORDER BY revenue_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM MonthlyRevenue
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 6 - CUSTOMER REVENUE LEADERBOARD
==============================================================================*/

WITH CustomerMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity) AS units_purchased,
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
    cm.completed_orders,
    cm.units_purchased,
    cm.completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY cm.completed_revenue DESC
    ) AS revenue_rank
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY
    revenue_rank,
    c.customer_id;
GO


/*==============================================================================
    SOLUTION 7 - ALL CUSTOMERS WITH REVENUE
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
    c.is_active,
    COALESCE(cm.completed_orders, 0) AS completed_orders,
    COALESCE(cm.completed_revenue, 0) AS completed_revenue
FROM training.customers AS c
LEFT JOIN CustomerMetrics AS cm
    ON cm.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 8 - CUSTOMERS WHO NEVER ORDERED
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
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
    SOLUTION 9 - ORDERS BUT NO COMPLETED ORDERS
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
    SOLUTION 10 - REPEAT CUSTOMERS
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
    cm.completed_orders,
    cm.completed_revenue
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
WHERE cm.completed_orders >= 2
ORDER BY
    cm.completed_orders DESC,
    cm.completed_revenue DESC,
    c.customer_id;
GO


/*==============================================================================
    SOLUTION 11 - REPEAT CUSTOMER RATE
==============================================================================*/

WITH CompletedOrderCounts AS
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS completed_customers,
    SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END)
        AS repeat_customers,
    100.0 * SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS repeat_customer_rate_pct
FROM CompletedOrderCounts;
GO


/*==============================================================================
    SOLUTION 12 - CUSTOMER LIFETIME METRICS
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
CustomerMetrics AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_completed_order_date,
        MAX(order_date) AS latest_completed_order_date,
        COUNT(*) AS completed_orders,
        SUM(order_value) AS completed_revenue
    FROM OrderValues
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cm.first_completed_order_date,
    cm.latest_completed_order_date,
    cm.completed_orders,
    cm.completed_revenue,
    1.0 * cm.completed_revenue
        / NULLIF(cm.completed_orders, 0) AS average_order_value
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 13 - ORDER VALUE
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
    SOLUTION 14 - LARGEST COMPLETED ORDERS
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
    ov.order_id,
    ov.customer_id,
    c.customer_name,
    ov.order_date,
    ov.order_value,
    DENSE_RANK() OVER
    (
        ORDER BY ov.order_value DESC
    ) AS order_value_rank
FROM OrderValues AS ov
INNER JOIN training.customers AS c
    ON c.customer_id = ov.customer_id
ORDER BY
    order_value_rank,
    ov.order_id;
GO


/*==============================================================================
    SOLUTION 15 - CUSTOMER AVERAGE ORDER VALUE
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
    c.customer_id,
    c.customer_name,
    cm.completed_orders,
    cm.completed_revenue,
    1.0 * cm.completed_revenue
        / NULLIF(cm.completed_orders, 0) AS average_order_value
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 16 - PRODUCT PERFORMANCE
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
    p.category,
    COALESCE(ps.units_sold, 0) AS units_sold,
    COALESCE(ps.completed_revenue, 0) AS completed_revenue
FROM training.products AS p
LEFT JOIN ProductSales AS ps
    ON ps.product_id = p.product_id
ORDER BY p.product_id;
GO


/*==============================================================================
    SOLUTION 17 - TOP PRODUCTS BY REVENUE
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
    p.category,
    ps.units_sold,
    ps.completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY ps.completed_revenue DESC
    ) AS revenue_rank
FROM ProductSales AS ps
INNER JOIN training.products AS p
    ON p.product_id = ps.product_id
ORDER BY
    revenue_rank,
    p.product_id;
GO


/*==============================================================================
    SOLUTION 18 - TOP 3 PRODUCTS PER CATEGORY
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.products AS p
    INNER JOIN training.order_items AS oi
        ON oi.product_id = p.product_id
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),
RankedProducts AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY completed_revenue DESC
        ) AS category_revenue_rank
    FROM ProductRevenue
)
SELECT
    category,
    product_id,
    product_name,
    completed_revenue,
    category_revenue_rank
FROM RankedProducts
WHERE category_revenue_rank <= 3
ORDER BY
    category,
    category_revenue_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 19 - UNSOLD PRODUCTS
==============================================================================*/

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity
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
    SOLUTION 20 - CATEGORY PERFORMANCE
==============================================================================*/

WITH CategoryMetrics AS
(
    SELECT
        p.category,
        COUNT(DISTINCT p.product_id) AS products_with_completed_sales,
        SUM(oi.quantity) AS units_sold,
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
    category,
    products_with_completed_sales,
    units_sold,
    completed_revenue,
    DENSE_RANK() OVER
    (
        ORDER BY completed_revenue DESC
    ) AS revenue_rank
FROM CategoryMetrics
ORDER BY
    revenue_rank,
    category;
GO


/*==============================================================================
    SOLUTION 21 - PRODUCT PROFITABILITY
==============================================================================*/

WITH ProductProfit AS
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
FROM ProductProfit
ORDER BY product_id;
GO

/*
    products.cost is the current product cost, not a historical cost recorded
    with each transaction. Historical profit is therefore estimated.
*/


/*==============================================================================
    SOLUTION 22 - CATEGORY PROFITABILITY
==============================================================================*/

WITH CategoryProfit AS
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
FROM CategoryProfit
ORDER BY
    estimated_gross_profit DESC,
    category;
GO


/*==============================================================================
    SOLUTION 23 - MOST PROFITABLE PRODUCTS
==============================================================================*/

WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * (oi.unit_price - p.cost))
            AS estimated_gross_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    revenue,
    estimated_gross_profit,
    DENSE_RANK() OVER
    (
        ORDER BY estimated_gross_profit DESC
    ) AS gross_profit_rank
FROM ProductProfit
ORDER BY
    gross_profit_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 24 - HIGH REVENUE, LOW MARGIN
==============================================================================*/

WITH ProductMetrics AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * (oi.unit_price - p.cost))
            AS estimated_gross_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
Margins AS
(
    SELECT
        *,
        100.0 * estimated_gross_profit
            / NULLIF(revenue, 0) AS estimated_gross_margin_pct
    FROM ProductMetrics
)
SELECT
    product_id,
    product_name,
    category,
    revenue,
    estimated_gross_profit,
    estimated_gross_margin_pct,
    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank,
    DENSE_RANK() OVER
    (
        ORDER BY estimated_gross_margin_pct DESC
    ) AS margin_rank
FROM Margins
ORDER BY
    revenue_rank,
    product_id;
GO

/*
    Revenue measures sales value, while margin measures profit relative to
    sales value. A high-revenue product can have a relatively thin margin.
*/


/*==============================================================================
    SOLUTION 25 - CUSTOMER REVENUE CONCENTRATION
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
            ORDER BY customer_revenue DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM CustomerRevenue
)
SELECT
    m.customer_id,
    c.customer_name,
    m.customer_revenue,
    m.total_revenue,
    100.0 * m.customer_revenue
        / NULLIF(m.total_revenue, 0) AS revenue_share_pct,
    m.cumulative_revenue,
    100.0 * m.cumulative_revenue
        / NULLIF(m.total_revenue, 0) AS cumulative_revenue_pct
FROM Metrics AS m
INNER JOIN training.customers AS c
    ON c.customer_id = m.customer_id
ORDER BY
    m.customer_revenue DESC,
    m.customer_id;
GO


/*==============================================================================
    SOLUTION 26 - CUSTOMER REVENUE QUARTILES
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
            ORDER BY completed_revenue DESC, customer_id
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
            ORDER BY completed_revenue DESC, customer_id
        ) AS revenue_quartile
    FROM CustomerRevenue
)
SELECT
    revenue_quartile,
    COUNT(*) AS customer_count,
    SUM(completed_revenue) AS quartile_revenue
FROM Quartiles
GROUP BY revenue_quartile
ORDER BY revenue_quartile;
GO


/*==============================================================================
    SOLUTION 27 - FIRST AND LATEST COMPLETED ORDER
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_completed_order_date,
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
    SOLUTION 28 - DAYS BETWEEN FIRST AND LATEST PURCHASE
==============================================================================*/

WITH CustomerDates AS
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
    cd.customer_id,
    c.customer_name,
    cd.first_completed_order_date,
    cd.latest_completed_order_date,
    DATEDIFF
    (
        DAY,
        cd.first_completed_order_date,
        cd.latest_completed_order_date
    ) AS customer_span_days
FROM CustomerDates AS cd
INNER JOIN training.customers AS c
    ON c.customer_id = cd.customer_id
ORDER BY cd.customer_id;
GO


/*==============================================================================
    SOLUTION 29 - DAYS BETWEEN CUSTOMER ORDERS
==============================================================================*/

WITH CompletedOrders AS
(
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_completed_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_completed_order_date,
    DATEDIFF
    (
        DAY,
        previous_completed_order_date,
        order_date
    ) AS days_since_previous_order
FROM CompletedOrders
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 30 - CUSTOMER PURCHASE SEQUENCE
==============================================================================*/

SELECT
    customer_id,
    order_id,
    order_date,
    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS purchase_number
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    purchase_number;
GO


/*==============================================================================
    SOLUTION 31 - NEW VS RETURNING MONTHLY CUSTOMERS
==============================================================================*/

WITH CustomerActivity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
FirstMonth AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS first_month
    FROM CustomerActivity
    GROUP BY customer_id
)
SELECT
    ca.activity_month,
    SUM(CASE WHEN ca.activity_month = fm.first_month THEN 1 ELSE 0 END)
        AS new_customers,
    SUM(CASE WHEN ca.activity_month > fm.first_month THEN 1 ELSE 0 END)
        AS returning_customers,
    COUNT(*) AS active_customers
FROM CustomerActivity AS ca
INNER JOIN FirstMonth AS fm
    ON fm.customer_id = ca.customer_id
GROUP BY ca.activity_month
ORDER BY ca.activity_month;
GO


/*==============================================================================
    SOLUTION 32 - MONTHLY CUSTOMER MIX
==============================================================================*/

WITH CustomerActivity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
FirstMonth AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS first_month
    FROM CustomerActivity
    GROUP BY customer_id
),
MonthlyMix AS
(
    SELECT
        ca.activity_month,
        SUM(CASE WHEN ca.activity_month = fm.first_month THEN 1 ELSE 0 END)
            AS new_customers,
        SUM(CASE WHEN ca.activity_month > fm.first_month THEN 1 ELSE 0 END)
            AS returning_customers,
        COUNT(*) AS active_customers
    FROM CustomerActivity AS ca
    INNER JOIN FirstMonth AS fm
        ON fm.customer_id = ca.customer_id
    GROUP BY ca.activity_month
)
SELECT
    activity_month,
    new_customers,
    returning_customers,
    active_customers,
    100.0 * new_customers
        / NULLIF(active_customers, 0) AS new_customer_pct,
    100.0 * returning_customers
        / NULLIF(active_customers, 0) AS returning_customer_pct
FROM MonthlyMix
ORDER BY activity_month;
GO


/*==============================================================================
    SOLUTION 33 - RFM BASE METRICS
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT
        DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
RFM AS
(
    SELECT
        o.customer_id,
        MAX(o.order_date) AS last_completed_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.quantity * oi.unit_price) AS monetary
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    r.customer_id,
    c.customer_name,
    r.last_completed_order_date,
    DATEDIFF(DAY, r.last_completed_order_date, rd.reference_date)
        AS recency_days,
    r.frequency,
    r.monetary
FROM RFM AS r
CROSS JOIN ReferenceDate AS rd
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
ORDER BY r.customer_id;
GO


/*==============================================================================
    SOLUTION 34 - RFM SCORES
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
Base AS
(
    SELECT
        o.customer_id,
        DATEDIFF
        (
            DAY,
            MAX(o.order_date),
            rd.reference_date
        ) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.quantity * oi.unit_price) AS monetary
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    CROSS JOIN ReferenceDate AS rd
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        rd.reference_date
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER
    (
        ORDER BY recency_days DESC, customer_id
    ) AS recency_score,
    NTILE(5) OVER
    (
        ORDER BY frequency ASC, customer_id
    ) AS frequency_score,
    NTILE(5) OVER
    (
        ORDER BY monetary ASC, customer_id
    ) AS monetary_score
FROM Base
ORDER BY customer_id;
GO

/*
    NTILE assigns increasing tile numbers according to the specified ordering.

    Recency is ordered DESC because high recency_days is worse, placing more
    recent customers toward the higher score tiles.

    Frequency and Monetary are ordered ASC so larger values receive higher
    tile numbers.

    On the tiny dataset, NTILE(5) may have very small/empty conceptual groups.
*/


/*==============================================================================
    SOLUTION 35 - RFM SEGMENTS
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
Base AS
(
    SELECT
        o.customer_id,
        DATEDIFF(DAY, MAX(o.order_date), rd.reference_date) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.quantity * oi.unit_price) AS monetary
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    CROSS JOIN ReferenceDate AS rd
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        rd.reference_date
),
Scores AS
(
    SELECT
        *,
        NTILE(5) OVER
        (
            ORDER BY recency_days DESC, customer_id
        ) AS recency_score,
        NTILE(5) OVER
        (
            ORDER BY frequency ASC, customer_id
        ) AS frequency_score,
        NTILE(5) OVER
        (
            ORDER BY monetary ASC, customer_id
        ) AS monetary_score
    FROM Base
)
SELECT
    s.customer_id,
    c.customer_name,
    s.recency_days,
    s.frequency,
    s.monetary,
    s.recency_score,
    s.frequency_score,
    s.monetary_score,
    CASE
        WHEN s.recency_score >= 4
         AND s.frequency_score >= 4
         AND s.monetary_score >= 4
            THEN 'Champions'

        WHEN s.frequency_score >= 4
         AND s.monetary_score >= 3
            THEN 'Loyal Customers'

        WHEN s.recency_score >= 4
         AND s.frequency_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN s.recency_score <= 2
         AND s.frequency_score >= 3
            THEN 'At Risk'

        WHEN s.recency_score <= 3
            THEN 'Needs Attention'

        ELSE 'Other'
    END AS rfm_segment
FROM Scores AS s
INNER JOIN training.customers AS c
    ON c.customer_id = s.customer_id
ORDER BY s.customer_id;
GO

/*
    Segment thresholds are business rules, not universal RFM standards.
*/


/*==============================================================================
    SOLUTION 36 - COHORT ASSIGNMENT
==============================================================================*/

SELECT
    customer_id,
    DATEFROMPARTS
    (
        YEAR(MIN(order_date)),
        MONTH(MIN(order_date)),
        1
    ) AS cohort_month
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 37 - CUSTOMER-MONTH ACTIVITY
==============================================================================*/

SELECT DISTINCT
    customer_id,
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
        AS activity_month
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    activity_month;
GO


/*==============================================================================
    SOLUTION 38 - COHORT ACTIVITY
==============================================================================*/

WITH Cohorts AS
(
    SELECT
        customer_id,
        DATEFROMPARTS
        (
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    a.customer_id,
    c.cohort_month,
    a.activity_month,
    DATEDIFF
    (
        MONTH,
        c.cohort_month,
        a.activity_month
    ) AS cohort_age
FROM Activity AS a
INNER JOIN Cohorts AS c
    ON c.customer_id = a.customer_id
ORDER BY
    c.cohort_month,
    a.customer_id,
    a.activity_month;
GO


/*==============================================================================
    SOLUTION 39 - COHORT RETENTION COUNTS
==============================================================================*/

WITH Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
Cohorts AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS cohort_month
    FROM Activity
    GROUP BY customer_id
)
SELECT
    c.cohort_month,
    DATEDIFF(MONTH, c.cohort_month, a.activity_month) AS cohort_age,
    COUNT(*) AS active_customers
FROM Activity AS a
INNER JOIN Cohorts AS c
    ON c.customer_id = a.customer_id
GROUP BY
    c.cohort_month,
    DATEDIFF(MONTH, c.cohort_month, a.activity_month)
ORDER BY
    c.cohort_month,
    cohort_age;
GO


/*==============================================================================
    SOLUTION 40 - COHORT RETENTION RATE
==============================================================================*/

WITH Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
Cohorts AS
(
    SELECT
        customer_id,
        MIN(activity_month) AS cohort_month
    FROM Activity
    GROUP BY customer_id
),
CohortSizes AS
(
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size
    FROM Cohorts
    GROUP BY cohort_month
),
Retention AS
(
    SELECT
        c.cohort_month,
        DATEDIFF(MONTH, c.cohort_month, a.activity_month) AS cohort_age,
        COUNT(*) AS active_customers
    FROM Activity AS a
    INNER JOIN Cohorts AS c
        ON c.customer_id = a.customer_id
    GROUP BY
        c.cohort_month,
        DATEDIFF(MONTH, c.cohort_month, a.activity_month)
)
SELECT
    r.cohort_month,
    r.cohort_age,
    cs.cohort_size,
    r.active_customers,
    100.0 * r.active_customers
        / NULLIF(cs.cohort_size, 0) AS retention_rate_pct
FROM Retention AS r
INNER JOIN CohortSizes AS cs
    ON cs.cohort_month = r.cohort_month
ORDER BY
    r.cohort_month,
    r.cohort_age;
GO


/*==============================================================================
    SOLUTION 41 - CONSECUTIVE-MONTH RETENTION
==============================================================================*/

WITH Activity AS
(
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
            AS activity_month
    FROM training.orders
    WHERE order_status = 'Completed'
),
Boundary AS
(
    SELECT MAX(activity_month) AS latest_month
    FROM Activity
),
MonthlyRetention AS
(
    SELECT
        a.activity_month,
        COUNT(*) AS active_customers,
        COUNT(n.customer_id) AS retained_next_month_customers
    FROM Activity AS a
    CROSS JOIN Boundary AS b
    LEFT JOIN Activity AS n
        ON n.customer_id = a.customer_id
       AND n.activity_month = DATEADD(MONTH, 1, a.activity_month)
    WHERE a.activity_month < b.latest_month
    GROUP BY a.activity_month
)
SELECT
    activity_month,
    active_customers,
    retained_next_month_customers,
    100.0 * retained_next_month_customers
        / NULLIF(active_customers, 0) AS next_month_retention_pct
FROM MonthlyRetention
ORDER BY activity_month;
GO

/*
    The latest observed month is excluded because its next month is not
    observable in this dataset.
*/


/*==============================================================================
    SOLUTION 42 - DATASET BOUNDARY
==============================================================================*/

SELECT
    MIN(order_date) AS first_completed_date,
    MAX(order_date) AS latest_completed_date,
    DATEFROMPARTS
    (
        YEAR(MAX(order_date)),
        MONTH(MAX(order_date)),
        1
    ) AS latest_completed_month
FROM training.orders
WHERE order_status = 'Completed';
GO

/*
    Absence of next-month data is not evidence of next-month churn.

    The observation window ended, so those customers are right-censored for
    that future-period question.
*/


/*==============================================================================
    SOLUTION 43 - 30-DAY INACTIVITY
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
LastPurchase AS
(
    SELECT
        customer_id,
        MAX(order_date) AS last_completed_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT
    lp.customer_id,
    c.customer_name,
    lp.last_completed_order_date,
    DATEDIFF
    (
        DAY,
        lp.last_completed_order_date,
        rd.reference_date
    ) AS days_inactive
FROM LastPurchase AS lp
CROSS JOIN ReferenceDate AS rd
INNER JOIN training.customers AS c
    ON c.customer_id = lp.customer_id
WHERE DATEDIFF
(
    DAY,
    lp.last_completed_order_date,
    rd.reference_date
) >= 30
ORDER BY
    days_inactive DESC,
    lp.customer_id;
GO


/*==============================================================================
    SOLUTION 44 - CUSTOMER FUNNEL
==============================================================================*/

WITH Counts AS
(
    SELECT
        (SELECT COUNT(*) FROM training.customers) AS registered,
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
        ) AS ordered,
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
            WHERE order_status = 'Completed'
        ) AS completed,
        (
            SELECT COUNT(*)
            FROM
            (
                SELECT customer_id
                FROM training.orders
                WHERE order_status = 'Completed'
                GROUP BY customer_id
                HAVING COUNT(*) >= 2
            ) AS r
        ) AS repeat_customers
)
SELECT
    v.stage_number,
    v.stage_name,
    v.customer_count
FROM Counts AS c
CROSS APPLY
(
    VALUES
        (1, 'Registered', c.registered),
        (2, 'Placed Any Order', c.ordered),
        (3, 'Completed Customer', c.completed),
        (4, 'Repeat Customer', c.repeat_customers)
) AS v(stage_number, stage_name, customer_count)
ORDER BY v.stage_number;
GO


/*==============================================================================
    SOLUTION 45 - FUNNEL CONVERSION RATES
==============================================================================*/

WITH Counts AS
(
    SELECT
        (SELECT COUNT(*) FROM training.customers) AS registered,
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
        ) AS ordered,
        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
            WHERE order_status = 'Completed'
        ) AS completed,
        (
            SELECT COUNT(*)
            FROM
            (
                SELECT customer_id
                FROM training.orders
                WHERE order_status = 'Completed'
                GROUP BY customer_id
                HAVING COUNT(*) >= 2
            ) AS x
        ) AS repeat_customers
),
Funnel AS
(
    SELECT
        v.stage_number,
        v.stage_name,
        v.customer_count,
        c.registered
    FROM Counts AS c
    CROSS APPLY
    (
        VALUES
            (1, 'Registered', c.registered),
            (2, 'Placed Any Order', c.ordered),
            (3, 'Completed Customer', c.completed),
            (4, 'Repeat Customer', c.repeat_customers)
    ) AS v(stage_number, stage_name, customer_count)
),
WithPrevious AS
(
    SELECT
        *,
        LAG(customer_count) OVER
        (
            ORDER BY stage_number
        ) AS previous_stage_count
    FROM Funnel
)
SELECT
    stage_number,
    stage_name,
    customer_count,
    previous_stage_count,
    CASE
        WHEN previous_stage_count IS NULL THEN NULL
        ELSE 100.0 * customer_count / NULLIF(previous_stage_count, 0)
    END AS step_conversion_pct,
    100.0 * customer_count / NULLIF(registered, 0)
        AS overall_conversion_pct
FROM WithPrevious
ORDER BY stage_number;
GO


/*==============================================================================
    SOLUTION 46 - CUSTOMER STATUS SEGMENTATION
==============================================================================*/

WITH OrderCounts AS
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
        WHEN COALESCE(oc.total_orders, 0) = 0
            THEN 'Never Ordered'

        WHEN COALESCE(oc.completed_orders, 0) = 0
            THEN 'Ordered But Never Completed'

        WHEN oc.completed_orders = 1
            THEN 'One-Time Completed Customer'

        ELSE 'Repeat Customer'
    END AS customer_segment
FROM training.customers AS c
LEFT JOIN OrderCounts AS oc
    ON oc.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 47 - SEGMENT SUMMARY
==============================================================================*/

WITH OrderCounts AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)
            AS completed_orders
    FROM training.orders
    GROUP BY customer_id
),
Segments AS
(
    SELECT
        c.customer_id,
        CASE
            WHEN COALESCE(oc.total_orders, 0) = 0
                THEN 'Never Ordered'
            WHEN COALESCE(oc.completed_orders, 0) = 0
                THEN 'Ordered But Never Completed'
            WHEN oc.completed_orders = 1
                THEN 'One-Time Completed Customer'
            ELSE 'Repeat Customer'
        END AS customer_segment
    FROM training.customers AS c
    LEFT JOIN OrderCounts AS oc
        ON oc.customer_id = c.customer_id
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
ORDER BY customer_count DESC;
GO


/*==============================================================================
    SOLUTION 48 - CITY PERFORMANCE
==============================================================================*/

WITH Registered AS
(
    SELECT
        city,
        COUNT(*) AS registered_customers
    FROM training.customers
    GROUP BY city
),
CompletedMetrics AS
(
    SELECT
        c.city,
        COUNT(DISTINCT o.customer_id) AS completed_customers,
        COUNT(DISTINCT o.order_id) AS completed_orders,
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
    r.city,
    r.registered_customers,
    COALESCE(cm.completed_customers, 0) AS completed_customers,
    COALESCE(cm.completed_orders, 0) AS completed_orders,
    COALESCE(cm.completed_revenue, 0) AS completed_revenue
FROM Registered AS r
LEFT JOIN CompletedMetrics AS cm
    ON (cm.city = r.city)
    OR (cm.city IS NULL AND r.city IS NULL)
ORDER BY r.city;
GO


/*==============================================================================
    SOLUTION 49 - CITY CONVERSION RATE
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
                  AND o.order_status = 'Completed'
            )
            THEN 1
            ELSE 0
        END AS is_completed_customer
    FROM training.customers AS c
)
SELECT
    city,
    COUNT(*) AS registered_customers,
    SUM(is_completed_customer) AS completed_customers,
    100.0 * SUM(is_completed_customer)
        / NULLIF(COUNT(*), 0) AS completion_conversion_pct
FROM CustomerFlags
GROUP BY city
ORDER BY city;
GO


/*==============================================================================
    SOLUTION 50 - CUSTOMER CATEGORY PREFERENCES
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
)
SELECT
    cc.customer_id,
    c.customer_name,
    cc.category,
    cc.category_revenue,
    DENSE_RANK() OVER
    (
        PARTITION BY cc.customer_id
        ORDER BY cc.category_revenue DESC
    ) AS category_rank_for_customer
FROM CustomerCategory AS cc
INNER JOIN training.customers AS c
    ON c.customer_id = cc.customer_id
ORDER BY
    cc.customer_id,
    category_rank_for_customer,
    cc.category;
GO


/*==============================================================================
    SOLUTION 51 - FAVORITE CATEGORY
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
    SOLUTION 52 - PRODUCT CUSTOMER PENETRATION
==============================================================================*/

WITH CompletedCustomers AS
(
    SELECT DISTINCT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
ProductBuyers AS
(
    SELECT
        oi.product_id,
        COUNT(DISTINCT o.customer_id) AS distinct_buyers
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
),
TotalCustomers AS
(
    SELECT COUNT(*) AS total_completed_customers
    FROM CompletedCustomers
)
SELECT
    pb.product_id,
    p.product_name,
    pb.distinct_buyers,
    tc.total_completed_customers,
    100.0 * pb.distinct_buyers
        / NULLIF(tc.total_completed_customers, 0)
        AS customer_penetration_pct
FROM ProductBuyers AS pb
INNER JOIN training.products AS p
    ON p.product_id = pb.product_id
CROSS JOIN TotalCustomers AS tc
ORDER BY
    customer_penetration_pct DESC,
    pb.product_id;
GO


/*==============================================================================
    SOLUTION 53 - PRODUCTS BOUGHT TOGETHER
==============================================================================*/

WITH CompletedOrderProducts AS
(
    SELECT DISTINCT
        oi.order_id,
        oi.product_id
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
)
SELECT
    a.product_id AS product_id_1,
    p1.product_name AS product_name_1,
    b.product_id AS product_id_2,
    p2.product_name AS product_name_2,
    COUNT(*) AS orders_together
FROM CompletedOrderProducts AS a
INNER JOIN CompletedOrderProducts AS b
    ON b.order_id = a.order_id
   AND b.product_id > a.product_id
INNER JOIN training.products AS p1
    ON p1.product_id = a.product_id
INNER JOIN training.products AS p2
    ON p2.product_id = b.product_id
GROUP BY
    a.product_id,
    p1.product_name,
    b.product_id,
    p2.product_name
ORDER BY
    orders_together DESC,
    product_id_1,
    product_id_2;
GO


/*==============================================================================
    SOLUTION 54 - CUSTOMER PRODUCT DIVERSITY
==============================================================================*/

SELECT
    o.customer_id,
    c.customer_name,
    COUNT(DISTINCT oi.product_id) AS distinct_products_purchased,
    COUNT(DISTINCT p.category) AS distinct_categories_purchased
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.customer_id,
    c.customer_name
ORDER BY o.customer_id;
GO


/*==============================================================================
    SOLUTION 55 - CUSTOMER ORDER FREQUENCY
==============================================================================*/

WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders,
        MIN(order_date) AS first_completed_order_date,
        MAX(order_date) AS latest_completed_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
    HAVING COUNT(*) >= 2
),
Metrics AS
(
    SELECT
        *,
        DATEDIFF
        (
            DAY,
            first_completed_order_date,
            latest_completed_order_date
        ) AS active_span_days
    FROM CustomerOrders
)
SELECT
    m.customer_id,
    c.customer_name,
    m.completed_orders,
    m.first_completed_order_date,
    m.latest_completed_order_date,
    m.active_span_days,
    1.0 * m.active_span_days
        / NULLIF(m.completed_orders - 1, 0)
        AS average_days_between_orders
FROM Metrics AS m
INNER JOIN training.customers AS c
    ON c.customer_id = m.customer_id
ORDER BY m.customer_id;
GO


/*==============================================================================
    SOLUTION 56 - REVENUE ABOVE CUSTOMER AVERAGE
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
    order_id,
    customer_id,
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
    SOLUTION 57 - PRODUCTS ABOVE CATEGORY AVERAGE
==============================================================================*/

WITH ProductRevenue AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS product_revenue
    FROM training.products AS p
    INNER JOIN training.order_items AS oi
        ON oi.product_id = p.product_id
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        p.product_id,
        p.product_name
),
Compared AS
(
    SELECT
        *,
        AVG(1.0 * product_revenue) OVER
        (
            PARTITION BY category
        ) AS category_average_product_revenue
    FROM ProductRevenue
)
SELECT
    category,
    product_id,
    product_name,
    product_revenue,
    category_average_product_revenue
FROM Compared
WHERE product_revenue > category_average_product_revenue
ORDER BY
    category,
    product_revenue DESC;
GO


/*==============================================================================
    SOLUTION 58 - MONTHLY PRODUCT LEADER
==============================================================================*/

WITH MonthlyProductRevenue AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
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
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1),
        p.product_id,
        p.product_name
),
Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY revenue_month
            ORDER BY
                product_revenue DESC,
                product_id ASC
        ) AS rn
    FROM MonthlyProductRevenue
)
SELECT
    revenue_month,
    product_id,
    product_name,
    product_revenue
FROM Ranked
WHERE rn = 1
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 59 - CUSTOMER'S LARGEST ORDER
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
    SOLUTION 60 - REVENUE GROWTH BY CATEGORY
==============================================================================*/

WITH MonthlyCategoryRevenue AS
(
    SELECT
        p.category,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        p.category,
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
Growth AS
(
    SELECT
        *,
        LAG(monthly_revenue) OVER
        (
            PARTITION BY category
            ORDER BY revenue_month
        ) AS previous_revenue
    FROM MonthlyCategoryRevenue
)
SELECT
    category,
    revenue_month,
    monthly_revenue,
    previous_revenue,
    100.0 * (monthly_revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) AS growth_pct
FROM Growth
ORDER BY
    category,
    revenue_month;
GO

/*
    LAG compares previous observed category-month rows. Missing calendar months
    should be generated explicitly if true month-to-month comparison is required.
*/


/*==============================================================================
    SOLUTION 61 - MONTHLY PROFIT TREND
==============================================================================*/

WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * p.cost) AS estimated_cost
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
)
SELECT
    revenue_month,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS estimated_gross_profit,
    100.0 * (revenue - estimated_cost)
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct
FROM MonthlyProfit
ORDER BY revenue_month;
GO

/*
    Cost is estimated using current products.cost, not transaction-time cost.
*/


/*==============================================================================
    SOLUTION 62 - CUMULATIVE CUSTOMER VALUE
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
)
SELECT
    customer_id,
    order_id,
    order_date,
    order_value,
    SUM(order_value) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_customer_revenue
FROM OrderValues
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 63 - CUSTOMER REVENUE DECILES
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
Deciles AS
(
    SELECT
        *,
        NTILE(10) OVER
        (
            ORDER BY completed_revenue DESC, customer_id
        ) AS revenue_decile
    FROM CustomerRevenue
)
SELECT
    d.customer_id,
    c.customer_name,
    d.completed_revenue,
    d.revenue_decile
FROM Deciles AS d
INNER JOIN training.customers AS c
    ON c.customer_id = d.customer_id
ORDER BY
    d.revenue_decile,
    d.completed_revenue DESC;
GO

/*
    NTILE distributes rows (customers) as evenly as possible across buckets.
    It does not attempt to place an equal amount of revenue in every bucket.
*/


/*==============================================================================
    SOLUTION 64 - TOP CUSTOMER REVENUE SHARE
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
Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            ORDER BY completed_revenue DESC, customer_id
        ) AS customer_number,
        COUNT(*) OVER () AS total_customers,
        SUM(completed_revenue) OVER () AS total_revenue,
        SUM(completed_revenue) OVER
        (
            ORDER BY completed_revenue DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM CustomerRevenue
)
SELECT
    r.customer_id,
    c.customer_name,
    r.completed_revenue,
    r.customer_number,
    r.total_customers,
    100.0 * r.completed_revenue
        / NULLIF(r.total_revenue, 0) AS revenue_share_pct,
    100.0 * r.cumulative_revenue
        / NULLIF(r.total_revenue, 0) AS cumulative_revenue_share_pct
FROM Ranked AS r
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
ORDER BY r.customer_number;
GO


/*==============================================================================
    SOLUTION 65 - ORDER STATUS SUMMARY
==============================================================================*/

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(oi.order_item_id) AS item_lines,
    COALESCE(SUM(oi.quantity), 0) AS units,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS order_item_value
FROM training.orders AS o
LEFT JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY o.order_status
ORDER BY o.order_status;
GO

/*
    Values attached to Pending/Cancelled orders are not called revenue here.
*/


/*==============================================================================
    SOLUTION 66 - CANCELLATION ANALYSIS
==============================================================================*/

WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM
        (
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS cancelled_orders
    FROM training.orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(co.total_orders, 0) AS total_orders,
    COALESCE(co.cancelled_orders, 0) AS cancelled_orders,
    CASE
        WHEN COALESCE(co.total_orders, 0) = 0 THEN NULL
        ELSE 100.0 * co.cancelled_orders
            / NULLIF(co.total_orders, 0)
    END AS cancellation_rate_pct
FROM training.customers AS c
LEFT JOIN CustomerOrders AS co
    ON co.customer_id = c.customer_id
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 67 - ACTIVE CUSTOMER HEALTH REPORT
==============================================================================*/

WITH OrderMetrics AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)
            AS completed_orders,
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
    c.signup_date,
    COALESCE(om.total_orders, 0) AS total_orders,
    COALESCE(om.completed_orders, 0) AS completed_orders,
    om.latest_completed_order_date,
    COALESCE(r.completed_revenue, 0) AS completed_revenue,
    CASE
        WHEN COALESCE(om.total_orders, 0) = 0
            THEN 'Never Ordered'
        WHEN COALESCE(om.completed_orders, 0) = 0
            THEN 'Ordered, Never Completed'
        WHEN om.completed_orders = 1
            THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_status
FROM training.customers AS c
LEFT JOIN OrderMetrics AS om
    ON om.customer_id = c.customer_id
LEFT JOIN Revenue AS r
    ON r.customer_id = c.customer_id
WHERE c.is_active = 1
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 68 - INVENTORY VALUE
==============================================================================*/

SELECT
    product_id,
    product_name,
    category,
    stock_quantity,
    cost,
    price,
    stock_quantity * cost AS inventory_cost_value,
    stock_quantity * price AS potential_retail_value,
    stock_quantity * (price - cost) AS potential_gross_profit
FROM training.products
ORDER BY product_id;
GO


/*==============================================================================
    SOLUTION 69 - CATEGORY INVENTORY VALUE
==============================================================================*/

SELECT
    category,
    COUNT(*) AS products,
    SUM(stock_quantity) AS total_units_in_stock,
    SUM(stock_quantity * cost) AS inventory_cost_value,
    SUM(stock_quantity * price) AS potential_retail_value,
    SUM(stock_quantity * (price - cost)) AS potential_gross_profit
FROM training.products
GROUP BY category
ORDER BY category;
GO


/*==============================================================================
    SOLUTION 70 - LOW STOCK PRIORITY
==============================================================================*/

WITH Sales AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold_completed
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    COALESCE(s.units_sold_completed, 0) AS units_sold_completed,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= 5 THEN 'Critical'
        WHEN p.stock_quantity <= 10 THEN 'Low'
        ELSE 'Healthy'
    END AS stock_priority
FROM training.products AS p
LEFT JOIN Sales AS s
    ON s.product_id = p.product_id
ORDER BY
    p.stock_quantity,
    p.product_id;
GO


/*==============================================================================
    SOLUTION 71 - EXECUTIVE CUSTOMER + REVENUE DASHBOARD
==============================================================================*/

WITH CustomerOrderMetrics AS
(
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM
        (
            CASE
                WHEN o.order_status = 'Completed' THEN 1
                ELSE 0
            END
        ) AS completed_orders
    FROM training.customers AS c
    LEFT JOIN training.orders AS o
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
),
CompletedTransactions AS
(
    SELECT
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
CustomerCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)
            AS active_registered_customers
    FROM training.customers
),
CustomerStages AS
(
    SELECT
        SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END)
            AS customers_with_any_order,
        SUM(CASE WHEN completed_orders > 0 THEN 1 ELSE 0 END)
            AS completed_customers,
        SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END)
            AS repeat_customers
    FROM CustomerOrderMetrics
)
SELECT
    cc.registered_customers,
    cc.active_registered_customers,
    cs.customers_with_any_order,
    cs.completed_customers,
    cs.repeat_customers,
    ct.completed_orders,
    ct.units_sold,
    ct.completed_revenue,
    1.0 * ct.completed_revenue
        / NULLIF(ct.completed_orders, 0) AS average_order_value,
    100.0 * cs.repeat_customers
        / NULLIF(cs.completed_customers, 0) AS repeat_customer_rate_pct
FROM CustomerCounts AS cc
CROSS JOIN CustomerStages AS cs
CROSS JOIN CompletedTransactions AS ct;
GO


/*==============================================================================
    SOLUTION 72 - EXECUTIVE PRODUCT DASHBOARD
==============================================================================*/

WITH ProductCounts AS
(
    SELECT
        COUNT(*) AS total_products,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_products
    FROM training.products
),
Sales AS
(
    SELECT
        COUNT(DISTINCT oi.product_id) AS products_with_completed_sales,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
        SUM(oi.quantity * (oi.unit_price - p.cost))
            AS estimated_gross_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
)
SELECT
    pc.total_products,
    pc.active_products,
    s.products_with_completed_sales,
    s.units_sold,
    s.completed_revenue,
    s.estimated_gross_profit,
    100.0 * s.estimated_gross_profit
        / NULLIF(s.completed_revenue, 0) AS estimated_gross_margin_pct
FROM ProductCounts AS pc
CROSS JOIN Sales AS s;
GO


/*==============================================================================
    SOLUTION 73 - MONTHLY EXECUTIVE DASHBOARD
==============================================================================*/

WITH Monthly AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        COUNT(DISTINCT o.customer_id) AS purchasing_customers,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity * (oi.unit_price - p.cost))
            AS estimated_gross_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
WithPrevious AS
(
    SELECT
        *,
        LAG(revenue) OVER
        (
            ORDER BY revenue_month
        ) AS previous_month_revenue
    FROM Monthly
)
SELECT
    revenue_month,
    completed_orders,
    purchasing_customers,
    units_sold,
    revenue,
    estimated_gross_profit,
    1.0 * revenue
        / NULLIF(completed_orders, 0) AS average_order_value,
    previous_month_revenue,
    100.0 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) AS revenue_growth_pct,
    SUM(revenue) OVER
    (
        ORDER BY revenue_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM WithPrevious
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 74 - DATA QUALITY VALIDATION
==============================================================================*/

/* A. Orders referencing missing customers */
SELECT o.*
FROM training.orders AS o
LEFT JOIN training.customers AS c
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;
GO


/* B. Order items referencing missing orders */
SELECT oi.*
FROM training.order_items AS oi
LEFT JOIN training.orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;
GO


/* C. Order items referencing missing products */
SELECT oi.*
FROM training.order_items AS oi
LEFT JOIN training.products AS p
    ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;
GO


/* D. Non-positive quantities */
SELECT *
FROM training.order_items
WHERE quantity <= 0;
GO


/* E. Negative transaction prices */
SELECT *
FROM training.order_items
WHERE unit_price < 0;
GO


/* F. Negative product stock */
SELECT *
FROM training.products
WHERE stock_quantity < 0;
GO


/* G. Duplicate customer emails */
SELECT
    email,
    COUNT(*) AS occurrences
FROM training.customers
GROUP BY email
HAVING COUNT(*) > 1;
GO


/*==============================================================================
    SOLUTION 75 - FUNNEL VALIDATION
==============================================================================*/

WITH Counts AS
(
    SELECT
        (SELECT COUNT(*) FROM training.customers) AS registered,

        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
        ) AS ordered,

        (
            SELECT COUNT(DISTINCT customer_id)
            FROM training.orders
            WHERE order_status = 'Completed'
        ) AS completed,

        (
            SELECT COUNT(*)
            FROM
            (
                SELECT customer_id
                FROM training.orders
                WHERE order_status = 'Completed'
                GROUP BY customer_id
                HAVING COUNT(*) >= 2
            ) AS x
        ) AS repeat_customers
)
SELECT
    registered,
    ordered,
    completed,
    repeat_customers AS repeat,
    CASE
        WHEN registered >= ordered
         AND ordered >= completed
         AND completed >= repeat_customers
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM Counts;
GO


/*==============================================================================
    SOLUTION 76 - REVENUE RECONCILIATION
==============================================================================*/

WITH DirectRevenue AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS direct_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
OrderValues AS
(
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
),
OrderRevenue AS
(
    SELECT
        COALESCE(SUM(order_value), 0) AS order_level_revenue
    FROM OrderValues
)
SELECT
    d.direct_revenue,
    o.order_level_revenue,
    d.direct_revenue - o.order_level_revenue AS difference,
    CASE
        WHEN d.direct_revenue = o.order_level_revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM DirectRevenue AS d
CROSS JOIN OrderRevenue AS o;
GO


/*==============================================================================
    SOLUTION 77 - CUSTOMER REVENUE RECONCILIATION
==============================================================================*/

WITH DirectRevenue AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS direct_revenue
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
Reaggregated AS
(
    SELECT COALESCE(SUM(customer_revenue), 0) AS customer_level_revenue
    FROM CustomerRevenue
)
SELECT
    d.direct_revenue,
    r.customer_level_revenue,
    d.direct_revenue - r.customer_level_revenue AS difference,
    CASE
        WHEN d.direct_revenue = r.customer_level_revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM DirectRevenue AS d
CROSS JOIN Reaggregated AS r;
GO


/*==============================================================================
    SOLUTION 78 - PERFORMANCE REVIEW
==============================================================================*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/*
    Grain:
        one row per customer with Completed revenue.

    Important columns:

        orders.order_status
        orders.customer_id
        orders.order_id
        order_items.order_id

    Inspect existing indexes:
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
    OBJECT_ID('training.orders'),
    OBJECT_ID('training.order_items')
)
ORDER BY
    table_name,
    i.index_id;
GO

/*
    Potential large-data candidates might include:

        orders(order_status, customer_id)
            INCLUDE(order_id)

        order_items(order_id)
            INCLUDE(quantity, unit_price)

    Actual index design depends on selectivity, existing indexes, workload,
    query frequency, and write patterns.

    Additional indexes increase storage and INSERT/UPDATE/DELETE maintenance.

    The equality predicate on order_status is SARGable.
*/


/*==============================================================================
    SOLUTION 79 - FIX THE BROKEN BUSINESS QUERY
==============================================================================*/

/*
    Problems in the original query:

    1. WHERE o.order_status = 'Completed' removes NULL right-side rows,
       defeating the requirement to keep all customers.

    2. COUNT(o.order_id) counts joined order-item rows and can multiply orders.

    3. Revenue uses products.price, which is the current catalog price.

       Historical transaction revenue must use order_items.unit_price.

    4. Customers with no Completed activity need zero metrics.

    5. Joining products is unnecessary for transaction revenue.
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
    SOLUTION 80 - FINAL BUSINESS CASE STUDY
==============================================================================*/

/*
    Final grain:
        exactly one row per registered customer.

    Architecture:

        1. Order-level counts/dates
        2. Completed transaction metrics
        3. Diversity
        4. Combine at customer grain
        5. Segment
        6. Rank positive-revenue customers
*/


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
    SELECT
        o.customer_id,
        SUM(oi.quantity) AS completed_units,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
        SUM
        (
            oi.quantity * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit,
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
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        c.signup_date,
        c.is_active,

        COALESCE(om.total_orders, 0) AS total_orders,
        COALESCE(om.completed_orders, 0) AS completed_orders,
        COALESCE(om.cancelled_orders, 0) AS cancelled_orders,

        om.first_completed_order_date,
        om.latest_completed_order_date,

        COALESCE(cm.completed_units, 0) AS completed_units,
        COALESCE(cm.completed_revenue, 0) AS completed_revenue,
        COALESCE(cm.estimated_gross_profit, 0) AS estimated_gross_profit,
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
        END AS customer_segment,

        CASE
            WHEN completed_revenue > 0
            THEN DENSE_RANK() OVER
            (
                ORDER BY
                    CASE
                        WHEN completed_revenue > 0 THEN completed_revenue
                    END DESC
            )
            ELSE NULL
        END AS raw_revenue_rank
    FROM CustomerBase
)
SELECT
    customer_id,
    customer_name,
    city,
    signup_date,
    is_active,

    total_orders,
    completed_orders,
    cancelled_orders,

    first_completed_order_date,
    latest_completed_order_date,

    completed_units,
    completed_revenue,

    1.0 * completed_revenue
        / NULLIF(completed_orders, 0) AS average_order_value,

    estimated_gross_profit,

    100.0 * estimated_gross_profit
        / NULLIF(completed_revenue, 0) AS estimated_gross_margin_pct,

    distinct_products_purchased,
    distinct_categories_purchased,

    customer_segment,

    CASE
        WHEN completed_revenue > 0 THEN raw_revenue_rank
        ELSE NULL
    END AS completed_revenue_rank

FROM Segmented
ORDER BY
    CASE WHEN raw_revenue_rank IS NULL THEN 1 ELSE 0 END,
    raw_revenue_rank,
    customer_id;
GO


/*------------------------------------------------------------------------------
    FINAL CASE STUDY VALIDATION
------------------------------------------------------------------------------*/

SELECT
    (SELECT COUNT(*) FROM training.customers) AS registered_customers;
GO

/*
    The final case-study query should return exactly the same number of rows.

    Additional validation principles:

    - one row per customer
    - Completed revenue uses unit_price
    - current cost is used only for estimated profit
    - order counts are calculated before detail-row multiplication
    - customers with no activity remain
    - no Completed activity -> NULL Completed dates
    - zero revenue customers receive NULL revenue rank
*/


/*==============================================================================
    FINAL BUSINESS METRIC RECONCILIATION
==============================================================================*/

WITH TransactionRevenue AS
(
    SELECT
        SUM(oi.quantity * oi.unit_price) AS revenue
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
    SELECT SUM(order_revenue) AS revenue
    FROM OrderRevenue
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
    SELECT SUM(customer_revenue) AS revenue
    FROM CustomerRevenue
)
SELECT
    t.revenue AS transaction_revenue,
    o.revenue AS order_level_revenue,
    c.revenue AS customer_level_revenue,
    CASE
        WHEN t.revenue = o.revenue
         AND o.revenue = c.revenue
        THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status
FROM TransactionRevenue AS t
CROSS JOIN OrderTotal AS o
CROSS JOIN CustomerTotal AS c;
GO


/*==============================================================================
    BUSINESS CHALLENGES COMPLETE

    Completed:
        80 business SQL challenges

    Major skills integrated:

        - Business metric definition
        - Result grain
        - Revenue analysis
        - Customer analytics
        - Product analytics
        - Profitability
        - Window functions
        - Ranking
        - Growth
        - Running totals
        - RFM
        - Cohorts
        - Retention
        - Churn/inactivity
        - Funnels
        - Segmentation
        - Market basket/product pairs
        - Data quality validation
        - Metric reconciliation
        - Performance reasoning

    Core analytics discipline:

        Define
            ->
        Establish grain
            ->
        Calculate
            ->
        Validate
            ->
        Reconcile
            ->
        Optimize

==============================================================================*/