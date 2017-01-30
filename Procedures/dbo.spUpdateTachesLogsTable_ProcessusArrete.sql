SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateTachesLogsTable_ProcessusArrete]
	
AS
BEGIN
	
	SET NOCOUNT ON;

    UPDATE [dbo].[Taches_Logs]
	SET [doit_etre_execute]=0
	WHERE id_status=4 AND [doit_etre_execute]=1

END
GO
