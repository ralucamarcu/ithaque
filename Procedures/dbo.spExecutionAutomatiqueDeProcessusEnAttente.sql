SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spExecutionAutomatiqueDeProcessusEnAttente]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @id_tache_log INT, @id_tache_log_details int
	EXEC [dbo].[spInsertionTacheLog] 29, 12, null, NULL, 'Ithaque BD'
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_utilisateur = 12 AND id_tache = 29					
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	
	exec msdb.dbo.sp_start_job 'ExecuterDesProcessusQuiSontEnAttente'


END

GO
