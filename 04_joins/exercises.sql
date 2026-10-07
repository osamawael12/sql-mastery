/*
============================================================
SQL MASTERY
04 - JOINS

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve each exercise before checking solutions.sql.

Topics:
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- CROSS JOIN
- Multiple JOINs
- Table Aliases
- Unmatched Rows
- JOIN + WHERE
- JOIN + GROUP BY
- JOIN + HAVING
- COUNT after JOIN
- Row Multiplication
- Result Grain
- Business Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - FIRST INNER JOIN
   ==========================================================

   Show every order with its customer name.

   Return:

   order_id
   customer_name
   order_date
   order_status

   Tables:

   training.orders
   training.customers
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - CUSTOMER ORDERS
   ==========================================================

   Show:

   customer_id
   customer_name
   order_id
   order_date

   Only customers who have matching orders.

   Sort by:
   customer_id
   order_date
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - JOIN + WHERE
   ==========================================================

   Show Completed orders only.

   Return:

   order_id
   customer_name
   order_date
   order_status

   Sort newest order first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - JOIN + DATE FILTER
   ==========================================================

   Show orders placed during March 2025.

   Return:

   order_id
   customer_name
   order_date
   order_status

   Use:

   >= '2025-03-01'
   <  '2025-04-01'
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - LEFT JOIN
   ==========================================================

   Show ALL customers and their orders.

   Customers with no orders must also appear.

   Return:

   customer_id
   customer_name
   order_id
   order_date
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - CUSTOMERS WITHOUT ORDERS
   ==========================================================

   Find customers who have never placed an order.

   Return:

   customer_id
   customer_name
   email

   Use:

   LEFT JOIN
   +
   IS NULL
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - RIGHT JOIN
   ==========================================================

   Use RIGHT JOIN to keep every customer.

   Start from:

   training.orders

   and RIGHT JOIN:

   training.customers

   Return:

   customer_id
   customer_name
   order_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - CROSS JOIN
   ==========================================================

   Return every possible customer/product combination.

   Return:

   customer_name
   product_name

   Sort by:

   customer_name
   product_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - CROSS JOIN COUNT
   ==========================================================

   Count how many customer/product combinations exist.

   Return:

   combination_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - ORDERS + ORDER ITEMS
   ==========================================================

   Join orders to order_items.

   Return:

   order_id
   order_date
   order_item_id
   product_id
   quantity
   unit_price

   Sort by:
   order_id
   order_item_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - ORDER ITEMS + PRODUCTS
   ==========================================================

   Show product information for each order item.

   Return:

   order_id
   product_id
   product_name
   quantity
   unit_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - THREE TABLE JOIN
   ==========================================================

   Join:

   orders
   order_items
   products

   Return:

   order_id
   order_date
   product_name
   quantity
   unit_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - CUSTOMER ORDER ITEMS
   ==========================================================

   Join:

   customers
   orders
   order_items

   Return:

   customer_name
   order_id
   product_id
   quantity
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - FOUR TABLE JOIN
   ==========================================================

   Join:

   customers
   orders
   order_items
   products

   Return:

   customer_name
   order_id
   order_date
   product_name
   category
   quantity
   unit_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - LINE VALUE
   ==========================================================

   Show every order-item line with:

   order_id
   customer_name
   product_name
   quantity
   unit_price
   line_value

   Calculate:

   line_value = quantity * unit_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - COMPLETED SALES DETAIL
   ==========================================================

   Show order-item details for Completed orders only.

   Return:

   order_id
   order_date
   customer_name
   product_name
   quantity
   unit_price
   line_value

   Sort by:
   order_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - COUNT ORDERS PER CUSTOMER
   ==========================================================

   Return ALL customers, including customers
   with zero orders.

   Return:

   customer_id
   customer_name
   order_count

   IMPORTANT:

   Use COUNT on a column from orders,
   not COUNT(*).

   Sort highest order count first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - COMPLETED ORDERS PER CUSTOMER
   ==========================================================

   Return ALL customers.

   Count only Completed orders.

   A customer with no Completed orders should
   have a count of 0.

   Return:

   customer_id
   customer_name
   completed_order_count

   Hint:

   Think carefully about whether:

   order_status = 'Completed'

   belongs in ON or WHERE.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - NO COMPLETED ORDERS
   ==========================================================

   Find customers who have no Completed orders.

   IMPORTANT:

   A customer can qualify if:

   - They have no orders at all

   OR

   - They have orders, but none are Completed

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - CUSTOMER SPENDING
   ==========================================================

   Calculate spending for customers using ALL
   order statuses.

   Return:

   customer_id
   customer_name
   total_spending

   Formula:

   quantity * unit_price

   Sort highest spending first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - COMPLETED CUSTOMER SPENDING
   ==========================================================

   Calculate spending from Completed orders only.

   Return:

   customer_id
   customer_name
   completed_spending

   Sort highest spending first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - CUSTOMER PERFORMANCE
   ==========================================================

   Analyze Completed orders.

   For each customer calculate:

   completed_orders
   units_purchased
   revenue

   Return:

   customer_id
   customer_name
   completed_orders
   units_purchased
   revenue

   IMPORTANT:

   One order can contain multiple order-item rows.

   Count DISTINCT orders.

   Sort revenue descending.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - PRODUCT DEMAND
   ==========================================================

   Calculate total ordered quantity for every
   product that appears in order_items.

   Return:

   product_id
   product_name
   total_units

   Sort highest demand first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - PRODUCT SALES VALUE
   ==========================================================

   Calculate total sales value for each product.

   Use all order statuses.

   Return:

   product_id
   product_name
   sales_value

   Sort highest sales value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - COMPLETED PRODUCT PERFORMANCE
   ==========================================================

   Analyze Completed orders only.

   For each product calculate:

   units_sold
   revenue

   Return:

   product_id
   product_name
   units_sold
   revenue

   Sort highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - INCLUDE UNSOLD PRODUCTS
   ==========================================================

   Return EVERY product.

   Count the number of order-item rows associated
   with each product.

   Unsold products should have:

   order_line_count = 0

   Return:

   product_id
   product_name
   order_line_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - PRODUCTS NEVER ORDERED
   ==========================================================

   Find products that never appeared in order_items.

   Return:

   product_id
   product_name
   category

   Use:

   LEFT JOIN
   +
   IS NULL
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - TOTAL UNITS FOR ALL PRODUCTS
   ==========================================================

   Return every product.

   Calculate its total ordered units.

   Products with no order items should show:

   0

   Return:

   product_id
   product_name
   total_units

   Hint:

   COALESCE(SUM(...), 0)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - ORDER TOTAL
   ==========================================================

   Calculate the value of each order and show
   the customer name.

   Return:

   order_id
   customer_name
   order_date
   order_status
   order_value

   Sort highest order value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - HIGH VALUE COMPLETED ORDERS
   ==========================================================

   Find Completed orders worth at least 3000.

   Return:

   order_id
   customer_name
   order_value

   Use:

   WHERE for order status
   HAVING for order value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - DISTINCT PRODUCTS PER CUSTOMER
   ==========================================================

   For each customer who has order items,
   count how many different products appear
   in their orders.

   Return:

   customer_id
   customer_name
   distinct_product_count

   Sort highest count first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - CUSTOMER PRODUCT HISTORY
   ==========================================================

   Return unique customer/product pairs.

   If the same customer purchased the same product
   more than once, show that pair only once.

   Return:

   customer_id
   customer_name
   product_id
   product_name

   Hint:

   DISTINCT
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - CUSTOMERS WITH MULTIPLE ORDERS
   ==========================================================

   Find customers with more than one order.

   Return:

   customer_id
   customer_name
   order_count

   Use HAVING.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - CATEGORY PERFORMANCE
   ==========================================================

   Using all order statuses, calculate by category:

   products_ordered
   total_units
   sales_value

   products_ordered should count distinct products.

   Return:

   category
   products_ordered
   total_units
   sales_value

   Sort highest sales value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - COMPLETED CATEGORY PERFORMANCE
   ==========================================================

   Analyze Completed orders only.

   For each product category calculate:

   order_count
   units_sold
   revenue

   order_count should count distinct orders.

   Return:

   category
   order_count
   units_sold
   revenue

   Sort highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - TOP CUSTOMER
   ==========================================================

   Find the customer generating the highest
   Completed revenue.

   Return maximum 1 row:

   customer_id
   customer_name
   completed_orders
   revenue
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - TOP PRODUCT
   ==========================================================

   Find the product generating the highest
   Completed revenue.

   Return maximum 1 row:

   product_id
   product_name
   units_sold
   revenue
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - ACTIVE CUSTOMERS WITHOUT ORDERS
   ==========================================================

   Find active customers who have never
   placed an order.

   Return:

   customer_id
   customer_name
   email
   city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - THINK ABOUT LEFT JOIN

   Compare:

   Query A:

       FROM training.customers AS c
       LEFT JOIN training.orders AS o
           ON c.customer_id = o.customer_id
       WHERE o.order_status = 'Completed'

   Query B:

       FROM training.customers AS c
       LEFT JOIN training.orders AS o
           ON c.customer_id = o.customer_id
          AND o.order_status = 'Completed'

   Answer:

   1. Do they always return the same result?

   2. Which query keeps customers without
      Completed orders?

   3. Why?
   ========================================================== */

