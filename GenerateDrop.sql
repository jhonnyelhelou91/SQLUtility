IF EXISTS (SELECT 1 FROM sys.views where [object_id] = OBJECT_ID('Utility.GenerateDrop'))
	DROP VIEW [Utility].[GenerateDrop]
GO

CREATE VIEW [Utility].[GenerateDrop]
AS
	SELECT
		[object].[type] AS [Type],
		[object].[type_desc] AS [TypeDescription],
        [object].[NAME] AS [Name],
        [schema].[NAME] AS [Schema], 
        [table].[NAME] AS [Table], 
       ( CASE 
           WHEN ( [object].[type] = 'PK' OR [object].[type] = 'F' OR [object].[type] = 'D' OR [object].[type] = 'C' ) THEN 
           'ALTER TABLE ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([table].[NAME]) + Char(10) +
		'DROP CONSTRAINT ' + QUOTENAME([object].[NAME])
           WHEN ( [object].[type] = 'TR' ) THEN 
           'DROP TRIGGER ' + QUOTENAME([schema].[NAME]) + '.' + [object].[NAME] 
           WHEN ( [object].[type] = 'UQ' ) THEN 
           'DROP INDEX ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME]) + Char(10) + 'ON ' + 
		QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([table].[NAME])
           WHEN ( [object].[type] = 'TF' OR [object].[type] = 'FN' OR [object].[type] = 'IF' ) THEN 
           'DROP FUNCTION [' + [schema].[NAME] + '].[' 
           + [object].[NAME] + ']' 
           WHEN ( [object].[type] = 'AF' ) THEN 
           'DROP AGGREGATE ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME]) 
           WHEN ( [object].[type] = 'V' ) THEN 
           'DROP VIEW ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME])
           WHEN ( [object].[type] = 'U' ) THEN 
           'DROP TABLE ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME])
           WHEN ( [object].[type] = 'P' ) THEN 
           'DROP PROCEDURE [' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME])
           --FS: CLR scalar fnc 
           WHEN ( [object].[type] = 'FS' ) THEN
           'DROP FUNCTION [' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME]) + '--Please do not forgot to drop assembly'
           --FT: CLR table-valued fnc 
           WHEN ( [object].[type] = 'FT' ) THEN
           'DROP FUNCTION ' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME]) + '--Please do not forgot to drop assembly'
           --PC: CLR stored procedure 
           WHEN ( [object].[type] = 'PC' ) THEN 
           'DROP PROCEDURE' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME]) + '--Please do not forgot to drop assembly'
           --IT: Internal Tables
	   WHEN ( [object].[type] = 'IT' ) THEN
	   '--Drop Internal Tables is not implemented'
           --PG: Plan Guide 
           WHEN ( [object].[type] = 'PG' ) THEN
	   'EXEC sp_control_plan_guide N''DROP'', N''' + [object].[NAME] + ''''
           --R: Rule
           WHEN ( [object].[type] = 'R' ) THEN 
           'DROP RULE [' + QUOTENAME([schema].[NAME]) + '.' + QUOTENAME([object].[NAME])
           --RF: Replication Filter Procedure 
	   WHEN ( [object].[type] = 'RF' ) THEN
	   '--Drop Internal Tables is not implemented'
           --SN: Synonym 
	   WHEN ( [object].[type] = 'SN' ) THEN
	   '--Drop Synonym is not implemented'
           --SQ: Service Queue 
	   WHEN ( [object].[type] = 'SQ' ) THEN
	   '--Drop Service Queue is not implemented'
           ELSE ''
         END ) + Char(10)       AS [Query]
	FROM   sys.objects [object]
		   LEFT JOIN sys.tables [table]
				  ON [table].object_id = [object].parent_object_id 
		   LEFT JOIN sys.schemas [schema]
				  ON [schema].schema_id = [schema].schema_id 
	WHERE  [object].type <> 's' --remove system constraints and objects
GO
