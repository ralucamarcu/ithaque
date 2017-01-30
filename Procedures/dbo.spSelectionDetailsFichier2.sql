SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[spSelectionDetailsFichier2]
        @piFullPath VARCHAR(500) = '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\workspace\resources\reorganization_step\imagesLog\'
        ,@CurrentName varchar(500) = '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\workspace\resources\reorganization_step\imagesLog\log_renameImages_85179-POIROUX-1793-1795.xml'
     AS

    SET NOCOUNT ON

DECLARE @Counter          INT          --General purpose counter
DECLARE @DirTreeCount     INT          --Remembers number of rows for xp_DirTree
DECLARE @IsFile           BIT          --1 if Name is a file, 0 if not
DECLARE @ObjFile          INT          --File object
DECLARE @ObjFileSystem    INT          --File System Object  
DECLARE @Name             VARCHAR(128) --File Name and Extension
DECLARE @Path             VARCHAR(128) --Full path including file name
DECLARE @Size             INT          --File size in bytes
DECLARE @Type             VARCHAR(100) --Long Windows file type (eg.'Text Document',etc)

     IF OBJECT_ID('FileDetails2','U') IS NOT NULL
        DROP TABLE FileDetails2

 CREATE TABLE FileDetails2(RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,Name VARCHAR(128), Path VARCHAR(128),ShortName VARCHAR(12)
	,ShortPath VARCHAR(100),DateCreated DATETIME,DateLastAccessed DATETIME,DateLastModified DATETIME,Attributes INT
	,ArchiveBit AS CASE WHEN Attributes&  32=32   THEN 1 ELSE 0 END,CompressedBit AS CASE WHEN Attributes&2048=2048 THEN 1 ELSE 0 END
    ,ReadOnlyBit AS CASE WHEN Attributes&   1=1    THEN 1 ELSE 0 END,Size INT,Type VARCHAR(100))


 SELECT @piFullPath = @piFullPath+'\'
  WHERE RIGHT(@piFullPath,1)<>'\'
  
  print @piFullPath

 
   EXEC dbo.sp_OACreate 'Scripting.FileSystemObject', @ObjFileSystem OUT

                   EXEC dbo.sp_OAMethod @ObjFileSystem,'GetFile', @ObjFile OUT, @CurrentName
                   print @CurrentName
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Path',             @Path             OUT
                   print @Path
                   
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Name',             @Name             OUT
                   print @Name                   
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Size',             @Size             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Type',             @Type             OUT
     
                 INSERT INTO FileDetails2(Path, Name, Size, Type)
                 SELECT @Path,@Name,@Size,@Type
       
   EXEC sp_OADestroy @ObjFileSystem
   EXEC sp_OADestroy @ObjFile

--select * from FileDetails2
--drop table FileDetails2
GO
