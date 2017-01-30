SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modification date: 15/09/2015
--				Description -> modified path destiontion for images from Taches_Logs_Images (from Sources into Projets)
-- Description:	<Description,,>
-- =============================================

--testrun: [spImportV4] '92E723EC-AD10-4A8F-ABF3-1BA5ABF4E47B','1376E61F-E580-49EB-86C0-C3E9295F8CAB',12,3053
CREATE PROCEDURE [dbo].[spImportV4] 
	-- Add the parameters for the stored procedure here
	 @id_source UNIQUEIDENTIFIER
	,@id_projet UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@id_tache_log INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date_creation DATETIME = GETDATE(), @id_tache_log_v4 INT, @machine_traitement VARCHAR(50) = 'Ithaque App'
		, @IntegerResultV4 INT,@id_tache_log_details INT, @nom_projet varchar(255),@chemin_general_projet varchar(255)

	SELECT @nom_projet=infos,@chemin_general_projet=chemin_dossier_general FROM Projets(NOLOCK) WHERE id_projet=@id_projet

	BEGIN TRY
	BEGIN TRANSACTION [spImportImagesV4Images];
	--insérer log pour la tâche = V3-import du processus V3
		--EXEC [dbo].[spInsertionTacheLog] 4, @id_utilisateur, @id_source, NULL, @machine_traitement
		--SET @id_tache_log_v4 = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
		--						WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
		--							AND id_tache = 4					
		--						ORDER BY date_creation DESC)

		UPDATE Taches_Logs
		SET id_projet=@id_projet
			,id_status=3
			,doit_etre_execute=0
			,date_debut = @date_creation
		WHERE id_tache_log=@id_tache_log

		EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
		SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

	IF @nom_projet LIKE '%-RC'
	BEGIN
	PRINT'RC' 
		SET @chemin_general_projet=@chemin_general_projet +'V4\images\'
		SELECT @chemin_general_projet
		CREATE TABLE #Files(ID INT IDENTITY,FILE_PATH VARCHAR(800),[FILE_NAME] VARCHAR(800),is_file bit)
		INSERT INTO #Files	(FILE_PATH, FILE_NAME, is_file)
		EXEC xp_dirtree @chemin_general_projet ,10,10

		CREATE INDEX idx_FILE_PATH ON #Files(FILE_PATH)
		
		INSERT INTO Taches_Images_Logs (id_image, path_origine, path_destination, id_tache, date_creation , nom_fichier_image_origine, nom_fichier_image_destination)
		SELECT tli.id_image, tli.path_destination AS path_origine --, REPLACE(tli.path_destination, 'V3', 'V4') AS path_destination
			, REPLACE(tli.[path_destination], '\\10.1.0.196\bigvol\Sources\' + s.[nom_format_dossier] + '\V3\images', '\\10.1.0.196\bigvol\Projets\'+p.nom_projet_dossier+'\V4\images')AS path_destination
			, 4 AS id_tache, @date_creation AS date_creation, tli.nom_fichier_image_destination AS nom_fichier_image_origine
			, tli.nom_fichier_image_destination AS nom_fichier_image_destination
		FROM #Files f 
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON f.FILE_PATH=tli.nom_fichier_image_destination
		INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
		INNER JOIN Sources s WITH (NOLOCK) ON  i.id_source = s.id_source
		INNER JOIN Sources_Projets sp WITH (NOLOCK) ON  i.id_source = sp.id_source
		INNER JOIN Projets p  WITH (NOLOCK) ON  p.id_projet = sp.id_projet
		WHERE i.id_source = @id_source  AND p.id_projet=@id_projet AND id_tache = 3
			AND (path_destination LIKE '%\RC\%') AND f.is_file=1
		GROUP BY tli.id_image, tli.path_destination 
			, REPLACE(tli.[path_destination], '\\10.1.0.196\bigvol\Sources\' + s.[nom_format_dossier] + '\V3\images', '\\10.1.0.196\bigvol\Projets\'+p.nom_projet_dossier+'\V4\images')
			,   tli.nom_fichier_image_destination 
			, tli.nom_fichier_image_destination

		UPDATE Images
		SET id_status_version_processus = 4, id_projet = @id_projet
		FROM #Files	f
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON f.FILE_PATH=tli.nom_fichier_image_destination
		INNER JOIN Images i WITH (NOLOCK) ON i.id_image = tli.id_image
		WHERE i.id_source = @id_source AND tli.id_tache = 4 AND f.is_file=1
	

		DROP TABLE #Files
	END
	ELSE IF @nom_projet  LIKE '%-TD'
	BEGIN
	PRINT'TD' 
		INSERT INTO Taches_Images_Logs (id_image, path_origine, path_destination, id_tache, date_creation
			, nom_fichier_image_origine, nom_fichier_image_destination)
		SELECT tli.id_image, tli.path_destination AS path_origine --, REPLACE(tli.path_destination, 'V3', 'V4') AS path_destination
			, REPLACE(tli.[path_destination], '\\10.1.0.196\bigvol\Sources\' + s.[nom_format_dossier] + '\V3\images', '\\10.1.0.196\bigvol\Projets\'+p.nom_projet_dossier+'\V4\images')AS path_destination
			, 4 AS id_tache
			, @date_creation AS date_creation, tli.nom_fichier_image_destination AS nom_fichier_image_origine
			, tli.nom_fichier_image_destination AS nom_fichier_image_destination
		FROM Taches_Images_Logs tli WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
		INNER JOIN Sources s WITH (NOLOCK) ON  i.id_source = s.id_source
		INNER JOIN Sources_Projets sp WITH (NOLOCK) ON  i.id_source = sp.id_source
		INNER JOIN Projets p  WITH (NOLOCK) ON  p.id_projet = sp.id_projet
		WHERE i.id_source = @id_source AND id_tache = 3 
			AND (path_destination LIKE '%\TD\%')

		UPDATE Images
		SET id_status_version_processus = 4, id_projet = @id_projet
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = tli.id_image
		WHERE i.id_source = @id_source AND tli.id_tache = 4
				
	END
	ELSE
	BEGIN
							
		INSERT INTO Taches_Images_Logs (id_image, path_origine, path_destination, id_tache, date_creation
			, nom_fichier_image_origine, nom_fichier_image_destination)
		SELECT tli.id_image, tli.path_destination AS path_origine --, REPLACE(tli.path_destination, 'V3', 'V4') AS path_destination
			, REPLACE(tli.[path_destination], '\\10.1.0.196\bigvol\Sources\' + s.[nom_format_dossier] + '\V3\images', '\\10.1.0.196\bigvol\Projets\'+p.nom_projet_dossier+'\V4\images')AS path_destination
			, 4 AS id_tache
			, @date_creation AS date_creation, tli.nom_fichier_image_destination AS nom_fichier_image_origine
			, tli.nom_fichier_image_destination AS nom_fichier_image_destination
		FROM Taches_Images_Logs tli WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
		INNER JOIN Sources s WITH (NOLOCK) ON  i.id_source = s.id_source
		INNER JOIN Sources_Projets sp WITH (NOLOCK) ON  i.id_source = sp.id_source
		INNER JOIN Projets p  WITH (NOLOCK) ON  p.id_projet = sp.id_projet
		WHERE i.id_source = @id_source AND id_tache = 3
			AND (path_destination LIKE '%\EC\%' OR path_destination LIKE '%\RP\%')
				
		UPDATE Images
		SET id_status_version_processus = 4, id_projet = @id_projet
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = tli.id_image
		WHERE i.id_source = @id_source AND tli.id_tache = 4
	END

	COMMIT TRANSACTION [spImportImagesV4Images];
		
	SET @IntegerResultV4 = 1 
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessageV4 NVARCHAR(4000);
		DECLARE @ErrorSeverityV4 INT;
		DECLARE @ErrorStateV4 INT;

		ROLLBACK TRANSACTION [spImportImagesV4Images];
				
		SET @IntegerResultV4 = -1
				
		SELECT @ErrorMessageV4 = ERROR_MESSAGE(),
		@ErrorSeverityV4 = ERROR_SEVERITY(),
		@ErrorStateV4 = ERROR_STATE();
		
		RAISERROR (@ErrorMessageV4,@ErrorSeverityV4, @ErrorStateV4 );
	END CATCH;
			
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResultV4 = 1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		UPDATE Sources
		SET id_status_version_processus = 4
		WHERE id_source = @id_source
		
		UPDATE Projets
		SET id_status_version_processus = 4
		WHERE id_projet = @id_projet
		END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log_v4, 2, NULL, @ErrorMessageV4
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessageV4
	END

	
END
GO
