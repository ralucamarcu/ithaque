SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteProjetParPeriode_v2]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesControleQualiteProjetParPeriode_v2] '01-02-2014', '01-12-2014'
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
	--CREATE TABLE #tmp (id_identity INT IDENTITY(1,1), id_projet UNIQUEIDENTIFIER)
   	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER PRIMARY KEY, id_statut INT)
   	--CREATE TABLE #tmp_lots_valides (id_lot UNIQUEIDENTIFIER PRIMARY KEY)
   	CREATE TABLE #Statistiques_Controle_Projet_Periode 
	(id_statistiques_controle_qualite_projet_periode INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, sous_projet VARCHAR(255), lots_livres INT, lots_controles INT, taux_lots_controles FLOAT, lots_valides INT, lots_rejetes INT, taux_lots_rejetes FLOAT
	, actes_livres int, actes_controles INT, taux_actes_controles float, actes_valides INT
	, actes_rejetes INT, taux_actes_rejetes FLOAT)
	
	declare cursor_1 cursor for
	SELECT p.id_projet
	FROM projets p WITH (NOLOCK)
	inner join Traitements t with (nolock) on p.id_projet = t.id_projet
	inner join DataXmlEchantillonEntete dxee WITH (NOLOCK) on t.id_traitement = dxee.id_traitement
	INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
	where la.[action] = 'CocheEchantillonTraité'
		AND la.id_type_objet = 1
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))
	group by p.id_projet
	open cursor_1
	fetch cursor_1 into @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @lots_livres = (SELECT COUNT(DISTINCT id_lot) FROM DataXml_fichiers WITH (NOLOCK)
						WHERE id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet)
						and conforme = 1)
		set @actes_livres = (SELECT COUNT(DISTINCT dxa.id) 
						FROM DataXmlRC_actes dxa with (nolock)
						inner join DataXml_fichiers dxf WITH (NOLOCK) on dxa.id_fichier = dxf.id_fichier
						WHERE dxf.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet)
							and conforme = 1)
						
		INSERT INTO #tmp_lots_controles(id_lot, id_statut)
		SELECT DISTINCT dxee.id_lot, dxee.id_statut
		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1
			AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))		
		SET @lots_controles = (SELECT COUNT(*) FROM #tmp_lots_controles)
		
		SET @tx_lots_controles = (CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND ISNULL(@lots_livres, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( @lots_livres  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	
		SET @lots_valides = (SELECT COUNT(id_lot) FROM #tmp_lots_controles WHERE id_statut IN (1,3)	)
		
		SET @lots_rejetes = (SELECT COUNT(id_lot) FROM  #tmp_lots_controles WHERE id_statut = 2)
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)

			
		SET @actes_controles = (select COUNT(distinct dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot)
		
		SET @actes_valides = (SELECT COUNT(distinct dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot
			WHERE id_statut IN (1,3))	
		
		SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot
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
		--TRUNCATE TABLE #tmp_lots_valides
				
		
		fetch cursor_1 into @id_projet
	END
	close cursor_1
	deallocate cursor_1

	
	--DELETE FROM #Statistiques_Controle_Projet_Periode WHERE lots_controles = 0
	SELECT * FROM #Statistiques_Controle_Projet_Periode
	DROP TABLE #Statistiques_Controle_Projet_Periode
	   	
END
GO
