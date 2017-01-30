SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 07.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesActesTraitesParOperateurTotal]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Statistiques fait pour chaque utilisateur
	
		DECLARE @id_projet UNIQUEIDENTIFIER, @id_utilisateur INT, @date DATETIME, @last_date_inserted datetime

	SET @last_date_inserted =(SELECT max([DATE]) FROM  Statistiques_Actes_Par_Operateurs WITH(NOLOCK))
	CREATE TABLE #tmp (id_utilisateur INT, [DATE] DATETIME)
			
	--IF OBJECT_ID('Statistiques_Actes_Par_Operateurs') IS NOT NULL 
	--	DROP TABLE Statistiques_Actes_Par_Operateurs
	--CREATE TABLE Statistiques_Actes_Par_Operateurs (id_statistiques_actes_par_operateurs INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	--	,id_utilisateur INT, operateur_nom VARCHAR(255), operateur_prenom VARCHAR(255), [DATE] DATETIME, sous_projet VARCHAR(255)
	--	,lots_traites INT, actes_traites INT, lots_rejetes INT)
	
	PRINT @last_date_inserted

	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT p.id_projet
	FROM projets p WITH (NOLOCK)
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp
		SELECT id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log)) AS [DATE]
		FROM Logs_actions WITH (NOLOCK)
		WHERE [ACTION] = 'CocheEchantillonTraité'  AND DATEADD(dd,00,DATEDIFF(dd, 0, date_log))>@last_date_inserted
		GROUP BY id_utilisateur , DATEADD(dd,00,DATEDIFF(dd, 0, date_log))
		PRINT @id_projet
		WHILE EXISTS (SELECT id_utilisateur FROM #tmp)
		BEGIN
			
			SELECT TOP 1 @id_utilisateur = id_utilisateur, @date = [DATE] 
			FROM #tmp 
			ORDER BY id_utilisateur
			PRINT @id_utilisateur
			PRINT @date
			PRINT @id_projet
			INSERT INTO Statistiques_Actes_Par_Operateurs (id_utilisateur, operateur_nom, operateur_prenom,[DATE], sous_projet
				, lots_traites, actes_traites, lots_rejetes)
			EXEC [spStatistiquesActesTraitesParOperateur] @id_projet, @id_utilisateur, @date
			
			
			DELETE FROM #tmp WHERE id_utilisateur = @id_utilisateur AND [DATE] = @date
			SET @id_utilisateur = NULL
			SET @date = NULL
			
		END
		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	DROP TABLE #tmp
	
	DELETE FROM Statistiques_Actes_Par_Operateurs WHERE lots_traites = 0 AND actes_traites = 0 AND lots_rejetes = 0
END

GO
