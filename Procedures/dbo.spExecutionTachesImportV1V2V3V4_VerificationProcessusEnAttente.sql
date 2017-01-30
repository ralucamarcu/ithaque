SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/11/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spExecutionTachesImportV1V2V3V4_VerificationProcessusEnAttente]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	 @id_tache int, @id_tache_log int, @id_utilisateur int, @path VARCHAR(500), @v1_exists BIT = 1,@id_source UNIQUEIDENTIFIER, @date_creation DATETIME = GETDATE()
			, @images_log_files_path VARCHAR(255) = NULL, @chemin_dossier varchar(255) ,@machine_traitement VARCHAR(255), @path_version VARCHAR(255) = NULL
			,@id_projet [uniqueidentifier], @chemin_dossier_projet varchar(255) , @ordre_max int,@nom_format_dossier varchar(100)
	CREATE TABLE  #temp_DirTree (id int identity,subdirectory varchar(500),depth int,[file] int )


    	BEGIN
		
		SELECT TOP 1 @id_tache_log=id_tache_log ,@id_tache=id_tache,@id_source=id_source,@id_utilisateur=id_utilisateur,@machine_traitement=machine_traitement, @id_projet=id_projet 
		FROM [dbo].[Taches_Logs] WITH (NOLOCK) 
		WHERE id_status=4 and doit_etre_execute=1
		ORDER BY ordre
		
		SELECT @nom_format_dossier=nom_format_dossier,  @chemin_dossier=chemin_dossier_general from Sources where id_source = @id_source

		IF (@id_projet IS NOT null)
		BEGIN
			SET @chemin_dossier_projet = (SELECT p.chemin_dossier_general from dbo.Projets p WHERE p.id_projet = @id_projet)
		END
	
		IF(@id_tache=1)
		BEGIN
			SET @chemin_dossier = (SELECT chemin_dossier_general + 'V1\' FROM dbo.Sources s WHERE s.id_source = @id_source)
			INSERT INTO #temp_DirTree([subdirectory],[depth],[file])
			EXEC xp_dirtree @chemin_dossier, 3, 1
			IF EXISTS (SELECT * FROM #temp_DirTree WHERE depth IN (2,3))
				BEGIN	
					EXEC  Ithaque.dbo.spImportImagesV1 @id_source =@id_source,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
						,@id_tache = @id_tache,@path = @chemin_dossier, @id_tache_log = @id_tache_log
				END
				else
				BEGIN
					UPDATE dbo.Taches_Logs
					SET dbo.Taches_Logs.id_status = 2
						,dbo.Taches_Logs.erreur_message = 'V1 n''existent pas physiquement sur le serveur'
					WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log
				END
				TRUNCATE TABLE #temp_DirTree				
		END
		IF(@id_tache=2)
		BEGIN
			SET @chemin_dossier = (SELECT chemin_dossier_general + 'V2\' FROM dbo.Sources s WHERE s.id_source = @id_source)

			INSERT INTO #temp_DirTree([subdirectory],[depth],[file])
			EXEC xp_dirtree @chemin_dossier, 3, 1

			IF EXISTS (SELECT * FROM #temp_DirTree WHERE depth IN (3,2))
			BEGIN
				EXEC spImportImagesV2 @id_source =@id_source,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
								,@id_tache = @id_tache,@path = @chemin_dossier, @id_tache_log = @id_tache_log
			END
			ELSE
			BEGIN
				UPDATE dbo.Taches_Logs
				SET dbo.Taches_Logs.id_status = 2
					,dbo.Taches_Logs.erreur_message = 'V2 n''existent pas physiquement sur le serveur'
				WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log
			END
			TRUNCATE TABLE #temp_DirTree
		END
		IF(@id_tache=3)
			BEGIN
					SET @chemin_dossier = (SELECT chemin_dossier_general + 'V3\images\' FROM dbo.Sources s WHERE s.id_source = @id_source)

					INSERT INTO #temp_DirTree([subdirectory],[depth],[file])
					EXEC xp_dirtree @chemin_dossier, 3, 1

					IF EXISTS (SELECT * FROM #temp_DirTree WHERE depth IN (3,2))
					BEGIN
						set @path_version = @chemin_dossier
						set @images_log_files_path = (SELECT chemin_dossier_general + 'workspace\resources\reorganization_step\imagesLog\' FROM dbo.Sources s WHERE s.id_source = @id_source)

						EXEC  Ithaque.dbo.[spImportImagesV3] @id_source =@id_source,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
									,@id_tache_v3 = @id_tache, @v3_general_path = @path_version, @images_log_files_path = @images_log_files_path, @id_tache_log = @id_tache_log
					END
					ELSE
					BEGIN
						UPDATE dbo.Taches_Logs
						SET dbo.Taches_Logs.id_status = 2
							,dbo.Taches_Logs.erreur_message = 'V3 n''existent pas physiquement sur le serveur'
						WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log
					END
					TRUNCATE TABLE #temp_DirTree
				END
		IF(@id_tache=4 AND @nom_format_dossier NOT LIKE '%-RC')
			BEGIN
					SET @id_projet = (SELECT id_projet FROM dbo.Sources_Projets sp WHERE sp.id_source = @id_source)
					SET @chemin_dossier = (SELECT p.chemin_dossier_general + 'V4\images\' FROM dbo.Projets p WHERE p.id_projet = @id_projet)

					INSERT INTO #temp_DirTree([subdirectory],[depth],[file])
					EXEC xp_dirtree @chemin_dossier, 3, 1

					IF EXISTS (SELECT * FROM #temp_DirTree WHERE depth IN (3,2))
					BEGIN
						EXEC [spImportV4] @id_source =@id_source, @id_projet = @id_projet, @id_utilisateur = @id_utilisateur, @id_tache_log = @id_tache_log
					END
					ELSE
					BEGIN
						UPDATE dbo.Taches_Logs
						SET dbo.Taches_Logs.id_status = 2
							,dbo.Taches_Logs.erreur_message = 'V4 n''existent pas physiquement sur le serveur'
						WHERE dbo.Taches_Logs.id_tache_log = @id_tache_log
					END
					TRUNCATE TABLE #temp_DirTree
				END
		IF(@id_tache=9)
			BEGIN	
					EXEC spImportImagesV1V2_ImagesBis @id_source =@id_source,@id_utilisateur = @id_utilisateur,@machine_traitement = @machine_traitement
							,@path = @chemin_dossier, @id_tache_log = @id_tache_log
				END
	  --IF(@id_tache = 17)
			--BEGIN
			--	EXEC Traitements_Images.dbo.[ImportSources] @id_source =@id_source, @id_utilisateur = @id_utilisateur, @id_tache_log = @id_tache_log					
			--END
		--FETCH cursor_taches INTO @id_tache_log, @id_tache, @id_source, @id_utilisateur, @machine_traitement, @id_projet
		
		SELECT  @id_tache_log=NULL, @id_tache= NULL, @id_source=NULL, @id_utilisateur=NULL, @machine_traitement=NULL, @id_projet=NULL
	END
	DROP TABLE #temp_DirTree
END
GO
