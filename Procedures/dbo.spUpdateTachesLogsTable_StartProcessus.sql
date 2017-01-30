SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spUpdateTachesLogsTable_StartProcessus
	
AS
BEGIN
	
	SET NOCOUNT ON;

    UPDATE [dbo].[Taches_Logs]
	SET [doit_etre_execute]=1
	WHERE id_status=4 and [doit_etre_execute]=0

END
GO
