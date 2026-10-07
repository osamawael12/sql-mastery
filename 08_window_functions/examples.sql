/*
============================================================
SQL MASTERY
08 - WINDOW FUNCTIONS

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- OVER()
- PARTITION BY
- ROW_NUMBER
- RANK
- DENSE_RANK
- NTILE
- Aggregate Window Functions
- Running Totals
- Moving Averages
- Percent of Total
- LAG
- LEAD
- FIRST_VALUE
- LAST_VALUE
- Top N per Group
- Time Series Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. OVER()

   Calculate overall average price without
   collapsing product rows.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    AVG(price) OVER () AS overall_average_price

FROM training.products;
GO


/* ==========================================================
   2. GROUP BY vs WINDOW FUNCTION

   GROUP BY collapses rows.
   ========================================================== */

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
GO


/*
Window function keeps every product row.
*/

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
   3. COUNT OVER

   Keep every customer and display total
   customer count.
   ========================================================== */

SELECT
    customer_id,
    customer_name,

    COUNT(*) OVER () AS total_customers

FROM training.customers;
GO


/* ==========================================================
   4. COUNT BY PARTITION

   Number of products in each category.
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
   5. SUM BY PARTITION

   Total stock by category without collapsing rows.
   ========================================================== */

SELECT
    product_id,
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
   6. MIN / MAX BY PARTITION
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

FROM training.products

ORDER BY
    category,
    price;
GO


/* ==========================================================
   7. AVG BY CATEGORY
   ========================================================== */

SELECT
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
   8. DIFFERENCE FROM CATEGORY AVERAGE
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
   9. ROW_NUMBER

   Unique sequence based on price.

   product_id is added as a deterministic tie-breaker.
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
   10. ROW_NUMBER BY CATEGORY

   Numbering restarts inside each category.
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
   11. RANK
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    RANK() OVER
    (
        ORDER BY price DESC
    ) AS price_rank

FROM training.products

ORDER BY
    price_rank,
    product_id;
GO


/* ==========================================================
   12. DENSE_RANK
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    DENSE_RANK() OVER
    (
        ORDER BY price DESC
    ) AS dense_price_rank

FROM training.products

ORDER BY
    dense_price_rank,
    product_id;
GO


/* ==========================================================
   13. COMPARE RANKING FUNCTIONS
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
   14. CATEGORY RANKING
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
   15. NTILE

   Divide products into approximately equal
   price buckets.
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
   16. TOP 2 PRODUCTS PER CATEGORY

   Window aliases cannot be filtered in WHERE
   at the same query level.

   Use a CTE.
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
   17. MOST EXPENSIVE PRODUCT PER CATEGORY
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
   18. LATEST ORDER PER CUSTOMER
   ========================================================== */

