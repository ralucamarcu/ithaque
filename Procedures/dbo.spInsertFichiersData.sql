SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric ROBILLARD
-- Create date: 06/05/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertFichiersData]
	@id_projet uniqueidentifier,
	@fichier varchar(512)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.FichiersData (nom, id_projet) VALUES (@fichier, @id_projet)
	
	
	
END


	
GO
