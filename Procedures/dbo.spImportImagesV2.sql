SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: [dbo].[spImportImagesV2] 'f9ea574f-fc97-4484-8414-0c41124c4b19',5,'IthaqueApp',1, '\\10.1.0.196\bigvol\Sources\77-SEINE-ET-MARNE-ADCG\V2\'
CREATE PROCEDURE [dbo].[spImportImagesV2]
	 @id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache INT = 2
	,@path VARCHAR(500) = NULL
	,@id_tache_log int
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE  @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log_details INT, @IntegerResult INT,@id_file INT, @file_path VARCHAR(500)
			,@file_name VARCHAR(255), @file_name_path VARCHAR(255)--,@id_tache_log int
    
----insérer log pour la tâche = V1-insertion du processus V1
--	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement--,@id_tache_log
--	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
--					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
--						AND id_tache = 1					
--					ORDER BY date_creation DESC)
    UPDATE dbo.Taches_Logs
	SET dbo.Taches_Logs.id_status = 3
		,doit_etre_execute=0
		,date_debut = @date
	WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log

	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	PRINT @id_tache_log 
	
	IF @path IS NOT NULL
	BEGIN
		EXEC dbo.spImportFichiers @path = @path, @suppression_tables = 1
	END
	
	BEGIN TRY
	BEGIN TRANSACTION spImportImagesV2;

		
		INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
				,nom_fichier_image_destination)
		SELECT til.id_image , til.path_origine AS path_origine, t.FILE_PATH AS path_destination, @id_tache AS id_tache, @date AS date_creation
				, til.path_origine AS nom_fichier_image_origine, t.[FILE_NAME] AS nom_fichier_image_destination
		FROM files t  WITH (NOLOCK)
		INNER JOIN taches_images_logs til WITH (NOLOCK) on t.file_path =REPLACE(til.path_origine,'V1','V2') AND til.nom_fichier_image_origine=t.file_name
		INNER JOIN Images i  WITH (NOLOCK) ON til.id_image=i.id_image
		WHERE id_tache=1 AND id_source=@id_source

		UPDATE Images
		SET id_status_version_processus = @id_tache
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs til WITH (NOLOCK) ON i.id_image = til.id_image
		WHERE i.id_source = @id_source and id_tache=@id_tache

		UPDATE Sources
		SET id_status_version_processus = 2
		WHERE id_source = @id_source


	COMMIT TRANSACTION spImportImagesV2;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spImportImagesV1;
		
		SET @IntegerResult = -1
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResult = 1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		--EXEC dbo.spBackupV2_CreationBackUpV2ProcessusGeneral @id_source=@id_source
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
	
	
END



GO
