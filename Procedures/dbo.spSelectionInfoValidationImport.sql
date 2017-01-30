SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.01.2015
-- Description:	IntegerResult = 0 => le tache ne peut pas etre faire , parce que la precedent n'a ete pas fait
--				IntegerResult = 1 => le tache peut etre faire , parce que la precedent a ete fait
--				IntegerResult = 2 => en cours
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionInfoValidationImport]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spSelectionInfoValidationImport] 'F32DA0D9-E06E-4A0D-8792-1728419433C7', null,1 
	 @id_source UNIQUEIDENTIFIER
	,@id_project UNIQUEIDENTIFIER = NULL
	,@id_tache INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IntegerResult INT, @id_parent_tache INT, @id_precedent_tache INT, @exists_log INT	
	
	SELECT @id_parent_tache = id_parent, @id_precedent_tache = id_precedent
	FROM Taches
	WHERE id_tache = @id_tache
	
	SET @exists_log = (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_tache = @id_precedent_tache 
		AND date_fin IS NOT NULL)

	-- un processus est en cours
	IF EXISTS (SELECT * FROM Taches_Logs WHERE id_status = 3 and id_tache in (1,2,3,7,9))
	BEGIN
		SELECT 2 AS IntegerResult
		RETURN
	END

	-- V1 Import validation
	IF ((@id_tache = 1) AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_source = @id_source AND id_tache = 1) > 0)
	BEGIN
		SELECT 0 AS IntegerResult
		RETURN
	END
	ELSE
	IF ((@id_tache = 1) AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_source = @id_source AND id_tache = 1) = 0)
	BEGIN
		SELECT 1 AS IntegerResult
		RETURN
	END
	
	
	-- V3 Import validation
	IF ((@id_tache = 3) AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_source = @id_source AND id_tache IN (2,7,9)
			AND date_fin IS NOT NULL) > 0)
	BEGIN
		SELECT 1 AS IntegerResult
		RETURN
	END
	ELSE
	IF ((@id_tache = 3) AND (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_source = @id_source AND id_tache IN (2,7,9)
			AND date_fin IS NOT NULL) < 0)
	BEGIN
		SELECT 0 AS IntegerResult
		RETURN
	END
	
	
	-- V2 Avant/Après/Import/Arborescence, V5 Import,V6 Import validations
	IF ((@id_tache IN (2,4,5,6,7,8,9,17)) AND @exists_log > 0)
	BEGIN
		SELECT 1 AS IntegerResult
		RETURN
	END
	ELSE
	IF ((@id_tache IN (2,4,5,6,7,8,9,17)) AND @exists_log < 0)
	BEGIN
		SELECT 0 AS IntegerResult
		RETURN
	END
	
	-- Mettre en Ligne Validation
	IF ((@id_tache = 10) AND @exists_log > 0)
	BEGIN
		SELECT 1 AS IntegerResult
		RETURN
	END
	ELSE
	IF ((@id_tache = 10) AND @exists_log < 0)
	BEGIN
		SELECT 0 AS IntegerResult
		RETURN
	END
	
	SELECT 0 AS IntegerResult
	
	
	

END
GO
