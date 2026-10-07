# 10 - Transactions and ACID

## Objective

Learn how SQL Server transactions protect data when multiple database changes belong to one logical operation.

This chapter covers:

- Transactions
- BEGIN TRANSACTION
- COMMIT
- ROLLBACK
- @@TRANCOUNT
- TRY / CATCH
- XACT_STATE()
- THROW
- Atomicity
- Consistency
- Isolation
- Durability
- Autocommit
- Explicit transactions
- Transaction errors
- Safe inventory updates
- Multi-step business operations
- Isolation levels
- Concurrency concepts
- Dirty reads
- Non-repeatable reads
- Phantom reads
- Deadlocks
- Transaction design

---

# Learning Database

```text
SQLMastery
```

# Learning Schema

```text
training
```

---

# Important Safety Rule

Transactions can modify real data.

Do not experiment casually against production databases.

This chapter uses:

```text
SQLMastery
```

as a learning environment.

For demonstrations, we will frequently use:

```sql
ROLLBACK;
```

so changes can be tested without being permanently saved.

---

# 1. What Is a Transaction?

A transaction groups one or more database operations into one logical unit of work.

Example business operation:

```text
Customer places an order.
```

The database may need to:

```text
1. Create the order

2. Add order items

3. Reduce inventory

4. Record related changes
```

From the business perspective, these steps belong together.

We usually do not want:

```text
Order created
but
inventory update failed
```

leaving the database partially updated.

Transactions help protect against that.

---

# 2. Basic Transaction Structure

Basic T-SQL syntax:

```sql
BEGIN TRANSACTION;

-- database changes

COMMIT TRANSACTION;
```

`BEGIN TRANSACTION` starts the explicit transaction.

`COMMIT` permanently completes its changes.

---

# 3. ROLLBACK

Instead of saving changes:

```sql
ROLLBACK TRANSACTION;
```

undoes changes made by the active transaction, subject to transaction semantics.

Example:

```sql
BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

ROLLBACK TRANSACTION;
```

The stock update is undone.

---

# 4. COMMIT

Example:

```sql
BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity + 1
WHERE product_id = 1;

COMMIT TRANSACTION;
```

After a successful commit, that change becomes durable according to SQL Server's transaction guarantees.

---

# 5. COMMIT vs ROLLBACK

Think:

```text
COMMIT
    Keep the transaction changes.

ROLLBACK
    Undo the transaction changes.
```

---

# 6. Why Transactions Matter

Imagine transferring money:

```text
Account A:
-100

Account B:
+100
```

If only the first statement succeeds:

```text
money disappears
```

If only the second succeeds:

```text
money appears from nowhere
```

These updates should belong to one transaction.

Either:

```text
both succeed
```

or:

```text
neither remains
```

This demonstrates Atomicity.

---

# 7. ACID

ACID stands for:

```text
Atomicity
Consistency
Isolation
Durability
```

These are core transaction properties.

---

# 8. Atomicity

Atomicity means:

```text
A transaction behaves as one logical unit.
```

Either the transaction's intended work completes and commits, or its changes are rolled back when the transaction cannot complete safely.

Example:

```text
Create Order
Add Order Item
Reduce Stock
```

We do not want to intentionally leave only part of that logical operation committed.

---

# 9. Consistency

Consistency means a transaction should move the database from one valid state to another valid state, with integrity rules preserved.

Examples:

```text
Primary Keys remain valid

Foreign Keys remain valid

CHECK constraints remain valid

Business rules remain valid
```

The database can enforce many structural rules, but application/transaction logic may also be required for business rules.

---

# 10. Isolation

Isolation controls how concurrent transactions interact and what changes they can observe from each other.

Two users can execute transactions at the same time.

SQL Server needs rules governing:

```text
What can each session read?

Which changes are visible?

Which operations must wait?

What anomalies are allowed?
```

Isolation levels control these trade-offs.

---

# 11. Durability

Durability means that after a transaction is successfully committed, SQL Server is responsible for preserving the committed change through its durability and recovery mechanisms.

Conceptually:

```text
COMMIT succeeded
->
the transaction is no longer temporary work
```

