SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spFichiersSelectionInfoParFichierDerniereLivraison] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spFichiersSelectionInfoParFichierDerniereLivraison] 'EC13_output_13040_1827_D_3610.xml'
	@nom_fichier VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT TOP 1 dxf.id_fichier, dxf.nom_fichier, t.nom AS nom_derniere_livraison
		, (CASE WHEN dxee.id_statut = 2 THEN 'Rejeté' WHEN dxee.id_statut IN (1,3) THEN 'Accepté' ELSE 'Pas traitée' END) AS Derniere_statut
		, dxf.conforme, dxf.nb_actes, dxf.nb_individus, dxf.nb_images
	FROM DataXml_fichiers dxf WITH (NOLOCK)
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
	WHERE nom_fichier = @nom_fichier
	ORDER BY dxf.date_creation DESC

END
GO
