/*==============================================================================
    SQL Mastery
    Chapter 10: Transactions and ACID
    File: solutions.sql
    Database: SQLMastery
    Schema: training

    IMPORTANT:
    - Modification exercises generally end with ROLLBACK.
    - Run two-session concurrency labs section by section.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    SOLUTION 1 - BASIC TRANSACTION
==============================================================================*/

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;

ROLLBACK TRANSACTION;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO


/*==============================================================================
    SOLUTION 2 - TRANSACTION COUNT
==============================================================================*/

SELECT @@TRANCOUNT AS before_transaction;

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS inside_transaction;

ROLLBACK TRANSACTION;

SELECT @@TRANCOUNT AS after_rollback;
GO


/*==============================================================================
    SOLUTION 3 - MULTIPLE CHANGES AS ONE UNIT
==============================================================================*/

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 1;

UPDATE training.products
SET stock_quantity = stock_quantity - 3
WHERE product_id = 2;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;

ROLLBACK TRANSACTION;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;
GO


/*==============================================================================
    SOLUTION 4 - TRY / CATCH TRANSACTION
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity + 5
    WHERE product_id = 1;

    -- Training-safe rollback.
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 5 - CUSTOM BUSINESS ERROR
==============================================================================*/

BEGIN TRY

    DECLARE
        @ProductId INT = 1,
        @RequestedQuantity INT = 1000000,
        @AvailableStock INT;

    SELECT
        @AvailableStock = stock_quantity
    FROM training.products
    WHERE product_id = @ProductId;

    IF @AvailableStock IS NULL
        THROW 50001, 'Product not found.', 1;

    IF @AvailableStock < @RequestedQuantity
        THROW 50002, 'Insufficient inventory.', 1;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO


/*==============================================================================
    SOLUTION 6 - XACT_STATE()
==============================================================================*/

SELECT
    XACT_STATE() AS xact_state,
    @@TRANCOUNT AS transaction_count;

BEGIN TRANSACTION;

SELECT
    XACT_STATE() AS xact_state,
    @@TRANCOUNT AS transaction_count;

ROLLBACK TRANSACTION;

SELECT
    XACT_STATE() AS xact_state,
    @@TRANCOUNT AS transaction_count;
GO


/*==============================================================================
    SOLUTION 7 - @@ROWCOUNT
==============================================================================*/

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity + 1
WHERE product_id = 1;

DECLARE @RowsAffected INT = @@ROWCOUNT;

SELECT @RowsAffected AS rows_affected;

ROLLBACK TRANSACTION;
GO

/*
    @@ROWCOUNT must be captured immediately because subsequent statements
    can change its value.
*/


/*==============================================================================
    SOLUTION 8 - ATOMIC INVENTORY UPDATE
==============================================================================*/

DECLARE
    @ProductId INT = 1,
    @Quantity INT = 2,
    @RowsUpdated INT;

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;

SET @RowsUpdated = @@ROWCOUNT;

SELECT
    @RowsUpdated AS rows_updated,
    CASE
        WHEN @RowsUpdated = 1 THEN 'Inventory reserved'
        ELSE 'Inventory not reserved'
    END AS result;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = @ProductId;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    SOLUTION 9 - INSUFFICIENT INVENTORY
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @ProductId INT = 1,
        @Quantity INT = 1000000;

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50001, 'Insufficient stock or product not found.', 1;

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO


/*==============================================================================
    SOLUTION 10 - SAVEPOINT
==============================================================================*/

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

SAVE TRANSACTION AfterProductOne;

UPDATE training.products
SET stock_quantity = stock_quantity - 5
WHERE product_id = 2;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;

ROLLBACK TRANSACTION AfterProductOne;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    SOLUTION 11 - NESTED TRANSACTION COUNT
==============================================================================*/

SELECT @@TRANCOUNT AS initial_count;

BEGIN TRANSACTION OuterTransaction;

SELECT @@TRANCOUNT AS after_outer_begin;

BEGIN TRANSACTION InnerTransaction;

SELECT @@TRANCOUNT AS after_inner_begin;

COMMIT TRANSACTION InnerTransaction;

SELECT @@TRANCOUNT AS after_inner_commit;

ROLLBACK TRANSACTION OuterTransaction;

SELECT @@TRANCOUNT AS final_count;
GO

