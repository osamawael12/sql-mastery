/*
============================================================
SQL MASTERY
09 - BUSINESS SQL

File: product_analysis.sql
Database: SQLMastery
Language: T-SQL

Business Definitions:

Units Sold:
    SUM(order_items.quantity)
    from Completed orders.

Product Revenue:
    SUM(quantity * unit_price)
    from Completed orders.

Product Customers:
    Distinct customers who bought the product
    through Completed orders.

Product Order Count:
    Distinct Completed orders containing the product.

Topics:
- Product Performance
- Units Sold
- Revenue
- Revenue Share
- Product Ranking
- Category Performance
- Top Products per Category
- Unsold Products
- Inventory Signals
- Revenue Concentration
- Product Validation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. PRODUCT CATALOG SUMMARY

   Grain:
   one product.
   ========================================================== */

SELECT
    COUNT(*) AS total_products,

    COUNT(
        CASE
            WHEN is_active = 1
                THEN product_id
        END
    ) AS active_products,

    SUM(stock_quantity)
        AS total_stock,

    AVG(price)
        AS average_catalog_price

FROM training.products;
GO


/* ==========================================================
   2. PRODUCTS BY CATEGORY
   ========================================================== */

SELECT
    category,

    COUNT(*) AS product_count,

    SUM(stock_quantity)
        AS total_stock,

    AVG(price)
        AS average_price,

    MIN(price)
        AS minimum_price,

    MAX(price)
        AS maximum_price

FROM training.products

GROUP BY category

ORDER BY product_count DESC;
GO


/* ==========================================================
   3. COMPLETED PRODUCT PERFORMANCE

   Only products that appear in Completed orders
   are returned.

   Grain:
   one product.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    COUNT(DISTINCT o.order_id)
        AS completed_order_count,

    COUNT(DISTINCT o.customer_id)
        AS customer_count,

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
   4. PRODUCT UNITS SOLD

   Do not use COUNT(*) for units.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    SUM(oi.quantity)
        AS units_sold

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY units_sold DESC;
GO


/* ==========================================================
   5. PRODUCT REVENUE
   ========================================================== */

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

ORDER BY revenue DESC;
GO


/* ==========================================================
   6. PRODUCT REVENUE SHARE
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
   7. PRODUCT REVENUE RANK
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
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM ProductRevenue

ORDER BY
    revenue_rank,
    product_id;
GO


/* ==========================================================
   8. PRODUCT UNITS RANK
   ========================================================== */

;WITH ProductUnits AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity)
            AS units_sold

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

    DENSE_RANK() OVER
    (
        ORDER BY units_sold DESC
    ) AS units_rank

FROM ProductUnits

ORDER BY
    units_rank,
    product_id;
GO


/* ==========================================================
   9. REVENUE vs UNITS

   High revenue does not necessarily mean
   high unit volume.

   This report displays both dimensions.
   ========================================================== */

;WITH ProductPerformance AS
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

    DENSE_RANK() OVER
    (
        ORDER BY units_sold DESC
    ) AS units_rank,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM ProductPerformance

ORDER BY revenue DESC;
GO


/* ==========================================================
   10. PRODUCT CUSTOMER REACH

   Number of distinct Completed customers
   for each product.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    COUNT(DISTINCT o.customer_id)
        AS customer_count

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY customer_count DESC;
GO


/* ==========================================================
   11. PRODUCT ORDER REACH

   How many distinct Completed orders contain
   each product?
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    COUNT(DISTINCT o.order_id)
        AS completed_order_count

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY completed_order_count DESC;
GO


/* ==========================================================
   12. CATEGORY PERFORMANCE
   ========================================================== */

SELECT
    p.category,

    COUNT(DISTINCT p.product_id)
        AS products_sold,

    COUNT(DISTINCT o.order_id)
        AS completed_orders,

    COUNT(DISTINCT o.customer_id)
        AS customers,

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

GROUP BY p.category

ORDER BY revenue DESC;
GO


/* ==========================================================
   13. CATEGORY REVENUE SHARE
   ========================================================== */

;WITH CategoryRevenue AS
(
    SELECT
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
    ) AS revenue_share_percent,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS category_revenue_rank

FROM CategoryRevenue

ORDER BY category_revenue_rank;
GO


