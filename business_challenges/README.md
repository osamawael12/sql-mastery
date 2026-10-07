# SQL Mastery — Business Challenges

## Overview

This section moves beyond isolated SQL syntax exercises.

The goal is to solve realistic business-analysis problems using the complete SQL toolkit developed throughout the repository.

You will combine concepts such as:

- Filtering
- Aggregation
- Joins
- CASE expressions
- Date calculations
- Subqueries
- CTEs
- Set operations
- Window functions
- Business metrics
- Revenue analysis
- Customer analysis
- Product analysis
- Growth analysis
- RFM segmentation
- Cohort analysis
- Retention and churn
- Funnel analysis
- Profit analysis
- Query-performance reasoning

The focus is no longer:

> Which SQL feature should I practice?

Instead, the focus is:

> What business question are we trying to answer, and how do we model that question correctly in SQL?

---

# Database

All challenges use:

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

# Core Data Model

The main relationships are:

```text
customers
    |
    | customer_id
    v
orders
    |
    | order_id
    v
order_items
    |
    | product_id
    v
products
```

Join keys:

```text
customers.customer_id = orders.customer_id

orders.order_id = order_items.order_id

products.product_id = order_items.product_id
```

---

# Important Business Definitions

The challenges use consistent definitions so that different analyses can be compared correctly.

## Revenue

Unless a challenge explicitly says otherwise:

```text
Revenue = Completed order-item value
```

Formula:

```sql
SUM(oi.quantity * oi.unit_price)
```

with:

```sql
o.order_status = 'Completed'
```

Use:

```text
order_items.unit_price
```

rather than:

```text
products.price
```

because `unit_price` represents the price stored on the transaction.

---

# Units Sold

Unless stated otherwise:

```text
Units Sold = SUM(order_items.quantity)
```

for:

```text
Completed orders
```

---

# Completed Orders

After joining orders to order items, one order can appear multiple times.

Therefore, when counting orders from a joined result, use the correct grain.

For example:

```sql
COUNT(DISTINCT o.order_id)
```

when necessary.

Do not accidentally count order lines as orders.

---

# Customer Grain

Many challenges require:

```text
One row per customer
```

Joining:

```text
customers
    ->
orders
    ->
order_items
```

creates a lower-grain intermediate dataset.

Always identify the intended final grain before calculating metrics.

---

# Product Grain

Product-analysis challenges often require:

```text
One row per product
```

Be careful to distinguish:

```text
units sold
```

from:

```text
number of order lines
```

For example:

```sql
SUM(quantity)
```

is not the same as:

```sql
COUNT(*)
```

---

# Profit Definitions

Estimated cost:

```sql
oi.quantity * p.cost
```

Estimated gross profit:

```sql
oi.quantity * (oi.unit_price - p.cost)
```

Gross margin percentage:

```text
Gross Profit / Revenue * 100
```

Use `NULLIF` when protecting against division by zero.

Example:

```sql
100.0 * gross_profit / NULLIF(revenue, 0)
```

---

# Profit Caveat

The current schema stores:

```text
products.cost
```

but does not store historical transaction-time cost on `order_items`.

Therefore:

```text
Historical revenue = transaction-based
```

but:

```text
Historical profit = estimated
```

because the analysis uses the product's current cost.

Do not present estimated historical gross profit as exact accounting profit.

---

# Repeat Customer

A repeat customer is defined as:

```text
A customer with at least 2 Completed orders
```

This definition is based on orders, not order items.

---

# Customer Cohort

A customer's cohort is:

```text
The month of their first Completed order
```

For example:

```text
2025-01-01
2025-02-01
2025-03-01
```

The cohort should generally be represented as a month-start date rather than only a month name.

---

# Activity Month

Activity month means:

```text
A month in which the customer had at least one Completed order
```

Customer-month activity should be deduplicated before retention calculations.

If a customer places five Completed orders in one month, that still represents:

```text
one active customer-month
```

---

# Cohort Age

Cohort age is:

```sql
DATEDIFF(MONTH, cohort_month, activity_month)
```

Meaning:

```text
0 = acquisition month
1 = following month
2 = two months later
...
```

---

# Retention

Retention can mean several different things.

These challenges distinguish between them explicitly.

## Cohort Retention

Measures whether members of an acquisition cohort are active at later cohort ages.

