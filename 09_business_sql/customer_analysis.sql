/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: customer_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definitions:

Completed Customer:
    Customer with at least one Completed order.

Repeat Customer:
    Customer with at least 2 Completed orders.

Customer Revenue:
    SUM(quantity * unit_price)
    from Completed orders.

Customer AOV:
    Completed Revenue / Completed Orders.

Topics:
- Customer Base
- Customers With / Without Orders
- First Order
- Latest Order
- Frequency
- Revenue
- AOV
- Repeat Customers
- Customer Ranking
- Revenue Share
- Revenue Concentration
- Customer 360
- Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. TOTAL REGISTERED CUSTOMERS

   Grain:
   one row per customer.
   ========================================================== */

SELECT
    COUNT(*) AS registered_customers
FROM training.customers;
GO


/* ==========================================================
   2. ACTIVE CUSTOMER RECORDS

   This uses the customers.is_active flag.

   Important:
   This is not the same as a purchasing customer.
   ========================================================== */

SELECT
    COUNT(*) AS active_customer_records
FROM training.customers
WHERE is_active = 1;
GO


/* ==========================================================
   3. CUSTOMERS WITH ANY ORDER

   An order can have any status.
   ========================================================== */

SELECT
    COUNT(DISTINCT customer_id)
        AS customers_with_orders
FROM training.orders;
GO


/* ==========================================================
   4. CUSTOMERS WITH COMPLETED ORDERS
   ========================================================== */

SELECT
    COUNT(DISTINCT customer_id)
        AS completed_customers
FROM training.orders
WHERE order_status = 'Completed';
GO


/* ==========================================================
   5. CUSTOMERS WITHOUT ORDERS

   Business question:
   Which registered customers have never ordered?

   NOT EXISTS expresses the requirement directly.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.signup_date
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.signup_date;
GO


/* ==========================================================
   6. COUNT CUSTOMERS WITHOUT ORDERS
   ========================================================== */

SELECT
    COUNT(*) AS customers_without_orders
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   7. CUSTOMERS WITHOUT COMPLETED ORDERS

   Includes:

   - Customers with no orders
   - Customers with orders but none Completed
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)
ORDER BY c.customer_name;
GO


/* ==========================================================
   8. CUSTOMER ORDER COUNTS

   Keep every customer.

   COUNT(o.order_id) returns zero for customers
   with no orders.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(o.order_id)
        AS total_orders

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    total_orders DESC,
    c.customer_name;
GO


/* ==========================================================
   9. ORDER STATUS METRICS BY CUSTOMER

   Keep every customer.

   Conditional aggregation gives several metrics
   in one customer-level result.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

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
    ) AS cancelled_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Pending'
                THEN o.order_id
        END
    ) AS pending_orders

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    completed_orders DESC,
    total_orders DESC;
GO


/* ==========================================================
   10. FIRST ORDER DATE

   Any order status.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_order_date

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY first_order_date;
GO


/* ==========================================================
   11. LATEST ORDER DATE
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS latest_order_date

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY latest_order_date DESC;
GO


/* ==========================================================
   12. FIRST COMPLETED ORDER

   Acquisition / purchasing behavior may be defined
   using Completed orders only.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_completed_order_date

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY first_completed_order_date;
GO


/* ==========================================================
   13. LATEST COMPLETED ORDER
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS latest_completed_order_date

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY latest_completed_order_date DESC;
GO


/* ==========================================================
   14. FIRST COMPLETED ORDER ROW

   MIN(date) gives the date.

   ROW_NUMBER lets us retrieve the complete
   first order row.
   ========================================================== */

;WITH RankedCompletedOrders AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS rn

    FROM training.orders AS o

    WHERE o.order_status = 'Completed'
)
SELECT
    c.customer_id,
    c.customer_name,
    rco.order_id AS first_completed_order_id,
    rco.order_date AS first_completed_order_date

FROM RankedCompletedOrders AS rco

INNER JOIN training.customers AS c
    ON rco.customer_id = c.customer_id

WHERE rco.rn = 1

ORDER BY rco.order_date;
GO


/* ==========================================================
   15. LATEST COMPLETED ORDER ROW
   ========================================================== */

