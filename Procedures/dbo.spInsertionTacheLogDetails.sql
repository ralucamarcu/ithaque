SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.01.2015
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionTacheLogDetails] 
	-- Add the parameters for the stored procedure here
	@id_tache_log INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     -- Insert statements for procedure here
    DECLARE @date DATETIME = GETDATE(), @id_tache_log_details INT
    
    BEGIN TRY
	BEGIN TRANSACTION [spInsertionTacheLog];
		INSERT INTO dbo.Taches_Logs_Details( id_tache_log, id_status, date_debut)	
		VALUES (@id_tache_log, 3, @date)
		
		SET @id_tache_log_details = SCOPE_IDENTITY()
		
	COMMIT TRANSACTION [spInsertionTacheLog];
	
	SELECT @id_tache_log_details AS IntegerResult
	
	RETURN
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION [spInsertionTacheLog];
		
		SELECT -1 AS IntegerResult
		
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
