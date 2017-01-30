SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 01.09.2014
-- Description:	utilisant le paramètre @path qui normalement avoir la valeur '\\ 10.1.0.196 \ bigvol \ Sources \' 
--			tous les sous-dossiers (toutes les sources) seront insérées dans la base de données
-- =============================================
CREATE PROCEDURE [dbo].[spImportSources]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportSources] '\\10.1.0.196\bigvol\Sources\'
	@path VARCHAR(255) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @sqlCommand1 NVARCHAR(2000) = '', @id_departement VARCHAR(5), @nom_departement VARCHAR(255), @code_image_type VARCHAR(5)
	

	CREATE TABLE tmp_sources_insert(subdirectory VARCHAR(255), DEPTH INT, [FILE] BIT)
	
	SET @sqlCommand1 = @sqlCommand1 + 'insert into tmp_sources_insert '  +  CHAR(13) + CHAR(10)  
	SET @sqlCommand1 = @sqlCommand1 + 'EXEC master.sys.xp_dirtree ''' + CAST(@path AS NVARCHAR(255)) + ''',1,1;'
	PRINT @sqlCommand1
	EXEC sp_executesql @sqlCommand1
	
	DELETE FROM tmp_sources_insert 
	WHERE [FILE] = 1 OR subdirectory NOT LIKE '[0-9][0-9]-%-%'
	
	INSERT INTO dbo.Images_Types (image_type_code)
	SELECT RTRIM(RIGHT(subdirectory, CHARINDEX('-', REVERSE(subdirectory)) - 1)) AS image_type_code
	FROM tmp_sources_insert 
	GROUP BY RTRIM(RIGHT(subdirectory, CHARINDEX('-', REVERSE(subdirectory)) - 1))
	
	INSERT INTO Sources (id_departement, nom_departement, nom_format_dossier, id_status_version_processus)
	SELECT SUBSTRING(subdirectory,1,2), SUBSTRING (LEFT(subdirectory, CHARINDEX((RTRIM(RIGHT(subdirectory, CHARINDEX('-', REVERSE(subdirectory)) - 1))), subdirectory) - 2), 4, LEN (LEFT(subdirectory, CHARINDEX((RTRIM(RIGHT(subdirectory, CHARINDEX('-', REVERSE(subdirectory)) - 1))), subdirectory) - 2)))
			,subdirectory, 1 AS id_status_version_processus
	FROM tmp_sources_insert tsi WITH (NOLOCK)
	INNER JOIN Images_Types it WITH (NOLOCK) ON RTRIM(RIGHT(tsi.subdirectory, CHARINDEX('-', REVERSE(tsi.subdirectory)) - 1)) = it.image_type_code
	
	INSERT INTO dbo.Sources_Images_Types(id_image_type, id_source)
	SELECT it.id_image_type, s.id_source
	FROM tmp_sources_insert tsi WITH (NOLOCK)
	INNER JOIN Images_Types it WITH (NOLOCK) ON RTRIM(RIGHT(tsi.subdirectory, CHARINDEX('-', REVERSE(tsi.subdirectory)) - 1)) = it.image_type_code
	INNER JOIN Sources s WITH (NOLOCK) ON tsi.subdirectory = s.nom_format_dossier
	
	SELECT * FROM tmp_sources_insert
	DROP TABLE tmp_sources_insert
END

GO
