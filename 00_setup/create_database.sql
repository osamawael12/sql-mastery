/*
============================================================
SQL MASTERY
00 - SETUP

File: create_database.sql
Database: Microsoft SQL Server
Language: T-SQL
============================================================
*/

-- Use the system database before creating SQLMastery
USE master;
GO


-- Create the learning database
IF DB_ID('SQLMastery') IS NULL
BEGIN
    CREATE DATABASE SQLMastery;
END;
GO


-- Switch to the learning database
USE SQLMastery;
GO


-- Create the training schema
IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'training'
)
BEGIN
    EXEC('CREATE SCHEMA training');
END;
GO


-- Verify setup
SELECT
    @@SERVERNAME AS server_name,
    DB_NAME() AS database_name,
    SYSTEM_USER AS current_login,
    GETDATE() AS setup_datetime;
GO


-- Verify training schema
SELECT
    name AS schema_name
FROM sys.schemas
WHERE name = 'training';
GO