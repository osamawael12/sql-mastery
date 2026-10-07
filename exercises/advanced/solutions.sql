/*==============================================================================
    SQL Mastery
    Practice Exercises - Advanced
    File: solutions.sql
    Database: SQLMastery
    Schema: training

    Default definitions:
    - Revenue = Completed order-item value
    - Revenue uses order_items.unit_price
    - Repeat Customer = >= 2 Completed orders
    - Historical profit is estimated using current products.cost

    IMPORTANT:
    Transaction demonstrations end in ROLLBACK where appropriate.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - EXECUTIVE KPI REPORT
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
CustomerCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_customers
    FROM training.customers
),
Stages AS
(
    SELECT
        SUM(CASE WHEN total_orders > 0 THEN 1 ELSE 0 END)
            AS customers_with_any_order,
        SUM(CASE WHEN completed_orders > 0 THEN 1 ELSE 0 END)
            AS completed_customers,
        SUM(CASE WHEN completed_orders >= 2 THEN 1 ELSE 0 END)
            AS repeat_customers
    FROM CustomerOrderMetrics
),
Sales AS
(
    SELECT
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
)
SELECT
    cc.registered_customers,
    cc.active_customers,
    s.customers_with_any_order,
    s.completed_customers,
    s.repeat_customers,
    sl.completed_orders,
    sl.units_sold,
    sl.completed_revenue,
    1.0 * sl.completed_revenue
        / NULLIF(sl.completed_orders, 0) AS average_order_value,
    100.0 * s.repeat_customers
        / NULLIF(s.completed_customers, 0) AS repeat_customer_rate_pct
FROM CustomerCounts AS cc
CROSS JOIN Stages AS s
CROSS JOIN Sales AS sl;
GO


/*==============================================================================
    SOLUTION 2 - MONTHLY BUSINESS DASHBOARD
==============================================================================*/

WITH Monthly AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS revenue_month,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        COUNT(DISTINCT o.customer_id) AS purchasing_customers,
        SUM(oi.quantity) AS units_sold,
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
        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
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
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue
FROM WithPrevious
ORDER BY revenue_month;
GO

/*
    LAG() compares previous observed months. Missing calendar months need
    an explicit calendar/month series when true calendar continuity matters.
*/


/*==============================================================================
    SOLUTION 3 - CUSTOMER LIFETIME VALUE REPORT
==============================================================================*/

WITH OrderValues AS
(
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        SUM(oi.quantity) AS order_units,
        SUM(oi.quantity * oi.unit_price) AS order_revenue,
        SUM
        (
            oi.quantity * (oi.unit_price - p.cost)
        ) AS estimated_order_profit
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    INNER JOIN training.products AS p
        ON p.product_id = oi.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        o.order_id,
        o.order_date
),
CustomerMetrics AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_completed_order_date,
        MAX(order_date) AS latest_completed_order_date,
        COUNT(*) AS completed_orders,
        SUM(order_units) AS completed_units,
        SUM(order_revenue) AS completed_revenue,
        SUM(estimated_order_profit) AS estimated_gross_profit
    FROM OrderValues
    GROUP BY customer_id
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.first_completed_order_date,
    cm.latest_completed_order_date,
    cm.completed_orders,
    cm.completed_units,
    cm.completed_revenue,
    1.0 * cm.completed_revenue
        / NULLIF(cm.completed_orders, 0) AS average_order_value,
    cm.estimated_gross_profit,
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
    SOLUTION 4 - CUSTOMER VALUE RANK
==============================================================================*/

WITH CustomerMetrics AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
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
    GROUP BY o.customer_id
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.completed_orders,
    cm.completed_revenue,
    cm.estimated_gross_profit,
    DENSE_RANK() OVER
    (
        ORDER BY cm.completed_revenue DESC
    ) AS revenue_rank,
    DENSE_RANK() OVER
    (
        ORDER BY cm.estimated_gross_profit DESC
    ) AS profit_rank
FROM CustomerMetrics AS cm
INNER JOIN training.customers AS c
    ON c.customer_id = cm.customer_id
ORDER BY
    revenue_rank,
    cm.customer_id;
GO


/*==============================================================================
    SOLUTION 5 - CUSTOMER REVENUE CONCENTRATION
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
Metrics AS
(
    SELECT
        customer_id,
        completed_revenue,
        ROW_NUMBER() OVER
        (
            ORDER BY completed_revenue DESC, customer_id
        ) AS customer_number,
        COUNT(*) OVER () AS total_customers,
        SUM(completed_revenue) OVER () AS total_revenue,
        SUM(completed_revenue) OVER
        (
            ORDER BY completed_revenue DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue
    FROM CustomerRevenue
)
SELECT
    m.customer_id,
    c.customer_name,
    m.completed_revenue,
    m.customer_number,
    m.total_customers,
    100.0 * m.completed_revenue
        / NULLIF(m.total_revenue, 0) AS revenue_share_pct,
    m.cumulative_revenue,
    100.0 * m.cumulative_revenue
        / NULLIF(m.total_revenue, 0) AS cumulative_revenue_pct
FROM Metrics AS m
INNER JOIN training.customers AS c
    ON c.customer_id = m.customer_id
ORDER BY m.customer_number;
GO


/*==============================================================================
    SOLUTION 6 - REVENUE DECILES
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
    NTILE divides rows (customers), not total revenue. Therefore each bucket
    can contribute a very different percentage of revenue.
*/


