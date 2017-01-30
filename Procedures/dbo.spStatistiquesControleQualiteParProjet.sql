SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteParProjet]
	-- Add the parameters for the stored procedure here
	-- Test Run : spStatistiquesControleQualiteParProjet '3871A253-F67C-43F0-B693-EF4D49F81440'
	 @id_projet UNIQUEIDENTIFIER 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @lots_controles INT, @lots_valides INT, @lots_rejetes INT, @tx_lots_rejetes FLOAT
		, @actes_controles INT, @livraisons INT, @actes_valides int, @actes_rejetes int, @tx_actes_rejetes float
		, @id int, @id_traitement int
	create table #tmp (id int not null identity(1,1) primary key, id_traitement int)
   	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER primary key, id_statut int)
   	CREATE TABLE #Statistiques_Controle_Projet
	(id_statistiques_controle_qualite_par_projet INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, sous_projet VARCHAR(255), livraison varchar(255), lots_controles INT, lots_valides INT, lots_rejetes INT
	, taux_lots_rejetes FLOAT, actes_controles INT, actes_valides int,lots_livres INT, actes_rejetes int, taux_actes_rejetes float,taux_lots_controles float,id_echantillon INT,id_traitement int)

	insert into #tmp (id_traitement)
	select id_traitement
	from Traitements with (nolock)
	where id_projet = @id_projet
	
	while EXISTS(select id_traitement from #tmp)
	begin
		select top 1 @id = id, @id_traitement = id_traitement
		from #tmp
		order by id
		
		INSERT INTO #tmp_lots_controles(id_lot, id_statut)
		SELECT DISTINCT dxee.id_lot, id_statut
		FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet and t.id_traitement = @id_traitement
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1
				
		SET @lots_controles = (SELECT COUNT(*) FROM #tmp_lots_controles)		
		SET @lots_valides = (SELECT COUNT(id_lot) from #tmp_lots_controles WHERE id_statut IN (1,3)	)
		SET @lots_rejetes = (SELECT COUNT(id_lot) FROM  #tmp_lots_controles WHERE id_statut = 2)		
		SET @tx_lots_rejetes = (CASE WHEN (ISNULL(@lots_rejetes, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejetes AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		SET @actes_controles = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier)
		SET @actes_valides = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
			WHERE id_statut IN (1,3))	
			
		SET @actes_rejetes = (SELECT COUNT(DISTINCT dxa.id) 
			FROM #tmp_lots_controles t
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxf.id_lot = t.id_lot
			INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK)ON dxa.id_fichier = dxf.id_fichier
			WHERE id_statut = 2)
		SET @tx_actes_rejetes = (CASE WHEN (ISNULL(@actes_rejetes, 0) <> 0 AND ISNULL(@actes_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@actes_rejetes AS FLOAT)/ CAST( @actes_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
		
		INSERT INTO #Statistiques_Controle_Projet (sous_projet, livraison, lots_controles, lots_valides, lots_rejetes
				, taux_lots_rejetes, actes_controles, actes_valides, actes_rejetes, lots_livres,taux_lots_controles, taux_actes_rejetes/*,id_echantillon*/,id_traitement)
		SELECT p.nom AS sous_projet, t.nom AS livraison, @lots_controles AS lots_controles, @lots_valides AS lots_valides
			, @lots_rejetes AS lots_rejetes, @tx_lots_rejetes AS taux_lots_rejetes
			, @actes_controles AS actes_controles, @actes_valides as actes_valides, @actes_rejetes as actes_rejetes
			,count(DISTINCT dxf.id_lot) AS lots_livres
			,(CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND COUNT(DISTINCT dxf.id_lot) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( COUNT(DISTINCT dxf.id_lot)  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END) AS taux_lots_controles
			, @tx_actes_rejetes as taux_actes_rejetes, t.id_traitement
		FROM Projets p WITH (NOLOCK)
		INNER JOIN Traitements t with (nolock) on t.id_projet = p.id_projet
		INNER JOIN DataXml_fichiers dxf with (nolock) ON dxf.id_traitement = t.id_traitement
		WHERE p.id_projet = @id_projet and t.id_traitement = @id_traitement
		GROUP BY  p.nom , t.nom  , t.id_traitement

				
		delete from #tmp where id = @id
		
		set @id = null
		set @id_traitement = null
		truncate table 	#tmp_lots_controles		
		
	end	
	SELECT * FROM #Statistiques_Controle_Projet order by sous_projet
	DROP TABLE #Statistiques_Controle_Projet
	DROP TABLE #tmp_lots_controles
	drop table #tmp
	   	
END
GO
