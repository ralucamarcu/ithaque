SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spMAJImagesZones 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DataXmlRC_zones
	SET id_image = tli.id_image
	FROM DataXmlRC_zones dxz WITH (NOLOCK)
	INNER JOIN Taches_Images_Logs tli WITH (NOLOCK)
		ON dxz.image = REPLACE((REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination))
		, 'V4\images', '\images')), '\', '/') + tli.nom_fichier_image_destination AND id_tache = 4
	WHERE dxz.id_image IS NULL
END
GO
