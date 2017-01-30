SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Traitement_XML_Insertion_XML_valide_Ithaque_archives]
	-- Add the parameters for the stored procedure here
	-- Test Run : AEL_Traitement_XML_Insertion_XML_valide '6F8401B1-301E-44B9-B895-737183B56401'
	-- Test Run : AEL_Traitement_XML_Insertion_XML_valide '5BC4606A-A0F3-46A9-9542-91D457F271E7', 'EC85_output_85136_1793-1794_N_4288.xml,EC85_output_85140_1812-1826_NMD_4360.xml,EC85_output_85008_1843-1848_NMD_283.xml,EC85_output_85008_1793-1800_NMD_260.xml'
	 @id_projet UNIQUEIDENTIFIER
	,@nom_fichiers varchar(800) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @sDelimiter VARCHAR(8000) = ',',@sItem VARCHAR(8000),@last_element VARCHAR(8000), @id_document UNIQUEIDENTIFIER
	CREATE TABLE #temp_fichiers_ithaque(id int identity,nom_fichier_ithaque varchar(255))
	CREATE TABLE #tmp (id_acte INT PRIMARY KEY, type_acte NVARCHAR(255), annee_acte NVARCHAR(255), nom_fichier varchar(255))	
	CREATE TABLE #tmp2 (id_acte INT PRIMARY KEY, type_acte NVARCHAR(255), annee_acte NVARCHAR(255), nom_fichier varchar(255))	
	CREATE TABLE #temp3(id_document uniqueidentifier, chemin varchar(500))
	CREATE TABLE #temp4(id_document uniqueidentifier, chemin varchar(500))


	IF @nom_fichiers IS NOT NULL
	BEGIN	
	PRINT 1 
		WHILE CHARINDEX(@sDelimiter,@nom_fichiers,0) <> 0
		BEGIN
			 SELECT @sItem=RTRIM(LTRIM(SUBSTRING(@nom_fichiers,1,CHARINDEX(@sDelimiter,@nom_fichiers,0)-1))),
			  @nom_fichiers=RTRIM(LTRIM(SUBSTRING(@nom_fichiers,CHARINDEX(@sDelimiter,@nom_fichiers,0)+LEN(@sDelimiter),LEN(@nom_fichiers)))),
			  @last_element=RTRIM(LTRIM(@nom_fichiers))
   
			IF LEN(@sItem) > 0
			BEGIN
				insert into #temp_fichiers_ithaque(nom_fichier_ithaque) SElect @sItem
			END
		END
		IF LEN(@sItem) > 0
		BEGIN
			insert into #temp_fichiers_ithaque(nom_fichier_ithaque) SElect @last_element
		END

		SET @id_document = (SELECT TOP 1 id_document FROM AEL_Parametres WHERE principal = 1)	
		INSERT INTO #tmp(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT DISTINCT dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN #temp_fichiers_ithaque tf WITH (nolock) ON dxf.nom_fichier = tf.nom_fichier_ithaque
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND id_statut IN (1,3)
			AND ISNUMERIC(annee_acte) = 1

		INSERT INTO #tmp2(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT DISTINCT dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN #temp_fichiers_ithaque tf WITH (nolock) ON dxf.nom_fichier = tf.nom_fichier_ithaque
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND id_statut IN (1,3)
			AND ISNUMERIC(annee_acte) <> 1
		
		END
	ELSE
	BEGIN    
		SET @id_document = (SELECT TOP 1 id_document FROM AEL_Parametres WHERE principal = 1)	
		INSERT INTO #tmp(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT DISTINCT dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND id_statut IN (1,3)
			AND ISNUMERIC(annee_acte) = 1
			
		INSERT INTO #tmp2(id_acte, type_acte, annee_acte, nom_fichier)
		SELECT DISTINCT dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte, dxf.nom_fichier
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND id_statut IN (1,3)
			AND ISNUMERIC(annee_acte) <> 1
	END
		
	CREATE INDEX idx_tmp_id_acte on #tmp(id_acte)
	CREATE INDEX idx_tmp2_id_acte on #tmp2(id_acte)
		
	EXEC [archives].dbo.AEL_Creation_TempTable_XML_fichiers

	INSERT INTO [archives].dbo.saisie_donnees_fichiers_xml_temp (id_document, chemin)
	SELECT @id_document AS id_document
		, '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier)))) AS chemin
	FROM #tmp t
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = t.id_acte
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
	WHERE (t.type_acte = 'naissance' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1893) )
		OR (t.type_acte = 'deces' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1909) )
		OR (t.type_acte = 'mariage' AND (CAST(t.annee_acte AS INT) >= 1792 AND CAST(t.annee_acte AS INT) <= 1938) )
	GROUP BY '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier))))


	INSERT INTO #temp3
	SELECT @id_document AS id_document
		, '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier)))) AS chemin
	FROM  #tmp2 t
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = t.id_acte
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
	WHERE (t.annee_acte in ('AN01', 'AN02', 'AN03', 'AN04', 'AN05', 'AN06', 'AN07', 'AN08', 'AN09', 'AN10', 'AN11', 'AN12', 'AN13'
		,'ANI', 'ANII', 'ANIII', 'ANIV','ANV', 'ANVI', 'ANVII', 'ANVIII', 'ANIX', 'ANX', 'ANXI', 'ANXII', 'ANXIII', 'ANXIV')
		OR isnull(t.annee_acte , '') = '' )
	GROUP BY '\' + REVERSE(SUBSTRING(REVERSE(chemin_fichier),0,CHARINDEX('\',REVERSE(chemin_fichier))))
	
	INSERT INTO #temp4
	SELECT id_document AS id_document ,chemin	
	FROM #temp3 
	WHERE chemin collate database_default NOT IN (SELECT chemin 
			FROM [archives].dbo.saisie_donnees_fichiers_xml_temp WITH (NOLOCK)) 
	
	INSERT INTO [archives].dbo.saisie_donnees_fichiers_xml_temp (id_document, chemin)	
	SELECT id_document,chemin
	FROM #temp4

	DROP TABLE #tmp
	DROP TABLE #tmp2
	DROP TABLE #temp_fichiers_ithaque
	DROP TABLE #temp3
	DROP TABLE #temp4
		
END
GO
