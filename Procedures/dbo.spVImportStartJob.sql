SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 28.11.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spVImportStartJob] 
	-- Add the parameters for the stored procedure here
	--Test Run : [spVImportStartJob] '{f32da0d9-e06e-4a0d-8792-1728419433c7}', 5, 2
	 @id_source UNIQUEIDENTIFIER = null
	,@id_utilisateur INT = null	
	,@id_tache INT = null
	--,@id_tache_log INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @date_creation DATETIME = GETDATE(),@images_log_files_path VARCHAR(255) = NULL, @chemin_dossier varchar(255)
		,@machine_traitement VARCHAR(255) = 'Ithaque App', @path_version VARCHAR(255) = null
	IF (@id_tache = 0)
	BEGIN
		SET @id_tache = 1
	END
	
	set @chemin_dossier = (select chemin_dossier_general from Sources where id_source = @id_source)
	
	IF OBJECT_ID('v_import_Parameters') IS NOT NULL 
		DROP TABLE v_import_Parameters
	CREATE TABLE v_import_Parameters (id INT IDENTITY(1,1),id_source UNIQUEIDENTIFIER,id_utilisateur INT,machine_traitement VARCHAR(255)
	,id_tache INT,path_version VARCHAR(255),images_log_files_path VARCHAR(255), date_creation DATETIME)--,id_tache_log INT)	
	
	
	IF (@id_tache = 1)
	BEGIN
		print 1
		
		set @path_version = @chemin_dossier + 'V1\'
		INSERT INTO v_import_Parameters (id_source,id_utilisateur ,machine_traitement ,id_tache ,path_version, images_log_files_path, date_creation)--,id_tache_log)
		VALUES (@id_source,@id_utilisateur ,@machine_traitement ,@id_tache ,@path_version, @images_log_files_path, @date_creation)--,@id_tache_log)
		EXEC msdb.dbo.sp_start_job N'Traitement V1 Import' ;
	END
	
	IF (@id_tache = 2)
	BEGIN
		print 1
		INSERT INTO v_import_Parameters (id_source,id_utilisateur ,machine_traitement ,id_tache ,path_version, images_log_files_path, date_creation)--,id_tache_log)
		VALUES (@id_source,@id_utilisateur ,@machine_traitement ,@id_tache ,@path_version, @images_log_files_path, @date_creation)--,@id_tache_log)

		EXEC msdb.dbo.sp_start_job N'V2 Import Avant Traitement' ;
	END
	
	IF (@id_tache = 9)
	BEGIN
		set @path_version = @chemin_dossier 
		INSERT INTO v_import_Parameters (id_source,id_utilisateur ,machine_traitement ,id_tache ,path_version, images_log_files_path, date_creation)--,id_tache_log)
		VALUES (@id_source,@id_utilisateur ,@machine_traitement ,@id_tache ,@path_version, @images_log_files_path, @date_creation)--,@id_tache_log)
	
		EXEC msdb.dbo.sp_start_job N'Traitement V2 Import Doubles' ;
	END
	
	IF ((@id_tache = 3) OR (@id_tache = 10))
	BEGIN
		set @path_version = @chemin_dossier + 'V3\images\'
		set @images_log_files_path = @chemin_dossier + 'workspace\resources\reorganization_step\imagesLog\'
		INSERT INTO v_import_Parameters (id_source,id_utilisateur ,machine_traitement ,id_tache ,path_version, images_log_files_path, date_creation)--,id_tache_log)
		VALUES (@id_source,@id_utilisateur ,@machine_traitement ,@id_tache ,@path_version, @images_log_files_path, @date_creation)--,@id_tache_log)
	
		EXEC msdb.dbo.sp_start_job N'Traitement V3 Import' ;
	END	

	
END
GO