Typical formula:

```text
Active Customers at Cohort Age
--------------------------------
Original Cohort Size
```

---

# Consecutive-Month Retention

This asks a different question:

> Of customers active in one month, how many were also active in the next month?

This is not the same as cohort retention.

---

# Returning Customer

A returning customer generally means a customer who has activity after an earlier Completed order.

Again, this is not automatically the same as cohort retention or consecutive-month retention.

---

# Churn

Churn has no universal SQL definition.

A business must define it.

Possible definitions include:

```text
No purchase in the next month

No purchase for 30 days

No purchase for 90 days

No purchase before the end of the observed dataset
```

Every churn query should clearly state which definition it uses.

---

# Dataset Boundary and Right-Censoring

Suppose the latest available data is:

```text
June 2025
```

A customer active in June cannot be classified as:

```text
"not retained in July"
```

if July data does not exist.

This is a right-censoring problem.

Retention and churn analysis must distinguish:

```text
customer did not return
```

from:

```text
we do not yet have enough future data to know
```

---

# RFM Analysis

RFM stands for:

```text
Recency
Frequency
Monetary
```

Definitions used here:

## Recency

```text
Days since customer's latest Completed order
```

## Frequency

```text
Number of distinct Completed orders
```

## Monetary

```text
Completed revenue
```

---

# RFM Reference Date

Do not blindly use:

```sql
GETDATE()
```

against a historical training dataset.

Instead, use a deterministic reference date such as:

```text
One day after the latest Completed order date
```

Conceptually:

```sql
DATEADD
(
    DAY,
    1,
    MAX(order_date)
)
```

This makes the analysis reproducible.

---

# Funnel Definition

The default customer funnel is:

```text
1. Registered
2. Placed Any Order
3. Completed Customer
4. Repeat Customer
```

Therefore the expected counts are:

```text
Registered
    >=
Ordered
    >=
Completed
    >=
Repeat
```

If this condition fails, investigate the stage logic.

---

# Growth Analysis

Growth usually compares one period with the previous period.

Typical formula:

```text
(Current Revenue - Previous Revenue)
--------------------------------------
Previous Revenue
```

Use:

```sql
LAG()
```

to access the previous period.

Protect against division by zero:

```sql
NULLIF(previous_revenue, 0)
```

---

# Missing Months

An important analytical issue:

Suppose revenue exists in:

```text
January
March
```

but not February.

A simple `LAG()` over existing rows compares:

```text
March -> January
```

not:

```text
March -> February
```

For production-grade calendar analysis, a calendar/date table can be used to generate missing periods explicitly.

---

# Ranking

Ranking challenges may use:

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
```

Choose according to the business requirement.

Example:

If products tie on revenue, decide whether tied products should share the same rank.

---

# Top N Per Group

Typical pattern:

```text
1. Aggregate to required grain
2. Apply ranking window function
3. Filter rank <= N
```

For example:

```text
Top 3 products within each category
```

Do not use a global `TOP (3)` when the requirement is:

```text
Top 3 per category
```

---

# Pareto / Revenue Concentration

Some challenges investigate questions such as:

> What percentage of revenue comes from the highest-value customers?

Useful tools include:

```sql
SUM() OVER()
SUM() OVER(ORDER BY ...)
ROW_NUMBER()
NTILE()
```

Be explicit about whether ranking is based on:

```text
customers
revenue share
percentile
```

These are not always the same concept.

---

# Customer Lifetime Metrics

Customer-level analysis may include:

```text
First Completed Order
Latest Completed Order
Completed Orders
Completed Revenue
Average Order Value
Customer Lifespan
```

Average Order Value should generally be:

```text
Completed Revenue / Completed Orders
```

not:

```text
AVG(order-item line value)
```

unless that is explicitly the metric requested.

---

# Order Value

An order can contain multiple lines.

Therefore:

```text
Order Value
```

should first be calculated at:

```text
one row per order
```

using:

```sql
SUM(quantity * unit_price)
GROUP BY order_id
```

Only then should order-level statistics such as:

```text
average order value
largest order
order-value ranking
```

be calculated.

---

# Active vs Inactive Customers

Some challenges explicitly request:

```text
all customers
```

while others request:

```text
active customers only
```

Do not automatically add:

```sql
WHERE is_active = 1
```

unless the business requirement says so.

---

# Zero-Activity Entities

Some reports should include entities with no activity.

Examples:

```text
Customers with zero Completed orders
Products with zero sales
Categories with zero sales
```

This often requires:

```sql
LEFT JOIN
```

and careful placement of filters.

For example, filtering the right-side table in `WHERE` can accidentally turn a `LEFT JOIN` into effective inner-join behavior.

---

# ON vs WHERE

Consider:

```sql
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
```

The `WHERE` condition removes rows where `o` is NULL.

That can eliminate customers with no Completed orders.

When the business requirement is to retain every customer, the condition may belong in:

```sql
ON
```

or inside a pre-aggregated subquery/CTE.

Always reason from the desired result.

---

# NULL Handling

Business SQL frequently contains NULL.

Examples:

```text
Customer never ordered
Product never sold
No previous month
No future month
No revenue denominator
```

Useful tools:

```sql
COALESCE()
NULLIF()
CASE
```

Do not replace NULL blindly.

Sometimes NULL correctly means:

```text
unknown / not applicable
```

rather than zero.

---

# Challenge Difficulty

Challenges progress broadly from:

```text
Intermediate
    ->
