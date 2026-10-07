/*==============================================================================
    SQL Mastery
    Practice Exercises - Intermediate
    File: exercises.sql
    Database: SQLMastery
    Schema: training

    Focus:
    - Multi-table joins
    - Result grain
    - Conditional aggregation
    - LEFT JOIN
    - Zero-activity entities
    - Subqueries
    - EXISTS / NOT EXISTS
    - CTEs
    - Set operations
    - Business metrics
    - Window functions
    - Ranking
    - LAG / LEAD
    - Running totals
    - Top N per group
    - Order/customer/product analysis

    Default Revenue:
        SUM(quantity * unit_price)
        for Completed orders only.

    Try each exercise before opening solutions.sql.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    EXERCISE 1 - CUSTOMER ORDER COUNTS
==============================================================================*/

/*
    Return ALL customers:

        customer_id
        customer_name
        total_orders

    Customers with no orders must display 0.

    Grain:
        one row per customer.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 2 - CUSTOMER STATUS COUNTS
==============================================================================*/

/*
    Return ALL customers with:

        customer_id
        customer_name
        total_orders
        completed_orders
        pending_orders
        cancelled_orders

    Use conditional aggregation.

    Do not join order_items.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 3 - CUSTOMERS WHO NEVER ORDERED
==============================================================================*/

/*
    Find customers with no order of any status.

    Solve using NOT EXISTS.

    Return:

        customer_id
        customer_name
        signup_date
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 4 - CUSTOMERS WITH COMPLETED ORDERS
==============================================================================*/

/*
    Find customers having at least one Completed order.

    Solve using EXISTS.

    Return each customer once.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 5 - ORDERED BUT NEVER COMPLETED
==============================================================================*/

/*
    Find customers who:

        have at least one order

    but:

        have no Completed orders.

    Use EXISTS + NOT EXISTS.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 6 - ALL CUSTOMERS WITH COMPLETED REVENUE
==============================================================================*/

/*
    Return ALL customers:

        customer_id
        customer_name
        completed_orders
        completed_revenue

    Customers with no Completed activity:

        completed_orders = 0
        completed_revenue = 0

    Avoid eliminating unmatched customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 7 - ALL PRODUCTS WITH SALES
==============================================================================*/

/*
    Return ALL products:

        product_id
        product_name
        units_sold
        completed_revenue

    Products with no Completed sales must display zero metrics.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 8 - UNSOLD PRODUCTS
==============================================================================*/

/*
    Find products that have never appeared in a Completed order.

    A product appearing in Pending or Cancelled orders still qualifies
    as unsold here.

    Use NOT EXISTS.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 9 - REPEAT CUSTOMERS
==============================================================================*/

/*
    Return customers with at least:

        2 Completed orders

    Columns:

        customer_id
        customer_name
        completed_orders

    Do not use order_items.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 10 - REPEAT CUSTOMER REVENUE
==============================================================================*/

/*
    Extend repeat-customer analysis.

    Return:

        customer_id
        customer_name
        completed_orders
        completed_revenue

    Be careful with order count after joining order_items.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 11 - CUSTOMER AVERAGE ORDER VALUE
==============================================================================*/

/*
    Return one row per customer with Completed orders:

        customer_id
        customer_name
        completed_orders
        completed_revenue
        average_order_value

    Average Order Value:

        completed_revenue / completed_orders
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 12 - ORDER-LEVEL DATASET
==============================================================================*/

/*
    Create one row per Completed order:

        order_id
        customer_id
        order_date
        order_value

    This order-level dataset will be reused conceptually in later exercises.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 13 - ABOVE-AVERAGE ORDERS
==============================================================================*/

/*
    Starting from Completed order values, return orders where:

        order_value > average value of all Completed orders

    Return:

        order_id
        customer_id
        order_date
        order_value

    Use a CTE plus scalar subquery or equivalent.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 14 - CUSTOMER'S ABOVE-AVERAGE ORDERS
==============================================================================*/

/*
    Return Completed orders whose value is greater than that customer's
    own average Completed order value.

    Columns:

        customer_id
        order_id
        order_date
        order_value
        customer_average_order_value
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 15 - PRODUCTS ABOVE GLOBAL AVERAGE PRICE
==============================================================================*/

/*
    Return products whose price is greater than:

        average product price

    Use a scalar subquery.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 16 - PRODUCTS ABOVE CATEGORY AVERAGE PRICE
==============================================================================*/

/*
    Return products priced above the average price of their own category.

    Columns:

        product_id
        product_name
        category
        price

    Use a correlated subquery or CTE approach.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 17 - CUSTOMER WITH HIGHEST COMPLETED REVENUE
==============================================================================*/

