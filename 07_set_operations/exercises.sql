/*
============================================================
SQL MASTERY
07 - SET OPERATIONS

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve every exercise before checking solutions.sql.

Topics:
- UNION
- UNION ALL
- INTERSECT
- EXCEPT
- Duplicate Handling
- Column Compatibility
- Source Labels
- CTEs with Set Operations
- Business Segmentation
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - UNION

   Return unique customer IDs that appear in:

   Completed orders
   OR
   Cancelled orders.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 2 - UNION ALL

   Return customer IDs from:

   Completed orders

   plus

   Cancelled orders.

   Keep duplicate rows.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 3 - UNION CUSTOMER / PRODUCT NAMES

   Create one unique list containing:

   customer names
   product names

   Return:

   entity_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 4 - UNION ALL ENTITIES

   Combine all customers and products.

   Return:

   entity_id
   entity_name
   entity_type

   entity_type must contain:

   Customer

   or

   Product

   Preserve every source row.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 5 - ORDER FINAL RESULT

   Solve the previous exercise and sort:

   entity_type ASC
   entity_name ASC

   Remember:

   ORDER BY belongs at the end of the complete
   set operation.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 6 - EXPLICIT CAST

   Combine customers and products using UNION ALL.

   Convert both IDs to:

   VARCHAR(20)

   Return:

   entity_id
   entity_name
   entity_type
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 7 - COMPLETED / PENDING

   Return unique customer IDs appearing in either:

   Completed orders

   OR

   Pending orders.

   Use UNION.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 8 - INTERSECT

   Find customer IDs that have BOTH:

   at least one Completed order

   AND

   at least one Cancelled order.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 9 - INTERSECT + DETAILS

   Using a CTE and INTERSECT, find customers
   who have both Completed and Cancelled orders.

   Return:

   customer_id
   customer_name
   city
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 10 - EXCEPT

   Find customer IDs that have:

   Completed orders

   BUT NO:

   Cancelled orders.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 11 - EXCEPT + CUSTOMER DETAILS

   Find customers with Completed orders
   but no Cancelled orders.

   Return:

   customer_id
   customer_name
   email
   city

   Use:

   CTE
   EXCEPT
   JOIN
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 12 - CUSTOMERS WITHOUT ORDERS

   Use EXCEPT to find customer IDs that exist
   in customers but not orders.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 13 - CUSTOMERS WITHOUT ORDERS - DETAILS

   Use a CTE with EXCEPT.

   Return:

   customer_id
   customer_name
   email
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 14 - REVERSE EXCEPT

   Run the opposite set comparison:

   customer IDs in orders

   EXCEPT

   customer IDs in customers

   Return:

   customer_id

   Think about why the result should normally
   be empty with the current Foreign Key.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 15 - PRODUCTS NEVER ORDERED

   Find product IDs that exist in products but
   never appear in order_items.

   Use EXCEPT.

   Return:

   product_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 16 - UNSOLD PRODUCT DETAILS

   Use EXCEPT inside a CTE.

   Return:

   product_id
   product_name
   category
   price
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 17 - PRODUCTS IN BOTH ORDER GROUPS

   Find products that appear in BOTH:

   Completed orders

   AND

   Cancelled orders.

   Use INTERSECT.

   Return:

   product_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 18 - COMPLETED BUT NOT CANCELLED PRODUCTS

   Find product IDs that appear in:

   Completed orders

   BUT NEVER in:

   Cancelled orders.

   Use EXCEPT.

   Return:

   product_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 19 - PRODUCT DETAILS

   Solve the previous problem and display:

   product_id
   product_name
   category
   price

   Use a CTE and JOIN.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 20 - NAMED SETS

   Create:

   CompletedCustomers

   and:

   CancelledCustomers

   Then use INTERSECT.

   Return customer IDs appearing in both sets.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 21 - NAMED SETS + EXCEPT

   Create:

   CompletedCustomers
   CancelledCustomers

   Return customers in CompletedCustomers
   but not CancelledCustomers.

   Return:

   customer_id
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 22 - NAMED SETS + UNION

   Using the same two logical sets, return all
   unique customer IDs appearing in either group.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 23 - GROUP MEMBERSHIP

   Create one row per customer/group membership.

   Groups:

   Completed
   Cancelled

   A customer who belongs to both groups should
   have two rows.

   A customer with multiple Completed orders should
   only have one Completed membership row.

   Return:

   customer_id
   group_name

   Hint:

   DISTINCT inside each source query
   +
   UNION ALL
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 24 - MEMBERSHIP WITH CUSTOMER NAMES

   Build the same membership dataset using a CTE.

   Return:

   customer_id
   customer_name
   group_name

   Sort:

   customer_name
   group_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 25 - VERTICAL ORDER METRICS

   Create this result shape:

   metric             metric_value
   ----------------  ------------
   Completed Orders   ...
   Cancelled Orders   ...
   Pending Orders     ...

   Use:

   COUNT
   UNION ALL
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 26 - SYSTEM SUMMARY

   Return:

   Customers
   Products
   Orders
   Order Items

   as separate metric rows.

   Output:

   metric
   metric_value

   Use UNION ALL.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 27 - BUSINESS METRIC SUMMARY

   Return these metrics vertically:

   Total Orders
   Total Units
   Gross Order Item Value

   Output:

   metric
   metric_value

   Use a compatible numeric data type for the
   metric_value column.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 28 - ORDER STATUS VALUE

   Calculate:

   Completed Value
   Cancelled Value

   Formula:

   SUM(quantity * unit_price)

   Return vertically:

   metric
   metric_value

   Use UNION ALL.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 29 - SET OPERATION INSIDE CTE

   Create a CTE called:

   CombinedEntities

   Combine:

   customers
   products

   Return from the final query:

   entity_id
   entity_name
   entity_type
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 30 - AGGREGATE SET RESULT

   Create CombinedEntities containing:

   one row per customer labelled Customer

   one row per product labelled Product

   Then calculate:

   entity_type
   entity_count

   Expected groups:

   Customer
   Product
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 31 - COMPLETED ONLY SEGMENT

   Find customers with:

   at least one Completed order

   AND

   no Cancelled order.

   Use EXCEPT.

   Then return:

   customer_id
   customer_name
   display_city

   Replace NULL city with:

   Unknown
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 32 - BOTH GROUPS SEGMENT

   Find customers who have:

   Completed order

   AND

   Cancelled order.

   Use INTERSECT.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 33 - NO ORDERS SEGMENT

   Use EXCEPT to identify customers with no orders.

   Return:

   customer_id
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 34 - PRODUCT SET LABELS

   Create product memberships:

   Ordered
   Active

   A product can belong to both groups.

   Return:

   product_id
   group_name

   Requirements:

   - One Ordered membership per product
   - One Active membership per product
   - Preserve membership in both groups

   Use DISTINCT where needed and UNION ALL.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 35 - COMPLETED PRODUCT DETAILS

   Find products appearing in Completed orders.

   Then return:

   product_id
   product_name
   category

   Build the ID set first using a CTE.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 36 - SHARED PRODUCT DETAILS

   Find products appearing in BOTH:

   Completed orders
   Cancelled orders

   Return:

   product_id
   product_name
   category

   Use named CTE sets and INTERSECT.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 37 - COMPLETED-ONLY PRODUCT DETAILS

   Find products appearing in Completed orders
   but never Cancelled orders.

   Return:

   product_id
   product_name
   category

   Use:

   named CTE sets
   EXCEPT
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 38 - SEGMENT COUNTS

   Build customer membership segments:

   Completed Buyer
   Cancelled Buyer
   No Orders

   A customer may belong to both buyer segments.

   Then calculate:

   segment
   customer_count

   Use CTEs and set operations.
*/

