SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- test run: spMAJSources 'E9F85707-962F-40FE-B39A-601003A9694C',12
CREATE PROCEDURE spMAJSources 
	@id_source uniqueidentifier,
	@id_departement varchar(50) =NULL,
	@nom_departement varchar(255)= NULL,
	@id_fournisseur int= NULL,
	@taille_dossier_GB int =NULL,
	@nom_format_dossier varchar(255) =NULL,
	@chemin_dossier_general varchar(255) =NULL,
	@id_status_version_processus_complements int = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Sources
	SET id_departement= CASE WHEN @id_departement IS NULL THEN id_departement ELSE @id_departement END,
		nom_departement=CASE WHEN @nom_departement IS NULL THEN nom_departement ELSE @nom_departement END,
		id_fournisseur=CASE WHEN @id_fournisseur IS NULL THEN id_fournisseur ELSE @id_fournisseur END,
		taille_dossier_GB= CASE WHEN @taille_dossier_GB IS NULL THEN taille_dossier_GB ELSE @taille_dossier_GB END,
		date_modifications= GETDATE(),
		nom_format_dossier=CASE WHEN @nom_format_dossier IS NULL THEN nom_format_dossier ELSE @nom_format_dossier END,
		chemin_dossier_general =CASE WHEN @chemin_dossier_general IS NULL THEN chemin_dossier_general ELSE @chemin_dossier_general END,
		id_status_version_processus_complements=CASE WHEN @id_status_version_processus_complements IS NULL THEN id_status_version_processus_complements ELSE @id_status_version_processus_complements END
	WHERE id_source=@id_source

END
GO
