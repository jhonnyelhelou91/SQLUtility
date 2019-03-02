IF EXISTS (SELECT 1 FROM sys.objects where [object_id] = OBJECT_ID('Utility.GenerateRenameLinkedServer'))
	DROP FUNCTION [Utility].[GenerateRenameLinkedServer]
GO

CREATE FUNCTION Utility.[GenerateRenameLinkedServer]
(
	@old nvarchar(max), 
    @new nvarchar(max)
)
RETURNS TABLE 
AS
RETURN
(
	SELECT o.Name, o.create_date, o.modify_date, o.[type_desc] as [Type], m.definition as CreateQuery, 
	replace(
					replace(
									replace(
													replace(definition, 'From ' + @old,  'From ' + @new), 
													'join ' + @old,  'join ' + @new), 
									'CREATE PROCEDURE', 'ALTER PROCEDURE'), 
					'CREATE VIEW', 'ALTER VIEW') as AlterQuery
	FROM sys.sql_modules m
	INNER JOIN sys.objects o
		on o.[object_id] = m.[object_id]
	WHERE m.[Definition] LIKE '%' + @old + '%.%.%' 
		  AND (OBJECTPROPERTY(o.[object_id], 'IsProcedure') = 1 or OBJECTPROPERTY(o.[object_id], 'IsView') = 1)
)
