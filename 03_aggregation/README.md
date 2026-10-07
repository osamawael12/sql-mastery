# Aggregation
# 03 - Aggregation

## Objective

Learn how to summarize multiple rows of data and answer analytical and business questions using aggregate functions.

This chapter introduces:

- COUNT
- SUM
- AVG
- MIN
- MAX
- GROUP BY
- HAVING
- WHERE with aggregation
- DISTINCT with aggregates
- NULL behavior in aggregate functions
- Grouping by multiple columns
- Business aggregation patterns

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

# 1. What Is Aggregation?

Aggregation summarizes multiple rows into a smaller result.

Suppose a table contains:

```text
product_name    price
Laptop          30000
Mouse             500
Keyboard         1000
Monitor          7000
Headphones       1500
```

Instead of returning every product, we can ask questions such as:

```text
How many products exist?

What is the average product price?

What is the highest price?

What is the lowest price?

What is the total stock?
```

These questions are answered using aggregate functions.

---

# 2. Aggregate Functions

The main aggregate functions covered in this chapter are:

```text
COUNT()    Count rows or values
SUM()      Calculate a total
AVG()      Calculate an average
MIN()      Find the minimum value
MAX()      Find the maximum value
```

---

# 3. COUNT(*)

`COUNT(*)` counts rows.

Example:

```sql
SELECT
    COUNT(*) AS customer_count
FROM training.customers;
```

This returns one row containing the number of customers.

---

# 4. COUNT(column)

You can also count values in a specific column.

```sql
SELECT
    COUNT(city) AS customers_with_city
FROM training.customers;
```

There is an important difference:

```text
COUNT(*)       Counts rows
COUNT(column)  Counts non-NULL values in that column
```

If a customer has:

```text
city = NULL
```

that row is counted by:

```sql
COUNT(*)
```

but not by:

```sql
COUNT(city)
```

---

# 5. COUNT(DISTINCT column)

`DISTINCT` can be used inside `COUNT`.

Example:

```sql
SELECT
    COUNT(DISTINCT city) AS unique_city_count
FROM training.customers;
```

This counts distinct non-NULL cities.

---

# 6. SUM

`SUM` calculates the total of numeric values.

Example:

```sql
SELECT
    SUM(stock_quantity) AS total_stock
FROM training.products;
```

This adds the stock quantity of all products.

Another example:

```sql
SELECT
    SUM(quantity) AS total_units
FROM training.order_items;
```

---

# 7. AVG

`AVG` calculates an average.

```sql
SELECT
    AVG(price) AS average_price
FROM training.products;
```

This calculates the average product price.

For a clearer display, you can cast the result when necessary:

```sql
SELECT
    CAST(AVG(price) AS DECIMAL(12,2)) AS average_price
FROM training.products;
```

---

# 8. MIN

`MIN` returns the smallest value.

```sql
SELECT
    MIN(price) AS minimum_price
FROM training.products;
```

`MIN` can also work with dates:

```sql
SELECT
    MIN(signup_date) AS first_signup_date
FROM training.customers;
```

---

# 9. MAX

`MAX` returns the largest value.

```sql
SELECT
    MAX(price) AS maximum_price
FROM training.products;
```

It can also be used with dates:

```sql
SELECT
    MAX(signup_date) AS latest_signup_date
FROM training.customers;
```

---

# 10. Multiple Aggregates

Multiple aggregate functions can be calculated in the same query.

```sql
SELECT
    COUNT(*) AS product_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price,
    SUM(stock_quantity) AS total_stock
FROM training.products;
```

The result contains one summary row.

---

# 11. Aggregation with WHERE

`WHERE` filters rows before aggregation.

Example:

```sql
SELECT
    COUNT(*) AS completed_orders
FROM training.orders
WHERE order_status = 'Completed';
```

Conceptually:

```text
1. Read orders
2. Keep Completed orders
3. Count those rows
```

Another example:

```sql
SELECT
    AVG(price) AS average_accessory_price
FROM training.products
WHERE category = N'Accessories';
```

---

# 12. GROUP BY

Without `GROUP BY`, an aggregate usually summarizes the entire filtered result.

Example:

```sql
SELECT
    COUNT(*) AS product_count
FROM training.products;
```

To calculate separate results for different groups, use `GROUP BY`.

