SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionSourceParId] 
	-- Add the parameters for the stored procedure here
	@id_source UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT s.id_source, s.id_departement, s.nom_departement, s.nom_format_dossier
		, p.id_projet, p.date_creation AS date_creation_projet
		, s.date_creation	
		, s.taille_dossier_GB, v.libelle, f.nom_fournisseur	 
		, p.nom AS nom_projet, p.nom_projet_dossier
		, p.chemin_dossier_general AS chemin_projet
	FROM Sources s
	INNER JOIN Sources_Projets sp WITH (NOLOCK) ON s.id_source = sp.id_source
	INNER JOIN Projets p WITH (NOLOCK) ON sp.id_projet = p.id_projet
	LEFT JOIN Version_Processus_Statuts v WITH (NOLOCK) ON s.id_status_version_processus = v.id_status
	INNER JOIN Fournisseurs f WITH (NOLOCK) ON s.id_fournisseur = f.id_fournisseur
	WHERE s.id_source = @id_source
END
GO