---

# 12. Autocommit

By default, SQL Server commonly operates in autocommit mode.

Example:

```sql
UPDATE training.products
SET price = 1000
WHERE product_id = 2;
```

Without an explicit transaction, SQL Server treats the statement as its own transaction.

If it succeeds, it is committed automatically.

---

# 13. Explicit Transaction

An explicit transaction gives you control over multiple statements.

```sql
BEGIN TRANSACTION;

UPDATE ...;

INSERT ...;

UPDATE ...;

COMMIT;
```

All statements participate in the active transaction unless the transaction is otherwise ended or affected by an error.

---

# 14. Testing with ROLLBACK

A useful learning pattern:

```sql
SELECT ...
FROM ...;

BEGIN TRANSACTION;

UPDATE ...;

SELECT ...
FROM ...;

ROLLBACK;

SELECT ...
FROM ...;
```

This lets you observe:

```text
Before

During transaction

After rollback
```

---

# 15. @@TRANCOUNT

SQL Server provides:

```sql
@@TRANCOUNT
```

to show the number of active transaction scopes for the current session.

Example:

```sql
SELECT @@TRANCOUNT AS transaction_count;
```

Before:

```text
0
```

After:

```sql
BEGIN TRANSACTION;
```

it normally becomes:

```text
1
```

---

# 16. Inspect Transaction Count

Example:

```sql
SELECT @@TRANCOUNT AS before_transaction;

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS during_transaction;

ROLLBACK;

SELECT @@TRANCOUNT AS after_transaction;
```

This is useful when learning transaction scope.

---

# 17. Transaction with UPDATE

Example:

```sql
BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

ROLLBACK;
```

No permanent stock change remains after the rollback.

---

# 18. Multiple Statements

```sql
BEGIN TRANSACTION;

UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

UPDATE training.products
SET stock_quantity = stock_quantity + 1
WHERE product_id = 2;

ROLLBACK;
```

Both updates belong to the same transaction.

---

# 19. Errors Inside Transactions

Transaction error handling deserves careful design.

A common production pattern uses:

```text
TRY
CATCH
XACT_STATE()
ROLLBACK
THROW
```

Example structure:

```sql
BEGIN TRY

    BEGIN TRANSACTION;

    -- changes

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
```

---

# 20. TRY / CATCH

SQL Server supports structured error handling:

```sql
BEGIN TRY

    -- code that may fail

END TRY
BEGIN CATCH

    -- error handling

END CATCH;
```

Transactions and `TRY/CATCH` are often used together.

---

# 21. Transaction TRY/CATCH Pattern

A robust starting pattern:

```sql
BEGIN TRY

    BEGIN TRANSACTION;

    -- Step 1
    -- Step 2
    -- Step 3

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;

END CATCH;
```

This pattern:

```text
Starts transaction

Attempts business operation

Commits if successful

Rolls back an active transaction after error

Re-throws the error
```

---

# 22. XACT_STATE()

`XACT_STATE()` reports the transaction state for the current session.

Possible values:

```text
1
    Active transaction exists
    and can be committed.

0
    No active transaction.

-1
    Active transaction exists
    but it is uncommittable.
```

---

# 23. Why XACT_STATE?

After some transaction errors, the transaction may remain active but become uncommittable.

Therefore:

```sql
XACT_STATE()
```

is useful inside `CATCH`.

Example:

```sql
IF XACT_STATE() <> 0
BEGIN
    ROLLBACK TRANSACTION;
END;
```

---

# 24. THROW

`THROW` re-raises an error.

Inside `CATCH`:

```sql
THROW;
```

This prevents the error from being silently hidden.

Silently swallowing database errors can make failures difficult to detect and debug.

---

# 25. Error Information

Inside `CATCH`, SQL Server exposes functions including:

```text
ERROR_NUMBER()
ERROR_MESSAGE()
ERROR_SEVERITY()
ERROR_STATE()
ERROR_LINE()
ERROR_PROCEDURE()
```

Example:

```sql
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_MESSAGE() AS error_message,
        ERROR_LINE() AS error_line;

END CATCH;
```

---

# 26. XACT_ABORT

