/*==============================================================================
    SQL Mastery
    Business Challenges
    File: challenges.sql
    Database: SQLMastery
    Schema: training

    Goal:
    Convert realistic business questions into correct, validated SQL.

    Core Tables:
        training.customers
        training.products
        training.orders
        training.order_items

    Default Business Definitions:
        Revenue          = SUM(quantity * unit_price) for Completed orders
        Units Sold       = SUM(quantity) for Completed orders
        Repeat Customer  = customer with >= 2 distinct Completed orders
        Cohort           = month of first Completed order
        Activity Month   = month containing >= 1 Completed order

    IMPORTANT:
    - Think about result grain before writing SQL.
    - Protect order counts from order-item row multiplication.
    - Use order_items.unit_price for transaction revenue.
    - Current products.cost makes historical profit an estimate.
    - Do not assume missing activity means churn when future data is unavailable.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    CHALLENGE 1 - EXECUTIVE REVENUE KPIs
==============================================================================*/

/*
    Build a one-row executive KPI report containing:

        completed_orders
        customers_with_completed_orders
        units_sold
        completed_revenue
        average_order_value

    Definitions:

        Completed orders only.

        completed_orders:
            distinct order count

        customers_with_completed_orders:
            distinct customers

        units_sold:
            SUM(quantity)

        completed_revenue:
            SUM(quantity * unit_price)

        average_order_value:
            completed_revenue / completed_orders

    Questions:

    1. Why must completed_orders not use COUNT(*) after joining order_items?
    2. What is the final result grain?
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 2 - MONTHLY REVENUE
==============================================================================*/

/*
    Return one row per month containing:

        revenue_month
        completed_orders
        purchasing_customers
        units_sold
        revenue

    Use Completed orders only.

    Represent revenue_month as a month-start DATE.

    Sort chronologically.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 3 - MONTHLY REVENUE SHARE
==============================================================================*/

/*
    Starting from monthly Completed revenue, return:

        revenue_month
        monthly_revenue
        total_revenue
        revenue_share_pct

    revenue_share_pct:

        monthly_revenue / total revenue * 100

    Use a window aggregate rather than joining the monthly result back
    to another total query.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 4 - MONTH-OVER-MONTH GROWTH
==============================================================================*/

/*
    Return:

        revenue_month
        monthly_revenue
        previous_month_revenue
        revenue_change
        growth_pct

    Use LAG().

    Protect the percentage calculation against division by zero.

    Question:
    What problem occurs if a calendar month is completely absent from
    the source data?
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 5 - RUNNING REVENUE
==============================================================================*/

/*
    Return monthly Completed revenue plus:

        cumulative_revenue

    cumulative_revenue should be the running total from the first
    month through the current month.

    Use a window aggregate.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 6 - CUSTOMER REVENUE LEADERBOARD
==============================================================================*/

/*
    Return one row per customer with at least one Completed order:

        customer_id
        customer_name
        completed_orders
        units_purchased
        completed_revenue
        revenue_rank

    Rank customers from highest to lowest revenue.

    Use DENSE_RANK() for revenue_rank.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 7 - ALL CUSTOMERS WITH REVENUE
==============================================================================*/

/*
    Return ALL customers, including customers with no Completed orders.

    Columns:

        customer_id
        customer_name
        is_active
        completed_orders
        completed_revenue

    Zero-activity customers should display:

        completed_orders = 0
        completed_revenue = 0

    Be careful not to accidentally remove zero-activity customers with
    an incorrect WHERE filter.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 8 - CUSTOMERS WHO NEVER ORDERED
==============================================================================*/

/*
    Return customers who have never placed ANY order.

    Return:

        customer_id
        customer_name
        email
        signup_date

    Solve using NOT EXISTS.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 9 - CUSTOMERS WITH ORDERS BUT NO COMPLETED ORDERS
==============================================================================*/

