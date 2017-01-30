SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MEP_MAJ_spReecritureImportInfo_nouveau]
	--Test Run: [dbo].[MEP_MAJ_spReecritureImportInfo_nouveau] 12, null,'F08A87A0-73C6-43FD-BCC8-2E1637BBE991'
	 @id_utilisateur INT
	,@machine_traitement VARCHAR(255) = 'Ithaque App'
	,@id_projet UNIQUEIDENTIFIER

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

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
	
	
	TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus_zones
	TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_marges]
	TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_zones
	TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_individus_identites]
	TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus]
	TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus
	TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_actes

	SELECT dxf.id_fichier, dxf.id_lot 
	INTO #tmp_fichiers
	FROM archives.dbo.MAJ_MEP_acte_xml_traitements_AcceptedEchantillon e
	INNER JOIN DataXml_fichiers dxf WITH (nolock) ON e.id_fichier=dxf.id_fichier 
		
	BEGIN TRY
	BEGIN TRANSACTION spReecritureImportInfo;  

		UPDATE DataXml_fichiers
		SET  MEP = 1
			,MEP_date = @date
		WHERE id_fichier IN (SELECT id_fichier FROM #tmp_fichiers)
		
		UPDATE dbo.DataXml_lots_fichiers
		SET MEP_date = @date
		WHERE id_lot in (SELECT distinct id_lot FROM #tmp_fichiers)
	   
		SET  IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_actes ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_actes ([id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture])

		SELECT [id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,dxf.[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
		FROM  #tmp_fichiers dxf 
		INNER JOIN  DataXmlRC_actes dxa WITH(NOLOCK) ON dxa.id_fichier = dxf.id_fichier

		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_actes OFF
		
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
		FROM  Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN Ithaque.[dbo].DataXmlRC_individus dxi WITH (NOLOCK) ON dxi.id_acte = dxa.id		
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_individus OFF
		
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
		
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_marges]([id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],[date_creation],[id_acte],[tag_image],[tag_rectangle],
					[id_individu_xml],[statut])
		SELECT [id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxm.[date_creation],[id_acte],[tag_image],[tag_rectangle],[id_individu_xml],[statut]
		FROM Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN [dbo].[DataXmlRC_marges] dxm WITH (NOLOCK) ON dxm.id_acte = dxa.id	
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] OFF

		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ([id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],[date_creation])
		SELECT dri.[id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],dri.[date_creation]
		FROM Ithaque_Reecriture.dbo.DataXmlRC_actes dxa  WITH (NOLOCK) 
		INNER JOIN [dbo].[DataXmlRC_relations_individus] dri WITH (NOLOCK) ON dri.id_acte = dxa.id
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] OFF
				
	COMMIT TRANSACTION spReecritureImportInfo;
	
	SET @IntegerResult = 1 

		SELECT 	@nom_department=[nom_departement]  	
		FROM Ithaque.[dbo].[Projets] WITH (NOLOCK) 
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
