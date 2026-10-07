/*==============================================================================
    SQL Mastery
    Chapter 10: Transactions and ACID
    File: examples.sql
    Database: SQLMastery
    Schema: training

    Topics:
    - Autocommit vs explicit transactions
    - BEGIN TRANSACTION / COMMIT / ROLLBACK
    - @@TRANCOUNT
    - TRY / CATCH
    - XACT_STATE()
    - THROW
    - SET XACT_ABORT ON
    - Savepoints
    - Nested transactions
    - ACID concepts
    - Isolation levels
    - Blocking and concurrency
    - Atomic inventory updates
    - Order + inventory transaction
    - Transaction design best practices

    IMPORTANT:
    Most modification examples intentionally end with ROLLBACK
    so the training data remains unchanged.

    Run examples section by section rather than executing the
    entire file at once, especially the concurrency demonstrations.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    1. AUTOCOMMIT TRANSACTIONS
==============================================================================*/

/*
    By default, SQL Server uses autocommit mode.

    Each individual INSERT, UPDATE, or DELETE statement is treated
    as its own transaction when no explicit transaction is active.

    If the statement succeeds, SQL Server commits it automatically.
*/

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
ORDER BY product_id;
GO


/*------------------------------------------------------------------------------
    The following statement would normally be committed immediately:

    UPDATE training.products
    SET stock_quantity = stock_quantity + 1
    WHERE product_id = 1;

    We do NOT execute it here because we want to preserve the training data.
------------------------------------------------------------------------------*/


/*==============================================================================
    2. BASIC EXPLICIT TRANSACTION
==============================================================================*/

/*
    An explicit transaction gives us control over when changes
    become permanent.

    BEGIN TRANSACTION
        Start transaction

    COMMIT
        Make changes permanent

    ROLLBACK
        Undo changes made by the transaction
*/

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO

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

/*
    The UPDATE is visible inside this transaction.
    We rollback so the original data is restored.
*/

ROLLBACK TRANSACTION;
GO

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = 1;
GO


/*==============================================================================
    3. COMMIT EXAMPLE
==============================================================================*/

/*
    COMMIT makes changes permanent.

    The actual COMMIT version is shown below as documentation,
    but the executable training demonstration uses ROLLBACK.
*/

/*
BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

COMMIT TRANSACTION;
*/


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

-- Training-safe cleanup
ROLLBACK TRANSACTION;
GO


/*==============================================================================
    4. MULTIPLE STATEMENTS AS ONE UNIT
==============================================================================*/

/*
    The major reason for transactions is atomicity.

    Either ALL related changes succeed,
    or NONE of them should remain.

    Example:
    - Create order
    - Create order item
    - Reduce inventory

    Those operations logically belong together.
*/

DECLARE @DemoOrderId INT;

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

SET @DemoOrderId = SCOPE_IDENTITY();

