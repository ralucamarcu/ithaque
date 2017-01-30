SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesV1Complements]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesV1Complements] '6FC626A5-222E-4D56-9F58-417702A69BE9', 5, 'Ithaque App', 22, '\\10.1.0.196\bigvol\Sources\04-ALPES-HAUTEPROVENCE-AD\V1\'
	@id_source uniqueidentifier
	,@id_utilisateur INT = 12
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache INT = 22
	,@path VARCHAR(500) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
    DECLARE @id_file INT, @file_path VARCHAR(500), @file_name VARCHAR(255), @file_name_path VARCHAR(255)
    
    --insérer log pour la tâche = V1-insertion du processus V1 complements
	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = @id_tache					
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	PRINT @id_tache_log 
	
	IF @path IS NOT NULL
	BEGIN
		EXEC dbo.spImportFichiers @path = @path, @suppression_tables = 1
	END
	
    CREATE NONCLUSTERED INDEX idx_file_path_tmpFiles ON Files(file_path)
    
     --suppressions
    DELETE FROM Files where FILE_PATH in (select path_origine from Images with (nolock) where id_source = @id_source)
    print 1
    
       
    BEGIN TRY
	BEGIN TRANSACTION spImportImagesV1;
		print 2
			
			INSERT INTO Images (id_source, path_origine, id_status_version_processus, date_creation, nom_fichier_origine)
			SELECT @id_source AS id_source, file_path AS path_origine, 1 AS id_status_version_processus, @date AS date_creation
				, [FILE_NAME] AS nom_fichier_origine
			FROM Files
			
			INSERT INTO Taches_Images_Logs(id_image, path_origine, id_tache, date_creation, nom_fichier_image_origine)
			SELECT i.id_image , i.path_origine AS path_origine, @id_tache AS id_tache, @date AS date_creation, [FILE_NAME] AS nom_fichier_image_origine
			FROM Images i WITH (NOLOCK)
			INNER JOIN Files t ON i.nom_fichier_origine = t.[file_name] AND  i.path_origine =t.file_path
		print 3	
			UPDATE Sources
			SET id_status_version_processus_complements = 1
			WHERE id_source = @id_source

			
	COMMIT TRANSACTION spImportImagesV1;
	
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
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END

END
GO
