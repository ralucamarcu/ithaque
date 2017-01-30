SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 21.11.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteGeneral]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER, @id_identity INT, @nom_projet_maitre VARCHAR(255)
		,@lots_conformes INT,@actes_conformes INT
		,@lots_a_controler INT, @tx_lots_a_controler FLOAT, @lots_controles INT, @tx_lots_controles FLOAT
		,@lots_valides INT, @tx_lots_valides FLOAT, @lots_rejetes INT, @tx_lots_rejetes FLOAT
		,@actes_a_controler INT, @tx_actes_a_controler FLOAT, @actes_controles INT, @tx_actes_controles FLOAT
		,@actes_valides INT, @tx_actes_valides INT, @actes_rejetes INT, @tx_actes_rejetes FLOAT
   	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER PRIMARY KEY, id_statut INT)
   	IF OBJECT_ID('Statistiques_Controle_Qualite_General') IS NOT NULL 
		DROP TABLE Statistiques_Controle_Qualite_General
	CREATE TABLE Statistiques_Controle_Qualite_General 
	(id_statistiques_controle_qualite_general INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, nom_projet_maitre VARCHAR(255), lots_conformes INT, actes_conformes INT, lots_a_controler INT, taux_lots_a_controler FLOAT, lots_controles INT, taux_lots_controles FLOAT
	, lots_valides INT, taux_lots_valides FLOAT, lots_rejetes INT, taux_lots_rejetes FLOAT, actes_a_controler INT, taux_actes_a_controler FLOAT
	, actes_controles INT, taux_actes_controles FLOAT, actes_valides INT, taux_actes_valides INT, actes_rejetes INT, taux_actes_rejetes FLOAT)
	
	
	DECLARE cursor_1 CURSOR FOR
	SELECT pm.nom 
	FROM Projets_Maitres pm
	INNER JOIN Projets p ON pm.id_projet_maitre = p.id_projet_maitre
	GROUP BY pm.nom 
	OPEN cursor_1
	FETCH cursor_1 INTO @nom_projet_maitre
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @lots_conformes = (SELECT COUNT(DISTINCT dxf.id_lot) 
				FROM DataXml_fichiers dxf WITH (NOLOCK) 
				INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
				INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
				INNER JOIN Projets_Maitres pm WITH (NOLOCK) ON p.id_projet_maitre = pm.id_projet_maitre
				WHERE dxf.conforme = 1 AND pm.nom = @nom_projet_maitre)
		SET @actes_conformes = (SELECT COUNT(DISTINCT dxa.id) 
						FROM DataXmlRC_actes dxa WITH (NOLOCK)
						INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
						INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
						INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
						INNER JOIN Projets_Maitres pm WITH (NOLOCK) ON p.id_projet_maitre = pm.id_projet_maitre
						WHERE conforme = 1 AND pm.nom = @nom_projet_maitre)
						
		INSERT INTO #tmp_lots_controles(id_lot, id_statut)
		SELECT DISTINCT dxee.id_lot, dxee.id_statut
		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
		INNER JOIN Projets_Maitres pm WITH (NOLOCK) ON p.id_projet_maitre = pm.id_projet_maitre
		WHERE la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND pm.nom = @nom_projet_maitre
				
		SET @lots_controles = (SELECT COUNT(*) FROM #tmp_lots_controles)		
		SET @tx_lots_controles = (CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND ISNULL(@lots_conformes, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( @lots_conformes  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
		SET @lots_a_controler = @lots_conformes	- @lots_controles
		SET @tx_lots_a_controler = (CASE WHEN (ISNULL(@lots_a_controler, 0) <> 0 AND ISNULL(@lots_conformes, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_a_controler AS FLOAT)/ CAST( @lots_conformes  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	
		SET @lots_valides = (SELECT COUNT(id_lot) FROM #tmp_lots_controles WHERE id_statut IN (1,3)	)
		SET @tx_lots_valides = (CASE WHEN (ISNULL(@lots_valides, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_valides AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
		SET @lots_rejetes = (SELECT COUNT(id_lot) FROM  #tmp_lots_controles WHERE id_statut = 2)
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)

			
		SET @actes_controles = (SELECT COUNT(DISTINCT dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot)
		SET @actes_a_controler = @actes_conformes - @actes_controles
		
		SET @actes_valides = (SELECT COUNT(DISTINCT dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot
			WHERE id_statut IN (1,3))	
		
		SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN #tmp_lots_controles t ON dxf.id_lot = t.id_lot
			WHERE id_statut = 2)
		
		
		SET @tx_actes_controles = (CASE WHEN (ISNULL(@actes_controles, 0) <> 0 AND ISNULL(@actes_conformes, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_controles AS FLOAT)/ CAST( @actes_conformes  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		SET @tx_actes_a_controler = (CASE WHEN (ISNULL(@actes_a_controler, 0) <> 0 AND ISNULL(@actes_conformes, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_a_controler AS FLOAT)/ CAST( @actes_conformes  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)	
		SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		SET @tx_actes_valides = (CASE WHEN (ISNULL(@actes_valides, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_valides AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		
		INSERT INTO Statistiques_Controle_Qualite_General (nom_projet_maitre, lots_conformes, actes_conformes, lots_a_controler, taux_lots_a_controler
		, lots_controles, taux_lots_controles, lots_valides, taux_lots_valides, lots_rejetes, taux_lots_rejetes, actes_a_controler
		, taux_actes_a_controler, actes_controles, taux_actes_controles, actes_valides, taux_actes_valides, actes_rejetes, taux_actes_rejetes)
		SELECT @nom_projet_maitre AS nom_projet_maitre, @lots_conformes AS lots_conformes, @actes_conformes AS actes_conformes
			, @lots_a_controler AS lots_a_controler, @tx_lots_a_controler AS taux_lots_a_controler, @lots_controles AS lots_controles
			, @tx_lots_controles AS taux_lots_controles
			, @lots_valides AS lots_valides, @tx_lots_valides AS taux_lots_valides, @lots_rejetes AS lots_rejetes
			, @tx_lots_rejetes AS taux_lots_rejetes,  @actes_a_controler AS actes_a_controler
			, @tx_actes_a_controler AS taux_actes_a_controler, @actes_controles AS actes_controles, @tx_actes_controles AS taux_actes_controles
			, @actes_valides AS actes_valides, @tx_actes_valides AS taux_actes_valides, @actes_rejetes AS actes_rejetes
			, @tx_actes_rejetes AS taux_actes_rejetes
	FETCH cursor_1 INTO @nom_projet_maitre
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	DELETE FROM Statistiques_Controle_Qualite_General WHERE ISNULL(lots_conformes,0) = 0 AND ISNULL(actes_conformes,0) = 0
	   	
END


GO
