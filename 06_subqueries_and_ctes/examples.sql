/*
============================================================
SQL MASTERY
06 - SUBQUERIES AND CTEs

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- Scalar Subqueries
- IN
- EXISTS
- NOT EXISTS
- Correlated Subqueries
- Derived Tables
- Pre-Aggregation
- CTEs
- Multiple CTEs
- CTE Pipelines
- Business Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. SCALAR SUBQUERY

   Products priced above the overall average.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price >
(
    SELECT AVG(price)
    FROM training.products
)
ORDER BY price DESC;
GO


/* ==========================================================
   2. VIEW THE INNER QUERY
   ========================================================== */

SELECT
    AVG(price) AS average_price
FROM training.products;
GO


/* ==========================================================
   3. SUBQUERY IN SELECT

   Display the overall average beside every product.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,

    (
        SELECT AVG(price)
        FROM training.products
    ) AS overall_average_price

FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   4. DIFFERENCE FROM AVERAGE
   ========================================================== */

SELECT
    product_name,
    price,

    (
        SELECT AVG(price)
        FROM training.products
    ) AS average_price,

    price -
    (
        SELECT AVG(price)
        FROM training.products
    ) AS difference_from_average

FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   5. MAXIMUM PRICE SUBQUERY

   Returns every product tied at the maximum price.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price =
(
    SELECT MAX(price)
    FROM training.products
);
GO


/* ==========================================================
   6. MINIMUM PRICE SUBQUERY
   ========================================================== */

SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price =
(
    SELECT MIN(price)
    FROM training.products
);
GO


/* ==========================================================
   7. SUBQUERY WITH COUNT

   Customers whose ID belongs to customers with orders.
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
);
GO


/* ==========================================================
   8. IN + BUSINESS CONDITION

   Customers with at least one Completed order.
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
);
GO


/* ==========================================================
   9. CUSTOMERS WITH CANCELLED ORDERS
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id IN
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
);
GO


/* ==========================================================
   10. NOT IN

   This works safely here because orders.customer_id
   is defined NOT NULL.

   In general, be careful when the subquery expression
   can return NULL.
   ========================================================== */

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_id NOT IN
(
    SELECT customer_id
    FROM training.orders
);
GO


/* ==========================================================
   11. EXISTS

   Customers with at least one order.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   12. EXISTS WITH CONDITION

   Customers with at least one Completed order.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   13. NOT EXISTS

   Customers with no orders.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   14. NO COMPLETED ORDERS

   Includes:
   - customers with no orders
   - customers with orders but no Completed order
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   15. PRODUCTS THAT WERE ORDERED
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.product_id = p.product_id
);
GO


/* ==========================================================
   16. PRODUCTS NEVER ORDERED
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi
    WHERE oi.product_id = p.product_id
);
GO


/* ==========================================================
   17. PRODUCTS IN COMPLETED ORDERS

   The subquery itself can contain JOINs.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE EXISTS
(
    SELECT 1
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   18. PRODUCTS NEVER IN A COMPLETED ORDER
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE oi.product_id = p.product_id
      AND o.order_status = 'Completed'
);
GO


/* ==========================================================
   19. CORRELATED SCALAR SUBQUERY

   Count orders for every customer.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS order_count

FROM training.customers AS c
ORDER BY order_count DESC;
GO


/* ==========================================================
   20. COMPLETED ORDERS PER CUSTOMER
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT COUNT(*)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
          AND o.order_status = 'Completed'
    ) AS completed_order_count

FROM training.customers AS c
ORDER BY completed_order_count DESC;
GO


/* ==========================================================
   21. LATEST ORDER DATE PER CUSTOMER
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    (
        SELECT MAX(o.order_date)
        FROM training.orders AS o
        WHERE o.customer_id = c.customer_id
    ) AS latest_order_date

FROM training.customers AS c
ORDER BY latest_order_date DESC;
GO


/* ==========================================================
   22. ABOVE CATEGORY AVERAGE

   Correlated scalar subquery.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM training.products AS p
WHERE p.price >
(
    SELECT AVG(p2.price)
    FROM training.products AS p2
    WHERE p2.category = p.category
)
ORDER BY
    p.category,
    p.price DESC;
GO


/* ==========================================================
   23. DISPLAY CATEGORY AVERAGE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,

    (
        SELECT AVG(p2.price)
        FROM training.products AS p2
        WHERE p2.category = p.category
    ) AS category_average_price

FROM training.products AS p
ORDER BY
    p.category,
    p.price DESC;
GO


/* ==========================================================
   24. ABOVE CATEGORY AVERAGE + DIFFERENCE
   ========================================================== */

