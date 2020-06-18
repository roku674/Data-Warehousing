-- TK463 Chapter 15 Code

/********************/
/* Chapter Examples */
/********************/

-- Query to get customer data needed for the entities in practice for lesson 3
USE AdventureWorksDW2012;
SELECT  C.CustomerKey
       ,C.FirstName + ' ' + c.LastName AS FullName
       ,C.AddressLine1 AS StreetAddress
       ,G.City
	   ,G.StateProvinceName
       ,G.EnglishCountryRegionName
	   ,C.EmailAddress
       ,C.MaritalStatus
	   ,C.BirthDate
	   ,C.YearlyIncome
  FROM dbo.DimCustomer AS C
       INNER JOIN dbo.DimGeography AS G
        ON C.GeographyKey = G.GeographyKey;