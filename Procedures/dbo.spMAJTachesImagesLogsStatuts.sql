SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 11.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJTachesImagesLogsStatuts] 
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJTachesImagesLogsStatuts '1E0C01C4-24C6-41B3-915F-35BFED4985FB',1,2,3
	@id_source UNIQUEIDENTIFIER
	,@id_tache_v1 INT
	,@id_tache_v2 INT
	,@id_tache_v3 INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IntegerResult INT
	
	BEGIN TRY
	BEGIN TRANSACTION spMAJTachesImagesLogsStatuts;
		UPDATE Taches_Images_Logs
		SET path_destination = (CASE WHEN til.path_destination LIKE '%.jpg' THEN REPLACE(til.path_destination, til.nom_fichier_image_destination, '') 
			WHEN til.path_destination NOT LIKE '%\' THEN path_destination + '\'
			ELSE path_destination END)
			,path_origine = (CASE WHEN til.path_origine LIKE '%.jpg' THEN REPLACE(til.path_origine, til.nom_fichier_image_origine, '') 
			WHEN til.path_origine NOT LIKE '%\' THEN til.path_origine
			ELSE til.path_origine END)
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		WHERE id_source = @id_source
			AND (til.path_destination LIKE '%.jpg' OR til.path_origine LIKE '%.jpg')
			
		-- vérifier la table Files si l'image existe réellement sur ​​v2 -> si pas défini un statut déplacés / copiés
		UPDATE Taches_Images_Logs
		SET id_status = 1
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN Files f WITH (NOLOCK) ON til.path_origine = f.FILE_PATH AND til.nom_fichier_image_origine = f.[FILE_NAME]
		WHERE id_source = @id_source
			AND id_tache = @id_tache_v1
			AND til.id_status IS NULL

		UPDATE Taches_Images_Logs
		SET id_status = 1
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN Files f WITH (NOLOCK) ON til.path_destination = f.FILE_PATH AND til.nom_fichier_image_destination = f.[FILE_NAME]
		WHERE id_source = @id_source
			AND ((id_tache = @id_tache_v2 AND path_destination NOT LIKE '%DUPLICATEDIMAGES%')
				OR (id_tache = @id_tache_v2 AND path_destination LIKE '%DUPLICATEDIMAGES%'))
			AND til.id_status IS NULL

		UPDATE Taches_Images_Logs
		SET id_status = 1
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		INNER JOIN Files f WITH (NOLOCK) ON til.path_destination = f.FILE_PATH AND til.nom_fichier_image_destination = f.[FILE_NAME]
		WHERE id_source = @id_source
			AND ((id_tache = @id_tache_v3 AND TIL.path_origine NOT LIKE '%DUPLICATEDIMAGES%')
				OR (id_tache = @id_tache_v3 AND til.path_origine LIKE '%DUPLICATEDIMAGES%'))
			AND til.id_status IS NULL
			
		UPDATE Taches_Images_Logs
		SET id_status = 2
		FROM Taches_Images_Logs til WITH (NOLOCK)
		INNER JOIN Images i WITH (NOLOCK) ON til.id_image = i.id_image
		WHERE id_source = @id_source AND til.id_status IS NULL
	
	COMMIT TRANSACTION spMAJTachesImagesLogsStatuts;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spMAJTachesImagesLogsStatuts;
		
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