SQL Server supports:

```sql
SET XACT_ABORT ON;
```

With `XACT_ABORT ON`, many runtime errors cause the active transaction to be rolled back automatically by SQL Server or become unsuitable for continued work depending on context.

A common defensive pattern is:

```sql
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    ...

    COMMIT;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;
```

---

# 27. Why Use XACT_ABORT?

Error behavior in SQL Server can vary depending on the type of error.

`XACT_ABORT ON` often makes multi-statement transaction behavior safer and more predictable for many runtime errors.

It does not eliminate the need to understand transaction error handling.

---

# 28. Inventory Business Example

Suppose a customer purchases:

```text
2 units of product 5
```

We need to verify:

```text
Is enough stock available?
```

Then reduce stock only when valid.

Incorrect:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - 2
WHERE product_id = 5;
```

if there are fewer than 2 units available.

---

# 29. Stock Constraint

The products table already includes:

```sql
CHECK (stock_quantity >= 0)
```

This helps prevent negative stock.

But good transaction logic should also check availability before attempting the business operation.

---

# 30. Validate Before Update

Conceptually:

```sql
IF current_stock < requested_quantity
BEGIN
    THROW ...
END;
```

Then:

```sql
UPDATE ...
```

But under concurrency, a simple read followed later by an update can still require careful locking/isolation design.

---

# 31. Business Rules Need Transaction Protection

Imagine two sessions both read:

```text
stock = 1
```

Both decide:

```text
I can buy 1.
```

Without appropriate concurrency control, they can race.

This is why transaction design is not only:

```text
BEGIN
COMMIT
ROLLBACK
```

It also involves:

```text
Isolation
Locking
Concurrency
Atomic update patterns
```

---

# 32. Atomic Conditional Update

A useful inventory pattern can combine the check and update:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @quantity
WHERE product_id = @product_id
  AND stock_quantity >= @quantity;
```

Then check:

```sql
@@ROWCOUNT
```

If no row was updated:

```text
Product does not exist
or
stock is insufficient
```

This avoids separating the stock condition from the actual update.

---

# 33. @@ROWCOUNT

`@@ROWCOUNT` tells how many rows were affected by the previous statement.

Example:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 999999;

SELECT @@ROWCOUNT AS affected_rows;
```

Likely:

```text
0
```

---

# 34. Throwing a Business Error

SQL Server `THROW` can create a custom error:

```sql
THROW 50001, 'Insufficient stock.', 1;
```

User-defined error numbers supplied directly to `THROW` must be at least 50000.

---

# 35. Safer Inventory Pattern

Conceptually:

```sql
UPDATE training.products
SET stock_quantity = stock_quantity - @quantity
WHERE product_id = @product_id
  AND stock_quantity >= @quantity;

IF @@ROWCOUNT = 0
BEGIN
    THROW 50001, 'Insufficient stock or product not found.', 1;
END;
```

Place this inside the larger order transaction.

---

# 36. Order Creation Transaction

A simplified order flow:

```text
1. Create order

2. Get new order_id

3. Reduce stock

4. Create order item

5. Commit
```

If any critical step fails:

```text
Rollback
```

---

# 37. SCOPE_IDENTITY()

After inserting an `IDENTITY` row:

```sql
INSERT INTO training.orders (...);

DECLARE @order_id INT =
    CAST(SCOPE_IDENTITY() AS INT);
