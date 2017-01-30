SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: spSelectionLivrasionsTest
CREATE PROCEDURE [dbo].[spSelectionLivrasionsTest]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE  @nb_actes						int=NULL
			,@nb_fichiers					int=NULL
			,@rejets						float=NULL
			,@nom_traitement				varchar(150)=NULL
			,@date_livraison				datetime=NULL
			,@type_livraison				char(1)=NULL
			,@livraison_conforme			int=NULL
			,@controle_livraison_conformite	int=NULL
			,@import_XML					int=NULL
			,@traite						int=NULL
			,@echant						int=NULL
			,@CQ							float=NULL
			,@nom_p							varchar(150)=NULL


	CREATE TABLE #TEMP (id_projet varchar(150),id_traitement int,nom varchar(150),date_livraison datetime,type_livraison char(1),import_xml int,livraison_conforme int,controle_livraison_conformite int)
	INSERT INTO #TEMP (id_projet,id_traitement,nom,date_livraison,type_livraison,import_xml,livraison_conforme,controle_livraison_conformite) 
	SELECT id_projet, id_traitement,nom,date_livraison,type_livraison,import_xml,livraison_conforme,controle_livraison_conformite FROM Traitements (NOLOCK) WHERE id_projet IS NOT NULL
	--SELECT * from #temp
	--Drop table #TEMP 

	CREATE TABLE #InsertData(id_projet varchar(150),date_livraison datetime,nom varchar(150),type_livraison char(1),traite int,livraison_conforme int,controle_livraison_conformite int,echant int,CQ float,nb_fichiers int, nb_actes int,rejets float)
	
	CREATE TABLE #DataXml_fichiers(id_fichier varchar(150),nom_fichier varchar(150),id_traitement int)
	INSERT INTO #DataXml_fichiers (id_fichier,nom_fichier,id_traitement) SELECT id_fichier,nom_fichier,id_traitement FROM DataXml_fichiers(nolock)
	
	CREATE TABLE #tmp (id_echantillon INT, id_statut INT, traite INT)
	INSERT INTO #tmp (id_echantillon, id_statut, traite)
    SELECT id_echantillon, id_statut, traite
    FROM DataXmlEchantillonEntete WITH (NOLOCK)
    
	
	DECLARE @id_projet varchar(150), @id_traitement int
	
	DECLARE SelectionInfo CURSOR FOR
	SELECT id_projet,id_traitement from #temp

	OPEN SelectionInfo
	FETCH NEXT FROM SelectionInfo
	INTO @id_projet,@id_traitement

	WHILE @@FETCH_STATUS=0

	BEGIN

	SELECT   @nom_traitement=t.nom
			,@nom_p=p.nom
			,@type_livraison=t.type_livraison
			,@date_livraison=t.date_livraison
			,@import_XML=t.import_xml
			,@livraison_conforme=t.livraison_conforme
			,@controle_livraison_conformite=t.controle_livraison_conformite
	FROM #TEMP t(NOLOCK)
		INNER JOIN Projets p(NOLOCK) ON p.id_projet=t.id_projet
	WHERE t.id_projet=@id_projet AND t.id_traitement=@id_traitement



	SET @nb_fichiers=(SELECT COUNT(*)  
					  FROM FichiersData fd (NOLOCK) 
							INNER JOIN #DataXml_fichiers dxf(NOLOCK) ON fd.nom=dxf.nom_fichier
							INNER JOIN #TEMP t (NOLOCK) ON dxf.id_traitement=t.id_traitement
					  WHERE t.id_projet= @id_projet AND t.id_traitement=@id_traitement)

	SET @nb_actes=(SELECT COUNT(*) 
				   FROM dataxmlrc_actes da WITH (NOLOCK) 
						INNER JOIN #DataXml_fichiers dxf WITH (NOLOCK) ON  da.id_fichier=dxf.id_fichier
						INNER JOIN #TEMP t WITH (NOLOCK) ON dxf.id_traitement=t.id_traitement
				   WHERE t.id_projet = @id_projet AND t.id_traitement=dxf.id_traitement )



	DECLARE @nb_lots_rejetes float,@nb_total_lots float,@nb_lots_traites float,@echantillon int,@avancement_controle float,@pourcentage_rejetes float

	SET @nb_lots_rejetes = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE id_statut = 2)
    SET @nb_total_lots = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK))
    SET @nb_lots_traites = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE traite = 1)
    SET @echantillon = (SELECT COUNT(*) FROM DataXml_lots_fichiers WITH (NOLOCK) WHERE id_traitement = @id_traitement) 

	SET @avancement_controle = (CASE WHEN (ISNULL(@nb_lots_traites, 0) <> 0 AND ISNULL(@nb_total_lots, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_lots_traites AS FLOAT) / CAST( @nb_total_lots  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
	SET @pourcentage_rejetes = (CASE WHEN (ISNULL(@nb_lots_rejetes, 0) <> 0 AND ISNULL(@nb_lots_traites, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_lots_rejetes AS FLOAT) / CAST( @nb_lots_traites  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)

	SET @echant=(SELECT CASE WHEN @echantillon = 0 THEN 0 ELSE 1 END)

	INSERT INTO #InsertData(id_projet,date_livraison,nom,type_livraison,traite,livraison_conforme,controle_livraison_conformite,echant,CQ,nb_fichiers, nb_actes,rejets)
	SELECT @id_projet,@date_livraison,@nom_traitement,@type_livraison,@traite,@livraison_conforme,@controle_livraison_conformite,@echant,@avancement_controle,@nb_fichiers,@nb_actes,@pourcentage_rejetes


	FETCH NEXT FROM SelectionInfo
	INTO @id_projet,@id_traitement

	END

	CLOSE SelectionInfo
	DEALLOCATE SelectionInfo

	SELECT * FROM #InsertData

	DROP TABLE #InsertData
	DROP TABLE #TEMP


END
GO
