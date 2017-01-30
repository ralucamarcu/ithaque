SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 28.08.2014
-- Description:	insère une nouvelle série d'images à partir d'un certain département (processus V1) 
--				si pour ce département spécifique (id_source) images existent déjà, il les supprime (processus de V1 est le premier à être exécuté)
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesV1] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesV1] 'A14BCDEB-0A65-46C2-BFC8-37439CC4356E', 12,'Ithaque App',1,'\\10.1.0.196\bigvol\Sources\78-YVELINES-AD_TEST-AD-AD\V1\', 877,1
	 @id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@id_tache INT = 1
	,@path VARCHAR(500) = NULL
	,@id_tache_log int
	,@v1_exists BIT = 1
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log_details INT, @IntegerResult INT,@nom_format_dossier varchar (155),@path_v2 varchar(500)
    DECLARE @id_file INT, @file_path VARCHAR(500), @file_name VARCHAR(255), @file_name_path VARCHAR(255),@id_tache_log_v2 int, @chemin_dossier_general varchar(255)

    --insérer log pour la tâche = V1-insertion du processus V1
	--EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement--,@id_tache_log
	--SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
	--				WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
	--					AND id_tache = 1					
	--				ORDER BY date_creation DESC)

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
 
    --suppressions
    IF EXISTS(SELECT * FROM Images WITH (NOLOCK) WHERE id_source = @id_source)
    BEGIN
		DELETE FROM Taches_Images_Logs WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source)
		DELETE FROM Images WHERE id_source = @id_source
    END
		
	BEGIN TRY
	BEGIN TRANSACTION spImportImagesV1;
			
			INSERT INTO Images (id_source, path_origine, id_status_version_processus, date_creation, nom_fichier_origine)
			SELECT @id_source AS id_source, file_path AS path_origine, 1 AS id_status_version_processus, @date AS date_creation
				, [FILE_NAME] AS nom_fichier_origine
			FROM Files
			
			INSERT INTO Taches_Images_Logs(id_image, path_origine, id_tache, date_creation, nom_fichier_image_origine)
			SELECT i.id_image , i.path_origine AS path_origine, @id_tache AS id_tache, @date AS date_creation, [FILE_NAME] AS nom_fichier_image_origine
			FROM Files t
			INNER JOIN Images i WITH (NOLOCK) ON i.nom_fichier_origine = t.[file_name] AND  i.path_origine =t.file_path
	
			UPDATE Sources
			SET id_status_version_processus = 1
			WHERE id_source = @id_source

			SET @chemin_dossier_general = (SELECT s.chemin_dossier_general from dbo.Sources s WHERE s.id_source = @id_source)
			--EXEC spMAJDossierTaille @chemin = @chemin_dossier_general, @id_projet = null, @id_source = @id_source
	
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

		SELECT @nom_format_dossier=nom_format_dossier FROM Sources WITH (NOLOCK) WHERE id_source=@id_source
		IF NOT EXISTS (SELECT libelle FROM [Traitements_Images].[dbo].[ImageTraitement] WITH (NOLOCK) where libelle like @nom_format_dossier+'%')
		BEGIN
			WAITFOR DELAY '00:02';

			SET @id_tache_log_v2 = (SELECT top 1 tl.id_tache_log from dbo.Taches_Logs tl WHERE tl.id_source = @id_source AND tl.id_tache = 17 and tl.id_status = 4 ORDER BY tl.date_creation DESC)
			EXEC Traitements_Images.dbo.[ImportSources] @id_source =@id_source, @id_utilisateur = @id_utilisateur, @id_tache_log = @id_tache_log_v2
		END
		ELSE 
		BEGIN
			CREATE TABLE  #temp_DirTree (id int identity,subdirectory varchar(500),depth int,[file] int)
			EXEC [dbo].[spInsertionTacheLog] @id_tache =2,@id_utilisateur =12,@id_source =@id_source,@id_projet = NULL, @machine_traitement =@machine_traitement
			SET @id_tache_log_v2 = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
									WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur AND id_tache = 2 AND id_status = 3			
									ORDER BY date_creation DESC)
			
			SET @path_v2= (SELECT REPLACE (@path,'\V1\','\V2\'))

			INSERT INTO #temp_DirTree([subdirectory],[depth],[file])
			EXEC xp_dirtree @path_v2, 3, 1
			IF EXISTS (SELECT * FROM #temp_DirTree WHERE depth IN (2,3))
			BEGIN	
				EXEC [spImportImagesV2]  @id_source =@id_source,@id_utilisateur =@id_utilisateur,@machine_traitement = @machine_traitement,@id_tache = 2,@path=@path_v2,@id_tache_log=@id_tache_log_v2
			END
			ELSE
			BEGIN
				UPDATE dbo.Taches_Logs
				SET  dbo.Taches_Logs.id_status = 2
					,dbo.Taches_Logs.erreur_message = 'V2 n''existent pas physiquement sur le serveur'
				WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log_v2
			END
			TRUNCATE TABLE #temp_DirTree	
			
			UPDATE taches_logs
			SET id_status = 2
				,erreur_message = 'V2 Import Arborescence a ete fait (id_tache = 2)'
			WHERE id_source = @id_source and id_tache = 17 and id_status = 4
		END
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
END

GO
