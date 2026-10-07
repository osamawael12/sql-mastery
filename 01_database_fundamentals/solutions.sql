/*
============================================================
SQL MASTERY
01 - DATABASE FUNDAMENTALS

File: exercises.sql
Database: SQLMastery
Language: T-SQL
============================================================
*/

USE SQLMastery;
GO


/* ==========================================================
   EXERCISE 1 - DATABASE
   ==========================================================

   Return the name of the database you are currently using.

   Expected:
   SQLMastery
*/

SELECT DB_NAME() AS current_database;
GO


/* ==========================================================
   EXERCISE 2 - SCHEMA
   ==========================================================

   Find the schema named 'training' using sys.schemas.
*/

SELECT 
    schema_id,
    name AS schema_name
FROM sys.schemas
WHERE name = 'training';
GO


/* ==========================================================
   EXERCISE 3 - TABLES
   ==========================================================

   Return all tables that belong to the training schema.

   Hint:
   sys.tables
   SCHEMA_NAME()
*/

SELECT 
    SCHEMA_NAME(schema_id) AS schema_name,
    name AS table_name
FROM sys.tables
WHERE SCHEMA_NAME(schema_id) = 'training'
ORDER BY name;
GO


/* ==========================================================
   EXERCISE 4 - CREATE TABLE
   ==========================================================

   Create a table:

   training.categories

   Requirements:

   category_id
   - INT
   - IDENTITY(1,1)
   - Primary Key

   category_name
   - NVARCHAR(100)
   - NOT NULL
   - UNIQUE
*/

CREATE TABLE training.categories
(
    category_id INT IDENTITY(1,1),
    category_name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_categories 
        PRIMARY KEY (category_id),

    CONSTRAINT UQ_categories_category_name 
        UNIQUE (category_name)
);
GO


/* ==========================================================
   EXERCISE 5 - DATA TYPES
   ==========================================================

   Create:

   training.employees

   Columns:

   employee_id
   INT
   IDENTITY
   Primary Key

   employee_name
   NVARCHAR(100)
   NOT NULL

   salary
   DECIMAL(12,2)
   NOT NULL

   hire_date
   DATE
   NOT NULL

   is_active
   BIT
   NOT NULL
*/

CREATE TABLE training.employees
(
    employee_id INT IDENTITY(1,1),
    employee_name NVARCHAR(100) NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    hire_date DATE NOT NULL,
    is_active BIT NOT NULL,

    CONSTRAINT PK_employees 
        PRIMARY KEY (employee_id)
);
GO


/* ==========================================================
   EXERCISE 6 - CHECK CONSTRAINT
   ==========================================================

   Add a CHECK constraint while creating this table:

   training.discounts

   Columns:

   discount_id
   INT IDENTITY PRIMARY KEY

   discount_name
   NVARCHAR(100) NOT NULL

   discount_percent
   DECIMAL(5,2) NOT NULL

   discount_percent must be between 0 and 100.
*/

CREATE TABLE training.discounts
(
    discount_id INT IDENTITY(1,1),
    discount_name NVARCHAR(100) NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL,

    CONSTRAINT PK_discounts 
        PRIMARY KEY (discount_id),

    CONSTRAINT CK_discounts_discount_percent 
        CHECK (discount_percent BETWEEN 0 AND 100)
);
GO


/* ==========================================================
   EXERCISE 7 - DEFAULT
   ==========================================================

   Create:

   training.tickets

   Columns:

   ticket_id
   INT IDENTITY PRIMARY KEY

   title
   NVARCHAR(200) NOT NULL

   status
   VARCHAR(20) NOT NULL

   created_at
   DATETIME2 NOT NULL

   Requirements:

   Default status:
   'Open'

   Default created_at:
   current date and time
*/

CREATE TABLE training.tickets
(
    ticket_id INT IDENTITY(1,1),
    title NVARCHAR(200) NOT NULL,

    status VARCHAR(20) NOT NULL 
        CONSTRAINT DF_tickets_status DEFAULT 'Open',

    created_at DATETIME2 NOT NULL 
        CONSTRAINT DF_tickets_created_at DEFAULT SYSDATETIME(),

    CONSTRAINT PK_tickets 
        PRIMARY KEY (ticket_id)
);
GO


/* ==========================================================
   EXERCISE 8 - FOREIGN KEY
   ==========================================================

   Create:

   training.customer_addresses

   Columns:

   address_id
   INT IDENTITY PRIMARY KEY

   customer_id
   INT NOT NULL

   address_line
   NVARCHAR(200) NOT NULL

   city
   NVARCHAR(100) NOT NULL

   Create a Foreign Key from:

   customer_addresses.customer_id

   to:

   customers.customer_id
*/

