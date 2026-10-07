# 07 - Set Operations

## Objective

Learn how to combine and compare the results of multiple SELECT queries using SQL set operations.

This chapter covers:

- UNION
- UNION ALL
- INTERSECT
- EXCEPT
- Duplicate handling
- Column compatibility
- Data type compatibility
- NULL behavior
- ORDER BY with set operations
- Set operations vs JOINs
- Combining historical or segmented datasets
- Comparing customer and product populations
- Business analysis with sets

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

# 1. What Is a Set Operation?

Set operations combine or compare the result sets produced by multiple `SELECT` statements.

Example:

```sql
SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

Each `SELECT` produces a set of rows.

The set operator determines how those results are combined.

---

# 2. Main Set Operators

The main SQL Server set operators are:

```text
UNION

UNION ALL

INTERSECT

EXCEPT
```

Conceptually:

```text
UNION
    Rows from A or B
    Remove duplicates

UNION ALL
    Rows from A plus B
    Keep duplicates

INTERSECT
    Rows that appear in both A and B

EXCEPT
    Rows in A that do not appear in B
```

---

# 3. Set Operations vs JOINs

This distinction is important.

A JOIN normally combines tables horizontally.

Example:

```text
customers
+
orders

->
customer_name | order_id | order_date
```

A set operation combines compatible query results vertically.

Example:

```text
Query A rows
+
Query B rows

->
one combined list of rows
```

Think:

```text
JOIN
    Add columns using relationships

SET OPERATION
    Combine or compare rows from query results
```

---

# 4. UNION

`UNION` combines results and removes duplicate rows.

Example:

```sql
SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

If the same customer appears in both queries, the final output contains that customer only once.

---

# 5. UNION Removes Duplicates

Suppose Query A returns:

```text
1
2
3
```

and Query B returns:

```text
2
3
4
```

`UNION` returns:

```text
1
2
3
4
```

Duplicate rows are eliminated from the combined result.

---

# 6. UNION ALL

`UNION ALL` combines results without removing duplicates.

Example:

```sql
SELECT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

If customer 1 appears twice in the source results, those occurrences remain.

---

# 7. UNION ALL Keeps Duplicates

Suppose Query A returns:

```text
1
2
3
```

Query B returns:

```text
2
3
4
```

`UNION ALL` returns:

```text
1
2
3
2
3
4
```

Nothing is deduplicated.

---

# 8. UNION vs UNION ALL

Use:

```text
UNION
```

when your business requirement needs a distinct combined result.

Use:

```text
UNION ALL
```

when duplicate rows are meaningful or when you simply need to append result sets.

Example:

```text
"Which unique customers appear in either group?"

UNION
```

versus:

```text
"Append all event rows from both sources."

UNION ALL
```

---

# 9. Performance Consideration

`UNION` must eliminate duplicate rows.

That can require additional work compared with:

```text
UNION ALL
```

Do not use `UNION` automatically.

Choose based on the required result.

If duplicates do not need to be removed:

```text
UNION ALL
```

often expresses the requirement more accurately and may avoid unnecessary deduplication work.

---

# 10. Column Count Must Match

Each SELECT in a set operation must return the same number of columns.

Valid:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION

SELECT
    product_id,
    product_name
FROM training.products;
```

Both queries return:

```text
2 columns
```

Invalid:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION

SELECT
    product_id
FROM training.products;
```

The column counts do not match.

---

# 11. Column Positions Matter

Set operations match columns by position, not by name.

Example:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name
FROM training.products;
```

SQL aligns:

```text
customer_id   <-> product_id

customer_name <-> product_name
```

The original column names do not determine the matching.

---

# 12. Compatible Data Types

Corresponding columns must have compatible data types.

Example:

```text
INT
with
INT

NVARCHAR
with
NVARCHAR
```

is straightforward.

SQL Server can perform implicit conversion in some cases, using data type precedence.

However, relying on surprising implicit conversions can cause:

```text
Errors
Loss of precision
Unexpected output
Hard-to-maintain queries
```

Use `CAST` when needed.

