SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 11.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImportGeneralProjetExistent] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportGeneralProjet]  '\\10.1.0.196\bigvol\Projets\p37-AD85\V4\,\\10.1.0.196\bigvol\Projets\p37-AD85\V5\,\\10.1.0.196\bigvol\Projets\p37-AD85\V65\','85', 'VENDEE'	,
	 @paths_import VARCHAR(MAX) 
	,@paths_to_exclude VARCHAR(MAX) = NULL
	,@id_projet UNIQUEIDENTIFIER
	,@id_departement VARCHAR(50) 
	,@nom_departement VARCHAR(255)
	,@nom_projet VARCHAR(255) 
	,@taille_dossier_GB INT 
	,@image_type_code VARCHAR(5)
	,@id_source VARCHAR(MAX)-- with comma for multiple sources	
	,@id_prestataire INT
	,@id_utilisateur INT 
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache_v3 INT 
	,@id_tache_v4 INT  
	,@id_tache_v5 INT  
	,@id_tache_v6 INT  	
	,@v3_general_path VARCHAR(255) 
	,@v4_general_path VARCHAR(255) 
	,@v5_general_path VARCHAR(255)
	,@v6_general_path VARCHAR(255)
	--,@metadata_logs bit = 1 -- 1- only xml logs; 0 - all metadata files
	--,@id_tache_v6 INT  = 6
	--,@path_general_source VARCHAR(100) = '\\10.1.0.196\bigvol\Projets\'
	--,@path_general_v1 varchar(255)
	--,@path_v2_logs_jpg bit  = 1
	--,@rc bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @path_current VARCHAR(255), @id_path_current INT
		, @id_tache_log_v4 INT, @id_tache_log_v5 INT, @id_tache_log_v6 INT
	DECLARE @id_file_metadata INT, @current_date DATETIME = GETDATE(), @IntegerResultV2 INT, @IntegerResultV3 INT
	
	DECLARE @sqlCommand1 NVARCHAR(2000) = ''
	CREATE TABLE #tmp(oldpath VARCHAR(500), oldname VARCHAR(255), newpath VARCHAR(500), newname VARCHAR(255), id_file_metadata INT)
	CREATE TABLE #tmp1(id INT IDENTITY(1,1) NOT NULL, PATH VARCHAR(255))
	CREATE TABLE #tmp2(id_projet UNIQUEIDENTIFIER)
	CREATE TABLE #tmp3(id_tache_log INT)
	CREATE TABLE #tmp4(id INT IDENTITY(1,1) NOT NULL, PATH VARCHAR(255))
	
	
	--import all files for a certain project	
	INSERT INTO #tmp1
	EXEC dbo.spCalculSplit @paths_import
		
	SELECT TOP 1 @path_current = [PATH],@id_path_current = id  FROM #tmp1 ORDER BY id	
	SET @sqlCommand1 = @sqlCommand1 + ' exec [spImportFichiers] ''' + CAST(@path_current AS NVARCHAR(255)) + ''', 1' + CHAR(10) + CHAR(13)
    EXEC sp_executesql @sqlCommand1
    PRINT @sqlCommand1
    
    DELETE FROM #tmp1 WHERE id = @id_path_current
    SET @path_current = NULL
    SET @id_path_current = NULL
    SET @sqlCommand1 = ''
    WHILE (SELECT COUNT(*) FROM #tmp1) > 0
    BEGIN
		SELECT TOP 1 @path_current = [PATH],@id_path_current = id  FROM #tmp1 ORDER BY id	
		SET @sqlCommand1 = @sqlCommand1 + ' exec [spImportFichiers] ''' + CAST(@path_current AS NVARCHAR(255)) + ''', 0' + CHAR(10) + CHAR(13)
		EXEC sp_executesql @sqlCommand1
		PRINT @sqlCommand1
		
		DELETE FROM #tmp1 WHERE id = @id_path_current
		SET @path_current = NULL
		SET @id_path_current = NULL
		SET @sqlCommand1 = ''
		
    END
    
    IF @paths_to_exclude IS NOT NULL
    BEGIN	
		INSERT INTO #tmp4
		EXEC dbo.spCalculSplit @paths_to_exclude
		SET @path_current = NULL
		SET @id_path_current = NULL
		WHILE (SELECT COUNT(*) FROM #tmp4) > 0
		BEGIN
			SELECT TOP 1 @path_current = [PATH],@id_path_current = id  FROM #tmp4 ORDER BY id	
			DELETE FROM Files WHERE FILE_PATH LIKE @path_current + '%'
			
			SET @path_current = NULL
			SET @id_path_current = NULL
			DELETE FROM #tmp4 WHERE id = @id_path_current

		END
	END
	
	DELETE FROM Files 
	WHERE REVERSE(LEFT(REVERSE([FILE_NAME]), CHARINDEX('.', REVERSE([FILE_NAME])) -1)) NOT IN ('jpg', 'jpeg', 'tiff', 'tif', 'bmp')
	
	
    CREATE CLUSTERED INDEX idx_id ON files(id)
	CREATE NONCLUSTERED INDEX idx_file_path ON files(file_path)    
    PRINT '------------------------------------Import Files Finished-------------------------------------------------------------------'
    
	--EXEC [spInsertionProjet] @id_departement = @id_departement, @nom_departement = @nom_departement, @id_prestataire = @id_prestataire
	--,@taille_dossier_GB = @taille_dossier_GB, @image_type_code = @image_type_code, @nom_projet = @nom_projet,@id_source = @id_source
	--set @id_projet = (select top 1 id_project from Projects with (nolock) order by date_creation desc)
	--print @id_projet

	UPDATE Projets
	SET id_departement = @id_departement
		,nom_departement = @nom_departement
		,nom_projet_dossier = @nom_projet
		,taille_dossier_GB = @taille_dossier_GB
		,id_status_version_processus = @id_tache_v4
	WHERE id_projet = @id_projet

	PRINT '------------------------------------New Project Inserted-------------------------------------------------------------------'

	
	--v4 images
	INSERT INTO #tmp3 (id_tache_log)
	EXEC [spImportImagesV4Existent] @id_projet = @id_projet,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
		,@id_tache_v3 = @id_tache_v3, @id_tache_v4 = @id_tache_v4, @v3_general_path = @v3_general_path, @v4_general_path = @v4_general_path
		,@id_source = @id_source
	SET @id_tache_log_v4 = (SELECT id_tache_log FROM #tmp3)
	PRINT @id_tache_log_v4
	TRUNCATE TABLE #tmp3
	PRINT '------------------------------------Import V4 Images Finished-------------------------------------------------------------------'
	
	
	INSERT INTO #tmp3 (id_tache_log)
	EXEC [spImportImagesV5Existent] @id_projet = @id_projet,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
		,@id_tache_v4 = @id_tache_v4, @id_tache_v5 = @id_tache_v5, @v4_general_path = @v4_general_path, @v5_general_path = @v5_general_path
		,@id_source = @id_source
	SET @id_tache_log_v5 = (SELECT id_tache_log FROM #tmp3)
	PRINT @id_tache_log_v5
	TRUNCATE TABLE #tmp3
	PRINT '------------------------------------Import V5 Images Finished-------------------------------------------------------------------'

	INSERT INTO #tmp3 (id_tache_log)
	EXEC [spImportImagesV6Existent] @id_projet = @id_projet,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
		,@id_tache_v5 = @id_tache_v5, @id_tache_v6 = @id_tache_v6, @v5_general_path = @v5_general_path, @v6_general_path = @v6_general_path
		,@id_source = @id_source
	SET @id_tache_log_v6 = (SELECT id_tache_log FROM #tmp3)
	PRINT @id_tache_log_v6
	TRUNCATE TABLE #tmp3
	PRINT '------------------------------------Import V6 Images Finished-------------------------------------------------------------------'


	IF (ISNULL(@id_tache_log_v4, -1) <> -1 )
	BEGIN
		EXEC [spMAJTachesImagesLogsStatutsGen] @id_projet = @id_projet, @id_tache = @id_tache_v4
		UPDATE Projets
		SET id_status_version_processus = @id_tache_v4
		WHERE id_projet = @id_projet
		
		UPDATE Sources
		SET id_status_version_processus = @id_tache_v4
		WHERE id_source = @id_source
	END
	IF (ISNULL(@id_tache_log_v5, -1) <> -1 )
	BEGIN
		EXEC [spMAJTachesImagesLogsStatutsGen] @id_projet = @id_projet, @id_tache = @id_tache_v5
		UPDATE Projets
		SET id_status_version_processus = @id_tache_v5
		WHERE id_projet = @id_projet
		
		UPDATE Sources
		SET id_status_version_processus = @id_tache_v5
		WHERE id_source = @id_source
	END
	IF (ISNULL(@id_tache_log_v6, -1) <> -1 )
	BEGIN
		EXEC [spMAJTachesImagesLogsStatutsGen] @id_projet = @id_projet, @id_tache = @id_tache_v6
		UPDATE Projets
		SET id_status_version_processus = @id_tache_v6
		WHERE id_projet = @id_projet
		
		UPDATE Sources
		SET id_status_version_processus = @id_tache_v6
		WHERE id_source = @id_source
	END
		
	PRINT '------------------------------------MAJ Images Finished-------------------------------------------------------------------'

	EXEC spMAJActesImagesProjetsExistent  @v4_general_path = @v4_general_path, @id_projet = @id_projet
	PRINT '------------------------------------MAJ Actes : id_image Finished-------------------------------------------------------------------'
	
	--drop table #tmp1
	DROP TABLE #tmp2
	DROP TABLE #tmp3
	DROP TABLE #tmp4
	
END



GO
