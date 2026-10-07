/*==============================================================================
    SQL Mastery
    Chapter 10: Transactions and ACID
    File: exercises.sql
    Database: SQLMastery
    Schema: training

    Purpose:
    Practice safe transaction handling, error handling, inventory updates,
    savepoints, ACID concepts, and concurrency/isolation reasoning.

    IMPORTANT:
    - Most exercises that modify data should end with ROLLBACK.
    - Do not permanently modify the training dataset unless explicitly intended.
    - Run concurrency exercises in separate SSMS / VS Code query sessions.
==============================================================================*/

USE SQLMastery;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
    EXERCISE 1 - BASIC TRANSACTION
==============================================================================*/

/*
    Write a transaction that:

    1. Starts an explicit transaction.
    2. Decreases stock_quantity by 1 for product_id = 1.
    3. SELECTs the product inside the transaction.
    4. Rolls the transaction back.
    5. SELECTs the product again after the rollback.

    Goal:
    Verify that ROLLBACK restores the original stock value.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 2 - TRANSACTION COUNT
==============================================================================*/

/*
    Demonstrate @@TRANCOUNT.

    Requirements:

    1. Display @@TRANCOUNT before starting a transaction.
    2. BEGIN TRANSACTION.
    3. Display @@TRANCOUNT again.
    4. ROLLBACK.
    5. Display @@TRANCOUNT one final time.

    Expected pattern:
        0 -> 1 -> 0
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 3 - MULTIPLE CHANGES AS ONE UNIT
==============================================================================*/

/*
    Create one transaction that:

    1. Reduces stock for product_id = 1 by 2.
    2. Reduces stock for product_id = 2 by 3.
    3. Displays both products before rollback.
    4. Rolls back the complete transaction.
    5. Displays both products after rollback.

    Goal:
    Demonstrate atomic rollback of multiple changes.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 4 - TRY / CATCH TRANSACTION
==============================================================================*/

/*
    Write a transaction using TRY/CATCH.

    Inside TRY:

    1. BEGIN TRANSACTION.
    2. Increase product_id = 1 stock by 5.
    3. Roll back intentionally for training safety.

    Inside CATCH:

    1. Check XACT_STATE().
    2. If a transaction exists, roll it back.
    3. Re-throw the original error with THROW.

    Also enable:
        SET XACT_ABORT ON;
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 5 - CUSTOM BUSINESS ERROR
==============================================================================*/

/*
    Create:

        @ProductId = 1
        @RequestedQuantity = 1000000

    Read the available stock.

    Throw a custom error if:

    - the product does not exist
    OR
    - available stock is less than the requested quantity.

    Use custom error numbers >= 50000.

    Catch the error and return:

    - ERROR_NUMBER()
    - ERROR_MESSAGE()
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 6 - XACT_STATE()
==============================================================================*/

/*
    Demonstrate XACT_STATE().

    Display:

    1. XACT_STATE() before a transaction.
    2. XACT_STATE() inside an active transaction.
    3. XACT_STATE() after rollback.

    Also display @@TRANCOUNT at each stage.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 7 - @@ROWCOUNT
==============================================================================*/

/*
    Inside a transaction:

    1. Update product_id = 1.
    2. Store @@ROWCOUNT immediately in a variable.
    3. Display the stored value.
    4. Roll back.

    Question:
    Why should @@ROWCOUNT be captured immediately after the UPDATE?

    Write the SQL and answer in a comment.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 8 - ATOMIC INVENTORY UPDATE
==============================================================================*/

/*
    Variables:

        @ProductId = 1
        @Quantity = 2

    Write ONE UPDATE that decreases stock only when:

        stock_quantity >= @Quantity

    Then:

    1. Capture @@ROWCOUNT.
    2. Display whether the update succeeded.
    3. Display the temporary stock value.
    4. Roll back.

    Do NOT perform a separate stock availability SELECT
    before the UPDATE.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 9 - INSUFFICIENT INVENTORY
==============================================================================*/

