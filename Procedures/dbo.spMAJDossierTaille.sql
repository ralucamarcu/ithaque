SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJDossierTaille]
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJDossierTaille '\\10.1.0.196\bigvol\Projets\p99-14-CALVADOS-AD',NULL
	@chemin varchar(500)
	,@id_projet [uniqueidentifier] = NULL
	,@id_source [uniqueidentifier] = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @size int
	CREATE TABLE	#Files(row VARCHAR(400))
	CREATE TABLE #tmp_t(filename varchar(255), filesize varchar(255))
	DECLARE @cmd varchar(800)
	SET @cmd =  'DIR  ' + @chemin + '/s'

	INSERT	#Files(row)
	EXEC	master..xp_cmdshell @cmd

	INSERT INTO #tmp_t
	SELECT	fileName,fileSize
	FROM	(SELECT	SUBSTRING(row, 37, 400) AS fileName,
				REPLACE(REPLACE(SUBSTRING(row, 18, 19), CHAR(160), ''), CHAR(32), '') AS fileSize
			FROM	#Files
		) AS d
	WHERE	fileSize NOT LIKE '%[^0-9]%'

	
	set @size = (SELECT cast(cast(sum(cast(filesize AS bigint)) AS float)/cast(1073741824 AS float) AS int) FROM #tmp_t)

	IF (@id_projet IS NOT NULL)
	BEGIN
		UPDATE dbo.Projets
		SET dbo.Projets.taille_dossier_GB = @size
		WHERE dbo.Projets.id_projet = @id_projet
	END
	IF (@id_source IS NOT NULL)
	BEGIN
		UPDATE dbo.Sources
		SET taille_dossier_GB = @size
		WHERE dbo.Sources.id_source = @id_source
	END

	DROP TABLE #tmp_t
	DROP TABLE	#Files
END
GO