---

# 13. Explicit Type Alignment

Example:

```sql
SELECT
    CAST(customer_id AS VARCHAR(20)) AS entity_id,
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    CAST(product_id AS VARCHAR(20)),
    product_name
FROM training.products;
```

Explicit conversion can make the intended output schema clearer.

---

# 14. Output Column Names

The final column names normally come from the first SELECT.

Example:

```sql
SELECT
    customer_id AS entity_id,
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name
FROM training.products;
```

Final names:

```text
entity_id
entity_name
```

not:

```text
product_id
product_name
```

---

# 15. Adding a Source Column

When combining different populations, add a label identifying the source.

Example:

```sql
SELECT
    customer_id AS entity_id,
    customer_name AS entity_name,
    'Customer' AS entity_type
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name,
    'Product'
FROM training.products;
```

Result conceptually:

```text
1 | Ahmed Ali | Customer
1 | Laptop    | Product
```

This is a useful reporting pattern.

---

# 16. UNION Example - Customer Groups

Find unique customers who have either:

```text
Completed orders

or

Cancelled orders
```

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

---

# 17. UNION ALL Example - Order Events

Suppose we want to append:

```text
Completed order events
Cancelled order events
```

while preserving every matching row:

```sql
SELECT
    order_id,
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    order_id,
    customer_id,
    order_status
FROM training.orders
WHERE order_status = 'Cancelled';
```

---

# 18. INTERSECT

`INTERSECT` returns rows that appear in both query results.

Example:

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

This answers:

```text
Which customer IDs appear in both groups?
```

In other words:

```text
Customers with a Completed order
AND
Customers with a Cancelled order
```

---

# 19. INTERSECT Removes Duplicates

Like `UNION`, `INTERSECT` returns distinct rows.

If the same value occurs many times in both source queries, the final intersection contains one copy of that row.

---

# 20. EXCEPT

`EXCEPT` returns distinct rows from the first query that do not appear in the second query.

Example:

```sql
SELECT
    customer_id
FROM training.customers

EXCEPT

SELECT
    customer_id
FROM training.orders;
```

This answers:

```text
Which customer IDs exist in customers
but do not appear in orders?
```

In the current data model:

```text
Customers without orders
```

---

# 21. EXCEPT Direction Matters

These are not equivalent:

```text
A EXCEPT B
```

and:

```text
B EXCEPT A
```

Example:

```sql
SELECT customer_id
FROM training.customers

EXCEPT

SELECT customer_id
FROM training.orders;
```

means:

```text
Customers not represented in orders
```

Reversing it:

```sql
SELECT customer_id
FROM training.orders

EXCEPT

SELECT customer_id
FROM training.customers;
```

means:

```text
Order customer IDs that do not exist in customers
```

With the Foreign Key constraint, that second result should normally be empty.

---

# 22. Set Operators and Duplicates

Summary:

```text
UNION
    DISTINCT combined rows

UNION ALL
    ALL combined rows

INTERSECT
    DISTINCT shared rows

EXCEPT
    DISTINCT first-only rows
```

The complete row matters when multiple columns are selected.

---

# 23. Duplicate Means Entire Row

Suppose:

```text
1 | Completed
1 | Cancelled
```

These are not duplicate rows because the second column differs.

For duplicate elimination, SQL compares all selected columns.

Example:

```sql
SELECT
    customer_id,
    order_status
FROM training.orders
...
```

The row is considered by the full selected combination:

```text
customer_id + order_status
```

---

# 24. NULL and Set Operations

Set operations have duplicate-comparison behavior that differs from normal equality predicates.

For duplicate elimination in operations such as:

```text
UNION
INTERSECT
EXCEPT
```

rows containing NULLs can be treated as duplicates when corresponding values are both NULL.

This means set operators can compare result rows for distinctness in ways that should not be confused with:

```sql
NULL = NULL
```

which is not TRUE in a normal `WHERE` comparison.

---

# 25. ORDER BY

Normally place `ORDER BY` at the end of the complete set operation.

Example:

