SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spFichiersSelectionInfoParFichier] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spFichiersSelectionInfoParFichier] 'EC13_output_13040_1827_D_3610.xml'
	@nom_fichier VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	
	SELECT dxf.id_fichier, dxf.nom_fichier, t.nom AS nom_livraison
		, (CASE WHEN dxee.id_statut = 2 THEN 'Rejeté' WHEN dxee.id_statut IN (1,3) THEN 'Accepté' ELSE 'Pas traitée' END) AS fichier_statut
		, dxf.conforme, dxf.nb_actes, dxf.nb_individus, dxf.nb_images
		, fd.date_creation AS date_creation_avant_prestataire, t.date_creation AS date_creation_livraison
		, fdf.nom AS nom_facture, t.date_verification_conformite
	FROM DataXml_fichiers dxf WITH (NOLOCK)
	INNER JOIN FichiersData fd WITH (NOLOCK) ON dxf.nom_fichier = fd.nom
	LEFT JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	LEFT JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
	LEFT JOIN FichiersData_Factures fdf WITH (NOLOCK) ON fd.id_facture = fdf.id_facture
	WHERE fd.nom = @nom_fichier


END

GO
