SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 25.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spAnalyseXMLFichiers] 
	-- Add the parameters for the stored procedure here
	-- Tets Run : spAnalyseXMLFichiers '\\10.1.0.196\bigvol\Projets\p37-AD85\V5\output\delivery\20140131\EC\EC85_output_85215_1837-1842_NMD_6760.xml'
	@chemin VARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE Tmp (id INT, instructions XML)

	--INSERT INTO Tmp (instructions)
	--SELECT CONVERT (XML, BulkColumn, 2 )   FROM OPENROWSET ( 
	--  BULK '\\10.1.0.196\bigvol\Projets\p37-AD85\V5\output\delivery\20140131\EC\EC85_output_85210_1899_D_6708.xml',
	--  SINGLE_BLOB) AS X 
	
	DECLARE @sqlCommand1 NVARCHAR(2000) = ''
	SET @sqlCommand1 = @sqlCommand1 + 'INSERT INTO Tmp(instructions) ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SELECT CONVERT (XML, BulkColumn, 2 )  FROM OPENROWSET( ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'BULK ''' + CAST(@chemin AS NVARCHAR(255)) + ''','+ CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SINGLE_BLOB '  + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + ') AS x '  + CHAR(10) + CHAR(13)
    EXEC sp_executesql @sqlCommand1
  
	SET ANSI_NULLS ON
	SET ANSI_PADDING ON
	SET ANSI_WARNINGS ON
	SET ARITHABORT ON
	SET CONCAT_NULL_YIELDS_NULL ON
	SET NUMERIC_ROUNDABORT OFF
	SET QUOTED_IDENTIFIER ON 

  
	SELECT T2.Loc.value('@document', 'varchar(150)') AS DOCUMENT
	,T2.Loc.value('@type', 'varchar(50)') AS [TYPE]
	,T2.Loc.value('@soustype', 'varchar(50)') AS soustype
	,T2.Loc.value('(id/text())[1]', 'varchar(150)') AS [id]
	,T2.Loc.value('(date_acte/text())[1]', 'varchar(50)') AS date_acte
	,T2.Loc.value('(date_acte/@annee)[1]', 'varchar(50)') AS annee
	,T2.Loc.value('(date_acte/@calendrier)[1]', 'varchar(50)') AS calendrier
	,T2.Loc.value('(lieu/text())[1]', 'varchar(150)') AS lieu
	,T2.Loc.value('(lieu/@insee)[1]', 'int') AS insee	
	,T4.Loc.value('@ordre', 'int')  AS ordre
	,T4.Loc.value('@cache', 'varchar(50)')  AS cache
	,T4.Loc.value('@primaire', 'varchar(50)')  AS primaire
	,T4.Loc.value('(image/@statut)[1]', 'varchar(50)')  AS statut
	,T4.Loc.value('(image/@chemin)[1]', 'varchar(250)')  AS chemin
	FROM   Tmp
	CROSS APPLY instructions.nodes('/lot/evenement')  T2(Loc) 
	CROSS APPLY T2.Loc.nodes('zones/*') AS T4(Loc)
	
	SELECT T2.Loc.value('@document', 'varchar(150)') AS DOCUMENT
	,T2.Loc.value('@type', 'varchar(50)') AS [TYPE]
	,T2.Loc.value('@soustype', 'varchar(50)') AS soustype
	,T2.Loc.value('(id/text())[1]', 'varchar(150)') AS [id]
	,T2.Loc.value('(date_acte/text())[1]', 'varchar(50)') AS date_acte
	,T2.Loc.value('(date_acte/@annee)[1]', 'varchar(50)') AS annee
	,T2.Loc.value('(date_acte/@calendrier)[1]', 'varchar(50)') AS calendrier
	,T2.Loc.value('(lieu/text())[1]', 'varchar(150)') AS lieu
	,T2.Loc.value('(lieu/@insee)[1]', 'int') AS insee
	,T2.Loc.value('(lieu/@geonameid)[1]', 'int') AS geonameid

	,T3.Loc.value('@principal', 'bit')  AS principal
	,T3.Loc.value('(id_individu/text())[1]', 'varchar(150)') AS id_individu
	,T3.Loc.value('(nom/text())[1]', 'varchar(150)') AS nom
	,T3.Loc.value('(prenom/text())[1]', 'varchar(150)') AS prenom
	
	,T5.Loc.value('@ordre', 'int')  AS ordre
	,T5.Loc.value('@cache', 'varchar(50)')  AS cache
	,T5.Loc.value('@primaire', 'varchar(50)')  AS primaire
	,T5.Loc.value('(image/@statut)[1]', 'varchar(50)')  AS statut
	,T5.Loc.value('(image/@chemin)[1]', 'varchar(250)')  AS chemin
	,T5.Loc.value('(rectangle/@x1)[1]', 'varchar(50)')  AS x1
	,T5.Loc.value('(rectangle/@y1)[1]', 'varchar(50)')  AS y1
	,T5.Loc.value('(rectangle/@x2)[1]', 'varchar(50)')  AS x2
	,T5.Loc.value('(rectangle/@y2)[1]', 'varchar(50)')  AS y2
	FROM   Tmp
	CROSS APPLY instructions.nodes('/lot/evenement') AS T2(Loc) 
	CROSS APPLY T2.Loc.nodes('individus/*') AS T3(Loc)	
	CROSS APPLY T2.Loc.nodes('zones/*') AS T5(Loc)
	
	
	
	
	SELECT T2.Loc.value('@document', 'varchar(150)') AS DOCUMENT
	,T2.Loc.value('@type', 'varchar(50)') AS [TYPE]
	,T2.Loc.value('@soustype', 'varchar(50)') AS soustype
	,T2.Loc.value('(id/text())[1]', 'varchar(150)') AS [id]
	,T2.Loc.value('(date_acte/text())[1]', 'varchar(50)') AS date_acte
	,T2.Loc.value('(date_acte/@annee)[1]', 'varchar(50)') AS annee
	,T2.Loc.value('(date_acte/@calendrier)[1]', 'varchar(50)') AS calendrier
	,T2.Loc.value('(lieu/text())[1]', 'varchar(150)') AS lieu
	,T2.Loc.value('(lieu/@insee)[1]', 'int') AS insee
	,T2.Loc.value('(lieu/@geonameid)[1]', 'int') AS geonameid

	,T3.Loc.value('@principal', 'bit')  AS principal
	,T3.Loc.value('(id_individu/text())[1]', 'varchar(150)') AS id_individu
	,T3.Loc.value('(nom/text())[1]', 'varchar(150)') AS nom
	,T3.Loc.value('(prenom/text())[1]', 'varchar(150)') AS prenom

	,T4.Loc.value('@id_ind', 'varchar(150)')  AS id_ind
	,T4.Loc.value('@id_ind_rel', 'varchar(150)')  AS id_ind_rel
	,T4.Loc.value('@nom_relation', 'varchar(150)')  AS nom_relation
	
	,T5.Loc.value('@ordre', 'int')  AS ordre
	,T5.Loc.value('@cache', 'varchar(50)')  AS cache
	,T5.Loc.value('@primaire', 'varchar(50)')  AS primaire
	,T5.Loc.value('(image/@statut)[1]', 'varchar(50)')  AS statut
	,T5.Loc.value('(image/@chemin)[1]', 'varchar(250)')  AS chemin
	,T5.Loc.value('(rectangle/@x1)[1]', 'varchar(50)')  AS x1
	,T5.Loc.value('(rectangle/@y1)[1]', 'varchar(50)')  AS y1
	,T5.Loc.value('(rectangle/@x2)[1]', 'varchar(50)')  AS x2
	,T5.Loc.value('(rectangle/@y2)[1]', 'varchar(50)')  AS y2
	FROM   Tmp
	CROSS APPLY instructions.nodes('/lot/evenement') AS T2(Loc) 
	CROSS APPLY T2.Loc.nodes('individus/*') AS T3(Loc)
	CROSS APPLY T2.Loc.nodes('relations/*') AS T4(Loc)
	CROSS APPLY T2.Loc.nodes('zones/*') AS T5(Loc)

	DROP TABLE Tmp
	
	SET ANSI_NULLS OFF
	SET ANSI_PADDING OFF
	SET ANSI_WARNINGS OFF
	SET ARITHABORT OFF
	SET CONCAT_NULL_YIELDS_NULL OFF
	SET NUMERIC_ROUNDABORT OFF
	SET QUOTED_IDENTIFIER OFF

END
GO