/*
    Find customers who:

        have at least one order

    but:

        have zero Completed orders

    Return one row per customer.

    This is different from "customers who never ordered."
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 10 - REPEAT CUSTOMERS
==============================================================================*/

/*
    A repeat customer has at least:

        2 distinct Completed orders

    Return:

        customer_id
        customer_name
        completed_orders
        completed_revenue

    Sort by:

        completed_orders DESC
        completed_revenue DESC
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 11 - REPEAT CUSTOMER RATE
==============================================================================*/

/*
    Build a one-row report containing:

        completed_customers
        repeat_customers
        repeat_customer_rate_pct

    Denominator:

        Customers with at least one Completed order.

    Numerator:

        Customers with at least two Completed orders.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 12 - CUSTOMER LIFETIME METRICS
==============================================================================*/

/*
    Return one row per customer with Completed activity:

        customer_id
        customer_name
        first_completed_order_date
        latest_completed_order_date
        completed_orders
        completed_revenue
        average_order_value

    average_order_value:

        completed_revenue / completed_orders
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 13 - ORDER VALUE
==============================================================================*/

/*
    Build one row per Completed order:

        order_id
        customer_id
        order_date
        order_value

    order_value:

        SUM(quantity * unit_price)

    Do not calculate average or ranking yet.

    First establish the correct order grain.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 14 - LARGEST COMPLETED ORDERS
==============================================================================*/

/*
    Starting from one row per Completed order, return:

        order_id
        customer_id
        customer_name
        order_date
        order_value
        order_value_rank

    Rank orders from largest to smallest value.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 15 - CUSTOMER AVERAGE ORDER VALUE
==============================================================================*/

/*
    Return one row per customer with Completed orders:

        customer_id
        customer_name
        completed_orders
        completed_revenue
        average_order_value

    Important:

    Average order value means:

        total Completed revenue / Completed orders

    It does NOT mean:

        average order-item line value
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 16 - PRODUCT PERFORMANCE
==============================================================================*/

/*
    Return ALL products, including products with zero Completed sales.

    Columns:

        product_id
        product_name
        category
        units_sold
        completed_revenue

    Revenue must use order_items.unit_price.

    Zero-sale products should remain in the report.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 17 - TOP PRODUCTS BY REVENUE
==============================================================================*/

/*
    Return products with Completed sales:

        product_id
        product_name
        category
        units_sold
        completed_revenue
        revenue_rank

    Rank products globally by Completed revenue using DENSE_RANK().
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 18 - TOP 3 PRODUCTS PER CATEGORY
==============================================================================*/

/*
    Find the top 3 products by Completed revenue INSIDE each category.

    Return:

        category
        product_id
        product_name
        completed_revenue
        category_revenue_rank

    Use a window ranking function after product-level aggregation.

    Do not use a single global TOP (3).
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 19 - UNSOLD PRODUCTS
==============================================================================*/

/*
    Find products that have never appeared in a Completed order.

    Return:

        product_id
        product_name
        category
        price
        stock_quantity

    A product appearing only in Pending/Cancelled orders still counts as
    unsold for this challenge.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 20 - CATEGORY PERFORMANCE
==============================================================================*/

/*
    Return one row per category:

        category
        products_with_completed_sales
        units_sold
        completed_revenue
        revenue_rank

    Use Completed orders only.

    Rank categories from highest revenue to lowest.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 21 - PRODUCT PROFITABILITY
==============================================================================*/

/*
    Using Completed orders, return one row per sold product:

        product_id
        product_name
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct

    Definitions:

        revenue =
            quantity * unit_price

        estimated_cost =
            quantity * current products.cost

        estimated_gross_profit =
            revenue - estimated_cost

        estimated_gross_margin_pct =
            estimated_gross_profit / revenue * 100

    Protect against division by zero.

    Explain why this is estimated historical profit.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 22 - CATEGORY PROFITABILITY
==============================================================================*/

