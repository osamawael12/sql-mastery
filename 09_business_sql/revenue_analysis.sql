/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: revenue_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definition:

Revenue =
Completed order item value

Formula:
quantity * unit_price

Only orders where:
order_status = 'Completed'

Topics:
- Total Revenue
- Order Revenue
- Average Order Value
- Revenue by Month
- Revenue by Customer
- Revenue by Product
- Revenue by Category
- Revenue Share
- Running Revenue
- Growth
- Revenue Reconciliation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. TOTAL COMPLETED REVENUE

   Grain before aggregation:
   one order-item line.

   Metric:
   SUM(quantity * unit_price)
   ========================================================== */

SELECT
    SUM(
        oi.quantity * oi.unit_price
    ) AS completed_revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   2. COMPLETED UNITS SOLD

   Units are measured using SUM(quantity),
   not COUNT(*).
   ========================================================== */

SELECT
    SUM(oi.quantity) AS completed_units_sold

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   3. COMPLETED ORDER COUNT

   This query starts from orders, so one row
   represents one order.
   ========================================================== */

SELECT
    COUNT(*) AS completed_order_count
FROM training.orders
WHERE order_status = 'Completed';
GO


/* ==========================================================
   4. COMPLETED ORDER COUNT AFTER JOIN

   Once orders are joined to order_items,
   one order can appear multiple times.

   Therefore use DISTINCT.
   ========================================================== */

SELECT
    COUNT(DISTINCT o.order_id)
        AS completed_order_count

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   5. COMPLETED CUSTOMER COUNT
   ========================================================== */

SELECT
    COUNT(DISTINCT o.customer_id)
        AS completed_customer_count

FROM training.orders AS o

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   6. REVENUE KPI SUMMARY

   One-row business summary.
   ========================================================== */

SELECT
    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    COUNT(DISTINCT o.customer_id)
        AS completed_customers,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS completed_revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   7. ORDER VALUE

   Create one row per Completed order.
   ========================================================== */

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,

    SUM(oi.quantity)
        AS total_units,

    SUM(
        oi.quantity * oi.unit_price
    ) AS order_value

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date

ORDER BY order_value DESC;
GO


/* ==========================================================
   8. ORDER VALUE WITH CUSTOMER NAME
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,

    c.customer_id,
    c.customer_name,

    SUM(oi.quantity)
        AS total_units,

    SUM(
        oi.quantity * oi.unit_price
    ) AS order_value

FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name

ORDER BY order_value DESC;
GO


/* ==========================================================
   9. AVERAGE ORDER VALUE

   AOV =
   average of Completed order totals.

   Important:
   Do not average individual order-item lines.
   ========================================================== */

;WITH CompletedOrderValues AS
(
    SELECT
        o.order_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.order_id
)
SELECT
    AVG(order_value) AS average_order_value
FROM CompletedOrderValues;
GO


/* ==========================================================
   10. AOV USING REVENUE / ORDER COUNT

   Alternative definition check:

   Revenue / Completed Orders
   ========================================================== */

SELECT
    SUM(
        oi.quantity * oi.unit_price
    )
    /
    NULLIF(
        COUNT(DISTINCT o.order_id) * 1.0,
        0
    ) AS average_order_value

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   11. AVERAGE UNITS PER COMPLETED ORDER
   ========================================================== */

SELECT
    SUM(oi.quantity) * 1.0
    /
    NULLIF(
        COUNT(DISTINCT o.order_id),
        0
    ) AS average_units_per_order

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   12. REVENUE BY CUSTOMER
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    SUM(oi.quantity)
        AS units_purchased,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY revenue DESC;
GO


/* ==========================================================
   13. CUSTOMER REVENUE SHARE
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue,

    cr.revenue * 100.0
    /
    NULLIF(
        SUM(cr.revenue) OVER (),
        0
    ) AS revenue_share_percent

FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   14. CUSTOMER REVENUE RANK
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue,

    DENSE_RANK() OVER
    (
        ORDER BY cr.revenue DESC
    ) AS revenue_rank

FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY
    revenue_rank,
    c.customer_id;
GO


/* ==========================================================
   15. REVENUE BY PRODUCT
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY revenue DESC;
GO


/* ==========================================================
   16. PRODUCT REVENUE SHARE
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

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

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent

FROM ProductRevenue

ORDER BY revenue DESC;
GO


/* ==========================================================
   17. REVENUE BY CATEGORY
   ========================================================== */

