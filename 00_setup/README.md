# 00 - Setup & Tools

This section prepares the environment used throughout the SQL learning journey.

## Technology Stack

- Microsoft SQL Server
- T-SQL
- SQL Server Management Studio (SSMS)
- Visual Studio Code
- Windows

## Learning Database

The main database used throughout the course:

```text
SQLMastery
```

## Training Schema

The main schema used for learning and exercises:

```text
training
```

## Setup Order

1. Verify SQL Server
2. Create the `SQLMastery` database
3. Create the `training` schema
4. Verify the environment
5. Start Database Fundamentals

## Verify SQL Server

Run in SQL Server Management Studio:

```sql
SELECT
    @@SERVERNAME AS server_name,
    @@VERSION AS sql_server_version;
```

## Project Structure

```text
00_setup/
├── README.md
├── sql_server_setup.md
├── create_database.sql
└── sample_data.sql
```

## Note

The learning dataset will be built gradually during the course instead of being created all at once.

This makes it possible to learn tables, data types, keys, constraints, and relationships by creating them step by step.