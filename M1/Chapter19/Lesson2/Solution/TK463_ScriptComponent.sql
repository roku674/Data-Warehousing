-- TK463 Chapter 19 Code

/*********************/
/* Lesson 2 Practice */
/*********************/

-- Change the context to the AdventureWorksDW2012 database
USE AdventureWorksDW2012;
GO

-- Prepare the table for the results of the Script component
IF OBJECT_ID('dbo.EmailValidated','U') IS NOT NULL
  DROP TABLE dbo.EmailValidated;
GO
CREATE TABLE dbo.EmailValidated
(
 CustomerKey   INT           NOT NULL,
 EmailAddress  NVARCHAR(50)  NULL,
 EmailValid    BIT           NULL
);
GO

-- Check the results
SELECT *
FROM dbo.EmailValidated
WHERE EmailValid = 0;
GO

-- Clean up
DROP TABLE dbo.EmailValidated;
GO