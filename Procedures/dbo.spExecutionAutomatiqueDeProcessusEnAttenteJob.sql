SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spExecutionAutomatiqueDeProcessusEnAttenteJob]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @id_tache_log int, @id_tache_log_details int
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs tl WITH (nolock) WHERE tl.id_tache = 29 ORDER BY tl.date_creation desc)
	SET @id_tache_log_details = (SELECT TOP 1 tld.id_tache_log_details FROM dbo.Taches_Logs_Details tld  WITH (nolock) WHERE tld.id_tache_log = @id_tache_log)
	
	WHILE EXISTS (SELECT id_tache_log FROM [dbo].[Taches_Logs] WITH(NOLOCK) WHERE id_status=4 and doit_etre_execute=1)-- and id_tache in (1,2,3,4,17,9))
	BEGIN
		EXEC [Ithaque].[dbo].[spExecutionTachesImportV1V2V3V4]
	END

	EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
	EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL

	

END

GO
