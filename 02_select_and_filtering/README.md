# SELECT and Filtering
# 02 - SELECT and Filtering

## Objective

Learn how to retrieve specific data from SQL Server tables and control which rows and columns appear in query results.

This chapter focuses on the foundation of data analysis with SQL:

- Selecting columns
- Removing duplicates
- Filtering rows
- Combining conditions
- Working with NULL values
- Searching text
- Sorting results
- Limiting results

---

## Learning Database

```text
SQLMastery
```

## Learning Schema

```text
training
```

## Tables Used

This chapter mainly uses:

```text
training.customers
training.products
training.orders
training.order_items
```

---

# 1. SELECT

`SELECT` retrieves data from a table.

General syntax:

```sql
SELECT column_name
FROM schema_name.table_name;
```

Example:

```sql
SELECT customer_name
FROM training.customers;
```

Multiple columns can be selected:

```sql
SELECT
    customer_name,
    email,
    city
FROM training.customers;
```

---

# 2. SELECT *

The asterisk selects all columns from a table.

```sql
SELECT *
FROM training.customers;
```

This is useful for:

- Exploring a small table
- Learning
- Quickly inspecting data

For production queries, explicitly selecting the required columns is usually preferable.

Example:

```sql
SELECT
    customer_id,
    customer_name,
    city
FROM training.customers;
```

---

# 3. Column Aliases

An alias gives a result column a different display name.

Use `AS`:

```sql
SELECT
    customer_name AS customer,
    signup_date AS joined_date
FROM training.customers;
```

The alias changes the result column name.

It does not rename the column inside the table.

---

# 4. DISTINCT

`DISTINCT` removes duplicate combinations from the result.

Example:

```sql
SELECT DISTINCT city
FROM training.customers;
```

Without `DISTINCT`, the same city may appear multiple times.

`DISTINCT` can also work with multiple columns:

```sql
SELECT DISTINCT
    city,
    is_active
FROM training.customers;
```

In this case, SQL Server returns unique combinations of `city` and `is_active`.

---

# 5. WHERE

`WHERE` filters rows.

Example:

```sql
SELECT
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo';
```

Only rows that satisfy the condition are returned.

---

# 6. Comparison Operators

Common comparison operators:

```text
=     Equal
<>    Not equal
>     Greater than
>=    Greater than or equal
<     Less than
<=    Less than or equal
```

Example:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price > 1000;
```

Example:

```sql
SELECT
    product_name,
    stock_quantity
FROM training.products
WHERE stock_quantity <= 25;
```

---

# 7. AND

`AND` requires all conditions to be true.

```sql
SELECT
    product_name,
    category,
    price
FROM training.products
WHERE category = N'Accessories'
  AND price >= 1000;
```

Both conditions must be satisfied.

---

# 8. OR

`OR` requires at least one condition to be true.

```sql
SELECT
    customer_name,
    city
FROM training.customers
WHERE city = N'Cairo'
   OR city = N'Giza';
```

---

# 9. NOT

`NOT` reverses a condition.

Example:

```sql
SELECT
    product_name,
    category
FROM training.products
WHERE NOT category = N'Electronics';
```

The following is often clearer:

```sql
SELECT
    product_name,
    category
FROM training.products
WHERE category <> N'Electronics';
```

---

# 10. AND and OR Together

Be careful when combining `AND` and `OR`.

SQL Server evaluates `AND` before `OR`.

Example:

```sql
WHERE city = N'Cairo'
   OR city = N'Giza'
  AND is_active = 1
```

This may not mean what the reader expects.

Use parentheses to make the intended logic explicit:

```sql
WHERE
    (city = N'Cairo' OR city = N'Giza')
    AND is_active = 1;
```

Using parentheses makes complex filters easier to understand and maintain.

---

# 11. IN

`IN` checks whether a value matches one of several values.

Instead of:

```sql
WHERE city = N'Cairo'
   OR city = N'Giza'
   OR city = N'Alexandria'
```

Use:

```sql
WHERE city IN
(
    N'Cairo',
    N'Giza',
    N'Alexandria'
);
```

`IN` is especially useful when checking the same column against multiple values.

---

# 12. NOT IN

`NOT IN` excludes specified values.

```sql
SELECT
    customer_name,
    city
FROM training.customers
WHERE city NOT IN
(
    N'Cairo',
    N'Giza'
);
```

Be careful when `NULL` values are involved.

SQL uses three-valued logic, so `NULL` does not behave like a normal value.

---

# 13. BETWEEN

`BETWEEN` checks whether a value is inside an inclusive range.

Example:

```sql
SELECT
    product_name,
    price