-- Write your answer here:




/* ==========================================================
   EXERCISE 39 - THINK ABOUT UNION

   Query A returns:

   1
   2
   3

   Query B returns:

   2
   3
   4

   Questions:

   1. What does UNION return?

   2. How many final rows?

   3. Why?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 40 - THINK ABOUT UNION ALL

   Using the same inputs:

   A:
   1
   2
   3

   B:
   2
   3
   4

   Questions:

   1. What does UNION ALL return?

   2. How many final rows?

   3. Why?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 41 - THINK ABOUT INTERSECT

   Sets:

   A:
   1
   2
   3

   B:
   2
   3
   4

   What does:

   A INTERSECT B

   return?
   ========================================================== */

/*
Answer:


*/


/* ==========================================================
   EXERCISE 42 - THINK ABOUT EXCEPT

   Sets:

   A:
   1
   2
   3

   B:
   2
   3
   4

   Questions:

   1. What does A EXCEPT B return?

   2. What does B EXCEPT A return?

   3. Why does direction matter?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 43 - COLUMN MATCHING

   Consider:

       SELECT
           customer_id,
           customer_name
       FROM training.customers

       UNION ALL

       SELECT
           product_name,
           product_id
       FROM training.products;

   Questions:

   1. Does UNION match columns by name or position?

   2. What is logically wrong with this output shape?

   3. What should the second SELECT return instead?
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   EXERCISE 44 - UNION vs JOIN

   For each requirement choose:

   JOIN

   or

   SET OPERATION


   1. Show every order with customer_name.

   2. Append customer names and product names
      into one list.

   3. Find IDs common to two query results.

   4. Add product_name to order_items using product_id.

   5. Find rows in set A that do not exist in set B.
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

5.

*/


/* ==========================================================
   EXERCISE 45 - CHOOSE THE SET OPERATOR

   Choose:

   UNION
   UNION ALL
   INTERSECT
   EXCEPT


   1. Unique entities appearing in A or B.

   2. Append every row from A and B.

   3. Entities that appear in both A and B.

   4. Entities in A but not B.
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

*/


