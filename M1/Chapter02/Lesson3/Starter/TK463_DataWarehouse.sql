-- TK463 Chapter 02 Code

/*********************/
/* Lesson 1 Practice */
/*********************/
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

-- Sequence for the Customers dimension
USE TK463DW;
GO
IF OBJECT_ID('dbo.SeqCustomerDwKey','SO') IS NOT NULL
  DROP SEQUENCE dbo.SeqCustomerDwKey;
GO
CREATE SEQUENCE dbo.SeqCustomerDwKey AS INT
 START WITH 1 
 INCREMENT BY 1;
GO

-- Drop the tables in correct order if needed
IF OBJECT_ID('dbo.InternetSales','U') IS NOT NULL
  DROP TABLE dbo.InternetSales;
GO
IF OBJECT_ID('dbo.Customers','U') IS NOT NULL
  DROP TABLE dbo.Customers;
GO
IF OBJECT_ID('dbo.Products','U') IS NOT NULL
  DROP TABLE dbo.Products;
GO
IF OBJECT_ID('dbo.Dates') IS NOT NULL
  DROP TABLE dbo.Dates;
GO

-- Customers dimension  with a PK
CREATE TABLE dbo.Customers
(
 CustomerDwKey INT           NOT NULL,
 CustomerKey   INT           NOT NULL,
 FullName      NVARCHAR(150) NULL,
 EmailAddress  NVARCHAR(50)  NULL,
 BirthDate     DATE          NULL,
 MaritalStatus NCHAR(1)      NULL,
 Gender        NCHAR(1)      NULL,
 Education     NVARCHAR(40)  NULL,
 Occupation    NVARCHAR(100) NULL,
 City          NVARCHAR(30)  NULL,
 StateProvince NVARCHAR(50)  NULL,
 CountryRegion NVARCHAR(50)  NULL,
 Age AS
  CASE
   WHEN BirthDate IS NULL THEN NULL
   WHEN DATEDIFF(yy,BirthDate,CURRENT_TIMESTAMP) > 50
   THEN 'Older'
   WHEN DATEDIFF(yy,BirthDate,CURRENT_TIMESTAMP) > 40
   THEN 'Middle Age'
   ELSE 'Younger' 
  END
 CurrentFlag   BIT           NOT NULL DEFAULT 1,
 CONSTRAINT PK_Customers PRIMARY KEY (CustomerDwKey)
);
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

-- Dates dimension with a PK
CREATE TABLE dbo.Dates
(
 DateKey         INT          NOT NULL,
 FullDate        DATE         NOT NULL,
 MonthNumberName NVARCHAR(15) NULL,
 CalendarQuarter TINYINT      NULL,
 CalendarYear    SMALLINT     NULL,
 CONSTRAINT PK_Dates PRIMARY KEY (DateKey)
);
GO

-- InternetSales fact table with a PK
CREATE TABLE dbo.InternetSales
(
 InternetSalesKey INT      NOT NULL IDENTITY(1,1),
 CustomerDwKey    INT      NOT NULL,
 ProductKey       INT      NOT NULL,
 DateKey          INT      NOT NULL,
 OrderQuantity    SMALLINT NOT NULL DEFAULT 0,
 SalesAmount      MONEY    NOT NULL DEFAULT 0,
 UnitPrice        MONEY    NOT NULL DEFAULT 0,
 DiscountAmount   FLOAT    NOT NULL DEFAULT 0,
 CONSTRAINT PK_InternetSales
  PRIMARY KEY (InternetSalesKey)
);
GO

