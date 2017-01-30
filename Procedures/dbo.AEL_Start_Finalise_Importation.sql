SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Start_Finalise_Importation] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_document UNIQUEIDENTIFIER, @id_association INT, @id_projet UNIQUEIDENTIFIER, @id_tache_log INT, @id_tache_log_details INT, @IntegerResult INT
	
	SELECT @id_document = id_document, @id_association = id_association, @id_projet = id_projet
	FROM AEL_Parametres 
	WHERE principal = 1 

	EXEC [192.168.0.138].Archives_Preprod.dbo.[finalize_importation] 
		@id_document = @id_document, @id_association = @id_association
	
END
GO
