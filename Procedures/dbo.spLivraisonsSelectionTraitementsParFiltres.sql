SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionTraitementsParFiltres] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spLivraisonsSelectionTraitementsParFiltres] '0A8314D6-E614-4E68-A7F1-DDD1F73454FD'
	 @id_projet UNIQUEIDENTIFIER = NULL
	,@statut INT = NULL
	,@date_livraison_debut DATETIME = NULL
	,@date_livraison_end DATETIME = NULL	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (@id_projet IS NOT NULL) AND (@statut IS NULL) AND (@date_livraison_debut IS NULL)
	BEGIN
		SELECT * FROM Traitements_Info  WITH (NOLOCK) WHERE id_projet = @id_projet
	END
	IF (@id_projet IS NULL) AND (@statut IS NOT NULL) AND (@date_livraison_debut IS NULL)
	BEGIN
		SELECT * FROM Traitements_Info  WITH (NOLOCK) WHERE statut = @statut
	END
	
	IF (@id_projet IS NULL) AND (@statut IS NULL) AND (@date_livraison_debut IS NOT NULL)
	BEGIN
		SELECT * FROM Traitements_Info  WITH (NOLOCK) WHERE date_livraison >= DATEADD(dd,0,DATEDIFF(dd,0,@date_livraison_debut))
						AND date_livraison <= DATEADD(dd,0,DATEDIFF(dd,0,@date_livraison_debut))
	END
	IF (@id_projet IS NOT NULL) AND (@statut IS NOT NULL) AND (@date_livraison_debut IS NULL)
	BEGIN
		SELECT * FROM Traitements_Info  WITH (NOLOCK) WHERE id_projet = @id_projet AND statut = @statut
	END
	IF (@id_projet IS NULL) AND (@statut IS NULL)AND (@date_livraison_debut IS NULL)
	BEGIN
		SELECT t.id_traitement as id_livraison, t.nom_projet as nom, t.date_livraison, ti.TYPE as type, ti.LivA_B as LivA_B, t.nom as description
			, ti.nb_fichiers as nb_fichiers, ti.nb_actes, ti.ImportCQ,t.objectif_effectif_min as [taille_lots_echantillonnage]
			,ti.nb_lots_rejetes, ti.avancement_controle, ti.nb_total_lots_livraison
			,t.date_retour_conformite_xml as [date_retour_conformite_xml],t.date_retour_cq [date_retour_cq]
			,t.date_reecriture, t.date_publication, null as [commentaire],t.id_projet, ti.[statut],t.date_verification_conformite as date_conforme
			,ti.nb_individus,ti.nb_images,ti.nb_naissances,ti.nb_mariages,ti.nb_deces,ti.nb_recensements,t.import_xml,t.livraison_annulee
		from Traitements t with (nolock) 
		left join Traitements_Info  ti WITH (NOLOCK) on t.id_traitement = ti.id_livraison
	END
	
END
GO
