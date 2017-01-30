SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionStatusMETJobs] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	   
	IF EXISTS (SELECT * FROM Taches_Logs WITH (NOLOCK) WHERE id_tache = 10 AND id_status = 3 AND date_fin IS NULL)
	BEGIN
		SELECT 1 AS StatusRunning
	END
	ELSE
	BEGIN
		SELECT 0 AS StatusRunning
	END
END
GO
