SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spValidationV3TacheExistent 
	-- Add the parameters for the stored procedure here
	@id_source [uniqueidentifier]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @chemin_dossier_v3 varchar(255)
	SET @chemin_dossier_v3 = (SELECT chemin_dossier_general + 'V3\' FROM dbo.Sources s WHERE s.id_source = @id_source)

	EXEC [dbo].[spImportFichiers] @path = @chemin_dossier_v3, @suppression_tables = 1

	IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V3%')
	BEGIN
		SELECT 1 AS IntegerResult
    END
	else
	BEGIN
		SELECT 0 AS IntegerResult
    END
END
GO
