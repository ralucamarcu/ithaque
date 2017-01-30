SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spSelectionDetailsFichier_v1]
--Test Run : [spSelectionDetailsFichier_v1] '\\10.1.0.196\bigvol\Projets\p99-73-SAVOIE-AD\V5\images\RP\SAINT-OFFENGE-DESSUS\SAINT-OFFENGE-DESSUS_1814\M\source_principale', 1
         @piFullPath VARCHAR(500) 
         ,@suppression_tables BIT = 1
AS
begin
	SET NOCOUNT ON

	DECLARE @Counter INT, @CurrentName VARCHAR(500), @DirTreeCount INT, @IsFile BIT, @ObjFile INT, @ObjFileSystem INT,@DateCreated DATETIME
		, @DateLastAccessed DATETIME, @DateLastModified DATETIME, @Name VARCHAR(500), @Path VARCHAR(500), @Size INT, @Type VARCHAR(100)

	IF OBJECT_ID('TempDB..#DirTree_v1','U') IS NOT NULL
        DROP TABLE #DirTree_v1
	CREATE TABLE #DirTree_v1(RowNum INT IDENTITY(1,1),Name   VARCHAR(500) PRIMARY KEY CLUSTERED, DEPTH  BIT, IsFile BIT)
  
	if @suppression_tables = 1
	begin
		IF OBJECT_ID('FileDetails_v1','U') IS NOT NULL
			DROP TABLE FileDetails_v1
		CREATE TABLE FileDetails_v1(RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,Name VARCHAR(500), PATH VARCHAR(500)
			,DateCreated DATETIME,DateLastAccessed DATETIME,DateLastModified DATETIME,SIZE INT,TYPE VARCHAR(100))
	end
 
	SELECT @piFullPath = @piFullPath+'\' WHERE RIGHT(@piFullPath,1)<>'\'

	INSERT INTO #DirTree_v1 (Name, DEPTH, IsFile)
    EXEC Master.dbo.xp_DirTree @piFullPath,1,1 

    SET @DirTreeCount = @@ROWCOUNT

	UPDATE #DirTree_v1 SET Name = @piFullPath + Name

	EXEC dbo.sp_OACreate 'Scripting.FileSystemObject', @ObjFileSystem OUT

    SET @Counter = 1
	WHILE @Counter <= @DirTreeCount
	BEGIN
		SELECT @CurrentName = Name,@IsFile = IsFile FROM #DirTree_v1 WHERE RowNum = @Counter
 
        IF @IsFile = 1 AND @CurrentName LIKE '%%'
        BEGIN
                   EXEC dbo.sp_OAMethod @ObjFileSystem,'GetFile', @ObjFile OUT, @CurrentName
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Path',             @Path             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Name',             @Name             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateCreated',      @DateCreated      OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastAccessed', @DateLastAccessed OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastModified', @DateLastModified OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Size',             @Size             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Type',             @Type             OUT
     
                 INSERT INTO FileDetails_v1(PATH, Name, DateCreated, DateLastAccessed, DateLastModified, SIZE, TYPE)
                 SELECT @Path,@Name,@DateCreated, @DateLastAccessed,@DateLastModified,@Size,@Type
        END        
        SELECT @Counter = @Counter + 1
   END

   EXEC sp_OADestroy @ObjFileSystem
   EXEC sp_OADestroy @ObjFile
end 


--select * from FileDetails_v1  
GO
