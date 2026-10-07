/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: retention_churn.sql
Database: SQLMastery
Language: T-SQL

Purpose:

Analyze customer retention and churn using
Completed purchasing behavior.

Important:

Retention and churn do NOT have one universal
definition.

This file demonstrates several valid analytical
definitions and states each assumption explicitly.

Definitions Used:

1. Monthly Active Customer
   Customer with at least one Completed order
   in the month.

2. Consecutive-Month Retention
   Customer active this month who was also active
   in the previous calendar month.

3. Cohort Retention
   Customer from an acquisition cohort who returns
   in a later cohort age.

4. Inactivity Churn Proxy
   Customer whose latest Completed purchase is older
   than a chosen inactivity threshold.

Reference Date:
   One day after the latest Completed order date
   in the dataset.

Topics:
- Monthly Active Customers
- Returning Customers
- Consecutive-Month Retention
- Cohort Retention
- Inactive Customers
- Churn Proxy
- Retention / Churn Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. ANALYSIS DATE

   For reproducibility:

   one day after latest Completed order date.
   ========================================================== */

DECLARE @analysis_date DATE;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';

SELECT
    @analysis_date AS analysis_date;
GO


/* ==========================================================
   2. MONTHLY ACTIVE CUSTOMERS

   Definition:

   Customer with at least one Completed order
   during the month.

   DISTINCT prevents multiple orders from counting
   the same customer multiple times.
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
   3. MONTHLY ACTIVE CUSTOMER COUNT
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
    activity_month,

    COUNT(*) AS active_customers

FROM CustomerMonths

GROUP BY activity_month

ORDER BY activity_month;
GO


/* ==========================================================
   4. FIRST ACTIVE MONTH

   Acquisition month based on first Completed order.
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

    MIN(activity_month)
        AS acquisition_month

FROM CustomerMonths

GROUP BY customer_id

ORDER BY acquisition_month;
GO


/* ==========================================================
   5. NEW vs RETURNING MONTHLY CUSTOMERS

   New:
       activity month = acquisition month

   Returning:
       activity month > acquisition month

   Note:
   Returning does not necessarily mean the customer
   was active in the immediately previous month.
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
),
CustomerAcquisition AS
(
    SELECT
        customer_id,

        MIN(activity_month)
            AS acquisition_month

    FROM CustomerMonths

    GROUP BY customer_id
)
SELECT
    cm.activity_month,

    COUNT(
        CASE
            WHEN cm.activity_month =
                 ca.acquisition_month
                THEN cm.customer_id
        END
    ) AS new_customers,

    COUNT(
        CASE
            WHEN cm.activity_month >
                 ca.acquisition_month
                THEN cm.customer_id
        END
    ) AS returning_customers,

    COUNT(*) AS active_customers

FROM CustomerMonths AS cm

INNER JOIN CustomerAcquisition AS ca
    ON cm.customer_id = ca.customer_id

GROUP BY cm.activity_month

ORDER BY cm.activity_month;
GO


/* ==========================================================
   6. RETURNING CUSTOMER SHARE

   Returning customers
   /
   active customers
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
),
CustomerAcquisition AS
(
    SELECT
        customer_id,

        MIN(activity_month)
            AS acquisition_month

    FROM CustomerMonths

    GROUP BY customer_id
),
MonthlyMix AS
(
    SELECT
        cm.activity_month,

        COUNT(*) AS active_customers,

        COUNT(
            CASE
                WHEN cm.activity_month >
                     ca.acquisition_month
                    THEN cm.customer_id
            END
        ) AS returning_customers

    FROM CustomerMonths AS cm

    INNER JOIN CustomerAcquisition AS ca
        ON cm.customer_id = ca.customer_id

    GROUP BY cm.activity_month
)
SELECT
    activity_month,
    active_customers,
    returning_customers,

    returning_customers * 100.0
    /
    NULLIF(
        active_customers,
        0
    ) AS returning_customer_share_percent

FROM MonthlyMix

ORDER BY activity_month;
GO


/* ==========================================================
   7. PREVIOUS ACTIVITY MONTH BY CUSTOMER

   LAG shows previous observed active month
   for the same customer.
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

    LAG(activity_month) OVER
    (
        PARTITION BY customer_id
        ORDER BY activity_month
    ) AS previous_activity_month

FROM CustomerMonths

ORDER BY
    customer_id,
    activity_month;
GO


/* ==========================================================
   8. CONSECUTIVE MONTH RETURN FLAG

   Returned from previous calendar month if:

   previous_activity_month
   =
   activity_month - 1 month
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
),
ActivityHistory AS
(
    SELECT
        customer_id,
        activity_month,

        LAG(activity_month) OVER
        (
            PARTITION BY customer_id
            ORDER BY activity_month
        ) AS previous_activity_month

    FROM CustomerMonths
)
SELECT
    customer_id,
    activity_month,
    previous_activity_month,

    CASE
        WHEN DATEDIFF(
            MONTH,
            previous_activity_month,
            activity_month
        ) = 1
            THEN 1
        ELSE 0
    END AS retained_from_previous_month

FROM ActivityHistory

ORDER BY
    customer_id,
    activity_month;
GO


/* ==========================================================
   9. MONTHLY RETAINED CUSTOMERS

   Definition:

   Customers active in current month who were also
   active in immediately previous calendar month.
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
),
ActivityHistory AS
(
    SELECT
        customer_id,
        activity_month,

        LAG(activity_month) OVER
        (
            PARTITION BY customer_id
            ORDER BY activity_month
        ) AS previous_activity_month

    FROM CustomerMonths
)
SELECT
    activity_month,

    COUNT(
        CASE
            WHEN DATEDIFF(
                MONTH,
                previous_activity_month,
                activity_month
            ) = 1
                THEN customer_id
        END
    ) AS retained_customers

FROM ActivityHistory

GROUP BY activity_month

ORDER BY activity_month;
GO


/* ==========================================================
   10. CONSECUTIVE-MONTH RETENTION DENOMINATOR

   Correct denominator:

   customers active in the previous calendar month.

   We need to compare month M to month M-1.
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
),
ObservedMonths AS
(
    SELECT DISTINCT
        activity_month
    FROM CustomerMonths
)
SELECT
    om.activity_month,

    (
        SELECT COUNT(*)
        FROM CustomerMonths AS prev
        WHERE prev.activity_month =
              DATEADD(
                  MONTH,
                  -1,
                  om.activity_month
              )
    ) AS previous_month_customers,

    (
        SELECT COUNT(*)
        FROM CustomerMonths AS current_month

        INNER JOIN CustomerMonths AS previous_month
            ON current_month.customer_id =
               previous_month.customer_id

           AND previous_month.activity_month =
               DATEADD(
                   MONTH,
                   -1,
                   current_month.activity_month
               )

        WHERE current_month.activity_month =
              om.activity_month
    ) AS retained_customers

FROM ObservedMonths AS om

ORDER BY om.activity_month;
GO


/* ==========================================================
   11. MONTHLY RETENTION RATE

   Retention Rate =
   customers from previous month who returned
   this month
   /
   customers active in previous month

   If there is no observed previous-month population,
   denominator can be zero.
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
),
ObservedMonths AS
(
    SELECT DISTINCT
        activity_month
    FROM CustomerMonths
),
MonthlyRetention AS
(
    SELECT
        om.activity_month,

        (
            SELECT COUNT(*)
            FROM CustomerMonths AS prev

            WHERE prev.activity_month =
                DATEADD(
                    MONTH,
                    -1,
                    om.activity_month
                )
        ) AS previous_month_customers,

        (
            SELECT COUNT(*)

            FROM CustomerMonths AS current_month

            INNER JOIN CustomerMonths AS previous_month
                ON current_month.customer_id =
                   previous_month.customer_id

               AND previous_month.activity_month =
                   DATEADD(
                       MONTH,
                       -1,
                       current_month.activity_month
                   )

            WHERE current_month.activity_month =
                  om.activity_month
        ) AS retained_customers

    FROM ObservedMonths AS om
)
SELECT
    activity_month,
    previous_month_customers,
    retained_customers,

    retained_customers * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS retention_rate_percent

FROM MonthlyRetention

ORDER BY activity_month;
GO


/* ==========================================================
   12. MONTHLY CUSTOMER CHURN

   Under this specific consecutive-month definition:

   churned customer =
   active in previous month
   but not active in current month.
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
),
ObservedMonths AS
(
    SELECT DISTINCT
        activity_month
    FROM CustomerMonths
),
MonthlyRetention AS
(
    SELECT
        om.activity_month,

        (
            SELECT COUNT(*)
            FROM CustomerMonths AS prev

            WHERE prev.activity_month =
                DATEADD(
                    MONTH,
                    -1,
                    om.activity_month
                )
        ) AS previous_month_customers,

        (
            SELECT COUNT(*)

            FROM CustomerMonths AS current_month

            INNER JOIN CustomerMonths AS previous_month
                ON current_month.customer_id =
                   previous_month.customer_id

               AND previous_month.activity_month =
                   DATEADD(
                       MONTH,
                       -1,
                       current_month.activity_month
                   )

            WHERE current_month.activity_month =
                  om.activity_month
        ) AS retained_customers

    FROM ObservedMonths AS om
)
SELECT
    activity_month,
    previous_month_customers,
    retained_customers,

    previous_month_customers
    - retained_customers
        AS churned_customers

FROM MonthlyRetention

ORDER BY activity_month;
GO


/* ==========================================================
   13. MONTHLY CHURN RATE

   Under this specific definition:

   Churn Rate =
   previous-month customers who did not return
   /
   previous-month customers
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
),
ObservedMonths AS
(
    SELECT DISTINCT
        activity_month
    FROM CustomerMonths
),
MonthlyRetention AS
(
    SELECT
        om.activity_month,

        (
            SELECT COUNT(*)
            FROM CustomerMonths AS prev

            WHERE prev.activity_month =
                DATEADD(
                    MONTH,
                    -1,
                    om.activity_month
                )
        ) AS previous_month_customers,

        (
            SELECT COUNT(*)

            FROM CustomerMonths AS current_month

            INNER JOIN CustomerMonths AS previous_month
                ON current_month.customer_id =
                   previous_month.customer_id

               AND previous_month.activity_month =
                   DATEADD(
                       MONTH,
                       -1,
                       current_month.activity_month
                   )

            WHERE current_month.activity_month =
                  om.activity_month
        ) AS retained_customers

    FROM ObservedMonths AS om
)
SELECT
    activity_month,

    previous_month_customers,

    retained_customers,

    previous_month_customers
    - retained_customers
        AS churned_customers,

    (
        previous_month_customers
        - retained_customers
    ) * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS churn_rate_percent

FROM MonthlyRetention

ORDER BY activity_month;
GO


/* ==========================================================
   14. RETENTION + CHURN TOGETHER

   Under this simple period definition:

   retention + churn = 100%

   when a valid previous-month denominator exists.
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
),
ObservedMonths AS
(
    SELECT DISTINCT
        activity_month
    FROM CustomerMonths
),
MonthlyRetention AS
(
    SELECT
        om.activity_month,

        (
            SELECT COUNT(*)
            FROM CustomerMonths AS prev

            WHERE prev.activity_month =
                DATEADD(
                    MONTH,
                    -1,
                    om.activity_month
                )
        ) AS previous_month_customers,

        (
            SELECT COUNT(*)

            FROM CustomerMonths AS current_month

            INNER JOIN CustomerMonths AS previous_month
                ON current_month.customer_id =
                   previous_month.customer_id

               AND previous_month.activity_month =
                   DATEADD(
                       MONTH,
                       -1,
                       current_month.activity_month
                   )

            WHERE current_month.activity_month =
                  om.activity_month
        ) AS retained_customers

    FROM ObservedMonths AS om
)
SELECT
    activity_month,
    previous_month_customers,
    retained_customers,

    retained_customers * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS retention_rate_percent,

    (
        previous_month_customers
        - retained_customers
    ) * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS churn_rate_percent

FROM MonthlyRetention

ORDER BY activity_month;
GO


/* ==========================================================
   15. CUSTOMER-LEVEL RETENTION DETAIL

   Show which previous-month customers returned.

   Useful for validating aggregate retention.
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
    prev.activity_month AS previous_month,
    DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) AS evaluation_month,

    prev.customer_id,

    CASE
        WHEN current_month.customer_id IS NOT NULL
            THEN 1
        ELSE 0
    END AS retained_flag

FROM CustomerMonths AS prev

LEFT JOIN CustomerMonths AS current_month
    ON prev.customer_id =
       current_month.customer_id

   AND current_month.activity_month =
       DATEADD(
           MONTH,
           1,
           prev.activity_month
       )

ORDER BY
    prev.activity_month,
    prev.customer_id;
GO


/* ==========================================================
   16. CUSTOMER-LEVEL CHURN FLAG

   Under consecutive-month activity definition.
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
    prev.customer_id,

    prev.activity_month
        AS previous_month,

    DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) AS evaluation_month,

    CASE
        WHEN current_month.customer_id IS NULL
            THEN 1
        ELSE 0
    END AS churned_flag

FROM CustomerMonths AS prev

LEFT JOIN CustomerMonths AS current_month
    ON prev.customer_id =
       current_month.customer_id

   AND current_month.activity_month =
       DATEADD(
           MONTH,
           1,
           prev.activity_month
       )

ORDER BY
    prev.activity_month,
    prev.customer_id;
GO


/* ==========================================================
   17. IMPORTANT RIGHT-CENSORING PROBLEM

   Do NOT automatically label customers from the final
   observed month as churned in the next month.

   The dataset may simply end before we observe whether
   they return.

   First determine the latest observed Completed month.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(MAX(order_date)),
        MONTH(MAX(order_date)),
        1
    ) AS latest_completed_month

FROM training.orders

WHERE order_status = 'Completed';
GO


/* ==========================================================
   18. CHURN FLAGS EXCLUDING UNOBSERVABLE FUTURE PERIOD

   Only evaluate churn if the next calendar month is
   within the observed data period.

   This avoids falsely treating end-of-dataset customers
   as known churners.
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
),
DataBoundary AS
(
    SELECT
        MAX(activity_month)
            AS latest_activity_month

    FROM CustomerMonths
)
SELECT
    prev.customer_id,

    prev.activity_month
        AS previous_month,

    DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) AS evaluation_month,

    CASE
        WHEN current_month.customer_id IS NULL
            THEN 1
        ELSE 0
    END AS churned_flag

FROM CustomerMonths AS prev

CROSS JOIN DataBoundary AS db

LEFT JOIN CustomerMonths AS current_month
    ON prev.customer_id =
       current_month.customer_id

   AND current_month.activity_month =
       DATEADD(
           MONTH,
           1,
           prev.activity_month
       )

WHERE DATEADD(
    MONTH,
    1,
    prev.activity_month
) <= db.latest_activity_month

ORDER BY
    prev.activity_month,
    prev.customer_id;
GO


/* ==========================================================
   19. ROBUST MONTHLY RETENTION WITH DATA BOUNDARY

   Exclude transitions where the next month lies beyond
   the observable Completed-order period.
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
),
DataBoundary AS
(
    SELECT
        MIN(activity_month)
            AS first_activity_month,

        MAX(activity_month)
            AS latest_activity_month

    FROM CustomerMonths
),
RetentionTransitions AS
(
    SELECT
        prev.activity_month
            AS previous_month,

        DATEADD(
            MONTH,
            1,
            prev.activity_month
        ) AS activity_month,

        prev.customer_id,

        CASE
            WHEN current_month.customer_id
                 IS NOT NULL
                THEN 1
            ELSE 0
        END AS retained_flag

    FROM CustomerMonths AS prev

    CROSS JOIN DataBoundary AS db

    LEFT JOIN CustomerMonths AS current_month
        ON prev.customer_id =
           current_month.customer_id

       AND current_month.activity_month =
           DATEADD(
               MONTH,
               1,
               prev.activity_month
           )

    WHERE DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) <= db.latest_activity_month
)
SELECT
    activity_month,

    COUNT(*)
        AS previous_month_customers,

    SUM(retained_flag)
        AS retained_customers,

    COUNT(*)
    - SUM(retained_flag)
        AS churned_customers,

    SUM(retained_flag) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS retention_rate_percent,

    (
        COUNT(*)
        - SUM(retained_flag)
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS churn_rate_percent

FROM RetentionTransitions

GROUP BY activity_month

ORDER BY activity_month;
GO


/* ==========================================================
   20. LATEST COMPLETED ORDER PER CUSTOMER

   Foundation for inactivity-based churn.
   ========================================================== */

