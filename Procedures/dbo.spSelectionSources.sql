SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 26.11.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionSources] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT s.id_source, s.nom_format_dossier, s.date_creation,  s.taille_dossier_GB, v.libelle, f.nom_fournisseur
		, p.nom AS nom_projet, p.id_projet, p.nom_projet_dossier
	FROM Sources s WITH (NOLOCK) 
	LEFT JOIN Sources_Projets sp WITH (NOLOCK) ON s.id_source = sp.id_source
	LEFT JOIN Projets p WITH (NOLOCK) ON sp.id_projet = p.id_projet
	LEFT JOIN Version_Processus_Statuts v WITH (NOLOCK) ON s.id_status_version_processus = v.id_status
	INNER JOIN Fournisseurs f WITH (NOLOCK) ON s.id_fournisseur = f.id_fournisseur
	ORDER BY s.nom_format_dossier ASC, s.date_creation DESC
END
GO
