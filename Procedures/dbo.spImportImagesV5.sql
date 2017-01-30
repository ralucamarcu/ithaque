SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spImportImagesV5 
	-- Add the parameters for the stored procedure here
	@id_source uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @date DATETIME = GETDATE(), @id_tache_log INT, @IntegerResult INT, @id_tache_log_details INT, @id_projet [uniqueidentifier]
	SET @id_projet = (SELECT id_projet FROM dbo.Sources_Projets sp WHERE sp.id_source = @id_source)
	
	EXEC [dbo].[spInsertionTacheLog] 5, 12, @id_source, @id_projet, 'Ithaque BD'
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_projet = @id_projet AND id_utilisateur = 12 AND id_tache = 5				
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

	BEGIN TRY
	BEGIN TRANSACTION spImportImagesV5;
		INSERT INTO dbo.Taches_Images_Logs(id_image,path_origine,path_destination,id_tache,date_creation,nom_fichier_image_origine,nom_fichier_image_destination,taille_image,id_status)
		SELECT til.id_image,til.path_origine,path_destination,5 as id_tache,@date as date_creation,nom_fichier_image_origine,nom_fichier_image_destination,null as taille_image,null as id_status
		FROM dbo.Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN dbo.Images i WITH (nolock) ON til.id_image = i.id_image
		WHERE i.id_source = @id_source AND id_tache = 4

		UPDATE dbo.Images
		SET dbo.Images.id_projet = @id_projet
			, dbo.Images.id_status_version_processus = 5
		WHERE dbo.Images.id_source = @id_source AND isnull(dbo.Images.id_projet, @id_projet) <> @id_projet 

		UPDATE dbo.Sources
		SET dbo.Sources.id_status_version_processus = 5
		WHERE id_source = @id_source

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