CREATE TABLE training.customer_addresses
(
    address_id INT IDENTITY(1,1),
    customer_id INT NOT NULL,
    address_line NVARCHAR(200) NOT NULL,
    city NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_customer_addresses 
        PRIMARY KEY (address_id),

    CONSTRAINT FK_customer_addresses_customers 
        FOREIGN KEY (customer_id) 
        REFERENCES training.customers(customer_id)
);
GO


/* ==========================================================
   EXERCISE 9 - INSERT DATA
   ==========================================================

   Insert these categories into training.categories:

   Electronics
   Accessories
   Furniture
*/

INSERT INTO training.categories (category_name)
VALUES 
(N'Electronics'),
(N'Accessories'),
(N'Furniture');
GO


/* ==========================================================
   EXERCISE 10 - INSERT EMPLOYEE
   ==========================================================

   Insert:

   Name:
   Mohamed Hassan

   Salary:
   12000.00

   Hire Date:
   2025-01-01

   Active:
   Yes
*/

INSERT INTO training.employees (employee_name, salary, hire_date, is_active)
VALUES (N'Mohamed Hassan', 12000.00, '2025-01-01', 1);
GO


/* ==========================================================
   EXERCISE 11 - TEST PRIMARY KEY
   ==========================================================

   Look at:

   training.customers

   Answer in comments:

   1. What is its Primary Key?
   2. Can two customers have the same customer_id?
   3. Can customer_id be NULL?
*/

/*
Answer:

1. Primary Key is: customer_id
2. No, Primary Key values must be unique across all rows.
3. No, Primary Key columns cannot accept NULL values.
*/


/* ==========================================================
   EXERCISE 12 - TEST FOREIGN KEY
   ==========================================================

   Look at:

   training.orders

   Answer in comments:

   1. What is its Foreign Key?
   2. Which table does it reference?
   3. Which column does it reference?
*/

/*
Answer:

1. Foreign Key is: FK_orders_customers (on customer_id column)
2. Table referenced: training.customers
3. Column referenced: customer_id
*/


/* ==========================================================
   EXERCISE 13 - RELATIONSHIPS
   ==========================================================

   Describe the relationship between:

   customers
   and
   orders

   Choose:

   One-to-One
   One-to-Many
   Many-to-Many
*/

/*
Answer:

One-to-Many
(One customer can place multiple orders, but each order belongs to only one customer.)
*/


/* ==========================================================
   EXERCISE 14 - MANY-TO-MANY
   ==========================================================

   Which table resolves the many-to-many relationship between:

   orders
   and
   products
*/

/*
Answer:

training.order_items
(It acts as a junction/bridge table that holds order_id and product_id.)
*/


/* ==========================================================
   EXERCISE 15 - DATA MODEL
   ==========================================================

   Complete the relationship diagram in comments.

   Tables:

   customers
   orders
   order_items
   products
*/

/*
Your diagram:

  customers (1) ───────< (N) orders (1) ───────< (N) order_items (N) >─────── (1) products

  Or written functionally:

  customers
      │
      └───< orders
              │
              └───< order_items >─── products
*/


/* ==========================================================
   BONUS - THINK LIKE A DATABASE DESIGNER
   ==========================================================

   We want to add product reviews.

   Each review belongs to:

   - One customer
   - One product

   Design:

   training.product_reviews

   Required information:

   review_id
   customer_id
   product_id
   rating
   review_text
   review_date

   Requirements:

   - Primary Key
   - Foreign Keys
   - Appropriate Data Types
   - NOT NULL where appropriate
   - rating must be between 1 and 5
   - review_date should have a default value

   Write the complete CREATE TABLE statement.
*/

CREATE TABLE training.product_reviews
(
    review_id INT IDENTITY(1,1),
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    review_text NVARCHAR(MAX) NULL,
    review_date DATETIME2 NOT NULL 
        CONSTRAINT DF_product_reviews_review_date DEFAULT SYSDATETIME(),

    CONSTRAINT PK_product_reviews 
        PRIMARY KEY (review_id),

    CONSTRAINT FK_product_reviews_customers 
        FOREIGN KEY (customer_id) 
        REFERENCES training.customers(customer_id),

    CONSTRAINT FK_product_reviews_products 
        FOREIGN KEY (product_id) 
        REFERENCES training.products(product_id),

    CONSTRAINT CK_product_reviews_rating 
        CHECK (rating BETWEEN 1 AND 5)
);
GO