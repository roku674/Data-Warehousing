-- TK463, Chapter 11

/*********************/
/* Lesson 2 Practice */
/*                   */
/* Exercise 5        */
/*********************/


-- Inspect SSISDB catalog prioperties
SELECT *
  FROM catalog.catalog_properties;

-- Inspect SSISDB folders
SELECT *
  FROM catalog.folders;
/*
There should be one folder in the catalog, named "TK 463 Chapter 11",
whic you created in Exercise 1 of Lesson 2.
*/


-- Inspect the SSISDB projects
SELECT *
  FROM catalog.projects;
/*
There should be two SSIS projects in the catalog, which you deployed
in Exercises 3 and 4 of Lesson 2.
*/


-- Inspect the SSISDB packages
SELECT *
  FROM catalog.packages;

SELECT projects.project_id, projects.name AS project_name,
  packages.package_id, packages.name AS package_name
  FROM catalog.projects
  JOIN catalog.packages ON projects.project_id = packages.project_id;
/*
There should be seven SSIS packages in the catalog, belonging to the
two projects you inspected earlier: three of them part of the
"TK 463 Chapter 8" project, and four of them part of the
"TK 463 Chapter 10" project.
*/


-- Inspect SSISDB object parameters
SELECT *,
  CASE object_parameters.object_type
    WHEN 20 THEN 'project parameter'
    WHEN 30 THEN 'package parameter'
    END AS object_type_name
  FROM catalog.object_parameters;
/*
There should be 61 parameters belonging to the SSISDB projects and
packages.
*/

-- Inspect SSISDB operations
SELECT *,
  case operations.operation_type
    WHEN    1 THEN 'Integration Services initialization'
    WHEN    2 THEN 'Retention window'
    WHEN    3 THEN 'MaxProjectVersion'
    WHEN  101 THEN 'deploy_project'
    WHEN  106 THEN 'restore_project'
    WHEN  200 THEN 'create_execution and start_execution'
    WHEN  202 THEN 'stop_operation'
    WHEN  300 THEN 'validate_project'
    WHEN  301 THEN 'validate_package'
    WHEN 1000 THEN 'configure_catalog'
    END
  FROM catalog.operations;
/*
There should currently be data from two operations in the SSISDB
catalog, documenting two project deployments.
*/
