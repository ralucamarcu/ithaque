SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 26.02.2015
-- Description:	@filter = 1 -> fichiers acceptes
--				@filter = 2 -> fichiers rejetes
--				@filter = 0 -> fichiers pas traitee
-- =============================================
CREATE PROCEDURE spFichiersSelectionFichiersTraiteeParProjet 
	-- Add the parameters for the stored procedure here
	-- Test Run : spFichiersSelectionFichiersTraiteeParProjet '24644541-77AC-4B10-B098-395F353A61D7', 0
	@id_projet UNIQUEIDENTIFIER
	,@filter INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@filter = 1)
	BEGIN
		SELECT dxf.nom_fichier, t.nom AS nom_livraison, t.date_creation AS date_creation_livraison, MAX(la.date_log) AS date_traitement
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		LEFT JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet AND la.id_type_objet = 1
		WHERE t.id_projet = @id_projet AND dxee.id_statut IN (1,3)
		GROUP BY dxf.nom_fichier, t.nom, t.date_creation
	END
	IF (@filter = 2)
	BEGIN
		SELECT dxf.nom_fichier, t.nom AS nom_livraison, t.date_creation AS date_creation_livraison, MAX(la.date_log) AS date_traitement
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		LEFT JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet AND la.id_type_objet = 1
		WHERE t.id_projet = @id_projet AND dxee.id_statut = 2
		GROUP BY dxf.nom_fichier, t.nom, t.date_creation
	END
	IF (@filter = 0)
	BEGIN
		SELECT dxf.nom_fichier, t.nom AS nom_livraison, t.date_creation AS date_creation_livraison, NULL AS date_traitement
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet AND dxee.traite <> 1
		GROUP BY dxf.nom_fichier, t.nom, t.date_creation
	END
	
END
GO
