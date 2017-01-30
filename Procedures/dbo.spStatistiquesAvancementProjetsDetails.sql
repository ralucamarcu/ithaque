SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 21.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesAvancementProjetsDetails]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesAvancementProjetsDetails] 4
	 @id_tache_v4 INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @nom_sous_projet VARCHAR (50), @nb_total_img_v4 INT, @nb_img_validees INT, @nb_actes_valides INT, @nb_actes_pas_controles INT
		, @nb_individus_actes_valides INT, @nb_caracteres_actes_valides INT
	--CREATE TABLE #tmp_img_valides (id_image UNIQUEIDENTIFIER)
    DECLARE @id_projet UNIQUEIDENTIFIER
	IF OBJECT_ID('Statistiques_Avancement_Projets_Details') IS NOT NULL 
		DROP TABLE Statistiques_Avancement_Projets_Details
	CREATE TABLE Statistiques_Avancement_Projets_Details (id_statistiques_avancement_projets_details INT NOT NULL IDENTITY(1,1) PRIMARY KEY
		, nom_sous_projet VARCHAR (50), nb_total_img_v4 INT, nb_img_validees INT, nb_actes_valides INT, nb_actes_pas_controles INT
		, nb_individus_actes_valides BIGINT, nb_caracteres_actes_valides INT)
	--CREATE INDEX idx_id_image ON #tmp_img_valides (id_image)


	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT p.id_projet,nom_projet_dossier
	FROM projets p WITH (NOLOCK)
	WHERE id_status_version_processus >= 4
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet,@nom_sous_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		CREATE TABLE #tmp_img_valides (id_image UNIQUEIDENTIFIER)

		--SET @nom_sous_projet = (SELECT nom_projet_dossier FROM Projets WHERE id_projet = @id_projet)
		SELECT @nb_total_img_v4 = COUNT(DISTINCT i.id_image) 
		FROM Images i WITH (NOLOCK)
		INNER JOIN Taches_Images_Logs tli WITH (NOLOCK) ON i.id_image = i.id_image
		WHERE id_projet = @id_projet AND id_tache = @id_tache_v4
		
		INSERT INTO #tmp_img_valides (id_image)
		SELECT DISTINCT dxz.id_image
		FROM Traitements t (nolock) 
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK) ON dxz.id_acte = dxa.id
		--DataXmlRC_zones dxz WITH (NOLOCK)
		--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		--INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		WHERE id_projet = @id_projet AND dxee.traite = 1 AND dxee.id_statut IN (1,3) 
			--AND dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet)

		CREATE INDEX idx_id_image ON #tmp_img_valides (id_image)	

		SET @nb_img_validees = (SELECT COUNT(*) FROM #tmp_img_valides)
		
		SET @nb_actes_valides = (SELECT COUNT(distinct dxz.id_acte) FROM #tmp_img_valides t						
						INNER JOIN  DataXmlRC_zones dxz WITH (NOLOCK) ON dxz.id_image = t.id_image)
		SET @nb_individus_actes_valides = (SELECT COUNT(dxi.id) FROM #tmp_img_valides t 
						INNER JOIN  DataXmlRC_zones dxz WITH (NOLOCK) ON dxz.id_image = t.id_image
						INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
						INNER JOIN DataXmlRC_individus dxi WITH (NOLOCK) ON dxi.id_acte = dxa.id)
		
		SET @nb_caracteres_actes_valides = (SELECT SUM(LEN(ISNULL(dxi.nom,0)) + LEN(ISNULL(dxi.prenom,0)) + LEN(ISNULL(DXI.aGE,0)) + LEN(ISNULL(dxi.date_naissance,0)) 
				+ LEN(ISNULL(dxi.annee_naissance,0)) + LEN(ISNULL(dxi.calendrier_date_naissance,0)) + LEN(ISNULL(dxi.lieu_naissance,0)) 
				+ LEN(ISNULL(dxi.insee_naissance,0)) +LEN(ISNULL(dxi.geonameid_naissance,0))) 
			FROM #tmp_img_valides t 
			INNER JOIN DataXmlRC_zones dxz WITH (NOLOCK) ON dxz.id_image = t.id_image
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK)  ON dxz.id_acte = dxa.id
			INNER JOIN DataXmlRC_individus dxi WITH (NOLOCK) ON dxi.id_acte = dxa.id)

		SET @nb_actes_pas_controles = (SELECT COUNT(dxa.id) 
				FROM Traitements t (nolock) 
				INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
				INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
				INNER JOIN  DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
				WHERE id_projet = @id_projet AND dxee.traite = 0 )
					--AND dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet))
		
		INSERT INTO Statistiques_Avancement_Projets_Details (nom_sous_projet, nb_total_img_v4, nb_img_validees, nb_actes_valides, nb_actes_pas_controles
			, nb_individus_actes_valides, nb_caracteres_actes_valides)
			
		SELECT @nom_sous_projet AS nom_sous_projet, @nb_total_img_v4 AS nb_total_img_v4
			, @nb_img_validees AS nb_img_validees, @nb_actes_valides AS nb_actes_valides, @nb_actes_pas_controles AS nb_actes_pas_controles
			, @nb_individus_actes_valides AS nb_individus_actes_valides, @nb_caracteres_actes_valides AS nb_caracteres_actes_valides

		DROP TABLE #tmp_img_valides
		FETCH cursor_1 INTO @id_projet,@nom_sous_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
END

GO
