/*
============================================================
SQL MASTERY
08 - WINDOW FUNCTIONS

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - OVER()
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    AVG(price) OVER () AS overall_average_price
FROM training.products;
GO


/* ==========================================================
   EXERCISE 2 - CATEGORY AVERAGE
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,

    AVG(price) OVER
    (
        PARTITION BY category
    ) AS category_average_price

FROM training.products;
GO


/* ==========================================================
   EXERCISE 3 - TOTAL CUSTOMER COUNT
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    COUNT(*) OVER () AS total_customers
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 4 - PRODUCTS IN CATEGORY
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,

    COUNT(*) OVER
    (
        PARTITION BY category
    ) AS products_in_category

FROM training.products;
GO


/* ==========================================================
   EXERCISE 5 - CATEGORY STOCK
   ========================================================== */

SELECT
    product_name,
    category,
    stock_quantity,

    SUM(stock_quantity) OVER
    (
        PARTITION BY category
    ) AS category_stock

FROM training.products;
GO


/* ==========================================================
   EXERCISE 6 - CATEGORY PRICE RANGE
   ========================================================== */

SELECT
    product_name,
    category,
    price,

    MIN(price) OVER
    (
        PARTITION BY category
    ) AS category_min_price,

    MAX(price) OVER
    (
        PARTITION BY category
    ) AS category_max_price

FROM training.products;
GO


/* ==========================================================
   EXERCISE 7 - DIFFERENCE FROM CATEGORY AVERAGE
   ========================================================== */

SELECT
    product_name,
    category,
    price,

    AVG(price) OVER
    (
        PARTITION BY category
    ) AS category_average_price,

    price -
    AVG(price) OVER
    (
        PARTITION BY category
    ) AS difference_from_category_average

FROM training.products

ORDER BY
    category,
    price DESC;
GO


/* ==========================================================
   EXERCISE 8 - ROW_NUMBER
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    ROW_NUMBER() OVER
    (
        ORDER BY
            price DESC,
            product_id ASC
    ) AS price_row_number

FROM training.products

ORDER BY price_row_number;
GO


/* ==========================================================
   EXERCISE 9 - ROW_NUMBER BY CATEGORY
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,

    ROW_NUMBER() OVER
    (
        PARTITION BY category
        ORDER BY
            price DESC,
            product_id ASC
    ) AS category_row_number

FROM training.products

ORDER BY
    category,
    category_row_number;
GO


/* ==========================================================
   EXERCISE 10 - RANK
   ========================================================== */

SELECT
    product_name,
    price,

    RANK() OVER
    (
        ORDER BY price DESC
    ) AS price_rank

FROM training.products

ORDER BY
    price_rank,
    product_name;
GO


/* ==========================================================
   EXERCISE 11 - DENSE_RANK
   ========================================================== */

SELECT
    product_name,
    price,

    DENSE_RANK() OVER
    (
        ORDER BY price DESC
    ) AS dense_price_rank

FROM training.products

ORDER BY
    dense_price_rank,
    product_name;
GO


/* ==========================================================
   EXERCISE 12 - COMPARE RANKING FUNCTIONS
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    ROW_NUMBER() OVER
    (
        ORDER BY
            price DESC,
            product_id
    ) AS row_number_value,

    RANK() OVER
    (
        ORDER BY price DESC
    ) AS rank_value,

    DENSE_RANK() OVER
    (
        ORDER BY price DESC
    ) AS dense_rank_value

FROM training.products

ORDER BY
    price DESC,
    product_id;
GO


/* ==========================================================
   EXERCISE 13 - CATEGORY RANK
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,

    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY price DESC
    ) AS category_price_rank

FROM training.products

ORDER BY
    category,
    category_price_rank,
    product_id;
GO


/* ==========================================================
   EXERCISE 14 - NTILE
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    NTILE(4) OVER
    (
        ORDER BY
            price DESC,
            product_id
    ) AS price_quartile

FROM training.products

ORDER BY
    price_quartile,
    price DESC;
GO


/* ==========================================================
   EXERCISE 15 - TOP 2 PER CATEGORY
   ========================================================== */

