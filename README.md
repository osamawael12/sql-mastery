# SQL Mastery — Microsoft SQL Server & T-SQL

A structured, hands-on SQL learning repository built around Microsoft SQL Server and T-SQL.

The repository progresses from relational database fundamentals to business analytics, transactions, indexing, execution plans, and query-performance tuning.

It combines:

- Theory
- Executable examples
- Exercises
- Complete solutions
- Business analysis
- Interview preparation
- Performance tuning
- 240 structured practice exercises

---

## Table of Contents

- [About the Repository](#about-the-repository)
- [Learning Goals](#learning-goals)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Learning Roadmap](#learning-roadmap)
- [Chapter Guide](#chapter-guide)
- [Business SQL](#business-sql)
- [Business Challenges](#business-challenges)
- [Practice Track](#practice-track)
- [Core Database Model](#core-database-model)
- [Business Metric Definitions](#business-metric-definitions)
- [Getting Started](#getting-started)
- [How to Study](#how-to-study)
- [SQL Problem-Solving Framework](#sql-problem-solving-framework)
- [Performance-Tuning Workflow](#performance-tuning-workflow)
- [Documentation](#documentation)
- [Official Learning Resources](#official-learning-resources)
- [Recommended Books](#recommended-books)
- [Articles and Deep Dives](#articles-and-deep-dives)
- [Practice Platforms](#practice-platforms)
- [Tools](#tools)
- [Interview Preparation](#interview-preparation)
- [Suggested Study Plan](#suggested-study-plan)
- [What to Learn Next](#what-to-learn-next)
- [Final Principles](#final-principles)

---

# About the Repository

`sql-mastery` is a progressive SQL curriculum centered on practical database work.

Instead of treating SQL as a collection of isolated commands, the repository emphasizes the complete reasoning process:

```text
Business Question
        |
        v
Data Model
        |
        v
Result Grain
        |
        v
Joins and Filters
        |
        v
Aggregation
        |
        v
Analytical Logic
        |
        v
Validation
        |
        v
Performance Analysis
```

The learning path begins with:

```sql
SELECT
FROM
WHERE
```

and progresses through:

```text
Aggregations
Joins
Data Transformation
Subqueries
CTEs
Set Operations
Window Functions
Business Analytics
Transactions
ACID
Concurrency
Indexes
Execution Plans
Query Optimization
```

---

# Learning Goals

After completing the repository, you should be able to:

- Design and understand relational database structures
- Query data confidently with T-SQL
- Filter, sort, transform, and aggregate data
- Work with NULL correctly
- Join multiple tables without accidentally duplicating metrics
- Understand result grain
- Use subqueries and CTEs
- Use set operations
- Use SQL window functions
- Build business KPIs
- Analyze customers, products, revenue, and growth
- Perform RFM analysis
- Build cohort and retention analysis
- Reason about churn definitions
- Build customer funnels
- Calculate estimated profitability
- Write safe database transactions
- Explain ACID
- Understand isolation levels
- Reason about blocking and deadlocks
- Design useful SQL Server indexes
- Read execution plans
- Measure logical reads and query time
- Recognize SARGability problems
- Tune queries using evidence rather than guesswork
- Validate and reconcile analytical results

---

# Technology Stack

This repository uses:

```text
Microsoft SQL Server
T-SQL
SQL Server Management Studio (SSMS)
Visual Studio Code
PowerShell
Git
GitHub
```

Primary database:

```text
SQLMastery
```

Primary schema:

```text
training
```

---

# Repository Structure

```text
sql-mastery/
│
├── 00_setup/
│
├── 01_database_fundamentals/
│
├── 02_select_and_filtering/
│
├── 03_aggregation/
│
├── 04_joins/
│
├── 05_data_transformation/
│
├── 06_subqueries_and_ctes/
│
├── 07_set_operations/
│
├── 08_window_functions/
│
├── 09_business_sql/
│
├── 10_transactions_and_acid/
│
├── 11_indexes_and_performance/
│
├── business_challenges/
│
├── docs/
│
├── exercises/
│
├── projects/
│   ├── ecommerce_analysis/
│   └── query_optimization/
│
└── README.md
```

Most learning chapters follow:

```text
README.md
examples.sql
exercises.sql
solutions.sql
```

This makes each chapter usable independently for:

```text
Learn
    ->
Observe
    ->
Practice
    ->
Review
```

---

# Learning Roadmap

The recommended progression is:

```text
00 Setup
    |
    v
01 Database Fundamentals
    |
    v
02 SELECT & Filtering
    |
    v
03 Aggregation
    |
    v
04 Joins
    |
    v
05 Data Transformation
    |
    v
06 Subqueries & CTEs
    |
    v
07 Set Operations
    |
    v
08 Window Functions
    |
    v
09 Business SQL
    |
    v
10 Transactions & ACID
    |
    v
11 Indexes & Performance
    |
    v
Business Challenges
    |
    v
Practice Track
    |
    v
Projects
```

---

# Chapter Guide

## 00 — Setup

Directory:

[`00_setup/`](./00_setup/)

Purpose:

- SQL Server environment preparation
- SQLMastery database setup
- Training schema
- Sample dataset

Start here before running the remaining chapters.

---

## 01 — Database Fundamentals

Directory:

[`01_database_fundamentals/`](./01_database_fundamentals/)

Topics include:

- Databases
- Schemas
- Tables
- Rows and columns
- Data types
- Primary keys
- Foreign keys
- Constraints
- Referential integrity
- Basic relational design

---

## 02 — SELECT and Filtering

Directory:

[`02_select_and_filtering/`](./02_select_and_filtering/)

Topics:

```text
SELECT
Aliases
DISTINCT
WHERE
AND
OR
NOT
IN
BETWEEN
LIKE
NULL
ORDER BY
TOP
Date filtering
```

Key goal:

> Learn to retrieve exactly the rows and columns required.

---

## 03 — Aggregation

Directory:

[`03_aggregation/`](./03_aggregation/)

Topics:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
COUNT(DISTINCT)
Conditional business aggregation
```

Important concept:

```text
COUNT(*)
!=
COUNT(column)
```

when NULL values exist.

---

## 04 — Joins

Directory:

[`04_joins/`](./04_joins/)

Topics:

```text
INNER JOIN
LEFT JOIN
RIGHT JOIN
FULL OUTER JOIN
CROSS JOIN
Multi-table joins
Row multiplication
Result grain
ON vs WHERE
```

A major lesson of this chapter is:

> Correct joins are about cardinality and grain, not just matching columns.

---

## 05 — Data Transformation

Directory:

[`05_data_transformation/`](./05_data_transformation/)

Topics:

```text
Calculated columns
CASE
COALESCE
ISNULL
NULLIF
CAST
CONVERT
TRY_CAST
TRY_CONVERT
String functions
Date functions
Conditional aggregation
Profit calculations
```

---

## 06 — Subqueries and CTEs

Directory:

[`06_subqueries_and_ctes/`](./06_subqueries_and_ctes/)

Topics:

```text
Scalar subqueries
IN
EXISTS
NOT EXISTS
Correlated subqueries
Derived tables
Common Table Expressions
Multiple CTEs
Analytical pipelines
```

Important lesson:

> A CTE improves query structure, but does not automatically materialize data or make a query faster.

---

## 07 — Set Operations

Directory:

[`07_set_operations/`](./07_set_operations/)

Topics:

```text
UNION
UNION ALL
INTERSECT
EXCEPT
Set-based segmentation
Vertical KPI reports
```

Remember:

```text
UNION     -> removes duplicates
UNION ALL -> preserves duplicates
```

---

## 08 — Window Functions

Directory:

[`08_window_functions/`](./08_window_functions/)

Topics:

```text
OVER
PARTITION BY
ROW_NUMBER
RANK
DENSE_RANK
NTILE
LAG
LEAD
FIRST_VALUE
LAST_VALUE
Running totals
Moving windows
Percent of total
Top N per group
```

Window functions are essential for analytical SQL.

---

## 09 — Business SQL

Directory:

[`09_business_sql/`](./09_business_sql/)

Business analysis modules include:

- Revenue analysis
- Customer analysis
- Product analysis
- Growth analysis
- RFM analysis
- Cohort analysis
- Retention and churn
- Funnel analysis
- Profit analysis

This chapter transforms SQL syntax into business reasoning.

---

## 10 — Transactions and ACID

Directory:

[`10_transactions_and_acid/`](./10_transactions_and_acid/)

Topics:

```text
BEGIN TRANSACTION
COMMIT
ROLLBACK
TRY/CATCH
THROW
XACT_STATE()
@@TRANCOUNT
@@ROWCOUNT
SCOPE_IDENTITY()
SAVE TRANSACTION
XACT_ABORT
ACID
Isolation levels
Blocking
Deadlocks
```

Robust transaction foundation:

```sql
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- database changes

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

---

## 11 — Indexes and Performance

Directory:

[`11_indexes_and_performance/`](./11_indexes_and_performance/)

Topics:

```text
Clustered indexes
Nonclustered indexes
Heaps
Index Seek
Index Scan
Composite indexes
INCLUDE
Covering indexes
Key Lookups
SARGability
Statistics
Execution plans
Logical reads
STATISTICS IO
STATISTICS TIME
Join algorithms
Memory grants
tempdb spills
Parameter sensitivity
Index maintenance
```

Core principle:

```text
Measure
    ->
Understand
    ->
Change
    ->
Measure Again
```

---

# Business SQL

The business SQL chapter includes focused analytical modules.

Directory:

[`09_business_sql/`](./09_business_sql/)

Files include:

```text
revenue_analysis.sql
customer_analysis.sql
product_analysis.sql
growth_analysis.sql
rfm_analysis.sql
cohort_analysis.sql
retention_churn.sql
funnel_analysis.sql
profit_analysis.sql
```

These scripts demonstrate how technical SQL concepts combine into business analysis.

---

# Business Challenges

Directory:

[`business_challenges/`](./business_challenges/)

Contains:

```text
README.md
challenges.sql
solutions.sql
```

The challenge set contains:

```text
80 business-oriented SQL challenges
```

Topics include:

- Revenue KPIs
- Customer lifetime metrics
- Repeat customers
- Product performance
- Category performance
- Growth
- Profitability
- Revenue concentration
- RFM
- Cohorts
- Retention
- Churn
- Funnels
- Market basket analysis
- Reconciliation
- Performance reasoning

The challenges begin with a business requirement rather than a SQL command.

---

# Practice Track

Directory:

[`exercises/`](./exercises/)

The structured practice track contains:

```text
240 exercises
```

divided into three levels.

## Beginner

[`exercises/beginner/`](./exercises/beginner/)

```text
80 exercises
+
80 worked solutions
```

Focus:

- SELECT
- Filtering
- Aggregation
- Basic joins
- CASE
- NULL handling
- Dates
- Introductory business metrics

## Intermediate

[`exercises/intermediate/`](./exercises/intermediate/)

```text
80 exercises
+
80 worked solutions
```

Focus:

- Multi-table queries
- Result grain
- Subqueries
- CTEs
- Set operations
- Window functions
- Customer/product analytics
- Ranking
- Growth
- Reconciliation

## Advanced

[`exercises/advanced/`](./exercises/advanced/)

```text
80 exercises
+
80 worked solutions
```

Focus:

- RFM
- Cohorts
- Retention
- Funnels
- Profitability
- Market basket analysis
- Transactions
- Concurrency
- Indexing
- Execution plans
- Performance tuning
- Integrated case studies

---

# Core Database Model

The repository uses a compact e-commerce-style schema.

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

Relationships:

```sql
customers.customer_id = orders.customer_id

orders.order_id = order_items.order_id

products.product_id = order_items.product_id
```

---

# Core Tables

## customers

Conceptual columns:

```text
customer_id
customer_name
email
city
signup_date
is_active
```

## products

```text
product_id
product_name
category
price
cost
stock_quantity
is_active
```

## orders

```text
order_id
customer_id
order_date
order_status
```

Statuses:

```text
Pending
Completed
Cancelled
```

## order_items

```text
order_item_id
order_id
product_id
quantity
unit_price
```

---

# Business Metric Definitions

Consistency matters in analytical SQL.

Unless a specific exercise says otherwise, the repository uses the following definitions.

## Revenue

```text
Completed Revenue =
SUM(quantity * unit_price)
```

where:

```sql
order_status = 'Completed'
```

Historical transaction revenue uses:

```text
order_items.unit_price
```

not:

```text
products.price
```

---

## Units Sold

```sql
SUM(order_items.quantity)
```

for Completed orders.

---

## Repeat Customer

```text
Customer with at least 2 Completed orders
```

---

## Average Order Value

```text
Completed Revenue
-----------------
Completed Orders
```

---

## Estimated Gross Profit

```text
quantity * (unit_price - current product cost)
```

Because historical transaction-time cost is not stored, historical profit is explicitly treated as estimated.

---

## RFM

```text
Recency:
Days since latest Completed order

Frequency:
Distinct Completed orders

Monetary:
Completed revenue
```

Reference date:

```text
One day after the latest Completed order
```

This makes historical analysis reproducible.

---

## Cohort

```text
Month of first Completed order
```

## Activity Month

```text
Month containing at least one Completed order
```

## Cohort Age

```sql
DATEDIFF
(
    MONTH,
    cohort_month,
    activity_month
)
```

---

# Getting Started

## 1. Install SQL Server

Microsoft SQL Server downloads:

https://www.microsoft.com/en-us/sql-server/sql-server-downloads

For learning locally, SQL Server Developer edition is usually the most useful free edition because it includes the full SQL Server feature set for non-production development/testing.

---

## 2. Install SQL Server Management Studio

SSMS:

https://learn.microsoft.com/en-us/ssms/install/install

---

## 3. Optional: Visual Studio Code

Download:

https://code.visualstudio.com/

Microsoft SQL development documentation:

https://learn.microsoft.com/en-us/sql/tools/visual-studio-code-extensions/mssql/mssql-extension-visual-studio-code

---

## 4. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/sql-mastery.git
```

Then:

```bash
cd sql-mastery
```

Replace `YOUR_USERNAME` with the actual GitHub username after publishing.

---

## 5. Build the Training Database

Start with:

[`00_setup/`](./00_setup/)

Then continue to:

[`01_database_fundamentals/`](./01_database_fundamentals/)

Before continuing, confirm the database contains:

```text
training.customers
training.products
training.orders
training.order_items
```

---

## 6. Verify the Database

```sql
USE SQLMastery;
GO

SELECT COUNT(*) AS customers
FROM training.customers;

SELECT COUNT(*) AS products
FROM training.products;

SELECT COUNT(*) AS orders
FROM training.orders;

SELECT COUNT(*) AS order_items
FROM training.order_items;
```

---

# How to Study

For each chapter:

## Step 1 — Read

Open:

```text
README.md
```

Understand the concept before copying syntax.

## Step 2 — Execute

Run:

```text
examples.sql
```

Execute examples section-by-section.

Inspect results.

## Step 3 — Practice

Open:

```text
exercises.sql
```

Try to solve exercises without looking at the solution.

## Step 4 — Compare

Open:

```text
solutions.sql
```

Do not only ask:

> Is my SQL text identical?

Ask:

```text
Does my query return the same business result?

Is the grain correct?

Are NULLs handled correctly?

Can joins multiply my metrics?

Is my date logic correct?

Are ties deterministic?
```

## Step 5 — Repeat

Re-solve difficult exercises later without looking at the answer.

---

# SQL Problem-Solving Framework

A useful process for almost every SQL problem:

```text
1. Define the business question.

2. Define what one output row represents.

3. Identify the required tables.

4. Identify relationships and join cardinality.

5. Decide which rows qualify.

6. Build the lowest-grain correct dataset.

7. Aggregate to the required grain.

8. Apply window/analytical calculations.

9. Handle NULL, zero denominators, dates, and ties.

10. Validate the result.

11. Reconcile important metrics.

12. Measure performance only when necessary.
```

One question prevents many SQL errors:

> What does one row represent at this point in the query?

---

# Performance-Tuning Workflow

Avoid:

```text
Slow query
    ->
Add random index
```

Use:

```text
Identify important query
        |
        v
Verify correctness
        |
        v
Capture baseline
        |
        v
Inspect Actual Execution Plan
        |
        v
Measure logical reads
        |
        v
Compare estimated vs actual rows
        |
        v
Find unnecessary work
        |
        v
Make one targeted change
        |
        v
Measure again
        |
        v
Evaluate broader workload impact
```

Useful SQL Server commands:

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

Performance tuning should be evidence-driven.

---

# Documentation

Directory:

[`docs/`](./docs/)

## Interview Questions

[`docs/interview_questions.md`](./docs/interview_questions.md)

Contains a large interview-review collection covering:

- SQL fundamentals
- Joins
- Aggregation
- CTEs
- Window functions
- Business SQL
- Transactions
- ACID
- Isolation
- Indexes
- Performance

## Learning Notes

[`docs/learning_notes.md`](./docs/learning_notes.md)

Condensed notes covering the entire repository.

## SQL Cheat Sheet

[`docs/sql_cheatsheet.md`](./docs/sql_cheatsheet.md)

Fast T-SQL syntax and concept reference.

---

# Official Learning Resources

Prefer official documentation when verifying SQL Server behavior.

## Microsoft Learn — SQL Documentation

https://learn.microsoft.com/en-us/sql/

Main SQL Server documentation hub.

---

## T-SQL Reference

https://learn.microsoft.com/en-us/sql/t-sql/language-reference

Reference for T-SQL syntax and language features.

---

## SELECT

https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql

---

## SELECT Logical Processing

https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql#logical-processing-order-of-the-select-statement

Useful for understanding why SQL clauses behave the way they do.

---

## FROM and JOIN

https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql

---

## GROUP BY

https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql

---

## HAVING

https://learn.microsoft.com/en-us/sql/t-sql/queries/select-having-transact-sql

---

## Common Table Expressions

https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql

---

## Set Operators

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/set-operators-union-transact-sql

---

## OVER Clause

https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql

---

## ROW_NUMBER

https://learn.microsoft.com/en-us/sql/t-sql/functions/row-number-transact-sql

---

## RANK

https://learn.microsoft.com/en-us/sql/t-sql/functions/rank-transact-sql

---

## DENSE_RANK

https://learn.microsoft.com/en-us/sql/t-sql/functions/dense-rank-transact-sql

---

## LAG

https://learn.microsoft.com/en-us/sql/t-sql/functions/lag-transact-sql

---

## LEAD

https://learn.microsoft.com/en-us/sql/t-sql/functions/lead-transact-sql

---

## Transactions

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/transactions-transact-sql

---

## BEGIN TRANSACTION

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/begin-transaction-transact-sql

---

## COMMIT

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/commit-transaction-transact-sql

---

## ROLLBACK

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/rollback-transaction-transact-sql

---

## TRY / CATCH

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql

---

## THROW

https://learn.microsoft.com/en-us/sql/t-sql/language-elements/throw-transact-sql

---

## XACT_STATE

https://learn.microsoft.com/en-us/sql/t-sql/functions/xact-state-transact-sql

---

## SET XACT_ABORT

https://learn.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql

---

## Transaction Locking and Row Versioning Guide

https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-transaction-locking-and-row-versioning-guide

Highly recommended for understanding:

```text
Isolation
Locks
Blocking
Row versioning
Concurrency
```

---

## Deadlocks

https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-deadlocks-guide

---

## SQL Server Index Architecture and Design Guide

https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide

Essential reading for SQL Server indexing.

---

## Clustered and Nonclustered Indexes

https://learn.microsoft.com/en-us/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described

---

## Included Columns

https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-indexes-with-included-columns

---

## Filtered Indexes

https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes

---

## Statistics

https://learn.microsoft.com/en-us/sql/relational-databases/statistics/statistics

---

## Execution Plans

https://learn.microsoft.com/en-us/sql/relational-databases/performance/execution-plans

---

## Display an Actual Execution Plan

https://learn.microsoft.com/en-us/sql/relational-databases/performance/display-an-actual-execution-plan

---

## Query Processing Architecture Guide

https://learn.microsoft.com/en-us/sql/relational-databases/query-processing-architecture-guide

Recommended after completing the performance chapter.

---

## SET STATISTICS IO

https://learn.microsoft.com/en-us/sql/t-sql/statements/set-statistics-io-transact-sql

---

## SET STATISTICS TIME

https://learn.microsoft.com/en-us/sql/t-sql/statements/set-statistics-time-transact-sql

---

# Recommended Books

Books are best used alongside hands-on SQL, not as replacements for practice.

## T-SQL Fundamentals — Itzik Ben-Gan

Publisher:

https://www.microsoftpressstore.com/

Search for:

```text
T-SQL Fundamentals
Itzik Ben-Gan
```

Excellent for:

```text
Relational thinking
SELECT
Joins
Grouping
Subqueries
CTEs
Set operations
Window functions
```

One of the strongest books for building a solid T-SQL foundation.

---

## T-SQL Querying — Itzik Ben-Gan et al.

Also available through Microsoft Press.

Useful after the fundamentals for deeper query reasoning and advanced T-SQL.

---

## SQL Server Execution Plans — Grant Fritchey

Publisher / author resources:

https://www.scarydba.com/

Useful for:

```text
Execution plans
Operators
Query optimization
SQL Server performance
```

---

## SQL Performance Explained — Markus Winand

Official site:

https://sql-performance-explained.com/

Useful for understanding:

```text
Indexes
Search predicates
Composite indexes
Sorting
Joins
Pagination
SQL performance fundamentals
```

The concepts apply broadly across relational database systems, though implementation details vary by engine.

---

## High Performance SQL Server

For deeper SQL Server performance study, also explore books and training from experienced SQL Server practitioners covering:

```text
Query optimization
Execution plans
Indexing
Statistics
Concurrency
Waits
SQL Server internals
```

Always verify version-specific behavior against current Microsoft documentation.

---

# Articles and Deep Dives

## Use The Index, Luke!

https://use-the-index-luke.com/

Excellent visual explanation of:

- B-tree indexes
- Composite indexes
- Range scans
- Sorting
- Pagination
- SQL indexing fundamentals

Database-independent concepts are especially useful.

---

## Brent Ozar

https://www.brentozar.com/

Large collection of practical SQL Server material covering:

```text
Indexes
Execution plans
Performance troubleshooting
SQL Server administration
Query tuning
```

Free learning resources:

https://www.brentozar.com/training/

---

## Erik Darling Data

https://erikdarling.com/

Advanced SQL Server performance material focused heavily on:

```text
Query tuning
Execution plans
Indexes
SQL Server optimizer behavior
```

Best approached after the fundamentals are strong.

---

## Paul White — SQL Server Performance

SQLPerformance:

https://sqlperformance.com/

Search author articles by Paul White for deep SQL Server query-optimizer and execution-engine material.

These articles can be highly technical and are best treated as advanced study.

---

## SQLskills

https://www.sqlskills.com/

Deep material covering:

```text
SQL Server internals
Indexes
Storage
Recovery
Transactions
Performance
Wait statistics
```

---

## Microsoft SQL Server Blog

https://www.microsoft.com/en-us/sql-server/blog/

Useful for product updates, new SQL Server capabilities, and engineering content.

---

# Practice Platforms

This repository is SQL Server/T-SQL focused, but external practice platforms can help develop general SQL problem-solving skills.

## LeetCode SQL

https://leetcode.com/problemset/database/

Useful for:

```text
Interview-style SQL
Joins
Aggregations
Subqueries
Window functions
```

---

## HackerRank SQL

https://www.hackerrank.com/domains/sql

Useful for progressive SQL exercises.

---

## DataLemur

https://datalemur.com/

Useful for analytics and data-interview-style SQL.

---

## StrataScratch

https://www.stratascratch.com/

Useful for:

```text
Data analyst SQL
Business questions
Interview problems
```

---

## SQLZoo

https://sqlzoo.net/

Useful for interactive SQL fundamentals.

---

## SQLBolt

https://sqlbolt.com/

Good for quick beginner-oriented interactive SQL lessons.

---

# Tools

## SQL Server Management Studio

https://learn.microsoft.com/en-us/ssms/

Primary GUI tool for SQL Server development and administration.

---

## Visual Studio Code

https://code.visualstudio.com/

Useful for repository-based SQL development.

---

## Microsoft SQL Extension for VS Code

https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql

---

## Git

https://git-scm.com/

Use Git to track changes and preserve your SQL learning history.

---

## GitHub

https://github.com/

Use GitHub to:

- Publish the repository
- Track progress
- Show projects
- Practice documentation
- Build a technical portfolio

---

# Interview Preparation

Recommended sequence:

```text
1. Review docs/sql_cheatsheet.md

2. Review docs/learning_notes.md

3. Work through docs/interview_questions.md

4. Re-solve random Beginner exercises.

5. Re-solve random Intermediate exercises.

6. Solve Advanced exercises without solutions.

7. Explain your queries verbally.

8. Practice performance-plan interpretation.
```

During interviews, explain your reasoning.

Instead of only writing:

```sql
COUNT(DISTINCT o.order_id)
```

explain:

> The join to order_items changes the intermediate result to line-item grain, so I need to protect the order-level count from row multiplication.

That demonstrates deeper SQL understanding than syntax alone.

---

# Suggested Study Plan

A possible 12-week path:

## Weeks 1–2

```text
Setup
Database fundamentals
SELECT
Filtering
```

## Weeks 3–4

```text
Aggregation
Joins
Data transformation
```

## Weeks 5–6

```text
Subqueries
CTEs
Set operations
```

## Weeks 7–8

```text
Window functions
Business SQL
```

## Weeks 9–10

```text
Transactions
ACID
Concurrency
Indexes
Performance
```

## Week 11

```text
Business Challenges
```

## Week 12

```text
Advanced Exercises
Interview Review
Projects
```

Adjust the pace based on experience.

---

# Alternative Intensive Plan

If studying full-time:

```text
Day 1-2:
Database fundamentals + SELECT

Day 3:
Aggregation

Day 4-5:
Joins

Day 6:
Transformation

Day 7-8:
Subqueries + CTEs

Day 9:
Set operations

Day 10-12:
Window functions

Day 13-15:
Business SQL

Day 16-17:
Transactions

Day 18-20:
Indexes + performance

Day 21+:
Exercises, challenges, projects, interviews
```

Do not rush window functions, grain, transactions, or performance.

---

# What to Learn Next

Completing this repository provides a strong SQL foundation, but SQL Server is much larger.

Recommended next topics:

## Stored Procedures

Learn:

```text
CREATE PROCEDURE
Parameters
Output parameters
Error handling
Transactions
Procedure design
```

Microsoft documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/stored-procedures/stored-procedures-database-engine

---

## Views

https://learn.microsoft.com/en-us/sql/relational-databases/views/views

Study:

```text
Views
Indexed views
Security implications
View design
```

---

## Functions

Study:

```text
Scalar functions
Inline table-valued functions
Multi-statement table-valued functions
Performance implications
```

Documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/user-defined-functions/user-defined-functions

---

## Temporary Tables

Learn:

```text
#temp tables
tempdb
Indexes on temp tables
Statistics
CTE vs temp table trade-offs
```

---

## Dynamic SQL

Study:

```text
sp_executesql
Parameters
SQL injection
Plan reuse
Dynamic search queries
```

Documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-executesql-transact-sql

---

## Query Store

SQL Server Query Store is important for production performance analysis.

Documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store

Learn:

```text
Query history
Plan history
Runtime statistics
Plan regression
Plan forcing
```

---

## Extended Events

Useful for deeper SQL Server diagnostics.

Documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/extended-events/extended-events

---

## Wait Statistics

For server-level performance troubleshooting, learn that a slow workload is not always an indexing problem.

Explore:

```text
CPU waits
I/O waits
Lock waits
Memory pressure
Parallelism
tempdb
```

---

## Database Design

Go deeper into:

```text
Normalization
1NF
2NF
3NF
BCNF
Surrogate vs natural keys
Constraints
Data modeling
OLTP vs analytical models
```

---

## Data Warehousing

After transactional SQL, study:

```text
Fact tables
Dimension tables
Star schemas
Slowly changing dimensions
Date dimensions
ETL / ELT
Columnstore indexes
```

---

## Columnstore Indexes

Important for analytical SQL Server workloads.

Microsoft documentation:

https://learn.microsoft.com/en-us/sql/relational-databases/indexes/columnstore-indexes-overview

---

# Portfolio Ideas

After finishing the repository, build larger datasets and projects.

Ideas:

## E-commerce Analytics

Analyze:

```text
Revenue
Orders
Customers
Products
Categories
Growth
Retention
RFM
Profit
Market basket
```

## Query Optimization Case Study

Create a large synthetic dataset and document:

```text
Initial query
Execution plan
Logical reads
Problem
Index/query change
New plan
New logical reads
Conclusion
```

This is far more valuable than simply saying:

> I know SQL performance tuning.

Show the evidence.

---

# GitHub Presentation

Before publishing, consider adding:

```text
Screenshots of execution plans

Example analytical output

A repository roadmap diagram

Project screenshots

Before/after performance measurements
```

Keep generated database files, secrets, and machine-specific configuration out of Git.

Example `.gitignore` topics:

```text
.vscode machine-specific files
database backup files
large generated datasets
credentials
logs
temporary output files
```

---

# Repository Quality Checklist

Before publishing:

```text
[ ] All SQL files execute against SQLMastery.

[ ] README links work.

[ ] Setup instructions are correct.

[ ] No credentials exist in Git history.

[ ] No unnecessary database backups are committed.

[ ] File encoding is UTF-8.

[ ] SQL comments render correctly.

[ ] examples.sql files are executable section by section.

[ ] transaction demos do not unintentionally modify training data.

[ ] experimental indexes are cleaned up.

[ ] Revenue definitions are consistent.

[ ] Solutions match exercises.

[ ] GitHub repository description is clear.
```

---

# Important SQL Principles

## Correctness Before Performance

Never optimize a query that you do not fully understand.

A query that executes in:

```text
10 ms
```

but returns incorrect revenue is worse than a correct query taking:

```text
100 ms
```

Correctness comes first.

Then measure.

Then optimize.

---

# Result Grain Before Aggregation

Before writing:

```sql
SUM(...)
COUNT(...)
AVG(...)
```

ask:

> What does each input row represent right now?

This prevents a large class of SQL analytics bugs.

---

# DISTINCT Is Not a Join Fix

If a join returns unexpected duplicates, do not immediately add:

```sql
DISTINCT
```

Investigate:

```text
join cardinality
missing join predicates
one-to-many relationships
intended result grain
```

---

# A CTE Is Not a Performance Feature

CTEs are excellent for readability and query organization.

They do not automatically:

```text
materialize data
reduce reads
improve execution speed
```

Measure the actual plan.

---

# Seek Is Not Always Good

An Index Seek returning millions of rows may still be expensive.

---

# Scan Is Not Always Bad

A table containing five rows can be scanned almost instantly.

The optimizer is solving a cost problem.

---

# More Indexes Are Not Always Better

Indexes improve some reads but increase:

```text
INSERT cost
UPDATE cost
DELETE cost
Storage
Memory pressure
Maintenance
Transaction logging
```

Index the workload, not every column.

---

# Transactions Should Be Short

Do not keep a database transaction open while waiting unnecessarily for:

```text
human input
external HTTP APIs
payment providers
long calculations
```

A short database transaction and a long-running business workflow are different concepts.

---

# Missing Data Is Not Always Zero

Examples:

```text
No previous month
No completed order
No future retention period
Unknown city
No applicable margin
```

Sometimes NULL is the correct answer.

---

# Validate Analytics

Do not trust a query only because SQL Server executed it.

Use checks such as:

```text
Registered >= Ordered >= Completed >= Repeat

Transaction Revenue = Sum(Order Revenue)

Transaction Revenue = Sum(Customer Revenue)

Transaction Revenue = Sum(Product Revenue)

Final Customer Report Rows = Registered Customers
```

---

# Final Principles

The repository can be summarized with these rules:

```text
1. Understand the business question.

2. Define result grain.

3. Understand table relationships.

4. Expect one-to-many joins to multiply rows.

5. Use transaction-time values for historical metrics.

6. Treat NULL deliberately.

7. Use deterministic ordering when selecting one row.

8. Validate important metrics independently.

9. Keep transactions short and atomic.

10. Design indexes around real access patterns.

11. Read execution plans instead of guessing.

12. Measure before and after optimization.

13. Optimize workloads, not syntax aesthetics.

14. Correctness comes before speed.

15. Keep learning by solving increasingly ambiguous problems.
```

---

# Final Learning Loop

```text
Learn
    |
    v
Write SQL
    |
    v
Run
    |
    v
Inspect
    |
    v
Validate
    |
    v
Break It
    |
    v
Fix It
    |
    v
Measure
    |
    v
Optimize
    |
    v
Explain It
    |
    v
Repeat
```

That is SQL mastery.