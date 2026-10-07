/*==============================================================================
    SQL Mastery
    Practice Exercises - Advanced
    File: exercises.sql
    Database: SQLMastery
    Schema: training

    Topics:
    - Advanced analytical SQL
    - Multi-stage CTE pipelines
    - RFM
    - Cohorts
    - Retention
    - Churn / inactivity
    - Funnels
    - Revenue concentration
    - Profitability
    - Market-basket analysis
    - Reconciliation
    - Transactions and ACID
    - Concurrency reasoning
    - Indexes
    - SARGability
    - Execution plans
    - Performance tuning
    - Integrated business analysis

    IMPORTANT:
    Correctness and business definitions come before performance.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    EXERCISE 1 - EXECUTIVE KPI REPORT
==============================================================================*/

/*
    Build ONE row containing:

        registered_customers
        active_customers
        customers_with_any_order
        completed_customers
        repeat_customers
        completed_orders
        units_sold
        completed_revenue
        average_order_value
        repeat_customer_rate_pct

    Definitions:

        Repeat = >= 2 Completed orders

        Revenue =
            Completed quantity * unit_price

    Ensure order-item joins do not inflate order/customer counts.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 2 - MONTHLY BUSINESS DASHBOARD
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

    Use current products.cost for estimated profit.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 3 - CUSTOMER LIFETIME VALUE REPORT
==============================================================================*/

/*
    Return one row per customer with Completed purchases:

        customer_id
        customer_name
        first_completed_order_date
        latest_completed_order_date
        completed_orders
        completed_units
        completed_revenue
        average_order_value
        estimated_gross_profit
        customer_span_days

    Ensure order counts are not multiplied by item lines.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 4 - CUSTOMER VALUE RANK
==============================================================================*/

/*
    Extend customer lifetime metrics with:

        revenue_rank
        profit_rank

    Use DENSE_RANK().

    Compare whether the highest-revenue customers are necessarily the
    highest-profit customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 5 - CUSTOMER REVENUE CONCENTRATION
==============================================================================*/

/*
    Return customers ordered by Completed revenue descending.

    Columns:

        customer_id
        customer_name
        completed_revenue
        customer_number
        total_customers
        revenue_share_pct
        cumulative_revenue
        cumulative_revenue_pct

    Use window functions.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 6 - REVENUE DECILES
==============================================================================*/

/*
    Divide customers with Completed revenue into 10 approximately
    equal-sized customer groups.

    Group 1 = highest revenue.

    Return:

        customer_id
        customer_name
        completed_revenue
        revenue_decile

    Explain why NTILE(10) does not mean each group contributes 10%
    of revenue.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 7 - DECILE SUMMARY
==============================================================================*/

/*
    Aggregate Exercise 6.

    Return:

        revenue_decile
        customers
        decile_revenue
        revenue_share_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 8 - RFM REFERENCE DATE
==============================================================================*/

/*
    Return ONE row:

        latest_completed_order_date
        rfm_reference_date

    rfm_reference_date:

        one day after latest Completed order date.

    Do not use GETDATE().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 9 - RFM BASE
==============================================================================*/

/*
    Return one row per customer with Completed history:

        customer_id
        customer_name
        last_completed_order_date
        recency_days
        frequency
        monetary

    Definitions:

        recency =
            days between latest Completed order and reference date

        frequency =
            distinct Completed orders

        monetary =
            Completed revenue
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 10 - RFM SCORES
==============================================================================*/

/*
    Assign 1-5 scores using NTILE(5):

        recency_score
        frequency_score
        monetary_score

    Desired interpretation:

        5 = strongest
        1 = weakest

    Remember:

        smaller recency_days = better
        larger frequency = better
        larger monetary = better
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 11 - RFM SEGMENTS
==============================================================================*/

/*
    Starting from the scores, assign:

        Champions
        Loyal Customers
        Potential Loyalists
        At Risk
        Needs Attention
        Other

    Define your CASE thresholds clearly in comments.

    There is no universal RFM segmentation rule.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 12 - RFM SEGMENT SUMMARY
==============================================================================*/

/*
    Return:

        rfm_segment
        customers
        segment_revenue
        average_recency
        average_frequency
        average_monetary

    Use the RFM segmentation from Exercise 11.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 13 - COHORT ASSIGNMENT
==============================================================================*/

