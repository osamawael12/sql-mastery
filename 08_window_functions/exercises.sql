/*
============================================================
SQL MASTERY
08 - WINDOW FUNCTIONS

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve every exercise before checking solutions.sql.

Topics:
- OVER()
- PARTITION BY
- ROW_NUMBER
- RANK
- DENSE_RANK
- NTILE
- Window Aggregates
- Running Totals
- Moving Averages
- Percent of Total
- LAG / LEAD
- FIRST_VALUE / LAST_VALUE
- Top N per Group
- Time Series Analysis
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - OVER()

   Return every product and display the overall
   average product price beside it.

   Return:

   product_id
   product_name
   price
   overall_average_price

   Do not use GROUP BY.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - CATEGORY AVERAGE

   Return every product with the average price
   of its category.

   Return:

   product_id
   product_name
   category
   price
   category_average_price

   Use:

   AVG()
   OVER()
   PARTITION BY
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - TOTAL CUSTOMER COUNT
   ==========================================================

   Keep every customer row.

   Display the total number of customers beside
   every customer.

   Return:

   customer_id
   customer_name
   total_customers
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - PRODUCTS IN CATEGORY
   ==========================================================

   Keep every product.

   Calculate how many products belong to the
   same category.

   Return:

   product_id
   product_name
   category
   products_in_category
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - CATEGORY STOCK
   ==========================================================

   Keep every product.

   Calculate total stock for its category.

   Return:

   product_name
   category
   stock_quantity
   category_stock
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - CATEGORY PRICE RANGE
   ==========================================================

   Return:

   product_name
   category
   price
   category_min_price
   category_max_price

   Use window functions.

   Do not collapse product rows.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - DIFFERENCE FROM CATEGORY AVERAGE
   ==========================================================

   Return:

   product_name
   category
   price
   category_average_price
   difference_from_category_average

   Formula:

   price - category average
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - ROW_NUMBER
   ==========================================================

   Number all products from highest price
   to lowest price.

   Return:

   product_id
   product_name
   price
   price_row_number

   If prices tie, use product_id ASC as
   the tie-breaker.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - ROW_NUMBER BY CATEGORY
   ==========================================================

   Number products independently inside each category.

   Most expensive product should be number 1.

   Return:

   product_id
   product_name
   category
   price
   category_row_number

   Use product_id as a tie-breaker.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - RANK
   ==========================================================

   Rank products globally by price.

   Equal prices should receive the same rank.

   Rank gaps are allowed.

   Return:

   product_name
   price
   price_rank
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - DENSE_RANK
   ==========================================================

   Rank products globally by price.

   Equal prices should receive the same rank.

   Rank gaps should NOT occur.

   Return:

   product_name
   price
   dense_price_rank
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - COMPARE RANKING FUNCTIONS
   ==========================================================

   Return:

   product_id
   product_name
   price
   row_number_value
   rank_value
   dense_rank_value

   Compare:

   ROW_NUMBER
   RANK
   DENSE_RANK
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - CATEGORY RANK
   ==========================================================

   Rank products by price inside each category.

   Use DENSE_RANK.

   Return:

   product_id
   product_name
   category
   price
   category_price_rank
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - NTILE
   ==========================================================

   Divide products into 4 approximately equal
   buckets based on price descending.

   Return:

   product_id
   product_name
   price
   price_quartile

   Use product_id as a deterministic tie-breaker.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - TOP 2 PER CATEGORY
   ==========================================================

   Find the 2 most expensive products in
   each category.

   Return:

   product_id
   product_name
   category
   price
   rn

   Use:

   ROW_NUMBER
   CTE

   Do not use TOP.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - MOST EXPENSIVE PER CATEGORY
   ==========================================================

   Return one product per category:

   product_id
   product_name
   category
   price

   Choose the highest-priced product.

   Use product_id to break price ties.

   Use ROW_NUMBER.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - LATEST ORDER PER CUSTOMER
   ==========================================================

   Return each customer's latest order.

   Only customers who currently have orders need
   to appear.

   Return:

   customer_id
   order_id
   order_date
   order_status

   Use:

   ROW_NUMBER
   PARTITION BY customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - LATEST ORDER WITH CUSTOMER NAME
   ==========================================================

   Extend the previous result.

   Return:

   customer_id
   customer_name
   order_id
   order_date
   order_status
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - FIRST ORDER PER CUSTOMER
   ==========================================================

   Return the first order for every customer
   who has an order.

   Return:

   customer_id
   order_id
   order_date
   order_status
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - ORDER SEQUENCE
   ==========================================================

   Give every order a sequential number inside
   its customer history.

   First order = 1.

   Return:

   customer_id
   order_id
   order_date
   customer_order_number

   Use order_id as a tie-breaker.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - ORDER TOTALS
   ==========================================================

   Before applying advanced windows, build a CTE
   containing one row per order.

   Calculate:

   order_id
   total_units
   order_value

   Formulas:

   total_units:
       SUM(quantity)

   order_value:
       SUM(quantity * unit_price)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - RUNNING ORDER VALUE
   ==========================================================

   Using one row per order, calculate running
   order value across all orders.

   Order by:

   order_date
   order_id

   Return:

   order_id
   order_date
   order_value
   running_order_value

   Use an explicit ROWS frame.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - RUNNING ORDER COUNT
   ==========================================================

   Return:

   order_id
   order_date
   running_order_count

   Ordered by:

   order_date
   order_id

   Use:

   COUNT() OVER(...)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - CUSTOMER RUNNING SPENDING
   ==========================================================

   First calculate order_value.

   Then calculate running spending separately
   for each customer.

   Return:

   customer_id
   order_id
   order_date
   order_value
   running_spending

   Running total must restart for each customer.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - CUSTOMER RUNNING SPENDING + NAME
   ==========================================================

   Extend the previous result.

   Return:

   customer_id
   customer_name
   order_id
   order_date
   order_value
   running_spending
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - MOVING AVERAGE
   ==========================================================

   Calculate a moving average of order_value using:

   current order
   +
   previous 2 orders

   Return:

   order_id
   order_date
   order_value
   moving_average_3_orders

   Order globally by:

   order_date
   order_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - MOVING SUM
   ==========================================================

   Calculate the sum of:

   current order
   +
   previous 2 orders

   Return:

   order_id
   order_date
   order_value
   moving_sum_3_orders
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - PRODUCT COMPLETED REVENUE
   ==========================================================

   First aggregate Completed revenue by product.

   Create a CTE containing:

   product_id
   revenue

   Then return the result highest revenue first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - PRODUCT REVENUE SHARE
   ==========================================================

   Analyze Completed orders.

   Calculate revenue per product.

   Then return:

   product_id
   revenue
   total_revenue
   revenue_percent

   revenue_percent:

   product revenue / total revenue * 100

   Use a window function for total revenue.

   Protect division using NULLIF.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - PRODUCT SHARE WITH NAMES
   ==========================================================

   Extend the previous query.

   Return:

   product_id
   product_name
   category
   revenue
   revenue_percent
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - CATEGORY REVENUE SHARE
   ==========================================================

   Analyze Completed orders.

   First calculate revenue per product.

   Then calculate:

   category_revenue

   category_revenue_percent

   where category_revenue_percent is the product's
   percentage of its own category revenue.

   Return:

   product_id
   product_name
   category
   revenue
   category_revenue
   category_revenue_percent
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - LAG
   ==========================================================

   Calculate order_value per order.

   Return:

   order_id
   order_date
   order_value
   previous_order_value

   Previous means the previous order globally based on:

   order_date
   order_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - CHANGE FROM PREVIOUS ORDER
   ==========================================================

   Extend the previous query.

   Return:

   order_id
   order_date
   order_value
   previous_order_value
   change_from_previous

   Formula:

   current order value - previous order value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - LEAD
   ==========================================================

   Return:

   order_id
   order_date
   order_value
   next_order_value

   Use LEAD.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - PREVIOUS ORDER DATE BY CUSTOMER
   ==========================================================

   For every order return:

   customer_id
   order_id
   order_date
   previous_order_date

   Previous order must belong to the SAME customer.

   Use:

   LAG
   PARTITION BY
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - DAYS BETWEEN CUSTOMER ORDERS
   ==========================================================

   Return:

   customer_id
   order_id
   order_date
   previous_order_date
   days_since_previous_order

   For the customer's first order,
   days_since_previous_order should naturally be NULL.

   Use:

   LAG
   DATEDIFF
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - NEXT ORDER DATE
   ==========================================================

   For every order calculate the customer's
   next order date.

   Return:

   customer_id
   order_id
   order_date
   next_order_date
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - FIRST_VALUE
   ==========================================================

   Keep every product.

   Return the highest price in its category.

   Return:

   product_id
   product_name
   category
   price
   highest_category_price

   Use FIRST_VALUE.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - MOST EXPENSIVE PRODUCT NAME
   ==========================================================

   Keep every product row.

   Display the name of the most expensive product
   in that category beside each row.

   Return:

   product_name
   category
   price
   most_expensive_product

   Use FIRST_VALUE.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 40 - LAST_VALUE
   ==========================================================

   Keep every product row.

   Return the lowest price in its category using:

   LAST_VALUE

   Requirements:

   - Order prices DESC
   - Use a frame covering the ENTIRE partition

   Return:

   product_name
   category
   price
   lowest_category_price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 41 - CUSTOMER REVENUE RANK
   ==========================================================

   Analyze Completed orders.

   First calculate customer revenue.

   Then rank customers by revenue.

   Equal revenue should receive equal rank
   without gaps.

   Return:

   customer_id
   customer_name
   revenue
   revenue_rank

   Use DENSE_RANK.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 42 - CUSTOMER REVENUE SHARE
   ==========================================================

   Analyze Completed revenue by customer.

   Return:

   customer_id
   customer_name
   revenue
   revenue_share_percent

   Use a window function for total revenue.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 43 - PRODUCT RANK WITHIN CATEGORY
   ==========================================================

   Analyze Completed revenue per product.

   Rank each product by revenue within its category.

   Return:

   product_id
   product_name
   category
   revenue
   category_revenue_rank

   Use DENSE_RANK.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 44 - TOP REVENUE PRODUCT PER CATEGORY
   ==========================================================

   Analyze Completed product revenue.

   Return ONE product per category.

   Return:

   product_id
   product_name
   category
   revenue

   Use:

   ROW_NUMBER
   CTE

   Break revenue ties with product_id.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 45 - MONTHLY REVENUE
   ==========================================================

   Calculate Completed revenue by month.

   Return:

   order_month
   revenue

   Represent month as the first date of the month.

   Sort chronologically.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 46 - CUMULATIVE MONTHLY REVENUE
   ==========================================================

   Extend monthly Completed revenue.

   Calculate:

   cumulative_revenue

   Return:

   order_month
   revenue
   cumulative_revenue

   Use an explicit running ROWS frame.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 47 - PREVIOUS MONTH REVENUE
   ==========================================================

   Return:

   order_month
   revenue
   previous_month_revenue

   Use LAG.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 48 - MONTHLY GROWTH
   ==========================================================

   Calculate:

   revenue_change

   growth_percent

   Formulas:

   revenue_change =
       revenue - previous_revenue

   growth_percent =
       (revenue - previous_revenue)
       / previous_revenue
       * 100

   Protect against division by zero.

   Return:

   order_month
   revenue
   previous_revenue
   revenue_change
   growth_percent
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 49 - FIRST / REPEAT ORDER
   ==========================================================

   Number every customer's orders chronologically.

   Then classify:

   order_number = 1
       First Order

   otherwise
       Repeat Order

   Return:

   order_id
   customer_id
   order_date
   order_number
   order_type
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 50 - CUSTOMER ORDER INTERVAL
   ==========================================================

   Build a customer order-history report.

   Return:

   customer_id
   customer_name
   order_id
   order_date
   order_number
   previous_order_date
   days_since_previous_order

   Use:

   ROW_NUMBER
   LAG
   DATEDIFF
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 51 - THINK: GROUP BY vs PARTITION BY

   Explain the key difference between:

   GROUP BY category

   and:

   OVER(PARTITION BY category)

   What happens to the original product rows?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 52 - THINK: RANKING FUNCTIONS

   Values:

   100
   90
   90
   80

   Write the output of:

   ROW_NUMBER

   RANK

   DENSE_RANK
   ========================================================== */

