/*
============================================================
SQL MASTERY
01 - DATABASE FUNDAMENTALS

File: examples.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   1. DATABASE
   ========================================================== */

SELECT DB_NAME() AS current_database;
GO


/* ==========================================================
   2. SCHEMA
   ========================================================== */

SELECT
    name AS schema_name
FROM sys.schemas
WHERE name = 'training';
GO


/* ==========================================================
   3. CREATE CUSTOMERS TABLE

   Concepts:
   - Table
   - Columns
   - Data Types
   - Primary Key
   - NOT NULL
   - UNIQUE
   - DEFAULT
   ========================================================== */

CREATE TABLE training.customers
(
    customer_id INT IDENTITY(1,1),

    customer_name NVARCHAR(100) NOT NULL,

    email VARCHAR(255) NOT NULL,

    city NVARCHAR(100) NULL,

    signup_date DATE NOT NULL
        CONSTRAINT DF_customers_signup_date
        DEFAULT CAST(GETDATE() AS DATE),

    is_active BIT NOT NULL
        CONSTRAINT DF_customers_is_active
        DEFAULT 1,

    CONSTRAINT PK_customers
        PRIMARY KEY (customer_id),

    CONSTRAINT UQ_customers_email
        UNIQUE (email)
);
GO


/* ==========================================================
   4. CREATE PRODUCTS TABLE

   Concepts:
   - Primary Key
   - Data Types
   - CHECK
   - DEFAULT
   ========================================================== */

CREATE TABLE training.products
(
    product_id INT IDENTITY(1,1),

    product_name NVARCHAR(150) NOT NULL,

    category NVARCHAR(100) NOT NULL,

    price DECIMAL(12,2) NOT NULL,

    cost DECIMAL(12,2) NOT NULL,

    stock_quantity INT NOT NULL
        CONSTRAINT DF_products_stock_quantity
        DEFAULT 0,

    is_active BIT NOT NULL
        CONSTRAINT DF_products_is_active
        DEFAULT 1,

    CONSTRAINT PK_products
        PRIMARY KEY (product_id),

    CONSTRAINT CK_products_price
        CHECK (price >= 0),

    CONSTRAINT CK_products_cost
        CHECK (cost >= 0),

    CONSTRAINT CK_products_stock_quantity
        CHECK (stock_quantity >= 0)
);
GO


/* ==========================================================
   5. CREATE ORDERS TABLE

   Concepts:
   - Primary Key
   - Foreign Key
   - Relationship
   - CHECK
   - DEFAULT
   ========================================================== */

CREATE TABLE training.orders
(
    order_id INT IDENTITY(1,1),

    customer_id INT NOT NULL,

    order_date DATETIME2 NOT NULL
        CONSTRAINT DF_orders_order_date
        DEFAULT SYSDATETIME(),

    order_status VARCHAR(20) NOT NULL
        CONSTRAINT DF_orders_status
        DEFAULT 'Pending',

    CONSTRAINT PK_orders
        PRIMARY KEY (order_id),

    CONSTRAINT FK_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES training.customers(customer_id),

    CONSTRAINT CK_orders_status
        CHECK
        (
            order_status IN
            (
                'Pending',
                'Completed',
                'Cancelled'
            )
        )
);
GO


/* ==========================================================
   6. CREATE ORDER_ITEMS TABLE

   Resolves the many-to-many relationship between
   orders and products.
   ========================================================== */

CREATE TABLE training.order_items
(
    order_item_id INT IDENTITY(1,1),

    order_id INT NOT NULL,

    product_id INT NOT NULL,

    quantity INT NOT NULL,

    unit_price DECIMAL(12,2) NOT NULL,

    CONSTRAINT PK_order_items
        PRIMARY KEY (order_item_id),

    CONSTRAINT FK_order_items_orders
        FOREIGN KEY (order_id)
        REFERENCES training.orders(order_id),

    CONSTRAINT FK_order_items_products
        FOREIGN KEY (product_id)
        REFERENCES training.products(product_id),

    CONSTRAINT CK_order_items_quantity
        CHECK (quantity > 0),

    CONSTRAINT CK_order_items_unit_price
        CHECK (unit_price >= 0)
);
GO


/* ==========================================================
   7. INSERT CUSTOMERS
   ========================================================== */

INSERT INTO training.customers
(
    customer_name,
    email,
    city,
    signup_date
)
VALUES
(N'Ahmed Ali', 'ahmed@example.com', N'Cairo', '2025-01-10'),
(N'Sara Mohamed', 'sara@example.com', N'Alexandria', '2025-01-15'),
(N'Omar Hassan', 'omar@example.com', N'Cairo', '2025-02-01'),
(N'Mona Adel', 'mona@example.com', N'Giza', '2025-02-10'),
(N'Youssef Samir', 'youssef@example.com', NULL, '2025-03-01');
GO


/* ==========================================================
   8. INSERT PRODUCTS
   ========================================================== */

INSERT INTO training.products
(
    product_name,
    category,
    price,
    cost,
    stock_quantity
)
VALUES
(N'Laptop', N'Electronics', 30000.00, 25000.00, 10),
(N'Mouse', N'Accessories', 500.00, 250.00, 100),
(N'Keyboard', N'Accessories', 1000.00, 600.00, 50),
(N'Monitor', N'Electronics', 7000.00, 5500.00, 25),
(N'Headphones', N'Accessories', 1500.00, 900.00, 40);
GO


/* ==========================================================
   9. INSERT ORDERS
   ========================================================== */

INSERT INTO training.orders
(
    customer_id,
    order_date,
    order_status
)
VALUES
(1, '2025-03-01 10:30:00', 'Completed'),
(2, '2025-03-02 14:15:00', 'Completed'),
(1, '2025-03-05 09:45:00', 'Completed'),
(3, '2025-03-10 17:20:00', 'Cancelled'),
(4, '2025-04-01 12:00:00', 'Completed');
GO


/* ==========================================================
   10. INSERT ORDER ITEMS
   ========================================================== */

INSERT INTO training.order_items
(
    order_id,
    product_id,
    quantity,
    unit_price
)
VALUES
(1, 1, 1, 30000.00),
(1, 2, 2, 500.00),
(2, 3, 1, 1000.00),
(3, 5, 2, 1500.00),
(4, 4, 1, 7000.00),
(5, 4, 1, 7000.00),
(5, 2, 1, 500.00);
GO


/* ==========================================================
   11. VIEW TABLE DATA
   ========================================================== */

SELECT *
FROM training.customers;
GO

SELECT *
FROM training.products;
GO

SELECT *
FROM training.orders;
GO

SELECT *
FROM training.order_items;
GO


/* ==========================================================
   12. VIEW TABLES
   ========================================================== */

SELECT
    SCHEMA_NAME(schema_id) AS schema_name,
    name AS table_name
FROM sys.tables
WHERE SCHEMA_NAME(schema_id) = 'training'
ORDER BY name;
GO


/* ==========================================================
   13. VIEW COLUMNS AND DATA TYPES
   ========================================================== */

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'training'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;
GO


/* ==========================================================
   FINAL DATA MODEL

   customers
       1
       |
       |----< orders
                 1
                 |
                 |----< order_items >----|
                                        1
                                     products
   ========================================================== */