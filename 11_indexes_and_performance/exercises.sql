/*==============================================================================
    SQL Mastery
    Chapter 11: Indexes and Query Performance
    File: exercises.sql
    Database: SQLMastery
    Schema: training

    Purpose:
    Practice index design, SARGability, execution-plan analysis,
    statistics, logical reads, join access paths, and performance tuning.

    IMPORTANT:
    - The training tables are intentionally small.
    - A scan on a tiny table is NOT proof that an index is useless.
    - Use Actual Execution Plans where requested.
    - Experimental indexes should be removed after the exercises.
    - Measure before and after optimization.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    EXERCISE 1 - TABLE SIZES
==============================================================================*/

/*
    Return one result containing:

        table_name
        row_count

    for:

        training.customers
        training.products
        training.orders
        training.order_items

    Question:
    Why can tiny table sizes make performance experiments misleading?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 2 - INSPECT EXISTING INDEXES
==============================================================================*/

/*
    Using sys.indexes, list indexes for the four training tables.

    Return:

        schema_name
        table_name
        index_id
        index_name
        type_desc
        is_unique
        is_primary_key
        is_unique_constraint

    Sort by table name and index_id.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 3 - INDEX COLUMNS
==============================================================================*/

/*
    Use:

        sys.indexes
        sys.index_columns
        sys.columns

    Return:

        table_name
        index_name
        column_name
        key_ordinal
        is_included_column
        is_descending_key

    Goal:
    Learn how to inspect index definitions without relying only on SSMS UI.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 4 - HEAP OR CLUSTERED?
==============================================================================*/

/*
    Determine whether each core training table:

        customers
        products
        orders
        order_items

    is:

        Heap

    or:

        Has clustered index

    Hint:
        index_id = 1 represents the clustered index.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 5 - PRIMARY KEY LOOKUP
==============================================================================*/

/*
    Write a query returning:

        product_id
        product_name
        price
        stock_quantity

    for:

        product_id = 1

    Enable Actual Execution Plan.

    Answer in comments:

    1. Which access operator did SQL Server choose?
    2. Why should you not assume that every primary-key lookup
       always appears exactly the same on every database?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 6 - STATISTICS IO
==============================================================================*/

/*
    Enable SET STATISTICS IO.

    Query all rows from training.orders.

    Then disable STATISTICS IO.

    Answer:

    What metric in the Messages output is especially useful when
    comparing I/O work between equivalent queries?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 7 - STATISTICS TIME
==============================================================================*/

/*
    Enable SET STATISTICS TIME.

    Query training.order_items.

    Disable STATISTICS TIME.

    Answer in comments:

    Why should you avoid judging query performance from only one
    elapsed-time measurement?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 8 - SELECT * VS REQUIRED COLUMNS
==============================================================================*/

/*
    Query orders for customer_id = 1 in two ways.

    Query A:
        SELECT *

    Query B:
        Return only:

            order_id
            order_date
            order_status

    Explain at least THREE reasons why Query B may be preferable
    in a real application.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 9 - SIMPLE NONCLUSTERED INDEX
==============================================================================*/

/*
    Safely create:

        IX_orders_customer

    on:

        training.orders(customer_id)

    Before CREATE, remove an existing index with that exact experimental
    name if necessary.

    Then query:

        order_id
        customer_id

    for customer_id = 1.

    Inspect the execution plan.

    Question:
    If SQL Server scans instead of seeks, does that automatically mean
    the index is badly designed? Explain.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 10 - SEEK VS SCAN
==============================================================================*/

/*
    Explain in comments:

    1. What is an Index Seek?
    2. What is an Index Scan?
    3. Why is "Seek = good, Scan = bad" an incorrect rule?
    4. Give an example of a query where scanning most/all rows is reasonable.
*/




/*==============================================================================
    EXERCISE 11 - COVERING INDEX
==============================================================================*/

/*
    Consider:

        SELECT
            order_date,
            order_status
        FROM training.orders
        WHERE customer_id = 1;

    Create an experimental index named:

        IX_orders_customer_cover

    Requirements:

        Key:
            customer_id

        INCLUDE:
            order_date
            order_status

    Explain why this index can cover the query.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 12 - KEY LOOKUP
==============================================================================*/