/*
    Return one row per category with Completed sales:

        category
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct

    Sort by estimated_gross_profit descending.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 23 - MOST PROFITABLE PRODUCTS
==============================================================================*/

/*
    Rank sold products using:

        estimated_gross_profit

    Return:

        product_id
        product_name
        category
        revenue
        estimated_gross_profit
        gross_profit_rank

    Use Completed transactions only.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 24 - HIGH REVENUE, LOW MARGIN
==============================================================================*/

/*
    Identify products that may look strong by revenue but weaker by margin.

    Build product-level Completed metrics:

        revenue
        estimated_gross_profit
        estimated_gross_margin_pct
        revenue_rank
        margin_rank

    Return all sold products so the rankings can be compared.

    Question:
    Why can revenue leadership differ substantially from profit leadership?
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 25 - CUSTOMER REVENUE CONCENTRATION
==============================================================================*/

/*
    Return one row per customer with Completed revenue:

        customer_id
        customer_name
        customer_revenue
        total_revenue
        revenue_share_pct
        cumulative_revenue
        cumulative_revenue_pct

    Sort customers from highest to lowest revenue.

    The cumulative values should follow that ranking.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 26 - CUSTOMER REVENUE QUARTILES
==============================================================================*/

/*
    Segment customers with Completed revenue into four groups using NTILE(4).

    Group:

        1 = highest-revenue customer group
        4 = lowest-revenue customer group

    Return:

        customer_id
        customer_name
        completed_revenue
        revenue_quartile

    Then aggregate the quartiles and return:

        revenue_quartile
        customer_count
        quartile_revenue
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 27 - FIRST AND LATEST COMPLETED ORDER
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        first_completed_order_date
        latest_completed_order_date

    for customers with Completed orders.

    Solve with aggregation.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 28 - DAYS BETWEEN FIRST AND LATEST PURCHASE
==============================================================================*/

/*
    Starting from first/latest Completed order dates, return:

        customer_id
        customer_name
        first_completed_order_date
        latest_completed_order_date
        customer_span_days

    customer_span_days:

        DATEDIFF(DAY, first_completed_order_date, latest_completed_order_date)
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 29 - DAYS BETWEEN CUSTOMER ORDERS
==============================================================================*/

/*
    For each Completed order, return:

        customer_id
        order_id
        order_date
        previous_completed_order_date
        days_since_previous_order

    Use LAG().

    The first Completed order for each customer should naturally have NULL
    for the previous order.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 30 - CUSTOMER PURCHASE SEQUENCE
==============================================================================*/

/*
    Number each customer's Completed orders chronologically.

    Return:

        customer_id
        order_id
        order_date
        purchase_number

    purchase_number = 1 for the customer's first Completed order.

    Use ROW_NUMBER() and a deterministic tie breaker.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 31 - NEW VS RETURNING MONTHLY CUSTOMERS
==============================================================================*/

/*
    For each activity month, return:

        activity_month
        new_customers
        returning_customers
        active_customers

    Definitions:

        New customer:
            activity month = month of first Completed order

        Returning customer:
            Completed activity in a month after their first Completed month

    Deduplicate customer-month activity before counting customers.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 32 - MONTHLY CUSTOMER MIX
==============================================================================*/

/*
    Extend Challenge 31 with:

        new_customer_pct
        returning_customer_pct

    Denominator:

        active customers in that month

    Protect percentage calculations against zero.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 33 - RFM BASE METRICS
==============================================================================*/

/*
    Create one row per customer with at least one Completed order:

        customer_id
        customer_name
        last_completed_order_date
        recency_days
        frequency
        monetary

    Definitions:

        reference_date =
            one day after MAX Completed order_date in the dataset

        recency_days =
            reference_date - customer's latest Completed order

        frequency =
            distinct Completed orders

        monetary =
            Completed revenue

    Do NOT use GETDATE() as the RFM reference date.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 34 - RFM SCORES
==============================================================================*/

