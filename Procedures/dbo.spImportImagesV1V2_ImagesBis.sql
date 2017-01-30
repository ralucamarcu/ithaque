SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.01.2015
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spImportImagesV1V2_ImagesBis] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spImportImagesV1V2_ImagesBis] 'ec04965a-30b1-4bb4-a2b7-cb22a171259b', 2, 'test',1, ''
	@id_source UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = NULL
	,@path VARCHAR(500) = NULL
	,@id_tache_log int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @IntegerResult INT
    DECLARE @id_file INT, @file_path VARCHAR(500), @file_name VARCHAR(255), @file_name_path VARCHAR(255), @id_tache int
		,@id_tache_log_details int
    
    set @id_tache = 9
	IF @path IS NOT NULL
	BEGIN
		EXEC dbo.spImportFichiers @path = @path, @suppression_tables = 1
	END
	
	CREATE TABLE #tmpFilesV1([ID] [INT] NULL,[FILE_PATH] [VARCHAR](500) NULL,[FILE_NAME] [VARCHAR](128) NULL)
	CREATE TABLE #tmpFilesV2([ID] [INT] NULL,[FILE_PATH] [VARCHAR](500) NULL,[FILE_NAME] [VARCHAR](128) NULL)
	
	INSERT INTO #tmpFilesV1
	SELECT * FROM Files WITH (NOLOCK) WHERE file_path LIKE '%V1%'
	
	INSERT INTO #tmpFilesV2
	SELECT * FROM Files WITH (NOLOCK) WHERE file_path LIKE '%V2%'	
	
    CREATE CLUSTERED INDEX idx_id_tmpFiles ON #tmpFilesV1(id)
    CREATE NONCLUSTERED INDEX idx_file_path_tmpFiles ON #tmpFilesV1(file_path)
    
    CREATE CLUSTERED INDEX idx_id_tmpFiles ON #tmpFilesV2(id)
    CREATE NONCLUSTERED INDEX idx_file_path_tmpFiles ON #tmpFilesV2(file_path)
    
    CREATE TABLE #images (id_image UNIQUEIDENTIFIER, path_origine VARCHAR(255), nom_fichier_origine VARCHAR(255))
	INSERT INTO #images
	SELECT id_image, path_origine, nom_fichier_origine
	FROM Images WITH (NOLOCK)
	WHERE id_source = @id_source
	
	UPDATE Taches_Logs
	SET id_status=3
			,doit_etre_execute=0
			,date_debut = @date
	WHERE id_tache_log=@id_tache_log

	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	
	BEGIN TRY
	BEGIN TRANSACTION spImportImages_ImagesBis;
			
			INSERT INTO Images (id_source, path_origine, id_status_version_processus, date_creation, nom_fichier_origine)
			SELECT @id_source AS id_source, file_path AS path_origine, 1 AS id_status_version_processus, @date AS date_creation
				, [FILE_NAME] AS nom_fichier_origine
			FROM #tmpFilesV1 f WITH (NOLOCK)
			LEFT JOIN #images i WITH (NOLOCK) ON f.FILE_PATH = i.path_origine AND f.[FILE_NAME] = i.nom_fichier_origine			 
			WHERE id_image IS NULL  AND [FILE_NAME] LIKE '%.jpg'
			
			INSERT INTO Taches_Images_Logs(id_image, path_origine, id_tache, date_creation, nom_fichier_image_origine)
			SELECT i.id_image , i.path_origine AS path_origine, 1 AS id_tache, @date AS date_creation, [FILE_NAME] AS nom_fichier_image_origine
			FROM Images i WITH (NOLOCK)
			INNER JOIN #tmpFilesV1 t ON i.nom_fichier_origine = t.[file_name] AND  i.path_origine =t.file_path
			WHERE i.id_source = @id_source
				AND DATEADD(dd,0,DATEDIFF(dd,0, i.date_creation)) >= DATEADD(dd,0,DATEDIFF(dd,0, @date))	
			
			INSERT INTO Taches_Images_Logs(id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
				,nom_fichier_image_destination)
			SELECT tli.id_image , tli.path_origine AS path_origine, t.FILE_PATH AS path_destination, 2 AS id_tache, @date AS date_creation
				, tli.nom_fichier_image_origine AS nom_fichier_image_origine, t.[FILE_NAME] AS nom_fichier_image_destination
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN #tmpFilesV2 t ON tli.nom_fichier_image_origine = t.[file_name] 
			WHERE DATEADD(dd,0,DATEDIFF(dd,0, tli.date_creation)) >= DATEADD(dd,0,DATEDIFF(dd,0, @date))

	
			
	COMMIT TRANSACTION spImportImages_ImagesBis;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spImportImages_ImagesBis;
		
		SET @IntegerResult = -1
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
	IF (@IntegerResult = 1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
	
	
	
	
	DROP TABLE #tmpFilesV1
	DROP TABLE #tmpFilesV2
	DROP TABLE #images
	
	
END

GO
