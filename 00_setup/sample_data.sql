# SQL Server Setup

## Environment

This project uses Microsoft SQL Server and T-SQL.

### Required Tools

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Visual Studio Code

## 1. Verify SQL Server Connection

Open SQL Server Management Studio and connect to your SQL Server instance.

Run:

```sql
SELECT @@VERSION AS sql_server_version;
```

## 2. Check Server Name

```sql
SELECT @@SERVERNAME AS server_name;
```

## 3. Check Current Login

```sql
SELECT SYSTEM_USER AS current_login;
```

## 4. Check Current Database

```sql
SELECT DB_NAME() AS current_database;
```

## 5. Environment Check

```sql
SELECT
    @@SERVERNAME AS server_name,
    DB_NAME() AS current_database,
    SYSTEM_USER AS current_login,
    GETDATE() AS current_datetime;
```

## SQL Dialect

This repository uses:

```text
T-SQL
```

SQL Server-specific syntax will be used throughout the project.

Example:

```sql
SELECT TOP (10) *
FROM table_name;
```

Instead of:

```sql
LIMIT 10
```

## Status

Environment ready for the `SQLMastery` database.