Example:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
```

Instead of one total, SQL Server calculates one result for each category.

---

# 13. How GROUP BY Works

Suppose the products are:

```text
Laptop       Electronics
Monitor      Electronics
Mouse        Accessories
Keyboard     Accessories
Headphones   Accessories
```

SQL logically groups them:

```text
Electronics
    Laptop
    Monitor

Accessories
    Mouse
    Keyboard
    Headphones
```

Then aggregates can be calculated for every group.

Example:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
```

---

# 14. GROUP BY with SUM

Calculate total stock by category:

```sql
SELECT
    category,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category;
```

---

# 15. GROUP BY with AVG

Calculate average price for each category:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

---

# 16. GROUP BY with MIN and MAX

```sql
SELECT
    category,
    MIN(price) AS cheapest_price,
    MAX(price) AS highest_price
FROM training.products
GROUP BY category;
```

---

# 17. Multiple Aggregates per Group

You can calculate several metrics for every group.

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price,
    SUM(stock_quantity) AS total_stock
FROM training.products
GROUP BY category;
```

This pattern is extremely common in analytical SQL.

---

# 18. The GROUP BY Rule

When aggregation is used, a column in `SELECT` generally must either:

1. Be inside an aggregate function

or

2. Be part of `GROUP BY`

Correct:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
```

Incorrect:

```sql
SELECT
    category,
    product_name,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category;
```

`product_name` is neither aggregated nor included in the grouping.

SQL Server does not know which individual product name should represent the entire category.

---

# 19. GROUP BY Multiple Columns

You can group by more than one column.

Example:

```sql
SELECT
    city,
    is_active,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY
    city,
    is_active;
```

Each unique combination becomes a separate group.

Conceptually:

```text
Cairo + Active
Cairo + Inactive
Giza + Active
Giza + Inactive
...
```

---

# 20. WHERE Before GROUP BY

`WHERE` can filter rows before grouping.

Example:

```sql
SELECT
    category,
    COUNT(*) AS active_product_count
FROM training.products
WHERE is_active = 1
GROUP BY category;
```

The order of the idea is:

```text
Filter rows
Then create groups
Then calculate aggregates
```

---

# 21. HAVING

`HAVING` filters groups after aggregation.

Example:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
HAVING COUNT(*) >= 2;
```

This returns only categories containing at least two products.

---

# 22. WHERE vs HAVING

This distinction is fundamental.

`WHERE` filters individual rows before grouping.

`HAVING` filters aggregated groups after grouping.

Example:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
WHERE is_active = 1
GROUP BY category
HAVING COUNT(*) >= 2;
```

Conceptually:

```text
WHERE
    Keep active product rows

GROUP BY
    Group them by category

COUNT
    Count products in each category

HAVING
    Keep groups with at least 2 products
```

---

# 23. Do Not Replace WHERE with HAVING

If a condition applies to individual rows, it normally belongs in `WHERE`.

Preferred:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
WHERE price >= 1000
GROUP BY category;
```

`price >= 1000` is a row-level condition.

A group-level condition belongs in `HAVING`:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) >= 2000;
```

---

# 24. HAVING with COUNT

Find cities containing at least two customers:

```sql
SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
WHERE city IS NOT NULL
GROUP BY city
HAVING COUNT(*) >= 2;
```

---

# 25. HAVING with SUM

Find products where the total ordered quantity is at least 2:

```sql
SELECT
    product_id,
    SUM(quantity) AS total_quantity
FROM training.order_items
GROUP BY product_id
HAVING SUM(quantity) >= 2;
```

At this stage we return `product_id`.

Retrieving `product_name` from another table requires a `JOIN`, which is covered later.

---

# 26. HAVING with AVG

Find categories whose average product price is at least 2000:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) >= 2000;
```

---

# 27. ORDER BY Aggregated Results

Aggregated results can be sorted.

Example:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
```

Aliases can be especially useful when sorting aggregated results.

---

# 28. TOP with Aggregation

You can combine `TOP`, grouping, aggregation, and sorting.

Example:

```sql
SELECT TOP (1)
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
```

This returns the category with the highest average product price.

If multiple categories tie, `TOP (1)` returns only one unless tie handling is explicitly requested.

SQL Server also supports:

```sql
TOP (1) WITH TIES
```

Example:

```sql
SELECT TOP (1) WITH TIES
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
```

This can return multiple groups if they share the same highest average.

