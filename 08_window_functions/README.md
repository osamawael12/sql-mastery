# 08 - Window Functions

## Objective

Learn how to perform analytical calculations across related rows without collapsing the result like `GROUP BY`.

This chapter covers:

- OVER()
- PARTITION BY
- ORDER BY inside windows
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- NTILE()
- COUNT() OVER()
- SUM() OVER()
- AVG() OVER()
- MIN() OVER()
- MAX() OVER()
- Running totals
- Running counts
- Moving averages
- Percent of total
- LAG()
- LEAD()
- FIRST_VALUE()
- LAST_VALUE()
- Window frames
- Top N per group
- Customer and product ranking
- Time-series analysis

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

# 1. What Is a Window Function?

A window function calculates a value across a group of related rows while keeping the individual rows in the result.

This is the key difference from:

```text
GROUP BY
```

Example:

```sql
SELECT
    product_id,
    product_name,
    category,
    price,
    AVG(price) OVER () AS overall_average_price
FROM training.products;
```

Every product remains visible.

The average is added beside each row.

---

# 2. GROUP BY vs Window Functions

`GROUP BY` collapses rows.

Example:

```sql
SELECT
    category,
    AVG(price) AS average_price
FROM training.products
GROUP BY category;
```

One result row represents:

```text
one category
```

A window function keeps product rows:

```sql
SELECT
    product_name,
    category,
    price,
    AVG(price) OVER
    (
        PARTITION BY category
    ) AS category_average_price
FROM training.products;
```

One result row still represents:

```text
one product
```

but each row also contains its category average.

---

# 3. OVER()

`OVER()` turns an aggregate or supported analytical function into a window function.

Example:

```sql
SELECT
    product_name,
    price,
    AVG(price) OVER () AS overall_average
FROM training.products;
```

The empty:

```sql
OVER ()
```

means:

```text
Use the entire result as one window.
```

---

# 4. Aggregate Without GROUP BY

Example:

```sql
SELECT
    product_name,
    price,
    SUM(price) OVER () AS total_product_price
FROM training.products;
```

Every product row remains visible.

The total is repeated beside each row.

---

# 5. PARTITION BY

`PARTITION BY` splits rows into logical groups for the window calculation.

Example:

```sql
SELECT
    product_name,
    category,
    price,
    AVG(price) OVER
    (
        PARTITION BY category
    ) AS category_average_price
FROM training.products;
```

Conceptually:

```text
Accessories window

Electronics window
```

The rows are not collapsed.

---

# 6. PARTITION BY vs GROUP BY

`GROUP BY`:

```text
Changes the result grain.
```

`PARTITION BY`:

```text
Defines groups for the calculation
while preserving the result rows.
```

This distinction is fundamental.

---

# 7. COUNT OVER

Count all rows while preserving detail:

```sql
SELECT
    customer_id,
    customer_name,
    COUNT(*) OVER () AS total_customers
FROM training.customers;
```

---

# 8. COUNT by Partition

Example:

```sql
SELECT
    product_id,
    product_name,
    category,
    COUNT(*) OVER
    (
        PARTITION BY category
    ) AS products_in_category
FROM training.products;
```

Every product receives the number of products in its category.

---

# 9. SUM OVER

```sql
SELECT
    product_name,
    category,
    stock_quantity,
    SUM(stock_quantity) OVER
    (
        PARTITION BY category
    ) AS category_stock
FROM training.products;
```

Each product remains visible.

---

# 10. MIN and MAX OVER

```sql
SELECT
    product_name,
    category,
    price,

    MIN(price) OVER
    (
        PARTITION BY category
    ) AS category_min_price,

    MAX(price) OVER
    (
        PARTITION BY category
    ) AS category_max_price

FROM training.products;
```

---

# 11. Compare a Row to Its Group

A common analytical pattern:

```sql
SELECT
    product_name,
    category,
    price,

    AVG(price) OVER
    (
        PARTITION BY category
    ) AS category_average,

    price -
    AVG(price) OVER
    (
        PARTITION BY category
    ) AS difference_from_category_average

FROM training.products;
```

No correlated subquery is required.

---

# 12. Window ORDER BY

