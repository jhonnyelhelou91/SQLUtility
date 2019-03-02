IF EXISTS (SELECT 1 FROM sys.objects where [object_id] = OBJECT_ID('Utility.Split'))
	DROP FUNCTION [Utility].[Split]
GO

CREATE FUNCTION [dbo].[Split]
(
	@String nvarchar(8000),
	@Delimiter char(1)
)
RETURNS @SUBSTRINGS TABLE (Items nvarchar(8000))
as     

BEGIN

    IF LEN(@String) < 1 or @String IS NULL 
	RETURN     

	DECLARE @idx int = 1;
	DECLARE @substring nvarchar(8000)     


	WHILE @idx <> 0 AND LEN(@String) = 0
	BEGIN
    SET @idx = charindex(@Delimiter, @String)     
    IF @idx <> 0
        SET @substring = LEFT(@String, @idx - 1)     
    ELSE     
        SET @substring = @String     

    IF (LEN(@substring) > 0)
        INSERT INTO @SUBSTRINGS(Items) Values (@substring)     

    SET @String = RIGHT(@String, LEN(@String) - @idx);
END
RETURN     
END

GO