INSERT INTO training.order_items
(
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    @DemoOrderId,
    product_id,
    1,
    price
FROM training.products
WHERE product_id = 1;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

SELECT
    @DemoOrderId AS demo_order_id;

SELECT *
FROM training.orders
WHERE order_id = @DemoOrderId;

SELECT *
FROM training.order_items
WHERE order_id = @DemoOrderId;

-- Keep training data unchanged.
ROLLBACK TRANSACTION;
GO


/*==============================================================================
    5. @@TRANCOUNT
==============================================================================*/

/*
    @@TRANCOUNT tells us how many BEGIN TRANSACTION statements
    are currently active in the session.
*/

SELECT @@TRANCOUNT AS transaction_count_before;
GO

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS transaction_count_inside;

ROLLBACK TRANSACTION;

SELECT @@TRANCOUNT AS transaction_count_after;
GO


/*==============================================================================
    6. NESTED TRANSACTIONS
==============================================================================*/

/*
    SQL Server allows multiple BEGIN TRANSACTION statements.

    However, nested transactions are NOT independent transactions.

    Each BEGIN increments @@TRANCOUNT.
    Each COMMIT normally decrements @@TRANCOUNT by one.

    Only the outermost COMMIT actually commits the transaction.
*/

SELECT @@TRANCOUNT AS initial_trancount;

BEGIN TRANSACTION OuterTransaction;

SELECT @@TRANCOUNT AS after_outer_begin;

BEGIN TRANSACTION InnerTransaction;

SELECT @@TRANCOUNT AS after_inner_begin;

/*
    This COMMIT does not permanently commit the work.
    It only reduces @@TRANCOUNT.
*/
COMMIT TRANSACTION InnerTransaction;

SELECT @@TRANCOUNT AS after_inner_commit;

/*
    Roll back the remaining outer transaction.
*/
ROLLBACK TRANSACTION OuterTransaction;

SELECT @@TRANCOUNT AS final_trancount;
GO


/*==============================================================================
    7. IMPORTANT NESTED TRANSACTION BEHAVIOR
==============================================================================*/

/*
    A normal ROLLBACK without a savepoint rolls back the entire transaction,
    not merely the most recent BEGIN TRANSACTION.

    Conceptual example:

        BEGIN TRANSACTION;
            BEGIN TRANSACTION;
            ...
            ROLLBACK;

    @@TRANCOUNT becomes 0.

    This is one reason nested transaction handling requires care.
*/

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS after_first_begin;

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS after_second_begin;

ROLLBACK TRANSACTION;

SELECT @@TRANCOUNT AS after_full_rollback;
GO


/*==============================================================================
    8. SAVEPOINTS
==============================================================================*/

/*
    SAVE TRANSACTION creates a savepoint.

    We can roll back to the savepoint without rolling back
    the entire transaction.
*/

BEGIN TRANSACTION;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;


/*
    First change
*/
UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;


/*
    Create savepoint after the first change.
*/
SAVE TRANSACTION AfterFirstUpdate;


/*
    Second change
*/
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


/*
    Undo only work performed after the savepoint.
*/
ROLLBACK TRANSACTION AfterFirstUpdate;


SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id IN (1, 2)
ORDER BY product_id;


/*
    Product 1's update still exists inside the transaction.
    Product 2's update was rolled back.

    Now rollback the whole transaction to restore all data.
*/
ROLLBACK TRANSACTION;
GO


/*==============================================================================
    9. BASIC TRY / CATCH
==============================================================================*/

/*
    TRY / CATCH allows us to handle runtime errors.

    A transaction should not be left open when an error occurs.
*/

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - 1
    WHERE product_id = 1;

    /*
        In production we might COMMIT here.

        For this training example, rollback intentionally.
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
    10. ERROR INFORMATION INSIDE CATCH
==============================================================================*/

/*
    SQL Server provides useful error functions inside CATCH:

    ERROR_NUMBER()
    ERROR_MESSAGE()
    ERROR_SEVERITY()
    ERROR_STATE()
    ERROR_LINE()
    ERROR_PROCEDURE()
*/

BEGIN TRY

    THROW 50001, 'Demo business error.', 1;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER()    AS error_number,
        ERROR_MESSAGE()   AS error_message,
        ERROR_SEVERITY()  AS error_severity,
        ERROR_STATE()     AS error_state,
        ERROR_LINE()      AS error_line,
        ERROR_PROCEDURE() AS error_procedure;

END CATCH;
GO


/*==============================================================================
    11. THROWING A BUSINESS ERROR
==============================================================================*/

/*
    THROW can raise a custom business error.

    User-defined error numbers should be 50000 or greater.
*/

BEGIN TRY

    DECLARE @RequestedQuantity INT = 1000000;
    DECLARE @AvailableStock INT;

    SELECT
        @AvailableStock = stock_quantity
    FROM training.products
    WHERE product_id = 1;

    IF @AvailableStock IS NULL
        THROW 50002, 'Product not found.', 1;

    IF @AvailableStock < @RequestedQuantity
        THROW 50003, 'Insufficient inventory.', 1;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER()  AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO


/*==============================================================================
    12. XACT_STATE()
==============================================================================*/

/*
    XACT_STATE() can return:

     1 = An active transaction exists and can be committed.
     0 = No active transaction.
    -1 = An active transaction exists but cannot be committed.

    In error handling, this pattern is common:

        IF XACT_STATE() <> 0
            ROLLBACK;
*/

SELECT
    XACT_STATE() AS xact_state_without_transaction;
GO


BEGIN TRANSACTION;

SELECT
    XACT_STATE() AS xact_state_inside_transaction,
    @@TRANCOUNT  AS transaction_count;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    13. SET XACT_ABORT ON
==============================================================================*/

/*
    SET XACT_ABORT ON tells SQL Server to automatically terminate
    and roll back the transaction for many runtime errors.

    It is commonly used with explicit transactions and TRY/CATCH.
*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - 1
    WHERE product_id = 1;

    /*
        Production code might COMMIT here.
        We rollback for training.
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
    14. ROBUST TRANSACTION TEMPLATE
==============================================================================*/

/*
    A strong general-purpose transaction pattern:

    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- work

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
*/

/*
    Executable training-safe version:
*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - 1
    WHERE product_id = 1;

    /*
        Intentional ROLLBACK instead of COMMIT.
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
    15. @@ROWCOUNT
==============================================================================*/

/*
    @@ROWCOUNT returns the number of rows affected by the
    immediately preceding statement.

    Important:
    Capture it immediately.

    Running another statement can change @@ROWCOUNT.
*/

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

DECLARE @RowsAffected INT = @@ROWCOUNT;

SELECT
    @RowsAffected AS rows_affected;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    16. ATOMIC INVENTORY UPDATE
==============================================================================*/

/*
    This pattern is much safer than:

        1. SELECT stock
        2. Application checks stock
        3. UPDATE stock

    Why?

    Another transaction could modify the inventory between
    the SELECT and UPDATE.

    Instead, make the validation part of the UPDATE itself.
*/

DECLARE @ProductId INT = 1;
DECLARE @Quantity INT = 1;
DECLARE @InventoryRowsAffected INT;

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - @Quantity
WHERE product_id = @ProductId
  AND stock_quantity >= @Quantity;

SET @InventoryRowsAffected = @@ROWCOUNT;

SELECT
    @InventoryRowsAffected AS inventory_rows_affected;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
WHERE product_id = @ProductId;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    17. DETECT INSUFFICIENT INVENTORY
==============================================================================*/

/*
    Request an intentionally unrealistic quantity.

    The UPDATE should affect zero rows.
*/

DECLARE @ProductId INT = 1;
DECLARE @RequestedQuantity INT = 1000000;
DECLARE @RowsUpdated INT;

BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - @RequestedQuantity
WHERE product_id = @ProductId
  AND stock_quantity >= @RequestedQuantity;

SET @RowsUpdated = @@ROWCOUNT;

SELECT
    @RowsUpdated AS rows_updated;

IF @RowsUpdated = 0
BEGIN
    PRINT 'Insufficient stock or product not found.';
END;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    18. INVENTORY UPDATE + THROW
==============================================================================*/

/*
    In application/database logic, zero affected rows can
    become a business error.
*/

BEGIN TRY

    DECLARE @ProductId INT = 1;
    DECLARE @RequestedQuantity INT = 1000000;

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity - @RequestedQuantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @RequestedQuantity;

    IF @@ROWCOUNT = 0
        THROW 50004, 'Insufficient stock or product not found.', 1;

    /*
        Would normally COMMIT if everything succeeds.
    */
    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()  AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO


/*==============================================================================
    19. SCOPE_IDENTITY()
==============================================================================*/

/*
    After inserting into a table with an IDENTITY column,
    SCOPE_IDENTITY() returns the identity generated in
    the current scope.

    This is generally preferred over @@IDENTITY.
*/

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

SELECT
    @NewOrderId AS newly_generated_order_id;

SELECT *
FROM training.orders
WHERE order_id = @NewOrderId;

ROLLBACK TRANSACTION;
GO


/*==============================================================================
    20. COMPLETE ORDER + INVENTORY TRANSACTION
==============================================================================*/

/*
    Business requirement:

    A customer orders a product.

    We need to:

    1. Validate/reduce stock atomically
    2. Create an order
    3. Create the order item
    4. Keep all operations atomic

    If any operation fails:
        rollback everything.

    This example intentionally rolls back at the end.
*/

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


    /*----------------------------------------------------------------------
        Step 1: Obtain transaction price
    ----------------------------------------------------------------------*/

    SELECT
        @UnitPrice = price
    FROM training.products
    WHERE product_id = @ProductId
      AND is_active = 1;

    IF @UnitPrice IS NULL
        THROW 50010, 'Active product not found.', 1;


    /*----------------------------------------------------------------------
        Step 2: Reduce inventory atomically
    ----------------------------------------------------------------------*/

    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND is_active = 1
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50011, 'Insufficient inventory.', 1;


    /*----------------------------------------------------------------------
        Step 3: Create order
    ----------------------------------------------------------------------*/

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


    /*----------------------------------------------------------------------
        Step 4: Create order item

        Notice:
        The transaction-time price is copied into unit_price.

        This preserves the sale price even if products.price
        changes in the future.
    ----------------------------------------------------------------------*/

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


    /*----------------------------------------------------------------------
        Inspect transaction before rollback
    ----------------------------------------------------------------------*/

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
        oi.unit_price
    FROM training.order_items AS oi
    WHERE oi.order_id = @OrderId;


    SELECT
        p.product_id,
        p.product_name,
        p.stock_quantity
    FROM training.products AS p
    WHERE p.product_id = @ProductId;


    /*
        Production version:
            COMMIT TRANSACTION;

        Training version:
    */
    ROLLBACK TRANSACTION;

    PRINT 'Training transaction succeeded and was intentionally rolled back.';

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO


/*==============================================================================
    21. FAILURE DEMO: ORDER WITH INSUFFICIENT STOCK
==============================================================================*/

/*
    Atomicity means the order should NOT remain if inventory
    cannot be reserved.

    We deliberately request an unrealistic quantity.
*/

SET XACT_ABORT ON;
GO

BEGIN TRY

    DECLARE
        @CustomerId INT = 1,
        @ProductId INT = 1,
        @Quantity INT = 1000000,
        @OrderId INT;

    BEGIN TRANSACTION;


    /*
        Create an order first.
    */
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


    /*
        Try to reserve inventory.
    */
    UPDATE training.products
    SET stock_quantity = stock_quantity - @Quantity
    WHERE product_id = @ProductId
      AND stock_quantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50012, 'Insufficient inventory. Order cancelled.', 1;


    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER()  AS error_number,
        ERROR_MESSAGE() AS error_message;

END CATCH;
GO


/*
    Verify that no failed demo order remained.

    Identity values can still show gaps after rollback.
    Rolling back an INSERT does not guarantee reuse of the
    consumed identity value.
*/

SELECT TOP (10)
    order_id,
    customer_id,
    order_date,
    order_status
FROM training.orders
ORDER BY order_id DESC;
GO


/*==============================================================================
    22. ACID: ATOMICITY
==============================================================================*/

/*
    Atomicity:

    A transaction behaves as one logical unit.

    Either all required operations succeed,
    or the transaction is rolled back.

    Example:
        order created
        + order item created
        + inventory reduced

    We should not allow only part of this business operation
    to remain.
*/


/*==============================================================================
    23. ACID: CONSISTENCY
==============================================================================*/

/*
    Consistency:

    Transactions should move the database from one valid state
    to another valid state.

    Database rules help maintain consistency:

    - PRIMARY KEY
    - FOREIGN KEY
    - UNIQUE constraints
    - CHECK constraints
    - NOT NULL
    - business validation

    Transactions do not magically define business correctness.
    Good constraints and good transaction logic work together.
*/


/*==============================================================================
    24. ACID: ISOLATION
==============================================================================*/

/*
    Isolation:

    Concurrent transactions should interact according to the
    configured isolation rules.

    Questions include:

    - Can one transaction see another transaction's uncommitted data?
    - Can values change between two reads?
    - Can new matching rows appear between two reads?

    Isolation levels control these trade-offs.
*/


/*==============================================================================
    25. ACID: DURABILITY
==============================================================================*/

/*
    Durability:

    Once a transaction successfully commits, SQL Server ensures
    the committed changes survive failures according to its
    durability/recovery mechanisms.

    The transaction log is fundamental to this behavior.
*/


/*==============================================================================
    26. CURRENT SESSION ISOLATION LEVEL
==============================================================================*/

/*
    SQL Server commonly uses READ COMMITTED as the default
    isolation level.

    DBCC USEROPTIONS can display session options including
    the current isolation level.
*/

DBCC USEROPTIONS;
GO


/*==============================================================================
    27. ISOLATION LEVEL SYNTAX
==============================================================================*/

/*
    Common SQL Server isolation levels:

    READ UNCOMMITTED
    READ COMMITTED
    REPEATABLE READ
    SNAPSHOT
    SERIALIZABLE

    Example:

        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        BEGIN TRANSACTION;

        SELECT ...

        COMMIT;

    Restore the session when appropriate:

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
*/


/*==============================================================================
    28. READ UNCOMMITTED
==============================================================================*/

/*
    READ UNCOMMITTED allows dirty reads.

    A dirty read means reading data another transaction
    has changed but not yet committed.

    Example syntax:
*/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT
    product_id,
    product_name,
    stock_quantity
FROM training.products
ORDER BY product_id;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


/*==============================================================================
    29. DIRTY READ DEMONSTRATION
==============================================================================*/

/*
    This demonstration requires TWO query windows/sessions.

    Do NOT simply execute both blocks in the same session.

    ------------------------------------------------------------
    SESSION A
    ------------------------------------------------------------

    USE SQLMastery;
    GO

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = 999999
    WHERE product_id = 1;

    -- Keep transaction open temporarily.
    -- Run Session B now.

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

    ------------------------------------------------------------

    Session B may see 999999 even though Session A eventually
    rolls it back.

    That is a dirty read.
*/


/*==============================================================================
    30. READ COMMITTED AND BLOCKING
==============================================================================*/

/*
    Under traditional lock-based READ COMMITTED behavior,
    a reader may wait for another transaction's uncommitted write.

    Two-session demonstration:

    ------------------------------------------------------------
    SESSION A
    ------------------------------------------------------------

    BEGIN TRANSACTION;

    UPDATE training.products
    SET stock_quantity = stock_quantity + 10
    WHERE product_id = 1;

    -- Keep transaction open temporarily.


    ------------------------------------------------------------
    SESSION B
    ------------------------------------------------------------

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    SELECT
        product_id,
        stock_quantity
    FROM training.products
    WHERE product_id = 1;

    ------------------------------------------------------------

    Depending on database configuration, Session B may block
    until Session A commits or rolls back.

    Then in Session A:

        ROLLBACK TRANSACTION;

    Important:
    READ_COMMITTED_SNAPSHOT database configuration can change
    reader/writer behavior by using row versions.
*/


/*==============================================================================
    31. NON-REPEATABLE READ
==============================================================================*/

/*
    Non-repeatable read:

    Transaction A reads the same row twice.
    Transaction B modifies and commits that row between the reads.

    Transaction A can then see two different values.

    This can occur under lock-based READ COMMITTED.

    Conceptual timeline:

        Session A:
            BEGIN TRANSACTION;
            SELECT stock_quantity ...

        Session B:
            UPDATE ...
            COMMIT;

        Session A:
            SELECT stock_quantity ...
            COMMIT;

    The two SELECT results in Session A may differ.
*/


/*==============================================================================
    32. PHANTOM READ
==============================================================================*/

/*
    Phantom read:

    The same search condition is executed twice,
    but another transaction inserts/deletes qualifying rows
    between those reads.

    Example:

        SELECT *
        FROM training.orders
        WHERE customer_id = 1;

    Another session inserts a new qualifying order.

    The first transaction repeats the query and sees an
    additional row.

    SERIALIZABLE provides stronger protection against
    these phantom changes using range protection.
*/


/*==============================================================================
    33. REPEATABLE READ
==============================================================================*/

/*
    REPEATABLE READ provides stronger read stability than
    lock-based READ COMMITTED.

    Shared locks on rows read are generally held until
    the transaction ends.

    However, it does not provide the same range protection
    against phantoms as SERIALIZABLE.
*/

/*
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;

SELECT *
FROM training.products
WHERE product_id = 1;

-- Additional work

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
*/


/*==============================================================================
    34. SERIALIZABLE
==============================================================================*/

/*
    SERIALIZABLE is a strong isolation level.

    It can prevent:
    - dirty reads
    - non-repeatable reads
    - phantom reads

    Stronger isolation can also increase:
    - blocking
    - lock duration
    - contention

    So higher isolation is not automatically "better".
    It is a correctness/performance trade-off.
*/

/*
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

SELECT *
FROM training.orders
WHERE customer_id = 1;

-- Keep transaction short.

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
*/


/*==============================================================================
    35. SNAPSHOT ISOLATION
==============================================================================*/

/*
    SNAPSHOT isolation uses row versions rather than relying only
    on shared locks for consistent reads.

    It can reduce some reader/writer blocking.

    SNAPSHOT must be enabled at the database level before use.

    Example database-level configuration:

        ALTER DATABASE SQLMastery
        SET ALLOW_SNAPSHOT_ISOLATION ON;

    Then a session could use:

        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    Do NOT change database-level configuration here automatically.
*/


/*==============================================================================
    36. READ COMMITTED SNAPSHOT
==============================================================================*/

/*
    READ_COMMITTED_SNAPSHOT (RCSI) changes how READ COMMITTED
    works at the database level.

    With RCSI enabled, READ COMMITTED reads can use row versions,
    reducing many reader/writer blocking scenarios.

    It is different from explicitly setting:

        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

    Database-level isolation configuration should be changed
    intentionally and tested before production use.
*/


/*==============================================================================
    37. LOCKING AND BLOCKING
==============================================================================*/

/*
    Locks help protect transactional correctness.

    Common lock concepts include:

    - Shared locks
    - Exclusive locks
    - Update locks
    - Intent locks
    - Key/range locks

    Blocking is not automatically an error.

    Example:

        Transaction A needs a resource and holds a lock.
        Transaction B requests an incompatible lock.
        Transaction B waits.

    The major concern is excessive or unnecessary blocking.
*/


/*==============================================================================
    38. DEADLOCK CONCEPT
==============================================================================*/

/*
    A deadlock occurs when transactions wait on one another
    in a cycle.

    Simplified example:

        Transaction A locks Product 1.
        Transaction B locks Product 2.

        Transaction A requests Product 2.
        Transaction B requests Product 1.

    Neither can continue.

    SQL Server detects the deadlock and chooses one transaction
    as the deadlock victim.

    The victim is rolled back and receives an error.

    Applications should be designed to retry suitable transactions.
*/


/*==============================================================================
    39. REDUCING DEADLOCK RISK
==============================================================================*/

/*
    Useful practices:

    - Keep transactions short.
    - Access resources in a consistent order.
    - Avoid unnecessary user interaction inside transactions.
    - Index queries appropriately.
    - Modify only the rows you actually need.
    - Avoid unnecessarily high isolation levels.
    - Build retry handling for deadlock victims where appropriate.
*/


/*==============================================================================
    40. TRANSACTIONS SHOULD BE SHORT
==============================================================================*/

/*
    Bad pattern conceptually:

        BEGIN TRANSACTION;

        UPDATE ...

        -- Wait for a human to approve something
        -- Call an external API
        -- Perform a long calculation

        COMMIT;

    The transaction may hold database resources the entire time.

    Prefer doing non-database preparation before BEGIN TRANSACTION
    whenever business correctness allows.
*/


/*==============================================================================
    41. DATABASE TRANSACTION VS BUSINESS WORKFLOW
==============================================================================*/

/*
    A database transaction is usually short-lived.

    A business workflow can be much longer.

    Example e-commerce workflow:

        Customer places order
        Payment provider processes payment
        Warehouse prepares shipment
        Carrier delivers package

    This entire multi-hour/day workflow should NOT normally be
    represented by one SQL transaction held open the whole time.

    Instead, systems typically store durable state transitions
    and use workflow/message/application patterns.
*/


/*==============================================================================
    42. VERIFY TRANSACTION CLEANUP
==============================================================================*/

/*
    At the end of training scripts it is useful to confirm that
    no transaction was accidentally left open.
*/

SELECT
    @@TRANCOUNT AS open_transaction_count,
    XACT_STATE() AS transaction_state;
GO


/*==============================================================================
    43. SAFETY CLEANUP
==============================================================================*/

/*
    Expected:
        @@TRANCOUNT = 0
        XACT_STATE() = 0

    If this training session somehow still has an active
    transaction, roll it back.
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
    44. KEY TAKEAWAYS
==============================================================================*/

/*
    1. Use transactions when multiple database changes must succeed
       or fail as one logical unit.

    2. BEGIN TRANSACTION starts an explicit transaction.

    3. COMMIT makes successful work permanent.

    4. ROLLBACK undoes transactional work.

    5. @@TRANCOUNT tells you whether nested BEGIN statements exist.

    6. Nested SQL Server transactions are not independent.

    7. SAVE TRANSACTION can establish rollback savepoints.

    8. TRY/CATCH + XACT_STATE() + THROW form a strong error-handling
       foundation.

    9. SET XACT_ABORT ON is valuable for many transactional routines.

    10. Capture @@ROWCOUNT immediately after the statement being checked.

    11. SCOPE_IDENTITY() is useful when inserting parent rows with
        identity keys.

    12. Put inventory validation into the UPDATE predicate when possible:

            UPDATE ...
            WHERE stock_quantity >= @Quantity;

    13. Transactions protect atomicity, but constraints and business
        rules are also required for consistency.

    14. Isolation level affects correctness, concurrency, and blocking.

    15. Stronger isolation can reduce concurrency.

    16. Keep transactions as short as practical.

    17. Avoid holding database transactions open while waiting for
        humans, external services, or long-running workflows.

    18. Committed transactions are supported by SQL Server's
        transaction logging and recovery mechanisms.

    19. Production transaction logic should be designed deliberately
        for concurrency, errors, deadlocks, retries, and data integrity.

    20. Always know whether your code intends to COMMIT or ROLLBACK.
*/