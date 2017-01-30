SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 14/09/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReportDetailsEchantillonRC] 
	@id_echantillon as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
--Concaténation des champs image pour chaque acte de l'échantillon
SELECT z1.id_acte,
       STUFF( (SELECT DISTINCT ', ' + cast(image AS varchar(1024))
               FROM DataXmlRC_zones AS z2
               INNER JOIN dbo.DataXmlEchantillonDetailsRC AS d2 ON d2.id_acte_Rc=z2.id_acte
               WHERE z1.id_acte = z2.id_acte AND d2.id_echantillon=@id_echantillon
               FOR XML PATH('')),1 ,1, '') AS image
INTO #temp
FROM DataXmlRC_zones AS z1
INNER JOIN dbo.DataXmlEchantillonDetailsRC AS d1 ON d1.id_acte_RC=z1.id_acte
WHERE d1.id_echantillon=@id_echantillon
GROUP BY z1.id_acte;

SELECT d.id AS [Id ligne échantillon], d.id_acte_RC AS [Id acte], d.message AS [Comments], cast(d.traite as tinyint) AS [Processed], a.id_acte_xml AS [Id acte XML], f.chemin_fichier AS [XML file], cast(erreur_saisie as tinyint) AS [Data entry error], cast(erreur_selection as tinyint) AS [Selection error], cast(absence_saisie as tinyint) AS [Missing data entry], cast(erreur_zonage as tinyint) AS [Zoning error], cast(erreur_image as tinyint) AS [Picture error], t.image AS [Picture file]
	FROM dbo.DataXmlEchantillonDetailsRC (nolock) d 
	INNER JOIN dbo.DataXmlEchantillonEntete (nolock) ee ON ee.id_echantillon=d.id_echantillon
	INNER JOIN dbo.DataXmlRC_actes (nolock) a ON d.id_acte_RC=a.id
	INNER JOIN dbo.DataXml_Fichiers (nolock) f ON a.id_fichier=f.id_fichier
	LEFT JOIN #temp (nolock) t ON a.id = t.id_acte
	WHERE d.id_echantillon=@id_echantillon
	ORDER BY d.traite DESC, d.date_modification ASC

END

GO