/*
    Assign customers with Completed history to:

        cohort_month

    Definition:

        month of first Completed order.

    Return:

        customer_id
        cohort_month
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 14 - CUSTOMER-MONTH ACTIVITY
==============================================================================*/

/*
    Return deduplicated Completed activity:

        customer_id
        activity_month

    One row per customer/month.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 15 - COHORT ACTIVITY
==============================================================================*/

/*
    Combine cohort assignment and customer-month activity.

    Return:

        customer_id
        cohort_month
        activity_month
        cohort_age

    cohort_age:

        DATEDIFF(MONTH, cohort_month, activity_month)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 16 - COHORT SIZES
==============================================================================*/

/*
    Return:

        cohort_month
        cohort_size

    Count each customer once.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 17 - COHORT RETENTION COUNTS
==============================================================================*/

/*
    Return:

        cohort_month
        cohort_age
        active_customers

    Count active customers, not orders.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 18 - COHORT RETENTION RATES
==============================================================================*/

/*
    Return:

        cohort_month
        cohort_age
        cohort_size
        active_customers
        retention_rate_pct

    retention:

        active_customers / cohort_size * 100
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 19 - COHORT RETENTION MATRIX SOURCE
==============================================================================*/

/*
    Produce a result suitable for building a retention heatmap:

        cohort_month
        month_0
        month_1
        month_2
        month_3

    Each month_N should contain retention percentage for that cohort age.

    Use conditional aggregation over the cohort-retention result.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 20 - CONSECUTIVE-MONTH RETENTION
==============================================================================*/

/*
    For every observable activity month:

        activity_month
        active_customers
        retained_next_month_customers
        next_month_retention_pct

    A customer is retained when they appear in:

        activity_month

    and:

        DATEADD(MONTH, 1, activity_month)

    Do not classify the latest dataset month when the next month is
    unavailable.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 21 - DATASET OBSERVATION BOUNDARY
==============================================================================*/

/*
    Return:

        first_completed_date
        latest_completed_date
        latest_completed_month

    Explain in comments what right-censoring means for retention/churn.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 22 - 30-DAY INACTIVITY
==============================================================================*/

/*
    Using the deterministic RFM reference date, return customers where:

        days_inactive >= 30

    Columns:

        customer_id
        customer_name
        last_completed_order_date
        days_inactive

    Label this inactivity, not permanent churn.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 23 - 60-DAY INACTIVITY
==============================================================================*/

/*
    Repeat Exercise 22 using:

        days_inactive >= 60
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 24 - INACTIVITY SEGMENT
==============================================================================*/

/*
    Segment customers with Completed history by recency:

        0-29 days   -> Recent
        30-59 days  -> Watch
        60-89 days  -> At Risk
        90+ days    -> Highly Inactive

    Use the deterministic reference date.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 25 - FUNNEL
==============================================================================*/

/*
    Build:

        1. Registered
        2. Placed Any Order
        3. Completed Customer
        4. Repeat Customer

    Return:

        stage_number
        stage_name
        customer_count

    Expected:

        Registered >= Ordered >= Completed >= Repeat
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 26 - FUNNEL CONVERSION
==============================================================================*/

/*
    Extend the funnel:

        previous_stage_count
        step_conversion_pct
        overall_conversion_pct

    overall denominator:

        Registered
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 27 - FUNNEL VALIDATION
==============================================================================*/

/*
    Return one row:

        registered
        ordered
        completed
        repeat_customers
        validation_status

    PASS when:

        registered >= ordered
        AND ordered >= completed
        AND completed >= repeat
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 28 - CUSTOMER SEGMENTATION
==============================================================================*/

/*
    Place every registered customer into exactly one segment:

        Never Ordered
        Ordered But Never Completed
        One-Time Completed Customer
        Repeat Customer

    Return one row per customer.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 29 - SEGMENT BUSINESS SUMMARY
==============================================================================*/

/*
    For each customer segment return:

        customer_segment
        customers
        completed_revenue
        revenue_share_pct

    Segments without Completed revenue should remain.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 30 - FAVORITE PRODUCT CATEGORY
==============================================================================*/

/*
    For every customer with Completed purchases, return exactly one:

        customer_id
        customer_name
        favorite_category
        category_revenue

    Tie breaker:
        category ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 31 - CUSTOMER CATEGORY SHARE
==============================================================================*/

