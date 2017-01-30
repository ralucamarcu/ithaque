SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2/01/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spCorrectionProcess_InsertionActesXml_ReecritureProcess]
	@id_projet uniqueidentifier
AS
BEGIN

	DECLARE  @current_date datetime=GETDATE(), @id_tache_log INT, @id_tache_log_details INT,@id_utilisateur int = 12 ,@machine_traitement varchar(255) = 'Ithaque App'
			,@id_source uniqueidentifier 

    SET @id_source = (SELECT id_source FROM dbo.Sources_Projets sp WITH(NOLOCK) WHERE sp.id_projet=@id_projet)

    EXEC [dbo].[spInsertionTacheLog] 35, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 35					
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)



	BEGIN TRY
	BEGIN TRANSACTION spReecritureImportInfo; 

		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus_zones
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_marges]
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_zones
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_individus_identites]
		TRUNCATE TABLE Ithaque_Reecriture.[dbo].[DataXmlRC_relations_individus]
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_individus
		TRUNCATE TABLE Ithaque_Reecriture.dbo.DataXmlRC_actes

		SET  IDENTITY_INSERT Ithaque_Reecriture.dbo.DataXmlRC_actes ON
		INSERT INTO Ithaque_Reecriture.dbo.DataXmlRC_actes ([id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture])
		SELECT	[id],[type_acte],[soustype_acte],[id_acte_xml],[date_acte],[annee_acte],[calendrier_date_acte],[lieu_acte]
		  ,[geonameid_acte],[insee_acte],[fichier_xml_acte],[id_traitement],[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction]
		  ,[date_acte_Correction],[annee_acte_Correction],[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction]
		  ,[id_fichier],[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
		FROM (SELECT ROW_NUMBER() OVER (PARTITION BY dxa.id_acte_xml ORDER BY dxa.id DESC) AS line,dxa.[id],[type_acte],[soustype_acte],dxa.[id_acte_xml],[date_acte],[annee_acte]
		  ,[calendrier_date_acte],[lieu_acte],[geonameid_acte],[insee_acte],[fichier_xml_acte]
		  ,dxa.[id_traitement],dxa.[date_creation],[soustype_xml_acte],[date_acte_gregorienne],[soustype_acte_Correction],[date_acte_Correction],[annee_acte_Correction]
		  ,[calendrier_date_acte_Correction],[lieu_acte_Correction],[geonameid_acte_Correction],[insee_acte_Correction],dxa.[id_fichier]
		  ,[type_acte_Correction],[id_image],[date_acte_Correction_Reecriture],[annee_acte_Correction_Reecriture]
			  FROM CorrectionProcess_ModifiedActs ma (NOLOCK) 
			  INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_acte_xml=ma.id_acte_xml
			  INNER JOIN DataXml_fichiers dxf WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
			  INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) on dxf.id_lot=lf.id_lot
			  INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
			  WHERE t.id_projet = @id_projet
				AND t.livraison_annulee=0 
				AND ISNULL(dxf.rejete, 0) = 0 
				AND ISNULL(dxf.ignore_export_publication, 0) = 0 
				AND isnull(lf.export_pour_mep, 0) = 0) AS ddt
		WHERE line=1

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

			COMMIT TRANSACTION spReecritureImportInfo;
		
		EXEC Ithaque.dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC Ithaque.dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spReecritureImportInfo;
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );

		EXEC Ithaque.dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC Ithaque.dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END CATCH;
END
GO
