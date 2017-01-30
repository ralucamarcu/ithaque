SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 01.12.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionTachesEnCourse]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here	
	DECLARE @current_date DATETIME
	SET @current_date = GETDATE()
	
	CREATE TABLE #tmp (job_name VARCHAR(255))
	--INSERT INTO #tmp	
	--SELECT sj.name
	--FROM msdb.dbo.sysjobactivity AS sja
	--INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
	--WHERE sja.start_execution_date IS NOT NULL
	--   AND sja.stop_execution_date IS NULL

	INSERT INTO #tmp	(job_name)
	SELECT name  FROM 
	OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;','EXEC msdb..sp_help_job')
	WHERE current_execution_status=1

	
	IF ((SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_status = 3 AND date_fin IS NULL) = 0 AND (SELECT COUNT(*) FROM #tmp 
		WHERE job_name IN ('Traitement V1 Import', 'Traitement V2 Import', 'Traitement V2 Import Doubles',
			'Traitement V3 Import', 'V2 Import Avant Traitement', 'Traitement V4 Import')) > 0)
	BEGIN
	print 1
		SELECT job_name AS Running_Jobs, GETDATE() AS Starting_Time, 0 AS Has_been_running
			,'' AS DepartName, 0 AS progression_pourcentage
		FROM #tmp
	END
	ELSE
	BEGIN
	print 2
		IF (SELECT COUNT(*) FROM Taches_Logs  WITH (NOLOCK) WHERE id_status = 3 AND date_fin IS NULL AND id_projet IS NULL) >0
		BEGIN
			SELECT t.nom_tache AS Running_Jobs, tl.date_debut AS Starting_Time, DATEDIFF(MINUTE, tl.date_debut, getdate()) AS Has_been_running
				,s.nom_format_dossier AS DepartName, null as progression_pourcentage
			FROM Taches_Logs tl WITH (NOLOCK)
			INNER JOIN Taches t WITH (NOLOCK) ON tl.id_tache = t.id_tache
			LEFT JOIN Sources s WITH (NOLOCK) ON tl.id_source = s.id_source
			--LEFT JOIN Taches_Logs_Details tld WITH (NOLOCK) ON tl.id_tache_log = tld.id_tache_log
			WHERE tl.id_status = 3 AND tl.date_fin IS NULL
			GROUP BY t.nom_tache, tl.date_debut, s.nom_format_dossier
			ORDER BY tl.date_debut DESC
		END
		ELSE
		BEGIN
		print 3
			SELECT t.nom_tache AS Running_Jobs, tld.date_debut AS Starting_Time, DATEDIFF(MINUTE, tld.date_debut, @current_date) AS Has_been_running
				,p.nom_projet_dossier AS DepartName, tld.progression_pourcentage
			FROM Taches_Logs tl WITH (NOLOCK)
			INNER JOIN Taches t WITH (NOLOCK) ON tl.id_tache = t.id_tache
			INNER JOIN Projets p WITH (NOLOCK) ON tl.id_projet = p.id_projet
			LEFT JOIN Taches_Logs_Details tld WITH (NOLOCK) ON tl.id_tache_log = tld.id_tache_log
			WHERE tl.id_status = 3 AND tld.date_fin IS NULL
			GROUP BY t.nom_tache, tld.date_debut, p.nom_projet_dossier, tld.progression_pourcentage
			ORDER BY tld.date_debut DESC
		END
	END
	

	DROP TABLE #tmp
END


GO
