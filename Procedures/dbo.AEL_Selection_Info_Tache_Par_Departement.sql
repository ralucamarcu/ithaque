SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 14.01.2015
-- Description:	vérifier si un certain département, une tâche spécifique AEL a été exécuté
--			@IntegerResult = 0 -> la tâche n'a été pas exécuté pour cet département
--			@IntegerResult = 1 -> la tâche a été exécuté pour cet département
-- =============================================
CREATE PROCEDURE AEL_Selection_Info_Tache_Par_Departement
	-- Add the parameters for the stored procedure here
	-- Test Run: AEL_Selection_Info_Tache_Par_Departement 'RunningJobAELByDepartXMLImportationSaisie', '85fb4438-6e26-4419-94bf-3cabc3c241d3'
	 @job_name VARCHAR(255)
	,@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_document UNIQUEIDENTIFIER, @job_id UNIQUEIDENTIFIER
	SET @job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = @job_name)
	SET @id_document = (SELECT id_document FROM AEL_Parametres WITH (NOLOCK) WHERE id_projet = @id_projet)
	
	IF (@id_document IS NULL)
	BEGIN
		SELECT 0 AS IntegerResult
		RETURN
	END
	ELSE
	BEGIN
		IF (@job_name = 'AEL Traitement des Images')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
		
		IF (@job_name = 'AEL Traitement XML Finalize Importation')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
		
		IF (@job_name = 'AEL Finalisation Geonames')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
		
		IF (@job_name = 'AEL Traitement Images JP2000')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
		
		IF (@job_name = 'AEL Traitement des XML Importation Saisie')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
		
		IF (@job_name = 'AEL Traitement Images Zones')
		BEGIN
			IF (SELECT COUNT(*) FROM AEL_CommandLog WHERE job_id = @job_id AND id_document = @id_document) >0
			BEGIN
				SELECT 1 AS IntegerResult
				RETURN
			END
			ELSE
			BEGIN
				SELECT 0 AS IntegerResult
				RETURN
			END
		END
	END
	
	SELECT 0 AS IntegerResult
END
GO