/* ==========================================================
   14. PRODUCT SHARE WITHIN CATEGORY
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
   15. CATEGORY PRODUCT RANKING
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
   16. TOP PRODUCT PER CATEGORY

   ROW_NUMBER selects exactly one product
   from each category.

   product_id breaks revenue ties.
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
   17. TOP 2 PRODUCTS PER CATEGORY
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
        ) AS category_position,

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
    category_position,
    category_revenue_percent

FROM ProductAnalytics

WHERE category_position <= 2

ORDER BY
    category,
    category_position;
GO


/* ==========================================================
   18. PRODUCTS NEVER ORDERED

   No order_items at all, regardless of order status.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity

FROM training.products AS p

WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.product_id = p.product_id
)

ORDER BY p.product_name;
GO


/* ==========================================================
   19. PRODUCTS NEVER IN COMPLETED ORDERS

   Different from "never ordered."

   A product may appear only in Cancelled orders.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity

FROM training.products AS p

WHERE NOT EXISTS
(
    SELECT 1

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
)

ORDER BY p.product_name;
GO


/* ==========================================================
   20. ALL PRODUCTS WITH COMPLETED UNITS

   Keep products with zero Completed activity.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity
                ELSE 0
            END
        ),
        0
    ) AS completed_units

FROM training.products AS p

LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

LEFT JOIN training.orders AS o
    ON oi.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY completed_units DESC;
GO


/* ==========================================================
   21. ALL PRODUCTS WITH COMPLETED REVENUE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

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

FROM training.products AS p

LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

LEFT JOIN training.orders AS o
    ON oi.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY completed_revenue DESC;
GO


/* ==========================================================
   22. ALL PRODUCT PERFORMANCE

   One row per catalog product.

   Includes products with zero Completed activity.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity,
    p.is_active,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'Completed'
                THEN o.order_id
        END
    ) AS completed_order_count,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'Completed'
                THEN o.customer_id
        END
    ) AS customer_count,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity
                ELSE 0
            END
        ),
        0
    ) AS units_sold,

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

FROM training.products AS p

LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

LEFT JOIN training.orders AS o
    ON oi.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity,
    p.is_active

ORDER BY revenue DESC;
GO


/* ==========================================================
   23. INVENTORY STATUS

   Illustrative thresholds.

   These are business rules, not universal rules.
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    stock_quantity,

    CASE
        WHEN stock_quantity = 0
            THEN 'Out of Stock'

        WHEN stock_quantity <= 20
            THEN 'Low Stock'

        ELSE 'Healthy Stock'
    END AS stock_status

FROM training.products

ORDER BY stock_quantity;
GO


/* ==========================================================
   24. LOW-STOCK ACTIVE PRODUCTS
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity

FROM training.products

WHERE is_active = 1
  AND stock_quantity <= 20

ORDER BY stock_quantity;
GO


/* ==========================================================
   25. LOW STOCK + DEMAND

   Combine stock with Completed demand.

   High sales + low stock can indicate
   replenishment priority.
   ========================================================== */

;WITH ProductDemand AS
(
    SELECT
        p.product_id,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity
                    ELSE 0
                END
            ),
            0
        ) AS units_sold

    FROM training.products AS p

    LEFT JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    LEFT JOIN training.orders AS o
        ON oi.order_id = o.order_id

    GROUP BY p.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    pd.units_sold,

    CASE
        WHEN p.stock_quantity = 0
            THEN 'Out of Stock'

        WHEN p.stock_quantity <= 20
             AND pd.units_sold > 0
            THEN 'Replenishment Priority'

        WHEN p.stock_quantity <= 20
            THEN 'Low Stock'

        ELSE 'Healthy Stock'
    END AS inventory_signal

FROM training.products AS p

INNER JOIN ProductDemand AS pd
    ON p.product_id = pd.product_id

WHERE p.is_active = 1

ORDER BY
    pd.units_sold DESC,
    p.stock_quantity;
GO


/* ==========================================================
   26. UNSOLD STOCK

   Products with stock but no Completed sales.

   Possible business question:
   Is inventory tied up in products with no
   completed demand in the observed period?
   ========================================================== */

;WITH ProductSales AS
(
    SELECT
        p.product_id,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity
                    ELSE 0
                END
            ),
            0
        ) AS units_sold

    FROM training.products AS p

    LEFT JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    LEFT JOIN training.orders AS o
        ON oi.order_id = o.order_id

    GROUP BY p.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.stock_quantity,
    ps.units_sold

FROM training.products AS p

INNER JOIN ProductSales AS ps
    ON p.product_id = ps.product_id

WHERE p.stock_quantity > 0
  AND ps.units_sold = 0

ORDER BY p.stock_quantity DESC;
GO


/* ==========================================================
   27. PRODUCT SELL-THROUGH PROXY

   IMPORTANT:

   This is only a training proxy.

   Formula:

   units_sold /
   (units_sold + current_stock)

   A true sell-through metric normally requires
   inventory received / beginning inventory data.
   ========================================================== */