/* ==========================================================
   EXERCISE 46 - DUPLICATE ROW MEANING

   Consider:

       1 | Completed
       1 | Cancelled

   Are these duplicate rows for UNION purposes?

   Explain why or why not.
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 47 - OUTPUT COLUMN NAMES

   Consider:

       SELECT
           customer_id AS entity_id,
           customer_name AS entity_name
       FROM training.customers

       UNION ALL

       SELECT
           product_id,
           product_name
       FROM training.products;

   What are the final output column names?
   ========================================================== */

/*
Answer:

1.

2.

*/


/* ==========================================================
   EXERCISE 48 - UNION vs UNION ALL PERFORMANCE

   Answer:

   1. Which operator removes duplicates?

   2. Which operator simply appends rows?

   3. Why can UNION require additional work?

   4. Should UNION ALL always be used instead?
   ========================================================== */

/*
Answer:

1.

2.

3.

4.

*/


/* ==========================================================
   EXERCISE 49 - NULL THINKING

   Is this normal predicate true?

       NULL = NULL

   How should that be distinguished from the way
   duplicate elimination in set operations can treat
   rows containing corresponding NULL values?
   ========================================================== */

/*
Answer:



*/


/* ==========================================================
   EXERCISE 50 - MULTIPLE SOLUTIONS

   Requirement:

   Find customers with no orders.

   Name three techniques covered so far that can
   solve this problem.
   ========================================================== */

/*
Answer:

1.

2.

3.

*/


/* ==========================================================
   CHALLENGE 1 - CUSTOMER SET CLASSIFICATION
   ==========================================================

   Build these sets:

   CompletedCustomers
   CancelledCustomers
   NoOrders

   Produce these final segments:

   Completed Only

       CompletedCustomers
       EXCEPT
       CancelledCustomers


   Completed and Cancelled

       CompletedCustomers
       INTERSECT
       CancelledCustomers


   No Orders

       customers
       EXCEPT
       orders


   Final result:

   customer_id
   customer_name
   display_city
   segment

   display_city:

   NULL -> Unknown

   Sort:

   segment
   customer_name
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 2 - PRODUCT SET CLASSIFICATION
   ==========================================================

   Build:

   CompletedProducts
   CancelledProducts

   Create segments:

   Completed Only

       CompletedProducts
       EXCEPT
       CancelledProducts


   Both Statuses

       CompletedProducts
       INTERSECT
       CancelledProducts


   Never Ordered

       products
       EXCEPT
       order_items


   Return:

   product_id
   product_name
   category
   segment

   Sort:

   segment
   product_name
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 3 - BUSINESS KPI STACK
   ==========================================================

   Build a vertical KPI report.

   Return:

   metric
   metric_value

   Metrics:

   Total Customers
   Active Customers
   Total Orders
   Completed Orders
   Cancelled Orders
   Total Units
   Completed Revenue

   Requirements:

   Use UNION ALL.

   Ensure metric_value has a compatible numeric type
   across every branch.
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 4 - CUSTOMER BEHAVIOR MEMBERSHIPS
   ==========================================================

   Create one row for every customer/group membership.

   Groups:

   Has Completed Order
   Has Cancelled Order
   Bought Electronics
   Bought Accessories
   No Orders

   A customer may belong to several groups.

   Requirements:

   - Do not duplicate the same customer/group pair
   - Preserve membership across different groups
   - Use UNION ALL to combine labeled sets

   Return:

   customer_id
   customer_name
   group_name

   Sort:

   customer_name
   group_name
*/

-- Write your answer here:




/* ==========================================================
   CHALLENGE 5 - FINAL SET OPERATIONS CHALLENGE
   ==========================================================

   Build a product opportunity report.

   Define:

   CompletedProducts:
       Products appearing in Completed orders

   CancelledProducts:
       Products appearing in Cancelled orders

   ActiveProducts:
       Products where is_active = 1


   Target products must:

   - Be active
   - Have appeared in Completed orders
   - Never have appeared in Cancelled orders


   Use set logic to derive the target product IDs.

   Return:

   product_id
   product_name
   category
   price
   stock_quantity

   Sort:

   price DESC

   Hint:

   Think about:

   INTERSECT
   EXCEPT

   and the direction/order of the sets.
*/

-- Write your answer here:




/* ==========================================================
   END OF EXERCISES

   Before completing Chapter 07,
   make sure you can explain:

   1. UNION vs UNION ALL

   2. INTERSECT

   3. EXCEPT

   4. Why EXCEPT direction matters

   5. How duplicates are handled

   6. Why complete selected rows matter
      for duplicate comparison

   7. Why SELECT column counts must match

   8. Why columns align by position

   9. Why compatible data types matter

   10. Why CAST can be useful

   11. Where ORDER BY belongs

   12. How final output columns are named

   13. JOIN vs set operations

   14. EXCEPT vs NOT EXISTS

   15. How CTEs can make set logic readable

   16. Why source/group labels are useful

   17. How UNION ALL can build a vertical
       business metric report

   18. How multiple set operations can build
       customer and product segmentation
   ========================================================== */