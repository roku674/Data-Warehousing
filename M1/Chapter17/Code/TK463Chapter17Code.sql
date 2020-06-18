-- TK463 Chapter 17 Code

/********************/
/* Chapter Examples */
/********************/

-- Attribute completeness

-- Find all nullable attributes
USE AdventureWorksDW2012;
SELECT COLUMN_NAME, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = N'dbo'
 AND TABLE_NAME = N'DimCustomer';
GO 

-- Find the number and the percentage of NULLs for MiddleName
WITH CountNULLsCTE AS
(
SELECT COUNT(*) AS cnt
FROM dbo.DimCustomer
 WHERE MiddleName IS NULL
)
SELECT cnt AS NumberOfNulls,
 100.0 * cnt / (SELECT COUNT(*) FROM dbo.DimCustomer)
  AS PercentageOfNulls
FROM CountNULLsCTE;

-- Frequency distribution of the Occupation column
USE DQS_STAGING_DATA;
WITH freqCTE AS
(
SELECT Occupation,
 ROW_NUMBER() OVER(PARTITION BY Occupation
  ORDER BY Occupation, CustomerKey) AS Rn_AbsFreq,
 ROW_NUMBER() OVER(
  ORDER BY Occupation, CustomerKey) AS Rn_CumFreq,
 ROUND(100 * PERCENT_RANK()
  OVER(ORDER BY Occupation), 0) AS Pr_AbsPerc, 
 ROUND(100 * CUME_DIST()
  OVER(ORDER BY Occupation, CustomerKey), 0) AS Cd_CumPerc
FROM dbo.TK463CustomersDirty 
)
SELECT Occupation,
 MAX(Rn_AbsFreq) AS AbsFreq,
 MAX(Rn_CumFreq) AS CumFreq,
 MAX(Cd_CumPerc) - MAX(Pr_Absperc) AS AbsPerc,
 MAX(Cd_CumPerc) AS CumPerc,
 CAST(REPLICATE('*',MAX(Cd_CumPerc) - MAX(Pr_Absperc)) AS varchar(100)) AS Histogram
FROM freqCTE
GROUP BY Occupation
ORDER BY Occupation;
GO
