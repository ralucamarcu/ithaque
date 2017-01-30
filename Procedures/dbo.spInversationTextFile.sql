SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	@format = 1 => copy ".\source_principale\EC61076_1793-1802_NMD_0001.jpg" ".\source_principale_temp\EC61076_1793-1802_NMD_0153.jpg"
--				@format = 2 => copy ".\erreur_source_communale\EC31048_1823-1832_NMD_0001.jpg" ".\source_communale\EC31048_1823-1832_NMD_0485.jpg"
--				@format = 3 => copy ".\erreur_source_principale\EC73307_1793-1813_D_0001.jpg" ".\source_principale\EC73307_1793-1813_D_0086.jpg"


-- =============================================
CREATE PROCEDURE [dbo].[spInversationTextFile]
	-- Add the parameters for the stored procedure here
	-- Tets Run : spInversationTextFile '\\10.1.0.196\bigvol\Projets\p99-60-OISE-AD\workspace\scripts\', 'BAT_renameCHEVRIERES_1804-1831NMD-20150210.txt'
	@path VARCHAR(400)
	,@file_name VARCHAR(255)
	,@id_source UNIQUEIDENTIFIER
	,@format INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @path_general VARCHAR(500), @sql_command NVARCHAR(MAX) = '', @date_creation DATETIME = GETDATE()
    SET @path_general = (CASE WHEN RIGHT(@path,1) = '\' THEN @path ELSE @path + '\' END) + @file_name
	IF OBJECT_ID('InversionInfo') IS NOT NULL 
		DROP TABLE InversionInfo
	CREATE TABLE InversionInfo (tache VARCHAR(50), nom_initial VARCHAR(255), nom_final VARCHAR(255)) 

	SET @sql_command = @sql_command	+ 'BULK INSERT InversionInfo '  + CHAR(13) + CHAR(10)
	SET @sql_command = @sql_command	+ 'FROM ''' + CAST(@path_general AS NVARCHAR(500)) + '''' + CHAR(13) + CHAR(10)
	SET @sql_command = @sql_command	+ 'WITH( '  + CHAR(13) + CHAR(10)
	SET @sql_command = @sql_command	+ 'FIELDTERMINATOR='' '', '  + CHAR(13) + CHAR(10)
	SET @sql_command = @sql_command	+ 'ROWTERMINATOR = ''\n'' '  + CHAR(13) + CHAR(10)
	SET @sql_command = @sql_command	+ ') '  + CHAR(13) + CHAR(10)	
	
	PRINT @sql_command
	EXEC(@sql_command)
	 
	--DELETE FROM InversionInfo WHERE tache <> 'copy'
	
	IF (@format = 1)
	BEGIN
		UPDATE InversionInfo
		SET nom_initial = REPLACE(REPLACE(nom_initial, '".\source_principale\', ''), '"', '')
			,nom_final = REPLACE(REPLACE(nom_final, '".\source_principale_temp\', ''), '"', '')
	END
	ELSE
	IF (@format = 2)
	BEGIN
		UPDATE InversionInfo
		SET nom_initial = REPLACE(REPLACE(nom_initial, '".\erreur_source_communale\', ''), '"', '')
			,nom_final = REPLACE(REPLACE(nom_final, '".\source_communale\', ''), '"', '')
	END
	ELSE
	IF (@format = 3)
	BEGIN
		UPDATE InversionInfo
		SET nom_initial = REPLACE(REPLACE(nom_initial, '".\erreur_source_principale\', ''), '"', '')
			,nom_final = REPLACE(REPLACE(nom_final, '".\source_principale\', ''), '"', '')
	END
	
	INSERT INTO InversionInfoLog(script_applied, path_projet, id_source, date_creation) VALUES (@file_name, @path, @id_source, @date_creation)

END
GO
