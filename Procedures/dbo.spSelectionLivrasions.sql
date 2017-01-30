SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: spSelectionLivrasions
CREATE PROCEDURE [dbo].[spSelectionLivrasions]
	
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
	
	
	DECLARE @id_projet varchar(150), @id_traitement int
	
	DECLARE SelectionInfo CURSOR FOR
	SELECT id_projet,id_traitement from #temp

	OPEN SelectionInfo
	FETCH NEXT FROM SelectionInfo
	INTO @id_projet,@id_traitement

	WHILE @@FETCH_STATUS=0

	BEGIN

	SELECT   @nom_traitement=nom
			,@nom_p=p.nom
			,@type_livraison=t.type_livraison
			,@date_livraison=t.date_livraison
			,@import_XML=t.import_xml
			,@livraison_conforme=t.livraison_conforme
			,@controle_livraison_conformite=t.controle_livraison_conformite
	FROM #TEMP t(NOLOCK)
		INNER JOIN Projects p(NOLOCK) ON p.id_projet=t.id_projet
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


	SET @traite=(SELECT traite 
				 FROM DataXmlEchantillonEntete de(NOLOCK) 
					INNER JOIN #TEMP t (NOLOCK) ON de.id_traitement=t.id_traitement
				 WHERE t.id_traitement=@id_traitement AND t.id_projet =@id_projet
				 GROUP BY traite)


	DECLARE @nb_in float, @nb_diff float
	SET @nb_in=(SELECT COUNT(*) 
				FROM DataXmlEchantillonEntete de(NOLOCK) 
					INNER JOIN #TEMP t(NOLOCK)  ON de.id_traitement=t.id_traitement 
				 WHERE t.id_traitement=@id_traitement and t.id_projet =@id_projet)	
	SET	@nb_diff=(SELECT COUNT(*) 
				  FROM DataXmlEchantillonEntete de(NOLOCK) 
					INNER JOIN #TEMP t(NOLOCK)  ON de.id_traitement=t.id_traitement 
				  WHERE t.id_traitement=@id_traitement and t.id_projet =@id_projet AND  id_statut NOT IN (1,3))
	PRINT @nb_in
	PRINT @nb_diff

	IF (@nb_diff=0)
		BEGIN
			SET @rejets=0
		END
	ELSE
		BEGIN
			SET @rejets=(@nb_diff*100)/@nb_in
		END
	
	PRINT @rejets


	DECLARE @nb_traite_in float, @nb_traite_diff float

	SET @nb_traite_in=@nb_in
	SET @nb_traite_diff=(SELECT COUNT(*)
						 FROM DataXmlEchantillonEntete de(NOLOCK) 
							INNER JOIN #TEMP t(NOLOCK)  ON de.id_traitement=t.id_traitement 
						 WHERE t.id_traitement=@id_traitement and t.id_projet =@id_projet AND traite<>1)
	IF (@nb_traite_diff=0)
		BEGIN
			SET @CQ=100
		END
	ELSE
		BEGIN
			SET @CQ=(@nb_traite_diff*100)/@nb_traite_in
		END

	PRINT @CQ

	IF EXISTS (SELECT id_lot 
			   FROM  DataXml_lots_fichiers dlf (nolock)
				INNER JOIN #TEMP t (NOLOCK) ON dlf.id_traitement=t.id_traitement
			   WHERE id_projet=@id_projet AND t.id_traitement=@id_traitement) 

		 BEGIN
			SET @echant=1
		 END 
	 ELSE 
		 BEGIN
			SET @echant=0
		 END

	INSERT INTO #InsertData(id_projet,date_livraison,nom,type_livraison,traite,livraison_conforme,controle_livraison_conformite,echant,CQ,nb_fichiers, nb_actes,rejets)
	SELECT @id_projet,@date_livraison,@nom_traitement,@type_livraison,@traite,@livraison_conforme,@controle_livraison_conformite,@echant,@CQ,@nb_fichiers,@nb_actes,@rejets


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
