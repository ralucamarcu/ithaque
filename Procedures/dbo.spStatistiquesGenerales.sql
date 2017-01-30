SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesGenerales] 
	@id_traitement as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @type_traitement int

	SELECT B.NOM_COMPTEUR as Compteur, A.VALEUR as Valeur
	FROM COMPTEURS_TRAITEMENTS (NOLOCK) A 
	INNER JOIN COMPTEURS_TYPES_TRAITEMENTS (NOLOCK) B ON A.ID_COMPTEUR=B.ID_COMPTEUR 
	WHERE ID_TRAITEMENT=@id_traitement 
	ORDER BY ORDRE ASC

	--Statistiques des erreurs
	SELECT @type_traitement=id_type_traitement FROM dbo.Traitements (nolock) WHERE id_traitement=@id_traitement
	IF @type_traitement=1 --TD/EC
	BEGIN
		SELECT ee.id_echantillon, ee.nom_echantillon, COUNT(*) as [Nb actes TD de l'échantillon]
		, SUM(CASE WHEN (erreur_saisie=1 OR erreur_selection=1 OR absence_saisie=1 OR individu_TD_non_trouve_EC=1 OR erreur_zonage=1 OR erreur_image=1) THEN 1 ELSE 0 END) as [Nb actes TD en erreur]
		, SUM(CASE WHEN (erreur_saisie=1) THEN 1 ELSE 0 END) as [Nb erreurs de saisie]
		, SUM(CASE WHEN (erreur_selection=1) THEN 1 ELSE 0 END) as [Nb erreurs de sélection]
		, SUM(CASE WHEN (absence_saisie=1) THEN 1 ELSE 0 END) as [Nb absences de saisie]
		, SUM(CASE WHEN (individu_TD_non_trouve_EC=1) THEN 1 ELSE 0 END) as [Nb individus TD non trouvés]
		, SUM(CASE WHEN (erreur_zonage=1) THEN 1 ELSE 0 END) as [Nb erreurs de zonage]
		, SUM(CASE WHEN (erreur_image=1) THEN 1 ELSE 0 END) as [Nb erreurs d'image]
		, SUM(CASE WHEN (ed.date_acte_TD_Correction IS NOT NULL AND LEN(ed.date_acte_TD_Correction)>0 AND ed.date_acte_TD_Correction<>ed.date_acte_TD COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END) as [Nb corrections de date]
		/*
		, SUM((CASE WHEN (ed.nom_individu1_acte_TD_Correction IS NOT NULL AND LEN(ed.nom_individu1_acte_TD_Correction)>0 AND ed.nom_individu1_acte_TD_Correction<>ed.nom_individu1_acte_TD COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END) + (CASE WHEN (ed.nom_individu2_acte_TD_Correction IS NOT NULL AND LEN(ed.nom_individu2_acte_TD_Correction)>0 AND ed.nom_individu2_acte_TD_Correction<>ed.nom_individu2_acte_TD COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END)) as [Nb corrections de noms]
		, SUM((CASE WHEN (ed.prenom_individu1_acte_TD_Correction IS NOT NULL AND LEN(ed.prenom_individu1_acte_TD_Correction)>0 AND ed.prenom_individu1_acte_TD_Correction<>ed.prenom_individu1_acte_TD COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END) + (CASE WHEN (ed.prenom_individu2_acte_TD_Correction IS NOT NULL AND LEN(ed.prenom_individu2_acte_TD_Correction)>0 AND ed.prenom_individu2_acte_TD_Correction<>ed.prenom_individu2_acte_TD COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END)) as [Nb corrections de prénoms]
		*/
		, SUM(CASE WHEN (i.nom_Correction IS NOT NULL AND LEN(i.nom_Correction)>0 AND i.nom_Correction<>i.nom COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END) as [Nb corrections de noms]
		, SUM(CASE WHEN (i.prenom_Correction IS NOT NULL AND LEN(i.prenom_Correction)>0 AND i.prenom_Correction<>i.prenom COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END) as [Nb corrections de prénoms]
		FROM dbo.DataXmlEchantillonEntete (nolock) ee
		INNER JOIN dbo.DataXmlEchantillonDetails (nolock) ed ON ed.id_echantillon=ee.id_echantillon
		INNER JOIN dbo.DataXmlTD_individus (nolock) i ON i.id_acte=ed.id_acte_TD
		WHERE ee.id_traitement=@id_traitement
		AND ed.traite=1
		GROUP BY ee.id_traitement, ee.id_echantillon, ee.nom_echantillon
		ORDER BY ee.id_traitement, ee.id_echantillon
	END
	ELSE IF @type_traitement IN (2, 3) --Recensement, Etat Civil
	BEGIN
		SELECT ee.id_traitement, ee.id_echantillon, ind.id_acte
		, SUM((CASE WHEN (ind.nom_Correction IS NOT NULL AND LEN(ind.nom_Correction)>0 AND ind.nom_Correction<>ind.nom COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END)) as [Nb corrections de noms]
		, SUM((CASE WHEN (ind.prenom_Correction IS NOT NULL AND LEN(ind.prenom_Correction)>0 AND ind.prenom_Correction<>ind.prenom COLLATE FRENCH_CS_AS) THEN 1 ELSE 0 END)) as [Nb corrections de prénoms]
		, SUM((CASE WHEN ((ind.date_naissance_Correction IS NOT NULL AND LEN(ind.date_naissance_Correction)>0 AND ind.date_naissance_Correction<>ISNULL(ind.date_naissance, '')) OR (ind.calendrier_date_naissance_Correction IS NOT NULL AND LEN(ind.calendrier_date_naissance_Correction)>0 AND ind.calendrier_date_naissance_Correction<>ISNULL(ind.calendrier_date_naissance, ''))) THEN 1 ELSE 0 END)) as [Nb corrections de dates de naissance]
		, SUM((CASE WHEN (ind.age_Correction IS NOT NULL AND LEN(ind.age_Correction)>0 AND ind.age_Correction<>ind.age) THEN 1 ELSE 0 END)) as [Nb corrections d'ages]
		, SUM((CASE WHEN ((ind.lieu_naissance_Correction IS NOT NULL AND LEN(ind.lieu_naissance_Correction)>0 AND ind.insee_naissance_Correction<>ISNULL(ind.insee_naissance,'')) OR (ind.insee_naissance_Correction IS NOT NULL AND LEN(ind.insee_naissance_Correction)>0 AND ind.insee_naissance_Correction<>ISNULL(ind.insee_naissance, '')) OR (ind.geonameid_naissance_Correction IS NOT NULL AND LEN(ind.geonameid_naissance_Correction)>0 AND ind.geonameid_naissance_Correction<>ISNULL(ind.geonameid_naissance, 0))) THEN 1 ELSE 0 END)) as [Nb corrections de lieux de naissance]
		INTO #temp_corrections
		FROM dbo.DataXmlEchantillonEntete (nolock) ee
		INNER JOIN dbo.DataXmlEchantillonDetailsRC (nolock) ed ON ed.id_echantillon=ee.id_echantillon
		INNER JOIN dbo.DataXmlRC_individus (nolock) ind ON ind.id_acte=ed.id_acte_RC
		WHERE ee.id_traitement=@id_traitement AND ed.traite=1
		GROUP BY ee.id_traitement, ee.id_echantillon, ind.id_acte
		ORDER BY ee.id_traitement, ee.id_echantillon

		SELECT ee.id_echantillon, ee.nom_echantillon, COUNT(*) as [Nb actes de l'échantillon]
		, SUM(CASE WHEN (erreur_saisie=1 OR erreur_selection=1 OR absence_saisie=1 OR erreur_zonage=1 OR erreur_image=1) THEN 1 ELSE 0 END) as [Nb actes en erreur]
		, SUM(CASE WHEN (erreur_saisie=1) THEN 1 ELSE 0 END) as [Nb erreurs de saisie]
		, SUM(CASE WHEN (erreur_selection=1) THEN 1 ELSE 0 END) as [Nb erreurs de sélection]
		, SUM(CASE WHEN (absence_saisie=1) THEN 1 ELSE 0 END) as [Nb absences de saisie]
		, SUM(CASE WHEN (erreur_zonage=1) THEN 1 ELSE 0 END) as [Nb erreurs de zonage]
		, SUM(CASE WHEN (erreur_image=1) THEN 1 ELSE 0 END) as [Nb erreurs d'image]
		, SUM(cor.[Nb corrections de noms]) as [Nb corrections de noms]
		, SUM(cor.[Nb corrections de prénoms]) as [Nb corrections de prénoms]
		, SUM(cor.[Nb corrections de dates de naissance]) as [Nb corrections de dates de naissance]
		, SUM(cor.[Nb corrections d'ages]) as [Nb corrections d'ages]
		, SUM(cor.[Nb corrections de lieux de naissance]) as [Nb corrections de lieux de naissance]
		FROM dbo.DataXmlEchantillonEntete (nolock) ee
		INNER JOIN dbo.DataXmlEchantillonDetailsRC (nolock) ed ON ed.id_echantillon=ee.id_echantillon
		LEFT JOIN #temp_corrections (nolock) cor ON cor.id_echantillon=ee.id_echantillon AND cor.id_acte=ed.id_acte_RC
		WHERE ee.id_traitement=@id_traitement
		AND ed.traite=1
		GROUP BY ee.id_traitement, ee.id_echantillon, ee.nom_echantillon
		ORDER BY ee.id_traitement, ee.id_echantillon
	END
END

GO
