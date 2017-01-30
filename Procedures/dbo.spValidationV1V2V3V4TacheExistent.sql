SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spValidationV1V2V3V4TacheExistent] 
	-- Add the parameters for the stored procedure here
	@id_source [uniqueidentifier]
	,@id_projet [uniqueidentifier] = NULL
	,@id_tache int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @chemin_dossier varchar(255)

	IF (@id_tache = 1)
	BEGIN
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V1\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V1%')
		BEGIN
			SELECT 1 AS IntegerResult
		END
		else
		BEGIN
			SELECT 0 AS IntegerResult
		END
	END
	IF (@id_tache = 2)
	BEGIN
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V2\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V2%')
		BEGIN
			SELECT 1 AS IntegerResult
		END
		else
		BEGIN
			SELECT 0 AS IntegerResult
		END
	END
	IF (@id_tache = 3)
	BEGIN	
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V3\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V3%')
		BEGIN
			SELECT 1 AS IntegerResult
		END
		else
		BEGIN
			SELECT 0 AS IntegerResult
		END
	END
	IF (@id_tache = 4)
	BEGIN
		SET @chemin_dossier = (SELECT p.chemin_dossier_general + 'V4\' FROM dbo.Projets p WHERE p.id_projet = @id_projet)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V4%')
		BEGIN
			SELECT 1 AS IntegerResult
		END
		else
		BEGIN
			SELECT 0 AS IntegerResult
		END	
	END
END
GO
