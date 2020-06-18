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

/*********************/
/* Lesson 2 Practice */
/*********************/
USE DQS_STAGING_DATA;
GO

-- View with dirty data
CREATE VIEW dbo.TK463CustomersDirty
AS
SELECT C.CustomerKey,
 C.FirstName + ' ' + c.LastName AS FullName,
 C.AddressLine1 AS StreetAddress,
 G.City, G.StateProvinceName AS StateProvince,
 G.EnglishCountryRegionName AS CountryRegion,
 C.EmailAddress,
 C.BirthDate, 
 C.EnglishOccupation AS Occupation
FROM AdventureWorksDW2012.dbo.DimCustomer AS C
 INNER JOIN AdventureWorksDW2012.dbo.DimGeography AS G
  ON C.GeographyKey = G.GeographyKey
WHERE C.CustomerKey % 10 = 0
UNION
SELECT -11000,
 N'Jon Yang',
 N'3761 N. 14th St', 
 N'Munich',                        -- wrong city
 N'Kingsland',                     -- wrong state
 N'Austria',                       -- wrong country
 N'jon24#adventure-works.com',     -- wrong email
 '18900224',                       -- wrong birth date
 'Profesional'                     -- wrong occupation
UNION
SELECT -11100,
 N'Jacquelyn Suarez',
 N'7800 Corrinne Ct.',             -- wrong term
 N'Muenchen',                      -- another wrong city
 N'Queensland', 
 N'Australia',                      
 N'jacquelyn20@adventure-works.com',     
 '19680206',                       
 'Professional';
GO

-- Check the exported results of the cleansing
SELECT *
FROM dbo.TK463CustomersCleansingResult
ORDER BY CustomerKey_Output;
GO

-- Clean-up
USE DQS_STAGING_DATA;
DROP VIEW dbo.TK463CitiesStatesCountries;
DROP VIEW dbo.TK463CustomersDirty;
DROP TABLE dbo.TK463CustomersCleansingResult;
GO