;WITH RankedCompletedOrders AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date DESC,
                o.order_id DESC
        ) AS rn

    FROM training.orders AS o

    WHERE o.order_status = 'Completed'
)
SELECT
    c.customer_id,
    c.customer_name,
    rco.order_id AS latest_completed_order_id,
    rco.order_date AS latest_completed_order_date

FROM RankedCompletedOrders AS rco

INNER JOIN training.customers AS c
    ON rco.customer_id = c.customer_id

WHERE rco.rn = 1

ORDER BY rco.order_date DESC;
GO


/* ==========================================================
   16. CUSTOMER COMPLETED REVENUE

   Only customers who generated Completed revenue
   appear here.
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
   17. CUSTOMER REVENUE INCLUDING ZERO

   Keep EVERY customer.

   Conditional aggregation avoids removing customers
   with no Completed purchases.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity * oi.unit_price
                ELSE 0
            END
        ),
        0
    ) AS completed_revenue

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

LEFT JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY completed_revenue DESC;
GO


/* ==========================================================
   18. CUSTOMER AVERAGE ORDER VALUE

   Correct grain:

   first calculate one value per Completed order.

   Then aggregate by customer.
   ========================================================== */

;WITH CompletedOrderValues AS
(
    SELECT
        o.order_id,
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        o.order_id,
        o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    COUNT(cov.order_id)
        AS completed_orders,

    SUM(cov.order_value)
        AS revenue,

    AVG(cov.order_value)
        AS average_order_value

FROM CompletedOrderValues AS cov

INNER JOIN training.customers AS c
    ON cov.customer_id = c.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY revenue DESC;
GO


/* ==========================================================
   19. REPEAT CUSTOMERS

   Chapter definition:

   Repeat Customer =
   at least 2 Completed orders.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(o.order_id)
        AS completed_orders

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

HAVING COUNT(o.order_id) >= 2

ORDER BY completed_orders DESC;
GO


/* ==========================================================
   20. REPEAT CUSTOMER COUNT
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
   21. REPEAT CUSTOMER RATE

   Denominator:
   customers with at least one Completed order.

   Numerator:
   customers with at least two Completed orders.
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
    ) AS repeat_customer_rate_percent

FROM CustomerCompletedOrders;
GO


/* ==========================================================
   22. FIRST VS REPEAT COMPLETED ORDERS

   Sequence only Completed orders.

   This avoids treating a Cancelled order as the
   customer's first purchase.
   ========================================================== */

;WITH CompletedOrderSequence AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS completed_order_number

    FROM training.orders AS o

    WHERE o.order_status = 'Completed'
)
SELECT
    order_id,
    customer_id,
    order_date,
    completed_order_number,

    CASE
        WHEN completed_order_number = 1
            THEN 'First Completed Order'
        ELSE 'Repeat Completed Order'
    END AS order_type

FROM CompletedOrderSequence

ORDER BY
    customer_id,
    completed_order_number;
GO


/* ==========================================================
   23. FIRST VS REPEAT COMPLETED ORDER COUNTS
   ========================================================== */

;WITH CompletedOrderSequence AS
(
    SELECT
        o.order_id,
        o.customer_id,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS completed_order_number

    FROM training.orders AS o

    WHERE o.order_status = 'Completed'
)
SELECT
    CASE
        WHEN completed_order_number = 1
            THEN 'First Completed Order'
        ELSE 'Repeat Completed Order'
    END AS order_type,

    COUNT(*) AS order_count

FROM CompletedOrderSequence

GROUP BY
    CASE
        WHEN completed_order_number = 1
            THEN 'First Completed Order'
        ELSE 'Repeat Completed Order'
    END;
GO


