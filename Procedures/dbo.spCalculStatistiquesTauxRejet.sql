SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spCalculStatistiquesTauxRejet] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	TRUNCATE TABLE dbo.Statistiques_Taux_Rejet
	
	INSERT INTO dbo.Statistiques_Taux_Rejet (jour, mois, annee, nb_actes_controle)
	SELECT DAY(dee.date_creation) AS jour, MONTH(dee.date_creation) AS mois
	,YEAR(dee.date_creation) AS annee, COUNT(da.id) AS nb_actes_controle
	FROM DataXmlEchantillonEntete dee WITH (NOLOCK)
	INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON dee.id_lot = df.id_lot
	INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON df.id_fichier = da.id_fichier
	WHERE dee.date_creation > DATEADD(MONTH, -2, GETDATE())
		AND dee.traite = 1 AND dee.id_statut IN (1,2,3)
	GROUP BY DAY(dee.date_creation), MONTH(dee.date_creation),  YEAR(dee.date_creation)
	ORDER BY YEAR(dee.date_creation) DESC, MONTH(dee.date_creation) DESC,  DAY(dee.date_creation) DESC

	UPDATE dbo.Statistiques_Taux_Rejet
	SET nb_actes_rejetes = x.nb_actes_rejetes
	FROM dbo.Statistiques_Taux_Rejet t
	INNER JOIN 
	(SELECT DAY(dee.date_creation) AS jour, MONTH(dee.date_creation) AS mois
	,YEAR(dee.date_creation) AS anne, COUNT(da.id) AS nb_actes_rejetes
	FROM DataXmlEchantillonEntete dee WITH (NOLOCK)
	INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON dee.id_lot = df.id_lot
	INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON df.id_fichier = da.id_fichier
	WHERE dee.date_creation > DATEADD(MONTH, -2, GETDATE())
		AND dee.traite = 1 AND dee.id_statut = 2
	GROUP BY DAY(dee.date_creation), MONTH(dee.date_creation),  YEAR(dee.date_creation))
	x ON t.jour = x.jour AND t.mois = x.mois AND t.annee = x.anne
	
	UPDATE dbo.Statistiques_Taux_Rejet
	SET taux_rejet = nb_actes_rejetes/nb_actes_controle*100
END
GO