-- Add foreign keys
ALTER TABLE dbo.InternetSales ADD CONSTRAINT 
 FK_InternetSales_Customers FOREIGN KEY(CustomerDwKey)
 REFERENCES dbo.Customers (CustomerDwKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT 
 FK_InternetSales_Products FOREIGN KEY(ProductKey)
 REFERENCES dbo.Products (ProductKey);
ALTER TABLE dbo.InternetSales ADD CONSTRAINT 
 FK_InternetSales_Dates FOREIGN KEY(DateKey)
 REFERENCES dbo.Dates (DateKey);
GO


/*********************/
/* Lesson 2 Practice */
/*********************/

-- Load the dimensions
-- Customers
/* Restart the sequence if needed
ALTER SEQUENCE dbo.SeqCustomerDwKey RESTART;
*/
INSERT INTO dbo.Customers
(CustomerDwKey, CustomerKey, FullName,
 EmailAddress, Birthdate, MaritalStatus,
 Gender, Education, Occupation,
 City, StateProvince, CountryRegion)
SELECT
 NEXT VALUE FOR dbo.SeqCustomerDwKey AS CustomerDwKey,
 C.CustomerKey,
 COALESCE(C.FirstName+' ','') + COALESCE(C.LastName,'') AS FullName,
 C.EmailAddress, C.BirthDate, C.MaritalStatus,
 C.Gender, C.EnglishEducation, C.EnglishOccupation,
 G.City, G.StateProvinceName, G.EnglishCountryRegionName 
FROM AdventureWorksDW2012.dbo.DimCustomer AS C
 INNER JOIN AdventureWorksDW2012.dbo.DimGeography AS G
  ON C.GeographyKey = G.GeographyKey;
GO
/* Check
SELECT *
FROM dbo.Customers;
*/

-- Products
INSERT INTO dbo.Products
(ProductKey, ProductName, Color,
 Size, SubcategoryName, CategoryName)
SELECT P.ProductKey, P.EnglishProductName, P.Color,
 P.Size, S.EnglishProductSubcategoryName, C.EnglishProductCategoryName 
FROM AdventureWorksDW2012.dbo.DimProduct AS P
 INNER JOIN AdventureWorksDW2012.dbo.DimProductSubcategory AS S
  ON P.ProductSubcategoryKey = S.ProductSubcategoryKey
 INNER JOIN AdventureWorksDW2012.dbo.DimProductCategory AS C
  ON S.ProductCategoryKey = C.ProductCategoryKey;
GO

-- Dates
INSERT INTO dbo.Dates
(DateKey, FullDate, MonthNumberName,
 CalendarQuarter, CalendarYear)
SELECT DateKey, FullDateAlternateKey,
 FORMAT(MonthNumberOfYear,'00 ') + EnglishMonthName,
 CalendarQuarter, CalendarYear 
FROM AdventureWorksDW2012.dbo.DimDate;
GO

/* Restart the identity if needed
DBCC CHECKIDENT ('dbo.InternetSales');
*/
-- InternetSales
INSERT INTO dbo.InternetSales
(CustomerDwKey, ProductKey, DateKey,
 OrderQuantity, SalesAmount,
 UnitPrice, DiscountAmount)
SELECT C.CustomerDwKey,
 FIS.ProductKey, FIS.OrderDateKey,
 FIS.OrderQuantity, FIS.SalesAmount,
 FIS.UnitPrice, FIS.DiscountAmount
FROM AdventureWorksDW2012.dbo.FactInternetSales AS FIS 
 INNER JOIN dbo.Customers AS C
  ON FIS.CustomerKey = C.CustomerKey;
GO
/* Check
SELECT *
FROM dbo.InternetSales;
*/

-- Data compression
-- Space used by the InternetSales table
EXEC sys.sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';
GO
-- 3080 KB reserved
-- Compress using page compression
ALTER TABLE dbo.InternetSales 
 REBUILD WITH (DATA_COMPRESSION = PAGE);
GO
-- Re-check the space used by the InternetSales table
EXEC sys.sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';
GO
-- 1096 KB reserved


-- Columnstore index
CREATE COLUMNSTORE INDEX CSI_InternetSales
  ON dbo.InternetSales
  (InternetSalesKey, CustomerDwKey, ProductKey, DateKey,
   OrderQuantity, SalesAmount,
   UnitPrice, DiscountAmount);
GO

-- Aggregating query with joins
SELECT C.CountryRegion, P.CategoryName, D.CalendarYear,
 SUM(I.SalesAmount) AS Sales
FROM dbo.InternetSales AS I
 INNER JOIN dbo.Customers AS C
  ON I.CustomerDwKey = C.CustomerDwKey
 INNER JOIN dbo.Products AS P
  ON I.ProductKey = p.ProductKey
 INNER JOIN dbo.Dates AS d
  ON I.DateKey = D.DateKey
GROUP BY C.CountryRegion, P.CategoryName, D.CalendarYear
ORDER BY C.CountryRegion, P.CategoryName, D.CalendarYear;
GO

-- Re-check the space used by the InternetSales table
EXEC sys.sp_spaceused N'dbo.InternetSales', @updateusage = N'TRUE';
GO
-- 1560 KB reserved
