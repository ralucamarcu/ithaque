SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionSuiviInfo]
	-- Add the parameters for the stored procedure here
	-- Test Run : spLivraisonsSelectionSuiviInfo 233
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nb_lots_rejetes INT, @avancement_controle FLOAT, @nb_total_lots INT, @nb_lots_traites INT, @pourcentage_rejetes FLOAT  
		,@echantillon INT, @nb_fichiers INT, @nb_actes INT, @nb_actes_naissance INT, @nb_actes_mariage INT, @nb_actes_deces INT, @nb_actes_recensement INT
    CREATE TABLE #tmp (id_echantillon INT, id_statut INT, traite INT)
	INSERT INTO #tmp (id_echantillon, id_statut, traite)
    SELECT id_echantillon, id_statut, traite
    FROM DataXmlEchantillonEntete WITH (NOLOCK)
    WHERE id_traitement = @id_traitement
    
    SET @nb_lots_rejetes = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE id_statut = 2)
    SET @nb_total_lots = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK))
    SET @nb_lots_traites = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE traite = 1)
    SET @echantillon = (SELECT COUNT(*) FROM DataXml_lots_fichiers WITH (NOLOCK) WHERE id_traitement = @id_traitement) 
    SELECT @nb_fichiers = COUNT(DISTINCT id_fichier), @nb_actes_naissance =  SUM(nb_actes_naissance)
		,@nb_actes_mariage = SUM(nb_actes_mariage), @nb_actes_deces = SUM(nb_actes_deces), @nb_actes_recensement = SUM(nb_actes_recensement)
    FROM DataXml_fichiers WITH (NOLOCK) WHERE id_traitement = @id_traitement
    
    SET @nb_actes = (SELECT COUNT(DISTINCT id) FROM DataXmlRC_actes da WITH (NOLOCK) 
			INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON da.id_fichier = df.id_fichier
			WHERE df.id_traitement = @id_traitement) 
	
    
    SET @avancement_controle = (CASE WHEN (ISNULL(@nb_lots_traites, 0) <> 0 AND ISNULL(@nb_total_lots, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_lots_traites AS FLOAT) / CAST( @nb_total_lots  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
	SET @pourcentage_rejetes = (CASE WHEN (ISNULL(@nb_lots_rejetes, 0) <> 0 AND ISNULL(@nb_lots_traites, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_lots_rejetes AS FLOAT) / CAST( @nb_lots_traites  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
    
	SELECT t.id_traitement AS id_livraison
		, t.nom AS nom_livraison, t.date_livraison, p.nom AS nom_projet, type_livraison
		, (CASE WHEN @nb_lots_traites = 0 THEN 1 ELSE 0 END) AS a_traiter
		, controle_livraison_conformite AS conformity
		, livraison_conforme AS valide
		, import_xml AS import_cq
		, (CASE WHEN @echantillon = 0 THEN 0 ELSE 1 END) AS echantill
		, @avancement_controle AS avancement_controle
		, @nb_fichiers AS nb_fichiers
		, @nb_actes AS nb_actes, @pourcentage_rejetes AS rejetees
		, @nb_actes_naissance  AS nb_actes_naissance
		, @nb_actes_mariage AS nb_actes_mariage
		, @nb_actes_deces AS nb_actes_deces
		, @nb_actes_recensement AS nb_actes_recensement
		, t.livraison_annulee
		,t.date_retour_conformite_xml
		,t.date_retour_cq
		
	FROM Traitements t WITH (NOLOCK)
	INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet	
	WHERE t.id_traitement = @id_traitement
	GROUP BY t.id_traitement, t.nom, t.date_livraison, p.nom, type_livraison, controle_livraison_conformite, livraison_conforme, t.import_xml, t.livraison_annulee, t.date_retour_conformite_xml, t.date_retour_cq
	
	DROP TABLE #tmp
	
	
END


GO
