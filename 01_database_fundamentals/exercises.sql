/*
============================================================
SQL MASTERY
01 - DATABASE FUNDAMENTALS

File: exercises.sql
Database: SQLMastery
Language: T-SQL

Rule:
Try to solve every exercise before opening solutions.sql.
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

-- Write your answer here:



/* ==========================================================
   EXERCISE 2 - SCHEMA
   ==========================================================

   Find the schema named 'training' using sys.schemas.
*/

-- Write your answer here:



/* ==========================================================
   EXERCISE 3 - TABLES
   ==========================================================

   Return all tables that belong to the training schema.

   Hint:
   sys.tables
   SCHEMA_NAME()
*/

-- Write your answer here:



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

-- Write your answer here:



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

-- Write your answer here:



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

-- Write your answer here:



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

-- Write your answer here:



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

-- Write your answer here:



/* ==========================================================
   EXERCISE 9 - INSERT DATA
   ==========================================================

   Insert these categories into training.categories:

   Electronics
   Accessories
   Furniture
*/

-- Write your answer here:



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

-- Write your answer here:



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

1.

2.

3.

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

1.

2.

3.

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

-- Write your answer here: