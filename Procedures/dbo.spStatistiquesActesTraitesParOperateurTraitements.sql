SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesActesTraitesParOperateurTraitements]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatististiquesActesTraitesParOperateurTraitements] '0C13983F-845D-4DEF-891E-12F382D347EE', 3, 'oct  3 2014 12:00AM'
	 @id_projet UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@date DATETIME
	,@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @lots_controles INT, @lots_valides INT, @lots_rejetes INT, @tx_lots_rejetes FLOAT
		,@actes_controles INT, @actes_valides INT, @actes_rejetes INT, @tx_actes_rejetes FLOAT, @actes_lus INT 
	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER)
	CREATE TABLE #tmp_lots_valides (id_lot UNIQUEIDENTIFIER)

	INSERT INTO #tmp_lots_controles
	SELECT DISTINCT dxee.id_lot
	FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	WHERE dxee.id_traitement = @id_traitement
		AND la.id_utilisateur = @id_utilisateur
		AND la.[action] = 'CocheEchantillonTraité'
		AND la.id_type_objet = 1
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date)))

	CREATE INDEX idx_id_lot ON #tmp_lots_controles(id_lot)
		
	SET @lots_controles = (SELECT COUNT(*) FROM #tmp_lots_controles)

	INSERT INTO #tmp_lots_valides
	SELECT dxee.id_lot 
	FROM #tmp_lots_controles t 
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
	WHERE id_statut IN (1,3)	
	
	SET @lots_valides = (SELECT COUNT(*) FROM #tmp_lots_valides)
		
	SET @lots_rejetes = (SELECT COUNT(dxee.id_lot) 
				FROM #tmp_lots_controles t 
				INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
				WHERE id_statut = 2)
	SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
		THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
	SET @actes_controles = (SELECT COUNT(DISTINCT dxa.id) 
		FROM #tmp_lots_controles t 
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK)  ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier)

	SET @actes_valides = (SELECT COUNT(DISTINCT dxa.id) 
		FROM #tmp_lots_valides t 
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier )	
		
	SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
		FROM #tmp_lots_controles t
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		WHERE dxee.id_statut = 2)

	SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
		THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)

	SET @actes_lus = (SELECT COUNT(DISTINCT dxa.id) 
		FROM #tmp_lots_controles t 
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
		INNER JOIN DataXmlEchantillonDetailsRC dxed WITH (NOLOCK) ON dxed.id_echantillon = dxee.id_echantillon
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = dxed.id_acte_RC
		WHERE dxed.traite = 1)
					
	SELECT (CASE WHEN p.nom IS NULL THEN p.nom_projet_dossier ELSE p.nom END)AS sous_projet, t.nom AS livraison
		, t.date_creation AS date_livraison, la.id_utilisateur AS id_operateur
		, u.nom AS nom_operateur, u.prenom AS prenom_utilisateur, @date AS date_traitement, @lots_controles AS lots_controles
		, @lots_valides AS lots_valides, @lots_rejetes AS lots_rejetes, @tx_lots_rejetes AS taux_lots_rejetes
		, @actes_controles AS actes_controles, @actes_valides AS actes_valides, @actes_rejetes AS actes_rejetes
		, @tx_actes_rejetes AS taux_actes_rejetes, @actes_lus AS actes_lus
	FROM Logs_actions la WITH (NOLOCK)
	INNER JOIN Utilisateurs u WITH (NOLOCK) ON la.id_utilisateur = u.id_utilisateur
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON la.id_objet = dxee.id_echantillon
	INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
	INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
	WHERE la.id_utilisateur = @id_utilisateur AND t.id_traitement = @id_traitement 
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date)))	 
	GROUP BY la.id_utilisateur, u.nom, u.prenom, (CASE WHEN p.nom IS NULL THEN p.nom_projet_dossier ELSE p.nom END), t.nom, t.date_creation 

	DROP TABLE #tmp_lots_valides
	DROP TABLE #tmp_lots_controles

END
GO
