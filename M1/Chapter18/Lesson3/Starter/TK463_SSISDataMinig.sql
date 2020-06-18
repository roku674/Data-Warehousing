-- TK463 Chapter 18 Code

/*********************/
/* Lesson 2 Practice */
/*********************/

USE AdventureWorks2012;
GO

-- Checking the extracted terms
SELECT Term, Score
FROM dbo.Terms
ORDER BY Score DESC;

-- Analyzing the Term Lookup results
-- Simple query
SELECT ReviewerName, Rating, Term, Frequency
FROM dbo.TermsInReviews
ORDER BY ReviewerName, Frequency DESC;
-- Advanced query - top 2 terms in reviews
WITH TermsCTE AS
(
SELECT ReviewerName, Rating, Term, Frequency,
 ROW_NUMBER() OVER(PARTITION BY ReviewerName ORDER BY Frequency DESC) AS RN
FROM dbo.TermsInReviews
)
SELECT ReviewerName, Rating, Term, Frequency
FROM TermsCTE
WHERE RN <= 2
ORDER BY Rating, Frequency DESC;
GO

-- Clean up
DROP TABLE dbo.Terms;
DROP TABLE dbo.TermsInReviews;
GO

