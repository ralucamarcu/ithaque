SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spCalculNbErreursEchantillon]
(
	@id_echantillon int
)
AS
	SET NOCOUNT ON;
	
--CALCUL DU NOMBRE D'ERREURS INDIVIDU PAR ACTE DE L'ECHANTILLON
IF OBJECT_ID('tempdb..#temp_sum_erreurs_individus_ligne_echantillon') is not null 
	DROP TABLE #temp_sum_erreurs_individus_ligne_echantillon
SELECT     id_acte, COUNT(DISTINCT i.id) AS nb_individus, SUM(CASE WHEN (LEN(ISNULL(i.nom, '')) > 0 AND isnull(i.nom, '') <> isnull(i.nom_Correction, isnull(i.nom, ''))) THEN (1) 
                      ELSE (0) END) AS nb_corrections_nom, SUM(CASE WHEN (LEN(ISNULL(i.prenom, '')) > 0 AND isnull(i.prenom, '') <> isnull(i.prenom_Correction, isnull(i.prenom, ''))) 
                      THEN (1) ELSE (0) END) AS nb_corrections_prenom, SUM(CASE WHEN (LEN(ISNULL(i.nom, '')) = 0) AND (LEN(ISNULL(i.nom_Correction, '')) > 0) THEN (1) ELSE (0) END) 
                      AS nb_absences_nom, SUM(CASE WHEN (LEN(ISNULL(i.prenom, '')) = 0) AND (LEN(ISNULL(i.prenom_Correction, '')) > 0) THEN (1) ELSE (0) END) 
                      AS nb_absences_prenom, SUM(nb_erreurs_individu) AS nb_corrections_individus
INTO #temp_sum_erreurs_individus_ligne_echantillon
FROM         dbo.DataXmlRC_individus AS i WITH (nolock)
INNER JOIN dbo.DataXmlEchantillonDetailsRC AS ed WITH (NOLOCK) ON i.id_acte=ed.id_acte_RC
WHERE ed.id_echantillon=@id_echantillon
GROUP BY id_acte

--CALCUL DU NOMBRE D'ERREURS ACTE PAR ACTE DE L'ECHANTILLON PAR TYPE D'ERREUR
IF OBJECT_ID('tempdb..#temp_sum_erreurs_ligne_echantillon') is not null 
	DROP TABLE #temp_sum_erreurs_ligne_echantillon
SELECT  ed.id_echantillon, ed.id, ed.erreur_saisie, ed.absence_saisie, ed.erreur_selection, ed.erreur_zonage, ed.erreur_image
		, SUM(CASE WHEN ed.erreur_selection=1 THEN (case when isnull(a.soustype_acte,'')<>isnull(a.soustype_acte_Correction,isnull(a.soustype_acte,'')) then (1) else (0) end) ELSE 0 END) AS nb_erreurs_selection_actes
		--NB ERREURS SAISIE ACTE
		, SUM(CASE WHEN ed.erreur_saisie=1 THEN (CASE WHEN isnull(a.date_acte,'')<>isnull(a.date_acte_Correction,isnull(a.date_acte,'')) then (1) else (0) end) else 0 end) AS nb_erreurs_saisie_actes
		, SUM(CASE WHEN ed.erreur_saisie=1 THEN (CASE WHEN isnull(a.insee_acte,'')<>isnull(a.insee_acte_Correction,isnull(a.insee_acte,'')) then (1) else (0) end) ELSE 0 END) AS nb_absences_saisie_actes
		, SUM(CASE WHEN ed.erreur_saisie=1 THEN i.nb_corrections_nom + i.nb_corrections_prenom ELSE 0 END) AS nb_erreurs_saisie_individus
		, SUM(CASE WHEN ed.absence_saisie=1 THEN i.nb_absences_nom + i.nb_absences_prenom  ELSE 0 END) AS nb_absences_saisie_individus
		, 0 AS nb_erreurs_selection_individus
		--, SUM(CASE WHEN (ed.erreur_zonage=1 OR ed.erreur_image=1) THEN 1 ELSE 0 END) AS nb_erreurs_zonage
INTO #temp_sum_erreurs_ligne_echantillon
FROM        DataXmlRC_actes AS a WITH (nolock) LEFT JOIN
			--NB INDIVIDUS ET D'ERREURS INDIVIDUS PAR ACTE
			#temp_sum_erreurs_individus_ligne_echantillon AS i WITH (nolock) ON a.id = i.id_acte INNER JOIN
			--vue_Nb_Corrections_Individus_Acte AS i WITH (nolock) ON a.id = i.id_acte INNER JOIN
			DataXmlEchantillonDetailsRC AS ed WITH (nolock) ON a.id = ed.id_acte_RC
WHERE        (ed.id_echantillon = @id_echantillon) AND ed.traite=1
GROUP BY ed.id_echantillon, ed.id, ed.erreur_saisie, ed.absence_saisie, ed.erreur_selection, ed.erreur_zonage, ed.erreur_image
--SELECT * FROM #temp_sum_erreurs_ligne_echantillon

--CALCUL DU NOMBRE DES ERREURS DE L'ECHANTILLON PAR TYPE D'ERREUR
IF OBJECT_ID('tempdb..#temp_sum_erreurs_echantillon') is not null 
	DROP TABLE #temp_sum_erreurs_echantillon
