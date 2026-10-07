# Business SQL
# 09 - Business SQL

## Objective

Apply the SQL concepts from Chapters 01-08 to real business analysis.

Previous chapters focused primarily on SQL techniques.

This chapter focuses on a different question:

```text
How do we turn business questions into reliable metrics?
```

The goal is not simply to write valid SQL.

The goal is to produce analysis that is:

- Correct
- Explainable
- Reproducible
- Business-aware
- Resistant to double counting
- Clear about assumptions

---

# Prerequisites

This chapter combines concepts learned previously:

```text
SELECT
WHERE
GROUP BY
HAVING
JOIN
CASE
COALESCE
Date functions
Conditional aggregation
Subqueries
CTEs
EXISTS
Window functions
Ranking
LAG / LEAD
Running totals
Percentages
```

---

# Data Model

The core model is:

```text
customers
    1
    |
    +----< orders
              1
              |
              +----< order_items >----+
                                      |
                                      1
                                  products
```

---

# Core Tables

## customers

One row represents:

```text
one customer
```

Important columns:

```text
customer_id
customer_name
email
city
signup_date
is_active
```

---

## orders

One row represents:

```text
one order
```

Important columns:

```text
order_id
customer_id
order_date
order_status
```

Possible statuses:

```text
Pending
Completed
Cancelled
```

---

## order_items

One row represents:

```text
one product line inside one order
```

Important columns:

```text
order_item_id
order_id
product_id
quantity
unit_price
```

This table is critical for:

```text
Units
Revenue
Product analysis
Order value
```

---

## products

One row represents:

```text
one product
```

Important columns:

```text
product_id
product_name
category
price
cost
stock_quantity
is_active
```

---

# 1. Start with the Business Question

Do not start by writing SQL.

Start by defining the question.

Example:

```text
What is total revenue?
```

That sounds simple, but it raises important questions:

```text
Do Cancelled orders count?

Do Pending orders count?

Is revenue based on product.price
or order_items.unit_price?

Are we measuring gross booked value
or recognized Completed revenue?
```

The SQL depends on these definitions.

---

# 2. Metric Definition Comes Before SQL

For this chapter, unless explicitly stated otherwise:

```text
Revenue =
Completed order item value
```

Formula:

```text
quantity * unit_price
```

Therefore:

```sql
SUM(oi.quantity * oi.unit_price)
```

with:

```sql
WHERE o.order_status = 'Completed'
```

---

# 3. Why Use unit_price?

The products table contains:

```text
products.price
```

But order_items contains:

```text
order_items.unit_price
```

For transaction revenue, prefer:

```text
order_items.unit_price
```

because it represents the price associated with the transaction line.

A product's current catalog price may change over time.

---

# 4. Revenue Definition

Default chapter definition:

```text
Revenue =
SUM(quantity * unit_price)
for Completed orders
```

Example:

```sql
SELECT
    SUM(
        oi.quantity * oi.unit_price
    ) AS revenue
FROM training.orders AS o
JOIN training.order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed';
```

---

# 5. Order Value

For one order:

```text
Order Value =
SUM(quantity * unit_price)
```

at:

```text
order_id grain
```

Example:

```sql
SELECT
    order_id,
    SUM(quantity * unit_price) AS order_value
FROM training.order_items
GROUP BY order_id;
```

---

# 6. Units Sold

Default definition:

```text
Units Sold =
SUM(quantity)
for Completed orders
```

This is not:

```sql
COUNT(*)
```

because one line can contain multiple units.

---

# 7. Completed Orders

Default definition:

```text
Number of orders where:

order_status = 'Completed'
```

When joined to `order_items`, use:

```sql
COUNT(DISTINCT o.order_id)
```

because one order can appear on multiple item rows.

---

# 8. Customers

There are several possible customer metrics:

```text
Registered Customers
Purchasing Customers
Completed Customers
Active Customers
Repeat Customers
```

They do not mean the same thing.

Always name metrics clearly.

---

# 9. Registered Customers

Definition:

```text
Rows in training.customers
```

```sql
SELECT
    COUNT(*) AS registered_customers
FROM training.customers;
```

---

# 10. Purchasing Customers

Possible definition:

```text
Customers with at least one order
```

This includes orders regardless of status unless specified otherwise.

---

# 11. Completed Customers

Default definition:

```text
Distinct customers with at least one Completed order
```

Example:

