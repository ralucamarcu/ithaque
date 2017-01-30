SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 01.12.2014
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[spSelectionTachesEnCourse_old]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @import_image_job_name varchar(255), @import_img_running bit = 0, @cmdline varchar(2000)
		, @current_date datetime, @import_img_stop_job_date datetime, @sec_running int
	
	create table #tmp (Running_Jobs varchar(255), Starting_time datetime, Has_been_running int)
	CREATE TABLE #tmp2 (cmdOutput VARCHAR(500))

	set @current_date = GETDATE()
	
	insert into #tmp
	SELECT J.name as Running_Jobs, JA.Start_execution_date As Starting_time,
		datediff(ss, JA.Start_execution_date,getdate()) as Has_been_running
	FROM msdb.dbo.sysjobactivity JA
	inner JOIN msdb.dbo.sysjobs J ON J.job_id=JA.job_id
	WHERE job_history_id is null AND start_execution_date is NOT NULL
	ORDER BY start_execution_date
	
	--import_image jp2000/toate restu
	select top 1 @import_image_job_name = name, @import_img_stop_job_date = stop_execution_date
	from msdb.dbo.sysjobactivity sa 
	inner join msdb.dbo.sysjobs s on sa.job_id = s.job_id
	where s.name in ('AEL Traitement Images JP2000 test') and stop_execution_date is not null
	order by start_execution_date desc

	SET @cmdline = 'tasklist'	  
	INSERT #tmp2
	EXEC master.dbo.xp_cmdshell @cmdline

	if exists(select * from #tmp2 where cmdOutput like 'import_image%')
	begin
		set @import_img_running = 1
		print @import_img_stop_job_date
		print @current_date
		set @sec_running = DATEDIFF(second, @import_img_stop_job_date, @current_date)
		print @sec_running
	end
	
	if @import_img_running = 1
	begin
		insert into #tmp (Running_Jobs, Starting_time, Has_been_running)
		values (@import_image_job_name, @import_img_stop_job_date, @sec_running)
	end
	
	select * from #tmp
	
	drop table #tmp
	
END
GO
