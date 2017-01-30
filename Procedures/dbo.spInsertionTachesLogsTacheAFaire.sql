SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionTachesLogsTacheAFaire]
	-- Add the parameters for the stored procedure here
	@id_source [uniqueidentifier]
	,@id_projet [uniqueidentifier] = NULL
	,@id_tache [int]
	,@id_utilisateur [int] = 12
	,@machine_traitement varchar(255) = 'Ithaque App'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ordre [int], @date [datetime]
	SET @date = getdate()
	--SET @ordre = (CASE WHEN EXISTS (SELECT * FROM dbo.Taches_Logs tl WITH (NOLOCK) WHERE tl.id_status = 4)
	--			THEN (SELECT max(ordre) FROM dbo.Taches_Logs tl WITH (NOLOCK) WHERE tl.id_status = 4) + 1
	--			ELSE 1 END)

	IF NOT EXISTS (SELECT * FROM dbo.Taches_Logs tl WHERE tl.id_source = @id_source AND tl.id_tache = @id_tache AND tl.id_status = 4)
	BEGIN
		INSERT INTO dbo.Taches_Logs (id_utilisateur,id_source,id_projet,id_status,machine_traitement,date_debut,date_creation,id_tache,ordre,doit_etre_execute)
		VALUES (@id_utilisateur, @id_source, @id_projet, 4, @machine_traitement, @date, @date, @id_tache, null,0)
	END
END
GO
