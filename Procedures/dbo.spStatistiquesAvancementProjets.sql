SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 21.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesAvancementProjets]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesAvancementProjets] 4
	 @id_tache_v4 INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @nom_sous_projet VARCHAR (50), @nb_total_img_v4 INT, @nb_img_livrees_par_prestataire INT
		, @nb_img_conforme INT, @nb_img_controlees INT, @nb_images_pas_controlees INT, @nb_img_validees INT, @nb_actes_valides INT
		, @pourcentage_img_livrees_v4_rapport FLOAT
		, @pourcentage_img_conformite_v4_rapport FLOAT
		, @pourcentage_img_controlees_v4_rapport FLOAT
		, @pourcentage_img_pas_controlees_v4_rapport FLOAT
		, @pourcentage_img_validees_v4_rapport FLOAT
		, @ratio_actes_valides_img_valides FLOAT
--	CREATE TABLE #tmp_ap_images (id_zone INT PRIMARY KEY, id_acte INT , id_image UNIQUEIDENTIFIER, conforme INT, traite INT, id_statut INT)
    DECLARE @id_projet UNIQUEIDENTIFIER
	IF OBJECT_ID('Statistiques_Avancement_Projets_Images') IS NOT NULL 
		DROP TABLE Statistiques_Avancement_Projets_Images
	CREATE TABLE Statistiques_Avancement_Projets_Images (id_statistiques_avancement_projets_image INT NOT NULL IDENTITY(1,1) PRIMARY KEY
		, nom_sous_projet VARCHAR (50), nb_total_img_v4 INT
		, nb_img_livrees_par_prestataire INT, pourcentage_img_livrees_v4_rapport FLOAT
		, nb_img_conforme INT, pourcentage_img_conformite_v4_rapport FLOAT
		, nb_img_controlees INT, pourcentage_img_controlees_v4_rapport FLOAT
		, nb_img_pas_controlees INT, pourcentage_img_pas_controlees_v4_rapport FLOAT
		, nb_img_validees INT, pourcentage_img_validees_v4_rapport FLOAT
		, nb_actes_valides INT, ratio_actes_valides_img_valides  FLOAT)
	
	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT p.id_projet
	FROM projets p WITH (NOLOCK)
	WHERE id_status_version_processus >= 4
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN

		CREATE TABLE #tmp_ap_images (id_zone INT PRIMARY KEY, id_acte INT , id_image UNIQUEIDENTIFIER, conforme INT, traite INT, id_statut INT)
		
		SET @nom_sous_projet = (SELECT nom_projet_dossier FROM Projets WHERE id_projet = @id_projet)
		SELECT @nb_total_img_v4 = COUNT(DISTINCT i.id_image) 
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = i.id_image
		WHERE id_projet = @id_projet AND id_tache = @id_tache_v4
		
		INSERT INTO #tmp_ap_images (id_zone, id_acte, id_image, conforme, traite, id_statut)
		SELECT dxz.id_zone, dxz.id_acte AS id_acte, dxz.id_image, dxf.conforme, dxee.traite, dxee.id_statut
		FROM DataXmlRC_zones dxz WITH (NOLOCK)
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		WHERE dxz.id_image IS NOT NULL AND dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet 
		 and livraison_conforme = 1)
		GROUP BY dxz.id_zone, dxz.id_acte, dxz.id_image, dxf.conforme, dxee.traite, dxee.id_statut 
		
		CREATE INDEX idx_id_image ON #tmp_ap_images (id_image)
		CREATE INDEX idx_traite ON #tmp_ap_images(traite)
		CREATE INDEX idx_id_statut ON #tmp_ap_images(id_statut)

		SET @nb_img_livrees_par_prestataire = (SELECT COUNT(DISTINCT id_image) FROM #tmp_ap_images)
		SET @pourcentage_img_livrees_v4_rapport = (CASE WHEN (ISNULL(@nb_img_livrees_par_prestataire, 0) <> 0
				AND ISNULL(@nb_total_img_v4, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_img_livrees_par_prestataire AS FLOAT)
				/ CAST( @nb_total_img_v4  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END) 
		
		SELECT @nb_img_conforme = COUNT(DISTINCT t.id_image) FROM #tmp_ap_images t WHERE t.conforme = 1	
		SET @pourcentage_img_conformite_v4_rapport = (CASE WHEN (ISNULL(@nb_img_livrees_par_prestataire, 0) <> 0
				AND ISNULL(@nb_img_conforme, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_img_conforme AS FLOAT)
				/ CAST( @nb_img_livrees_par_prestataire  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)		

		SELECT @nb_img_controlees = COUNT(DISTINCT id_image) FROM #tmp_ap_images WHERE traite = 1	
		SET @pourcentage_img_controlees_v4_rapport = (CASE WHEN (ISNULL(@nb_img_livrees_par_prestataire, 0) <> 0
				AND ISNULL(@nb_img_controlees, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_img_controlees AS FLOAT)
				/ CAST(  @nb_img_livrees_par_prestataire  AS FLOAT) AS FLOAT)  * 100 AS FLOAT)  ELSE NULL END)
				
		SELECT @nb_images_pas_controlees = 	@nb_img_conforme - @nb_img_controlees
		SET @pourcentage_img_pas_controlees_v4_rapport = (CASE WHEN (ISNULL(@nb_img_livrees_par_prestataire, 0) <> 0
				AND ISNULL(@nb_images_pas_controlees, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_images_pas_controlees AS FLOAT)
				/ CAST(  @nb_img_livrees_par_prestataire  AS FLOAT) AS FLOAT)  * 100 AS FLOAT)  ELSE NULL END)
		
		SELECT @nb_img_validees = COUNT(DISTINCT dxz.id_image), @nb_actes_valides = COUNT(DISTINCT dxz.id_acte)
		FROM #tmp_ap_images t
		INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK)  ON dxz.id_image = t.id_image
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = dxz.id_acte
		WHERE t.traite = 1 AND t.id_statut IN (1,3) 	

		SET @pourcentage_img_validees_v4_rapport = (CASE WHEN (ISNULL(@nb_img_livrees_par_prestataire, 0) <> 0
				AND ISNULL(@nb_img_validees, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_img_validees AS FLOAT)
				/ CAST(  @nb_img_livrees_par_prestataire  AS FLOAT) AS FLOAT)  * 100 AS FLOAT)  ELSE NULL END)
		SET @ratio_actes_valides_img_valides  = (CASE WHEN (ISNULL(@nb_actes_valides, 0) <> 0
				AND ISNULL(@nb_img_validees, 0) <> 0 )
				THEN CAST(CAST(CAST(@nb_actes_valides AS FLOAT)
				/ CAST(  @nb_img_validees  AS FLOAT) AS FLOAT) AS FLOAT)  ELSE NULL END)
		
		INSERT INTO Statistiques_Avancement_Projets_Images (nom_sous_projet, nb_total_img_v4
		, nb_img_livrees_par_prestataire, pourcentage_img_livrees_v4_rapport, nb_img_conforme, pourcentage_img_conformite_v4_rapport
		, nb_img_controlees, pourcentage_img_controlees_v4_rapport, nb_img_pas_controlees, pourcentage_img_pas_controlees_v4_rapport
		, nb_img_validees, pourcentage_img_validees_v4_rapport
		, nb_actes_valides, ratio_actes_valides_img_valides )
			
		SELECT @nom_sous_projet AS nom_sous_projet, @nb_total_img_v4 AS nb_total_img_v4
			, @nb_img_livrees_par_prestataire AS nb_img_livrees_par_prestataire
			, @pourcentage_img_livrees_v4_rapport AS pourcentage_img_livrees_v4_rapport
			, @nb_img_conforme AS nb_img_conforme, @pourcentage_img_conformite_v4_rapport AS pourcentage_img_conformite_v4_rapport
			, @nb_img_controlees AS nb_img_controlees, @pourcentage_img_controlees_v4_rapport AS pourcentage_img_controlees_v4_rapport
			, @nb_images_pas_controlees AS nb_img_pas_controlees, @pourcentage_img_pas_controlees_v4_rapport AS pourcentage_img_pas_controlees_v4_rapport
			, @nb_img_validees AS nb_img_validees, @pourcentage_img_validees_v4_rapport AS pourcentage_img_validees_v4_rapport
			, @nb_actes_valides AS nb_actes_valides, @ratio_actes_valides_img_valides AS pourcentage_actes_validees_img

		--TRUNCATE TABLE #tmp_ap_images
		DROP TABLE #tmp_ap_images

		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	--DROP TABLE #tmp_ap_images
	
	
END

GO
