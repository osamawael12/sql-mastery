/*==============================================================================
    SQL Mastery
    Practice Exercises - Beginner
    File: solutions.sql
    Database: SQLMastery
    Schema: training
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - SELECT ALL CUSTOMERS
==============================================================================*/

SELECT *
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 2 - SELECT SPECIFIC COLUMNS
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    email
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 3 - COLUMN ALIASES
==============================================================================*/

SELECT
    customer_name AS customer,
    signup_date AS joined_date
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 4 - DISTINCT CITIES
==============================================================================*/

SELECT DISTINCT
    city
FROM training.customers
ORDER BY city;
GO


/*==============================================================================
    SOLUTION 5 - ACTIVE CUSTOMERS
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE is_active = 1;
GO


/*==============================================================================
    SOLUTION 6 - PRODUCTS ABOVE A PRICE
==============================================================================*/

SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price > 100;
GO


/*==============================================================================
    SOLUTION 7 - PRODUCTS IN STOCK
==============================================================================*/

SELECT
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity > 0;
GO


/*==============================================================================
    SOLUTION 8 - MULTIPLE CONDITIONS
==============================================================================*/

SELECT
    product_id,
    product_name,
    price,
    is_active
FROM training.products
WHERE is_active = 1
  AND price >= 100;
GO


/*==============================================================================
    SOLUTION 9 - OR
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city = 'Cairo'
   OR city = 'Giza';
GO


/*==============================================================================
    SOLUTION 10 - IN
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IN ('Cairo', 'Giza');
GO


/*==============================================================================
    SOLUTION 11 - NOT
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE NOT order_status = 'Cancelled';
GO

/*
    Equivalent:

        WHERE order_status <> 'Cancelled'
*/


/*==============================================================================
    SOLUTION 12 - BETWEEN
==============================================================================*/

SELECT
    product_id,
    product_name,
    price
FROM training.products
WHERE price BETWEEN 100 AND 1000;
GO


/*==============================================================================
    SOLUTION 13 - LIKE: STARTS WITH
==============================================================================*/

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_name LIKE 'A%';
GO


/*==============================================================================
    SOLUTION 14 - LIKE: CONTAINS
==============================================================================*/

SELECT
    customer_id,
    customer_name
FROM training.customers
WHERE customer_name LIKE '%a%';
GO


/*==============================================================================
    SOLUTION 15 - NULL
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IS NULL;
GO


/*==============================================================================
    SOLUTION 16 - NOT NULL
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    city
FROM training.customers
WHERE city IS NOT NULL;
GO


/*==============================================================================
    SOLUTION 17 - ORDER BY ASC
==============================================================================*/

SELECT
    product_name,
    price
FROM training.products
ORDER BY price ASC;
GO


/*==============================================================================
    SOLUTION 18 - ORDER BY DESC
==============================================================================*/

SELECT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
GO


/*==============================================================================
    SOLUTION 19 - MULTIPLE SORT COLUMNS
==============================================================================*/

SELECT
    category,
    product_name,
    price
FROM training.products
ORDER BY
    category ASC,
    price DESC,
    product_id ASC;
GO


/*==============================================================================
    SOLUTION 20 - TOP 3 MOST EXPENSIVE PRODUCTS
==============================================================================*/

SELECT TOP (3)
    product_id,
    product_name,
    price
FROM training.products
ORDER BY
    price DESC,
    product_id ASC;
GO


/*==============================================================================
    SOLUTION 21 - CALCULATED PRODUCT PROFIT
==============================================================================*/

SELECT
    product_id,
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products;
GO


/*==============================================================================
    SOLUTION 22 - PRODUCT MARGIN PERCENTAGE
==============================================================================*/

SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit,
    100.0 * (price - cost)
        / NULLIF(price, 0) AS margin_pct
FROM training.products;
GO


/*==============================================================================
    SOLUTION 23 - ORDER ITEM LINE TOTAL
==============================================================================*/

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_total
FROM training.order_items;
GO