/*
    Use:

        @ProductId = 1
        @Quantity = 1000000

    Try to reduce inventory atomically.

    If zero rows are updated:

        THROW 50001, 'Insufficient stock or product not found.', 1;

    Requirements:

    - SET XACT_ABORT ON
    - TRY/CATCH
    - Explicit transaction
    - XACT_STATE() cleanup
    - Display the caught error
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 10 - SAVEPOINT
==============================================================================*/

/*
    Write a transaction with these steps:

    1. Reduce product_id = 1 stock by 1.
    2. Create a savepoint named AfterProductOne.
    3. Reduce product_id = 2 stock by 5.
    4. Display both products.
    5. Roll back to AfterProductOne.
    6. Display both products again.
    7. Roll back the entire remaining transaction.

    Goal:
    Verify that rollback to a savepoint only undoes work after
    the savepoint.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 11 - NESTED TRANSACTION COUNT
==============================================================================*/

/*
    Demonstrate nested transaction behavior.

    Requirements:

    1. Display initial @@TRANCOUNT.
    2. BEGIN outer transaction.
    3. Display @@TRANCOUNT.
    4. BEGIN inner transaction.
    5. Display @@TRANCOUNT.
    6. COMMIT the inner transaction.
    7. Display @@TRANCOUNT.
    8. ROLLBACK the outer transaction.
    9. Display final @@TRANCOUNT.

    Question:
    Did COMMIT of the inner transaction permanently commit the work?

    Answer in a SQL comment.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 12 - SCOPE_IDENTITY()
==============================================================================*/

/*
    Inside a transaction:

    1. Insert a Pending order for customer_id = 1.
    2. Store the generated order_id using SCOPE_IDENTITY().
    3. Display the generated ID.
    4. SELECT the inserted order.
    5. Roll back.

    Goal:
    Practice retrieving an IDENTITY value safely.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 13 - CREATE ORDER AND ORDER ITEM
==============================================================================*/

/*
    Build one transaction that:

    1. Creates a Pending order for customer_id = 1.
    2. Captures the new order_id.
    3. Inserts an order item:
           product_id = 1
           quantity = 2
           unit_price = current products.price
    4. Displays the new order.
    5. Displays the new order item.
    6. Rolls back everything.

    Requirements:
    Use SCOPE_IDENTITY() for the order ID.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 14 - SAFE ORDER + INVENTORY TRANSACTION
==============================================================================*/

/*
    Build a complete transaction using:

        @CustomerId = 1
        @ProductId = 1
        @Quantity = 2

    Requirements:

    1. SET XACT_ABORT ON.
    2. Use TRY/CATCH.
    3. BEGIN TRANSACTION.
    4. Get the current price of the active product.
    5. Throw an error if the active product does not exist.
    6. Atomically reduce inventory using:

           WHERE stock_quantity >= @Quantity

    7. If zero rows are updated, throw an insufficient-stock error.
    8. Insert a Pending order.
    9. Capture order_id with SCOPE_IDENTITY().
    10. Insert the order item using the captured price.
    11. Display the temporary order and item.
    12. ROLLBACK for training safety.
    13. In CATCH, roll back if necessary and THROW.

    This is one of the most important exercises in the chapter.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 15 - FAILED ORDER MUST NOT REMAIN
==============================================================================*/

/*
    Use:

        @CustomerId = 1
        @ProductId = 1
        @Quantity = 1000000

    Inside one transaction:

    1. Insert a Pending order first.
    2. Capture its order_id.
    3. Attempt the atomic inventory reduction.
    4. If inventory cannot be reduced, THROW an error.
    5. CATCH the error and rollback the transaction.

    After the CATCH:

    Verify that the attempted order does not exist.

    Goal:
    Demonstrate transaction atomicity when a later operation fails.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 16 - IDENTITY AND ROLLBACK
==============================================================================*/

/*
    Create an order inside a transaction.

    Capture its generated order_id.

    Roll back the transaction.

    Then inspect the latest order IDs.

    Question:
    Does rolling back guarantee that the generated identity value
    will be reused?

    Answer in a SQL comment.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 17 - ACID CLASSIFICATION
==============================================================================*/