/*
    Starting from the RFM base metrics, assign:

        recency_score
        frequency_score
        monetary_score

    using NTILE(5).

    Desired meaning:

        5 = strongest
        1 = weakest

    Remember:

        Lower recency_days is better.
        Higher frequency is better.
        Higher monetary is better.

    Handle ordering accordingly.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 35 - RFM SEGMENTS
==============================================================================*/

/*
    Build an RFM segmentation.

    Starting from RFM scores, create an rfm_segment column.

    You may use categories such as:

        Champions
        Loyal Customers
        Potential Loyalists
        At Risk
        Needs Attention
        Other

    Write the CASE logic clearly.

    This segmentation is a business rule, so document your chosen thresholds.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 36 - COHORT ASSIGNMENT
==============================================================================*/

/*
    Assign every customer with a Completed order to a cohort.

    Return:

        customer_id
        cohort_month

    cohort_month:

        Month-start date of first Completed order.

    One row per customer.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 37 - CUSTOMER-MONTH ACTIVITY
==============================================================================*/

/*
    Create one row per:

        customer_id
        activity_month

    for Completed activity.

    If a customer has multiple Completed orders in the same month,
    they must appear only once for that month.

    This dataset will be used for retention analysis.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 38 - COHORT ACTIVITY
==============================================================================*/

/*
    Combine:

        customer cohort
        customer-month activity

    Return:

        customer_id
        cohort_month
        activity_month
        cohort_age

    cohort_age:

        DATEDIFF(MONTH, cohort_month, activity_month)

    One row per customer/activity month.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 39 - COHORT RETENTION COUNTS
==============================================================================*/

/*
    Return:

        cohort_month
        cohort_age
        active_customers

    Use the deduplicated customer-month activity dataset.

    Do not count individual orders as active customers.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 40 - COHORT RETENTION RATE
==============================================================================*/

/*
    Extend Challenge 39.

    Return:

        cohort_month
        cohort_age
        cohort_size
        active_customers
        retention_rate_pct

    cohort_size:

        number of customers in the cohort at cohort_age = 0

    retention_rate_pct:

        active_customers / cohort_size * 100
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 41 - CONSECUTIVE-MONTH RETENTION
==============================================================================*/

/*
    For each activity month that has an observable next month, calculate:

        activity_month
        active_customers
        retained_next_month_customers
        next_month_retention_pct

    A customer is retained if they have Completed activity in:

        activity_month

    AND:

        DATEADD(MONTH, 1, activity_month)

    This is different from cohort retention.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 42 - DATASET BOUNDARY
==============================================================================*/

/*
    Find:

        first_completed_date
        latest_completed_date
        latest_completed_month

    Then explain:

    Why should the latest observed month usually not be classified as
    "churned next month" when the dataset contains no following month?
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 43 - 30-DAY INACTIVITY
==============================================================================*/

/*
    Using a deterministic reference date:

        one day after latest Completed order date

    return customers with Completed history and:

        customer_id
        customer_name
        last_completed_order_date
        days_inactive

    Filter to customers with:

        days_inactive >= 30

    This is an inactivity definition, not necessarily permanent churn.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 44 - CUSTOMER FUNNEL
==============================================================================*/

/*
    Build this funnel:

        1. Registered
        2. Placed Any Order
        3. Completed Customer
        4. Repeat Customer

    Return:

        stage_number
        stage_name
        customer_count

    Expected logical condition:

        Registered >= Ordered >= Completed >= Repeat
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 45 - FUNNEL CONVERSION RATES
==============================================================================*/

/*
    Extend the customer funnel with:

        previous_stage_count
        step_conversion_pct
        overall_conversion_pct

    Definitions:

        step_conversion_pct =
            current stage / previous stage

        overall_conversion_pct =
            current stage / Registered

    Registered stage has no previous stage.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 46 - CUSTOMER STATUS SEGMENTATION
==============================================================================*/