/*
    Explain in comments:

    1. What is a Key Lookup?
    2. Why can a Key Lookup be efficient when only a few rows qualify?
    3. Why can thousands or millions of repeated lookups become expensive?
    4. How can INCLUDE sometimes eliminate the lookup?
*/




/*==============================================================================
    EXERCISE 13 - COMPOSITE INDEX
==============================================================================*/

/*
    Create:

        IX_orders_customer_date

    on:

        training.orders(customer_id, order_date)

    INCLUDE:

        order_status

    Then query:

        order_id
        order_date
        order_status

    where:

        customer_id = 1
        order_date >= '20250101'

    ordered by order_date.

    Inspect the execution plan.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 14 - LEFTMOST KEY
==============================================================================*/

/*
    Given:

        IX_orders_customer_date
        (customer_id, order_date)

    Compare:

    Query A:
        WHERE customer_id = 1

    Query B:
        WHERE order_date >= '20250101'

    Explain why the same index provides different search possibilities
    for these predicates.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 15 - COMPOSITE COLUMN ORDER
==============================================================================*/

/*
    Compare conceptually:

        Index A:
        (customer_id, order_date)

        Index B:
        (order_date, customer_id)

    For each query, state which ordering would usually be the more natural
    starting point and explain why.

    Query 1:

        WHERE customer_id = 1
          AND order_date >= '20250101'

    Query 2:

        WHERE order_date >= '20250101'

    Do NOT answer merely "Index A is always better."
*/




/*==============================================================================
    EXERCISE 16 - SARGABLE DATE FILTER
==============================================================================*/

/*
    Rewrite this query into a SARGable date range:

        SELECT *
        FROM training.orders
        WHERE YEAR(order_date) = 2025;

    Requirements:

        Do not call YEAR() on order_date.

    Use a half-open range.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 17 - MONTH FILTER
==============================================================================*/

/*
    Rewrite:

        WHERE YEAR(order_date) = 2025
          AND MONTH(order_date) = 1

    as an index-friendly date range representing January 2025.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 18 - HALF-OPEN DATE RANGE
==============================================================================*/

/*
    Explain why:

        order_date >= '20250101'
        AND order_date < '20250201'

    is generally preferable to trying to construct:

        order_date <= '2025-01-31 23:59:59...'

    especially when a column contains both date and time.
*/




/*==============================================================================
    EXERCISE 19 - DATE INDEX
==============================================================================*/

/*
    Create:

        IX_orders_order_date

    Key:

        order_date

    INCLUDE:

        customer_id
        order_status

    Compare these queries with STATISTICS IO and Actual Execution Plan:

    A:
        WHERE YEAR(order_date) = 2025

    B:
        WHERE order_date >= '20250101'
          AND order_date < '20260101'

    Record observations in comments.

    Remember:
    Tiny tables can hide the performance difference.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 20 - LIKE SEARCHES
==============================================================================*/

/*
    Create:

        IX_customers_name

    on customer_name and INCLUDE:

        customer_id
        city

    Compare:

        customer_name LIKE 'A%'

    and:

        customer_name LIKE '%a%'

    Explain which predicate provides a normal B-tree index with a more
    useful search starting point.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 21 - FUNCTION ON SEARCH COLUMN
==============================================================================*/

/*
    Create:

        IX_customers_city

    on:

        city

    INCLUDE:

        customer_id
        customer_name

    Compare:

        WHERE city = 'Cairo'

    with:

        WHERE UPPER(city) = 'CAIRO'

    Explain the SARGability difference.

    Note:
    Do not assume case behavior without considering database collation.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 22 - ISNULL AND SARGABILITY
==============================================================================*/

/*
    Consider:

        WHERE ISNULL(city, '') = 'Cairo'

    Explain why wrapping the search column in ISNULL can make normal
    index navigation more difficult.

    Also explain why performance rewrites must preserve NULL semantics.
*/




/*==============================================================================
    EXERCISE 23 - IMPLICIT CONVERSION
==============================================================================*/

/*
    Answer in comments:

    1. What is an implicit conversion?
    2. Why can mismatched data types hurt performance?
    3. Why should parameter types normally match their target columns?
    4. Where might SQL Server expose conversion warnings?
*/




