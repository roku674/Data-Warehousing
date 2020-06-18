-- TK463 Chapter 16 Code

/*********************/
/* Lesson 1 Practice */
/*********************/

USE MDSTK463;
GO

-- Populate the CountryRegion staging table
INSERT INTO stg.CountryRegion_Leaf
 (ImportType, ImportStatus_ID, BatchTag, Name)
SELECT DISTINCT 1, 0, N'CountryRegionLeaf_Batch00001',
 G.EnglishCountryRegionName
FROM AdventureWorksDW2012.dbo.DimCustomer AS C
 INNER JOIN AdventureWorksDW2012.dbo.DimGeography AS G
  ON C.GeographyKey = G.GeographyKey;

-- Populate the StateProvince staging table
INSERT INTO stg.StateProvince_Leaf
 (ImportType, ImportStatus_ID, BatchTag,
  Name, CountryRegion)
SELECT DISTINCT 1, 0, N'StateProvinceLeaf_Batch00001',
 G.StateProvinceName, CR.Code
FROM AdventureWorksDW2012.dbo.DimCustomer AS C
 INNER JOIN AdventureWorksDW2012.dbo.DimGeography AS G
  ON C.GeographyKey = G.GeographyKey
 INNER JOIN mdm.CountryRegion AS CR
  ON G.EnglishCountryRegionName = CR.Name;
  
-- Populate the TK463Customer staging table
-- Only every tenth customer from AW is selected
INSERT INTO stg.TK463Customer_Leaf
 (ImportType, ImportStatus_ID, BatchTag,
  Code, Name, StateProvince, StreetAddress,
  City, EmailAddress, MaritalStatus, 
  BirthDate, YearlyIncome)
SELECT 1, 0, N'TK463Customer_Batch00001',
 C.CustomerKey,
 C.FirstName + ' ' + c.LastName AS Name,
 SP.Code, C.AddressLine1 AS StreetAddress,
 G.City, C.EmailAddress, C.MaritalStatus,
 C.BirthDate, C.YearlyIncome
FROM AdventureWorksDW2012.dbo.DimCustomer AS C
 INNER JOIN AdventureWorksDW2012.dbo.DimGeography AS G
  ON C.GeographyKey = G.GeographyKey
 INNER JOIN mdm.StateProvince AS SP
  ON G.StateProvinceName = SP.Name
WHERE C.CustomerKey % 10 = 0;
GO


