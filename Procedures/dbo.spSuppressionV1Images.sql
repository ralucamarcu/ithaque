SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSuppressionV1Images] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spSuppressionV1Images] @id_source = '64FE81D1-3E18-45C6-9928-A0DC64938627',@id_tache = 21, @id_utilisateur = 5
	@id_source UNIQUEIDENTIFIER
	,@id_tache INT
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = 'Ithaque App'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 DECLARE @date DATETIME = GETDATE(), @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT, @id_parent INT
    
    --insérer log pour la tâche = V1-insertion du processus V1
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
	
	
	BEGIN TRY
	BEGIN TRANSACTION spSuppressionVImages;
	print 1
			
			DELETE FROM Taches_Images_Logs
			WHERE id_image IN (SELECT id_image FROM Images WITH (NOLOCK) WHERE id_source = @id_source) AND id_tache = 7
		print 2	
			UPDATE Images
			SET id_status_version_processus = 1
			WHERE id_source = @id_source
			
			UPDATE Sources
			SET id_status_version_processus = 1
			WHERE id_source = @id_source
			
			DELETE FROM Traitements_Images.dbo.ImageTraitement WHERE id_source = @id_source
			
	COMMIT TRANSACTION spSuppressionVImages;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spSuppressionVImages;
		
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
