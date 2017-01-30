SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 22/02/2015
-- Description:	Renvoi la liste des fichiers livrés et appartenant à une livraison conforme XML et non annulée qui sont acceptés, en cours de contrôle ou pas encore contrôlés
-- =============================================
CREATE PROCEDURE [dbo].[spFichiersNonRejetes] 
	@id_projet UNIQUEIDENTIFIER, 
	@nom_fichier VARCHAR(250)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT /*TOP 1*/ fd.id_fichier as idFichiersData, fd.nom, f.id_fichier, t.id_traitement, t.nom as nom_livraison, t.date_livraison, ee.id_statut, se.libelle 
	FROM dbo.FichiersData fd with (nolock)
	INNER JOIN dbo.DataXml_fichiers f with (nolock) ON f.id_FichierData=fd.id_fichier
	INNER JOIN dbo.Traitements t with (nolock) ON f.id_traitement=t.id_traitement AND t.livraison_conforme=1 AND ISNULL(t.livraison_annulee,0)=0 --LIVRAISON CONFORME
	LEFT JOIN dbo.DataXml_lots_fichiers lf with (nolock) ON lf.id_lot=f.id_lot
	LEFT JOIN dbo.DataXmlEchantillonEntete ee with (nolock) ON ee.id_lot=lf.id_lot
	LEFT JOIN dbo.Statuts_Echantillons se with (nolock) ON se.id_statut=ee.id_statut
	WHERE fd.id_projet=@id_projet AND fd.nom=@nom_fichier
		AND (ee.id_statut in (1, 3, 4) OR ee.id_statut IS NULL) --ACCEPTE ou EN COURS DE CONTROLE ou PAS ENCORE CONTROLE
		AND ((f.ignore=0 OR f.ignore is null) AND (f.ignore_export_publication=0 OR f.ignore_export_publication is null)) --NON IGNORE
	order by t.date_livraison desc, t.id_traitement desc

END
GO
