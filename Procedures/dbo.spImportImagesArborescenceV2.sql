SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 28.08.2014
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesArborescenceV2] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesArborescenceV2] '1E0C01C4-24C6-41B3-915F-35BFED4985FB', 2
	@id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache INT = 2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log INT, @IntegerResult INT
    DECLARE @id_file INT, @file_path VARCHAR(500), @file_name VARCHAR(255), @file_name_path VARCHAR(255)
		, @id_status_version_processus INT, @chemin_dossier_general varchar(255)
    
    SET @id_status_version_processus =(SELECT id_status_version_processus FROM Taches WHERE id_tache = @id_tache)
    
    SET @chemin_dossier_general = (SELECT chemin_dossier_general FROM Sources where id_source = @id_source)
    SET @chemin_dossier_general = @chemin_dossier_general + 'V2\'
    
    EXEC dbo.spImportFichiers @path = @chemin_dossier_general, @suppression_tables = 1
    
	CREATE TABLE #tmpFiles([ID] [INT] NULL,[FILE_PATH] [VARCHAR](500) NULL,[FILE_NAME] [VARCHAR](128) NULL)
    INSERT INTO #tmpFiles
    SELECT * FROM Files WITH (NOLOCK) WHERE file_path LIKE '%V2%' 
    
    CREATE CLUSTERED INDEX idx_id_tmpFiles ON #tmpFiles(id)
    CREATE NONCLUSTERED INDEX idx_file_path_tmpFiles ON #tmpFiles(file_path)
    
  
	--insérer log pour la tâche = V1-insertion du processus V1
	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = @id_tache					
					ORDER BY date_creation DESC)
	PRINT @id_tache_log 
	
	BEGIN TRY
	BEGIN TRANSACTION spImportImagesArborescenceV2;			
			
			INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation
				, nom_fichier_image_origine, nom_fichier_image_destination)
			SELECT i.id_image , i.path_origine AS path_origine, t.file_path AS path_destination, @id_tache AS id_tache, @date AS date_creation
				, nom_fichier_image_origine AS nom_fichier_image_origine, [FILE_NAME] AS nom_fichier_image_destination
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN #tmpFiles t ON tli.nom_fichier_image_origine = t.[file_name] 
				AND  REPLACE(tli.path_origine, 'V1', 'V2') =t.file_path
			WHERE i.id_source = @id_source
			group by i.id_image , i.path_origine, t.file_path, nom_fichier_image_origine, [FILE_NAME]
			
			UPDATE Images
			SET id_status_version_processus = @id_status_version_processus
			FROM Images i WITH (NOLOCK)
			INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = tli.id_image AND tli.id_tache = @id_tache
			WHERE id_source = @id_source
				

	DROP TABLE #tmpFiles
			
	COMMIT TRANSACTION spImportImagesArborescenceV2;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spImportImagesArborescenceV2;
		
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
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
	END
	
	
END

GO
