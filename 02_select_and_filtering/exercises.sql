/*
============================================================
SQL MASTERY
02 - SELECT AND FILTERING

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Solve every exercise yourself before checking solutions.sql.

Topics:
- SELECT
- Aliases
- DISTINCT
- WHERE
- Comparison Operators
- AND / OR / NOT
- IN / NOT IN
- BETWEEN
- LIKE
- NULL
- ORDER BY
- TOP
- Date Filtering
- Business Filtering
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - SELECT COLUMNS
   ==========================================================

   Return these columns from training.customers:

   customer_id
   customer_name
   email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - COLUMN ALIASES
   ==========================================================

   Return:

   customer_name as customer
   email as customer_email
   signup_date as joined_date
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - DISTINCT
   ==========================================================

   Return all unique cities from training.customers.

   Do not return duplicate cities.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - DISTINCT CATEGORIES
   ==========================================================

   Return all unique product categories.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - BASIC WHERE
   ==========================================================

   Return:

   customer_id
   customer_name
   city

   Only customers who live in Cairo.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - NUMERIC FILTER
   ==========================================================

   Return:

   product_name
   price

   Only products with a price greater than 5000.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - LESS THAN OR EQUAL
   ==========================================================

   Return:

   product_name
   stock_quantity

   Only products where stock_quantity is less than
   or equal to 25.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - NOT EQUAL
   ==========================================================

   Return:

   order_id
   order_status

   Return orders that are NOT Completed.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - AND
   ==========================================================

   Return:

   product_name
   category
   price

   Conditions:

   category = Accessories
   AND
   price >= 1000
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - OR
   ==========================================================

   Return:

   customer_name
   city

   Customers who live in:

   Cairo
   OR
   Giza
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - IN
   ==========================================================

   Rewrite the previous idea using IN.

   Return customers whose city is:

   Cairo
   Giza
   Alexandria

   Return:

   customer_name
   city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - ORDER STATUS WITH IN
   ==========================================================

   Return:

   order_id
   order_date
   order_status

   Only orders whose status is:

   Completed
   Pending
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - NOT IN
   ==========================================================

   Return:

   customer_name
   city

   Exclude customers whose city is:

   Cairo
   Giza

   IMPORTANT:
   For this exercise, do not handle NULL yet.

   Observe what happens to customers whose city is NULL.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - BETWEEN
   ==========================================================

   Return:

   product_name
   price

   Products with a price between:

   1000 and 10000

   Both boundaries should be included.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - DATE FILTER
   ==========================================================

   Return:

   customer_name
   signup_date

   Customers who signed up on or after:

   2025-02-01
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - DATE RANGE
   ==========================================================

   Return:

   customer_name
   signup_date

   Customers who joined during February 2025.

   Use this pattern:

   >= start date
   < next month
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - DATETIME RANGE
   ==========================================================

   Return:

   order_id
   order_date
   order_status

   Orders placed during March 2025.

   Remember:
   order_date is DATETIME2.

   Use a half-open date range.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - LIKE STARTS WITH
   ==========================================================

   Return:

   customer_name

   Find customers whose name starts with:

   A
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - LIKE ENDS WITH
   ==========================================================

   Return:

   customer_name

   Find customers whose name ends with:

   Hassan
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - LIKE CONTAINS
   ==========================================================

   Return:

   customer_name

   Find customer names containing:

   Mohamed
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - NULL
   ==========================================================

   Return:

   customer_id
   customer_name
   city

   Find customers whose city is unknown.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - IS NOT NULL
   ==========================================================

   Return:

   customer_name
   city

   Return only customers who have a city.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - NULL + FILTERING
   ==========================================================

   Return:

   customer_name
   city

   Find customers whose city:

   - Is NOT Cairo
   OR
   - Is NULL

   Make sure the customer with an unknown city
   is included.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - ORDER BY
   ==========================================================

   Return:

   product_name
   price

   Sort products from cheapest to most expensive.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - DESCENDING ORDER
   ==========================================================

   Return:

   product_name
   price

   Sort products from most expensive to cheapest.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - MULTIPLE SORTING
   ==========================================================

   Return:

   category
   product_name
   price

   Sort:

   category alphabetically

   Then:

   price from highest to lowest
   inside each category.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - TOP
   ==========================================================

   Return the 3 most expensive products.

   Columns:

   product_name
   price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - TOP CHEAPEST
   ==========================================================

   Return the 2 cheapest products.

   Columns:

   product_name
   price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - TOP + WHERE
   ==========================================================

   Find the 2 most expensive products from:

   Accessories

   Return:

   product_name
   category
   price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - BOOLEAN / BIT FILTER
   ==========================================================

   Return:

   customer_id
   customer_name
   is_active

   Only active customers.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - MULTIPLE CONDITIONS
   ==========================================================

   Return products that:

   - Are Accessories
   - Have price >= 500
   - Have price <= 2000
   - Have stock available

   Return:

   product_name
   category
   price
   stock_quantity

   Sort by price from highest to lowest.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - AND + OR + PARENTHESES
   ==========================================================

   Return:

   customer_name
   city
   is_active

   Conditions:

   Customer must be active

   AND

   city must be either:
   Cairo
   OR
   Giza

   Use parentheses explicitly.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - BUSINESS QUESTION
   ==========================================================

   The sales team wants all completed orders
   placed during March 2025.

   Return:

   order_id
   customer_id
   order_date
   order_status

   Requirements:

   - Completed only
   - March 2025 only
   - Newest order first
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - BUSINESS QUESTION
   ==========================================================

   The inventory team wants products that:

   - Are active
   - Have stock available
   - Cost at least 1000

   Return:

   product_id
   product_name
   category
   price
   stock_quantity

   Sort from highest price to lowest.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - BUSINESS QUESTION
   ==========================================================

   Marketing wants customers who:

   - Live in Cairo, Giza, or Alexandria
   - Are active
   - Joined on or after 2025-02-01

   Return:

   customer_id
   customer_name
   city
   signup_date

   Sort newest signup first.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - BUSINESS QUESTION
   ==========================================================

   Management wants the 3 most expensive active
   products currently in stock.

   Return:

   product_id
   product_name
   category
   price
   stock_quantity

   Requirements:

   - Active products only
   - stock_quantity > 0
   - Highest price first
   - Maximum 3 rows
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - THINK ABOUT NULL

   Consider this condition:

   WHERE city <> N'Cairo'

   Question:

   Will a customer whose city is NULL be returned?

   Write your answer and explanation below.
   ========================================================== */

