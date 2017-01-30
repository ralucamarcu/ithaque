SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 26/01/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSources_UpdateStatusVersionProcessus]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @id_source uniqueidentifier, @id_type_traitement1 int, @id_type_traitement2 int,@id_type_traitement3 int, @dossier_destination1 varchar(255),
			@dossier_destination2 varchar(255),@dossier_destination3 varchar(255)

	CREATE TABLE #DirTreeTraitement1(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)
	CREATE TABLE #DirTreeTraitement2(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)
	CREATE TABLE #DirTreeTraitement3(FOLDER_ID INT IDENTITY(1,1),FILE_PATH VARCHAR(800),FOLDER_NAME VARCHAR(128),DEPTH INT,IS_FILE BIT)

	SELECT s.id_source ,id_projet 
	INTO #temp_sources_projets
	FROM dbo.Sources s WITH (NOLOCK) 
	INNER JOIN sources_projets sp WITH (NOLOCK) ON s.id_source=sp.id_source 
	WHERE s.id_status_version_processus=4
	
	SELECT * INTO #temp_Traitements_Sources FROM [Traitements_Images].dbo.Images_Traitements_Sources its WHERE id_source IN (SELECT id_source FROM #temp_sources_projets tsp) AND its.termine=1
	
	DECLARE source_cursor CURSOR FOR
	SELECT id_source FROM #temp_Traitements_Sources
	OPEN source_cursor -- open the cursor
	FETCH NEXT FROM source_cursor INTO @id_source
	WHILE @@FETCH_STATUS=0

	BEGIN
		
		SELECT * INTO #traitement_sours FROM #temp_Traitements_Sources WHERE id_source= @id_source
		SELECT @id_type_traitement1=id_type_traitement, @dossier_destination1=dossier_destination FROM #temp_Traitements_Sources WHERE id_type_traitement=1
		SELECT @id_type_traitement2=id_type_traitement, @dossier_destination2=dossier_destination FROM #temp_Traitements_Sources WHERE id_type_traitement=2
		SELECT @id_type_traitement3=id_type_traitement, @dossier_destination3=dossier_destination FROM #temp_Traitements_Sources WHERE id_type_traitement=3

		IF (@id_type_traitement1 IS NOT NULL AND @id_type_traitement2 IS NOT NULL AND @dossier_destination1 IS NOT NULL AND @dossier_destination2 IS NOT NULL)
		BEGIN

			INSERT INTO #DirTreeTraitement1(folder_name, DEPTH, is_file)  
			EXEC master..xp_DirTree @dossier_destination1,10,1

			IF EXISTS (SELECT folder_name FROM #DirTreeTraitement1 WHERE is_file=1)
			BEGIN 

				INSERT INTO #DirTreeTraitement2(folder_name, DEPTH, is_file)  
				EXEC master..xp_DirTree @dossier_destination2,10,1

				IF EXISTS (SELECT folder_name FROM #DirTreeTraitement2 WHERE is_file=1)
				BEGIN
					IF (@id_type_traitement3 IS NOT NULL AND @dossier_destination3 IS NOT NULL)	
					BEGIN
						INSERT INTO #DirTreeTraitement3(folder_name, DEPTH, is_file)  
						EXEC master..xp_DirTree @dossier_destination3,10,1
						
						IF EXISTS (SELECT folder_name FROM #DirTreeTraitement3 WHERE is_file=1)
						BEGIN
							UPDATE dbo.Sources
							SET dbo.Sources.id_status_version_processus = 6
							WHERE id_source = @id_source

						END
						ELSE 
						BEGIN 
							IF EXISTS( SELECT til.id_image FROM Taches_Images_Logs til WITH(NOLOCK) INNER JOIN dbo.Images i WITH(NOLOCK) ON til.id_image = i.id_image WHERE i.id_source=@id_source AND til.id_tache=5)
							BEGIN
								UPDATE dbo.Sources
								SET dbo.Sources.id_status_version_processus = 5
								WHERE id_source = @id_source
							END
						END
					
					END
				END
			END
			ELSE
			PRINT 'JP2000 ne se fait pas'
		END
		

		SELECT @dossier_destination1= NULL, @dossier_destination2= NULL, @dossier_destination3=NULL, @dossier_destination1=NULL,@dossier_destination2=NULL,@dossier_destination3=NULL
		DELETE FROM #DirTreeTraitement1
		DELETE FROM #DirTreeTraitement2
		DELETE FROM #DirTreeTraitement3
		 
		FETCH NEXT FROM source_cursor INTO @id_source
	END 
	CLOSE source_cursor
	DEALLOCATE source_cursor



END
GO
