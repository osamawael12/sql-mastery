/*
============================================================
SQL MASTERY
04 - JOINS

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - FIRST INNER JOIN
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
   EXERCISE 2 - CUSTOMER ORDERS
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
   EXERCISE 3 - JOIN + WHERE
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
ORDER BY o.order_date DESC;
GO


/* ==========================================================
   EXERCISE 4 - JOIN + DATE FILTER
   ========================================================== */

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_date >= '2025-03-01'
  AND o.order_date <  '2025-04-01'
ORDER BY o.order_date;
GO


/* ==========================================================
   EXERCISE 5 - LEFT JOIN
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
   EXERCISE 6 - CUSTOMERS WITHOUT ORDERS
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
   EXERCISE 7 - RIGHT JOIN
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM training.orders AS o
RIGHT JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
GO


/* ==========================================================
   EXERCISE 8 - CROSS JOIN
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
   EXERCISE 9 - CROSS JOIN COUNT
   ========================================================== */

SELECT
    COUNT(*) AS combination_count
FROM training.customers AS c
CROSS JOIN training.products AS p;
GO


/* ==========================================================
   EXERCISE 10 - ORDERS + ORDER ITEMS
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
   EXERCISE 11 - ORDER ITEMS + PRODUCTS
   ========================================================== */

SELECT
    oi.order_id,
    p.product_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.order_items AS oi
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id;
GO


/* ==========================================================
   EXERCISE 12 - THREE TABLE JOIN
   ========================================================== */

SELECT
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
ORDER BY o.order_id;
GO


/* ==========================================================
   EXERCISE 13 - CUSTOMER ORDER ITEMS
   ========================================================== */

SELECT
    c.customer_name,
    o.order_id,
    oi.product_id,
    oi.quantity
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
GO


/* ==========================================================
   EXERCISE 14 - FOUR TABLE JOIN
   ========================================================== */

SELECT
    c.customer_name,
    o.order_id,
    o.order_date,
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
ORDER BY o.order_id;
GO


/* ==========================================================
   EXERCISE 15 - LINE VALUE
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
   EXERCISE 16 - COMPLETED SALES DETAIL
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
ORDER BY o.order_id;
GO


/* ==========================================================
   EXERCISE 17 - COUNT ORDERS PER CUSTOMER
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
   EXERCISE 18 - COMPLETED ORDERS PER CUSTOMER
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
   EXERCISE 19 - NO COMPLETED ORDERS
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
   EXERCISE 20 - CUSTOMER SPENDING
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
   EXERCISE 21 - COMPLETED CUSTOMER SPENDING
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
   EXERCISE 22 - CUSTOMER PERFORMANCE
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
   EXERCISE 23 - PRODUCT DEMAND
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
   EXERCISE 24 - PRODUCT SALES VALUE
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
   EXERCISE 25 - COMPLETED PRODUCT PERFORMANCE
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
   EXERCISE 26 - INCLUDE UNSOLD PRODUCTS
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
   EXERCISE 27 - PRODUCTS NEVER ORDERED
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category
FROM training.products AS p
LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;
GO


/* ==========================================================
   EXERCISE 28 - TOTAL UNITS FOR ALL PRODUCTS
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
   EXERCISE 29 - ORDER TOTAL
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
   EXERCISE 30 - HIGH VALUE COMPLETED ORDERS
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
   EXERCISE 31 - DISTINCT PRODUCTS PER CUSTOMER
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
   EXERCISE 32 - CUSTOMER PRODUCT HISTORY
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
   EXERCISE 33 - CUSTOMERS WITH MULTIPLE ORDERS
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
   EXERCISE 34 - CATEGORY PERFORMANCE
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
   EXERCISE 35 - COMPLETED CATEGORY PERFORMANCE
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
   EXERCISE 36 - TOP CUSTOMER
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
   EXERCISE 37 - TOP PRODUCT
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
   EXERCISE 38 - ACTIVE CUSTOMERS WITHOUT ORDERS
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
   EXERCISE 39 - THINK ABOUT LEFT JOIN
   ========================================================== */

/*
Answer:

1. No.

2. Query B keeps customers without Completed orders.

3. Query A performs the LEFT JOIN first and then:

       WHERE o.order_status = 'Completed'

   removes rows where o.order_status is NULL.

   Therefore unmatched customers disappear.

   Query B places the filter inside ON:

       ON c.customer_id = o.customer_id
      AND o.order_status = 'Completed'

   This controls which orders can match while still
   preserving every row from customers.
*/


/* ==========================================================
   EXERCISE 40 - COUNT AFTER LEFT JOIN
   ========================================================== */