SELECT
    p.product_name,
    p.category,
    p.price,

    (
        SELECT AVG(p2.price)
        FROM training.products AS p2
        WHERE p2.category = p.category
    ) AS category_average_price,

    p.price -
    (
        SELECT AVG(p3.price)
        FROM training.products AS p3
        WHERE p3.category = p.category
    ) AS amount_above_average

FROM training.products AS p

WHERE p.price >
(
    SELECT AVG(p4.price)
    FROM training.products AS p4
    WHERE p4.category = p.category
)

ORDER BY amount_above_average DESC;
GO


/* ==========================================================
   25. DERIVED TABLE

   Calculate order values inside FROM.
   ========================================================== */

SELECT
    totals.order_id,
    totals.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   26. FILTER DERIVED TABLE

   Orders worth at least 3000.
   ========================================================== */

SELECT
    totals.order_id,
    totals.order_value
FROM
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
WHERE totals.order_value >= 3000
ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   27. JOIN A DERIVED TABLE

   Calculate order value first.
   Then connect it to orders and customers.
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_status,
    totals.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
    ON o.order_id = totals.order_id

ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   28. COMPLETED HIGH-VALUE ORDERS
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    totals.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
) AS totals
    ON o.order_id = totals.order_id

WHERE o.order_status = 'Completed'
  AND totals.order_value >= 3000

ORDER BY totals.order_value DESC;
GO


/* ==========================================================
   29. FIRST CTE
   ========================================================== */

;WITH ExpensiveProducts AS
(
    SELECT
        product_id,
        product_name,
        price
    FROM training.products
    WHERE price >= 5000
)
SELECT
    product_id,
    product_name,
    price
FROM ExpensiveProducts
ORDER BY price DESC;
GO


/* ==========================================================
   30. CTE WITH AGGREGATION

   One row per order.
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
    order_id,
    order_value
FROM OrderTotals
ORDER BY order_value DESC;
GO


/* ==========================================================
   31. FILTER A CTE
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
    order_id,
    order_value
FROM OrderTotals
WHERE order_value >= 3000
ORDER BY order_value DESC;
GO


/* ==========================================================
   32. CTE + JOIN
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
    c.customer_name,
    o.order_date,
    o.order_status,
    ot.order_value
FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   33. MULTIPLE CTEs
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id,
        order_date
    FROM training.orders
    WHERE order_status = 'Completed'
)
SELECT
    co.order_id,
    co.customer_id,
    co.order_date,
    ot.order_value
FROM CompletedOrders AS co

INNER JOIN OrderTotals AS ot
    ON co.order_id = ot.order_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   34. CTE DEPENDING ON EARLIER CTE
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
HighValueOrders AS
(
    SELECT
        order_id,
        order_value
    FROM OrderTotals
    WHERE order_value >= 3000
)
SELECT
    order_id,
    order_value
FROM HighValueOrders
ORDER BY order_value DESC;
GO


/* ==========================================================
   35. THREE-STAGE CTE PIPELINE
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CompletedOrderValues AS
(
    SELECT
        co.order_id,
        co.customer_id,
        ot.order_value
    FROM CompletedOrders AS co
    INNER JOIN OrderTotals AS ot
        ON co.order_id = ot.order_id
)
SELECT
    order_id,
    customer_id,
    order_value
FROM CompletedOrderValues
ORDER BY order_value DESC;
GO


/* ==========================================================
   36. CUSTOMER COMPLETED REVENUE WITH CTEs
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CustomerRevenue AS
(
    SELECT
        co.customer_id,
        SUM(ot.order_value) AS revenue
    FROM CompletedOrders AS co

    INNER JOIN OrderTotals AS ot
        ON co.order_id = ot.order_id

    GROUP BY co.customer_id
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
   37. HIGH-VALUE CUSTOMERS
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
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

WHERE cr.revenue >= 3000
ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   38. PRODUCT PERFORMANCE CTE
   ========================================================== */

;WITH ProductSales AS
(
    SELECT
        oi.product_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity) AS units_sold,
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
    ps.order_count,
    ps.units_sold,
    ps.revenue
FROM ProductSales AS ps

INNER JOIN training.products AS p
    ON ps.product_id = p.product_id

ORDER BY ps.revenue DESC;
GO


/* ==========================================================
   39. CUSTOMER ORDER METRICS CTE

   Keep all customers.
   ========================================================== */

;WITH CustomerOrderMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders,

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
        ) AS cancelled_orders

    FROM training.customers AS c

    LEFT JOIN training.orders AS o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    m.total_orders,
    m.completed_orders,
    m.cancelled_orders