/*==============================================================================
    SOLUTION 7 - DECILE SUMMARY
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
),
Summary AS
(
    SELECT
        revenue_decile,
        COUNT(*) AS customers,
        SUM(completed_revenue) AS decile_revenue
    FROM Deciles
    GROUP BY revenue_decile
)
SELECT
    revenue_decile,
    customers,
    decile_revenue,
    100.0 * decile_revenue
        / NULLIF(SUM(decile_revenue) OVER (), 0) AS revenue_share_pct
FROM Summary
ORDER BY revenue_decile;
GO


/*==============================================================================
    SOLUTION 8 - RFM REFERENCE DATE
==============================================================================*/

SELECT
    MAX(order_date) AS latest_completed_order_date,
    DATEADD(DAY, 1, MAX(order_date)) AS rfm_reference_date
FROM training.orders
WHERE order_status = 'Completed';
GO


/*==============================================================================
    SOLUTION 9 - RFM BASE
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
    DATEDIFF
    (
        DAY,
        r.last_completed_order_date,
        rd.reference_date
    ) AS recency_days,
    r.frequency,
    r.monetary
FROM RFM AS r
CROSS JOIN ReferenceDate AS rd
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
ORDER BY r.customer_id;
GO


/*==============================================================================
    SOLUTION 10 - RFM SCORES
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT
        DATEADD(DAY, 1, MAX(order_date)) AS reference_date
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


/*==============================================================================
    SOLUTION 11 - RFM SEGMENTS
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
    *,
    CASE
        WHEN recency_score >= 4
         AND frequency_score >= 4
         AND monetary_score >= 4
            THEN 'Champions'

        WHEN frequency_score >= 4
         AND monetary_score >= 3
            THEN 'Loyal Customers'

        WHEN recency_score >= 4
         AND frequency_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN recency_score <= 2
         AND frequency_score >= 3
            THEN 'At Risk'

        WHEN recency_score <= 3
            THEN 'Needs Attention'

        ELSE 'Other'
    END AS rfm_segment
FROM Scores
ORDER BY customer_id;
GO

/*
    These thresholds are example business rules, not universal RFM rules.
*/


/*==============================================================================
    SOLUTION 12 - RFM SEGMENT SUMMARY
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
),
Segments AS
(
    SELECT
        *,
        CASE
            WHEN recency_score >= 4
             AND frequency_score >= 4
             AND monetary_score >= 4
                THEN 'Champions'
            WHEN frequency_score >= 4
             AND monetary_score >= 3
                THEN 'Loyal Customers'
            WHEN recency_score >= 4
             AND frequency_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'
            WHEN recency_score <= 2
             AND frequency_score >= 3
                THEN 'At Risk'
            WHEN recency_score <= 3
                THEN 'Needs Attention'
            ELSE 'Other'
        END AS rfm_segment
    FROM Scores
)
SELECT
    rfm_segment,
    COUNT(*) AS customers,
    SUM(monetary) AS segment_revenue,
    AVG(1.0 * recency_days) AS average_recency,
    AVG(1.0 * frequency) AS average_frequency,
    AVG(1.0 * monetary) AS average_monetary
FROM Segments
GROUP BY rfm_segment
ORDER BY segment_revenue DESC;
GO


/*==============================================================================
    SOLUTION 13 - COHORT ASSIGNMENT
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
    SOLUTION 14 - CUSTOMER-MONTH ACTIVITY
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
    SOLUTION 15 - COHORT ACTIVITY
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
    SOLUTION 16 - COHORT SIZES
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
)
SELECT
    cohort_month,
    COUNT(*) AS cohort_size
FROM Cohorts
GROUP BY cohort_month
ORDER BY cohort_month;
GO


/*==============================================================================
    SOLUTION 17 - COHORT RETENTION COUNTS
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
    SOLUTION 18 - COHORT RETENTION RATES
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
Sizes AS
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
    s.cohort_size,
    r.active_customers,
    100.0 * r.active_customers
        / NULLIF(s.cohort_size, 0) AS retention_rate_pct
FROM Retention AS r
INNER JOIN Sizes AS s
    ON s.cohort_month = r.cohort_month
ORDER BY
    r.cohort_month,
    r.cohort_age;
GO


/*==============================================================================
    SOLUTION 19 - COHORT RETENTION MATRIX SOURCE
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
Sizes AS
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
),
Rates AS
(
    SELECT
        r.cohort_month,
        r.cohort_age,
        100.0 * r.active_customers
            / NULLIF(s.cohort_size, 0) AS retention_rate_pct
    FROM Retention AS r
    INNER JOIN Sizes AS s
        ON s.cohort_month = r.cohort_month
)
SELECT
    cohort_month,
    MAX(CASE WHEN cohort_age = 0 THEN retention_rate_pct END) AS month_0,
    MAX(CASE WHEN cohort_age = 1 THEN retention_rate_pct END) AS month_1,
    MAX(CASE WHEN cohort_age = 2 THEN retention_rate_pct END) AS month_2,
    MAX(CASE WHEN cohort_age = 3 THEN retention_rate_pct END) AS month_3
FROM Rates
GROUP BY cohort_month
ORDER BY cohort_month;
GO


/*==============================================================================
    SOLUTION 20 - CONSECUTIVE-MONTH RETENTION
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
Retention AS
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
FROM Retention
ORDER BY activity_month;
GO


/*==============================================================================
    SOLUTION 21 - DATASET OBSERVATION BOUNDARY
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
    Right-censoring means future behavior cannot be observed because the
    dataset ends.

    No observed next-month purchase is only meaningful as churn when the
    next month was actually available for observation.
*/


/*==============================================================================
    SOLUTION 22 - 30-DAY INACTIVITY
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
    SOLUTION 23 - 60-DAY INACTIVITY
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
    DATEDIFF(DAY, lp.last_completed_order_date, rd.reference_date)
        AS days_inactive
FROM LastPurchase AS lp
CROSS JOIN ReferenceDate AS rd
INNER JOIN training.customers AS c
    ON c.customer_id = lp.customer_id
WHERE DATEDIFF
(
    DAY,
    lp.last_completed_order_date,
    rd.reference_date
) >= 60
ORDER BY
    days_inactive DESC,
    lp.customer_id;
GO


/*==============================================================================
    SOLUTION 24 - INACTIVITY SEGMENT
==============================================================================*/