/*==============================================================================
    EXERCISE 24 - FOREIGN KEY INDEX
==============================================================================*/

/*
    Create:

        IX_order_items_order

    on:

        order_id

    INCLUDE:

        product_id
        quantity
        unit_price

    Then execute a join between:

        training.orders
        training.order_items

    for:

        o.order_id = 1

    Question:
    Does defining a FOREIGN KEY automatically guarantee that SQL Server
    created this supporting nonclustered index?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 25 - PRODUCT AGGREGATION INDEX
==============================================================================*/

/*
    Create:

        IX_order_items_product

    Key:

        product_id

    INCLUDE:

        quantity

    Then execute:

        one row per product_id
        SUM(quantity)

    Explain how this index can cover the aggregation.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 26 - STATUS INDEX SELECTIVITY
==============================================================================*/

/*
    Consider:

        order_status

    with values such as:

        Pending
        Completed
        Cancelled

    Answer:

    1. Why does low cardinality not automatically mean an index is useless?
    2. Why does data distribution matter?
    3. Compare conceptually:

           99.9% Completed
           0.1% Pending

       Which predicate is likely more selective?
*/




/*==============================================================================
    EXERCISE 27 - STATUS + DATE INDEX
==============================================================================*/

/*
    Create:

        IX_orders_status_date

    Keys:

        order_status
        order_date

    INCLUDE:

        customer_id

    Test:

        WHERE order_status = 'Completed'
          AND order_date >= '20250101'

        ORDER BY order_date

    Explain how one index may help filtering and ordering.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 28 - FILTERED INDEX
==============================================================================*/

/*
    Create:

        IX_products_active_category

    Key:

        category

    INCLUDE:

        product_name
        price
        stock_quantity

    Filter:

        WHERE is_active = 1

    Query active Electronics products.

    Explain why a filtered index can be smaller than an equivalent
    unfiltered index.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 29 - UNIQUE INDEX
==============================================================================*/

/*
    Before creating a unique index on customers.email:

    1. Write a query that detects duplicate emails.
    2. Inspect whether an existing unique constraint/index already covers email.
    3. Explain why blindly creating another unique index may be redundant.

    Do NOT create UX_customers_email in this exercise unless you first
    establish that the schema needs it.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 30 - OVER-INDEXING
==============================================================================*/

/*
    Suppose training.orders contains:

        IX_A (customer_id)
        IX_B (customer_id, order_date)
        IX_C (customer_id, order_status)
        IX_D (customer_id, order_date, order_status)
        IX_E (order_status)
        IX_F (order_status, order_date)
        IX_G (order_date)

    Answer:

    1. Why might this be too many indexes?
    2. What costs do indexes add to INSERT/UPDATE/DELETE?
    3. Why should apparently overlapping indexes not be removed blindly?
*/




/*==============================================================================
    EXERCISE 31 - INDEX WRITE COST
==============================================================================*/

/*
    Explain what happens when an UPDATE changes a column that participates
    in several indexes.

    Include:

        - base table/clustered structure
        - affected nonclustered indexes
        - I/O
        - transaction log
        - concurrency implications
*/




/*==============================================================================
    EXERCISE 32 - INSPECT STATISTICS
==============================================================================*/

/*
    Using sys.stats, list statistics for training.orders.

    Return:

        stats_id
        statistics_name
        auto_created
        user_created
        no_recompute
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 33 - STATISTICS PROPERTIES
==============================================================================*/

/*
    Use:

        sys.stats
        sys.dm_db_stats_properties

    for training.orders.

    Return:

        statistics_name
        last_updated
        rows
        rows_sampled
        steps
        modification_counter

    Explain what statistics are used for by the optimizer.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 34 - STATISTICS VS INDEX
==============================================================================*/

/*
    Explain the difference:

        Index
        vs
        Statistics

    Your answer should mention:

        physical access structure
        cardinality estimation

    Can SQL Server have statistics without a corresponding user-created
    index?
*/




/*==============================================================================
    EXERCISE 35 - ESTIMATED VS ACTUAL ROWS
==============================================================================*/