```sql
SELECT
    COUNT(DISTINCT customer_id) AS completed_customers
FROM training.orders
WHERE order_status = 'Completed';
```

---

# 12. Average Order Value

A common metric:

```text
AOV
=
Completed Revenue
/
Number of Completed Orders
```

Do not calculate:

```text
AVG(order_item line value)
```

if the question asks for average order value.

The grain is different.

Correct thinking:

```text
First:
one row per order

Then:
average those order values
```

---

# 13. AOV Using Pre-Aggregation

```sql
;WITH CompletedOrderValues AS
(
    SELECT
        o.order_id,
        SUM(
            oi.quantity * oi.unit_price
        ) AS order_value

    FROM training.orders AS o

    JOIN training.order_items AS oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'Completed'

    GROUP BY o.order_id
)
SELECT
    AVG(order_value) AS average_order_value
FROM CompletedOrderValues;
```

---

# 14. Result Grain

Before calculating any metric ask:

```text
What does one row represent right now?
```

Possible grains:

```text
Customer
Order
Order item
Product
Month
Customer-month
Product-month
Cohort-month
```

Many analytical errors are grain errors rather than syntax errors.

---

# 15. Revenue Grain

When joining:

```text
orders
->
order_items
```

one result row usually represents:

```text
one order item
```

Therefore:

```sql
SUM(quantity * unit_price)
```

works naturally for revenue.

But:

```sql
COUNT(order_id)
```

can overcount orders.

Use:

```sql
COUNT(DISTINCT order_id)
```

when counting orders at order-item grain.

---

# 16. Customer Grain

When producing one customer row:

```text
Customer-level metrics
```

may include:

```text
First order date
Last order date
Order count
Completed order count
Units purchased
Revenue
Average order value
Recency
```

The query should ultimately return:

```text
one row per customer
```

---

# 17. Product Grain

Product performance typically uses:

```text
one row per product
```

Metrics may include:

```text
Units sold
Revenue
Order count
Customer count
Revenue share
Category rank
Estimated profit
```

---

# 18. Time Grain

Growth analysis requires a defined time grain.

Examples:

```text
Day
Week
Month
Quarter
Year
```

In this project, many examples use:

```text
month
```

represented as:

```text
first day of month
```

Example:

```sql
DATEFROMPARTS(
    YEAR(order_date),
    MONTH(order_date),
    1
)
```

---

# 19. Monthly Revenue

Definition:

```text
Completed revenue grouped by order month
```

This becomes the foundation for:

```text
Revenue trend
Month-over-month growth
Cumulative revenue
Best month
```

---

# 20. Growth

Absolute growth:

```text
Current Revenue - Previous Revenue
```

Growth percentage:

```text
(Current - Previous)
/
Previous
* 100
```

Use:

```sql
NULLIF(previous_revenue, 0)
```

to avoid division by zero.

---

# 21. LAG for Growth

A common pattern:

```sql
LAG(revenue) OVER
(
    ORDER BY order_month
)
```

Then calculate:

```text
Revenue change
Growth percentage
```

---

# 22. Missing Time Periods

An important limitation:

If there are no orders in a month, a simple:

```sql
GROUP BY order_month
```

does not automatically create a zero-revenue month.

For robust production time-series analysis, a calendar/date dimension is often used.

The training dataset is intentionally small, so this chapter focuses on the SQL analysis pattern.

---

# 23. Customer Analysis

Useful customer metrics include:

```text
Total customers
Customers with orders
Completed customers
Customers with no orders
First order date
Last order date
Completed order count
Revenue per customer
Revenue share
Customer rank
Repeat customers
```

---

# 24. Repeat Customer

A possible definition:

```text
Customer with at least 2 Completed orders
```

That definition must be explicit.

Another business could define repeat customer differently.

For this chapter:

```text
Repeat Customer =
2 or more Completed orders
```

unless another definition is stated.

---

# 25. New vs Repeat Orders

Using:

```sql
ROW_NUMBER() OVER
(
    PARTITION BY customer_id
    ORDER BY order_date, order_id
)
```

we can classify:

```text
order_number = 1
    First Order

order_number > 1
    Repeat Order
```

The status filter matters.

If analyzing Completed purchasing behavior, rank only Completed orders.

---

# 26. Product Analysis

Product analysis can answer:

```text
Which products sell the most units?

Which products generate the most revenue?

What is each product's revenue share?

Which products dominate each category?

Which products have never sold?

Which products have low stock?
```

---

# 27. Product Revenue

Default:

