SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spWriteStringToFile]
 (
@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(500),
@Filename VARCHAR(500)

--
)
AS
DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @HR int,
		@fileAndPath varchar(800),
		@Append int

set nocount on

select @strErrorMessage='opening the File System Object'
EXECUTE @HR = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT






Select @FileAndPath=@path+'\'+@filename
--if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'
--if @HR=0 execute @HR = sp_OAMethod   @objFileSystem   , 'CreateTextFile'
--	, @objTextStream OUT, @FileAndPath,2,True
EXEC sp_OAMethod @objFileSystem, 'FileExists', @Append out, @FileAndPath

IF @Append = 1
BEGIN
	--open the text stream for append
	IF @HR=0 EXECUTE @HR = sp_OAMethod @objFileSystem,'OpenTextFile', @objTextStream OUTPUT, @FileAndPath, 8
END
ELSE
BEGIN
	--Create the text file for write
	IF @HR=0 EXECUTE @HR = sp_OAMethod @objFileSystem,'CreateTextFile',@objTextStream OUTPUT,@FileAndPath,-1
END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='writing to the file "'+@FileAndPath+'"'
if @HR=0 execute @HR = sp_OAMethod  @objTextStream, 'Write', Null, @String

if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
if @HR=0 execute @HR = sp_OAMethod  @objTextStream, 'Close'

if @HR<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	raiserror (@strErrorMessage,16,1)
	end
EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objTextStream
GO
