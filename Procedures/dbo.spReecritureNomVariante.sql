SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecritureNomVariante] 
	-- Add the parameters for the stored procedure here
	 @string VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @new_string VARCHAR(255)
    CREATE TABLE #TMP_nom (id_string INT IDENTITY(1,1), string VARCHAR(255))
    
    IF (@string LIKE '%--%')
    BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('--', @string), LEN(@string)), '--', '')))
		SET @string = RTRIM(LTRIM(LEFT(@string, CHARINDEX('--', @string) - 1)))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)
		INSERT INTO #TMP_nom (string) VALUES (@string)
    END
    
   	IF @string LIKE 'ST %'
	BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(@string, 'ST ', 'SAINT ')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)		 
	END
	IF @string LIKE 'ST-%'
	BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(@string, 'ST-', 'SAINT-')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)
	END
	IF @string LIKE 'STE %'
	BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(@string, 'STE ', 'SAINTE')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)
	END
	IF @string LIKE 'STE-%'
	BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(@string, 'STE-', 'SAINTE-')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)
	END
	IF (@string LIKE '% (DE)')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' (DE)', '')))	
		SET @new_string = 'DE ' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% (D'')')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' (D'')', '')))	
		SET @new_string = 'D''' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% DE')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' DE', '')))	
		SET @new_string = 'DE ' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% D''')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' D''', '')))	
		SET @new_string = 'D''' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% (DE LA)')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' (DE LA)', '')))
		SET @new_string = 'DE LA ' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'DE LA ', 'LA ')	))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% (DE L'')')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, ' (DE L'')', '')	))
		SET @new_string = 'DE L''' + @string
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'DE L''', 'L''')	))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	
	IF (@string LIKE 'D''%')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'D''', '')))			
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'DE %')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'DE ', '')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'DU %')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'DU ', '')))	
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'LA %')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'LA ', '')))	
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'LE %')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'LE ', '')))	
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'L''%')
	BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(@new_string, 'L''', '')))
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'DE LA %')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, 'DE ', '')))	
		SET @new_string = REPLACE(@string, 'LA ', '')
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE 'DE L''%')
	BEGIN		
		SET @string = RTRIM(LTRIM(REPLACE(@string, 'DE ', '')))	
		SET @new_string = REPLACE(@string, 'L''', '')
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)
	END
	
	IF (@string LIKE '% DITE %')
	BEGIN
		SET @new_string = RTRIM(LTRIM(LEFT(@STRING, CHARINDEX('DITE', @STRING) - 1)))		
		SET @string = RTRIM(LTRIM(REPLACE(SUBSTRING(@STRING, CHARINDEX('DITE', @STRING), LEN(@STRING)), 'DITE', '')))		
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% DIT %')
	BEGIN
		SET @new_string = RTRIM(LTRIM(LEFT(@STRING, CHARINDEX('DIT', @STRING) - 1)	))	
		SET @string = RTRIM(LTRIM(REPLACE(SUBSTRING(@STRING, CHARINDEX('DIT', @STRING), LEN(@STRING)), 'DIT', '')))		
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% OU %')
	BEGIN
		SET @new_string = RTRIM(LTRIM(LEFT(@STRING, CHARINDEX('OU', @STRING) - 1)))		
		SET @string = RTRIM(LTRIM(REPLACE(SUBSTRING(@STRING, CHARINDEX('OU', @STRING), LEN(@STRING)), 'OU', '')))		
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END
	IF (@string LIKE '% ET %')
	BEGIN
		SET @new_string = RTRIM(LTRIM(LEFT(@STRING, CHARINDEX('ET', @STRING) - 1)))		
		SET @string = RTRIM(LTRIM(REPLACE(SUBSTRING(@STRING, CHARINDEX('ET', @STRING), LEN(@STRING)), 'ET', '')))		
		INSERT INTO #TMP_nom (string) VALUES (@string)
		INSERT INTO #TMP_nom (string) VALUES (@new_string)	
	END	
	
	SELECT * FROM #TMP_nom
	DROP TABLE #TMP_nom
	
END
GO