FROM CustomerOrderMetrics AS m

INNER JOIN training.customers AS c
    ON m.customer_id = c.customer_id

ORDER BY m.total_orders DESC;
GO


/* ==========================================================
   40. FILTER CALCULATED CUSTOMER METRICS

   Customers with:
   - at least 2 orders
   - at least 1 Completed order
   ========================================================== */

;WITH CustomerOrderMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders,

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
    m.total_orders,
    m.completed_orders
FROM CustomerOrderMetrics AS m

INNER JOIN training.customers AS c
    ON m.customer_id = c.customer_id

WHERE m.total_orders >= 2
  AND m.completed_orders >= 1

ORDER BY m.total_orders DESC;
GO


/* ==========================================================
   41. ABOVE-AVERAGE CUSTOMER ORDER COUNT

   Step 1:
   count orders per customer who has orders.

   Step 2:
   calculate the average of those counts.

   Step 3:
   return customers above that average.
   ========================================================== */

;WITH CustomerOrders AS
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM training.orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    co.order_count
FROM CustomerOrders AS co

INNER JOIN training.customers AS c
    ON co.customer_id = c.customer_id

WHERE co.order_count >
(
    SELECT AVG(1.0 * order_count)
    FROM CustomerOrders
)

ORDER BY co.order_count DESC;
GO


/* ==========================================================
   42. ABOVE-AVERAGE CUSTOMER REVENUE

   Average is calculated among customers who generated
   Completed revenue.
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue

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

WHERE cr.revenue >
(
    SELECT AVG(revenue)
    FROM CustomerRevenue
)

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   43. COMPARE CUSTOMER REVENUE TO AVERAGE

   Display both customer revenue and overall
   customer average.
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue

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

    (
        SELECT AVG(revenue)
        FROM CustomerRevenue
    ) AS average_customer_revenue,

    cr.revenue -
    (
        SELECT AVG(revenue)
        FROM CustomerRevenue
    ) AS difference_from_average

FROM CustomerRevenue AS cr

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   44. ORDER VALUE COMPARED TO AVERAGE ORDER VALUE
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
    order_id,
    order_value
FROM OrderTotals
WHERE order_value >
(
    SELECT AVG(order_value)
    FROM OrderTotals
)
ORDER BY order_value DESC;
GO


/* ==========================================================
   45. PRODUCTS ABOVE CATEGORY AVERAGE USING CTE

   Calculate category averages first.
   ========================================================== */

