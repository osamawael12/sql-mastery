/*
============================================================
SQL MASTERY
05 - DATA TRANSFORMATION

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve each exercise before checking solutions.sql.

Topics:
- Calculated Columns
- CASE
- COALESCE
- ISNULL
- NULLIF
- CAST
- CONVERT
- TRY_CAST
- String Functions
- Date Functions
- Conditional Aggregation
- Profit and Margin
- Business Transformations
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - CALCULATED COLUMN
   ==========================================================

   Calculate unit profit for every product.

   Formula:

   price - cost

   Return:

   product_id
   product_name
   price
   cost
   unit_profit
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - ORDER LINE VALUE
   ==========================================================

   Calculate the value of every order-item line.

   Formula:

   quantity * unit_price

   Return:

   order_item_id
   order_id
   quantity
   unit_price
   line_value
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - BASIC CASE
   ==========================================================

   Classify products:

   price >= 10000
       Expensive

   otherwise
       Affordable

   Return:

   product_name
   price
   price_group
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - MULTIPLE CASE CONDITIONS
   ==========================================================

   Create a price_level:

   price >= 10000
       High

   price >= 1000
       Medium

   otherwise
       Low

   Return:

   product_name
   price
   price_level
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - ORDER STATUS TRANSFORMATION
   ==========================================================

   Transform:

   Completed -> Successful
   Cancelled -> Failed
   Anything else -> In Progress

   Return:

   order_id
   order_status
   status_group
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - SIMPLE CASE
   ==========================================================

   Solve the previous exercise using simple CASE:

   CASE order_status
       WHEN ...
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - CASE WITH NULL
   ==========================================================

   Return:

   customer_name
   city
   display_city

   If city is NULL:

   display_city = Unknown

   Otherwise return the original city.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - COALESCE
   ==========================================================

   Solve the previous problem using COALESCE.

   Return:

   customer_name
   display_city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - ISNULL
   ==========================================================

   Solve the same problem using SQL Server ISNULL.

   Return:

   customer_name
   display_city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - CAST
   ==========================================================

   Convert product price to INT.

   Return:

   product_name
   price
   price_as_integer
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - DATETIME TO DATE
   ==========================================================

   Convert order_date from DATETIME2 to DATE
   using CAST.

   Return:

   order_id
   order_date
   order_day
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - CONVERT
   ==========================================================

   Solve the previous exercise using CONVERT.

   Return:

   order_id
   order_date
   order_day
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - DATE TO TEXT
   ==========================================================

   Convert order_date to text in:

   yyyy-mm-dd

   Use:

   VARCHAR(10)
   style 23

   Return:

   order_id
   order_date_text
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - TRY_CAST
   ==========================================================

   Attempt these conversions:

   '500' -> INT
   'SQL' -> INT

   Return:

   valid_number
   invalid_number

   The query must not fail.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - CONCAT
   ==========================================================

   Create:

   customer_details

   Format conceptually:

   Ahmed Ali - ahmed@example.com

   Return:

   customer_details
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - CONCAT + NULL
   ==========================================================

   Create a customer location:

   customer_name - city

   If city is NULL, display:

   Unknown

   Use:

   CONCAT
   COALESCE

   Return:

   customer_location
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - LEN
   ==========================================================

   Return:

   customer_name
   name_length
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - UPPER / LOWER
   ==========================================================

   Return:

   customer_name
   uppercase_name
   email
   lowercase_email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - TRIM
   ==========================================================

   Return:

   customer_name
   clean_name

   Use TRIM.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - STRING EXTRACTION
   ==========================================================

   For each customer return:

   customer_name

   first_three_characters
       first 3 characters of customer_name

   last_four_email_characters
       last 4 characters of email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - SUBSTRING
   ==========================================================

   Extract the first 5 characters of customer_name
   using SUBSTRING.

   Return:

   customer_name
   short_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - REPLACE
   ==========================================================

   Replace:

   @

   with:

   [at]

   in customer emails.

   Return:

   email
   display_email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - YEAR / MONTH / DAY
   ==========================================================

   Return:

   order_id
   order_date
   order_year
   order_month
   order_day
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - DATENAME
   ==========================================================

   Return the month name for every order.

   Return:

   order_id
   order_date
   month_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - DATEADD
   ==========================================================

   Add 30 days to every customer's signup date.

   Return:

   customer_name
   signup_date
   date_after_30_days
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - DATEDIFF
   ==========================================================

   Calculate the number of day boundaries between
   signup_date and today's date.

   Return:

   customer_name
   signup_date
   days_since_signup
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - EOMONTH
   ==========================================================

   Find the month-end date for every order.

   Return:

   order_id
   order_date
   month_end
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - MONTH BUCKET
   ==========================================================

   Transform every order_date into the first
   day of its month.

   Example:

   2025-03-17
       ->
   2025-03-01

   Use DATEFROMPARTS.

   Return:

   order_id
   order_date
   order_month
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - ORDERS BY MONTH
   ==========================================================

   Count orders by month.

   Use the first day of the month as the bucket.

   Return:

   order_month
   order_count

   Sort chronologically.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - PRODUCT SEGMENTATION
   ==========================================================

   Classify products:

   price >= 10000:
       Premium

   price >= 2000:
       Mid Range

   otherwise:
       Budget

   Return:

   product_id
   product_name
   price
   price_segment

   Sort highest price first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - GROUP BY TRANSFORMATION
   ==========================================================

   Using the same price segments:

   Premium
   Mid Range
   Budget

   Count products in each segment.

   Return:

   price_segment
   product_count
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - CUSTOMER SEGMENTATION
   ==========================================================

   Classify customers:

   signup_date < 2025-02-01:
       Early Customer

   otherwise:
       New Customer

   Return:

   customer_name
   signup_date
   customer_segment
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - CONDITIONAL AGGREGATION
   ==========================================================

   Return one summary row containing:

   total_orders
   completed_orders
   cancelled_orders
   pending_orders

   Use:

   SUM(CASE ...)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - CONDITIONAL COUNT
   ==========================================================

   Calculate:

   completed_orders
   cancelled_orders

   using:

   COUNT(CASE ...)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - DISTINCT CONDITIONAL COUNT
   ==========================================================

   How many different customers have at least
   one Completed order?

   Return:

   customers_with_completed_orders

   Use:

   COUNT(DISTINCT CASE ...)
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - CUSTOMER ORDER SUMMARY
   ==========================================================

   Return EVERY customer, including customers
   with no orders.

   Calculate:

   total_orders
   completed_orders
   cancelled_orders

   Return:

   customer_id
   customer_name
   total_orders
   completed_orders
   cancelled_orders

   Use conditional aggregation.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - CONDITIONAL REVENUE
   ==========================================================

   Using orders + order_items calculate:

   completed_revenue
   cancelled_order_value

   Return both metrics in ONE result row.

   Use SUM(CASE ...).
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - REVENUE BY STATUS
   ==========================================================

   Return:

   order_status
   order_value

   Calculate:

   SUM(quantity * unit_price)

   Group by order_status.

   Sort highest value first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - PROFIT MARGIN
   ==========================================================

   For each product calculate:

   unit_profit

   margin_percent

   Formulas:

   unit_profit =
       price - cost

   margin_percent =
       (price - cost) * 100.0 / price

   Protect the calculation from division by zero
   using NULLIF.

   Return:

   product_name
   price
   cost
   unit_profit
   margin_percent
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 40 - STOCK CLASSIFICATION
   ==========================================================

   Create stock_status:

   stock_quantity = 0
       Out of Stock

   stock_quantity <= 20
       Low Stock

   otherwise
       Healthy Stock

   Return:

   product_name
   stock_quantity
   stock_status
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 41 - SALES DETAIL TRANSFORMATION
   ==========================================================

   Join:

   orders
   customers
   order_items
   products

   Return:

   order_id
   order_day
   customer_name
   display_city
   product_name
   quantity
   unit_price
   line_revenue
   status_group

   Transformations:

   order_day:
       Convert order_date to DATE

   display_city:
       NULL -> Unknown

   line_revenue:
       quantity * unit_price

   status_group:

       Completed -> Successful
       Cancelled -> Failed
       Otherwise -> In Progress
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 42 - MONTHLY ORDER METRICS
   ==========================================================

   For every month calculate:

   total_orders
   completed_orders
   cancelled_orders

   Return:

   order_month
   total_orders
   completed_orders
   cancelled_orders

   Use:

   DATEFROMPARTS
   conditional aggregation

   Sort chronologically.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 43 - MONTHLY COMPLETED REVENUE
   ==========================================================

   Calculate Completed revenue by month.

   Return:

   order_month
   revenue

   Requirements:

   - Completed orders only
   - Revenue = quantity * unit_price
   - Month represented as the first day of month
   - Sort chronologically
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 44 - CUSTOMER COMPLETED REVENUE
   ==========================================================

   Return EVERY customer.

   Calculate Completed revenue.

   Customers with no Completed revenue should show:

   0

   Return:

   customer_id
   customer_name
   completed_revenue

   Hint:

   LEFT JOIN
   SUM(CASE ...)
   COALESCE
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 45 - PRODUCT BUSINESS REPORT
   ==========================================================

   Return:

   product_id
   product_name
   price
   cost
   stock_quantity
   unit_profit
   margin_percent
   price_segment
   stock_status

   price_segment:

       price >= 10000 -> Premium
       price >= 2000  -> Mid Range
       otherwise      -> Budget

   stock_status:

       stock = 0      -> Out of Stock
       stock <= 20    -> Low Stock
       otherwise      -> Healthy Stock

   Protect margin from division by zero.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 46 - THINK ABOUT CASE ORDER

   Consider:

       CASE
           WHEN price >= 1000 THEN 'Medium'
           WHEN price >= 10000 THEN 'High'
           ELSE 'Low'
       END

   For price = 30000:

   1. What value is returned?

   2. Why?

   3. How should the conditions be ordered?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 47 - THINK ABOUT NULL
   ==========================================================

   Answer:

   1. Does COALESCE(city, N'Unknown')
      permanently update the table?

   2. What does COALESCE return when city has a value?

   3. What does it return when city is NULL?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 48 - INTEGER DIVISION
   ==========================================================

   What is the important difference between:

       1 / 2

   and:

       1.0 / 2

   in SQL Server?

   Why does this matter for percentage calculations?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 49 - NULLIF
   ==========================================================

   Explain why:

       profit / NULLIF(revenue, 0)

   can be safer than:

       profit / revenue

   when revenue may equal zero.
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 50 - TRANSFORMATION VS UPDATE
   ==========================================================

   Consider:

       SELECT
           UPPER(customer_name)
       FROM training.customers;

   Answer:

   1. Does this permanently change customer_name?

   2. What does it change?

   3. What type of SQL operation would be needed
      to permanently modify stored values?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER BUSINESS REPORT
   ==========================================================

   Return EVERY customer.

   Return:

   customer_id
   customer_name
   display_city
   signup_month
   total_orders
   completed_orders
   cancelled_orders
   latest_order_date
   customer_type

   display_city:
       NULL -> Unknown

   signup_month:
       First day of signup month

   customer_type:

       No orders:
           No Orders

       At least 2 Completed orders:
           Repeat Customer

       Otherwise:
           Customer

   Sort:

   total_orders DESC
   customer_name ASC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - PRODUCT PROFITABILITY
   ==========================================================

   For every product calculate:

   product_id
   product_name
   category
   price
   cost
   unit_profit
   margin_percent
   price_segment

   price_segment:

       >= 10000 -> Premium
       >= 2000  -> Mid Range
       otherwise -> Budget

   Then sort:

   margin_percent DESC

   Protect against division by zero.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - MONTHLY BUSINESS SUMMARY
   ==========================================================

   For every order month calculate:

   order_month
   total_orders
   completed_orders
   cancelled_orders
   distinct_customers
   completed_revenue

   Definitions:

   total_orders:
       Distinct order IDs

   completed_orders:
       Distinct Completed order IDs

   cancelled_orders:
       Distinct Cancelled order IDs

   distinct_customers:
       Distinct customers with orders that month

   completed_revenue:
       Revenue from Completed orders only

   IMPORTANT:

   Joining orders to order_items can multiply
   order rows.

   Use DISTINCT where required.

   Sort chronologically.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - PRODUCT SALES TRANSFORMATION
   ==========================================================

   Return EVERY product, even if it has no sales.

   Calculate:

   product_id
   product_name
   price_segment
   completed_units
   cancelled_units
   completed_revenue

   price_segment:

       >= 10000 -> Premium
       >= 2000  -> Mid Range
       otherwise -> Budget

   Products with no matching activity should display:

   0

   for quantity/revenue metrics.

   Sort:

   completed_revenue DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL TRANSFORMATION CHALLENGE
   ==========================================================

   Build a Completed product performance report.

   For every product that appears in Completed orders:

   Return:

   product_id
   product_name
   category
   completed_order_count
   customer_count
   units_sold
   revenue
   estimated_gross_profit
   revenue_segment

   Definitions:

   completed_order_count:
       Distinct Completed orders

   customer_count:
       Distinct customers

   units_sold:
       SUM(quantity)

   revenue:
       SUM(quantity * unit_price)

   estimated_gross_profit:
       SUM(quantity * (unit_price - cost))

   revenue_segment:

       revenue >= 10000:
           High Revenue

       revenue >= 3000:
           Medium Revenue

       otherwise:
           Low Revenue

   Sort:

   revenue DESC

   Note:

   Using current product cost for historical profit
   is a simplifying assumption in this training model.
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before completing Chapter 05, make sure you can explain:

   1. CASE and why condition order matters

   2. Searched CASE vs simple CASE

   3. COALESCE vs ISNULL

   4. NULLIF and division by zero

   5. CAST vs CONVERT

   6. TRY_CAST and why it is useful

   7. CONCAT vs string +

   8. Common string functions

   9. Common date functions

   10. How to create a month bucket

   11. SUM(CASE ...) conditional aggregation

   12. COUNT(CASE ...) conditional aggregation

   13. COUNT(DISTINCT CASE ...)

   14. Integer vs decimal division

   15. Query transformations vs permanent data changes

   16. How JOIN row multiplication affects
       conditional aggregation

   17. How to turn raw columns into business metrics
       and classifications
   ========================================================== */