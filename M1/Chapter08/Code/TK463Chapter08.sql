-- TK463 Chapter 08 Code

/*********************/
/* Lesson 1 Practice */
/*********************/
USE TK463DW;

-- Drop the tables if needed
IF OBJECT_ID('stg.Customer','U') IS NOT NULL
  DROP TABLE stg.Customer;
GO

CREATE TABLE stg.Customer
(
 CustomerID    INT          NULL,
 PersonID      INT          NULL,
 StoreID       INT          NULL,
 TerritoryID   INT          NULL,
 AccountNumber VARCHAR(20) NULL,
 ModifiedDate  DATETIME     NULL,
);

GO

TRUNCATE TABLE stg.Customer;

SELECT 
	CustomerID, PersonId, StoreID, TerritoryID, AccountNumber, ModifiedDate
FROM stg.Customer;

-- Produce error in SSIS using this UPDATE statement

UPDATE stg.Customer
SET CustomerID = 'ASD';


