# Database Fundamentals
# 01 - Database Fundamentals

## Objective

Understand how relational databases are structured before writing data analysis queries.

## Topics

- Database
- Schema
- Table
- Rows
- Columns
- Data Types
- Primary Key
- Foreign Key
- Constraints
- Relationships

## Learning Database

```text
SQLMastery
```

## Learning Schema

```text
training
```

## Database Structure

```text
SQL Server
└── SQLMastery
    └── training
        └── Tables
            ├── Columns
            └── Rows
```

## Database

A database is a container that stores related database objects and data.

Course database:

```text
SQLMastery
```

## Schema

A schema organizes database objects inside a database.

Course schema:

```text
training
```

Objects are referenced using:

```text
schema_name.object_name
```

Example:

```text
training.customers
```

## Table

A table stores data about an entity.

Examples:

```text
customers
products
orders
order_items
```

## Columns

Columns define the attributes stored for an entity.

Example:

```text
customers

customer_id
customer_name
email
city
signup_date
```

## Rows

A row represents one record inside a table.

Example:

```text
1 | Ahmed Ali | ahmed@example.com | Cairo | 2025-01-10
```

## Data Types

Common SQL Server data types used in this repository:

```text
INT
BIGINT
DECIMAL
VARCHAR
NVARCHAR
DATE
DATETIME2
BIT
```

Example:

```sql
customer_id   INT
customer_name NVARCHAR(100)
price         DECIMAL(10,2)
signup_date   DATE
created_at    DATETIME2
is_active     BIT
```

## Primary Key

A Primary Key uniquely identifies each row in a table.

Example:

```text
customers.customer_id
```

A Primary Key must be unique and cannot be NULL.

## Foreign Key

A Foreign Key creates a relationship between tables.

Example:

```text
customers.customer_id
        ↑
        │
orders.customer_id
```

## Constraints

Constraints protect data integrity.

Main constraints:

```text
PRIMARY KEY
FOREIGN KEY
NOT NULL
UNIQUE
CHECK
DEFAULT
```

## Relationships

### One-to-One

```text
A 1 ─── 1 B
```

### One-to-Many

One customer can have many orders.

```text
customers 1 ───< orders
```

### Many-to-Many

One order can contain many products, and one product can appear in many orders.

This relationship is resolved using a junction table:

```text
orders
   1
   │
   <
order_items
   >
   │
   1
products
```

## Training Data Model

During this chapter we will build:

```text
customers
    │
    └──< orders
            │
            └──< order_items >── products
```

## Chapter Files

```text
01_database_fundamentals/
├── README.md
├── examples.sql
├── exercises.sql
└── solutions.sql
```

## Learning Outcome

By the end of this chapter, you should understand how SQL Server organizes data and how tables are connected using keys and relationships.