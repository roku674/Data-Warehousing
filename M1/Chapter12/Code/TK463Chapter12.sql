-- TK463, Chapter 12

/************************/
/* Lesson 1             */
/*                      */
/* Transact-SQL Example */
/************************/

USE SSISDB;
GO

-- Execute Package, use Basic Logging
DECLARE @execution_id    BIGINT;
DECLARE @use32bitruntime BIT         = CAST(0 AS BIT);
DECLARE @logging_level   INT         = 1;

EXEC catalog.create_execution
     @folder_name = N'TK 463 Chapter 11',
     @project_name = N'TK 463 Chapter 10',
     @package_name = N'Master.dtsx',
     @use32bitruntime = @use32bitruntime,
     @reference_id = NULL,
     @execution_id = @execution_id OUTPUT;

EXEC catalog.set_execution_parameter_value
     @execution_id,
     @object_type = 50,
     @parameter_name = N'LOGGING_LEVEL',
     @parameter_value = @logging_level;

EXEC catalog.start_execution
     @execution_id = @execution_id;
GO


-- Execute Package, and Stop the Operation after 30 seconds
DECLARE @execution_id    BIGINT;
DECLARE @use32bitruntime BIT         = CAST(0 AS BIT);
DECLARE @logging_level   INT         = 1;
DECLARE @operation_id    BIGINT;

EXEC catalog.create_execution
     @folder_name = N'TK 463 Chapter 11',
     @project_name = N'TK 463 Chapter 10',
     @package_name = N'Master.dtsx',
     @use32bitruntime = @use32bitruntime,
     @reference_id = NULL,
     @execution_id = @execution_id OUTPUT;

EXEC catalog.set_execution_parameter_value
     @execution_id,
     @object_type = 50,
     @parameter_name = N'LOGGING_LEVEL',
     @parameter_value = @logging_level;

EXEC catalog.start_execution
     @execution_id = @execution_id;

WAITFOR DELAY '00:00:30.000';

SET @operation_id = (
  SELECT operations.operation_id
    FROM catalog.operations
    INNER JOIN catalog.executions on operations.process_id = executions.process_id
    WHERE (executions.execution_id = @execution_id)
  );

EXEC catalog.stop_operation
     @operation_id = @operation_id;
GO
