/*
============================================================
SQL MASTERY
03 - AGGREGATION

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - COUNT ROWS
   ========================================================== */

SELECT
    COUNT(*) AS customer_count
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 2 - COUNT PRODUCTS
   ========================================================== */

SELECT
    COUNT(*) AS product_count
FROM training.products;
GO


/* ==========================================================
   EXERCISE 3 - COUNT ORDERS
   ========================================================== */

SELECT
    COUNT(*) AS order_count
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 4 - COUNT NON-NULL VALUES
   ========================================================== */

SELECT
    COUNT(city) AS customers_with_city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 5 - NULL ANALYSIS
   ========================================================== */

SELECT
    COUNT(*) AS total_customers,
    COUNT(city) AS customers_with_city,
    COUNT(*) - COUNT(city) AS customers_without_city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 6 - COUNT DISTINCT
   ========================================================== */

SELECT
    COUNT(DISTINCT city) AS unique_city_count
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 7 - DISTINCT PRODUCT CATEGORIES
   ========================================================== */

SELECT
    COUNT(DISTINCT category) AS category_count
FROM training.products;
GO


/* ==========================================================
   EXERCISE 8 - SUM
   ========================================================== */

SELECT
    SUM(stock_quantity) AS total_stock
FROM training.products;
GO


/* ==========================================================
   EXERCISE 9 - TOTAL UNITS
   ========================================================== */

SELECT
    SUM(quantity) AS total_units
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 10 - AVERAGE
   ========================================================== */

SELECT
    AVG(price) AS average_price
FROM training.products;
GO


/* ==========================================================
   EXERCISE 11 - MINIMUM AND MAXIMUM
   ========================================================== */

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products;
GO


/* ==========================================================
   EXERCISE 12 - DATE AGGREGATION
   ========================================================== */

SELECT
    MIN(signup_date) AS first_signup,
    MAX(signup_date) AS latest_signup
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 13 - MULTIPLE AGGREGATES
   ========================================================== */

SELECT
    COUNT(*) AS product_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price,
    SUM(stock_quantity) AS total_stock
FROM training.products;
GO


/* ==========================================================
   EXERCISE 14 - WHERE + COUNT
   ========================================================== */

SELECT
    COUNT(*) AS completed_order_count
FROM training.orders
WHERE order_status = 'Completed';
GO


/* ==========================================================
   EXERCISE 15 - WHERE + AVG
   ========================================================== */

SELECT
    AVG(price) AS average_accessory_price
FROM training.products
WHERE category = N'Accessories';
GO


/* ==========================================================
   EXERCISE 16 - WHERE + SUM
   ========================================================== */

SELECT
    SUM(stock_quantity) AS electronics_stock
FROM training.products
WHERE category = N'Electronics';
GO


/* ==========================================================
   EXERCISE 17 - GROUP BY
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   EXERCISE 18 - ORDERS BY STATUS
   ========================================================== */

SELECT
    order_status,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY order_status
ORDER BY order_count DESC;
GO


/* ==========================================================
   EXERCISE 19 - CUSTOMERS BY CITY
   ========================================================== */

SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY city;
GO


/* ==========================================================
   EXERCISE 20 - TOTAL STOCK BY CATEGORY
   ========================================================== */

SELECT
    category,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category
ORDER BY total_stock DESC;
GO


/* ==========================================================
   EXERCISE 21 - AVERAGE PRICE BY CATEGORY
   ========================================================== */

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
GO


/* ==========================================================
   EXERCISE 22 - PRICE RANGE BY CATEGORY
   ========================================================== */

SELECT
    category,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   EXERCISE 23 - CATEGORY SUMMARY
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock_quantity) AS total_stock,
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   EXERCISE 24 - MULTIPLE GROUPING COLUMNS
   ========================================================== */

SELECT
    city,
    is_active,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY
    city,
    is_active;
GO


/* ==========================================================
   EXERCISE 25 - WHERE BEFORE GROUP BY
   ========================================================== */

SELECT
    category,
    COUNT(*) AS active_product_count
FROM training.products
WHERE is_active = 1
GROUP BY category;
GO


