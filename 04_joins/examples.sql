/*
============================================================
SQL MASTERY
04 - JOINS

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- Table Aliases
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- CROSS JOIN
- Multiple JOINs
- JOIN + WHERE
- JOIN + Aggregation
- Unmatched Rows
- Row Multiplication
- COUNT after JOIN
- ON vs WHERE
- Business Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. REVIEW - CUSTOMERS
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers;
GO


/* ==========================================================
   2. REVIEW - ORDERS
   ========================================================== */

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders;
GO


/* ==========================================================
   3. FIRST INNER JOIN

   Relationship:

   customers.customer_id
       =
   orders.customer_id

   One result row represents one order.
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
GO


/* ==========================================================
   4. JOIN IS INNER JOIN

   JOIN and INNER JOIN are equivalent here.
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_status
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
GO


/* ==========================================================
   5. QUALIFIED COLUMN NAMES

   Both tables contain customer_id.

   Use aliases to make the source explicit.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.customer_id AS order_customer_id
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/* ==========================================================
   6. ONE-TO-MANY RELATIONSHIP

   One customer can have multiple orders.

   Therefore customer information can appear
   multiple times.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
ORDER BY
    c.customer_id,
    o.order_date;
GO


/* ==========================================================
   7. INNER JOIN + WHERE

   Completed orders with customer information.
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
ORDER BY o.order_date;
GO


/* ==========================================================
   8. JOIN + DATE FILTER

   Completed orders during March 2025.
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
  AND o.order_date >= '2025-03-01'
  AND o.order_date <  '2025-04-01'
ORDER BY o.order_date;
GO


/* ==========================================================
   9. LEFT JOIN

   Keep ALL customers.

   Add their orders when a match exists.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
ORDER BY
    c.customer_id,
    o.order_id;
GO


/* ==========================================================
   10. INNER JOIN vs LEFT JOIN

   INNER JOIN:
   customers with matching orders only.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/*
LEFT JOIN:
all customers, including customers with no orders.
*/

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/* ==========================================================
   11. FIND CUSTOMERS WITHOUT ORDERS

   Anti-join pattern:

   LEFT JOIN
   +
   WHERE right_table_key IS NULL
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
GO


/* ==========================================================
   12. RIGHT JOIN

   Keep every row from the right table.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.orders AS o
RIGHT JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
GO


/*
The same business idea is usually easier to read
using LEFT JOIN:
*/

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/* ==========================================================
   13. FULL OUTER JOIN

   Keep matched and unmatched rows from both sides.

   Foreign key constraints mean some unmatched scenarios
   may not exist in the current dataset.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_status
FROM training.customers AS c
FULL OUTER JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
GO


/* ==========================================================
   14. CROSS JOIN

   Every customer combined with every product.
   ========================================================== */

SELECT
    c.customer_name,
    p.product_name
FROM training.customers AS c
CROSS JOIN training.products AS p
ORDER BY
    c.customer_name,
    p.product_name;
GO


/* ==========================================================
   15. COUNT CROSS JOIN ROWS

   Number of combinations:

   customer count * product count
   ========================================================== */

SELECT
    COUNT(*) AS combination_count
FROM training.customers AS c
CROSS JOIN training.products AS p;
GO


/* ==========================================================
   16. ORDERS + ORDER_ITEMS

   One order can contain multiple order-item rows.

   Result grain:
   one order-item line.
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,
    oi.order_item_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
ORDER BY
    o.order_id,
    oi.order_item_id;
GO


/* ==========================================================
   17. ORDER_ITEMS + PRODUCTS

   Replace product IDs with descriptive product data.
   ========================================================== */

SELECT
    oi.order_id,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price
FROM training.order_items AS oi
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY oi.order_id;
GO


/* ==========================================================
   18. THREE-TABLE JOIN

   orders
   -> order_items
   -> products
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY
    o.order_id,
    p.product_name;
GO


/* ==========================================================
   19. CUSTOMERS + ORDERS + ORDER_ITEMS

   Show which customer owns each order-item line.
   ========================================================== */

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
ORDER BY
    c.customer_name,
    o.order_id;
GO


/* ==========================================================
   20. FOUR-TABLE JOIN

   customers
   -> orders
   -> order_items
   -> products

   Result grain:
   one order-item line.
   ========================================================== */

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
    o.order_status,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY
    o.order_id,
    p.product_name;
