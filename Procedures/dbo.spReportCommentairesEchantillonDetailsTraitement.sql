SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 30/04/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReportCommentairesEchantillonDetailsTraitement] 
	@id_traitement as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT lf.nom_lot AS [Lot], CASE WHEN CHARINDEX('\', f.chemin_fichier)>0 THEN SUBSTRING(f.chemin_fichier, LEN(f.chemin_fichier)-CHARINDEX('\', REVERSE(f.chemin_fichier))+2, CHARINDEX('\', REVERSE(f.chemin_fichier))+1) ELSE f.chemin_fichier END AS [Fichier], d.id AS [Id ligne échantillon], d.id_acte_RC AS [Id acte], a.id_acte_xml AS [Id acte XML], d.message as [Comments]
	, CASE WHEN (d.erreur_saisie=1 OR d.erreur_selection=1 OR d.absence_saisie=1 OR d.erreur_zonage=1 OR d.erreur_image=1) THEN 'Oui' ELSE 'Non' END AS [Erreur comptabilisée]
	FROM dbo.DataXmlEchantillonDetailsRC (nolock) d 
	INNER JOIN dbo.DataXmlEchantillonEntete (nolock) ee ON ee.id_echantillon=d.id_echantillon
	INNER JOIN dbo.DataXmlRC_actes (nolock) a ON d.id_acte_RC=a.id
	INNER JOIN dbo.DataXml_Fichiers (nolock) f ON a.id_fichier=f.id_fichier
	INNER JOIN dbo.DataXml_lots_fichiers (nolock) lf ON ee.id_lot=lf.id_lot
	WHERE a.id_traitement=@id_traitement AND LEN(RTRIM(LTRIM(d.message)))>0
	ORDER BY lf.ordre, a.id_acte_xml, d.traite DESC, d.date_modification ASC

END

GO
