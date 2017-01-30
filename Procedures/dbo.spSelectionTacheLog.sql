SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionTacheLog]
	-- Add the parameters for the stored procedure here
	@id_projet UNIQUEIDENTIFIER
	,@id_tache INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT TOP 1 tl.id_tache_log, tld.id_tache_log_details, tl.id_utilisateur, tl.id_source, tl.id_projet, tl.id_status AS id_status_tache_log
		, tl.date_debut AS date_debut_tache_log, tl.date_fin AS date_fin_tache_log, tl.id_tache
		, tl.erreur_message AS erreur_message_tache_log, tld.id_status AS id_status_tache_log_details
		, tld.date_debut AS date_debut_tache_log_details, tld.date_fin AS date_fin_tache_log_details
		, tld.erreur_message AS erreur_message_tache_log_details, tld.progression_pourcentage
	FROM Taches_Logs tl WITH (NOLOCK)
	INNER JOIN Taches_Logs_Details tld WITH (NOLOCK) ON tl.id_tache_log = tld.id_tache_log
	WHERE id_projet = @id_projet AND id_tache = @id_tache
	ORDER BY (CASE WHEN tl.date_creation IS NULL THEN tl.date_debut ELSE tl.date_creation END) DESC, tld.date_debut DESC
END
GO