```text
Completed revenue generated by the product
```

Formula:

```text
SUM(quantity * unit_price)
```

grouped by:

```text
product_id
```

---

# 28. Product Revenue Share

Formula:

```text
Product Revenue
/
Total Revenue
* 100
```

Window function:

```sql
revenue * 100.0
/
NULLIF(
    SUM(revenue) OVER (),
    0
)
```

---

# 29. Category Revenue Share

A product's contribution to its category:

```text
Product Revenue
/
Category Revenue
* 100
```

Window:

```sql
SUM(revenue) OVER
(
    PARTITION BY category
)
```

---

# 30. Product Ranking

Examples:

```text
Overall revenue rank

Category revenue rank

Units rank
```

Use:

```text
ROW_NUMBER
RANK
DENSE_RANK
```

depending on tie behavior.

---

# 31. Profit Analysis

The products table contains:

```text
cost
```

A simplified estimated line profit can be:

```text
quantity * (unit_price - cost)
```

Then:

```text
Estimated Gross Profit =
SUM(quantity * (unit_price - cost))
```

---

# 32. Important Profit Assumption

The current schema stores:

```text
current product cost
```

not necessarily:

```text
historical cost at sale time
```

Therefore:

```text
Estimated Gross Profit
```

is more accurate terminology than pretending it is exact historical accounting profit.

A production transaction model may store cost at the time of sale.

---

# 33. Margin

A common margin formula:

```text
Profit
/
Revenue
* 100
```

Use:

```sql
profit * 100.0
/
NULLIF(revenue, 0)
```

Do not confuse:

```text
margin
```

with:

```text
markup
```

They use different denominators.

---

# 34. RFM Analysis

RFM stands for:

```text
Recency
Frequency
Monetary
```

It is a customer segmentation technique.

---

# 35. Recency

Recency asks:

```text
How long since the customer's most recent purchase?
```

Example:

```text
analysis date - last completed order date
```

Smaller recency is usually better.

---

# 36. Frequency

Frequency asks:

```text
How often did the customer purchase?
```

Possible definition:

```text
Number of Completed orders
```

Use:

```sql
COUNT(DISTINCT order_id)
```

when necessary.

---

# 37. Monetary

Monetary asks:

```text
How much revenue did the customer generate?
```

Default:

```text
Completed revenue
```

---

# 38. RFM Reference Date

For reproducible analysis, avoid blindly using:

```sql
GETDATE()
```

when the dataset is historical.

Instead choose an explicit analysis date or derive a stable date from the data.

Example idea:

```text
one day after maximum Completed order date
```

This makes results reproducible.

---

# 39. RFM Scoring

After calculating:

```text
Recency
Frequency
Monetary
```

customers can be scored or bucketed.

For example:

```text
1 to 5
```

using:

```sql
NTILE(5)
```

But direction matters:

```text
Recency:
lower days is better

Frequency:
higher is better

Monetary:
higher is better
```

---

# 40. RFM Segmentation

Possible segments:

```text
Champions
Loyal Customers
Potential Loyalists
At Risk
Lost
```

There is no universal segmentation rule.

A real company should define segments according to its customer lifecycle and business model.

---

# 41. Cohort Analysis

A cohort groups customers by a shared starting period.

Common ecommerce definition:

```text
Customer acquisition cohort =
month of first Completed order
```

Example:

```text
Customer A:
First purchase in January

Customer B:
First purchase in January

Both belong to:
January cohort
```

---

# 42. Cohort Month

Typical representation:

```text
2025-01-01
2025-02-01
2025-03-01
```

where the value represents the month, not a specific purchase day.

---

# 43. Activity Month

For each customer order:

```text
Activity Month =
month of that Completed order
```

Then compare:

```text
Activity Month
vs
Cohort Month
```

---

# 44. Cohort Age

Conceptually:

```text
Month 0
    Acquisition month

Month 1
    One month after acquisition

Month 2
    Two months after acquisition
```

SQL Server can use:

```sql
DATEDIFF(
    MONTH,
    cohort_month,
    activity_month
)
```

---

# 45. Cohort Retention

Retention asks:

```text
What percentage of the original cohort
returned in later periods?
```

Formula:

```text
Active Customers in Period
/
Cohort Size
* 100
```

---

# 46. Retention Requires Deduplication

If a customer places 3 orders in one month, they should normally count as:

```text
1 active customer
```

for monthly retention.

Therefore:

