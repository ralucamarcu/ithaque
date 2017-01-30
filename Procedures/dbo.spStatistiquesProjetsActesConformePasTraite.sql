SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesProjetsActesConformePasTraite]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    CREATE TABLE #tmp (moyenne_par_heure_derniere_semaine INT, moyenne_par_heure_derniere_mois INT)
    INSERT INTO #tmp
    EXEC [spStatistiquesMoyenneActesControlesParHeure] 
    
    DECLARE @moyenne_par_heure_derniere_semaine INT, @moyenne_par_heure_derniere_mois INT
    SELECT @moyenne_par_heure_derniere_semaine = moyenne_par_heure_derniere_semaine
		,@moyenne_par_heure_derniere_mois = moyenne_par_heure_derniere_mois
	FROM #tmp
    
	SELECT  p.nom, COUNT(da.id) AS nb_total_actes_conforme_pas_traite
		, COUNT(da.id) / @moyenne_par_heure_derniere_semaine AS nb_heures_estimee_moyenne_derniere_semaine
		, COUNT(da.id) / @moyenne_par_heure_derniere_mois AS nb_heures_estimee_moyenne_derniere_mois
	FROM DataXmlEchantillonEntete dee WITH (NOLOCK)
	INNER JOIN Traitements t WITH (NOLOCK) ON dee.id_traitement = t.id_traitement
	INNER JOIN Projets p WITH (NOLOCK) ON p.id_projet = t.id_projet
	INNER JOIN DataXml_lots_fichiers dlf WITH (NOLOCK) ON dee.id_lot = dlf.id_lot
	INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON dlf.id_lot = df.id_lot
	INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON df.id_fichier = da.id_fichier
	WHERE dee.id_traitement IN (SELECT id_traitement FROM Traitements WITH (NOLOCK)
				WHERE controle_livraison_conformite = 1 AND livraison_conforme = 1)
	AND dee.Traite = 0
	GROUP BY p.nom
	
	DROP TABLE #tmp
END
GO
