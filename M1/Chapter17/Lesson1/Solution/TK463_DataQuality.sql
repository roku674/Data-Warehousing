-- TK463 Chapter 17 Code

/*********************/
/* Lesson 1 Practice */
/*********************/
USE DQS_STAGING_DATA;
GO

-- View with all possible valid cities, states or provinces, and countries or regions 
CREATE VIEW dbo.TK463CitiesStatesCountries
AS
SELECT DISTINCT
 City, StateProvinceName AS StateProvince,
 EnglishCountryRegionName AS CountryRegion
FROM AdventureWorksDW2012.dbo.DimGeography;
GO


-- Clean-up
USE DQS_STAGING_DATA;
DROP VIEW dbo.TK463CitiesStatesCountries;
GO

