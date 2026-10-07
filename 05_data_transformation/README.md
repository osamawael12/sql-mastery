# 05 - Data Transformation

## Objective

Learn how to transform raw database values into useful analytical output.

This chapter focuses on:

- CASE
- Conditional logic
- COALESCE
- ISNULL
- NULL replacement
- CAST
- CONVERT
- Type conversion
- String functions
- Date functions
- Calculated columns
- Conditional aggregation
- Business classifications

---

# Learning Database

```text
SQLMastery
```

# Learning Schema

```text
training
```

# Tables Used

```text
training.customers
training.products
training.orders
training.order_items
```

---

# 1. What Is Data Transformation?

Raw database values are not always in the format required for analysis.

For example, a product may contain:

```text
price = 30000
cost  = 25000
```

But an analyst may need:

```text
profit = 5000
```

A customer may contain:

```text
city = NULL
```

But a report may need:

```text
Unknown
```

An order may contain:

```text
order_status = Completed
```

But management may want:

```text
Successful
```

SQL can transform these values while querying the data.

---

# 2. Calculated Columns

Expressions can create calculated result columns.

Example:

```sql
SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products;
```

The original table is not modified.

`unit_profit` exists only in the query result.

---

# 3. Arithmetic Expressions

Common arithmetic operators:

```text
+    Addition
-    Subtraction
*    Multiplication
/    Division
```

Example:

```sql
SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products;
```

---

# 4. Order Line Value

For an order item:

```text
quantity
unit_price
```

Line value:

```text
quantity * unit_price
```

Query:

```sql
SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    quantity * unit_price AS line_value
FROM training.order_items;
```

---

# 5. CASE

`CASE` adds conditional logic to SQL expressions.

General form:

```sql
CASE
    WHEN condition THEN result
    WHEN condition THEN result
    ELSE result
END
```

Example:

```sql
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Expensive'
        ELSE 'Affordable'
    END AS price_group
FROM training.products;
```

---

# 6. Multiple CASE Conditions

`CASE` can contain multiple conditions.

```sql
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'High'
        WHEN price >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS price_level
FROM training.products;
```

SQL evaluates the conditions from top to bottom.

The first matching condition wins.

---

# 7. CASE Order Matters

Consider:

```sql
CASE
    WHEN price >= 1000 THEN 'Medium'
    WHEN price >= 10000 THEN 'High'
    ELSE 'Low'
END
```

A price of:

```text
30000
```

matches:

```text
price >= 1000
```

first.

Therefore SQL returns:

```text
Medium
```

and never reaches the second condition.

Correct:

```sql
CASE
    WHEN price >= 10000 THEN 'High'
    WHEN price >= 1000 THEN 'Medium'
    ELSE 'Low'
END
```

When conditions overlap, order them carefully.

---

# 8. CASE with Equality

`CASE` can transform categorical values.

```sql
SELECT
    order_id,
    order_status,
    CASE
        WHEN order_status = 'Completed' THEN 'Successful'
        WHEN order_status = 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group
FROM training.orders;
```

---

# 9. Simple CASE

SQL also supports a simple CASE form.

```sql
CASE order_status
    WHEN 'Completed' THEN 'Successful'
    WHEN 'Cancelled' THEN 'Failed'
    ELSE 'In Progress'
END
```

Example:

```sql
SELECT
    order_id,
    CASE order_status
        WHEN 'Completed' THEN 'Successful'
        WHEN 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group
FROM training.orders;
```

Use searched CASE when conditions involve ranges or more complex logic.

---

# 10. CASE with NULL

Example:

```sql
SELECT
    customer_name,
    city,
    CASE
        WHEN city IS NULL THEN N'Unknown'
        ELSE city
    END AS display_city
FROM training.customers;
```

Remember:

```sql
city = NULL
```

is not the correct way to test NULL.

Use:

```sql
city IS NULL
```

---

# 11. COALESCE

`COALESCE` returns the first non-NULL expression.

Example:

```sql
SELECT
    customer_name,
    COALESCE(city, N'Unknown') AS city
FROM training.customers;
```

If `city` contains a value, SQL returns it.

If `city` is NULL, SQL returns:

```text
Unknown
```

---

# 12. COALESCE with Multiple Values

`COALESCE` can check several expressions:

```sql
COALESCE(value1, value2, value3)
```

SQL returns the first non-NULL value.

Example idea:

```sql
COALESCE(mobile_phone, home_phone, office_phone, 'No Phone')
```

