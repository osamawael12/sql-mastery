/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: growth_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definitions:

Revenue:
    Completed order item value.

Order Growth:
    Change in Completed order count over time.

Customer Growth:
    Change in distinct Completed customers over time.

New Customer:
    Customer whose first Completed order occurs
    in the analyzed month.

Repeat Order:
    Completed order after the customer's first
    Completed order.

Important:
The training dataset is small and does not contain
a complete calendar table.

Months with no activity may therefore be absent
from simple GROUP BY results.

Topics:
- Monthly Revenue
- Monthly Orders
- Monthly Customers
- Month-over-Month Growth
- Cumulative Growth
- Customer Acquisition
- New vs Repeat Customers
- New vs Repeat Revenue
- Growth Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. MONTHLY COMPLETED REVENUE

   Grain:
   one month.

   Month represented by the first day.
   ========================================================== */

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

ORDER BY order_month;
GO


/* ==========================================================
   2. MONTHLY COMPLETED ORDERS

   Start from orders so one source row is one order.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,

    COUNT(*) AS completed_orders

FROM training.orders

WHERE order_status = 'Completed'

GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   3. MONTHLY COMPLETED CUSTOMERS
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,

    COUNT(DISTINCT customer_id)
        AS completed_customers

FROM training.orders

WHERE order_status = 'Completed'

GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   4. MONTHLY UNITS SOLD
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    SUM(oi.quantity)
        AS units_sold

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
   5. MONTHLY BUSINESS SUMMARY

   One row per month.

   Metrics:

   - Completed orders
   - Completed customers
   - Units sold
   - Revenue
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
   6. MONTHLY AVERAGE ORDER VALUE

   First establish one row per Completed order.
   ========================================================== */

;WITH CompletedOrderValues AS
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

FROM CompletedOrderValues

GROUP BY order_month

ORDER BY order_month;
GO


/* ==========================================================
   7. PREVIOUS MONTH REVENUE

   LAG retrieves the previous available monthly row.

   Important:
   Without a calendar table, this means previous
   observed month, not necessarily previous
   calendar month.
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

    LAG(revenue) OVER
    (
        ORDER BY order_month
    ) AS previous_revenue

FROM MonthlyRevenue

ORDER BY order_month;
GO


/* ==========================================================
   8. MONTH-OVER-MONTH REVENUE CHANGE
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
        AS revenue_change

FROM RevenueHistory

ORDER BY order_month;
GO


/* ==========================================================
   9. MONTH-OVER-MONTH REVENUE GROWTH %
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
    NULLIF(
        previous_revenue,
        0
    ) AS revenue_growth_percent

FROM RevenueHistory

ORDER BY order_month;
GO


/* ==========================================================
   10. CUMULATIVE REVENUE
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
   11. MONTHLY ORDER GROWTH
   ========================================================== */

;WITH MonthlyOrders AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        COUNT(*) AS completed_orders

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
),
OrderHistory AS
(
    SELECT
        order_month,
        completed_orders,

        LAG(completed_orders) OVER
        (
            ORDER BY order_month
        ) AS previous_orders

    FROM MonthlyOrders
)
SELECT
    order_month,
    completed_orders,
    previous_orders,

    completed_orders - previous_orders
        AS order_change,

    (completed_orders - previous_orders) * 100.0
    /
    NULLIF(
        previous_orders,
        0
    ) AS order_growth_percent

FROM OrderHistory

ORDER BY order_month;
GO


/* ==========================================================
   12. CUMULATIVE COMPLETED ORDERS
   ========================================================== */

;WITH MonthlyOrders AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        COUNT(*) AS completed_orders

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    order_month,
    completed_orders,

    SUM(completed_orders) OVER
    (
        ORDER BY order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_completed_orders

FROM MonthlyOrders

ORDER BY order_month;
GO


/* ==========================================================
   13. MONTHLY CUSTOMER ACTIVITY
   ========================================================== */

;WITH MonthlyCustomers AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        COUNT(DISTINCT customer_id)
            AS completed_customers

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    order_month,
    completed_customers,

    LAG(completed_customers) OVER
    (
        ORDER BY order_month
    ) AS previous_customer_count

FROM MonthlyCustomers

ORDER BY order_month;
GO


/* ==========================================================
   14. MONTHLY CUSTOMER ACTIVITY GROWTH

   This measures monthly active purchasing customers.

   It is NOT customer acquisition growth.
   ========================================================== */

;WITH MonthlyCustomers AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        COUNT(DISTINCT customer_id)
            AS completed_customers

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
),
CustomerHistory AS
(
    SELECT
        order_month,
        completed_customers,

        LAG(completed_customers) OVER
        (
            ORDER BY order_month
        ) AS previous_customers

    FROM MonthlyCustomers
)
SELECT
    order_month,
    completed_customers,
    previous_customers,

    completed_customers - previous_customers
        AS customer_change,

    (completed_customers - previous_customers) * 100.0
    /
    NULLIF(
        previous_customers,
        0
    ) AS customer_growth_percent

