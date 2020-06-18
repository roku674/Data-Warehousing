-- TK463 Chapter 02 Code

/********************/
/* Chapter Examples */
/********************/

-- Indexed views
USE AdventureWorksDW2012;
GO

SET STATISTICS IO ON;
GO

-- Query with aggregates
SELECT ProductKey, 
 SUM(SalesAmount) AS Sales,
 COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;
GO

-- Create a view
CREATE VIEW dbo.SalesByProduct
WITH SCHEMABINDING AS
SELECT ProductKey, 
 SUM(SalesAmount) AS Sales,
 COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;
GO
-- Index the view
CREATE UNIQUE CLUSTERED INDEX CLU_SalesByProduct
 ON dbo.SalesByProduct (ProductKey);
GO

-- Query with aggregates
SELECT ProductKey, 
 SUM(SalesAmount) AS Sales,
 COUNT_BIG(*) AS NumberOfRows
FROM dbo.FactInternetSales
GROUP BY ProductKey;
GO

-- Clean up
DROP VIEW dbo.SalesByProduct;
GO


-- Running totals
USE AdventureWorksDW2012;
GO

SET STATISTICS IO ON;
GO

-- Query with a self join
WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
 ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1))
  AS OrderLineNumber,
 ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA
 INNER JOIN dbo.DimCustomer AS C
    ON ISA.CustomerKey = C.CustomerKey
WHERE ISA.CustomerKey <= 12000
)
SELECT ISG1.Gender, ISG1.OrderLineNumber,
 MIN(ISG1.SalesAmount), SUM(ISG2.SalesAmount) AS RunningTotal
FROM InternetSalesGender AS ISG1
 INNER JOIN InternetSalesGender AS ISG2
  ON ISG1.Gender = ISG2.Gender
     AND ISG1.OrderLineNumber >= ISG2.OrderLineNumber 
GROUP BY ISG1.Gender, ISG1.OrderLineNumber
ORDER BY ISG1.Gender, ISG1.OrderLineNumber;

-- Query with a window function
WITH InternetSalesGender AS
(
SELECT ISA.CustomerKey, C.Gender,
 ISA.SalesOrderNumber + CAST(ISA.SalesOrderLineNumber AS CHAR(1))
  AS OrderLineNumber,
 ISA.SalesAmount
FROM dbo.FactInternetSales AS ISA
 INNER JOIN dbo.DimCustomer AS C
    ON ISA.CustomerKey = C.CustomerKey
WHERE ISA.CustomerKey  <= 12000
)
SELECT ISG.Gender, ISG.OrderLineNumber, ISG.SalesAmount, 
 SUM(ISG.SalesAmount) 
   OVER(PARTITION BY ISG.Gender
        ORDER BY ISG.OrderLineNumber
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW) AS RunningTotal
FROM InternetSalesGender AS ISG
ORDER BY ISG.Gender, ISG.OrderLineNumber;
GO

SET STATISTICS IO OFF;
GO


-- Functions useful for lineage information
SELECT 
 APP_NAME() AS ApplicationName,
 DATABASE_PRINCIPAL_ID() AS DatabasePrincipalId,
 USER_NAME() AS DatabasePrincipalName,
 SUSER_ID() AS ServerPrincipalId,
 SUSER_SID() AS ServerPrincipalSID,
 SUSER_SNAME() AS ServerPrincipalName,
 CONNECTIONPROPERTY('net_transport') AS TransportProtocol,
 CONNECTIONPROPERTY('client_net_address') AS ClientNetAddress,
 CURRENT_TIMESTAMP AS CurrentDateTime,
 @@ROWCOUNT AS RowsProcessedByLastCommand;
GO



/***********************/
/* Suggested Practices */
/***********************/
-- Code for filtered index suggested practice
/*
USE AdventureWorksDW2012;
GO

SELECT Suffix, COUNT(*)
FROM dbo.DimCustomer
GROUP BY Suffix;

SELECT CustomerKey, FirstName, LastName, Suffix
FROM dbo.DimCustomer
WHERE Suffix = 'Jr.';
GO

CREATE INDEX NCLF_DimCustomer_Suffix
 ON dbo.DimCustomer(Suffix)
 WHERE Suffix IS NOT NULL;
GO

SET STATISTICS IO ON;
GO

SELECT CustomerKey, FirstName, LastName, Suffix
FROM dbo.DimCustomer
WHERE Suffix = 'Jr.';

SELECT CustomerKey, FirstName, LastName, Suffix
FROM dbo.DimCustomer
WHERE Suffix IS NULL;

SET STATISTICS IO OFF;
GO

-- Clean up
DROP INDEX NCLF_DimCustomer_Suffix
 ON dbo.DimCustomer;
GO
*/
