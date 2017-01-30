SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionStatusImportJobs] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmp (job_name VARCHAR(255))
	--INSERT INTO #tmp	
	--SELECT sj.name
	--FROM msdb.dbo.sysjobactivity AS sja
	--INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
	--WHERE sja.start_execution_date IS NOT NULL
	--   AND sja.stop_execution_date IS NULL

	INSERT INTO #tmp (job_name)
	SELECT name FROM 
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;','EXEC msdb..sp_help_job')
	WHERE current_execution_status=1
	   
	IF ( (SELECT COUNT(*) FROM #tmp WHERE job_name IN ('Traitement V1 Import', 'Traitement V2 Import', 'Traitement V2 Import Doubles',
			'Traitement V3 Import', 'V2 Import Avant Traitement', 'Traitement V4 Import')) > 0) OR 
			((SELECT COUNT(*) FROM Taches_Logs WHERE id_status = 3 and id_tache in (1,2,3,7,9)) > 0)
	BEGIN
		SELECT 1 AS StatusRunning
	END
	ELSE
	BEGIN
		SELECT 0 AS StatusRunning
	END
DROP TABLE #tmp
END
GO
