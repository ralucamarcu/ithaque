SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Status_Jobs]
	-- Add the parameters for the stored procedure here
	-- Test Run : [AEL_Status_Jobs] 'AEL Traitement XML Finalisation Zonage'
	@job_name VARCHAR(255)  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@job_name = 'AEL Check Processes Management')
	BEGIN
		SELECT [enabled] AS RunningInteger 
		FROM msdb.dbo.sysjobs sj
		INNER JOIN msdb.dbo.sysjobactivity sja ON sj.job_id = sja.job_id
		WHERE name = @job_name
		RETURN 
	END
	
	IF EXISTS (SELECT * FROM msdb.dbo.sysjobs sj
			INNER JOIN msdb.dbo.sysjobactivity sja ON sj.job_id = sja.job_id
			WHERE name = @job_name)
	BEGIN	
		SELECT (CASE WHEN start_execution_date IS NOT NULL AND stop_execution_date IS NULL THEN 1 ELSE 0 END) AS RunningInteger
		FROM msdb.dbo.sysjobs sj
		INNER JOIN msdb.dbo.sysjobactivity sja ON sj.job_id = sja.job_id
		WHERE name = @job_name
	END	
	ELSE
	BEGIN
		SELECT 0 AS RunningInteger
	END
END



GO
