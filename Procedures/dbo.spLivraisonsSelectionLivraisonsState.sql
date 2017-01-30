SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 18.02.2015
-- Description:	Statut = 1 -> Termine
--				Statut = 2 -> En cours
--				Statut = 3 -> En attente
--				Statut = 4 -> Pas Traite
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionLivraisonsState]
	-- Add the parameters for the stored procedure here
	-- Test Run : spLivraisonsSelectionLivraisonsState '85FB4438-6E26-4419-94BF-3CABC3C241D3'
	@id_project UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nb_lots_total INT, @nb_lots_traite INT, @id_projet_tt UNIQUEIDENTIFIER
	CREATE TABLE #tmp (id_traitement INT, nom_livraison VARCHAR(255), nom_projet VARCHAR(255), Statut INT)
	
	IF (@id_project IS NOT NULL)
	BEGIN
		SET @nb_lots_total = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
							INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
							WHERE t.id_projet = @id_project)
							
		SET @nb_lots_traite = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
							INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
							WHERE t.id_projet = @id_project AND dxee.traite = 1)
							
		SELECT t.id_traitement, t.nom AS nom_livraison, p.nom AS nom_projet, 
			(CASE WHEN @nb_lots_total = @nb_lots_traite AND @nb_lots_total <> 0 THEN 1
				WHEN @nb_lots_total > @nb_lots_traite THEN 2
				WHEN @nb_lots_traite = 0 AND @nb_lots_total <> 0 THEN 3
				WHEN @nb_lots_traite = 0 AND @nb_lots_total = 0 THEN 4
				ELSE 0 END) AS Statut
		FROM Traitements t WITH (NOLOCK)
		INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
		LEFT JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON t.id_traitement = dxee.id_traitement AND dxee.traite = 1
		WHERE t.id_projet = @id_project AND  dxee.id_echantillon IS NOT NULL
		GROUP BY t.id_traitement, t.nom, p.nom
	END
	ELSE
	BEGIN
		DECLARE cursor_1 CURSOR FOR
		SELECT id_projet
		FROM projets WITH (NOLOCK)
		OPEN cursor_1
		FETCH cursor_1 INTO @id_projet_tt
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @nb_lots_total = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
							INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
							WHERE t.id_projet = @id_projet_tt)
							
			SET @nb_lots_traite = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
								INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
								WHERE t.id_projet = @id_projet_tt AND dxee.traite = 1)
								
			INSERT INTO #tmp (id_traitement, nom_livraison, nom_projet, Statut)
			SELECT t.id_traitement, t.nom AS nom_livraison, p.nom AS nom_projet, 
				(CASE WHEN @nb_lots_total = @nb_lots_traite AND @nb_lots_total <> 0 THEN 1
					WHEN @nb_lots_total > @nb_lots_traite THEN 2
					WHEN @nb_lots_traite = 0 AND @nb_lots_total <> 0 THEN 3
					WHEN @nb_lots_traite = 0 AND @nb_lots_total = 0 THEN 4
					ELSE 0 END) AS Statut
			FROM Traitements t WITH (NOLOCK)
			INNER JOIN Projets p WITH (NOLOCK) ON t.id_projet = p.id_projet
			LEFT JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON t.id_traitement = dxee.id_traitement AND dxee.traite = 1
			WHERE t.id_projet = @id_projet_tt --AND  dxee.id_echantillon IS NOT NULL
			GROUP BY t.id_traitement, t.nom, p.nom
		
			FETCH cursor_1 INTO @id_projet_tt
		END
		CLOSE cursor_1
		DEALLOCATE cursor_1
		
		SELECT * FROM #tmp
		DROP TABLE #tmp
	END
END



GO