/*
    No.

    COMMIT of the inner transaction only reduced @@TRANCOUNT.
    It did not independently make the changes permanent.

    Only the outermost COMMIT would commit the transaction.
*/


/*==============================================================================
    SOLUTION 12 - SCOPE_IDENTITY()
==============================================================================*/

DECLARE @NewOrderId INT;

BEGIN TRANSACTION;

INSERT INTO training.orders
(
    customer_id,
    order_date,
    order_status
)
VALUES
(
    1,
    GETDATE(),
    'Pending'
);

SET @NewOrderId = CONVERT(INT, SCOPE_IDENTITY());

SELECT @NewOrderId AS generated_order_id;

SELECT
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
WHERE order_id = @NewOrderId;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    SOLUTION 13 - CREATE ORDER AND ORDER ITEM
==============================================================================*/

DECLARE
    @OrderId INT,
    @ProductPrice DECIMAL(10, 2);

BEGIN TRANSACTION;

SELECT
    @ProductPrice = price
FROM training.products
WHERE product_id = 1;

INSERT INTO training.orders
(
    customer_id,
    order_date,
    order_status
)
VALUES
(
    1,
    GETDATE(),
    'Pending'
);

SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

INSERT INTO training.order_items
(
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES
(
    @OrderId,
    1,
    2,
    @ProductPrice
);

SELECT *
FROM training.orders
WHERE order_id = @OrderId;

SELECT *
FROM training.order_items
WHERE order_id = @OrderId;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    SOLUTION 14 - SAFE ORDER + INVENTORY TRANSACTION
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @CustomerId INT = 1,
        @ProductId INT = 1,
        @Quantity INT = 2,
        @UnitPrice DECIMAL(10, 2),
        @OrderId INT;

    BEGIN TRANSACTION;

    SELECT
        @UnitPrice = price
    FROM training.products
    WHERE product_id = @ProductId
      AND is_active = 1;

    IF @UnitPrice IS NULL
        THROW 50010, 'Active product not found.', 1;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND is_active = 1
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50011, 'Insufficient inventory.', 1;

    INSERT INTO training.orders
    (
        customer_id,
        order_date,
        order_status
    )
    VALUES
    (
        @CustomerId,
        GETDATE(),
        'Pending'
    );

    SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO training.order_items
    (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES
    (
        @OrderId,
        @ProductId,
        @Quantity,
        @UnitPrice
    );

    SELECT *
    FROM training.orders
    WHERE order_id = @OrderId;

    SELECT *
    FROM training.order_items
    WHERE order_id = @OrderId;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = @ProductId;

    -- Training version only.
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 15 - FAILED ORDER MUST NOT REMAIN
==============================================================================*/

SET XACT_ABORT ON;
GO

DECLARE @AttemptedOrderId INT = NULL;

BEGIN TRY

    DECLARE
        @CustomerId INT = 1,
        @ProductId INT = 1,
        @Quantity INT = 1000000;

    BEGIN TRANSACTION;

    INSERT INTO training.orders
    (
        customer_id,
        order_date,
        order_status
    )
    VALUES
    (
        @CustomerId,
        GETDATE(),
        'Pending'
    );

    SET @AttemptedOrderId = CONVERT(INT, SCOPE_IDENTITY());

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50020, 'Insufficient inventory.', 1;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;

SELECT
    @AttemptedOrderId AS attempted_order_id;

SELECT *
FROM training.orders
WHERE order_id = @AttemptedOrderId;
GO

/*
    The second SELECT should return no order.

    The INSERT occurred inside the same transaction and was undone
    when the inventory operation failed.
*/


/*==============================================================================
    SOLUTION 16 - IDENTITY AND ROLLBACK
==============================================================================*/

DECLARE @RolledBackOrderId INT;

BEGIN TRANSACTION;

INSERT INTO training.orders
(
    customer_id,
    order_date,
    order_status
)
VALUES
(
    1,
    GETDATE(),
    'Pending'
);

SET @RolledBackOrderId = CONVERT(INT, SCOPE_IDENTITY());

SELECT
    @RolledBackOrderId AS generated_identity;

ROLLBACK TRANSACTION;

SELECT TOP (10)
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
ORDER BY order_id DESC;
GO

/*
    No.

    ROLLBACK does not guarantee reuse of an IDENTITY value.
    Identity sequences can therefore contain gaps.

    An identity column guarantees generation behavior, not a
    perfectly gap-free numeric sequence.
*/


/*==============================================================================
    SOLUTION 17 - ACID CLASSIFICATION
==============================================================================*/

/*
    A. Atomicity

       The order and inventory reduction succeed or fail together.


    B. Durability

       Once COMMIT succeeds, committed data must survive recovery.


    C. Consistency

       Constraints and business rules help move the database from
       one valid state to another.


    D. Isolation

       Concurrent transactions interact according to defined
       visibility and concurrency rules.
*/


/*==============================================================================
    SOLUTION 18 - AUTOCOMMIT VS EXPLICIT TRANSACTION
==============================================================================*/

/*
    1. Autocommit

       When no explicit transaction is active, SQL Server normally
       treats each individual statement as its own transaction.

       If the statement succeeds, it is committed automatically.


    2. Why use an explicit transaction?

       An explicit transaction allows several related statements to
       form one atomic unit.

       If any required step fails, all related changes can be rolled back.


    3. Example

       Creating an order, inserting its order items, and reducing inventory
       should generally be coordinated transactionally.
*/


/*==============================================================================
    SOLUTION 19 - DIRTY READ
==============================================================================*/

/*
    1. A dirty read occurs when one transaction reads data changed by
       another transaction before that change has been committed.

    2. READ UNCOMMITTED allows dirty reads.

    3. Dirty reads are dangerous because reports or business decisions
       can use values that are later rolled back and therefore never
       become real committed database state.
*/


/*==============================================================================
    SOLUTION 20 - NON-REPEATABLE READ
==============================================================================*/

/*
    A non-repeatable read occurs when a transaction reads the same row
    twice and sees different committed values because another transaction
    changed the row between the reads.

    Conceptual example:

    Session A:

        BEGIN TRANSACTION;

        SELECT stock_quantity
        FROM training.products
        WHERE product_id = 1;

        -- Session B performs its update here.

        SELECT stock_quantity
        FROM training.products
        WHERE product_id = 1;

        COMMIT;


    Session B:

        UPDATE training.products
        SET stock_quantity = stock_quantity + 1
        WHERE product_id = 1;

    Under suitable isolation/configuration, the two reads in Session A
    may return different values.
*/


/*==============================================================================
    SOLUTION 21 - PHANTOM READ
==============================================================================*/

/*
    A phantom read concerns a SET of matching rows rather than merely
    a changed value in one already-read row.

    Session A might execute:

        SELECT *
        FROM training.orders
        WHERE customer_id = 1;

    Session B could insert and commit another order for customer 1.

    If Session A executes the same predicate again and now receives an
    additional row, that new matching row is a phantom.
*/


/*==============================================================================
    SOLUTION 22 - ISOLATION LEVELS
==============================================================================*/

/*
    Isolation levels covered:

        READ UNCOMMITTED
        READ COMMITTED
        REPEATABLE READ
        SNAPSHOT
        SERIALIZABLE


    1. READ UNCOMMITTED allows dirty reads.

    2. SERIALIZABLE provides strong range protection against phantoms.

    3. Stronger isolation is not automatically better.

       Stronger isolation can improve guarantees but may also increase
       blocking, lock duration, contention, or other concurrency costs.

       The correct isolation strategy depends on the application's
       correctness and performance requirements.
*/


/*==============================================================================
    SOLUTION 23 - TWO-SESSION DIRTY READ LAB
==============================================================================*/

/*
    Run the two sections in TWO separate query windows.

    ------------------------------------------------------------
    SESSION A
    ------------------------------------------------------------

    USE SQLMastery;
    GO

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = 999999
    WHERE product_id = 1;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = 1;

    -- Do not finish Session A until Session B has read the row.

    ROLLBACK TRANSACTION;


    ------------------------------------------------------------
    SESSION B
    ------------------------------------------------------------

    USE SQLMastery;
    GO

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = 1;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


    ANSWER:

    Yes.

    Session B can potentially observe 999999 even though Session A later
    rolls the update back.

    That value was never committed, which makes the read a dirty read.
*/


/*==============================================================================
    SOLUTION 24 - BLOCKING LAB
==============================================================================*/

/*
    Run in two sessions.

    ------------------------------------------------------------
    SESSION A
    ------------------------------------------------------------

    USE SQLMastery;
    GO

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity + 1
    WHERE product_id = 1;

    -- Run Session B while this transaction remains open.

    ROLLBACK TRANSACTION;


    ------------------------------------------------------------
    SESSION B
    ------------------------------------------------------------

    USE SQLMastery;
    GO

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = 1;


    ANSWER:

    Under traditional lock-based READ COMMITTED, Session A's UPDATE
    holds an exclusive lock that conflicts with Session B's required
    read lock.

    Session B can therefore wait until Session A completes.

    Behavior can differ when READ_COMMITTED_SNAPSHOT is enabled.
*/


/*==============================================================================
    SOLUTION 25 - DEADLOCK REASONING
==============================================================================*/

/*
    1. Transaction A owns a lock needed by Transaction B, while
       Transaction B owns a lock needed by Transaction A.

       This creates a circular wait.


    2. Both transactions can reduce this risk by accessing products in
       the same order.

       For example, always update Product 1 before Product 2.


    3. SQL Server detects a deadlock and chooses one transaction as
       the deadlock victim.

       That transaction is rolled back and receives an error.


    4. Suitable application operations should often be prepared to retry
       after a deadlock, generally with controlled retry limits/backoff.
*/


/*==============================================================================
    SOLUTION 26 - SHORT TRANSACTIONS
==============================================================================*/

/*
    A. Waiting for human approval

       Usually should not happen inside an open database transaction.
       The wait can be extremely long while locks/resources remain held.


    B. Calling an external payment API

       Usually should not be performed while unnecessarily holding a
       database transaction open. Network calls can be slow or fail.


    C. Sleeping for several minutes

       This unnecessarily extends transaction duration and can increase
       blocking and resource usage.


    D. Database changes that must succeed atomically

       These are exactly the kind of operations that belong together
       inside a transaction.

       The transaction should still be kept as short as practical.
*/


/*==============================================================================
    SOLUTION 27 - BUSINESS WORKFLOW VS DATABASE TRANSACTION
==============================================================================*/

/*
    No.

    One SQL Server transaction should not normally remain open throughout:

        order placement
        payment processing
        warehouse preparation
        shipping
        delivery

    That workflow could take minutes, hours, or days.

    A database transaction should normally protect a short unit of
    database work.

    A long-lived business workflow should instead persist its state as
    it moves through business stages.

    Real systems may additionally use techniques such as messaging,
    idempotency, outbox patterns, retries, and compensating actions.
*/


/*==============================================================================
    SOLUTION 28 - TRANSACTION ERROR-HANDLING TEMPLATE
==============================================================================*/

/*
    Production-style structure:

        SET XACT_ABORT ON;

        BEGIN TRY

            BEGIN TRANSACTION;

            -- Database changes

            COMMIT TRANSACTION;

        END TRY
        BEGIN CATCH

            IF XACT_STATE() <> 0
                ROLLBACK TRANSACTION;

            THROW;

        END CATCH;
*/


SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity + 1
    WHERE product_id = 1;

    /*
        Training version intentionally rolls back.

        In a real successful operation this would normally be:

            COMMIT TRANSACTION;
    */
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    SOLUTION 29 - TRANSACTION DESIGN REVIEW
==============================================================================*/

/*
    Problems/risks:

    1. The stock SELECT and UPDATE are separate operations.

       Inventory can change between validation and modification.


    2. The transaction waits while application logic makes a decision.

       This unnecessarily increases transaction duration.


    3. The UPDATE does not protect against insufficient inventory.

       It can reduce stock below zero.


    4. Concurrent requests could make decisions based on stale stock.


    Safer pattern:

        UPDATE training.products
        SET stock_quantity = stock_quantity - @Quantity
        WHERE product_id = @ProductId
          AND stock_quantity >= @Quantity;

        IF @@ROWCOUNT = 0
            THROW 50001,
                  'Insufficient stock or product not found.',
                  1;

    This makes the stock requirement part of the modification itself.
*/


/*==============================================================================
    SOLUTION 30 - FINAL CHALLENGE
==============================================================================*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @CustomerId INT = 1,
        @ProductId INT = 1,
        @Quantity INT = 2,
        @UnitPrice DECIMAL(10, 2),
        @OrderId INT,
        @RowsUpdated INT;


    /*--------------------------------------------------------------------------
        Validate quantity before starting transactional work.
    --------------------------------------------------------------------------*/

    IF @Quantity <= 0
        THROW 50100, 'Quantity must be greater than zero.', 1;


    BEGIN TRANSACTION;


    /*--------------------------------------------------------------------------
        Validate customer.
    --------------------------------------------------------------------------*/

    IF NOT EXISTS
    (
        SELECT 1
        FROM training.customers
        WHERE customer_id = @CustomerId
          AND is_active = 1
    )
    BEGIN
        THROW 50101, 'Active customer not found.', 1;
    END;


    /*--------------------------------------------------------------------------
        Get and preserve transaction-time product price.

        The inventory UPDATE below still performs the actual stock check
        atomically.
    --------------------------------------------------------------------------*/

    SELECT
        @UnitPrice = price
    FROM training.products
    WHERE product_id = @ProductId
      AND is_active = 1;

    IF @UnitPrice IS NULL
        THROW 50102, 'Active product not found.', 1;


    /*--------------------------------------------------------------------------
        Atomically reserve inventory.

        stock_quantity >= @Quantity prevents negative inventory.
    --------------------------------------------------------------------------*/

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND is_active = 1
      AND stock_quantity >= @Quantity;

    SET @RowsUpdated = @@ROWCOUNT;

    IF @RowsUpdated = 0
        THROW 50103, 'Insufficient inventory.', 1;


    /*--------------------------------------------------------------------------
        Create exactly one Pending order.
    --------------------------------------------------------------------------*/

    INSERT INTO training.orders
    (
        customer_id,
        order_date,
        order_status
    )
    VALUES
    (
        @CustomerId,
        GETDATE(),
        'Pending'
    );

    SET @OrderId = CONVERT(INT, SCOPE_IDENTITY());


    /*--------------------------------------------------------------------------
        Create exactly one order item.

        unit_price stores the transaction price rather than depending
        on future products.price values.
    --------------------------------------------------------------------------*/

    INSERT INTO training.order_items
    (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES
    (
        @OrderId,
        @ProductId,
        @Quantity,
        @UnitPrice
    );


    /*--------------------------------------------------------------------------
        Verification inside transaction.
    --------------------------------------------------------------------------*/

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status
    FROM training.orders AS o
    WHERE o.order_id = @OrderId;


    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.quantity * oi.unit_price AS line_total
    FROM training.order_items AS oi
    WHERE oi.order_id = @OrderId;


    SELECT
        p.product_id,
        p.product_name,
        p.stock_quantity
    FROM training.products AS p
    WHERE p.product_id = @ProductId;


    /*
        Production success path:

            COMMIT TRANSACTION;

        Training success path:
    */

    ROLLBACK TRANSACTION;

    SELECT
        @OrderId AS rolled_back_demo_order_id,
        'Successful checkout simulation was rolled back.' AS result;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*
    Bonus discussion:

    For multiple products, each line must be validated/reserved as part
    of the same logical checkout transaction.

    Important concerns include:

    - All inventory reservations must succeed before final commit.
    - A failure for one line must rollback the complete checkout.
    - Products should preferably be processed in a consistent order to
      reduce deadlock risk.
    - Set-based approaches are usually preferable to unnecessary loops.
    - The transaction should remain short.
*/


/*==============================================================================
    SOLUTION 31 - FINAL SAFETY CHECK
==============================================================================*/

SELECT
    @@TRANCOUNT AS transaction_count,
    XACT_STATE() AS transaction_state;
GO

/*
    Expected:

        transaction_count = 0
        transaction_state = 0
*/


IF XACT_STATE() <> 0
BEGIN
    ROLLBACK TRANSACTION;
END;
GO


SELECT
    @@TRANCOUNT AS final_transaction_count,
    XACT_STATE() AS final_transaction_state;
GO


/*==============================================================================
    CHAPTER 10 COMPLETE

    You should now understand:

    - Autocommit transactions
    - Explicit transactions
    - BEGIN TRANSACTION
    - COMMIT
    - ROLLBACK
    - @@TRANCOUNT
    - Nested transaction behavior
    - Savepoints
    - TRY / CATCH
    - THROW
    - XACT_STATE()
    - SET XACT_ABORT ON
    - @@ROWCOUNT
    - SCOPE_IDENTITY()
    - Atomic inventory updates
    - Order + inventory transactions
    - ACID
    - Isolation levels
    - Dirty reads
    - Non-repeatable reads
    - Phantom reads
    - Blocking
    - Deadlocks
    - Short transaction design
    - Database transactions vs long-lived business workflows

    Next chapter:
        11_indexes_and_performance
==============================================================================*/