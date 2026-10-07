/*
============================================================
SQL MASTERY
03 - AGGREGATION

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve each exercise before opening solutions.sql.

Topics:
- COUNT
- SUM
- AVG
- MIN
- MAX
- DISTINCT
- GROUP BY
- WHERE
- HAVING
- ORDER BY
- TOP
- NULL
- Business Metrics
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - COUNT ROWS
   ==========================================================

   How many customers exist?

   Return:

   customer_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - COUNT PRODUCTS
   ==========================================================

   How many products exist?

   Return:

   product_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - COUNT ORDERS
   ==========================================================

   How many orders exist?

   Return:

   order_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - COUNT NON-NULL VALUES
   ==========================================================

   How many customers have a known city?

   Use COUNT(city).

   Return:

   customers_with_city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - NULL ANALYSIS
   ==========================================================

   Return:

   total_customers
   customers_with_city
   customers_without_city

   Hint:

   customers_without_city can be calculated using:

   COUNT(*) - COUNT(city)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - COUNT DISTINCT
   ==========================================================

   How many unique non-NULL cities exist?

   Return:

   unique_city_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - DISTINCT PRODUCT CATEGORIES
   ==========================================================

   How many unique product categories exist?

   Return:

   category_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - SUM
   ==========================================================

   Calculate total stock across all products.

   Return:

   total_stock
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - TOTAL UNITS
   ==========================================================

   Calculate the total quantity from order_items.

   IMPORTANT:

   We want units, not the number of rows.

   Return:

   total_units
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - AVERAGE
   ==========================================================

   Calculate the average product price.

   Return:

   average_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - MINIMUM AND MAXIMUM
   ==========================================================

   Return:

   minimum_price
   maximum_price

   from training.products.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - DATE AGGREGATION
   ==========================================================

   Find:

   first_signup
   latest_signup

   from training.customers.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - MULTIPLE AGGREGATES
   ==========================================================

   Create one summary row for products.

   Return:

   product_count
   minimum_price
   maximum_price
   average_price
   total_stock
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - WHERE + COUNT
   ==========================================================

   Count only Completed orders.

   Return:

   completed_order_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - WHERE + AVG
   ==========================================================

   Calculate the average price of Accessories products.

   Return:

   average_accessory_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - WHERE + SUM
   ==========================================================

   Calculate total stock for Electronics products.

   Return:

   electronics_stock
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - GROUP BY
   ==========================================================

   Count products in each category.

   Return:

   category
   product_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - ORDERS BY STATUS
   ==========================================================

   Count orders for each status.

   Return:

   order_status
   order_count

   Sort highest count first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - CUSTOMERS BY CITY
   ==========================================================

   Count customers in each city.

   Return:

   city
   customer_count

   Include the NULL city group.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - TOTAL STOCK BY CATEGORY
   ==========================================================

   Return:

   category
   total_stock

   Sort highest stock first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - AVERAGE PRICE BY CATEGORY
   ==========================================================

   Return:

   category
   average_price

   Sort highest average first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - PRICE RANGE BY CATEGORY
   ==========================================================

   For each category calculate:

   minimum_price
   maximum_price

   Return:

   category
   minimum_price
   maximum_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - CATEGORY SUMMARY
   ==========================================================

   For each product category calculate:

   - Number of products
   - Total stock
   - Average price
   - Minimum price
   - Maximum price

   Return:

   category
   product_count
   total_stock
   average_price
   minimum_price
   maximum_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - MULTIPLE GROUPING COLUMNS
   ==========================================================

   Group customers by:

   city
   is_active

   Return:

   city
   is_active
   customer_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - WHERE BEFORE GROUP BY
   ==========================================================

   Analyze active products only.

   Count active products in each category.

   Return:

   category
   active_product_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - FILTER THEN GROUP
   ==========================================================

   Only include products with:

   price >= 1000

   For each category calculate:

   category
   product_count
   average_price

   Sort average_price descending.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - HAVING
   ==========================================================

   Find categories containing at least 2 products.

   Return:

   category
   product_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - HAVING WITH AVG
   ==========================================================

   Find categories whose average price is
   at least 2000.

   Return:

   category
   average_price

   Sort highest average first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - HAVING WITH SUM
   ==========================================================

   Find categories whose total stock is
   at least 50 units.

   Return:

   category
   total_stock

   Sort highest total stock first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - WHERE + GROUP BY + HAVING
   ==========================================================

   Analyze only:

   active products
   priced at least 500

   Group by category.

   Keep only categories containing
   at least 2 qualifying products.

   Return:

   category
   product_count
   average_price

   Sort by average_price descending.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - KNOWN CITIES
   ==========================================================

   Count customers by city.

   Requirements:

   - Exclude NULL cities
   - Return city and customer_count
   - Highest customer count first
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - CITY HAVING
   ==========================================================

   Find known cities containing at least
   2 customers.

   Return:

   city
   customer_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - DISTINCT ORDERS
   ==========================================================

   How many different order IDs exist in
   training.order_items?

   Return:

   distinct_orders
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - DISTINCT PRODUCTS
   ==========================================================

   How many different product IDs appear in
   training.order_items?

   Return:

   distinct_products
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - SALES VALUE
   ==========================================================

   Calculate total sales value from order_items.

   Formula for one line:

   quantity * unit_price

   Return:

   total_sales_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - ORDER VALUE
   ==========================================================

   Calculate the value of every order.

   Return:

   order_id
   order_value

   Sort the most valuable order first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - ORDER STATISTICS
   ==========================================================

   For every order calculate:

   - Number of order_item rows
   - Total units
   - Total order value

   Return:

   order_id
   line_count
   total_units
   order_value

   Sort highest order value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - PRODUCT DEMAND
   ==========================================================

   Calculate total ordered units for every product_id.

   Return:

   product_id
   total_units

   Sort highest demand first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - PRODUCT SALES
   ==========================================================

   Calculate sales value generated by every product_id.

   Return:

   product_id
   sales_value

   Highest sales value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 40 - HAVING ON PRODUCT DEMAND
   ==========================================================

   Find product IDs where at least 2 units
   were ordered.

   Return:

   product_id
   total_units

   Highest quantity first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 41 - HIGH VALUE ORDERS
   ==========================================================

   Find orders whose total value is
   at least 3000.

   Return:

   order_id
   order_value

   Highest value first.

   Think carefully:

   Should the condition use WHERE or HAVING?
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 42 - TOP AGGREGATED RESULT
   ==========================================================

   Find the category with the highest
   average product price.

   Return maximum 1 row:

   category
   average_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 43 - TOP ORDERS
   ==========================================================

   Find the 2 orders with the highest value.

   Return:

   order_id
   order_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 44 - MARCH ORDERS
   ==========================================================

   Count orders placed during March 2025.

   Use a half-open date range:

   >= 2025-03-01
   <  2025-04-01

   Return:

   march_order_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 45 - MARCH ORDERS BY STATUS
   ==========================================================

   Analyze only orders placed during March 2025.

   Count orders by status.

   Return:

   order_status
   order_count

   Sort highest count first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 46 - COUNT vs SUM

   Suppose training.order_items contains:

       order_item_id | quantity
       1             | 1
       2             | 5
       3             | 2

   Answer:

   1. What does COUNT(*) return?

   2. What does SUM(quantity) return?

   3. Which should be used to answer:
      "How many units were ordered?"
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 47 - COUNT AND NULL

   Assume there are 5 customers and one customer
   has city = NULL.

   Answer:

   1. What does COUNT(*) return?

   2. What does COUNT(city) return?

   3. Why are the results different?
   ========================================================== */

