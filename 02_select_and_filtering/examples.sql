/*
============================================================
SQL MASTERY
02 - SELECT AND FILTERING

File: examples.sql
Database: SQLMastery
Language: T-SQL

Topics:
- SELECT
- Column Aliases
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
- Combined Filters
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. SELECT ALL COLUMNS
   ========================================================== */

SELECT *
FROM training.customers;
GO

SELECT *
FROM training.products;
GO


/* ==========================================================
   2. SELECT SPECIFIC COLUMNS
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    email,
    city
FROM training.customers;
GO


SELECT
    product_id,
    product_name,
    category,
    price
FROM training.products;
GO


/* ==========================================================
   3. COLUMN ALIASES

   AS changes the column name in the result only.
   It does not rename the actual table column.
   ========================================================== */

SELECT
    customer_name AS customer,
    email AS customer_email,
    signup_date AS joined_date
FROM training.customers;
GO


SELECT
    product_name AS product,
    price AS selling_price,
    stock_quantity AS stock
FROM training.products;
GO


/* ==========================================================
   4. DISTINCT

   Return unique values.
   ========================================================== */

SELECT DISTINCT
    city
FROM training.customers;
GO


SELECT DISTINCT
    category
FROM training.products;
GO


/* ==========================================================
   5. DISTINCT WITH MULTIPLE COLUMNS

   Returns unique combinations.
   ========================================================== */

SELECT DISTINCT
    city,
    is_active
FROM training.customers;
GO


/* ==========================================================
   6. BASIC WHERE

   Return only rows that satisfy a condition.
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo';
GO


SELECT
    order_id,
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Completed';
GO


/* ==========================================================
   7. EQUAL =
   ========================================================== */

SELECT
    product_name,
    category,
    price
FROM training.products
WHERE category = N'Electronics';
GO


/* ==========================================================
   8. NOT EQUAL <>
   ========================================================== */

SELECT
    product_name,
    category
FROM training.products
WHERE category <> N'Electronics';
GO


SELECT
    order_id,
    order_status
FROM training.orders
WHERE order_status <> 'Completed';
GO


/* ==========================================================
   9. GREATER THAN >
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
WHERE price > 1000;
GO


/* ==========================================================
   10. GREATER THAN OR EQUAL >=
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
WHERE price >= 7000;
GO


/* ==========================================================
   11. LESS THAN <
   ========================================================== */

SELECT
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity < 50;
GO


/* ==========================================================
   12. LESS THAN OR EQUAL <=
   ========================================================== */

SELECT
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity <= 25;
GO


/* ==========================================================
   13. AND

   Every condition must be TRUE.
   ========================================================== */

SELECT
    product_name,
    category,
    price
FROM training.products
WHERE category = N'Accessories'
  AND price >= 1000;
GO


SELECT
    product_name,
    price,
    stock_quantity
FROM training.products
WHERE price >= 1000
  AND stock_quantity > 20;
GO


/* ==========================================================
   14. OR

   At least one condition must be TRUE.
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo'
   OR city = N'Giza';
GO


/* ==========================================================
   15. AND + OR

   Use parentheses to make the intended logic clear.
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


/* ==========================================================
   16. WHY PARENTHESES MATTER

   AND has higher precedence than OR.
   ========================================================== */

-- Without parentheses:

SELECT
    customer_name,
    city,
    is_active
FROM training.customers
WHERE city = N'Cairo'
   OR city = N'Giza'
  AND is_active = 1;
GO


-- Explicit intended logic:

SELECT
    customer_name,
    city,
    is_active
FROM training.customers
WHERE
    (city = N'Cairo' OR city = N'Giza')
    AND is_active = 1;
GO


/* ==========================================================
   17. NOT
   ========================================================== */

SELECT
    product_name,
    category
FROM training.products
WHERE NOT category = N'Electronics';
GO


-- Often easier to read:

SELECT
    product_name,
    category
FROM training.products
WHERE category <> N'Electronics';
GO


/* ==========================================================
   18. IN

   Cleaner than repeating OR for the same column.
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
   19. NOT IN
   ========================================================== */

SELECT
    order_id,
    order_status
FROM training.orders
WHERE order_status NOT IN
(
    'Cancelled',
    'Pending'
);
GO


/* ==========================================================
   IMPORTANT: NULL AND NOT IN

   NULL represents UNKNOWN.

   A customer whose city is NULL will not automatically
   appear in this result.

   We will handle NULL explicitly below.
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


/* ==========================================================
   20. BETWEEN - NUMBERS

   BETWEEN is inclusive.

   price BETWEEN 1000 AND 7000

   means:

   price >= 1000
   AND
   price <= 7000
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
WHERE price BETWEEN 1000 AND 7000;
GO


/* ==========================================================
   21. BETWEEN - DATES
   ========================================================== */

SELECT
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date BETWEEN '2025-01-01' AND '2025-02-01';
GO