FROM CustomerHistory

ORDER BY order_month;
GO


/* ==========================================================
   15. FIRST COMPLETED ORDER PER CUSTOMER

   Foundation for acquisition analysis.
   ========================================================== */

SELECT
    customer_id,
    MIN(order_date)
        AS first_completed_order_date

FROM training.orders

WHERE order_status = 'Completed'

GROUP BY customer_id

ORDER BY first_completed_order_date;
GO


/* ==========================================================
   16. CUSTOMER ACQUISITION MONTH
   ========================================================== */

;WITH FirstCompletedOrder AS
(
    SELECT
        customer_id,

        MIN(order_date)
            AS first_completed_order_date

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    customer_id,
    first_completed_order_date,

    DATEFROMPARTS(
        YEAR(first_completed_order_date),
        MONTH(first_completed_order_date),
        1
    ) AS acquisition_month

FROM FirstCompletedOrder

ORDER BY acquisition_month;
GO


/* ==========================================================
   17. NEW CUSTOMERS BY MONTH

   New Customer:
   customer's first Completed order occurs
   in that month.
   ========================================================== */

;WITH FirstCompletedOrder AS
(
    SELECT
        customer_id,

        MIN(order_date)
            AS first_completed_order_date

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerAcquisition AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(first_completed_order_date),
            MONTH(first_completed_order_date),
            1
        ) AS acquisition_month

    FROM FirstCompletedOrder
)
SELECT
    acquisition_month,

    COUNT(*) AS new_customers

FROM CustomerAcquisition

GROUP BY acquisition_month

ORDER BY acquisition_month;
GO


/* ==========================================================
   18. CUMULATIVE ACQUIRED CUSTOMERS

   Because each customer appears once in acquisition data,
   cumulative new customers represent cumulative acquired
   purchasing customers.
   ========================================================== */

;WITH FirstCompletedOrder AS
(
    SELECT
        customer_id,

        MIN(order_date)
            AS first_completed_order_date

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
MonthlyAcquisition AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(first_completed_order_date),
            MONTH(first_completed_order_date),
            1
        ) AS acquisition_month,

        COUNT(*) AS new_customers

    FROM FirstCompletedOrder

    GROUP BY
        DATEFROMPARTS(
            YEAR(first_completed_order_date),
            MONTH(first_completed_order_date),
            1
        )
)
SELECT
    acquisition_month,
    new_customers,

    SUM(new_customers) OVER
    (
        ORDER BY acquisition_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_acquired_customers

FROM MonthlyAcquisition

ORDER BY acquisition_month;
GO


/* ==========================================================
   19. COMPLETED ORDER SEQUENCE

   Number Completed orders separately for
   each customer.
   ========================================================== */

SELECT
    customer_id,
    order_id,
    order_date,

    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id

        ORDER BY
            order_date,
            order_id
    ) AS completed_order_number

FROM training.orders

WHERE order_status = 'Completed'

ORDER BY
    customer_id,
    completed_order_number;
GO


/* ==========================================================
   20. FIRST vs REPEAT COMPLETED ORDERS
   ========================================================== */