/*
Answer:

1.

2.

3.


Explanation:


*/


/* ==========================================================
   EXERCISE 48 - WHERE vs HAVING

   Answer:

   1. Does WHERE filter rows before or after GROUP BY?

   2. Does HAVING filter rows or groups?

   3. Which should be used for:

      price >= 1000

      when filtering individual products?

   4. Which should be used for:

      AVG(price) >= 1000

      when filtering category averages?
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

*/


/* ==========================================================
   EXERCISE 49 - GROUP BY RULE

   Explain why this query is invalid:

       SELECT
           category,
           product_name,
           COUNT(*) AS product_count
       FROM training.products
       GROUP BY category;

   What is wrong with product_name?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 50 - BUSINESS METRIC

   What is the difference between:

       COUNT(*)

       COUNT(DISTINCT order_id)

       SUM(quantity)

   when they are used on training.order_items?

   Explain what business question each one answers.
   ========================================================== */

/*
Answer:

COUNT(*):


COUNT(DISTINCT order_id):


SUM(quantity):


*/


/* ==========================================================
   CHALLENGE 1 - INVENTORY SUMMARY
   ==========================================================

   Management needs an inventory report.

   Analyze ACTIVE products only.

   For each category return:

   category
   product_count
   total_stock
   average_price
   minimum_price
   maximum_price

   Sort by:

   total_stock DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - STRONG CATEGORIES
   ==========================================================

   Find product categories satisfying ALL conditions:

   - Only active products are analyzed
   - Only products priced at least 500 are analyzed
   - Category must contain at least 2 qualifying products
   - Total stock must be at least 50

   Return:

   category
   product_count
   total_stock
   average_price

   Sort:

   average_price DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - ORDER PERFORMANCE
   ==========================================================

   For every order calculate:

   order_id
   line_count
   total_units
   order_value

   Only return orders where:

   total_units >= 2

   AND

   order_value >= 1000

   Sort:

   order_value DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - PRODUCT PERFORMANCE
   ==========================================================

   For every product_id calculate:

   - Number of order_item rows
   - Number of distinct orders
   - Total units ordered
   - Total sales value

   Return:

   product_id
   order_item_rows
   order_count
   total_units
   sales_value

   Only include products where:

   total_units >= 2

   Sort:

   sales_value DESC

   Note:
   Product names require a JOIN, so use product_id
   in this chapter.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL ANALYTICAL CHALLENGE
   ==========================================================

   Create a summary of order_items by product_id.

   Requirements:

   Calculate:

   - Number of distinct orders
   - Total units
   - Average unit price
   - Minimum unit price
   - Maximum unit price
   - Total sales value

   Keep only products that:

   - Appear in at least 1 order
   - Have at least 2 total units

   Return:

   product_id
   order_count
   total_units
   average_unit_price
   minimum_unit_price
   maximum_unit_price
   sales_value

   Sort by:

   sales_value DESC

   Try to solve this using only the concepts
   covered through Chapter 03.
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before considering Chapter 03 complete,
   make sure you can explain without memorization:

   1. COUNT(*) vs COUNT(column)

   2. COUNT vs COUNT(DISTINCT)

   3. COUNT(*) vs SUM(quantity)

   4. What GROUP BY actually does

   5. Why non-aggregated SELECT columns normally
      need to appear in GROUP BY

   6. WHERE vs HAVING

   7. Why an aggregate normally cannot be used
      directly inside WHERE

   8. How NULL affects aggregate functions

   9. How to calculate:
      SUM(quantity * unit_price)

   10. How to translate a business question into:

       FROM
       WHERE
       GROUP BY
       HAVING
       SELECT
       ORDER BY
   ========================================================== */