/*
    Return Completed revenue by customer/category:

        customer_id
        category
        category_revenue
        customer_revenue
        category_share_pct

    Use a partitioned window SUM.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 32 - PRODUCT CUSTOMER PENETRATION
==============================================================================*/

/*
    For each product with Completed sales:

        product_id
        product_name
        distinct_buyers
        completed_customers
        penetration_pct

    Denominator:
        all customers with >= 1 Completed order.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 33 - PRODUCT PAIRS
==============================================================================*/

/*
    Find products appearing together in the same Completed order.

    Return:

        product_id_1
        product_name_1
        product_id_2
        product_name_2
        orders_together

    Rules:

        no self-pairs
        no (A,B) and (B,A) duplicates
        deduplicate order/product before pairing
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 34 - MOST COMMON PRODUCT PAIR
==============================================================================*/

/*
    Starting from product-pair counts, return the pair(s) having the
    highest orders_together.

    Return all ties.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 35 - PRODUCT PROFITABILITY
==============================================================================*/

/*
    Return sold products:

        product_id
        product_name
        category
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct

    Completed only.

    Document the current-cost caveat.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 36 - PROFIT RANK WITHIN CATEGORY
==============================================================================*/

/*
    Rank products inside their category by:

        estimated_gross_profit

    Return:

        category
        product_id
        product_name
        estimated_gross_profit
        category_profit_rank
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 37 - HIGH REVENUE VS HIGH PROFIT
==============================================================================*/

/*
    Return sold products with:

        revenue
        estimated_gross_profit
        revenue_rank
        profit_rank
        rank_difference

    rank_difference:

        revenue_rank - profit_rank

    Use global DENSE_RANK().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 38 - MONTHLY PROFIT TREND
==============================================================================*/

/*
    Return:

        revenue_month
        revenue
        estimated_cost
        estimated_gross_profit
        estimated_gross_margin_pct
        previous_profit
        profit_growth_pct

    Use LAG() after monthly aggregation.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 39 - CATEGORY MONTHLY GROWTH
==============================================================================*/

/*
    Return Completed revenue by category/month:

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
    EXERCISE 40 - MONTHLY PRODUCT LEADER
==============================================================================*/

/*
    Find exactly one highest-revenue product per Completed activity month.

    Return:

        revenue_month
        product_id
        product_name
        product_revenue

    Tie breaker:
        product_id ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 41 - CUSTOMER'S LARGEST ORDER
==============================================================================*/

/*
    Return exactly one largest Completed order per customer.

    Tie breakers:

        order_value DESC
        order_date DESC
        order_id DESC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 42 - CUMULATIVE CUSTOMER VALUE
==============================================================================*/

/*
    Return every Completed order:

        customer_id
        order_id
        order_date
        order_value
        cumulative_customer_revenue

    Calculate order value before applying the running total.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 43 - CUSTOMER ORDER VELOCITY
==============================================================================*/

/*
    For customers with at least two Completed orders, return:

        customer_id
        completed_orders
        first_completed_order_date
        latest_completed_order_date
        active_span_days
        average_days_between_orders

    Define:

        average_days_between_orders =
            active_span_days / (completed_orders - 1)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 44 - ORDER GAP STATISTICS
==============================================================================*/

/*
    Using LAG(), calculate customer order gaps.

    Then return per customer:

        completed_orders_with_previous
        average_gap_days
        minimum_gap_days
        maximum_gap_days
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 45 - DATA QUALITY: ORPHANS
==============================================================================*/

/*
    Write three validation queries:

    A. Orders referencing missing customers.
    B. Order items referencing missing orders.
    C. Order items referencing missing products.

    Use LEFT JOIN + IS NULL or NOT EXISTS.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 46 - DATA QUALITY: INVALID VALUES
==============================================================================*/

/*
    Write validation queries for:

        quantity <= 0
        unit_price < 0
        stock_quantity < 0
        price < 0
        cost < 0
        duplicate customer emails
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 47 - REVENUE RECONCILIATION
==============================================================================*/

/*
    Calculate Completed revenue at three independent grains:

        direct transaction revenue
        sum of order-level revenue
        sum of customer-level revenue

    Return:

        transaction_revenue
        order_level_revenue
        customer_level_revenue
        validation_status

    PASS only when all three match.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 48 - PRODUCT REVENUE RECONCILIATION
==============================================================================*/

/*
    Compare:

        direct Completed revenue

    against:

        revenue aggregated first per product and then re-summed.

    Return difference and PASS/FAIL.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 49 - TRANSACTION BASICS
==============================================================================*/

