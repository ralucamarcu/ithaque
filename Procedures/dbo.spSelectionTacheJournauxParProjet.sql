SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spSelectionTacheJournauxParProjet 
	-- Add the parameters for the stored procedure here
	-- Test Run : spSelectionTacheJournauxParProjet '{85fb4438-6e26-4419-94bf-3cabc3c241d3}'
	@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_source UNIQUEIDENTIFIER
	SET @id_source = (SELECT TOP 1 id_source FROM Sources_Projets WHERE id_projet = @id_projet)
	
	SELECT t.nom_tache, t.description_tache, tl.id_status, tl.date_debut, tl.date_fin, tl.date_modification, tl.erreur_message
	FROM Taches_Logs tl WITH (NOLOCK)
	INNER JOIN Taches t WITH (NOLOCK) ON tl.id_tache = t.id_tache
	WHERE (tl.id_projet = @id_projet OR id_source = @id_source ) AND id_status IN (1,2) AND date_fin IS NOT NULL
END
GO