;WITH CompletedOrderSequence AS
(
    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id

            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM training.orders

    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    completed_order_number,

    CASE
        WHEN completed_order_number = 1
            THEN 'First Order'
        ELSE 'Repeat Order'
    END AS order_type

FROM CompletedOrderSequence

ORDER BY
    customer_id,
    completed_order_number;
GO


/* ==========================================================
   21. FIRST vs REPEAT ORDERS BY MONTH
   ========================================================== */

;WITH CompletedOrderSequence AS
(
    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id

            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM training.orders

    WHERE order_status = 'Completed'
)
SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,

    SUM(
        CASE
            WHEN completed_order_number = 1
                THEN 1
            ELSE 0
        END
    ) AS first_orders,

    SUM(
        CASE
            WHEN completed_order_number > 1
                THEN 1
            ELSE 0
        END
    ) AS repeat_orders

FROM CompletedOrderSequence

GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   22. REPEAT ORDER SHARE

   Repeat Completed orders
   /
   all Completed orders
   ========================================================== */

;WITH CompletedOrderSequence AS
(
    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM training.orders

    WHERE order_status = 'Completed'
),
MonthlyOrders AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        COUNT(*) AS completed_orders,

        SUM(
            CASE
                WHEN completed_order_number > 1
                    THEN 1
                ELSE 0
            END
        ) AS repeat_orders

    FROM CompletedOrderSequence

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    order_month,
    completed_orders,
    repeat_orders,

    repeat_orders * 100.0
    /
    NULLIF(
        completed_orders,
        0
    ) AS repeat_order_share_percent

FROM MonthlyOrders

ORDER BY order_month;
GO


/* ==========================================================
   23. ORDER VALUE + ORDER SEQUENCE

   First create one row per Completed order,
   then identify first / repeat behavior.
   ========================================================== */

;WITH CompletedOrderValues AS
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
OrderSequence AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM CompletedOrderValues
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_value,
    completed_order_number,

    CASE
        WHEN completed_order_number = 1
            THEN 'First Order'
        ELSE 'Repeat Order'
    END AS order_type

FROM OrderSequence

ORDER BY
    customer_id,
    completed_order_number;
GO


/* ==========================================================
   24. NEW vs REPEAT REVENUE BY MONTH

   First Order Revenue:
   revenue from each customer's first Completed order.

   Repeat Revenue:
   revenue from later Completed orders.
   ========================================================== */

;WITH CompletedOrderValues AS
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
OrderSequence AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM CompletedOrderValues
)
SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,

    SUM(
        CASE
            WHEN completed_order_number = 1
                THEN order_value
            ELSE 0
        END
    ) AS first_order_revenue,

    SUM(
        CASE
            WHEN completed_order_number > 1
                THEN order_value
            ELSE 0
        END
    ) AS repeat_order_revenue,

    SUM(order_value)
        AS total_revenue

FROM OrderSequence

GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   25. REPEAT REVENUE SHARE
   ========================================================== */

;WITH CompletedOrderValues AS
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
OrderSequence AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS completed_order_number

    FROM CompletedOrderValues
),
MonthlyRevenueMix AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        SUM(order_value)
            AS revenue,

        SUM(
            CASE
                WHEN completed_order_number > 1
                    THEN order_value
                ELSE 0
            END
        ) AS repeat_revenue

    FROM OrderSequence

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    order_month,
    revenue,
    repeat_revenue,

    repeat_revenue * 100.0
    /
    NULLIF(
        revenue,
        0
    ) AS repeat_revenue_share_percent

FROM MonthlyRevenueMix

ORDER BY order_month;
GO


/* ==========================================================
   26. MONTHLY NEW vs EXISTING PURCHASING CUSTOMERS

   Definition:

   New:
       acquisition month = activity month

   Existing:
       activity month > acquisition month

   Each customer should count once per activity month.
   ========================================================== */

;WITH CompletedCustomerMonths AS
(
    SELECT DISTINCT
        customer_id,

        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS activity_month

    FROM training.orders

    WHERE order_status = 'Completed'
),
CustomerAcquisition AS
(
    SELECT
        customer_id,
        MIN(activity_month)
            AS acquisition_month

    FROM CompletedCustomerMonths

    GROUP BY customer_id
)
SELECT
    ccm.activity_month,

    COUNT(
        CASE
            WHEN ccm.activity_month =
                 ca.acquisition_month
                THEN ccm.customer_id
        END
    ) AS new_customers,

    COUNT(
        CASE
            WHEN ccm.activity_month >
                 ca.acquisition_month
                THEN ccm.customer_id
        END
    ) AS existing_customers,

    COUNT(*)
        AS active_purchasing_customers

FROM CompletedCustomerMonths AS ccm

INNER JOIN CustomerAcquisition AS ca
    ON ccm.customer_id = ca.customer_id

GROUP BY ccm.activity_month

ORDER BY ccm.activity_month;
GO