WITH ReferenceDate AS
(
    SELECT DATEADD(DAY, 1, MAX(order_date)) AS reference_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
Recency AS
(
    SELECT
        o.customer_id,
        MAX(o.order_date) AS last_completed_order_date,
        DATEDIFF
        (
            DAY,
            MAX(o.order_date),
            rd.reference_date
        ) AS days_inactive
    FROM training.orders AS o
    CROSS JOIN ReferenceDate AS rd
    WHERE o.order_status = 'Completed'
    GROUP BY
        o.customer_id,
        rd.reference_date
)
SELECT
    r.customer_id,
    c.customer_name,
    r.last_completed_order_date,
    r.days_inactive,
    CASE
        WHEN r.days_inactive <= 29 THEN 'Recent'
        WHEN r.days_inactive <= 59 THEN 'Watch'
        WHEN r.days_inactive <= 89 THEN 'At Risk'
        ELSE 'Highly Inactive'
    END AS inactivity_segment
FROM Recency AS r
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
ORDER BY
    r.days_inactive DESC,
    r.customer_id;
GO


/*==============================================================================
    SOLUTION 25 - FUNNEL
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
    SOLUTION 26 - FUNNEL CONVERSION
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
        ELSE 100.0 * customer_count
            / NULLIF(previous_stage_count, 0)
    END AS step_conversion_pct,
    100.0 * customer_count
        / NULLIF(registered, 0) AS overall_conversion_pct
FROM WithPrevious
ORDER BY stage_number;
GO


/*==============================================================================
    SOLUTION 27 - FUNNEL VALIDATION
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
    repeat_customers,
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
    SOLUTION 28 - CUSTOMER SEGMENTATION
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
    SOLUTION 29 - SEGMENT BUSINESS SUMMARY
==============================================================================*/

WITH OrderMetrics AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)
            AS completed_orders
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
),
CustomerSegments AS
(
    SELECT
        c.customer_id,
        COALESCE(r.completed_revenue, 0) AS completed_revenue,
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
    LEFT JOIN Revenue AS r
        ON r.customer_id = c.customer_id
),
Summary AS
(
    SELECT
        customer_segment,
        COUNT(*) AS customers,
        SUM(completed_revenue) AS completed_revenue
    FROM CustomerSegments
    GROUP BY customer_segment
)
SELECT
    customer_segment,
    customers,
    completed_revenue,
    100.0 * completed_revenue
        / NULLIF(SUM(completed_revenue) OVER (), 0) AS revenue_share_pct
FROM Summary
ORDER BY
    completed_revenue DESC,
    customer_segment;
GO


/*==============================================================================
    SOLUTION 30 - FAVORITE PRODUCT CATEGORY
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
    SOLUTION 31 - CUSTOMER CATEGORY SHARE
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
Metrics AS
(
    SELECT
        *,
        SUM(category_revenue) OVER
        (
            PARTITION BY customer_id
        ) AS customer_revenue
    FROM CustomerCategory
)
SELECT
    customer_id,
    category,
    category_revenue,
    customer_revenue,
    100.0 * category_revenue
        / NULLIF(customer_revenue, 0) AS category_share_pct
FROM Metrics
ORDER BY
    customer_id,
    category_revenue DESC;
GO


/*==============================================================================
    SOLUTION 32 - PRODUCT CUSTOMER PENETRATION
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
Total AS
(
    SELECT COUNT(*) AS completed_customers
    FROM CompletedCustomers
)
SELECT
    pb.product_id,
    p.product_name,
    pb.distinct_buyers,
    t.completed_customers,
    100.0 * pb.distinct_buyers
        / NULLIF(t.completed_customers, 0) AS penetration_pct
FROM ProductBuyers AS pb
INNER JOIN training.products AS p
    ON p.product_id = pb.product_id
CROSS JOIN Total AS t
ORDER BY
    penetration_pct DESC,
    pb.product_id;
GO


/*==============================================================================
    SOLUTION 33 - PRODUCT PAIRS
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
    SOLUTION 34 - MOST COMMON PRODUCT PAIR
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
),
Pairs AS
(
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
)
SELECT
    p.product_id_1,
    p1.product_name AS product_name_1,
    p.product_id_2,
    p2.product_name AS product_name_2,
    p.orders_together
FROM Pairs AS p
INNER JOIN training.products AS p1
    ON p1.product_id = p.product_id_1
INNER JOIN training.products AS p2
    ON p2.product_id = p.product_id_2
WHERE p.orders_together =
(
    SELECT MAX(orders_together)
    FROM Pairs
)
ORDER BY
    p.product_id_1,
    p.product_id_2;
GO


/*==============================================================================
    SOLUTION 35 - PRODUCT PROFITABILITY
==============================================================================*/

WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
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
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    revenue,
    estimated_cost,
    revenue - estimated_cost AS estimated_gross_profit,
    100.0 * (revenue - estimated_cost)
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct
FROM ProductProfit
ORDER BY
    estimated_gross_profit DESC,
    product_id;
GO

/*
    Current products.cost is not a historical transaction-time cost.
*/


/*==============================================================================
    SOLUTION 36 - PROFIT RANK WITHIN CATEGORY
==============================================================================*/

WITH ProductProfit AS
(
    SELECT
        p.category,
        p.product_id,
        p.product_name,
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
        p.category,
        p.product_id,
        p.product_name
)
SELECT
    category,
    product_id,
    product_name,
    estimated_gross_profit,
    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY estimated_gross_profit DESC
    ) AS category_profit_rank
