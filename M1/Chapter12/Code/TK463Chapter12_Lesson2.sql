-- TK463, Chapter 12

/*********************/
/* Lesson 2 Practice */
/*                   */
/* Exercise 1        */
/*********************/

-- Create logins
USE MASTER;

CREATE LOGIN Dejan
WITH PASSWORD = 'p@S5w0rd';

CREATE LOGIN Grega
WITH PASSWORD = 'p@S5w0rd';

CREATE LOGIN Matija
WITH PASSWORD = 'p@S5w0rd';
GO


-- Create SSISDB Users
USE SSISDB;

CREATE USER Dejan;
CREATE USER Grega;
CREATE USER Matija;
GO

/*********************/
/* Lesson 2 Practice */
/*                   */
/* Exercise 1        */
/*********************/


-- Verify your own settings
SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO


-- Verify Dejan's Settings
EXECUTE AS USER = 'Dejan';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO


-- Verify Grega's Settings
EXECUTE AS USER = 'Grega';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO


-- Verify Matija's Settings
EXECUTE AS USER = 'Matija';
GO

SELECT CASE effective_object_permissions.object_type
         WHEN 1 THEN 'folder'
         WHEN 2 THEN 'project'
         WHEN 3 THEN 'environment'
         END AS object_type_name,
       CASE effective_object_permissions.object_type
         WHEN 1 THEN (
                     SELECT CAST(folders.name as NVARCHAR(128))
                       FROM catalog.folders
                      WHERE (folders.folder_id = effective_object_permissions.[object_id])
                     )
         WHEN 2 THEN (
                     SELECT CAST(projects.name as NVARCHAR(128))
                       FROM catalog.projects
                      WHERE (projects.project_id = effective_object_permissions.[object_id])
                     )
         WHEN 3 THEN (
                     SELECT CAST(environments.name as NVARCHAR(128))
                       FROM catalog.environments
                      WHERE (environments.environment_id = effective_object_permissions.[object_id])
                     )
         END AS securable,
       CASE effective_object_permissions.permission_type
         WHEN   1 THEN 'READ'
         WHEN   2 THEN 'MODIFY'
         WHEN   3 THEN 'EXECUTE'
         WHEN   4 THEN 'MANAGE_PERMISSIONS'
         WHEN 100 THEN 'CREATE_OBJECTS'
         WHEN 101 THEN 'READ_OBJECTS'
         WHEN 102 THEN 'MODIFY_OBJECTS'
         WHEN 103 THEN 'EXECUTE_OBJECTS'
         WHEN 104 THEN 'MANAGE_OBJECT_PERMISSIONS'
         END AS permission
  FROM catalog.effective_object_permissions
 WHERE (effective_object_permissions.object_type IN (1, 2, 3));
GO

REVERT;
GO