/* ==========================================================
   27. NEW CUSTOMER SHARE
   ========================================================== */

;WITH CompletedCustomerMonths AS
(
    SELECT DISTINCT
        customer_id,

        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS activity_month

    FROM training.orders

    WHERE order_status = 'Completed'
),
CustomerAcquisition AS
(
    SELECT
        customer_id,
        MIN(activity_month)
            AS acquisition_month

    FROM CompletedCustomerMonths

    GROUP BY customer_id
),
MonthlyCustomerMix AS
(
    SELECT
        ccm.activity_month,

        COUNT(*)
            AS active_customers,

        COUNT(
            CASE
                WHEN ccm.activity_month =
                     ca.acquisition_month
                    THEN ccm.customer_id
            END
        ) AS new_customers

    FROM CompletedCustomerMonths AS ccm

    INNER JOIN CustomerAcquisition AS ca
        ON ccm.customer_id = ca.customer_id

    GROUP BY ccm.activity_month
)
SELECT
    activity_month,
    active_customers,
    new_customers,

    new_customers * 100.0
    /
    NULLIF(
        active_customers,
        0
    ) AS new_customer_share_percent

FROM MonthlyCustomerMix

ORDER BY activity_month;
GO


/* ==========================================================
   28. CUMULATIVE REVENUE + ORDERS + ACQUIRED CUSTOMERS

   Combine several growth metrics.
   ========================================================== */

