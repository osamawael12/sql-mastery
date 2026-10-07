/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: cohort_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definition:

Customer Cohort =
Month of customer's first Completed order.

Activity Month =
Month in which customer placed a Completed order.

Cohort Age =
Number of months between:

cohort_month
and
activity_month

Month 0:
    acquisition month

Month 1:
    one month after acquisition

Month 2:
    two months after acquisition

Important:

A customer can place multiple orders in one month.

For monthly cohort activity, the customer should
normally count once per activity month.

Topics:
- First Purchase
- Cohort Assignment
- Customer-Month Grain
- Cohort Age
- Cohort Size
- Active Customers
- Retention
- Revenue by Cohort
- Revenue by Cohort Age
- Cohort Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. COMPLETED ORDER BASE

   Cohort analysis in this chapter uses
   Completed purchasing behavior only.
   ========================================================== */

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/* ==========================================================
   2. FIRST COMPLETED ORDER PER CUSTOMER

   Acquisition begins at the customer's
   first Completed order.
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
   3. ASSIGN COHORT MONTH

   Convert first Completed order into
   first day of that month.
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
    ) AS cohort_month

FROM FirstCompletedOrder

ORDER BY cohort_month;
GO


/* ==========================================================
   4. CUSTOMER COHORT WITH NAME
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
    c.customer_id,
    c.customer_name,

    fco.first_completed_order_date,

    DATEFROMPARTS(
        YEAR(fco.first_completed_order_date),
        MONTH(fco.first_completed_order_date),
        1
    ) AS cohort_month

FROM FirstCompletedOrder AS fco

INNER JOIN training.customers AS c
    ON fco.customer_id = c.customer_id

ORDER BY
    cohort_month,
    c.customer_id;
GO


/* ==========================================================
   5. COHORT SIZE

   Number of customers acquired in each cohort month.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
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

FROM CustomerCohorts

GROUP BY cohort_month

ORDER BY cohort_month;
GO


/* ==========================================================
   6. COMPLETED CUSTOMER-MONTH ACTIVITY

   DISTINCT is important.

   One customer with multiple Completed orders in
   the same month should appear once for monthly
   retention analysis.

   Grain:
   one customer + one activity month.
   ========================================================== */

SELECT DISTINCT
    customer_id,

    DATEFROMPARTS(
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


/* ==========================================================
   7. CUSTOMER-MONTH ACTIVITY COUNT

   Verify the deduplicated activity grain.
   ========================================================== */

;WITH CustomerMonths AS
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
)
SELECT
    customer_id,
    COUNT(*) AS active_month_count
FROM CustomerMonths
GROUP BY customer_id
ORDER BY active_month_count DESC;
GO


/* ==========================================================
   8. COHORT + ACTIVITY MONTH

   Attach each customer's cohort to each
   month in which they were active.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
)
SELECT
    cm.customer_id,
    cc.cohort_month,
    cm.activity_month

FROM CustomerMonths AS cm

INNER JOIN CustomerCohorts AS cc
    ON cm.customer_id = cc.customer_id

ORDER BY
    cc.cohort_month,
    cm.customer_id,
    cm.activity_month;
GO


/* ==========================================================
   9. COHORT AGE

   Cohort Age =
   months between cohort and activity month.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
)
SELECT
    cm.customer_id,
    cc.cohort_month,
    cm.activity_month,

    DATEDIFF(
        MONTH,
        cc.cohort_month,
        cm.activity_month
    ) AS cohort_age

FROM CustomerMonths AS cm

INNER JOIN CustomerCohorts AS cc
    ON cm.customer_id = cc.customer_id

ORDER BY
    cc.cohort_month,
    cohort_age,
    cm.customer_id;
GO


/* ==========================================================
   10. VALIDATE COHORT AGE

   Cohort age should never be negative because
   cohort_month is the first Completed activity month.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
CohortActivity AS
(
    SELECT
        cm.customer_id,
        cc.cohort_month,
        cm.activity_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cm.activity_month
        ) AS cohort_age

    FROM CustomerMonths AS cm

    INNER JOIN CustomerCohorts AS cc
        ON cm.customer_id = cc.customer_id
)
SELECT *
FROM CohortActivity
WHERE cohort_age < 0;
GO


/*
Expected:
No rows.
*/


