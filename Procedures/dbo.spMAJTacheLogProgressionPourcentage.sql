SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJTacheLogProgressionPourcentage]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_tache_log INT, @id_projet UNIQUEIDENTIFIER, @id_tache INT, @progression INT
	SET @id_projet = (SELECT id_projet FROM AEL_Parametres WHERE principal = 1)
	
	DECLARE cursor_1 CURSOR FOR
	SELECT tl.id_tache_log, tl.id_projet, tl.id_tache
	FROM Taches_Logs tl WITH (NOLOCK)
	INNER JOIN Taches_Logs_Details tld WITH (NOLOCK) ON tl.id_tache_log = tld.id_tache_log
	WHERE tl.id_projet = @id_projet AND tl.id_tache IN (12, 13, 15) 
	
	GROUP BY tl.id_tache_log, tl.id_projet, tl.id_tache
	OPEN cursor_1
	FETCH cursor_1 INTO @id_tache_log, @id_projet, @id_tache
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spMAJProgressionPourcentageImportImageImportationImage @id_projet, @id_tache, @progression OUTPUT 
		
		UPDATE Taches_Logs_Details
		SET progression_pourcentage = @progression
		FROM Taches_Logs_Details tld WITH (NOLOCK)
		INNER JOIN Taches_Logs tl WITH (NOLOCK) ON tld.id_tache_log = tl.id_tache_log
		WHERE tl.id_tache_log = @id_tache_log		
	
		FETCH cursor_1 INTO @id_tache_log, @id_projet, @id_tache
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
END
GO
