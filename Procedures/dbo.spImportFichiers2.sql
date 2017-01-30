SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.09.2014
-- Description:	
-- =============================================

--test run: [dbo].[spImportFichiers2] '\\10.1.0.196\bigvol\Sources\81-TARN-AD\V2\'
CREATE PROCEDURE [dbo].[spImportFichiers2] 
	-- Add the parameters for the stored procedure here
	@path VARCHAR(800) 
	,@suppression_tables BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @sub_path VARCHAR(800), @folder_id INT, @sql VARCHAR(4000)

	IF @suppression_tables = 1
	BEGIN
		IF OBJECT_ID('DirTree2','u') IS NOT NULL
			DROP TABLE DirTree2
		CREATE TABLE DirTree2(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)

		IF OBJECT_ID('FolderBucket2','u') IS NOT NULL
			DROP TABLE FolderBucket2
		CREATE TABLE FolderBucket2(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(128),PROCESSED BIT DEFAULT(0))

		IF OBJECT_ID('Files2','u') IS NOT NULL
			DROP TABLE Files2
		CREATE TABLE Files2(ID INT IDENTITY,FILE_PATH VARCHAR(800),[FILE_NAME] VARCHAR(128))
	END
	ELSE
	BEGIN
		TRUNCATE TABLE DirTree2
	END

	INSERT INTO DirTree2(folder_name, DEPTH, is_file)  
	EXEC master..xp_DirTree @path,1,1
	
	
	UPDATE DirTree2 SET file_path = @path
	
	IF @suppression_tables = 1
	BEGIN
		CREATE CLUSTERED INDEX idx_folder_id2 ON DirTree2(FOLDER_ID)
		CREATE NONCLUSTERED INDEX idx_is_file2 ON   DirTree2(is_file) 
		CREATE NONCLUSTERED INDEX idx_file_path2 ON   DirTree2(file_path) 
		CREATE CLUSTERED INDEX idx_folder_id_fd2 ON   FolderBucket2(FOLDER_ID) 
		CREATE NONCLUSTERED INDEX idx_processed2 ON   FolderBucket2(PROCESSED) 
	END
	WHILE EXISTS (SELECT folder_id FROM DirTree2)
		BEGIN
			INSERT INTO FolderBucket2(file_path,folder_name)
			SELECT FILE_PATH,FOLDER_NAME
			FROM DirTree2
			WHERE IS_FILE = 0
			
			INSERT INTO Files2		 
			SELECT file_path,folder_name
			FROM DirTree2
			WHERE is_file = 1 

			TRUNCATE TABLE DirTree

			WHILE EXISTS (SELECT folder_id FROM FolderBucket2 WHERE processed = 0)
				BEGIN
					SELECT @folder_id = (SELECT MIN(folder_id) FROM FolderBucket2 WHERE processed = 0)
	
					SELECT @sub_path = (SELECT file_path + '' + folder_name FROM FolderBucket2 WHERE folder_id = @folder_id)

					--PRINT(@sub_path)
					SELECT @sql = 'INSERT INTO DirTree2(folder_name, depth, is_file)  
								EXEC master..xp_DirTree ''' +  REPLACE(@sub_path,'''','''''') + ''',1,1'
					EXEC(@sql)
				
					UPDATE FolderBucket2
					SET processed = 1
					WHERE folder_id = @folder_id
	
					UPDATE DirTree2
					SET file_path = @sub_path + '\'
					WHERE file_path IS NULL				   				 
				END
			END
END

GO
