SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 27.08.2014
-- Description:	insérer une nouvelle tâche log, et retourne l'id de la nouvelle tâche log ou -1 si l'insertion a échoué
--			la tâche peut être associé à une source ou d'un projet; 
--			deux paramètres @id_source et @id_projet sont mis à null(défaut), donc en fonction de ce que le groupe est associé, 
--			un seul paramètre sera rempli et l'autre restera par défaut (null)
--			id_status_version_processus -> dbo.Version_Processus_Statuts.id_status (v1, v2, v3, etc)
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionTacheLog] 
	-- Add the parameters for the stored procedure here
	@id_tache INT
	,@id_utilisateur INT
	,@id_source UNIQUEIDENTIFIER = NULL
	,@id_projet UNIQUEIDENTIFIER = NULL
	,@machine_traitement VARCHAR(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_tache_log INT
    IF @machine_traitement IS NULL
    BEGIN
		SET @machine_traitement = 'Ithaque Application'
    END
    IF @id_source IS NULL
    BEGIN
		SET @id_source = (SELECT TOP 1 id_source FROM Sources_Projets WHERE id_projet = @id_projet)
    END
    IF @id_projet IS NULL
    BEGIN
		SET @id_projet = (SELECT TOP 1 id_projet FROM Sources_Projets WHERE id_source = @id_source)
    END
    
    BEGIN TRY
	BEGIN TRANSACTION [spInsertionTacheLog];
		INSERT INTO dbo.Taches_Logs( id_tache, id_utilisateur, id_source, id_projet, id_status
			, machine_traitement, date_debut, date_creation)	
		VALUES (@id_tache, @id_utilisateur, @id_source, @id_projet, 3
			, @machine_traitement, @date, @date)
		
		SET @id_tache_log = SCOPE_IDENTITY() 
		
		IF (@id_tache = 10)
		BEGIN
			EXEC msdb.dbo.sp_update_job @job_name='AEL MAJ Progression',@enabled = 1
		END
		
	COMMIT TRANSACTION [spInsertionTacheLog];
	
	SELECT @id_tache_log AS IntegerResult
	
	RETURN
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [spInsertionTacheLog];
		
		SELECT -1 AS IntegerResult
		
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