SELECT
    p.category,

    COUNT(DISTINCT p.product_id)
        AS products_sold,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY p.category

ORDER BY revenue DESC;
GO


/* ==========================================================
   18. CATEGORY REVENUE SHARE
   ========================================================== */

;WITH CategoryRevenue AS
(
    SELECT
        p.category,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY p.category
)
SELECT
    category,
    revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent

FROM CategoryRevenue

ORDER BY revenue DESC;
GO


/* ==========================================================
   19. REVENUE BY CITY

   Customers with NULL city appear as Unknown.
   ========================================================== */

SELECT
    COALESCE(
        c.city,
        N'Unknown'
    ) AS city,

    COUNT(DISTINCT c.customer_id)
        AS customers,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    COALESCE(
        c.city,
        N'Unknown'
    )

ORDER BY revenue DESC;
GO


/* ==========================================================
   20. MONTHLY COMPLETED REVENUE

   Month is represented by its first day.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    COUNT(DISTINCT o.customer_id)
        AS completed_customers,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   21. MONTHLY AVERAGE ORDER VALUE
   ========================================================== */

;WITH OrderValues AS
(
    SELECT
        o.order_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.order_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    order_month,
    COUNT(*) AS completed_orders,
    SUM(order_value) AS revenue,
    AVG(order_value) AS average_order_value

FROM OrderValues

GROUP BY order_month

ORDER BY order_month;
GO


/* ==========================================================
   22. CUMULATIVE MONTHLY REVENUE
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    order_month,
    revenue,

    SUM(revenue) OVER
    (
        ORDER BY order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue

FROM MonthlyRevenue

ORDER BY order_month;
GO


/* ==========================================================
   23. MONTH-OVER-MONTH REVENUE

   First calculate monthly revenue.
   Then use LAG.
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
RevenueHistory AS
(
    SELECT
        order_month,
        revenue,

        LAG(revenue) OVER
        (
            ORDER BY order_month
        ) AS previous_revenue

    FROM MonthlyRevenue
)
SELECT
    order_month,
    revenue,
    previous_revenue,

    revenue - previous_revenue
        AS revenue_change,

    (revenue - previous_revenue) * 100.0
    /
    NULLIF(previous_revenue, 0)
        AS growth_percent

FROM RevenueHistory

ORDER BY order_month;
GO


/* ==========================================================
   24. MONTHLY REVENUE SHARE
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    order_month,
    revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent

FROM MonthlyRevenue

ORDER BY order_month;
GO


/* ==========================================================
   25. MONTHLY REVENUE RANK
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    order_month,
    revenue,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM MonthlyRevenue

ORDER BY revenue_rank;
GO


/* ==========================================================
   26. BEST REVENUE MONTH
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
RankedMonths AS
(
    SELECT
        order_month,
        revenue,

        DENSE_RANK() OVER
        (
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM MonthlyRevenue
)
SELECT
    order_month,
    revenue
FROM RankedMonths
WHERE revenue_rank = 1;
GO


/* ==========================================================
   27. HIGHEST VALUE COMPLETED ORDERS
   ========================================================== */

;WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)
SELECT
    ov.order_id,
    ov.order_date,
    c.customer_name,
    ov.order_value,

    DENSE_RANK() OVER
    (
        ORDER BY ov.order_value DESC
    ) AS order_value_rank

FROM OrderValues AS ov

INNER JOIN training.customers AS c
    ON ov.customer_id = c.customer_id

ORDER BY
    order_value_rank,
    ov.order_id;
GO


/* ==========================================================
   28. TOP 3 COMPLETED ORDERS

   ROW_NUMBER gives exactly three rows when available.
   ========================================================== */

;WITH OrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),
RankedOrders AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER
        (
            ORDER BY
                order_value DESC,
                order_id
        ) AS rn

    FROM OrderValues
)
SELECT
    ro.order_id,
    ro.order_date,
    c.customer_name,
    ro.order_value
FROM RankedOrders AS ro

INNER JOIN training.customers AS c
    ON ro.customer_id = c.customer_id

WHERE ro.rn <= 3

ORDER BY ro.rn;
GO


/* ==========================================================
   29. REVENUE BY ORDER STATUS

   This is NOT the default Completed revenue metric.

   It is a diagnostic comparison of value attached
   to each order status.
   ========================================================== */