```sql
COUNT(DISTINCT customer_id)
```

or a deduplicated customer-month dataset is necessary.

---

# 47. Retention Analysis Grain

Useful intermediate grain:

```text
one row per customer per activity month
```

Then calculate:

```text
cohort
cohort age
active customers
retention rate
```

---

# 48. Churn

Churn has many possible definitions.

Examples:

```text
No purchase for 30 days

No purchase for 90 days

Did not return next month

Subscription cancelled

Account deactivated
```

There is no universal churn definition.

Always state it explicitly.

---

# 49. Retention vs Churn

In a simplified period-based model:

```text
Churn Rate
=
100% - Retention Rate
```

But real churn models may use different populations and definitions.

Do not assume every retention calculation directly implies a valid business churn metric.

---

# 50. Funnel Analysis

A funnel tracks entities through ordered business stages.

Example:

```text
Registered
    ->
Placed Order
    ->
Completed Order
    ->
Repeat Customer
```

---

# 51. Funnel Counts

Possible stages:

```text
Registered Customers

Customers with Any Order

Customers with Completed Order

Customers with 2+ Completed Orders
```

Each stage should generally be a subset of the previous stage if the funnel is meant to represent sequential progression.

---

# 52. Funnel Conversion

Example:

```text
Completed Conversion Rate
=
Customers with Completed Order
/
Registered Customers
* 100
```

Another:

```text
Repeat Conversion Rate
=
Repeat Customers
/
Completed Customers
* 100
```

The denominator must be clearly defined.

---

# 53. Funnel Integrity

A good funnel should satisfy:

```text
Stage 1 count
>= Stage 2 count
>= Stage 3 count
>= Stage 4 count
```

If that is not true, investigate:

```text
Stage definitions

Join duplication

Incorrect DISTINCT logic

Non-sequential stages
```

---

# 54. Data Validation

Business SQL is not complete when the query executes successfully.

Validate results.

Examples:

```text
Revenue should reconcile to detailed Completed lines.

Customer revenue should sum to total revenue.

Product revenue should sum to total revenue.

Monthly revenue should sum to total revenue.

Completed order count should match source orders.

Cohort Month 0 retention should normally be 100%.

Funnel stages should follow expected monotonic behavior.
```

---

# 55. Revenue Reconciliation

If total Completed revenue is:

```text
X
```

then ideally:

```text
SUM(customer revenue) = X

SUM(product revenue) = X

SUM(monthly revenue) = X
```

assuming all use the same metric definition and population.

This is a powerful validation technique.

---

# 56. Avoid Double Counting

Before using:

```sql
COUNT(*)
```

ask:

```text
What does one row represent after my JOIN?
```

After:

```text
orders
JOIN order_items
```

one order can appear multiple times.

Therefore:

```sql
COUNT(DISTINCT o.order_id)
```

may be required.

---

# 57. Missing Customers

An `INNER JOIN` from:

```text
customers
to
orders
```

removes customers with no orders.

Sometimes that is correct.

Sometimes the report needs:

```text
all customers
```

Then use:

```text
LEFT JOIN
```

and handle zero/NULL metrics correctly.

---

# 58. Missing Products

Similarly:

```text
products
INNER JOIN
order_items
```

removes unsold products.

For an inventory/opportunity report, use:

```text
LEFT JOIN
```

so unsold products remain.

---

# 59. Zero vs NULL

These meanings are different:

```text
0
    Known value of zero

NULL
    Unknown / absent / not applicable
```

For business reporting, sometimes:

```sql
COALESCE(metric, 0)
```

is appropriate.

But only when:

```text
no matching activity
```

really means:

```text
zero activity
```

---

# 60. Analysis Date

Metrics such as:

```text
Recency
Churn
Inactive days
```

depend on the reference date.

A professional report should make that date explicit.

Example:

```sql
DECLARE @analysis_date DATE = '2025-05-01';
```

or calculate it deterministically from the dataset.

---

# 61. Reproducibility

A query is reproducible when running it against the same data produces the same analytical definition.

Using:

```sql
GETDATE()
```

on historical training data changes results over time.

For exercises involving RFM/churn, prefer a defined reference date.

---

# 62. Business SQL Workflow

A useful workflow:

```text
1. Read the question.

2. Define the metric.

3. Define included/excluded populations.

4. Define time grain.

5. Define row grain.

6. Identify required tables.

7. Build small validation queries.

8. Build intermediate CTEs.

9. Calculate final metrics.

10. Validate totals.

11. Add rankings/percentages/segments.

12. Document assumptions.
```