/*
Answer:

ROW_NUMBER:


RANK:


DENSE_RANK:


*/


/* ==========================================================
   EXERCISE 53 - THINK: TIE BREAKING

   Why can this be non-deterministic when prices tie?

       ROW_NUMBER() OVER
       (
           ORDER BY price DESC
       )

   How can product_id help?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 54 - THINK: FILTERING

   Why is this wrong?

       SELECT
           product_name,
           ROW_NUMBER() OVER
           (
               ORDER BY price DESC
           ) AS rn
       FROM training.products
       WHERE rn <= 3;

   How should the query be structured?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 55 - THINK: WINDOW ORDER

   Does:

       ROW_NUMBER() OVER
       (
           ORDER BY price DESC
       )

   guarantee that the final query output will
   physically display rows by price DESC?

   If not, what else is required?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 56 - THINK: LAST_VALUE

   Why can LAST_VALUE produce surprising results
   when ORDER BY is specified but the frame is not
   explicitly defined?

   What frame can be used to inspect the entire partition?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 57 - THINK: RESULT GRAIN

   Business requirement:

   "Calculate running revenue per order."

   order_items contains multiple rows per order.

   Why should order_items normally be aggregated
   before applying the running total?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 58 - THINK: LAG

   For the first order of each customer:

   What should:

       LAG(order_date)

   normally return?

   Why?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 59 - THINK: NTILE

   Does:

       NTILE(4)

   create four equal numeric price ranges?

   Explain what it actually does.
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 60 - CHOOSE THE FUNCTION

   Choose the best function/pattern:

   ROW_NUMBER
   RANK
   DENSE_RANK
   NTILE
   LAG
   LEAD
   SUM() OVER
   AVG() OVER


   1. Previous month's revenue

   2. Next customer order date

   3. Running revenue

   4. Unique sequence for customer orders

   5. Rank with ties and gaps

   6. Rank with ties and no gaps

   7. Divide customers into 4 ordered buckets

   8. 3-row moving average
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

5.

6.

7.

8.

*/


