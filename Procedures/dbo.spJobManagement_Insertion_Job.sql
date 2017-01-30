SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spJobManagement_Insertion_Job
	-- Add the parameters for the stored procedure here
	@job_name VARCHAR(255)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [Ithaque].[dbo].[Jobs_Ithaque_Management] ([job_name] ) VALUES (@job_name)
		
	UPDATE [Jobs_Ithaque_Management]
	SET job_id = sj.job_id
	FROM [Jobs_Ithaque_Management] jim 
	INNER JOIN msdb.dbo.sysjobs sj ON jim.job_name = sj.name
	WHERE jim.job_id IS NULL
	
	UPDATE Jobs_Ithaque_Management
	SET last_outcome_id = sj.last_run_outcome
		, last_outcome_message = sj.last_outcome_message
		, last_run_date =  sj.last_run_date
	FROM Jobs_Ithaque_Management ji WITH (NOLOCK)
	INNER JOIN msdb.dbo.sysjobservers sj ON ji.job_id = sj.job_id
	WHERE ji.last_outcome_id IS NULL
END
GO
