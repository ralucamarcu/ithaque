SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 10/09/2012
-- Description:	Calcul des statistiques par commune
-- =============================================
CREATE PROCEDURE [dbo].[calculStatsCommunesRC]
	-- Add the parameters for the stored procedure here
	@id_traitement integer
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT OFF;

	--Nb actes par communes
	SELECT geonameid_acte, lieu_acte, insee_acte, COUNT(id) as cpt INTO #cpt_actes_RC FROM dbo.DataXmlRC_actes (nolock) WHERE id_traitement=@id_traitement GROUP BY geonameid_acte, lieu_acte, insee_acte ORDER BY geonameid_acte, lieu_acte

	--Nb individus par commune
	SELECT geonameid_acte, lieu_acte, insee_acte, COUNT(i.id) as nb_individus INTO #nb_individus FROM dbo.DataXmlRC_actes a (nolock) INNER JOIN dbo.DataXmlRC_individus i (nolock) ON a.id=i.id_acte WHERE id_traitement=@id_traitement GROUP BY geonameid_acte, lieu_acte, insee_acte ORDER BY lieu_acte
	
	--Nb caracteres par commune
	--SELECT
	
	--Nb images par commune
	SELECT geonameid_acte, lieu_acte, COUNT(DISTINCT z.id_acte) as nb_images INTO #nb_images FROM dbo.DataXmlRC_actes a (nolock) INNER JOIN dbo.DataXmlRC_zones z (nolock) ON a.id=z.id_acte WHERE id_traitement=@id_traitement GROUP BY geonameid_acte, lieu_acte ORDER BY lieu_acte

	--Nb fichiers par commune
	SELECT geonameid_acte, lieu_acte, COUNT(DISTINCT fichier_xml_acte) as nb_fichiers INTO #nb_fichiers FROM dbo.DataXmlRC_actes a (nolock) WHERE id_traitement=@id_traitement GROUP BY geonameid_acte, lieu_acte ORDER BY lieu_acte

	--Fusion de tous les comptages pour résultat
	DELETE FROM dbo.DataXmlStatsCommunesRC WHERE id_traitement=@id_traitement
	INSERT INTO dbo.DataXmlStatsCommunesRC(id_traitement, lieu_acte, geonameid_acte, insee_acte, nb_actes, nb_individus, nb_caracteres, nb_images, nb_fichiers_XML)
	SELECT @id_traitement, a.lieu_acte as [Lieu acte], a.geonameid_acte as Geonameid, a.insee_acte as insee_acte, a.cpt, ISNULL(b.nb_individus, 0), null, ISNULL(c.nb_images, 0), ISNULL(d.nb_fichiers, 0)
	FROM #cpt_actes_RC a
	LEFT JOIN #nb_individus b ON a.geonameid_acte=b.geonameid_acte and a.lieu_acte=b.lieu_acte
	LEFT JOIN #nb_images c ON a.geonameid_acte=c.geonameid_acte and a.lieu_acte=c.lieu_acte
	LEFT JOIN #nb_fichiers d ON a.geonameid_acte=d.geonameid_acte and a.lieu_acte=d.lieu_acte
	ORDER BY a.lieu_acte

END

GO
