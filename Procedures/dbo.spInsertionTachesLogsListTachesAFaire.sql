SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionTachesLogsListTachesAFaire]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_source [uniqueidentifier], @id_tache [uniqueidentifier], @id_version int, @IntegerResult int, @id_projet [uniqueidentifier], @chemin_dossier varchar(255)

	DECLARE cursor_10 CURSOR FOR
	SELECT s.id_source, s.id_status_version_processus
	from dbo.Sources s 
	WHERE id_source NOT IN (SELECT id_source from taches_logs WITH (NOLOCK) WHERE id_status = 4)
		AND s.id_status_version_processus IN (0,1,2,3)
	OPEN cursor_10
	FETCH cursor_10 INTO @id_source, @id_version
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @id_version
		PRINT @id_source
		IF (@id_version = 0)
		BEGIN
			SET @chemin_dossier = (SELECT chemin_dossier_general + 'V1\' FROM dbo.Sources s WHERE s.id_source = @id_source)

			EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

			IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V1%')
			BEGIN
				SET @IntegerResult= 1
			END
			else
			BEGIN
				SET @IntegerResult= 0
			END
			IF @IntegerResult = 1
			BEGIN
				EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 1
				
			END
		END
		IF (@id_version = 1)
		BEGIN
			SET @chemin_dossier = (SELECT chemin_dossier_general + 'V2\' FROM dbo.Sources s WHERE s.id_source = @id_source)

			EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

			IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V2%')
			BEGIN
				SET @IntegerResult= 1
			END
			else
			BEGIN
				SET @IntegerResult= 0
			END
			IF @IntegerResult = 1
			BEGIN
				EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 2				
			END
			ELSE
			BEGIN
				EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 17
			END
		END
		IF (@id_version = 2)
		BEGIN
			SET @chemin_dossier = (SELECT chemin_dossier_general + 'V3\' FROM dbo.Sources s WHERE s.id_source = @id_source)

			EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

			IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V3%')
			BEGIN
				SET @IntegerResult= 1
			END
			else
			BEGIN
				SET @IntegerResult= 0
			END
			IF @IntegerResult = 1
			BEGIN
				EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 3
				
			END
		END
		IF (@id_version = 3)
		BEGIN
			SET @id_projet = (SELECT id_projet FROM dbo.Sources_Projets sp WHERE sp.id_source = @id_source)
			SET @chemin_dossier = (SELECT p.chemin_dossier_general + 'V4\' FROM dbo.Projets p WHERE p.id_projet = @id_projet)

			EXEC [dbo].[spImportFichiers] @path = @chemin_dossier, @suppression_tables = 1

			IF EXISTS (SELECT * FROM dbo.Files f WHERE f.FILE_PATH LIKE '%V4%')
			BEGIN
				SET @IntegerResult= 1
			END
			else
			BEGIN
				SET @IntegerResult= 0
			END	
			IF @IntegerResult = 1
			BEGIN
				EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = @id_projet, @id_tache = 4
				
			END
		END
		FETCH cursor_10 INTO @id_source, @id_version
	END
	CLOSE cursor_10
	DEALLOCATE cursor_10

END
GO
