SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Frédérci ROBILLARD
-- Create date: 24/02/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spVerificationExistenceFichier] 
	@id_projet UNIQUEIDENTIFIER, 
	@nom_fichier VARCHAR(250)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @id_fichier AS UNIQUEIDENTIFIER
	SELECT TOP 1 id_fichier FROM FichiersData (NOLOCK) WHERE id_projet=@id_projet AND nom LIKE REPLACE(@nom_fichier, 'outputIdOk', 'output')

END

GO
