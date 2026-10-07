/*
============================================================
SQL MASTERY
06 - SUBQUERIES AND CTEs

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve each exercise before checking solutions.sql.

Topics:
- Scalar Subqueries
- IN / NOT IN
- EXISTS / NOT EXISTS
- Correlated Subqueries
- Derived Tables
- CTEs
- Multiple CTEs
- Pre-Aggregation
- Business Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - ABOVE AVERAGE PRICE
   ==========================================================

   Find products priced above the overall
   average product price.

   Return:

   product_id
   product_name
   price

   Sort highest price first.

   Use a scalar subquery.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - HIGHEST PRICE
   ==========================================================

   Find every product whose price equals
   the maximum product price.

   Return:

   product_id
   product_name
   price

   Do not use TOP.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - LOWEST PRICE
   ==========================================================

   Find every product whose price equals
   the minimum product price.

   Return:

   product_id
   product_name
   price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - SUBQUERY IN SELECT
   ==========================================================

   Return:

   product_name
   price
   overall_average_price

   Display the overall average price beside
   every product.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - DIFFERENCE FROM AVERAGE
   ==========================================================

   Return:

   product_name
   price
   overall_average_price
   difference_from_average

   Formula:

   price - overall average price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - IN SUBQUERY
   ==========================================================

   Find customers who have at least one order.

   Return:

   customer_id
   customer_name

   Use IN with a subquery.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - COMPLETED ORDER CUSTOMERS
   ==========================================================

   Find customers who have at least one
   Completed order.

   Return:

   customer_id
   customer_name

   Use IN.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - CANCELLED ORDER CUSTOMERS
   ==========================================================

   Find customers who have at least one
   Cancelled order.

   Return:

   customer_id
   customer_name

   Use IN.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - NOT IN
   ==========================================================

   Find customers with no orders using NOT IN.

   Return:

   customer_id
   customer_name

   Note:

   orders.customer_id is NOT NULL in this schema.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - EXISTS
   ==========================================================

   Find customers with at least one order.

   Solve using EXISTS.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - EXISTS WITH CONDITION
   ==========================================================

   Find customers with at least one
   Completed order.

   Use EXISTS.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - NOT EXISTS
   ==========================================================

   Find customers who have never placed
   an order.

   Use NOT EXISTS.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - NO COMPLETED ORDERS
   ==========================================================

   Find customers who have NO Completed orders.

   This should include:

   - Customers with no orders
   - Customers with orders but none Completed

   Use NOT EXISTS.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - PRODUCTS THAT WERE ORDERED
   ==========================================================

   Find products that appear at least once in
   training.order_items.

   Use EXISTS.

   Return:

   product_id
   product_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - PRODUCTS NEVER ORDERED
   ==========================================================

   Find products that never appear in order_items.

   Use NOT EXISTS.

   Return:

   product_id
   product_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - COMPLETED ORDER PRODUCTS
   ==========================================================

   Find products that have appeared in at least one
   Completed order.

   Use EXISTS.

   The subquery will require:

   order_items
   JOIN
   orders

   Return:

   product_id
   product_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - NEVER IN COMPLETED ORDER
   ==========================================================

   Find products that have never appeared in
   a Completed order.

   Use NOT EXISTS.

   Return:

   product_id
   product_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - CORRELATED ORDER COUNT
   ==========================================================

   Return EVERY customer.

   Calculate the number of orders for each customer
   using a correlated scalar subquery.

   Return:

   customer_id
   customer_name
   order_count

   Do not use GROUP BY in the outer query.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - CORRELATED COMPLETED COUNT
   ==========================================================

   Return every customer.

   Calculate their Completed order count using
   a correlated subquery.

   Return:

   customer_id
   customer_name
   completed_order_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - LATEST ORDER
   ==========================================================

   Return every customer and the date/time of
   their latest order.

   Customers with no orders should return NULL.

   Return:

   customer_id
   customer_name
   latest_order_date

   Use a correlated subquery.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - ABOVE CATEGORY AVERAGE
   ==========================================================

   Find products whose price is greater than
   the average price of THEIR OWN category.

   Return:

   product_id
   product_name
   category
   price

   Use a correlated subquery.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - DISPLAY CATEGORY AVERAGE
   ==========================================================

   Return every product with:

   product_id
   product_name
   category
   price
   category_average_price

   Calculate category_average_price using
   a correlated scalar subquery.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - DERIVED TABLE
   ==========================================================

   Calculate order totals inside a derived table.

   Formula:

   SUM(quantity * unit_price)

   Return:

   order_id
   order_value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - FILTER DERIVED TABLE
   ==========================================================

   Using a derived table, find orders whose
   total value is at least 3000.

   Return:

   order_id
   order_value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - JOIN DERIVED TABLE
   ==========================================================

   First calculate order totals in a derived table.

   Then join the result to:

   orders
   customers

   Return:

   order_id
   customer_name
   order_status
   order_value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - COMPLETED HIGH-VALUE ORDERS
   ==========================================================

   Using a derived table, find Completed orders
   worth at least 3000.

   Return:

   order_id
   customer_name
   order_value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - FIRST CTE
   ==========================================================

   Create a CTE named:

   ExpensiveProducts

   It should contain products where:

   price >= 5000

   Final result:

   product_id
   product_name
   price

   Sort highest price first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - ORDER TOTALS CTE
   ==========================================================

   Create:

   OrderTotals

   Calculate:

   order_id
   order_value

   where:

   order_value =
   SUM(quantity * unit_price)

   Final result should sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - FILTER CTE RESULT
   ==========================================================

   Create OrderTotals.

   Then return only orders where:

   order_value >= 3000

   Return:

   order_id
   order_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - CTE + JOIN
   ==========================================================

   Create OrderTotals.

   Join it to:

   orders
   customers

   Return:

   order_id
   customer_name
   order_date
   order_status
   order_value

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - MULTIPLE CTEs
   ==========================================================

   Create:

   OrderTotals

   containing:

   order_id
   order_value


   Create:

   CompletedOrders

   containing Completed orders:

   order_id
   customer_id
   order_date


   Join the CTEs.

   Return:

   order_id
   customer_id
   order_date
   order_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - CTE DEPENDS ON CTE
   ==========================================================

   Create:

   OrderTotals

   Then:

   HighValueOrders

   HighValueOrders should reference OrderTotals
   and keep:

   order_value >= 3000

   Final result:

   order_id
   order_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - CUSTOMER COMPLETED REVENUE
   ==========================================================

   Create a CTE called:

   CustomerRevenue

   Calculate Completed revenue per customer.

   Formula:

   SUM(quantity * unit_price)

   Final output:

   customer_id
   customer_name
   revenue

   Sort highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - HIGH-VALUE CUSTOMERS
   ==========================================================

   Using a CTE, calculate Completed revenue
   by customer.

   Return customers whose revenue is:

   >= 3000

   Return:

   customer_id
   customer_name
   revenue

   Highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - PRODUCT PERFORMANCE CTE
   ==========================================================

   Analyze Completed orders.

   Create a CTE that calculates by product_id:

   order_count
   units_sold
   revenue

   Definitions:

   order_count:
       distinct orders

   units_sold:
       SUM(quantity)

   revenue:
       SUM(quantity * unit_price)

   Then join products to display:

   product_id
   product_name
   category
   order_count
   units_sold
   revenue

   Sort highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - CUSTOMER METRICS CTE
   ==========================================================

   Return EVERY customer.

   Create a CTE containing:

   customer_id
   total_orders
   completed_orders
   cancelled_orders

   Use conditional aggregation.

   Then join customers for:

   customer_name

   Final columns:

   customer_id
   customer_name
   total_orders
   completed_orders
   cancelled_orders
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - FILTER CUSTOMER METRICS
   ==========================================================

   Using a CTE, calculate:

   total_orders
   completed_orders

   for every customer.

   Then return customers where:

   total_orders >= 2

   AND

   completed_orders >= 1

   Return:

   customer_id
   customer_name
   total_orders
   completed_orders
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - ABOVE-AVERAGE ORDER COUNT
   ==========================================================

   First calculate order_count by customer.

   Then calculate the average order_count.

   Return customers whose order_count is above
   that average.

   Return:

   customer_id
   customer_name
   order_count

   Use:

   CTE
   +
   scalar subquery

   Use decimal arithmetic when calculating
   the average.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - ABOVE-AVERAGE CUSTOMER REVENUE
   ==========================================================

   Calculate Completed revenue by customer.

   Then return customers whose revenue is above
   the average Completed revenue among customers
   who generated Completed revenue.

   Return:

   customer_id
   customer_name
   revenue
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 40 - ORDER VALUE ABOVE AVERAGE
   ==========================================================

   Create OrderTotals.

   Find orders whose order_value is greater than
   average order_value.

   Return:

   order_id
   order_value

   Sort highest first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 41 - ACTIVE CUSTOMERS WITHOUT ORDERS
   ==========================================================

   Find active customers who have no orders.

   Use NOT EXISTS.

   Return:

   customer_id
   customer_name
   email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 42 - CUSTOMERS WHO BOUGHT ACCESSORIES
   ==========================================================

   Find customers who have an order containing
   a product from:

   Accessories

   Use EXISTS.

   Tables inside the existence check may require:

   orders
   order_items
   products

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 43 - NEVER BOUGHT ELECTRONICS
   ==========================================================

   Find customers who have never had an Electronics
   product in any order.

   Use NOT EXISTS.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 44 - COMPLETED BUT NEVER CANCELLED
   ==========================================================

   Find customers who:

   - Have at least one Completed order

   AND

   - Have no Cancelled orders

   Use:

   EXISTS
   +
   NOT EXISTS

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 45 - PRE-AGGREGATION
   ==========================================================

   Create OrderTotals with one row per order.

   Calculate:

   line_count
   total_units
   order_value

   Then join to orders and customers.

   Return:

   order_id
   customer_name
   order_status
   line_count
   total_units
   order_value

   Sort highest order value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 46 - THINK ABOUT SCALAR SUBQUERIES

   Consider:

       WHERE customer_id =
       (
           SELECT customer_id
           FROM training.orders
       )

   Assume the inner query returns multiple rows.

   Questions:

   1. Is this valid for execution?

   2. Why?

   3. Name two techniques that could be appropriate
      if the requirement is membership/existence.
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 47 - THINK ABOUT EXISTS

   Answer:

   1. What does EXISTS test?

   2. Why is SELECT 1 commonly used?

   3. Does EXISTS require returning actual columns
      to the outer SELECT?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 48 - NOT IN AND NULL
   ==========================================================

   Suppose a subquery used by NOT IN returns:

       1
       2
       NULL

   Why can this produce unexpected results?

   Which pattern is often preferable when checking
   that no related row exists?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 49 - CTE SCOPE

   Consider:

       ;WITH ProductData AS
       (
           SELECT *
           FROM training.products
       )
       SELECT *
       FROM ProductData;

   Then as a separate statement:

       SELECT *
       FROM ProductData;

   Questions:

   1. Does the second statement work?

   2. Why or why not?

   3. Is a CTE a permanent table?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 50 - CTE vs PERFORMANCE
   ==========================================================

   Evaluate this statement:

   "Using a CTE automatically makes a SQL query faster."

   Questions:

   1. Is this guaranteed to be true?

   2. What is the main reason we are currently
      using CTEs?

   3. What should eventually be examined when
      query performance matters?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER REVENUE BENCHMARK
   ==========================================================

   Analyze Completed orders only.

   Step 1:

   Calculate for each customer:

   completed_orders
   revenue

   Step 2:

   Calculate average customer revenue.

   Step 3:

   Return customers whose revenue is ABOVE
   that average.

   Return:

   customer_id
   customer_name
   completed_orders
   revenue
   average_revenue
   difference_from_average

   Sort highest revenue first.

   Use CTEs.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - PRODUCT CATEGORY BENCHMARK
   ==========================================================

   Find products whose price is above the average
   price of their category.

   Use a CTE to calculate category averages.

   Return:

   product_id
   product_name
   category
   price
   category_average_price
   difference_from_average

   Sort:

   category
   then difference_from_average DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - CUSTOMER PERFORMANCE PIPELINE
   ==========================================================

   Analyze Completed orders.

   Build a multi-stage CTE pipeline.

   Stage 1:
       Calculate one row per order:

       order_id
       total_units
       order_value

   Stage 2:
       Keep Completed orders and customer_id.

   Stage 3:
       Calculate customer performance:

       completed_order_count
       total_units
       revenue

   Final output:

   customer_id
   customer_name
   completed_order_count
   total_units
   revenue

   Keep only customers with:

   revenue >= 1000

   Sort highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - CUSTOMER BEHAVIOR
   ==========================================================

   Return EVERY customer.

   Calculate:

   total_orders
   completed_orders
   cancelled_orders

   Then classify:

   No orders:
       No Orders

   completed_orders >= 2:
       Repeat Customer

   completed_orders = 1:
       Customer

   otherwise:
       No Completed Orders

   Return:

   customer_id
   customer_name
   total_orders
   completed_orders
   cancelled_orders
   customer_type

   Use a CTE.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL SUBQUERY / CTE CHALLENGE
   ==========================================================

   Build a Completed product performance report.

   Stage 1:

   For each product calculate:

   completed_order_count
   customer_count
   units_sold
   revenue

   Stage 2:

   Calculate average product revenue among products
   that appear in Completed orders.

   Stage 3:

   Return products whose revenue is ABOVE that average.

   Final columns:

   product_id
   product_name
   category
   completed_order_count
   customer_count
   units_sold
   revenue
   average_product_revenue
   difference_from_average

   Requirements:

   completed_order_count:
       distinct orders

   customer_count:
       distinct customers

   Sort:
       revenue DESC

   Use CTEs and/or a scalar subquery.
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before completing Chapter 06, make sure
   you can explain:

   1. What a subquery is

   2. Scalar vs multi-row subqueries

   3. Why = cannot be used when a scalar subquery
      unexpectedly returns multiple rows

   4. IN with a subquery

   5. EXISTS and SELECT 1

   6. NOT EXISTS

   7. The NULL risk of NOT IN

   8. What makes a subquery correlated

   9. Subquery vs JOIN for existence checks

   10. What a derived table is

   11. Why a derived table needs an alias

   12. What pre-aggregation means

   13. What a CTE is

   14. CTE scope

   15. Why ;WITH is useful in T-SQL

   16. How multiple CTEs are written

   17. How one CTE can reference an earlier CTE

   18. Why CTEs do not automatically mean
       better performance

   19. How to create a multi-stage analytical
       query pipeline

   20. How to combine:

       CTE
       JOIN
       GROUP BY
       EXISTS
       Scalar Subquery
       Conditional Aggregation
       Business Metrics
   ========================================================== */