SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Import_ImagesEnLigne_TraitementImages_NouveauImg]
	-- Add the parameters for the stored procedure here
	-- Test Run :AEL_Import_ImagesEnLigne_TraitementImages_NouveauImg '3871A253-F67C-43F0-B693-EF4D49F81440', '5D0C3D3F-1715-4F8B-B9CF-5DCC1A33FB43' , '412'
	 @id_projet UNIQUEIDENTIFIER
	,@id_document UNIQUEIDENTIFIER
	,@id_livraisons VARCHAR(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmp_acte (id_acte INT, id_image UNIQUEIDENTIFIER, id_fichier UNIQUEIDENTIFIER)
	CREATE TABLE #tmp_deja_publie (id_image INT, id_fichier UNIQUEIDENTIFIER)
	CREATE TABLE #tmp_a_publie(id_image INT)
	CREATE TABLE #tmp_livraisons (id_livraison INT)
	declare @id_tache_log INT, @id_tache_log_details INT
	
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_projet = @id_projet AND id_tache = 18 and date_fin is null
					ORDER BY date_creation DESC)
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	
	IF @id_livraisons IS NULL
	BEGIN
		INSERT INTO #tmp_acte
		SELECT dxz.id_acte, dxz.id_image, dxf.id_fichier
		FROM DataXmlRC_zones dxz WITH (NOLOCK)
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet AND dxee.id_statut IN (1,3)
		GROUP BY dxz.id_acte, dxz.id_image , dxf.id_fichier
	END
	
	IF @id_livraisons IS NOT NULL
	BEGIN
		INSERT INTO #tmp_livraisons
		EXEC dbo.spCalculSplit @id_livraisons
		
		INSERT INTO #tmp_acte
		SELECT dxz.id_acte, dxz.id_image, dxf.id_fichier
		FROM DataXmlRC_zones dxz WITH (NOLOCK)
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE t.id_traitement IN (SELECT id_livraison FROM #tmp_livraisons) 
			AND dxee.id_statut IN (1,3)
		GROUP BY dxz.id_acte, dxz.id_image , dxf.id_fichier
	END
	
	INSERT INTO #tmp_deja_publie
	SELECT sdi.id_image, dxf.id_fichier
	FROM DataXml_fichiers dxf WITH (NOLOCK) 
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
	INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK) ON dxa.id = dxz.id_acte
	INNER JOIN [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images sdi WITH (NOLOCK)
			ON sdi.path COLLATE database_default = REPLACE(REPLACE(dxz.image, '/images', ''), '/', '\')
	WHERE sdi.id_document = @id_document AND sdi.jp2_a_traiter = 1
	GROUP BY sdi.id_image, dxf.id_fichier
	
	insert into #tmp_a_publie
	SELECT sdi.id_image
	FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images sdi WITH (NOLOCK)
	INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK) ON sdi.path COLLATE database_default = REPLACE(REPLACE(dxz.image, '/images', ''), '/', '\')
	INNER JOIN #tmp_acte t WITH (NOLOCK) ON dxz.id_acte = t.id_acte
	WHERE sdi.id_document = @id_document AND sdi.jp2_a_traiter = 0
		AND sdi.id_image NOT IN (SELECT id_image FROM #tmp_deja_publie)
	GROUP BY sdi.id_image
	
	UPDATE [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images
	SET jp2_a_traiter = 1
		,thumb_a_traiter = 1
	FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images sdi WITH (NOLOCK)
	INNER JOIN #tmp_a_publie t WITH (NOLOCK) ON sdi.id_image = t.id_image
	WHERE sdi.id_document = @id_document AND sdi.jp2_a_traiter = 0 
	
	
	DROP TABLE #tmp_acte
	DROP TABLE #tmp_deja_publie
	DROP TABLE #tmp_livraisons
	drop table #tmp_a_publie
	
	EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
	EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		
END
GO