```sql
SELECT
    customer_id AS entity_id,
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name
FROM training.products

ORDER BY entity_name;
```

The ordering applies to the final combined result.

---

# 26. ORDER BY Uses Final Output

Because the first SELECT defines final output names, use those names when possible.

Example:

```sql
SELECT
    customer_id AS entity_id,
    customer_name AS entity_name
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name
FROM training.products

ORDER BY entity_name;
```

---

# 27. Set Operations with CTEs

CTEs make more advanced set logic easier to read.

Example:

```sql
;WITH CompletedCustomers AS
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT customer_id
FROM CompletedCustomers

INTERSECT

SELECT customer_id
FROM CancelledCustomers;
```

---

# 28. Customers with Completed but No Cancelled Orders

Using `EXCEPT`:

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

EXCEPT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

Meaning:

```text
Completed customer IDs
minus
Cancelled customer IDs
```

---

# 29. Customers in Both Groups

Using `INTERSECT`:

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

Meaning:

```text
Completed customers
AND
Cancelled customers
```

---

# 30. Set Operation Followed by JOIN

Sometimes the set operation determines IDs first.

Then a JOIN retrieves descriptive information.

Example:

```sql
;WITH TargetCustomers AS
(
    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Completed'

    EXCEPT

    SELECT
        customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM TargetCustomers AS tc
JOIN training.customers AS c
    ON tc.customer_id = c.customer_id;
```

This separates:

```text
Set logic

from

Descriptive enrichment
```

---

# 31. Set Operation vs EXISTS

This:

```sql
SELECT customer_id
FROM training.customers

EXCEPT

SELECT customer_id
FROM training.orders;
```

and:

```sql
SELECT
    c.customer_id
FROM training.customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM training.orders AS o
    WHERE o.customer_id = c.customer_id
);
```

can answer the same business question:

```text
Customers without orders
```

But they express the logic differently.

---

# 32. Set Operation vs Conditional Logic

Question:

```text
Which customers have Completed orders but no Cancelled orders?
```

Possible approaches include:

```text
EXCEPT

EXISTS + NOT EXISTS

Conditional aggregation
```

Learning multiple approaches helps you choose the clearest structure for a particular query.

---

# 33. Combining Entity Lists

Set operations do not require queries to use the same source table.

Example:

```sql
SELECT
    customer_name AS name,
    'Customer' AS source_type
FROM training.customers

UNION ALL

SELECT
    product_name,
    'Product'
FROM training.products;
```

The result combines two different entity lists into one compatible output schema.

---

# 34. Standardizing Different Sources

Imagine two source tables representing similar data:

```text
current_orders
archived_orders
```

A common pattern would be:

```sql
SELECT
    order_id,
    customer_id,
    order_date
FROM current_orders

UNION ALL

SELECT
    order_id,
    customer_id,
    order_date
FROM archived_orders;
```

This is a common real-world use of `UNION ALL`.

The current training database does not have an archive table, but the pattern is important.

---

# 35. Set Operations and Calculated Columns

Each query can transform its output before combining.

Example:

```sql
SELECT
    customer_id AS entity_id,
    customer_name AS entity_name,
    COALESCE(city, N'Unknown') AS detail
FROM training.customers

UNION ALL

SELECT
    product_id,
    product_name,
    category
FROM training.products;
```

The corresponding columns form a single output schema.

---

# 36. Aggregation Before Set Operations

Each side can contain aggregation.

Example:

```sql
SELECT
    'Completed' AS metric,
    COUNT(*) AS metric_value
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT
    'Cancelled',
    COUNT(*)
FROM training.orders
WHERE order_status = 'Cancelled';
```

Result:

```text
Completed | 4
Cancelled | 1
```

This creates a vertical metric report.

---

# 37. Vertical Metric Reports

Conditional aggregation might create:

```text
completed_orders | cancelled_orders
4                | 1
```

`UNION ALL` can create:

```text
metric            | value
Completed Orders  | 4
Cancelled Orders  | 1
```

Both structures are useful.

The desired report shape determines the approach.

---

