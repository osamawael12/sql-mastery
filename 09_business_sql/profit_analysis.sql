/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: profit_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definitions:

Revenue:
    quantity * unit_price

Estimated Cost:
    quantity * products.cost

Estimated Gross Profit:
    Revenue - Estimated Cost

Equivalent line formula:
    quantity * (unit_price - products.cost)

Gross Margin %:
    Estimated Gross Profit / Revenue * 100

IMPORTANT ASSUMPTION:

training.products.cost represents the CURRENT product cost.

The schema does NOT store historical cost at the
time each order was placed.

Therefore the profit metrics in this file are:

    ESTIMATED gross profit

not guaranteed historical accounting profit.

Only Completed orders count unless explicitly stated.

Topics:
- Revenue vs Profit
- Unit Profit
- Gross Profit
- Gross Margin
- Product Profitability
- Category Profitability
- Customer Profitability
- Order Profitability
- Monthly Profit
- Profit Growth
- Profit Share
- Profit Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. PRODUCT UNIT PROFIT

   Catalog-level calculation:

   price - cost

   This is NOT transactional profit.
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    cost,

    price - cost
        AS catalog_unit_profit

FROM training.products

ORDER BY catalog_unit_profit DESC;
GO


/* ==========================================================
   2. CATALOG GROSS MARGIN %

   Formula:

   (price - cost) / price * 100
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,

    price - cost
        AS catalog_unit_profit,

    (price - cost) * 100.0
    /
    NULLIF(
        price,
        0
    ) AS catalog_margin_percent

FROM training.products

ORDER BY catalog_margin_percent DESC;
GO


/* ==========================================================
   3. COMPLETED SALES PROFIT BASE

   Grain:

   one Completed order-item line.

   Metrics:

   line_revenue
   estimated_line_cost
   estimated_gross_profit
   ========================================================== */

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,

    oi.order_item_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,

    p.cost AS current_unit_cost,

    oi.quantity * oi.unit_price
        AS line_revenue,

    oi.quantity * p.cost
        AS estimated_line_cost,

    oi.quantity
    * (oi.unit_price - p.cost)
        AS estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

ORDER BY
    o.order_id,
    oi.order_item_id;
GO


/* ==========================================================
   4. OVERALL ESTIMATED PROFIT SUMMARY
   ========================================================== */

SELECT
    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * p.cost
    ) AS estimated_cost,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   5. OVERALL ESTIMATED GROSS MARGIN
   ========================================================== */

SELECT
    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_gross_margin_percent

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   6. PRODUCT PROFITABILITY
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * p.cost
    ) AS estimated_cost,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

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

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   7. PRODUCT GROSS MARGIN
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_margin_percent

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

ORDER BY estimated_margin_percent DESC;
GO


/* ==========================================================
   8. PRODUCT PROFIT RANK
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
    estimated_gross_profit,

    DENSE_RANK() OVER
    (
        ORDER BY estimated_gross_profit DESC
    ) AS profit_rank

FROM ProductProfit

ORDER BY
    profit_rank,
    product_id;
GO


/* ==========================================================
   9. PRODUCT PROFIT SHARE

   Product contribution to total estimated profit.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
    estimated_gross_profit,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent

FROM ProductProfit

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   10. REVENUE RANK vs PROFIT RANK

   A high-revenue product is not necessarily
   the highest-profit product.
   ========================================================== */

;WITH ProductPerformance AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
    estimated_gross_profit,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER
    (
        ORDER BY estimated_gross_profit DESC
    ) AS profit_rank

FROM ProductPerformance

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   11. CATEGORY PROFITABILITY
   ========================================================== */

SELECT
    p.category,

    COUNT(DISTINCT p.product_id)
        AS products_sold,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * p.cost
    ) AS estimated_cost,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY p.category

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   12. CATEGORY GROSS MARGIN
   ========================================================== */

SELECT
    p.category,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_margin_percent

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY p.category

ORDER BY estimated_margin_percent DESC;
GO


/* ==========================================================
   13. CATEGORY PROFIT SHARE
   ========================================================== */

;WITH CategoryProfit AS
(
    SELECT
        p.category,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY p.category
)
SELECT
    category,
    estimated_gross_profit,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent

FROM CategoryProfit

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   14. PRODUCT PROFIT WITHIN CATEGORY

   Product share of category estimated profit.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
    estimated_gross_profit,

    SUM(estimated_gross_profit) OVER
    (
        PARTITION BY category
    ) AS category_profit,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER
        (
            PARTITION BY category
        ),
        0
    ) AS category_profit_share_percent,

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