Some window calculations depend on row order.

Example:

```sql
ROW_NUMBER() OVER
(
    ORDER BY price DESC
)
```

This means:

```text
Number rows from highest price to lowest price.
```

---

# 13. ROW_NUMBER

`ROW_NUMBER()` assigns a unique sequential number.

Example:

```sql
SELECT
    product_name,
    price,

    ROW_NUMBER() OVER
    (
        ORDER BY price DESC
    ) AS price_row_number

FROM training.products;
```

Possible result:

```text
Laptop      30000   1
Monitor      7000   2
Headphones   1500   3
Keyboard     1000   4
Mouse         500   5
```

---

# 14. ROW_NUMBER with PARTITION BY

Rank separately inside each category:

```sql
SELECT
    product_name,
    category,
    price,

    ROW_NUMBER() OVER
    (
        PARTITION BY category
        ORDER BY price DESC
    ) AS category_row_number

FROM training.products;
```

The numbering restarts for every category.

---

# 15. RANK

`RANK()` gives equal ranking values to ties.

Example:

```sql
SELECT
    product_name,
    price,

    RANK() OVER
    (
        ORDER BY price DESC
    ) AS price_rank

FROM training.products;
```

If prices are:

```text
100
90
90
80
```

`RANK()` produces:

```text
1
2
2
4
```

Rank 3 is skipped.

---

# 16. DENSE_RANK

`DENSE_RANK()` also gives equal ranks to ties, but does not leave gaps.

For:

```text
100
90
90
80
```

the result is:

```text
1
2
2
3
```

---

# 17. ROW_NUMBER vs RANK vs DENSE_RANK

For:

```text
Value
100
90
90
80
```

Conceptually:

```text
ROW_NUMBER
1
2
3
4

RANK
1
2
2
4

DENSE_RANK
1
2
2
3
```

Choose based on the business meaning.

---

# 18. Ranking Within Groups

Example:

```sql
SELECT
    product_name,
    category,
    price,

    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY price DESC
    ) AS category_price_rank

FROM training.products;
```

Each category has its own ranking.

---

# 19. Deterministic ROW_NUMBER

If the ordering column contains ties, this:

```sql
ROW_NUMBER() OVER
(
    ORDER BY price DESC
)
```

does not fully define the order among equal prices.

For deterministic numbering, add a tie-breaker:

```sql
ROW_NUMBER() OVER
(
    ORDER BY
        price DESC,
        product_id ASC
)
```

This is important in production SQL.

---

# 20. Top N per Group

A classic window-function problem:

```text
Find the 2 most expensive products
in each category.
```

First calculate row numbers:

```sql
;WITH RankedProducts AS
(
    SELECT
        product_id,
        product_name,
        category,
        price,

        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                price DESC,
                product_id
        ) AS rn

    FROM training.products
)
SELECT
    product_id,
    product_name,
    category,
    price
FROM RankedProducts
WHERE rn <= 2;
```

This is one of the most important window patterns.

---

# 21. Why a CTE Is Needed for Filtering Window Results

This will not work logically in the same query level:

```sql
SELECT
    product_name,
    ROW_NUMBER() OVER
    (
        ORDER BY price DESC
    ) AS rn
FROM training.products
WHERE rn <= 3;
```

The `WHERE` phase occurs before the SELECT window expression is available.

Use:

```text
CTE

Derived table
```

then filter the calculated window column outside.

---

# 22. NTILE

`NTILE(n)` divides ordered rows into approximately equal buckets.

Example:

```sql
SELECT
    product_name,
    price,

    NTILE(4) OVER
    (
        ORDER BY price DESC
    ) AS price_quartile

FROM training.products;
```

This can be useful for segmentation such as:

```text
Quartiles
Deciles
Value bands
```

---

# 23. NTILE Is Row Distribution

`NTILE(4)` does not mean that each bucket covers an equal price range.

It distributes ordered rows across buckets as evenly as possible.

That is an important distinction.

---

# 24. Running Total

Windowed `SUM` with ordering can create a running total.

Example:

```sql
SELECT
    order_id,
    order_date,

    SUM(order_value) OVER
    (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_revenue

FROM ...;
```

