SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.09.2014
-- Description:	select * from files
-- Test Run : exec [spImportFichiers] '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-QUENTIN-DU-DROPT--SAINT-QUENTIN\SAINT-QUENTIN-DU-DROPT--SAINT-QUENTIN_1767-1792\BMS\source_principale\', 1
-- Test Run : exec [spImportFichiers] '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS_1749-1755\BMS\source_principale\', 1
-- select * from files
-- =============================================
CREATE PROCEDURE [dbo].[spImportFichiers] 
	-- Add the parameters for the stored procedure here
	@path VARCHAR(800) --= '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS_1749-1755\BMS\source_principale\'
	,@suppression_tables BIT = 0
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @sub_path VARCHAR(800), @folder_id INT, @sql VARCHAR(4000)
	--if (@path = '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS_1749-1755\BMS\source_principale\')
	--begin
	--	set @path = '\\10.1.0.196\bigvol\Sources\4HGMGV~7\V3\images\ENKS36~A\STAJNU~R\S64MSG~Q\BMS\source_principale\'
	--end
	
	--SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS_1749-1755\BMS\source_principale\source_principale


	IF @suppression_tables = 1
	BEGIN
		IF OBJECT_ID('DirTree','u') IS NOT NULL
			DROP TABLE DirTree
		CREATE TABLE DirTree(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(800),DEPTH INT,IS_FILE BIT)

		IF OBJECT_ID('FolderBucket','u') IS NOT NULL
			DROP TABLE FolderBucket
		CREATE TABLE FolderBucket(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(800),PROCESSED BIT DEFAULT(0))

		IF OBJECT_ID('Files','u') IS NOT NULL
			DROP TABLE Files
		CREATE TABLE Files(ID INT IDENTITY,FILE_PATH VARCHAR(800),[FILE_NAME] VARCHAR(800))
	END
	ELSE
	BEGIN
		TRUNCATE TABLE DirTree
	END

	INSERT INTO DirTree(folder_name, DEPTH, is_file)  
	EXEC master..xp_DirTree @path,1,1	
	
	UPDATE DirTree SET file_path = @path
	--select * from DirTree
	delete from DirTree 
	where FILE_PATH like '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\%'
	--select * from DirTree
	
	IF @suppression_tables = 1
	BEGIN
		CREATE CLUSTERED INDEX idx_folder_id ON DirTree(FOLDER_ID)
		CREATE NONCLUSTERED INDEX idx_is_file ON   DirTree(is_file) 
		CREATE NONCLUSTERED INDEX idx_file_path ON   DirTree(file_path) 
		CREATE CLUSTERED INDEX idx_folder_id_fd ON   FolderBucket(FOLDER_ID) 
		CREATE NONCLUSTERED INDEX idx_processed ON   FolderBucket(PROCESSED) 
	END
	WHILE EXISTS (SELECT folder_id FROM DirTree
	where FILE_PATH not like '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\%')
		BEGIN
			INSERT INTO FolderBucket(file_path,folder_name)
			SELECT FILE_PATH,FOLDER_NAME
			FROM DirTree
			WHERE IS_FILE = 0
			and FILE_PATH not like '\\10.1.0.196\bigvol\Sources\47-LOT-ET-GARONNE-AD\V3\images\EC_avant_1792\SAINT-MAURIN--SAINT-PIERRE-DELPECH-SAINT-JULIEN-DE-LASSERRE-SAINT-MARTIN-D--ANGLARS\%'

			
			--select * from FolderBucket
			
			INSERT INTO Files		 
			SELECT file_path,folder_name
			FROM DirTree
			WHERE is_file = 1 

			TRUNCATE TABLE DirTree
		

			WHILE EXISTS (SELECT folder_id FROM FolderBucket WHERE processed = 0)
				BEGIN
					SELECT @folder_id = (SELECT MIN(folder_id) FROM FolderBucket WHERE processed = 0)
	
					SELECT @sub_path = (SELECT file_path + '' + folder_name FROM FolderBucket WHERE folder_id = @folder_id)

					PRINT(@sub_path)
					SELECT @sql = 'INSERT INTO DirTree(folder_name, depth, is_file)  
								EXEC master..xp_DirTree ''' +  REPLACE(@sub_path,'''','''''') + ''',1,1'
					EXEC(@sql)
					print @sql
				
					UPDATE FolderBucket
					SET processed = 1
					WHERE folder_id = @folder_id
					
					print @folder_id
	
					UPDATE DirTree
					SET file_path = @sub_path + '\'
					WHERE file_path IS NULL				   				 
				END
			END
END

GO
