/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: funnel_analysis.sql
Database: SQLMastery
Language: T-SQL

Customer Funnel:

Stage 1:
Registered Customer

Stage 2:
Placed Any Order

Stage 3:
Completed Customer

Stage 4:
Repeat Customer

Definitions:

Registered Customer:
    Exists in training.customers.

Ordered Customer:
    Has at least one order of any status.

Completed Customer:
    Has at least one Completed order.

Repeat Customer:
    Has at least 2 Completed orders.

Important:

The stages are intentionally defined so that:

Registered
    >= Ordered
        >= Completed
            >= Repeat

Topics:
- Funnel Stages
- Stage Counts
- Conversion Rates
- Drop-off Rates
- Customer-Level Funnel Flags
- Funnel by City
- Funnel by Signup Month
- Funnel Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. REGISTERED CUSTOMERS

   Stage 1.
   ========================================================== */

SELECT
    COUNT(*) AS registered_customers
FROM training.customers;
GO


/* ==========================================================
   2. CUSTOMERS WHO PLACED ANY ORDER

   Stage 2.

   Any order status qualifies.
   ========================================================== */

SELECT
    COUNT(DISTINCT customer_id)
        AS customers_with_orders

FROM training.orders;
GO


/* ==========================================================
   3. COMPLETED CUSTOMERS

   Stage 3.
   ========================================================== */

SELECT
    COUNT(DISTINCT customer_id)
        AS completed_customers

FROM training.orders

WHERE order_status = 'Completed';
GO


/* ==========================================================
   4. REPEAT CUSTOMERS

   Stage 4.

   Repeat Customer =
   at least 2 Completed orders.
   ========================================================== */

;WITH CustomerCompletedOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS completed_orders

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    COUNT(*) AS repeat_customers

FROM CustomerCompletedOrders

WHERE completed_orders >= 2;
GO


/* ==========================================================
   5. BASIC FUNNEL COUNTS

   Return all stage counts in one row.
   ========================================================== */

SELECT
    COUNT(*) AS registered_customers,

    COUNT(
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
            )
            THEN c.customer_id
        END
    ) AS customers_with_orders,

    COUNT(
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
                  AND o.order_status = 'Completed'
            )
            THEN c.customer_id
        END
    ) AS completed_customers,

    COUNT(
        CASE
            WHEN
            (
                SELECT COUNT(*)
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
                  AND o.order_status = 'Completed'
            ) >= 2
            THEN c.customer_id
        END
    ) AS repeat_customers

FROM training.customers AS c;
GO


/* ==========================================================
   6. CUSTOMER FUNNEL FLAGS

   One row per registered customer.

   Each flag indicates whether the customer
   reached that stage.
   ========================================================== */

;WITH CustomerOrderMetrics AS
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    1 AS registered_flag,

    CASE
        WHEN com.total_orders >= 1
            THEN 1
        ELSE 0
    END AS ordered_flag,

    CASE
        WHEN com.completed_orders >= 1
            THEN 1
        ELSE 0
    END AS completed_flag,

    CASE
        WHEN com.completed_orders >= 2
            THEN 1
        ELSE 0
    END AS repeat_flag

FROM CustomerOrderMetrics AS com

INNER JOIN training.customers AS c
    ON com.customer_id = c.customer_id

ORDER BY c.customer_id;
GO


/* ==========================================================
   7. FUNNEL COUNTS FROM FLAGS

   This structure makes the nested nature of
   the stages easy to validate.
   ========================================================== */

;WITH CustomerFunnel AS
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT
    COUNT(*) AS registered_customers,

    SUM(
        CASE
            WHEN total_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS customers_with_orders,

    SUM(
        CASE
            WHEN completed_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS completed_customers,

    SUM(
        CASE
            WHEN completed_orders >= 2
                THEN 1
            ELSE 0
        END
    ) AS repeat_customers

FROM CustomerFunnel;
GO


/* ==========================================================
   8. VERTICAL FUNNEL

   Better shape for charts and BI tools.
   ========================================================== */

;WITH CustomerFunnel AS
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerFunnel
)
SELECT
    1 AS stage_number,
    'Registered' AS stage_name,
    registered_customers AS customer_count
FROM FunnelCounts

UNION ALL

SELECT
    2,
    'Placed Order',
    ordered_customers
FROM FunnelCounts

UNION ALL

SELECT
    3,
    'Completed Order',
    completed_customers
FROM FunnelCounts

UNION ALL

SELECT
    4,
    'Repeat Customer',
    repeat_customers
FROM FunnelCounts

ORDER BY stage_number;
GO


/* ==========================================================
   9. REGISTERED -> ORDER CONVERSION

   Customers with orders
   /
   registered customers
   ========================================================== */

;WITH Metrics AS
(
    SELECT
        COUNT(*) AS registered_customers,

        COUNT(
            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM training.orders AS o
                    WHERE o.customer_id = c.customer_id
                )
                THEN c.customer_id
            END
        ) AS ordered_customers

    FROM training.customers AS c
)
SELECT
    registered_customers,
    ordered_customers,

    ordered_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS registered_to_order_rate_percent

