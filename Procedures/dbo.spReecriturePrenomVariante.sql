SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecriturePrenomVariante]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecriturePrenomVariante] 'test Dite abcd'
	@string VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @new_string VARCHAR(255)
    CREATE TABLE #TMP_prenom (id_identity INT IDENTITY(1,1), string VARCHAR(255), id_type_identite INT)
    
    IF (@string LIKE '%Surnom%')
    BEGIN
    	SET @new_string = 
    		(CASE WHEN @string LIKE '%Surnommée %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnommée', @string), LEN(@string)), 'Surnommée', '')))
    		WHEN @string LIKE '%Surnome %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnome', @string), LEN(@string)), 'Surnome', '')))	
    		WHEN @string LIKE '%Surnom %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnom', @string), LEN(@string)), 'Surnom', '')))	
    		WHEN @string LIKE '%Surnommie %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnommie', @string), LEN(@string)), 'Surnommie', '')))	
    		WHEN @string LIKE '%Surnommee %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnommee', @string), LEN(@string)), 'Surnommee', '')))	
    		WHEN @string LIKE '%Surnommé %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnommé', @string), LEN(@string)), 'Surnommé', '')))
    		WHEN @string LIKE '%Surnomé%' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnomé', @string), LEN(@string)), 'Surnomé', '')))
    		WHEN @string LIKE '%Surnomme %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnomme', @string), LEN(@string)), 'Surnomme', '')))
    		WHEN @string LIKE '%Surnomée %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnomée', @string), LEN(@string)), 'Surnomée', '')))
    		WHEN @string LIKE '%Surnomé %' THEN RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Surnomé', @string), LEN(@string)), 'Surnomé', '')))	
    		ELSE NULL END)
    	IF @new_string IS NOT NULL
    	BEGIN
			INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 7)
		END		
	END
	
    IF (@string LIKE '% Veuve %') OR (@string LIKE 'Veuve %')
    BEGIN
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('veuve', @string), LEN(@string)), 'veuve', '')))
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 6)
    END
   
    IF (@string LIKE '% Et %')
    BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Et', @string), LEN(@string)), 'Et', '')))
		SET @string = RTRIM(LTRIM(LEFT(@string, CHARINDEX('Et', @string) - 1)))
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@string, 3)
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 3)
    END    
   
    IF (@string LIKE '% Dit %')
    BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Dit', @string), LEN(@string)), 'Dit', '')))
		SET @string = RTRIM(LTRIM(LEFT(@string, CHARINDEX('Dit', @string) - 1)))
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@string, 3)
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 3)
    END
  
    IF (@string LIKE '% dit %')
    BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('dit', @string), LEN(@string)), 'dit', '')))
		SET @string = RTRIM(LTRIM(LEFT(@string, CHARINDEX('dit', @string) - 1)))
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@string, 3)
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 3)
    END
   
    IF (@string LIKE '% Dite %')
    BEGIN		
		SET @new_string = RTRIM(LTRIM(REPLACE(SUBSTRING(@string, CHARINDEX('Dite', @string), LEN(@string)), 'Dite', '')))
		SET @string = RTRIM(LTRIM(LEFT(@string, CHARINDEX('Dite', @string) - 1)))
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@string, 3)
		INSERT INTO #TMP_prenom (string, id_type_identite) VALUES (@new_string, 3)
    END
  
    SELECT *  FROM #TMP_prenom
    DROP TABLE #TMP_prenom
    
    
END
GO