/*
    Create a training-safe explicit transaction:

        1. Read product_id = 1 stock.
        2. BEGIN TRANSACTION.
        3. Reduce stock by 1.
        4. Read temporary stock.
        5. ROLLBACK.
        6. Read stock again.

    Verify rollback restored the original value.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 50 - ROBUST TRANSACTION TEMPLATE
==============================================================================*/

/*
    Write a safe demonstration containing:

        SET XACT_ABORT ON
        BEGIN TRY
        BEGIN TRANSACTION
        UPDATE
        ROLLBACK for training safety
        BEGIN CATCH
        XACT_STATE
        ROLLBACK
        THROW

    Do not permanently modify data.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 51 - ATOMIC INVENTORY
==============================================================================*/

/*
    Variables:

        @ProductId = 1
        @Quantity = 2

    Reduce inventory only when:

        stock_quantity >= @Quantity

    Capture @@ROWCOUNT immediately.

    Throw an error when zero rows were updated.

    Use a transaction and ROLLBACK for training safety.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 52 - FAILED INVENTORY REQUEST
==============================================================================*/

/*
    Request:

        @Quantity = 1000000

    Use the atomic inventory pattern.

    The business error should be caught and displayed.

    Ensure no transaction remains open.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 53 - SAVEPOINT
==============================================================================*/

/*
    In one transaction:

        update product 1
        create savepoint
        update product 2
        rollback to savepoint
        inspect products
        rollback entire transaction

    Explain which update remains after rollback-to-savepoint and before
    the final rollback.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 54 - SAFE ORDER CREATION
==============================================================================*/

/*
    Simulate checkout:

        @CustomerId = 1
        @ProductId = 1
        @Quantity = 2

    Requirements:

        active customer exists
        active product exists
        quantity > 0
        sufficient stock
        atomic inventory reduction
        create Pending order
        capture SCOPE_IDENTITY()
        create order item
        use current product price as transaction unit_price
        rollback training success
        rollback any failure

    Use TRY/CATCH and XACT_ABORT.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 55 - ACID
==============================================================================*/

/*
    Match these descriptions:

    A. All checkout changes succeed or all fail.

    B. A committed transaction survives recovery.

    C. Constraints/business logic maintain valid database states.

    D. Concurrent transactions follow defined visibility rules.

    Write the corresponding ACID property in comments.
*/




/*==============================================================================
    EXERCISE 56 - DIRTY READ REASONING
==============================================================================*/

/*
    Explain:

    1. What is a dirty read?
    2. Which isolation level permits it?
    3. Why can it produce incorrect business reports?
*/




/*==============================================================================
    EXERCISE 57 - NON-REPEATABLE READ
==============================================================================*/

/*
    Describe a two-session example using:

        products.stock_quantity

    where one transaction reads the same row twice but gets different
    committed values.
*/




/*==============================================================================
    EXERCISE 58 - PHANTOM READ
==============================================================================*/

/*
    Describe a two-session example using:

        SELECT *
        FROM training.orders
        WHERE customer_id = 1;

    Explain how another transaction could create a phantom row.
*/




/*==============================================================================
    EXERCISE 59 - DEADLOCK
==============================================================================*/

/*
    Transaction A:
        Product 1 -> Product 2

    Transaction B:
        Product 2 -> Product 1

    Explain:

        why deadlock can occur
        what SQL Server does
        how consistent resource order helps
        why retry logic can be appropriate
*/




/*==============================================================================
    EXERCISE 60 - SHORT TRANSACTIONS
==============================================================================*/

/*
    Explain why these should normally not unnecessarily occur while a
    database transaction remains open:

        human approval
        external API request
        multi-minute sleep

    Connect your answer to locks, blocking, and concurrency.
*/




/*==============================================================================
    EXERCISE 61 - INSPECT INDEXES
==============================================================================*/

/*
    List indexes for:

        customers
        products
        orders
        order_items

    Return:

        schema_name
        table_name
        index_name
        type_desc
        is_unique
        is_primary_key
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 62 - INSPECT INDEX COLUMNS
==============================================================================*/

/*
    Use:

        sys.indexes
        sys.index_columns
        sys.columns

    Return key and included columns for the core tables.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 63 - SARGABILITY
==============================================================================*/