FROM training.products
WHERE price BETWEEN 1000 AND 7000;
```

This includes both boundaries.

It is equivalent to:

```sql
WHERE price >= 1000
  AND price <= 7000;
```

`BETWEEN` can also be used with dates.

Example:

```sql
SELECT
    order_id,
    order_date
FROM training.orders
WHERE order_date BETWEEN '2025-03-01' AND '2025-03-31T23:59:59.9999999';
```

For date/time ranges, a half-open range is often safer:

```sql
WHERE order_date >= '2025-03-01'
  AND order_date < '2025-04-01';
```

This pattern avoids problems caused by time components.

---

# 14. LIKE

`LIKE` searches text using patterns.

Example:

```sql
SELECT
    customer_name
FROM training.customers
WHERE customer_name LIKE N'A%';
```

This finds names beginning with `A`.

---

# 15. LIKE Wildcards

Common SQL Server wildcards:

```text
%       Zero or more characters
_       Exactly one character
```

Starts with `A`:

```sql
WHERE customer_name LIKE N'A%';
```

Ends with `Ali`:

```sql
WHERE customer_name LIKE N'%Ali';
```

Contains `med`:

```sql
WHERE customer_name LIKE N'%med%';
```

One unknown character:

```sql
WHERE customer_name LIKE N'_mar%';
```

SQL Server also supports bracket patterns such as:

```sql
WHERE customer_name LIKE N'[AMS]%';
```

This searches for names beginning with `A`, `M`, or `S`.

---

# 16. NULL

`NULL` represents a missing or unknown value.

It is not:

```text
0
''
'NULL'
```

A comparison like this is incorrect:

```sql
WHERE city = NULL;
```

Because `NULL` is not compared using `=`.

---

# 17. IS NULL

Use `IS NULL` to find missing values.

```sql
SELECT
    customer_name,
    city
FROM training.customers
WHERE city IS NULL;
```

---

# 18. IS NOT NULL

Use `IS NOT NULL` to find rows where a value exists.

```sql
SELECT
    customer_name,
    city
FROM training.customers
WHERE city IS NOT NULL;
```

---

# 19. Three-Valued Logic

SQL conditions can evaluate to:

```text
TRUE
FALSE
UNKNOWN
```

Comparisons involving `NULL` normally result in `UNKNOWN`.

For example:

```sql
city = N'Cairo'
```

If `city` is `NULL`, SQL cannot say the condition is true or false.

The result is `UNKNOWN`.

A `WHERE` clause only keeps rows where the condition evaluates to `TRUE`.

This is why `NULL` requires special handling with:

```sql
IS NULL
IS NOT NULL
```

---

# 20. ORDER BY

SQL tables do not guarantee a particular result order unless `ORDER BY` is specified.

Ascending order:

```sql
SELECT
    product_name,
    price
FROM training.products
ORDER BY price ASC;
```

Descending order:

```sql
SELECT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

`ASC` is the default.

---

# 21. Sorting by Multiple Columns

Results can be sorted using more than one column.

```sql
SELECT
    category,
    product_name,
    price
FROM training.products
ORDER BY
    category ASC,
    price DESC;
```

SQL Server first sorts by `category`.

Rows with the same category are then sorted by `price`.

---

# 22. TOP

SQL Server uses `TOP` to limit the number of returned rows.

Example:

```sql
SELECT TOP (3)
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

This returns the three most expensive products.

Using `TOP` without `ORDER BY` does not guarantee which rows will be returned.

Prefer:

```sql
SELECT TOP (3)
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

Rather than:

```sql
SELECT TOP (3)
    product_name,
    price
FROM training.products;
```

when the goal is to retrieve a meaningful top three.

---

# 23. TOP PERCENT

SQL Server also supports `TOP` with percentages.

```sql
SELECT TOP (20) PERCENT
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

This returns approximately the top 20 percent of rows according to the specified ordering.

---

# 24. Query Structure

A basic query may combine several concepts:

```sql
SELECT TOP (5)
    product_name,
    category,
    price
FROM training.products
WHERE price >= 1000
  AND category IN (N'Electronics', N'Accessories')