To use this with order revenue, we first need one row per order.

---

# 25. Pre-Aggregation Before Window Functions

`order_items` has multiple rows per order.

First calculate order totals:

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT *
FROM OrderTotals;
```

Then join to orders and apply the window function.

---

# 26. Running Order Value

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_date,
    ot.order_value,

    SUM(ot.order_value) OVER
    (
        ORDER BY
            o.order_date,
            o.order_id
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_order_value

FROM training.orders AS o
JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id

ORDER BY
    o.order_date,
    o.order_id;
```

---

# 27. Window Frames

For ordered aggregate windows, the frame specifies which rows participate relative to the current row.

Example:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW
```

means:

```text
Start from the first row

Continue through the current row
```

This produces a running calculation.

---

# 28. Explicit ROWS Frame

For running totals, it is good practice to explicitly write:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW
```

instead of relying on the default frame.

This makes the intended row-by-row behavior clear, especially when the ordering values contain ties.

---

# 29. Running Total by Customer

The running calculation can restart for each customer.

```sql
SUM(order_value) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date, order_id
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
)
```

Meaning:

```text
Running customer spending over time.
```

---

# 30. Running Count

Example:

```sql
COUNT(*) OVER
(
    ORDER BY order_date, order_id
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND CURRENT ROW
)
```

This calculates:

```text
1
2
3
4
...
```

across the ordered rows.

Unlike `ROW_NUMBER`, this is an aggregate-window pattern and can be combined with partitions and frames for different use cases.

---

# 31. Moving Average

A moving average uses a limited frame.

Example:

```sql
AVG(order_value) OVER
(
    ORDER BY order_date, order_id
    ROWS BETWEEN 2 PRECEDING
             AND CURRENT ROW
)
```

This uses:

```text
Current row
+
previous 2 rows
```

giving a 3-row moving average.

At the beginning of the result, fewer than three rows may be available.

---

# 32. Moving Sum

Similarly:

```sql
SUM(order_value) OVER
(
    ORDER BY order_date, order_id
    ROWS BETWEEN 2 PRECEDING
             AND CURRENT ROW
)
```

calculates a rolling 3-row total.

---

# 33. Percent of Total

Suppose revenue is already calculated per product.

Percentage of total revenue:

```sql
revenue * 100.0
/
SUM(revenue) OVER ()
```

This is a very common analytical window pattern.

---

# 34. Product Revenue Share

```sql
;WITH ProductRevenue AS
(
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.order_items AS oi
    JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi.product_id
)
SELECT
    product_id,
    revenue,

    revenue * 100.0
    / NULLIF(
        SUM(revenue) OVER (),
        0
    ) AS revenue_percent

FROM ProductRevenue;
```

---

# 35. Percent Within Group

You can partition the denominator.

Example concept:

```sql
revenue * 100.0
/
SUM(revenue) OVER
(
    PARTITION BY category
)
```

This answers:

```text
What percentage of category revenue
does this product contribute?
```

---

# 36. LAG

`LAG` accesses a previous row according to window ordering.

Example:

```sql
LAG(order_value) OVER
(
    ORDER BY order_date, order_id
)
```

This can retrieve the previous order's value.

---

# 37. LAG Example

```sql
;WITH OrderTotals AS
(
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_value
    FROM training.order_items
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.order_date,
    ot.order_value,

    LAG(ot.order_value) OVER
    (
        ORDER BY o.order_date, o.order_id
    ) AS previous_order_value

FROM training.orders AS o
JOIN OrderTotals AS ot
    ON o.order_id = ot.order_id;
```

The first row has no previous row, so:

```text
previous_order_value = NULL
```

---

# 38. Difference from Previous Row

A powerful time-series pattern:

```sql
current_value - LAG(current_value)
```

Example:

```sql
ot.order_value
-
LAG(ot.order_value) OVER
(
    ORDER BY o.order_date, o.order_id
) AS change_from_previous
```

---

# 39. LEAD

`LEAD` accesses a following row.

Example:

```sql
LEAD(order_value) OVER
(
    ORDER BY order_date, order_id
)
```

The last row normally has:

```text
NULL
```

because no next row exists.

---

# 40. LAG and LEAD by Customer

