/*
============================================================
SQL MASTERY
05 - DATA TRANSFORMATION

File: solutions.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - CALCULATED COLUMN
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
   EXERCISE 2 - ORDER LINE VALUE
   ========================================================== */

SELECT
    order_item_id,
    order_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_value
FROM training.order_items;
GO


/* ==========================================================
   EXERCISE 3 - BASIC CASE
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
   EXERCISE 4 - MULTIPLE CASE CONDITIONS
   ========================================================== */

SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'High'
        WHEN price >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS price_level
FROM training.products;
GO


/* ==========================================================
   EXERCISE 5 - ORDER STATUS TRANSFORMATION
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
   EXERCISE 6 - SIMPLE CASE
   ========================================================== */

SELECT
    order_id,
    order_status,
    CASE order_status
        WHEN 'Completed' THEN 'Successful'
        WHEN 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 7 - CASE WITH NULL
   ========================================================== */

SELECT
    customer_name,
    city,
    CASE
        WHEN city IS NULL THEN N'Unknown'
        ELSE city
    END AS display_city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 8 - COALESCE
   ========================================================== */

SELECT
    customer_name,
    COALESCE(city, N'Unknown') AS display_city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 9 - ISNULL
   ========================================================== */

SELECT
    customer_name,
    ISNULL(city, N'Unknown') AS display_city
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 10 - CAST
   ========================================================== */

SELECT
    product_name,
    price,
    CAST(price AS INT) AS price_as_integer
FROM training.products;
GO


/* ==========================================================
   EXERCISE 11 - DATETIME TO DATE
   ========================================================== */

SELECT
    order_id,
    order_date,
    CAST(order_date AS DATE) AS order_day
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 12 - CONVERT
   ========================================================== */

SELECT
    order_id,
    order_date,
    CONVERT(DATE, order_date) AS order_day
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 13 - DATE TO TEXT
   ========================================================== */

SELECT
    order_id,
    CONVERT(VARCHAR(10), order_date, 23) AS order_date_text
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 14 - TRY_CAST
   ========================================================== */

SELECT
    TRY_CAST('500' AS INT) AS valid_number,
    TRY_CAST('SQL' AS INT) AS invalid_number;
GO


/* ==========================================================
   EXERCISE 15 - CONCAT
   ========================================================== */

SELECT
    CONCAT(
        customer_name,
        ' - ',
        email
    ) AS customer_details
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 16 - CONCAT + NULL
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
   EXERCISE 17 - LEN
   ========================================================== */

SELECT
    customer_name,
    LEN(customer_name) AS name_length
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 18 - UPPER / LOWER
   ========================================================== */

SELECT
    customer_name,
    UPPER(customer_name) AS uppercase_name,
    email,
    LOWER(email) AS lowercase_email
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 19 - TRIM
   ========================================================== */

SELECT
    customer_name,
    TRIM(customer_name) AS clean_name
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 20 - STRING EXTRACTION
   ========================================================== */

SELECT
    customer_name,
    LEFT(customer_name, 3) AS first_three_characters,
    RIGHT(email, 4) AS last_four_email_characters
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 21 - SUBSTRING
   ========================================================== */

SELECT
    customer_name,
    SUBSTRING(customer_name, 1, 5) AS short_name
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 22 - REPLACE
   ========================================================== */

SELECT
    email,
    REPLACE(email, '@', ' [at] ') AS display_email
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 23 - YEAR / MONTH / DAY
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
   EXERCISE 24 - DATENAME
   ========================================================== */

SELECT
    order_id,
    order_date,
    DATENAME(MONTH, order_date) AS month_name
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 25 - DATEADD
   ========================================================== */

SELECT
    customer_name,
    signup_date,
    DATEADD(DAY, 30, signup_date) AS date_after_30_days
FROM training.customers;
GO


/* ==========================================================
   EXERCISE 26 - DATEDIFF
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
   EXERCISE 27 - EOMONTH
   ========================================================== */

SELECT
    order_id,
    order_date,
    EOMONTH(order_date) AS month_end
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 28 - MONTH BUCKET
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
   EXERCISE 29 - ORDERS BY MONTH
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
   EXERCISE 30 - PRODUCT SEGMENTATION
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
   EXERCISE 31 - GROUP BY TRANSFORMATION
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
    END
ORDER BY product_count DESC;
GO


/* ==========================================================
   EXERCISE 32 - CUSTOMER SEGMENTATION
   ========================================================== */

SELECT
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
   EXERCISE 33 - CONDITIONAL AGGREGATION
   ========================================================== */

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    SUM(
        CASE
            WHEN order_status = 'Pending' THEN 1
            ELSE 0
        END
    ) AS pending_orders

