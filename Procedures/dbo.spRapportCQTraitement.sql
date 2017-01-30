SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 12/11/2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spRapportCQTraitement] 
	@id_traitement_param as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @nb_champs_acte int, @nb_champs_individu int, @id_traitement int
SET @id_traitement = @id_traitement_param
SET @nb_champs_acte = 1
SET @nb_champs_individu = 2
	
--DETAIL LOTS
IF OBJECT_ID('tempdb..#detail_lots') is not null 
	DROP TABLE #detail_lots
SELECT lf.id_traitement, lf.id_lot, lf.nom_lot AS [Lot], COUNT(DISTINCT a.id) AS [Nb actes du lot], (COUNT(DISTINCT a.id)*@nb_champs_acte) + (COUNT(DISTINCT i.id)*@nb_champs_individu) as [Nb champs du lot], nqa.seuil_rejet as [Seuil de rejet]
		, el.effectif_echantillon AS [Objectif en nb de champs]
INTO #detail_lots
FROM dbo.DataXmlRC_actes a (nolock)
INNER JOIN dbo.DataXml_Fichiers f (nolock) ON a.id_fichier=f.id_fichier
INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) ON f.id_lot=lf.id_lot
LEFT JOIN dbo.DataXmlRC_individus i (nolock) ON a.id=i.id_acte
INNER JOIN dbo.Traitements (nolock) t ON lf.id_traitement=t.id_traitement
INNER JOIN dbo.Projets p (nolock) ON t.id_projet=p.id_projet
LEFT JOIN dbo.Table_NQA nqa (NOLOCK) ON p.id_effectif_lot=nqa.id_effectif and p.nqa=nqa.nqa
LEFT JOIN dbo.Table_effectifs_lots el (NOLOCK) ON p.id_effectif_lot=el.id_effectif_lot
WHERE lf.id_traitement=@id_traitement
GROUP BY lf.id_traitement,lf.id_lot, t.nom, lf.ordre, lf.nom_lot, nqa.seuil_rejet, el.effectif_echantillon
ORDER BY lf.id_traitement, t.nom, lf.ordre

--CALCUL DU NOMBRE DE CHAMPS POUR CHAQUE ACTE
IF OBJECT_ID('tempdb..#temp_actes') is not null 
	DROP TABLE #temp_actes
SELECT a.id as id_acte, f.id_fichier, lf.id_lot, COUNT(DISTINCT a.id)*@nb_champs_acte + COUNT(DISTINCT i.id)*@nb_champs_individu AS [nb_champs], NEWID() as rn
INTO #temp_actes
FROM dbo.DataXmlRC_actes (nolock) a
INNER JOIN dbo.DataXml_Fichiers f (nolock) ON a.id_fichier=f.id_fichier
INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) ON f.id_lot=lf.id_lot
INNER JOIN dbo.DataXmlRC_individus (nolock) i ON a.id=i.id_acte
WHERE a.id_traitement = @id_traitement
GROUP BY a.id, f.id_fichier, lf.id_lot
ORDER BY a.id, f.id_fichier, lf.id_lot

--NB ACTES ET CHAMPS DE CHAQUE ECHANTILLON
IF OBJECT_ID('tempdb..#detail_echantillon') is not null 
	DROP TABLE #detail_echantillon
SELECT ee.id_lot, ee.[id_echantillon], ee.[nom_echantillon], COUNT(ed.id_acte_RC) as nb_actes, SUM(i.[nb_champs]) as nb_champs
INTO #detail_echantillon
FROM dbo.[DataXmlEchantillonEntete] ee (nolock)
inner join dbo.DataXmlEchantillonDetailsRC ed (nolock) on ed.id_echantillon=ee.id_echantillon
inner join #temp_actes i (nolock) on i.id_acte=ed.id_acte_RC
where ee.id_traitement=@id_traitement
group by ee.id_lot, ee.[id_echantillon], ee.[nom_echantillon]
order by ee.[id_echantillon]

--RAPPORT SAISIE
IF OBJECT_ID('tempdb..#detail_saisie') is not null 
	DROP TABLE #detail_saisie
