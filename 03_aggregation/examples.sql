/*
============================================================
SQL MASTERY
03 - AGGREGATION

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- COUNT
- SUM
- AVG
- MIN
- MAX
- DISTINCT with Aggregates
- NULL and Aggregates
- GROUP BY
- Multiple Grouping Columns
- WHERE with Aggregation
- HAVING
- ORDER BY Aggregated Results
- TOP with Aggregation
- Aggregating Expressions
- Business Metrics
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. COUNT(*)

   COUNT(*) counts rows.
   ========================================================== */

SELECT
    COUNT(*) AS customer_count
FROM training.customers;
GO


SELECT
    COUNT(*) AS product_count
FROM training.products;
GO


SELECT
    COUNT(*) AS order_count
FROM training.orders;
GO


/* ==========================================================
   2. COUNT(column)

   COUNT(column) counts non-NULL values.
   ========================================================== */

SELECT
    COUNT(*) AS total_customers,
    COUNT(city) AS customers_with_city
FROM training.customers;
GO


/* ==========================================================
   3. COUNT(*) vs COUNT(column)

   The difference represents rows where city is NULL.
   ========================================================== */

SELECT
    COUNT(*) AS total_rows,
    COUNT(city) AS non_null_cities
FROM training.customers;
GO


/* ==========================================================
   4. COUNT(DISTINCT)

   Count unique non-NULL values.
   ========================================================== */

SELECT
    COUNT(DISTINCT city) AS unique_city_count
FROM training.customers;
GO


SELECT
    COUNT(DISTINCT category) AS category_count
FROM training.products;
GO


/* ==========================================================
   5. SUM

   Calculate total stock across all products.
   ========================================================== */

SELECT
    SUM(stock_quantity) AS total_stock
FROM training.products;
GO


/* ==========================================================
   6. SUM QUANTITY

   How many units exist in order_items?

   Remember:
   COUNT(*) counts rows.
   SUM(quantity) counts units represented by those rows.
   ========================================================== */

SELECT
    COUNT(*) AS order_item_rows,
    SUM(quantity) AS total_units
FROM training.order_items;
GO


/* ==========================================================
   7. AVG

   Calculate average product price.
   ========================================================== */

SELECT
    AVG(price) AS average_product_price
FROM training.products;
GO


/* ==========================================================
   8. MIN
   ========================================================== */

SELECT
    MIN(price) AS minimum_product_price
FROM training.products;
GO


/* ==========================================================
   9. MAX
   ========================================================== */

SELECT
    MAX(price) AS maximum_product_price
FROM training.products;
GO


/* ==========================================================
   10. MIN AND MAX WITH DATES
   ========================================================== */

SELECT
    MIN(signup_date) AS first_signup,
    MAX(signup_date) AS latest_signup
FROM training.customers;
GO


SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS latest_order
FROM training.orders;
GO


/* ==========================================================
   11. MULTIPLE AGGREGATES

   Generate several product metrics in one result.
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
   12. AGGREGATION WITH WHERE

   Count Completed orders only.

   WHERE filters rows BEFORE aggregation.
   ========================================================== */

SELECT
    COUNT(*) AS completed_order_count
FROM training.orders
WHERE order_status = 'Completed';
GO


/* ==========================================================
   13. COUNT CANCELLED ORDERS
   ========================================================== */

SELECT
    COUNT(*) AS cancelled_order_count
FROM training.orders
WHERE order_status = 'Cancelled';
GO


/* ==========================================================
   14. AGGREGATION AFTER NUMERIC FILTERING

   Calculate the average price only for products
   priced at least 1000.
   ========================================================== */

SELECT
    AVG(price) AS average_price
FROM training.products
WHERE price >= 1000;
GO


/* ==========================================================
   15. FILTER THEN SUM

   Total stock of Accessories products.
   ========================================================== */

SELECT
    SUM(stock_quantity) AS accessories_stock
FROM training.products
WHERE category = N'Accessories';
GO


/* ==========================================================
   16. GROUP BY

   Count products in each category.
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   17. GROUP BY CUSTOMER CITY
   ========================================================== */

SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY city;
GO


/*
Notice:

NULL can appear as its own group.
*/


/* ==========================================================
   18. GROUP BY ORDER STATUS
   ========================================================== */

SELECT
    order_status,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY order_status;
GO


/* ==========================================================
   19. SUM BY GROUP

   Total stock in each category.
   ========================================================== */

SELECT
    category,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   20. AVG BY GROUP

   Average price in each category.
   ========================================================== */

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   21. MIN AND MAX BY GROUP
   ========================================================== */

