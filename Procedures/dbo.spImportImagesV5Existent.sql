SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 28.08.2014
-- Description:	insère une nouvelle série d'images à partir d'un certain département (processus V4) 
--				si pour ce département spécifique (id_projet) images existent déjà, il les supprime (processus de V4 est le premier à être exécuté pour les processes)
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesV5] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesV5] '29C1BDE7-D8AE-428B-BCB6-2BD0D79BA0BD', 2, null, 4,5, '\\10.1.0.196\bigvol\Projets\p37-AD85\V4\images\','\\10.1.0.196\bigvol\Projets\p37-AD85\V5\images\'
	 @id_projet UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache_v4 INT = 4
	,@id_tache_v5 INT = 5
	,@v4_general_path VARCHAR(255)
	,@v5_general_path VARCHAR(255)
	,@id_source uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log INT, @IntegerResult INT, @id_version_v5 INT
    SET @id_version_v5 = (SELECT id_status_version_processus FROM Taches WITH (NOLOCK) WHERE id_tache = @id_tache_v5)
    
	CREATE TABLE #tmpFiles([ID] [INT] NULL,[FILE_PATH] [VARCHAR](500) NULL,[FILE_NAME] [VARCHAR](128) NULL)
    INSERT INTO #tmpFiles
    SELECT * FROM Files WITH (NOLOCK) WHERE file_path LIKE '%V5%'
    
    CREATE CLUSTERED INDEX idx_id_tmpFiles ON #tmpFiles(id)
    CREATE NONCLUSTERED INDEX idx_file_path_tmpFiles ON #tmpFiles(file_path)
    
      
	--insérer log pour la tâche = V1-insertion du processus V1
	EXEC [dbo].[spInsertionTacheLog] @id_tache_v5, @id_utilisateur, NULL, @id_projet, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_projet = @id_projet AND id_utilisateur = @id_utilisateur AND id_tache = @id_tache_v5				
					ORDER BY date_creation DESC)
	--PRINT @id_tache_log 
	
	BEGIN TRY
	BEGIN TRANSACTION spImportImagesV5;
	
			INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation
				, nom_fichier_image_origine, nom_fichier_image_destination)
			SELECT tli.id_image, tli.path_destination AS path_origine, t.FILE_PATH AS path_destination, @id_tache_v5 AS id_tache
				, @date AS date_creation, tli.nom_fichier_image_destination AS nom_fichier_image_origine
				, t.[FILE_NAME] AS nom_fichier_image_destination
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN #tmpFiles t WITH (NOLOCK) ON
				REPLACE(tli.path_destination, @v4_general_path, '') 
					= REPLACE(t.FILE_PATH, @v5_general_path,'') 
				AND 
				REPLACE(tli.nom_fichier_image_destination,REVERSE(LEFT(REVERSE(tli.nom_fichier_image_destination), CHARINDEX('.', REVERSE(tli.nom_fichier_image_destination)) )),'')
					= REPLACE(t.[FILE_NAME],REVERSE(LEFT(REVERSE(t.[FILE_NAME]), CHARINDEX('.', REVERSE(t.[FILE_NAME])) )),'')			
			UPDATE Images 
			SET id_projet = @id_projet
				, id_status_version_processus = @id_version_v5
			FROM Images i WITH (NOLOCK)
			INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = tli.id_image
			WHERE id_tache = @id_tache_v5 and id_source = @id_source
			
	DROP TABLE #tmpFiles
			
	COMMIT TRANSACTION spImportImagesV5;
	
	SET @IntegerResult = 1
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spImportImagesV5;
		
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
	IF (@IntegerResult <> -1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
	END
	
	
END

GO