;WITH RankedProducts AS
(
    SELECT
        product_id,
        product_name,
        category,
        price,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                price DESC,
                product_id
        ) AS rn

    FROM training.products
)
SELECT
    product_id,
    product_name,
    category,
    price,
    rn
FROM RankedProducts
WHERE rn <= 2
ORDER BY
    category,
    rn;
GO


/* ==========================================================
   EXERCISE 16 - MOST EXPENSIVE PER CATEGORY
   ========================================================== */

;WITH RankedProducts AS
(
    SELECT
        product_id,
        product_name,
        category,
        price,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                price DESC,
                product_id
        ) AS rn

    FROM training.products
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM RankedProducts
WHERE rn = 1
ORDER BY category;
GO


/* ==========================================================
   EXERCISE 17 - LATEST ORDER PER CUSTOMER
   ========================================================== */

;WITH RankedOrders AS
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


/* ==========================================================
   EXERCISE 18 - LATEST ORDER WITH CUSTOMER NAME
   ========================================================== */

;WITH RankedOrders AS
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
)
SELECT
    c.customer_id,
    c.customer_name,
    ro.order_id,
    ro.order_date,
    ro.order_status
FROM RankedOrders AS ro

INNER JOIN training.customers AS c
    ON ro.customer_id = c.customer_id

WHERE ro.rn = 1

ORDER BY c.customer_id;
GO


/* ==========================================================
   EXERCISE 19 - FIRST ORDER PER CUSTOMER
   ========================================================== */

;WITH RankedOrders AS
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


/* ==========================================================
   EXERCISE 20 - ORDER SEQUENCE
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
    ) AS customer_order_number

FROM training.orders

ORDER BY
    customer_id,
    customer_order_number;
GO


/* ==========================================================
   EXERCISE 21 - ORDER TOTALS
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity) AS total_units,
        SUM(quantity * unit_price) AS order_value

    FROM training.order_items
    GROUP BY order_id
)
SELECT
    order_id,
    total_units,
    order_value
FROM OrderTotals
ORDER BY order_id;
GO


/* ==========================================================
   EXERCISE 22 - RUNNING ORDER VALUE
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
    o.order_date,
    ot.order_value,

    SUM(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_order_value

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 23 - RUNNING ORDER COUNT
   ========================================================== */