/* ==========================================================
   EXERCISE 26 - FILTER THEN GROUP
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM training.products
WHERE price >= 1000
GROUP BY category
ORDER BY average_price DESC;
GO


/* ==========================================================
   EXERCISE 27 - HAVING
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
HAVING COUNT(*) >= 2;
GO


/* ==========================================================
   EXERCISE 28 - HAVING WITH AVG
   ========================================================== */

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) >= 2000
ORDER BY average_price DESC;
GO


/* ==========================================================
   EXERCISE 29 - HAVING WITH SUM
   ========================================================== */

SELECT
    category,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category
HAVING SUM(stock_quantity) >= 50
ORDER BY total_stock DESC;
GO


/* ==========================================================
   EXERCISE 30 - WHERE + GROUP BY + HAVING
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM training.products
WHERE is_active = 1
  AND price >= 500
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY average_price DESC;
GO


/* ==========================================================
   EXERCISE 31 - KNOWN CITIES
   ========================================================== */

SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
WHERE city IS NOT NULL
GROUP BY city
ORDER BY customer_count DESC;
GO


/* ==========================================================
   EXERCISE 32 - CITY HAVING
   ========================================================== */

SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
WHERE city IS NOT NULL
GROUP BY city
HAVING COUNT(*) >= 2
ORDER BY customer_count DESC;
GO


/* ==========================================================
   EXERCISE 33 - DISTINCT ORDERS
   ========================================================== */

SELECT
    COUNT(DISTINCT order_id) AS distinct_orders
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 34 - DISTINCT PRODUCTS
   ========================================================== */

SELECT
    COUNT(DISTINCT product_id) AS distinct_products
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 35 - SALES VALUE
   ========================================================== */

SELECT
    SUM(quantity * unit_price) AS total_sales_value
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 36 - ORDER VALUE
   ========================================================== */

SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 37 - ORDER STATISTICS
   ========================================================== */

SELECT
    order_id,
    COUNT(*) AS line_count,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 38 - PRODUCT DEMAND
   ========================================================== */

SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
ORDER BY total_units DESC;
GO


/* ==========================================================
   EXERCISE 39 - PRODUCT SALES
   ========================================================== */

SELECT
    product_id,
    SUM(quantity * unit_price) AS sales_value
FROM training.order_items
GROUP BY product_id
ORDER BY sales_value DESC;
GO


/* ==========================================================
   EXERCISE 40 - HAVING ON PRODUCT DEMAND
   ========================================================== */

SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
HAVING SUM(quantity) >= 2
ORDER BY total_units DESC;
GO


/* ==========================================================
   EXERCISE 41 - HIGH VALUE ORDERS
   ========================================================== */

SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
HAVING SUM(quantity * unit_price) >= 3000
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 42 - TOP AGGREGATED RESULT
   ========================================================== */

SELECT TOP (1)
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
GO


/* ==========================================================
   EXERCISE 43 - TOP ORDERS
   ========================================================== */

SELECT TOP (2)
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
GO


/* ==========================================================
   EXERCISE 44 - MARCH ORDERS
   ========================================================== */

SELECT
    COUNT(*) AS march_order_count
FROM training.orders
WHERE order_date >= '2025-03-01'
  AND order_date <  '2025-04-01';
GO


/* ==========================================================
   EXERCISE 45 - MARCH ORDERS BY STATUS
   ========================================================== */

SELECT
    order_status,
    COUNT(*) AS order_count
FROM training.orders
WHERE order_date >= '2025-03-01'
  AND order_date <  '2025-04-01'
GROUP BY order_status
ORDER BY order_count DESC;
GO


/* ==========================================================
   EXERCISE 46 - COUNT vs SUM
   ========================================================== */

/*
Answer:

1. COUNT(*) returns:
   3

2. SUM(quantity) returns:
   8

3. To answer:
   "How many units were ordered?"

   Use:

   SUM(quantity)

Explanation:

COUNT(*) counts rows.

SUM(quantity) adds the number of units represented
by those rows.
*/


/* ==========================================================
   EXERCISE 47 - COUNT AND NULL
   ========================================================== */

/*
Answer:

1. COUNT(*) returns:
   5

2. COUNT(city) returns:
   4

3. COUNT(*) counts all rows.

   COUNT(city) counts only rows where city
   is NOT NULL.

Explanation:

Most aggregate functions ignore NULL values.

COUNT(*) is different because it counts rows
rather than values from a particular column.
*/


/* ==========================================================
   EXERCISE 48 - WHERE vs HAVING
   ========================================================== */