/*
    Match each scenario to the most relevant ACID property.

    Write your answers in comments.

    A.
    An order and its inventory reduction must either both succeed
    or both fail.

    Answer:


    B.
    After COMMIT succeeds, the data must survive system recovery.

    Answer:


    C.
    Foreign keys and business rules help ensure the database moves
    from one valid state to another.

    Answer:


    D.
    Two concurrent transactions should interact according to defined
    visibility/concurrency rules.

    Answer:
*/




/*==============================================================================
    EXERCISE 18 - AUTOCOMMIT VS EXPLICIT TRANSACTION
==============================================================================*/

/*
    Answer in comments:

    1. What is autocommit mode?

    2. Why would you use an explicit transaction instead of allowing
       each statement to commit independently?

    3. Give one example from the training schema where multiple
       statements logically belong in the same transaction.
*/




/*==============================================================================
    EXERCISE 19 - DIRTY READ
==============================================================================*/

/*
    Answer in comments:

    1. What is a dirty read?

    2. Which isolation level explicitly allows dirty reads?

    3. Why can dirty reads be dangerous in business reporting?
*/




/*==============================================================================
    EXERCISE 20 - NON-REPEATABLE READ
==============================================================================*/

/*
    Explain in comments:

    What is a non-repeatable read?

    Create a conceptual example using:

        training.products.stock_quantity

    Describe what Session A and Session B would do.
*/




/*==============================================================================
    EXERCISE 21 - PHANTOM READ
==============================================================================*/

/*
    Explain in comments:

    What is a phantom read?

    Use this conceptual query:

        SELECT *
        FROM training.orders
        WHERE customer_id = 1;

    Describe how another transaction could cause a phantom row
    to appear.
*/




/*==============================================================================
    EXERCISE 22 - ISOLATION LEVELS
==============================================================================*/

/*
    List these SQL Server isolation levels from the chapter:

    - READ UNCOMMITTED
    - READ COMMITTED
    - REPEATABLE READ
    - SNAPSHOT
    - SERIALIZABLE

    Then answer:

    1. Which one allows dirty reads?

    2. Which one provides strong range protection against phantoms?

    3. Does stronger isolation always mean better system design?

    Explain briefly in comments.
*/




/*==============================================================================
    EXERCISE 23 - TWO-SESSION DIRTY READ LAB
==============================================================================*/

/*
    This exercise requires TWO query windows.

    Write SQL for Session A that:

    1. Begins a transaction.
    2. Sets stock_quantity = 999999 for product_id = 1.
    3. Leaves the transaction open temporarily.
    4. Eventually rolls it back.

    Write SQL for Session B that:

    1. Uses READ UNCOMMITTED.
    2. Reads product_id = 1.
    3. Restores isolation level to READ COMMITTED.

    Question:
    Can Session B observe a value that never becomes committed?

    IMPORTANT:
    Do not leave Session A's transaction open after the experiment.
*/

-- SESSION A:




-- SESSION B:




/*==============================================================================
    EXERCISE 24 - BLOCKING LAB
==============================================================================*/

/*
    This exercise requires TWO query windows.

    Session A:

    1. BEGIN TRANSACTION.
    2. UPDATE product_id = 1.
    3. Keep transaction open briefly.

    Session B:

    1. Use READ COMMITTED.
    2. SELECT product_id = 1.

    Observe whether Session B waits.

    Then rollback Session A.

    Answer in comments:

    Why can blocking occur?

    NOTE:
    Actual behavior can differ if READ_COMMITTED_SNAPSHOT is enabled.
*/

-- SESSION A:




-- SESSION B:




/*==============================================================================
    EXERCISE 25 - DEADLOCK REASONING
==============================================================================*/

/*
    Consider:

    Transaction A:
        1. Updates product 1.
        2. Then attempts to update product 2.

    Transaction B:
        1. Updates product 2.
        2. Then attempts to update product 1.

    Answer in comments:

    1. Why can this produce a deadlock?

    2. How can consistent resource access order reduce the risk?

    3. What does SQL Server do when it detects a deadlock?

    4. What should suitable application logic often be prepared to do
       after becoming a deadlock victim?
*/