/*
    Place every registered customer into exactly ONE mutually exclusive segment:

        Never Ordered

        Ordered But Never Completed

        One-Time Completed Customer

        Repeat Customer

    Definitions:

        One-Time Completed Customer:
            exactly 1 Completed order

        Repeat Customer:
            >= 2 Completed orders

    Return:

        customer_id
        customer_name
        customer_segment

    Validate that every customer appears exactly once.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 47 - SEGMENT SUMMARY
==============================================================================*/

/*
    Starting from Challenge 46, return:

        customer_segment
        customer_count
        customer_pct

    customer_pct uses all registered customers as denominator.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 48 - CITY PERFORMANCE
==============================================================================*/

/*
    Return one row per customer city:

        city
        registered_customers
        completed_customers
        completed_orders
        completed_revenue

    Include cities whose customers generated zero Completed revenue.

    Be careful with row multiplication when counting customers and orders.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 49 - CITY CONVERSION RATE
==============================================================================*/

/*
    Extend city analysis with:

        completion_conversion_pct

    Formula:

        customers with >= 1 Completed order
        ------------------------------------
        registered customers in city

    Protect against division by zero.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 50 - CUSTOMER CATEGORY PREFERENCES
==============================================================================*/

/*
    Calculate Completed revenue by:

        customer_id
        category

    Return:

        customer_id
        customer_name
        category
        category_revenue
        category_rank_for_customer

    Rank each customer's categories from highest Completed revenue to lowest.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 51 - FAVORITE CATEGORY
==============================================================================*/

/*
    Return each customer with Completed purchases and their top category.

    Columns:

        customer_id
        customer_name
        favorite_category
        category_revenue

    Tie rule:

        If multiple categories tie, use category alphabetically as a
        deterministic tie breaker and return exactly one row per customer.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 52 - PRODUCT CUSTOMER PENETRATION
==============================================================================*/

/*
    For each product with Completed sales, return:

        product_id
        product_name
        distinct_buyers
        total_completed_customers
        customer_penetration_pct

    customer_penetration_pct:

        customers who bought product
        ----------------------------
        all customers with >= 1 Completed order
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 53 - PRODUCTS BOUGHT TOGETHER
==============================================================================*/

/*
    Find product pairs appearing in the same Completed order.

    Return:

        product_id_1
        product_name_1
        product_id_2
        product_name_2
        orders_together

    Requirements:

    - Do not pair a product with itself.
    - Do not produce both (A, B) and (B, A).
    - Count distinct Completed orders containing the pair.

    Hint:
        Self-join order_items within the same order and enforce:

            product_id_1 < product_id_2
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 54 - CUSTOMER PRODUCT DIVERSITY
==============================================================================*/

/*
    Return one row per customer with Completed orders:

        customer_id
        customer_name
        distinct_products_purchased
        distinct_categories_purchased

    Use distinct counts at the correct grain.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 55 - CUSTOMER ORDER FREQUENCY
==============================================================================*/

/*
    For customers with at least 2 Completed orders, return:

        customer_id
        customer_name
        completed_orders
        first_completed_order_date
        latest_completed_order_date
        active_span_days
        average_days_between_orders

    Define average_days_between_orders as:

        active_span_days / (completed_orders - 1)

    Protect against invalid division.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 56 - REVENUE ABOVE CUSTOMER AVERAGE
==============================================================================*/

/*
    First calculate Completed order values.

    Then, for every Completed order, return:

        order_id
        customer_id
        order_date
        order_value
        customer_average_order_value

    Keep only orders where:

        order_value > customer's average Completed order value

    Use an analytical/window approach or a multi-step CTE.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 57 - PRODUCTS ABOVE CATEGORY AVERAGE
==============================================================================*/

