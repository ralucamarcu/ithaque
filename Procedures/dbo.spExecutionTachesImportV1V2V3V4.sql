SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/11/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spExecutionTachesImportV1V2V3V4]	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE	 @id_tache int, @id_tache_log int, @id_utilisateur int, @path VARCHAR(500), @v1_exists BIT = 1,@id_source UNIQUEIDENTIFIER, @date_creation DATETIME = GETDATE()
		, @images_log_files_path VARCHAR(255) = NULL, @chemin_dossier varchar(255) ,@machine_traitement VARCHAR(255), @path_version VARCHAR(255) = NULL
		,@id_projet [uniqueidentifier], @chemin_dossier_projet varchar(255) , @ordre_max int
	--CREATE TABLE  #temp_DirTree (id int identity,subdirectory varchar(500),depth int,[file] int )

	DECLARE @id_tache_log_general int, @id_tache_log_details_general int
	SET @id_tache_log_general = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs tl WITH (nolock) WHERE tl.id_tache = 29 and tl.id_status = 3 and tl.date_fin is null ORDER BY tl.date_creation desc)
	SET @id_tache_log_details_general = (SELECT TOP 1 tld.id_tache_log_details FROM dbo.Taches_Logs_Details tld  WITH (nolock) WHERE tld.id_tache_log = @id_tache_log_general)


	IF EXISTS (SELECT id_tache_log FROM [dbo].[Taches_Logs] WITH (NOLOCK) WHERE id_status=4 and doit_etre_execute=1)
	BEGIN 
		EXEC spExecutionTachesImportV1V2V3V4_VerificationProcessusEnAttente

		--WAITFOR DELAY '00:00:02';
		IF EXISTS (SELECT id_tache_log FROM [dbo].[Taches_Logs] WITH (NOLOCK) WHERE id_status=4 and doit_etre_execute=1)
		BEGIN 
			EXEC spExecutionTachesImportV1V2V3V4_VerificationProcessusEnAttente
			
			--WAITFOR DELAY '00:00:02';
			IF EXISTS (SELECT id_tache_log FROM [dbo].[Taches_Logs] WITH (NOLOCK) WHERE id_status=4 and doit_etre_execute=1)
			BEGIN 
				EXEC spExecutionTachesImportV1V2V3V4_VerificationProcessusEnAttente
				
			--	WAITFOR DELAY '00:00:02';
				IF EXISTS (SELECT id_tache_log FROM [dbo].[Taches_Logs] WITH (NOLOCK) WHERE id_status=4 and doit_etre_execute=1)
				BEGIN 
					EXEC spExecutionTachesImportV1V2V3V4_VerificationProcessusEnAttente
				END
			END
		END
	END

	
	PRINT @id_tache_log_general

	EXEC dbo.spMAJTacheLogTerminee @id_tache_log_general, 1, NULL, NULL
	EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details_general, 1, NULL

	IF (SELECT j.name AS job_name FROM msdb.dbo.sysjobactivity ja 
			LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id
			JOIN msdb.dbo.sysjobs j  ON ja.job_id = j.job_id
			JOIN msdb.dbo.sysjobsteps js ON ja.job_id = js.job_id
					AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
			WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
				AND start_execution_date is not null
					AND stop_execution_date is null) <> 'Traitement V2 Import'
		AND EXISTS (SELECT * FROM Traitements_Images.dbo.ImageTraitement it WHERE it.termine = 1 AND it.id_importer_statut = 2)
	BEGIN
		EXEC msdb.dbo.sp_start_job 'Traitement V2 Import'
	END

END
GO
