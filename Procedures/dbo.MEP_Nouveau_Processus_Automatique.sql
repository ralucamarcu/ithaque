SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE MEP_Nouveau_Processus_Automatique 
	-- Add the parameters for the stored procedure here
	@id_projet uniqueidentifier = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

    -- Insert statements for procedure here
    DECLARE @id_source uniqueidentifier, @id_tache int = 41, @id_utilisateur int = 12, @IntegerResult int
		, @machine_traitement varchar(150) = 'Ithaque BD', @id_tache_log int, @id_tache_log_details int
		
	IF (@id_projet IS NULL)
	BEGIN
		SET @id_projet = (SELECT p.id_projet FROM Projets p
						INNER JOIN Sources_Projets sp on p.id_projet = sp.id_projet
						INNER JOIN sources S on sp.id_source = s.id_source
						WHERE s.id_status_version_processus >= 4 and isnull(MEP, 0) = 0)
	END
	
	set @id_source = (SELECT id_source FROM Sources_Projets WHERE id_projet = @id_projet)
	
	EXEC [dbo].[spInsertionTacheLog] @id_tache, @id_utilisateur, @id_source, NULL, @machine_traitement--,@id_tache_log
	SET @id_tache_log = (SELECT TOP 1 id_tache_log FROM dbo.Taches_Logs WITH (NOLOCK)
					WHERE id_source = @id_source AND id_utilisateur = @id_utilisateur
						AND id_tache = 41					
					ORDER BY date_creation DESC)
	EXEC [dbo].[spInsertionTacheLogDetails] @id_tache_log
	SET @id_tache_log_details = (SELECT TOP 1 id_tache_log_details FROM dbo.Taches_Logs_Details WITH (NOLOCK)
					WHERE id_tache_log = @id_tache_log					
					ORDER BY date_debut DESC)
	PRINT @id_tache_log 
	
	BEGIN TRY
	BEGIN TRANSACTION MEP_Nouveau_Processus;
	
		EXEC [Ithaque_Reecriture].[dbo].[spReecritureTacheGeneral_nouveau] @id_projet = @id_projet
			,@id_utilisateur = 12
			,@machine_traitement = 'Ithaque App'
			
		EXEC [Ithaque_Reecriture].[dbo].[spImportPrepareImportationSaisieDB_nouveau]
			@nom_fichiers = NULL
			,@id_projet = @id_projet
			,@id_utilisateur = 12
			,@machine_traitement = 'Ithaque App'
	COMMIT TRANSACTION MEP_Nouveau_Processus;
	
	SET @IntegerResult = 1 
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION MEP_Nouveau_Processus;
		
		SET @IntegerResult = -1
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
	--si l'insertion d'images a terminé avec succès / erreur (IntegerResult = 1/-1), mettre à jour le log de tâche	
	IF (@IntegerResult = 1)
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 1, NULL, NULL
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 1, NULL		
		
		UPDATE Sources
		SET MEP = 1
		WHERE id_source = @id_source
	END
	ELSE
	BEGIN
		EXEC dbo.spMAJTacheLogTerminee @id_tache_log, 2, NULL, @ErrorMessage
		EXEC dbo.spMAJTacheLogDetailsTerminee @id_tache_log_details, 2, @ErrorMessage
	END
END
GO
