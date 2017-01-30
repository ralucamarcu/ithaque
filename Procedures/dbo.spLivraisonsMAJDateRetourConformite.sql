SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spLivraisonsMAJDateRetourConformite
	-- Add the parameters for the stored procedure here
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE Traitements
	SET date_retour_conformite_xml = GETDATE()
	WHERE id_traitement = @id_traitement
END
GO
