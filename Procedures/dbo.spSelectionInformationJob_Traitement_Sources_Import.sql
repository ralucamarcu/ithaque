SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 01.12.2014
-- Description:	@IntegerResult = 1 => le travail 'Traitement V1 Import' a pris fin avec succès
--				@IntegerResult = 2 => le travail 'Traitement V1 Import' n'est pas terminé
--				@IntegerResult = 0 => le travail 'Traitement V1 Import' s'est terminé par un échec
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionInformationJob_Traitement_Sources_Import] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spSelectionInformationJob_Traitement_Sources_Import] 'Traitement V2 Import Doubles'
	@job_name varchar(255)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IntegerResult INT, @sql_message_id INT, @sql_severity INT, @stop_execution_date DATETIME
	
	SELECT TOP 1 @sql_message_id = sql_message_id, @sql_severity = sql_severity, @stop_execution_date = stop_execution_date
	FROM msdb.dbo.sysjobhistory sjh
	INNER JOIN msdb.dbo.sysjobs sj ON sjh.job_id = sj.job_id
	INNER JOIN msdb.dbo.sysjobactivity sja ON sjh.job_id = sja.job_id 
	WHERE sj.name = @job_name AND step_id = 1
	ORDER BY run_date DESC, run_time DESC
	
	IF (@sql_message_id = 0) AND (@sql_severity = 0) AND (@stop_execution_date IS NOT NULL)
	BEGIN
		SET @IntegerResult = 1
	END
	IF (@sql_message_id = 0) AND (@sql_severity = 0) AND (@stop_execution_date IS NULL)
	BEGIN
		SET @IntegerResult = 2
	END
	IF ((@sql_message_id <> 0) OR (@sql_severity <> 0)) 
	BEGIN
		SET @IntegerResult = 0
	END
	
	SELECT @IntegerResult AS IntegerResult
	
END
GO
