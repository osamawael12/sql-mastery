# SQL Mastery — Practice Exercises

## Overview

This directory is the final hands-on practice section of the SQL Mastery repository.

The numbered chapters teach SQL concepts individually.

The business challenges combine those concepts into analytical problems.

This section provides a structured practice path organized by difficulty:

```text
Beginner
    ->
Intermediate
    ->
Advanced
```

The goal is to practice solving SQL problems independently without being told exactly which SQL feature to use.

---

# Database

All exercises use Microsoft SQL Server and T-SQL.

```sql
USE SQLMastery;
GO
```

Main schema:

```text
training
```

Core tables:

```text
training.customers
training.products
training.orders
training.order_items
```

---

# Data Model

```text
customers
    |
    | 1
    |
    | customer_id
    |
    | N
    v
orders
    |
    | 1
    |
    | order_id
    |
    | N
    v
order_items
    |
    | N
    |
    | product_id
    |
    | 1
    v
products
```

Main relationships:

```sql
customers.customer_id = orders.customer_id

orders.order_id = order_items.order_id

products.product_id = order_items.product_id
```

---

# Directory Structure

```text
exercises/
│
├── README.md
│
├── beginner/
│   ├── exercises.sql
│   └── solutions.sql
│
├── intermediate/
│   ├── exercises.sql
│   └── solutions.sql
│
└── advanced/
    ├── exercises.sql
    └── solutions.sql
```

---

# How to Use This Section

Recommended workflow:

```text
1. Read one exercise.

2. Do not immediately open solutions.sql.

3. Write your own query.

4. Execute it.

5. Inspect the returned rows.

6. Ask whether the result makes business sense.

7. Test edge cases.

8. Compare against solutions.sql.

9. If your answer differs, understand why.

10. Rewrite the solution from memory later.
```

The objective is not to memorize the supplied solutions.

The objective is to develop SQL problem-solving habits.

---

# Exercise Levels

## Beginner

Focuses on:

```text
SELECT
Aliases
DISTINCT
WHERE
Comparison operators
AND / OR / NOT
IN
BETWEEN
LIKE
NULL
ORDER BY
TOP
Basic calculations
CASE
Basic date functions
Basic aggregates
GROUP BY
HAVING
Simple joins
```

At this level, most problems can be solved with one relatively direct query.

---

# Intermediate

Focuses on combining SQL features:

```text
Multi-table joins
Result grain
Conditional aggregation
LEFT JOIN
Customers/products with zero activity
Subqueries
EXISTS
NOT EXISTS
CTEs
Set operations
Order-level calculations
Business revenue
Customer metrics
Product metrics
Date analysis
Ranking
ROW_NUMBER
RANK
DENSE_RANK
LAG
Running totals
Top N per group
```

At this level, you should begin thinking in multiple logical stages.

---

# Advanced

Focuses on:

```text
Complex analytical pipelines
Multiple CTEs
Advanced window functions
RFM
Cohorts
Retention
Churn/inactivity
Funnels
Profitability
Revenue concentration
Customer segmentation
Market-basket analysis
Metric reconciliation
Transactions
Concurrency reasoning
Index design
SARGability
Execution plans
Performance analysis
Integrated business reports
```

Many advanced exercises have multiple valid implementations.

The supplied solution is one correct approach, not necessarily the only correct approach.

---

# Core Business Definitions

To keep exercises consistent, use these definitions unless an exercise explicitly overrides them.

---

# Revenue

```text
Revenue = Completed order-item value
```

Formula:

```sql
SUM
(
    oi.quantity * oi.unit_price
)
```

Filter:

```sql
o.order_status = 'Completed'
```

Use:

```text
order_items.unit_price
```

not:

```text
products.price
```

for historical transaction revenue.

---

# Units Sold

```sql
SUM(oi.quantity)
```

for Completed orders.

Do not use:

```sql
COUNT(*)
```

unless the metric actually asks for order-item lines.

---

# Completed Orders

A Completed order is:

```sql
order_status = 'Completed'
```

If the query has already joined to `order_items`, one order may appear more than once.

Use the correct grain.

For example:

```sql
COUNT(DISTINCT o.order_id)
```

when appropriate.

---

# Repeat Customer

A repeat customer has:

```text
At least 2 Completed orders
```

The definition is based on orders, not:

```text
order lines
units
products
```

---

# Average Order Value

```text
Completed Revenue
-----------------
Completed Orders
```

Example:

```sql
1.0 * completed_revenue
/ NULLIF(completed_orders, 0)
```

Do not accidentally calculate average line-item value.

---

# Estimated Profit

Estimated cost:

```sql
oi.quantity * p.cost
```

Estimated gross profit:

```sql
oi.quantity
* (oi.unit_price - p.cost)
```

Estimated gross margin:

```text
Estimated Gross Profit
----------------------
Revenue
```

---

# Historical Profit Caveat

The schema stores:

```text
transaction-time selling price
```

in:

```text
order_items.unit_price
```

but cost comes from:

```text
products.cost
```

which represents the current product cost.

Therefore historical profit calculations are:

```text
estimated
```

rather than exact historical accounting profit.

---

# Result Grain

Before solving any intermediate or advanced problem, answer:

> What does one output row represent?

Examples:

```text
one customer
one order
one product
one category
one month
one customer-month
one product-month
one cohort-age
```

This is one of the most important habits in SQL.

---

# One-to-Many Joins

Remember:

```text
customers
    1 -> many
orders

orders
    1 -> many
order_items
```

If one order contains three items, joining that order to `order_items` produces three rows.

This affects:

```text
COUNT
SUM
AVG
window calculations
result grain
```

---

# Zero-Activity Entities

If an exercise says:

```text
all customers
```

or:

```text
all products
```

you may need to preserve entities with no activity.

Common pattern:

```sql
LEFT JOIN
```

followed by:

```sql
COALESCE(metric, 0)
```

when zero is semantically appropriate.

---

# LEFT JOIN Warning

This can remove customers with no matching orders:

```sql
FROM training.customers AS c
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
```

The `WHERE` clause rejects NULL right-side rows.

Possible alternatives include:

```sql
LEFT JOIN training.orders AS o
    ON o.customer_id = c.customer_id
   AND o.order_status = 'Completed'
```

or pre-aggregating Completed data before the LEFT JOIN.

Choose based on the exact requirement.

---

# NULL

Remember:

```text
NULL != 0
NULL != ''
```

Test using:

```sql
IS NULL
```

and:

```sql
IS NOT NULL
```

Use:

```sql
COALESCE()
NULLIF()
CASE
```

where appropriate.

Do not replace NULL with zero automatically when NULL means "not applicable."

---

# Safe Division

Prefer:

```sql
100.0 * numerator
/ NULLIF(denominator, 0)
```

This protects against division by zero and forces decimal arithmetic.

---

# Date Filtering

Prefer half-open ranges:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20250201'
```

rather than:

```sql
WHERE YEAR(order_date) = 2025
  AND MONTH(order_date) = 1
```

when an index-friendly range is appropriate.

---

# Month Representation

For analytical month grouping:

```sql
DATEFROMPARTS
(
    YEAR(order_date),
    MONTH(order_date),
    1
)
```

This produces an actual month-start date such as:

```text
2025-01-01
```

which sorts chronologically.

---

# Deterministic Ranking

If you need exactly one latest order:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY
        order_date DESC,
        order_id DESC
)
```

The second column resolves ties.

Do not rely on unspecified row order.

---

# Top N Per Group

General pattern:

```text
Aggregate to correct grain
        |
        v
Apply window ranking
        |
        v
Filter rank <= N
```

Example:

```text
Top 3 products per category
```

requires ranking separately within each category.

---

# Growth

General formula:

```text
Current - Previous
------------------
Previous
```

In SQL:

```sql
100.0
* (current_value - previous_value)
/ NULLIF(previous_value, 0)
```

Use `LAG()` for previous-period metrics.

---

# Missing Period Warning

`LAG()` operates on existing rows.

If data contains:

```text
January
March
```

then March's previous row may be January.

That does not mean February existed with zero revenue.

Production calendar reporting may require an explicit calendar/date table or month series.

---

# RFM

Definitions:

```text
Recency:
days since latest Completed order

Frequency:
distinct Completed orders

Monetary:
Completed revenue
```

Reference date:

```text
one day after latest Completed order date
```

Do not use `GETDATE()` unless the business problem actually requires today's date.

---

# Cohorts

Customer cohort:

```text
month of first Completed order
```

Activity month:

```text
month with at least one Completed order
```