/*
Answer:

1. WHERE filters rows before GROUP BY.

2. HAVING filters groups after aggregation.

3. For:

       price >= 1000

   use WHERE when filtering individual products.

4. For:

       AVG(price) >= 1000

   use HAVING when filtering category averages.
*/


/* ==========================================================
   EXERCISE 49 - GROUP BY RULE
   ========================================================== */

/*
Answer:

product_name is neither:

- Inside an aggregate function

nor

- Included in GROUP BY

The query groups multiple products into one row
per category.

SQL Server cannot choose one product_name to represent
the entire category.

For a category-level result:

    SELECT
        category,
        COUNT(*) AS product_count
    FROM training.products
    GROUP BY category;
*/


/* ==========================================================
   EXERCISE 50 - BUSINESS METRIC
   ========================================================== */

/*
Answer:

COUNT(*):

Counts order-item rows.

Business question:
"How many order lines are recorded?"


COUNT(DISTINCT order_id):

Counts unique orders represented in order_items.

Business question:
"How many different orders are represented?"


SUM(quantity):

Adds the quantity from all order-item rows.

Business question:
"How many total units were ordered?"


These metrics are not interchangeable.
*/


/* ==========================================================
   CHALLENGE 1 - INVENTORY SUMMARY
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock_quantity) AS total_stock,
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products
WHERE is_active = 1
GROUP BY category
ORDER BY total_stock DESC;
GO


/* ==========================================================
   CHALLENGE 2 - STRONG CATEGORIES
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock_quantity) AS total_stock,
    AVG(price) AS average_price
FROM training.products
WHERE is_active = 1
  AND price >= 500
GROUP BY category
HAVING COUNT(*) >= 2
   AND SUM(stock_quantity) >= 50
ORDER BY average_price DESC;
GO


/* ==========================================================
   CHALLENGE 3 - ORDER PERFORMANCE
   ========================================================== */

SELECT
    order_id,
    COUNT(*) AS line_count,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
HAVING SUM(quantity) >= 2
   AND SUM(quantity * unit_price) >= 1000
ORDER BY order_value DESC;
GO


/* ==========================================================
   CHALLENGE 4 - PRODUCT PERFORMANCE
   ========================================================== */

SELECT
    product_id,
    COUNT(*) AS order_item_rows,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price) AS sales_value
FROM training.order_items
GROUP BY product_id
HAVING SUM(quantity) >= 2
ORDER BY sales_value DESC;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL ANALYTICAL CHALLENGE
   ========================================================== */

SELECT
    product_id,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(quantity) AS total_units,
    AVG(unit_price) AS average_unit_price,
    MIN(unit_price) AS minimum_unit_price,
    MAX(unit_price) AS maximum_unit_price,
    SUM(quantity * unit_price) AS sales_value
FROM training.order_items
GROUP BY product_id
HAVING COUNT(DISTINCT order_id) >= 1
   AND SUM(quantity) >= 2
ORDER BY sales_value DESC;
GO


/* ==========================================================
   FINAL RECAP
   ==========================================================

   COUNT(*)
       Counts rows.

   COUNT(column)
       Counts non-NULL values.

   COUNT(DISTINCT column)
       Counts unique non-NULL values.

   SUM()
       Calculates a total.

   AVG()
       Calculates an average.

   MIN()
       Returns the minimum.

   MAX()
       Returns the maximum.


   GROUP BY
       Creates groups.

   WHERE
       Filters individual rows BEFORE grouping.

   HAVING
       Filters groups AFTER aggregation.


   Example:

       SELECT
           category,
           COUNT(*) AS product_count,
           AVG(price) AS average_price
       FROM training.products
       WHERE is_active = 1
       GROUP BY category
       HAVING COUNT(*) >= 2
       ORDER BY average_price DESC;


   Think approximately:

       FROM
       WHERE
       GROUP BY
       HAVING
       SELECT
       DISTINCT
       ORDER BY
       TOP


   BUSINESS THINKING:

   Before choosing an aggregate, ask:

   - What does one row represent?
   - Am I counting rows or units?
   - Do I need unique values?
   - What dimension am I grouping by?
   - Am I filtering rows or aggregated groups?
   - What metric actually answers the business question?

============================================================
END OF CHAPTER 03
============================================================
*/