/*
    Calculate Completed revenue per product.

    Then return products whose revenue is greater than the average
    product revenue inside their category.

    Return:

        category
        product_id
        product_name
        product_revenue
        category_average_product_revenue
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 58 - MONTHLY PRODUCT LEADER
==============================================================================*/

/*
    For every month with Completed sales, find the product with the
    highest Completed revenue.

    Return exactly one product per month:

        revenue_month
        product_id
        product_name
        product_revenue

    Tie breaker:

        product_id ASC

    Steps:

        1. Aggregate to month/product.
        2. Rank within month.
        3. Keep rank/row number 1.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 59 - CUSTOMER'S LARGEST ORDER
==============================================================================*/

/*
    Return one row per customer with Completed orders:

        customer_id
        customer_name
        order_id
        order_date
        order_value

    Keep the customer's largest Completed order.

    Tie breaker:

        latest order_date
        then highest order_id
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 60 - REVENUE GROWTH BY CATEGORY
==============================================================================*/

/*
    Return category revenue by month and calculate growth from the
    category's previous observed month.

    Columns:

        category
        revenue_month
        monthly_revenue
        previous_revenue
        growth_pct

    Partition LAG() by category.

    Explain the missing-month caveat.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 61 - MONTHLY PROFIT TREND
==============================================================================*/

/*
    For Completed sales, return monthly:

        revenue_month
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct

    Use current products.cost and document the historical-cost limitation.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 62 - CUMULATIVE CUSTOMER VALUE
==============================================================================*/

/*
    For each customer and each Completed order, return:

        customer_id
        order_id
        order_date
        order_value
        cumulative_customer_revenue

    Steps:

        1. Calculate one row per order.
        2. Use SUM() OVER() partitioned by customer.
        3. Use deterministic chronological ordering.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 63 - CUSTOMER REVENUE PERCENTILE GROUP
==============================================================================*/

/*
    Using one row per customer with Completed revenue, divide customers
    into 10 revenue groups using NTILE(10).

    Group 1 should contain the highest-revenue customers.

    Return:

        customer_id
        customer_name
        completed_revenue
        revenue_decile

    Question:
    Why does NTILE divide customers rather than guarantee exactly 10% of
    total revenue in each group?
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 64 - TOP CUSTOMER REVENUE SHARE
==============================================================================*/

/*
    Rank customers from highest to lowest Completed revenue.

    Return:

        customer_id
        customer_name
        completed_revenue
        customer_number
        total_customers
        revenue_share_pct
        cumulative_revenue_share_pct

    Use the result to identify how concentrated revenue is among top customers.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 65 - ORDER STATUS SUMMARY
==============================================================================*/

/*
    Return one row per order_status:

        order_status
        orders
        customers
        item_lines
        units
        order_item_value

    Important:

    order_item_value here is the value associated with that status.

    Do NOT call Pending/Cancelled value "Revenue" unless the business explicitly
    defines it that way.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 66 - CANCELLATION ANALYSIS
==============================================================================*/

/*
    Return one row per customer:

        customer_id
        customer_name
        total_orders
        cancelled_orders
        cancellation_rate_pct

    Include customers who have no orders.

    Define:

        cancellation_rate_pct =
            cancelled_orders / total_orders * 100

    Avoid counting order_items.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 67 - ACTIVE CUSTOMER HEALTH REPORT
==============================================================================*/

/*
    Return all customers where is_active = 1.

    Columns:

        customer_id
        customer_name
        signup_date
        total_orders
        completed_orders
        latest_completed_order_date
        completed_revenue
        customer_status

    customer_status rules:

        Never Ordered
        Ordered, Never Completed
        One-Time Buyer
        Repeat Buyer

    Keep one row per active customer.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 68 - INVENTORY VALUE
==============================================================================*/