/*
    Enable Actual Execution Plan and run:

        SELECT
            order_id,
            customer_id,
            order_date,
            order_status
        FROM training.orders
        WHERE customer_id = 1;

    Inspect:

        Estimated Number of Rows
        Actual Number of Rows

    Explain why major differences between estimates and actual rows can
    influence plan quality.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 36 - JOIN ALGORITHMS
==============================================================================*/

/*
    Explain the basic idea and a common useful scenario for:

        1. Nested Loops
        2. Hash Match
        3. Merge Join

    Is any one of these universally the "best" join algorithm?
*/




/*==============================================================================
    EXERCISE 37 - SORT OPERATOR
==============================================================================*/

/*
    Run:

        SELECT
            customer_id,
            order_status,
            order_date
        FROM training.orders
        ORDER BY
            order_status,
            customer_id,
            order_date;

    Inspect the plan.

    Answer:

    1. Why might SQL Server need a Sort?
    2. Why is a Sort not automatically bad?
    3. What can make a large Sort expensive?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 38 - MEMORY GRANTS AND SPILLS
==============================================================================*/

/*
    Explain in comments:

    1. Which types of operators commonly require query memory?
    2. What is a memory grant?
    3. What can happen if the grant is too small?
    4. What is a tempdb spill?
    5. Why can bad cardinality estimates contribute to this problem?
*/




/*==============================================================================
    EXERCISE 39 - WINDOW FUNCTION ACCESS PATTERN
==============================================================================*/

/*
    Write ROW_NUMBER() for orders:

        PARTITION BY customer_id
        ORDER BY order_date DESC, order_id DESC

    Return:

        order_id
        customer_id
        order_date
        row number

    Then explain what kind of index ordering could potentially help this
    access/order pattern.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 40 - LATEST ORDER PER CUSTOMER
==============================================================================*/

/*
    Using ROW_NUMBER(), return the latest order per customer.

    Grain:

        one row per customer that has an order

    Tie breaker:

        order_date DESC
        order_id DESC

    Then explain why deterministic tie-breaking is important.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 41 - CTE PERFORMANCE
==============================================================================*/

/*
    Answer:

    Does a CTE automatically materialize its result into temporary storage?

    Explain why:

        "I used a CTE, therefore this query is faster"

    is not a valid performance conclusion.
*/




/*==============================================================================
    EXERCISE 42 - EXISTS VS JOIN
==============================================================================*/

/*
    Requirement:

        Return customers who have at least one order.

    Write Version A using EXISTS.

    Write Version B using JOIN.

    Ensure Version B returns one row per customer.

    Explain why EXISTS naturally communicates the required semantics.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 43 - DISTINCT ANTI-PATTERN
==============================================================================*/

/*
    Consider:

        SELECT DISTINCT
            product_id,
            product_name,
            category
        FROM training.products;

    Explain why DISTINCT is unnecessary if product_id is unique.

    Then write the cleaner query.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 44 - RESULT GRAIN
==============================================================================*/

/*
    Requirement:

        One row per customer containing Completed revenue.

    Revenue definition:

        SUM(quantity * unit_price)
        for Completed orders only.

    Write a query that clearly preserves the intended customer grain.

    Include customers with zero Completed revenue.

    Then explain why joining customers -> orders -> order_items changes
    the intermediate grain.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 45 - PRE-AGGREGATION
==============================================================================*/

/*
    Create a CTE that calculates:

        one row per order
        order_revenue

    Then join it to orders and return Completed orders.

    Explain one reason pre-aggregation can sometimes reduce work in
    larger analytical queries.

    Also explain why it is not automatically faster.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 46 - PARAMETER SENSITIVITY
==============================================================================*/

/*
    Consider:

        WHERE customer_id = @CustomerId

    Dataset A:

        Customer 1 has 3 orders.
        Customer 2 has 3 orders.

    Dataset B:

        Customer 1 has 3 orders.
        Customer 2 has 5,000,000 orders.

    Explain why one cached execution plan may be suitable for Dataset A
    but less ideal for every parameter in Dataset B.

    What broad SQL Server performance topic does this relate to?
*/




/*==============================================================================
    EXERCISE 47 - OPTION (RECOMPILE)
==============================================================================*/

