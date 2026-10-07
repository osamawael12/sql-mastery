/*
============================================================
SQL MASTERY
05 - DATA TRANSFORMATION

File: examples.sql
Database: SQLMastery
Language: T-SQL

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
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. CALCULATED COLUMN - UNIT PROFIT
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products;
GO


/* ==========================================================
   2. CALCULATED COLUMN - ORDER LINE VALUE
   ========================================================== */

SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_value
FROM training.order_items;
GO


/* ==========================================================
   3. BASIC CASE

   Split products into two groups.
   ========================================================== */

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Expensive'
        ELSE 'Affordable'
    END AS price_group
FROM training.products;
GO


/* ==========================================================
   4. CASE WITH MULTIPLE CONDITIONS

   Conditions are checked from top to bottom.
   ========================================================== */

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'High'
        WHEN price >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS price_level
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   5. CASE ORDER MATTERS

   This example intentionally demonstrates
   problematic condition ordering.

   A price >= 10000 also satisfies price >= 1000.

   Therefore the first condition wins.
   ========================================================== */

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 1000 THEN 'Medium'
        WHEN price >= 10000 THEN 'High'
        ELSE 'Low'
    END AS incorrect_price_level
FROM training.products;
GO


/*
Correct ordering:
*/

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'High'
        WHEN price >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS correct_price_level
FROM training.products;
GO


/* ==========================================================
   6. CASE WITH ORDER STATUS
   ========================================================== */

SELECT
    order_id,
    order_status,
    CASE
        WHEN order_status = 'Completed' THEN 'Successful'
        WHEN order_status = 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group
FROM training.orders;
GO


/* ==========================================================
   7. SIMPLE CASE
   ========================================================== */

SELECT
    order_id,
    order_status,
    CASE order_status
        WHEN 'Completed' THEN 'Successful'
        WHEN 'Cancelled' THEN 'Failed'
        WHEN 'Pending' THEN 'In Progress'
        ELSE 'Unknown'
    END AS status_group
FROM training.orders;
GO


/* ==========================================================
   8. CASE WITH NULL
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    city,
    CASE
        WHEN city IS NULL THEN N'Unknown'
        ELSE city
    END AS display_city
FROM training.customers;
GO


/* ==========================================================
   9. COALESCE

   Replace NULL city for display purposes.
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    COALESCE(city, N'Unknown') AS display_city
FROM training.customers;
GO


/* ==========================================================
   10. ISNULL

   SQL Server-specific NULL replacement.
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    ISNULL(city, N'Unknown') AS display_city
FROM training.customers;
GO


/* ==========================================================
   11. COALESCE vs ISNULL

   Both produce similar output in this simple case.
   ========================================================== */

SELECT
    customer_name,
    city,
    COALESCE(city, N'Unknown') AS city_coalesce,
    ISNULL(city, N'Unknown') AS city_isnull
FROM training.customers;
GO


/* ==========================================================
   12. CAST

   Convert DECIMAL price to INT.

   Be aware:
   fractional precision is lost.
   ========================================================== */

SELECT
    product_name,
    price,
    CAST(price AS INT) AS price_as_integer
FROM training.products;
GO


/* ==========================================================
   13. CAST DATE/TIME TO DATE
   ========================================================== */

SELECT
    order_id,
    order_date,
    CAST(order_date AS DATE) AS order_day
FROM training.orders;
GO


/* ==========================================================
   14. CONVERT
   ========================================================== */

SELECT
    order_id,
    order_date,
    CONVERT(DATE, order_date) AS order_day
FROM training.orders;
GO


/* ==========================================================
   15. CONVERT DATE TO TEXT

   Style 23:
   yyyy-mm-dd
   ========================================================== */

SELECT
    order_id,
    order_date,
    CONVERT(VARCHAR(10), order_date, 23) AS order_date_text
FROM training.orders;
GO


/* ==========================================================
   16. TRY_CAST

   Failed conversion returns NULL.
   ========================================================== */

SELECT
    TRY_CAST('123' AS INT) AS valid_number,
    TRY_CAST('ABC' AS INT) AS invalid_number;
GO


/* ==========================================================
   17. TRY_CONVERT
   ========================================================== */

SELECT
    TRY_CONVERT(INT, '500') AS valid_number,
    TRY_CONVERT(INT, 'SQL') AS invalid_number;
GO


/* ==========================================================
   18. STRING CONCATENATION WITH +
   ========================================================== */

SELECT
    customer_name,
    email,
    customer_name + ' - ' + email AS customer_details
FROM training.customers;
GO


/* ==========================================================
   19. NULL WITH STRING +

   city can be NULL.

   If city is NULL, the expression may become NULL
   under the usual SQL Server setting.
   ========================================================== */

