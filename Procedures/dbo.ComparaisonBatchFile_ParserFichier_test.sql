SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 18/08/2015
-- Description:	<Description>
-- =============================================
--testrun: ComparaisonBatchFile_ParserFichier_test @chemin ='\\10.1.0.196\bigvol\Projets\p37-AD85\V4\batches\EC\', @nom_fichier= 'EC69_batch_69001_1793-1794_D_95803.xml'

CREATE PROCEDURE ComparaisonBatchFile_ParserFichier_test
@chemin VARCHAR(500),
@nom_fichier varchar (150)

AS
BEGIN

	SET NOCOUNT ON

	CREATE TABLE Tmporar (id INT, instructions XML)
	CREATE TABLE #temp_Fichier_chemin(id int identity, nom_fichier varchar(150),id_fichier_data uniqueidentifier,chemin varchar(150),id_image uniqueidentifier)

	--DECLARE @chemin VARCHAR(500)='\\10.1.0.196\bigvol\Projets\p99-78-YVELINES-AD\V5\batches\EC\', @nom_fichier varchar (150)= 'EC78_batch_78361_1901-1901_M_1249.xml'
	DECLARE @chemin_path VARCHAR(500)=@chemin+@nom_fichier
	DECLARE @id_projet uniqueidentifier,@id_source uniqueidentifier
	
	SET @id_projet= (SELECT id_projet FROM FichiersData WHERE nom=REPLACE(@nom_fichier,'batch','output'))

	DECLARE @sqlCommand1 NVARCHAR(2000) = ''
	SET @sqlCommand1 = @sqlCommand1 + 'INSERT INTO Tmporar(instructions) ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SELECT CONVERT (XML, BulkColumn, 2 )  FROM OPENROWSET( ' + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'BULK ''' + CAST(@chemin_path AS NVARCHAR(255)) + ''','+ CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + 'SINGLE_BLOB '  + CHAR(10) + CHAR(13)
    SET @sqlCommand1 = @sqlCommand1 + ') AS x '  + CHAR(10) + CHAR(13)
    EXEC sp_executesql @sqlCommand1

	INSERT INTO #temp_Fichier_chemin (chemin)
	SELECT	distinct T2.Loc.value('@chemin', 'varchar(250)')  AS chemin
	FROM Tmporar
	CROSS APPLY instructions.nodes('batch/image')  T2(Loc) 

	UPDATE #temp_Fichier_chemin
	SET nom_fichier=nom,
		id_fichier_data=id_fichier
	FROM FichiersData(NOLOCK) where  nom =REPLACE(@nom_fichier,'batch','output')

	UPDATE #temp_Fichier_chemin
	SET	id_image=til.id_image
	FROM [dbo].[Taches_Images_Logs] til (NOLOCK)
	INNER JOIN  #temp_Fichier_chemin tfc 
	ON '\images'+RTRIM(LTRIM(REPLACE(SUBSTRING(til.path_destination,CHARINDEX('images',til.path_destination),LEN(til.path_destination)),'images','')))+til.nom_fichier_image_destination=REPLACE(tfc.chemin,'/','\')
	WHERE til.id_tache=4
	
	UPDATE [dbo].[Images]
	SET id_fichier_data_batch=tfc.id_fichier_data	
	FROM #temp_Fichier_chemin tfc 
	INNER JOIN [dbo].[Images] i (NOLOCK) ON i.id_image=tfc.id_image 

	DROP TABLE Tmporar
	DROP TABLE #temp_Fichier_chemin
	


END
GO
