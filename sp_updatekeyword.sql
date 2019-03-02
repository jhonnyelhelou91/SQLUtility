IF EXISTS (SELECT 1 FROM sys.objects where [object_id] = OBJECT_ID('Utility.sp_updatekeyword'))
	DROP PROCEDURE [Utility].[sp_updatekeyword]
GO

CREATE PROCEDURE [Utility].[sp_updatekeyword]
	@Keyword     NVARCHAR(max), 
    @Separator   CHAR(1), 
    @Replacement NVARCHAR(max) 
AS
    DECLARE @tableColumns TABLE 
      ( 
         tablename  NVARCHAR(max), 
         columnname NVARCHAR(max) 
      ) 
    DECLARE @tableQueries TABLE 
      ( 
         tablename   NVARCHAR(max), 
         whereclause NVARCHAR(max) NULL, 
         selectquery NVARCHAR(max) NULL, 
         updatequery NVARCHAR(max) NULL 
      ) 

    INSERT INTO @tableColumns 
    SELECT '[' + schemas.NAME + '].[' + tables.NAME + ']' AS tableName, 
           '[' + columns.NAME + ']'                       AS columnName 
    FROM   sys.tables 
           INNER JOIN sys.columns 
                   ON columns.object_id = tables.object_id 
           INNER JOIN sys.schemas 
                   ON schemas.schema_id = tables.schema_id 
           INNER JOIN sys.types 
                   ON types.system_type_id = columns.system_type_id 
                      AND types.user_type_id = columns.user_type_id 
    WHERE  types.NAME IN ( 'varchar', 'char', 'nvarchar', 'nchar', 
                           'text', 'uniqueidentifier' ) 

    --select * from @tableColumns 
    INSERT INTO @tableQueries 
    SELECT DISTINCT tablename, 
                    (SELECT temp.columnname + ' LIKE ''' 
                            + Ltrim(Rtrim(items)) + ''' OR ' + Char(10) 
                     FROM   @tableColumns temp, 
                            dbo.Split(@Keyword, @Separator) 
                     WHERE  tblCol.tablename = temp.tablename 
                     FOR xml path('')), 
                    NULL, 
                    (SELECT 'UPDATE ' + tablename + Char(10) + 'SET ' 
                            + temp.columnname + ' = ''' 
                            + Ltrim(Rtrim(@Replacement)) + '''' + Char(10) 
                            + 'WHERE ' + temp.columnname + ' LIKE ''' 
                            + Ltrim(Rtrim(items)) + '''' + Char(10) + Char(10) 
                     FROM   @tableColumns temp, 
                            dbo.Split(@Keyword, @Separator) 
                     WHERE  tblCol.tablename = temp.tablename 
                     FOR xml path('')) 
    FROM   @tableColumns tblCol 

    UPDATE @tableQueries 
    SET    whereclause = Substring(whereclause, 0, Len(whereclause) - 3) 

    UPDATE @tableQueries 
    SET    selectquery = 'SELECT *' + Char(10) + 'FROM ' + tablename 
                         + Char(10) + 'WHERE ' + whereclause 

    RETURN 
      SELECT * 
      FROM   @tableQueries 

go 
