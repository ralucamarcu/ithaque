SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <20/08/2015>
-- Description:	<Description,,>
-- =============================================
-- Test Run : [dbo].[spBackupV2_ComparisonDossierTaille] '\\10.1.0.196\bigvol\Projets\p99-95-VALDOISE-AD\V4'

CREATE PROCEDURE [dbo].[spBackupV2_ComparisonDossierTaille]
	@chemin_V2 varchar(500),
	@chemin_V2_Backup varchar(500),
	@id_tache_log int,
	@id_tache_log_details int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @size int, @size_backup int
	CREATE TABLE	#Files(row VARCHAR(400))
	CREATE TABLE	#Files_backup(row VARCHAR(400))
	CREATE TABLE #tmp_t(filename varchar(255), filesize varchar(255))
	CREATE TABLE #tmp_t_backup(filename varchar(255), filesize varchar(255))

	DECLARE @cmd varchar(800),@cmd_backup varchar(800)
	SET @cmd =  'DIR  ' + @chemin_V2 + '/s'
	SET @cmd_backup =  'DIR  ' + @chemin_V2_Backup + '/s'

	INSERT	#Files(row)
	EXEC	master..xp_cmdshell @cmd

	INSERT INTO #tmp_t
	SELECT	fileName,fileSize
	FROM	(SELECT	SUBSTRING(row, 37, 400) AS fileName,
				REPLACE(REPLACE(SUBSTRING(row, 18, 19), CHAR(160), ''), CHAR(32), '') AS fileSize
			 FROM	#Files ) AS d
	WHERE	fileSize NOT LIKE '%[^0-9]%'
		
	SET @size = (SELECT cast(cast(sum(cast(filesize AS bigint)) AS float)/cast(1073741824 AS float) AS int) FROM #tmp_t)

	INSERT	#Files_backup(row)
	EXEC	master..xp_cmdshell @cmd_backup

	INSERT INTO #tmp_t_backup
	SELECT	fileName,fileSize
	FROM	(SELECT	SUBSTRING(row, 37, 400) AS fileName,
				REPLACE(REPLACE(SUBSTRING(row, 18, 19), CHAR(160), ''), CHAR(32), '') AS fileSize
			 FROM	#Files_backup) AS d
	WHERE	fileSize NOT LIKE '%[^0-9]%'
		
	SET @size_backup = (SELECT cast(cast(sum(cast(filesize AS bigint)) AS float)/cast(1073741824 AS float) AS int) FROM #tmp_t_backup)

	--SELECT @size as TailleDossierV2, @size_backup as TailleDossierV2Backup
	IF (@size= @size_backup)
		BEGIN
			EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
			EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		END

	DROP TABLE #tmp_t_backup
	DROP TABLE #Files_backup
	DROP TABLE #tmp_t
	DROP TABLE #Files
END
GO
