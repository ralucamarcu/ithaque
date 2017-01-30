SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelection_fichiers_reecriture_valide]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT f.id_fichier-- f.nom_fichier --, COUNT(f.id_fichier), f.id_fichier
	FROM dbo.DataXml_lots_fichiers AS lf WITH (NOLOCK) 
	INNER JOIN dbo.DataXml_fichiers AS f WITH (NOLOCK) ON lf.id_lot = f.id_lot AND ISNULL(f.rejete, 0) = 0 AND ISNULL(f.ignore_export_publication, 0) = 0 
	INNER JOIN dbo.DataXmlEchantillonEntete de (nolock) ON lf.id_lot = de.id_lot
	INNER JOIN dbo.Traitements AS t WITH (NOLOCK) ON lf.id_traitement = t.id_traitement
	WHERE t.livraison_annulee=0 AND de.id_statut IN (1,3)
	GROUP BY f.id_fichier--f.nom_fichier



END
GO