The current training schema does not contain these columns, but this pattern is common.

---

# 13. ISNULL

SQL Server provides:

```sql
ISNULL(expression, replacement)
```

Example:

```sql
SELECT
    customer_name,
    ISNULL(city, N'Unknown') AS city
FROM training.customers;
```

This can produce similar results to:

```sql
COALESCE(city, N'Unknown')
```

for simple two-value cases.

---

# 14. COALESCE vs ISNULL

`ISNULL` is SQL Server-specific.

```sql
ISNULL(city, N'Unknown')
```

`COALESCE` is standard SQL and supports multiple expressions:

```sql
COALESCE(value1, value2, value3)
```

Their type/nullability behavior can differ in some cases.

For general analytical SQL, understanding both is useful.

---

# 15. NULL in Arithmetic

NULL can propagate through arithmetic.

Suppose:

```text
value = NULL
```

Then:

```text
value + 10
```

usually produces:

```text
NULL
```

If business logic requires treating missing values as zero:

```sql
COALESCE(value, 0) + 10
```

But only replace NULL with zero when that interpretation is valid.

Missing does not automatically mean zero.

---

# 16. CAST

`CAST` converts one data type to another.

Syntax:

```sql
CAST(expression AS data_type)
```

Example:

```sql
SELECT
    product_name,
    CAST(price AS INT) AS price_as_integer
FROM training.products;
```

The original column remains unchanged.

---

# 17. CAST Number to Text

Example:

```sql
SELECT
    product_name,
    CAST(price AS VARCHAR(20)) AS price_text
FROM training.products;
```

This may be useful when constructing formatted text.

---

# 18. CONVERT

SQL Server also supports:

```sql
CONVERT(data_type, expression)
```

Example:

```sql
SELECT
    order_id,
    CONVERT(DATE, order_date) AS order_day
FROM training.orders;
```

`order_date` is `DATETIME2`.

The result contains only the date portion.

---

# 19. CAST vs CONVERT

Standard style:

```sql
CAST(order_date AS DATE)
```

SQL Server style:

```sql
CONVERT(DATE, order_date)
```

Both can perform many of the same conversions.

`CONVERT` also supports SQL Server formatting styles for certain date/string conversions.

---

# 20. Safe Conversion

A normal conversion can fail if the value cannot be converted.

SQL Server provides:

```text
TRY_CAST
TRY_CONVERT
```

Example:

```sql
SELECT
    TRY_CAST('123' AS INT) AS valid_number,
    TRY_CAST('ABC' AS INT) AS invalid_number;
```

Result conceptually:

```text
123
NULL
```

`TRY_CAST` returns NULL instead of raising a conversion error when the conversion fails.

---

# 21. String Concatenation

SQL Server can combine strings using:

```text
+
```

Example:

```sql
SELECT
    customer_name + ' - ' + email AS customer_details
FROM training.customers;
```

But `+` has an important NULL behavior.

If one part is NULL, the entire expression can become NULL.

---

# 22. CONCAT

`CONCAT` is often convenient when combining values.

Example:

```sql
SELECT
    CONCAT(customer_name, ' - ', city) AS customer_details
FROM training.customers;
```

`CONCAT` handles NULL values differently from the `+` operator and treats NULL arguments like empty strings.

---

# 23. LEN

`LEN` returns the number of characters.

```sql
SELECT
    customer_name,
    LEN(customer_name) AS name_length
FROM training.customers;
```

In SQL Server, `LEN` does not count trailing spaces.

---

# 24. UPPER

Convert text to uppercase:

```sql
SELECT
    customer_name,
    UPPER(customer_name) AS uppercase_name
FROM training.customers;
```

---

# 25. LOWER

Convert text to lowercase:

```sql
SELECT
    email,
    LOWER(email) AS normalized_email
FROM training.customers;
```

---

# 26. LTRIM and RTRIM

Remove leading or trailing spaces.

```sql
LTRIM(value)
RTRIM(value)
```

Example:

```sql
SELECT
    LTRIM(RTRIM(customer_name)) AS clean_name
FROM training.customers;
```

Modern SQL Server versions also support:

```sql
TRIM(customer_name)
```

---

# 27. TRIM

Example:

```sql
SELECT
    customer_name,
    TRIM(customer_name) AS clean_name
FROM training.customers;
```

Useful when source data contains unwanted spaces.

---

# 28. LEFT