/*==============================================================================
    SOLUTION 24 - CASE: STOCK STATUS
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 5 THEN 'Critical'
        WHEN stock_quantity <= 10 THEN 'Low'
        ELSE 'Healthy'
    END AS stock_status
FROM training.products;
GO


/*==============================================================================
    SOLUTION 25 - CASE: ORDER STATUS GROUP
==============================================================================*/

SELECT
    order_id,
    order_status,
    CASE
        WHEN order_status = 'Completed' THEN 'Successful'
        WHEN order_status = 'Cancelled' THEN 'Unsuccessful'
        ELSE 'Open'
    END AS status_group
FROM training.orders;
GO


/*==============================================================================
    SOLUTION 26 - COALESCE
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    COALESCE(city, 'Unknown') AS display_city
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 27 - CONCAT
==============================================================================*/

SELECT
    customer_id,
    CONCAT
    (
        customer_name,
        ' - ',
        COALESCE(city, 'Unknown')
    ) AS customer_summary
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 28 - UPPER / LOWER
==============================================================================*/

SELECT
    customer_name,
    UPPER(customer_name) AS customer_name_upper,
    email,
    LOWER(email) AS email_lower
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 29 - STRING LENGTH
==============================================================================*/

SELECT
    product_name,
    LEN(product_name) AS product_name_length
FROM training.products;
GO


/*==============================================================================
    SOLUTION 30 - CAST
==============================================================================*/

SELECT
    product_name,
    price,
    CAST(price AS INT) AS price_as_int
FROM training.products;
GO


/*==============================================================================
    SOLUTION 31 - ORDER YEAR AND MONTH
==============================================================================*/

SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month
FROM training.orders;
GO


/*==============================================================================
    SOLUTION 32 - MONTH NAME
==============================================================================*/

SELECT
    order_id,
    order_date,
    DATENAME(MONTH, order_date) AS month_name
FROM training.orders;
GO


/*==============================================================================
    SOLUTION 33 - ONE WEEK AFTER ORDER
==============================================================================*/

SELECT
    order_id,
    order_date,
    DATEADD(DAY, 7, order_date) AS seven_days_later
FROM training.orders;
GO


/*==============================================================================
    SOLUTION 34 - DAYS SINCE SIGNUP
==============================================================================*/

DECLARE @ReferenceDate DATE;

SELECT
    @ReferenceDate = DATEADD(DAY, 1, MAX(signup_date))
FROM training.customers;

SELECT
    customer_id,
    customer_name,
    signup_date,
    DATEDIFF
    (
        DAY,
        signup_date,
        @ReferenceDate
    ) AS days_since_signup
FROM training.customers
ORDER BY customer_id;
GO


/*==============================================================================
    SOLUTION 35 - MONTH START
==============================================================================*/

SELECT
    order_id,
    order_date,
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month
FROM training.orders;
GO


/*==============================================================================
    SOLUTION 36 - COUNT CUSTOMERS
==============================================================================*/

SELECT
    COUNT(*) AS total_customers
FROM training.customers;
GO


/*==============================================================================
    SOLUTION 37 - COUNT ACTIVE CUSTOMERS
==============================================================================*/

SELECT
    COUNT(*) AS active_customers
FROM training.customers
WHERE is_active = 1;
GO


/*==============================================================================
    SOLUTION 38 - TOTAL INVENTORY
==============================================================================*/

SELECT
    SUM(stock_quantity) AS total_units_in_stock
FROM training.products;
GO


/*==============================================================================
    SOLUTION 39 - PRICE STATISTICS
==============================================================================*/

SELECT
    AVG(price) AS average_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM training.products;
GO


/*==============================================================================
    SOLUTION 40 - PRODUCTS PER CATEGORY
==============================================================================*/

SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
ORDER BY
    product_count DESC,
    category ASC;
GO


/*==============================================================================
    SOLUTION 41 - AVERAGE PRICE BY CATEGORY
==============================================================================*/

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY category;
GO


/*==============================================================================
    SOLUTION 42 - INVENTORY BY CATEGORY
==============================================================================*/

SELECT
    category,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category
ORDER BY
    total_stock DESC,
    category ASC;
GO


