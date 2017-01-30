SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 07.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesActesGeneralParProjet]
	-- Add the parameters for the stored procedure here
	-- Test Run : spStatistiquesActesGeneralParProjet '3871A253-F67C-43F0-B693-EF4D49F81440'
	@id_project UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @lots_recus INT, @actes_recus INT, @lots_controles INT, @actes_controles INT, @avancement_pourcentage FLOAT, @lots_rejet INT, @tx_rejet_pourcentage FLOAT
		
	SET @lots_recus = (SELECT COUNT(id_lot) FROM DataXml_lots_fichiers WHERE id_traitement 
	IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project))
	
	SET @actes_recus = (SELECT COUNT(dxa.id) FROM DataXmlRC_actes dxa WITH (NOLOCK) 
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	INNER JOIN DataXml_lots_fichiers dlf WITH (NOLOCK) ON dxf.id_lot = dlf.id_lot
	WHERE dlf.id_traitement 
	IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project))
	
	SET @lots_controles = (SELECT COUNT(dxee.id_lot) 
		FROM  dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) 
	WHERE dxee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)	
		AND dxee.traite = 1)
		
	SET @actes_controles = (SELECT COUNT(dxa.id) FROM DataXmlRC_actes dxa WITH (NOLOCK) 
	INNER JOIN  DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	INNER JOIN dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	WHERE dxee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)	
		AND dxee.traite = 1)
	
	SET @lots_rejet = (SELECT COUNT(dxee.id_lot) 
		FROM  dbo.DataXmlEchantillonEntete dxee WITH (NOLOCK) 
	WHERE dxee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK) WHERE id_projet = @id_project)	
		AND dxee.traite = 1 AND id_statut = 2)
	
	--SET @avancement_pourcentage = CAST(CAST(CAST(@lots_rejet AS FLOAT)/CAST(@lots_controles AS FLOAT) AS FLOAT) * 100 AS FLOAT)
	--SET @tx_rejet_pourcentage = CAST(CAST(CAST(@lots_controles AS FLOAT)/CAST(@lots_recus AS FLOAT) AS FLOAT) * 100 AS FLOAT)
	SET @tx_rejet_pourcentage = (CASE WHEN (ISNULL(@lots_rejet, 0) <> 0 AND ISNULL(@lots_controles, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_rejet AS FLOAT)/ CAST( @lots_controles  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	SET @avancement_pourcentage =  (CASE WHEN (ISNULL(@lots_controles, 0) <> 0 AND ISNULL(@lots_recus, 0) <> 0 )
			THEN CAST(CAST(CAST(@lots_controles AS FLOAT)/ CAST( @lots_recus  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
	
	SELECT pm.nom AS projet, p.nom AS [sous-projet], pt.nom AS prestataire, @lots_recus AS lots_recus, @actes_recus AS actes_recus
		, @lots_controles AS lots_controles, @actes_controles AS actes_controles, @avancement_pourcentage AS avancement_pourcentage
		, @lots_rejet AS lots_rejet, @tx_rejet_pourcentage AS tx_rejet_pourcentage
	FROM Projets p WITH (NOLOCK)
	INNER JOIN Projets_Maitres pm WITH (NOLOCK) ON p.id_projet_maitre = pm.id_projet_maitre
	INNER JOIN Prestataires pt WITH (NOLOCK) ON pm.id_prestataire = pt.id_prestataire
	WHERE p.id_projet = @id_project
END
GO
