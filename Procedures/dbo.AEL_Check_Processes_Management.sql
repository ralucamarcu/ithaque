SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[AEL_Check_Processes_Management]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @import_image_job_name VARCHAR(255), @import_img_running BIT = 0, @cmdline VARCHAR(2000)
		, @current_date DATETIME, @import_img_stop_job_date DATETIME, @sec_running INT, @id_document uniqueidentifier
		, @restarted_import_image bit = 0, @restarted_importation_saisie bit = 0
		, @job_id uniqueidentifier, @enabled bit, @planification_job_id varchar(100)
		
	--EXEC msdb.dbo.sp_start_job N'AEL Check Processes' ;
	
	select @job_id = sj.job_id,  @enabled = [enabled], @planification_job_id = schedule_id
	from msdb.dbo.sysjobs sj
	inner join msdb.dbo.sysjobschedules sjs on sj.job_id = sjs.job_id
	where sj.name='AEL Check Processes Management'
	
	SET @current_date = GETDATE()
	set @id_document = (select top 1 id_document from AEL_Parametres where principal = 1)
	IF OBJECT_ID('AEL_Processes_Management_tmp') IS NOT NULL 
		DROP TABLE AEL_Processes_Management_tmp
	CREATE TABLE AEL_Processes_Management_tmp (Running_Jobs VARCHAR(255), Starting_time DATETIME, Has_been_running INT)
	
	INSERT INTO AEL_Processes_Management_tmp
	SELECT J.name AS Running_Jobs, JA.Start_execution_date AS Starting_time,
		DATEDIFF(ss, JA.Start_execution_date,GETDATE()) AS Has_been_running
	FROM msdb.dbo.sysjobactivity JA
	INNER JOIN msdb.dbo.sysjobs J ON J.job_id=JA.job_id
	WHERE job_history_id IS NULL AND start_execution_date IS NOT NULL
	ORDER BY start_execution_date
	
	--import_image jp2000/import_image zones/import_image prod
	SELECT TOP 1 @import_image_job_name = name, @import_img_stop_job_date = stop_execution_date
	FROM msdb.dbo.sysjobactivity sa 
	INNER JOIN msdb.dbo.sysjobs s ON sa.job_id = s.job_id
	WHERE s.name IN ('AEL Traitement Images JP2000', 'AEL Traitement Images Prod', 'AEL Traitement Images Zones'
		,'AEL Traitement des XML Importation Saisie') 
		AND stop_execution_date IS NOT NULL
	ORDER BY start_execution_date DESC
	
	IF EXISTS(SELECT * FROM AEL_Check_Processes_Running WHERE RESULT LIKE 'import_image%')
	begin
		if (@import_image_job_name <> 'AEL Traitement Images JP2000' and @import_image_job_name <> 'AEL Traitement Images Prod'
			and @import_image_job_name <> 'AEL Traitement Images Zones')
		begin 
			INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
			VALUES ('Import Image Program: pas commencé du travail', null, null)		
		end
		else
		if (@import_image_job_name = 'AEL Traitement Images JP2000' or @import_image_job_name = 'AEL Traitement Images Prod'
			or @import_image_job_name = 'AEL Traitement Images Zones')
		begin
			SET @import_img_running = 1
			SET @sec_running = DATEDIFF(SECOND, @import_img_stop_job_date, @current_date)		
				
			INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
			VALUES (@import_image_job_name, @import_img_stop_job_date, @sec_running)
		end
	end	
	else
	begin
		if(@import_image_job_name = 'AEL Traitement Images JP2000')
		begin
			if(select COUNT(*) from [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_images with (nolock) where id_document = @id_document 
				and jp2_a_traiter = 1 and jp2_traitee is null and [status] = 0) > 0
			begin
				exec msdb.dbo.sp_start_job 'AEL Traitement Images JP2000'
				set @restarted_import_image = 1
				
				INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
				VALUES (@import_image_job_name, @current_date, 5)
			end
		end
		
		if(@import_image_job_name = 'AEL Traitement Images Prod')
		begin
			if(select COUNT(path) from [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_images with (nolock) where id_document = @id_document 
				and production=1 and date_production is null) > 0
			begin
				exec msdb.dbo.sp_start_job 'AEL Traitement Images Prod'				
				set @restarted_import_image = 1
				
				INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
				VALUES (@import_image_job_name, @current_date, 5)
			end
		end
		
		if(@import_image_job_name = 'AEL Traitement Images Zones')
		begin
			if(select COUNT(id_image) from [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_images with (nolock) where id_document = @id_document 
				and zones_a_traiter=1 and zones_traitees is null and status=0) > 0
			begin
				exec msdb.dbo.sp_start_job 'AEL Traitement Images Zones'
				set @restarted_import_image = 1
				
				INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
				VALUES (@import_image_job_name, @current_date, 5)
			end
		end
	end
	
	
	IF EXISTS(SELECT * FROM AEL_Check_Processes_Running WHERE RESULT LIKE 'ImportationSaisie%')
	begin
		if (@import_image_job_name <> 'AEL Traitement des XML Importation Saisie') 
		begin 
			INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
			VALUES ('Importation Saisie Program: pas commencé du travail', null, null)		
		end
		else
		if (@import_image_job_name = 'AEL Traitement des XML Importation Saisie' )
		begin
			SET @import_img_running = 1
			SET @sec_running = DATEDIFF(SECOND, @import_img_stop_job_date, @current_date)		
				
			INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
			VALUES (@import_image_job_name, @import_img_stop_job_date, @sec_running)
		end
	end	
	else
	begin
		if(@import_image_job_name = 'AEL Traitement des XML Importation Saisie')
		begin
			if(select COUNT(*) from Archives_Preprod.dbo.saisie_donnees_fichiers_XML with (nolock) where id_document = @id_document 
				and statut = 0) > 0
			begin
				exec msdb.dbo.sp_start_job 'AEL Traitement des XML Importation Saisie'
				set @restarted_importation_saisie = 1
				
				INSERT INTO AEL_Processes_Management_tmp (Running_Jobs, Starting_time, Has_been_running)
				VALUES (@import_image_job_name, @current_date, 5)
			end
		end
	end
	
	if (select COUNT(*) from AEL_Processes_Management_tmp where running_jobs <> 'AEL Check Processes Management') = 0 and @import_img_running = 0 and @restarted_import_image = 0 and @restarted_importation_saisie = 0
	begin
		--exec msdb.dbo.sp_detach_schedule @job_id = @job_id, @job_name = 'AEL Check Processes Management'
		--	, @schedule_id = @planification_job_id, @schedule_name = 'check_processes_management_planification'
		print 1
		 EXEC msdb.dbo.sp_start_job N'AEL Disable Job Processes_Management' ;
		print 2
	end

END
GO