Cohort age:

```sql
DATEDIFF
(
    MONTH,
    cohort_month,
    activity_month
)
```

---

# Customer-Month Deduplication

For retention:

```text
five orders in one month
```

still represents:

```text
one active customer-month
```

Therefore activity data often begins with:

```sql
SELECT DISTINCT
    customer_id,
    activity_month
```

---

# Retention Definitions

Do not mix:

```text
Cohort retention

Consecutive-month retention

Returning customers

30-day inactivity
```

These answer different business questions.

---

# Right-Censoring

If the dataset ends in June:

```text
No July data
```

does not mean:

```text
June customer churned in July
```

The future outcome is unobserved.

---

# Transactions

Advanced exercises may use:

```sql
BEGIN TRANSACTION
COMMIT
ROLLBACK
```

Training modification exercises should usually end with:

```sql
ROLLBACK
```

so the dataset remains reusable.

---

# Recommended Transaction Error Pattern

```sql
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- changes

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

---

# Atomic Inventory Pattern

Prefer:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;
```

Then immediately check:

```sql
IF @@ROWCOUNT = 0
    THROW 50001, 'Insufficient inventory.', 1;
```

---

# Performance Exercises

For tuning exercises, remember:

```text
Correctness first
Measurement second
Change third
Measurement again
```

Useful tools:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

and the SQL Server Actual Execution Plan.

---

# Seek vs Scan

Never assume:

```text
Seek = good
Scan = bad
```

The important question is:

> How much work did SQL Server actually perform?

A five-row scan can be trivial.

A seek returning millions of rows can be expensive.

---

# SARGability

Prefer:

```sql
WHERE order_date >= '20250101'
  AND order_date <  '20260101'
```

over:

```sql
WHERE YEAR(order_date) = 2025
```

when the semantics allow the range form.

---

# Index Design

Consider:

```text
Filtering columns
Join columns
Equality predicates
Range predicates
Ordering
Included output columns
Selectivity
Existing indexes
Write cost
```

Do not create every index suggested by an execution plan automatically.

---

# Performance Baseline

Before changing a query/index, record:

```text
Query text
Parameters
Returned rows
Actual execution plan
Logical reads
CPU
Elapsed time
Existing relevant indexes
```

Without a baseline, improvement cannot be demonstrated reliably.

---

# Validation Techniques

Useful validation questions:

```text
Does final customer row count equal expected customer count?

Can funnel counts increase unexpectedly?

Did a join multiply orders?

Does transaction revenue equal sum of order-level revenue?

Does transaction revenue equal sum of customer-level revenue?

Are zero-activity entities still present where required?

Are latest-period retention values actually observable?
```

---

# Reconciliation

For the same qualifying Completed transactions:

```text
Direct Transaction Revenue
        =
Sum of Order Revenue
        =
Sum of Customer Revenue
        =
Sum of Product Revenue
```

Differences usually signal:

```text
join problems
filter differences
grain problems
duplicated rows
missing rows
```

---

# Difficulty Expectations

## Beginner

You should be able to solve most exercises with:

```text
one SELECT
one table or simple join
basic aggregation
simple conditions
```

Target:

```text
Correct syntax + clear fundamentals
```

---

# Intermediate

Expect:

```text
multiple joins
subqueries
CTEs
aggregation before joins
window functions
business definitions
zero-activity handling
```

Target:

```text
Correct result grain + combined SQL skills
```

---

# Advanced

Expect:

```text
multi-stage analytical pipelines
ambiguous business definitions
validation requirements
performance reasoning
transaction safety
```

Target:

```text
Production-style reasoning
```

---

# When Your Answer Differs From solutions.sql

A different query is not automatically wrong.

Ask:

```text
Does it return the same business result?

Does it preserve the intended grain?

Does it handle NULL correctly?

Does it include/exclude the same entities?

Does it use the same date boundaries?

Does it handle ties correctly?

Does it avoid duplicated metrics?
```

SQL frequently has multiple correct implementations.

---

# Do Not Memorize Query Shapes Blindly

Instead of memorizing:

```sql
WITH x AS (...)
SELECT ...
```

understand:

```text
Why did we need the CTE?

What was its grain?

What problem did it solve?

Could the same logic be written another way?
```

That knowledge transfers to new problems.

---

# Suggested Practice Schedule

