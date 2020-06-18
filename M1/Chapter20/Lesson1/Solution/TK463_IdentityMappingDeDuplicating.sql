-- TK463 Chapter 20 Code

/*********************/
/* Lesson 1 Practice */
/*********************/

USE DQS_STAGING_DATA;
GO

-- Creating the table for clean data
IF OBJECT_ID(N'dbo.CustomersClean', N'U') IS NOT NULL
   DROP TABLE dbo.CustomersClean;
GO
CREATE TABLE dbo.CustomersClean
(
 CustomerKey   INT           NOT NULL PRIMARY KEY,
 FullName      NVARCHAR(200) NULL,
 StreetAddress NVARCHAR(200) NULL
);
GO

-- Populating the clean data table
INSERT INTO dbo.CustomersClean
 (CustomerKey, FullName, StreetAddress)
SELECT CustomerKey,
 FirstName + ' ' + LastName AS FullName,
 AddressLine1 AS StreetAddress
FROM AdventureWorksDW2012.dbo.DimCustomer
WHERE CustomerKey % 10 = 0;
GO        

-- Creating and populating the table for dirty data
IF OBJECT_ID(N'dbo.CustomersDirty', N'U') IS NOT NULL
   DROP TABLE dbo.CustomersDirty;
GO
CREATE TABLE dbo.CustomersDirty
(
 CustomerKey      INT           NOT NULL PRIMARY KEY,
 FullName         NVARCHAR(200) NULL,
 StreetAddress    NVARCHAR(200) NULL,
 Updated          INT           NULL,
 CleanCustomerKey INT           NULL
);
GO
INSERT INTO dbo.CustomersDirty
 (CustomerKey, FullName, StreetAddress, Updated)
SELECT CustomerKey * (-1) AS CustomerKey,
 FirstName + ' ' + LastName AS FullName,
 AddressLine1 AS StreetAddress,
 0 AS Updated
FROM AdventureWorksDW2012.dbo.DimCustomer
WHERE CustomerKey % 10 = 0;
GO   

-- Making random changes in the dirty table
DECLARE @i AS INT = 0, @j AS INT = 0;
WHILE (@i < 3)      -- loop more times for more changes
BEGIN
 SET @i += 1;
 SET @j = @i - 2;   -- control here in which step you want to update
                    -- only already updated rows
 WITH RandomNumbersCTE AS
 (
  SELECT  CustomerKey
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber1
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber2  
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber3                      
         ,FullName
         ,StreetAddress
         ,Updated
    FROM dbo.CustomersDirty 
 )    
 UPDATE RandomNumbersCTE SET
         FullName =
         STUFF(FullName,
               CAST(CEILING(RandomNumber1 * LEN(FullName)) AS INT),
               1,
               CHAR(CEILING(RandomNumber2 * 26) + 96))
        ,StreetAddress = 
         STUFF(StreetAddress,
               CAST(CEILING(RandomNumber1 * LEN(StreetAddress)) AS INT),
               2, '')                              
        ,Updated = Updated + 1
  WHERE RAND(CHECKSUM(NEWID()) % 1000000000 - CustomerKey) < 0.17
        AND Updated > @j;
 WITH RandomNumbersCTE AS
 (
  SELECT  CustomerKey
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber1
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber2 
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber3                   
         ,FullName
         ,StreetAddress
		 ,Updated
    FROM dbo.CustomersDirty 
 )    
 UPDATE RandomNumbersCTE SET
         FullName =
         STUFF(FullName, CAST(CEILING(RandomNumber1 * LEN(FullName)) AS INT),
               0,
               CHAR(CEILING(RandomNumber2 * 26) + 96))
        ,StreetAddress = 
         STUFF(StreetAddress,
               CAST(CEILING(RandomNumber1 * LEN(StreetAddress)) AS INT),
               2,
               CHAR(CEILING(RandomNumber2 * 26) + 96) + 
               CHAR(CEILING(RandomNumber3 * 26) + 96))  
        ,Updated = Updated + 1                                                               
  WHERE RAND(CHECKSUM(NEWID()) % 1000000000 - CustomerKey) < 0.17
        AND Updated > @j;
 WITH RandomNumbersCTE AS
 (
  SELECT  CustomerKey
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber1
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber2 
         ,RAND(CHECKSUM(NEWID()) % 1000000000 + CustomerKey) AS RandomNumber3                   
         ,FullName
         ,StreetAddress
         ,Updated
    FROM dbo.CustomersDirty
 )    
 UPDATE RandomNumbersCTE SET
         FullName =
         STUFF(FullName,
               CAST(CEILING(RandomNumber1 * LEN(FullName)) AS INT),
               1, '')
        ,StreetAddress = 
         STUFF(StreetAddress,
               CAST(CEILING(RandomNumber1 * LEN(StreetAddress)) AS INT),
               0,
               CHAR(CEILING(RandomNumber2 * 26) + 96) + 
               CHAR(CEILING(RandomNumber3 * 26) + 96))                           
        ,Updated = Updated + 1               
  WHERE RAND(CHECKSUM(NEWID()) % 1000000000 - CustomerKey) < 0.16
        AND Updated > @j;
END;
GO

-- Checking the data after changes
SELECT  C.FullName
       ,D.FullName
       ,C.StreetAddress
       ,D.StreetAddress
       ,D.Updated
  FROM dbo.CustomersClean AS C
       INNER JOIN dbo.CustomersDirty AS D
        ON C.CustomerKey = D.CustomerKey * (-1)
 WHERE C.FullName <> D.FullName
       OR C.StreetAddress <> D.StreetAddress
ORDER BY D.Updated DESC;
GO       

-- Updating for DQS Cleansing transformation
UPDATE dbo.CustomersDirty
   SET FullName = N'Jacquelyn Suarez',
       StreetAddress = N'7800 Corrinne Ct.'
WHERE CustomerKey = -11010;
GO