SELECT
    o.order_status,

    COUNT(DISTINCT o.order_id)
        AS order_count,

    SUM(oi.quantity)
        AS units,

    SUM(
        oi.quantity * oi.unit_price
    ) AS order_item_value

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

GROUP BY o.order_status

ORDER BY order_item_value DESC;
GO


/* ==========================================================
   30. COMPLETION VALUE RATE

   Diagnostic metric:

   Completed item value
   /
   value attached to all order statuses

   This is not necessarily an accounting metric.
   ========================================================== */

SELECT
    SUM(
        CASE
            WHEN o.order_status = 'Completed'
                THEN oi.quantity * oi.unit_price
            ELSE 0
        END
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS completed_value_percent

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
GO


/* ==========================================================
   31. COMPLETED ORDER RATE

   Completed orders / all orders.
   ========================================================== */

SELECT
    SUM(
        CASE
            WHEN order_status = 'Completed'
                THEN 1
            ELSE 0
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS completed_order_rate_percent

FROM training.orders;
GO


/* ==========================================================
   32. CANCELLED ORDER RATE
   ========================================================== */

SELECT
    SUM(
        CASE
            WHEN order_status = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS cancelled_order_rate_percent

FROM training.orders;
GO


/* ==========================================================
   33. ORDER STATUS SUMMARY
   ========================================================== */

SELECT
    order_status,
    COUNT(*) AS order_count,

    COUNT(*) * 100.0
    /
    NULLIF(
        SUM(COUNT(*)) OVER (),
        0
    ) AS order_share_percent

FROM training.orders

GROUP BY order_status

ORDER BY order_count DESC;
GO


/* ==========================================================
   34. DAILY REVENUE

   Useful pattern even though the current dataset
   contains few orders.
   ========================================================== */

SELECT
    CAST(o.order_date AS DATE) AS order_day,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY CAST(o.order_date AS DATE)

ORDER BY order_day;
GO


/* ==========================================================
   35. DAILY CUMULATIVE REVENUE
   ========================================================== */

;WITH DailyRevenue AS
(
    SELECT
        CAST(o.order_date AS DATE)
            AS order_day,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY CAST(o.order_date AS DATE)
)
SELECT
    order_day,
    revenue,

    SUM(revenue) OVER
    (
        ORDER BY order_day

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue

FROM DailyRevenue

ORDER BY order_day;
GO


/* ==========================================================
   36. CUSTOMER REVENUE CONCENTRATION

   Running revenue share after ranking customers
   from highest to lowest revenue.

   Useful for questions such as:

   "How concentrated is revenue among top customers?"
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
),
RankedCustomers AS
(
    SELECT
        customer_id,
        revenue,

        ROW_NUMBER() OVER
        (
            ORDER BY
                revenue DESC,
                customer_id
        ) AS revenue_position

    FROM CustomerRevenue
)
SELECT
    c.customer_id,
    c.customer_name,
    rc.revenue,
    rc.revenue_position,

    SUM(rc.revenue) OVER
    (
        ORDER BY rc.revenue_position

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_customer_revenue,

    SUM(rc.revenue) OVER
    (
        ORDER BY rc.revenue_position

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) * 100.0
    /
    NULLIF(
        SUM(rc.revenue) OVER (),
        0
    ) AS cumulative_revenue_share_percent

FROM RankedCustomers AS rc

INNER JOIN training.customers AS c
    ON rc.customer_id = c.customer_id

ORDER BY rc.revenue_position;
GO


/* ==========================================================
   37. PRODUCT REVENUE CONCENTRATION
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name
),
RankedProducts AS
(
    SELECT
        product_id,
        product_name,
        revenue,

        ROW_NUMBER() OVER
        (
            ORDER BY
                revenue DESC,
                product_id
        ) AS revenue_position

    FROM ProductRevenue
)
SELECT
    product_id,
    product_name,
    revenue,
    revenue_position,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent,

    SUM(revenue) OVER
    (
        ORDER BY revenue_position

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS cumulative_revenue_share_percent

FROM RankedProducts

ORDER BY revenue_position;
GO


/* ==========================================================
   38. REVENUE RECONCILIATION - DIRECT TOTAL

   Save the expected business total mentally or compare
   it against the following reconciliation queries.
   ========================================================== */

SELECT
    SUM(
        oi.quantity * oi.unit_price
    ) AS direct_completed_revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   39. RECONCILIATION - CUSTOMER REVENUE

   Sum of customer-level revenue should equal
   direct Completed revenue.
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    SUM(revenue)
        AS customer_revenue_reconciliation
FROM CustomerRevenue;
GO


/* ==========================================================
   40. RECONCILIATION - PRODUCT REVENUE
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        oi.product_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    SUM(revenue)
        AS product_revenue_reconciliation
FROM ProductRevenue;
GO


/* ==========================================================
   41. RECONCILIATION - MONTHLY REVENUE
   ========================================================== */

;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    SUM(revenue)
        AS monthly_revenue_reconciliation
FROM MonthlyRevenue;
GO


/* ==========================================================
   42. RECONCILIATION IN ONE QUERY

   All metrics should match.
   ========================================================== */

;WITH BaseSales AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        oi.product_id,
        oi.quantity,
        oi.unit_price,

        oi.quantity * oi.unit_price
            AS line_revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'
),
CustomerRevenue AS
(
    SELECT
        customer_id,
        SUM(line_revenue) AS revenue

    FROM BaseSales
    GROUP BY customer_id
),
ProductRevenue AS
(
    SELECT
        product_id,
        SUM(line_revenue) AS revenue

    FROM BaseSales
    GROUP BY product_id
),
MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        SUM(line_revenue) AS revenue

    FROM BaseSales

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    (
        SELECT SUM(line_revenue)
        FROM BaseSales
    ) AS direct_revenue,

    (
        SELECT SUM(revenue)
        FROM CustomerRevenue
    ) AS customer_revenue,

    (
        SELECT SUM(revenue)
        FROM ProductRevenue
    ) AS product_revenue,

    (
        SELECT SUM(revenue)
        FROM MonthlyRevenue
    ) AS monthly_revenue;
GO


/* ==========================================================
   43. REUSABLE COMPLETED SALES BASE

   A common professional pattern is to define the
   business population once, then build metrics from it.

   Grain:
   one Completed order-item line.
   ========================================================== */

;WITH CompletedSales AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        oi.order_item_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,

        oi.quantity * oi.unit_price
            AS line_revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'
)
SELECT
    COUNT(DISTINCT order_id)
        AS completed_orders,

    COUNT(DISTINCT customer_id)
        AS completed_customers,

    SUM(quantity)
        AS units_sold,

    SUM(line_revenue)
        AS completed_revenue

FROM CompletedSales;
GO


/* ==========================================================
   44. FINAL REVENUE DASHBOARD DATASET

   One-row executive revenue summary.

   Metrics:

   - Completed orders
   - Completed customers
   - Units sold
   - Revenue
   - Average order value
   - Average units per order
   - Revenue per purchasing customer
   ========================================================== */

;WITH CompletedSales AS
(
    SELECT
        o.order_id,
        o.customer_id,
        oi.quantity,

        oi.quantity * oi.unit_price
            AS line_revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'
),
Metrics AS
(
    SELECT
        COUNT(DISTINCT order_id)
            AS completed_orders,

        COUNT(DISTINCT customer_id)
            AS completed_customers,

        SUM(quantity)
            AS units_sold,

        SUM(line_revenue)
            AS revenue

    FROM CompletedSales
)
SELECT
    completed_orders,
    completed_customers,
    units_sold,
    revenue,

    revenue * 1.0
    /
    NULLIF(
        completed_orders,
        0
    ) AS average_order_value,

    units_sold * 1.0
    /
    NULLIF(
        completed_orders,
        0
    ) AS average_units_per_order,

    revenue * 1.0
    /
    NULLIF(
        completed_customers,
        0
    ) AS revenue_per_customer

FROM Metrics;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   COMPLETED REVENUE:

       SUM(quantity * unit_price)

       WHERE:
       order_status = 'Completed'


   COMPLETED ORDERS:

       COUNT(DISTINCT order_id)


   COMPLETED CUSTOMERS:

       COUNT(DISTINCT customer_id)


   UNITS SOLD:

       SUM(quantity)


   AVERAGE ORDER VALUE:

       Completed Revenue
       /
       Completed Orders


   REVENUE PER CUSTOMER:

       Completed Revenue
       /
       Completed Customers


   IMPORTANT:

   - Use order_items.unit_price for transaction revenue.
   - Do not count order-item rows as orders.
   - Define status filters consistently.
   - Keep grain explicit.
   - Reconcile revenue across dimensions.
   - Missing months require a calendar structure if
     zero-activity periods must appear.

============================================================
END OF REVENUE ANALYSIS
============================================================
*/