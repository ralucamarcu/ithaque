SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Importation d'actes, individus, zones, marges, relations d'individus dans Ithaque_Reecriture
	--, afin de faire de la réécriture.
	-- Pour un departement, toutes les données seront importées. (avamt de terminer le CQ)
	-- Si le projet a été livré par le prestataire, mais le CQ n'a pas commencé 
	--			=> dans le table DataXML_fichiers, il y a seulement une ligne par nom_fichier 
	--				=> insérer toutes les données de tous les fichiers, qui font part des livraisons avec 
	--						(controle_livraison_conformite = 1 & import_XML = 1 & livraison_annulee = 0)
	-- Si le projet a été livré par le prestataire et le CQ a commencé 
	--			=> dans le table DataXML_fichiers il y a plusieurs lignes par nom_fichier 
	--				=> insérer toutes les données du plus récent nom_fichier, de livraisons avec 
	--					(controle_livraison_conformite = 1 & import_XML = 1 & livraison_annulee = 0 ) 
	--					
-- =============================================
CREATE PROCEDURE [dbo].[spReecritureImportInfo_nouveau]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecritureImportInfo_nouveau]'37F9232A-9ED6-4D97-A79C-D229EDF02505', 5,'Ithaque BD'
	 @id_projet UNIQUEIDENTIFIER
	,@id_utilisateur INT
	,@machine_traitement VARCHAR(255) = 'Ithaque App'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_image UNIQUEIDENTIFIER, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
		,@id_source UNIQUEIDENTIFIER,@nb_fichiers int, @nb_actes int,@nb_images int,@nom_department varchar(150)
		,@nb_fichiers_CQ_commence int, @nb_fichiers_CQ_pas_commence int
	
	SET @id_source = (SELECT id_source FROM sources_projets WHERE id_projet = @id_projet)
  
--SELECT @id_source
 
    EXEC [dbo].[spInsertionTacheLog] 23, @id_utilisateur, @id_source, @id_projet, @machine_traitement
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

		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus_zones
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_marges]
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_zones
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_individus_identites]
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus]
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_actes
		
		CREATE TABLE #tmp_fichiers (id_fichier uniqueidentifier, id_lot uniqueidentifier)

		INSERT INTO #tmp_fichiers (id_fichier, id_lot)
		select x.id_fichier, x.id_lot from(
			select row_number() over (partition by dxf.nom_fichier order by dxf.date_creation desc) as row_num, dxf.* 
			from DataXml_fichiers dxf with (nolock)
			INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) on dxf.id_lot=lf.id_lot
			INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
			WHERE t.id_projet = @id_projet
				AND t.controle_livraison_conformite = 1 
				AND t.import_xml = 1 
				AND t.livraison_annulee = 0
				
				) as x
		where x.row_num = 1
		
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
		SELECT dxa.[id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte],[geonameid_acte],[insee_acte],[fichier_xml_acte]
			  ,dxa.[id_traitement],dxa.[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction],[date_acte_Correction],[annee_acte_Correction]
			  ,[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction],dxa.[id_fichier]
			  ,[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN #tmp_fichiers dxf WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
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
		FROM DataXmlRC_individus dxi WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxi.id_acte = dxa.id		
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_individus OFF
		
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_zones ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_zones ([id_zone],[ordre],[cache],[IMAGE],[rect_x1],[rect_y1],[rect_x2],[rect_y2],[date_creation],[id_acte]
			,[tag_image],[tag_rectangle],[id_individu_xml],[primaire],[id_image],[statut])
		SELECT [id_zone],[ordre],[cache],[IMAGE],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxz.[date_creation],[id_acte]
			,[tag_image],[tag_rectangle],[id_individu_xml],[primaire],dxz.[id_image],dxz.[statut]
		FROM DataXmlRC_zones dxz WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
		SET IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_zones OFF
		
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_individus_zones ([id_zone],[id_individu_xml],[date_creation])
		SELECT dxiz.[id_zone],dxiz.[id_individu_xml],dxiz.[date_creation]
		FROM DataXmlRC_individus_zones dxiz WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_zones dxz ON dxiz.id_zone = dxz.id_zone
		
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_marges]([id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],[date_creation],[id_acte],[tag_image],[tag_rectangle],
					[id_individu_xml],[statut])
		SELECT [id_marge],[ordre],[cache],[image],[rect_x1],[rect_y1],[rect_x2],[rect_y2],dxm.[date_creation],[id_acte],[tag_image],[tag_rectangle],[id_individu_xml],[statut]
		FROM [dbo].[DataXmlRC_marges] dxm WITH (NOLOCK)
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dxm.id_acte = dxa.id	
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_marges] OFF
	
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ON
		INSERT INTO Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] ([id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],[date_creation])
		SELECT dri.[id],[id_individu_xml],[id_individu_relation_xml],[nom_relation],[id_acte],dri.[date_creation]
		FROM [dbo].[DataXmlRC_relations_individus] dri WITH (NOLOCK) 
		INNER JOIN Ithaque_Reecriture.dbo.DataXmlRC_actes dxa WITH (NOLOCK) ON dri.id_acte = dxa.id
		SET IDENTITY_INSERT Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus] OFF
		
		DROP TABLE #tmp_fichiers

	COMMIT TRANSACTION spReecritureImportInfo;
	
	SET @IntegerResult = 1 
	
		SELECT 	@nom_department=[nom_departement]  	
		FROM Ithaque.[dbo].[Projets] WITH (NOLOCK) 
		WHERE id_projet=@id_projet

		SELECT @nb_images=COUNT(DISTINCT z.id_image),@nb_actes=COUNT(DISTINCT a.id),@nb_fichiers=count(DISTINCT a.id_fichier)
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