Advanced
    ->
Business Analytics
    ->
Integrated Case Studies
```

Later problems intentionally combine multiple SQL concepts.

---

# Recommended Workflow

For each challenge:

1. Write the business definition in plain language.
2. Identify the final result grain.
3. Identify required tables.
4. Identify join relationships.
5. Decide which statuses qualify.
6. Build the lowest-level correct dataset.
7. Aggregate to the required grain.
8. Apply windows/ranking only after grain is correct.
9. Handle NULL and zero denominators.
10. Validate the result with sanity checks.
11. Only then think about performance.

---

# Validation

Do not trust a query merely because SQL Server executes it.

Ask:

```text
Can counts exceed their logical parent stage?

Can one order be counted multiple times?

Can one customer appear multiple times unexpectedly?

Can revenue be duplicated by a join?

Are customers with zero activity supposed to remain?

Can NULL change NOT IN behavior?

Does the date logic include the complete intended period?

Does the latest period have enough future data for churn analysis?
```

Business SQL requires validation, not only syntax correctness.

---

# Performance

Correctness comes first, but the later challenges should also encourage performance awareness.

Consider:

```text
SARGable predicates
Join columns
Existing indexes
Result grain
Unnecessary DISTINCT
Repeated calculations
Pre-aggregation
Logical reads
Execution plans
```

Do not add indexes simply because a query looks complicated.

Measure first.

---

# Files

This directory contains:

```text
business_challenges/
│
├── README.md
├── challenges.sql
└── solutions.sql
```

## challenges.sql

Contains the business problems without completed query solutions.

You should be able to attempt them independently.

## solutions.sql

Contains complete worked solutions with explanations and validation logic.

---

# Challenge Areas

The challenge set covers areas including:

```text
Revenue KPIs
Monthly revenue
Customer ranking
Repeat customers
Customer lifetime metrics
Product performance
Category performance
Profitability
Order value analysis
Growth rates
Running totals
Top N per group
Revenue concentration
RFM
Cohorts
Retention
Churn
Funnels
Inactive customers
Unsold products
Cross-sell analysis
Customer-product behavior
Integrated executive reporting
Performance reasoning
```

---

# What Makes These Challenges Different?

Earlier repository chapters focused mainly on SQL mechanics.

For example:

```text
Practice GROUP BY
Practice JOIN
Practice ROW_NUMBER
Practice CTE
```

Business challenges work in the opposite direction.

You receive a requirement such as:

> Find the top three products by Completed revenue inside each category.

You must decide:

```text
Which tables?

Which joins?

Which status?

What grain?

Which aggregation?

Which window function?

How should ties behave?

Should unsold products appear?
```

That reasoning is the real skill being practiced.

---

# Final Goal

After completing this section, you should be able to take a business question and transform it into:

```text
Business definition
        |
        v
Correct result grain
        |
        v
Required source data
        |
        v
Correct joins and filters
        |
        v
Aggregations
        |
        v
Analytical calculations
        |
        v
Validation
        |
        v
Performance review
```

The objective is not merely to know T-SQL syntax.

The objective is to reliably turn business requirements into correct, explainable, maintainable SQL.