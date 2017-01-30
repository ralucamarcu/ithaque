SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- Test Run : select * from  [dbo].[fnSelectionDetailsFichier]('\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V1\AD85\ETAT CIVIL\', '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V1\AD85\ETAT CIVIL\001D1_1_AE\001D1_1_AE_0001.JPG')
-- Test Run : select * from [dbo].[fnSelectionDetailsFichier] ('\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\workspace\resources\reorganization_step\imagesLog\', '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\workspace\resources\reorganization_step\imagesLog\log_renameImages_85179-POIROUX-1793-1795.xml')

CREATE FUNCTION  [dbo].[fnSelectionDetailsFichier]( @piFullPath VARCHAR(500), @CurrentName VARCHAR(500))
RETURNS @filedetails2 TABLE
  ( RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,Name VARCHAR(128), PATH VARCHAR(128)
	,DateCreated DATETIME,DateLastAccessed DATETIME,DateLastModified DATETIME,SIZE INT,TYPE VARCHAR(100)  )
     AS

BEGIN
DECLARE @Counter          INT          --General purpose counter
DECLARE @DirTreeCount     INT          --Remembers number of rows for xp_DirTree
DECLARE @IsFile           BIT          --1 if Name is a file, 0 if not
DECLARE @ObjFile          INT          --File object
DECLARE @ObjFileSystem    INT          --File System Object  
DECLARE @DateCreated      DATETIME     --Date file was created
DECLARE @DateLastAccessed DATETIME     --Date file was last read (accessed)
DECLARE @DateLastModified DATETIME     --Date file was last written to
DECLARE @Name             VARCHAR(128) --File Name and Extension
DECLARE @Path             VARCHAR(128) --Full path including file name
DECLARE @Size             INT          --File size in bytes
DECLARE @Type             VARCHAR(100) --Long Windows file type (eg.'Text Document',etc)    

   SELECT @piFullPath = @piFullPath+'\'
   WHERE RIGHT(@piFullPath,1)<>'\'

 
   EXEC dbo.sp_OACreate 'Scripting.FileSystemObject', @ObjFileSystem OUT

   EXEC dbo.sp_OAMethod @ObjFileSystem,'GetFile', @ObjFile OUT, @CurrentName
   EXEC dbo.sp_OAGetProperty @ObjFile, 'Path',             @Path             OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'Name',             @Name             OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateCreated',      @DateCreated      OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastAccessed', @DateLastAccessed OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastModified', @DateLastModified OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'Size',             @Size             OUT
   EXEC dbo.sp_OAGetProperty @ObjFile, 'Type',             @Type             OUT
     
   INSERT INTO @filedetails2(PATH, Name, DateCreated, DateLastAccessed, DateLastModified, SIZE, TYPE)
   SELECT @Path,@Name,@DateCreated, @DateLastAccessed,@DateLastModified,@Size,@Type
       
   EXEC sp_OADestroy @ObjFileSystem
   EXEC sp_OADestroy @ObjFile
   RETURN ;

END

GO