/* ==========================================================
   11. ACTIVE CUSTOMERS BY COHORT AGE

   Grain:
   one cohort + one cohort age.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
CohortActivity AS
(
    SELECT
        cm.customer_id,
        cc.cohort_month,
        cm.activity_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cm.activity_month
        ) AS cohort_age

    FROM CustomerMonths AS cm

    INNER JOIN CustomerCohorts AS cc
        ON cm.customer_id = cc.customer_id
)
SELECT
    cohort_month,
    cohort_age,

    COUNT(DISTINCT customer_id)
        AS active_customers

FROM CohortActivity

GROUP BY
    cohort_month,
    cohort_age

ORDER BY
    cohort_month,
    cohort_age;
GO


/* ==========================================================
   12. COHORT SIZES AS SEPARATE DATASET
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
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

FROM CustomerCohorts

GROUP BY cohort_month

ORDER BY cohort_month;
GO


/* ==========================================================
   13. COHORT RETENTION DATASET

   Retention:

   active customers at cohort age
   /
   original cohort size
   * 100
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CohortSizes AS
(
    SELECT
        cohort_month,

        COUNT(*) AS cohort_size

    FROM CustomerCohorts

    GROUP BY cohort_month
),
CustomerMonths AS
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
CohortActivity AS
(
    SELECT
        cm.customer_id,
        cc.cohort_month,
        cm.activity_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cm.activity_month
        ) AS cohort_age

    FROM CustomerMonths AS cm

    INNER JOIN CustomerCohorts AS cc
        ON cm.customer_id = cc.customer_id
),
CohortCounts AS
(
    SELECT
        cohort_month,
        cohort_age,

        COUNT(DISTINCT customer_id)
            AS active_customers

    FROM CohortActivity

    GROUP BY
        cohort_month,
        cohort_age
)
SELECT
    cc.cohort_month,
    cc.cohort_age,

    cs.cohort_size,
    cc.active_customers,

    cc.active_customers * 100.0
    /
    NULLIF(
        cs.cohort_size,
        0
    ) AS retention_rate_percent

FROM CohortCounts AS cc

INNER JOIN CohortSizes AS cs
    ON cc.cohort_month = cs.cohort_month

ORDER BY
    cc.cohort_month,
    cc.cohort_age;
GO


/* ==========================================================
   14. VALIDATE MONTH 0 RETENTION

   Each customer is active in their acquisition month.

   Therefore cohort age 0 should normally have:

   active_customers = cohort_size

   retention = 100%
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
MonthZero AS
(
    SELECT
        cc.cohort_month,

        COUNT(DISTINCT cc.customer_id)
            AS cohort_size,

        COUNT(
            DISTINCT CASE
                WHEN cm.activity_month = cc.cohort_month
                    THEN cc.customer_id
            END
        ) AS month_zero_active

    FROM CustomerCohorts AS cc

    LEFT JOIN CustomerMonths AS cm
        ON cc.customer_id = cm.customer_id

    GROUP BY cc.cohort_month
)
SELECT
    cohort_month,
    cohort_size,
    month_zero_active,

    month_zero_active * 100.0
    /
    NULLIF(
        cohort_size,
        0
    ) AS month_zero_retention

FROM MonthZero

ORDER BY cohort_month;
GO


/* ==========================================================
   15. COHORT RETENTION - WIDE VIEW

   A simple matrix-style report for:

   Month 0
   Month 1
   Month 2
   Month 3

   With a larger dataset, more periods could be added
   or the long-format dataset could be pivoted elsewhere.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonths AS
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
CohortActivity AS
(
    SELECT
        cm.customer_id,
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cm.activity_month
        ) AS cohort_age

    FROM CustomerMonths AS cm

    INNER JOIN CustomerCohorts AS cc
        ON cm.customer_id = cc.customer_id
),
CohortSummary AS
(
    SELECT
        cohort_month,

        COUNT(
            DISTINCT CASE
                WHEN cohort_age = 0
                    THEN customer_id
            END
        ) AS month_0_customers,

        COUNT(
            DISTINCT CASE
                WHEN cohort_age = 1
                    THEN customer_id
            END
        ) AS month_1_customers,

        COUNT(
            DISTINCT CASE
                WHEN cohort_age = 2
                    THEN customer_id
            END
        ) AS month_2_customers,

        COUNT(
            DISTINCT CASE
                WHEN cohort_age = 3
                    THEN customer_id
            END
        ) AS month_3_customers

    FROM CohortActivity

    GROUP BY cohort_month
)
SELECT
    cohort_month,

    month_0_customers AS cohort_size,

    100.0 AS month_0_retention,

    month_1_customers * 100.0
    /
    NULLIF(
        month_0_customers,
        0
    ) AS month_1_retention,

    month_2_customers * 100.0
    /
    NULLIF(
        month_0_customers,
        0
    ) AS month_2_retention,

    month_3_customers * 100.0
    /
    NULLIF(
        month_0_customers,
        0
    ) AS month_3_retention

FROM CohortSummary

ORDER BY cohort_month;
GO


/* ==========================================================
   16. CUSTOMER COHORT DETAIL

   Useful for validating which customer belongs
   to which cohort.
   ========================================================== */

