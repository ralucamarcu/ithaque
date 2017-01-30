SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.09.2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spImportFichiers_temp] 
	-- Add the parameters for the stored procedure here
	@path VARCHAR(200) 
	,@suppression_tables BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @sub_path VARCHAR(200), @folder_id INT, @sql VARCHAR(4000)

	IF @suppression_tables = 1
	BEGIN
		IF OBJECT_ID('DirTree_temp','u') IS NOT NULL
			DROP TABLE DirTree_temp
		CREATE TABLE DirTree_temp(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(500),FOLDER_NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)

		IF OBJECT_ID('FolderBucket_temp','u') IS NOT NULL
			DROP TABLE FolderBucket_temp
		CREATE TABLE FolderBucket_temp(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(500),FOLDER_NAME VARCHAR(128),PROCESSED BIT DEFAULT(0))

		IF OBJECT_ID('Files_temp','u') IS NOT NULL
			DROP TABLE Files_temp
		CREATE TABLE Files_temp(ID INT IDENTITY,FILE_PATH VARCHAR(500),[FILE_NAME] VARCHAR(128))
	END
	ELSE
	BEGIN
		TRUNCATE TABLE DirTree_temp
	END

	INSERT INTO DirTree_temp(folder_name, DEPTH, is_file)  
	EXEC master..xp_DirTree @path,1,1
	
	
	UPDATE DirTree_temp SET file_path = @path
	
	IF @suppression_tables = 1
	BEGIN
		CREATE CLUSTERED INDEX idx_folder_id ON DirTree_temp(FOLDER_ID)
		CREATE NONCLUSTERED INDEX idx_is_file ON   DirTree_temp(is_file) 
		CREATE NONCLUSTERED INDEX idx_file_path ON   DirTree_temp(file_path) 
		CREATE CLUSTERED INDEX idx_folder_id_fd ON   FolderBucket_temp(FOLDER_ID) 
		CREATE NONCLUSTERED INDEX idx_processed ON   FolderBucket_temp(PROCESSED) 
	END
	WHILE EXISTS (SELECT folder_id FROM DirTree_temp)
		BEGIN
			INSERT INTO FolderBucket_temp(file_path,folder_name)
			SELECT FILE_PATH,FOLDER_NAME
			FROM DirTree_temp
			WHERE IS_FILE = 0
			
			INSERT INTO Files_temp		 
			SELECT file_path,folder_name
			FROM DirTree_temp
			WHERE is_file = 1 

			TRUNCATE TABLE DirTree_temp

			WHILE EXISTS (SELECT folder_id FROM FolderBucket_temp WHERE processed = 0)
				BEGIN
					SELECT @folder_id = (SELECT MIN(folder_id) FROM FolderBucket_temp WHERE processed = 0)
	
					SELECT @sub_path = (SELECT file_path + '' + folder_name FROM FolderBucket_temp WHERE folder_id = @folder_id)

					--PRINT(@sub_path)
					SELECT @sql = 'INSERT INTO DirTree_temp(folder_name, depth, is_file)  
								EXEC master..xp_DirTree ''' +  REPLACE(@sub_path,'''','''''') + ''',1,1'
					EXEC(@sql)
				
					UPDATE FolderBucket_temp
					SET processed = 1
					WHERE folder_id = @folder_id
	
					UPDATE DirTree_temp
					SET file_path = @sub_path + '\'
					WHERE file_path IS NULL				   				 
				END
			END
END

GO
