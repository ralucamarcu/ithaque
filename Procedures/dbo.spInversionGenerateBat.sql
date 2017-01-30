SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInversionGenerateBat]
	-- Add the parameters for the stored procedure here
	-- Test Run : spInversionGenerateBat '\\10.1.0.196\bigvol\Projets\p99-61-ORNE-AD\workspace\scripts', '61-ORNE-AD', '/CERCUEIL/CERCUEIL_1893-1902/N/source_principale', 1, -1, 5, 'BB3CE68F-8A07-4E4A-B5AA-CB4095C1F264'
	 @file_path VARCHAR(255)
	,@depart VARCHAR(255) 
	,@rep VARCHAR(255) 
	,@img_first INT
	,@img_last INT
	,@id_utilisateur INT
	,@id_source UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--PRINT '@rep = ' + @rep

    -- Insert statements for procedure here
	DECLARE @date_script DATETIME = GETDATE(), @rep_fold VARCHAR(255), @txt VARCHAR(MAX), @file_bat_name VARCHAR(255), @file_bat_name_part VARCHAR(255)
		, @contor INT = @img_first, @contor_end INT, @nom_image_initial VARCHAR(255) , @nom_image_final VARCHAR(255)
		, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT, @cnt INT = 0
	CREATE TABLE #tmp_bat_read (id INT IDENTITY(1,1), line VARCHAR(255))
	--Début Modif FR
	/*
	CREATE TABLE #tmp_images_log (id_log INT, id_image UNIQUEIDENTIFIER, nom_image VARCHAR(255))
	*/
	CREATE TABLE #tmp_images_log (id_log INT, id_image UNIQUEIDENTIFIER, nom_image VARCHAR(255), path_destination VARCHAR(1024))
	--Fin Modif FR
	CREATE TABLE #tmp_images_log_asc (id INT IDENTITY(1,1), nom_image VARCHAR(255))
	CREATE TABLE #tmp_images_log_desc (id INT IDENTITY(1,1), nom_image VARCHAR(255))
	
	--Début Modif FR
	/*
	INSERT INTO #tmp_images_log (id_log, id_image, nom_image)
	SELECT id_log, tli.id_image, nom_fichier_image_destination
	*/
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Début SELECT Taches_Images_Logs V3 de la source',0,1) WITH NOWAIT;
	INSERT INTO #tmp_images_log (id_log, id_image, nom_image, path_destination)
	SELECT id_log, tli.id_image, nom_fichier_image_destination, path_destination
	--Fin Modif FR
	FROM  Taches_Images_Logs tli WITH (NOLOCK) 
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
	WHERE id_source = @id_source AND id_tache = 3
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Fin SELECT Taches_Images_Logs V3 de la source',0,1) WITH NOWAIT;
	
	--Début Modif FR
	/*
	DELETE FROM #tmp_images_log
	WHERE nom_image NOT LIKE '%' + REPLACE(@rep, '/', '\')
	*/
	--PRINT 'DELETE FROM #tmp_images_log WHERE path_destination NOT LIKE '''%'''' + REPLACE(@rep, '/', '\')
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Début DELETE Taches_Images_Logs V3 qui ne correspondent pas au répertoire',0,1) WITH NOWAIT;
	DELETE FROM #tmp_images_log
	WHERE path_destination NOT LIKE '%' + REPLACE(@rep, '/', '\') + '%'
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Fin DELETE Taches_Images_Logs V3 qui ne correspondent pas au répertoire',0,1) WITH NOWAIT;
	--Fin Modif FR
	
	SET @file_bat_name_part = REPLACE(RIGHT(@rep, LEN(@rep)-1), '/source_principale', '')	
	SET @file_bat_name = RIGHT(@file_bat_name_part, LEN(@file_bat_name_part) - PATINDEX ('%/%', @file_bat_name_part))
	SET @file_bat_name = 'BAT_rename' + @file_bat_name + '-' + CONVERT(VARCHAR, @date_script, 112) + '.txt'
	SET @file_bat_name = REPLACE(@file_bat_name, '/', '')
	PRINT @file_bat_name	
	SET @rep_fold = '.\IMAGES\EC' + REPLACE(REPLACE(@rep, '/', '\'), 'source_principale', '')
	
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Début spInsertionTacheLog ',0,1) WITH NOWAIT;
	EXEC [dbo].[spInsertionTacheLog] 20, @id_utilisateur, @id_source, NULL, 'Ithaque App'
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Fin spInsertionTacheLog ',0,1) WITH NOWAIT;
	SET @id_tache_log= (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
							WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
								AND id_tache = 20					
							ORDER BY date_creation DESC)
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Début spInsertionTacheLogDetails ',0,1) WITH NOWAIT;
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Fin spInsertionTacheLogDetails ',0,1) WITH NOWAIT;
					
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Début écriture fichier bat ',0,1) WITH NOWAIT;
	BEGIN TRY
	BEGIN TRANSACTION [InversionGenerateBat];

				SET @txt = 'cd "' + @rep_fold+ '" ' + CHAR(13) + CHAR(10)
				SET @txt = @txt + 'mkdir "source_principale_temp" '  + CHAR(13) + CHAR(10)
				EXECUTE spWriteStringToFile @txt, @file_path,@file_bat_name
								
				--INSERT INTO #tmp_images_log (id_log, id_image, nom_image)
				--SELECT id_log, id_image, nom_fichier_image_destination
				--FROM  Taches_Images_Logs WITH (NOLOCK) 
				--WHERE path_destination LIKE '%' + REPLACE(@rep, '/', '\') AND id_tache = 3
				
				INSERT INTO #tmp_images_log_asc
				SELECT nom_image FROM #tmp_images_log ORDER BY nom_image ASC
				
				INSERT INTO #tmp_images_log_desc
				SELECT nom_image FROM #tmp_images_log ORDER BY nom_image DESC
				
				IF (@img_last = -1)
				BEGIN
					SET @contor_end = (SELECT COUNT(*) FROM #tmp_images_log_asc)
				END
				ELSE
				BEGIN
					SET @contor_end = @img_last
				END
				SET @cnt = 0
				WHILE @contor <= @contor_end
				BEGIN
					SET @nom_image_initial = (SELECT nom_image FROM #tmp_images_log_asc WHERE id = @contor)
					--SET @nom_image_final = (SELECT nom_image FROM #tmp_images_log_desc WHERE id = @contor)
					SET @nom_image_final = (SELECT nom_image FROM #tmp_images_log_asc WHERE id = @contor_end-@cnt)
					SET @txt = 'copy ".\source_principale\' + @nom_image_initial + '" ".\source_principale_temp\' + @nom_image_final + '"' + CHAR(13) + CHAR(10)
					EXECUTE spWriteStringToFile @txt, @file_path,@file_bat_name
					SET @contor = @contor +1
					SET @cnt = @cnt + 1
				END

				SET @txt = 'copy /Y source_principale_temp\* source_principale '  + CHAR(13) + CHAR(10)
				SET @txt = @txt + 'rd /s /q "source_principale_temp" '  + CHAR(13) + CHAR(10)
				EXECUTE spWriteStringToFile @txt, @file_path,@file_bat_name
				
	COMMIT TRANSACTION [InversionGenerateBat];
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'Fin écriture fichier bat ',0,1) WITH NOWAIT;
		
	SET @IntegerResult = 1 
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [InversionGenerateBat];
				
		SET @IntegerResult = -1
				
		SELECT @ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
		
		RAISERROR (@ErrorMessage,@ErrorSeverity, @ErrorState );
	END CATCH;
			
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResult = 1)
	BEGIN
		INSERT INTO #tmp_bat_read(line)
		SELECT line FROM Dbo.uftReadfileAsTable(@file_path,@file_bat_name)
		IF (SELECT TOP 1 line FROM #tmp_bat_read ORDER BY id DESC) LIKE 'rd%'
		BEGIN
			EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
			EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		END
		ELSE
		BEGIN
			SET @ErrorMessage = 'Problème avec les informations dans le fichier généré. Vérifiez le fichier : ' + @file_bat_name
			EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
			EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
		END
		
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
	
	DROP TABLE #tmp_bat_read 
	DROP TABLE #tmp_images_log 
	DROP TABLE #tmp_images_log_asc 
	DROP TABLE #tmp_images_log_desc

END
GO