/*
    Find the customer(s) with the maximum Completed revenue.

    Return all ties.

    Avoid hardcoding customer IDs.

    Hint:
        First calculate revenue per customer.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 18 - PRODUCT WITH HIGHEST COMPLETED REVENUE
==============================================================================*/

/*
    Find the product(s) with the maximum Completed revenue.

    Return all ties.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 19 - CATEGORIES ABOVE AVERAGE CATEGORY REVENUE
==============================================================================*/

/*
    Calculate Completed revenue per category.

    Return categories whose revenue is greater than the average revenue
    across categories with Completed sales.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 20 - FIRST COMPLETED ORDER DATE
==============================================================================*/

/*
    Return one row per customer with Completed activity:

        customer_id
        customer_name
        first_completed_order_date
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 21 - LATEST COMPLETED ORDER DATE
==============================================================================*/

/*
    Return one row per customer with Completed activity:

        customer_id
        customer_name
        latest_completed_order_date
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 22 - CUSTOMER LIFETIME SUMMARY
==============================================================================*/

/*
    Return one row per customer with Completed activity:

        customer_id
        customer_name
        first_completed_order_date
        latest_completed_order_date
        completed_orders
        completed_revenue
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 23 - CUSTOMER SPAN DAYS
==============================================================================*/

/*
    Extend the lifetime summary with:

        customer_span_days

    Formula:

        DATEDIFF(
            DAY,
            first_completed_order_date,
            latest_completed_order_date
        )
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 24 - COMPLETED ORDER SEQUENCE
==============================================================================*/

/*
    Number each customer's Completed orders chronologically.

    Return:

        customer_id
        order_id
        order_date
        purchase_number

    Use ROW_NUMBER().

    Tie breaker:
        order_id
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 25 - LATEST COMPLETED ORDER PER CUSTOMER
==============================================================================*/

/*
    Return exactly one latest Completed order per customer.

    Columns:

        customer_id
        order_id
        order_date
        order_status

    Use ROW_NUMBER().

    Tie breaker:
        highest order_id
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 26 - FIRST COMPLETED ORDER PER CUSTOMER
==============================================================================*/

/*
    Return exactly one first Completed order per customer.

    Use ROW_NUMBER().

    Order by:

        order_date ASC
        order_id ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 27 - PREVIOUS COMPLETED ORDER
==============================================================================*/

/*
    Return each Completed order with:

        customer_id
        order_id
        order_date
        previous_order_date

    Use LAG().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 28 - DAYS SINCE PREVIOUS ORDER
==============================================================================*/

/*
    Extend Exercise 27 with:

        days_since_previous_order

    The customer's first order should naturally return NULL.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 29 - NEXT COMPLETED ORDER
==============================================================================*/

/*
    Return every Completed order with:

        customer_id
        order_id
        order_date
        next_order_date

    Use LEAD().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 30 - PRODUCT REVENUE RANKING
==============================================================================*/

/*
    Calculate Completed product revenue.

    Return:

        product_id
        product_name
        completed_revenue
        revenue_rank

    Use DENSE_RANK().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 31 - CATEGORY REVENUE RANKING
==============================================================================*/

/*
    Calculate Completed category revenue.

    Return:

        category
        completed_revenue
        revenue_rank
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 32 - CUSTOMER REVENUE RANKING
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        completed_revenue
        revenue_rank

    Use DENSE_RANK().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 33 - PRODUCT RANK WITHIN CATEGORY
==============================================================================*/

/*
    Calculate Completed revenue per product.

    Rank products inside their own category.

    Return:

        category
        product_id
        product_name
        completed_revenue
        category_rank
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 34 - TOP 2 PRODUCTS PER CATEGORY
==============================================================================*/

/*
    Starting from Exercise 33, return products where:

        category_rank <= 2

    Decide whether ties should be preserved.

    Use DENSE_RANK().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 35 - MONTHLY COMPLETED REVENUE
==============================================================================*/

/*
    Return:

        revenue_month
        monthly_revenue

    revenue_month:
        month-start DATE

    Completed orders only.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 36 - MONTHLY RUNNING REVENUE
==============================================================================*/

/*
    Extend monthly Completed revenue with:

        cumulative_revenue

    Use:

        SUM() OVER()

    with an explicit ROWS frame.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 37 - MONTH-OVER-MONTH REVENUE
==============================================================================*/

/*
    Return:

        revenue_month
        monthly_revenue
        previous_revenue

    Use LAG().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 38 - MONTHLY REVENUE GROWTH
==============================================================================*/

