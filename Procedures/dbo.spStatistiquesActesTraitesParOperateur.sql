SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 07.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesActesTraitesParOperateur]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesActesTraitesParOperateur] , 1, '06-03-2015'
	 @id_projet UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@date DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

print @date

    -- Insert statements for procedure here
    DECLARE @lots_traites INT, @actes_traites INT, @lots_rejetes INT
    CREATE TABLE #temp (id_acte INT, id_lot UNIQUEIDENTIFIER, id_statut INT)
    INSERT INTO #temp (id_acte, id_lot, id_statut)
    SELECT dxa.id AS id_acte, dxee.id_lot , dxee.id_statut
	FROM DataXmlRC_actes dxa WITH (NOLOCK)
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement 
	WHERE t.id_projet = @id_projet
		AND la.id_utilisateur = @id_utilisateur	
		AND la.[action] = 'CocheEchantillonTraité'
		AND la.id_type_objet = 1
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date)))
	GROUP BY dxa.id, dxee.id_lot , dxee.id_statut
				
	--SET @lots_traites = (SELECT COUNT(DISTINCT dxee.id_lot) 
	--		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
	--		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	--		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
	--		WHERE t.id_projet = @id_projet
	--			AND la.id_utilisateur = @id_utilisateur	
	--			AND la.[action] = 'CocheEchantillonTraité'
	--			AND la.id_type_objet = 1
	--			and (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) and date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date))))
				
	
	--SET @lots_rejetes = (SELECT COUNT(DISTINCT dxee.id_lot) 
	--		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
	--		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	--		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
	--		WHERE t.id_projet = @id_projet
	--			AND la.id_utilisateur = @id_utilisateur	
	--			AND la.[action] = 'CocheEchantillonTraité'
	--			AND la.id_type_objet = 1
	--			AND id_statut = 2
	--			and (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) and date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date))))
	
	--SET @actes_traites = (SELECT COUNT(DISTINCT dxa.id) 
	--		FROM DataXmlRC_actes dxa WITH (NOLOCK)
	--		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	--		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	--		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	--		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement 
	--		WHERE t.id_projet = @id_projet
	--			AND la.id_utilisateur = @id_utilisateur	
	--			AND la.[action] = 'CocheEchantillonTraité'
	--			AND la.id_type_objet = 1
	--			and (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) and date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date))))	
	
	SET @lots_traites = (SELECT COUNT(DISTINCT id_lot) FROM #temp)
	SET @lots_rejetes = (SELECT COUNT(DISTINCT id_lot) FROM #temp WHERE id_statut = 2)
	SET @actes_traites = (SELECT COUNT(DISTINCT id_acte) FROM #temp)
	
			
	SELECT la.id_utilisateur, u.nom AS operateur_nom, u.prenom AS operateur_prenom, DATEADD(dd,00,DATEDIFF(dd, 0, @date)) AS [DATE] , p.nom AS sous_projet
		, @lots_traites AS lots_traites, @actes_traites AS actes_traites, @lots_rejetes AS lots_rejetes
	FROM Logs_actions la WITH (NOLOCK)
	INNER JOIN Utilisateurs u WITH (NOLOCK) ON la.id_utilisateur = u.id_utilisateur
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON la.id_objet = dxee.id_echantillon
	INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
	INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
	WHERE la.id_utilisateur = @id_utilisateur AND p.id_projet = @id_projet
	GROUP BY la.id_utilisateur, u.nom, u.prenom, p.nom
	
	DROP TABLE #temp


	
END
GO