Return characters from the beginning of a string.

```sql
SELECT
    customer_name,
    LEFT(customer_name, 3) AS first_three_characters
FROM training.customers;
```

---

# 29. RIGHT

Return characters from the end.

```sql
SELECT
    email,
    RIGHT(email, 4) AS last_four_characters
FROM training.customers;
```

---

# 30. SUBSTRING

Extract part of a string.

Syntax:

```sql
SUBSTRING(expression, start, length)
```

Example:

```sql
SELECT
    customer_name,
    SUBSTRING(customer_name, 1, 5) AS short_name
FROM training.customers;
```

SQL Server string positions start at 1.

---

# 31. REPLACE

Replace text inside a string.

```sql
SELECT
    email,
    REPLACE(email, '@', ' [at] ') AS display_email
FROM training.customers;
```

This transforms the query result, not the stored email.

---

# 32. Date and Time Transformation

Dates are critical in business analysis.

Useful SQL Server functions include:

```text
YEAR()
MONTH()
DAY()
DATEPART()
DATENAME()
DATEADD()
DATEDIFF()
EOMONTH()
```

---

# 33. YEAR

Extract the year:

```sql
SELECT
    order_id,
    order_date,
    YEAR(order_date) AS order_year
FROM training.orders;
```

---

# 34. MONTH

```sql
SELECT
    order_id,
    order_date,
    MONTH(order_date) AS order_month
FROM training.orders;
```

---

# 35. DAY

```sql
SELECT
    order_id,
    order_date,
    DAY(order_date) AS order_day
FROM training.orders;
```

---

# 36. DATEPART

`DATEPART` extracts a numeric date part.

Example:

```sql
SELECT
    order_date,
    DATEPART(YEAR, order_date) AS order_year,
    DATEPART(MONTH, order_date) AS order_month
FROM training.orders;
```

---

# 37. DATENAME

`DATENAME` returns a text representation.

Example:

```sql
SELECT
    order_date,
    DATENAME(MONTH, order_date) AS month_name
FROM training.orders;
```

The returned language depends on SQL Server session language settings.

---

# 38. DATEADD

`DATEADD` adds or subtracts a time interval.

Syntax:

```sql
DATEADD(datepart, number, date)
```

Example:

```sql
SELECT
    signup_date,
    DATEADD(DAY, 30, signup_date) AS date_after_30_days
FROM training.customers;
```

Subtracting:

```sql
DATEADD(DAY, -7, signup_date)
```

---

# 39. DATEDIFF

`DATEDIFF` calculates the number of date-part boundaries crossed.

Example:

```sql
SELECT
    customer_name,
    signup_date,
    DATEDIFF(DAY, signup_date, CAST(GETDATE() AS DATE))
        AS days_since_signup
FROM training.customers;
```

Important: `DATEDIFF` is based on boundaries for the requested date part, so it should not always be interpreted as precise elapsed duration.

---

# 40. EOMONTH

`EOMONTH` returns the last day of a month.

```sql
SELECT
    order_date,
    EOMONTH(order_date) AS month_end
FROM training.orders;
```

This is useful in monthly reporting.

---

# 41. Creating a Month Bucket

A useful reporting transformation is converting a date into a month bucket.

One option:

```sql
SELECT
    order_date,
    DATEFROMPARTS(
        YEAR(order_date),
        MONTH(order_date),
        1
    ) AS order_month
FROM training.orders;
```

This returns the first day of each order's month.

Example:

```text
2025-03-15
->
2025-03-01
```

This is useful for grouping.

---

# 42. Grouping by Transformed Dates

Example:

```sql
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
```

Now the result contains one row per month.

---

# 43. CASE for Business Segmentation

Example product segmentation:

```sql
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment
FROM training.products;
```

This is a common analytical pattern.

---

# 44. Customer Segmentation

Example:

```sql
SELECT
    customer_name,
    signup_date,
    CASE
        WHEN signup_date < '2025-02-01'
            THEN 'Early Customer'
        ELSE 'New Customer'
    END AS customer_segment
FROM training.customers;
```

---

# 45. Conditional Aggregation

`CASE` can be placed inside aggregate functions.

Example:

```sql
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
    ) AS cancelled_orders
FROM training.orders;
```

This is called conditional aggregation.

---

# 46. Conditional COUNT

Another pattern:

```sql
SELECT
    COUNT(
        CASE
            WHEN order_status = 'Completed'
            THEN order_id
        END
    ) AS completed_orders
FROM training.orders;
```

