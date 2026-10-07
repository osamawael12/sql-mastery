/*
============================================================
SQL MASTERY
02 - SELECT AND FILTERING

File: solutions.sql
Database: SQLMastery
Language: T-SQL

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
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    email
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 2 - COLUMN ALIASES
   ========================================================== */

SELECT
    customer_name AS customer,
    email AS customer_email,
    signup_date AS joined_date
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 3 - DISTINCT
   ========================================================== */

SELECT DISTINCT
    city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 4 - DISTINCT CATEGORIES
   ========================================================== */

SELECT DISTINCT
    category
FROM training.products;
GO


/* ==========================================================
   EXERCISE 5 - BASIC WHERE
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo';
GO


/* ==========================================================
   EXERCISE 6 - NUMERIC FILTER
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
WHERE price > 5000;
GO


/* ==========================================================
   EXERCISE 7 - LESS THAN OR EQUAL
   ========================================================== */

SELECT
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity <= 25;
GO


/* ==========================================================
   EXERCISE 8 - NOT EQUAL
   ========================================================== */

SELECT
    order_id,
    order_status
FROM training.orders
WHERE order_status <> 'Completed';
GO


/* ==========================================================
   EXERCISE 9 - AND
   ========================================================== */

SELECT
    product_name,
    category,
    price
FROM training.products
WHERE category = N'Accessories'
  AND price >= 1000;
GO


/* ==========================================================
   EXERCISE 10 - OR
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo'
   OR city = N'Giza';
GO


/* ==========================================================
   EXERCISE 11 - IN
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city IN
(
    N'Cairo',
    N'Giza',
    N'Alexandria'
);
GO


/* ==========================================================
   EXERCISE 12 - ORDER STATUS WITH IN
   ========================================================== */

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE order_status IN
(
    'Completed',
    'Pending'
);
GO


/* ==========================================================
   EXERCISE 13 - NOT IN
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city NOT IN
(
    N'Cairo',
    N'Giza'
);
GO

/*
Important:

A row where city IS NULL will not be returned.

NULL represents an unknown value, so:

NULL NOT IN (...)

does not evaluate to TRUE.
*/


/* ==========================================================
   EXERCISE 14 - BETWEEN
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
WHERE price BETWEEN 1000 AND 10000;
GO


/* ==========================================================
   EXERCISE 15 - DATE FILTER
   ========================================================== */

SELECT
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date >= '2025-02-01';
GO


/* ==========================================================
   EXERCISE 16 - DATE RANGE
   ========================================================== */

SELECT
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date >= '2025-02-01'
  AND signup_date <  '2025-03-01';
GO


/* ==========================================================
   EXERCISE 17 - DATETIME RANGE
   ========================================================== */

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
WHERE order_date >= '2025-03-01'
  AND order_date <  '2025-04-01';
GO


/* ==========================================================
   EXERCISE 18 - LIKE STARTS WITH
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'A%';
GO


/* ==========================================================
   EXERCISE 19 - LIKE ENDS WITH
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'%Hassan';
GO


/* ==========================================================
   EXERCISE 20 - LIKE CONTAINS
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'%Mohamed%';
GO


/* ==========================================================
   EXERCISE 21 - NULL
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IS NULL;
GO


/* ==========================================================
   EXERCISE 22 - IS NOT NULL
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city IS NOT NULL;
GO


/* ==========================================================
   EXERCISE 23 - NULL + FILTERING
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city <> N'Cairo'
   OR city IS NULL;
GO


/* ==========================================================
   EXERCISE 24 - ORDER BY
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
ORDER BY price ASC;
GO


/* ==========================================================
   EXERCISE 25 - DESCENDING ORDER
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 26 - MULTIPLE SORTING
   ========================================================== */

SELECT
    category,
    product_name,
    price
FROM training.products
ORDER BY
    category ASC,
    price DESC;
GO


/* ==========================================================
   EXERCISE 27 - TOP
   ========================================================== */

SELECT TOP (3)
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 28 - TOP CHEAPEST
   ========================================================== */

SELECT TOP (2)
    product_name,
    price
FROM training.products
ORDER BY price ASC;
GO


/* ==========================================================
   EXERCISE 29 - TOP + WHERE
   ========================================================== */

SELECT TOP (2)
    product_name,
    category,
    price
FROM training.products
WHERE category = N'Accessories'
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 30 - BOOLEAN / BIT FILTER
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    is_active
FROM training.customers
WHERE is_active = 1;
GO


/* ==========================================================
   EXERCISE 31 - MULTIPLE CONDITIONS
   ========================================================== */

SELECT
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE category = N'Accessories'
  AND price >= 500
  AND price <= 2000
  AND stock_quantity > 0
ORDER BY price DESC;
GO


/*
Alternative using BETWEEN:
*/

SELECT
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE category = N'Accessories'
  AND price BETWEEN 500 AND 2000
  AND stock_quantity > 0
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 32 - AND + OR + PARENTHESES
   ========================================================== */

SELECT
    customer_name,
    city,
    is_active
FROM training.customers
WHERE
    (city = N'Cairo' OR city = N'Giza')
    AND is_active = 1;
GO


/*
The same condition could be written more compactly
using IN:
*/