/*
    Extend Exercise 37 with:

        revenue_change
        growth_pct

    Formula:

        revenue_change =
            current - previous

        growth_pct =
            (current - previous) / previous * 100

    Protect against division by zero.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 39 - MONTHLY REVENUE SHARE
==============================================================================*/

/*
    Return:

        revenue_month
        monthly_revenue
        total_revenue
        revenue_share_pct

    Use a window SUM for total revenue.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 40 - CUSTOMER REVENUE SHARE
==============================================================================*/

/*
    Return one row per customer with Completed revenue:

        customer_id
        customer_name
        customer_revenue
        total_revenue
        revenue_share_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 41 - CUMULATIVE CUSTOMER REVENUE SHARE
==============================================================================*/

/*
    Rank customers from highest Completed revenue to lowest.

    Return:

        customer_id
        customer_name
        customer_revenue
        cumulative_revenue
        cumulative_revenue_pct

    Add customer_id as a deterministic tie breaker for cumulative ordering.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 42 - CUSTOMER REVENUE QUARTILES
==============================================================================*/

/*
    Divide customers with Completed revenue into four approximately
    equal-sized groups.

    Highest revenue should be in quartile 1.

    Return:

        customer_id
        customer_name
        completed_revenue
        revenue_quartile

    Use NTILE(4).
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 43 - PRODUCT REVENUE PERCENT OF CATEGORY
==============================================================================*/

/*
    Calculate Completed product revenue.

    Return:

        category
        product_id
        product_name
        product_revenue
        category_revenue
        category_revenue_share_pct

    Use:

        SUM(product_revenue)
            OVER (PARTITION BY category)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 44 - ORDER REVENUE PERCENT OF CUSTOMER
==============================================================================*/

/*
    Start at one row per Completed order.

    Return:

        customer_id
        order_id
        order_value
        customer_revenue
        order_share_of_customer_revenue_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 45 - CUSTOMER'S LARGEST ORDER
==============================================================================*/

/*
    Return exactly one largest Completed order per customer.

    Return:

        customer_id
        customer_name
        order_id
        order_date
        order_value

    Tie breakers:

        order_value DESC
        order_date DESC
        order_id DESC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 46 - GLOBAL TOP 3 ORDERS
==============================================================================*/

/*
    Return the three largest Completed orders by order value.

    Return:

        order_id
        customer_id
        order_date
        order_value

    Use an order-level CTE first.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 47 - ORDERS ABOVE GLOBAL AVERAGE
==============================================================================*/

/*
    Return Completed orders whose value is above the average Completed
    order value.

    Also return:

        average_order_value
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 48 - CUSTOMER CATEGORY REVENUE
==============================================================================*/

/*
    Return Completed revenue by:

        customer_id
        customer_name
        category

    Grain:

        one row per customer/category.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 49 - CUSTOMER FAVORITE CATEGORY
==============================================================================*/

/*
    Find exactly one highest-revenue category for each customer with
    Completed purchases.

    Return:

        customer_id
        customer_name
        favorite_category
        category_revenue

    Tie breaker:

        category ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 50 - PRODUCT DISTINCT BUYERS
==============================================================================*/

/*
    Return:

        product_id
        product_name
        distinct_buyers

    for products with Completed sales.

    Count distinct customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 51 - CUSTOMER PRODUCT DIVERSITY
==============================================================================*/

/*
    Return one row per customer with Completed purchases:

        customer_id
        customer_name
        distinct_products
        distinct_categories
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 52 - PRODUCT PAIRS
==============================================================================*/

/*
    Find product pairs appearing in the same Completed order.

    Return:

        product_id_1
        product_id_2
        orders_together

    Rules:

        product_id_1 < product_id_2

        no self-pairs

        no reversed duplicates

    Deduplicate product/order combinations before pairing.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 53 - SET OPERATION: CUSTOMERS WITH ANY ORDER
==============================================================================*/

/*
    Use a set-based query to return distinct customer IDs that appear
    in training.orders.

    This is intentionally simple preparation for later set exercises.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 54 - SET OPERATION: COMPLETED OR PENDING CUSTOMERS
==============================================================================*/

/*
    Build two sets:

        Customers with Completed orders

        Customers with Pending orders

    Combine them using UNION.

    Return one distinct customer_id column.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 55 - COMPLETED AND PENDING CUSTOMERS
==============================================================================*/

/*
    Return customer IDs that have:

        at least one Completed order

    AND:

        at least one Pending order

    Use INTERSECT.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 56 - COMPLETED BUT NEVER CANCELLED
==============================================================================*/

