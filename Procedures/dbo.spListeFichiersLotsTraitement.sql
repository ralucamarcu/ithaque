SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 13/11/2013
-- Description:	Renvoie la liste des fichiers pour tous les lots du traitement
-- =============================================
CREATE PROCEDURE [dbo].[spListeFichiersLotsTraitement] 
	@id_traitement_param as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @id_traitement int
SET @id_traitement = @id_traitement_param
	
--LISTE DES FICHIERS PAR LOT
SELECT t.nom AS [Livraison], lf.nom_lot AS [Lot], SUBSTRING(f.chemin_fichier, LEN(f.chemin_fichier)-CHARINDEX('\', REVERSE(f.chemin_fichier))+2,LEN(f.chemin_fichier)) AS Fichier, CASE WHEN ISNULL(f.rejete, 0) = 0 THEN se.libelle ELSE 'Invalidé' END AS [Statut]
FROM dbo.DataXml_Fichiers f (nolock)
INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) ON f.id_lot=lf.id_lot
INNER JOIN dbo.Traitements (nolock) t ON lf.id_traitement=t.id_traitement
LEFT JOIN dbo.DataXmlEchantillonEntete ee ON lf.id_lot=ee.id_lot
LEFT JOIN dbo.Statuts_Echantillons se (NOLOCK) ON ee.id_statut=se.id_statut
WHERE t.id_traitement=@id_traitement
ORDER BY t.nom, lf.ordre, f.chemin_fichier

END

GO
