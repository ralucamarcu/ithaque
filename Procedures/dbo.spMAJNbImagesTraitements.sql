SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spMAJNbImagesTraitements
	-- Add the parameters for the stored procedure here
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nb_images INT
	SET @nb_images = (SELECT SUM(dxf.nb_images)
			FROM Traitements t WITH (NOLOCK)
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON t.id_traitement = dxf.id_traitement
			WHERE t.id_traitement = @id_traitement)
	
	UPDATE Traitements
	SET nb_images = @nb_images
	WHERE id_traitement = @id_traitement
END
GO
