SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spJobManagement_Selection_Info_Dernieres_Executions 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    --select * from Jobs_Ithaque_Management
    DECLARE @job_id UNIQUEIDENTIFIER
    CREATE TABLE #tmp (job_name VARCHAR(255), [enabled] INT, start_execution_date DATETIME, stop_execution_date DATETIME
		, last_outcome VARCHAR(255), last_outcome_message VARCHAR(MAX), last_run_date_string VARCHAR(255), last_run_duration INT
		, last_run_date DATETIME, sql_severity_error INT, step_message  VARCHAR(MAX), run_step_status VARCHAR(50))
		
	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT job_id
	FROM Jobs_Ithaque_Management	
	OPEN cursor_1
	FETCH cursor_1 INTO @job_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp(job_name, [enabled], start_execution_date, stop_execution_date, last_outcome, last_outcome_message
			, last_run_date_string, last_run_duration, sql_severity_error, step_message, run_step_status)
		SELECT TOP 1 sj.name AS job_name, sj.enabled, sja.start_execution_date, sja.stop_execution_date, 
			(CASE WHEN last_run_outcome = 0 THEN 'Fail'
				WHEN last_run_outcome = 1 THEN 'Success'
				WHEN last_run_outcome = 3 THEN 'Cancel'
			ELSE 'Unknown Error' END) AS last_outcome
			, last_outcome_message
			, CAST((CASE WHEN (LEN(last_run_time) = 6 AND last_run_date <> 0 )
				THEN( CAST(CAST(last_run_date AS VARCHAR(8)) AS DATETIME) + CAST(STUFF(STUFF(CAST(last_run_time AS VARCHAR(6)),5,0,':'),3,0,':') AS TIME(0)))
				WHEN (LEN(last_run_time) = 5 AND last_run_date <> 0 ) THEN  (CAST(CAST(last_run_date AS VARCHAR(8)) AS DATETIME))
				ELSE '' END) AS VARCHAR(250)) AS last_run_date_string
			, last_run_duration, sjh.sql_severity AS sql_severity_error, sjh.[message] AS step_message
			, (CASE WHEN sjh.run_status = 0 THEN 'Failed'
				WHEN sjh.run_status = 1 THEN 'Succeeded'
				WHEN sjh.run_status = 2 THEN 'Retry'
				WHEN sjh.run_status = 3 THEN 'Canceled'
				ELSE 'Unknown Error' END ) AS run_step_status
		FROM msdb.dbo.sysjobs sj WITH (NOLOCK)
		INNER JOIN msdb.dbo.sysjobactivity sja WITH (NOLOCK) ON sj.job_id = sja.job_id		
		INNER JOIN msdb.dbo.sysjobservers sjs WITH (NOLOCK) ON sj.job_id = sjs.job_id
		LEFT JOIN msdb.dbo.sysjobhistory sjh WITH (NOLOCK) ON sj.job_id = sjh.job_id AND step_id = 1
		WHERE sj.job_id = @job_id 
		ORDER BY start_execution_date DESC	
		FETCH cursor_1 INTO @job_id
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	UPDATE #tmp
	SET last_run_date = CONVERT(DATETIME, last_run_date_string, 120)
	
	SELECT job_name, [enabled], start_execution_date, stop_execution_date, last_outcome, last_outcome_message, last_run_duration
		, last_run_date, sql_severity_error, step_message, run_step_status
	FROM #tmp
	
	DROP TABLE #tmp
	
END
GO
