SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 19/05/2015
-- Description:	Met à jour, si besoin, les champs nb de la table FichiersDatas pour les fichiers d'un traitement
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateFichiersDatasNb] 
	@id_traitement int
AS
BEGIN

	UPDATE dbo.FichiersData
	SET nb_actes=f.nb_actes, nb_images=f.nb_images, nb_individus=f.nb_individus
	--SELECT *
	FROM dbo.FichiersData fd with (nolock)
	INNER JOIN dbo.DataXml_fichiers f with (nolock) on fd.id_fichier=f.id_FichierData
	INNER JOIN dbo.Traitements t with (nolock) on f.id_traitement=t.id_traitement
	WHERE t.id_traitement=@id_traitement AND (ISNULL(t.controle_livraison_conformite, 0)=1 AND ISNULL(t.livraison_conforme, 0)=1 AND ISNULL(t.livraison_annulee, 0)=0)

END
GO