/*
    This challenge is about current inventory, not sales.

    Return one row per product:

        product_id
        product_name
        category
        stock_quantity
        cost
        price
        inventory_cost_value
        potential_retail_value
        potential_gross_profit

    Definitions:

        inventory_cost_value =
            stock_quantity * cost

        potential_retail_value =
            stock_quantity * price

        potential_gross_profit =
            stock_quantity * (price - cost)

    Do not confuse potential inventory value with realized revenue.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 69 - CATEGORY INVENTORY VALUE
==============================================================================*/

/*
    Aggregate current inventory by category.

    Return:

        category
        products
        total_units_in_stock
        inventory_cost_value
        potential_retail_value
        potential_gross_profit
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 70 - LOW STOCK PRIORITY
==============================================================================*/

/*
    Create a current-stock report.

    Return:

        product_id
        product_name
        category
        stock_quantity
        units_sold_completed
        stock_priority

    Example business rules:

        stock_quantity = 0
            -> Out of Stock

        stock_quantity <= 5
            -> Critical

        stock_quantity <= 10
            -> Low

        otherwise
            -> Healthy

    Include products with no Completed sales.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 71 - EXECUTIVE CUSTOMER + REVENUE DASHBOARD
==============================================================================*/

/*
    Build ONE row containing:

        registered_customers
        active_registered_customers
        customers_with_any_order
        completed_customers
        repeat_customers
        completed_orders
        units_sold
        completed_revenue
        average_order_value
        repeat_customer_rate_pct

    Make sure each metric follows the definitions in README.md.

    This is an integrated challenge.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 72 - EXECUTIVE PRODUCT DASHBOARD
==============================================================================*/

/*
    Build ONE row containing:

        total_products
        active_products
        products_with_completed_sales
        units_sold
        completed_revenue
        estimated_gross_profit
        estimated_gross_margin_pct

    Profit uses current products.cost and is therefore estimated.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 73 - MONTHLY EXECUTIVE DASHBOARD
==============================================================================*/

/*
    Return one row per Completed activity month:

        revenue_month
        completed_orders
        purchasing_customers
        units_sold
        revenue
        estimated_gross_profit
        average_order_value
        previous_month_revenue
        revenue_growth_pct
        cumulative_revenue

    This challenge combines:

        aggregation
        CTEs
        LAG()
        running totals
        safe division
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 74 - DATA QUALITY VALIDATION
==============================================================================*/

/*
    Write separate validation queries for:

    A. Orders referencing missing customers.

    B. Order items referencing missing orders.

    C. Order items referencing missing products.

    D. Non-positive order-item quantities.

    E. Negative order-item unit prices.

    F. Negative product stock.

    G. Duplicate customer emails.

    Even if database constraints already prevent some issues, write the
    diagnostic queries.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 75 - FUNNEL VALIDATION
==============================================================================*/

/*
    Calculate:

        registered
        ordered
        completed
        repeat

    Then produce a validation result:

        PASS

    when:

        registered >= ordered
        AND ordered >= completed
        AND completed >= repeat

    otherwise:

        FAIL

    Return the four counts plus validation_status.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 76 - REVENUE RECONCILIATION
==============================================================================*/

/*
    Calculate total Completed revenue in TWO independent ways.

    Method A:
        Directly from Completed order items.

    Method B:
        First aggregate one row per Completed order,
        then SUM(order_value).

    Return:

        direct_revenue
        order_level_revenue
        difference
        validation_status

    Expected:

        difference = 0

    This is an important analytics validation technique.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 77 - CUSTOMER REVENUE RECONCILIATION
==============================================================================*/

/*
    Calculate total Completed revenue:

    A. Directly from Completed transactions.

    B. By first calculating one row per customer and then summing
       customer revenue.

    Compare the totals.

    The totals should reconcile.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 78 - PERFORMANCE REVIEW
==============================================================================*/

