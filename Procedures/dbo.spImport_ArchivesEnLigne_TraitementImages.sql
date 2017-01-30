SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--SELECT @@SERVERNAME, SERVERPROPERTY('MachineName')
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 17.11.2014
-- Description:	
-- =============================================
-- Test Run : spImport_ArchivesEnLigne_TraitementImages_nouveau 'test', 'test', 'test', 'test','test','test', 1, '01-01-2001', '85FB4438-6E26-4419-94BF-3CABC3C241D3'

CREATE PROCEDURE [dbo].[spImport_ArchivesEnLigne_TraitementImages] 
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
    DECLARE @stmt NVARCHAR(MAX), @id_document UNIQUEIDENTIFIER, @current_date DATETIME, @IntegerResult INT, @id_tache_log INT
		, @id_tache_log_details INT, @id_source UNIQUEIDENTIFIER, @id_utilisateur INT=12, @machine_traitement VARCHAR(100)='Ithaque App'

    SET @id_source = (SELECT id_source FROM Ithaque.dbo.sources_projets WHERE id_projet = @id_projet) 

    EXEC Ithaque.[dbo].[spInsertionTacheLog] 38, @id_utilisateur, @id_source, NULL, @machine_traitement
    SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_projet = @id_projet AND id_tache = 38				
					ORDER BY date_creation DESC)
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)

	IF OBJECT_ID('tmp_images_actes') IS NOT NULL
	BEGIN 
		DROP TABLE tmp_images_actes
		CREATE TABLE tmp_images_actes (id int primary key identity, id_acte INT, id_image UNIQUEIDENTIFIER) 
	END
    
    BEGIN TRY

		INSERT INTO tmp_images_actes
		SELECT id_acte, id_image 
		FROM ( SELECT ROW_NUMBER() OVER (PARTITION BY dxa.id_acte_xml ORDER BY dxa.id ASC) AS line, dxa.id AS id_acte, dxz.id_image 
			   FROM	DataXmlRC_actes dxa WITH (NOLOCK)
			   INNER JOIN  DataXmlRC_zones dxz WITH (NOLOCK) ON dxz.id_acte = dxa.id
			   INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
			   INNER JOIN DataXmlEchantillonEntete dxee (NOLOCK) ON dxf.id_lot = dxee.id_lot
			   INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
			   WHERE t.id_projet = @id_projet
			   GROUP BY dxa.id, dxz.id_image ,dxa.id_acte_xml) AS dddt
		WHERE line=1

		CREATE INDEX idx_tmp_images_actes_id_acte ON tmp_images_actes(id_acte)
		CREATE INDEX idx_tmp_images_actes_id_image ON tmp_images_actes(id_image)

--	BEGIN TRANSACTION ArchivesEnLigne_TraitementImages;    
		
		SET @stmt = 'INSERT INTO Archives_Preprod.dbo.saisie_donnees_documents (titre, [description], miniature_document,sous_titre
		, image_principale, image_secondaire, publie, date_publication)
		VALUES (@titre_document, @description, @miniature_document, @sous_titre, @image_principale, @image_secondaire, @publie, @date_publication)'
		
		EXEC [PRESQL04].master..sp_executesql
			@stmt = @stmt,
			@params = N'@titre_document varchar(150),@description varchar(max),@miniature_document varchar(255),@sous_titre varchar(1024)
		,@image_principale varchar(255),@image_secondaire varchar(255),@publie bit,@date_publication datetime',
			 @titre_document = @titre_document, @description = @description, @miniature_document = @miniature_document
			, @sous_titre = @sous_titre, @image_principale = @image_principale, @image_secondaire = @image_secondaire
			, @publie = @publie, @date_publication = @date_publication
		
		SET @id_document = (SELECT TOP 1 id_document FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_documents
				WHERE titre = @titre_document AND ISNULL([description],0) = ISNULL(@description,0) 
					AND ISNULL(miniature_document,0) = ISNULL(@miniature_document,0)
					AND ISNULL(sous_titre ,0) = ISNULL(@sous_titre,0))
		SET @stmt = N''

		PRINT @id_document
		
		IF @id_document IS NOT NULL
		BEGIN

			EXEC [dbo].[spImportationSaisie_BulkInsertPagesImages] @id_projet=@id_projet,@id_document=@id_document,@date_publication=@date_publication
		
			
		END
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		EXEC spImport_RollbackArchivesEnLigne_TraitementImages @date_publication=@date_publication,@id_projet=@id_projet ,@id_document=@id_document
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
