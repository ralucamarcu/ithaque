SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--SELECT @@SERVERNAME, SERVERPROPERTY('MachineName')
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 17.11.2014
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spImport_ArchivesEnLigne_TraitementImages_nouveau] 
	-- Add the parameters for the stored procedure here
	-- Test Run : spImport_ArchivesEnLigne_TraitementImages 'test', 'test', 'test', 'test','test','test', 1, '01-01-2001', '85FB4438-6E26-4419-94BF-3CABC3C241D3'
	 @titre_document VARCHAR(150)
	,@description VARCHAR(MAX)
	,@miniature_document VARCHAR(255)
	,@sous_titre VARCHAR(1024)
	,@image_principale VARCHAR(255)
	,@image_secondaire VARCHAR(255)
	,@publie BIT
	,@date_publication DATETIME
	,@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
    DECLARE @stmt NVARCHAR(MAX), @id_document UNIQUEIDENTIFIER, @current_date DATETIME = GETDATE()
		, @IntegerResult INT, @id_tache_log INT, @id_tache_log_details INT, @id_source UNIQUEIDENTIFIER
		, @id_utilisateur INT=12, @machine_traitement VARCHAR(100)='Ithaque App'

    SET @id_source = (SELECT id_source FROM Ithaque.dbo.sources_projets WHERE id_projet = @id_projet) 

    EXEC Ithaque.[dbo].[spInsertionTacheLog] 38, @id_utilisateur, @id_source, @id_projet, @machine_traitement
    SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_projet = @id_projet AND id_tache = 38				
					ORDER BY date_creation DESC)
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

BEGIN TRY
BEGIN TRANSACTION ArchivesEnLigne_TraitImG_nouveau;    
		
		INSERT INTO archives.dbo.saisie_donnees_documents (id_document, titre, [description], miniature_document,sous_titre
		, image_principale, image_secondaire, publie, date_publication)
		VALUES (newid(), @titre_document, @description, @miniature_document, @sous_titre, @image_principale, @image_secondaire, @publie, @date_publication)
		
		
		SET @id_document = (SELECT TOP 1 id_document FROM archives.dbo.saisie_donnees_documents
				WHERE titre = @titre_document AND ISNULL([description],0) = ISNULL(@description,0) 
					AND ISNULL(miniature_document,0) = ISNULL(@miniature_document,0)
					AND ISNULL(sous_titre ,0) = ISNULL(@sous_titre,0))		
		PRINT @id_document
		
		IF @id_document IS NOT NULL
		BEGIN

			INSERT INTO [archives].[dbo].[saisie_donnees_pages]([image_viewer],[image_miniature],[image_origine],[id_document],[ordre],[fenetre_navigation],[id_lot],[visible],[date_creation]
				   ,[affichage_image],[ordre_fichier_xml],[id_fichier_xml],[id_statut],[cote],[id_fichier_xml_test],[date_modification])
			SELECT  REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
						+ tli.nom_fichier_image_destination AS [image_viewer]
				   ,NULL AS [image_miniature]
				   ,REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
						+ tli.nom_fichier_image_destination AS [image_origine]
				   ,@id_document AS [id_document],NULL AS [ordre],NULL AS [fenetre_navigation],1 AS [id_lot]
				   ,1 AS [visible]
				   ,@current_date AS [date_creation],1 AS [affichage_image]
				   ,NULL AS [ordre_fichier_xml],NULL AS [id_fichier_xml],NULL AS [id_statut],NULL AS [cote]
				   ,NULL AS [id_fichier_xml_test],NULL AS [date_modification]
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
			WHERE id_projet = @id_projet AND tli.id_tache = 4

			
			INSERT INTO  [archives].[dbo].[Saisie_donnees_images]([path],[zones_a_traiter],[zones_traitees]
				,[jp2_a_traiter],[jp2_traitee],[id_page],[id_document],[status],[date_status],[date_creation])
			SELECT  REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
						+ tli.nom_fichier_image_destination AS [path], 1 AS [zones_a_traitees]
				   ,NULL AS [zones_traitees],1 AS [jp2_a_traiter],NULL AS [jp2_traitee],NULL AS [id_page]
				   ,@id_document AS [id_document],0 AS [status],NULL AS [date_status]
				   --,dxa.id_fichier AS [id_fichier_xml]
				   ,@current_date AS [date_creation]
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
			--LEFT JOIN tmp_images_actes t ON i.id_image = t.id_image
			--LEFT JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON t.id_acte = dxa.id
			WHERE id_projet = @id_projet AND tli.id_tache = 4
			GROUP BY REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
						+ tli.nom_fichier_image_destination
			
			
		END
	
	SET @IntegerResult = 1 
	COMMIT TRANSACTION ArchivesEnLigne_TraitImG_nouveau;

	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

	ROLLBACK TRANSACTION ArchivesEnLigne_TraitImG_nouveau;
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
		UPDATE AEL_Parametres_nouveau
		SET id_document = @id_document
		WHERE id_projet = @id_projet
			
		UPDATE Projets
		SET id_status_version_processus = 5
		WHERE id_projet = @id_projet
		
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
	END
	ELSE
	BEGIN
	
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
	
	

END
GO