/* ==========================================================
   CHALLENGE 1 - PRODUCT ANALYTICS REPORT
   ==========================================================

   Analyze Completed sales per product.

   First calculate:

   product_id
   product_name
   category
   units_sold
   revenue

   Then add:

   overall_revenue
   overall_revenue_percent
   category_revenue
   category_revenue_percent
   category_revenue_rank

   Requirements:

   - overall percentage must use total Completed revenue
   - category percentage must use category revenue
   - category ranking must use DENSE_RANK
   - protect percentage calculations from division by zero

   Sort:

   category
   category_revenue_rank
   product_id
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - CUSTOMER ANALYTICS REPORT
   ==========================================================

   Analyze Completed orders.

   For every customer who generated Completed revenue,
   calculate:

   customer_id
   customer_name
   completed_orders
   total_units
   revenue
   revenue_rank
   revenue_share_percent

   Requirements:

   completed_orders:
       distinct orders

   revenue_rank:
       DENSE_RANK by revenue DESC

   revenue_share_percent:
       customer revenue / total customer revenue * 100

   Sort:

   revenue_rank
   customer_id
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - ORDER HISTORY REPORT
   ==========================================================

   Build one row per order.

   Calculate:

   order_value

   Then for each customer return:

   customer_id
   customer_name
   order_id
   order_date
   order_number
   previous_order_date
   days_since_previous_order
   order_value
   running_customer_value

   Requirements:

   - order_number starts at 1 for each customer
   - previous order belongs to same customer
   - running total restarts per customer
   - use deterministic ordering

   Sort:

   customer_id
   order_number
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - MONTHLY GROWTH REPORT
   ==========================================================

   Analyze Completed revenue by month.

   Return:

   order_month
   revenue
   previous_revenue
   revenue_change
   growth_percent
   cumulative_revenue
   revenue_rank

   Requirements:

   previous_revenue:
       LAG

   cumulative_revenue:
       SUM() OVER with explicit running frame

   revenue_rank:
       DENSE_RANK by revenue DESC

   growth_percent:
       protect against division by zero

   Sort:

   order_month
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - TOP PRODUCTS PER CATEGORY
   ==========================================================

   Analyze Completed sales.

   Calculate product revenue first.

   Then return the TOP 2 products from each category
   according to revenue.

   Return:

   product_id
   product_name
   category
   units_sold
   revenue
   category_row_number
   category_revenue_percent

   Requirements:

   - ROW_NUMBER within category
   - highest revenue first
   - product_id tie-breaker
   - category revenue percentage
   - filter category_row_number <= 2

   Sort:

   category
   category_row_number
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before completing Chapter 08,
   make sure you can explain:

   1. GROUP BY vs window functions

   2. OVER()

   3. PARTITION BY

   4. Window ORDER BY vs final ORDER BY

   5. ROW_NUMBER vs RANK vs DENSE_RANK

   6. Why deterministic tie-breakers matter

   7. NTILE

   8. Aggregate window functions

   9. Running totals

   10. Window frames

   11. Moving averages

   12. Percent of total

   13. Percent within partition

   14. LAG

   15. LEAD

   16. FIRST_VALUE

   17. LAST_VALUE and its frame

   18. Top N per group

   19. Latest row per group

   20. Why window results usually require
       another query layer before filtering

   21. Why result grain still matters

   22. Why pre-aggregation may be required

   23. How window functions work over
       already aggregated results

   24. How to calculate month-over-month growth

   25. How window functions support
       real analytical reporting
   ========================================================== */