/* ==========================================================
   15. CUSTOMER PROFITABILITY

   Estimated profit generated by each customer.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

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

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   16. CUSTOMER MARGIN
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_margin_percent

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

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   17. CUSTOMER PROFIT RANK
   ========================================================== */

;WITH CustomerProfit AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    cp.revenue,
    cp.estimated_gross_profit,

    DENSE_RANK() OVER
    (
        ORDER BY cp.estimated_gross_profit DESC
    ) AS profit_rank

FROM CustomerProfit AS cp

INNER JOIN training.customers AS c
    ON cp.customer_id = c.customer_id

ORDER BY
    profit_rank,
    c.customer_id;
GO


/* ==========================================================
   18. CUSTOMER PROFIT SHARE
   ========================================================== */

;WITH CustomerProfit AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,

    cp.estimated_gross_profit,

    cp.estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(cp.estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent

FROM CustomerProfit AS cp

INNER JOIN training.customers AS c
    ON cp.customer_id = c.customer_id

ORDER BY cp.estimated_gross_profit DESC;
GO


/* ==========================================================
   19. ORDER PROFITABILITY

   Grain:
   one Completed order.
   ========================================================== */

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,

    SUM(oi.quantity)
        AS total_units,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * p.cost
    ) AS estimated_cost,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   20. ORDER MARGIN
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_margin_percent

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    o.order_id,
    o.order_date

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   21. MONTHLY PROFITABILITY
   ========================================================== */

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
    ) AS revenue,

    SUM(
        oi.quantity * p.cost
    ) AS estimated_cost,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

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
   22. MONTHLY GROSS MARGIN
   ========================================================== */

;WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

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
    estimated_gross_profit,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        revenue,
        0
    ) AS estimated_margin_percent

FROM MonthlyProfit

ORDER BY order_month;
GO


/* ==========================================================
   23. MONTH-OVER-MONTH PROFIT CHANGE

   LAG refers to previous observed profit month.

   With missing months, this is not automatically
   strict calendar MoM.
   ========================================================== */

;WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
ProfitHistory AS
(
    SELECT
        order_month,
        estimated_gross_profit,

        LAG(estimated_gross_profit) OVER
        (
            ORDER BY order_month
        ) AS previous_profit

    FROM MonthlyProfit
)
SELECT
    order_month,
    estimated_gross_profit,
    previous_profit,

    estimated_gross_profit - previous_profit
        AS profit_change,

    (
        estimated_gross_profit
        - previous_profit
    ) * 100.0
    /
    NULLIF(
        previous_profit,
        0
    ) AS profit_growth_percent

FROM ProfitHistory

ORDER BY order_month;
GO


/* ==========================================================
   24. CUMULATIVE ESTIMATED PROFIT
   ========================================================== */

;WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

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
    estimated_gross_profit,

    SUM(estimated_gross_profit) OVER
    (
        ORDER BY order_month

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_estimated_profit

FROM MonthlyProfit

ORDER BY order_month;
GO


/* ==========================================================
   25. STRICT MONTH-OVER-MONTH PROFIT GROWTH

   Only calculate when the previous observed period
   is exactly one calendar month earlier.
   ========================================================== */

;WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
),
ProfitHistory AS
(
    SELECT
        order_month,
        estimated_gross_profit,

        LAG(order_month) OVER
        (
            ORDER BY order_month
        ) AS previous_month,

        LAG(estimated_gross_profit) OVER
        (
            ORDER BY order_month
        ) AS previous_profit

    FROM MonthlyProfit
)
SELECT
    order_month,
    estimated_gross_profit,
    previous_month,
    previous_profit,

    CASE
        WHEN DATEDIFF(
            MONTH,
            previous_month,
            order_month
        ) = 1
        THEN
            estimated_gross_profit
            - previous_profit
    END AS strict_mom_profit_change,

    CASE
        WHEN DATEDIFF(
            MONTH,
            previous_month,
            order_month
        ) = 1
        THEN
            (
                estimated_gross_profit
                - previous_profit
            ) * 100.0
            /
            NULLIF(
                previous_profit,
                0
            )
    END AS strict_mom_profit_growth_percent

FROM ProfitHistory

ORDER BY order_month;
GO


/* ==========================================================
   26. PROFIT BY CUSTOMER CITY
   ========================================================== */