;WITH CustomerCohorts AS
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
    c.customer_id,
    c.customer_name,

    cc.first_completed_order_date,

    DATEFROMPARTS(
        YEAR(cc.first_completed_order_date),
        MONTH(cc.first_completed_order_date),
        1
    ) AS cohort_month

FROM CustomerCohorts AS cc

INNER JOIN training.customers AS c
    ON cc.customer_id = c.customer_id

ORDER BY
    cohort_month,
    c.customer_id;
GO


/* ==========================================================
   17. COMPLETED REVENUE BY CUSTOMER-MONTH

   Different grain from retention activity:

   one customer + month with revenue.
   ========================================================== */

SELECT
    o.customer_id,

    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS activity_month,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.customer_id,

    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )

ORDER BY
    o.customer_id,
    activity_month;
GO


/* ==========================================================
   18. COHORT REVENUE BY ACTIVITY MONTH
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    cc.cohort_month,
    cmr.activity_month,

    SUM(cmr.revenue)
        AS cohort_revenue

FROM CustomerMonthlyRevenue AS cmr

INNER JOIN CustomerCohorts AS cc
    ON cmr.customer_id = cc.customer_id

GROUP BY
    cc.cohort_month,
    cmr.activity_month

ORDER BY
    cc.cohort_month,
    cmr.activity_month;
GO


/* ==========================================================
   19. COHORT REVENUE BY COHORT AGE
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    cc.cohort_month,

    DATEDIFF(
        MONTH,
        cc.cohort_month,
        cmr.activity_month
    ) AS cohort_age,

    SUM(cmr.revenue)
        AS cohort_revenue

FROM CustomerMonthlyRevenue AS cmr

INNER JOIN CustomerCohorts AS cc
    ON cmr.customer_id = cc.customer_id

GROUP BY
    cc.cohort_month,

    DATEDIFF(
        MONTH,
        cc.cohort_month,
        cmr.activity_month
    )

ORDER BY
    cc.cohort_month,
    cohort_age;
GO


/* ==========================================================
   20. CUMULATIVE COHORT REVENUE

   Running revenue across cohort ages.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
CohortRevenue AS
(
    SELECT
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        ) AS cohort_age,

        SUM(cmr.revenue)
            AS revenue

    FROM CustomerMonthlyRevenue AS cmr

    INNER JOIN CustomerCohorts AS cc
        ON cmr.customer_id = cc.customer_id

    GROUP BY
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        )
)
SELECT
    cohort_month,
    cohort_age,
    revenue,

    SUM(revenue) OVER
    (
        PARTITION BY cohort_month

        ORDER BY cohort_age

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_cohort_revenue

FROM CohortRevenue

ORDER BY
    cohort_month,
    cohort_age;
GO


/* ==========================================================
   21. REVENUE PER ORIGINAL COHORT CUSTOMER

   Useful as a simple cohort monetization measure.

   Formula:

   revenue at cohort age
   /
   original cohort size

   This is NOT the same as revenue per active customer.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CohortSizes AS
(
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size

    FROM CustomerCohorts

    GROUP BY cohort_month
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
CohortRevenue AS
(
    SELECT
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        ) AS cohort_age,

        SUM(cmr.revenue)
            AS revenue

    FROM CustomerMonthlyRevenue AS cmr

    INNER JOIN CustomerCohorts AS cc
        ON cmr.customer_id = cc.customer_id

    GROUP BY
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        )
)
SELECT
    cr.cohort_month,
    cr.cohort_age,

    cs.cohort_size,
    cr.revenue,

    cr.revenue * 1.0
    /
    NULLIF(
        cs.cohort_size,
        0
    ) AS revenue_per_original_customer

FROM CohortRevenue AS cr

INNER JOIN CohortSizes AS cs
    ON cr.cohort_month = cs.cohort_month

ORDER BY
    cr.cohort_month,
    cr.cohort_age;
GO


/* ==========================================================
   22. ACTIVE CUSTOMER REVENUE

   Revenue per active customer at each cohort age.

   Denominator differs from previous query.

   Here:

   revenue / active customers
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
CohortActivity AS
(
    SELECT
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        ) AS cohort_age,

        cmr.customer_id,
        cmr.revenue

    FROM CustomerMonthlyRevenue AS cmr

    INNER JOIN CustomerCohorts AS cc
        ON cmr.customer_id = cc.customer_id
)
SELECT
    cohort_month,
    cohort_age,

    COUNT(DISTINCT customer_id)
        AS active_customers,

    SUM(revenue)
        AS revenue,

    SUM(revenue) * 1.0
    /
    NULLIF(
        COUNT(DISTINCT customer_id),
        0
    ) AS revenue_per_active_customer

FROM CohortActivity

GROUP BY
    cohort_month,
    cohort_age

ORDER BY
    cohort_month,
    cohort_age;
GO


/* ==========================================================
   23. COHORT REVENUE RECONCILIATION

   Total revenue across cohorts should equal
   total Completed revenue.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CohortRevenue AS
(
    SELECT
        cc.cohort_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN CustomerCohorts AS cc
        ON o.customer_id = cc.customer_id

    WHERE o.order_status = 'Completed'

    GROUP BY cc.cohort_month
)
SELECT
    SUM(revenue)
        AS cohort_revenue_total

FROM CohortRevenue;
GO


/* ==========================================================
   24. DIRECT REVENUE CHECK
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
   25. COHORT SIZE RECONCILIATION

   Sum of cohort sizes should equal number of
   customers with at least one Completed order.
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CohortSizes AS
(
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size

    FROM CustomerCohorts

    GROUP BY cohort_month
)
SELECT
    SUM(cohort_size)
        AS customers_across_cohorts

FROM CohortSizes;
GO


/* ==========================================================
   26. DIRECT COMPLETED CUSTOMER COUNT
   ========================================================== */

