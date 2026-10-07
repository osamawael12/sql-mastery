/*==============================================================================
    SQL Mastery
    Practice Exercises - Beginner
    File: exercises.sql
    Database: SQLMastery
    Schema: training

    Topics:
    - SELECT
    - Aliases
    - DISTINCT
    - WHERE
    - AND / OR / NOT
    - IN / BETWEEN / LIKE
    - NULL
    - ORDER BY
    - TOP
    - Calculated columns
    - CASE
    - COALESCE
    - CAST
    - String functions
    - Date functions
    - Aggregates
    - GROUP BY
    - HAVING
    - Basic joins

    Try every exercise before opening solutions.sql.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    EXERCISE 1 - SELECT ALL CUSTOMERS
==============================================================================*/

/*
    Return all columns from training.customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 2 - SELECT SPECIFIC COLUMNS
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        email

    from training.customers.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 3 - COLUMN ALIASES
==============================================================================*/

/*
    Return:

        customer_name as customer
        signup_date as joined_date
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 4 - DISTINCT CITIES
==============================================================================*/

/*
    Return each distinct city appearing in training.customers.

    Sort alphabetically.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 5 - ACTIVE CUSTOMERS
==============================================================================*/

/*
    Return all active customers.

    Filter:

        is_active = 1

    Return:

        customer_id
        customer_name
        city
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 6 - PRODUCTS ABOVE A PRICE
==============================================================================*/

/*
    Return products with:

        price > 100

    Return:

        product_id
        product_name
        price
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 7 - PRODUCTS IN STOCK
==============================================================================*/

/*
    Return products where:

        stock_quantity > 0

    Return:

        product_name
        stock_quantity
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 8 - MULTIPLE CONDITIONS
==============================================================================*/

/*
    Return products that are:

        active
        AND
        price >= 100

    Return:

        product_id
        product_name
        price
        is_active
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 9 - OR
==============================================================================*/

/*
    Return customers located in:

        Cairo
        OR
        Giza

    Return:

        customer_id
        customer_name
        city
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 10 - IN
==============================================================================*/

/*
    Solve the previous city problem using IN instead of OR.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 11 - NOT
==============================================================================*/

/*
    Return orders whose status is NOT Cancelled.

    Return:

        order_id
        customer_id
        order_date
        order_status
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 12 - BETWEEN
==============================================================================*/

/*
    Return products whose price is between:

        100 and 1000

    inclusive.

    Return:

        product_id
        product_name
        price
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 13 - LIKE: STARTS WITH
==============================================================================*/

/*
    Return customers whose name starts with:

        A
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 14 - LIKE: CONTAINS
==============================================================================*/

/*
    Return customers whose name contains:

        a

    Exact case behavior depends on collation.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 15 - NULL
==============================================================================*/

/*
    Return customers where city is NULL.

    Do not use:

        city = NULL
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 16 - NOT NULL
==============================================================================*/

/*
    Return customers where city is not NULL.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 17 - ORDER BY ASC
==============================================================================*/

/*
    Return:

        product_name
        price

    sorted from lowest price to highest.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 18 - ORDER BY DESC
==============================================================================*/

/*
    Return:

        product_name
        price

    sorted from highest price to lowest.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 19 - MULTIPLE SORT COLUMNS
==============================================================================*/

/*
    Return:

        category
        product_name
        price

    Sort:

        category ASC
        price DESC
        product_id ASC

    product_id is the deterministic tie breaker.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 20 - TOP 3 MOST EXPENSIVE PRODUCTS
==============================================================================*/

/*
    Return the 3 most expensive products.

    Return:

        product_id
        product_name
        price

    Ensure TOP has a meaningful ORDER BY.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 21 - CALCULATED PRODUCT PROFIT
==============================================================================*/

/*
    For every product calculate:

        unit_profit = price - cost

    Return:

        product_id
        product_name
        price
        cost
        unit_profit
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 22 - PRODUCT MARGIN PERCENTAGE
==============================================================================*/

/*
    Calculate:

        unit_profit
        margin_pct

    Formula:

        (price - cost) / price * 100

    Protect against division by zero.

    Return:

        product_name
        price
        cost
        unit_profit
        margin_pct
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 23 - ORDER ITEM LINE TOTAL
==============================================================================*/

/*
    For every order item calculate:

        line_total = quantity * unit_price

    Return:

        order_item_id
        order_id
        product_id
        quantity
        unit_price
        line_total
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 24 - CASE: STOCK STATUS
==============================================================================*/

