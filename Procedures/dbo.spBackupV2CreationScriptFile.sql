SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: [dbo].[spBackupV2CreationScriptFile] 'F794348C-07BC-475B-919C-363946E55AF4'

CREATE PROCEDURE [dbo].[spBackupV2CreationScriptFile] 
	-- Add the parameters for the stored procedure here
	@id_source [uniqueidentifier],
	@id_tache_log int=NULL,
	@id_tache_log_details int=NULL

AS
BEGIN
	
	SET NOCOUNT ON;

	--DECLARE @id_source  [uniqueidentifier]='F794348C-07BC-475B-919C-363946E55AF4'

    DECLARE @Command nvarchar(2000), @LineConnector nchar(1), @FileCreateChar nchar(1), @FileAppendString nchar(2), @FilePath nvarchar(120), @nom_dossier nvarchar(100),@str nvarchar(500) ,@PathV2 varchar(120)
	
	SELECT @nom_dossier=s.nom_format_dossier, @PathV2=chemin_dossier_general+'V2' FROM dbo.Sources s WITH (nolock) WHERE s.id_source =@id_source
	SET @str = N'rsync -a /bigvol/data/Sources/' + cast(@nom_dossier AS nvarchar(100)) + '/V2 ardbck01:/mnt/backup01/Sources/'  + cast(@nom_dossier AS nvarchar(100)) + ''
	SELECT @LineConnector = '&', @FileAppendString = ' > ',@FilePath = ' \\10.1.0.196\bigvol\Sources\workspace\V2Backup\script-rsyncV2toARDBCK01-'+ cast(@nom_dossier AS nvarchar(100))  +'.sh'

	SET @Command = 'echo ' + @str + @FileAppendString + @FilePath +char(13)+char(10) 
	PRINT @FilePath
	EXEC master..xp_cmdshell @Command, NO_OUTPUT

--DECLARE @FilePath nvarchar(120)
--SET @FilePath = 'master.dbo.xp_cmdshell ''osql -S 10.1.0.211 -U ARDTRAIT\Administrateur -P sa5shimi3$ -i " \\10.1.0.196\bigvol\Sources\workspace\V2Backup\' + 'script-rsyncV2toARDBCK01-78-YVELINES-AD.sh' + '"'''
--	EXEC master..xp_CMDShell @FilePath

	--IF OBJECT_ID('v_import_backupV2_Parameters') IS NOT NULL 
	--	BEGIN
	--		DROP TABLE v_import_backupV2_Parameters
	--		CREATE TABLE v_import_backupV2_Parameters (id int identity,Path_DossierBackUpV2 varchar(500), Path_DossierV2 varchar(500),id_tache_log int,id_tache_log_details int)
	--	END
	
	--INSERT INTO v_import_backupV2_Parameters (Path_DossierBackUpV2,Path_DossierV2,id_tache_log,id_tache_log_details) VALUES (@FilePath,@PathV2,@id_tache_log,@id_tache_log_details)

--	EXEC [dbo].[spBackUpV2_StartJobComparisonTailleDossier]
	
END
GO