FROM training.orders;
GO


/* ==========================================================
   EXERCISE 34 - CONDITIONAL COUNT
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
   EXERCISE 35 - DISTINCT CONDITIONAL COUNT
   ========================================================== */

SELECT
    COUNT(
        DISTINCT CASE
            WHEN order_status = 'Completed'
                THEN customer_id
        END
    ) AS customers_with_completed_orders
FROM training.orders;
GO


/* ==========================================================
   EXERCISE 36 - CUSTOMER ORDER SUMMARY
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
   EXERCISE 37 - CONDITIONAL REVENUE
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
   EXERCISE 38 - REVENUE BY STATUS
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
   EXERCISE 39 - PROFIT MARGIN
   ========================================================== */

SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit,
    (price - cost) * 100.0
        / NULLIF(price, 0) AS margin_percent
FROM training.products;
GO


/* ==========================================================
   EXERCISE 40 - STOCK CLASSIFICATION
   ========================================================== */

SELECT
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 20 THEN 'Low Stock'
        ELSE 'Healthy Stock'
    END AS stock_status
FROM training.products;
GO


/* ==========================================================
   EXERCISE 41 - SALES DETAIL TRANSFORMATION
   ========================================================== */

SELECT
    o.order_id,

    CAST(o.order_date AS DATE) AS order_day,

    c.customer_name,

    COALESCE(c.city, N'Unknown') AS display_city,

    p.product_name,

    oi.quantity,
    oi.unit_price,

    oi.quantity * oi.unit_price AS line_revenue,

    CASE
        WHEN o.order_status = 'Completed'
            THEN 'Successful'
        WHEN o.order_status = 'Cancelled'
            THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group

FROM training.orders AS o

INNER JOIN training.customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

INNER JOIN training.products AS p
    ON oi.product_id = p.product_id

ORDER BY o.order_id;
GO


/* ==========================================================
   EXERCISE 42 - MONTHLY ORDER METRICS
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
            WHEN order_status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
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
   EXERCISE 43 - MONTHLY COMPLETED REVENUE
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue

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
   EXERCISE 44 - CUSTOMER COMPLETED REVENUE
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
   EXERCISE 45 - PRODUCT BUSINESS REPORT
   ========================================================== */

SELECT
    product_id,
    product_name,
    price,
    cost,
    stock_quantity,

    price - cost AS unit_profit,

    (price - cost) * 100.0
        / NULLIF(price, 0) AS margin_percent,

    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment,

    CASE
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity <= 20 THEN 'Low Stock'
        ELSE 'Healthy Stock'
    END AS stock_status

FROM training.products
ORDER BY price DESC;
GO


/* ==========================================================
   EXERCISE 46 - THINK ABOUT CASE ORDER
   ========================================================== */

/*
Answer:

1. 'Medium'

2. CASE checks conditions from top to bottom.

   30000 satisfies:

       price >= 1000

   so SQL returns 'Medium' immediately.

   The next condition is never reached.

3. More specific / higher threshold first:

       CASE
           WHEN price >= 10000 THEN 'High'
           WHEN price >= 1000 THEN 'Medium'
           ELSE 'Low'
       END
*/


/* ==========================================================
   EXERCISE 47 - THINK ABOUT NULL
   ========================================================== */

/*
Answer:

1. No.

   COALESCE does not permanently update the table.

2. If city contains a value, COALESCE returns city.

3. If city is NULL, it returns:

   Unknown

The transformation affects the query result only.
*/


/* ==========================================================
   EXERCISE 48 - INTEGER DIVISION
   ========================================================== */

/*
Answer:

    1 / 2

uses integer operands and returns:

    0


    1.0 / 2

uses decimal arithmetic and returns:

    0.5


This matters for percentages because integer division
can discard the fractional portion and produce an
incorrect analytical result.

Example:

    completed_orders * 100.0 / total_orders

is preferable when a decimal percentage is required.
*/


/* ==========================================================
   EXERCISE 49 - NULLIF
   ========================================================== */

/*
Answer:

NULLIF(revenue, 0) returns NULL when revenue is zero.

Therefore:

    profit / NULLIF(revenue, 0)

avoids attempting:

    profit / 0

which would cause a division-by-zero error.

When revenue is zero, the result becomes NULL instead.
*/


/* ==========================================================
   EXERCISE 50 - TRANSFORMATION VS UPDATE
   ========================================================== */

