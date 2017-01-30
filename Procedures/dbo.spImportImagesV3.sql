SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modification date: 15/09/2015
--		Description -> add '\' to the new path
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesV3] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesV3] '9C96BC57-DFC7-4C42-AE51-422B0D9528FD',12, 'Ithaque BD' ,  3,  '\\10.1.0.196\bigvol\Sources\85-VENDEE-RC\V3\images\' , '\\10.1.0.196\bigvol\Sources\85-VENDEE-RC\workspace\resources\reorganization_step\imagesLog\', 1105
	 @id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache_v3 INT = 3
	,@v3_general_path VARCHAR(255) 
	,@images_log_files_path VARCHAR(255) 
	,@id_tache_log INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_file_metadata INT, @path_general_v1 VARCHAR(255), @id_tache_log_v3 INT, @IntegerResultV3 INT
		, @current_date DATETIME, @path_general_v2 VARCHAR(255), @id_tache_log_details int
	SET @current_date = GETDATE()
	CREATE TABLE #tmp(oldpath VARCHAR(500), oldname VARCHAR(255), newpath VARCHAR(500), newname VARCHAR(255), id_file_metadata INT)
	
	--insérer log pour la tâche = V3-import du processus V3
	--EXEC [dbo].[spInsertionTacheLog] @id_tache_v3, @id_utilisateur, @id_source, NULL, @machine_traitement
	--SET @id_tache_log_v3 = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
	--						WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
	--							AND id_tache = @id_tache_v3					
	--						ORDER BY date_creation DESC)

	UPDATE Taches_Logs
	SET id_status=3
	   ,doit_etre_execute=0
	   ,date_debut = @current_date
	WHERE id_tache_log=@id_tache_log

	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	
	SET @path_general_v1 = REPLACE(@v3_general_path, 'V3\images', 'V1')
	SET @path_general_v2 = REPLACE(@v3_general_path, 'V3\images', 'V2')
	
	PRINT @v3_general_path
	PRINT @images_log_files_path
	EXEC [spImportFichiers] @v3_general_path, 1
	EXEC [spImportFichiers] @images_log_files_path, 0
	
	DELETE FROM Files 
	WHERE REVERSE(LEFT(REVERSE([FILE_NAME]), CHARINDEX('.', REVERSE([FILE_NAME])) +0)) NOT IN ('.jpg', '.jpeg', '.tiff', '.tif', '.bmp', '.xml')
	
    CREATE CLUSTERED INDEX idx_id ON files(id)
	CREATE NONCLUSTERED INDEX idx_file_path ON files(file_path)
	

	EXEC spImportFilesMetadataLogs @id_source = @id_source
	
--#region - analyse log files
PRINT 'tmp_begin'
	DECLARE cursor_1 CURSOR FOR
	SELECT  id_file_metadata FROM FilesMetadata WITH (NOLOCK) WHERE id_source = @id_source
	OPEN cursor_1
	FETCH NEXT FROM cursor_1 INTO @id_file_metadata
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		INSERT INTO #tmp
		EXEC spCalculMetadataFileXML @id_file_metadata
		FETCH NEXT FROM cursor_1 INTO @id_file_metadata
	END
PRINT 'tmp_end'
	CLOSE cursor_1
	DEALLOCATE cursor_1