/*==============================================================================
    EXERCISE 26 - SHORT TRANSACTIONS
==============================================================================*/

/*
    Which operations should usually NOT be placed inside a long-running
    database transaction?

    Explain why for each:

    A. Waiting for human approval.

    B. Calling an external payment API.

    C. Sleeping for several minutes.

    D. Performing database updates that must succeed atomically.

    Write answers in comments.
*/




/*==============================================================================
    EXERCISE 27 - BUSINESS WORKFLOW VS DATABASE TRANSACTION
==============================================================================*/

/*
    Consider this workflow:

        1. Customer places order.
        2. Payment provider processes payment.
        3. Warehouse prepares shipment.
        4. Carrier delivers package.

    Question:

    Should one SQL Server transaction remain open from step 1
    until step 4?

    Explain why or why not.

    Mention the difference between:
    - a short database transaction
    - a long-lived business workflow
*/




/*==============================================================================
    EXERCISE 28 - TRANSACTION ERROR-HANDLING TEMPLATE
==============================================================================*/

/*
    From memory, write the general production-style pattern containing:

    - SET XACT_ABORT ON
    - BEGIN TRY
    - BEGIN TRANSACTION
    - database changes
    - COMMIT
    - BEGIN CATCH
    - XACT_STATE()
    - ROLLBACK
    - THROW

    This exercise should end with a safe example that does not
    permanently modify training data.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 29 - TRANSACTION DESIGN REVIEW
==============================================================================*/

/*
    Review the following pseudo-code:

        BEGIN TRANSACTION;

        SELECT stock_quantity
        FROM training.products
        WHERE product_id = 1;

        -- Application waits and decides whether stock is sufficient.

        UPDATE training.products
        SET stock_quantity = stock_quantity - 5
        WHERE product_id = 1;

        COMMIT;

    Identify at least THREE problems or risks.

    Then describe a safer inventory update pattern.

    Write your answer in comments.
*/




/*==============================================================================
    EXERCISE 30 - FINAL CHALLENGE
==============================================================================*/

/*
    Build a robust single-product checkout transaction.

    Inputs:

        @CustomerId
        @ProductId
        @Quantity

    Business rules:

    1. Customer must exist and be active.
    2. Product must exist and be active.
    3. Quantity must be greater than zero.
    4. Product must have enough inventory.
    5. Inventory must never become negative.
    6. Create exactly one Pending order.
    7. Create exactly one order item.
    8. order_items.unit_price must preserve the current product price.
    9. Any failure must rollback all changes.
    10. The training version must rollback even after success.

    Technical requirements:

    - SET XACT_ABORT ON
    - TRY/CATCH
    - Explicit transaction
    - THROW custom business errors
    - Atomic inventory UPDATE
    - @@ROWCOUNT
    - SCOPE_IDENTITY()
    - XACT_STATE()
    - Final verification queries

    Suggested test values:

        @CustomerId = 1
        @ProductId = 1
        @Quantity = 2

    Bonus:
    Think about how this design would need to change for an order
    containing multiple different products.
*/

-- Write your solution below:




/*==============================================================================
    EXERCISE 31 - FINAL SAFETY CHECK
==============================================================================*/

/*
    Write a query that displays:

        @@TRANCOUNT
        XACT_STATE()

    Expected after all exercises:

        @@TRANCOUNT = 0
        XACT_STATE() = 0

    If an active transaction remains in this training session,
    safely roll it back.
*/

-- Write your solution below:




/*==============================================================================
    END OF EXERCISES

    Skills practiced:

    - BEGIN TRANSACTION
    - COMMIT
    - ROLLBACK
    - @@TRANCOUNT
    - TRY/CATCH
    - THROW
    - XACT_STATE()
    - XACT_ABORT
    - @@ROWCOUNT
    - SCOPE_IDENTITY()
    - SAVE TRANSACTION
    - Atomic conditional UPDATE
    - ACID reasoning
    - Isolation levels
    - Dirty reads
    - Non-repeatable reads
    - Phantom reads
    - Blocking
    - Deadlocks
    - Short transaction design
    - Order/inventory atomicity

    Next file:
        solutions.sql
==============================================================================*/