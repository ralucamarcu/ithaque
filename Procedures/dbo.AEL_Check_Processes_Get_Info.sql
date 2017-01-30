SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 05.12.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Check_Processes_Get_Info]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF OBJECT_ID('AEL_Check_Processes_Running') IS NOT NULL 
		DROP TABLE AEL_Check_Processes_Running
	CREATE TABLE AEL_Check_Processes_Running (id INT IDENTITY(1,1) NOT NULL,RESULT NVARCHAR(MAX) NULL)
	
	INSERT INTO AEL_Check_Processes_Running (RESULT)
	EXEC xp_cmdshell 'type C:\Users\Administrateur\Desktop\raluca\outfile.txt'
	
	IF (SELECT COUNT(*) FROM AEL_Check_Processes_Running) > 0
	BEGIN
		EXEC xp_cmdshell 'del C:\Users\Administrateur\Desktop\raluca\outfile.txt'
	END
	
END
GO
