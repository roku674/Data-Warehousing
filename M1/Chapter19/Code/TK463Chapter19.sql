-- TK463 Chapter 19 Code

/*********************/
/* Lesson 3 Practice */
/*********************/

-- Prepare TK463DW database
USE master;
IF DB_ID('TK463DW') IS NOT NULL
  DROP DATABASE TK463DW;
GO
CREATE DATABASE TK463DW
 ON PRIMARY 
 (NAME = N'TK463DW', FILENAME = N'C:\TK463\TK463DW.mdf',
  SIZE = 307200KB , FILEGROWTH = 10240KB )
 LOG ON 
 (NAME = N'TK463DW_log', FILENAME = N'C:\TK463\TK463DW_log.ldf',
  SIZE = 51200KB , FILEGROWTH = 10%);
GO
ALTER DATABASE TK463DW SET RECOVERY SIMPLE WITH NO_WAIT;
GO

USE TK463DW;
GO
-- Create the schema stg to stage all needed source tables
CREATE SCHEMA stg AUTHORIZATION dbo;
GO

-- Drop the tables if they already exist
IF OBJECT_ID('stg.Person','U') IS NOT NULL
  DROP TABLE stg.Person;
GO

IF OBJECT_ID('stg.Customer','U') IS NOT NULL
  DROP TABLE stg.Customer;
GO

IF OBJECT_ID('stg.CustomerInformation','U') IS NOT NULL
  DROP TABLE stg.CustomerInformation;
GO

IF OBJECT_ID('dbo.Customers','U') IS NOT NULL
  DROP TABLE dbo.Customers;
GO

IF OBJECT_ID('dbo.UpdateCustomers','U') IS NOT NULL
  DROP TABLE dbo.UpdateCustomers;
GO

IF OBJECT_ID('dbo.ETLHistory','U') IS NOT NULL
  DROP TABLE dbo.ETLHistory;
GO


-- Create stage tables

CREATE TABLE stg.Person
(
 BusinessEntityID INT           NULL,
 PersonType       NCHAR(2)      NULL,
 Title            NVARCHAR(8)   NULL,
 FirstName        NVARCHAR(50)  NULL,
 MiddleName       NVARCHAR(50)  NULL,
 LastName         NVARCHAR(50)  NULL,
 Suffix           NVARCHAR(10)  NULL,
 ModifiedDate     DATETIME      NULL,
 RowCheckSum      VARCHAR(128)  NULL
);

CREATE TABLE stg.Customer
(
 CustomerID    INT           NULL,
 PersonID      INT           NULL,
 StoreID       INT           NULL,
 TerritoryID   INT           NULL,
 AccountNumber NVARCHAR(20)  NULL,
 ModifiedDate  DATETIME      NULL,
 RowCheckSum   VARCHAR(128)  NULL
);

CREATE TABLE stg.CustomerInformation 
(
 PersonID          INT           NULL,
 EnglishEducation  NVARCHAR(30)  NULL,
 EnglishOccupation NVARCHAR(50)  NULL,
 BirthDate         DATE          NULL,
 Gender            NCHAR(1)      NULL,
 MaritalStatus     NCHAR(1)      NULL,
 EmailAddress      NVARCHAR(50)  NULL,
 RowCheckSum       VARCHAR(128)  NULL
);

-- Drop and create the sequence
IF OBJECT_ID('dbo.SeqCustomerDwKey','SO') IS NOT NULL
  DROP SEQUENCE dbo.SeqCustomerDwKey;
GO
CREATE SEQUENCE dbo.SeqCustomerDwKey AS INT
 START WITH 1 
 INCREMENT BY 1;
GO

-- Create the Customers dimension
CREATE TABLE dbo.Customers
(
 CustomerDwKey INT           NOT NULL,
 CustomerKey   INT           NOT NULL,
 FullName      NVARCHAR(150) NULL,
 EmailAddress  NVARCHAR(50)  NULL,
 BirthDate     DATE          NULL,
 MaritalStatus NCHAR(5)      NULL,
 Gender        NCHAR(5)      NULL,
 Education     NVARCHAR(40)  NULL,
 Occupation    NVARCHAR(100) NULL,
 City          NVARCHAR(30)  NULL,
 StateProvince NVARCHAR(50)  NULL,
 CountryRegion NVARCHAR(50)  NULL,
 RowCheckSum   VARCHAR(128)  NULL,
 Age AS
  CASE
   WHEN DATEDIFF(yy, BirthDate, CURRENT_TIMESTAMP) <= 40 
   THEN 'Younger'
   WHEN DATEDIFF(yy, BirthDate, CURRENT_TIMESTAMP) > 50
   THEN 'Older'
   ELSE 'Middle Age'
  END,
 CurrentFlag   BIT           NOT NULL DEFAULT 1,
 CONSTRAINT PK_Customers PRIMARY KEY (CustomerDwKey)
);
GO

-- Add default constraint to get surrogate key from sequence when inserting trough SSIS
ALTER TABLE  dbo.Customers
  ADD CONSTRAINT DFT_CustomerDwKey DEFAULT (NEXT VALUE FOR dbo.SeqCustomerDwKey) FOR CustomerDwKey;

-- Create temporary table for updating dbo.Customers 
CREATE TABLE dbo.UpdateCustomers
(
 CustomerKey   INT           NOT NULL,
 FullName      NVARCHAR(150) NULL,
 EmailAddress  NVARCHAR(50)  NULL,
 BirthDate     DATE          NULL,
 MaritalStatus NCHAR(5)      NULL,
 Gender        NCHAR(5)      NULL,
 Education     NVARCHAR(40)  NULL,
 Occupation    NVARCHAR(100) NULL,
 City          NVARCHAR(30)  NULL,
 StateProvince NVARCHAR(50)  NULL,
 CountryRegion NVARCHAR(50)  NULL,
 RowCheckSum   VARCHAR(128)  NULL
);
GO

CREATE TABLE dbo.ETLHistory
(
 PackageID           UNIQUEIDENTIFIER NOT NULL,
 RunTime             DATETIME         NOT NULL
 CONSTRAINT DFT_ETLHistory_StartTime DEFAULT (GETDATE()),
 NewRecordCount      INT              NOT NULL,
 ModifiedRecordCount INT              NOT NULL,
 CONSTRAINT PK_ETLHistory PRIMARY KEY (PackageID, RunTime)
);
GO


-- Check stg.Customer data
SELECT *
  FROM stg.Customer;
GO