Use:

```sql
PARTITION BY customer_id
```

to prevent one customer's sequence from flowing into another customer's sequence.

Example:

```sql
LAG(order_date) OVER
(
    PARTITION BY customer_id
    ORDER BY order_date, order_id
)
```

This can answer:

```text
What was this customer's previous order date?
```

---

# 41. Days Since Previous Order

```sql
DATEDIFF(
    DAY,
    LAG(order_date) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ),
    order_date
)
```

This calculates the number of day boundaries between a customer's previous order and current order.

For their first order:

```text
NULL
```

is expected.

---

# 42. FIRST_VALUE

`FIRST_VALUE` retrieves the first value in the ordered window.

Example:

```sql
FIRST_VALUE(price) OVER
(
    PARTITION BY category
    ORDER BY price DESC
) AS highest_category_price
```

Because prices are ordered descending, the first value is the highest.

---

# 43. FIRST_VALUE Example

```sql
SELECT
    product_name,
    category,
    price,

    FIRST_VALUE(product_name) OVER
    (
        PARTITION BY category
        ORDER BY
            price DESC,
            product_id
    ) AS most_expensive_product

FROM training.products;
```

The top product name is repeated across its category rows.

---

# 44. LAST_VALUE

`LAST_VALUE` can be surprising because its result depends on the window frame.

Example:

```sql
LAST_VALUE(price) OVER
(
    PARTITION BY category
    ORDER BY price DESC
)
```

may not mean:

```text
lowest price in the whole category
```

if the frame ends at the current row.

---

# 45. LAST_VALUE with Explicit Frame

To inspect the full partition:

```sql
LAST_VALUE(price) OVER
(
    PARTITION BY category
    ORDER BY price DESC
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND UNBOUNDED FOLLOWING
)
```

Now the frame includes every row in the category.

Because ordering is descending, the last value is the lowest price.

---

# 46. FIRST_VALUE vs MIN

Sometimes:

```sql
MIN(price) OVER
(
    PARTITION BY category
)
```

is simpler than:

```sql
FIRST_VALUE(...)
```

if you only need the minimum numeric value.

`FIRST_VALUE` becomes more valuable when you need a value from an ordered row, such as:

```text
Product name of the most expensive product
```

---

# 47. Window Functions After GROUP BY

Window functions can operate on an already aggregated result.

Example:

```sql
;WITH MonthlyRevenue AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS order_month,

        SUM(oi.quantity * oi.unit_price) AS revenue

    FROM training.orders AS o
    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        )
)
SELECT
    order_month,
    revenue,

    SUM(revenue) OVER
    (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS cumulative_revenue

FROM MonthlyRevenue;
```

This is a major analytical pattern:

```text
GROUP BY first

then window over the aggregated rows
```

---

# 48. Monthly Revenue Growth

Using `LAG`:

```sql
;WITH MonthlyRevenue AS
(
    ...
)
SELECT
    order_month,
    revenue,

    LAG(revenue) OVER
    (
        ORDER BY order_month
    ) AS previous_month_revenue

FROM MonthlyRevenue;
```

Then calculate the difference.

---

# 49. Growth Amount

```sql
revenue
-
LAG(revenue) OVER
(
    ORDER BY order_month
)
```

This gives absolute change.

---

# 50. Growth Percentage

Conceptually:

```text
(current - previous)
/
previous
* 100
```

A safe SQL pattern:

```sql
(
    revenue
    -
    LAG(revenue) OVER
    (
        ORDER BY order_month
    )
) * 100.0
/
NULLIF(
    LAG(revenue) OVER
    (
        ORDER BY order_month
    ),
    0
)
```

For clarity, a CTE can calculate the previous value first.

---

# 51. Cleaner Growth with Multiple Stages

```sql
;WITH MonthlyRevenue AS
(
    ...
),
RevenueWithLag AS
(
    SELECT
        order_month,
        revenue,

        LAG(revenue) OVER
        (
            ORDER BY order_month
        ) AS previous_revenue

    FROM MonthlyRevenue
)
SELECT
    order_month,
    revenue,
    previous_revenue,

    revenue - previous_revenue AS revenue_change,

    (revenue - previous_revenue) * 100.0
    / NULLIF(previous_revenue, 0)
        AS growth_percent

FROM RevenueWithLag;
```

