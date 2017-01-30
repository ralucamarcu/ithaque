SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
--============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--testrun: [spInsertionTachesLogsTacheAFaireMAJSource]  '7759DB0D-3C83-43BD-A7FF-DF0B7BBC46E9'
CREATE PROCEDURE [dbo].[spInsertionTachesLogsTacheAFaireMAJSource] 
	@id_source uniqueidentifier
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @id_version int, @id_tache [uniqueidentifier], @IntegerResult int, @id_projet [uniqueidentifier], @chemin_dossier varchar(255)
	
	SELECT @id_version=s.id_status_version_processus
	FROM dbo.Sources s 
	WHERE id_source =@id_source

	CREATE TABLE  #temp_DirTree (id int identity,subdirectory varchar(500),depth int,[file] int )

		IF (@id_version = 0)
		BEGIN
			EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 1
		END
		IF (@id_version = 1)
		BEGIN
			EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 17
		END
		IF (@id_version = 2)
		BEGIN
			EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = NULL, @id_tache = 3
		END

		IF (@id_version = 3 )
		BEGIN
			SET @id_projet = (SELECT id_projet FROM dbo.Sources_Projets sp WHERE sp.id_source = @id_source)
			EXEC spInsertionTachesLogsTacheAFaire @id_source = @id_source, @id_projet = @id_projet, @id_tache = 4
		END

	DROP TABLE #temp_DirTree
END
GO