/*
Answer:

1.

2.

3.


Explanation:



*/


/* ==========================================================
   EXERCISE 40 - COUNT AFTER LEFT JOIN

   Consider a customer who has NO orders.

   After:

       customers
       LEFT JOIN orders

   Answer:

   1. What can COUNT(*) return for that customer group?

   2. What does COUNT(o.order_id) return?

   3. Which expression should normally be used
      to count actual orders?
   ========================================================== */

/*
Answer:

1.

2.

3.


Explanation:



*/


/* ==========================================================
   EXERCISE 41 - ROW MULTIPLICATION

   Suppose:

   Customer A has:

   Order 1:
       3 order items

   Order 2:
       2 order items

   Then we join:

   customers
   -> orders
   -> order_items

   Answer:

   1. How many joined rows belong to Customer A?

   2. What does COUNT(o.order_id) produce?

   3. What does COUNT(DISTINCT o.order_id) produce?

   4. Which one correctly answers:
      "How many orders did Customer A place?"
   ========================================================== */

/*
Answer:

1.

2.

3.

4.


Explanation:



*/


/* ==========================================================
   EXERCISE 42 - RESULT GRAIN

   Consider:

       customers
       JOIN orders
       JOIN order_items
       JOIN products

   with no aggregation.

   What does one result row normally represent?

   Choose:

   A. One customer

   B. One order

   C. One order-item line

   D. One product
   ========================================================== */