/*
    Take this business query:

        Completed revenue per customer.

    Tasks:

    1. Write the correct query.
    2. State the final grain.
    3. Identify all join/filter columns.
    4. Inspect existing indexes.
    5. Enable STATISTICS IO.
    6. Enable STATISTICS TIME.
    7. Inspect Actual Execution Plan.
    8. Identify whether predicates are SARGable.
    9. Propose reasonable indexes for a much larger dataset.
    10. Explain the write cost of those indexes.

    Do not blindly create indexes just because this challenge asks you
    to discuss them.
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 79 - FIX THE BROKEN BUSINESS QUERY
==============================================================================*/

/*
    Someone wrote:

        SELECT
            c.customer_id,
            c.customer_name,
            COUNT(o.order_id) AS orders,
            SUM(p.price * oi.quantity) AS revenue
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

    Requirement:

        Return ALL customers with:

            distinct Completed orders
            Completed transaction revenue

    Identify every important logical problem.

    Then write the corrected query.

    Consider:

        LEFT JOIN behavior
        WHERE filtering
        order row multiplication
        current price vs transaction price
        zero-activity customers
*/

-- Write your solution below:




/*==============================================================================
    CHALLENGE 80 - FINAL BUSINESS CASE STUDY
==============================================================================*/

/*
    Build a customer performance report containing ONE row per registered
    customer.

    Required columns:

        customer_id
        customer_name
        city
        signup_date
        is_active

        total_orders
        completed_orders
        cancelled_orders

        first_completed_order_date
        latest_completed_order_date

        completed_units
        completed_revenue
        average_order_value

        estimated_gross_profit
        estimated_gross_margin_pct

        distinct_products_purchased
        distinct_categories_purchased

        customer_segment
        completed_revenue_rank

    Customer segments:

        Never Ordered

        Ordered But Never Completed

        One-Time Completed Customer

        Repeat Customer

    Requirements:

    1. Every registered customer must appear exactly once.

    2. Revenue must use:
           order_items.unit_price

    3. Estimated cost/profit must use:
           products.cost

    4. Order counts must not be multiplied by order-item joins.

    5. Customers with no activity must display zero where zero is
       semantically appropriate.

    6. Customers without Completed orders should have NULL first/latest
       Completed dates.

    7. Revenue rank should rank customers with positive Completed revenue.

       Decide/document how customers with zero Completed revenue should
       be represented.

    8. average_order_value:
           completed_revenue / completed_orders

    9. gross margin:
           estimated_gross_profit / completed_revenue * 100

    10. Validate:
           output row count = registered customer count

    Suggested architecture:

        Order-level metrics
            +
        Completed transaction metrics
            +
        Product/category diversity
            +
        Customer aggregation
            +
        Final customer join
            +
        Ranking

    This challenge intentionally combines most major SQL concepts in the
    repository.
*/

-- Write your solution below:




/*==============================================================================
    FINAL VALIDATION CHECKLIST
==============================================================================*/

/*
    Before considering your solutions complete, verify:

    [ ] Revenue uses order_items.unit_price.

    [ ] Revenue includes Completed orders only unless explicitly stated.

    [ ] Order counts are not multiplied by order_items.

    [ ] Repeat customers require >= 2 distinct Completed orders.

    [ ] Zero-activity entities remain when the requirement says "all."

    [ ] LEFT JOIN filters do not accidentally eliminate unmatched rows.

    [ ] Result grain matches each business requirement.

    [ ] Percentages protect against zero denominators.

    [ ] RFM reference date is deterministic.

    [ ] Cohort activity uses deduplicated customer-month rows.

    [ ] Churn/retention logic respects dataset boundaries.

    [ ] Profit is labeled estimated because historical cost is unavailable.

    [ ] Ranking uses deterministic tie breakers where exactly one row is needed.

    [ ] Missing months are considered in growth analysis.

    [ ] Business metrics are reconciled where possible.

    [ ] Performance changes never alter business correctness.
*/


/*==============================================================================
    END OF BUSINESS CHALLENGES

    Total Challenges:
        80

    Next file:
        business_challenges/solutions.sql
==============================================================================*/