SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 28/01/2015
-- Description:	Liste les fichiers batches XML dans l'arborescence d'un projet et insère les noms des fichiers dans la table FichiersData
-- =============================================
CREATE PROCEDURE [dbo].[spImportXMLBatchesList] 
	-- Test Run : [spImportXMLBatchesList] '{c80dff45-1b3e-47a8-bb59-aefc642b0f92}'
	@id_projet uniqueidentifier, @depth int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @project_path as varchar(2048)
	DECLARE @xmlbatches_path as varchar(2048)
	
	SELECT @project_path=LTRIM(RTRIM(chemin_dossier_general)) FROM dbo.Projets WITH (NOLOCK) WHERE id_projet=@id_projet
	IF LEN(ISNULL(@project_path,''))>0
	BEGIN
		print 1
		SET @project_path = CASE WHEN RIGHT(@project_path, 1)='\' THEN LEFT(@project_path, LEN(@project_path)-1) ELSE @project_path END
		SET @xmlbatches_path = @project_path + '\V5\batches'
		IF OBJECT_ID('tempdb..#DirTree') IS NOT NULL
			DROP TABLE #DirTree
		CREATE TABLE #DirTree(FOLDER_ID INT IDENTITY(1,1),NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)
		INSERT INTO #DirTree(NAME, DEPTH, is_file)
		EXEC master..xp_DirTree @xmlbatches_path,@depth,1
		UPDATE #DirTree SET NAME=REPLACE(NAME, '_batch_', '_output_') WHERE IS_FILE=1 AND RTRIM(LTRIM(NAME)) LIKE '%_batch_%.xml'
		
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO FichiersData (nom, id_projet)
			SELECT NAME, @id_projet 
			FROM #DirTree dt
			LEFT JOIN FichiersData fd WITH (NOLOCK) ON fd.id_projet=@id_projet AND fd.nom=dt.NAME COLLATE FRENCH_CI_AS
			WHERE fd.id_fichier IS NULL AND dt.IS_FILE=1 AND RTRIM(LTRIM(dt.NAME)) LIKE '%_output_%.xml'
			
			IF @@ROWCOUNT > 0
			BEGIN
				UPDATE dbo.Projets SET import_batches_xml=1 WHERE id_projet=@id_projet
			END
			
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			SELECT 
				ERROR_NUMBER() AS ErrorNumber
				,ERROR_SEVERITY() AS ErrorSeverity
				,ERROR_STATE() AS ErrorState
				,ERROR_PROCEDURE() AS ErrorProcedure
				,ERROR_LINE() AS ErrorLine
				,ERROR_MESSAGE() AS ErrorMessage;

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
		END CATCH;
		
	END

	IF OBJECT_ID('v_import_fichier_projet_Parameters') IS NOT NULL 
		BEGIN
			DROP TABLE v_import_fichier_projet_Parameters
			CREATE TABLE v_import_fichier_projet_Parameters (id int identity,id_projet uniqueidentifier)
		END
	
	INSERT INTO v_import_fichier_projet_Parameters (id_projet) VALUES (@id_projet)
	
	EXEC msdb.dbo.sp_start_job 'ComparaisonBatchFile_MAJImagesFichierDataBatch'
END
GO