Rows where the condition does not match produce NULL.

`COUNT(expression)` ignores NULL.

---

# 47. Conditional Aggregation by Customer

With a LEFT JOIN:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,

    COUNT(
        CASE
            WHEN o.order_status = 'Completed'
            THEN o.order_id
        END
    ) AS completed_orders

FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;
```

Every customer remains in the result.

---

# 48. Conditional Revenue

Example:

```sql
SELECT
    SUM(
        CASE
            WHEN o.order_status = 'Completed'
            THEN oi.quantity * oi.unit_price
            ELSE 0
        END
    ) AS completed_revenue
FROM training.orders AS o
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id;
```

This calculates completed revenue while preserving other rows in the source result.

---

# 49. Multiple Metrics in One Query

Conditional aggregation allows multiple metrics from the same data.

Example:

```sql
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT
        CASE
            WHEN o.order_status = 'Completed'
            THEN o.order_id
        END
    ) AS completed_orders,

    COUNT(DISTINCT
        CASE
            WHEN o.order_status = 'Cancelled'
            THEN o.order_id
        END
    ) AS cancelled_orders

FROM training.orders AS o;
```

---

# 50. Profit Calculation

Products contain:

```text
price
cost
```

Unit profit:

```text
price - cost
```

Query:

```sql
SELECT
    product_name,
    price,
    cost,
    price - cost AS unit_profit
FROM training.products;
```

---

# 51. Profit Margin

A simple gross margin percentage can be calculated as:

```text
(price - cost) / price * 100
```

But numeric types matter.

Example:

```sql
SELECT
    product_name,
    price,
    cost,
    CASE
        WHEN price = 0 THEN NULL
        ELSE
            (price - cost) * 100.0 / price
    END AS margin_percent
FROM training.products;
```

The `CASE` prevents division by zero.

---

# 52. Division by Zero

This can fail:

```sql
value / 0
```

One solution:

```sql
CASE
    WHEN denominator = 0 THEN NULL
    ELSE numerator / denominator
END
```

SQL Server also supports:

```sql
numerator / NULLIF(denominator, 0)
```

---

# 53. NULLIF

`NULLIF(a, b)` returns NULL when:

```text
a = b
```

Otherwise it returns `a`.

Example:

```sql
SELECT
    (price - cost) * 100.0 / NULLIF(price, 0)
        AS margin_percent
FROM training.products;
```

If `price` is zero, `NULLIF(price, 0)` becomes NULL, avoiding division by zero.

---

# 54. Percentage Calculations

Be careful with integer division.

Example:

```sql
SELECT
    1 / 2;
```

With integer operands, this can produce:

```text
0
```

Instead:

```sql
SELECT
    1.0 / 2;
```

produces a decimal result.

Using:

```text
100.0
```

is a common way to ensure decimal arithmetic in percentage calculations.

---

# 55. CASE + GROUP BY

You can group by a calculated business segment.

Example:

```sql
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
```

The CASE expression is repeated because the SELECT alias is not generally available to `GROUP BY` at that logical processing stage.

Later chapters introduce techniques that can make complex transformations easier to reuse.

---

# 56. CASE + ORDER BY

Aliases can be used in `ORDER BY`.

```sql
SELECT
    product_name,
    price,
    CASE
        WHEN price >= 10000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid Range'
        ELSE 'Budget'
    END AS price_segment
FROM training.products
ORDER BY
    price_segment,
    price DESC;
```

---

# 57. Transformation with JOINs

Transformation functions work naturally with joined data.

Example:

```sql
SELECT
    c.customer_name,
    COALESCE(c.city, N'Unknown') AS city,
    o.order_id,
    CAST(o.order_date AS DATE) AS order_day,
    CASE
        WHEN o.order_status = 'Completed' THEN 'Successful'
        WHEN o.order_status = 'Cancelled' THEN 'Failed'
        ELSE 'In Progress'
    END AS status_group
FROM training.customers AS c
JOIN training.orders AS o
    ON c.customer_id = o.customer_id;
```

---

# 58. Business Sales Transformation

Example:

```sql
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_revenue,

    CASE
        WHEN oi.quantity >= 2 THEN 'Multi Unit'
        ELSE 'Single Unit'
    END AS quantity_type

FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
JOIN training.products AS p
    ON oi.product_id = p.product_id;