;WITH RankedOrders AS
(
    SELECT
        order_id,
        customer_id,
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
    order_id,
    customer_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;
GO


/* ==========================================================
   19. LATEST ORDER WITH CUSTOMER NAME
   ========================================================== */

;WITH RankedOrders AS
(
    SELECT
        order_id,
        customer_id,
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
   20. FIRST ORDER PER CUSTOMER
   ========================================================== */

;WITH RankedOrders AS
(
    SELECT
        order_id,
        customer_id,
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
    order_id,
    customer_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1
ORDER BY customer_id;
GO


/* ==========================================================
   21. PRE-AGGREGATE ORDER TOTALS

   One row per order before window calculations.
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

ORDER BY order_value DESC;
GO


/* ==========================================================
   22. RUNNING ORDER VALUE

   Running total across all orders.
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
   23. RUNNING COUNT OF ORDERS
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
   24. CUSTOMER RUNNING SPENDING

   Running total restarts for each customer.
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
    ) AS customer_running_spending

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.customer_id,
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   25. CUSTOMER RUNNING SPENDING WITH NAME
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
   26. 3-ROW MOVING AVERAGE OF ORDER VALUE
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
   27. 3-ROW MOVING SUM
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
   28. PRODUCT COMPLETED REVENUE
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
   29. PERCENT OF TOTAL REVENUE
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
    revenue,

    SUM(revenue) OVER () AS total_revenue,

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
   30. PRODUCT REVENUE SHARE WITH NAMES
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
   31. PERCENT OF CATEGORY REVENUE
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
   32. LAG - PREVIOUS ORDER VALUE
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
   33. CHANGE FROM PREVIOUS ORDER
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
    ) AS previous_order_value,

    ot.order_value
    -
    LAG(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id
    ) AS change_from_previous

FROM training.orders AS o

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
GO


/* ==========================================================
   34. LEAD - NEXT ORDER VALUE
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
   35. PREVIOUS ORDER DATE BY CUSTOMER
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
   36. DAYS SINCE PREVIOUS ORDER
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
   37. NEXT ORDER DATE BY CUSTOMER
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
   38. FIRST_VALUE - HIGHEST PRICE IN CATEGORY
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
   39. FIRST_VALUE - MOST EXPENSIVE PRODUCT NAME
   ========================================================== */

SELECT
    product_id,
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
   40. LAST_VALUE WITH FULL FRAME

   Find the lowest price in each category.

   Because ordering is DESC:
   last row = lowest price.
   ========================================================== */

SELECT
    product_id,
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
   41. FIRST AND LAST VALUE TOGETHER
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

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND UNBOUNDED FOLLOWING
    ) AS highest_category_price,

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
   42. CUSTOMER COMPLETED REVENUE
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
    cr.revenue
FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   43. CUSTOMER REVENUE RANK
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
   44. CUSTOMER REVENUE SHARE
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
   45. PRODUCT REVENUE RANK WITHIN CATEGORY
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
   46. TOP REVENUE PRODUCT PER CATEGORY
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
   47. MONTHLY COMPLETED REVENUE
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
   48. CUMULATIVE MONTHLY REVENUE
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
   49. PREVIOUS MONTH REVENUE
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
   50. MONTH-OVER-MONTH CHANGE
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
RevenueWithLag AS
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

FROM RevenueWithLag

ORDER BY order_month;
GO


/* ==========================================================
   51. MONTHLY REVENUE SHARE
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
    ) AS total_revenue_percent

FROM MonthlyRevenue

ORDER BY order_month;
GO


/* ==========================================================
   52. MONTHLY REVENUE RANK
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
   53. CUSTOMER ORDER SEQUENCE

   Give every order a sequence within its customer.
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
   54. FIRST / REPEAT ORDER LABEL
   ========================================================== */

;WITH OrderedSequence AS
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

FROM OrderedSequence

ORDER BY
    customer_id,
    order_number;
GO


/* ==========================================================
   55. CUSTOMER ORDER INTERVAL REPORT
   ========================================================== */

;WITH OrderHistory AS
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
        ) AS order_number,

        LAG(o.order_date) OVER
        (
            PARTITION BY o.customer_id
            ORDER BY
                o.order_date,
                o.order_id
        ) AS previous_order_date

    FROM training.orders AS o
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
   56. FINAL PRODUCT ANALYTICS REPORT

   Completed revenue by product with:

   - Revenue
   - Overall revenue share
   - Category revenue
   - Category revenue share
   - Category rank
   ========================================================== */

;WITH ProductRevenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity
        ) AS units_sold,

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
   57. FINAL CUSTOMER ANALYTICS REPORT

   Completed customer revenue with:

   - Orders
   - Units
   - Revenue
   - Revenue rank
   - Revenue share
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
   58. FINAL MONTHLY ANALYTICS PIPELINE

   Calculate:

   - Monthly Completed revenue
   - Previous month revenue
   - Absolute change
   - Growth percentage
   - Cumulative revenue
   - Revenue rank
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
   FINAL RECAP

   OVER()
       Defines a window calculation.

   PARTITION BY
       Splits rows into groups without collapsing them.

   ORDER BY inside OVER
       Defines analytical row order.

   ROW_NUMBER
       Unique sequence.

   RANK
       Equal rank for ties, with gaps.

   DENSE_RANK
       Equal rank for ties, without gaps.

   NTILE
       Distributes ordered rows into buckets.

   AGGREGATE WINDOWS:
       COUNT
       SUM
       AVG
       MIN
       MAX

   RUNNING TOTAL:
       ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW

   MOVING WINDOW:
       ROWS BETWEEN n PRECEDING
                AND CURRENT ROW

   LAG
       Previous row.

   LEAD
       Next row.

   FIRST_VALUE
       First ordered value.

   LAST_VALUE
       Last value in the defined frame.

   TOP N PER GROUP:
       ROW_NUMBER + CTE + WHERE

   IMPORTANT:

   - Know the result grain.
   - Pre-aggregate when necessary.
   - Use deterministic tie-breakers.
   - Window ORDER BY does not guarantee final display order.
   - Window aliases generally require an outer query
     before they can be filtered.
   - Be explicit with window frames when the frame matters.

============================================================
END OF EXAMPLES
============================================================
*/