/*
    Return customers with a Completed order but no Cancelled order.

    Use EXCEPT.

    Return:

        customer_id
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 57 - UNION VS UNION ALL
==============================================================================*/

/*
    Build:

        Set A = customer IDs with Completed orders
        Set B = customer IDs with Pending orders

    Run once using UNION.

    Run again using UNION ALL.

    Explain in comments why row counts can differ.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 58 - COMPLETED ORDER VALUE BY MONTH
==============================================================================*/

/*
    First calculate one row per Completed order.

    Then return one row per month:

        revenue_month
        completed_orders
        monthly_revenue
        average_order_value

    This exercise deliberately separates order grain from month grain.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 59 - MONTHLY UNIQUE CUSTOMERS
==============================================================================*/

/*
    Return one row per Completed activity month:

        activity_month
        active_customers

    Count each customer once per month regardless of how many Completed
    orders they placed.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 60 - NEW CUSTOMER MONTH
==============================================================================*/

/*
    Return:

        customer_id
        first_completed_month

    for every customer with Completed activity.

    first_completed_month must be a month-start DATE.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 61 - CUSTOMER-MONTH ACTIVITY
==============================================================================*/

/*
    Return one row per:

        customer_id
        activity_month

    for Completed activity.

    Deduplicate customer/month.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 62 - NEW VS RETURNING ACTIVITY
==============================================================================*/

/*
    Combine first_completed_month and customer-month activity.

    Return:

        customer_id
        activity_month
        customer_type

    Rules:

        activity_month = first_completed_month
            -> New

        activity_month > first_completed_month
            -> Returning
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 63 - MONTHLY NEW VS RETURNING COUNTS
==============================================================================*/

/*
    Aggregate Exercise 62.

    Return:

        activity_month
        new_customers
        returning_customers
        active_customers
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 64 - CUSTOMER ORDER GAP SUMMARY
==============================================================================*/

/*
    Use LAG() to calculate gaps between each customer's Completed orders.

    Then return one row per customer with at least one measurable gap:

        customer_id
        average_days_between_orders
        minimum_days_between_orders
        maximum_days_between_orders

    Ignore the first order's NULL gap naturally through aggregate behavior.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 65 - CATEGORY PRODUCT COUNT + SALES
==============================================================================*/

/*
    Return ALL categories that exist in products.

    Columns:

        category
        total_products
        products_with_completed_sales
        completed_revenue

    Categories with zero Completed sales must remain.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 66 - ACTIVE PRODUCTS WITH NO COMPLETED SALES
==============================================================================*/

/*
    Return products where:

        is_active = 1

    and the product has never appeared in a Completed order.

    Use NOT EXISTS.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 67 - ACTIVE CUSTOMERS WITH NO COMPLETED ORDER
==============================================================================*/

/*
    Return customers where:

        is_active = 1

    and they have no Completed orders.

    They may have Pending/Cancelled orders.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 68 - CUSTOMER SEGMENT
==============================================================================*/

/*
    Assign every customer exactly one segment:

        Never Ordered

        Ordered But Never Completed

        One-Time Completed Customer

        Repeat Customer

    Return:

        customer_id
        customer_name
        customer_segment

    Definitions:

        One-Time = exactly 1 Completed order
        Repeat   = >= 2 Completed orders
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 69 - SEGMENT SUMMARY
==============================================================================*/

/*
    Using the segment definition from Exercise 68, return:

        customer_segment
        customer_count
        customer_pct

    Denominator:

        all registered customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 70 - CITY CUSTOMER METRICS
==============================================================================*/

/*
    Return one row per city:

        city
        registered_customers
        customers_with_any_order
        completed_customers

    Include cities where customers have no orders.

    Avoid counting duplicated customer rows from joins.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 71 - CITY COMPLETED REVENUE
==============================================================================*/

/*
    Return one row per city appearing in customers:

        city
        registered_customers
        completed_revenue

    Cities with no Completed revenue must display 0.

    Handle NULL city consistently.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 72 - ESTIMATED PRODUCT PROFIT
==============================================================================*/

/*
    Return sold products:

        product_id
        product_name
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct

    Completed orders only.

    Historical profit is estimated because products.cost is current cost.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 73 - CATEGORY PROFIT
==============================================================================*/

/*
    Return Completed profitability by category:

        category
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 74 - PRODUCT REVENUE VS PROFIT RANK
==============================================================================*/

/*
    Return sold products:

        product_id
        product_name
        revenue
        estimated_gross_profit
        revenue_rank
        gross_profit_rank

    Use DENSE_RANK() for both.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 75 - MONTHLY ESTIMATED PROFIT
==============================================================================*/