```

---

# 59. Data Cleaning vs Data Transformation

Data transformation in a query does not necessarily modify stored data.

Example:

```sql
SELECT
    UPPER(customer_name)
FROM training.customers;
```

changes the result display.

It does not permanently change:

```text
training.customers.customer_name
```

Permanent changes require statements such as:

```text
UPDATE
```

which should be used deliberately.

---

# 60. Do Not Hide Data Quality Problems

Functions such as:

```text
TRIM
COALESCE
UPPER
LOWER
```

can make reporting output cleaner.

But they should not automatically hide real data-quality problems.

For example:

```text
NULL city
```

might mean:

```text
Customer did not provide a city
Data import failed
Legacy data is incomplete
```

Transforming it to:

```text
Unknown
```

is useful for reporting, but the underlying missing data still exists.

---

# 61. Query Logical Processing

With the concepts learned so far, think approximately:

```text
1. FROM / JOIN / ON
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. DISTINCT
7. ORDER BY
8. TOP
```

Many transformations such as:

```text
CASE
CAST
COALESCE
```

are expressions used within these clauses.

---

# 62. Business Thinking

When transforming data, ask:

```text
What does the raw value mean?

What output does the business need?

How should NULL be interpreted?

Could conversion fail?

Could division by zero occur?

Are CASE conditions overlapping?

Does the transformation change only the result
or the stored data?

Am I transforming presentation or business logic?
```

---

# Common Mistakes

## Incorrect NULL comparison

Wrong:

```sql
CASE
    WHEN city = NULL THEN 'Unknown'
END
```

Correct:

```sql
CASE
    WHEN city IS NULL THEN 'Unknown'
END
```

---

## Incorrect CASE order

Potentially wrong:

```sql
CASE
    WHEN price >= 1000 THEN 'Medium'
    WHEN price >= 10000 THEN 'High'
END
```

The second condition may never be reached for high prices.

---

## Assuming COALESCE modifies data

This:

```sql
COALESCE(city, N'Unknown')
```

only changes the result expression.

It does not update the table.

---

## Integer division

Potential issue:

```sql
1 / 2
```

Use decimal arithmetic when needed:

```sql
1.0 / 2
```

---

## Division by zero

Unsafe:

```sql
profit / revenue
```

when revenue can be zero.

Possible solution:

```sql
profit / NULLIF(revenue, 0)
```

---

## Converting invalid text

This can fail:

```sql
CAST('ABC' AS INT)
```

When invalid source values are possible:

```sql
TRY_CAST('ABC' AS INT)
```

can be safer.

---

# Analysis Patterns to Remember

```text
Replace missing display values:
COALESCE()

Create business categories:
CASE

Convert data types:
CAST()
CONVERT()

Safely attempt conversion:
TRY_CAST()
TRY_CONVERT()

Clean text:
TRIM()
UPPER()
LOWER()
REPLACE()

Inspect text:
LEN()
LEFT()
RIGHT()
SUBSTRING()

Analyze dates:
YEAR()
MONTH()
DAY()
DATEPART()
DATENAME()
DATEADD()
DATEDIFF()
EOMONTH()

Build monthly buckets:
DATEFROMPARTS()

Calculate conditional metrics:
SUM(CASE ...)
COUNT(CASE ...)

Avoid zero denominator:
NULLIF()
```

---

# Chapter Summary

By the end of this chapter, you should understand:

```text
Calculated expressions

CASE
Searched CASE
Simple CASE

CASE evaluation order

COALESCE
ISNULL
NULLIF

CAST
CONVERT
TRY_CAST
TRY_CONVERT

CONCAT

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

YEAR
MONTH
DAY
DATEPART
DATENAME
DATEADD
DATEDIFF
EOMONTH
DATEFROMPARTS

Conditional aggregation

SUM(CASE ...)
COUNT(CASE ...)

Profit calculations
Margin calculations

Division by zero

Integer vs decimal division

Business classification
```

---

# Chapter Files

```text
05_data_transformation/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

After completing this chapter, you should be able to transform raw SQL data into report-ready analytical output.

You should be able to answer questions such as:

```text
Which price segment does each product belong to?

How should missing cities appear in a report?

What is the profit per product?

What is the profit margin?

How many Completed vs Cancelled orders exist?

How many Completed orders did each customer place?

What month does each order belong to?

What is revenue by month?

How can text be cleaned and normalized?

How can invalid conversions be handled safely?
```

These transformation skills will be reused heavily in later business analysis.