SELECT
    customer_name,
    city,
    customer_name + N' - ' + city AS customer_location
FROM training.customers;
GO


/* ==========================================================
   20. CONCAT

   CONCAT treats NULL arguments as empty strings.
   ========================================================== */

SELECT
    customer_name,
    city,
    CONCAT(customer_name, N' - ', city) AS customer_location
FROM training.customers;
GO


/* ==========================================================
   21. CONCAT + COALESCE

   More explicit report output.
   ========================================================== */

SELECT
    CONCAT(
        customer_name,
        N' - ',
        COALESCE(city, N'Unknown')
    ) AS customer_location
FROM training.customers;
GO


/* ==========================================================
   22. LEN
   ========================================================== */

SELECT
    customer_name,
    LEN(customer_name) AS name_length
FROM training.customers;
GO


/* ==========================================================
   23. UPPER AND LOWER
   ========================================================== */

SELECT
    customer_name,
    UPPER(customer_name) AS uppercase_name,
    LOWER(customer_name) AS lowercase_name
FROM training.customers;
GO


SELECT
    email,
    UPPER(email) AS uppercase_email,
    LOWER(email) AS lowercase_email
FROM training.customers;
GO


/* ==========================================================
   24. TRIM
   ========================================================== */

SELECT
    customer_name,
    TRIM(customer_name) AS clean_name
FROM training.customers;
GO


/* ==========================================================
   25. LTRIM + RTRIM
   ========================================================== */

SELECT
    customer_name,
    LTRIM(RTRIM(customer_name)) AS clean_name
FROM training.customers;
GO


/* ==========================================================
   26. LEFT
   ========================================================== */

SELECT
    customer_name,
    LEFT(customer_name, 3) AS first_three_characters
FROM training.customers;
GO


/* ==========================================================
   27. RIGHT
   ========================================================== */

SELECT
    email,
    RIGHT(email, 4) AS last_four_characters
FROM training.customers;
GO


/* ==========================================================
   28. SUBSTRING

   SQL Server positions begin at 1.
   ========================================================== */

SELECT
    customer_name,
    SUBSTRING(customer_name, 1, 5) AS short_name
FROM training.customers;
GO


/* ==========================================================
   29. REPLACE
   ========================================================== */

SELECT
    email,
    REPLACE(email, '@', ' [at] ') AS display_email
FROM training.customers;
GO


/* ==========================================================
   30. YEAR / MONTH / DAY
   ========================================================== */

SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    DAY(order_date) AS order_day
FROM training.orders;
GO


/* ==========================================================
   31. DATEPART
   ========================================================== */

SELECT
    order_id,
    order_date,
    DATEPART(YEAR, order_date) AS order_year,
    DATEPART(MONTH, order_date) AS order_month,
    DATEPART(DAY, order_date) AS order_day
FROM training.orders;
GO


/* ==========================================================
   32. DATENAME

   Month name depends on session language.
   ========================================================== */

SELECT
    order_id,
    order_date,
    DATENAME(MONTH, order_date) AS month_name
FROM training.orders;
GO


/* ==========================================================
   33. DATEADD

   Add 30 days to signup_date.
   ========================================================== */

SELECT
    customer_name,
    signup_date,
    DATEADD(DAY, 30, signup_date) AS date_after_30_days
FROM training.customers;
GO


/* ==========================================================
   34. DATEADD - SUBTRACT DAYS
   ========================================================== */

SELECT
    customer_name,
    signup_date,
    DATEADD(DAY, -7, signup_date) AS seven_days_before
FROM training.customers;
GO


/* ==========================================================
   35. DATEDIFF

   Number of day boundaries between signup_date
   and today.
   ========================================================== */

SELECT
    customer_name,
    signup_date,
    DATEDIFF(
        DAY,
        signup_date,
        CAST(GETDATE() AS DATE)
    ) AS days_since_signup
FROM training.customers;
GO


/* ==========================================================
   36. EOMONTH
   ========================================================== */

SELECT
    order_id,
    order_date,
    EOMONTH(order_date) AS month_end
FROM training.orders;
GO


/* ==========================================================
   37. MONTH BUCKET

   Convert every order date to the first day
   of its month.
   ========================================================== */

SELECT
    order_id,
    order_date,
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month
FROM training.orders;
GO


/* ==========================================================
   38. ORDERS BY MONTH
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,
    COUNT(*) AS order_count
FROM training.orders
GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )
ORDER BY order_month;
GO


/* ==========================================================
   39. PRODUCT PRICE SEGMENT
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment
FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   40. GROUP BY CASE

   Count products by price segment.
   ========================================================== */