/*
Answer:


Explanation:



*/


/* ==========================================================
   EXERCISE 43 - CHOOSE THE JOIN

   For each question choose:

   INNER JOIN
   or
   LEFT JOIN

   1. Show only customers who have orders.

   2. Show every customer and their orders if any.

   3. Find customers who have no orders.

   4. Show only products that appear in order_items.

   5. Show every product, including unsold products.
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

5.

*/


/* ==========================================================
   EXERCISE 44 - JOIN KEYS

   Complete the relationships:

   1.

   customers.__________
       =
   orders.__________

   2.

   orders.__________
       =
   order_items.__________

   3.

   products.__________
       =
   order_items.__________
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 45 - BUSINESS METRICS AFTER JOIN

   Explain what each expression measures after joining:

   customers
   -> orders
   -> order_items

   Expressions:

   COUNT(*)

   COUNT(o.order_id)

   COUNT(DISTINCT o.order_id)

   COUNT(oi.order_item_id)

   SUM(oi.quantity)
   ========================================================== */

/*
Answer:

COUNT(*):


COUNT(o.order_id):


COUNT(DISTINCT o.order_id):


COUNT(oi.order_item_id):


SUM(oi.quantity):


*/


/* ==========================================================
   CHALLENGE 1 - COMPLETE SALES REPORT
   ==========================================================

   Build a Completed sales detail report.

   Return:

   order_id
   order_date
   customer_id
   customer_name
   product_id
   product_name
   category
   quantity
   unit_price
   line_value

   Requirements:

   - Completed orders only
   - Sort by order_date
   - Then order_id
   - Then product_name
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - CUSTOMER PERFORMANCE
   ==========================================================

   Analyze Completed orders.

   For each customer with Completed order items,
   calculate:

   customer_id
   customer_name
   completed_order_count
   distinct_products
   total_units
   revenue

   Requirements:

   completed_order_count:
       Count distinct orders.

   distinct_products:
       Count distinct product IDs.

   total_units:
       Sum quantity.

   revenue:
       Sum quantity * unit_price.

   Keep only customers whose:

   revenue >= 1000

   Sort:

   revenue DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - PRODUCT PERFORMANCE
   ==========================================================

   Analyze Completed orders.

   For each product calculate:

   product_id
   product_name
   category
   order_count
   customer_count
   units_sold
   revenue

   Definitions:

   order_count:
       Number of distinct Completed orders.

   customer_count:
       Number of distinct customers who bought
       the product through Completed orders.

   units_sold:
       SUM(quantity)

   revenue:
       SUM(quantity * unit_price)

   Keep only products with:

   units_sold >= 1

   Sort:

   revenue DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - ALL CUSTOMER ORDER SUMMARY
   ==========================================================

   Return EVERY customer, including customers
   with zero orders.

   Calculate:

   customer_id
   customer_name
   total_orders
   completed_orders

   Requirements:

   total_orders:
       All orders.

   completed_orders:
       Completed orders only.

   IMPORTANT:

   Do not remove customers with zero orders.

   Hint:

   You may need conditional aggregation.

   CASE is introduced fully in Chapter 05,
   but the pattern is:

       COUNT(
           CASE
               WHEN condition THEN value
           END
       )

   Sort:
   total_orders DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL JOIN CHALLENGE
   ==========================================================

   Create a Completed category performance report.

   For each category calculate:

   category
   product_count
   order_count
   customer_count
   units_sold
   revenue

   Definitions:

   product_count:
       Distinct products sold.

   order_count:
       Distinct Completed orders.

   customer_count:
       Distinct customers.

   units_sold:
       Total quantity.

   revenue:
       quantity * unit_price.

   Requirements:

   - Completed orders only
   - Keep categories with revenue >= 1000
   - Highest revenue first

   Tables required:

   customers
   orders
   order_items
   products
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before completing Chapter 04, make sure you can explain:

   1. INNER JOIN vs LEFT JOIN

   2. Why table aliases are useful

   3. PK/FK relationships used in JOINs

   4. How to join more than two tables

   5. How order_items resolves the many-to-many
      relationship between orders and products

   6. How to find unmatched records

   7. Why COUNT(*) can be dangerous after LEFT JOIN

   8. Why COUNT(DISTINCT order_id) may be needed
      after joining to order_items

   9. What row multiplication means

   10. What result grain means

   11. Why filtering a right-side table in WHERE
       can change LEFT JOIN behavior

   12. Difference between:

       COUNT(*)
       COUNT(key)
       COUNT(DISTINCT key)
       SUM(quantity)

   13. How to translate:

       customers
       -> orders
       -> order_items
       -> products

       into SQL JOIN conditions
   ========================================================== */