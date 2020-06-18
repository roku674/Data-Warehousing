-- TK463 Chapter 07 Code

/*********************/
/* Lesson 1 Practice */
/*********************/

-- Prepare TK463DW database

USE TK463DW;
GO

-- Add columns for SCD
ALTER TABLE dbo.Customers 
  ADD
    ValidFrom DATE,
	ValidTo DATE;

-- Delete existing data in Customers dimension

TRUNCATE TABLE dbo.Customers;

-- After you have execute the package to load the Customer dimension

SELECT 
	CustomerDwKey,
	CustomerKey,
	FullName,
	MaritalStatus,
	Gender,
	CountryRegion,
	ValidFrom,
	ValidTo
FROM dbo.Customers
WHERE CustomerKey IN (15001, 14996, 14997);

-- Modify the stage table
UPDATE stg.Customer
SET TerritoryID = 4
WHERE 
	CustomerID  IN (15001, 14996, 14997);

-- Check the data after you again execute the SSIS job to load Customer dimension table

SELECT 
	CustomerDwKey,
	CustomerKey,
	FullName,
	MaritalStatus,
	Gender,
	CountryRegion,
	ValidFrom,
	ValidTo
FROM dbo.Customers
WHERE CustomerKey IN (15001, 14996, 14997);

GO

-- Drop the tables 
IF OBJECT_ID('dbo.UpdateCustomers','U') IS NOT NULL
  DROP TABLE dbo.UpdateCustomers;
GO

-- temporary table for updating dbo.Customers 
CREATE TABLE dbo.UpdateCustomers
(
 CustomerKey   INT           NOT NULL,
 FullName      NVARCHAR(150) NULL,
 EmailAddress  NVARCHAR(50)  NULL
);
GO

-- update 
UPDATE C
SET 
  FullName = U.FullName,
  EmailAddress = U.EmailAddress
FROM dbo.Customers AS C
INNER JOIN dbo.UpdateCustomers AS U ON U.CustomerKey = C.CustomerKey;

-- truncate table
TRUNCATE TABLE dbo.UpdateCustomers;

/*********************/
/* Lesson 2 Practice */
/*********************/

USE TK463DW;
-- Create needed tables

IF OBJECT_ID('stg.SalesOrderHeader','U') IS NOT NULL
  DROP TABLE stg.SalesOrderHeader;
GO

IF OBJECT_ID('stg.tmpUpdateSalesOrderHeader','U') IS NOT NULL
  DROP TABLE stg.tmpUpdateSalesOrderHeader;
GO

IF OBJECT_ID('stg.tmpDeleteSalesOrderHeader','U') IS NOT NULL
  DROP TABLE stg.tmpDeleteSalesOrderHeader;
GO

IF OBJECT_ID('stg.CDCSalesOrderHeader','U') IS NOT NULL
  DROP TABLE stg.CDCSalesOrderHeader;
GO

CREATE TABLE stg.SalesOrderHeader
(
  SalesOrderID      INT NULL,
  OrderDate		    DATETIME NULL,
  SalesOrderNumber  NVARCHAR(50),
  CustomerID		INT NULL,
  SalesPersonID		INT NULL,
  TerritoryID		INT NULL,
  SubTotal			DECIMAL(16,6) NULL,
  TaxAmt			DECIMAL(16,6) NULL,
  Freight			DECIMAL(16,6) NULL
);
GO

CREATE TABLE stg.CDCSalesOrderHeader
(
  SalesOrderID      INT NOT NULL PRIMARY KEY,
  OrderDate		    DATETIME NULL,
  SalesOrderNumber  NVARCHAR(50),
  CustomerID		INT NULL,
  SalesPersonID		INT NULL,
  TerritoryID		INT NULL,
  SubTotal			DECIMAL(16,6) NULL,
  TaxAmt			DECIMAL(16,6) NULL,
  Freight			DECIMAL(16,6) NULL
);
GO