;WITH CategoryAverages AS
(
    SELECT
        category,
        AVG(price) AS average_price
    FROM training.products
    GROUP BY category
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    ca.average_price,
    p.price - ca.average_price AS difference_from_average
FROM training.products AS p

INNER JOIN CategoryAverages AS ca
    ON p.category = ca.category

WHERE p.price > ca.average_price

ORDER BY
    p.category,
    p.price DESC;
GO


/* ==========================================================
   46. EXISTS vs JOIN

   EXISTS version:
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/*
JOIN version.

DISTINCT is needed because one customer
can have multiple orders.
*/

SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM training.customers AS c

INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/* ==========================================================
   47. ACTIVE CUSTOMERS WITHOUT ORDERS
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM training.customers AS c
WHERE c.is_active = 1
  AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
GO


/* ==========================================================
   48. CUSTOMERS WHO BOUGHT A SPECIFIC CATEGORY

   Example:
   Accessories
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE EXISTS
(
    SELECT 1

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.customer_id = c.customer_id
      AND p.category = N'Accessories'
);
GO


/* ==========================================================
   49. CUSTOMERS WHO NEVER BOUGHT ELECTRONICS
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    INNER JOIN training.products AS p
        ON oi.product_id = p.product_id

    WHERE o.customer_id = c.customer_id
      AND p.category = N'Electronics'
);
GO


/* ==========================================================
   50. CUSTOMERS WITH BOTH CONDITIONS

   Customers who:
   - have at least one Completed order
   - have no Cancelled order
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c

WHERE EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)

AND NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Cancelled'
);
GO


/* ==========================================================
   51. PRE-AGGREGATION PIPELINE

   First:
   one row per order.

   Then:
   join to the order/customer data.
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        COUNT(*) AS line_count,
        SUM(quantity) AS total_units,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.customer_name,
    o.order_status,
    ot.line_count,
    ot.total_units,
    ot.order_value
FROM OrderTotals AS ot

INNER JOIN training.orders AS o
    ON ot.order_id = o.order_id

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

ORDER BY ot.order_value DESC;
GO


/* ==========================================================
   52. COMPLETED CUSTOMER PERFORMANCE PIPELINE
   ========================================================== */

;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity) AS units,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
),
CompletedOrders AS
(
    SELECT
        order_id,
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CustomerPerformance AS
(
    SELECT
        co.customer_id,
        COUNT(*) AS completed_orders,
        SUM(ot.units) AS total_units,
        SUM(ot.order_value) AS revenue

    FROM CompletedOrders AS co

    INNER JOIN OrderTotals AS ot
        ON co.order_id = ot.order_id

    GROUP BY co.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cp.completed_orders,
    cp.total_units,
    cp.revenue
FROM CustomerPerformance AS cp

INNER JOIN training.customers AS c
    ON cp.customer_id = c.customer_id

ORDER BY cp.revenue DESC;
GO


/* ==========================================================
   53. CUSTOMER CLASSIFICATION USING CTE
   ========================================================== */

;WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,

        COUNT(o.order_id) AS total_orders,

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
        WHEN cm.total_orders = 0
            THEN 'No Orders'

        WHEN cm.completed_orders >= 2
            THEN 'Repeat Customer'

        WHEN cm.completed_orders = 1
            THEN 'Customer'

        ELSE 'No Completed Orders'
    END AS customer_type

FROM CustomerMetrics AS cm

INNER JOIN training.customers AS c
    ON cm.customer_id = c.customer_id

ORDER BY
    cm.completed_orders DESC,
    c.customer_name;
GO


/* ==========================================================
   54. MULTI-STAGE PRODUCT ANALYSIS

   Stage 1:
   Completed product sales.

   Stage 2:
   Calculate revenue segment.

   Stage 3:
   Return product descriptions.
   ========================================================== */

;WITH ProductSales AS
(
    SELECT
        oi.product_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue

    FROM training.order_items AS oi

    INNER JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY oi.product_id
),
ProductSegments AS
(
    SELECT
        product_id,
        order_count,
        units_sold,
        revenue,

        CASE
            WHEN revenue >= 10000 THEN 'High Revenue'
            WHEN revenue >= 3000 THEN 'Medium Revenue'
            ELSE 'Low Revenue'
        END AS revenue_segment

    FROM ProductSales
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    ps.order_count,
    ps.units_sold,
    ps.revenue,
    ps.revenue_segment
FROM ProductSegments AS ps

INNER JOIN training.products AS p
    ON ps.product_id = p.product_id

ORDER BY ps.revenue DESC;
GO


/* ==========================================================
   55. FINAL BUSINESS EXAMPLE

   Find customers whose Completed revenue is above
   the average Completed revenue among customers
   who generated Completed revenue.

   Return:

   customer_id
   customer_name
   completed_orders
   revenue
   average_revenue
   difference_from_average
   ========================================================== */

;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id)
            AS completed_orders,

        SUM(oi.quantity * oi.unit_price)
            AS revenue

    FROM training.orders AS o

    INNER JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.customer_id
),
RevenueBenchmark AS
(
    SELECT
        AVG(revenue) AS average_revenue
    FROM CustomerRevenue
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.completed_orders,
    cr.revenue,
    rb.average_revenue,
    cr.revenue - rb.average_revenue
        AS difference_from_average

FROM CustomerRevenue AS cr

CROSS JOIN RevenueBenchmark AS rb

INNER JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

WHERE cr.revenue > rb.average_revenue

ORDER BY cr.revenue DESC;
GO


/* ==========================================================
   FINAL RECAP

   SCALAR SUBQUERY:
       Returns one value.

   IN:
       Match against a set returned by a subquery.

   EXISTS:
       At least one matching row exists.

   NOT EXISTS:
       No matching row exists.

   CORRELATED SUBQUERY:
       Inner query references the outer query.

   DERIVED TABLE:
       Subquery inside FROM.

   PRE-AGGREGATION:
       Aggregate detailed rows before later JOINs.

   CTE:

       ;WITH Name AS
       (
           SELECT ...
       )
       SELECT ...
       FROM Name;

   MULTIPLE CTEs:

       ;WITH A AS
       (
           ...
       ),
       B AS
       (
           ...
       )
       SELECT ...;

   CTE PIPELINE:

       Raw data
           ->
       Aggregate
           ->
       Filter
           ->
       Transform
           ->
       Join
           ->
       Final report


   IMPORTANT:

   CTEs are primarily a query-structuring tool.

   Do not assume:

       CTE = temporary table
       CTE = cached result
       CTE = automatically faster query

   Always choose the structure based on:

       correctness
       grain
       readability
       maintainability
       execution plan when performance matters

============================================================
END OF EXAMPLES
============================================================
*/