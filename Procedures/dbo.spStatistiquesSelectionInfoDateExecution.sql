SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <22/09/2015>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesSelectionInfoDateExecution]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @date datetime = GETDATE() --,@job_id_ithaque uniqueidentifier,@job_id_archives uniqueidentifier

	--SELECT @job_id_ithaque =job_id FROM msdb.dbo.sysjobs WHERE name  = N'Statistiques_CC_Avancement_Projets'
 --   SELECT @job_id_archives=job_id FROM [158.255.103.92].msdb.dbo.sysjobs sjh WHERE name = N'Archives Statistiques Actes'

	SELECT MAX(msdb.dbo.agent_datetime( CASE WHEN js.last_run_date = 0 THEN NULL ELSE js.last_run_date END,
										CASE WHEN js.last_run_time = 0 THEN NULL ELSE js.last_run_time END)) AS date_run
		  ,CASE WHEN step_name = 'Statistiques_Controle_Qualite_Operateurs' THEN 'Suivi journalier operateurs' 
				WHEN step_name = 'Statistiques_Avancement_Projets_Details' THEN 'Details Projets'			
				WHEN step_name = 'Statistiques_Avancement_Projets_Images' THEN 'Anvancement Projet Images'
				WHEN step_name = 'Statistiques_Avancement_Projets_AEL' THEN 'A Mettre En Ligne'
				WHEN step_name = 'Statistiques_Controle_Qualite_General' THEN 'Stats generale'
			ELSE step_name END AS step_name
	FROM msdb.dbo.sysjobs j
	INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id 
	WHERE /*js.job_id=@job_id_ithaque AND*/
	j.name = 'Statistiques_CC_Avancement_Projets' AND js.last_run_outcome = 1
	AND step_name IN ('Statistiques_Controle_Qualite_Operateurs', 'Statistiques_Avancement_Projets_Details','Statistiques_Avancement_Projets_Images'
					  ,'Statistiques_Avancement_Projets_AEL','Statistiques_Controle_Qualite_General')
	GROUP BY step_name
	UNION 
	SELECT MAX(msdb.dbo.agent_datetime(CASE WHEN js.last_run_date = 0 THEN NULL ELSE js.last_run_date END,
									   CASE WHEN js.last_run_time = 0 THEN NULL ELSE js.last_run_time END)) AS date_run
		  ,CASE WHEN step_name = 'statistiques_actes' THEN 'Actes En Ligne' ELSE step_name END AS step_name
	FROM [158.255.103.92].msdb.dbo.sysjobs j
	INNER JOIN [158.255.103.92].msdb.dbo.sysjobsteps js ON j.job_id = js.job_id 
	WHERE /*js.job_id=@job_id_archives AND*/ 
	j.name= 'Archives Statistiques Actes' AND js.last_run_outcome = 1  
	GROUP BY step_name
	UNION 
	SELECT @date, 'Suivi qualite'
	UNION
	SELECT @date, 'Suivi sous projet'


END


GO