FROM ProductProfit
ORDER BY
    category,
    category_profit_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 37 - HIGH REVENUE VS HIGH PROFIT
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
),
Ranks AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            ORDER BY revenue DESC
        ) AS revenue_rank,
        DENSE_RANK() OVER
        (
            ORDER BY estimated_gross_profit DESC
        ) AS profit_rank
    FROM ProductMetrics
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_gross_profit,
    revenue_rank,
    profit_rank,
    revenue_rank - profit_rank AS rank_difference
FROM Ranks
ORDER BY
    revenue_rank,
    product_id;
GO


/*==============================================================================
    SOLUTION 38 - MONTHLY PROFIT TREND
==============================================================================*/

WITH Monthly AS
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
),
Profit AS
(
    SELECT
        *,
        revenue - estimated_cost AS estimated_gross_profit
    FROM Monthly
),
WithPrevious AS
(
    SELECT
        *,
        LAG(estimated_gross_profit) OVER
        (
            ORDER BY revenue_month
        ) AS previous_profit
    FROM Profit
)
SELECT
    revenue_month,
    revenue,
    estimated_cost,
    estimated_gross_profit,
    100.0 * estimated_gross_profit
        / NULLIF(revenue, 0) AS estimated_gross_margin_pct,
    previous_profit,
    100.0 * (estimated_gross_profit - previous_profit)
        / NULLIF(previous_profit, 0) AS profit_growth_pct
FROM WithPrevious
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 39 - CATEGORY MONTHLY GROWTH
==============================================================================*/

WITH Monthly AS
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
    FROM Monthly
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
    LAG sees the previous observed category-month, not necessarily the previous
    calendar month. Fill missing periods when calendar continuity is required.
*/


/*==============================================================================
    SOLUTION 40 - MONTHLY PRODUCT LEADER
==============================================================================*/

WITH ProductMonth AS
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
    FROM ProductMonth
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
    SOLUTION 41 - CUSTOMER'S LARGEST ORDER
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
    customer_id,
    order_id,
    order_date,
    order_value
FROM Ranked
WHERE rn = 1
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 42 - CUMULATIVE CUSTOMER VALUE
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
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_customer_revenue
FROM OrderValues
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 43 - CUSTOMER ORDER VELOCITY
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
    customer_id,
    completed_orders,
    first_completed_order_date,
    latest_completed_order_date,
    active_span_days,
    1.0 * active_span_days
        / NULLIF(completed_orders - 1, 0) AS average_days_between_orders
FROM Metrics
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 44 - ORDER GAP STATISTICS
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
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM training.orders
    WHERE order_status = 'Completed'
),
Gaps AS
(
    SELECT
        customer_id,
        DATEDIFF(DAY, previous_order_date, order_date) AS gap_days
    FROM History
    WHERE previous_order_date IS NOT NULL
)
SELECT
    customer_id,
    COUNT(*) AS completed_orders_with_previous,
    AVG(1.0 * gap_days) AS average_gap_days,
    MIN(gap_days) AS minimum_gap_days,
    MAX(gap_days) AS maximum_gap_days
FROM Gaps
GROUP BY customer_id
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 45 - DATA QUALITY: ORPHANS
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


/*==============================================================================
    SOLUTION 46 - DATA QUALITY: INVALID VALUES
==============================================================================*/

SELECT *
FROM training.order_items
WHERE quantity <= 0;
GO

SELECT *
FROM training.order_items
WHERE unit_price < 0;
GO

SELECT *
FROM training.products
WHERE stock_quantity < 0;
GO

SELECT *
FROM training.products
WHERE price < 0;
GO

SELECT *
FROM training.products
WHERE cost < 0;
GO

SELECT
    email,
    COUNT(*) AS occurrences
FROM training.customers
GROUP BY email
HAVING COUNT(*) > 1;
GO


/*==============================================================================
    SOLUTION 47 - REVENUE RECONCILIATION
==============================================================================*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
OrderRevenue AS
(
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
),
OrderTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM OrderRevenue
),
CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
CustomerTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM CustomerRevenue
)
SELECT
    d.revenue AS transaction_revenue,
    ot.revenue AS order_level_revenue,
    ct.revenue AS customer_level_revenue,
    CASE
        WHEN d.revenue = ot.revenue
         AND ot.revenue = ct.revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM Direct AS d
CROSS JOIN OrderTotal AS ot
CROSS JOIN CustomerTotal AS ct;
GO


/*==============================================================================
    SOLUTION 48 - PRODUCT REVENUE RECONCILIATION
==============================================================================*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
Products AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
),
ProductTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM Products
)
SELECT
    d.revenue AS direct_revenue,
    p.revenue AS product_level_revenue,
    d.revenue - p.revenue AS difference,
    CASE
        WHEN d.revenue = p.revenue THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM Direct AS d
CROSS JOIN ProductTotal AS p;
GO


/*==============================================================================
    SOLUTION 49 - TRANSACTION BASICS
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;

ROLLBACK TRANSACTION;
GO

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO


/*==============================================================================
    SOLUTION 50 - ROBUST TRANSACTION TEMPLATE
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity + 1
    WHERE product_id = 1;

    -- Training-safe success path.
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 51 - ATOMIC INVENTORY
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @ProductId INT = 1,
        @Quantity INT = 2,
        @RowsUpdated INT;

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @Quantity;

    SET @RowsUpdated = @@ROWCOUNT;

    IF @RowsUpdated = 0
        THROW 50001, 'Insufficient stock or product not found.', 1;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = @ProductId;

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 52 - FAILED INVENTORY REQUEST
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @ProductId INT = 1,
        @Quantity INT = 1000000;

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50002, 'Insufficient stock or product not found.', 1;

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO

SELECT
    @@TRANCOUNT AS transaction_count,
    XACT_STATE() AS transaction_state;
GO


/*==============================================================================
    SOLUTION 53 - SAVEPOINT
==============================================================================*/

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