# 38. Combining Multiple Metrics

Example:

```sql
SELECT
    'Customers' AS metric,
    COUNT(*) AS metric_value
FROM training.customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM training.products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM training.orders

UNION ALL

SELECT
    'Order Items',
    COUNT(*)
FROM training.order_items;
```

This produces a compact system summary.

---

# 39. Mixing COUNT Types

Be clear about what each metric represents.

Example:

```sql
SELECT
    'Orders' AS metric,
    COUNT(*) AS metric_value
FROM training.orders

UNION ALL

SELECT
    'Units Ordered',
    SUM(quantity)
FROM training.order_items;
```

Both produce a numeric metric, but:

```text
Orders
```

counts rows.

```text
Units Ordered
```

sums quantities.

The shared output type does not imply shared business meaning.

---

# 40. Business Set Thinking

For a set problem, identify:

```text
Set A

Set B

Desired relationship
```

Example:

```text
A:
Customers with Completed orders

B:
Customers with Cancelled orders

Question:
Customers in A but not B
```

Operator:

```text
EXCEPT
```

Another question:

```text
Customers in both A and B
```

Operator:

```text
INTERSECT
```

Another:

```text
Unique customers appearing in either A or B
```

Operator:

```text
UNION
```

Another:

```text
Append all rows from A and B
```

Operator:

```text
UNION ALL
```

---

# 41. Venn Diagram Mental Model

Think conceptually:

```text
A UNION B

Everything in A or B


A INTERSECT B

Only the overlap


A EXCEPT B

Only the part unique to A
```

`UNION ALL` is different because it appends rows rather than creating a distinct mathematical set.

---

# 42. UNION Is Not a Substitute for JOIN

Incorrect mental model:

```text
"I have two tables, so I should UNION them."
```

Ask instead:

```text
Do I need to add columns based on a relationship?

-> JOIN


Do I need to append compatible rows?

-> UNION / UNION ALL


Do I need the overlap between two result sets?

-> INTERSECT


Do I need rows from A that are absent from B?

-> EXCEPT
```

---

# 43. Example - JOIN

Question:

```text
Show each order with customer_name.
```

Need:

```text
Columns from two related tables.
```

Use:

```sql
SELECT
    o.order_id,
    c.customer_name
FROM training.orders AS o
JOIN training.customers AS c
    ON o.customer_id = c.customer_id;
```

Not UNION.

---

# 44. Example - UNION

Question:

```text
Create one list containing customer names
and product names.
```

Need:

```text
Append rows with a compatible shape.
```

Use:

```sql
SELECT
    customer_name AS name
FROM training.customers

UNION

SELECT
    product_name
FROM training.products;
```

---

# 45. Example - INTERSECT

Question:

```text
Which customers have both Completed
and Cancelled orders?
```

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

INTERSECT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

---

# 46. Example - EXCEPT

Question:

```text
Which customers have Completed orders
but no Cancelled orders?
```

```sql
SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Completed'

EXCEPT

SELECT
    customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

---

# 47. EXCEPT for Unsold Products

```sql
SELECT
    product_id
FROM training.products

EXCEPT

SELECT
    product_id
FROM training.order_items;
```

This returns product IDs that have never appeared in order items.

---

# 48. INTERSECT for Product Groups

Question:

```text
Which products appear in both Completed
and Cancelled orders?
```

```sql
SELECT
    oi.product_id
FROM training.order_items AS oi
JOIN training.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'

INTERSECT

SELECT
    oi.product_id
FROM training.order_items AS oi
JOIN training.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';
```

---

# 49. EXCEPT for Product Groups

Question:

```text
Which products appear in Completed orders
but never in Cancelled orders?
```

```sql
SELECT
    oi.product_id
FROM training.order_items AS oi
JOIN training.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'

EXCEPT

SELECT
    oi.product_id
