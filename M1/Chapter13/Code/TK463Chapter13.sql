-- TK463 Chapter 13 Code
/*********************/
/* Lesson 1 Practice */
/*********************/
USE TK463DW;

-- Create stage table
IF OBJECT_ID('stg.SalesTerritory','U') IS NOT NULL
  DROP TABLE stg.SalesTerritory;
GO

CREATE TABLE stg.SalesTerritory
(
 TerritoryID	   INT          NULL,
 Name			   NVARCHAR(50) NULL,
 CountryRegionCode NVARCHAR(10) NULL,
 [Group]           NVARCHAR(50) NULL,
 ModifiedDate      DATETIME     NULL
);


USE SSISDB;

DECLARE	@execution_id bigint;
-- Create an execution instance of the package 
EXEC catalog.create_execution
		@folder_name = N'TK463', 
		@project_name = N'TK 463 Chapter 13',
		@package_name = N'DimCustomerNew.dtsx', 
		@execution_id = @execution_id OUTPUT;

-- Create a data tap
EXEC catalog.add_data_tap
		@execution_id = @execution_id,
		@task_package_path = N'\Package\Dim Customer',
		@dataflow_path_id_string = N'Paths[stgPersonCustomer.OLE DB Source Output]',
		@data_filename = N'stgPersonCustomerDataTap.csv';

-- Execute the package
EXEC catalog.start_execution @execution_id;

/*********************/
/* Lesson 2 Practice */
/*********************/
USE SSISDB;

-- Retrieve execution times for packages
SELECT 
  MIN(start_time) AS start_time,
  execution_id, 
  package_name, 
  task_name, 
  subcomponent_name, 
  SUM(DATEDIFF(ms, start_time, end_time)) AS active_time,
  DATEDIFF(ms, MIN(start_time), MAX(end_time)) AS total_time
FROM 
  catalog.execution_component_phases
GROUP BY execution_id, package_name, task_name, subcomponent_name, execution_path
ORDER BY execution_id, package_name, task_name, subcomponent_name, execution_path;