/* ==========================================================
   24. CUSTOMER REVENUE RANKING
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
   25. CUSTOMER REVENUE SHARE
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
   26. CUMULATIVE CUSTOMER REVENUE SHARE

   Revenue concentration analysis.
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

    rc.revenue * 100.0
    /
    NULLIF(
        SUM(rc.revenue) OVER (),
        0
    ) AS revenue_share_percent,

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
   27. CUSTOMER ORDER FREQUENCY RANK

   Completed orders only.
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
    c.customer_id,
    c.customer_name,
    cf.completed_orders,

    DENSE_RANK() OVER
    (
        ORDER BY cf.completed_orders DESC
    ) AS frequency_rank

FROM CustomerFrequency AS cf

INNER JOIN training.customers AS c
    ON cf.customer_id = c.customer_id

ORDER BY
    frequency_rank,
    c.customer_id;
GO


/* ==========================================================
   28. CUSTOMER UNITS PURCHASED
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    SUM(oi.quantity)
        AS units_purchased

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY units_purchased DESC;
GO


/* ==========================================================
   29. DISTINCT PRODUCTS PURCHASED
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(DISTINCT oi.product_id)
        AS distinct_products_purchased

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY distinct_products_purchased DESC;
GO


/* ==========================================================
   30. DISTINCT CATEGORIES PURCHASED
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(DISTINCT p.category)
        AS distinct_categories_purchased

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY distinct_categories_purchased DESC;
GO


/* ==========================================================
   31. CUSTOMER PURCHASE HISTORY

   Completed orders only.

   Grain:
   one Completed order.
   ========================================================== */

;WITH CompletedOrderValues AS
(
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
)
SELECT
    c.customer_id,
    c.customer_name,

    cov.order_id,
    cov.order_date,
    cov.total_units,
    cov.order_value,

    ROW_NUMBER() OVER
    (
        PARTITION BY c.customer_id
        ORDER BY
            cov.order_date,
            cov.order_id
    ) AS completed_order_number

FROM CompletedOrderValues AS cov

INNER JOIN training.customers AS c
    ON cov.customer_id = c.customer_id

ORDER BY
    c.customer_id,
    completed_order_number;
GO


/* ==========================================================
   32. DAYS BETWEEN COMPLETED ORDERS
   ========================================================== */

;WITH CompletedOrders AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        LAG(o.order_date) OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS previous_completed_order_date

    FROM training.orders AS o

    WHERE o.order_status = 'Completed'
)
SELECT
    c.customer_id,
    c.customer_name,

    co.order_id,
    co.order_date,
    co.previous_completed_order_date,

    DATEDIFF(
        DAY,
        co.previous_completed_order_date,
        co.order_date
    ) AS days_since_previous_completed_order

FROM CompletedOrders AS co

INNER JOIN training.customers AS c
    ON co.customer_id = c.customer_id

ORDER BY
    c.customer_id,
    co.order_date,
    co.order_id;
GO


/* ==========================================================
   33. CUSTOMER ACQUISITION MONTH

   Definition:

   Month of first Completed order.

   Only customers with a Completed order appear.
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
    ) AS acquisition_month

FROM FirstCompletedOrder AS fco

INNER JOIN training.customers AS c
    ON fco.customer_id = c.customer_id

ORDER BY acquisition_month;
GO


/* ==========================================================
   34. CUSTOMERS ACQUIRED BY MONTH
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

    COUNT(*)
        AS acquired_customers

FROM CustomerAcquisition

GROUP BY acquisition_month

ORDER BY acquisition_month;
GO


/* ==========================================================
   35. CUSTOMER BASE SUMMARY

   One-row summary of customer populations.
   ========================================================== */

SELECT
    COUNT(*) AS registered_customers,

    COUNT(
        CASE
            WHEN c.is_active = 1
                THEN c.customer_id
        END
    ) AS active_customer_records,

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
            WHEN NOT EXISTS
            (
                SELECT 1
                FROM training.orders AS o
                WHERE o.customer_id = c.customer_id
            )
            THEN c.customer_id
        END
    ) AS customers_without_orders

FROM training.customers AS c;
GO


/* ==========================================================
   36. CUSTOMER 360 - ORDER METRICS

   First layer:
   order-level customer metrics.

   Keep every customer.
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
        ) AS completed_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN o.order_id
            END
        ) AS cancelled_orders,

        MIN(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS first_completed_order_date,

        MAX(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS latest_completed_order_date

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT *
FROM CustomerOrderMetrics
ORDER BY customer_id;
GO


/* ==========================================================
   37. CUSTOMER 360 - SALES METRICS

   Completed transactional metrics.

   Only customers with Completed order items
   appear in this CTE.
   ========================================================== */