GO


/* ==========================================================
   21. CALCULATED VALUE AFTER JOIN

   line_value:

   quantity * unit_price
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY o.order_id;
GO


/* ==========================================================
   22. COMPLETED SALES DETAIL
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
ORDER BY
    o.order_id,
    p.product_name;
GO


/* ==========================================================
   23. COUNT ORDERS PER CUSTOMER

   LEFT JOIN keeps customers with zero orders.

   COUNT(o.order_id) ignores NULL values.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY order_count DESC;
GO


/* ==========================================================
   24. WHY COUNT(*) CAN BE WRONG AFTER LEFT JOIN

   Customers with no orders still have a preserved
   LEFT JOIN result row.

   COUNT(*) counts that row.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS count_star,
    COUNT(o.order_id) AS actual_order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/* ==========================================================
   25. COMPLETED ORDERS PER CUSTOMER

   Keep all customers.

   Match Completed orders only.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS completed_order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_order_count DESC;
GO


/* ==========================================================
   26. LEFT JOIN + WHERE TRAP

   Although this says LEFT JOIN, the WHERE condition
   removes customers without a Completed order.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_status
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed';
GO


/* ==========================================================
   27. FILTER IN ON

   Business requirement:

   Keep ALL customers.
   Show Completed orders when they exist.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_status
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
ORDER BY c.customer_id;
GO


/* ==========================================================
   28. FIND CUSTOMERS WITH NO COMPLETED ORDERS
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
   AND o.order_status = 'Completed'
WHERE o.order_id IS NULL;
GO


/* ==========================================================
   29. CUSTOMER SPENDING - ALL ORDER STATUSES

   This includes every order represented in order_items.

   Be careful with the business meaning.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spending DESC;
GO


/* ==========================================================
   30. CUSTOMER SPENDING - COMPLETED ONLY

   More realistic recognized sales metric.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS completed_spending
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_spending DESC;
GO


/* ==========================================================
   31. CUSTOMER ORDER COUNT + REVENUE

   COUNT(DISTINCT o.order_id) is important because
   one order can contain multiple order-item rows.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
   32. ROW MULTIPLICATION

   Compare:

   COUNT(o.order_id)

   vs

   COUNT(DISTINCT o.order_id)

   after joining orders to order_items.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS repeated_order_ids,
    COUNT(DISTINCT o.order_id) AS actual_order_count,
    COUNT(oi.order_item_id) AS order_item_count
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/* ==========================================================
   33. PRODUCT DEMAND WITH PRODUCT NAMES
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_units DESC;
GO


/* ==========================================================
   34. PRODUCT REVENUE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS sales_value
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY sales_value DESC;
GO


/* ==========================================================
   35. COMPLETED PRODUCT PERFORMANCE

   Count only Completed orders.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
   36. PRODUCTS INCLUDING UNSOLD PRODUCTS

   LEFT JOIN keeps every product.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) AS order_line_count
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY order_line_count DESC;
GO


/* ==========================================================
   37. FIND PRODUCTS NEVER ORDERED
   ========================================================== */

SELECT
    p.product_id,
    p.product_name
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;
GO


/* ==========================================================
   38. TOTAL UNITS INCLUDING UNSOLD PRODUCTS

   SUM returns NULL when no matching values exist.

   COALESCE converts that NULL to 0.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity), 0) AS total_units
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_units DESC;
GO


/* ==========================================================
   39. COMPLETED UNITS INCLUDING ALL PRODUCTS

   Keep all products.

   Match only order items belonging to Completed orders.

   Because status belongs to orders, we first connect
   order_items to orders.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(
        CASE
            WHEN o.order_status = 'Completed'
            THEN oi.quantity
            ELSE 0
        END
    ), 0) AS completed_units
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
LEFT JOIN training.orders AS o
    ON oi.order_id = o.order_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY completed_units DESC;
GO


/*
CASE will be studied in more detail in
Chapter 05 - Data Transformation.
*/


