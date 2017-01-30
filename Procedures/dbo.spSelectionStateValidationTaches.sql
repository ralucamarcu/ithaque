SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,> select * from ael_parametres where principal = 1
-- Description:	<Description,,> select * from taches
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionStateValidationTaches]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spSelectionStateValidationTaches] '3871A253-F67C-43F0-B693-EF4D49F81440', 12
	 @id_project UNIQUEIDENTIFIER
	,@id_tache INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @actif BIT = 0, @en_cours BIT = 0, @fait_success BIT = 0, @fait_erreur BIT = 0
		, @id_tache_log_main INT, @id_tache_precedent INT
	
	SET @id_tache_precedent = (SELECT id_precedent FROM Taches WHERE id_tache = @id_tache)
	
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = 10 AND id_status = 3) > 0
		AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache) = 0
		AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache_precedent AND id_status = 1) > 0
	BEGIN
		SET @actif = 1
	END
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = 10 AND id_status = 3) > 0
		AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache AND id_status = 3 AND date_fin IS NULL) > 0
	BEGIN
		SET @en_cours = 1
	END
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = 10 AND id_status = 3) > 0
		AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache AND id_status = 1 AND date_fin IS NOT NULL) > 0
	BEGIN
		SET @fait_success = 1
	END
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = 10 AND id_status = 3) > 0
		AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache AND id_status = 2 AND date_fin IS NOT NULL) > 0
	BEGIN
		SET @fait_erreur = 1
	END
	
	SELECT @actif AS Actif, @en_cours AS EnCours, @fait_success AS FaitSuccess, @fait_erreur AS FaitErreur
	
END


--select * from Taches_Logs where id_projet = '3871A253-F67C-43F0-B693-EF4D49F81440'

--EXEC [dbo].[spInsertionTacheLog] 12, 5, '85D79A20-2F1A-4E0F-BF4E-8F482CAFCE4D', NULL, 'Ithaque Application'
--EXEC [dbo].[spInsertionTacheLogDetails] 315
--EXEC dbo.spMAJTacheLogTerminee 315, 1, NULL, NULL
--EXEC dbo.spMAJTacheLogDetailsTerminee 92, 1, NULL


GO
