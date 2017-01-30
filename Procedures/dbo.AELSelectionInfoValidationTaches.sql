SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 20.01.2015
-- Description:	@precedent_validation = 1 => le processus précédent a fini, ok pour commencer
--				@precedent_validation = 0 => le processus précédent n'a pas fini, pas ok pour commencer

--				@running_process = 1 => le processus current est en cours
--				@running_process = 0 => le processus current n'est pas en cours

--				@ael_main_running = 1 => le processus parent de Mettre en ligne pour cet projet est en cours
--				@ael_main_running = 0 => le processus parent de Mettre en ligne pour cet projet n'est pas en cours

--				@tache_en_cours_depart_current = 0 => un processus AEL est en cours d'exécution, mais pas pour l'actuel département
--				@tache_en_cours_depart_current = 1 => un processus AEL est en cours d'exécution, pour l'actuel département
--				@tache_en_cours_depart_current = 2 => un autre processus est en cours d'exécution
--								, mais pas AEL/ou AEL jpg2000/zonage/ImportationSaisie -> ignorer

--				@ael_tache_status = 0 => AEL Tache, pour l'actuel département, pas encore fait
--				@ael_tache_status = 1 => AEL Tache, pour l'actuel département, déjà fait, terminé avec success
--				@ael_tache_status = 2 =>  AEL Tache, pour l'actuel département, est en cours
--				@ael_tache_status = 3 => AEL Tache, pour l'actuel département, terminé avec une erreur

--				lorsque la page principale se ouvre, pour les processus AEL, pour un certain département
--				, vérifiez s'il ya un processus en cours d'exécution, pour ce département ou pour une autre
-- =============================================
CREATE PROCEDURE AELSelectionInfoValidationTaches 
	-- Add the parameters for the stored procedure here
	-- Test Run: AELSelectionInfoValidationTaches '{85fb4438-6e26-4419-94bf-3cabc3c241d3}', 15
	 @id_project UNIQUEIDENTIFIER
	,@id_tache INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	-- Archives en Ligne Processus validations
	DECLARE @precedent_validation INT = 0, @parent_validation BIT, @ael_main_running INT = 0
		,@id_parent_tache INT, @id_precedent_tache INT, @exists_log INT, @id_tache_en_cours INT, @id_projet_tache_en_cours	UNIQUEIDENTIFIER
		,@tache_en_cours_depart_current INT = 0, @ael_tache_status INT = 0, @id_tache_ael_main INT, @date_debut_ael_main DATETIME
	
	--vérifier s'il y a un processus en cours
	SELECT TOP 1 @id_tache_en_cours = id_tache, @id_projet_tache_en_cours = id_projet
	FROM Taches_Logs tl
	INNER JOIN Taches_Logs_Details tld ON tl.id_tache_log = tld.id_tache_log
	WHERE tld.id_status = 3 AND tld.date_fin IS NULL	
		AND tl.id_projet = @id_project AND tl.id_tache IN (10,11,12,13,14,15,16)
	ORDER BY tld.date_debut DESC
	
	IF (@id_tache_en_cours IN (11,12,13,14,15,16)) AND @id_projet_tache_en_cours = @id_project
	BEGIN
		SET @tache_en_cours_depart_current = 1
	END
	IF (@id_tache_en_cours IN (12,13,15)) AND @id_projet_tache_en_cours = @id_project
	BEGIN
		SET @tache_en_cours_depart_current = 2
	END
	IF (@id_tache_en_cours IN (11,12,13,14,15,16)) AND @id_projet_tache_en_cours <> @id_project
	BEGIN
		SET @tache_en_cours_depart_current = 0
	END
	IF (@id_tache_en_cours NOT IN (10,11,12,13,14,15,16)) AND @id_projet_tache_en_cours <> @id_project
	BEGIN
		SET @tache_en_cours_depart_current = 0
	END
	
	
	SELECT @id_parent_tache = id_parent, @id_precedent_tache = id_precedent
	FROM Taches
	WHERE id_tache = @id_tache
	
	--vérifier si le processus principal AEL pour ce département spécifique (id_project) est en cours d'exécution ou non
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project
		AND id_tache = 10 AND date_fin IS NULL AND id_status = 3) > 0
	BEGIN
		SET @ael_main_running = 1
		SELECT @id_tache_ael_main = id_tache_log, @date_debut_ael_main = (CASE WHEN date_creation IS NULL THEN date_debut ELSE date_creation END)
		FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project
		AND id_tache = 10 AND date_fin IS NULL AND id_status = 3
	END
	ELSE
	BEGIN
		SET @ael_main_running = 0
	END
	
	
	--vérifier si la tâche précédent a été exécuté et terminé avec succès (dans le même processus)
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_precedent_tache 
		AND date_fin IS NOT NULL AND id_status = 1 AND ((id_tache_log > @id_tache_ael_main 
		AND (date_creation > @date_debut_ael_main OR date_debut > @date_debut_ael_main) OR (id_tache = 4)))) > 0
	BEGIN
		SET @precedent_validation = 1
	END
	ELSE
	BEGIN
		SET @precedent_validation = 0
	END
	
	
	--vérifier le status de la tâche en cours
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache 
		AND date_fin IS NOT NULL AND id_status = 1 AND id_tache_log > @id_tache_ael_main 
		AND (date_creation > @date_debut_ael_main OR date_debut > @date_debut_ael_main)) > 0
	BEGIN
		SET @ael_tache_status = 1
	END
	ELSE
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache 
		AND date_fin IS NULL AND id_status = 3 AND id_tache_log > @id_tache_ael_main 
		AND (date_creation > @date_debut_ael_main OR date_debut > @date_debut_ael_main)) > 0
	BEGIN
		SET @ael_tache_status = 2
	END
	ELSE
	IF (SELECT COUNT(*) FROM Taches_Logs WITH (NOLOCK) WHERE id_projet = @id_project AND id_tache = @id_tache 
		AND date_fin IS NOT NULL AND id_status = 2 AND id_tache_log > @id_tache_ael_main 
		AND (date_creation > @date_debut_ael_main OR date_debut > @date_debut_ael_main)) > 0
	BEGIN
		SET @ael_tache_status = 3
	END
	ELSE
	BEGIN
		SET @ael_tache_status = 0
	END
	
	SELECT @ael_tache_status AS ael_tache_status, @precedent_validation AS precedent_validation, @ael_main_running AS ael_main_running
		, ISNULL(@tache_en_cours_depart_current,0) AS tache_en_cours_depart_current
END
GO