/*
Answer:



Explanation:



*/


/* ==========================================================
   EXERCISE 38 - THINK ABOUT BETWEEN

   Consider:

   WHERE price BETWEEN 1000 AND 7000

   Questions:

   1. Is a product priced exactly 1000 included?
   2. Is a product priced exactly 7000 included?
   3. Is BETWEEN inclusive or exclusive?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 39 - THINK ABOUT TOP
   ==========================================================

   Why can this query be dangerous if the business
   wants the 3 most expensive products?

       SELECT TOP (3)
           product_name,
           price
       FROM training.products;

   What is missing?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 40 - THINK ABOUT LOGIC
   ==========================================================

   Business requirement:

   Return active customers who live in Cairo or Giza.

   Compare:

   Query A:

       WHERE city = N'Cairo'
          OR city = N'Giza'
         AND is_active = 1

   Query B:

       WHERE
           (city = N'Cairo' OR city = N'Giza')
           AND is_active = 1

   Questions:

   1. Are these conditions logically identical?
   2. Which operator has higher precedence: AND or OR?
   3. Which query correctly expresses the requirement?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   CHALLENGE 1
   ==========================================================

   Find products that satisfy ALL these rules:

   - Category is Electronics OR Accessories
   - Price is between 1000 and 10000
   - Stock quantity is greater than 0
   - Product is active

   Return:

   product_id
   product_name
   category
   price
   stock_quantity

   Sort by:

   price DESC
   product_name ASC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2
   ==========================================================

   Customer targeting.

   Find customers who:

   - Are active
   - Joined between 2025-01-01 and 2025-02-28
   - Have a known city
   - City is NOT Giza

   IMPORTANT:

   Write the date condition using:

   >= '2025-01-01'
   <  '2025-03-01'

   Return:

   customer_id
   customer_name
   city
   signup_date

   Sort newest signup first.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3
   ==========================================================

   Find orders that:

   - Were NOT Cancelled
   - Were placed during March 2025

   Return:

   order_id
   customer_id
   order_date
   order_status

   Sort:

   order_date DESC
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4
   ==========================================================

   Find customers whose names:

   - Start with A
   OR
   - Start with S

   Return:

   customer_name
   email
   city

   Sort alphabetically by customer_name.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL BUSINESS CHALLENGE
   ==========================================================

   You are asked to prepare a product shortlist.

   Requirements:

   - Product must be active
   - Product must be in stock
   - Category must be Electronics or Accessories
   - Price must be between 500 and 10000 inclusive
   - Return at most 3 products
   - Highest price first

   Return:

   product_id
   product_name
   category
   price
   stock_quantity

   Try to write the complete query without looking
   at previous examples.
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before opening solutions.sql:

   Make sure you can explain:

   - Why NULL cannot be compared using =
   - Difference between AND and OR
   - Why parentheses matter
   - Difference between IN and multiple OR conditions
   - Whether BETWEEN includes its boundaries
   - Why DATETIME2 ranges often use >= and <
   - Why TOP usually needs ORDER BY
   - How to translate a business question into filters
   ========================================================== */