SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [fctValidationV1V2V3V4TacheExistent]
(
	-- Add the parameters for the function here
	@id_source [uniqueidentifier]
	,@id_projet [uniqueidentifier] = NULL
	,@id_tache int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @IntegerResult int
	DECLARE @chemin_dossier varchar(255)

	-- Add the T-SQL statements to compute the return value here
	IF (@id_tache = 1)
	BEGIN
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V1\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V1%')
		BEGIN
			SET @IntegerResult = 1
		END
		else
		BEGIN
			SET @IntegerResult = 0
		END
	END
	IF (@id_tache = 2)
	BEGIN
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V2\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V2%')
		BEGIN
			SET @IntegerResult = 1
		END
		else
		BEGIN
			SET @IntegerResult = 0
		END
	END
	IF (@id_tache = 3)
	BEGIN	
		SET @chemin_dossier = (SELECT chemin_dossier_general + 'V3\' FROM dbo.Sources s WHERE s.id_source = @id_source)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V3%')
		BEGIN
			SET @IntegerResult = 1
		END
		else
		BEGIN
			SET @IntegerResult = 0
		END
	END
	IF (@id_tache = 4)
	BEGIN
		SET @chemin_dossier = (SELECT p.chemin_dossier_general + 'V4\' FROM dbo.Projets p WHERE p.id_projet = @id_projet)

		EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

		IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V4%')
		BEGIN
			SET @IntegerResult = 1
		END
		else
		BEGIN
			SET @IntegerResult = 0
		END	
	END

	-- Return the result of the function
	RETURN @IntegerResult

END
GO
