SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <19/08/2015>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spComparaisonBatchFile_InsertionImagesProcessusGeneral]
	-- Test Run : [spComparaisonBatchFile_InsertionImagesProcessusGeneral] '3A7C7386-EACF-4BBE-BDFA-39F77659FA01'
	@id_projet uniqueidentifier	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	DECLARE @date DATETIME = GETDATE(), @id_tache_log_details INT, @IntegerResult INT, 	@id_tache int =32, @id_tache_log int,@id_utilisateur int= 12,
			@machine_traitement varchar(120)='Ithaque BD',@id_source uniqueidentifier, @nb_fichiers_batch int
			,@chemin_fichier varchar(500), @nom_fichier varchar(150),@chemin_dossier_general varchar(255),@chemin varchar(500), @chemin_path VARCHAR(500)
			, @dossier_general_source varchar(255)
	DECLARE @sqlCommand1 NVARCHAR(2000) = N''
	SET @id_source= (SELECT id_source FROM dbo.Sources_Projets sp (NOLOCK) WHERE id_projet=@id_projet)
	SET @dossier_general_source = (SELECT s.nom_format_dossier FROM dbo.Sources s WHERE s.id_source = @id_source)
    
    --insérer log pour la tâche = 32-ParserFichierXMLBatch
	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 32					
					ORDER BY date_creation DESC)
	
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

	SET @chemin_dossier_general=(SELECT chemin_dossier_general FROM Projets(NOLOCK) WHERE id_projet = @id_projet)
	
	IF @id_projet ='65042153-90E9-47E8-9BDA-C0DBE370EDD2'
		BEGIN
			SET @chemin=@chemin_dossier_general+'V4\batches\EC\'
		END
	ELSE
		BEGIN
			SET @chemin=@chemin_dossier_general+'V5\batches\EC\'
		END

	IF OBJECT_ID('temp_Fichier_chemin') IS NOT NULL 
		DROP TABLE temp_Fichier_chemin
	CREATE TABLE temp_Fichier_chemin ([id] int identity(1,1) PRIMARY KEY,[nom_fichier] varchar(255),[id_fichier_data] [uniqueidentifier],[chemin] varchar(500),[id_image] [uniqueidentifier]) 


	BEGIN TRY
		DECLARE NomFichier_Cursor CURSOR FOR
		SELECT REPLACE(nom,'output','batch')
		FROM FichiersData(NOLOCK) 
		WHERE id_projet=@id_projet
		OPEN NomFichier_Cursor
		FETCH NEXT FROM NomFichier_Cursor INTO @nom_fichier
		WHILE @@FETCH_STATUS = 0
		BEGIN
			TRUNCATE TABLE Tmporar
			SET @chemin_path = @chemin + @nom_fichier

			SET @sqlCommand1 = @sqlCommand1 + N'INSERT INTO Tmporar(instructions) ' + CHAR(10) + CHAR(13)
			SET @sqlCommand1 = @sqlCommand1 + N'SELECT CONVERT (XML, BulkColumn, 2 )  FROM OPENROWSET( ' + CHAR(10) + CHAR(13)
			SET @sqlCommand1 = @sqlCommand1 + N'BULK ''' + CAST(@chemin_path AS NVARCHAR(255)) + ''','+ CHAR(10) + CHAR(13)
			SET @sqlCommand1 = @sqlCommand1 + N'SINGLE_BLOB '  + CHAR(10) + CHAR(13)
			SET @sqlCommand1 = @sqlCommand1 + N') AS x '  + CHAR(10) + CHAR(13)
			EXEC sp_executesql @sqlCommand1
			--PRINT @sqlCommand1

			INSERT INTO temp_Fichier_chemin (chemin,nom_fichier)
			SELECT	distinct T2.Loc.value('@chemin', 'varchar(250)')  AS chemin,@nom_fichier
			FROM Tmporar
			CROSS APPLY instructions.nodes('batch/image')  T2(Loc) 
			WHERE T2.Loc.value('@chemin', 'varchar(250)') NOT IN (SELECT chemin FROM dbo.temp_Fichier_chemin tfc)

			--PRINT @nom_fichier
			SET @sqlCommand1 = N''
			FETCH NEXT FROM NomFichier_Cursor INTO @nom_fichier
		END
		CLOSE  NomFichier_Cursor
		DEALLOCATE NomFichier_Cursor

		CREATE NONCLUSTERED INDEX idx_nom_fichier ON [temp_Fichier_chemin](nom_fichier)
		CREATE NONCLUSTERED INDEX idx_chemin ON [temp_Fichier_chemin](chemin)

		UPDATE [temp_Fichier_chemin]
		SET id_fichier_data = fd.id_fichier
		FROM dbo.temp_Fichier_chemin tfc WITH (NOLOCK)
		INNER JOIN FichiersData fd (NOLOCK) ON  fd.nom =REPLACE(tfc.nom_fichier,'batch','output')

		ALTER TABLE temp_Fichier_chemin ADD chemin_images_taches varchar(500)
		UPDATE temp_Fichier_chemin
		SET chemin_images_taches = '\\10.1.0.196\bigvol\Sources\' + @dossier_general_source + '\V4' + replace(chemin, '/', '\')
		
		
		UPDATE [temp_Fichier_chemin]
		SET id_image=til.id_image
		FROM [dbo].[Taches_Images_Logs] til (NOLOCK)
		INNER JOIN  [temp_Fichier_chemin] tfc with (nolock) ON til.path_origine + til.nom_fichier_image_origine = replace(tfc.chemin_images_taches, 'V4', 'V3')
		WHERE til.id_tache=4
		

		UPDATE [dbo].[Images]
		SET id_fichier_data_batch=tfc.id_fichier_data	
		FROM [temp_Fichier_chemin] tfc 
		INNER JOIN [dbo].[Images] i (NOLOCK) ON i.id_image=tfc.id_image 
	
	SET @IntegerResult = 1 
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

				
		SET @IntegerResult = -1
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResult = 1)
		BEGIN

		SET @nb_fichiers_batch=(SELECT COUNT(id_fichier_data_batch) FROM Images WITH(NOLOCK) WHERE id_projet= @id_projet AND id_fichier_data_batch IS NOT NULL)
		
		IF (@nb_fichiers_batch>1)			
			BEGIN
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
				EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
			END
		ELSE
			BEGIN
				EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, 'Erreur: pas des lignes ont été update'
			EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, 'Erreur: pas des lignes ont été update'
			END

		END
	ELSE
		BEGIN
			EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
			EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
		END

END


GO
