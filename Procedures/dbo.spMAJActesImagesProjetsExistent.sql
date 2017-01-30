SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 26.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJActesImagesProjetsExistent]
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJActesImagesProjetsExistent '\\10.1.0.196\bigvol\Projets\p99-06-ALPES-MARITIMES-AD\V4\', '9219D296-1BEB-4E37-9ABF-A71B592B2421'
	 @v4_general_path VARCHAR(150)
	,@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DataXmlRC_zones
	SET id_image = tli.id_image
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN dbo.DataXmlRC_zones dxz WITH (NOLOCK)
		ON LEFT(@v4_general_path, LEN(@v4_general_path) - 1) + REPLACE(REPLACE (dxz.image,SUBSTRING(dxz.image,LEN(dxz.image) 
				- CHARINDEX('/',REVERSE(dxz.image))+2,LEN(dxz.image)), ''),'/','\') = tli.path_destination
		AND SUBSTRING(dxz.image,LEN(dxz.image) - CHARINDEX('/',REVERSE(dxz.image))+2,LEN(dxz.image)) = tli.nom_fichier_image_destination
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	AND tli.id_tache = 4
	AND dxa.id_fichier IN (SELECT id_fichier FROM DataXml_fichiers dxf WITH (NOLOCK)
						INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
						 WHERE id_projet = @id_projet)
END
GO