A practical progression:

```text
Day 1:
Beginner exercises without solutions.

Day 2:
Review Beginner mistakes and repeat difficult ones.

Day 3:
Intermediate first half.

Day 4:
Intermediate second half.

Day 5:
Redo difficult Intermediate exercises from memory.

Day 6:
Advanced analytical exercises.

Day 7:
Transactions + performance exercises.

Later:
Randomly select problems across all difficulty levels.
```

Spaced repetition is more useful than reading every solution once.

---

# Timed Practice

After completing the repository once, retry common problems with time limits.

Examples:

```text
5 minutes:
basic aggregation

10 minutes:
multi-table customer metric

15 minutes:
Top N per group

20 minutes:
monthly growth query

30 minutes:
cohort retention

30 minutes:
transaction workflow

30 minutes:
performance diagnosis
```

The objective is not speed alone.

The objective is to make the reasoning process automatic.

---

# Interview Practice Mode

For interview preparation:

1. Read the exercise.
2. Explain your planned result grain out loud.
3. Explain which tables you need.
4. Explain potential row multiplication.
5. Write the query.
6. Explain edge cases.
7. Discuss possible performance considerations.

This mirrors real technical interviews better than silent memorization.

---

# Core Debugging Sequence

If your query is wrong:

```text
1. Remove aggregation.
2. Inspect raw joined rows.
3. Check join conditions.
4. Identify current grain.
5. Check filters.
6. Check NULLs.
7. Reintroduce aggregation.
8. Validate against a smaller known subset.
```

Do not immediately add `DISTINCT`.

---

# Avoid These Habits

Do not automatically:

```text
Use SELECT *

Add DISTINCT when duplicates appear

Turn every query into multiple CTEs

Use functions around indexed filter columns

Create an index for every WHERE column

Use NOLOCK to "solve" blocking

Use current products.price for historical revenue

Use GETDATE() for historical RFM

Count order-item rows as orders

Treat missing future periods as churn

Optimize before verifying correctness
```

---

# Progress Checklist

## Beginner

```text
[ ] SELECT
[ ] aliases
[ ] DISTINCT
[ ] filtering
[ ] logical operators
[ ] IN
[ ] BETWEEN
[ ] LIKE
[ ] NULL
[ ] sorting
[ ] TOP
[ ] calculations
[ ] CASE
[ ] dates
[ ] aggregates
[ ] GROUP BY
[ ] HAVING
[ ] basic joins
```

## Intermediate

```text
[ ] multi-table joins
[ ] result grain
[ ] conditional aggregation
[ ] LEFT JOIN behavior
[ ] zero-activity entities
[ ] subqueries
[ ] EXISTS
[ ] NOT EXISTS
[ ] CTEs
[ ] set operations
[ ] business revenue
[ ] order-level metrics
[ ] customer metrics
[ ] product metrics
[ ] ranking
[ ] LAG
[ ] running totals
[ ] Top N per group
```

## Advanced

```text
[ ] multi-stage CTE pipelines
[ ] RFM
[ ] cohorts
[ ] retention
[ ] churn definitions
[ ] right-censoring
[ ] funnels
[ ] segmentation
[ ] profitability
[ ] revenue concentration
[ ] market basket analysis
[ ] reconciliation
[ ] transactions
[ ] error handling
[ ] concurrency concepts
[ ] indexing
[ ] SARGability
[ ] execution plans
[ ] statistics
[ ] performance tuning
```

---

# Completion Standard

You have not fully mastered an exercise simply because your query executes.

A strong solution should be:

```text
Syntactically valid
+
Logically correct
+
At the correct grain
+
Consistent with business definitions
+
Robust around NULL/zero/ties
+
Readable
+
Validated
```

For performance-sensitive exercises, add:

```text
Measured
+
Compared
+
Workload-aware
```

---

# Final Practice Principle

When solving SQL, think in this order:

```text
Business Question
        |
        v
Definition
        |
        v
Result Grain
        |
        v
Source Tables
        |
        v
Relationships
        |
        v
Filters
        |
        v
Intermediate Grain
        |
        v
Aggregation
        |
        v
Analytical Logic
        |
        v
NULL / Dates / Ties
        |
        v
Validation
        |
        v
Performance
```

If that reasoning becomes habitual, unfamiliar SQL problems become much easier to break into manageable steps.