SAVE TRANSACTION AfterProductOne;

UPDATE training.products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 2;

ROLLBACK TRANSACTION AfterProductOne;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;

/*
    At this point:

    Product 1's change remains part of the open transaction.
    Product 2's change has been rolled back to the savepoint.
*/

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    SOLUTION 54 - SAFE ORDER CREATION
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @CustomerId INT = 1,
        @ProductId INT = 1,
        @Quantity INT = 2,
        @UnitPrice DECIMAL(10, 2),
        @OrderId INT;

    IF @Quantity <= 0
        THROW 50010, 'Quantity must be greater than zero.', 1;

    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM training.customers
        WHERE customer_id = @CustomerId
          AND is_active = 1
    )
        THROW 50011, 'Active customer not found.', 1;

    SELECT
        @UnitPrice = price
    FROM training.products
    WHERE product_id = @ProductId
      AND is_active = 1;

    IF @UnitPrice IS NULL
        THROW 50012, 'Active product not found.', 1;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND is_active = 1
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50013, 'Insufficient inventory.', 1;

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

    SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO training.order_items
    (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES
    (
        @OrderId,
        @ProductId,
        @Quantity,
        @UnitPrice
    );

    SELECT *
    FROM training.orders
    WHERE order_id = @OrderId;

    SELECT *
    FROM training.order_items
    WHERE order_id = @OrderId;

    -- Production success path would normally COMMIT.
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 55 - ACID
==============================================================================*/

/*
    A. Atomicity
       All checkout operations succeed or fail as one unit.

    B. Durability
       Successfully committed work survives recovery.

    C. Consistency
       Constraints and business logic help move the database between
       valid states.

    D. Isolation
       Concurrent transactions interact according to defined visibility
       and concurrency rules.
*/


/*==============================================================================
    SOLUTION 56 - DIRTY READ REASONING
==============================================================================*/

/*
    A dirty read occurs when one transaction reads another transaction's
    uncommitted modification.

    READ UNCOMMITTED permits dirty reads.

    The writer can later ROLLBACK, meaning a report may have used a value
    that never became committed business state.
*/


/*==============================================================================
    SOLUTION 57 - NON-REPEATABLE READ
==============================================================================*/

/*
    Conceptual example:

    SESSION A:

        BEGIN TRANSACTION;

        SELECT stock_quantity
        FROM training.products
        WHERE product_id = 1;

        -- Session B modifies and commits here.

        SELECT stock_quantity
        FROM training.products
        WHERE product_id = 1;

        COMMIT;


    SESSION B:

        UPDATE training.products
        SET stock_quantity = stock_quantity + 1
        WHERE product_id = 1;

    Session A can observe two different committed values depending on
    isolation/database configuration.
*/


/*==============================================================================
    SOLUTION 58 - PHANTOM READ
==============================================================================*/

/*
    Session A executes:

        SELECT *
        FROM training.orders
        WHERE customer_id = 1;

    Session B inserts and commits another order for customer 1.

    Session A executes the same predicate again and sees an additional
    qualifying row.

    That new matching row is a phantom.
*/


/*==============================================================================
    SOLUTION 59 - DEADLOCK
==============================================================================*/

/*
    A can hold Product 1 while waiting for Product 2.

    B can hold Product 2 while waiting for Product 1.

    This creates a circular wait.

    SQL Server detects the deadlock and chooses a victim, rolling that
    transaction back.

    Accessing products in a consistent order can reduce this risk.

    Appropriate application operations should often support controlled
    deadlock retries.
*/


/*==============================================================================
    SOLUTION 60 - SHORT TRANSACTIONS
==============================================================================*/

/*
    Human interaction, external API calls, or long sleeps can make transaction
    duration unpredictable.

    While the transaction remains open it may:

        hold locks
        block other sessions
        consume transaction-log resources
        increase contention
        increase deadlock opportunities

    Keep database transactions as short as business correctness permits.
*/


/*==============================================================================
    SOLUTION 61 - INSPECT INDEXES
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key
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
    SOLUTION 62 - INSPECT INDEX COLUMNS
==============================================================================*/

SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
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
    SOLUTION 63 - SARGABILITY
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
    SOLUTION 64 - COMPOSITE INDEX DESIGN
==============================================================================*/

/*
    One reasonable candidate:

        CREATE INDEX IX_orders_customer_date
        ON training.orders
        (
            customer_id,
            order_date DESC
        )
        INCLUDE
        (
            order_status
        );

    customer_id:
        equality predicate and therefore a natural leading key.

    order_date:
        range predicate and requested ordering.

    order_status:
        output column that does not need to be a search key for this query.

    Depending on the existing clustered key, order_id may already be carried
    in the nonclustered index. Inspect the actual schema/indexes first.

    This is a candidate, not proof of the optimal production design.
*/


/*==============================================================================
    SOLUTION 65 - COVERING INDEX
==============================================================================*/

/*
    For an appropriate query, an index:

        (customer_id, order_date)
        INCLUDE(order_status)

    can provide:

        search by customer
        date range/order support
        order_status output

    without needing another structure for that included column.

    Trade-offs:

        larger index
        more storage
        more memory/cache use
        more INSERT/UPDATE/DELETE maintenance
*/


/*==============================================================================
    SOLUTION 66 - KEY LOOKUP
==============================================================================*/

/*
    A Key Lookup retrieves columns missing from a chosen nonclustered index
    from the clustered-index row.

    A few lookups can be efficient.

    Thousands or millions of repeated lookups can become expensive.

    A carefully designed covering index can sometimes remove the lookup,
    at the cost of a larger index and more write maintenance.
*/


/*==============================================================================
    SOLUTION 67 - STATISTICS IO
==============================================================================*/

SET STATISTICS IO ON;
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
GO

/*
    Logical reads represent database pages accessed from SQL Server's
    buffer cache during execution.
*/


/*==============================================================================
    SOLUTION 68 - STATISTICS TIME
==============================================================================*/

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

SET STATISTICS TIME OFF;
GO

/*
    One timing is weak evidence because results can vary with:

        cache state
        compilation
        concurrent workload
        CPU scheduling
        I/O state

    Benchmark repeatedly under representative conditions.
*/


/*==============================================================================
    SOLUTION 69 - ACTUAL EXECUTION PLAN REVIEW
==============================================================================*/

SELECT
    o.customer_id,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY o.customer_id;
GO

/*
    Enable Actual Execution Plan and inspect:

        access operators
        selected indexes
        join algorithm
        estimated rows
        actual rows
        number of executions
        scans/seeks
        sorts
        lookups
        warnings

    The exact plan is environment/data/index dependent.
*/


/*==============================================================================
    SOLUTION 70 - ESTIMATES
==============================================================================*/

/*
    The optimizer chooses the plan using estimates.

    If it estimates 10 rows but receives 1,000,000, decisions made for a tiny
    input can become inappropriate.

    Consequences can include:

        unsuitable join algorithms
        too-small memory grants and spills
        excessive repeated lookups
        inappropriate access strategies
        poor join ordering
*/


/*==============================================================================
    SOLUTION 71 - MISSING INDEX SUGGESTION
==============================================================================*/

/*
    Before creating the suggested index ask:

    1. Does a similar index already exist?
    2. Can an existing index be modified/consolidated instead?
    3. How important/frequent is the query?
    4. What read reduction does measurement predict/show?
    5. What INSERT/UPDATE/DELETE cost will be added?
    6. How much storage will it consume?
    7. Is the suggested index excessively wide?
    8. Does it benefit the broader workload?
    9. Is the underlying problem actually poor SQL or statistics?
*/


/*==============================================================================
    SOLUTION 72 - OVER-INDEXING
==============================================================================*/

/*
    Every index is another physical structure that SQL Server may have to
    maintain during modifications.

    Costs include:

        extra INSERT work
        extra DELETE work
        extra UPDATE work
        storage
        buffer-cache usage
        transaction-log generation
        backup/maintenance cost
        rebuild/reorganize/statistics work

    More indexes are not automatically better.
*/


/*==============================================================================
    SOLUTION 73 - INDEX USAGE DMV
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
    Usage DMV values reset under events such as SQL Server restarts and other
    database lifecycle conditions. They are not permanent historical telemetry.
*/


/*==============================================================================
    SOLUTION 74 - INDEX PHYSICAL STATS
==============================================================================*/

SELECT
    OBJECT_NAME(ips.object_id) AS table_name,
    i.name AS index_name,
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
    A tiny index can have a high fragmentation percentage while consisting of
    very few pages. The absolute amount of work is then tiny.

    Page count and actual workload matter.
*/


/*==============================================================================
    SOLUTION 75 - PARAMETER SENSITIVITY
==============================================================================*/

/*
    A plan appropriate for two matching rows may use strategies that perform
    poorly for five million matching rows.

    One cached plan can therefore be less suitable for highly skewed parameter
    values.

    OPTION (RECOMPILE) can compile a plan for the current execution:

        SELECT ...
        WHERE customer_id = @CustomerId
        OPTION (RECOMPILE);

    Trade-off:
        additional compilation work and less plan reuse.

    Diagnose with runtime plans/evidence rather than assuming parameter
    sensitivity is the cause of every slow parameterized query.
*/


/*==============================================================================
    SOLUTION 76 - PERFORMANCE BASELINE
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
    Also capture:

        exact query text
        parameters
        returned row count
        Actual Execution Plan
        logical reads
        CPU time
        elapsed time
        estimated vs actual rows
        operator warnings
        relevant existing indexes
        representative workload conditions
*/


/*==============================================================================
    SOLUTION 77 - FIX PERFORMANCE ANTI-PATTERNS
==============================================================================*/

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

/*
    Changes:

    SELECT *:
        replaced by required columns.

    DISTINCT:
        unnecessary because order_id uniquely identifies each order in this
        query and there is no join multiplying rows.

    YEAR(order_date):
        replaced by a SARGable half-open date range.
*/


/*==============================================================================
    SOLUTION 78 - COMPLETE BUSINESS RECONCILIATION
==============================================================================*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
OrderRevenue AS
(
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
),
OrderTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM OrderRevenue
),
CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
CustomerTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM CustomerRevenue
),
ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
),
ProductTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM ProductRevenue
)
SELECT
    d.revenue AS transaction_revenue,
    ot.revenue AS order_revenue,
    ct.revenue AS customer_revenue,
    pt.revenue AS product_revenue,
    CASE
        WHEN d.revenue = ot.revenue
         AND ot.revenue = ct.revenue
         AND ct.revenue = pt.revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM Direct AS d
CROSS JOIN OrderTotal AS ot
CROSS JOIN CustomerTotal AS ct
CROSS JOIN ProductTotal AS pt;
GO


/*==============================================================================
    SOLUTION 79 - ADVANCED CUSTOMER REPORT
==============================================================================*/

WITH OrderMetrics AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)
            AS completed_orders,
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END)
            AS cancelled_orders,
        MIN
        (
            CASE WHEN order_status = 'Completed' THEN order_date END
        ) AS first_completed_order_date,
        MAX
        (
            CASE WHEN order_status = 'Completed' THEN order_date END
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
        COUNT(DISTINCT oi.product_id) AS distinct_products,
        COUNT(DISTINCT p.category) AS distinct_categories
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
        COALESCE(cm.distinct_products, 0) AS distinct_products,
        COALESCE(cm.distinct_categories, 0) AS distinct_categories
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
    s.signup_date,
    s.is_active,
    s.total_orders,
    s.completed_orders,
    s.cancelled_orders,
    s.first_completed_order_date,
    s.latest_completed_order_date,
    s.completed_units,
    s.completed_revenue,
    1.0 * s.completed_revenue
        / NULLIF(s.completed_orders, 0) AS average_order_value,
    s.estimated_gross_profit,
    100.0 * s.estimated_gross_profit
        / NULLIF(s.completed_revenue, 0) AS estimated_gross_margin_pct,
    s.distinct_products,
    s.distinct_categories,
    s.customer_segment,
    pr.revenue_rank
FROM Segmented AS s
LEFT JOIN PositiveRevenueRanking AS pr
    ON pr.customer_id = s.customer_id
ORDER BY
    CASE WHEN pr.revenue_rank IS NULL THEN 1 ELSE 0 END,
    pr.revenue_rank,
    s.customer_id;
GO


/* Validation */
WITH FinalCustomerIds AS
(
    SELECT customer_id
    FROM training.customers
)
SELECT
    (SELECT COUNT(*) FROM training.customers) AS expected_rows,
    (SELECT COUNT(*) FROM FinalCustomerIds) AS report_driver_rows,
    CASE
        WHEN
            (SELECT COUNT(*) FROM training.customers)
            =
            (SELECT COUNT(*) FROM FinalCustomerIds)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS row_count_validation;
GO


/*==============================================================================
    SOLUTION 80 - FINAL SQL MASTERY CAPSTONE

    Separate result sets are intentional because each represents a different
    business grain.
==============================================================================*/


/*------------------------------------------------------------------------------
    RESULT 1 - EXECUTIVE KPIs
------------------------------------------------------------------------------*/

WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END)
            AS completed_orders
    FROM training.orders
    GROUP BY customer_id
),
CustomerStages AS
(
    SELECT
        COUNT(DISTINCT CASE WHEN completed_orders > 0 THEN customer_id END)
            AS completed_customers,
        COUNT(DISTINCT CASE WHEN completed_orders >= 2 THEN customer_id END)
            AS repeat_customers
    FROM CustomerOrders
),
Sales AS
(
    SELECT
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue,
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
)
SELECT
    (SELECT COUNT(*) FROM training.customers) AS registered_customers,
    cs.completed_customers,
    cs.repeat_customers,
    s.completed_orders,
    s.units_sold,
    s.completed_revenue,
    s.estimated_gross_profit,
    100.0 * s.estimated_gross_profit
        / NULLIF(s.completed_revenue, 0) AS estimated_gross_margin_pct,
    1.0 * s.completed_revenue
        / NULLIF(s.completed_orders, 0) AS average_order_value
