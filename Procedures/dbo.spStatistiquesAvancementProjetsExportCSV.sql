SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesAvancementProjetsExportCSV]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT sai.nom_sous_projet, sai.nb_total_img_v4, sai.nb_img_livrees_par_prestataire, sai.pourcentage_img_livrees_v4_rapport
		, sai.nb_img_conforme, sai.pourcentage_img_conformite_v4_rapport, sai.nb_img_controlees, sai.pourcentage_img_controlees_v4_rapport
		, sai.nb_img_pas_controlees, sai.pourcentage_img_pas_controlees_v4_rapport
		, sai.nb_img_validees, sai.pourcentage_img_validees_v4_rapport, sai.nb_actes_valides, sad.nb_actes_pas_controles
		, sad.nb_individus_actes_valides, sad.nb_caracteres_actes_valides 
	FROM Statistiques_Avancement_Projets_Images sai WITH (NOLOCK)
	INNER JOIN Statistiques_Avancement_Projets_Details sad WITH (NOLOCK) ON sai.nom_sous_projet = sad.nom_sous_projet	
													AND sai.nb_total_img_v4 = sad.nb_total_img_v4	
END

GO
