SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vue_Correction_Individus_EchantillonRC]
AS
SELECT     TOP (100) PERCENT e.id_echantillon, a.fichier_xml_acte, i.id AS id_individu, i.id_individu_xml, i.principal, i.nom, i.prenom, i.age, i.date_naissance, 
                      i.annee_naissance, i.calendrier_date_naissance, i.nom_Correction, i.prenom_Correction, i.age_Correction, i.date_naissance_Correction, 
                      i.annee_naissance_Correction, i.calendrier_date_naissance_Correction, a.id_acte_xml
FROM         dbo.DataXmlRC_individus AS i WITH (nolock) INNER JOIN
                      dbo.DataXmlRC_actes AS a WITH (nolock) ON i.id_acte = a.id INNER JOIN
                      dbo.DataXmlEchantillonDetailsRC AS e WITH (nolock) ON a.id = e.id_acte_RC
WHERE     (e.erreur_saisie = 1) OR
                      (e.erreur_selection = 1) OR
                      (e.absence_saisie = 1)
ORDER BY a.fichier_xml_acte

GO
