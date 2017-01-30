SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--test run: [dbo].[spCalculMetadataFileXML]  456065
CREATE PROCEDURE [dbo].[spCalculMetadataFileXML] 
	@id_file_metadata INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @path VARCHAR(255) = (SELECT path_source + nom_fichier_metadata FROM FilesMetadata WITH (NOLOCK) WHERE id_file_metadata = @id_file_metadata)
	DECLARE @sqlCommand1 NVARCHAR(2000) = ''
	DECLARE @xmlstring VARCHAR(MAX)
	CREATE TABLE Tmp_calculMedataXML (IntCol INT, XmlCol varchar(max)) 
    SET @sqlCommand1 = @sqlCommand1 + 'INSERT INTO Tmp_calculMedataXML(XmlCol) ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SELECT * FROM OPENROWSET( ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'BULK ''' + CAST(@path AS NVARCHAR(255)) + ''','+ CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SINGLE_BLOB '  + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + ') AS x '  + CHAR(10) + CHAR(13)
    EXEC sp_executesql @sqlCommand1
	
	
	SET @xmlstring = (SELECT '<root>' + replace(CAST(XmlCol AS nVARCHAR(MAX)), CHAR(160), N' ') +'</root>' FROM Tmp_calculMedataXML )
	set @xmlstring = '<?xml version="1.0" encoding="ISO-8859-1"?>' + @xmlstring
	set @xmlstring = REPLACE (@xmlstring, '&', '&#38;')

	--select @xmlstring
	--select * from Tmp_calculMedataXML

	DECLARE @DocHandle INT

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @xmlstring
	
	SELECT x.oldPath, x.oldName, x.newPath, x.newName , @id_file_metadata as id_file_metadata
	INTO #temp FROM OPENXML(@DocHandle, '/root/image',1) 
	WITH (oldPath  VARCHAR(255),oldName  VARCHAR(100),newPath  VARCHAR(255),newName  VARCHAR(100), id_file_metadata int) AS x
	
	EXEC sp_xml_removedocument @DocHandle 
	SELECT * FROM #temp
	
	DROP TABLE Tmp_calculMedataXML

END

GO
