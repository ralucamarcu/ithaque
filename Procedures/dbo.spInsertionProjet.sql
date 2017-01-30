SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 09.01.2015
-- Description:	insérer une nouveau projet dans la base de données(v4)
--				12-test125756-TD
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionProjet] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spInsertionProjet] 'E9F85707-962F-40FE-B39A-601003A9694C', '43DCD200-3D23-47DE-BE93-5A795B2922B1', 1, 2, 6.5, 100
	 @id_source UNIQUEIDENTIFIER
	,@id_projet_maitre UNIQUEIDENTIFIER
	,@id_effectif_lot INT
	,@objectif_effectif_min BIGINT
	,@NQA FLOAT
	,@taille_dossier_GB INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here

    DECLARE @date DATETIME = GETDATE(), @id_projet  UNIQUEIDENTIFIER, @nom_projet_maitre VARCHAR(255)
    CREATE TABLE #tmp (id_projet UNIQUEIDENTIFIER)

    SET @nom_projet_maitre = (SELECT nom FROM Projets_Maitres WHERE id_projet_maitre = @id_projet_maitre)
 
    BEGIN TRY
	BEGIN TRANSACTION spInsertionProjet;
	
		INSERT INTO dbo.Projets (nom, infos, date_creation, id_effectif_lot, objectif_effectif_min , NQA, id_projet_maitre, id_departement
			, nom_departement, nom_projet_dossier, taille_dossier_GB, chemin_dossier_general)
		OUTPUT inserted.id_projet
		INTO #tmp
		SELECT @nom_projet_maitre + '-' + id_departement AS nom, nom_format_dossier AS infos, @date AS date_creation
			, @id_effectif_lot AS id_effectif_lot, @objectif_effectif_min AS objectif_effectif_min, @NQA AS NQA
			, @id_projet_maitre AS id_projet_maitre, id_departement, nom_departement, @nom_projet_maitre + '-' + nom_format_dossier AS nom_projet_dossier
			, @taille_dossier_GB AS taille_dossier_GB
			, '\\10.1.0.196\bigvol\Projets\' + @nom_projet_maitre + '-' + nom_format_dossier + '\' AS chemin_dossier_general
		FROM Sources
		WHERE id_source = @id_source
		SET @id_projet = (SELECT id_projet FROM #tmp)		
		
		
		INSERT INTO dbo.Sources_Projets (id_projet, id_source)
		VALUES (@id_projet, @id_source)

	COMMIT TRANSACTION spInsertionProjet;
--	RETURN
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spInsertionProjet;
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
END

GO
