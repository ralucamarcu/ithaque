SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.09.3014
-- Description:	
-- =============================================
--test run: [dbo].[spImportFichiers3] '\\10.1.0.196\bigvol\Sources\78-YVELINES-AD_TEST-AD\V2\'

CREATE PROCEDURE [dbo].[spImportFichiers3] 
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
		IF OBJECT_ID('DirTree3','u') IS NOT NULL
			DROP TABLE DirTree3
		CREATE TABLE DirTree3(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(138),DEPTH INT,IS_FILE BIT)

		IF OBJECT_ID('FolderBucket3','u') IS NOT NULL
			DROP TABLE FolderBucket3
		CREATE TABLE FolderBucket3(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(138),PROCESSED BIT DEFAULT(0))

		IF OBJECT_ID('Files3','u') IS NOT NULL
			DROP TABLE Files3
		CREATE TABLE Files3(ID INT IDENTITY,FILE_PATH VARCHAR(800),[FILE_NAME] VARCHAR(138))
	END
	ELSE
	BEGIN
		TRUNCATE TABLE DirTree3
	END

	INSERT INTO DirTree3(folder_name, DEPTH, is_file)  
	EXEC master..xp_DirTree @path,1,1
	
	
	UPDATE DirTree3 SET file_path = @path
	
	IF @suppression_tables = 1
	BEGIN
		CREATE CLUSTERED INDEX idx_folder_id3 ON DirTree3(FOLDER_ID)
		CREATE NONCLUSTERED INDEX idx_is_file3 ON   DirTree3(is_file) 
		CREATE NONCLUSTERED INDEX idx_file_path3 ON   DirTree3(file_path) 
		CREATE CLUSTERED INDEX idx_folder_id_fd3 ON   FolderBucket3(FOLDER_ID) 
		CREATE NONCLUSTERED INDEX idx_processed3 ON   FolderBucket3(PROCESSED) 
	END
	WHILE EXISTS (SELECT folder_id FROM DirTree3)
		BEGIN
			INSERT INTO FolderBucket3(file_path,folder_name)
			SELECT FILE_PATH,FOLDER_NAME
			FROM DirTree3
			WHERE IS_FILE = 0
			
			INSERT INTO Files3		 
			SELECT file_path,folder_name
			FROM DirTree3
			WHERE is_file = 1 

			TRUNCATE TABLE DirTree

			WHILE EXISTS (SELECT folder_id FROM FolderBucket3 WHERE processed = 0)
				BEGIN
					SELECT @folder_id = (SELECT MIN(folder_id) FROM FolderBucket3 WHERE processed = 0)
	
					SELECT @sub_path = (SELECT file_path + '' + folder_name FROM FolderBucket3 WHERE folder_id = @folder_id)

					--PRINT(@sub_path)
					SELECT @sql = 'INSERT INTO DirTree3(folder_name, depth, is_file)  
								EXEC master..xp_DirTree ''' +  REPLACE(@sub_path,'''','''''') + ''',1,1'
					EXEC(@sql)
				
					UPDATE FolderBucket3
					SET processed = 1
					WHERE folder_id = @folder_id
	
					UPDATE DirTree3
					SET file_path = @sub_path + '\'
					WHERE file_path IS NULL				   				 
				END
			END
END

GO