FROM training.order_items AS oi
JOIN training.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Cancelled';
```

---

# 50. Enriching Product Set Results

Use a CTE:

```sql
;WITH TargetProducts AS
(
    SELECT
        oi.product_id
    FROM training.order_items AS oi
    JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'

    EXCEPT

    SELECT
        oi.product_id
    FROM training.order_items AS oi
    JOIN training.orders AS o
        ON oi.order_id = o.order_id
    WHERE o.order_status = 'Cancelled'
)
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM TargetProducts AS tp
JOIN training.products AS p
    ON tp.product_id = p.product_id;
```

This pattern is useful when:

```text
Set operation selects entities

JOIN adds descriptive attributes
```

---

# 51. Parentheses and Complex Set Logic

When combining multiple set operators, make the intended logic explicit and avoid relying on memory of operator precedence.

Complex set logic should be written for clarity.

When necessary, use:

```text
CTEs
Derived tables
Parenthesized query expressions where supported
```

A CTE often makes business set logic easiest to understand.

---

# 52. Prefer Named Sets for Complex Logic

Instead of mentally parsing a long chain, define sets:

```sql
;WITH CompletedCustomers AS
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Completed'
),
CancelledCustomers AS
(
    SELECT customer_id
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT customer_id
FROM CompletedCustomers

EXCEPT

SELECT customer_id
FROM CancelledCustomers;
```

The query reads almost like the business requirement.

---

# 53. Set Operations Inside a CTE

A CTE itself can contain a set operation.

Example:

```sql
;WITH CustomerEntities AS
(
    SELECT
        customer_id AS entity_id,
        customer_name AS entity_name
    FROM training.customers

    UNION ALL

    SELECT
        product_id,
        product_name
    FROM training.products
)
SELECT *
FROM CustomerEntities;
```

---

# 54. Set Results Can Be Aggregated

Example:

```sql
;WITH CombinedEntities AS
(
    SELECT
        'Customer' AS entity_type
    FROM training.customers

    UNION ALL

    SELECT
        'Product'
    FROM training.products
)
SELECT
    entity_type,
    COUNT(*) AS entity_count
FROM CombinedEntities
GROUP BY entity_type;
```

A set operation can be one stage in a larger analytical query.

---

# 55. DISTINCT Before UNION?

Consider:

```sql
SELECT DISTINCT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION

SELECT DISTINCT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

Because `UNION` already deduplicates the final combined result, the inner `DISTINCT`s may be unnecessary for correctness.

Do not add `DISTINCT` everywhere automatically.

Understand where deduplication is actually required.

---

# 56. DISTINCT with UNION ALL

With `UNION ALL`, source-level `DISTINCT` can change the result.

Example:

```sql
SELECT DISTINCT customer_id
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT DISTINCT customer_id
FROM training.orders
WHERE order_status = 'Cancelled';
```

This means:

```text
Unique customers inside each source group

then append the groups

while preserving overlap between the two groups
```

A customer appearing in both groups can still appear twice in the final output.

---

# 57. Labeling Group Membership

Example:

```sql
SELECT DISTINCT
    customer_id,
    'Completed Customer' AS customer_group
FROM training.orders
WHERE order_status = 'Completed'

UNION ALL

SELECT DISTINCT
    customer_id,
    'Cancelled Customer'
FROM training.orders
WHERE order_status = 'Cancelled';
```

If a customer belongs to both groups, that customer receives two rows with different labels.

This can be useful for segmentation.

---

# 58. Set-Based Segmentation Report

Using a CTE:

```sql
;WITH CustomerGroups AS
(
    SELECT DISTINCT
        customer_id,
        'Completed' AS group_name
    FROM training.orders
    WHERE order_status = 'Completed'

    UNION ALL

    SELECT DISTINCT
        customer_id,
        'Cancelled'
    FROM training.orders
    WHERE order_status = 'Cancelled'
)
SELECT
    cg.customer_id,
    c.customer_name,
    cg.group_name
FROM CustomerGroups AS cg
JOIN training.customers AS c
    ON cg.customer_id = c.customer_id
ORDER BY
    c.customer_name,
    cg.group_name;
```

---

# 59. Common Mistake - Different Column Counts

Incorrect:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION

SELECT
    product_id
FROM training.products;
```

Fix the output shape:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION

SELECT
    product_id,
    product_name
FROM training.products;
```

---

# 60. Common Mistake - Wrong Column Order

This may be logically wrong:

```sql
SELECT
    customer_id,
    customer_name
FROM training.customers

UNION ALL

SELECT
    product_name,
    product_id
FROM training.products;
```

Columns are matched by position.

Design the output schema first.

---

# 61. Common Mistake - UNION When Duplicates Matter

If every event row should remain, this may be wrong:

```sql
... UNION ...
```

because duplicate rows can disappear.

Use:

```sql
UNION ALL
```

when appending all source rows is the business requirement.

---

# 62. Common Mistake - UNION ALL When Unique Entities Are Required

If the business requirement asks:

```text
How many unique customers appear in either group?
```

blindly appending with `UNION ALL` can double count customers belonging to both groups.

You may need:

```text
UNION
```

or an explicit distinct step.

---

# 63. Common Mistake - Reversing EXCEPT

Always translate:

```text
A EXCEPT B
```

as:

```text
Rows in A that are not in B
```

Order matters.

---

# 64. Common Mistake - Confusing INTERSECT with UNION

Question:

```text
Customers who have both Completed and Cancelled orders
```

means:

```text
intersection
```

not:

```text
union
```

The word:

```text
both
```

is a useful clue.

---

# 65. Common Mistake - Assuming UNION Matches by Column Name

It does not.

It matches by:

```text
column position
```

and requires compatible types.

---

# 66. Business Translation Guide

Words in a requirement can suggest operators:

```text
"either"
"combined unique list"
    -> UNION

"append all"
"keep every event"
    -> UNION ALL

"both"
"in common"
    -> INTERSECT

"A but not B"
"only A"
    -> EXCEPT
```

These are useful clues, but always verify the actual intended business logic.

---

# 67. Choosing Between Set Operations and Earlier Techniques

You now know several ways to answer similar questions.

Customers without orders:

```text
LEFT JOIN + IS NULL

NOT EXISTS

EXCEPT
```

Customers with orders:

```text
INNER JOIN + DISTINCT

EXISTS

IN
```

Customers with Completed but no Cancelled orders:

```text
EXCEPT

EXISTS + NOT EXISTS

Conditional aggregation
```

There is not always one universally best syntax.

Choose based on:

```text
Correctness
Clarity
Result shape
NULL behavior
Maintainability
Performance when measured
```

---

# 68. Final Mental Model

Think about result sets as:

```text
A
B
```

Then ask:

```text
All unique rows from both?

A UNION B


All rows from both, including duplicates?

A UNION ALL B


Rows common to both?

A INTERSECT B


Rows in A but not B?

A EXCEPT B
```

---

# Chapter Summary

After completing this chapter, you should understand:

```text
UNION
UNION ALL
INTERSECT
EXCEPT

Duplicate handling

Column count requirements

Column position alignment

Data type compatibility

Explicit CAST for alignment

Final output column names

NULL behavior in set comparison

ORDER BY with set operations

Source labels

Set operations with CTEs

Set results followed by JOIN

Set results followed by aggregation

Set operations vs JOINs

Set operations vs EXISTS / NOT EXISTS
```

---

# Chapter Files

```text
07_set_operations/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Learning Outcome

By the end of this chapter, you should be able to answer:

```text
Which customers appear in either of two groups?

Which customers appear in both groups?

Which customers appear in one group but not another?

Which products were never ordered?

Which products were sold in both Completed
and Cancelled orders?

How do I append multiple compatible datasets?

When should duplicates be preserved?

When should duplicates be removed?

What is the difference between a JOIN
and a set operation?

How can set logic be combined with CTEs,
JOINs, aggregation, and business reporting?
```

The main idea is simple:

```text
JOINs combine related columns.

Set operations combine or compare compatible rows.
```

The next chapter, `08_window_functions`, introduces one of the most important areas of analytical SQL: ranking, running totals, percentages, previous/next rows, and calculations across groups without collapsing the underlying detail rows.