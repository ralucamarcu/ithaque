SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteProjetParPeriode_v1]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesControleQualiteProjetParPeriode_v1] '01-01-2014', '01-12-2014'
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
		,@lots_livres INT, @tx_lots_controles FLOAT, @actes_livres int, @tx_actes_controles float
	CREATE TABLE #tmp (id_identity INT IDENTITY(1,1), id_projet UNIQUEIDENTIFIER)
	create table #tmp_actes_livres(id_identity INT IDENTITY(1,1) primary key, id_acte int, id_fichier uniqueidentifier
		, id_lot uniqueidentifier, id_statut int, id_echantillon int)
	
   	CREATE TABLE #Statistiques_Controle_Projet_Periode 
	(id_statistiques_controle_qualite_projet_periode INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, sous_projet VARCHAR(255), lots_livres INT, lots_controles INT, taux_lots_controles FLOAT, lots_valides INT, lots_rejetes INT, taux_lots_rejetes FLOAT
	, actes_livres int, actes_controles INT, taux_actes_controles FLOAT, actes_valides INT, actes_rejetes INT, taux_actes_rejetes FLOAT)

	INSERT INTO #tmp (id_projet)
	SELECT DISTINCT p.id_projet
	FROM projets p WITH (NOLOCK)
	
	WHILE (SELECT COUNT(*) FROM #tmp) > 0
	BEGIN
		SELECT TOP 1 @id_identity = id_identity, @id_projet = id_projet
		FROM #tmp
		ORDER BY id_identity
		
		insert into #tmp_actes_livres (id_acte, id_fichier, id_lot, id_statut, id_echantillon)
		select dxa.id as id_acte, dxf.id_fichier as id_fichier, dxf.id_lot, dxee.id_statut, dxee.id_echantillon
		from DataXmlRC_actes dxa with (nolock)
		inner join DataXml_fichiers dxf with (nolock) on dxa.id_fichier = dxf.id_fichier
		left join DataXmlEchantillonEntete dxee with (nolock) on dxf.id_lot = dxee.id_lot
		where dxf.id_traitement in (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_projet)
			and dxf.conforme = 1
		group by dxa.id , dxf.id_fichier, dxf.id_lot, dxee.id_statut, dxee.id_echantillon
		
		SET @lots_livres = (SELECT COUNT(DISTINCT id_lot) FROM #tmp_actes_livres)
		SELECT @lots_controles = COUNT(DISTINCT id_lot), @actes_controles = COUNT(DISTINCT id_acte)
		FROM #tmp_actes_livres t 
		inner join Logs_actions la WITH (NOLOCK) ON t.id_echantillon = la.id_objet
		where la.[action] = 'CocheEchantillonTraité'
		AND la.id_type_objet = 1
		AND (date_log >= DATEADD(dd,00,DATEDIFF(dd, 0, @date_debut)) AND date_log < DATEADD(dd,1,DATEDIFF(dd, 0, @date_fin)))		
		
		SET @tx_lots_controles = (CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND ISNULL(@lots_livres, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( @lots_livres  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	
		SELECT @lots_valides = COUNT(DISTINCT id_lot), @actes_valides = COUNT(distinct id_acte)
		FROM #tmp_actes_livres WHERE id_statut IN (1,3)
				
		SELECT @lots_rejetes = COUNT(DISTINCT id_lot), @actes_rejetes = COUNT(distinct id_acte)
		FROM #tmp_actes_livres WHERE id_statut = 2
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		SET @actes_livres = (select COUNT(distinct id_acte) from #tmp_actes_livres)
		
		SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		IF (@lots_controles <> 0)
		BEGIN
			INSERT INTO #Statistiques_Controle_Projet_Periode (sous_projet, lots_livres, lots_controles, taux_lots_controles
				, lots_valides, lots_rejetes, taux_lots_rejetes, actes_livres, actes_controles, taux_actes_controles, actes_valides
				, actes_rejetes, taux_actes_rejetes)
			SELECT nom AS sous_projet, @lots_livres as lots_livres, @lots_controles AS lots_controles, @tx_lots_controles as taux_lots_controles
				, @lots_valides AS lots_valides, @lots_rejetes AS lots_rejetes, @tx_lots_rejetes AS taux_lots_rejetes
				, @actes_livres as actes_livres, @actes_controles AS actes_controles, @tx_actes_controles as taux_actes_controles
				, @actes_valides AS actes_valides, @actes_rejetes AS actes_rejetes, @tx_actes_rejetes AS taux_actes_rejetes 
			FROM Projets WITH (NOLOCK)
			WHERE id_projet = @id_projet 
		END
		
		TRUNCATE TABLE #tmp_actes_livres
				
		
		DELETE FROM #tmp WHERE id_identity = @id_identity AND id_projet = @id_projet
		SET @id_identity = NULL
		SET @id_projet = NULL		
	END

	
	--DELETE FROM #Statistiques_Controle_Projet_Periode WHERE lots_controles = 0
	SELECT * FROM #Statistiques_Controle_Projet_Periode
	DROP TABLE #Statistiques_Controle_Projet_Periode
	drop table #tmp_actes_livres
	   	
END
GO