;WITH ProductSales AS
(
    SELECT
        p.product_id,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity
                    ELSE 0
                END
            ),
            0
        ) AS units_sold

    FROM training.products AS p

    LEFT JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    LEFT JOIN training.orders AS o
        ON oi.order_id = o.order_id

    GROUP BY p.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity,
    ps.units_sold,

    ps.units_sold * 100.0
    /
    NULLIF(
        ps.units_sold + p.stock_quantity,
        0
    ) AS sell_through_proxy_percent

FROM training.products AS p

INNER JOIN ProductSales AS ps
    ON p.product_id = ps.product_id

ORDER BY sell_through_proxy_percent DESC;
GO


/* ==========================================================
   28. AVERAGE TRANSACTION UNIT PRICE BY PRODUCT

   This is average order-item unit price,
   not weighted average selling price.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    AVG(oi.unit_price)
        AS average_line_unit_price

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY average_line_unit_price DESC;
GO


/* ==========================================================
   29. WEIGHTED AVERAGE SELLING PRICE

   ASP =
   revenue / units sold

   This correctly weights unit prices by quantity.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(oi.quantity)
        AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) * 1.0
    /
    NULLIF(
        SUM(oi.quantity),
        0
    ) AS average_selling_price

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name

ORDER BY revenue DESC;
GO


/* ==========================================================
   30. CATALOG PRICE vs SELLING PRICE

   Useful for spotting differences between current
   catalog price and realized transaction pricing.

   Do not assume current catalog price was the intended
   price at historical order time.
   ========================================================== */

;WITH ProductSales AS
(
    SELECT
        oi.product_id,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue,

        SUM(oi.quantity)
            AS units_sold

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,

    p.price AS current_catalog_price,

    ps.revenue * 1.0
    /
    NULLIF(
        ps.units_sold,
        0
    ) AS average_selling_price

FROM ProductSales AS ps

INNER JOIN training.products AS p
    ON ps.product_id = p.product_id

ORDER BY p.product_id;
GO


/* ==========================================================
   31. MONTHLY PRODUCT PERFORMANCE

   Grain:
   one product-month.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    p.product_id,
    p.product_name,

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

GROUP BY
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ),
    p.product_id,
    p.product_name

ORDER BY
    order_month,
    revenue DESC;
GO


/* ==========================================================
   32. PRODUCT MONTH-OVER-MONTH REVENUE

   Only months with product revenue appear.

   Missing months are not automatically filled.
   ========================================================== */

;WITH MonthlyProductRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

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
        ),
        p.product_id,
        p.product_name
),
RevenueHistory AS
(
    SELECT
        order_month,
        product_id,
        product_name,
        revenue,

        LAG(revenue) OVER
        (
            PARTITION BY product_id
            ORDER BY order_month
        ) AS previous_revenue

    FROM MonthlyProductRevenue
)
SELECT
    order_month,
    product_id,
    product_name,
    revenue,
    previous_revenue,

    revenue - previous_revenue
        AS revenue_change,

    (revenue - previous_revenue) * 100.0
    /
    NULLIF(
        previous_revenue,
        0
    ) AS growth_percent

FROM RevenueHistory

ORDER BY
    product_id,
    order_month;
GO


/* ==========================================================
   33. PRODUCT REVENUE CONCENTRATION
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
   34. CATEGORY PRODUCT COVERAGE

   Compare:

   products in catalog

   vs

   products with Completed sales.
   ========================================================== */

;WITH CategoryCatalog AS
(
    SELECT
        category,
        COUNT(*) AS catalog_products

    FROM training.products

    GROUP BY category
),
CategorySold AS
(
    SELECT
        p.category,

        COUNT(DISTINCT p.product_id)
            AS sold_products

    FROM training.products AS p

    INNER JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY p.category
)
SELECT
    cc.category,
    cc.catalog_products,

    COALESCE(
        cs.sold_products,
        0
    ) AS sold_products,

    COALESCE(
        cs.sold_products,
        0
    ) * 100.0
    /
    NULLIF(
        cc.catalog_products,
        0
    ) AS product_sales_coverage_percent

FROM CategoryCatalog AS cc

LEFT JOIN CategorySold AS cs
    ON cc.category = cs.category

ORDER BY product_sales_coverage_percent DESC;
GO


/* ==========================================================
   35. PRODUCT REVENUE RECONCILIATION

   Sum of product revenue should equal total
   Completed revenue.
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
        AS product_revenue_total

FROM ProductRevenue;
GO


/* ==========================================================
   36. DIRECT REVENUE CHECK
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
   37. UNIT RECONCILIATION

   Sum of product units should equal total
   Completed units.
   ========================================================== */

;WITH ProductUnits AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
)
SELECT
    SUM(units_sold)
        AS product_units_total

