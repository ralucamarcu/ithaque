SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 21-01-2016
-- Description:	<Description,,>
-- =============================================
-- testrun :  spCorrectionProcess_UpdateActsModifications_DernierTraitement '69689087-9FA6-477D-9F56-896DE7884F5D'

CREATE PROCEDURE spCorrectionProcess_UpdateActsModifications_DernierTraitement
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

	DECLARE @id_document uniqueidentifier= (SELECT id_document FROM [AEL_Parametres_nouveau] (NOLOCK) WHERE id_projet=@id_projet)

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
	      WHERE t.id_projet = '69689087-9FA6-477D-9F56-896DE7884F5D'-- @id_projet
			AND t.livraison_annulee=0 
			AND ISNULL(dxf.rejete, 0) = 0 
			AND ISNULL(dxf.ignore_export_publication, 0) = 0 
			AND isnull(lf.export_pour_mep, 0) = 0) AS ddt
	WHERE line=1

	CREATE INDEX idx_id ON #temp_actes(id)

	SELECT dxi.[id],[id_individu_xml],[principal],[nom],[prenom],[age],[date_naissance],[annee_naissance],[calendrier_date_naissance],[lieu_naissance],[insee_naissance]
		  ,[geonameid_naissance],[id_acte],[rang],[date_naissance_gregorienne],dxi.[date_creation],[nom_Correction],[prenom_Correction],[age_Correction]
		  ,[date_naissance_Correction],[annee_naissance_Correction],[calendrier_date_naissance_Correction],[date_modification],[lieu_naissance_Correction]
		  ,[insee_naissance_Correction],[geonameid_naissance_Correction],[nom_Correction_Reecriture],[prenom_Correction_Reecriture]
	INTO #temp_individus
	FROM DataXmlRC_individus dxi WITH (NOLOCK)
	INNER JOIN #temp_actes dxa WITH (NOLOCK) ON dxi.id_acte = dxa.id	

	CREATE INDEX idx_id ON #temp_individus(id)

	SELECT  [id_zone],[ordre],[cache],[IMAGE],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxz.[date_creation],[id_acte],[tag_image],[tag_rectangle],[id_individu_xml],[primaire]
			,dxz.[id_image],dxz.[statut]
	INTO #temp_zones
	FROM DataXmlRC_zones dxz WITH (NOLOCK)
	INNER JOIN #temp_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id	

	CREATE INDEX idx_id_zone ON #temp_zones(id_zone)

	SELECT dxiz.[id_zone],dxiz.[id_individu_xml],dxiz.[date_creation]
	INTO #temp_individus_zones
	FROM DataXmlRC_individus_zones dxiz WITH (NOLOCK)
	INNER JOIN #temp_zones dxz ON dxiz.id_zone = dxz.id_zone

	SELECT [id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxm.[date_creation],[id_acte],[tag_image],[tag_rectangle],[id_individu_xml],[statut]
	INTO #temp_marges
	FROM [dbo].[DataXmlRC_marges] dxm WITH (NOLOCK)
	INNER JOIN #temp_actes dxa WITH (NOLOCK) ON dxm.id_acte = dxa.id
	
	SELECT dri.[id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],dri.[date_creation]
	INTO #temp_relations_individus
	FROM [dbo].[DataXmlRC_relations_individus] dri WITH (NOLOCK) 
	INNER JOIN #temp_actes dxa WITH (NOLOCK) ON dri.id_acte = dxa.id

	SELECT id_acte_xml, id_acte_ithaque, id_acte AS id_acte_archives
	INTO #temp_actes_production_archives
	FROM [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_actes] sda
	INNER JOIN [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_pages] sdp ON sda.id_page=sdp.id_page
	WHERE sdp.id_document= 'C0314790-F5D0-454E-A999-A64C37A8CCD2' --@id_document ---- LYON -> do not delete!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
		SELECT @id_acte_prod=id FROM #temp_actes_production_archives WHERE id_acte_xml=@id_acte_xml_ithaque

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

END
GO