/*==============================================================================
    SOLUTION 43 - ORDER COUNT BY STATUS
==============================================================================*/

SELECT
    order_status,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY order_status
ORDER BY order_status;
GO


/*==============================================================================
    SOLUTION 44 - CUSTOMERS WITH AT LEAST 2 ORDERS
==============================================================================*/

SELECT
    customer_id,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY
    order_count DESC,
    customer_id;
GO


/*==============================================================================
    SOLUTION 45 - CATEGORIES WITH AVERAGE PRICE ABOVE 100
==============================================================================*/

SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) > 100
ORDER BY average_price DESC;
GO


/*==============================================================================
    SOLUTION 46 - BASIC CUSTOMER / ORDER JOIN
==============================================================================*/

SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    c.customer_name
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
ORDER BY o.order_id;
GO


/*==============================================================================
    SOLUTION 47 - ORDER ITEM PRODUCT JOIN
==============================================================================*/

SELECT
    oi.order_item_id,
    oi.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM training.order_items AS oi
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
ORDER BY oi.order_item_id;
GO


/*==============================================================================
    SOLUTION 48 - THREE-TABLE JOIN
==============================================================================*/

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.order_status,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
ORDER BY
    o.order_id,
    oi.order_item_id;
GO


/*==============================================================================
    SOLUTION 49 - FOUR-TABLE JOIN
==============================================================================*/

SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
ORDER BY
    o.order_id,
    oi.order_item_id;
GO


/*==============================================================================
    SOLUTION 50 - ALL CUSTOMERS AND THEIR ORDERS
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_status
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
ORDER BY
    c.customer_id,
    o.order_id;
GO


/*==============================================================================
    SOLUTION 51 - COMPLETED ORDERS
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date
FROM training.orders
WHERE order_status = 'Completed'
ORDER BY order_id;
GO


/*==============================================================================
    SOLUTION 52 - COMPLETED ORDER ITEMS
==============================================================================*/

SELECT
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
ORDER BY
    oi.order_id,
    oi.order_item_id;
GO


/*==============================================================================
    SOLUTION 53 - TOTAL COMPLETED REVENUE
==============================================================================*/

SELECT
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO


/*==============================================================================
    SOLUTION 54 - COMPLETED UNITS SOLD
==============================================================================*/

SELECT
    SUM(oi.quantity) AS units_sold
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO


/*==============================================================================
    SOLUTION 55 - COMPLETED ORDERS PER CUSTOMER
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS completed_orders
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 56 - COMPLETED REVENUE PER CUSTOMER
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    completed_revenue DESC,
    c.customer_id;
GO


/*==============================================================================
    SOLUTION 57 - COMPLETED REVENUE PER PRODUCT
==============================================================================*/

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON oi.product_id = p.product_id
INNER JOIN training.orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    completed_revenue DESC,
    p.product_id;
GO


/*==============================================================================
    SOLUTION 58 - COMPLETED REVENUE PER CATEGORY
==============================================================================*/

SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.products AS p
INNER JOIN training.order_items AS oi
    ON oi.product_id = p.product_id
INNER JOIN training.orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY
    completed_revenue DESC,
    p.category;
GO


/*==============================================================================
    SOLUTION 59 - ORDER VALUES
==============================================================================*/

SELECT
    o.order_id,
    o.order_status,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
GROUP BY
    o.order_id,
    o.order_status
ORDER BY o.order_id;
GO

/*
    Because all statuses are included, order_value is not necessarily
    realized revenue.
*/


/*==============================================================================
    SOLUTION 60 - COMPLETED ORDER VALUES
==============================================================================*/

SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date
ORDER BY
    order_value DESC,
    o.order_id;
GO


/*==============================================================================
    SOLUTION 61 - COMPLETED CUSTOMERS
==============================================================================*/

SELECT
    COUNT(DISTINCT customer_id) AS completed_customers
FROM training.orders
WHERE order_status = 'Completed';
GO


/*==============================================================================
    SOLUTION 62 - DISTINCT PRODUCTS SOLD
==============================================================================*/

SELECT
    COUNT(DISTINCT oi.product_id) AS products_with_completed_sales
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO


/*==============================================================================
    SOLUTION 63 - SIMPLE REPEAT CUSTOMER QUERY
==============================================================================*/

SELECT
    customer_id,
    COUNT(*) AS completed_orders
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY
    completed_orders DESC,
    customer_id;
GO


/*==============================================================================
    SOLUTION 64 - CURRENT INVENTORY COST VALUE
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity,
    cost,
    stock_quantity * cost AS inventory_cost_value
FROM training.products
ORDER BY product_id;
GO


/*==============================================================================
    SOLUTION 65 - CURRENT POTENTIAL RETAIL VALUE
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity,
    price,
    stock_quantity * price AS potential_retail_value
FROM training.products
ORDER BY product_id;
GO

/*
    Potential retail value is current inventory valuation at current price,
    not realized revenue.
*/


/*==============================================================================
    SOLUTION 66 - CATEGORY INVENTORY COST
==============================================================================*/

SELECT
    category,
    SUM(stock_quantity) AS total_units,
    SUM(stock_quantity * cost) AS inventory_cost_value
FROM training.products
GROUP BY category
ORDER BY category;
GO


/*==============================================================================
    SOLUTION 67 - CUSTOMERS SIGNED UP AFTER A DATE
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    signup_date
FROM training.customers
WHERE signup_date >= '20250101'
ORDER BY
    signup_date,
    customer_id;
GO


/*==============================================================================
    SOLUTION 68 - ORDERS IN A DATE RANGE
==============================================================================*/

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_date >= '20250101'
  AND order_date <  '20250201'
ORDER BY
    order_date,
    order_id;
GO


/*==============================================================================
    SOLUTION 69 - COMPLETED REVENUE IN A DATE RANGE
==============================================================================*/

SELECT
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
  AND o.order_date >= '20250101'
  AND o.order_date <  '20250201';
GO


/*==============================================================================
    SOLUTION 70 - MONTHLY ORDER COUNTS
==============================================================================*/

SELECT
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY order_month;
GO


/*==============================================================================
    SOLUTION 71 - MONTHLY COMPLETED ORDER COUNTS
==============================================================================*/

SELECT
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,
    COUNT(*) AS completed_orders
