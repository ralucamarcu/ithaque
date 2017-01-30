SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spInversionMAJTachesImagesLog 
	-- Add the parameters for the stored procedure here
	 @id_source UNIQUEIDENTIFIER
	,@id_tache INT
	,@id_utilisateur INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
    EXEC [dbo].[spInsertionTacheLog] 19, @id_utilisateur, @id_source, NULL, 'Ithaque App'
	SET @id_tache_log= (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
							WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
								AND id_tache = 19					
							ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
					
	BEGIN TRY
	BEGIN TRANSACTION [InversionProcess];
				
			
    
		IF @id_tache = 3
		BEGIN
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_destination = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_destination = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 3
		END
		
		IF @id_tache = 4
		BEGIN
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_destination = ii.nom_final
				, nom_fichier_image_origine = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_destination = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 4
			
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_origine = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_origine = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 5
		END
		
		IF @id_tache = 999
		BEGIN
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_destination = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_destination = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 3
			
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_destination = ii.nom_final
				, nom_fichier_image_origine = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_destination = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 4
			
			UPDATE Taches_Images_Logs
			SET nom_fichier_image_origine = ii.nom_final
			FROM Taches_Images_Logs tli WITH (NOLOCK)
			INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image
			INNER JOIN InversionInfo ii WITH (NOLOCK) ON tli.nom_fichier_image_origine = ii.nom_initial
			WHERE id_source = @id_source AND id_tache = 5
		END
	COMMIT TRANSACTION [InversionProcess];
		
	SET @IntegerResult = 1 
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [InversionProcess];
				
		SET @IntegerResult = -1
				
		SELECT @ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
		
		RAISERROR (@ErrorMessage,@ErrorSeverity, @ErrorState );
	END CATCH;
			
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResult = 1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL
		
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END

	
END
GO
