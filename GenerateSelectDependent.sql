SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT 1 FROM sys.objects where [object_id] = OBJECT_ID('Utility.GenerateSelectDependent'))
	DROP FUNCTION [Utility].GenerateSelectDependent
GO

CREATE FUNCTION Utility.GenerateSelectDependent
(	
	@table nvarchar(100),
	@Where nvarchar(max)
)
RETURNS TABLE 
AS
RETURN
(
	SELECT * 
	FROM   (SELECT 'SELECT * FROM ' 
				   + Quotename(Schema_name([table].[schema_id])) + '.' 
				   + Quotename([table].[name]) + ' WHERE ' 
				   + Replace(
				   Stuff( 
					( 
						SELECT ' OR ' + Quotename(c.[name]) + ' ' + RTRIM(LTRIM(@Where))
						FROM sys.foreign_keys fk
						INNER JOIN sys.foreign_key_columns fkc
							ON fkc.constraint_object_id = fk.object_id
						INNER JOIN sys.columns c
							ON c.object_id = fkc.parent_object_id AND fkc.parent_column_id = c.column_id
						WHERE fk.parent_object_id = [table].[object_id] AND fk.referenced_object_id = Object_id(@table)
						FOR XML PATH('')
					), 1, 4, ''), '&gt;', '>') AS Query 
			FROM sys.tables [table]) d 
	WHERE  d.query IS NOT NULL
)
GO