SELECT
    COUNT(DISTINCT customer_id)
        AS completed_customers

FROM training.orders

WHERE order_status = 'Completed';
GO


/* ==========================================================
   27. DUPLICATE CUSTOMER-MONTH VALIDATION

   CustomerMonths should contain no duplicates.

   This query should return no rows.
   ========================================================== */

;WITH CustomerMonths AS
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
)
SELECT
    customer_id,
    activity_month,
    COUNT(*) AS duplicate_count

FROM CustomerMonths

GROUP BY
    customer_id,
    activity_month

HAVING COUNT(*) > 1;
GO


/* ==========================================================
   28. FINAL LONG-FORM COHORT REPORT

   This is often the most useful source structure
   for BI tools.

   Grain:

   cohort_month
   +
   cohort_age

   Metrics:

   cohort_size
   active_customers
   retention_rate
   revenue
   revenue_per_original_customer
   revenue_per_active_customer
   cumulative_cohort_revenue
   ========================================================== */

;WITH CustomerCohorts AS
(
    SELECT
        customer_id,

        DATEFROMPARTS(
            YEAR(MIN(order_date)),
            MONTH(MIN(order_date)),
            1
        ) AS cohort_month

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CohortSizes AS
(
    SELECT
        cohort_month,

        COUNT(*) AS cohort_size

    FROM CustomerCohorts

    GROUP BY cohort_month
),
CustomerMonthlyRevenue AS
(
    SELECT
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.customer_id,

        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
CohortActivity AS
(
    SELECT
        cc.cohort_month,

        DATEDIFF(
            MONTH,
            cc.cohort_month,
            cmr.activity_month
        ) AS cohort_age,

        cmr.customer_id,
        cmr.revenue

    FROM CustomerMonthlyRevenue AS cmr

    INNER JOIN CustomerCohorts AS cc
        ON cmr.customer_id = cc.customer_id
),
CohortMetrics AS
(
    SELECT
        cohort_month,
        cohort_age,

        COUNT(DISTINCT customer_id)
            AS active_customers,

        SUM(revenue)
            AS revenue

    FROM CohortActivity

    GROUP BY
        cohort_month,
        cohort_age
),
CohortAnalytics AS
(
    SELECT
        cm.cohort_month,
        cm.cohort_age,

        cs.cohort_size,
        cm.active_customers,
        cm.revenue,

        SUM(cm.revenue) OVER
        (
            PARTITION BY cm.cohort_month

            ORDER BY cm.cohort_age

            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_cohort_revenue

    FROM CohortMetrics AS cm

    INNER JOIN CohortSizes AS cs
        ON cm.cohort_month = cs.cohort_month
)
SELECT
    cohort_month,
    cohort_age,

    cohort_size,
    active_customers,

    active_customers * 100.0
    /
    NULLIF(
        cohort_size,
        0
    ) AS retention_rate_percent,

    revenue,

    revenue * 1.0
    /
    NULLIF(
        cohort_size,
        0
    ) AS revenue_per_original_customer,

    revenue * 1.0
    /
    NULLIF(
        active_customers,
        0
    ) AS revenue_per_active_customer,

    cumulative_cohort_revenue

FROM CohortAnalytics

ORDER BY
    cohort_month,
    cohort_age;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   COHORT:

       Month of customer's first Completed order.


   ACTIVITY MONTH:

       Month containing a Completed customer order.


   CUSTOMER-MONTH:

       One customer can appear at most once
       per activity month for retention counting.


   COHORT AGE:

       DATEDIFF(
           MONTH,
           cohort_month,
           activity_month
       )


   COHORT SIZE:

       Number of customers acquired in cohort month.


   ACTIVE CUSTOMERS:

       Distinct cohort customers active at
       a given cohort age.


   RETENTION RATE:

       Active Customers
       /
       Cohort Size
       * 100


   MONTH 0:

       Acquisition month.

       It should normally have 100% retention
       under this definition.


   COHORT REVENUE:

       Completed revenue produced by customers
       belonging to the cohort.


   REVENUE PER ORIGINAL CUSTOMER:

       Cohort-age Revenue
       /
       Original Cohort Size


   REVENUE PER ACTIVE CUSTOMER:

       Cohort-age Revenue
       /
       Active Customers at that age


   IMPORTANT:

   - Deduplicate customer-month activity.
   - Do not count orders as customers.
   - Cohort size must remain fixed across ages.
   - Missing cohort ages do not automatically
     appear as zero rows.
   - The small training dataset may produce
     sparse cohorts.
   - Validate Month 0 retention.
   - Reconcile cohort revenue to total revenue.
   - Reconcile cohort sizes to Completed customers.

============================================================
END OF COHORT ANALYSIS
============================================================
*/