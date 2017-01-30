SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 01.12.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spTachesEnCourse]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @import_image_job_name VARCHAR(255), @import_img_running BIT = 0, @cmdline VARCHAR(2000)
		, @current_date DATETIME, @import_img_stop_job_date DATETIME, @sec_running INT
	
	CREATE TABLE #tmp (Running_Jobs VARCHAR(255), Starting_time DATETIME, Has_been_running INT)
	CREATE TABLE #tmp2 (cmdOutput VARCHAR(500))

	SET @current_date = GETDATE()
	
	INSERT INTO #tmp
	SELECT J.name AS Running_Jobs, JA.Start_execution_date AS Starting_time,
		DATEDIFF(ss, JA.Start_execution_date,GETDATE()) AS Has_been_running
	FROM msdb.dbo.sysjobactivity JA
	INNER JOIN msdb.dbo.sysjobs J ON J.job_id=JA.job_id
	WHERE job_history_id IS NULL AND start_execution_date IS NOT NULL
	ORDER BY start_execution_date
	
	--import_image jp2000/toate restu
	SELECT TOP 1 @import_image_job_name = name, @import_img_stop_job_date = stop_execution_date
	FROM msdb.dbo.sysjobactivity sa 
	INNER JOIN msdb.dbo.sysjobs s ON sa.job_id = s.job_id
	WHERE s.name IN ('AEL Traitement Images JP2000 test') AND stop_execution_date IS NOT NULL
	ORDER BY start_execution_date DESC

	SET @cmdline = 'tasklist'	  
	INSERT #tmp2
	EXEC master.dbo.xp_cmdshell @cmdline

	IF EXISTS(SELECT * FROM #tmp2 WHERE cmdOutput LIKE 'import_image%')
	BEGIN
		SET @import_img_running = 1
		PRINT @import_img_stop_job_date
		PRINT @current_date
		SET @sec_running = DATEDIFF(SECOND, @import_img_stop_job_date, @current_date)
		PRINT @sec_running
	END
	
	IF @import_img_running = 1
	BEGIN
		INSERT INTO #tmp (Running_Jobs, Starting_time, Has_been_running)
		VALUES (@import_image_job_name, @import_img_stop_job_date, @sec_running)
	END
	
	SELECT * FROM #tmp
	
	DROP TABLE #tmp
	
END
GO
