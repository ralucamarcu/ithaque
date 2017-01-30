SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 13/03/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spAddEventLivraisonTraitement] 
	@id_traitement int,
	@id_type_evenement int,
	@id_utilisateur int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY

		--CREATION DE L'EVENEMENT DU TRAITEMENT
		INSERT INTO dbo.FichiersData_Evenements_Traitements (id_traitement, id_type_evenement, id_utilisateur)
		VALUES (@id_traitement, @id_type_evenement, @id_utilisateur)

		--CREATION D'UN EVENEMENT POUR CHACUN DES FichiersData DU TRAITEMENT
		INSERT INTO dbo.FichiersData_Evenements_Fichiers (id_fichier, id_type_evenement, id_utilisateur, id_statut, date_statut)
			SELECT id_FichierData, @id_type_evenement as id_type_evenement, @id_utilisateur as id_utilisateur, id_statut, date_statut 
			FROM dbo.DataXml_fichiers (NOLOCK) f
			INNER JOIN dbo.FichiersData (NOLOCK) fd ON fd.id_fichier=f.id_FichierData
			WHERE f.id_traitement=@id_traitement

	END TRY
	BEGIN CATCH
		SELECT 
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
	END CATCH;
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
	END
	RETURN 0    
END


GO