FROM CustomerStages AS cs
CROSS JOIN Sales AS s;
GO


/*------------------------------------------------------------------------------
    RESULT 2 - MONTHLY PERFORMANCE
------------------------------------------------------------------------------*/

WITH Monthly AS
(
    SELECT
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
            AS revenue_month,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        COUNT(DISTINCT o.customer_id) AS purchasing_customers,
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
        DATEFROMPARTS(YEAR(o.order_date), MONTH(o.order_date), 1)
),
Previous AS
(
    SELECT
        *,
        LAG(revenue) OVER
        (
            ORDER BY revenue_month
        ) AS previous_revenue
    FROM Monthly
)
SELECT
    revenue_month,
    completed_orders,
    purchasing_customers,
    revenue,
    estimated_gross_profit,
    previous_revenue,
    100.0 * (revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) AS revenue_growth_pct,
    SUM(revenue) OVER
    (
        ORDER BY revenue_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM Previous
ORDER BY revenue_month;
GO


/*------------------------------------------------------------------------------
    RESULT 3 - TOP CUSTOMERS
------------------------------------------------------------------------------*/

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
),
Ranked AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            ORDER BY completed_revenue DESC
        ) AS revenue_rank
    FROM CustomerMetrics
)
SELECT TOP (5)
    r.customer_id,
    c.customer_name,
    r.completed_orders,
    r.completed_revenue,
    r.revenue_rank
