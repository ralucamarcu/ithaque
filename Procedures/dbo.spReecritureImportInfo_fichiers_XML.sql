SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: [dbo].[spReecritureImportInfo_fichiers_XML] 5,'Ithaque App','EC85_output_85008_1793-1800_NMD_260.xml,EC85_output_85008_1843-1848_NMD_283.xml,EC85_output_85136_1793-1794_N_4288.xml,EC85_output_85140_1812-1826_NMD_4360.xml'

CREATE PROCEDURE [dbo].[spReecritureImportInfo_fichiers_XML]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecritureImportInfo_fichiers_XML] 5,'Ithaque App','EC85_output_85008_1793-1800_NMD_260.xml,EC85_output_85008_1843-1848_NMD_283.xml,EC85_output_85136_1793-1794_N_4288.xml,EC85_output_85140_1812-1826_NMD_4360.xml'
	 @id_utilisateur INT
	,@machine_traitement VARCHAR(255) = 'Ithaque App'
	,@nom_fichier varchar(max)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @sDelimiter VARCHAR(8000) = ',',@sItem VARCHAR(8000),@last_element VARCHAR(8000),@id_projet uniqueidentifier
	CREATE TABLE #temp_fichiers(id int identity,nom_fichier varchar(255))
	CREATE TABLE #temp_ID_fichier(id int identity,id_fichier UNIQUEIDENTIFIER,date_creation datetime,nom_fichier varchar(255))

	WHILE CHARINDEX(@sDelimiter,@nom_fichier,0) <> 0
	BEGIN
		 SELECT @sItem=RTRIM(LTRIM(SUBSTRING(@nom_fichier,1,CHARINDEX(@sDelimiter,@nom_fichier,0)-1))),
		  @nom_fichier=RTRIM(LTRIM(SUBSTRING(@nom_fichier,CHARINDEX(@sDelimiter,@nom_fichier,0)+LEN(@sDelimiter),LEN(@nom_fichier)))),
		  @last_element=RTRIM(LTRIM(@nom_fichier))
   
		IF LEN(@sItem) > 0
		BEGIN
			insert into #temp_fichiers(nom_fichier) SElect @sItem
		END
	 END
	 IF LEN(@sItem) > 0
		BEGIN
			insert into #temp_fichiers(nom_fichier) SElect @last_element
		END


	INSERT INTO #temp_ID_fichier(id_fichier,date_creation,nom_fichier)
	SELECT dxf.id_fichier,MAX(dxf.date_creation) as date_creation,dxf.nom_fichier
	FROM  Ithaque.[dbo].[DataXml_fichiers] dxf WITH (NOLOCK)
		INNER JOIN Ithaque.[dbo].DataXmlEchantillonEntete de (nolock) on dxf.id_lot=de.id_lot
		INNER JOIN #temp_fichiers tt on dxf.nom_fichier=tt.nom_fichier COLLATE DATABASE_DEFAULT 
		INNER JOIN Traitements t WITH (NOLOCK) ON de.id_traitement = t.id_traitement
	WHERE de.traite=1 and de.id_statut in (1,3) AND t.livraison_annulee=0 AND ISNULL(dxf.rejete, 0) = 0 AND ISNULL(dxf.ignore_export_publication, 0) = 0 
	GROUP BY dxf.id_fichier,dxf.nom_fichier


	SET @id_projet=(SELECT t.id_projet 
					FROM Ithaque.[dbo].DataXmlRC_actes dxa WITH (NOLOCK)
						INNER JOIN Ithaque.[dbo].DataXml_fichiers dxf WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
						INNER JOIN Ithaque.[dbo].Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
						INNER JOIN #temp_ID_fichier tf ON tf.id_fichier=dxf.id_fichier
					GROUP BY id_projet)


    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
		,@id_source UNIQUEIDENTIFIER,@nb_fichiers int, @nb_actes int,@nb_images int,@nom_department varchar(150)
	
	SET @id_source = (SELECT id_source FROM sources_projets WHERE id_projet = @id_projet)
    
    EXEC [dbo].[spInsertionTacheLog] 23, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 23					
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	PRINT @id_tache_log 
	
	BEGIN TRY
	BEGIN TRANSACTION spReecritureImportInfo;  
	   
	   truncate table Ithaque_Reecriture.dbo.DataXmlRC_actes
		SET  IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_actes ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_actes ([id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture])

		SELECT dxa.[id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte],[geonameid_acte],[insee_acte],[fichier_xml_acte]
		  ,dxa.[id_traitement],dxa.[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction],[date_acte_Correction],[annee_acte_Correction]
		  ,[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction],dxa.[id_fichier]
		  ,[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
		FROM Ithaque.[dbo].DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN Ithaque.[dbo].DataXml_fichiers dxf WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN Ithaque.[dbo].Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN #temp_ID_fichier tf ON tf.id_fichier=dxf.id_fichier
		--WHERE t.id_projet = @id_projet

		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_actes OFF
		
		truncate table Ithaque_Reecriture.dbo.DataXmlRC_individus 
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_individus ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_individus ([id],[id_individu_xml],[principal],[nom],[prenom],[age],[date_naissance],[annee_naissance]
		  ,[calendrier_date_naissance],[lieu_naissance],[insee_naissance],[geonameid_naissance],[id_acte],[rang],[date_naissance_gregorienne],[date_creation],[nom_Correction]
		  ,[prenom_Correction],[age_Correction],[date_naissance_Correction],[annee_naissance_Correction],[calendrier_date_naissance_Correction],[date_modification]
		  ,[lieu_naissance_Correction],[insee_naissance_Correction],[geonameid_naissance_Correction],[nom_Correction_Reecriture]
		  ,[prenom_Correction_Reecriture])
		SELECT dxi.[id],[id_individu_xml],[principal],[nom],[prenom],[age],[date_naissance],[annee_naissance],[calendrier_date_naissance],[lieu_naissance],[insee_naissance]
		  ,[geonameid_naissance],[id_acte],[rang],[date_naissance_gregorienne],dxi.[date_creation],[nom_Correction],[prenom_Correction],[age_Correction]
		  ,[date_naissance_Correction],[annee_naissance_Correction],[calendrier_date_naissance_Correction],[date_modification],[lieu_naissance_Correction]
		  ,[insee_naissance_Correction],[geonameid_naissance_Correction],[nom_Correction_Reecriture],[prenom_Correction_Reecriture]
		FROM Ithaque.[dbo].DataXmlRC_individus dxi WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxi.id_acte = dxa.id		
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_individus OFF
		

		truncate table Ithaque_Reecriture.dbo.DataXmlRC_zones 
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_zones ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_zones ([id_zone],[ordre],[cache],[IMAGE],[rect_x1],[rect_y1],[rect_x2],[rect_y2],[date_creation],[id_acte]
			,[tag_image],[tag_rectangle],[id_individu_xml],[primaire],[id_image],[statut])
		SELECT [id_zone],[ordre],[cache],[IMAGE],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxz.[date_creation],[id_acte]
			,[tag_image],[tag_rectangle],[id_individu_xml],[primaire],dxz.[id_image],dxz.[statut]
		FROM Ithaque.[dbo].DataXmlRC_zones dxz WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_zones OFF
		
		
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_individus_zones ([id_zone],[id_individu_xml],[date_creation])
		SELECT dxiz.[id_zone],dxiz.[id_individu_xml],dxiz.[date_creation]
		FROM Ithaque.[dbo].DataXmlRC_individus_zones dxiz WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_zones dxz ON dxiz.id_zone = dxz.id_zone
		
		
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_marges]
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_marges]([id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],[date_creation],[id_acte],[tag_image],[tag_rectangle],
					[id_individu_xml],[statut])
		SELECT [id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxm.[date_creation],[id_acte],[tag_image],[tag_rectangle],[id_individu_xml],[statut]
		FROM [dbo].[DataXmlRC_marges] dxm WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxm.id_acte = dxa.id	
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] OFF

		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus]
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ([id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],[date_creation])
		SELECT dri.[id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],dri.[date_creation]
		FROM [dbo].[DataXmlRC_relations_individus] dri WITH (NOLOCK) 
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dri.id_acte = dxa.id
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] OFF

				
	COMMIT TRANSACTION spReecritureImportInfo;
	
	SET @IntegerResult = 1 

		SELECT 	@nom_department=[nom_departement]  	
		FROM Ithaque.[dbo].[Projet] WITH (NOLOCK) 
		WHERE id_projet=@id_projet

		SELECT @nb_images=COUNT(DISTINCT z.id_image),@nb_actes=COUNT(DISTINCT a.id),@nb_fichiers=COUNT(DISTINCT id_fichier)
		FROM Ithaque_Reecriture.dbo.DataXmlRC_actes a WITH (NOLOCK)
		INNER JOIN [dbo].[DataXmlRC_zones] z WITH (NOLOCK) ON a.id=z.id_acte

		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[Details_reecriture]
		INSERT INTO Ithaque_Reecriture.[dbo].[Details_reecriture]([nom_departement],[nb_fichiers],[nb_images],[nb_actes_total_import],id_projet)
		VALUES (@nom_department,@nb_fichiers,@nb_images,@nb_actes,@id_projet)
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spReecritureImportInfo;
		
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
