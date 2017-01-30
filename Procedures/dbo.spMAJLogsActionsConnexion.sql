SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.08.2014
-- Description:	insérer une ligne pour l'action 'Connexion' dans la table [Logs_actions] pour chaque jour un utilisateur s'est connecté
--		, en trouvant la première action 'CocheActeTraité', pour l'utilisateur, pour ce jour précis. 
--		Si l'utilisateur a déjà un ligne avec l'action 'Connexion' pour un jour, une autre ligne ne sera pas inséré dans le table [Logs_actions]. 
-- =============================================
CREATE PROCEDURE [dbo].[spMAJLogsActionsConnexion]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_utilisateur INT, @action VARCHAR(255), @date_log DATETIME
	CREATE TABLE #tmp (id_utilisateur INT, ACTION VARCHAR(255), date_log DATETIME)
	INSERT INTO #tmp
	SELECT  id_utilisateur, ACTION , DATEADD(dd, 0, DATEDIFF(dd,0, date_log))
	FROM [Logs_actions] 
	WHERE ACTION = 'CocheActeTraité'
	GROUP BY id_utilisateur, ACTION , DATEADD(dd, 0, DATEDIFF(dd,0, date_log))
	ORDER BY DATEADD(dd, 0, DATEDIFF(dd,0, date_log))
	
	--select * from #tmp
	DECLARE cursor_1 CURSOR FOR
	SELECT * FROM #tmp
	OPEN cursor_1
	FETCH NEXT FROM cursor_1 INTO @id_utilisateur, @action, @date_log
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT * FROM Logs_actions WITH (NOLOCK) WHERE id_utilisateur = @id_utilisateur 
					AND (date_log >= @date_log AND date_log < DATEADD(DAY, 1, @date_log)) AND ACTION = 'Connexion')
		BEGIN
			DELETE FROM #tmp WHERE id_utilisateur = @id_utilisateur AND date_log = @date_log AND ACTION = @action
		END
		ELSE
		BEGIN
			INSERT INTO Logs_actions (date_log, id_utilisateur, ACTION, id_objet, id_type_objet)			
			SELECT TOP 1 date_log, id_utilisateur, 'Connexion' AS ACTION, NULL AS id_objet, NULL AS id_type_objet
			FROM Logs_actions WITH (NOLOCK)
			WHERE id_utilisateur = @id_utilisateur 
				AND (date_log >= @date_log AND date_log < DATEADD(DAY, 1, @date_log)) 
				AND ACTION = @action
			ORDER BY date_log ASC
		END
	
		FETCH NEXT FROM cursor_1 INTO @id_utilisateur, @action, @date_log
	END
	CLOSE cursor_1;
	DEALLOCATE cursor_1;
	
	

	DROP TABLE #tmp

	
	
END
GO
