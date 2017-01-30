SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Start_import_images_zones]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	--EXEC master.dbo.xp_cmdshell "start import_images_jp2.bat", no_output
	
	DECLARE @obj INT
	EXEC sp_oacreate 'WScript.Shell', @obj OUT
	EXEC sp_oamethod @obj, 'Run("c:\sys\psexec \\10.1.0.236 -u NFARD\raluca.marcu -p pass;1234 c:\Applications\import_images_zones.bat", 0)'
	EXEC sp_oadestroy @obj
END
GO