SELECT id_echantillon
	, SUM(CASE WHEN nb_erreurs_saisie_actes+nb_erreurs_saisie_individus=0 AND erreur_saisie=1 THEN 1 ELSE nb_erreurs_saisie_actes+nb_erreurs_saisie_individus END) AS nb_erreurs_saisie
	, SUM(CASE WHEN nb_erreurs_selection_actes+nb_erreurs_selection_individus=0 AND erreur_selection=1 THEN 1 ELSE nb_erreurs_selection_actes+nb_erreurs_selection_individus END) AS nb_erreurs_selection
	, SUM(CASE WHEN nb_absences_saisie_actes+nb_absences_saisie_individus=0 AND absence_saisie=1 THEN 1 ELSE nb_absences_saisie_actes+nb_absences_saisie_individus END) AS nb_absences_saisie
	, SUM(CASE WHEN erreur_zonage=1 THEN 1 ELSE 0 END) AS nb_erreurs_zonage
	, SUM(CASE WHEN erreur_image=1 THEN 1 ELSE 0 END) AS nb_erreurs_image
INTO #temp_sum_erreurs_echantillon
FROM #temp_sum_erreurs_ligne_echantillon
GROUP BY id_echantillon
--SELECT * FROM #temp_sum_erreurs_echantillon

SELECT id_echantillon, (nb_erreurs_saisie + nb_erreurs_selection + nb_absences_saisie + nb_erreurs_zonage + nb_erreurs_image) AS nb_erreurs_saisie
	, (nb_erreurs_saisie + nb_erreurs_selection + nb_absences_saisie+ nb_erreurs_image) AS nb_erreurs_saisie_hors_zonage
FROM #temp_sum_erreurs_echantillon

/* VERSION DE LA PROC STOCK AVNT LE 28/11/2013
SELECT a.id_echantillon, (nb_erreurs_saisie_actes + nb_erreurs_saisie_individus + nb_absences_saisie_actes + nb_absences_saisie_individus + nb_erreurs_selection_actes) AS nb_erreurs_saisie_hors_zonage
	, (nb_erreurs_saisie_actes + nb_erreurs_saisie_individus + nb_absences_saisie_actes + nb_absences_saisie_individus + nb_erreurs_selection_actes + nb_erreurs_zonage)  AS nb_erreurs_saisie
	, nb_erreurs_selection_actes, nb_erreurs_saisie_actes, nb_absences_saisie_actes, nb_erreurs_saisie_individus, nb_absences_saisie_individus, nb_erreurs_zonage
FROM (
	SELECT  ed.id_echantillon
			, SUM(CASE WHEN ed.erreur_selection=1 THEN (case when isnull(a.soustype_acte,'')<>isnull(a.soustype_acte_Correction,isnull(a.soustype_acte,'')) then (1) else (0) end) ELSE 0 END) AS nb_erreurs_selection_actes
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN (CASE WHEN isnull(a.date_acte,'')<>isnull(a.date_acte_Correction,isnull(a.date_acte,'')) then (1) else (0) end) else 0 end)  AS nb_erreurs_saisie_actes
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN (CASE WHEN isnull(a.insee_acte,'')<>isnull(a.insee_acte_Correction,isnull(a.insee_acte,'')) then (1) else (0) end) ELSE 0 END) AS nb_absences_saisie_actes
			, SUM(CASE WHEN ed.erreur_saisie=1 THEN i.nb_corrections_nom + i.nb_corrections_prenom ELSE 0 END) AS nb_erreurs_saisie_individus
			, SUM(CASE WHEN ed.absence_saisie=1 THEN i.nb_absences_nom + i.nb_absences_prenom  ELSE 0 END) AS nb_absences_saisie_individus
			, SUM(CASE WHEN (ed.erreur_zonage=1 OR ed.erreur_image=1) THEN 1 ELSE 0 END) AS nb_erreurs_zonage
	FROM            DataXmlRC_actes AS a WITH (nolock) INNER JOIN
				--NB INDIVIDUS ET D'ERREURS INDIVIDUS PAR ACTE
				vue_Nb_Corrections_Individus_Acte AS i WITH (nolock) ON a.id = i.id_acte INNER JOIN
				DataXmlEchantillonDetailsRC AS ed WITH (nolock) ON a.id = ed.id_acte_RC
	WHERE        (ed.id_echantillon = @id_echantillon) AND ed.traite=1
	GROUP BY ed.id_echantillon
) a
*/

/*
SELECT        SUM(a.nb_erreurs_acte) AS nb_erreurs_acte, SUM(i.nb_erreurs_individu) AS nb_erreurs_individu, SUM(a.nb_erreurs_acte) + SUM(i.nb_erreurs_individu) + SUM(CASE WHEN (ed.erreur_zonage=1 OR ed.erreur_image=1) THEN 1 ELSE 0 END) AS nb_erreurs_echantillon
FROM            DataXmlRC_actes AS a WITH (nolock) INNER JOIN
			--NB INDIVIDUS ET D'ERREURS INDIVIDUS PAR ACTE
            (SELECT id_acte, COUNT(DISTINCT id) AS nb_individus, SUM(case when isnull([nom],'')<>isnull([nom_Correction],isnull([nom],'')) then (1) else (0) end) AS nb_erreurs_nom, SUM(case when isnull([prenom],'')<>isnull([prenom_Correction],isnull([prenom],'')) then (1) else (0) end) AS nb_erreurs_prenom, SUM(nb_erreurs_individu) as nb_erreurs_individu FROM DataXmlRC_individus WITH (nolock) GROUP BY id_acte) AS i ON a.id = i.id_acte INNER JOIN
                         DataXmlEchantillonDetailsRC AS ed WITH (nolock) ON a.id = ed.id_acte_RC
WHERE        (ed.id_echantillon = @id_echantillon) AND ed.traite=1
*/

GO