SELECT  ee.id_lot, ee.id_echantillon, t.nom as Traitement, ee.nom_echantillon
		, SUM(CASE WHEN (ed_traites.erreur_saisie=1 OR ed_traites.erreur_selection=1 OR ed_traites.erreur_zonage=1 OR ed_traites.erreur_image=1) THEN 1 ELSE 0 END) AS [Nb d'actes en erreur]
		, SUM(CASE WHEN ed_traites.erreur_saisie=1 THEN (case when isnull(a.[date_acte],'')<>isnull(a.[date_acte_Correction],isnull(a.[date_acte],'')) then (1) else (0) end) ELSE 0 END) AS [Nb d'erreurs sur date]
		, SUM(CASE WHEN ed_traites.erreur_saisie=1 THEN i.nb_erreurs_nom ELSE 0 END) AS [Nb d'erreurs sur Nom]
		, SUM(CASE WHEN ed_traites.erreur_saisie=1 THEN i.nb_erreurs_prenom ELSE 0 END) AS [Nb d'erreurs sur Prénom]
		, SUM(CASE WHEN (ed_traites.erreur_zonage=1 OR ed_traites.erreur_image=1) AND ed_traites.traite=1 THEN 1 ELSE 0 END) AS [Nb d'erreurs sur Zonage]
		, SUM(CASE WHEN ed_traites.erreur_selection=1 THEN (CASE WHEN isnull(a.soustype_acte,'')<>isnull(a.soustype_acte_Correction,isnull(a.soustype_acte,'')) then (1) else (0) end) ELSE 0 END) AS [Nb d'erreurs sélection]
		, SUM(CASE WHEN ed_traites.traite=1 THEN 1 ELSE 0 END) AS [Nb d'actes traités]
		, se.libelle AS [Statut]
INTO #comptage_erreurs
FROM    dbo.DataXmlEchantillonEntete AS ee (nolock) 
        --LIGNES D'ECHANTILLON TRAITEES
        LEFT JOIN DataXmlEchantillonDetailsRC AS ed_traites WITH (nolock) ON ee.id_echantillon = ed_traites.id_echantillon AND ed_traites.traite=1
        --ACTES TRAITES DE L'ECHANTILLON
		LEFT JOIN DataXmlRC_actes AS a WITH (nolock) ON ed_traites.id_acte_RC=a.id 
		--NB INDIVIDUS ET D'ERREURS INDIVIDUS PAR ACTE TRAITE
        LEFT JOIN (SELECT id_acte, COUNT(DISTINCT id) AS nb_individus, SUM(case when isnull([nom],'')<>isnull([nom_Correction],isnull([nom],'')) then (1) else (0) end) AS nb_erreurs_nom, SUM(case when isnull([prenom],'')<>isnull([prenom_Correction],isnull([prenom],'')) then (1) else (0) end) AS nb_erreurs_prenom, SUM(nb_erreurs_individu) as nb_erreurs_individu FROM DataXmlRC_individus WITH (nolock) GROUP BY id_acte) AS i ON a.id = i.id_acte
        INNER JOIN dbo.Traitements AS t (nolock) ON ee.id_traitement=t.id_traitement
        LEFT JOIN dbo.Statuts_Echantillons se (NOLOCK) ON ee.id_statut=se.id_statut
WHERE       t.id_traitement=@id_traitement
GROUP BY ee.id_lot, ee.id_echantillon, t.nom, ee.nom_echantillon, se.libelle
ORDER BY ISNULL(ee.id_echantillon,9999), ee.nom_echantillon

SELECT id_lot, id_echantillon, Traitement, nom_echantillon as [Echantillon], [Nb d'erreurs sur date] + [Nb d'erreurs sur Nom] + [Nb d'erreurs sur Prénom] + [Nb d'erreurs sur Zonage] + [Nb d'erreurs sélection] AS [Nb d'erreurs]
		, [Nb d'actes en erreur], [Nb d'erreurs sur date], [Nb d'erreurs sur Nom], [Nb d'erreurs sur Prénom], [Nb d'erreurs sur Zonage], [Nb d'erreurs sélection]
		, [Nb d'actes traités], [Statut]
INTO #detail_saisie
FROM #comptage_erreurs
ORDER BY ISNULL(id_echantillon,9999), nom_echantillon

--COMPILATION DES DONNEES
SELECT ds.[Traitement], dl.[Lot], dl.[Nb actes du lot], dl.[Nb champs du lot], ROUND(CAST(dl.[Nb champs du lot] AS float)/CAST(dl.[Nb actes du lot] AS float), 2) AS [Ratio Nb champs / Nb actes], dl.[Objectif en nb de champs]
		, de.nb_actes AS [Nb d'actes de l'échantillon], de.nb_champs AS [Taille de l'échantillon (nb champs)], dl.[Seuil de rejet]
		, ds.[Nb d'erreurs]-ds.[Nb d'erreurs sur Zonage] AS [Nb d'erreurs hors zonage], ds.[Nb d'erreurs], ds.[Nb d'actes en erreur], ds.[Nb d'erreurs sur date], ds.[Nb d'erreurs sur Nom], ds.[Nb d'erreurs sur Prénom], ds.[Nb d'erreurs sur Zonage], ds.[Nb d'erreurs sélection]
		, ds.[Nb d'actes traités], ROUND(CAST(ds.[Nb d'actes traités] AS float)/CAST(de.nb_actes AS float)*100, 2) AS [% actes traités]
		, ds.[Statut]
FROM #detail_lots dl
LEFT JOIN #detail_echantillon de ON dl.id_lot=de.id_lot
LEFT JOIN #detail_saisie ds ON dl.id_lot=ds.id_lot
ORDER BY ds.id_echantillon

END

GO
