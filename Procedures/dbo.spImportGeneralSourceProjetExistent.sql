SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 11.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImportGeneralSourceProjetExistent] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportGeneralSourceProjetExistent]  '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V1\AD85\ETAT CIVIL\,\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V1\AD85\RECENSEMENTS\,\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V2\ETAT CIVIL\,\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V2\RECENSEMENTS\,\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V3\,\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\workspace\resources\reorganization_step\imagesLog\','85', 'VENDEE'	,1,125, 'RC', 'Recensement'
	 @paths_import VARCHAR(MAX)
	,@paths_to_exclude VARCHAR(MAX) = NULL
	,@id_departement VARCHAR(50)
	,@nom_departement VARCHAR(255)
	,@id_fournisseur INT
	,@taille_dossier_GB INT
	,@image_type_code VARCHAR(5)
	,@image_type VARCHAR(50)
	,@metadata_logs BIT = 1 -- 1- only xml logs; 0 - all metadata files
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache_v1 INT 
	,@id_tache_v2 INT 
	,@id_tache_v3 INT 
	,@path_general_source VARCHAR(100)
	,@path_general_v3 VARCHAR(255)
	,@path_general_v2 VARCHAR(255)
	,@path_general_v1 VARCHAR(255)
	,@path_v2_logs_jpg BIT  = 1
	,@rc BIT = 0
	,@id_projet UNIQUEIDENTIFIER 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @path_current VARCHAR(255), @id_path_current INT,@id_source UNIQUEIDENTIFIER
		, @id_tache_log_v1 INT, @id_tache_log_v2 INT, @id_tache_log_v3 INT
	DECLARE @id_file_metadata INT, @current_date DATETIME = GETDATE(), @IntegerResultV2 INT, @IntegerResultV3 INT
	
	DECLARE @sqlCommand1 NVARCHAR(2000) = ''
	CREATE TABLE #tmp(oldpath VARCHAR(500), oldname VARCHAR(255), newpath VARCHAR(500), newname VARCHAR(255), id_file_metadata INT)
	CREATE TABLE #tmp1(id INT IDENTITY(1,1) NOT NULL, PATH VARCHAR(255))
	CREATE TABLE #tmp2(id_source UNIQUEIDENTIFIER)
	CREATE TABLE #tmp3(id_tache_log INT)
	CREATE TABLE #tmp4(id INT IDENTITY(1,1) NOT NULL, PATH VARCHAR(255))


	
	--import all files for a certain source	
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
			
			DELETE FROM #tmp4 WHERE id = @id_path_current
			
			SET @path_current = NULL
			SET @id_path_current = NULL

		END
	END
	
	DELETE FROM Files 
	WHERE REVERSE(LEFT(REVERSE([FILE_NAME]), CHARINDEX('.', REVERSE([FILE_NAME])) -1)) NOT IN ('jpg', 'jpeg', 'tiff', 'tif', 'bmp', 'xml')
	
    CREATE CLUSTERED INDEX idx_id ON files(id)
	CREATE NONCLUSTERED INDEX idx_file_path ON files(file_path)
	
    
    PRINT '------------------------------------Import Files Finished-------------------------------------------------------------------'
    DECLARE @date DATETIME = GETDATE(), @nom_format VARCHAR(255) = '', @id_image_type INT
    CREATE TABLE #tmp_source (id_source UNIQUEIDENTIFIER)
    
   
	--INSERT INTO #tmp2
	--EXEC [spInsertionSource] @id_departement = @id_departement, @nom_departement = @nom_departement, @id_fournisseur = @id_fournisseur
	--,@taille_dossier_GB = @taille_dossier_GB, @image_type_code = @image_type_code, @image_type = @image_type
	--SET @id_source = (SELECT TOP 1 id_source FROM Sources WHERE nom_departement = @nom_departement ORDER BY date_creation DESC)
	--PRINT @id_source
	IF EXISTS (SELECT * FROM dbo.Images_Types WHERE image_type_code = @image_type_code)
    BEGIN
		SET @id_image_type = (SELECT id_image_type FROM dbo.Images_Types WHERE image_type_code = @image_type_code)
		UPDATE Images_Types
		SET image_type = @image_type
		WHERE image_type_code = @image_type_code
    END
    ELSE
    BEGIN
		INSERT INTO dbo.Images_Types  (image_type, image_type_code)
		VALUES (@image_type, @image_type_code)
		SET @id_image_type = SCOPE_IDENTITY()
    END
    BEGIN TRY
	BEGIN TRANSACTION spInsertionSource;
		SET @nom_format = @id_departement + '-' + @nom_departement + '-' + @image_type_code
		INSERT INTO dbo.Sources (id_departement, nom_departement, id_fournisseur, taille_dossier_GB, id_status_version_processus
			, date_creation, nom_format_dossier)
		OUTPUT inserted.id_source
		INTO #tmp_source
		VALUES (@id_departement, @nom_departement, @id_fournisseur, @taille_dossier_GB, 1
			, @date, @nom_format)
		SET @id_source = (SELECT id_source FROM #tmp_source)
		INSERT INTO dbo.Sources_Images_Types (id_image_type, id_source)
		VALUES (@id_image_type, @id_source)
	COMMIT TRANSACTION spInsertionSource;
	--SELECT @id_source AS id_source
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;
		ROLLBACK TRANSACTION spInsertionSource;		
		SELECT '-1' AS id_source		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
	DROP TABLE #tmp_source
	
	INSERT INTO Sources_Projets(id_projet, id_source)
	VALUES (@id_projet, @id_source)
    PRINT '------------------------------------Import Source Finished-------------------------------------------------------------------'



	
	--metadata files
	IF (@metadata_logs = 1)
	BEGIN
		EXEC spImportFilesMetadataLogs @id_source = @id_source --33min
		PRINT 1
	END
	ELSE
	BEGIN
		EXEC spImportFileMetadata @id_source = @id_source
	END
	
	PRINT '------------------------------------Import Metadata Files Finished-------------------------------------------------------------------'

	
	--v1 images
	INSERT INTO #tmp3
	EXEC [spImportImagesV1] @id_source = @id_source,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement,@id_tache = @id_tache_v1
	SET @id_tache_log_v1 = (SELECT id_tache_log FROM #tmp3)
	PRINT @id_tache_log_v1
	
	PRINT '------------------------------------Import V1 Images Finished-------------------------------------------------------------------'

	
	--v2,v3 images
	IF (SELECT id_status FROM Taches_Logs WITH (NOLOCK) WHERE id_tache_log = @id_tache_log_v1) = 1
	BEGIN
			IF EXISTS(SELECT * FROM Taches_Images_Logs til WITH (NOLOCK) 
					INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
					WHERE id_source = @id_source AND til.id_tache = @id_tache_v2)
			BEGIN
				DELETE FROM Taches_Images_Logs 
				WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source) 
					AND id_tache = @id_tache_v2
			END
			
			IF EXISTS(SELECT * FROM Taches_Images_Logs til WITH (NOLOCK) 
					INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
					WHERE id_source = @id_source AND til.id_tache = @id_tache_v3)
			BEGIN
				DELETE FROM Taches_Images_Logs 
				WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source) 
					AND id_tache = @id_tache_v3
			END
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
					CLOSE cursor_1
					DEALLOCATE cursor_1	
			BEGIN TRY
			BEGIN TRANSACTION [spImportImagesV2Images];
				--insérer log pour la tâche = V2-import du processus V2
				EXEC [dbo].[spInsertionTacheLog] @id_tache_v2, @id_utilisateur, @id_source, NULL, @machine_traitement
				SET @id_tache_log_v2 = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
							WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
								AND id_tache = @id_tache_v2					
							ORDER BY date_creation DESC)
						
				IF (@path_v2_logs_jpg = 1)
				BEGIN
					INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
						, nom_fichier_image_destination)
					SELECT til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') AS path_destination
						, @id_tache_v2 AS id_tache, @current_date AS date_creation, oldname AS nom_fichier_image_origine ,[oldname] AS nom_fichier_image_destination
					FROM Taches_Images_Logs til WITH (NOLOCK)
					INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
					INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
					INNER JOIN #tmp t WITH (NOLOCK) ON til.nom_fichier_image_origine = t.oldname
						AND REPLACE(til.path_origine + til.nom_fichier_image_origine, '/', '\') = REPLACE(@path_general_v1 + t.oldpath, '/', '\')
					WHERE s.id_source = @id_source 
						AND id_tache = @id_tache_v1 
						AND  oldpath NOT LIKE '%DUPLICATEDIMAGES%'
					GROUP BY til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') 
						, oldname ,[oldname]
						
					UPDATE Images
					SET id_file_metadata = t.id_file_metadata
					FROM Images i WITH (NOLOCK)
					INNER JOIN #tmp t ON REPLACE(i.path_origine + i.nom_fichier_origine, '/', '\') 
						= REPLACE(@path_general_v1 + t.oldpath, '/', '\')
					WHERE id_source = @id_source
				END
				ELSE
				IF (@path_v2_logs_jpg = 0)
				BEGIN
					INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
						, nom_fichier_image_destination)
					SELECT til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') AS path_destination
						, @id_tache_v2 AS id_tache, @current_date AS date_creation, oldname AS nom_fichier_image_origine ,[oldname] AS nom_fichier_image_destination
					FROM Taches_Images_Logs til WITH (NOLOCK)
					INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
					INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
					INNER JOIN #tmp t WITH (NOLOCK) ON til.nom_fichier_image_origine = t.oldname
						AND REPLACE(til.path_origine, '/', '\') = REPLACE(@path_general_v1 + t.oldpath, '/', '\')
					WHERE s.id_source = @id_source 
						AND id_tache = @id_tache_v1 
						AND  oldpath NOT LIKE '%DUPLICATEDIMAGES%'
					GROUP BY til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') 
						, oldname ,[oldname]
						
					UPDATE Images
					SET id_file_metadata = t.id_file_metadata
					FROM Images i WITH (NOLOCK)
					INNER JOIN #tmp t ON REPLACE(i.path_origine, '/', '\') = REPLACE(@path_general_v1 + t.oldpath, '/', '\')
					WHERE id_source = @id_source
				END
				
				INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
					, nom_fichier_image_destination)
				SELECT til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') AS path_destination
					, @id_tache_v2 AS id_tache, @current_date AS date_creation, oldname AS nom_fichier_image_origine ,[oldname] AS nom_fichier_image_destination
				FROM Taches_Images_Logs til WITH (NOLOCK)
				INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
				INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
				INNER JOIN #tmp t WITH (NOLOCK) ON til.nom_fichier_image_origine = t.oldname
					--and replace(til.path_origine + til.nom_fichier_image_origine, '/', '\') = replace(@path_general_v1 + t.oldpath, '/', '\')
				WHERE s.id_source = @id_source 
					AND id_tache = @id_tache_v1 
					AND  oldpath LIKE '%DUPLICATEDIMAGES%'
				GROUP BY til.id_image, til.path_origine,  @path_general_source + s.nom_format_dossier + '\V2\' + REPLACE(oldpath, '/', '\') 
					, oldname ,[oldname]
				
				UPDATE Images
				SET id_status_version_processus = 2
				FROM Images i WITH (NOLOCK)
				INNER JOIN Taches_Images_Logs til WITH (NOLOCK) ON i.id_image = til.id_image
				WHERE i.id_source = @id_source AND til.id_tache = @id_tache_v2

				
			COMMIT TRANSACTION [spImportImagesV2Images];
		
			SET @IntegerResultV2 = 1 
		
			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessageV2 NVARCHAR(4000);
				DECLARE @ErrorSeverityV2 INT;
				DECLARE @ErrorStateV2 INT;

				ROLLBACK TRANSACTION [spImportImagesV2Images];
				
				SET @IntegerResultV2 = -1
				
				SELECT @ErrorMessageV2 = ERROR_MESSAGE(),@ErrorSeverityV2 = ERROR_SEVERITY(),@ErrorStateV2 = ERROR_STATE();

				RAISERROR (@ErrorMessageV2,@ErrorSeverityV2, @ErrorStateV2);
			END CATCH;
			
			--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
			IF (@IntegerResultV2 = 1)
			BEGIN
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v2, 1, NULL, NULL
				UPDATE Sources
				SET id_status_version_processus = @id_tache_v2
				WHERE id_source = @id_source
			END
			ELSE
			BEGIN
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v2, 2, NULL, @ErrorMessageV2
			END
				
			
			BEGIN TRY
			BEGIN TRANSACTION [spImportImagesV3Images];
				
				--insérer log pour la tâche = V3-import du processus V3
				EXEC [dbo].[spInsertionTacheLog] @id_tache_v3, @id_utilisateur, @id_source, NULL, @machine_traitement
				SET @id_tache_log_v3 = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
							WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
								AND id_tache = @id_tache_v3					
							ORDER BY date_creation DESC)
				
				
				INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
					, nom_fichier_image_destination)
				SELECT til.id_image, path_destination, @path_general_source + s.nom_format_dossier + '\V3\images\' + REPLACE(newpath, '/', '\')
					, @id_tache_v3 AS id_tache,@current_date AS date_creation, oldname AS nom_fichier_image_origine,[newname] AS nom_fichier_image_destination
				FROM Taches_Images_Logs til WITH (NOLOCK)
				INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
				INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
				INNER JOIN #tmp t WITH (NOLOCK) ON til.nom_fichier_image_origine = t.oldname 
				WHERE s.id_source = @id_source 
					AND  id_tache = @id_tache_v2
					AND  oldpath NOT LIKE '%DUPLICATEDIMAGES%'
					AND til.path_destination = REPLACE(@path_general_v2 + t.oldpath, '/', '\')
					AND til.path_destination NOT LIKE  '%DUPLICATEDIMAGES%'
				GROUP BY til.id_image, path_destination, @path_general_source + s.nom_format_dossier + '\V3\images\' + REPLACE(newpath, '/', '\')
					,oldname ,[newname]

				INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
					, nom_fichier_image_destination)
				SELECT til.id_image, path_destination, @path_general_source + s.nom_format_dossier + '\V3\images\' + REPLACE(newpath, '/', '\')
					, @id_tache_v3 AS id_tache,  @current_date AS date_creation, oldname AS nom_fichier_image_origine,[newname] AS nom_fichier_image_destination
				FROM Taches_Images_Logs til WITH (NOLOCK)
				INNER JOIN images i WITH (NOLOCK) ON til.id_image = i.id_image
				INNER JOIN sources s WITH (NOLOCK) ON i.id_source = s.id_source
				INNER JOIN #tmp t WITH (NOLOCK) ON til.nom_fichier_image_origine = t.oldname --and til.path_origine like '%' + t.oldpath
				WHERE s.id_source = @id_source AND id_tache = @id_tache_v2 AND til.path_destination LIKE  '%DUPLICATEDIMAGES%'
					--and til.path_destination = replace(@path_general_v2 + t.oldpath, '/', '\')
					AND  oldpath LIKE '%DUPLICATEDIMAGES%'
					
				GROUP BY til.id_image, path_destination, @path_general_source + s.nom_format_dossier + '\V3\images\' + REPLACE(newpath, '/', '\')
					,oldname ,[newname]				
								
				UPDATE Images
				SET id_status_version_processus = 3
				FROM Images i WITH (NOLOCK)
				INNER JOIN Taches_Images_Logs til WITH (NOLOCK) ON i.id_image = til.id_image
				WHERE i.id_source = @id_source AND til.id_tache = @id_tache_v3
				
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
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v3, 1, NULL, NULL
				UPDATE Sources
				SET id_status_version_processus = @id_tache_v3
				WHERE id_source = @id_source
			END
			ELSE
			BEGIN
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v3, 2, NULL, @ErrorMessageV3
			END

		DROP TABLE #tmp
		
		DELETE FROM Images WHERE id_source = @id_source AND nom_fichier_origine LIKE '%.zip'
		
		--supprimer les dublons
		--;WITH cte AS (
		--  SELECT tli.id_image, tli.path_origine, tli.path_destination, tli.id_tache, tli.nom_fichier_image_origine
		--	, tli.nom_fichier_image_destination, tli.id_status ,
		--	 ROW_NUMBER() OVER(PARTITION BY tli.id_image, tli.path_origine, tli.path_destination, tli.id_tache
		--			, tli.nom_fichier_image_origine, tli.nom_fichier_image_destination, tli.id_status ORDER BY tli.id_image) AS [rn]
		--  FROM Taches_Images_Logs tli WITH (NOLOCK)
		--  INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
		--  WHERE i.id_source = @id_source
		  
		--)
		--DELETE FROM cte WHERE [rn] > 1

		
    PRINT '------------------------------------Import V2/V3 Images Finished-------------------------------------------------------------------'
		
		
		IF (ISNULL(@id_tache_log_v2, -1) <> -1 AND ISNULL(@id_tache_log_v3, -1) <> -1 )
		BEGIN
			EXEC spMAJTachesImagesLogsStatuts @id_source =  @id_source,@id_tache_v1 = @id_tache_v1,@id_tache_v2 = @id_tache_v2,@id_tache_v3 = @id_tache_v3
			EXEC spMAJImagesAttributesImport @id_source = @id_source, @path_general_v3 = @path_general_v3, @rc=@rc
		END
		
	PRINT '------------------------------------MAJ Images Finished-------------------------------------------------------------------'

		IF EXISTS (SELECT * FROM Images WITH (NOLOCK) WHERE id_source = @id_source AND id_status_version_processus = 1)
		BEGIN				
			EXEC spImportImagesArborescenceV2 @id_source =  @id_source, @id_utilisateur = @id_utilisateur
				,@machine_traitement = @machine_traitement, @id_tache = @id_tache_v2
		END
		
		UPDATE Taches_Images_Logs
		SET id_status = 1
		FROM Taches_Images_Logs tli WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
		WHERE i.id_source = @id_source AND tli.id_tache = 2 AND tli.id_status IS NULL
	
	PRINT '------------------------------------V2 Existing Images Finished-------------------------------------------------------------------'
	


	END
	
	--drop table #tmp1
	DROP TABLE #tmp2
	DROP TABLE #tmp3
	DROP TABLE #tmp4
	
END
GO
