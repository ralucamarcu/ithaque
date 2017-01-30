SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24/08/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spBackupDatabases]

AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @name VARCHAR(50) -- database name  
	DECLARE @path VARCHAR(256) -- path for backup files  
	DECLARE @fileName VARCHAR(256) -- filename for backup  
	DECLARE @fileDate VARCHAR(20) -- used for file name

 
	-- specify database backup directory
	SET @path = '\\10.1.0.196\bigvol\BackupSQLTest\'

 
	-- specify filename format
	SELECT @fileDate =CONVERT(VARCHAR(20),GETDATE(),112)  + '_'  + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','') 

 
	DECLARE db_cursor CURSOR FOR  
	SELECT name 
	FROM master.dbo.sysdatabases 
	WHERE name = 'Traitements_Images' --- IN ('Ithaque','Traitements_Images','Ithaque_Reecriture')   -- take these databases

 
	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @name   

 
	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
		   BACKUP DATABASE @name TO DISK = @fileName  WITH Checksum,COMPRESSION

 
		   FETCH NEXT FROM db_cursor INTO @name   
	END   

 
	CLOSE db_cursor   
	DEALLOCATE db_cursor

END
GO
