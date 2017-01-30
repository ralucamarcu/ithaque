SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spLivraisonsSelectionCommentairesParId
	-- Add the parameters for the stored procedure here
	-- Test Run : spLivraisonsSelectionCommentairesParId 406
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT commentaire, u.nom + ' ' + u.prenom AS nom_utilisateur, c.date_creation, p.nom AS nom_projet
		,t.nom AS nom_livraison, t.id_traitement AS id_livraison
	FROM Commentaires c WITH (NOLOCK)
	INNER JOIN Traitements t WITH (NOLOCK) ON c.id_objet = t.id_traitement
	INNER JOIN Utilisateurs u WITH (NOLOCK) ON c.id_utilisateur = u.id_utilisateur
	LEFT JOIN Projets p WITH (NOLOCK) ON c.id_projet = p.id_projet
	WHERE type_objet = 'traitement' AND id_objet = @id_traitement
END
GO