/*
    Write a parameterized query for orders by customer_id using:

        OPTION (RECOMPILE)

    Then explain:

    1. What RECOMPILE can help with.
    2. What cost it introduces.
    3. Why it should not be added to every query.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 48 - MISSING INDEX SUGGESTIONS
==============================================================================*/

/*
    An execution plan recommends:

        CREATE INDEX ...
        ON orders(customer_id, order_status)
        INCLUDE(order_date);

    Should you immediately create it?

    Explain at least FOUR questions you should ask first.
*/




/*==============================================================================
    EXERCISE 49 - INDEX HINTS
==============================================================================*/

/*
    Explain why this should not normally be your first tuning approach:

        WITH (INDEX(SomeIndex))

    What can happen when:

        - table size changes
        - data distribution changes
        - indexes change
        - workload changes

    What should usually be investigated first?
*/




/*==============================================================================
    EXERCISE 50 - INDEX USAGE STATISTICS
==============================================================================*/

/*
    Query sys.dm_db_index_usage_stats for the training tables.

    Return:

        table_name
        index_name
        user_seeks
        user_scans
        user_lookups
        user_updates

    Explain why these counters should not be treated as permanent
    historical records.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 51 - INDEX FRAGMENTATION
==============================================================================*/

/*
    Use sys.dm_db_index_physical_stats in LIMITED mode.

    Return for the training tables:

        table_name
        index_name
        index_type_desc
        avg_fragmentation_in_percent
        page_count

    Question:
    Why is fragmentation percentage on a tiny index often not useful
    for making maintenance decisions?
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 52 - REORGANIZE VS REBUILD
==============================================================================*/

/*
    Explain conceptually:

        ALTER INDEX ... REORGANIZE
        ALTER INDEX ... REBUILD

    Why is:

        "Rebuild every index above X% fragmentation"

    an incomplete production maintenance strategy?

    Mention index size/page count and workload.
*/




/*==============================================================================
    EXERCISE 53 - FILL FACTOR
==============================================================================*/

/*
    Explain:

    1. What fill factor controls.
    2. Why lower fill factor can leave room for future page changes.
    3. Why lower fill factor can increase storage and reads.
    4. Why there is no universal best fill factor.
*/




/*==============================================================================
    EXERCISE 54 - PERFORMANCE BASELINE
==============================================================================*/

/*
    Write a baseline block that enables:

        SET STATISTICS IO ON
        SET STATISTICS TIME ON

    Then runs this business requirement:

        One row per customer with:
            completed order count
            Completed revenue

    Revenue:
        SUM(quantity * unit_price)

    Completed order count must not be multiplied by order-item joins.

    Disable statistics afterward.

    List in comments what else you would capture besides IO/time.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 55 - FREQUENCY VS SINGLE EXECUTION
==============================================================================*/

/*
    Query A:
        500 ms
        runs once per month

    Query B:
        50 ms
        runs 1,000,000 times per day

    Which query could have the greater total system impact?

    Explain why tuning priorities should consider workload frequency.
*/




/*==============================================================================
    EXERCISE 56 - PERFORMANCE VS CONCURRENCY
==============================================================================*/

/*
    Explain why a query that finishes quickly in isolation can still be
    harmful to a busy production system.

    Include examples involving:

        locks
        blocking
        CPU
        memory
        I/O
        execution frequency
*/




/*==============================================================================
    EXERCISE 57 - OPTIMIZATION REVIEW
==============================================================================*/

/*
    Review this query:

        SELECT DISTINCT *
        FROM training.orders
        WHERE YEAR(order_date) = 2025
        ORDER BY order_date;

    Identify at least THREE areas you would investigate.

    Rewrite the query assuming the application needs only:

        order_id
        customer_id
        order_date
        order_status

    for orders in 2025.

    Do not use DISTINCT unless required.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 58 - INDEX DESIGN CHALLENGE
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

    Propose one reasonable nonclustered index.

    Explain:

        - key column order
        - equality predicate
        - range predicate
        - INCLUDE columns
        - ORDER BY support

    Remember:
    This is a proposed design, not proof that the index is optimal for
    every workload.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 59 - PERFORMANCE TUNING WORKFLOW
==============================================================================*/