SELECT
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment,

    COUNT(*) AS product_count

FROM training.products

GROUP BY
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END;
GO


/* ==========================================================
   41. CUSTOMER SEGMENT
   ========================================================== */

SELECT
    customer_id,
    customer_name,
    signup_date,
    CASE
        WHEN signup_date < '2025-02-01'
            THEN 'Early Customer'
        ELSE 'New Customer'
    END AS customer_segment
FROM training.customers;
GO


/* ==========================================================
   42. CONDITIONAL AGGREGATION

   Multiple order metrics in one row.
   ========================================================== */

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Completed'
                THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    SUM(
        CASE
            WHEN order_status = 'Pending'
                THEN 1
            ELSE 0
        END
    ) AS pending_orders

FROM training.orders;
GO


/* ==========================================================
   43. CONDITIONAL COUNT
   ========================================================== */

SELECT
    COUNT(
        CASE
            WHEN order_status = 'Completed'
                THEN order_id
        END
    ) AS completed_orders,

    COUNT(
        CASE
            WHEN order_status = 'Cancelled'
                THEN order_id
        END
    ) AS cancelled_orders

FROM training.orders;
GO


/* ==========================================================
   44. DISTINCT CONDITIONAL COUNT
   ========================================================== */

SELECT
    COUNT(DISTINCT
        CASE
            WHEN order_status = 'Completed'
                THEN customer_id
        END
    ) AS customers_with_completed_orders
FROM training.orders;
GO


/* ==========================================================
   45. CONDITIONAL AGGREGATION BY CUSTOMER

   Keep every customer, including customers
   with zero orders.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(o.order_id) AS total_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Completed'
                THEN o.order_id
        END
    ) AS completed_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Cancelled'
                THEN o.order_id
        END
    ) AS cancelled_orders

FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY c.customer_id;
GO


/* ==========================================================
   46. CONDITIONAL REVENUE
   ========================================================== */

SELECT
    SUM(
        CASE
            WHEN o.order_status = 'Completed'
                THEN oi.quantity * oi.unit_price
            ELSE 0
        END
    ) AS completed_revenue,

    SUM(
        CASE
            WHEN o.order_status = 'Cancelled'
                THEN oi.quantity * oi.unit_price
            ELSE 0
        END
    ) AS cancelled_order_value

FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
GO


/* ==========================================================
   47. REVENUE BY STATUS USING GROUP BY
   ========================================================== */

SELECT
    o.order_status,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM training.orders AS o
INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY order_value DESC;
GO


/* ==========================================================
   48. CONDITIONAL CUSTOMER REVENUE

   Return all customers.

   Customers without matching order items can receive 0.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity * oi.unit_price
                ELSE 0
            END
        ),
        0
    ) AS completed_revenue

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

LEFT JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY completed_revenue DESC;
GO


/* ==========================================================
   49. UNIT PROFIT
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products
ORDER BY unit_profit DESC;
GO


/* ==========================================================
   50. PROFIT MARGIN WITH CASE

   Margin:

   (price - cost) / price * 100

   Avoid division by zero.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,

    CASE
        WHEN price = 0 THEN NULL
        ELSE
            (price - cost) * 100.0 / price
    END AS margin_percent

FROM training.products;
GO


/* ==========================================================
   51. PROFIT MARGIN WITH NULLIF

   NULLIF(price, 0) returns NULL when price = 0.
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,

    (price - cost) * 100.0
        / NULLIF(price, 0) AS margin_percent

FROM training.products;
GO


/* ==========================================================
   52. INTEGER DIVISION
   ========================================================== */

SELECT
    1 / 2 AS integer_division,
    1.0 / 2 AS decimal_division;
GO


/* ==========================================================
   53. SALES DETAIL TRANSFORMATION
   ========================================================== */

SELECT
    o.order_id,
    CAST(o.order_date AS DATE) AS order_day,

    c.customer_name,
    COALESCE(c.city, N'Unknown') AS city,

    p.product_name,
    p.category,

    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_revenue,

    CASE
        WHEN oi.quantity >= 2 THEN 'Multi Unit'
        ELSE 'Single Unit'
    END AS quantity_type,

    CASE
        WHEN o.order_status = 'Completed' THEN 'Successful'
        WHEN o.order_status = 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group

FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

ORDER BY
    o.order_id,
    p.product_name;
GO