This is easier to read and avoids repeating the window expression.

---

# 52. Ranking Aggregated Results

First calculate customer revenue:

```sql
;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    revenue,

    DENSE_RANK() OVER
    (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM CustomerRevenue;
```

---

# 53. Customer Revenue Ranking

Add customer names:

```sql
;WITH CustomerRevenue AS
(
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM training.orders AS o
    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue,

    DENSE_RANK() OVER
    (
        ORDER BY cr.revenue DESC
    ) AS revenue_rank

FROM CustomerRevenue AS cr
JOIN training.customers AS c
    ON cr.customer_id = c.customer_id

ORDER BY revenue_rank;
```

---

# 54. Product Ranking Within Category

First calculate product revenue:

```sql
;WITH ProductRevenue AS
(
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.unit_price
        ) AS revenue

    FROM training.products AS p

    JOIN training.order_items AS oi
        ON p.product_id = oi.product_id

    JOIN training.orders AS o
        ON oi.order_id = o.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    revenue,

    DENSE_RANK() OVER
    (
        PARTITION BY category
        ORDER BY revenue DESC
    ) AS category_rank

FROM ProductRevenue;
```

---

# 55. Top Product per Category

```sql
;WITH ProductRevenue AS
(
    ...
),
RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY category
            ORDER BY
                revenue DESC,
                product_id
        ) AS rn

    FROM ProductRevenue
)
SELECT
    product_id,
    product_name,
    category,
    revenue
FROM RankedProducts
WHERE rn = 1;
```

This pattern generalizes to:

```text
Top customer per city

Latest order per customer

Highest revenue product per category

Top N employees per department
```

---

# 56. Latest Order per Customer

Use:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY order_date DESC, order_id DESC
)
```

Example:

```sql
;WITH RankedOrders AS
(
    SELECT
        order_id,
        customer_id,
        order_date,
        order_status,

        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY
                order_date DESC,
                order_id DESC
        ) AS rn

    FROM training.orders
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM RankedOrders
WHERE rn = 1;
```

---

# 57. First Order per Customer

Reverse the ordering:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY
        order_date ASC,
        order_id ASC
)
```

Then filter:

```text
rn = 1
```

---

# 58. ROW_NUMBER for Deduplication

Window functions are commonly used when data contains multiple rows representing the same business entity and you need to choose one.

Pattern:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY business_key
    ORDER BY preferred_row_rule
)
```

Then:

```sql
WHERE rn = 1
```

The ordering rule must clearly define which row should win.

---

# 59. Window Function Execution Thinking

Simplified logical processing:

```text
FROM / JOIN
WHERE
GROUP BY
HAVING
window calculations
SELECT
DISTINCT
ORDER BY
TOP
```

This is why you normally cannot filter a window result directly in `WHERE` at the same query level.

Use another query layer.

---

# 60. PARTITION BY Does Not Sort Final Output

This:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY category
    ORDER BY price DESC
)
```

defines order for the window calculation.

It does NOT guarantee the final result display order.

If final order matters, also write:

```sql
ORDER BY
    category,
    price DESC;
```

---

# 61. Window ORDER BY vs Final ORDER BY

These serve different purposes.

Inside:

```sql
OVER
(
    ORDER BY order_date
)
```

controls the calculation.

At the end:

```sql
ORDER BY order_date
```

controls displayed result ordering.

A query may need both.

---

# 62. Common Mistake - Filtering Window Alias in WHERE

Incorrect:

```sql
SELECT
    product_name,
    ROW_NUMBER() OVER
    (
        ORDER BY price DESC
    ) AS rn
FROM training.products
WHERE rn <= 3;
```

Correct pattern:

```sql
;WITH RankedProducts AS
(
    SELECT
        product_name,
        price,

        ROW_NUMBER() OVER
        (
            ORDER BY price DESC
        ) AS rn

    FROM training.products
)
SELECT *
FROM RankedProducts
WHERE rn <= 3;
```

---

# 63. Common Mistake - Missing Tie-Breaker