FROM Ranked AS r
INNER JOIN training.customers AS c
    ON c.customer_id = r.customer_id
ORDER BY
    r.revenue_rank,
    r.completed_revenue DESC,
    r.customer_id;
GO


/*------------------------------------------------------------------------------
    RESULT 4 - TOP PRODUCTS
------------------------------------------------------------------------------*/

WITH ProductMetrics AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS units_sold,
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
        p.product_name,
        p.category
),
Ranked AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            ORDER BY revenue DESC
        ) AS revenue_rank
    FROM ProductMetrics
)
SELECT TOP (5)
    product_id,
    product_name,
    category,
    units_sold,
    revenue,
    estimated_gross_profit,
    revenue_rank
FROM Ranked
ORDER BY
    revenue_rank,
    revenue DESC,
    product_id;
GO


/*------------------------------------------------------------------------------
    RESULT 5 - FUNNEL
------------------------------------------------------------------------------*/

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
        v.customer_count
    FROM Counts AS c
    CROSS APPLY
    (
        VALUES
            (1, 'Registered', c.registered),
            (2, 'Ordered', c.ordered),
            (3, 'Completed', c.completed),
            (4, 'Repeat', c.repeat_customers)
    ) AS v(stage_number, stage_name, customer_count)
),
Metrics AS
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
        ELSE 100.0 * customer_count
            / NULLIF(previous_stage_count, 0)
    END AS step_conversion_pct
