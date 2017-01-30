SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 02/04/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReportDetailsEchantillon] 
	@id_echantillon as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/*
--Comptage des actes en erreur
SELECT ee.id_traitement, ee.id_echantillon, ee.nom_echantillon, COUNT(*) as [Nb actes TD de l'échantillon]
, SUM(CASE WHEN (erreur_saisie=1 OR erreur_selection=1 OR absence_saisie=1 OR individu_TD_non_trouve_EC=1 OR erreur_zonage=1 OR erreur_image=1) THEN 1 ELSE 0 END) as [Nb actes TD en erreur]
, SUM(CASE WHEN (erreur_saisie=1) THEN 1 ELSE 0 END) as [Nb erreurs de saisie]
, SUM(CASE WHEN (erreur_selection=1) THEN 1 ELSE 0 END) as [Nb erreurs de sélection]
, SUM(CASE WHEN (absence_saisie=1) THEN 1 ELSE 0 END) as [Nb absences de saisie]
, SUM(CASE WHEN (individu_TD_non_trouve_EC=1) THEN 1 ELSE 0 END) as [Nb individus TD non trouvés]
, SUM(CASE WHEN (erreur_zonage=1) THEN 1 ELSE 0 END) as [Nb erreurs de zonage]
, SUM(CASE WHEN (erreur_image=1) THEN 1 ELSE 0 END) as [Nb erreurs d'image]
FROM dbo.DataXmlEchantillonEntete (nolock) ee
INNER JOIN dbo.DataXmlEchantillonDetails (nolock) ed ON ed.id_echantillon=ee.id_echantillon
WHERE ee.id_echantillon=@id_echantillon
AND traite=1
GROUP BY ee.id_traitement, ee.id_echantillon, ee.nom_echantillon
*/

--Concaténation des champs image pour chaque acte de l'échantillon
SELECT z1.id_acte,
       STUFF( (SELECT DISTINCT ', ' + cast(image AS varchar(1024))
               FROM DataXmlTD_zones AS z2
               INNER JOIN dbo.DataXmlEchantillonDetails AS d2 ON d2.id_acte_TD=z2.id_acte
               WHERE z1.id_acte = z2.id_acte AND d2.id_echantillon=@id_echantillon
               FOR XML PATH('')),1 ,1, '') AS image
INTO #temp
FROM DataXmlTD_zones AS z1
INNER JOIN dbo.DataXmlEchantillonDetails AS d1 ON d1.id_acte_TD=z1.id_acte
WHERE d1.id_echantillon=@id_echantillon
GROUP BY z1.id_acte;

SELECT d.id AS [Id ligne échantillon], d.id_acte_TD AS [Id acte TD], d.message AS [Comments], cast(d.traite as tinyint) AS [Processed], a.id_acte_xml AS [Id acte XML], a.fichier_xml_acte AS [XML File], cast(erreur_saisie as tinyint) AS [Data entry error], cast(erreur_selection as tinyint) AS [Selection error], cast(absence_saisie as tinyint) AS [Missing data entry], cast(individu_TD_non_trouve_EC as tinyint) AS [TD individual not found], cast(erreur_zonage as tinyint) AS [Wrong household recognition], cast(erreur_image as tinyint) AS [Picture error], t.image AS [Picture file]
	, CASE WHEN ISNULL(i1.nom,'')<>ISNULL(i1.nom_Correction,ISNULL(i1.nom,'')) THEN 'Wrong name : ' + ISNULL(i1.nom,'') + ' --> Correct name : ' + i1.nom_Correction ELSE '' END as [Individual name 1]
	, CASE WHEN ISNULL(i1.prenom,'')<>ISNULL(i1.prenom_Correction,ISNULL(i1.prenom,'')) THEN 'Wrong name : ' + ISNULL(i1.prenom,'') + ' --> Correct name : ' + i1.prenom_Correction ELSE '' END as [Individual first name 1]
	, CASE WHEN ISNULL(i2.nom,'')<>ISNULL(i2.nom_Correction,ISNULL(i2.nom,'')) THEN 'Wrong name : ' + ISNULL(i2.nom,'') + ' --> Correct name : ' + i2.nom_Correction ELSE '' END as [Individual name 2]
	, CASE WHEN ISNULL(i2.prenom,'')<>ISNULL(i2.prenom_Correction,ISNULL(i2.prenom,'')) THEN 'Wrong name : ' + ISNULL(i2.prenom,'') + ' --> Correct name : ' + i2.prenom_Correction ELSE '' END as [Individual first name 2]
	/*
	, CASE WHEN ISNULL(nom_individu1_acte_TD,'')<>ISNULL(nom_individu1_acte_TD_Correction,ISNULL(nom_individu1_acte_TD,'')) THEN 'Wrong name : ' + ISNULL(nom_individu1_acte_TD,'') + ' --> Correct name : ' + nom_individu1_acte_TD_Correction ELSE '' END as [Individual name 1]
	, CASE WHEN ISNULL(prenom_individu1_acte_TD,'')<>ISNULL(prenom_individu1_acte_TD_Correction,ISNULL(prenom_individu1_acte_TD,'')) THEN 'Wrong first name : ' + ISNULL(prenom_individu1_acte_TD,'') + ' --> Correct first name : ' + prenom_individu1_acte_TD_Correction ELSE '' END as [Individual first name 1]
	, CASE WHEN ISNULL(nom_individu2_acte_TD,'')<>ISNULL(nom_individu2_acte_TD_Correction,ISNULL(nom_individu2_acte_TD,'')) THEN 'Wrong name : ' + ISNULL(nom_individu2_acte_TD,'') + ' --> Correct name : ' + nom_individu2_acte_TD_Correction ELSE '' END as [Individual name  2]
	, CASE WHEN ISNULL(prenom_individu2_acte_TD,'')<>ISNULL(prenom_individu2_acte_TD_Correction,ISNULL(prenom_individu2_acte_TD,'')) THEN 'Wrong first name : ' + ISNULL(prenom_individu2_acte_TD,'') + ' --> Correct first nam : ' + prenom_individu2_acte_TD_Correction ELSE '' END as [Individual first name 2]
	*/
	FROM dbo.DataXmlEchantillonDetails (nolock) d 
	INNER JOIN dbo.DataXmlEchantillonEntete (nolock) ee ON ee.id_echantillon=d.id_echantillon
	INNER JOIN dbo.DataXmlTD_actes (nolock) a ON d.id_acte_TD=a.id
	LEFT JOIN dbo.DataXmlTD_individus (nolock) i1 ON i1.id_acte=a.id AND i1.rang=1
	LEFT JOIN dbo.DataXmlTD_individus (nolock) i2 ON i2.id_acte=a.id AND i2.rang=2
	LEFT JOIN #temp (nolock) t ON a.id = t.id_acte
	WHERE d.id_echantillon=@id_echantillon
	ORDER BY d.traite DESC, d.date_modification ASC

END

GO
