SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 25/01/2016
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CorrectionProcess_PrepareImportationSaisieDB]
	@id_projet uniqueidentifier,
	@id_document uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  	CREATE TABLE #tmp (id_acte INT PRIMARY KEY, type_acte NVARCHAR(255), annee_acte NVARCHAR(255), nom_fichier varchar(255))	
	CREATE TABLE #tmp2 (id_acte INT PRIMARY KEY, type_acte NVARCHAR(255), annee_acte NVARCHAR(255), nom_fichier varchar(255))	

	DECLARE  @current_date datetime=GETDATE(), @id_tache_log INT, @id_tache_log_details INT,@id_utilisateur int = 12 ,@machine_traitement varchar(255) = 'Ithaque App'
			,@id_source uniqueidentifier 

	SET @id_source = (SELECT id_source FROM dbo.Sources_Projets sp WITH(NOLOCK) WHERE sp.id_projet=@id_projet) 

	EXEC Ithaque.[dbo].[spInsertionTacheLog] 34, @id_utilisateur, @id_source, NULL, @machine_traitement
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM Ithaque.dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 34					
					ORDER BY date_creation DESC)
	EXEC Ithaque.[dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM Ithaque.dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)


	BEGIN TRY

		CREATE TABLE #TEMP_fichiers(id int identity,id_fichier uniqueidentifier, id_traitement int
			,chemin_fichier varchar(255),id_projet uniqueidentifier)
		INSERT INTO #TEMP_fichiers(id_fichier,id_traitement,id_projet)
		SELECT da.id_fichier,t.id_traitement,t.id_projet
		FROM ithaque.dbo.DataXml_fichiers df WITH (NOLOCK)
		INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON da.id_fichier=df.id_fichier
		INNER JOIN Ithaque.dbo.DataXmlEchantillonEntete dxee WITH (nolock) ON df.id_lot = dxee.id_lot
		INNER JOIN Ithaque.dbo.Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet	
		INNER JOIN ithaque.dbo.traitements t(NOLOCK) on df.id_traitement=t.id_traitement
		WHERE t.id_projet = @id_projet 
			AND la.[action] = 'CocheEchantillonTraité' 
			AND la.id_type_objet = 1	
		GROUP BY da.id_fichier , t.id_traitement,t.id_projet
		ORDER BY t.id_traitement DESC

		UPDATE #TEMP_fichiers
		SET chemin_fichier=RTRIM(LTRIM(RIGHT(df.chemin_fichier, charindex('\', REVERSE(df.chemin_fichier)))))
		FROM ithaque.dbo.DataXml_fichiers df WITH (NOLOCK)
			INNER JOIN #TEMP_fichiers t ON df.id_fichier=t.id_fichier


		BEGIN TRANSACTION PrepareImportationSaisieDB


		INSERT INTO #tmp(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT id_acte,type_acte, annee_acte, nom_fichier
		FROM (	SELECT ROW_NUMBER() OVER (PARTITION BY dxa.id_acte_xml ORDER BY dxa.id DESC) AS line, dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
				FROM CorrectionProcess_ModifiedActs ma (NOLOCK) 
				INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_acte_xml=ma.id_acte_xml 
				INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
				INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
				INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
				INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
				INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
				WHERE t.id_projet = @id_projet
				AND la.[action] = 'CocheEchantillonTraité'
				AND la.id_type_objet = 1	
				AND ISNUMERIC(annee_acte) = 1) AS dtl
		WHERE line=1
			
		INSERT INTO #tmp2(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT id_acte,type_acte, annee_acte, nom_fichier
		FROM (	SELECT ROW_NUMBER() OVER (PARTITION BY dxa.id_acte_xml ORDER BY dxa.id DESC) AS line, dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
				FROM CorrectionProcess_ModifiedActs ma (NOLOCK) 
				INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_acte_xml=ma.id_acte_xml 
				INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
				INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
				INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
				INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
				INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
				WHERE t.id_projet = @id_projet
				AND la.[action] = 'CocheEchantillonTraité'
				AND la.id_type_objet = 1	
				AND ISNUMERIC(annee_acte) <> 1) AS dtl
		WHERE line=1
			
		CREATE INDEX idx_tmp_id_acte on #tmp(id_acte)
		CREATE INDEX idx_tmp2_id_acte on #tmp2(id_acte)
		
		EXEC [PRESQL04].Archives_Preprod.dbo.AEL_Creation_TempTable_XML_fichiers


		INSERT INTO [PRESQL04].Archives_Preprod.dbo.saisie_donnees_fichiers_xml_temp (id_document, chemin)	
	SELECT @id_document AS id_document
		, '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier)))) AS chemin
	FROM #tmp t
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = t.id_acte
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
	WHERE (t.type_acte = 'naissance' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1893) )
		OR (t.type_acte = 'deces' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1909) )
		OR (t.type_acte = 'mariage' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1938) )
	GROUP BY '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier))))

		SELECT @id_document AS id_document
		, '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier)))) AS chemin
		INTO #temp3
		FROM  #tmp2 t
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = t.id_acte
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
		WHERE (t.annee_acte in ('AN01', 'AN02', 'AN03', 'AN04', 'AN05', 'AN06', 'AN07', 'AN08', 'AN09', 'AN10', 'AN11', 'AN12', 'AN13'
			,'ANI', 'ANII', 'ANIII', 'ANIV','ANV', 'ANVI', 'ANVII', 'ANVIII', 'ANIX', 'ANX', 'ANXI', 'ANXII', 'ANXIII', 'ANXIV')
			OR isnull(t.annee_acte , '') = '' )
		GROUP BY '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier))))
	
		SELECT id_document AS id_document ,chemin
		INTO #temp4
		FROM #temp3 
		WHERE chemin collate database_default NOT IN (SELECT chemin FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_fichiers_xml_temp WITH (NOLOCK)) 
	
		INSERT INTO [PRESQL04].Archives_Preprod.dbo.saisie_donnees_fichiers_xml_temp (id_document, chemin)	
		SELECT id_document,chemin
		FROM #temp4
	
		delete FROM #TEMP_fichiers WHERE #TEMP_fichiers.chemin_fichier COLLATE database_default NOT IN 
			(SELECT chemin from [PRESQL04].Archives_Preprod.dbo.saisie_donnees_fichiers_xml_temp with (nolock)  WHERE id_document = @id_document)

		INSERT INTO [PRESQL04].Archives_Preprod.dbo.saisie_donnees_fichiers_xml(chemin, statut, date_creation, id_document, id_fichier_ithaque) 	
		SELECT tf.chemin_fichier AS chemin, 0 AS statut, @current_date AS date_creation, @id_document as id_document , tf.id_fichier
		from #TEMP_fichiers tf
		GROUP BY tf.chemin_fichier, tf.id_fichier
	
		DROP TABLE #TEMP_fichiers

		EXEC [PRESQL04].Archives_Preprod.dbo.saisie_donnees_truncate_table_temp_ithaque

		-- create files
		EXEC [Ithaque_Reecriture].[dbo].[spCreationFichiersImportationSaisie]

	COMMIT TRANSACTION PrepareImportationSaisieDB;

		-- --start job Archives_preprod nouveau
		EXEC spImportationSaisieStartJob_NouveauUpdate
		
		EXEC Ithaque.dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC Ithaque.dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;
		
		ROLLBACK TRANSACTION PrepareImportationSaisieDB;

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
