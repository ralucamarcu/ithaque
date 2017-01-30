SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 27.11.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSupprimerSource] 
	-- Add the parameters for the stored procedure here
	-- Test Run: [spSupprimerSource] '70087AFC-6F13-4B55-9386-180132D25244'
	@id_source UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM dbo.Sources_Images_Types WHERE id_source = @id_source
	DELETE FROM Taches_Logs WHERE id_source = @id_source
	DELETE FROM Sources WHERE id_source = @id_source

END

GO