SELECT
    category,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   22. MULTIPLE AGGREGATES BY GROUP
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   23. ORDER GROUPED RESULTS

   Categories with the largest number of products first.
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
ORDER BY product_count DESC;
GO


/* ==========================================================
   24. GROUP BY MULTIPLE COLUMNS

   Each unique combination of city + is_active
   becomes a group.
   ========================================================== */

SELECT
    city,
    is_active,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY
    city,
    is_active
ORDER BY
    city,
    is_active;
GO


/* ==========================================================
   25. MULTIPLE GROUPING COLUMNS

   Count products based on:

   category
   AND
   is_active
   ========================================================== */

SELECT
    category,
    is_active,
    COUNT(*) AS product_count
FROM training.products
GROUP BY
    category,
    is_active
ORDER BY category;
GO


/* ==========================================================
   26. WHERE + GROUP BY

   First:
       Keep active products.

   Then:
       Group them by category.

   Then:
       Count them.
   ========================================================== */

SELECT
    category,
    COUNT(*) AS active_product_count
FROM training.products
WHERE is_active = 1
GROUP BY category;
GO


/* ==========================================================
   27. WHERE + GROUP BY + SUM

   Total stock by category for active products.
   ========================================================== */

SELECT
    category,
    SUM(stock_quantity) AS active_stock
FROM training.products
WHERE is_active = 1
GROUP BY category
ORDER BY active_stock DESC;
GO


/* ==========================================================
   28. HAVING

   Return only categories containing
   at least 2 products.

   HAVING filters GROUPS.
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
HAVING COUNT(*) >= 2;
GO


/* ==========================================================
   29. WHERE vs HAVING

   WHERE:
       Filters individual rows.

   HAVING:
       Filters aggregated groups.
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
WHERE price >= 500
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY product_count DESC;
GO


/* ==========================================================
   30. HAVING WITH AVG

   Return categories where average price
   is at least 2000.
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
   31. HAVING WITH SUM

   Return categories whose total stock
   is at least 50.
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
   32. FILTER NULL BEFORE GROUPING

   Count customers by known city.
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
   33. HAVING WITH CUSTOMER CITY

   Find known cities that contain at least
   2 customers.
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
   34. COUNT DISTINCT ORDERS

   How many different orders appear
   inside order_items?
   ========================================================== */

SELECT
    COUNT(DISTINCT order_id) AS distinct_orders
FROM training.order_items;
GO


/* ==========================================================
   35. COUNT DISTINCT PRODUCTS

   How many different products appear
   inside order_items?
   ========================================================== */

SELECT
    COUNT(DISTINCT product_id) AS distinct_products
FROM training.order_items;
GO


/* ==========================================================
   36. AGGREGATE AN EXPRESSION

   Each order item line has:

   line value = quantity * unit_price

   SUM can aggregate the calculated expression.
   ========================================================== */

SELECT
    SUM(quantity * unit_price) AS total_sales_value
FROM training.order_items;
GO


/* ==========================================================
   37. ORDER VALUE

   Calculate total value for every order.

   Each order_id becomes one group.
   ========================================================== */

SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
GO


/* ==========================================================
   38. ORDER STATISTICS

   For every order calculate:

   - Number of item rows
   - Number of units
   - Total value
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
   39. PRODUCT DEMAND

   Calculate total ordered units for every product.

   We currently use product_id.

   Product names will be added later using JOIN.
   ========================================================== */

SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
ORDER BY total_units DESC;
GO


/* ==========================================================
   40. PRODUCT SALES VALUE

   Calculate sales value generated by each product ID.
   ========================================================== */

SELECT
    product_id,
    SUM(quantity * unit_price) AS sales_value
FROM training.order_items
GROUP BY product_id
ORDER BY sales_value DESC;
GO


/* ==========================================================
   41. HAVING ON PRODUCT DEMAND

   Return products with at least 2 ordered units.
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
   42. HIGH VALUE ORDERS

   Return orders worth at least 3000.
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
   43. TOP WITH AGGREGATION

   Find the category with the highest
   average product price.
   ========================================================== */

SELECT TOP (1)
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
GO


/* ==========================================================
   44. TOP WITH TIES

   If multiple categories have the same highest
   average, WITH TIES can return all tied groups.
   ========================================================== */

SELECT TOP (1) WITH TIES
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
GO


/* ==========================================================
   45. TOP GROUPS

   Find the 2 orders with the highest value.
   ========================================================== */

SELECT TOP (2)
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
GO


