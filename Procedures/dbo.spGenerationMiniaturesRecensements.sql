SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tamas Andrea
-- Create date: 19.01.2017
-- Description:	Miniatures for recensements.
-- =============================================
--testrun: spGenerationMiniaturesRecensements '2491E975-D438-4114-B87C-28A5DDC4A243'

CREATE PROCEDURE spGenerationMiniaturesRecensements
	@id_projet uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @current_date datetime = getdate(),
			@id_document [uniqueidentifier] = NULL, 
			@titre_document VARCHAR(255), 
			@id_association int,
			@id_image UNIQUEIDENTIFIER, 
			@id_tache_log INT, 
			@id_tache_log_details INT, 
			@IntegerResult INT, 
			@id_source UNIQUEIDENTIFIER, 
			@premier_id_fichier [uniqueidentifier],
			@chemin_dossier_v4 VARCHAR(255),
			@chemin_dossier_v5 VARCHAR(255),
			@chemin_xml VARCHAR(255),
			@chemin_dossier_v6 VARCHAR(255),
			@chemin_dossier_general VARCHAR(255),
			@description VARCHAR(1000),
			@miniature_document varchar(255),
			@sous_titre varchar(255),
			@image_principale varchar(255) = NULL,
			@image_secondaire varchar(255) = NULL,
			@publie bit=0 ,
			@date_publication datetime= GETDATE()
-------------------------------------------------
-- Project info
-------------------------------------------------

	SELECT @titre_document = s.infos, @chemin_dossier_v4 = s.chemin_dossier_general + 'V4\images', @chemin_dossier_v5 = s.chemin_dossier_general + 'V5\images',
		   @chemin_xml = s.chemin_dossier_general + 'V5\output\publication', @chemin_dossier_v6 = NULL, @chemin_dossier_general = s.chemin_dossier_general,@id_association = id_association
	FROM  Projets s
	WHERE s.id_projet = @id_projet

-------------------------------------------------
-- create document
-------------------------------------------------
BEGIN TRY
BEGIN TRANSACTION ArchivesEnLigne_TraitImG_nouveau;    
		
IF NOT EXISTS (SELECT id_document FROM archives.dbo.saisie_donnees_documents (NOLOCK) where titre=@titre_document)
	BEGIN

	SET @id_document=newid()

	INSERT INTO archives.dbo.saisie_donnees_documents (id_document, titre, [description], miniature_document,sous_titre, image_principale, image_secondaire, publie, date_publication)
     	 VALUES (@id_document, @titre_document, @description, @miniature_document, @sous_titre, @image_principale, @image_secondaire, @publie, @date_publication)

	
	
-------------------------------------------------
-- create pages
-------------------------------------------------

	IF NOT EXISTS (SELECT id_document FROM archives.dbo.[saisie_donnees_pages] (NOLOCK) where id_document=@id_document)
	BEGIN
	INSERT INTO [archives].[dbo].[saisie_donnees_pages]([image_viewer],[image_miniature],[image_origine],[id_document],[ordre],[fenetre_navigation],[id_lot],[visible],[date_creation],
				[affichage_image],[ordre_fichier_xml],[id_fichier_xml],[id_statut],[cote],[id_fichier_xml_test],[date_modification])
	SELECT  REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '') + tli.nom_fichier_image_destination AS [image_viewer],
			NULL AS [image_miniature] ,REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '') + tli.nom_fichier_image_destination AS [image_origine],
			@id_document AS [id_document],NULL AS [ordre],NULL AS [fenetre_navigation],1 AS [id_lot],1 AS [visible],@current_date AS [date_creation],1 AS [affichage_image],NULL AS [ordre_fichier_xml],
			NULL AS [id_fichier_xml],NULL AS [id_statut],NULL AS [cote],NULL AS [id_fichier_xml_test],NULL AS [date_modification]
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
	WHERE id_projet = @id_projet AND tli.id_tache = 4
	END
-------------------------------------------------
-- create images
-------------------------------------------------

	IF NOT EXISTS (SELECT id_document FROM archives.dbo.[Saisie_donnees_images] (NOLOCK) where id_document=@id_document)
	BEGIN		
	INSERT INTO  [archives].[dbo].[Saisie_donnees_images]([path],[zones_a_traiter],[zones_traitees],[jp2_a_traiter],[jp2_traitee],[id_page],[id_document],[status],[date_status],[date_creation])
	SELECT  REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')+ tli.nom_fichier_image_destination AS [path], 
			1 AS [zones_a_traitees],NULL AS [zones_traitees],1 AS [jp2_a_traiter],NULL AS [jp2_traitee],NULL AS [id_page],@id_document AS [id_document],0 AS [status],NULL AS [date_status],@current_date AS [date_creation]
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
	WHERE id_projet = @id_projet AND tli.id_tache = 4
	GROUP BY REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')+ tli.nom_fichier_image_destination
	END
END
-------------------------------------------------
-- generate miniatures file
-------------------------------------------------
	COMMIT TRANSACTION ArchivesEnLigne_TraitImG_nouveau;

	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

	ROLLBACK TRANSACTION ArchivesEnLigne_TraitImG_nouveau;
				
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;

SELECT @id_document as '@id_document',@id_projet as '@id_projet'

	--EXEC [192.168.0.76].[archives].[dbo].[create_miniatures_table_fichier_recensements]  @id_document=@id_document, @id_projet=@id_projet
	EXEC [archives].[dbo].[create_miniatures_table_fichier_recensements]  @id_document=@id_document, @id_projet=@id_projet
	
END
GO
