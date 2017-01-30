SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Start_Finalise_Geonames] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_document UNIQUEIDENTIFIER
	
	SELECT @id_document = id_document
	FROM AEL_Parametres 
	WHERE principal = 1 	
	
	EXEC [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_maj_images_actes_geonames @id_document = @id_document

	
END
GO