--#endregion	

	CREATE TABLE #images_tmp (id_image UNIQUEIDENTIFIER, path_nom_origine VARCHAR(400), id_file_metadata INT)
	INSERT INTO #images_tmp(id_image, path_nom_origine)
	SELECT id_image,  REPLACE(rtrim(ltrim(path_origine)) + rtrim(ltrim(nom_fichier_origine)), '/', '\')  AS path__nom_origine
	FROM Images WITH (NOLOCK)
	WHERE id_source = @id_source	
	
	ALTER TABLE #tmp ADD path_general_v1_oldpath VARCHAR(255)
	
	UPDATE #tmp
	SET path_general_v1_oldpath = REPLACE(@path_general_v1 + oldpath, '/', '\')		
	
	UPDATE #images_tmp
	SET id_file_metadata = t.id_file_metadata
	FROM #images_tmp i 
	INNER JOIN #tmp t ON path_nom_origine = path_general_v1_oldpath
		
	UPDATE Images
	SET id_file_metadata = t.id_file_metadata
	FROM Images i WITH (NOLOCK)
	INNER JOIN #images_tmp t  ON i.id_image = t.id_image
	WHERE i.id_source = @id_source
	
--#region - insert v3 taches_images_logs
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION [spImportImagesV3Images];
				
	PRINT 'inside tran'
					
	IF ISNULL((SELECT COUNT(*) FROM Taches_Images_Logs WITH (NOLOCK)
		WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source)
		AND id_tache = 3),0)  = 0		
	BEGIN		
		PRINT 'inserturi'			
		INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
			, nom_fichier_image_destination)
		SELECT til.id_image, path_destination, @v3_general_path + REPLACE(newpath, '/', '\')
			, @id_tache_v3 AS id_tache,@current_date AS date_creation, oldname AS nom_fichier_image_origine,[newname] AS nom_fichier_image_destination
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
		INNER JOIN #tmp t  ON rtrim(ltrim(til.nom_fichier_image_destination)) = rtrim(ltrim(t.oldname)) 
		WHERE s.id_source = @id_source
			AND  id_tache in (2,7,9)
			AND til.path_destination + rtrim(ltrim(nom_fichier_image_destination)) = REPLACE(@path_general_v2 + t.oldpath, '/', '\')
		GROUP BY til.id_image, path_destination, @v3_general_path + REPLACE(newpath, '/', '\')
			,oldname ,[newname]	

		UPDATE 	Taches_Images_Logs	
		SET Taches_Images_Logs.path_destination=path_destination+'\'
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
		WHERE id_tache=3 AND i.id_source=@id_source AND path_destination NOT LIKE '%\'
									
		UPDATE Images
		SET id_status_version_processus = @id_tache_v3
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs til WITH (NOLOCK) ON i.id_image = til.id_image
		WHERE i.id_source = @id_source AND til.id_tache = @id_tache_v3
	END
	ELSE
	IF (SELECT COUNT(*) FROM Taches_Images_Logs WITH (NOLOCK)
		WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source)
		AND id_tache = 3)  > 0		
	BEGIN
		INSERT INTO Images (id_source, path_origine, id_status_version_processus, date_creation, nom_fichier_origine)
		SELECT @id_source AS id_source, file_path AS path_origine, 3 AS id_status_version_processus, @current_date AS date_creation
			, [FILE_NAME] AS nom_fichier_origine
		FROM Files f WITH (NOLOCK)
		LEFT JOIN Taches_Images_Logs tli WITH (NOLOCK) ON tli.path_destination = f.FILE_PATH AND tli.nom_fichier_image_destination = f.[FILE_NAME]
			AND id_tache = 3
		INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image		 
		WHERE i.id_image IS NULL  
			AND tli.id_image IS NULL
			AND tli.id_tache = 3
			AND [FILE_NAME] LIKE '%.jpg'
		
		INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
			, nom_fichier_image_destination)
		SELECT til.id_image, path_destination, @v3_general_path + REPLACE(newpath, '/', '\')
			, @id_tache_v3 AS id_tache,@current_date AS date_creation, oldname AS nom_fichier_image_origine,[newname] AS nom_fichier_image_destination
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
		INNER JOIN #tmp t  ON til.nom_fichier_image_origine = t.oldname 
		WHERE s.id_source = @id_source
			AND  id_tache  in (2,7,9)
			AND til.path_destination + nom_fichier_image_destination = REPLACE(@path_general_v2 + t.oldpath, '/', '\')
			AND DATEADD(dd,0,DATEDIFF(dd,0, i.date_creation)) >= DATEADD(dd,0,DATEDIFF(dd,0, @current_date))
		GROUP BY til.id_image, path_destination, @v3_general_path + REPLACE(newpath, '/', '\')
			,oldname ,[newname]			

		UPDATE 	Taches_Images_Logs	
		SET Taches_Images_Logs.path_destination=path_destination+'\'
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
		WHERE id_tache=3 AND i.id_source=@id_source AND path_destination NOT LIKE '%\'
	END
				
	COMMIT TRANSACTION [spImportImagesV3Images];
		
	SET @IntegerResultV3 = 1 
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessageV3 NVARCHAR(4000);
		DECLARE @ErrorSeverityV3 INT;
		DECLARE @ErrorStateV3 INT;

		ROLLBACK TRANSACTION [spImportImagesV3Images];
				
		SET @IntegerResultV3 = -1
				
		SELECT @ErrorMessageV3 = ERROR_MESSAGE(),
		@ErrorSeverityV3 = ERROR_SEVERITY(),
		@ErrorStateV3 = ERROR_STATE();
		
		RAISERROR (@ErrorMessageV3,@ErrorSeverityV3, @ErrorStateV3 );
	END CATCH;
			
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResultV3 = 1)
	BEGIN

	 --#region - finalisation
		EXEC spMAJTachesImagesLogsStatuts @id_source =  @id_source,@id_tache_v1 = 1,@id_tache_v2 = 2,@id_tache_v3 = @id_tache_v3
		EXEC spMAJImagesAttributesImport @id_source = @id_source, @path_general_v3 = @v3_general_path, @rc=0
	 --#endregion

		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		UPDATE Sources
		SET id_status_version_processus = @id_tache_v3
		WHERE id_source = @id_source
		END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v3, 2, NULL, @ErrorMessageV3
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessageV3
	END

	DROP TABLE #tmp
	DROP TABLE #images_tmp	
END
--#endregion




END
GO
