SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> select * from ael_parametres where principal = 1
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Start_Jobs]
	-- Add the parameters for the stored procedure here	
	-- Test Run : [AEL_Start_Jobs] 'AEL Traitement XML Finalize Importation', 14, 5, '5BC4606A-A0F3-46A9-9542-91D457F271E7'
	@job_name VARCHAR(255)
	,@id_tache INT
	,@id_utilisateur INT
	,@id_projet UNIQUEIDENTIFIER
	,@machine_traitement VARCHAR(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	IF (@job_name = 'AEL Check Processes Management')
	BEGIN
		EXEC [AEL_Enable_Job_Processes_Management]
	END
	
	IF @machine_traitement IS NULL
	BEGIN
		SET @machine_traitement = 'Ithaque Application'
	END
	
	DECLARE @id_source UNIQUEIDENTIFIER, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
	SET @id_source = (SELECT TOP 1 id_source FROM Sources_Projets WHERE id_projet = @id_projet)
	
	IF (EXISTS (SELECT * FROM Taches_Logs WHERE id_projet = @id_projet AND id_tache = 10 AND id_status = 3)
		AND EXISTS (SELECT * FROM Taches_Logs WHERE id_projet = @id_projet AND id_tache = @id_tache AND date_fin IS NOT NULL))
	BEGIN
		print 1
		SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
						WHERE id_source = @id_source AND id_tache = @id_tache					
						ORDER BY date_creation DESC)
						
		UPDATE Taches_Logs
		SET id_status = 3
			,date_fin = NULL
		WHERE id_tache_log = @id_tache_log
		
		EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
		SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
						WHERE id_tache_log = @id_tache_log					
						ORDER BY date_debut DESC)
	END
	ELSE
	BEGIN
		print 2
		EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement
		SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
						WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur AND id_tache = @id_tache					
						ORDER BY date_creation DESC)
		EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
		SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
						WHERE id_tache_log = @id_tache_log					
						ORDER BY date_debut DESC)
	END
	BEGIN TRY
	BEGIN TRANSACTION spStartJobs;	
	
			EXEC msdb.dbo.sp_start_job @job_name ;
			
	COMMIT TRANSACTION spImportImagesV1;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spStartJobs;
		
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