SELECT
    order_id,
    order_date,

    COUNT(*) OVER
    (
        ORDER BY
            order_date,
            order_id

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_order_count

FROM training.orders

ORDER BY
    order_date,
    order_id;
GO


/* ==========================================================
   EXERCISE 24 - CUSTOMER RUNNING SPENDING
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
    o.customer_id,
    o.order_id,
    o.order_date,
    ot.order_value,

    SUM(ot.order_value) OVER
    (
        PARTITION BY o.customer_id

        ORDER BY
            o.order_date,
            o.order_id

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_spending

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.customer_id,
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 25 - CUSTOMER RUNNING SPENDING + NAME
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
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    ot.order_value,

    SUM(ot.order_value) OVER
    (
        PARTITION BY c.customer_id

        ORDER BY
            o.order_date,
            o.order_id

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_spending

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    c.customer_id,
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 26 - MOVING AVERAGE
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
    o.order_date,
    ot.order_value,

    AVG(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id

        ROWS BETWEEN 2 PRECEDING
                 AND CURRENT ROW
    ) AS moving_average_3_orders

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 27 - MOVING SUM
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
    o.order_date,
    ot.order_value,

    SUM(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id

        ROWS BETWEEN 2 PRECEDING
                 AND CURRENT ROW
    ) AS moving_sum_3_orders

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 28 - PRODUCT COMPLETED REVENUE
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        oi.product_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    product_id,
    revenue
FROM ProductRevenue
ORDER BY revenue DESC;
GO


/* ==========================================================
   EXERCISE 29 - PRODUCT REVENUE SHARE
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    product_id,
    revenue,

    SUM(revenue) OVER ()
        AS total_revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_percent

FROM ProductRevenue

ORDER BY revenue DESC;
GO


/* ==========================================================
   EXERCISE 30 - PRODUCT SHARE WITH NAMES
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
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
    pr.revenue,

    pr.revenue * 100.0
    /
    NULLIF(
        SUM(pr.revenue) OVER (),
        0
    ) AS revenue_percent

FROM ProductRevenue AS pr

INNER JOIN training.products AS p
    ON pr.product_id = p.product_id

ORDER BY pr.revenue DESC;
GO


/* ==========================================================
   EXERCISE 31 - CATEGORY REVENUE SHARE
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

    SUM(revenue) OVER
    (
        PARTITION BY category
    ) AS category_revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER
        (
            PARTITION BY category
        ),
        0
    ) AS category_revenue_percent

FROM ProductRevenue

ORDER BY
    category,
    revenue DESC;
GO


/* ==========================================================
   EXERCISE 32 - LAG
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
    o.order_date,
    ot.order_value,

    LAG(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id
    ) AS previous_order_value

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 33 - CHANGE FROM PREVIOUS ORDER
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value

    FROM training.order_items
    GROUP BY order_id
),
OrderHistory AS
(
    SELECT
        o.order_id,
        o.order_date,
        ot.order_value,

        LAG(ot.order_value) OVER
        (
            ORDER BY
                o.order_date,
                o.order_id
        ) AS previous_order_value

    FROM training.orders AS o

    INNER JOIN OrderTotals AS ot
        ON o.order_id = ot.order_id
)
SELECT
    order_id,
    order_date,
    order_value,
    previous_order_value,

    order_value - previous_order_value
        AS change_from_previous

FROM OrderHistory

ORDER BY
    order_date,
    order_id;
GO


/* ==========================================================
   EXERCISE 34 - LEAD
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
    o.order_date,
    ot.order_value,

    LEAD(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id
    ) AS next_order_value

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   EXERCISE 35 - PREVIOUS ORDER DATE BY CUSTOMER
   ========================================================== */

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

ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/* ==========================================================
   EXERCISE 36 - DAYS BETWEEN CUSTOMER ORDERS
   ========================================================== */

;WITH OrderHistory AS
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
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,

    DATEDIFF(
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


/* ==========================================================
   EXERCISE 37 - NEXT ORDER DATE
   ========================================================== */

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

ORDER BY
    customer_id,
    order_date,
    order_id;
GO


/* ==========================================================
   EXERCISE 38 - FIRST_VALUE
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,

    FIRST_VALUE(price) OVER
    (
        PARTITION BY category
        ORDER BY
            price DESC,
            product_id
    ) AS highest_category_price

FROM training.products

ORDER BY
    category,
    price DESC;
GO


/* ==========================================================
   EXERCISE 39 - MOST EXPENSIVE PRODUCT NAME
   ========================================================== */

SELECT
    product_name,
    category,
    price,

    FIRST_VALUE(product_name) OVER
    (
        PARTITION BY category
        ORDER BY
            price DESC,
            product_id
    ) AS most_expensive_product

FROM training.products

ORDER BY
    category,
    price DESC;
GO


/* ==========================================================
   EXERCISE 40 - LAST_VALUE
   ========================================================== */

SELECT
    product_name,
    category,
    price,

    LAST_VALUE(price) OVER
    (
        PARTITION BY category

        ORDER BY
            price DESC,
            product_id

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS lowest_category_price

FROM training.products

ORDER BY
    category,
    price DESC;
GO


/* ==========================================================
   EXERCISE 41 - CUSTOMER REVENUE RANK
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
   EXERCISE 42 - CUSTOMER REVENUE SHARE
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
   EXERCISE 43 - PRODUCT RANK WITHIN CATEGORY
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

    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY revenue DESC
    ) AS category_revenue_rank

FROM ProductRevenue

ORDER BY
    category,
    category_revenue_rank,
    product_id;
GO


/* ==========================================================
   EXERCISE 44 - TOP REVENUE PRODUCT PER CATEGORY
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
),
RankedProducts AS
(
    SELECT
        product_id,
        product_name,
        category,
        revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                revenue DESC,
                product_id
        ) AS rn

    FROM ProductRevenue
)
SELECT
    product_id,
    product_name,
    category,
    revenue
FROM RankedProducts
WHERE rn = 1
ORDER BY category;
GO


/* ==========================================================
   EXERCISE 45 - MONTHLY REVENUE
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
    revenue
FROM MonthlyRevenue
ORDER BY order_month;
GO


/* ==========================================================
   EXERCISE 46 - CUMULATIVE MONTHLY REVENUE
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
   EXERCISE 47 - PREVIOUS MONTH REVENUE
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
    ) AS previous_month_revenue

FROM MonthlyRevenue

ORDER BY order_month;
GO


/* ==========================================================
   EXERCISE 48 - MONTHLY GROWTH
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
   EXERCISE 49 - FIRST / REPEAT ORDER
   ========================================================== */

;WITH OrderSequence AS
(
    SELECT
        order_id,
        customer_id,
        order_date,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS order_number

    FROM training.orders
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_number,

    CASE
        WHEN order_number = 1
            THEN 'First Order'
        ELSE 'Repeat Order'
    END AS order_type

FROM OrderSequence

ORDER BY
    customer_id,
    order_number;
GO


/* ==========================================================
   EXERCISE 50 - CUSTOMER ORDER INTERVAL
   ========================================================== */

;WITH OrderHistory AS
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
        ) AS order_number,

        LAG(order_date) OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date,
                order_id
        ) AS previous_order_date

    FROM training.orders
)
SELECT
    c.customer_id,
    c.customer_name,
    oh.order_id,
    oh.order_date,
    oh.order_number,
    oh.previous_order_date,

    DATEDIFF(
        DAY,
        oh.previous_order_date,
        oh.order_date
    ) AS days_since_previous_order

FROM OrderHistory AS oh

INNER JOIN training.customers AS c
    ON oh.customer_id = c.customer_id

ORDER BY
    c.customer_id,
    oh.order_number;
GO


/* ==========================================================
   EXERCISE 51 - THINK: GROUP BY vs PARTITION BY
   ========================================================== */

/*
Answer:

GROUP BY changes the result grain.

Example:

    GROUP BY category

can turn many product rows into one row per category.


PARTITION BY does not collapse those product rows.

Example:

    AVG(price) OVER
    (
        PARTITION BY category
    )

keeps each product row and adds the category-level
calculation beside it.
*/


/* ==========================================================
   EXERCISE 52 - THINK: RANKING FUNCTIONS
   ========================================================== */

/*
Values:

100
90
90
80


ROW_NUMBER:

1
2
3
4


RANK:

1
2
2
4


DENSE_RANK:

1
2
2
3
*/


/* ==========================================================
   EXERCISE 53 - THINK: TIE BREAKING
   ========================================================== */

/*
Answer:

If two products have the same price, then:

    ORDER BY price DESC

does not uniquely define which tied product should
receive the earlier ROW_NUMBER.

Add a stable tie-breaker:

    ORDER BY
        price DESC,
        product_id ASC

Now equal-price rows have a deterministic order.
*/


/* ==========================================================
   EXERCISE 54 - THINK: FILTERING
   ========================================================== */

/*
Answer:

rn is created by a window expression and is not
available to WHERE at the same query level.

Use another query layer.

Example:

    ;WITH RankedProducts AS
    (
        SELECT
            product_name,
            price,

            ROW_NUMBER() OVER
            (
                ORDER BY price DESC
            ) AS rn

        FROM training.products
    )
    SELECT *
    FROM RankedProducts
    WHERE rn <= 3;

A derived table could also be used.
*/


/* ==========================================================
   EXERCISE 55 - THINK: WINDOW ORDER
   ========================================================== */

/*
Answer:

No.

ORDER BY inside OVER controls the order used by
the window calculation.

It does not guarantee final display order.

Use a final:

    ORDER BY price DESC

if that display order is required.
*/


/* ==========================================================
   EXERCISE 56 - THINK: LAST_VALUE
   ========================================================== */

/*
Answer:

LAST_VALUE depends on the active window frame.

With an ordered window, the default frame may end
at the current row, so "last" can mean the last
value visible up to that row instead of the final
row of the entire partition.

To inspect the entire partition:

    ROWS BETWEEN UNBOUNDED PRECEDING
             AND UNBOUNDED FOLLOWING
*/


/* ==========================================================
   EXERCISE 57 - THINK: RESULT GRAIN
   ========================================================== */

/*
Answer:

order_items has one row per order-item line.

One order can therefore appear on several rows.

If the business metric requires one running value
per order, first aggregate order_items to:

    one row per order

Then apply the window calculation.

Otherwise the running calculation would operate at
the order-item grain rather than the order grain.
*/


/* ==========================================================
   EXERCISE 58 - THINK: LAG
   ========================================================== */

/*
Answer:

NULL.

The customer's first order has no previous row
inside that customer's partition.

Therefore LAG(order_date) has no earlier value
to return.
*/


/* ==========================================================
   EXERCISE 59 - THINK: NTILE
   ========================================================== */

/*
Answer:

No.

NTILE(4) does not divide the numeric price range
into four equal intervals.

It sorts the rows according to the window ORDER BY
and distributes those rows into four groups as evenly
as possible.
*/


/* ==========================================================
   EXERCISE 60 - CHOOSE THE FUNCTION
   ========================================================== */

/*
Answer:

1. LAG

2. LEAD

3. SUM() OVER

4. ROW_NUMBER

5. RANK

6. DENSE_RANK

7. NTILE

8. AVG() OVER with an appropriate ROWS frame
*/


/* ==========================================================
   CHALLENGE 1 - PRODUCT ANALYTICS REPORT
   ========================================================== */

;WITH ProductRevenue AS
(
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
)
SELECT
    product_id,
    product_name,
    category,
    units_sold,
    revenue,

    SUM(revenue) OVER ()
        AS overall_revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS overall_revenue_percent,

    SUM(revenue) OVER
    (
        PARTITION BY category
    ) AS category_revenue,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER
        (
            PARTITION BY category
        ),
        0
    ) AS category_revenue_percent,

    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY revenue DESC
    ) AS category_revenue_rank