---

# 29. NULL and Aggregate Functions

Most aggregate functions ignore `NULL` values.

For example:

```sql
SELECT
    COUNT(*) AS total_customers,
    COUNT(city) AS customers_with_city
FROM training.customers;
```

If one customer has `city = NULL`:

```text
COUNT(*)     includes the row
COUNT(city)  ignores the NULL city
```

This difference is important.

---

# 30. NULL with SUM, AVG, MIN and MAX

These functions generally ignore `NULL` values:

```text
SUM()
AVG()
MIN()
MAX()
```

Suppose values are:

```text
10
20
NULL
```

Then:

```text
SUM = 30
AVG = 15
```

The `NULL` value does not behave like zero.

This distinction matters:

```text
NULL = unknown/missing
0    = known numeric zero
```

---

# 31. NULL as a GROUP BY Group

`GROUP BY` can create a group for `NULL`.

Example:

```sql
SELECT
    city,
    COUNT(*) AS customer_count
FROM training.customers
GROUP BY city;
```

Customers where `city IS NULL` appear together as one group in the grouped result.

This differs from equality comparisons such as:

```sql
WHERE city = NULL
```

which are incorrect for testing missing values.

---

# 32. Counting Business Events

`COUNT(*)` is often used to count events.

Examples:

Number of customers:

```sql
SELECT
    COUNT(*) AS customer_count
FROM training.customers;
```

Number of orders:

```sql
SELECT
    COUNT(*) AS order_count
FROM training.orders;
```

Completed orders:

```sql
SELECT
    COUNT(*) AS completed_order_count
FROM training.orders
WHERE order_status = 'Completed';
```

---

# 33. Measuring Units Sold

The number of order item rows is not necessarily the number of units sold.

This:

```sql
SELECT
    COUNT(*) AS order_item_rows
FROM training.order_items;
```

counts rows.

This:

```sql
SELECT
    SUM(quantity) AS total_units
FROM training.order_items;
```

adds quantities.

If one row has:

```text
quantity = 5
```

that row represents five units, not one unit.

Always understand what the metric actually represents.

---

# 34. Simple Sales Value

The `order_items` table contains:

```text
quantity
unit_price
```

The value of one line is:

```text
quantity * unit_price
```

We can aggregate expressions:

```sql
SELECT
    SUM(quantity * unit_price) AS sales_value
FROM training.order_items;
```

This introduces an important analytical pattern:

```text
SUM(expression)
```

---

# 35. Sales Value by Order

We can calculate order value without a JOIN because `order_id` exists in `order_items`.

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id;
```

Each order becomes one group.

---

# 36. Units by Product

```sql
SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
ORDER BY total_units DESC;
```

We currently return the ID.

Later, `JOIN` will allow us to return:

```text
product_id
product_name
total_units
```

from multiple tables.

---

# 37. Order Line Statistics

Several measures can be generated together:

```sql
SELECT
    order_id,
    COUNT(*) AS line_count,
    SUM(quantity) AS total_units,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
```

This is closer to real analytical SQL.

---

# 38. Aggregation and Business Meaning

Consider these three metrics:

```sql
COUNT(*)
COUNT(DISTINCT order_id)
SUM(quantity)
```

They answer different questions.

```text
COUNT(*)
How many order-item rows exist?

COUNT(DISTINCT order_id)
How many different orders appear?

SUM(quantity)
How many units appear across those rows?
```

Choosing the wrong aggregate can produce a technically valid but logically incorrect business answer.

---

# 39. Query Structure with Aggregation

A common aggregated query looks like:

```sql
SELECT
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price
FROM training.products
WHERE is_active = 1
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY average_price DESC;
```

Written order:

```text
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
```

---

# 40. Logical Query Processing

For the concepts learned so far, think approximately:

```text
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. DISTINCT
7. ORDER BY
8. TOP
```

This explains why:

```text
WHERE
```

filters rows before aggregation, while:

```text
HAVING
```

filters groups after aggregation.

---

# 41. Common Mistake: Aggregate in WHERE

This is incorrect:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
WHERE AVG(price) > 1000
GROUP BY category;
```

`WHERE` runs before the groups and their aggregate values are logically produced.

Use `HAVING`:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
HAVING AVG(price) > 1000;
```

---

# 42. Common Mistake: Missing GROUP BY Column

Incorrect:

```sql
SELECT
    category,
    product_name,
    AVG(price)