FROM Metrics;
GO


/* ==========================================================
   10. ORDER -> COMPLETED CONVERSION

   Completed customers
   /
   customers who placed any order
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelMetrics AS
(
    SELECT
        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers

    FROM CustomerMetrics
)
SELECT
    ordered_customers,
    completed_customers,

    completed_customers * 100.0
    /
    NULLIF(
        ordered_customers,
        0
    ) AS order_to_completed_rate_percent

FROM FunnelMetrics;
GO


/* ==========================================================
   11. COMPLETED -> REPEAT CONVERSION

   Repeat customers
   /
   customers with a Completed order
   ========================================================== */

;WITH CustomerFrequency AS
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

    COUNT(
        CASE
            WHEN completed_orders >= 2
                THEN customer_id
        END
    ) AS repeat_customers,

    COUNT(
        CASE
            WHEN completed_orders >= 2
                THEN customer_id
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS completed_to_repeat_rate_percent

FROM CustomerFrequency;
GO


/* ==========================================================
   12. END-TO-END COMPLETED CONVERSION

   Completed customers
   /
   registered customers
   ========================================================== */

;WITH CustomerFunnel AS
(
    SELECT
        c.customer_id,

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
    COUNT(*) AS registered_customers,

    SUM(
        CASE
            WHEN completed_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS completed_customers,

    SUM(
        CASE
            WHEN completed_orders >= 1
                THEN 1
            ELSE 0
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS registered_to_completed_rate_percent

FROM CustomerFunnel;
GO


/* ==========================================================
   13. END-TO-END REPEAT CONVERSION
   ========================================================== */

;WITH CustomerFunnel AS
(
    SELECT
        c.customer_id,

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
    COUNT(*) AS registered_customers,

    SUM(
        CASE
            WHEN completed_orders >= 2
                THEN 1
            ELSE 0
        END
    ) AS repeat_customers,

    SUM(
        CASE
            WHEN completed_orders >= 2
                THEN 1
            ELSE 0
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS registered_to_repeat_rate_percent

FROM CustomerFunnel;
GO


/* ==========================================================
   14. STAGE DROP-OFF COUNTS
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics
)
SELECT
    registered_customers,

    ordered_customers,

    registered_customers
    - ordered_customers
        AS registration_to_order_dropoff,

    completed_customers,

    ordered_customers
    - completed_customers
        AS order_to_completed_dropoff,

    repeat_customers,

    completed_customers
    - repeat_customers
        AS completed_to_repeat_dropoff

FROM FunnelCounts;
GO


/* ==========================================================
   15. STAGE DROP-OFF RATES

   Drop-off is relative to the prior stage.
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics
)
SELECT
    (
        registered_customers
        - ordered_customers
    ) * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS registration_to_order_dropoff_percent,

    (
        ordered_customers
        - completed_customers
    ) * 100.0
    /
    NULLIF(
        ordered_customers,
        0
    ) AS order_to_completed_dropoff_percent,

    (
        completed_customers
        - repeat_customers
    ) * 100.0
    /
    NULLIF(
        completed_customers,
        0
    ) AS completed_to_repeat_dropoff_percent

FROM FunnelCounts;
GO


/* ==========================================================
   16. COMPLETE FUNNEL KPI TABLE
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics
)
SELECT
    registered_customers,
    ordered_customers,
    completed_customers,
    repeat_customers,

    ordered_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS registered_to_order_percent,

    completed_customers * 100.0
    /
    NULLIF(
        ordered_customers,
        0
    ) AS order_to_completed_percent,

    repeat_customers * 100.0
    /
    NULLIF(
        completed_customers,
        0
    ) AS completed_to_repeat_percent,

    completed_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS overall_completed_conversion_percent,

    repeat_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS overall_repeat_conversion_percent

FROM FunnelCounts;
GO


/* ==========================================================
   17. CUSTOMER FUNNEL STAGE

   Assign each customer their highest achieved stage.

   Priority:

   Repeat
   Completed
   Ordered
   Registered
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
    cm.completed_orders,

    CASE
        WHEN cm.completed_orders >= 2
            THEN 'Repeat Customer'

        WHEN cm.completed_orders >= 1
            THEN 'Completed Customer'

        WHEN cm.total_orders >= 1
            THEN 'Ordered Customer'

        ELSE 'Registered Only'
    END AS highest_funnel_stage

FROM CustomerMetrics AS cm

INNER JOIN training.customers AS c
    ON cm.customer_id = c.customer_id

ORDER BY
    cm.completed_orders DESC,
    cm.total_orders DESC,
    c.customer_id;
GO


/* ==========================================================
   18. DISTRIBUTION BY HIGHEST FUNNEL STAGE

   These segments are mutually exclusive.
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
CustomerStages AS
(
    SELECT
        customer_id,

        CASE
            WHEN completed_orders >= 2
                THEN 'Repeat Customer'

            WHEN completed_orders >= 1
                THEN 'Completed Customer'

            WHEN total_orders >= 1
                THEN 'Ordered Customer'

            ELSE 'Registered Only'
        END AS highest_funnel_stage

    FROM CustomerMetrics
)
SELECT
    highest_funnel_stage,

    COUNT(*) AS customer_count

FROM CustomerStages

GROUP BY highest_funnel_stage

ORDER BY customer_count DESC;
GO


/* ==========================================================
   19. FUNNEL BY CITY

   Compare funnel behavior geographically.

   NULL city becomes Unknown.
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,
        c.city,

        COUNT(o.order_id)
            AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,
        c.city
)
SELECT
    COALESCE(
        city,
        N'Unknown'
    ) AS city,

    COUNT(*) AS registered_customers,

    SUM(
        CASE
            WHEN total_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS ordered_customers,

    SUM(
        CASE
            WHEN completed_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS completed_customers,

    SUM(
        CASE
            WHEN completed_orders >= 2
                THEN 1
            ELSE 0
        END
    ) AS repeat_customers

FROM CustomerMetrics

GROUP BY
    COALESCE(
        city,
        N'Unknown'
    )

ORDER BY registered_customers DESC;
GO


/* ==========================================================
   20. FUNNEL CONVERSION BY CITY
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        COALESCE(
            c.city,
            N'Unknown'
        ) AS city,

        COUNT(o.order_id)
            AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,
        COALESCE(
            c.city,
            N'Unknown'
        )
),
CityFunnel AS
(
    SELECT
        city,

        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics

    GROUP BY city
)
SELECT
    city,

    registered_customers,
    ordered_customers,
    completed_customers,
    repeat_customers,

    ordered_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS registration_to_order_percent,

    completed_customers * 100.0
    /
    NULLIF(
        ordered_customers,
        0
    ) AS order_to_completed_percent,

    repeat_customers * 100.0
    /
    NULLIF(
        completed_customers,
        0
    ) AS completed_to_repeat_percent

FROM CityFunnel

ORDER BY registered_customers DESC;
GO


/* ==========================================================
   21. SIGNUP MONTH

   Before funnel by signup cohort, standardize
   the signup month.
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    signup_date,

    DATEFROMPARTS(
        YEAR(signup_date),
        MONTH(signup_date),
        1
    ) AS signup_month

FROM training.customers

ORDER BY signup_month;
GO


/* ==========================================================
   22. FUNNEL BY SIGNUP MONTH
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        DATEFROMPARTS(
            YEAR(c.signup_date),
            MONTH(c.signup_date),
            1
        ) AS signup_month,

        COUNT(o.order_id)
            AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,

        DATEFROMPARTS(
            YEAR(c.signup_date),
            MONTH(c.signup_date),
            1
        )
)
SELECT
    signup_month,

    COUNT(*) AS registered_customers,

    SUM(
        CASE
            WHEN total_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS ordered_customers,

    SUM(
        CASE
            WHEN completed_orders >= 1
                THEN 1
            ELSE 0
        END
    ) AS completed_customers,

    SUM(
        CASE
            WHEN completed_orders >= 2
                THEN 1
            ELSE 0
        END
    ) AS repeat_customers

FROM CustomerMetrics

GROUP BY signup_month

ORDER BY signup_month;
GO


/* ==========================================================
   23. FUNNEL CONVERSION BY SIGNUP MONTH
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        DATEFROMPARTS(
            YEAR(c.signup_date),
            MONTH(c.signup_date),
            1
        ) AS signup_month,

        COUNT(o.order_id)
            AS total_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,

        DATEFROMPARTS(
            YEAR(c.signup_date),
            MONTH(c.signup_date),
            1
        )
),
SignupFunnel AS
(
    SELECT
        signup_month,

        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics

    GROUP BY signup_month
)
SELECT
    signup_month,

    registered_customers,
    ordered_customers,
    completed_customers,
    repeat_customers,

    ordered_customers * 100.0
    /
    NULLIF(
        registered_customers,
        0
    ) AS registration_to_order_percent,

    completed_customers * 100.0
    /
    NULLIF(
        ordered_customers,
        0
    ) AS order_to_completed_percent,

    repeat_customers * 100.0
    /
    NULLIF(
        completed_customers,
        0
    ) AS completed_to_repeat_percent

FROM SignupFunnel

ORDER BY signup_month;
GO


/* ==========================================================
   24. TIME TO FIRST ORDER

   For customers with any order.

   Days between:

   signup_date
   and
   first order date.
   ========================================================== */

;WITH FirstOrder AS
(
    SELECT
        customer_id,

        MIN(order_date)
            AS first_order_date

    FROM training.orders

    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    c.signup_date,
    fo.first_order_date,

    DATEDIFF(
        DAY,
        c.signup_date,
        CAST(
            fo.first_order_date
            AS DATE
        )
    ) AS days_to_first_order

FROM FirstOrder AS fo

INNER JOIN training.customers AS c
    ON fo.customer_id = c.customer_id

ORDER BY days_to_first_order;
GO


/* ==========================================================
   25. TIME TO FIRST COMPLETED ORDER

   More directly tied to purchasing conversion.
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
    c.signup_date,

    fco.first_completed_order_date,

    DATEDIFF(
        DAY,
        c.signup_date,
        CAST(
            fco.first_completed_order_date
            AS DATE
        )
    ) AS days_to_first_completed_order

FROM FirstCompletedOrder AS fco

INNER JOIN training.customers AS c
    ON fco.customer_id = c.customer_id

ORDER BY days_to_first_completed_order;
GO


/* ==========================================================
   26. AVERAGE DAYS TO FIRST ORDER
   ========================================================== */

;WITH FirstOrder AS
(
    SELECT
        customer_id,

        MIN(order_date)
            AS first_order_date

    FROM training.orders

    GROUP BY customer_id
),
ConversionTimes AS
(
    SELECT
        c.customer_id,

        DATEDIFF(
            DAY,
            c.signup_date,
            CAST(
                fo.first_order_date
                AS DATE
            )
        ) AS days_to_first_order

    FROM FirstOrder AS fo

    INNER JOIN training.customers AS c
        ON fo.customer_id = c.customer_id
)
SELECT
    AVG(
        1.0 * days_to_first_order
    ) AS average_days_to_first_order

FROM ConversionTimes;
GO


/* ==========================================================
   27. AVERAGE DAYS TO FIRST COMPLETED ORDER
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
ConversionTimes AS
(
    SELECT
        c.customer_id,

        DATEDIFF(
            DAY,
            c.signup_date,
            CAST(
                fco.first_completed_order_date
                AS DATE
            )
        ) AS days_to_first_completed_order

    FROM FirstCompletedOrder AS fco

    INNER JOIN training.customers AS c
        ON fco.customer_id = c.customer_id
)
SELECT
    AVG(
        1.0 * days_to_first_completed_order
    ) AS average_days_to_first_completed_order

FROM ConversionTimes;
GO


/* ==========================================================
   28. FUNNEL INTEGRITY CHECK

   Expected:

   registered >= ordered >= completed >= repeat
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics
)
SELECT
    registered_customers,
    ordered_customers,
    completed_customers,
    repeat_customers,

    CASE
        WHEN registered_customers >= ordered_customers
         AND ordered_customers >= completed_customers
         AND completed_customers >= repeat_customers
            THEN 'PASS'
        ELSE 'FAIL'
    END AS funnel_integrity_check

FROM FunnelCounts;
GO


/* ==========================================================
   29. CUSTOMER FLAG INTEGRITY CHECK

   Search for impossible combinations.

   These queries should return no rows.
   ========================================================== */

;WITH CustomerFunnel AS
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT *
FROM CustomerFunnel

WHERE completed_orders > total_orders

   OR (
        completed_orders >= 2
        AND total_orders < 2
   );
GO


/* ==========================================================
   30. COMPLETED CUSTOMER VALIDATION

   Funnel Completed customer count should match
   direct source calculation.
   ========================================================== */

;WITH FunnelCompleted AS
(
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
)
SELECT
    (
        SELECT COUNT(*)
        FROM FunnelCompleted
    ) AS funnel_completed_customers,

    (
        SELECT
            COUNT(DISTINCT customer_id)

        FROM training.orders

        WHERE order_status = 'Completed'
    ) AS direct_completed_customers;
GO


/* ==========================================================
   31. REPEAT CUSTOMER VALIDATION
   ========================================================== */

;WITH CustomerFrequency AS
(
    SELECT
        customer_id,

        COUNT(*) AS completed_orders

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    COUNT(
        CASE
            WHEN completed_orders >= 2
                THEN customer_id
        END
    ) AS repeat_customers

FROM CustomerFrequency;
GO


/* ==========================================================
   32. FINAL FUNNEL REPORT

   Long-form format suitable for visualization.

   Includes:

   - Stage number
   - Stage name
   - Customer count
   - Previous stage count
   - Stage conversion
   - Overall conversion
   - Drop-off count
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
        ) AS completed_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
FunnelCounts AS
(
    SELECT
        COUNT(*) AS registered_customers,

        SUM(
            CASE
                WHEN total_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS ordered_customers,

        SUM(
            CASE
                WHEN completed_orders >= 1
                    THEN 1
                ELSE 0
            END
        ) AS completed_customers,

        SUM(
            CASE
                WHEN completed_orders >= 2
                    THEN 1
                ELSE 0
            END
        ) AS repeat_customers

    FROM CustomerMetrics
),
FunnelStages AS
(
    SELECT
        1 AS stage_number,
        'Registered' AS stage_name,
        registered_customers AS customer_count
    FROM FunnelCounts

    UNION ALL

    SELECT
        2,
        'Placed Order',
        ordered_customers
    FROM FunnelCounts

    UNION ALL

    SELECT
        3,
        'Completed Order',
        completed_customers
    FROM FunnelCounts

    UNION ALL

    SELECT
        4,
        'Repeat Customer',
        repeat_customers
    FROM FunnelCounts
),
FunnelWithPrevious AS
(
    SELECT
        stage_number,
        stage_name,
        customer_count,

        LAG(customer_count) OVER
        (
            ORDER BY stage_number
        ) AS previous_stage_count,

        FIRST_VALUE(customer_count) OVER
        (
            ORDER BY stage_number

            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND UNBOUNDED FOLLOWING
        ) AS registered_customer_count

    FROM FunnelStages
)
SELECT
    stage_number,
    stage_name,
    customer_count,
    previous_stage_count,

    CASE
        WHEN stage_number = 1
            THEN 100.0

        ELSE
            customer_count * 100.0
            /
            NULLIF(
                previous_stage_count,
                0
            )
    END AS stage_conversion_percent,

    customer_count * 100.0
    /
    NULLIF(
        registered_customer_count,
        0
    ) AS overall_conversion_percent,

    CASE
        WHEN stage_number = 1
            THEN 0

        ELSE
            previous_stage_count
            - customer_count
    END AS stage_dropoff_count

FROM FunnelWithPrevious

ORDER BY stage_number;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   STAGE 1 - REGISTERED:

       Customer exists in training.customers.


   STAGE 2 - PLACED ORDER:

       Customer has at least one order
       of any status.


   STAGE 3 - COMPLETED:

       Customer has at least one Completed order.


   STAGE 4 - REPEAT:

       Customer has at least two Completed orders.


   STAGE CONVERSION RATE:

       Current Stage Customers
       /
       Previous Stage Customers
       * 100


   OVERALL CONVERSION RATE:

       Current Stage Customers
       /
       Registered Customers
       * 100


   DROP-OFF:

       Previous Stage Customers
       -
       Current Stage Customers


   IMPORTANT:

   1. Funnel stages must be explicitly defined.

   2. Stages should be nested if the funnel represents
      sequential progression.

   3. Count customers, not order rows.

   4. Use customer-level metrics before calculating
      funnel stages.

   5. A Repeat Customer is defined here as:
      2+ Completed orders.

   6. Funnel definitions can vary by business.

   7. Always validate:

      Registered
      >= Ordered
      >= Completed
      >= Repeat

   8. Signup-month and city funnels can reveal
      differences in conversion across segments.

============================================================
END OF FUNNEL ANALYSIS
============================================================
*/