SELECT
    customer_name,
    city,
    is_active
FROM training.customers
WHERE city IN (N'Cairo', N'Giza')
  AND is_active = 1;
GO


/* ==========================================================
   EXERCISE 33 - BUSINESS QUESTION
   ========================================================== */

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_status = 'Completed'
  AND order_date >= '2025-03-01'
  AND order_date <  '2025-04-01'
ORDER BY order_date DESC;
GO


/* ==========================================================
   EXERCISE 34 - BUSINESS QUESTION
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE is_active = 1
  AND stock_quantity > 0
  AND price >= 1000
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 35 - BUSINESS QUESTION
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city,
    signup_date
FROM training.customers
WHERE city IN
(
    N'Cairo',
    N'Giza',
    N'Alexandria'
)
AND is_active = 1
AND signup_date >= '2025-02-01'
ORDER BY signup_date DESC;
GO


/* ==========================================================
   EXERCISE 36 - BUSINESS QUESTION
   ========================================================== */

SELECT TOP (3)
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE is_active = 1
  AND stock_quantity > 0
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 37 - THINK ABOUT NULL
   ========================================================== */

/*
Answer:

No.

Explanation:

A customer whose city is NULL will NOT be returned by:

    WHERE city <> N'Cairo'

SQL does not treat NULL as a normal value.

The comparison:

    NULL <> N'Cairo'

evaluates to UNKNOWN rather than TRUE.

WHERE keeps only rows for which the condition evaluates
to TRUE.

To explicitly include NULL:

    WHERE city <> N'Cairo'
       OR city IS NULL
*/


/* ==========================================================
   EXERCISE 38 - THINK ABOUT BETWEEN
   ========================================================== */

/*
Answer:

1. Yes.

2. Yes.

3. BETWEEN is inclusive.

Therefore:

    price BETWEEN 1000 AND 7000

is equivalent to:

    price >= 1000
    AND
    price <= 7000
*/


/* ==========================================================
   EXERCISE 39 - THINK ABOUT TOP
   ========================================================== */

/*
Answer:

ORDER BY is missing.

This:

    SELECT TOP (3)
        product_name,
        price
    FROM training.products;

only asks SQL Server for 3 qualifying rows.

It does NOT mean the 3 most expensive products.

For the 3 most expensive products:

    SELECT TOP (3)
        product_name,
        price
    FROM training.products
    ORDER BY price DESC;
*/


/* ==========================================================
   EXERCISE 40 - THINK ABOUT LOGIC
   ========================================================== */

/*
Answer:

1. No.

2. AND has higher precedence than OR.

3. Query B correctly expresses the business requirement:

       WHERE
           (city = N'Cairo' OR city = N'Giza')
           AND is_active = 1

Query A is logically interpreted approximately as:

       city = N'Cairo'
       OR
       (
           city = N'Giza'
           AND is_active = 1
       )

This means an inactive Cairo customer could still qualify.

Parentheses make the intended business logic explicit.
*/


/* ==========================================================
   CHALLENGE 1
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE category IN
(
    N'Electronics',
    N'Accessories'
)
AND price BETWEEN 1000 AND 10000
AND stock_quantity > 0
AND is_active = 1
ORDER BY
    price DESC,
    product_name ASC;
GO


/* ==========================================================
   CHALLENGE 2
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city,
    signup_date
FROM training.customers
WHERE is_active = 1
  AND signup_date >= '2025-01-01'
  AND signup_date <  '2025-03-01'
  AND city IS NOT NULL
  AND city <> N'Giza'
ORDER BY signup_date DESC;
GO


/* ==========================================================
   CHALLENGE 3
   ========================================================== */

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_status <> 'Cancelled'
  AND order_date >= '2025-03-01'
  AND order_date <  '2025-04-01'
ORDER BY order_date DESC;
GO


/* ==========================================================
   CHALLENGE 4
   ========================================================== */

SELECT
    customer_name,
    email,
    city
FROM training.customers
WHERE customer_name LIKE N'A%'
   OR customer_name LIKE N'S%'
ORDER BY customer_name ASC;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL BUSINESS CHALLENGE
   ========================================================== */

SELECT TOP (3)
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE is_active = 1
  AND stock_quantity > 0
  AND category IN
  (
      N'Electronics',
      N'Accessories'
  )
  AND price BETWEEN 500 AND 10000
ORDER BY price DESC;
GO


/* ==========================================================
   FINAL RECAP
   ==========================================================

   SELECT
       Choose the columns to return.

   FROM
       Choose the source table.

   WHERE
       Filter rows.

   DISTINCT
       Remove duplicate result combinations.

   AND
       All conditions must be TRUE.

   OR
       At least one condition must be TRUE.

   IN
       Match against a list of values.

   BETWEEN
       Inclusive range.

   LIKE
       Pattern matching.

   IS NULL
       Find missing / unknown values.

   ORDER BY
       Control result ordering.

   TOP
       Limit the number of returned rows.


   Approximate logical processing learned so far:

       FROM
       WHERE
       SELECT
       DISTINCT
       ORDER BY
       TOP


   IMPORTANT:

   SQL is not only about writing valid syntax.

   The goal is to correctly translate a business
   requirement into filtering logic.
   ========================================================== */