```

`SCOPE_IDENTITY()` returns the last identity value inserted in the same scope/session context.

It is commonly used to capture the newly created parent key.

---

# 38. Simplified Order Transaction

Conceptual example:

```sql
DECLARE @order_id INT;

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO training.orders
    (
        customer_id,
        order_status
    )
    VALUES
    (
        1,
        'Pending'
    );

    SET @order_id =
        CAST(SCOPE_IDENTITY() AS INT);

    INSERT INTO training.order_items
    (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES
    (
        @order_id,
        2,
        1,
        500
    );

    COMMIT;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;
```

A complete commerce transaction should also safely handle stock.

---

# 39. Order + Stock Transaction

A stronger logical sequence:

```text
BEGIN TRANSACTION

Create order

Attempt atomic stock reduction

If stock reduction affected 0 rows:
    error

Create order item

COMMIT
```

Any error:

```text
ROLLBACK
```

---

# 40. Why Insert Order Before Stock?

There is no universal required statement ordering.

Transaction design depends on:

```text
Business requirements
Locking behavior
Failure behavior
Contention
Schema design
```

The important part is that the final transaction is correct and tested under concurrency.

---

# 41. Transaction Size

Transactions should generally be:

```text
As short as practical.
```

Long transactions can:

```text
Hold locks longer

Block other sessions

Increase contention

Increase deadlock risk

Increase transaction log pressure
```

Do not start a transaction long before the required database modifications.

---

# 42. User Interaction Inside Transactions

Avoid patterns such as:

```text
BEGIN TRANSACTION

Update row

Wait for a human to click Confirm

COMMIT
```

This can keep database locks open while waiting for external interaction.

Gather required user input before starting the database transaction whenever practical.

---

# 43. Isolation Levels

SQL Server supports isolation levels including:

```text
READ UNCOMMITTED

READ COMMITTED

REPEATABLE READ

SNAPSHOT

SERIALIZABLE
```

They provide different trade-offs between:

```text
Consistency
Concurrency
Blocking
Versioning
```

---

# 44. READ COMMITTED

`READ COMMITTED` is a common SQL Server default isolation level.

Conceptually, it prevents reading another transaction's uncommitted changes.

Exact behavior can depend on database options such as:

```text
READ_COMMITTED_SNAPSHOT
```

which can make READ COMMITTED use row versioning instead of traditional shared locks for reads.

---

# 45. READ UNCOMMITTED

Example:

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

This allows dirty reads.

A query may observe data that another transaction has changed but not committed.

If the other transaction rolls back, the reader observed data that never became committed state.

Use this level carefully.

---

# 46. Dirty Read

Conceptual timeline:

```text
Session A:

BEGIN TRANSACTION
UPDATE price from 500 to 900
Do not commit yet


Session B:

READ UNCOMMITTED
Reads price = 900


Session A:

ROLLBACK
```

Session B read a value that never became committed.

That is a dirty read.

---

# 47. Non-Repeatable Read

Conceptually:

```text
Transaction A reads row:
price = 500

Transaction B commits:
price = 700

Transaction A reads same row again:
price = 700
```

The same row produced different values during Transaction A.

Higher isolation levels can provide stronger protections against this behavior.

---

# 48. Phantom Read

Conceptually:

```text
Transaction A:
SELECT rows matching condition
-> 5 rows

Transaction B:
INSERT a new matching row and commit

Transaction A:
Runs same predicate
-> 6 rows
```

The new matching row is a phantom.

---

# 49. REPEATABLE READ

`REPEATABLE READ` provides stronger protection for rows already read than `READ COMMITTED`.

It can prevent other transactions from modifying those read rows before the transaction completes.

However, new rows matching the query range may still be possible, so phantom behavior is a separate concern.

---

# 50. SERIALIZABLE

`SERIALIZABLE` is one of SQL Server's strongest standard isolation levels.

It can protect ranges so concurrent transactions behave more like serial execution for the protected operation.

The trade-off can be:

```text
More locking
More blocking
Lower concurrency
Higher deadlock risk
```

Use stronger isolation when the business requirement needs it, not automatically.

---

# 51. SNAPSHOT

`SNAPSHOT` isolation uses row versioning.

Readers can see a transactionally consistent snapshot rather than reading uncommitted changes.

Snapshot isolation requires appropriate database configuration.

It changes concurrency behavior and has costs, including version storage.

---

# 52. Isolation Is a Trade-off

Stronger isolation can improve consistency guarantees but may reduce concurrency or increase resource usage.

There is no rule:

```text
Always use the strongest isolation level.
```

Choose based on:

```text
Business correctness

Expected concurrency

Read/write patterns

Blocking tolerance

Database configuration
```

---

# 53. Locks

SQL Server uses locks as part of concurrency control under lock-based execution.

Examples include:

```text
Shared locks

Exclusive locks

Update locks

Intent locks

Key-range locks
```

You do not need to memorize every lock type yet.

Understand the principle:

```text
Transactions can block each other when they
need incompatible access to the same resources.
```

---

# 54. Blocking

Blocking occurs when one session waits because another transaction holds an incompatible lock.

Blocking is not automatically an error.

It is sometimes necessary for correctness.

But excessive blocking can become a performance problem.

---

# 55. Deadlock

A deadlock can occur when transactions form a dependency cycle.

Example:

```text
Transaction A:
holds Resource 1
waits for Resource 2

Transaction B:
holds Resource 2
waits for Resource 1
```

Neither can continue.

SQL Server detects deadlocks and chooses one transaction as a victim so the other can proceed.

---

# 56. Reduce Deadlock Risk

Common strategies include:

```text
Keep transactions short

Access resources in consistent order

Use appropriate indexes

Avoid unnecessary locks

Avoid user interaction inside transactions

Retry deadlock victims where appropriate

Choose isolation deliberately
```

Deadlocks cannot always be eliminated completely in concurrent systems.

---

# 57. Nested Transactions in SQL Server

SQL Server allows multiple:

```sql
BEGIN TRANSACTION;
```

calls.

`@@TRANCOUNT` increases.

However, nested transactions do not behave like completely independent inner transactions.

Example:

```sql
BEGIN TRANSACTION;
BEGIN TRANSACTION;

SELECT @@TRANCOUNT;
```

returns:

```text
2
```

A normal inner `COMMIT` primarily reduces `@@TRANCOUNT`.

The outer transaction still controls final durability.

---

# 58. Nested COMMIT

Example:

```sql
BEGIN TRANSACTION;
BEGIN TRANSACTION;

COMMIT;

SELECT @@TRANCOUNT;
```

Typically:

```text
1
```

The outer transaction remains active.

---

# 59. ROLLBACK and Nested Transactions

A full:

```sql
ROLLBACK TRANSACTION;
```

without a savepoint name rolls back the active transaction and resets the transaction count.

Do not assume nested `BEGIN TRANSACTION` statements create fully independent rollback scopes.

---

# 60. SAVE TRANSACTION

SQL Server supports savepoints:

```sql
SAVE TRANSACTION savepoint_name;
```

A savepoint marks a point inside a transaction.

You can roll back to it:

```sql
ROLLBACK TRANSACTION savepoint_name;
```

This can undo work after the savepoint while leaving the broader transaction active, subject to transaction state and error conditions.

---

# 61. Savepoint Example

```sql
BEGIN TRANSACTION;

UPDATE ...;

SAVE TRANSACTION Step1Complete;

UPDATE ...;

ROLLBACK TRANSACTION Step1Complete;

COMMIT;
```

The second section is rolled back while earlier work can remain.

Use savepoints deliberately; they do not replace good transaction design.

---

# 62. Transaction Log

SQL Server records transactional changes in its transaction log.

The log supports important capabilities including:

```text
Recovery

Rollback

Durability

Backup/recovery workflows
```

Transactions and logging are deeply connected.

---

# 63. COMMIT Does Not Mean "Write Every Page to Disk Immediately"

SQL Server durability relies heavily on its write-ahead logging architecture.

At a high level:

```text
Required transaction log records are hardened
before a normal durable commit is acknowledged.
```

Data pages themselves may be written later.

This distinction becomes important when studying SQL Server internals.

---

# 64. Transaction Design Checklist

Before creating a transaction, ask:

```text
What business operation am I protecting?

Which statements must succeed together?

What can fail?

What should happen after failure?

What rows/resources will be touched?

Could concurrent sessions modify the same data?

How long will locks be held?

What isolation behavior is required?

Can I make the transaction shorter?

How will errors be propagated?
```

---

# 65. Example Business Operation

Customer wants:

```text
2 Mouse units
```

Potential transaction steps:

```text
1. Begin transaction

2. Create Pending order

3. Atomically reduce stock where stock >= 2

4. If no row updated:
       throw error

5. Insert order item

6. Mark order Completed if business workflow says
   completion happens immediately

7. Commit
```

Real commerce systems can require more complex states such as payment authorization, shipment, cancellation, inventory reservation, and asynchronous processing.

---

# 66. Do Not Confuse Database Transaction with Business Workflow

A database transaction should usually remain short.

A real order lifecycle might last:

```text
Minutes
Hours
Days
```

Do not keep a SQL transaction open for the entire business lifecycle.

Instead, persist business states such as:

```text
Pending
Paid
Shipped
Completed
Cancelled
```

and use short database transactions for each atomic state transition.

---

# 67. Transaction vs Business State

Example:

```text
Database transaction:
Create Pending order + reserve stock
-> milliseconds

Business workflow:
Payment processing
Shipping
Delivery
-> potentially days
```

These are different concepts.

---

# 68. Common Mistake - Forgetting COMMIT

Example:

```sql
BEGIN TRANSACTION;

UPDATE ...;
```

Then the session remains inside an open transaction.

This can:

```text
Hold locks

Block other sessions

Cause unexpected behavior
```

Always know whether your transaction has ended.

---

# 69. Common Mistake - Forgetting ROLLBACK After Error

If an error leaves a transaction active and your error handling does not clean it up, the session may remain in an unwanted transactional state.

Use deliberate error handling.

---

# 70. Common Mistake - Swallowing Errors

This is risky:

```sql
BEGIN CATCH
    ROLLBACK;
END CATCH;
```

The caller may not know why the operation failed.

Prefer propagating the failure appropriately, commonly:

```sql
THROW;
```

---

# 71. Common Mistake - Checking Then Updating Without Concurrency Thinking

Potential race:

```text
Read stock = 1

Another session changes stock

Update based on stale assumption
```

Prefer transactionally safe patterns such as an atomic conditional update, appropriate locking, or other concurrency design suited to the application.

---

# 72. Common Mistake - Long Transactions

Do not do unrelated work inside the same transaction.

Keep the transaction focused on the operation that needs atomicity.

---

# 73. Common Mistake - READ UNCOMMITTED for "Performance"

Dirty reads can produce:

```text
Impossible totals

Rows that disappear after rollback

Inconsistent analytical results
```

Do not treat `READ UNCOMMITTED` or `NOLOCK` as a generic speed switch.

Correctness matters.

---

# 74. NOLOCK

SQL Server's:

```sql
WITH (NOLOCK)
```

is commonly associated with READ UNCOMMITTED behavior for table access.

It can allow inconsistent reads.

It does not mean:

```text
safe non-blocking read
```

Use only when the consequences of weaker read consistency are explicitly acceptable.

---

# 75. Transactions and Analytics

Even analysts need transaction knowledge.

Why?

Because:

```text
Source data can change while reports run

Isolation affects what a report sees

NOLOCK can produce incorrect results

Long analytical queries can interact with writers

Snapshot/versioning settings affect concurrency
```

Understanding transactions improves analytical reliability too.

---

# 76. Learning Outcome

By the end of this chapter you should be able to explain:

```text
What a transaction is

BEGIN TRANSACTION

COMMIT

ROLLBACK

@@TRANCOUNT

TRY / CATCH

XACT_STATE()

THROW

XACT_ABORT

Atomicity

Consistency

Isolation

Durability

Autocommit vs explicit transactions

Inventory transaction patterns

SCOPE_IDENTITY()

@@ROWCOUNT

Isolation levels

Dirty reads

Non-repeatable reads

Phantom reads

Blocking

Deadlocks

Nested transaction behavior

Savepoints
```

---

# Chapter Files

```text
10_transactions_and_acid/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

---

# Core Mental Model

A transaction is not:

```text
"just BEGIN and COMMIT"
```

It is a correctness boundary.

Think:

```text
Business Operation
        ↓
Which changes must succeed together?
        ↓
BEGIN TRANSACTION
        ↓
Perform minimal required work
        ↓
Validate results
        ↓
Success?
   /           \
Yes            No
 |              |
COMMIT        ROLLBACK
                |
               THROW
```

And under concurrency always ask:

```text
What happens if another session
touches the same data at the same time?
```

That question is where transaction knowledge becomes real database engineering.