/* ==========================================================
   40. ORDER TOTAL WITH CUSTOMER NAME
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
ORDER BY order_value DESC;
GO


/* ==========================================================
   41. HIGH VALUE COMPLETED ORDERS

   JOIN + WHERE + GROUP BY + HAVING
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.order_id,
    c.customer_name
HAVING SUM(oi.quantity * oi.unit_price) >= 3000
ORDER BY order_value DESC;
GO


/* ==========================================================
   42. CUSTOMER PRODUCT HISTORY

   Which products appear in each customer's orders?

   One row currently represents a customer-product
   occurrence through an order-item line.
   ========================================================== */

SELECT
    c.customer_name,
    o.order_id,
    p.product_name,
    oi.quantity
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY
    c.customer_name,
    o.order_id;
GO


/* ==========================================================
   43. DISTINCT CUSTOMER-PRODUCT PAIRS

   Which different products has each customer
   ever had in their orders?
   ========================================================== */

SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY
    c.customer_name,
    p.product_name;
GO


/* ==========================================================
   44. CUSTOMER PRODUCT COUNT

   Count different products associated with each customer.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT oi.product_id) AS distinct_product_count
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY distinct_product_count DESC;
GO


/* ==========================================================
   45. CUSTOMERS INCLUDING ZERO ORDERS

   Summary using LEFT JOIN.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS order_count
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    order_count DESC,
    c.customer_name;
GO


/* ==========================================================
   46. CUSTOMERS WITH MORE THAN ONE ORDER

   HAVING filters the customer groups.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;
GO


/* ==========================================================
   47. CATEGORY PERFORMANCE

   Combine products and order_items.
   ========================================================== */

SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS products_ordered,
    SUM(oi.quantity) AS total_units,
    SUM(oi.quantity * oi.unit_price) AS sales_value
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY sales_value DESC;
GO


/* ==========================================================
   48. COMPLETED CATEGORY PERFORMANCE
   ========================================================== */

SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY revenue DESC;
GO


/* ==========================================================
   49. TOP CUSTOMER BY COMPLETED REVENUE
   ========================================================== */

SELECT TOP (1)
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
   50. TOP PRODUCT BY COMPLETED REVENUE
   ========================================================== */

SELECT TOP (1)
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
   51. BUSINESS QUESTION

   Customer performance based on Completed orders.

   Return:

   - customer
   - different completed orders
   - units purchased
   - completed revenue
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity) AS units_purchased,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
   52. BUSINESS QUESTION

   Detailed Completed sales report.
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_value
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
ORDER BY
    o.order_date,
    o.order_id,
    p.product_name;
GO


/* ==========================================================
   53. BUSINESS QUESTION

   Find active customers who have never placed an order.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.city
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
WHERE c.is_active = 1
  AND o.order_id IS NULL;
GO


/* ==========================================================
   54. BUSINESS QUESTION

   Find products that have never appeared
   in an order item.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.product_name;
GO


/* ==========================================================
   55. RESULT GRAIN DEMONSTRATION

   This query has four tables.

   But one row does NOT represent:
   - one customer
   - one order
   - one product

   One row represents:
   one ORDER-ITEM LINE.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    oi.order_item_id,
    p.product_id,
    p.product_name,
    oi.quantity
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY oi.order_item_id;
GO


/* ==========================================================
   56. FINAL ANALYTICAL EXAMPLE

   Completed product performance.

   For each product calculate:

   - Different Completed orders
   - Units sold
   - Revenue

   Keep products with at least 1 unit sold.
   Highest revenue first.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS completed_order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
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
HAVING SUM(oi.quantity) >= 1
ORDER BY revenue DESC;
GO


/* ==========================================================
   FINAL RECAP

   INNER JOIN
       Matched rows only.

   LEFT JOIN
       Keep all rows from the left table.

   RIGHT JOIN
       Keep all rows from the right table.

   FULL OUTER JOIN
       Keep rows from both sides.

   CROSS JOIN
       Every possible combination.

   ON
       Defines how tables relate.

   LEFT JOIN + IS NULL
       Common pattern for finding unmatched records.

   COUNT(key)
       Useful after LEFT JOIN because NULL is ignored.

   COUNT(DISTINCT key)
       Important when another JOIN can repeat an entity.

   RESULT GRAIN
       Always understand what one output row represents.

   LEFT JOIN:
       Be careful whether a right-table filter belongs
       in ON or WHERE.

   Core relationship:

       customers
           |
           v
       orders
           |
           v
       order_items
           |
           v
       products

============================================================
END OF EXAMPLES
============================================================
*/