SELECT
    COALESCE(
        c.city,
        N'Unknown'
    ) AS city,

    COUNT(DISTINCT c.customer_id)
        AS customers,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    COALESCE(
        c.city,
        N'Unknown'
    )

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   27. CITY GROSS MARGIN
   ========================================================== */

SELECT
    COALESCE(
        c.city,
        N'Unknown'
    ) AS city,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) * 100.0
    /
    NULLIF(
        SUM(
            oi.quantity * oi.unit_price
        ),
        0
    ) AS estimated_margin_percent

FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'

GROUP BY
    COALESCE(
        c.city,
        N'Unknown'
    )

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   28. NEGATIVE-MARGIN TRANSACTION LINES

   Identify lines where:

   unit_price < current product cost.

   Remember:
   current cost may not equal historical cost.
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,

    p.product_id,
    p.product_name,

    oi.quantity,
    oi.unit_price,
    p.cost AS current_unit_cost,

    oi.quantity
    * (oi.unit_price - p.cost)
        AS estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed'
  AND oi.unit_price < p.cost

ORDER BY estimated_gross_profit;
GO


/* ==========================================================
   29. ZERO OR NEGATIVE MARGIN PRODUCTS

   Based on Completed transactional performance.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_gross_profit

FROM ProductProfit

WHERE estimated_gross_profit <= 0

ORDER BY estimated_gross_profit;
GO


/* ==========================================================
   30. HIGH REVENUE / LOW MARGIN SIGNAL

   Illustrative business segmentation.

   The thresholds are examples only.
   ========================================================== */

;WITH ProductPerformance AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
ProductMargins AS
(
    SELECT
        product_id,
        product_name,
        revenue,
        estimated_gross_profit,

        estimated_gross_profit * 100.0
        /
        NULLIF(
            revenue,
            0
        ) AS margin_percent

    FROM ProductPerformance
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_gross_profit,
    margin_percent,

    CASE
        WHEN revenue >= 10000
         AND margin_percent < 20
            THEN 'High Revenue / Low Margin'

        WHEN revenue >= 10000
            THEN 'High Revenue'

        WHEN margin_percent >= 30
            THEN 'High Margin'

        ELSE 'Standard'
    END AS profitability_signal

FROM ProductMargins

ORDER BY revenue DESC;
GO


/* ==========================================================
   31. REVENUE vs PROFIT CONTRIBUTION
   ========================================================== */

;WITH ProductPerformance AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    revenue,
    estimated_gross_profit,

    revenue * 100.0
    /
    NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_share_percent,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent

FROM ProductPerformance

ORDER BY estimated_gross_profit DESC;
GO


/* ==========================================================
   32. PROFIT CONCENTRATION

   Cumulative profit contribution by product.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
        estimated_gross_profit,

        ROW_NUMBER() OVER
        (
            ORDER BY
                estimated_gross_profit DESC,
                product_id
        ) AS profit_position

    FROM ProductProfit
)
SELECT
    product_id,
    product_name,
    estimated_gross_profit,
    profit_position,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent,

    SUM(estimated_gross_profit) OVER
    (
        ORDER BY profit_position

        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS cumulative_profit_share_percent

FROM RankedProducts

ORDER BY profit_position;
GO


/* ==========================================================
   33. PROFIT RECONCILIATION - PRODUCT TOTAL

   Sum of product-level profit.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        oi.product_id,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    SUM(estimated_gross_profit)
        AS product_profit_total

FROM ProductProfit;
GO


/* ==========================================================
   34. PROFIT RECONCILIATION - CUSTOMER TOTAL
   ========================================================== */

;WITH CustomerProfit AS
(
    SELECT
        o.customer_id,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
)
SELECT
    SUM(estimated_gross_profit)
        AS customer_profit_total

FROM CustomerProfit;
GO


/* ==========================================================
   35. PROFIT RECONCILIATION - MONTHLY TOTAL
   ========================================================== */

;WITH MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    SUM(estimated_gross_profit)
        AS monthly_profit_total

FROM MonthlyProfit;
GO


/* ==========================================================
   36. DIRECT PROFIT RECONCILIATION
   ========================================================== */

SELECT
    SUM(
        oi.quantity
        * (oi.unit_price - p.cost)
    ) AS direct_estimated_gross_profit

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   37. PROFIT RECONCILIATION IN ONE QUERY

   All four totals should match.
   ========================================================== */

;WITH CompletedSales AS
(
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        oi.product_id,

        oi.quantity
        * (oi.unit_price - p.cost)
            AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'
),
ProductProfit AS
(
    SELECT
        product_id,

        SUM(estimated_gross_profit)
            AS profit

    FROM CompletedSales

    GROUP BY product_id
),
CustomerProfit AS
(
    SELECT
        customer_id,

        SUM(estimated_gross_profit)
            AS profit

    FROM CompletedSales

    GROUP BY customer_id
),
MonthlyProfit AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS order_month,

        SUM(estimated_gross_profit)
            AS profit

    FROM CompletedSales

    GROUP BY
        DATEFROMPARTS(
            YEAR(order_date),
            MONTH(order_date),
            1
        )
)
SELECT
    (
        SELECT
            SUM(estimated_gross_profit)
        FROM CompletedSales
    ) AS direct_profit,

    (
        SELECT SUM(profit)
        FROM ProductProfit
    ) AS product_profit,

    (
        SELECT SUM(profit)
        FROM CustomerProfit
    ) AS customer_profit,

    (
        SELECT SUM(profit)
        FROM MonthlyProfit
    ) AS monthly_profit;
