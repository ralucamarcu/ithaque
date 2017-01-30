SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.08.2014
-- Description:	La moyenne par heure est calculé globalement et pour chaque utilisateur qui s'est connecté à l'application afin de traiter certains actes.
--				La moyenne peut être fait pour la dernière semaine ou la dernière mois, basé sur le paramètre  @statistique_type = 1 = 'derniere_semaine'/ 2 = 'derniere_mois'

-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesMoyenneActesControlesParHeure_v1] 
	-- Add the parameters for the stored procedure here	
	 @date_fin DATETIME = NULL
	,@statistique_type INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date_debut DATETIME, @id_utilisateur INT
		, @nb_total_actes_controle_global INT, @nb_total_actes_controle_par_utilisateur INT
		, @nb_heures_considere_global INT, @nb_heures_considere_par_utilisateur INT
		, @moyenne_par_heure_global FLOAT, @moyenne_par_heure_par_utilisateur FLOAT
	
	IF @date_fin IS NULL
		SET @date_fin = GETDATE()
	IF @statistique_type = 1
		SET @date_debut = DATEADD(WEEK, -1, @date_fin)
	ELSE
		IF @statistique_type = 2
			SET @date_debut = DATEADD(MONTH, -1, @date_fin)
	
-- Statistiques fait globalement pour tous les utilisateur
	SELECT @nb_heures_considere_global = 7*COUNT(x.id_utilisateur)
	FROM (SELECT id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log)) AS DATE
		FROM Logs_actions WITH (NOLOCK)
		WHERE ACTION = 'Connexion' 
			AND (date_log >= @date_debut AND date_log < @date_fin)
		GROUP BY id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log))
	) AS x

	SELECT @nb_total_actes_controle_global = COUNT(da.id)
	FROM DataXmlEchantillonEntete  dee WITH (NOLOCK)
	INNER JOIN DataXml_lots_fichiers dlf WITH (NOLOCK) ON dee.id_lot = dlf.id_lot
	INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON dlf.id_lot = df.id_lot
	INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON df.id_fichier = da.id_fichier
	WHERE id_echantillon IN (SELECT x.id_objet FROM (SELECT id_objet, DATEADD(dd,0,DATEDIFF(dd,0,date_log)) AS date_log
						FROM [Logs_actions] WITH (NOLOCK)
						WHERE id_type_objet = 1 
							AND ACTION = 'CocheEchantillonTraité'
						GROUP BY id_objet, DATEADD(dd,0,DATEDIFF(dd,0,date_log))
						HAVING DATEADD(dd,0,DATEDIFF(dd,0,date_log)) > @date_debut) AS x )
	
	SET @moyenne_par_heure_global = (CASE WHEN (ISNULL(@nb_total_actes_controle_global, 0) <> 0
			AND ISNULL(@nb_heures_considere_global, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_total_actes_controle_global AS FLOAT)
			/ CAST( @nb_heures_considere_global  AS FLOAT) AS FLOAT) as float) ELSE NULL END) 
	
-- Insérer dans Statistiques_MoyenneParHeure le moyenne par heure (le champ 'par_utilisateur' restera NULL parce que la moyenne calculé est globale)
	INSERT INTO Statistiques_MoyenneParHeure(date_debut, date_fin, nb_actes_considere, nb_heures_considere, moyenne_par_heure, statistique_type)
	VALUES (@date_debut, @date_fin, @nb_total_actes_controle_global, @nb_heures_considere_global, @moyenne_par_heure_global, @statistique_type)
						
	
-- Statistiques fait pour chaque utilisateur
	DECLARE cursor_1 CURSOR FOR
	SELECT id_utilisateur FROM [Logs_actions] WITH (NOLOCK) WHERE date_log >= @date_debut GROUP BY id_utilisateur
	OPEN cursor_1
	FETCH NEXT FROM cursor_1 INTO @id_utilisateur
	WHILE @@FETCH_STATUS = 0
	BEGIN
			SELECT @nb_heures_considere_par_utilisateur = 7*COUNT(x.id_utilisateur)
			FROM (SELECT id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log)) AS DATE
				FROM Logs_actions WITH (NOLOCK)
				WHERE ACTION = 'Connexion' 
					AND (date_log >= @date_debut AND date_log < @date_fin) 
					AND id_utilisateur = @id_utilisateur
				GROUP BY id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log))
			) AS x

			SELECT @nb_total_actes_controle_par_utilisateur = COUNT(da.id)
			FROM DataXmlEchantillonEntete  dee WITH (NOLOCK)
			INNER JOIN DataXml_lots_fichiers dlf WITH (NOLOCK) ON dee.id_lot = dlf.id_lot
			INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON dlf.id_lot = df.id_lot
			INNER JOIN DataXmlRC_actes da WITH (NOLOCK) ON df.id_fichier = da.id_fichier
			WHERE id_echantillon IN (SELECT x.id_objet FROM (SELECT id_objet, DATEADD(dd,0,DATEDIFF(dd,0,date_log)) AS date_log
								FROM [Logs_actions] WITH (NOLOCK)
								WHERE id_type_objet = 1 
									AND ACTION = 'CocheEchantillonTraité'
									AND id_utilisateur = @id_utilisateur
								GROUP BY id_objet, DATEADD(dd,0,DATEDIFF(dd,0,date_log))
								HAVING DATEADD(dd,0,DATEDIFF(dd,0,date_log)) > @date_debut) AS x )
			
			SET @moyenne_par_heure_global = (CASE WHEN (ISNULL(@nb_total_actes_controle_par_utilisateur, 0) <> 0
			AND ISNULL(@nb_heures_considere_par_utilisateur, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_total_actes_controle_par_utilisateur AS FLOAT)
			/ CAST( @nb_heures_considere_par_utilisateur  AS FLOAT) AS FLOAT) AS float) ELSE NULL END) 
			
			
			INSERT INTO Statistiques_MoyenneParHeure(date_debut, date_fin, nb_actes_considere, nb_heures_considere, moyenne_par_heure, par_utilisateur, statistique_type)
			VALUES (@date_debut, @date_fin, @nb_total_actes_controle_par_utilisateur, @nb_heures_considere_par_utilisateur, @moyenne_par_heure_global, @id_utilisateur, @statistique_type)
				
		FETCH NEXT FROM cursor_1 INTO @id_utilisateur
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
							
END
GO