/*
    Create:

        stock_status

    Rules:

        stock_quantity = 0
            -> Out of Stock

        stock_quantity <= 5
            -> Critical

        stock_quantity <= 10
            -> Low

        otherwise
            -> Healthy

    Return:

        product_id
        product_name
        stock_quantity
        stock_status
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 25 - CASE: ORDER STATUS GROUP
==============================================================================*/

/*
    Return every order with:

        order_id
        order_status
        status_group

    Rules:

        Completed -> Successful
        Cancelled -> Unsuccessful
        everything else -> Open
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 26 - COALESCE
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        city

    Replace NULL city with:

        Unknown

    Name the output column:

        display_city
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 27 - CONCAT
==============================================================================*/

/*
    Create:

        customer_summary

    Format conceptually as:

        customer_name - city

    If city is NULL, display Unknown.

    Use CONCAT and COALESCE.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 28 - UPPER / LOWER
==============================================================================*/

/*
    Return:

        customer_name
        customer_name_upper
        email
        email_lower

    Use UPPER() and LOWER().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 29 - STRING LENGTH
==============================================================================*/

/*
    Return:

        product_name
        product_name_length

    using LEN().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 30 - CAST
==============================================================================*/

/*
    Return:

        product_name
        price
        price_as_int

    using CAST().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 31 - ORDER YEAR AND MONTH
==============================================================================*/

/*
    Return:

        order_id
        order_date
        order_year
        order_month

    using YEAR() and MONTH().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 32 - MONTH NAME
==============================================================================*/

/*
    Return:

        order_id
        order_date
        month_name

    using DATENAME().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 33 - ONE WEEK AFTER ORDER
==============================================================================*/

/*
    Return:

        order_id
        order_date
        seven_days_later

    Use DATEADD().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 34 - DAYS SINCE SIGNUP
==============================================================================*/

/*
    Find the latest signup_date in the customer table.

    Use ONE DAY AFTER that date as a deterministic reference date.

    Return:

        customer_id
        customer_name
        signup_date
        days_since_signup

    Do not use GETDATE().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 35 - MONTH START
==============================================================================*/

/*
    Return every order with:

        order_id
        order_date
        order_month

    order_month should be the first day of the order's month.

    Use DATEFROMPARTS().
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 36 - COUNT CUSTOMERS
==============================================================================*/

/*
    Return the total number of customer rows.

    Name the result:

        total_customers
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 37 - COUNT ACTIVE CUSTOMERS
==============================================================================*/

/*
    Return the number of customers where:

        is_active = 1
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 38 - TOTAL INVENTORY
==============================================================================*/

/*
    Return:

        total_units_in_stock

    using SUM(stock_quantity).
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 39 - PRICE STATISTICS
==============================================================================*/

/*
    Return one row containing:

        average_price
        minimum_price
        maximum_price
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 40 - PRODUCTS PER CATEGORY
==============================================================================*/

/*
    Return:

        category
        product_count

    One row per category.

    Sort by:

        product_count DESC
        category ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 41 - AVERAGE PRICE BY CATEGORY
==============================================================================*/

/*
    Return:

        category
        average_price

    One row per category.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 42 - INVENTORY BY CATEGORY
==============================================================================*/

/*
    Return:

        category
        total_stock

    total_stock:

        SUM(stock_quantity)

    Sort highest stock first.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 43 - ORDER COUNT BY STATUS
==============================================================================*/

/*
    Return:

        order_status
        order_count

    One row per order status.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 44 - CUSTOMERS WITH AT LEAST 2 ORDERS
==============================================================================*/

/*
    Return:

        customer_id
        order_count

    for customers with at least 2 orders of ANY status.

    Use:

        GROUP BY
        HAVING
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 45 - CATEGORIES WITH AVERAGE PRICE ABOVE 100
==============================================================================*/

/*
    Return:

        category
        average_price

    Keep only categories where:

        AVG(price) > 100
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 46 - BASIC CUSTOMER / ORDER JOIN
==============================================================================*/

/*
    Return:

        order_id
        order_date
        order_status
        customer_name

    Use INNER JOIN.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 47 - ORDER ITEM PRODUCT JOIN
==============================================================================*/

/*
    Return:

        order_item_id
        order_id
        product_name
        quantity
        unit_price

    Join:

        order_items
        products
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 48 - THREE-TABLE JOIN
==============================================================================*/

/*
    Return:

        order_id
        customer_name
        order_date
        order_status
        product_id
        quantity
        unit_price

    Join:

        customers
        orders
        order_items
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 49 - FOUR-TABLE JOIN
==============================================================================*/

