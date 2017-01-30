SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <20/08/2015,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spBackupV2_StartJobComparisonTailleDossier]
AS
BEGIN

	WAITFOR DELAY '0:0:10';
	
	EXEC msdb.dbo.sp_start_job 'BackupV2_ComparisonTailleDossier'

END
GO