/*
    Put these ideas into a sensible tuning workflow and explain each:

        - identify important query
        - capture baseline
        - verify correctness
        - inspect actual execution plan
        - inspect logical reads
        - compare estimated vs actual rows
        - identify likely bottleneck
        - make one targeted change
        - measure again
        - evaluate broader workload/write impact

    Write the answer in comments.
*/




/*==============================================================================
    EXERCISE 60 - FINAL PERFORMANCE CHALLENGE
==============================================================================*/

/*
    Business requirement:

    Return one row per active customer containing:

        customer_id
        customer_name
        completed_orders
        completed_revenue
        latest_completed_order_date

    Definitions:

        Completed order:
            order_status = 'Completed'

        completed_orders:
            distinct Completed orders

        completed_revenue:
            SUM(order_items.quantity * order_items.unit_price)

        latest_completed_order_date:
            MAX(order_date) among Completed orders

    Include active customers with no Completed orders.

    Tasks:

    1. Write a correct query.

    2. Clearly state the result grain.

    3. Enable STATISTICS IO/TIME for a baseline.

    4. Inspect the Actual Execution Plan.

    5. Identify relevant join/filter columns.

    6. Inspect existing indexes before proposing new ones.

    7. Propose one or more reasonable indexes for a much larger dataset.

    8. Explain why order count must be protected from row multiplication.

    9. Explain how your proposed indexes affect write cost.

    10. Explain why the tiny training dataset cannot prove the proposed
        indexes are optimal.

    Do not permanently create the proposed final indexes unless you also
    clean them up afterward.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 61 - CLEAN UP EXPERIMENTAL INDEXES
==============================================================================*/

/*
    Safely remove the experimental indexes created by these exercises:

        IX_orders_customer
        IX_orders_customer_cover
        IX_orders_customer_date
        IX_orders_order_date
        IX_customers_name
        IX_customers_city
        IX_order_items_order
        IX_order_items_product
        IX_orders_status_date
        IX_products_active_category

    Use existence checks so cleanup can run safely more than once.

    Do NOT remove primary keys, unique constraints, or unrelated indexes.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 62 - FINAL INDEX AUDIT
==============================================================================*/

/*
    After cleanup, list the remaining indexes on:

        training.customers
        training.products
        training.orders
        training.order_items

    Return:

        schema_name
        table_name
        index_name
        type_desc
        is_primary_key
        is_unique
        is_unique_constraint

    Goal:
    Verify that training experiments did not leave unwanted indexes behind.
*/

-- Write your solution below:




/*==============================================================================
    FINAL THEORY CHECK
==============================================================================*/

/*
    Answer these in your own words:

    1. Why is a scan not automatically bad?

    2. Why is a seek not automatically good?

    3. What makes a predicate SARGable?

    4. Why does composite index key order matter?

    5. What does INCLUDE do?

    6. What is a covering index?

    7. What is a Key Lookup?

    8. Why do statistics matter?

    9. Why can estimated-vs-actual row differences matter?

    10. What are logical reads?

    11. Why can too many indexes hurt performance?

    12. Why should missing-index suggestions not be followed blindly?

    13. Why should query hints normally not be the first tuning tool?

    14. Why does result grain matter to performance?

    15. What is the most important optimization loop?

    Suggested final answer:

        Measure
            ->
        Understand
            ->
        Change
            ->
        Measure again
*/


/*==============================================================================
    END OF EXERCISES

    Skills practiced:

    - Index catalog inspection
    - Clustered/nonclustered indexes
    - Seeks and scans
    - Composite indexes
    - INCLUDE columns
    - Covering indexes
    - Key lookups
    - SARGability
    - Date-range filtering
    - LIKE patterns
    - Implicit conversion awareness
    - STATISTICS IO
    - STATISTICS TIME
    - Execution-plan analysis
    - Statistics
    - Join algorithms
    - Sorts
    - Memory grants and spills
    - Filtered indexes
    - Index write costs
    - Index usage DMVs
    - Fragmentation concepts
    - Parameter sensitivity
    - Performance baselining
    - Workload-aware optimization
    - Safe experimental index cleanup

    Next file:
        solutions.sql
==============================================================================*/