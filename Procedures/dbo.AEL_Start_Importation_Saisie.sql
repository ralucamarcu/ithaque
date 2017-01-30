SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Start_Importation_Saisie]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
	DECLARE @obj INT
	EXEC sp_oacreate 'WScript.Shell', @obj OUT
	EXEC sp_oamethod @obj, 'Run("c:\sys\psexec \\10.1.0.236 -u NFARD\raluca.marcu -p pass;1234 c:\Applications\Importation_Saisie.bat", 0)'
	EXEC sp_oadestroy @obj
END
GO