CREATE TABLE stg.tmpUpdateSalesOrderHeader
(
  SalesOrderID      INT NULL,
  OrderDate		    DATETIME NULL,
  SalesOrderNumber  NVARCHAR(50),
  CustomerID		INT NULL,
  SalesPersonID		INT NULL,
  TerritoryID		INT NULL,
  SubTotal			DECIMAL(16,6) NULL,
  TaxAmt			DECIMAL(16,6) NULL,
  Freight			DECIMAL(16,6) NULL
);
GO

CREATE TABLE stg.tmpDeleteSalesOrderHeader
(
  SalesOrderID      INT NULL,
  OrderDate		    DATETIME NULL,
  SalesOrderNumber  NVARCHAR(50),
  CustomerID		INT NULL,
  SalesPersonID		INT NULL,
  TerritoryID		INT NULL,
  SubTotal			DECIMAL(16,6) NULL,
  TaxAmt			DECIMAL(16,6) NULL,
  Freight			DECIMAL(16,6) NULL
);
GO

-- Populate a sample table stg.CDCSalesOrderHeader from AdventureWorks2012 DB

INSERT INTO stg.CDCSalesOrderHeader (
  SalesOrderID, OrderDate, SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID, SubTotal, TaxAmt, Freight
)
SELECT 
  SalesOrderID, OrderDate, SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID, SubTotal, TaxAmt, Freight
FROM AdventureWorks2012.Sales.SalesOrderHeader;


-- Enable database for CDC

EXEC sys.sp_cdc_enable_db;

-- Add a custom role for CDC
CREATE ROLE cdc_role;

-- Enable table for CDC 
-- Ensure that the SQL Server Agent is running

EXEC sys.sp_cdc_enable_table
  @source_schema = N'stg',
  @source_name = N'CDCSalesOrderHeader',
  @role_name = N'cdc_role',
  @supports_net_changes = 1;

-- Test
UPDATE stg.CDCSalesOrderHeader
SET TerritoryID = 6
WHERE SalesOrderID = 43659; 

-- Read the changed data - you will get 2 rows, one with values before update and one after the update
SELECT * 
FROM cdc.stg_CDCSalesOrderHeader_CT;

-- Check the dbo.cdc_states table after the initial load using CDC in SSIS

SELECT 
  name,
  state
FROM dbo.cdc_states;

-- Needed update statment in SSIS

UPDATE S
SET
  OrderDate = U.OrderDate,
  SalesOrderNumber = U.SalesOrderNumber,
  CustomerID = U.CustomerID,
  SalesPersonID = U.SalesPersonID,
  TerritoryID = U.TerritoryID,
  SubTotal = U.SubTotal,
  TaxAmt = U.TaxAmt,
  Freight = U.Freight
FROM stg.SalesOrderHeader AS S
INNER JOIN stg.tmpUpdateSalesOrderHeader AS U ON S.SalesOrderID = U.SalesOrderID;

-- Delete statement to remove the deleted rows from the source system

DELETE stg.SalesOrderHeader
WHERE SalesOrderID IN 
  (SELECT SalesOrderID FROM stg.tmpDeleteSalesOrderHeader);

-- Produce a change in the CDC  

UPDATE stg.CDCSalesOrderHeader
SET TerritoryID = 8
WHERE SalesOrderID = 43659; 

/*********************/
/* Lesson 3 Practice */
/*********************/

IF OBJECT_ID('dbo.Products','U') IS NOT NULL
  DROP TABLE dbo.Products;
GO

-- Products dimension with a PK
CREATE TABLE dbo.Products
(
 ProductKey      INT          NOT NULL,
 ProductName     NVARCHAR(50) NULL,
 Color           NVARCHAR(15) NULL,
 Size            NVARCHAR(50) NULL,
 SubcategoryName NVARCHAR(50) NULL,
 CategoryName    NVARCHAR(50) NULL,
 CONSTRAINT PK_Products PRIMARY KEY (ProductKey)
);
GO