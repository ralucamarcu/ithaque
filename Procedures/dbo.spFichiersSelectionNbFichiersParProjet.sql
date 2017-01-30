SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spFichiersSelectionNbFichiersParProjet 
	-- Add the parameters for the stored procedure here
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
		SELECT count(distinct dxf.nom_fichier) as Nb_fichiers
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		LEFT JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet AND la.id_type_objet = 1
		WHERE t.id_projet = @id_projet AND dxee.id_statut IN (1,3)
		
	END
	IF (@filter = 2)
	BEGIN
		SELECT count(distinct dxf.nom_fichier) as Nb_fichiers
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		LEFT JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet AND la.id_type_objet = 1
		WHERE t.id_projet = @id_projet AND dxee.id_statut = 2
	END
	IF (@filter = 0)
	BEGIN
		SELECT count(distinct dxf.nom_fichier) as Nb_fichiers
		FROM DataXml_fichiers dxf WITH (NOLOCK)
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet AND dxee.traite <> 1
	END
END
GO
