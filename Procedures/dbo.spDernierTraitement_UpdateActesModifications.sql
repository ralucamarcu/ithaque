SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 21-01-2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spDernierTraitement_UpdateActesModifications]
	@id_projet uniqueidentifier

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @id_acte_ithaque bigint, @id_acte_prod bigint,
			@date_acte_ithaque nvarchar(50), @date_acte_prod nvarchar(50),
			@annee_acte_ithaque nvarchar(50), @annee_acte_prod nvarchar(50),
			@calendrier_date_acte_ithaque varchar(20), @calendrier_date_acte_prod varchar(20),
			@lieu_acte_ithaque nvarchar(10), @lieu_acte_prod nvarchar(10),
			@type_acte_ithaque nvarchar(50), @type_acte_prod nvarchar(50),
			@id_acte_xml_ithaque nvarchar(50), @id_acte_xml_prod nvarchar(50)

	DECLARE @nom_ithaque varchar(255), @nom_prod varchar(255),
			@prenom_ithaque varchar(255), @prenom_prod varchar(255),
			@id_individu_xml_ithaque varchar(50), @id_individu_xml_prod varchar(50),
			@nbr_individus_ithaque int, @nbr_individus_prod int

	DECLARE @nbr_zones_ithaque int, @nbr_zones_prod int,
			@nbr_marges_ithaque INT, @nbr_marges_prod INT

	DECLARE	 @current_date datetime = GETDATE(), @id_document [uniqueidentifier], @titre_document VARCHAR(255)
			,@id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT, @id_source UNIQUEIDENTIFIER
			,@chemin_dossier_v4 VARCHAR(255),@chemin_dossier_v5 VARCHAR(255),@chemin_xml VARCHAR(255)
			,@chemin_dossier_v6 VARCHAR(255),@chemin_dossier_general VARCHAR(255)


	IF OBJECT_ID ('CorrectionProcess_ModifiedActs') IS NOT NULL
	BEGIN 
		DROP TABLE CorrectionProcess_ModifiedActs
	END

	IF OBJECT_ID ('CorrectionProcess_ActesToDelete') IS NOT NULL
	BEGIN 
		DROP TABLE CorrectionProcess_ActesToDelete
	END

	CREATE TABLE CorrectionProcess_ActesToDelete (id_acte_xml nvarchar(50), id_acte_ithaque bigint, id_acte_archives uniqueidentifier)
	CREATE TABLE CorrectionProcess_ModifiedActs (id_acte_xml nvarchar(50), id_acte_ithaque bigint, flag int)

	SET @id_source = (SELECT id_source FROM Ithaque.dbo.sources_projets WHERE id_projet = @id_projet) 

	SELECT @titre_document = s.nom_format_dossier, @chemin_dossier_v4 = s.chemin_dossier_general + 'V4\images', @chemin_dossier_v5 = s.chemin_dossier_general + 'V5\images'
		, @chemin_xml = s.chemin_dossier_general + 'V5\output\publication', @chemin_dossier_v6 = s.chemin_dossier_general + 'V5\images'
		, @chemin_dossier_general = s.chemin_dossier_general
	from Ithaque.dbo.Sources s
	WHERE s.id_source = @id_source
	
	EXEC Ithaque.dbo.[AEL_Insertion_Parametres_nouveau] @titre_document = @titre_document,@description = NULL, @miniature_document = NULL, @sous_titre = NULL,@image_principale = NULL
		,@image_secondaire = NULL, @publie = 0, @date_publication = @current_date,@id_projet  = @id_projet
		,@chemin_dossier_v4 = @chemin_dossier_v4,@chemin_dossier_v5 = @chemin_dossier_v5,@chemin_xml  = @chemin_xml, @id_association  = NULL
		,@date_creation_projet = null,@chemin_dossier_v6  = @chemin_dossier_v6,@chemin_dossier_general  = @chemin_dossier_general,@id_livraisons = NULL

	SELECT @id_document =id_document FROM Ithaque.dbo.AEL_Parametres_nouveau (NOLOCK) WHERE principal = 1

	SELECT	[id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
	INTO #temp_actes
	FROM (SELECT ROW_NUMBER() OVER (PARTITION BY dxa.id_acte_xml ORDER BY dxa.id DESC) AS line,dxa.[id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte],[geonameid_acte],[insee_acte],[fichier_xml_acte]
		  ,dxa.[id_traitement],dxa.[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction],[date_acte_Correction],[annee_acte_Correction]
		  ,[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction],dxa.[id_fichier]
		  ,[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
		  FROM DataXmlRC_actes dxa WITH (NOLOCK)
		  INNER JOIN DataXml_fichiers dxf WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
	      INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) on dxf.id_lot=lf.id_lot
          INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
	      WHERE t.id_projet = @id_projet
			AND t.livraison_annulee=0 
			AND ISNULL(dxf.rejete, 0) = 0 
			AND ISNULL(dxf.ignore_export_publication, 0) = 0 
			AND isnull(lf.export_pour_mep, 0) = 0) AS ddt
	WHERE line=1

	CREATE INDEX idx_id ON #temp_actes(id)

	-- get all acts from production for a certain document id
	SELECT id_acte_xml, id_acte_ithaque, id_acte AS id_acte_archives
	INTO #temp_actes_production_archives
	FROM [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_actes] sda
	INNER JOIN [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_pages] sdp ON sda.id_page=sdp.id_page
	WHERE sdp.id_document= @id_document 

	-------- actele care nu mai exista pe ithaque
	/*SELECT id_acte_xml, id_acte_ithaque INTO #temp_delete_from_production_archives FROM #temp_actes_production_archives WHERE id_acte_xml NOT IN (SELECT id_acte_xml FROM #temp_actes ta)*/

	INSERT INTO CorrectionProcess_ActesToDelete (id_acte_xml,id_acte_ithaque,id_acte_archives)
	SELECT id_acte_xml, id_acte_ithaque, id_acte_archives
	FROM #temp_actes_production_archives tapa
	LEFT JOIN #temp_actes ta ON tapa.id_acte_xml=ta.id_acte_xml 
	WHERE ta.id_acte_xml IS NULL 

	-------- actele pe care le avem in comun
	/*SELECT id_acte_xml, ta.id INTO #temp_common_acts FROM #temp_actes ta WHERE id_acte_xml IN (SELECT id_acte_xml FROM #temp_actes_production_archives tpaa)*/

	SELECT id_acte_xml, ta.id 
	INTO #temp_common_acts 
	FROM #temp_actes ta 
	INNER JOIN #temp_actes_production_archives tapa ON ta.id_acte_xml=tapa.id_acte_xml
	
	--- acte care nu exista in productie.
	/*SELECT id_acte_xml, ta.id INTO #temp_insert_this_actes FROM #temp_actes ta WHERE id_acte_xml NOT IN (SELECT id_acte_xml FROM #temp_actes_production_archives tpaa)*/

	INSERT INTO CorrectionProcess_ModifiedActs ( id_acte_xml, id_acte_ithaque, flag) 
	SELECT id_acte_xml, ta.id, 1 AS flag 
	FROM #temp_actes ta 
	LEFT JOIN #temp_actes_production_archives tapa ON ta.id_acte_xml=tapa.id_acte_xml
	WHERE tapa.id_acte_xml IS NULL
	
	CREATE INDEX idx_id_acte_xml ON CorrectionProcess_ModifiedActs (id_acte_xml)
	CREATE INDEX idx_id_acte_ithaque ON CorrectionProcess_ModifiedActs (id_acte_ithaque)
	CREATE INDEX idx_flag ON CorrectionProcess_ModifiedActs (flag)

	DECLARE check_actes_details CURSOR FOR
	SELECT id_acte_xml, id FROM #temp_common_acts ta
	OPEN check_actes_details -- open the cursor
	FETCH NEXT FROM check_actes_details INTO @id_acte_xml_ithaque, @id_acte_ithaque
	WHILE @@FETCH_STATUS = 0
 
	BEGIN
		SELECT @id_acte_prod=id_acte_ithaque FROM #temp_actes_production_archives WHERE id_acte_xml=@id_acte_xml_ithaque

		SELECT @type_acte_prod=type_acte, @lieu_acte_prod=lieu_acte, @calendrier_date_acte_prod=calendrier_date_acte, @annee_acte_prod=annee_acte, @date_acte_prod=date_acte
		FROM DataXmlRC_actes(nolock) ta WHERE id=@id_acte_prod 

		SELECT @type_acte_ithaque=type_acte, @lieu_acte_ithaque=lieu_acte, @calendrier_date_acte_ithaque=calendrier_date_acte, @annee_acte_ithaque=annee_acte, @date_acte_ithaque=date_acte
		FROM #temp_actes ta WHERE id=@id_acte_ithaque

		IF (@type_acte_prod=@type_acte_ithaque AND @lieu_acte_prod=@lieu_acte_ithaque AND @date_acte_prod=@date_acte_ithaque AND
			@calendrier_date_acte_prod=@calendrier_date_acte_ithaque AND @annee_acte_prod=@annee_acte_ithaque)
		BEGIN 
			SELECT nom, prenom INTO #temp_names_prod FROM DataXmlRC_individus(nolock) WHERE id_acte=@id_acte_prod
			SELECT nom, prenom INTO #temp_names_ithaque FROM DataXmlRC_individus(nolock) WHERE id_acte=@id_acte_ithaque
			
			DECLARE name_check_cursor CURSOR FOR
			SELECT nom, prenom FROM #temp_names_ithaque
			OPEN name_check_cursor -- open the cursor
			FETCH NEXT FROM name_check_cursor INTO @nom_ithaque, @prenom_ithaque
			WHILE @@FETCH_STATUS = 0
 
			BEGIN
				IF NOT EXISTS (SELECT nom,prenom FROM #temp_names_prod WHERE RTRIM(LTRIM(nom))=RTRIM(LTRIM(@nom_ithaque)) AND RTRIM(LTRIM(prenom))=RTRIM(LTRIM(@prenom_ithaque)))
					BEGIN 
						INSERT INTO CorrectionProcess_ModifiedActs( id_acte_xml, id_acte_ithaque, flag)
						SELECT @id_acte_xml_ithaque, @id_acte_prod,2 AS flag
					END
				ELSE 
					BEGIN
						SELECT @nbr_zones_prod = COUNT(DISTINCT id_zone) FROM DataXmlRC_zones(nolock) WHERE id_acte=@id_acte_prod
						SELECT @nbr_zones_ithaque = COUNT(DISTINCT id_zone) FROM DataXmlRC_zones(nolock) WHERE id_acte=@id_acte_prod

						SELECT @nbr_marges_prod = COUNT(DISTINCT id_marge) FROM DataXmlRC_marges(nolock) WHERE id_acte=@id_acte_prod
						SELECT @nbr_marges_ithaque = COUNT(DISTINCT id_marge) FROM DataXmlRC_marges(nolock) WHERE id_acte=@id_acte_ithaque

						IF NOT (@nbr_zones_prod = @nbr_zones_ithaque AND @nbr_marges_prod=@nbr_marges_ithaque)
							BEGIN
								INSERT INTO CorrectionProcess_ModifiedActs(id_acte_xml, id_acte_ithaque, flag)
								SELECT @id_acte_xml_ithaque, @id_acte_prod, 3 AS flag
							END
					END
					
				FETCH NEXT FROM name_check_cursor INTO @nom_ithaque, @prenom_ithaque
			END
			FETCH NEXT FROM check_actes_details INTO @id_acte_xml_ithaque, @date_acte_ithaque
		END	

	CLOSE check_actes_details -- close the cursor
	DEALLOCATE check_actes_details -- Deallocate the cursor

	END

	---- sterge actele de pe prod si preprod care nu se mai regasesc in ultimul tratament
	--EXEC [PRESQL04].[Archives_Preprod].[dbo].[spCorrectionProcessus_SupprimerActes_Preprod_Prod] @id_document=@id_document

	---- insereaza in procesul de reecriture actele_xml pt care trebuie sa rulam procesul
	--EXEC [dbo].[spCorrectionProcess_InsertionActesXml_ReecritureProcess] @id_projet=@id_projet

	---- start reecriture process
	--EXEC [Ithaque_Reecriture].[dbo].[spReecritureTraitement]
	
	---- insert fichiers into saisie_donnees_fichiers_xml_temp
	--EXEC [dbo].[CorrectionProcess_PrepareImportationSaisieDB] @id_projet = @id_projet, @id_document =@id_document

	---- --start job Archives_preprod nouveau
	--EXEC spImportationSaisieStartJob_NouveauUpdate


	
		
END
GO