/*
    Return:

        order_id
        customer_name
        product_name
        category
        quantity
        unit_price
        line_total

    line_total:

        quantity * unit_price

    Join all four core tables.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 50 - ALL CUSTOMERS AND THEIR ORDERS
==============================================================================*/

/*
    Return all customers.

    Include matching order IDs where available.

    Return:

        customer_id
        customer_name
        order_id
        order_status

    Customers with no orders must remain.

    Use LEFT JOIN.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 51 - COMPLETED ORDERS
==============================================================================*/

/*
    Return:

        order_id
        customer_id
        order_date

    for Completed orders only.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 52 - COMPLETED ORDER ITEMS
==============================================================================*/

/*
    Return the item lines belonging to Completed orders.

    Columns:

        order_id
        product_id
        quantity
        unit_price
        line_total
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 53 - TOTAL COMPLETED REVENUE
==============================================================================*/

/*
    Calculate total Completed revenue.

    Formula:

        SUM(quantity * unit_price)

    Use transaction-time:

        order_items.unit_price

    Name the result:

        completed_revenue
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 54 - COMPLETED UNITS SOLD
==============================================================================*/

/*
    Return total units sold from Completed orders.

    Name:

        units_sold

    Remember:

        SUM(quantity)

    not:

        COUNT(*)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 55 - COMPLETED ORDERS PER CUSTOMER
==============================================================================*/

/*
    Return customers who have at least one Completed order.

    Columns:

        customer_id
        customer_name
        completed_orders

    At this point, you do NOT need order_items for this query.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 56 - COMPLETED REVENUE PER CUSTOMER
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        completed_revenue

    Include only customers with Completed revenue.

    Sort highest revenue first.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 57 - COMPLETED REVENUE PER PRODUCT
==============================================================================*/

/*
    Return products that have Completed sales.

    Columns:

        product_id
        product_name
        units_sold
        completed_revenue

    Use:

        SUM(quantity)
        SUM(quantity * unit_price)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 58 - COMPLETED REVENUE PER CATEGORY
==============================================================================*/

/*
    Return:

        category
        units_sold
        completed_revenue

    Use Completed orders only.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 59 - ORDER VALUES
==============================================================================*/

/*
    Return one row per order that has order_items.

    Columns:

        order_id
        order_status
        order_value

    order_value:

        SUM(quantity * unit_price)

    Include every order status.

    Important:
    Do not call all of this "revenue" because Pending/Cancelled values
    are not Completed revenue.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 60 - COMPLETED ORDER VALUES
==============================================================================*/

/*
    Return one row per Completed order:

        order_id
        customer_id
        order_date
        order_value

    order_value:

        SUM(quantity * unit_price)

    Sort largest order value first.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 61 - COMPLETED CUSTOMERS
==============================================================================*/

/*
    Return the number of distinct customers with at least one Completed order.

    Name:

        completed_customers
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 62 - DISTINCT PRODUCTS SOLD
==============================================================================*/

/*
    Return the number of distinct products appearing in Completed orders.

    Name:

        products_with_completed_sales
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 63 - SIMPLE REPEAT CUSTOMER QUERY
==============================================================================*/

/*
    Return:

        customer_id
        completed_orders

    for customers with:

        at least 2 Completed orders

    Use only training.orders.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 64 - CURRENT INVENTORY COST VALUE
==============================================================================*/

/*
    For each product calculate:

        inventory_cost_value =
            stock_quantity * cost

    Return:

        product_id
        product_name
        stock_quantity
        cost
        inventory_cost_value
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 65 - CURRENT POTENTIAL RETAIL VALUE
==============================================================================*/

/*
    For each product calculate:

        potential_retail_value =
            stock_quantity * price

    Return:

        product_id
        product_name
        stock_quantity
        price
        potential_retail_value

    This is NOT realized revenue.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 66 - CATEGORY INVENTORY COST
==============================================================================*/

/*
    Return one row per category:

        category
        total_units
        inventory_cost_value

    inventory_cost_value:

        SUM(stock_quantity * cost)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 67 - CUSTOMERS SIGNED UP AFTER A DATE
==============================================================================*/

/*
    Return customers whose signup_date is on or after:

        2025-01-01

    Use an unambiguous date literal:

        '20250101'
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 68 - ORDERS IN A DATE RANGE
==============================================================================*/

/*
    Return orders occurring during January 2025.

    Use:

        >= '20250101'
        <  '20250201'

    Do not use YEAR()/MONTH() for this exercise.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 69 - COMPLETED REVENUE IN A DATE RANGE
==============================================================================*/

