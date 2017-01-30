SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <20/08/2015>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spBackupV2_CreationBackUpV2ProcessusGeneral]
	 @id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT=12
	,@machine_traitement VARCHAR(255) ='Ithaque BD'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @id_tache int =31,@id_tache_log_details int,@id_tache_log int

	--insérer log pour la tâche = Backup du dossier V2
	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 31					
					ORDER BY date_creation DESC)    
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

	EXEC msdb.dbo.sp_update_job @job_name='BackupV2_ComparisonTailleDossir',@enabled = 0

	EXEC [dbo].[spBackupV2CreationScriptFile] @id_source=@id_source,@id_tache_log=@id_tache_log,@id_tache_log_details=@id_tache_log_details
	

END
GO
