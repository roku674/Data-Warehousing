-- TK463 Chapter 05 Code

/*********************/
/* Lesson 1 Practice */
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
-- Drop the tables if needed
IF OBJECT_ID('stg.Person','U') IS NOT NULL
  DROP TABLE stg.Person;
GO

IF OBJECT_ID('stg.Customer','U') IS NOT NULL
  DROP TABLE stg.Customer;
GO

IF OBJECT_ID('stg.CustomerInformation','U') IS NOT NULL
  DROP TABLE stg.CustomerInformation;
GO
-- Create stage tables

CREATE TABLE stg.Person
(
 BusinessEntityID INT          NULL,
 PersonType       NCHAR(2)     NULL,
 Title            NVARCHAR(8)  NULL,
 FirstName        NVARCHAR(50) NULL,
 MiddleName       NVARCHAR(50) NULL,
 LastName         NVARCHAR(50) NULL,
 Suffix           NVARCHAR(10) NULL,
 ModifiedDate     DATETIME     NULL
);

CREATE TABLE stg.Customer
(
 CustomerID    INT          NULL,
 PersonID      INT          NULL,
 StoreID       INT          NULL,
 TerritoryID   INT          NULL,
 AccountNumber NVARCHAR(20) NULL,
 ModifiedDate  DATETIME     NULL,
);

CREATE TABLE stg.CustomerInformation 
(
 PersonID          INT NULL,
 EnglishEducation  NVARCHAR(30) NULL,
 EnglishOccupation NVARCHAR(50) NULL,
 BirthDate         DATE NULL,
 Gender            NCHAR(5) NULL,
 MaritalStatus     NCHAR(5) NULL,
 EmailAddress      NVARCHAR(50) NULL
);

/*********************/
/* Lesson 2 Practice */
/*********************/

-- Sequence for the Customers dimension
USE TK463DW;
GO

-- Drop the tables 
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL
  DROP TABLE dbo.Customers;
GO

-- Drop and create the sequence
IF OBJECT_ID('dbo.SeqCustomerDwKey','SO') IS NOT NULL
  DROP SEQUENCE dbo.SeqCustomerDwKey;
GO
CREATE SEQUENCE dbo.SeqCustomerDwKey AS INT
 START WITH 1 
 INCREMENT BY 1;
GO

-- Customers dimension  with a PK
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

-- add default constraint to get surrogate key from sequence when inserting through SSIS
ALTER TABLE  dbo.Customers
  ADD CONSTRAINT DFT_CustomerDwKey DEFAULT (NEXT VALUE FOR dbo.SeqCustomerDwKey) FOR CustomerDwKey;

/*********************/
/* Lesson 3 Practice */
/*********************/

SELECT
	P.BusinessEntityID,
	P.PersonType,
	P.Title,
	P.FirstName,
	P.MiddleName,
	P.LastName,
	P.Suffix,
	C.TerritoryID
FROM stg.Person AS P
INNER JOIN stg.Customer AS C ON C.CustomerID = P.BusinessEntityID
ORDER BY C.TerritoryID;

-- Drop the tables 
IF OBJECT_ID('dbo.UpdateCustomers','U') IS NOT NULL
  DROP TABLE dbo.UpdateCustomers;
GO

-- temporary table for updating dbo.Customers 
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
 CountryRegion NVARCHAR(50)  NULL
);
GO

-- update 
UPDATE C
SET 
	FullName = U.FullName,
	EmailAddress = U.EmailAddress,
	BirthDate = U.BirthDate,
	MaritalStatus = U.MaritalStatus,
	Gender = U.Gender,
	Education = U.Education,
	Occupation = U.Occupation,
	City = U.City,
	StateProvince = U.StateProvince,
	CountryRegion = U.CountryRegion
FROM dbo.Customers AS C
INNER JOIN dbo.UpdateCustomers AS U ON U.CustomerKey = C.CustomerKey;

-- truncate table
TRUNCATE TABLE dbo.UpdateCustomers;
