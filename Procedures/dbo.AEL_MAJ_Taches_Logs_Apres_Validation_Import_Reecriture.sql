SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE AEL_MAJ_Taches_Logs_Apres_Validation_Import_Reecriture
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE  @id_tache_log [int], @id_tache_log_details [int], @IntegerResult [int], @ErrorMessage NVARCHAR(4000);	
	DECLARE @tmp_valid TABLE (IntegerResult int)
	DECLARE @tmp_taches TABLE (id_tache_log int)

	INSERT INTO @tmp_taches (id_tache_log)
	EXEC AEL_Insertion_Tache_Log @id_tache = 27
	SET @id_tache_log = (SELECT top 1 id_tache_log FROM @tmp_taches)

	INSERT INTO @tmp_valid(IntegerResult)
	EXEC saisie_donnees_validations_info_importation_saisie

	SET @IntegerResult = (SELECT TOP 1 IntegerResult FROM @tmp_valid)

	IF (@IntegerResult = 0)
	BEGIN
		SET @ErrorMessage = 'Importer après réécriture n''a pas été complétée avec succès'
		EXEC [10.1.0.213].[Ithaque].[dbo].spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC [10.1.0.213].[Ithaque].[dbo].spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
END
GO