/*
    Calculate Completed revenue during January 2025.

    Requirements:

        order_status = 'Completed'

        order_date >= '20250101'

        order_date < '20250201'

        revenue = quantity * unit_price
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 70 - MONTHLY ORDER COUNTS
==============================================================================*/

/*
    Return:

        order_month
        order_count

    for ALL order statuses.

    order_month must be a month-start date.

    Sort chronologically.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 71 - MONTHLY COMPLETED ORDER COUNTS
==============================================================================*/

/*
    Return:

        order_month
        completed_orders

    using Completed orders only.

    You do not need order_items.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 72 - MONTHLY COMPLETED REVENUE
==============================================================================*/

/*
    Return:

        revenue_month
        completed_revenue

    using Completed orders only.

    revenue_month:
        month-start date

    completed_revenue:
        SUM(quantity * unit_price)
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 73 - CUSTOMER ORDER SUMMARY
==============================================================================*/

/*
    Return one row per customer that has at least one order:

        customer_id
        customer_name
        total_orders
        first_order_date
        latest_order_date

    Use ALL order statuses.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 74 - PRODUCT PRICE POSITION
==============================================================================*/

/*
    For every product create:

        price_position

    Rules:

        price < 100
            -> Budget

        price <= 500
            -> Mid-Range

        otherwise
            -> Premium

    Return:

        product_name
        price
        price_position
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 75 - PROFITABLE PRODUCTS
==============================================================================*/

/*
    Return products where:

        price > cost

    Include:

        product_name
        price
        cost
        unit_profit

    unit_profit:

        price - cost
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 76 - PRODUCTS WITH ZERO OR LOW STOCK
==============================================================================*/

/*
    Return products where:

        stock_quantity <= 10

    Sort:

        stock_quantity ASC
        product_id ASC
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 77 - CUSTOMER EMAIL DISPLAY
==============================================================================*/

/*
    Return:

        customer_id
        customer_name
        email

    sorted by customer_name alphabetically.

    Rename:

        email -> contact_email
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 78 - SIMPLE COMPLETED SALES REPORT
==============================================================================*/

/*
    Return one row per Completed order item:

        order_id
        order_date
        customer_name
        product_name
        quantity
        unit_price
        line_revenue

    line_revenue:

        quantity * unit_price

    Join all required tables.

    Sort:

        order_date
        order_id
        product_id
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 79 - COMPLETED SALES SUMMARY
==============================================================================*/

/*
    Build a ONE-row report containing:

        completed_orders
        completed_customers
        units_sold
        completed_revenue

    Because the query joins order_items, protect order/customer counts
    from row multiplication.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 80 - BEGINNER FINAL CHALLENGE
==============================================================================*/

/*
    Build a product sales report.

    Return ALL products, including products with no Completed sales.

    Columns:

        product_id
        product_name
        category
        price
        stock_quantity
        units_sold
        completed_revenue

    Requirements:

    - Completed orders only for sales metrics.
    - Revenue uses order_items.unit_price.
    - Products with no Completed sales must remain.
    - Zero sales should display:
          units_sold = 0
          completed_revenue = 0
    - One row per product.
    - Sort:
          completed_revenue DESC
          product_id ASC

    Think carefully about LEFT JOIN behavior.
*/

-- Write your solution below:




/*==============================================================================
    FINAL BEGINNER SELF-CHECK
==============================================================================*/

/*
    Before opening solutions.sql, make sure you can explain:

    1. SELECT * vs explicit columns.

    2. WHERE vs HAVING.

    3. COUNT(*) vs COUNT(column).

    4. Why COUNT(DISTINCT) can matter after joins.

    5. INNER JOIN vs LEFT JOIN.

    6. Why WHERE on the right side of LEFT JOIN can remove unmatched rows.

    7. Why SUM(quantity) differs from COUNT(*).

    8. Why transaction revenue uses order_items.unit_price.

    9. Why NULL requires IS NULL / IS NOT NULL.

    10. Why NULLIF helps safe division.

    11. Why half-open date ranges are useful.

    12. What one-to-many row multiplication means.

    13. Why GROUP BY changes result grain.

    14. Why TOP should normally have an ORDER BY.

    15. Why result grain should be identified before aggregation.
*/


/*==============================================================================
    END OF BEGINNER EXERCISES

    Total:
        80 exercises

    Next file:
        exercises/beginner/solutions.sql
==============================================================================*/