/* ==========================================================
   22. DATE RANGES WITH DATETIME2

   order_date contains both date and time.

   A half-open range is usually safer:

   >= start
   <  next period
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
   23. LIKE - STARTS WITH
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'A%';
GO


/* ==========================================================
   24. LIKE - ENDS WITH
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'%Ali';
GO


/* ==========================================================
   25. LIKE - CONTAINS
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'%med%';
GO


/* ==========================================================
   26. LIKE - EXACTLY ONE CHARACTER

   _ represents exactly one character.
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'_mar%';
GO


/* ==========================================================
   27. LIKE - BRACKET PATTERN

   SQL Server supports [] patterns.

   Find names starting with:
   A, M, or S
   ========================================================== */

SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'[AMS]%';
GO


/* ==========================================================
   28. NULL

   This is WRONG:

   WHERE city = NULL

   NULL must be handled with IS NULL / IS NOT NULL.
   ========================================================== */


/* ==========================================================
   29. IS NULL

   Find customers with no city.
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IS NULL;
GO


/* ==========================================================
   30. IS NOT NULL
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IS NOT NULL;
GO


/* ==========================================================
   31. COMBINING NULL WITH OTHER CONDITIONS

   Customers outside Cairo and Giza,
   including customers whose city is unknown.
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
WHERE city NOT IN
(
    N'Cairo',
    N'Giza'
)
OR city IS NULL;
GO


/* ==========================================================
   32. ORDER BY - ASCENDING

   ASC is the default.
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
ORDER BY price ASC;
GO


/* ==========================================================
   33. ORDER BY - DESCENDING
   ========================================================== */

SELECT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   34. SORT TEXT
   ========================================================== */

SELECT
    customer_name,
    city
FROM training.customers
ORDER BY customer_name ASC;
GO


/* ==========================================================
   35. SORT DATES
   ========================================================== */

SELECT
    order_id,
    order_date,
    order_status
FROM training.orders
ORDER BY order_date DESC;
GO


/* ==========================================================
   36. ORDER BY MULTIPLE COLUMNS

   First:
       category ASC

   Then within each category:
       price DESC
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
   37. TOP

   Return a limited number of rows.
   ========================================================== */

SELECT TOP (3)
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   38. TOP - CHEAPEST PRODUCTS
   ========================================================== */

SELECT TOP (2)
    product_name,
    price
FROM training.products
ORDER BY price ASC;
GO


/* ==========================================================
   39. TOP WITH FILTERING

   Get the most expensive Accessories products.
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
   40. TOP PERCENT
   ========================================================== */

SELECT TOP (40) PERCENT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   41. FILTER USING BIT

   BIT commonly contains:
   1 = True
   0 = False
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    is_active
FROM training.customers
WHERE is_active = 1;
GO


/* ==========================================================
   42. FILTER BY DATE
   ========================================================== */

SELECT
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date >= '2025-02-01';
GO


/* ==========================================================
   43. FILTER A DATE PERIOD

   Customers who joined during February 2025.
   ========================================================== */

SELECT
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date >= '2025-02-01'
  AND signup_date <  '2025-03-01';
GO


/* ==========================================================
   44. COMBINED FILTER

   Business Question:

   Which products:
   - Are Accessories
   - Cost at least 500
   - Cost no more than 2000
   - Have stock available
   ========================================================== */

SELECT
    product_id,
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
   45. BUSINESS QUESTION

   Find completed orders during March 2025.
   Show newest orders first.
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
   46. BUSINESS QUESTION

   Find customers who:
   - Live in Cairo or Giza
   - Are active
   - Joined on or after 2025-02-01
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city,
    signup_date,
    is_active
FROM training.customers
WHERE city IN
(
    N'Cairo',
    N'Giza'
)
AND is_active = 1
AND signup_date >= '2025-02-01'
ORDER BY signup_date DESC;
GO


/* ==========================================================
   47. BUSINESS QUESTION

   Find the 3 most expensive products currently in stock.
   ========================================================== */

SELECT TOP (3)
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE stock_quantity > 0
ORDER BY price DESC;
GO


/* ==========================================================
   48. BUSINESS QUESTION

   Find customers whose city:
   - Is not Cairo
   - Or is unknown
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city <> N'Cairo'
   OR city IS NULL
ORDER BY customer_name;
GO


/* ==========================================================
   49. QUERY WRITING ORDER

   SQL is written approximately as:

   SELECT
   FROM
   WHERE
   ORDER BY

   TOP appears inside SELECT.
   ========================================================== */

SELECT TOP (3)
    product_name,
    price
FROM training.products
WHERE price >= 1000
ORDER BY price DESC;
GO


/* ==========================================================
   50. LOGICAL PROCESSING

   For the concepts learned so far, think approximately:

   1. FROM
   2. WHERE
   3. SELECT
   4. DISTINCT
   5. ORDER BY
   6. TOP

   This mental model becomes more important
   in later chapters.
   ========================================================== */


/* ==========================================================
   FINAL PRACTICE QUERY

   Business Question:

   Show the 3 most expensive active products that:
   - Are Electronics or Accessories
   - Cost at least 1000
   - Have stock available

   Sort from highest price to lowest.
   ========================================================== */

SELECT TOP (3)
    product_id,
    product_name,
    category,
    price,
    stock_quantity
FROM training.products
WHERE is_active = 1
  AND category IN
  (
      N'Electronics',
      N'Accessories'
  )
  AND price >= 1000
  AND stock_quantity > 0
ORDER BY price DESC;
GO