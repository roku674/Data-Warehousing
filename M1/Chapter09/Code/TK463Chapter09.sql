-- TK463 Chapter 09 Code

/*********************/
/* Lesson 1 Practice */
/*********************/

-- SSIS query 
SELECT     
	BusinessEntityID, 
	PersonType, 
	NameStyle, 
	Title, 
	FirstName, 
	MiddleName, 
	LastName, 
	Suffix, 
	EmailPromotion, 
	AdditionalContactInfo, 
	Demographics, 
	rowguid, 
    ModifiedDate
FROM
	Person.Person
WHERE 
	YEAR(ModifiedDate) >= ?

-- Create additional database

USE master;
IF DB_ID('TK463DWProd') IS NOT NULL
  DROP DATABASE TK463DWProd;
GO
CREATE DATABASE TK463DWProd
 ON PRIMARY 
 (NAME = N'TK463DWProd', FILENAME = N'C:\TK463\TK463DWProd.mdf',
  SIZE = 307200KB , FILEGROWTH = 10240KB )
 LOG ON 
 (NAME = N'TK463DWProd_log', FILENAME = N'C:\TK463\TK463DWProd_log.ldf',
  SIZE = 51200KB , FILEGROWTH = 10%);
GO
ALTER DATABASE TK463DWProd SET RECOVERY SIMPLE WITH NO_WAIT;
GO

USE TK463DWProd;
GO
-- Create the schema stg to stage all needed source tables
CREATE SCHEMA stg AUTHORIZATION dbo;
GO

-- create the needed table
CREATE TABLE stg.Person
(
 BusinessEntityID INT          NULL,
 PersonType       NCHAR(2)     NULL,
 Title            NVARCHAR(8)  NULL,
 FirstName        NVARCHAR(50) NULL,
 MiddleName       NVARCHAR(50) NULL,
 LastName         NVARCHAR(50) NULL,
 Suffix           NVARCHAR(10) NULL,
 ModifiedDate     DATETIME     NULL
);
