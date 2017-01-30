SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.01.2015
-- =============================================
CREATE PROCEDURE [dbo].[spMAJTacheLogDetailsTerminee] 
	-- Add the parameters for the stored procedure here
	 @id_tache_log_details INT
	,@id_status INT
	,@erreur_message VARCHAR(800) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @date DATETIME = GETDATE(), @IntegerResult INT
	BEGIN TRY
	BEGIN TRANSACTION [spMAJTacheLogTerminee];
		UPDATE dbo.Taches_Logs_Details
		SET id_status = @id_status
			,erreur_message = (CASE WHEN @erreur_message IS NOT NULL THEN @erreur_message ELSE erreur_message END)
			,date_fin = (CASE WHEN @id_status <> 3 THEN @date ELSE date_fin END)
		WHERE id_tache_log_details = @id_tache_log_details
	
	COMMIT TRANSACTION [spMAJTacheLogTerminee];
	
	SET @IntegerResult = 1 
	
	RETURN
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [spMAJTacheLogTerminee];
		
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