/* ==========================================================
   46. NULL AND COUNT

   Compare:

   COUNT(*)
       Counts every customer row.

   COUNT(city)
       Counts only customers with a non-NULL city.
   ========================================================== */

SELECT
    COUNT(*) AS total_customers,
    COUNT(city) AS customers_with_city,
    COUNT(*) - COUNT(city) AS customers_without_city
FROM training.customers;
GO


/* ==========================================================
   47. AGGREGATION AND DATE FILTERING

   Count orders placed during March 2025.
   ========================================================== */

SELECT
    COUNT(*) AS march_order_count
FROM training.orders
WHERE order_date >= '2025-03-01'
  AND order_date <  '2025-04-01';
GO


/* ==========================================================
   48. GROUP FILTERED ORDERS BY STATUS

   Count March 2025 orders by status.
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
   49. BUSINESS QUESTION

   Inventory summary by category.

   Calculate:

   - Number of products
   - Total units in stock
   - Average price
   - Cheapest price
   - Most expensive price
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count,
    SUM(stock_quantity) AS total_stock,
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products
GROUP BY category
ORDER BY category;
GO


/* ==========================================================
   50. BUSINESS QUESTION

   Only analyze active products priced at least 500.

   For each category return:

   - Product count
   - Total stock
   - Average price

   Keep only categories containing at least
   2 qualifying products.
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
ORDER BY average_price DESC;
GO


/* ==========================================================
   51. BUSINESS QUESTION

   Order-item performance.

   For each order return:

   - order_id
   - number of lines
   - total units
   - order value

   Keep only orders containing at least 2 units.
   ========================================================== */

SELECT
    order_id,
    COUNT(*) AS line_count,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
HAVING SUM(quantity) >= 2
ORDER BY order_value DESC;
GO


/* ==========================================================
   52. COUNT vs DISTINCT vs SUM

   These answer THREE DIFFERENT questions.
   ========================================================== */

SELECT
    COUNT(*) AS order_item_rows,
    COUNT(DISTINCT order_id) AS different_orders,
    COUNT(DISTINCT product_id) AS different_products,
    SUM(quantity) AS total_units
FROM training.order_items;
GO


/* ==========================================================
   53. WRITTEN QUERY ORDER

   SELECT
   FROM
   WHERE
   GROUP BY
   HAVING
   ORDER BY

   TOP appears as part of SELECT syntax.
   ========================================================== */

SELECT TOP (2)
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM training.products
WHERE is_active = 1
GROUP BY category
HAVING COUNT(*) >= 1
ORDER BY average_price DESC;
GO


/* ==========================================================
   54. LOGICAL PROCESSING ORDER

   For what we have learned so far,
   think approximately:

   1. FROM
   2. WHERE
   3. GROUP BY
   4. HAVING
   5. SELECT
   6. DISTINCT
   7. ORDER BY
   8. TOP
   ========================================================== */


/* ==========================================================
   55. COMMON ERROR - MISSING GROUP BY

   DO NOT EXECUTE:

   SELECT
       category,
       COUNT(*)
   FROM training.products;

   category is neither aggregated nor grouped.

   Correct:
   ========================================================== */

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
GO


/* ==========================================================
   56. COMMON ERROR - AGGREGATE INSIDE WHERE

   DO NOT EXECUTE:

   SELECT
       category,
       AVG(price)
   FROM training.products
   WHERE AVG(price) >= 2000
   GROUP BY category;

   Aggregate-based group filters belong in HAVING.

   Correct:
   ========================================================== */

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) >= 2000;
GO


/* ==========================================================
   57. FINAL ANALYTICAL EXAMPLE

   Business Question:

   Which product IDs demonstrate meaningful demand?

   Requirements:

   - At least 2 units ordered
   - Calculate number of order-item rows
   - Calculate distinct orders
   - Calculate total units
   - Calculate sales value
   - Highest sales value first

   We deliberately use product_id here because JOIN
   has not been covered yet.
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
   FINAL RECAP

   COUNT(*)
       Counts rows.

   COUNT(column)
       Counts non-NULL values.

   COUNT(DISTINCT column)
       Counts unique non-NULL values.

   SUM()
       Adds numeric values.

   AVG()
       Calculates an average.

   MIN()
       Finds the minimum.

   MAX()
       Finds the maximum.

   GROUP BY
       Creates groups.

   WHERE
       Filters rows before grouping.

   HAVING
       Filters groups after aggregation.

   ORDER BY
       Sorts the final result.

   TOP
       Limits the final result.

   Most important question:

       What does one row represent,
       and what exactly am I trying to measure?
   ========================================================== */