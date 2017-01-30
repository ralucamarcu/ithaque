SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_MAJ_Images_Traitements_Zonage] 
	-- Add the parameters for the stored procedure here
	-- Test Run: AEL_MAJ_Images_Traitements_Zonage '3871A253-F67C-43F0-B693-EF4D49F81440'
	@id_projet UNIQUEIDENTIFIER
	,@id_document UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @current_date DATETIME
   
    SET @current_date = GETDATE()
	INSERT INTO Images_Traitements(id_image, id_projet, date_creation, chemin)
	SELECT dxz.id_image, @id_projet AS id_projet, @current_date AS date_creation, m.[image] AS chemin
	FROM DataXmlRC_marges m(NOLOCK)
	INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK) ON m.[image] = dxz.[image]
	INNER JOIN DataXmlRC_actes a WITH (NOLOCK) ON m.id_acte = a.id
	WHERE m.id_marge IN (
	SELECT m.id_marge FROM DataXmlRC_marges m(NOLOCK)
	INNER JOIN DataXmlRC_actes a (NOLOCK) ON m.id_acte = a.id	
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON a.id_fichier = dxf.id_fichier
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	INNER JOIN Traitements t (NOLOCK) ON a.id_traitement = t.id_traitement 
	WHERE t.id_projet = @id_projet
	AND id_statut IN (1,3))
	GROUP BY dxz.id_image, m.[image]
	
	IF EXISTS (SELECT * FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images WHERE id_document = @id_document AND zones_a_traiter = 1)
	BEGIN
		UPDATE Images_Traitements
		SET zone_status = 2
		FROM Images_Traitements it WITH (NOLOCK)
		INNER JOIN [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images sdi WITH (NOLOCK) ON 
			REPLACE(REPLACE(it.chemin, '/images', ''), '/', '\') COLLATE database_default = sdi.path AND sdi.zones_a_traiter = 1
		WHERE it.id_projet = @id_projet AND id_document = @id_document
		
	END

	
END
GO