ORDER BY price DESC;
```

The query is written in this order:

```text
SELECT
FROM
WHERE
ORDER BY
```

---

# 25. Logical Query Processing

The written order is not exactly the same as SQL's logical processing order.

For the concepts covered in this chapter, think of it approximately as:

```text
1. FROM
2. WHERE
3. SELECT
4. DISTINCT
5. ORDER BY
6. TOP
```

Example:

```sql
SELECT TOP (3)
    product_name,
    price
FROM training.products
WHERE price >= 1000
ORDER BY price DESC;
```

Conceptually:

```text
FROM
    Find the source table

WHERE
    Filter rows

SELECT
    Choose the output columns

ORDER BY
    Sort the result

TOP
    Return the required number of rows
```

Understanding this becomes increasingly important as queries become more complex.

---

# 26. Strings and Unicode

String values are placed inside single quotes:

```sql
WHERE order_status = 'Completed';
```

For Unicode text, SQL Server supports the `N` prefix:

```sql
WHERE city = N'Cairo';
```

This becomes important when storing or comparing languages such as Arabic.

Example:

```sql
N'القاهرة'
```

---

# 27. Filtering Dates

SQL Server supports ISO-style date values.

Example:

```sql
WHERE signup_date >= '2025-02-01';
```

For a date range:

```sql
WHERE signup_date >= '2025-02-01'
  AND signup_date < '2025-03-01';
```

For `DATETIME2`, the same half-open range pattern is useful:

```sql
WHERE order_date >= '2025-03-01'
  AND order_date < '2025-04-01';
```

This means:

```text
From March 1 inclusive
Until April 1 exclusive
```

---

# 28. Combining Filters

Real queries often combine several conditions.

Example:

```sql
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
AND price BETWEEN 500 AND 10000
AND stock_quantity > 0
ORDER BY
    price DESC,
    product_name ASC;
```

Keep complex conditions readable by:

- Placing important conditions on separate lines
- Using parentheses where needed
- Using `IN` instead of repeated `OR` conditions
- Choosing explicit column names

---

# 29. Common Mistakes

## Comparing NULL with =

Incorrect:

```sql
WHERE city = NULL;
```

Correct:

```sql
WHERE city IS NULL;
```

## Using double quotes for string values

Avoid:

```sql
WHERE city = "Cairo";
```

Use:

```sql
WHERE city = N'Cairo';
```

## Forgetting quotes around dates

Incorrect:

```sql
WHERE signup_date = 2025-01-10;
```

Correct:

```sql
WHERE signup_date = '2025-01-10';
```

## Assuming row order

Do not assume:

```sql
SELECT *
FROM training.products;
```

will always return rows in the same order.

Use:

```sql
SELECT *
FROM training.products
ORDER BY product_id;
```

when order matters.

## Using TOP without meaningful ordering

This:

```sql
SELECT TOP (3) *
FROM training.products;
```

returns three rows, but not necessarily the three rows you logically want.

If you want the most expensive products:

```sql
SELECT TOP (3)
    product_name,
    price
FROM training.products
ORDER BY price DESC;
```

---

# 30. Analysis Mindset

When writing a query, translate the business question into parts.

Question:

```text
Which active customers from Cairo or Giza joined during or after February 2025?
```

Think:

```text
Table:
customers

Columns:
customer_name
city
signup_date

Conditions:
is_active = 1
city is Cairo or Giza
signup_date >= 2025-02-01

Sorting:
newest signup first
```

Then write:

```sql
SELECT
    customer_name,
    city,
    signup_date
FROM training.customers
WHERE is_active = 1
  AND city IN (N'Cairo', N'Giza')
  AND signup_date >= '2025-02-01'
ORDER BY signup_date DESC;
```

This habit becomes very important in business analysis.

---

# Chapter Summary

After completing this chapter, you should be comfortable with:

```text
SELECT
SELECT *
Aliases
DISTINCT
WHERE
Comparison operators
AND
OR
NOT
IN
NOT IN
BETWEEN
LIKE
Wildcards
NULL
IS NULL
IS NOT NULL
ORDER BY
ASC
DESC
TOP
Date filtering
Combining multiple filters
Basic logical query processing
```

---

# Chapter Files

```text
02_select_and_filtering/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to translate a simple business question into a SQL query that:

1. Selects the required columns.
2. Reads from the correct table.
3. Filters the required rows.
4. Handles missing values correctly.
5. Searches text patterns.
6. Filters numbers and dates.
7. Sorts the result.
8. Limits the result when necessary.

The next chapter introduces aggregation, where multiple rows are summarized using functions such as `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`.