/*
    Rewrite:

        WHERE YEAR(order_date) = 2025

    as a SARGable half-open date range.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 64 - COMPOSITE INDEX DESIGN
==============================================================================*/

/*
    Important query:

        SELECT
            order_id,
            order_date,
            order_status
        FROM training.orders
        WHERE customer_id = @CustomerId
          AND order_date >= @StartDate
          AND order_date < @EndDate
        ORDER BY order_date DESC;

    Propose an index.

    Explain:

        key order
        equality predicate
        range predicate
        INCLUDE
        sorting support
*/




/*==============================================================================
    EXERCISE 65 - COVERING INDEX
==============================================================================*/

/*
    Explain how an index such as:

        (customer_id, order_date)
        INCLUDE(order_status)

    can cover an appropriate orders query.

    What is the trade-off of adding INCLUDE columns?
*/




/*==============================================================================
    EXERCISE 66 - KEY LOOKUP
==============================================================================*/

/*
    Explain:

        what a Key Lookup is
        why a few lookups may be fine
        why many lookups can be expensive
        how a covering index may help
*/




/*==============================================================================
    EXERCISE 67 - STATISTICS IO
==============================================================================*/

/*
    Enable STATISTICS IO.

    Run a Completed revenue-per-customer query.

    Disable STATISTICS IO.

    Explain what logical reads represent.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 68 - STATISTICS TIME
==============================================================================*/

/*
    Enable STATISTICS TIME around the same business query.

    Explain why one timing measurement is insufficient evidence.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 69 - ACTUAL EXECUTION PLAN REVIEW
==============================================================================*/

/*
    Run a Completed revenue-per-customer query with Actual Execution Plan.

    Record in comments:

        access operators
        join algorithms
        estimated rows
        actual rows
        scans/seeks
        sorts
        lookups
        warnings

    Results depend on your SQL Server environment.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 70 - ESTIMATES
==============================================================================*/

/*
    Explain why:

        estimated rows = 10
        actual rows = 1,000,000

    can lead to a poor execution plan.

    Mention:

        join strategy
        memory grants
        access paths
*/




/*==============================================================================
    EXERCISE 71 - MISSING INDEX SUGGESTION
==============================================================================*/

/*
    An execution plan suggests a new index.

    List at least FIVE questions you should ask before creating it.

    Include:

        existing indexes
        overlap
        query importance
        write cost
        storage
        broader workload
*/




/*==============================================================================
    EXERCISE 72 - OVER-INDEXING
==============================================================================*/

/*
    Explain why adding indexes can hurt:

        INSERT
        UPDATE
        DELETE

    Mention:

        storage
        memory
        transaction log
        maintenance
*/




/*==============================================================================
    EXERCISE 73 - INDEX USAGE DMV
==============================================================================*/

/*
    Query:

        sys.dm_db_index_usage_stats

    for the four training tables.

    Return:

        table_name
        index_name
        user_seeks
        user_scans
        user_lookups
        user_updates

    Explain why counters are not permanent history.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 74 - INDEX PHYSICAL STATS
==============================================================================*/

/*
    Use:

        sys.dm_db_index_physical_stats

    in LIMITED mode.

    Return:

        table_name
        index_name
        avg_fragmentation_in_percent
        page_count

    Explain why a tiny index with high fragmentation percentage may not
    deserve maintenance.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 75 - PARAMETER SENSITIVITY
==============================================================================*/

/*
    Consider:

        WHERE customer_id = @CustomerId

    Customer A:
        2 matching rows

    Customer B:
        5,000,000 matching rows

    Explain why one cached plan may not be ideal for both.

    Mention OPTION(RECOMPILE) as one possible tool and its trade-off.
*/




/*==============================================================================
    EXERCISE 76 - PERFORMANCE BASELINE
==============================================================================*/

/*
    Create a baseline block for:

        Completed revenue per customer.

    Use:

        SET STATISTICS IO
        SET STATISTICS TIME

    Also list in comments what you would capture from the Actual Plan
    before tuning.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 77 - FIX PERFORMANCE ANTI-PATTERNS
==============================================================================*/

/*
    Review:

        SELECT DISTINCT *
        FROM training.orders
        WHERE YEAR(order_date) = 2025
        ORDER BY order_date;

    Requirement:

        Return:
            order_id
            customer_id
            order_date
            order_status

        for orders during 2025.

    Rewrite the query.

    Explain the issues with:

        SELECT *
        unnecessary DISTINCT
        YEAR(order_date)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 78 - COMPLETE BUSINESS RECONCILIATION
==============================================================================*/