FROM training.orders
WHERE order_status = 'Completed'
GROUP BY
    DATEFROMPARTS
    (
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY order_month;
GO


/*==============================================================================
    SOLUTION 72 - MONTHLY COMPLETED REVENUE
==============================================================================*/

SELECT
    DATEFROMPARTS
    (
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS revenue_month,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY
    DATEFROMPARTS
    (
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )
ORDER BY revenue_month;
GO


/*==============================================================================
    SOLUTION 73 - CUSTOMER ORDER SUMMARY
==============================================================================*/

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS total_orders,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS latest_order_date
FROM training.customers AS c
INNER JOIN training.orders AS o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;
GO


/*==============================================================================
    SOLUTION 74 - PRODUCT PRICE POSITION
==============================================================================*/

SELECT
    product_name,
    price,
    CASE
        WHEN price < 100 THEN 'Budget'
        WHEN price <= 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_position
FROM training.products
ORDER BY
    price,
    product_id;
GO


/*==============================================================================
    SOLUTION 75 - PROFITABLE PRODUCTS
==============================================================================*/

SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products
WHERE price > cost
ORDER BY
    unit_profit DESC,
    product_id;
GO


/*==============================================================================
    SOLUTION 76 - PRODUCTS WITH ZERO OR LOW STOCK
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity <= 10
ORDER BY
    stock_quantity ASC,
    product_id ASC;
GO


/*==============================================================================
    SOLUTION 77 - CUSTOMER EMAIL DISPLAY
==============================================================================*/

SELECT
    customer_id,
    customer_name,
    email AS contact_email
FROM training.customers
ORDER BY
    customer_name,
    customer_id;
GO


/*==============================================================================
    SOLUTION 78 - SIMPLE COMPLETED SALES REPORT
==============================================================================*/

SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_revenue
FROM training.orders AS o
INNER JOIN training.customers AS c
    ON c.customer_id = o.customer_id
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN training.products AS p
    ON p.product_id = oi.product_id
WHERE o.order_status = 'Completed'
ORDER BY
    o.order_date,
    o.order_id,
    p.product_id;
GO


/*==============================================================================
    SOLUTION 79 - COMPLETED SALES SUMMARY
==============================================================================*/

SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,
    COUNT(DISTINCT o.customer_id) AS completed_customers,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS completed_revenue
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed';
GO

/*
    After joining to order_items, one order can appear multiple times.

    Therefore distinct business entities must be protected from row
    multiplication.
*/


/*==============================================================================
    SOLUTION 80 - BEGINNER FINAL CHALLENGE
==============================================================================*/

WITH ProductSales AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS completed_revenue
    FROM training.order_items AS oi
    INNER JOIN training.orders AS o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    p.stock_quantity,
    COALESCE(ps.units_sold, 0) AS units_sold,
    COALESCE(ps.completed_revenue, 0) AS completed_revenue
FROM training.products AS p
LEFT JOIN ProductSales AS ps
    ON ps.product_id = p.product_id
ORDER BY
    completed_revenue DESC,
    p.product_id ASC;
GO

/*
    Final grain:
        one row per product.

    Completed activity is aggregated before the LEFT JOIN.

    This keeps products with no Completed sales while avoiding an
    outer-join filtering mistake.
*/


/*==============================================================================
    BEGINNER REVIEW - CORE ANSWERS
==============================================================================*/

/*
    1. SELECT * vs explicit columns

       SELECT * returns every column.

       Explicit columns return only what the query requires and generally
       produce clearer and more stable query contracts.


    2. WHERE vs HAVING

       WHERE filters rows before grouping.

       HAVING filters groups after aggregation.


    3. COUNT(*) vs COUNT(column)

       COUNT(*) counts rows.

       COUNT(column) counts non-NULL values.


    4. COUNT(DISTINCT) after joins

       A one-to-many join can repeat a business entity such as an order.

       COUNT(DISTINCT order_id) can protect the entity count when that is
       the required metric.


    5. INNER JOIN vs LEFT JOIN

       INNER JOIN returns matches.

       LEFT JOIN retains every row from the left side plus available matches.


    6. WHERE after LEFT JOIN

       A right-side predicate in WHERE can remove NULL-extended unmatched rows,
       defeating the requirement to preserve all left-side rows.


    7. SUM(quantity) vs COUNT(*)

       SUM(quantity) counts units.

       COUNT(*) counts rows/order lines.


    8. Why unit_price for revenue?

       order_items.unit_price represents the transaction-time sale price.

       products.price represents the current catalog price.


    9. NULL

       Use:

           IS NULL
           IS NOT NULL

       not:

           = NULL


    10. NULLIF

        Useful for turning a zero denominator into NULL and avoiding
        divide-by-zero errors.


    11. Half-open date ranges

        Example:

            >= '20250101'
            <  '20250201'

        naturally supports date/time values without constructing a final
        second/fraction of the month.


    12. One-to-many row multiplication

        A parent row can appear multiple times after joining to several
        child rows.


    13. GROUP BY and grain

        GROUP BY collapses input rows into one output row per grouping key
        combination.


    14. TOP and ORDER BY

        TOP without meaningful ordering does not represent a stable business
        definition of "top."


    15. Result grain

        Always identify what one result row represents before aggregating.
*/


/*==============================================================================
    BEGINNER LEVEL COMPLETE

    Covered:

    - SELECT
    - Aliases
    - DISTINCT
    - Filtering
    - AND / OR / NOT
    - IN
    - BETWEEN
    - LIKE
    - NULL
    - ORDER BY
    - TOP
    - Calculated columns
    - CASE
    - COALESCE
    - String functions
    - CAST
    - Date functions
    - Aggregate functions
    - GROUP BY
    - HAVING
    - INNER JOIN
    - LEFT JOIN
    - Multi-table joins
    - Basic business revenue
    - Basic result-grain awareness

    Next:
        exercises/intermediate/exercises.sql
==============================================================================*/