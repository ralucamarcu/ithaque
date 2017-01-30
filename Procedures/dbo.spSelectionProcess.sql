SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionProcess]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE	 @id_tache int
			,@id_tache_log int
			,@id_utilisateur int
			,@machine_traitement VARCHAR(255)
			,@path VARCHAR(500)
			,@v1_exists BIT = 1
			,@id_source UNIQUEIDENTIFIER

	 SELECT TOP 1 @id_tache_log=id_tache_log ,@id_tache=id_tache--,@id_source=id_source,@id_utilisateur=id_utilisateur,@machine_traitement=machine_traitement
	 FROM [dbo].[Taches_Logs] WITH (NOLOCK) WHERE id_status=4 and doit_etre_execute=1 ORDER BY ordre
	
	IF (@id_tache=1)
		BEGIN
			EXEC msdb.dbo.sp_start_job '[Traitement V1 Import]'
		END
	IF(@id_tache=2)
		BEGIN
			EXEC msdb.dbo.sp_start_job '[V2 Import Avant Traitement]'
		END
	IF(@id_tache=3)
		BEGIN
			EXEC msdb.dbo.sp_start_job '[Traitement V3 Import]'
		END
	IF(@id_tache=4)
		BEGIN
			EXEC msdb.dbo.sp_start_job '[Traitement V4 Import]'
		END



END
GO