/*
Answer:

1. COUNT(*) can return 1.

2. COUNT(o.order_id) returns 0.

3. COUNT(o.order_id) should normally be used to
   count actual orders after this LEFT JOIN.

Explanation:

LEFT JOIN preserves the customer row even if no
matching order exists.

COUNT(*) counts that preserved result row.

COUNT(o.order_id) ignores NULL.
*/


/* ==========================================================
   EXERCISE 41 - ROW MULTIPLICATION
   ========================================================== */

/*
Answer:

1. 5 joined rows.

2. COUNT(o.order_id) = 5.

3. COUNT(DISTINCT o.order_id) = 2.

4. COUNT(DISTINCT o.order_id).

Explanation:

Joining orders to order_items changes the result grain
to one row per order-item line.

Order 1 appears three times.
Order 2 appears two times.

There are five result rows but only two unique orders.
*/


/* ==========================================================
   EXERCISE 42 - RESULT GRAIN
   ========================================================== */

/*
Answer:

C. One order-item line.

Explanation:

order_items is the detailed transactional table in
this join path.

Each row connects one order to one product and contains
its quantity and unit price.
*/


/* ==========================================================
   EXERCISE 43 - CHOOSE THE JOIN
   ========================================================== */

/*
Answer:

1. INNER JOIN

2. LEFT JOIN

3. LEFT JOIN
   followed by checking the right-side key for NULL

4. INNER JOIN

5. LEFT JOIN
*/


/* ==========================================================
   EXERCISE 44 - JOIN KEYS
   ========================================================== */

/*
Answer:

1.

customers.customer_id
    =
orders.customer_id


2.

orders.order_id
    =
order_items.order_id


3.

products.product_id
    =
order_items.product_id
*/


/* ==========================================================
   EXERCISE 45 - BUSINESS METRICS AFTER JOIN
   ========================================================== */

/*
Answer:

COUNT(*):

Counts result rows after the JOIN.


COUNT(o.order_id):

Counts non-NULL order_id occurrences.
After joining to order_items, the same order ID
can be counted multiple times.


COUNT(DISTINCT o.order_id):

Counts unique orders.


COUNT(oi.order_item_id):

Counts actual order-item lines.


SUM(oi.quantity):

Counts the total number of units represented by
the order-item rows.
*/


/* ==========================================================
   CHALLENGE 1 - COMPLETE SALES REPORT
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
   CHALLENGE 2 - CUSTOMER PERFORMANCE
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS completed_order_count,
    COUNT(DISTINCT oi.product_id) AS distinct_products,
    SUM(oi.quantity) AS total_units,
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
HAVING SUM(oi.quantity * oi.unit_price) >= 1000
ORDER BY revenue DESC;
GO


/* ==========================================================
   CHALLENGE 3 - PRODUCT PERFORMANCE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT o.customer_id) AS customer_count,
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
   CHALLENGE 4 - ALL CUSTOMER ORDER SUMMARY

   CASE is covered fully in Chapter 05.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
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
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_orders DESC;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL JOIN CHALLENGE
   ========================================================== */

SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN training.products AS p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) >= 1000
ORDER BY revenue DESC;
GO


/* ==========================================================
   FINAL RECAP

   CORE RELATIONSHIPS:

   customers.customer_id
       =
   orders.customer_id

   orders.order_id
       =
   order_items.order_id

   products.product_id
       =
   order_items.product_id


   INNER JOIN:
       Matching rows only.

   LEFT JOIN:
       Preserve every row from the left table.

   LEFT JOIN + right key IS NULL:
       Find unmatched records.

   COUNT(*) after LEFT JOIN:
       Can count a preserved row even when there
       is no right-side entity.

   COUNT(right_table.key):
       Ignores unmatched NULL values.

   COUNT(DISTINCT key):
       Important when one-to-many JOINs duplicate
       an entity across result rows.

   ROW MULTIPLICATION:
       A one-to-many JOIN creates multiple rows
       for the parent when multiple child rows exist.

   RESULT GRAIN:
       Always know what one output row represents.

   LEFT JOIN FILTERING:

       WHERE right_table.column = ...
           can remove unmatched rows.

       ON ... AND right_table.column = ...
           restricts matches while preserving
           left-side rows.

   JOIN does not automatically mean the query
   is logically correct.

   Always verify:

   - Which tables are required?
   - Which keys connect them?
   - Which side must be preserved?
   - What does one result row represent?
   - Can the JOIN multiply rows?
   - What exactly are you counting?

============================================================
END OF CHAPTER 04
============================================================
*/