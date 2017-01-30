SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 27.08.2014
-- Description:	mettra à jour une certaine tâche à son statut de finition. 
--			Dans le cas où la tâche a terminé par un échec le paramètre sera également mis à la jour avec le chemin de le log d'erreur, 
--			ou le message de l'erreur, ou il restera nulle (par défaut)
--			id_status_version_processus -> dbo.Version_Processus_Statuts.id_status (v1, v2, v3, etc)
--			@id_status -> dbo.Taches_Statuts.id_status (terminé avec succès/terminé avec échec/en cours)
-- =============================================
CREATE PROCEDURE [dbo].[spMAJTacheLogTerminee] 
	-- Add the parameters for the stored procedure here
	 @id_tache_log INT
	,@id_status INT
	,@path_erreur_log VARCHAR(500) = NULL
	,@erreur_message VARCHAR(800) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @date DATETIME = GETDATE(), @IntegerResult INT, @id_tache INT
	SET @id_tache = (SELECT id_tache FROM Taches_Logs WHERE id_tache_log = @id_tache_log)
	BEGIN TRY
	BEGIN TRANSACTION [spMAJTacheLogTerminee];
		UPDATE dbo.Taches_Logs
		SET id_status = @id_status
			,path_erreur_log = (CASE WHEN @path_erreur_log IS NOT NULL THEN @path_erreur_log ELSE path_erreur_log END)
			,erreur_message = (CASE WHEN @erreur_message IS NOT NULL THEN @erreur_message ELSE erreur_message END)
			,date_fin = (CASE WHEN @id_status <> 3 THEN @date ELSE date_fin END)
			,date_modification = @date
		WHERE id_tache_log = @id_tache_log
		
		IF (@id_tache = 10)
		BEGIN
			EXEC msdb.dbo.sp_update_job @job_name='AEL MAJ Progression',@enabled = 0
		END
	
	COMMIT TRANSACTION [spMAJTacheLogTerminee];
	
	SET @IntegerResult = 1 
	
	RETURN
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [spMAJTacheLogTerminee];
		
		SET @IntegerResult = -1
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
END

GO
