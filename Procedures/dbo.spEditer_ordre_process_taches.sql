SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[spEditer_ordre_process_taches]
--	Test Run: [dbo].[spEditer_ordre_process_taches] '9C96BC57-DFC7-4C42-AE51-422B0D9528FD',1,1,null,null,null
	 @id_source uniqueidentifier
	,@id_tache [int]
	,@ordre int = NULL
	,@id_projet [uniqueidentifier] = NULL
	,@id_utilisateur [int] = 12
	,@machine_traitement varchar(255) = 'Ithaque App'

AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @date datetime=GETDATE()

	IF EXISTS (SELECT * FROM dbo.Taches_Logs tl WHERE tl.id_status IN (1,2) AND tl.doit_etre_execute = 0 AND tl.ordre IS NOT NULL)
	BEGIN
		UPDATE Taches_Logs
		SET Taches_Logs.ordre = NULL
		WHERE id_status IN (1,2) AND doit_etre_execute = 0 AND ordre IS NOT NULL
	END
	
	IF (@ordre IS NOT NULL)
	BEGIN 
		UPDATE dbo.Taches_Logs
		SET ordre=ordre+1
		WHERE ordre>=@ordre

		UPDATE dbo.Taches_Logs
		SET dbo.Taches_Logs.doit_etre_execute = 1
			,dbo.Taches_Logs.ordre = @ordre
		WHERE dbo.Taches_Logs.id_source = @id_source AND dbo.Taches_Logs.id_tache = @id_tache AND dbo.Taches_Logs.id_status = 4
	END
	ELSE
	BEGIN
		SET @ordre = (CASE WHEN EXISTS (SELECT * FROM dbo.Taches_Logs tl WITH (NOLOCK) WHERE tl.id_status = 4 AND tl.ordre IS NOT null)
				THEN (SELECT max(ordre) FROM dbo.Taches_Logs tl WITH (NOLOCK) WHERE tl.id_status = 4 AND tl.ordre IS NOT null) + 1
				ELSE 1 END)

		UPDATE dbo.Taches_Logs
		SET dbo.Taches_Logs.doit_etre_execute = 1
			,dbo.Taches_Logs.ordre = @ordre
		WHERE dbo.Taches_Logs.id_source = @id_source AND dbo.Taches_Logs.id_tache = @id_tache AND dbo.Taches_Logs.id_status = 4
	END

END


GO
