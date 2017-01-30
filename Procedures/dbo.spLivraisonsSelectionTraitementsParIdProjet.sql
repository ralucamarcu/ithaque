SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [spLivraisonsSelectionTraitementsParIdProjet] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spLivraisonsSelectionTraitementsParIdProjet] '0A8314D6-E614-4E68-A7F1-DDD1F73454FD'
	@id_projet UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM Traitements_Info  WITH (NOLOCK) WHERE id_projet = @id_projet
END
GO
