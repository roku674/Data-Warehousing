-- TK463 Chapter 16 Code

/********************/
/* Chapter Examples */
/********************/

-- MDSModelDeploy examples

-- List commands
!!"C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\MDSModelDeploy"

-- Help for a command
!!"C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\MDSModelDeploy" help listmodels

-- Creating a package with data
!!"C:\Program Files\Microsoft SQL Server\110\Master Data Services\Configuration\MDSModelDeploy" createpackage -model TK463Customer -version VERSION_1 -package C:\TK463\Chapter16\TK463CustomerData.pkg -includedata


-- Changing the System Administrator
/*
-- Replace DOMAIN\user_name with the new administrator's user name
-- and SID with the SID value for this user in the mdm.tblUser table
EXEC mdm.udpSecuritySetAdministrator @UserName='DOMAIN\user_name', @SID = 'SID', @PromoteNonAdmin = 1
*/