FROM ProductUnits;
GO


/* ==========================================================
   38. DIRECT UNIT CHECK
   ========================================================== */

SELECT
    SUM(oi.quantity)
        AS direct_completed_units

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   39. PRODUCT DATA QUALITY CHECK

   Completed order items should reference valid
   products because of the Foreign Key.

   This query should return no rows.
   ========================================================== */

SELECT
    oi.order_item_id,
    oi.product_id

FROM training.order_items AS oi

LEFT JOIN training.products AS p
    ON oi.product_id = p.product_id

WHERE p.product_id IS NULL;
GO


/* ==========================================================
   40. FINAL PRODUCT ANALYTICS REPORT

   One row per catalog product.

   Includes products with zero Completed sales.

   Metrics:

   - Catalog properties
   - Completed order count
   - Customer reach
   - Units sold
   - Revenue
   - Revenue share
   - Revenue rank
   - Category revenue
   - Category share
   - Category rank
   - Inventory signal
   ========================================================== */

;WITH ProductBase AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        p.cost,
        p.stock_quantity,
        p.is_active,

        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) AS completed_order_count,

        COUNT(
            DISTINCT CASE
                WHEN o.order_status = 'Completed'
                    THEN o.customer_id
            END
        ) AS customer_count,

        COALESCE(
            SUM(
                CASE
                    WHEN o.order_status = 'Completed'
                        THEN oi.quantity
                    ELSE 0
                END
            ),
            0
        ) AS units_sold,

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

    FROM training.products AS p

    LEFT JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    LEFT JOIN training.orders AS o
        ON oi.order_id = o.order_id

    GROUP BY
        p.product_id,
        p.product_name,
        p.category,
        p.price,
        p.cost,
        p.stock_quantity,
        p.is_active
),
ProductAnalytics AS
(
    SELECT
        product_id,
        product_name,
        category,
        price,
        cost,
        stock_quantity,
        is_active,
        completed_order_count,
        customer_count,
        units_sold,
        revenue,

        SUM(revenue) OVER ()
            AS total_revenue,

        SUM(revenue) OVER
        (
            PARTITION BY category
        ) AS category_revenue,

        DENSE_RANK() OVER
        (
            ORDER BY revenue DESC
        ) AS revenue_rank,

        DENSE_RANK() OVER
        (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS category_revenue_rank

    FROM ProductBase
)
SELECT
    product_id,
    product_name,
    category,
    price,
    cost,
    stock_quantity,
    is_active,

    completed_order_count,
    customer_count,
    units_sold,
    revenue,

    revenue * 100.0
    /
    NULLIF(
        total_revenue,
        0
    ) AS revenue_share_percent,

    revenue_rank,

    category_revenue,

    revenue * 100.0
    /
    NULLIF(
        category_revenue,
        0
    ) AS category_revenue_percent,

    category_revenue_rank,

    CASE
        WHEN stock_quantity = 0
            THEN 'Out of Stock'

        WHEN stock_quantity <= 20
             AND units_sold > 0
            THEN 'Replenishment Priority'

        WHEN stock_quantity <= 20
            THEN 'Low Stock'

        WHEN units_sold = 0
             AND stock_quantity > 0
            THEN 'Unsold Stock'

        ELSE 'Healthy Stock'
    END AS inventory_signal

FROM ProductAnalytics

ORDER BY
    revenue DESC,
    product_id;
GO


/* ==========================================================
   FINAL BUSINESS DEFINITIONS

   UNITS SOLD:

       SUM(quantity)

       from Completed orders.


   PRODUCT REVENUE:

       SUM(quantity * unit_price)

       from Completed orders.


   PRODUCT ORDER COUNT:

       COUNT(DISTINCT order_id)

       for Completed orders.


   PRODUCT CUSTOMER COUNT:

       COUNT(DISTINCT customer_id)

       for Completed orders.


   PRODUCT REVENUE SHARE:

       Product Completed Revenue
       /
       Total Completed Revenue
       * 100


   CATEGORY SHARE:

       Product Revenue
       /
       Category Revenue
       * 100


   AVERAGE SELLING PRICE:

       Revenue
       /
       Units Sold


   IMPORTANT:

   - Units are SUM(quantity), not COUNT(*).
   - Use transactional unit_price for revenue.
   - Distinguish "never ordered" from
     "never in a Completed order."
   - Keep unsold products using LEFT JOIN when needed.
   - Inventory signals in this file are illustrative.
   - A proper sell-through rate needs richer
     inventory history.
   - Reconcile product revenue with total revenue.
   - Reconcile product units with total Completed units.

============================================================
END OF PRODUCT ANALYSIS
============================================================
*/