---

# 63. SQL Is Not the First Step

Example question:

```text
Who are our best customers?
```

This is not yet a SQL question.

Define:

```text
Best by revenue?

Best by frequency?

Best by profit?

Best by recent activity?

Best by lifetime value?

Best by RFM score?
```

Only then choose SQL.

---

# 64. Metric Naming

Prefer explicit names:

```text
completed_revenue

completed_order_count

units_sold

customer_revenue_share

estimated_gross_profit

days_since_last_order
```

Avoid vague names such as:

```text
total
value
count
score
```

unless the context is unambiguous.

---

# 65. Avoid False Precision

If the data model does not support an exact metric, say so.

Example:

```text
Historical profit
```

cannot be guaranteed from current product cost if cost changes over time.

Therefore call the metric:

```text
estimated_gross_profit
```

and document the assumption.

---

# 66. Analysis Files

This chapter is divided by business domain.

```text
09_business_sql/
├── README.md
├── revenue_analysis.sql
├── customer_analysis.sql
├── product_analysis.sql
├── growth_analysis.sql
├── rfm_analysis.sql
├── cohort_analysis.sql
├── retention_churn.sql
├── funnel_analysis.sql
└── profit_analysis.sql
```

---

# 67. revenue_analysis.sql

Focus:

```text
Completed revenue

Order value

Average Order Value

Monthly revenue

Revenue contribution

Revenue reconciliation
```

---

# 68. customer_analysis.sql

Focus:

```text
Customer counts

Customers with / without orders

Customer revenue

Order frequency

Repeat customers

First / latest orders

Customer rankings

Revenue concentration
```

---

# 69. product_analysis.sql

Focus:

```text
Product revenue

Units sold

Product ranking

Category performance

Revenue share

Unsold products

Inventory-related signals
```

---

# 70. growth_analysis.sql

Focus:

```text
Monthly revenue

Month-over-month change

Growth percentage

Cumulative revenue

Customer growth

Order growth

New vs repeat behavior
```

---

# 71. rfm_analysis.sql

Focus:

```text
Recency

Frequency

Monetary

RFM scores

Customer segmentation
```

---

# 72. cohort_analysis.sql

Focus:

```text
First purchase month

Acquisition cohorts

Activity months

Cohort age

Retention matrix source data
```

---

# 73. retention_churn.sql

Focus:

```text
Retention

Repeat activity

Inactive customers

Churn assumptions

Retention and churn rates
```

---

# 74. funnel_analysis.sql

Focus:

```text
Registered customers

Customers with orders

Completed customers

Repeat customers

Stage conversion rates
```

---

# 75. profit_analysis.sql

Focus:

```text
Estimated gross profit

Product profitability

Category profitability

Customer profit contribution

Margin percentages
```

---

# 76. Validation Mindset

For every major metric, ask:

```text
Can I calculate the same total a second way?
```

Example:

Revenue by product:

```sql
SUM(product_revenue)
```

should reconcile with:

```text
overall Completed revenue
```

This helps catch:

```text
Missing joins

Duplicate joins

Incorrect status filters

Wrong grain
```

---

# 77. Small Dataset Warning

The training dataset is intentionally small.

That means some advanced outputs may contain:

```text
Very few cohorts

Sparse monthly trends

Empty funnel stages

Few RFM buckets

No examples of some edge cases
```

The purpose is to learn the analytical SQL pattern.

The larger ecommerce project later provides a better environment for realistic analysis.

---

# 78. Business Question Checklist

Before writing a query, answer:

```text
What is the metric?

What is the entity?

What is the grain?

What time period applies?

Which statuses count?

Which records are excluded?

What is the denominator?

How are NULLs treated?

Can JOINs duplicate entities?

What assumptions are being made?

How will I validate the output?
```

---

# Chapter Goal

By the end of `09_business_sql`, you should be able to move from:

```text
"Write a JOIN"
```

to:

```text
"Define and calculate a trustworthy business metric."
```

And from:

```text
"Use a window function"
```

to:

```text
"Use a window function because the business question
requires ranking, contribution, retention, or change
while preserving the correct analytical grain."
```

The most important skill in this chapter is not syntax.

It is translating:

```text
Business Question
        ↓
Metric Definition
        ↓
Population
        ↓
Grain
        ↓
SQL Logic
        ↓
Validation
        ↓
Business Interpretation
```