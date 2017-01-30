SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 11.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJTachesImagesLogsStatutsGen] 
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJTachesImagesLogsStatuts '1E0C01C4-24C6-41B3-915F-35BFED4985FB',1
	@id_projet UNIQUEIDENTIFIER
	,@id_tache INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IntegerResult INT
	
	BEGIN TRY
	BEGIN TRANSACTION spMAJTachesImagesLogsStatutsGen;
	
		-- vérifier la table Files si l'image existe réellement sur ​​v2 -> si pas défini un statut déplacés / copiés
		UPDATE Taches_Images_Logs
		SET id_status = 1
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN Files f WITH (NOLOCK) ON til.path_destination = f.FILE_PATH AND til.nom_fichier_image_destination = f.[FILE_NAME]
		WHERE i.id_projet = @id_projet
			AND id_tache = @id_tache

		UPDATE Taches_Images_Logs
		SET id_status = 2
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		WHERE i.id_projet = @id_projet AND til.id_status IS NULL
	
	COMMIT TRANSACTION spMAJTachesImagesLogsStatutsGen;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spMAJTachesImagesLogsStatutsGen;
		
		SET @IntegerResult = -1
		
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
