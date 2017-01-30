SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spTachesLogsInsertionTachesLogAFaireEnAttent]
	
AS
BEGIN
	
	SET NOCOUNT ON;

   EXEC msdb.dbo.sp_start_job N'Insertion Taches Log A Faire En Attent'

  
END
GO