FROM ProductRevenue

ORDER BY
    category,
    category_revenue_rank,
    product_id;
GO


/* ==========================================================
   CHALLENGE 2 - CUSTOMER ANALYTICS REPORT
   ========================================================== */

;WITH CustomerPerformance AS
(
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id)
            AS completed_orders,

        SUM(oi.quantity)
            AS total_units,

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
    cp.completed_orders,
    cp.total_units,
    cp.revenue,

    DENSE_RANK() OVER
    (
        ORDER BY cp.revenue DESC
    ) AS revenue_rank,

    cp.revenue * 100.0
    /
    NULLIF(
        SUM(cp.revenue) OVER (),
        0
    ) AS revenue_share_percent

FROM CustomerPerformance AS cp

INNER JOIN training.customers AS c
    ON cp.customer_id = c.customer_id

ORDER BY
    revenue_rank,
    c.customer_id;
GO


/* ==========================================================
   CHALLENGE 3 - ORDER HISTORY REPORT
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,

        SUM(
            quantity * unit_price
        ) AS order_value

    FROM training.order_items

    GROUP BY order_id
),
OrderHistory AS
(
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        ot.order_value,

        ROW_NUMBER() OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS order_number,

        LAG(o.order_date) OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS previous_order_date,

        SUM(ot.order_value) OVER
        (
            PARTITION BY o.customer_id

            ORDER BY
                o.order_date,
                o.order_id

            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS running_customer_value

    FROM training.orders AS o

    INNER JOIN OrderTotals AS ot
        ON o.order_id = ot.order_id
)
SELECT
    c.customer_id,
    c.customer_name,
    oh.order_id,
    oh.order_date,
    oh.order_number,
    oh.previous_order_date,

    DATEDIFF(
        DAY,
        oh.previous_order_date,
        oh.order_date
    ) AS days_since_previous_order,

    oh.order_value,
    oh.running_customer_value

FROM OrderHistory AS oh

INNER JOIN training.customers AS c
    ON oh.customer_id = c.customer_id

ORDER BY
    c.customer_id,
    oh.order_number;
GO


/* ==========================================================
   CHALLENGE 4 - MONTHLY GROWTH REPORT
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
        ) AS previous_revenue,

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
        AS growth_percent,

    cumulative_revenue,
    revenue_rank

FROM RevenueHistory

ORDER BY order_month;
GO


/* ==========================================================
   CHALLENGE 5 - TOP PRODUCTS PER CATEGORY
   ========================================================== */

