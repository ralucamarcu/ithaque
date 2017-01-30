SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionParIdTraitement]
	-- Add the parameters for the stored procedure here
	--Test Run : spLivraisonsSelectionParIdTraitement 406
	@id_traitement INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @nb_lots_rejetes INT, @avancement_controle FLOAT, @nb_total_lots INT, @nb_lots_traites INT, @commentaire varchar(max) = ''
    CREATE TABLE #tmp (id_echantillon INT, id_statut INT, traite INT)
    
    SELECT @commentaire = '[' + CONVERT(VARCHAR(50),date_creation,3) + '] ' + commentaire + CHAR(10) + CHAR(13) + @commentaire 
    FROM Commentaires where id_objet = @id_traitement and type_objet = 'traitement' 
    
    INSERT INTO #tmp (id_echantillon, id_statut, traite)
    SELECT id_echantillon, id_statut, traite
    FROM DataXmlEchantillonEntete WITH (NOLOCK)
    WHERE id_traitement = @id_traitement
    
    SET @nb_lots_rejetes = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE id_statut = 2)
    SET @nb_total_lots = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK))
    SET @nb_lots_traites = (SELECT COUNT(id_echantillon) FROM #tmp WITH (NOLOCK) WHERE traite = 1)
    
    SET @avancement_controle = (CASE WHEN (ISNULL(@nb_lots_traites, 0) <> 0 AND ISNULL(@nb_total_lots, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_lots_traites AS FLOAT) / CAST( @nb_total_lots  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
    
	SELECT t.id_traitement AS id_livraison, p.nom, t.date_livraison, (CASE WHEN t.nom LIKE '%RP' THEN 'RP' ELSE 'EC' END) AS [TYPE]
		, type_livraison AS LivA_B 
		, t.nom AS [description], COUNT(DISTINCT dxf.id_fichier) AS nb_fichiers
		, COUNT(dxa.id) AS nb_actes, t.import_xml as ImportCQ
		, t.objectif_effectif_min AS taille_lots_echantillonnage, @nb_lots_rejetes AS nb_lots_rejetes
		, @avancement_controle AS avancement_controle, @nb_total_lots AS nb_total_lots_livraison
		, date_retour_conformite_xml, date_retour_cq, date_reecriture, date_publication
		, @commentaire as commentaire
	FROM Traitements t WITH (NOLOCK)
	INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
	LEFT JOIN DataXml_fichiers dxf WITH (NOLOCK) ON t.id_traitement = dxf.id_traitement
	LEFT JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxf.id_fichier = dxa.id_fichier
	WHERE t.id_traitement = @id_traitement
	GROUP BY t.id_traitement, p.nom, t.date_livraison, type_livraison, t.nom, t.import_xml, t.objectif_effectif_min
		, date_retour_conformite_xml, date_retour_cq, date_reecriture, date_publication
	
	
END
GO
