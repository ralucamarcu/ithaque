SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteProjetParPeriode_v]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesControleQualiteProjetParPeriode] '2014-01-16', '2014-11-11'
	 @date_debut DATETIME 
	,@date_fin DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER, @lots_controles INT, @lots_valides INT, @lots_rejetes INT, @tx_lots_rejetes FLOAT
		,@actes_controles INT, @actes_valides INT, @actes_rejetes INT, @tx_actes_rejetes FLOAT, @id_identity INT
		,@lots_livres INT, @tx_lots_controles FLOAT
		,@actes_livres int, @tx_actes_controles float	
   	CREATE TABLE #tmp_lots_controles ( id_lot UNIQUEIDENTIFIER PRIMARY KEY, id_statut INT, id_traitement INT)
   	CREATE TABLE #Statistiques_Controle_Projet_Periode 
	(id_statistiques_controle_qualite_projet_periode INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, sous_projet VARCHAR(255), lots_livres INT, lots_controles INT, taux_lots_controles FLOAT, lots_valides INT, lots_rejetes INT, taux_lots_rejetes FLOAT
	, actes_livres int, actes_controles INT, taux_actes_controles float, actes_valides INT
	, actes_rejetes INT, taux_actes_rejetes FLOAT)
	CREATE TABLE #temo (id int identity, nb int)
--create table #temp_actes_controle (id_lot UNIQUEIDENTIFIER,id_acte int ,id_statut int)
--	CREATE TABLE #temp (id int identity primary key, id_lot UNIQUEIDENTIFIER PRIMARY KEY, id_statut INT, id_traitement INT,id_projet UNIQUEIDENTIFIER)
	
--	INSERT INTO #temp (id_lot,id_statut,id_traitement,id_projet) 
--	SELECT dxee.id_lot, dxee.id_statut,t.id_traitement,p.id_projet
--	FROM Traitements t with (nolock) on p.id_projet = t.id_projet
--	inner join DataXmlEchantillonEntete dxee WITH (NOLOCK) on t.id_traitement = dxee.id_traitement
--	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
--	where la.[action] = 'CocheEchantillonTraité'
--		AND la.id_type_objet = 1
--		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))
--	GROUP BY dxee.id_lot, dxee.id_statut,t.id_traitement,p.id_projet

--	CREATE INDEX IDX_temp ON #temp(id_projet)

	declare cursor_1 cursor FOR
	--SELECT id_projet FROM #temp
	--GROUP BY id_projet
	SELECT t.id_projet
	FROM-- projets p WITH (NOLOCK)
	 Traitements t with (nolock) 
	inner join DataXmlEchantillonEntete dxee WITH (NOLOCK) on t.id_traitement = dxee.id_traitement
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	where la.[action] = 'CocheEchantillonTraité'
		AND la.id_type_objet = 1
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))
	group by t.id_projet
	open cursor_1
	fetch cursor_1 into @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN

		--INSERT INTO #tmp_lots_controles(id_lot, id_statut,id_traitement)
		--SELECT id_lot, id_statut, id_traitement
		--FROM #temp
		--WHERE id_projet = @id_projet
		--GROUP BY id_lot, id_statut, id_traitement
		
		INSERT INTO #tmp_lots_controles(id_lot, id_statut,id_traitement)
		SELECT dxee.id_lot, dxee.id_statut,t.id_traitement
		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1
			AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))
		GROUP BY dxee.id_lot, dxee.id_statut,t.id_traitement
	
		
		SET @lots_livres = (SELECT COUNT(DISTINCT id_lot) FROM DataXml_fichiers WITH (NOLOCK)
						WHERE id_traitement IN (SELECT id_traitement FROM #tmp_lots_controles WITH (NOLOCK))
						and conforme = 1)

		SET @actes_livres = (SELECT COUNT(DISTINCT dxa.id) FROM DataXmlRC_actes dxa with (nolock)
						inner join DataXml_fichiers dxf WITH (NOLOCK) on dxa.id_fichier = dxf.id_fichier
						WHERE dxf.id_traitement IN (SELECT id_traitement FROM #tmp_lots_controles WITH (NOLOCK))
							and conforme = 1)
						
		SET @lots_controles = (SELECT COUNT(distinct id_lot) FROM #tmp_lots_controles)
		
		SET @tx_lots_controles = (CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND ISNULL(@lots_livres, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( @lots_livres  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	
		SET @lots_valides = (SELECT COUNT(DISTINCT id_lot) FROM #tmp_lots_controles WHERE id_statut IN (1,3))
		
		SET @lots_rejetes = (SELECT COUNT(DISTINCT id_lot) FROM  #tmp_lots_controles WHERE id_statut = 2)
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)

		--INSERT INTO #temp_actes_controle (id_lot,id_acte,id_statut)
		--SELECT t.id_lot,dxa.id,id_statut
		--FROM #tmp_lots_controles t  
		--INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
		--INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	

--INSERT INTO #temo (nb)
--SELECT COUNT(distinct dxa.id) 
--		FROM #tmp_lots_controles t  
--		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
--		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
--		WHERE id_statut IN (1,3)
--		OR id_statut=2

--SET @actes_valides = (SELECT TOP 1 nb FROM #temo t ORDER BY id)
--SET @actes_rejetes= (SELECT TOP 1 nb FROM #temo t ORDER BY id DESC)

		SET @actes_controles = (select COUNT(distinct dxa.id) 
		FROM #tmp_lots_controles t  
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier)
		
		SET @actes_valides = (SELECT COUNT(distinct dxa.id) 
		FROM #tmp_lots_controles t  
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		WHERE id_statut IN (1,3))	
		
		SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
		FROM #tmp_lots_controles t  
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
		INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		WHERE id_statut = 2)
			
		SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		SET @tx_actes_controles = (CASE WHEN (ISNULL(@actes_controles, 0) <> 0 AND ISNULL(@actes_livres, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_controles AS FLOAT)/ CAST( @actes_livres  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		IF (@lots_controles <> 0)
		BEGIN
			INSERT INTO #Statistiques_Controle_Projet_Periode (sous_projet, lots_livres, lots_controles, taux_lots_controles
				, lots_valides, lots_rejetes, taux_lots_rejetes, actes_livres, actes_controles, taux_actes_controles
				, actes_valides, actes_rejetes, taux_actes_rejetes)
			SELECT nom AS sous_projet, @lots_livres as lots_livres, @lots_controles AS lots_controles, @tx_lots_controles as taux_lots_controles
				, @lots_valides AS lots_valides, @lots_rejetes AS lots_rejetes, @tx_lots_rejetes AS taux_lots_rejetes
				, @actes_livres as actes_livres, @actes_controles AS actes_controles, @tx_actes_controles as taux_actes_controles
				, @actes_valides AS actes_valides, @actes_rejetes AS actes_rejetes
				, @tx_actes_rejetes AS taux_actes_rejetes 
			FROM Projets WITH (NOLOCK)
			WHERE id_projet = @id_projet 
		END
		
		TRUNCATE TABLE #tmp_lots_controles
	--	TRUNCATE TABLE #temo
		
		fetch cursor_1 into @id_projet
	END
	close cursor_1
	deallocate cursor_1

	
	--DELETE FROM #Statistiques_Controle_Projet_Periode WHERE lots_controles = 0
	SELECT * FROM #Statistiques_Controle_Projet_Periode
	DROP TABLE #Statistiques_Controle_Projet_Periode
	DROP TABLE #temp
	   	
END
GO
