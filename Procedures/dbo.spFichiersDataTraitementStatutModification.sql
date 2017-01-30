SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 25/02/2014
-- Description:	Met à jour le statut et l'utilisateur ayant changé le statut 
--				des FichiersData correspondant au DataXml_fichiers d'un traitement
-- =============================================
CREATE PROCEDURE [dbo].[spFichiersDataTraitementStatutModification]
	@id_traitement INT, 
	@id_statut INT,
	@id_utilisateur INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.FichiersData SET id_statut=@id_statut, statut_id_utilisateur=@id_utilisateur, date_statut=GETDATE()
	FROM dbo.FichiersData (NOLOCK) fd
	INNER JOIN dbo.DataXml_fichiers (NOLOCK) f ON f.id_FichierData=fd.id_fichier
	WHERE f.id_traitement=@id_traitement

END

GO