;WITH MonthlyBusiness AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        COUNT(DISTINCT o.order_id)
            AS completed_orders,

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
FirstCompletedOrder AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS acquisition_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
MonthlyAcquisition AS
(
    SELECT
        acquisition_month AS order_month,
        COUNT(*) AS new_customers

    FROM FirstCompletedOrder

    GROUP BY acquisition_month
)
SELECT
    mb.order_month,
    mb.completed_orders,
    mb.revenue,

    COALESCE(
        ma.new_customers,
        0
    ) AS new_customers,

    SUM(mb.completed_orders) OVER
    (
        ORDER BY mb.order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_orders,

    SUM(mb.revenue) OVER
    (
        ORDER BY mb.order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue,

    SUM(
        COALESCE(
            ma.new_customers,
            0
        )
    ) OVER
    (
        ORDER BY mb.order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_acquired_customers

FROM MonthlyBusiness AS mb

LEFT JOIN MonthlyAcquisition AS ma
    ON mb.order_month = ma.order_month

ORDER BY mb.order_month;
GO


/* ==========================================================
   29. FULL MONTHLY GROWTH REPORT

   Includes:

   - Orders
   - Customers
   - Units
   - Revenue
   - Previous revenue
   - Revenue growth
   - Cumulative revenue
   - Revenue rank
   ========================================================== */

;WITH MonthlyBusiness AS
(
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
),
GrowthMetrics AS
(
    SELECT
        order_month,
        completed_orders,
        completed_customers,
        units_sold,
        revenue,

        LAG(revenue) OVER
        (
            ORDER BY order_month
        ) AS previous_revenue,

        LAG(completed_orders) OVER
        (
            ORDER BY order_month
        ) AS previous_orders,

        LAG(completed_customers) OVER
        (
            ORDER BY order_month
        ) AS previous_customers,

        SUM(revenue) OVER
        (
            ORDER BY order_month

            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_revenue,

        DENSE_RANK() OVER
        (
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM MonthlyBusiness
)
SELECT
    order_month,

    completed_orders,

    previous_orders,

    completed_orders - previous_orders
        AS order_change,

    (completed_orders - previous_orders) * 100.0
    /
    NULLIF(
        previous_orders,
        0
    ) AS order_growth_percent,

    completed_customers,

    previous_customers,

    completed_customers - previous_customers
        AS customer_change,

    (completed_customers - previous_customers) * 100.0
    /
    NULLIF(
        previous_customers,
        0
    ) AS customer_activity_growth_percent,

    units_sold,

    revenue,

    previous_revenue,

    revenue - previous_revenue
        AS revenue_change,

    (revenue - previous_revenue) * 100.0
    /
    NULLIF(
        previous_revenue,
        0
    ) AS revenue_growth_percent,

    cumulative_revenue,
    revenue_rank

FROM GrowthMetrics

ORDER BY order_month;
GO


/* ==========================================================
   30. MONTH GAP DIAGNOSTIC

   If the difference is greater than 1,
   there is at least one missing calendar month
   between observed monthly rows.
   ========================================================== */

;WITH ObservedMonths AS
(
    SELECT DISTINCT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month

    FROM training.orders

    WHERE order_status = 'Completed'
),
MonthHistory AS
(
    SELECT
        order_month,

        LAG(order_month) OVER
        (
            ORDER BY order_month
        ) AS previous_observed_month

    FROM ObservedMonths
)
SELECT
    order_month,
    previous_observed_month,

    DATEDIFF(
        MONTH,
        previous_observed_month,
        order_month
    ) AS months_since_previous_observed_month

FROM MonthHistory

ORDER BY order_month;
GO


/* ==========================================================
   31. STRICT MONTH-OVER-MONTH REVENUE

   This version only calculates growth when the previous
   observed row is exactly one calendar month earlier.

   Without a calendar table, this avoids incorrectly calling
   a multi-month gap "month-over-month."
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

        LAG(order_month) OVER
        (
            ORDER BY order_month
        ) AS previous_month,

        LAG(revenue) OVER
        (
            ORDER BY order_month
        ) AS previous_revenue

    FROM MonthlyRevenue
)
SELECT
    order_month,
    revenue,
    previous_month,
    previous_revenue,

    CASE
        WHEN DATEDIFF(
            MONTH,
            previous_month,
            order_month
        ) = 1
        THEN revenue - previous_revenue
    END AS strict_mom_revenue_change,

    CASE
        WHEN DATEDIFF(
            MONTH,
            previous_month,
            order_month
        ) = 1
        THEN
            (revenue - previous_revenue) * 100.0
            /
            NULLIF(
                previous_revenue,
                0
            )
    END AS strict_mom_growth_percent

FROM RevenueHistory

ORDER BY order_month;
GO


/* ==========================================================
   32. GROWTH VALIDATION - REVENUE

   Sum of monthly revenue should equal
   total Completed revenue.
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
        AS monthly_revenue_total

FROM MonthlyRevenue;
GO


/* ==========================================================
   33. DIRECT REVENUE VALIDATION
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
   34. ACQUISITION VALIDATION

   Every customer with a Completed order should
   appear exactly once in FirstCompletedOrder.
   ========================================================== */

;WITH FirstCompletedOrder AS
(
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    (
        SELECT COUNT(*)
        FROM FirstCompletedOrder
    ) AS acquisition_customer_count,

    (
        SELECT COUNT(DISTINCT customer_id)
        FROM training.orders
        WHERE order_status = 'Completed'
    ) AS completed_customer_count;
GO


/* ==========================================================
   35. FIRST + REPEAT REVENUE VALIDATION

   First-order revenue plus repeat-order revenue
   should equal Completed revenue.
   ========================================================== */

;WITH CompletedOrderValues AS
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
OrderSequence AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS order_number

    FROM CompletedOrderValues
)
SELECT
    SUM(
        CASE
            WHEN order_number = 1
                THEN order_value
            ELSE 0
        END
    ) AS first_order_revenue,

    SUM(
        CASE
            WHEN order_number > 1
                THEN order_value
            ELSE 0
        END
    ) AS repeat_order_revenue,

    SUM(order_value)
        AS total_revenue

FROM OrderSequence;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   MONTHLY REVENUE:

       Completed revenue grouped by order month.


   REVENUE GROWTH:

       (Current Revenue - Previous Revenue)
       /
       Previous Revenue
       * 100


   COMPLETED CUSTOMER ACTIVITY:

       Distinct customers with Completed orders
       in the month.


   NEW CUSTOMER:

       Customer whose first Completed order
       occurs in the month.


   FIRST COMPLETED ORDER:

       Customer's earliest Completed order.


   REPEAT COMPLETED ORDER:

       Any Completed order after their first.


   FIRST ORDER REVENUE:

       Revenue generated by customers'
       first Completed orders.


   REPEAT ORDER REVENUE:

       Revenue generated by later
       Completed orders.


   IMPORTANT:

   LAG over observed monthly data means:

       previous observed month

   not automatically:

       previous calendar month


   If zero-activity months must be represented,
   use a calendar/date dimension or generated
   calendar series.

   Before calling a metric "MoM", confirm that
   adjacent rows represent adjacent calendar months.

============================================================
END OF GROWTH ANALYSIS
============================================================
*/