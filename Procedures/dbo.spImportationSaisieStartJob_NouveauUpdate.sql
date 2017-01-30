SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImportationSaisieStartJob_NouveauUpdate] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @sql nvarchar(500) = N''
	set @sql = @sql + N' use msdb' + char(10) + char(13)
	set @sql = @sql + N' exec [PRESQL04].msdb.dbo.sp_start_job ' + char(10) + char(13)
	set @sql = @sql + N' @job_name = ''Importation Saisie Nouveau Update''' + char(10) + char(13)
	set @sql = @sql + N' ,@server_name=''192.168.0.138'' ' + char(10) + char(13)
	
	PRINT @sql
	EXECUTE sp_executesql  @sql
END
GO
