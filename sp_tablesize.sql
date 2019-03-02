IF EXISTS (SELECT 1 FROM sys.objects where [object_id] = OBJECT_ID('Utility.sp_tablesize'))
	DROP PROCEDURE [Utility].[sp_tablesize]
GO

CREATE PROCEDURE [Utility].[sp_tablesize]
AS
BEGIN
-- TEMP TABLES FOR ANALYSIS 
CREATE TABLE #ttables 
  ( 
     sname       NVARCHAR(max), 
     irows       BIGINT, 
     ireservedkb BIGINT, 
     idatakb     BIGINT, 
     iindexkb    BIGINT, 
     iunusedkb   BIGINT 
  ) 

CREATE TABLE #ttmp 
  ( 
     sname       NVARCHAR(max), 
     irows       BIGINT, 
     sreservedkb NVARCHAR(max), 
     sdatakb     NVARCHAR(max), 
     sindexkb    NVARCHAR(max), 
     sunusedkb   NVARCHAR(max) 
  ) 

-- COLLECT SPACE USE PER TABLE 
EXEC Sp_msforeachtable 
  'INSERT #tTmp EXEC sp_spaceused [?];' 

-- CONVERT NUMBER-AS-TEXT COLUMNS TO NUMBER TYPES FOR EASIER ANALYSIS 
INSERT #ttables 
SELECT sname, 
       irows, 
       Cast(Replace(sreservedkb, ' KB', '') AS BIGINT), 
       Cast(Replace(sdatakb, ' KB', '') AS BIGINT), 
       Cast(Replace(sindexkb, ' KB', '') AS BIGINT), 
       Cast(Replace(sunusedkb, ' KB', '') AS BIGINT) 
FROM   #ttmp 

DROP TABLE #ttmp 

-- DO SOME ANALYSIS  
SELECT sName='TOTALS', 
       iRows=Sum(irows), 
       iReservedKB=Sum(ireservedkb), 
       iDataKB=Sum(idatakb), 
       iIndexKB=Sum(iindexkb), 
       iUnusedKB=Sum(iunusedkb) 
FROM   #ttables 
ORDER  BY sname 

SELECT * 
FROM   #ttables 
ORDER  BY ireservedkb DESC 

-- CLEAN UP 
DROP TABLE #ttables

END
GO