GO


/* ==========================================================
   38. FINAL PROFIT KPI SUMMARY

   Executive-style one-row report.
   ========================================================== */

;WITH CompletedProfitBase AS
(
    SELECT
        o.order_id,
        o.customer_id,

        oi.quantity,

        oi.quantity * oi.unit_price
            AS revenue,

        oi.quantity * p.cost
            AS estimated_cost,

        oi.quantity
        * (oi.unit_price - p.cost)
            AS estimated_gross_profit

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.order_status = 'Completed'
)
SELECT
    COUNT(DISTINCT order_id)
        AS completed_orders,

    COUNT(DISTINCT customer_id)
        AS completed_customers,

    SUM(quantity)
        AS units_sold,

    SUM(revenue)
        AS revenue,

    SUM(estimated_cost)
        AS estimated_cost,

    SUM(estimated_gross_profit)
        AS estimated_gross_profit,

    SUM(estimated_gross_profit) * 100.0
    /
    NULLIF(
        SUM(revenue),
        0
    ) AS estimated_gross_margin_percent

FROM CompletedProfitBase;
GO


/* ==========================================================
   39. FINAL PRODUCT PROFIT REPORT

   One row per product with Completed activity.
   ========================================================== */

;WITH ProductProfit AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity)
            AS units_sold,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(
            oi.quantity * p.cost
        ) AS estimated_cost,

        SUM(
            oi.quantity
            * (oi.unit_price - p.cost)
        ) AS estimated_gross_profit

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
        estimated_cost,
        estimated_gross_profit,

        estimated_gross_profit * 100.0
        /
        NULLIF(
            revenue,
            0
        ) AS estimated_margin_percent,

        DENSE_RANK() OVER
        (
            ORDER BY estimated_gross_profit DESC
        ) AS profit_rank,

        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY estimated_gross_profit DESC
        ) AS category_profit_rank

    FROM ProductProfit
)
SELECT
    product_id,
    product_name,
    category,
    units_sold,
    revenue,
    estimated_cost,
    estimated_gross_profit,
    estimated_margin_percent,

    estimated_gross_profit * 100.0
    /
    NULLIF(
        SUM(estimated_gross_profit) OVER (),
        0
    ) AS profit_share_percent,

    profit_rank,
    category_profit_rank

FROM ProductAnalytics

ORDER BY
    profit_rank,
    product_id;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   REVENUE:

       quantity * unit_price


   ESTIMATED COST:

       quantity * current product cost


   ESTIMATED GROSS PROFIT:

       Revenue - Estimated Cost

   or:

       quantity * (unit_price - cost)


   GROSS MARGIN:

       Estimated Gross Profit
       /
       Revenue
       * 100


   PROFIT SHARE:

       Entity Estimated Profit
       /
       Total Estimated Profit
       * 100


   IMPORTANT:

   1. Revenue and profit are not the same metric.

   2. High revenue does not guarantee high profit.

   3. Margin and markup are different calculations.

   4. NULLIF protects division-by-zero calculations.

   5. Current products.cost is being applied to
      historical transactions.

   6. Therefore these results are estimates.

   7. For exact historical profitability, store
      transaction-time cost or maintain valid
      historical cost data.

   8. Profit should reconcile across:

      Product
      Customer
      Month
      Overall total

============================================================
END OF PROFIT ANALYSIS
============================================================
*/