;WITH ProductRevenue AS
(
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
),
ProductAnalytics AS
(
    SELECT
        product_id,
        product_name,
        category,
        units_sold,
        revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                revenue DESC,
                product_id
        ) AS category_row_number,

        revenue * 100.0
        /
        NULLIF(
            SUM(revenue) OVER
            (
                PARTITION BY category
            ),
            0
        ) AS category_revenue_percent

    FROM ProductRevenue
)
SELECT
    product_id,
    product_name,
    category,
    units_sold,
    revenue,
    category_row_number,
    category_revenue_percent

FROM ProductAnalytics

WHERE category_row_number <= 2

ORDER BY
    category,
    category_row_number;
GO


/* ==========================================================
   FINAL RECAP

   OVER()
       Adds analytical context while keeping rows.

   PARTITION BY
       Restarts calculation by logical group.

   ROW_NUMBER()
       Unique sequence.

   RANK()
       Ties share rank; gaps occur.

   DENSE_RANK()
       Ties share rank; no gaps.

   NTILE()
       Divides ordered rows into buckets.

   SUM() OVER()
       Totals, running totals, partition totals.

   AVG() OVER()
       Group averages and moving averages.

   LAG()
       Previous row.

   LEAD()
       Next row.

   FIRST_VALUE()
       First ordered value.

   LAST_VALUE()
       Last value according to the active frame.


   RUNNING FRAME:

       ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW


   3-ROW MOVING FRAME:

       ROWS BETWEEN 2 PRECEDING
                AND CURRENT ROW


   FULL PARTITION FRAME:

       ROWS BETWEEN UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING


   TOP-N PER GROUP:

       ROW_NUMBER()
       +
       PARTITION BY
       +
       outer WHERE


   PERCENT OF TOTAL:

       value * 100.0
       /
       NULLIF(
           SUM(value) OVER (),
           0
       )


   PERCENT WITHIN GROUP:

       value * 100.0
       /
       NULLIF(
           SUM(value) OVER
           (
               PARTITION BY group_column
           ),
           0
       )


   TIME SERIES:

       GROUP BY period
           ->
       LAG
           ->
       change
           ->
       growth %
           ->
       cumulative total


   IMPORTANT:

   - Window functions do not replace GROUP BY.
   - They often work after GROUP BY.
   - Always understand result grain.
   - Pre-aggregate detailed rows when necessary.
   - Window ORDER BY and final ORDER BY are different.
   - Use deterministic tie-breakers when required.
   - Be explicit about frames when frame behavior matters.

============================================================
END OF CHAPTER 08
============================================================
*/