FROM Metrics
ORDER BY stage_number;
GO


/*------------------------------------------------------------------------------
    RESULT 6 - DATA QUALITY STATUS
------------------------------------------------------------------------------*/

WITH Quality AS
(
    SELECT
        (
            SELECT COUNT(*)
            FROM training.orders AS o
            LEFT JOIN training.customers AS c
                ON c.customer_id = o.customer_id
            WHERE c.customer_id IS NULL
        ) AS orphan_orders,

        (
            SELECT COUNT(*)
            FROM training.order_items AS oi
            LEFT JOIN training.orders AS o
                ON o.order_id = oi.order_id
            LEFT JOIN training.products AS p
                ON p.product_id = oi.product_id
            WHERE o.order_id IS NULL
               OR p.product_id IS NULL
        ) AS orphan_order_items,

        (
            SELECT COUNT(*)
            FROM training.order_items
            WHERE quantity <= 0
        ) AS invalid_quantities,

        (
            SELECT COUNT(*)
            FROM training.products
            WHERE stock_quantity < 0
        ) AS negative_stock,

        (
            SELECT COUNT(*)
            FROM
            (
                SELECT email
                FROM training.customers
                GROUP BY email
                HAVING COUNT(*) > 1
            ) AS x
        ) AS duplicate_emails
)
SELECT
    orphan_orders,
    orphan_order_items,
    invalid_quantities,
    negative_stock,
    duplicate_emails,
    CASE
        WHEN orphan_orders = 0
         AND orphan_order_items = 0
         AND invalid_quantities = 0
         AND negative_stock = 0
         AND duplicate_emails = 0
            THEN 'PASS'
        ELSE 'FAIL'
    END AS data_quality_status
FROM Quality;
GO


/*------------------------------------------------------------------------------
    RESULT 7 - REVENUE RECONCILIATION
------------------------------------------------------------------------------*/

WITH Direct AS
(
    SELECT
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
),
OrderRevenue AS
(
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_id
),
OrderTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM OrderRevenue
),
CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
CustomerTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM CustomerRevenue
),
ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    INNER JOIN training.order_items AS oi
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
),
ProductTotal AS
(
    SELECT COALESCE(SUM(revenue), 0) AS revenue
    FROM ProductRevenue
)
SELECT
    d.revenue AS transaction_revenue,
    ot.revenue AS order_level_revenue,
    ct.revenue AS customer_level_revenue,
    pt.revenue AS product_level_revenue,
    CASE
        WHEN d.revenue = ot.revenue
         AND ot.revenue = ct.revenue
         AND ct.revenue = pt.revenue
            THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status
FROM Direct AS d
CROSS JOIN OrderTotal AS ot
CROSS JOIN CustomerTotal AS ct
CROSS JOIN ProductTotal AS pt;
GO


/*------------------------------------------------------------------------------
    RESULT 8 - PERFORMANCE REVIEW
------------------------------------------------------------------------------*/

/*
    Important filter columns:

        orders.order_status
        orders.order_date


    Important join columns:

        orders.customer_id
        order_items.order_id
        order_items.product_id


    Possible candidate indexes for larger representative workloads:

        orders(customer_id, order_date)

        orders(order_status, order_date)
            INCLUDE(customer_id)

        order_items(order_id)
            INCLUDE(product_id, quantity, unit_price)

        order_items(product_id)
            INCLUDE(order_id, quantity, unit_price)


    These are candidates only.

    Before creating them:

        inspect existing indexes
        inspect query frequency
        inspect data distribution
        inspect selectivity
        measure logical reads
        inspect Actual Execution Plans
        consider write cost


    SARGability:

    Prefer:

        order_date >= @StartDate
        AND order_date < @EndDate

    over:

        YEAR(order_date) = @Year


    Actual Execution Plan:

        inspect access operators
        joins
        actual vs estimated rows
        number of executions
        lookups
        sorts
        warnings
        spills
        memory grants


    Performance baseline:

        SET STATISTICS IO ON;
        SET STATISTICS TIME ON;

    Record:

        logical reads
        CPU
        elapsed time
        returned rows
        actual plan
        parameters


    Write trade-off:

    Every additional index may increase:

        INSERT cost
        UPDATE cost
        DELETE cost
        storage
        cache usage
        transaction-log work
        maintenance
*/


/*==============================================================================
    FINAL TRANSACTION SAFETY CHECK
==============================================================================*/

SELECT
    @@TRANCOUNT AS transaction_count,
    XACT_STATE() AS transaction_state;
GO

IF XACT_STATE() <> 0
BEGIN
    ROLLBACK TRANSACTION;
END;
GO


/*==============================================================================
    ADVANCED LEVEL COMPLETE

    Practice track completed:

        Beginner
            80 exercises + solutions

        Intermediate
            80 exercises + solutions

        Advanced
            80 exercises + solutions

    Total:
        240 structured practice exercises

    Skills integrated:

        SQL fundamentals
        Aggregations
        Joins
        Result grain
        Data transformation
        Subqueries
        CTEs
        Set operations
        Window functions
        Business analytics
        RFM
        Cohorts
        Retention
        Churn / inactivity
        Funnels
        Profitability
        Data validation
        Metric reconciliation
        Transactions
        ACID
        Concurrency
        Indexes
        Execution plans
        Performance tuning

    Core workflow:

        Define
            ->
        Establish Grain
            ->
        Query
            ->
        Validate
            ->
        Reconcile
            ->
        Measure
            ->
        Optimize
            ->
        Measure Again

==============================================================================*/