FROM training.products
GROUP BY category;
```

`product_name` is neither aggregated nor grouped.

If you want category-level statistics:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

---

# 43. Common Mistake: COUNT(*) vs SUM(quantity)

Question:

```text
How many units were ordered?
```

Incorrect metric:

```sql
COUNT(*)
```

Correct metric:

```sql
SUM(quantity)
```

`COUNT(*)` counts rows, not units.

---

# 44. Common Mistake: COUNT(column) and NULL

Suppose you want all customers.

This:

```sql
COUNT(city)
```

can undercount customers because NULL cities are ignored.

Use:

```sql
COUNT(*)
```

when the goal is to count rows.

---

# 45. Business Example - Products by Category

Question:

```text
How many products are in each category?
```

Break it down:

```text
Table:
products

Grouping:
category

Metric:
COUNT(*)
```

Query:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
GROUP BY category
ORDER BY product_count DESC;
```

---

# 46. Business Example - Average Price

Question:

```text
What is the average product price in each category?
```

Query:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category
ORDER BY average_price DESC;
```

---

# 47. Business Example - Order Value

Question:

```text
What is the value of each order?
```

We know:

```text
line value = quantity * unit_price
```

Therefore:

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
ORDER BY order_value DESC;
```

---

# 48. Business Example - Product Demand

Question:

```text
Which product IDs have the highest ordered quantity?
```

Query:

```sql
SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
ORDER BY total_units DESC;
```

Later, joins will convert these IDs into descriptive product information.

---

# 49. Business Example - High Value Orders

Question:

```text
Which orders have an order value of at least 3000?
```

Query:

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id
HAVING SUM(quantity * unit_price) >= 3000
ORDER BY order_value DESC;
```

Notice why `HAVING` is used.

The condition applies to an aggregated value:

```text
SUM(quantity * unit_price)
```

not an individual row.

---

# 50. Analysis Mindset

When given an aggregation question, ask:

```text
1. What table contains the data?

2. What does one row represent?

3. Do I need to filter rows first?

4. What is the grouping dimension?

5. What metric do I need?

6. Do I need to filter the resulting groups?

7. How should the final results be sorted?
```

Example business question:

```text
Which product IDs sold at least 2 units,
and which sold the most?
```

Breakdown:

```text
Table:
order_items

Group:
product_id

Metric:
SUM(quantity)

Group filter:
SUM(quantity) >= 2

Sort:
total_units DESC
```

Query:

```sql
SELECT
    product_id,
    SUM(quantity) AS total_units
FROM training.order_items
GROUP BY product_id
HAVING SUM(quantity) >= 2
ORDER BY total_units DESC;
```

---

# Chapter Summary

After completing this chapter, you should understand:

```text
COUNT(*)
COUNT(column)
COUNT(DISTINCT column)
SUM()
AVG()
MIN()
MAX()

GROUP BY
GROUP BY multiple columns

WHERE before aggregation
HAVING after aggregation

NULL behavior with aggregates

Aggregating expressions

COUNT vs SUM

Sorting aggregate results

TOP with aggregate results

Basic aggregation business logic
```

---

# WHERE vs HAVING Summary

Remember:

```text
WHERE
    Filters rows before GROUP BY

HAVING
    Filters groups after GROUP BY
```

Example:

```sql
SELECT
    category,
    COUNT(*) AS product_count
FROM training.products
WHERE price >= 500
GROUP BY category
HAVING COUNT(*) >= 2
ORDER BY product_count DESC;
```

Conceptually:

```text
FROM
    products

WHERE
    Keep products priced >= 500

GROUP BY
    Create category groups

COUNT
    Count rows in each group

HAVING
    Keep categories with at least 2 products

ORDER BY
    Sort final results
```

---

# Chapter Files

```text
03_aggregation/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to answer questions such as:

```text
How many customers do we have?

How many unique cities do customers come from?

How many products exist in each category?

What is the average price by category?

What is the total inventory?

How many units were ordered?

What is the value of each order?

Which orders exceed a certain value?

Which product IDs have the highest demand?
```

The next major step is combining data from multiple tables.

That will allow questions such as:

```text
Which customer placed each order?

What is each customer's total spending?

What are the names of the best-selling products?

Which customers have never placed an order?
```

Those questions require JOINs.