/*
    Calculate Completed revenue through:

        direct transactions
        order grain
        customer grain
        product grain

    Return ONE row:

        transaction_revenue
        order_revenue
        customer_revenue
        product_revenue
        validation_status

    All totals must match for PASS.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 79 - ADVANCED CUSTOMER REPORT
==============================================================================*/

/*
    Return exactly one row per registered customer:

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

        distinct_products
        distinct_categories

        customer_segment
        revenue_rank

    Segment:

        Never Ordered
        Ordered But Never Completed
        One-Time Completed Customer
        Repeat Customer

    Revenue rank:
        positive Completed revenue customers only.

    Validate final row count.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 80 - FINAL SQL MASTERY CAPSTONE
==============================================================================*/

/*
    This is the final exercise in the practice track.

    Build a multi-result executive analysis containing the following
    logically separate result sets.


    RESULT 1 - EXECUTIVE KPIs

        registered_customers
        completed_customers
        repeat_customers
        completed_orders
        units_sold
        completed_revenue
        estimated_gross_profit
        estimated_gross_margin_pct
        average_order_value


    RESULT 2 - MONTHLY PERFORMANCE

        revenue_month
        completed_orders
        purchasing_customers
        revenue
        estimated_gross_profit
        previous_revenue
        revenue_growth_pct
        cumulative_revenue


    RESULT 3 - TOP CUSTOMERS

        top 5 customers by Completed revenue

        customer_id
        customer_name
        completed_orders
        completed_revenue
        revenue_rank


    RESULT 4 - TOP PRODUCTS

        top 5 products by Completed revenue

        product_id
        product_name
        category
        units_sold
        revenue
        estimated_gross_profit
        revenue_rank


    RESULT 5 - FUNNEL

        Registered
        Ordered
        Completed
        Repeat

        Include step conversion.


    RESULT 6 - DATA QUALITY STATUS

        Check:

            orphan orders
            orphan order_items
            invalid quantities
            negative stock
            duplicate emails

        Return a PASS/FAIL summary.


    RESULT 7 - REVENUE RECONCILIATION

        transaction revenue
        order-level revenue
        customer-level revenue
        product-level revenue

        Return PASS when all match.


    RESULT 8 - PERFORMANCE REVIEW

        Do not change schema automatically.

        In comments document:

            important filter columns
            important join columns
            candidate indexes
            SARGability considerations
            expected write trade-offs
            what you would inspect in Actual Execution Plan
            which STATISTICS IO/TIME metrics you would baseline


    Requirements:

        - Completed revenue uses order_items.unit_price.
        - Profit uses current products.cost and must be called estimated.
        - Order counts must not be inflated by line-item joins.
        - Divide safely with NULLIF.
        - Use deterministic ranking.
        - Validate important totals.
        - Keep each result grain explicit.

    The goal is not to create one enormous SELECT.

    Build clear stages and separate result sets for separate business grains.
*/

-- Write your solution below:




/*==============================================================================
    FINAL ADVANCED SELF-CHECK
==============================================================================*/

/*
    You should now be able to explain:

    [ ] Result grain and row multiplication

    [ ] Business metric definitions

    [ ] RFM and deterministic reference dates

    [ ] Cohort assignment and cohort age

    [ ] Cohort vs consecutive-month retention

    [ ] Right-censoring

    [ ] Funnel validation

    [ ] Revenue/profit ranking

    [ ] Revenue concentration

    [ ] Product-pair analysis

    [ ] Metric reconciliation

    [ ] Atomic transactions

    [ ] TRY/CATCH + XACT_STATE + THROW

    [ ] ACID

    [ ] Isolation anomalies

    [ ] Blocking and deadlocks

    [ ] Clustered vs nonclustered indexes

    [ ] Composite indexes and key order

    [ ] INCLUDE and covering indexes

    [ ] Key Lookups

    [ ] SARGability

    [ ] Execution plans

    [ ] Statistics and cardinality estimates

    [ ] Logical reads

    [ ] Index write cost

    [ ] Parameter sensitivity

    [ ] Measurement-driven performance tuning
*/


/*==============================================================================
    END OF ADVANCED EXERCISES

    Total:
        80 exercises

    FINAL FILE:
        exercises/advanced/solutions.sql
==============================================================================*/