/*
Answer:

1. No.

2. It changes only the value displayed by the
   SELECT result.

3. UPDATE would be required to permanently modify
   existing stored rows.

Example:

    UPDATE training.customers
    SET customer_name = UPPER(customer_name);

An UPDATE should only be executed when a permanent
data change is actually intended.
*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER BUSINESS REPORT
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

    MAX(o.order_date) AS latest_order_date,

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
    c.customer_name ASC;
GO


/* ==========================================================
   CHALLENGE 2 - PRODUCT PROFITABILITY
   ========================================================== */

SELECT
    product_id,
    product_name,
    category,
    price,
    cost,

    price - cost AS unit_profit,

    (price - cost) * 100.0
        / NULLIF(price, 0) AS margin_percent,

    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment

FROM training.products

ORDER BY margin_percent DESC;
GO


/* ==========================================================
   CHALLENGE 3 - MONTHLY BUSINESS SUMMARY

   Important:

   orders -> order_items is one-to-many.

   After joining to order_items, one order can appear
   multiple times.

   Therefore order/customer counts use DISTINCT.
   ========================================================== */

SELECT
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    ) AS order_month,

    COUNT(
        DISTINCT o.order_id
    ) AS total_orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'Completed'
                THEN o.order_id
        END
    ) AS completed_orders,

    COUNT(
        DISTINCT CASE
            WHEN o.order_status = 'Cancelled'
                THEN o.order_id
        END
    ) AS cancelled_orders,

    COUNT(
        DISTINCT o.customer_id
    ) AS distinct_customers,

    SUM(
        CASE
            WHEN o.order_status = 'Completed'
                THEN oi.quantity * oi.unit_price
            ELSE 0
        END
    ) AS completed_revenue

FROM training.orders AS o

LEFT JOIN training.order_items AS oi
    ON o.order_id = oi.order_id

GROUP BY
    DATEFROMPARTS(
        YEAR(o.order_date),
        MONTH(o.order_date),
        1
    )

ORDER BY order_month;
GO


/* ==========================================================
   CHALLENGE 4 - PRODUCT SALES TRANSFORMATION
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,

    CASE
        WHEN p.price >= 10000 THEN 'Premium'
        WHEN p.price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment,

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
    p.product_name,
    p.price

ORDER BY completed_revenue DESC;
GO


/* ==========================================================
   CHALLENGE 5 - FINAL TRANSFORMATION CHALLENGE
   ========================================================== */

SELECT
    p.product_id,
    p.product_name,
    p.category,

    COUNT(
        DISTINCT o.order_id
    ) AS completed_order_count,

    COUNT(
        DISTINCT o.customer_id
    ) AS customer_count,

    SUM(
        oi.quantity
    ) AS units_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue,

    SUM(
        oi.quantity * (oi.unit_price - p.cost)
    ) AS estimated_gross_profit,

    CASE
        WHEN SUM(
            oi.quantity * oi.unit_price
        ) >= 10000
            THEN 'High Revenue'

        WHEN SUM(
            oi.quantity * oi.unit_price
        ) >= 3000
            THEN 'Medium Revenue'

        ELSE 'Low Revenue'
    END AS revenue_segment

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


/* ==========================================================
   FINAL RECAP

   CALCULATED COLUMNS:

       price - cost

       quantity * unit_price


   CASE:

       CASE
           WHEN condition THEN result
           ELSE result
       END


   NULL HANDLING:

       COALESCE()
       ISNULL()
       NULLIF()


   TYPE CONVERSION:

       CAST()
       CONVERT()
       TRY_CAST()
       TRY_CONVERT()


   STRING TRANSFORMATION:

       CONCAT()
       LEN()
       UPPER()
       LOWER()
       TRIM()
       LTRIM()
       RTRIM()
       LEFT()
       RIGHT()
       SUBSTRING()
       REPLACE()


   DATE TRANSFORMATION:

       YEAR()
       MONTH()
       DAY()
       DATEPART()
       DATENAME()
       DATEADD()
       DATEDIFF()
       EOMONTH()
       DATEFROMPARTS()


   CONDITIONAL AGGREGATION:

       SUM(
           CASE
               WHEN condition THEN value
               ELSE 0
           END
       )

       COUNT(
           CASE
               WHEN condition THEN value
           END
       )

       COUNT(
           DISTINCT CASE
               WHEN condition THEN value
           END
       )


   SAFE DIVISION:

       numerator
       / NULLIF(denominator, 0)


   IMPORTANT:

   Transforming a value inside SELECT does not
   permanently modify the stored data.

   Always distinguish:

       raw data
       transformed display value
       business metric
       permanent database modification

============================================================
END OF CHAPTER 05
============================================================
*/