SELECT
    customer_id,

    MAX(order_date)
        AS latest_completed_order

FROM training.orders

WHERE order_status = 'Completed'

GROUP BY customer_id

ORDER BY latest_completed_order DESC;
GO


/* ==========================================================
   21. DAYS SINCE LAST PURCHASE

   Reference date is deterministic.
   ========================================================== */

DECLARE @analysis_date DATE;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';


SELECT
    customer_id,

    MAX(order_date)
        AS latest_completed_order,

    DATEDIFF(
        DAY,
        CAST(
            MAX(order_date)
            AS DATE
        ),
        @analysis_date
    ) AS days_since_last_purchase

FROM training.orders

WHERE order_status = 'Completed'

GROUP BY customer_id

ORDER BY days_since_last_purchase DESC;
GO


/* ==========================================================
   22. INACTIVITY CHURN PROXY

   Illustrative business rule:

   Churned / Inactive if no Completed order
   in the last 30 days.

   This is an assumption for training.

   It is NOT a universal churn definition.
   ========================================================== */

DECLARE @analysis_date DATE;
DECLARE @inactivity_threshold_days INT = 30;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';


;WITH CustomerLastPurchase AS
(
    SELECT
        customer_id,

        MAX(order_date)
            AS latest_completed_order

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    clp.latest_completed_order,

    DATEDIFF(
        DAY,
        CAST(
            clp.latest_completed_order
            AS DATE
        ),
        @analysis_date
    ) AS days_since_last_purchase,

    CASE
        WHEN DATEDIFF(
            DAY,
            CAST(
                clp.latest_completed_order
                AS DATE
            ),
            @analysis_date
        ) > @inactivity_threshold_days
            THEN 'Inactive / Churn Risk'

        ELSE 'Active Purchaser'
    END AS customer_status

FROM CustomerLastPurchase AS clp

INNER JOIN training.customers AS c
    ON clp.customer_id = c.customer_id

ORDER BY days_since_last_purchase DESC;
GO


/* ==========================================================
   23. INACTIVITY CHURN COUNT
   ========================================================== */

DECLARE @analysis_date DATE;
DECLARE @inactivity_threshold_days INT = 30;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';


;WITH CustomerLastPurchase AS
(
    SELECT
        customer_id,

        MAX(order_date)
            AS latest_completed_order

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerStatus AS
(
    SELECT
        customer_id,

        DATEDIFF(
            DAY,
            CAST(
                latest_completed_order
                AS DATE
            ),
            @analysis_date
        ) AS days_since_last_purchase

    FROM CustomerLastPurchase
)
SELECT
    COUNT(*) AS purchasing_customers,

    COUNT(
        CASE
            WHEN days_since_last_purchase >
                 @inactivity_threshold_days
                THEN customer_id
        END
    ) AS inactive_customers,

    COUNT(
        CASE
            WHEN days_since_last_purchase <=
                 @inactivity_threshold_days
                THEN customer_id
        END
    ) AS active_purchasers

FROM CustomerStatus;
GO


/* ==========================================================
   24. INACTIVITY CHURN RATE

   Population:
   customers with at least one Completed purchase.

   Customers with no Completed purchase are handled
   separately.
   ========================================================== */

DECLARE @analysis_date DATE;
DECLARE @inactivity_threshold_days INT = 30;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';


;WITH CustomerLastPurchase AS
(
    SELECT
        customer_id,

        MAX(order_date)
            AS latest_completed_order

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
),
CustomerStatus AS
(
    SELECT
        customer_id,

        DATEDIFF(
            DAY,
            CAST(
                latest_completed_order
                AS DATE
            ),
            @analysis_date
        ) AS days_since_last_purchase

    FROM CustomerLastPurchase
)
SELECT
    COUNT(
        CASE
            WHEN days_since_last_purchase >
                 @inactivity_threshold_days
                THEN customer_id
        END
    ) * 100.0
    /
    NULLIF(
        COUNT(*),
        0
    ) AS inactivity_churn_rate_percent

FROM CustomerStatus;
GO


/* ==========================================================
   25. CUSTOMERS WITHOUT COMPLETED PURCHASES

   They are not automatically "churned purchasers."

   They never entered the Completed-purchase population.
   ========================================================== */

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
      AND o.order_status = 'Completed'
)

ORDER BY c.signup_date;
GO


/* ==========================================================
   26. FULL CUSTOMER ACTIVITY STATUS

   Separate:

   - Never Completed Purchase
   - Active Purchaser
   - Inactive / Churn Risk

   This avoids mixing non-buyers with churned buyers.
   ========================================================== */

DECLARE @analysis_date DATE;
DECLARE @inactivity_threshold_days INT = 30;

SELECT
    @analysis_date =
        DATEADD(
            DAY,
            1,
            CAST(
                MAX(order_date)
                AS DATE
            )
        )
FROM training.orders
WHERE order_status = 'Completed';


;WITH CustomerLastPurchase AS
(
    SELECT
        customer_id,

        MAX(order_date)
            AS latest_completed_order

    FROM training.orders

    WHERE order_status = 'Completed'

    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    clp.latest_completed_order,

    CASE
        WHEN clp.customer_id IS NULL
            THEN NULL

        ELSE
            DATEDIFF(
                DAY,
                CAST(
                    clp.latest_completed_order
                    AS DATE
                ),
                @analysis_date
            )
    END AS days_since_last_purchase,

    CASE
        WHEN clp.customer_id IS NULL
            THEN 'Never Completed Purchase'

        WHEN DATEDIFF(
            DAY,
            CAST(
                clp.latest_completed_order
                AS DATE
            ),
            @analysis_date
        ) > @inactivity_threshold_days
            THEN 'Inactive / Churn Risk'

        ELSE 'Active Purchaser'
    END AS activity_status

FROM training.customers AS c

LEFT JOIN CustomerLastPurchase AS clp
    ON c.customer_id = clp.customer_id

ORDER BY
    activity_status,
    c.customer_name;
GO


/* ==========================================================
   27. COHORT RETENTION RECAP

   Another retention definition:

   retention relative to original acquisition cohort.

   This differs from consecutive-month retention.
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
    ) AS cohort_retention_percent

FROM CohortCounts AS cc

INNER JOIN CohortSizes AS cs
    ON cc.cohort_month = cs.cohort_month

ORDER BY
    cc.cohort_month,
    cc.cohort_age;
GO


/* ==========================================================
   28. RETENTION DEFINITION COMPARISON

   These are different questions:

   Returning Customer:
       Has purchased before.

   Consecutive-Month Retention:
       Was active last calendar month and returned
       this calendar month.

   Cohort Retention:
       Member of original cohort who is active at
       a given cohort age.

   Inactivity Churn:
       Has not purchased for X days.

   Do not mix these metrics under one label.
   ========================================================== */


/* ==========================================================
   29. VALIDATE RETENTION FLAGS

   Retained + Churned should equal previous-month
   customers for observable transitions.
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
),
DataBoundary AS
(
    SELECT
        MAX(activity_month)
            AS latest_activity_month

    FROM CustomerMonths
),
Transitions AS
(
    SELECT
        prev.activity_month AS previous_month,

        DATEADD(
            MONTH,
            1,
            prev.activity_month
        ) AS activity_month,

        prev.customer_id,

        CASE
            WHEN current_month.customer_id
                 IS NOT NULL
                THEN 1
            ELSE 0
        END AS retained_flag

    FROM CustomerMonths AS prev

    CROSS JOIN DataBoundary AS db

    LEFT JOIN CustomerMonths AS current_month
        ON prev.customer_id =
           current_month.customer_id

       AND current_month.activity_month =
           DATEADD(
               MONTH,
               1,
               prev.activity_month
           )

    WHERE DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) <= db.latest_activity_month
)
SELECT
    activity_month,

    COUNT(*) AS previous_month_customers,

    SUM(retained_flag)
        AS retained_customers,

    COUNT(*)
    - SUM(retained_flag)
        AS churned_customers,

    SUM(retained_flag)
    +
    (
        COUNT(*)
        - SUM(retained_flag)
    ) AS validation_total

FROM Transitions

GROUP BY activity_month

ORDER BY activity_month;
GO


/* ==========================================================
   30. FINAL RETENTION REPORT

   Consecutive-month retention.

   Only observable transitions are evaluated.

   Grain:
   one evaluation month.
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
),
DataBoundary AS
(
    SELECT
        MAX(activity_month)
            AS latest_activity_month

    FROM CustomerMonths
),
Transitions AS
(
    SELECT
        prev.activity_month
            AS previous_month,

        DATEADD(
            MONTH,
            1,
            prev.activity_month
        ) AS activity_month,

        prev.customer_id,

        CASE
            WHEN current_month.customer_id
                 IS NOT NULL
                THEN 1
            ELSE 0
        END AS retained_flag

    FROM CustomerMonths AS prev

    CROSS JOIN DataBoundary AS db

    LEFT JOIN CustomerMonths AS current_month
        ON prev.customer_id =
           current_month.customer_id

       AND current_month.activity_month =
           DATEADD(
               MONTH,
               1,
               prev.activity_month
           )

    WHERE DATEADD(
        MONTH,
        1,
        prev.activity_month
    ) <= db.latest_activity_month
),
MonthlyRetention AS
(
    SELECT
        activity_month,

        COUNT(*)
            AS previous_month_customers,

        SUM(retained_flag)
            AS retained_customers,

        COUNT(*)
        - SUM(retained_flag)
            AS churned_customers

    FROM Transitions

    GROUP BY activity_month
)
SELECT
    activity_month,
    previous_month_customers,
    retained_customers,
    churned_customers,

    retained_customers * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS retention_rate_percent,

    churned_customers * 100.0
    /
    NULLIF(
        previous_month_customers,
        0
    ) AS churn_rate_percent

FROM MonthlyRetention

ORDER BY activity_month;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   MONTHLY ACTIVE CUSTOMER:

       Customer with at least one Completed order
       during a calendar month.


   RETURNING CUSTOMER:

       Customer active in a month after their
       acquisition month.

       This does NOT require activity in the
       immediately previous month.


   CONSECUTIVE-MONTH RETENTION:

       Customers active in previous month
       who are also active in current month
       /
       customers active in previous month


   CONSECUTIVE-MONTH CHURN:

       Previous-month customers who do not return
       in current month
       /
       previous-month customers


   COHORT RETENTION:

       Cohort customers active at cohort age N
       /
       original cohort size


   INACTIVITY CHURN PROXY:

       Purchasing customer whose latest Completed
       order is older than a defined threshold.


   IMPORTANT:

   1. Churn must have an explicit definition.

   2. Non-purchasers are not automatically churned
      purchasers.

   3. Deduplicate customer-month activity.

   4. Avoid right-censoring:
      do not classify customers as churned when the
      dataset ends before the evaluation period.

   5. Returning-customer share is not the same as
      consecutive-month retention.

   6. Cohort retention is not the same as
      consecutive-month retention.

   7. A 30-day inactivity threshold is only an
      illustrative business rule.

   8. For robust production analysis, use a
      calendar/date dimension and clearly defined
      observation windows.

============================================================
END OF RETENTION & CHURN ANALYSIS
============================================================
*/