/*
    Return one row per Completed sales month:

        revenue_month
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 76 - CUSTOMER KPI REPORT
==============================================================================*/

/*
    Return ALL customers:

        customer_id
        customer_name
        total_orders
        completed_orders
        completed_revenue
        first_completed_order_date
        latest_completed_order_date

    Requirements:

    - one row per customer
    - zero activity stays visible
    - dates should remain NULL when no Completed order exists
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 77 - CUSTOMER REVENUE RECONCILIATION
==============================================================================*/

/*
    Calculate Completed revenue two ways:

    A:
        directly from Completed order items

    B:
        first aggregate revenue per customer,
        then sum all customer revenue

    Return:

        direct_revenue
        customer_level_revenue
        difference

    Expected difference:

        0
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 78 - ORDER REVENUE RECONCILIATION
==============================================================================*/

/*
    Calculate Completed revenue two ways:

    A:
        directly from Completed order items

    B:
        aggregate one row per order,
        then sum order revenue

    Return:

        direct_revenue
        order_level_revenue
        difference
        validation_status

    PASS when totals match.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 79 - FIX THE BROKEN QUERY
==============================================================================*/

/*
    Requirement:

        Return ALL customers with:
            completed_orders
            completed_revenue

    Broken query:

        SELECT
            c.customer_id,
            c.customer_name,
            COUNT(o.order_id) AS completed_orders,
            SUM(p.price * oi.quantity) AS completed_revenue
        FROM training.customers AS c
        LEFT JOIN training.orders AS o
            ON o.customer_id = c.customer_id
        LEFT JOIN training.order_items AS oi
            ON oi.order_id = o.order_id
        LEFT JOIN training.products AS p
            ON p.product_id = oi.product_id
        WHERE o.order_status = 'Completed'
        GROUP BY
            c.customer_id,
            c.customer_name;

    Identify in comments:

    1. LEFT JOIN / WHERE problem.
    2. Order row multiplication.
    3. Wrong revenue price.
    4. Unnecessary products join.

    Then write the corrected query.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 80 - INTERMEDIATE FINAL CHALLENGE
==============================================================================*/

/*
    Build a customer performance report.

    Return ALL customers:

        customer_id
        customer_name
        city
        is_active

        total_orders
        completed_orders
        cancelled_orders

        completed_units
        completed_revenue
        average_order_value

        first_completed_order_date
        latest_completed_order_date

        distinct_products_purchased
        distinct_categories_purchased

        customer_segment
        revenue_rank

    Segment definitions:

        Never Ordered
        Ordered But Never Completed
        One-Time Completed Customer
        Repeat Customer

    Requirements:

    - exactly one row per registered customer
    - revenue uses order_items.unit_price
    - no Completed activity -> zero metrics
    - no Completed activity -> NULL first/latest Completed dates
    - order counts must not be multiplied by order items
    - revenue rank should rank customers with positive Completed revenue
    - zero-revenue customers may have NULL revenue_rank
    - protect average_order_value against division by zero

    Recommended approach:

        1. Aggregate orders to customer grain.
        2. Aggregate Completed order-item metrics to customer grain.
        3. Join those customer-level datasets to customers.
        4. Create segment.
        5. Rank revenue.

    Validation:

        final row count
        =
        COUNT(*) FROM training.customers
*/

-- Write your solution below:




/*==============================================================================
    INTERMEDIATE SELF-CHECK
==============================================================================*/

/*
    Make sure you can explain:

    1. Why result grain should be established before aggregation.

    2. Why one-to-many joins can inflate counts.

    3. When COUNT(DISTINCT) is appropriate.

    4. Why pre-aggregation can simplify business queries.

    5. EXISTS vs NOT EXISTS.

    6. The NOT IN + NULL problem.

    7. CTE scope.

    8. Why a CTE is not automatically materialized.

    9. UNION vs UNION ALL.

    10. INTERSECT vs EXCEPT.

    11. ROW_NUMBER vs RANK vs DENSE_RANK.

    12. Why deterministic tie breakers matter.

    13. LAG vs LEAD.

    14. Running totals.

    15. Percent-of-total window calculations.

    16. Top N per group.

    17. Why customer-month activity should be deduplicated.

    18. Why unit_price is used for transaction revenue.

    19. Why historical profit is only estimated.

    20. How revenue reconciliation detects analytical errors.
*/


/*==============================================================================
    END OF INTERMEDIATE EXERCISES

    Total:
        80 exercises

    Next file:
        exercises/intermediate/solutions.sql
==============================================================================*/