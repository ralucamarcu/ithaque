SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[saisie_donnes_recensement_report_email]

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id_source uniqueidentifier,
			@id_projet uniqueidentifier,
			@id_version_processus int,
			@projet_year varchar(100)='-',
			@nb_images int,
			@nb_actes int,
			@pret_pour_MEP bit =0,
			@nb_projets int=0,
			@chemin_dossier_general varchar(1000),
			@total_nb_images int=0,
			@total_nb_actes int=0,
			@total_nb_projets int=0,
			@total_sources int=0,
			@total_pret_pour_MEP int=0

	DECLARE @recipients1 VARCHAR(200),
			@recipients2 VARCHAR(200), 
			@recipients3 VARCHAR(200), 
			@recipients4 VARCHAR(200),
			@recipients5 VARCHAR(200),
			@subject varchar(500)='Rapport hebdomadaire Recensements',
			@nom_department varchar(100), 
			@body varchar(max),
			@date date=getdate(),
			@tr_table varchar(max)='<tr><tr>',
			@profileaccount varchar(100)='Raluca',
			@file_miniaturi bit=0,
			@log_miniaturi bit=0,
			@id_departement varchar (4),
			@total_log_miniaturi int=0,
			@total_file_miniaturi int=0
			
			

	SET @recipients1 = 'rmarcu@pitechnologies.ro'
	SET @recipients4 = 'andrea.tamas@pitechnologies.ro'
	SET @recipients2 = 'frederic.robillard@filae.com;loo.xiaohui@filae.com;	vincent.brossier@filae.com'

	CREATE TABLE #temp_miniatures_files(subdirectory varchar(300),depth int,[file] int,[department] varchar(250))
	CREATE TABLE #temp_miniatures_log(subdirectory varchar(300),depth int,[file] int,[department] varchar(250))

	INSERT INTO #temp_miniatures_log (subdirectory,depth,[file])
	EXEC xp_dirtree '\\10.1.0.196\bigvol\Jobs\miniatures_fichiers_recensement\bigarc.logs\', 1,1

	INSERT INTO #temp_miniatures_files (subdirectory,depth,[file])
	EXEC xp_dirtree '\\10.1.0.196\bigvol\Jobs\miniatures_fichiers_recensement\', 1,1

	UPDATE #temp_miniatures_log
	SET [department]= REPLACE(LEFT(subdirectory, CHARINDEX('.', subdirectory) - 1),'miniatures_dept','')
	WHERE [file]=1

	UPDATE #temp_miniatures_files
	SET [department]= REPLACE(REPLACE(right(subdirectory, len(subdirectory) - charindex('_dept', subdirectory)),'dept',''),'.csv','')
	WHERE [file]=1


	SELECT nom_format_dossier, id_source, id_status_version_processus, id_departement INTO #sources_recensement FROM dbo.Sources s(NOLOCK) WHERE s.nom_format_dossier LIKE '%-RC'
	SET @total_sources=(SELECT count(*) FROM #sources_recensement)
	DECLARE sources_cursor CURSOR FOR
	SELECT nom_format_dossier, id_source, id_status_version_processus ,id_departement FROM #sources_recensement --WHERE id_source='3114DFB7-C504-4999-B13D-07D88ACA892B'
	OPEN sources_cursor   
	FETCH NEXT FROM sources_cursor INTO @nom_department, @id_source, @id_version_processus   ,@id_departement

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		
		SET @nb_images = (SELECT count(id_image) FROM Images(NOLOCK) WHERE id_source=@id_source AND id_status_version_processus = @id_version_processus)

		IF (@id_version_processus >= 4)
		BEGIN
			

			IF EXISTS (SELECT * from #temp_miniatures_log where department=@id_departement)
			BEGIN
				SET @log_miniaturi = 1
			END
			
			IF EXISTS (SELECT * from #temp_miniatures_files where department=@id_departement)
			BEGIN
				SET @file_miniaturi = 1
			END 

			CREATE TABLE #projets_rencesement (id_projet uniqueidentifier)
			INSERT INTO #projets_rencesement (id_projet)
			SELECT id_projet FROM dbo.Sources_Projets sp(NOLOCK) WHERE sp.id_source = @id_source
	
			SET @nb_projets =(SELECT count(id_projet) FROM #projets_rencesement)

			DECLARE projet_cursor CURSOR FOR
			SELECT id_projet FROM #projets_rencesement
			OPEN projet_cursor   
			FETCH NEXT FROM projet_cursor INTO @id_projet

			WHILE @@FETCH_STATUS = 0   
			BEGIN   
				SELECT @chemin_dossier_general = chemin_dossier_general FROM projets (NOLOCK) WHERE id_projet = @id_projet
				SET @chemin_dossier_general = @chemin_dossier_general +'V4\images\'

				CREATE TABLE #tmp_fichiers (id_fichier uniqueidentifier, id_lot uniqueidentifier)

				INSERT INTO #tmp_fichiers (id_fichier, id_lot)
				SELECT x.id_fichier, x.id_lot 
				FROM (
					SELECT  row_number() OVER (PARTITION BY  dxf.nom_fichier ORDER BY dxf.date_creation DESC) as row_num, dxf.* 
					FROM DataXml_fichiers dxf WITH (nolock)
					INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) on dxf.id_lot=lf.id_lot
					INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
					WHERE t.id_projet = @id_projet
						AND t.controle_livraison_conformite = 1 
						AND t.import_xml = 1 
						AND t.livraison_annulee = 0
				
						) as x
				WHERE x.row_num = 1

				SET @nb_actes= (SELECT count(distinct a.id) FROM #tmp_fichiers f INNER JOIN DataXmlRC_actes a ON a.id_fichier=f.id_fichier)

				CREATE TABLE #Files_projets (subdirectory varchar(255), deprth int, [file] int)
				INSERT INTO #Files_projets
				EXEC xp_dirtree @chemin_dossier_general, 2,1
				--EXEC xp_dirtree '\\10.1.0.196\bigvol\Projets\p120-04-ALPESHP-RC\v4\images', 2,1
				SET @projet_year= (SELECT subdirectory FROM #Files_projets WHERE deprth=2)

				DROP TABLE #tmp_fichiers
				DROP TABLE #Files_projets
	
				--SELECT @id_source,@id_version_processus,@nb_actes,@nb_images,@projet_year,@nb_projets

				IF (@nb_actes>0 AND (@projet_year <>'-' OR @projet_year IS NOT NULL) AND @nb_images>0)
				BEGIN
                	SET @pret_pour_MEP =1
                END
	
				SET @total_pret_pour_MEP = @total_pret_pour_MEP+@pret_pour_MEP

				SET @tr_table=@tr_table+'<tr>
										 <td style="text-align: left !important;">'+ Cast(@nom_department AS varchar(50))+ '</td>'	
									   +'<td> V' + Cast(@id_version_processus AS varchar(50))+'</td>'
									   +'<td>' +Cast(@nb_projets AS varchar(50))+'</td>'
									   +'<td>' +Cast(@projet_year AS varchar(50))+'</td>'
									   +'<td>'+ Cast(@nb_images AS varchar(50))+'</td>'
									   +'<td>'+ Cast(@nb_actes AS varchar(50))+'</td>'
									   +'<th>'+ Cast(@file_miniaturi as varchar(50))+'</th>'
									   +'<th>'+ Cast(@log_miniaturi as varchar(50))+'</th>'
									   +'<td>'+ Cast(@pret_pour_MEP AS varchar(50))+'</td>'
									  +'</tr>'


				
				

				FETCH NEXT FROM projet_cursor INTO @id_projet
				
			END
			CLOSE projet_cursor   
			DEALLOCATE projet_cursor

			DROP TABLE #projets_rencesement
		END
		ELSE
		BEGIN
				SET  @pret_pour_MEP=0

				SET @tr_table=@tr_table+'<tr>
										 <td style="text-align: left !important;">'+ Cast(@nom_department AS varchar(50))+ '</td>'	
									   +'<td> V' + Cast(@id_version_processus AS varchar(50))+'</td>'
									   +'<td>' +Cast(0 AS varchar(50))+'</td>'
									   +'<td>' +Cast('-' AS varchar(50))+'</td>'
									   +'<td>'+ Cast(@nb_images AS varchar(50))+'</td>'
									   +'<td>'+ Cast(0 AS varchar(50))+'</td>'
									   +'<th>'+ Cast(0 as varchar(50))+'</th>'
									   +'<th>'+ Cast(0 as varchar(50))+'</th>'
									   +'<td>'+ Cast(@pret_pour_MEP AS varchar(50))+'</td>'
									  +'</tr>'
		END
		
		SET @total_log_miniaturi=@total_log_miniaturi+@log_miniaturi
		SET @total_file_miniaturi=@total_file_miniaturi+@file_miniaturi
		SET @total_nb_images = @total_nb_images + @nb_images
		SET @total_nb_actes = @total_nb_actes + @nb_actes
		SET @total_nb_projets = @total_nb_projets + @nb_projets

		--SELECT @id_source,@id_version_processus,@nb_actes,@nb_images,@projet_year,@nb_projets,@pret_pour_MEP
		SELECT @nom_department= NULL ,@id_source = NULL ,@id_version_processus = NULL ,@nb_actes =0 ,@nb_images =0 ,@nb_projets =0,@projet_year = '-' ,@pret_pour_MEP=0,@log_miniaturi=0,@file_miniaturi=0

		FETCH NEXT FROM sources_cursor INTO @nom_department, @id_source, @id_version_processus,@id_departement

	END   

	CLOSE sources_cursor   
	DEALLOCATE sources_cursor

	DROP TABLE #sources_recensement
	--DROP TABLE #projets_rencesement
	--DROP TABLE #tmp_fichiers
	--DROP TABLE #Files_projets

	SELECT @body='<!doctype html> 
	<html>
	<head>
	<style>
	* {font-family: "Helvetica Neue", "Helvetica", Helvetica, Arial, sans-serif;font-size: 100%;line-height: 1.6em;margin: 0;padding: 0;}
	img {max-width: 600px;width: auto;}
	body {-webkit-font-smoothing: antialiased;height: 100%;-webkit-text-size-adjust: none;width: 100% !important;}
	a {color: #348eda;}
	.btn-primary {Margin-bottom: 10px;width: auto !important;}
	.btn-primary td {background-color: #348eda; border-radius: 25px;font-family: "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif; font-size: 14px; text-align: center;vertical-align: top; }
	.btn-primary td a {background-color: #348eda;border: solid 1px #348eda;border-radius: 25px;border-width: 10px 20px;display: inline-block;color: #ffffff;cursor: pointer;font-weight: bold;line-height: 2;text-decoration: none;}
	.last {margin-bottom: 0;}
	.first {margin-top: 0;}
	.padding {padding: 10px 0;}
	table.body-wrap {padding: 20px;width: 100%;}
	table.body-wrap .container {border: 1px solid #f0f0f0;}
	table.footer-wrap {clear: both !important;width: 100%;}
	.footer-wrap .container p {color: #666666;font-size: 12px;}
	table.footer-wrap a {color: #999999;}
	h1,h2,h3 {color: #111111;font-family: "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;font-weight: 200;line-height: 1.2em;margin: 40px 0 10px;}
	h1 {font-size: 36px;}
	h2 {font-size: 28px;}
	h3 {font-size: 22px;}
	p, ul, ol {font-size: 14px;font-weight: normal;margin-bottom: 10px;}
	ul li, ol li {margin-left: 5px;list-style-position: inside;}
	.container {clear: both !important;display: block !important;Margin: 0 auto !important;max-width: 1000px !important;}
	.body-wrap .container {padding: 20px;}
	.content {display: block;margin: 0 auto;max-width: 1000px;}
	.content table {width: 100%;}
	th {text-align: center !important;}
	td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;text-align: center;}
	</style>
	</head>

	<body bgcolor="#f6f6f6">
	<table class="body-wrap" bgcolor="#f6f6f6">
	  <tr>
   
		<td class="container" bgcolor="#FFFFFF">
		  <div class="content">
		  <table>
			<tr>
			  <td>
				<h2 style="text-align: center !important;">   Rapport hebdomadaire Recensements '+ cast(@date as varchar(50)) +' </h2>

			<tr>
			  <td>
				<h3 style="text-align: center !important;"><b>   Liste avec les Départements Recensements et leur état</b></h3>
				<table  style="font-family: arial, sans-serif;border-collapse: collapse;width: 100%;">
				<tr>
					<th>Source</th>
					<th>Etat </th>
					<th>Nb Projets</th>
					<th>Les Projets</th>
					<th>Nb Images</th>
					<th>Nb Actes</th>
					<th>Fichier miniatures genere</th>
					<th>Fichier miniatures log</th>
					<th>Pret pout MEP</th>
				</tr>'+@tr_table+'
			 	<tr>
				<th style="text-align: left !important;">Total<th>
				</tr>
				<tr><th>'+ Cast(@total_sources as varchar(50))+'</th>
					<th>'+ Cast('-' as varchar(50))+'</th>
					<th>'+ Cast('-' as varchar(50))+'</th>
					<th>'+ Cast('-' as varchar(50))+'</th>
					<th>'+ Cast(@total_nb_images as varchar(50))+'</th>
					<th>'+ Cast(@total_nb_actes as varchar(50))+'</th>
					<th>'+ Cast(@total_file_miniaturi as varchar(50))+'</th>
					<th>'+ Cast(@total_log_miniaturi as varchar(50))+'</th>
					<th>'+ Cast(@total_pret_pour_MEP as varchar(50))+'</th>
				</tr>	
				</table>

			  </td>
			</tr>
		
		  </div>
		</td>
 
	  </tr>
	</table>
</table>

	</body>
	</html>'

	EXEC msdb.dbo.sp_send_dbmail
			@recipients = @recipients4,
			@profile_name = @profileaccount,
			@subject = @subject, 
			@body = @body,
			@body_format = 'HTML' ;	

	EXEC msdb.dbo.sp_send_dbmail
			@recipients = @recipients1,
			@profile_name = @profileaccount,
			@subject = @subject, 
			@body = @body,
			@body_format = 'HTML' ;	

	EXEC msdb.dbo.sp_send_dbmail
			@recipients = @recipients2,
			@profile_name = @profileaccount,
			@subject = @subject, 
			@body = @body,
			@body_format = 'HTML' ;	




END
GO