/* ==========================================================
   54. MONTHLY ORDER METRICS
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month,

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Completed'
                THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) AS cancelled_orders

FROM training.orders

GROUP BY
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   55. MONTHLY REVENUE

   Calculate Completed revenue by month.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    SUM(oi.quantity * oi.unit_price) AS revenue

FROM training.orders AS o

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   56. CUSTOMER ORDER SUMMARY

   Conditional aggregation allows several metrics
   without removing customers with no orders.
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(c.city, N'Unknown') AS city,

    COUNT(o.order_id) AS total_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Completed'
                THEN o.order_id
        END
    ) AS completed_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Cancelled'
                THEN o.order_id
        END
    ) AS cancelled_orders,

    MAX(o.order_date) AS latest_order_date

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.city

ORDER BY
    total_orders DESC,
    c.customer_name;
GO


/* ==========================================================
   57. PRODUCT BUSINESS CLASSIFICATION
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    cost,
    stock_quantity,

    price - cost AS unit_profit,

    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment,

    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 20 THEN 'Low Stock'
        ELSE 'Healthy Stock'
    END AS stock_status,

    (price - cost) * 100.0
        / NULLIF(price, 0) AS margin_percent

FROM training.products

ORDER BY price DESC;
GO


/* ==========================================================
   58. COMPLETED PRODUCT PERFORMANCE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    COUNT(DISTINCT o.order_id) AS order_count,

    SUM(oi.quantity) AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit

FROM training.products AS p

INNER JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

INNER JOIN training.orders AS o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'Completed'

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY revenue DESC;
GO


/*
Important:

The profit calculation above assumes the current
products.cost is appropriate for historical sales.

In a real production system, historical cost may need
to be stored at transaction time.

Business definitions and data modeling matter.
*/


/* ==========================================================
   59. CONDITIONAL PRODUCT PERFORMANCE

   Use a single grouped query to show values
   across multiple order statuses.
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity
                ELSE 0
            END
        ),
        0
    ) AS completed_units,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled'
                    THEN oi.quantity
                ELSE 0
            END
        ),
        0
    ) AS cancelled_units,

    COALESCE(
        SUM(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN oi.quantity * oi.unit_price
                ELSE 0
            END
        ),
        0
    ) AS completed_revenue

FROM training.products AS p

LEFT JOIN training.order_items AS oi
    ON p.product_id = oi.product_id

LEFT JOIN training.orders AS o
    ON oi.order_id = o.order_id

GROUP BY
    p.product_id,
    p.product_name

ORDER BY completed_revenue DESC;
GO


/* ==========================================================
   60. FINAL BUSINESS EXAMPLE

   Create a transformed customer report.

   Return:

   - Customer
   - Display city
   - Signup month
   - Total orders
   - Completed orders
   - Cancelled orders
   - Customer activity classification
   ========================================================== */

SELECT
    c.customer_id,
    c.customer_name,

    COALESCE(
        c.city,
        N'Unknown'
    ) AS display_city,

    DATEFROMPARTS(
        YEAR(c.signup_date),
        MONTH(c.signup_date),
        1
    ) AS signup_month,

    COUNT(o.order_id) AS total_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Completed'
                THEN o.order_id
        END
    ) AS completed_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Cancelled'
                THEN o.order_id
        END
    ) AS cancelled_orders,

    CASE
        WHEN COUNT(o.order_id) = 0
            THEN 'No Orders'

        WHEN COUNT(
            CASE
                WHEN o.order_status = 'Completed'
                    THEN o.order_id
            END
        ) >= 2
            THEN 'Repeat Customer'

        ELSE 'Customer'
    END AS customer_type

FROM training.customers AS c

LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.city,
    c.signup_date

ORDER BY
    total_orders DESC,
    c.customer_name;
GO


/* ==========================================================
   FINAL RECAP

   CASE
       Conditional transformation.

   COALESCE
       First non-NULL value.

   ISNULL
       SQL Server NULL replacement.

   NULLIF
       Return NULL when two expressions are equal.

   CAST / CONVERT
       Data type conversion.

   TRY_CAST / TRY_CONVERT
       Safe conversion attempts.

   CONCAT
       Combine values.

   STRING FUNCTIONS:
       LEN
       UPPER
       LOWER
       TRIM
       LTRIM
       RTRIM
       LEFT
       RIGHT
       SUBSTRING
       REPLACE

   DATE FUNCTIONS:
       YEAR
       MONTH
       DAY
       DATEPART
       DATENAME
       DATEADD
       DATEDIFF
       EOMONTH
       DATEFROMPARTS

   CONDITIONAL AGGREGATION:
       SUM(CASE ...)
       COUNT(CASE ...)
       COUNT(DISTINCT CASE ...)

   BUSINESS TRANSFORMATION:
       Segmentation
       Classification
       Revenue
       Profit
       Margin
       Monthly buckets

============================================================
END OF EXAMPLES
============================================================
*/