Potentially nondeterministic:

```sql
ROW_NUMBER() OVER
(
    ORDER BY price DESC
)
```

when several products have the same price.

Better:

```sql
ROW_NUMBER() OVER
(
    ORDER BY
        price DESC,
        product_id ASC
)
```

when a stable deterministic result is required.

---

# 64. Common Mistake - Confusing RANK and ROW_NUMBER

If two customers have equal revenue:

```text
ROW_NUMBER
```

still gives different row numbers.

```text
RANK
```

and:

```text
DENSE_RANK
```

give equal rankings to ties.

Choose according to the business definition of rank.

---

# 65. Common Mistake - LAST_VALUE Frame

This:

```sql
LAST_VALUE(price) OVER
(
    PARTITION BY category
    ORDER BY price DESC
)
```

may return the current row's value rather than the final value of the whole category.

Use the intended frame explicitly.

---

# 66. Common Mistake - Wrong Grain Before Window

Suppose you want:

```text
Running revenue per order.
```

If you apply the window directly to `order_items`, one order may occupy multiple rows.

First decide the grain:

```text
one row per order
```

Then aggregate order items before applying the running total.

Grain remains critical even with window functions.

---

# 67. Common Mistake - Percentage Integer Division

Potentially wrong:

```sql
revenue / total_revenue * 100
```

Use decimal arithmetic:

```sql
revenue * 100.0
/
NULLIF(total_revenue, 0)
```

---

# 68. Business Analysis Workflow

For window-function problems ask:

```text
1. What should one result row represent?

2. Do I need GROUP BY first?

3. What is the window partition?

4. What defines order inside the window?

5. Do ties matter?

6. Do I need a window frame?

7. Do I need to filter the window result
   in an outer query?

8. Do I need a deterministic tie-breaker?
```

---

# 69. Choosing the Function

Need a unique sequence?

```text
ROW_NUMBER
```

Need ranking with gaps after ties?

```text
RANK
```

Need ranking without gaps?

```text
DENSE_RANK
```

Need buckets?

```text
NTILE
```

Need previous value?

```text
LAG
```

Need next value?

```text
LEAD
```

Need cumulative value?

```text
SUM() OVER (...)
```

Need moving metric?

```text
AVG() OVER (... ROWS ...)
```

Need group total while retaining detail?

```text
SUM() OVER (PARTITION BY ...)
```

Need first ordered value?

```text
FIRST_VALUE
```

Need final ordered value?

```text
LAST_VALUE
```

---

# 70. Final Mental Model

Traditional aggregate:

```sql
GROUP BY category
```

changes:

```text
many product rows
```

into:

```text
one category row
```

Window function:

```sql
AVG(price) OVER
(
    PARTITION BY category
)
```

keeps:

```text
every product row
```

and adds:

```text
category context
```

That is the core power of window functions.

---

# Chapter Summary

After completing this chapter, you should understand:

```text
OVER()

PARTITION BY

Window ORDER BY

Window frames

ROW_NUMBER()

RANK()

DENSE_RANK()

NTILE()

COUNT() OVER()

SUM() OVER()

AVG() OVER()

MIN() OVER()

MAX() OVER()

Running totals

Running counts

Moving averages

Percent of total

LAG()

LEAD()

FIRST_VALUE()

LAST_VALUE()

Top N per group

Latest row per group

Ranking aggregated results

Windowing over aggregated CTEs

Deterministic ordering

Result grain before window calculations
```

---

# Chapter Files

```text
08_window_functions/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to answer questions such as:

```text
How does each product compare with its category average?

What is the ranking of products by price?

What are the top 2 products in each category?

What is each customer's latest order?

What was the previous order value?

How many days passed between customer orders?

What is cumulative revenue?

What is monthly revenue growth?

What percentage of total revenue does each product generate?

What percentage of category revenue comes from each product?

Which customers rank highest by revenue?

How can I calculate analytics while preserving
the underlying rows?
```

Window functions are one of the foundations of advanced analytical SQL.

After this chapter, the project moves into `09_business_sql`, where the concepts from Chapters 01–08 start being combined into revenue, customer, product, growth, retention, funnel, cohort, and RFM analysis.