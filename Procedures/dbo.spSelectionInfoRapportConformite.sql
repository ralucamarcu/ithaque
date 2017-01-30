SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 30.01.2015
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionInfoRapportConformite]
	-- Add the parameters for the stored procedure here
	-- Test Run : spSelectionInfoRapportConformite 410
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nb_lots_total INT = 0, @nb_lots_controle INT = 0, @nb_lots_pas_controle INT = 0, @lots_acceptes INT = 0, @lots_refuses INT = 0
	,@nb_fichiers_controles INT = 0, @nb_fichiers_acceptes INT = 0, @nb_fichiers_vides INT = 0, @nb_fichiers_refuses INT = 0
	,@nb_champs_en_erreur INT = 0, @nb_erreurs_nom INT = 0, @nb_erreurs_prenom INT = 0, @nb_erreurs_dates INT = 0, @nb_erreurs_zonage INT = 0
	,@nb_erreurs_selection INT = 0, @etat_controle INT = 0, @avancement_controle_pourcentage INT = 0, @operateurs VARCHAR (255) = ''
	,@visa VARCHAR(255) = '', @date_debut_controle DATETIME = NULL, @date_fin_controle DATETIME = NULL
	,@current_date DATETIME = GETDATE()
	
	SELECT @date_debut_controle = MIN(la.date_log) 
	FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	WHERE dxee.id_traitement = @id_traitement AND la.action = 'VerrouillageEchantillon'
	
	SELECT @date_fin_controle = MAX (la.date_log) 
	FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	WHERE dxee.id_traitement = @id_traitement AND la.action = 'CocheEchantillonTraité'
	
	IF (@date_debut_controle IS NOT NULL)
	BEGIN
		CREATE TABLE #tmp (nom_operateur VARCHAR(255)) 
		INSERT INTO #tmp 
		SELECT prenom
		FROM Utilisateurs u WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_utilisateur_verrou = u.id_utilisateur	
		GROUP BY prenom
		SELECT @operateurs = @operateurs + ', ' + nom_operateur FROM #tmp
		
		CREATE TABLE #tmp2 (nom VARCHAR(255)) 
		INSERT INTO #tmp2 
		SELECT prenom
		FROM Utilisateurs u WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.verrou = u.id_utilisateur	
		GROUP BY prenom
		SELECT @visa = @visa + ', ' + nom FROM #tmp2
	END
	
	SET @nb_lots_pas_controle = (SELECT COUNT(*) FROM DataXmlEchantillonEntete WHERE id_traitement = @id_traitement AND traite = 0)
	SET @nb_lots_total = (SELECT COUNT(*) FROM DataXmlEchantillonEntete WHERE id_traitement = @id_traitement)
	SELECT @nb_lots_controle = COUNT(DISTINCT dxee.id_echantillon) , @nb_fichiers_controles = COUNT(DISTINCT dxf.id_fichier)
	FROM DataXmlEchantillonEntete  dxee WITH (NOLOCK)
	INNER JOIN DataXml_fichiers dxf WITH(NOLOCK) ON dxee.id_lot = dxf.id_lot
	WHERE dxee.id_traitement = @id_traitement AND traite = 1
	
	IF (@nb_lots_total = @nb_lots_controle)
	BEGIN
		SET @etat_controle = 1
		SET @avancement_controle_pourcentage = (CASE WHEN ISNULL(@nb_lots_controle,0) <> 0 AND ISNULL (@nb_lots_total, 0) <> 0 THEN
			FLOOR(CAST(CAST(@nb_lots_controle AS FLOAT)/CAST(@nb_lots_total AS FLOAT) * 100 AS FLOAT)) ELSE NULL END)
	END
	IF (@nb_lots_total = @nb_lots_pas_controle)
	BEGIN
		SET @etat_controle = 0
	END
	IF (@nb_lots_pas_controle < @nb_lots_total ) AND (@nb_lots_controle < @nb_lots_total)
	BEGIN
		SET @etat_controle = 2
		SET @avancement_controle_pourcentage = (CASE WHEN ISNULL(@nb_lots_controle,0) <> 0 AND ISNULL (@nb_lots_total, 0) <> 0 THEN
			FLOOR(CAST(CAST(@nb_lots_controle AS FLOAT)/CAST(@nb_lots_total AS FLOAT) * 100 AS FLOAT)) ELSE NULL END)
	END

	SELECT @lots_acceptes = COUNT(DISTINCT dxee.id_echantillon) , @nb_fichiers_acceptes = COUNT(DISTINCT dxf.id_fichier)
	FROM DataXmlEchantillonEntete  dxee WITH (NOLOCK)
	INNER JOIN DataXml_fichiers dxf WITH(NOLOCK) ON dxee.id_lot = dxf.id_lot
	WHERE dxee.id_traitement = @id_traitement AND traite = 1 AND dxee.id_statut IN (1,3)

	SELECT @lots_refuses = COUNT(DISTINCT dxee.id_echantillon) , @nb_fichiers_refuses = COUNT(DISTINCT dxf.id_fichier)
	FROM DataXmlEchantillonEntete  dxee WITH (NOLOCK)
	INNER JOIN DataXml_fichiers dxf WITH(NOLOCK) ON dxee.id_lot = dxf.id_lot
	WHERE dxee.id_traitement = @id_traitement AND traite = 1 AND dxee.id_statut = 2

	IF (@nb_lots_controle IS NOT NULL)
	BEGIN
		IF OBJECT_ID('tempdb..#temp_sum_erreurs_ligne_echantillon') IS NOT NULL 
			DROP TABLE #temp_sum_erreurs_ligne_echantillon
		SELECT ee.id_traitement, ee.id_echantillon--, se.libelle AS statut
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.nom, '')) > 0 AND ISNULL(i.nom, '') <> ISNULL(i.nom_Correction, ISNULL(i.nom, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_erreurs_nom
			, SUM(CASE WHEN ed.absence_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.nom, '')) = 0 AND ISNULL(i.nom, '') <> ISNULL(i.nom_Correction, ISNULL(i.nom, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_absences_nom
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.prenom, '')) > 0 AND ISNULL(i.prenom, '') <> ISNULL(i.prenom_Correction, ISNULL(i.prenom, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_erreurs_prenom
			, SUM(CASE WHEN ed.absence_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.prenom, '')) = 0 AND ISNULL(i.prenom, '') <> ISNULL(i.prenom_Correction, ISNULL(i.prenom, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_absences_prenom
			, MAX(CASE WHEN ed.erreur_saisie=1 THEN CASE WHEN (LEN(ISNULL(a.date_acte, '')) > 0 AND ISNULL(a.date_acte, '') <> ISNULL(a.date_acte_Correction, ISNULL(a.date_acte, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_erreurs_date_acte
			, MAX(CASE WHEN ed.absence_saisie=1 THEN CASE WHEN (LEN(ISNULL(a.date_acte, '')) = 0 AND ISNULL(a.date_acte, '') <> ISNULL(a.date_acte_Correction, ISNULL(a.date_acte, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_absences_date_acte
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.date_naissance, '')) > 0 AND ISNULL(i.date_naissance, '') <> ISNULL(i.date_naissance_Correction, ISNULL(i.date_naissance, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_erreurs_date_naissance
			, SUM(CASE WHEN ed.absence_saisie=1 THEN CASE WHEN (LEN(ISNULL(i.date_naissance, '')) = 0 AND ISNULL(i.date_naissance, '') <> ISNULL(i.date_naissance_Correction, ISNULL(i.date_naissance, ''))) THEN (1) ELSE 0 END ELSE 0 END) AS nb_absences_date_naissance
			, MAX(CASE WHEN ed.erreur_zonage=1 THEN (1) ELSE 0 END) AS nb_erreurs_zonage
			, MAX(CASE WHEN ed.erreur_image=1 THEN (1) ELSE 0 END) AS nb_erreurs_image
			, MAX(CASE WHEN ed.erreur_selection=1 THEN CASE WHEN (ISNULL(a.type_acte,'')<>ISNULL(a.type_acte_Correction, ISNULL(a.type_acte,''))) THEN (1) ELSE (0) END ELSE 0 END) AS nb_erreurs_selection_type_acte
			, MAX(CASE WHEN ed.erreur_selection=1 THEN CASE WHEN (ISNULL(a.soustype_acte,'')<>ISNULL(a.soustype_acte_Correction, ISNULL(a.soustype_acte,''))) THEN (1) ELSE (0) END ELSE 0 END) AS nb_erreurs_selection_soustype_acte
			, MAX(CASE WHEN ed.erreur_selection=1 THEN CASE WHEN (ISNULL(a.calendrier_date_acte,'')<>ISNULL(a.calendrier_date_acte_Correction, ISNULL(a.calendrier_date_acte,''))) THEN (1) ELSE (0) END ELSE 0 END) AS nb_erreurs_selection_calendrier_date_acte
			, SUM(CASE WHEN ed.erreur_selection=1 THEN CASE WHEN (ISNULL(i.calendrier_date_naissance,'')<>ISNULL(i.calendrier_date_naissance_Correction, ISNULL(i.calendrier_date_naissance,''))) THEN (1) ELSE (0) END ELSE 0 END) AS nb_erreurs_selection_calendrier_date_naissance
		INTO #temp_sum_erreurs_ligne_echantillon
		FROM dbo.DataXmlEchantillonEntete ee (NOLOCK)
		INNER JOIN dbo.DataXmlEchantillonDetailsRC ed (NOLOCK) ON ee.id_echantillon = ed.id_echantillon
		INNER JOIN dbo.DataXmlRC_actes a (NOLOCK) ON ed.id_acte_RC = a.id
		LEFT JOIN dbo.DataXmlRC_individus i (NOLOCK) ON a.id = i.id_acte
		LEFT JOIN dbo.Statuts_Echantillons se (NOLOCK) ON ee.id_statut = se.id_statut
		WHERE ee.id_traitement = @id_traitement AND ee.traite=1
		GROUP BY ee.id_traitement, ee.id_echantillon, ed.id

		SELECT @nb_erreurs_nom = SUM(nb_erreurs_nom) + SUM(nb_absences_nom)
			, @nb_erreurs_prenom = SUM(nb_erreurs_prenom) + SUM(nb_absences_prenom)
			, @nb_erreurs_dates = SUM(nb_erreurs_date_acte) + SUM(nb_absences_date_acte) + SUM(nb_erreurs_date_naissance) + SUM(nb_absences_date_naissance)
			, @nb_erreurs_zonage = SUM(nb_erreurs_zonage) 
			, @nb_erreurs_selection = SUM(nb_erreurs_selection_type_acte) + SUM(nb_erreurs_selection_soustype_acte) 
				+ SUM(nb_erreurs_selection_calendrier_date_acte) + SUM(nb_erreurs_selection_calendrier_date_naissance) 
		FROM #temp_sum_erreurs_ligne_echantillon
		GROUP BY #temp_sum_erreurs_ligne_echantillon.id_traitement
		
		SET @nb_champs_en_erreur = @nb_erreurs_nom + @nb_erreurs_prenom + @nb_erreurs_dates + @nb_erreurs_zonage + @nb_erreurs_selection
	END
	
	SELECT pt.nom AS nom_prestataire
		, @current_date AS date_current, p.nom AS nom_projet, t.date_livraison
		, CAST(t.id_traitement AS VARCHAR(5)) + ' - ' + t.nom AS id_traitement_echantillonnage	
		, COUNT(dxf.id_fichier) AS nb_fichiers_recu 
		, t.date_verification_conformite 
		, t.objectif_effectif_min AS taille_lot
		, 'Contrôle simple – ISO 2859' AS procedure_echantillonnage
		, tel.effectif_echantillon AS taille_echantillon
		, CAST(CAST(CAST(CAST(100 AS FLOAT) - p.nqa AS FLOAT) AS FLOAT) AS VARCHAR(50)) + ' au champ' AS taux_qualite_attendu
		, CAST(tn.seuil_rejet AS VARCHAR(50)) + ' erreurs' AS criteres_rejet
		, (CASE WHEN @etat_controle = 0 THEN 'A faire' WHEN @etat_controle = 1 THEN 'Terminé' ELSE 'En Cours' END) AS etat_controle
		, CAST(@avancement_controle_pourcentage AS VARCHAR(255)) + '%'	AS avancement_controle
		, @date_debut_controle	AS date_debut_controle
		, @date_fin_controle AS date_fin_controle
		, (CASE WHEN @operateurs LIKE ',%' THEN SUBSTRING(@operateurs,2, LEN(@operateurs)) ELSE @operateurs END) AS operateur
		, (CASE WHEN @visa LIKE ',%' THEN SUBSTRING(@visa,2, LEN(@visa)) ELSE @visa END) AS visa
		, SUM(dxf.nb_actes) AS nb_actes_total, SUM(dxf.nb_actes_naissance) AS nb_actes_naissance, SUM(dxf.nb_actes_mariage) AS nb_actes_mariage
		, SUM(dxf.nb_actes_deces) AS nb_actes_deces
		, (SUM(dxf.nb_actes) - SUM(dxf.nb_actes_naissance) - SUM(dxf.nb_actes_mariage) - SUM(dxf.nb_actes_deces) - SUM(nb_actes_autre)) AS nb_actes_aucun
		, SUM(nb_actes_autre) AS nb_actes_autre
		, t.nb_images AS nb_images
		, t.remarques
		, SUM(dxf.nb_individus) AS nb_individus
		, @nb_lots_total AS nb_lots_total, @nb_lots_controle AS nb_lots_controle, @lots_acceptes AS nb_lots_acceptes, @lots_refuses AS nb_lots_refuses
		, @nb_fichiers_controles AS nb_fichiers_controles, @nb_fichiers_acceptes AS nb_fichiers_acceptes
		, (@nb_fichiers_controles - @nb_fichiers_acceptes - @nb_fichiers_refuses) AS nb_fichiers_vides
		, @nb_fichiers_refuses AS nb_fichiers_refuses, @nb_champs_en_erreur AS nb_champs_en_erreur, @nb_erreurs_nom AS nb_erreurs_nom
		, @nb_erreurs_prenom AS nb_erreurs_prenom, @nb_erreurs_dates AS nb_erreurs_dates, @nb_erreurs_zonage AS nb_erreurs_zonage
		, @nb_erreurs_selection AS nb_erreurs_selection
		
	FROM Traitements t
	INNER JOIN Projets p ON t.id_projet = p.id_projet
	INNER JOIN Table_effectifs_lots tel WITH (NOLOCK) ON p.id_effectif_lot = tel.id_effectif_lot
	INNER JOIN Table_NQA tn WITH (NOLOCK) ON p.id_effectif_lot = tn.id_effectif AND p.NQA = tn.NQA
	INNER JOIN Projets_Maitres pm WITH (NOLOCK) ON p.id_projet_maitre = pm.id_projet_maitre
	INNER JOIN Prestataires pt WITH (NOLOCK) ON pm.id_prestataire = pt.id_prestataire
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON t.id_traitement = dxf.id_traitement	
	WHERE t.id_traitement = @id_traitement
	GROUP BY pt.nom, p.nom , t.date_livraison,CAST(t.id_traitement AS VARCHAR(5)) + ' - ' + t.nom, t.date_verification_conformite, t.objectif_effectif_min
		, tel.effectif_echantillon, CAST(CAST(CAST(100 AS FLOAT) - p.nqa AS FLOAT) AS FLOAT), tn.seuil_rejet, t.nb_images, t.remarques 


END
GO
