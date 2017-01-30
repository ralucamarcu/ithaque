SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualite_v]
	-- Add the parameters for the stored procedure here
AS
BEGIN

	SET NOCOUNT ON;
	
	  -- Insert statements for procedure here
 --  	IF OBJECT_ID('Statistiques_Controle_Qualite_Operateurs') IS NOT NULL 
	--	DROP TABLE Statistiques_Controle_Qualite_Operateurs
	--CREATE TABLE temp3 
	--(id_statistiques_controle_qualite_operateurs INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	--, id_utilisateur INT, operateur_nom VARCHAR(255), operateur_prenom VARCHAR(255), [DATE] DATETIME
	--, lots_controles INT, lots_valides INT, lots_rejetes INT, taux_lots_rejetes FLOAT, actes_controles INT
	--, actes_valides INT, actes_rejetes INT, taux_actes_rejetes FLOAT, actes_lus INT)
	 
	CREATE TABLE #temp_fichiers_actes_controle (id_lot UNIQUEIDENTIFIER, id_statut INT ,id_acte INT)   	

   	CREATE TABLE #tmp (id_utilisateur INT, [DATE] DATETIME)
   	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER, id_statut INT)
   	DECLARE @lots_controles INT, @lots_valides INT, @actes_controles INT, @lots_rejetes INT, @id_utilisateur INT
   		, @date DATETIME, @tx_lots_rejetes FLOAT, @actes_valides INT, @actes_rejetes INT, @tx_actes_rejetes FLOAT
   		, @actes_lus INT
	INSERT INTO #tmp
	SELECT id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log)) AS [DATE]
	FROM Logs_actions WITH (NOLOCK)
	WHERE [ACTION] = 'CocheEchantillonTraité'
	GROUP BY id_utilisateur , DATEADD(dd,00,DATEDIFF(dd, 0, date_log))

	--WHILE (SELECT COUNT(*) FROM #tmp) > 0
	WHILE EXISTS (SELECT id_utilisateur FROM #tmp t)
	BEGIN

		SELECT TOP 1 @id_utilisateur = id_utilisateur, @date = [DATE] 
		FROM #tmp 
		ORDER BY id_utilisateur
		
		INSERT INTO #tmp_lots_controles(id_lot, id_statut)
		SELECT DISTINCT dxee.id_lot, dxee.id_statut
		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		--INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE la.id_utilisateur = @id_utilisateur	
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1
			AND dxee.traite = 1
			AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date)))
		
				
		SET @lots_controles = (SELECT COUNT(id_lot) FROM #tmp_lots_controles)
		SET @lots_valides = (SELECT COUNT(t.id_lot) FROM #tmp_lots_controles t WHERE t.id_statut IN (1,3))
		SET @lots_rejetes = (SELECT COUNT(t.id_lot) FROM #tmp_lots_controles t WHERE id_statut = 2)
		SET @actes_controles = (SELECT COUNT(DISTINCT dxa.id) FROM #tmp_lots_controles t 
								INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
								INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier)
					
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
		SET @actes_valides = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t 
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
			WHERE t.id_statut IN (1,3))
			
		SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t 
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
			WHERE t.id_statut = 2)

		SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		SET @actes_lus = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t 
			INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxee.id_lot = t.id_lot
			INNER JOIN DataXmlEchantillonDetailsRC dxed WITH (NOLOCK) ON dxed.id_echantillon = dxee.id_echantillon
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxa.id = dxed.id_acte_RC
			WHERE dxed.traite = 1)

		INSERT INTO temp3 (id_utilisateur, operateur_nom, operateur_prenom, [DATE]
			, lots_controles, lots_valides, lots_rejetes, taux_lots_rejetes, actes_controles, actes_valides
			, actes_rejetes, taux_actes_rejetes, actes_lus)
		SELECT u.id_utilisateur, u.nom AS operateur_nom, u.prenom AS operateur_prenom, @date AS [DATE]
			 , @lots_controles AS lots_controles, @lots_valides AS lots_valides, @lots_rejetes AS lots_rejetes
			 , @tx_lots_rejetes AS taux_lots_rejetes, @actes_controles AS actes_controles, @actes_valides AS actes_valides
			 , @actes_rejetes AS actes_rejetes, @tx_actes_rejetes AS taux_actes_rejetes, @actes_lus AS actes_lus
		FROM Utilisateurs u WITH (NOLOCK) 
		WHERE u.id_utilisateur = @id_utilisateur
			
		DELETE FROM #tmp WHERE id_utilisateur = @id_utilisateur AND [DATE] = @date
		SET @id_utilisateur = NULL
		SET @date = NULL
		
TRUNCATE TABLE #tmp_lots_controles
TRUNCATE TABLE #temp_fichiers_actes_controle
	
	END
		
	DROP TABLE #tmp
	DROP TABLE #tmp_lots_controles
END

GO
