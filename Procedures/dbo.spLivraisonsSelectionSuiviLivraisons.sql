SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionSuiviLivraisons]
	-- Add the parameters for the stored procedure here
	 @annulee bit = 0
	,@termine bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF (@annulee =0 AND @termine=0)
	BEGIN 
    -- Insert statements for procedure here
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, t.date_retour_conformite_xml, t.date_retour_cq  ,ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM Traitements t WITH (NOLOCK)
	left join LivraisonsSuivi ls with (nolock) on ls.id_livraison = t.id_traitement
	where t.date_retour_cq IS NULL AND isnull(t.livraison_annulee,0) = 0
	END
	
	IF (@annulee =0 AND @termine=1)
	BEGIN 
    -- Insert statements for procedure here
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, t.date_retour_conformite_xml, t.date_retour_cq , ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM Traitements t WITH (NOLOCK)
	left join LivraisonsSuivi ls with (nolock) on ls.id_livraison = t.id_traitement
	where isnull(t.livraison_annulee,0) = 0
	END
	
	IF (@annulee =1 AND @termine=0)
	BEGIN 
    -- Insert statements for procedure here
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, t.date_retour_conformite_xml, t.date_retour_cq , ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM Traitements t  WITH (NOLOCK)
	left join LivraisonsSuivi ls with (nolock) on ls.id_livraison = t.id_traitement
	where (t.date_retour_cq IS NULL)
	END
	
	

	/*IF (@annulee =1 AND @termine=1)
	BEGIN 
    -- Insert statements for procedure here
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM LivraisonsSuivi ls WITH (NOLOCK)
	left join Traitements t with (nolock) on ls.id_livraison = t.id_traitement
	where t.livraison_annulee = @annulee 
	END


	IF (@termine=1)
	BEGIN
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM LivraisonsSuivi ls WITH (NOLOCK)
	left join Traitements t with (nolock) on ls.id_livraison = t.id_traitement
	where t.date_retour_cq IS NOT NULL
	END

	IF (@termine=0)
	BEGIN
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM LivraisonsSuivi ls WITH (NOLOCK)
	left join Traitements t with (nolock) on ls.id_livraison = t.id_traitement
	where t.date_retour_cq IS NULL
	END*/

	IF (@annulee =1 AND @termine=1)
	BEGIN
	SELECT ls.id_livraisons_suivi, t.id_traitement as id_livraison, t.nom as nom_livraisons, t.date_livraison as date_livraisons, ls.nom_projet
		, t.type_livraison as type_livraisons, ls.a_traiter, t.controle_livraison_conformite AS conformity, t.livraison_conforme AS valide
		, t.import_xml as import_cq, t.date_retour_conformite_xml, t.date_retour_cq , ls.echantill, ls.avancement_controle, ls.nb_fichiers, ls.nb_actes, ls.rejetess
		, ls.nb_actes_naissance, ls.nb_actes_mariage, ls.nb_actes_deces , t.livraison_annulee
	FROM Traitements t WITH (NOLOCK)
	left join LivraisonsSuivi ls with (nolock) on ls.id_livraison = t.id_traitement
	/*where t.date_retour_cq IS NOT NULL AND t.livraison_annulee = @annulee */
	END

END
GO
