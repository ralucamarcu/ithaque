SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesImagesParProjet]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesImagesParProjet] '5BC4606A-A0F3-46A9-9542-91D457F271E7', 4
	@id_project UNIQUEIDENTIFIER
	,@id_tache_v4 INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nom_sous_projet VARCHAR (50), @nb_total_img_v4 INT, @nb_total_img_envoye_par_le_prestataire INT
		, @nb_img_validite_conformite INT, @nb_img_validitate_CQ INT, @nb_img_rejet INT
		, @pourcentage_total_img_envoye_img_par_projet FLOAT
		, @pourcentage_total_img_envoye_img_validite_conformite FLOAT
		, @pourcentage_total_img_envoye_img_validitate_CQ FLOAT
		, @pourcentage_total_img_envoye_img_rejet FLOAT

	CREATE TABLE #temp_zones_actes_fichiers (id int identity PRIMARY KEY, id_image uniqueidentifier, id_lot uniqueidentifier, id_traitement int, conforme bit)
	INSERT INTO #temp_zones_actes_fichiers (id_image,id_lot,id_traitement,conforme)
	SELECT dxz.id_image,dxf.id_lot,dxf.id_traitement,dxf.conforme
	FROM DataXmlRC_zones dxz WITH (NOLOCK)
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	WHERE dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)

	CREATE INDEX idx_zones_actes_fichiers ON #temp_zones_actes_fichiers (id_lot) INCLUDE (id_image)

	SET @nom_sous_projet = (SELECT nom_projet_dossier FROM Projets WHERE id_projet = @id_project)
	SELECT @nb_total_img_v4 = COUNT(DISTINCT i.id_image) 
	FROM Images i WITH (NOLOCK)
	INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = i.id_image
	WHERE id_projet = @id_project AND id_tache = @id_tache_v4
	
	SELECT @nb_total_img_envoye_par_le_prestataire = COUNT(DISTINCT id_image) 
	FROM #temp_zones_actes_fichiers

	SELECT @nb_img_validite_conformite = COUNT(DISTINCT id_image) 
	FROM #temp_zones_actes_fichiers dxf
	WHERE dxf.conforme = 1	

	SELECT @nb_img_validitate_CQ = COUNT(DISTINCT id_image) 
	FROM #temp_zones_actes_fichiers dxf
	INNER JOIN dbo.DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
	INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxlf.id_lot = dxee.id_lot
	WHERE dxee.traite = 1 AND dxee.id_statut IN (1,3)

	SELECT @nb_img_rejet =  COUNT(DISTINCT dxf.id_image) 
	FROM #temp_zones_actes_fichiers dxf
	INNER JOIN dbo.DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
	INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxlf.id_lot = dxee.id_lot
	WHERE dxee.traite = 1 AND dxee.id_statut =2

	--SELECT @nb_total_img_envoye_par_le_prestataire = COUNT(DISTINCT dxz.id_image) 
	--FROM DataXmlRC_zones dxz WITH (NOLOCK)
	--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	--WHERE dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)
	
	--SELECT @nb_img_validite_conformite = COUNT(DISTINCT dxz.id_image) 
	--FROM DataXmlRC_zones dxz WITH (NOLOCK)
	--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	--WHERE dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)
	--	AND dxf.conforme = 1	

	--SELECT @nb_img_validitate_CQ = COUNT(DISTINCT dxz.id_image) 
	--FROM DataXmlRC_zones dxz WITH (NOLOCK)
	--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	--INNER JOIN dbo.DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
	--INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxlf.id_lot = dxee.id_lot
	--WHERE dxee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)	
	--	AND dxee.traite = 1 AND dxee.id_statut IN (1,3) 	
	
	--SELECT @nb_img_rejet =  COUNT(DISTINCT dxz.id_image) 
	--FROM DataXmlRC_zones dxz WITH (NOLOCK)
	--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id 
	--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	--INNER JOIN dbo.DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
	--INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxlf.id_lot = dxee.id_lot
	--WHERE dxee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)	
	--	AND dxee.traite = 1 AND dxee.id_statut IN (2) 	
	
	SET @pourcentage_total_img_envoye_img_par_projet = (CASE WHEN (ISNULL(@nb_total_img_envoye_par_le_prestataire, 0) <> 0
			AND ISNULL(@nb_total_img_v4, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_total_img_envoye_par_le_prestataire AS FLOAT)
			/ CAST( @nb_total_img_v4  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END) 
	SET @pourcentage_total_img_envoye_img_validite_conformite = (CASE WHEN (ISNULL(@nb_total_img_envoye_par_le_prestataire, 0) <> 0
			AND ISNULL(@nb_img_validite_conformite, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_img_validite_conformite AS FLOAT)
			/ CAST( @nb_total_img_envoye_par_le_prestataire  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	SET @pourcentage_total_img_envoye_img_validitate_CQ = (CASE WHEN (ISNULL(@nb_total_img_envoye_par_le_prestataire, 0) <> 0
			AND ISNULL(@nb_img_validitate_CQ, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_img_validitate_CQ AS FLOAT)
			/ CAST(  @nb_total_img_envoye_par_le_prestataire  AS FLOAT) AS FLOAT)  * 100 AS FLOAT)  ELSE NULL END)
	SET @pourcentage_total_img_envoye_img_rejet = (CASE WHEN (ISNULL(@nb_total_img_envoye_par_le_prestataire, 0) <> 0
			AND ISNULL(@nb_img_rejet, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_img_rejet AS FLOAT)
			/ CAST( @nb_total_img_envoye_par_le_prestataire  AS FLOAT) AS FLOAT)* 100 AS FLOAT) ELSE NULL END) 
	
	SELECT @nom_sous_projet AS nom_sous_projet, @nb_total_img_v4 AS nb_total_img_v4
		, @nb_total_img_envoye_par_le_prestataire AS nb_total_img_envoye_par_le_prestataire
		, @nb_img_validite_conformite AS nb_img_validite_conformite, @nb_img_validitate_CQ AS nb_img_validitate_CQ
		, @nb_img_rejet AS nb_img_rejet, @pourcentage_total_img_envoye_img_par_projet AS pourcentage_total_img_envoye_img_par_projet
		, @pourcentage_total_img_envoye_img_validite_conformite AS pourcentage_total_img_envoye_img_validite_conformite
		, @pourcentage_total_img_envoye_img_validitate_CQ AS pourcentage_total_img_envoye_img_validitate_CQ
		, @pourcentage_total_img_envoye_img_rejet AS pourcentage_total_img_envoye_img_rejet 
	
	DROP TABLE #temp_zones_actes_fichiers
END

GO