;WITH CustomerSales AS
(
    SELECT
        o.customer_id,

        SUM(oi.quantity)
            AS units_purchased,

        COUNT(DISTINCT oi.product_id)
            AS distinct_products,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT *
FROM CustomerSales
ORDER BY revenue DESC;
GO


/* ==========================================================
   38. CUSTOMER 360 REPORT

   One row per registered customer.

   This combines:

   - Customer profile
   - Order behavior
   - Completed activity
   - Revenue
   - Frequency
   - AOV
   - Customer classification
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
        ) AS completed_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN o.order_id
            END
        ) AS cancelled_orders,

        MIN(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS first_completed_order_date,

        MAX(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS latest_completed_order_date

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
CustomerSales AS
(
    SELECT
        o.customer_id,

        SUM(oi.quantity)
            AS units_purchased,

        COUNT(DISTINCT oi.product_id)
            AS distinct_products,

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
    c.email,

    COALESCE(
        c.city,
        N'Unknown'
    ) AS city,

    c.signup_date,
    c.is_active,

    om.total_orders,
    om.completed_orders,
    om.cancelled_orders,

    om.first_completed_order_date,
    om.latest_completed_order_date,

    COALESCE(
        cs.units_purchased,
        0
    ) AS units_purchased,

    COALESCE(
        cs.distinct_products,
        0
    ) AS distinct_products,

    COALESCE(
        cs.revenue,
        0
    ) AS revenue,

    COALESCE(
        cs.revenue,
        0
    ) * 1.0
    /
    NULLIF(
        om.completed_orders,
        0
    ) AS average_order_value,

    CASE
        WHEN om.total_orders = 0
            THEN 'No Orders'

        WHEN om.completed_orders = 0
            THEN 'No Completed Orders'

        WHEN om.completed_orders = 1
            THEN 'One-Time Customer'

        WHEN om.completed_orders >= 2
            THEN 'Repeat Customer'
    END AS customer_type

FROM training.customers AS c

INNER JOIN CustomerOrderMetrics AS om
    ON c.customer_id = om.customer_id

LEFT JOIN CustomerSales AS cs
    ON c.customer_id = cs.customer_id

ORDER BY
    revenue DESC,
    c.customer_id;
GO


/* ==========================================================
   39. CUSTOMER 360 + REVENUE RANK

   Rank purchasing customers while keeping zero-revenue
   customers at the bottom.

   We create the metrics first, then rank them.
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,
        c.customer_name,

        COUNT(DISTINCT
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_orders,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity
                    ELSE 0
                END
            ),
            0
        ) AS units_purchased,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity * oi.unit_price
                    ELSE 0
                END
            ),
            0
        ) AS revenue

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    LEFT JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    completed_orders,
    units_purchased,
    revenue,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM CustomerMetrics

ORDER BY
    revenue_rank,
    customer_id;
GO


/*
Note:

Zero-revenue customers tie together in the ranking.

Depending on the report, you might instead rank only
customers with revenue > 0.
*/


/* ==========================================================
   40. CUSTOMER VALUE SEGMENT

   Example business segmentation.

   These thresholds are illustrative only.

   Real thresholds should be defined by the business.
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        c.customer_id,
        c.customer_name,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity * oi.unit_price
                    ELSE 0
                END
            ),
            0
        ) AS revenue

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    LEFT JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
)
SELECT
    customer_id,
    customer_name,
    revenue,

    CASE
        WHEN revenue >= 20000
            THEN 'High Value'

        WHEN revenue >= 5000
            THEN 'Medium Value'

        WHEN revenue > 0
            THEN 'Low Value'

        ELSE 'No Revenue'
    END AS value_segment

FROM CustomerRevenue

ORDER BY revenue DESC;
GO


/* ==========================================================
   41. CUSTOMER REVENUE RECONCILIATION

   Sum of customer revenue should equal total
   Completed revenue.
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
        AS customer_revenue_total
FROM CustomerRevenue;
GO


/* ==========================================================
   42. DIRECT REVENUE FOR RECONCILIATION
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
   43. VALIDATE COMPLETED CUSTOMER COUNT

   Compare:

   customers in the customer revenue result

   vs

   distinct customers with Completed orders.
   ========================================================== */

;WITH RevenueCustomers AS
(
    SELECT
        o.customer_id

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    (
        SELECT COUNT(*)
        FROM RevenueCustomers
    ) AS customers_with_completed_sales,

    (
        SELECT COUNT(DISTINCT customer_id)
        FROM training.orders
        WHERE order_status = 'Completed'
    ) AS customers_with_completed_orders;
GO


/*
These counts could differ if a Completed order
exists without any order_items.

That would be a useful data-quality signal.
*/


/* ==========================================================
   44. CUSTOMERS WITH COMPLETED ORDERS BUT NO ITEMS

   Data-quality check.
   ========================================================== */

SELECT
    o.order_id,
    o.customer_id,
    o.order_date

FROM training.orders AS o

WHERE o.order_status = 'Completed'

AND NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.order_id = o.order_id
);
GO


/* ==========================================================
   45. REGISTERED -> ORDER -> COMPLETED CUSTOMER COUNTS

   Useful preview for funnel analysis.
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
    ) AS completed_customers

FROM training.customers AS c;
GO


/* ==========================================================
   46. FINAL CUSTOMER ANALYTICS REPORT

   One row per customer with:

   - Profile
   - Order counts
   - Completed behavior
   - First / latest Completed order
   - Units
   - Products
   - Revenue
   - AOV
   - Revenue share
   - Revenue rank
   - Customer type

   Grain:
   one registered customer.
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
        ) AS completed_orders,

        COUNT(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN o.order_id
            END
        ) AS cancelled_orders,

        MIN(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS first_completed_order_date,

        MAX(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_date
            END
        ) AS latest_completed_order_date

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
),
CustomerSales AS
(
    SELECT
        o.customer_id,

        SUM(oi.quantity)
            AS units_purchased,

        COUNT(DISTINCT oi.product_id)
            AS distinct_products,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
),
CustomerBase AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        c.email,

        COALESCE(
            c.city,
            N'Unknown'
        ) AS city,

        c.signup_date,
        c.is_active,

        om.total_orders,
        om.completed_orders,
        om.cancelled_orders,

        om.first_completed_order_date,
        om.latest_completed_order_date,

        COALESCE(
            cs.units_purchased,
            0
        ) AS units_purchased,

        COALESCE(
            cs.distinct_products,
            0
        ) AS distinct_products,

        COALESCE(
            cs.revenue,
            0
        ) AS revenue

    FROM training.customers AS c

    INNER JOIN CustomerOrderMetrics AS om
        ON c.customer_id = om.customer_id

    LEFT JOIN CustomerSales AS cs
        ON c.customer_id = cs.customer_id
)
SELECT
    customer_id,
    customer_name,
    email,
    city,
    signup_date,
    is_active,

    total_orders,
    completed_orders,
    cancelled_orders,

    first_completed_order_date,
    latest_completed_order_date,

    units_purchased,
    distinct_products,
    revenue,

    revenue * 1.0
    /
    NULLIF(
        completed_orders,
        0
    ) AS average_order_value,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    CASE
        WHEN total_orders = 0
            THEN 'No Orders'

        WHEN completed_orders = 0
            THEN 'No Completed Orders'

        WHEN completed_orders = 1
            THEN 'One-Time Customer'

        ELSE 'Repeat Customer'
    END AS customer_type

FROM CustomerBase

ORDER BY
    revenue DESC,
    customer_id;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   REGISTERED CUSTOMER:

       One row in training.customers.


   CUSTOMER WITH ORDER:

       Customer with at least one order
       regardless of status.


   COMPLETED CUSTOMER:

       Customer with at least one Completed order.


   REPEAT CUSTOMER:

       Customer with at least 2 Completed orders.


   CUSTOMER REVENUE:

       SUM(quantity * unit_price)
       from Completed orders.


   CUSTOMER AOV:

       Completed customer revenue
       /
       Completed order count.


   FIRST COMPLETED ORDER:

       Earliest Completed order.


   LATEST COMPLETED ORDER:

       Most recent Completed order.


   REVENUE SHARE:

       Customer revenue
       /
       Total Completed revenue
       * 100


   IMPORTANT:

   - customers.is_active is not purchase activity.
   - Rank Completed purchasing behavior separately
     from account status.
   - Sequence Completed orders when measuring
     purchase/repeat behavior.
   - Keep customers without orders when building
     full Customer 360 datasets.
   - Validate customer revenue against total revenue.

============================================================
END OF CUSTOMER ANALYSIS
============================================================
*/