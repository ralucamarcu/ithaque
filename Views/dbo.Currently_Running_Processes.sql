SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW Currently_Running_Processes
AS
SELECT
OBJECT_NAME(objectid) as ObjectName
,SUBSTRING(stateText.text, (statement_start_offset/2)+1,
((CASE statement_end_offset
WHEN -1 THEN DATALENGTH(stateText.text)
ELSE statement_end_offset
END - statement_start_offset)/2) + 1) AS statement_text
,DB_Name(database_id) as DatabaseName
,req.cpu_time AS CPU_Time
,DATEDIFF(minute, last_request_start_time, getdate()) AS RunningMinutes
,req.Percent_Complete
,sess.HOST_NAME as RunningFrom
,LEFT(CLIENT_INTERFACE_NAME, 25) AS RunningBy
,sess.session_id AS SessionID
,req.blocking_session_id AS BlockingWith
,req.reads
,req.writes
,sess.[program_name]
,sess.login_name
,sess.status
,sess.last_request_start_time
,req.logical_reads

FROM
sys.dm_exec_requests req
INNER JOIN sys.dm_exec_sessions sess ON sess.session_id = req.session_id
AND sess.is_user_process = 1
CROSS APPLY
sys.dm_exec_sql_text(sql_handle) AS stateText
GO
