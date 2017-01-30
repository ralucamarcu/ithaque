SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 24.11.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesNbActesMettreEnLigne]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER, @nb_actes_valide_n INT, @nb_actes_valide_d INT, @nb_actes_valide_m INT 	
   	CREATE TABLE #tmp (id_acte INT PRIMARY KEY, type_acte NVARCHAR(255), annee_acte NVARCHAR(255))
   	IF OBJECT_ID('StatistiquesNbActesMettreEnLigne') IS NOT NULL 
		DROP TABLE StatistiquesNbActesMettreEnLigne
   	CREATE TABLE StatistiquesNbActesMettreEnLigne
	(sous_projet VARCHAR(255),nb_actes_valide_n INT, nb_actes_valide_d INT, nb_actes_valide_m INT)	
	
	
	DECLARE cursor_1 CURSOR FOR
	SELECT p.id_projet
	FROM projets p WITH (NOLOCK)	
	GROUP BY p.id_projet
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #tmp(id_acte, type_acte, annee_acte)
		SELECT DISTINCT dxa.id AS id_acte, dxa.type_acte, dxa.annee_acte
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
		INNER JOIN DataXml_lots_fichiers dxlf WITH (NOLOCK) ON dxf.id_lot = dxlf.id_lot
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		INNER JOIN Logs_actions la WITH (NOLOCK) ON dxee.id_echantillon = la.id_objet
		WHERE t.id_projet = @id_projet
			AND la.[action] = 'CocheEchantillonTraité'
			AND la.id_type_objet = 1	
			AND id_statut IN (1,3)
			AND ISNUMERIC(annee_acte) = 1
			AND dxlf.export_pour_mep = 0
		
		SET @nb_actes_valide_n = (SELECT COUNT(id_acte) FROM #tmp WHERE type_acte = 'naissance' 
					AND (CAST(annee_acte AS INT) >= 1792 AND CAST(annee_acte AS INT) <= 1893) )	
		SET @nb_actes_valide_d = (SELECT COUNT(id_acte) FROM #tmp WHERE type_acte = 'deces'
					AND (CAST(annee_acte AS INT) >= 1792 AND CAST(annee_acte AS INT) <= 1909) )
		SET @nb_actes_valide_m = (SELECT COUNT(id_acte) FROM #tmp WHERE type_acte = 'mariage'
					AND (CAST(annee_acte AS INT) >= 1792 AND CAST(annee_acte AS INT) <= 1938) )
			
		print @id_projet
		print @nb_actes_valide_n
		print @nb_actes_valide_d
		print @nb_actes_valide_m	
		print '--------------'	
		INSERT INTO StatistiquesNbActesMettreEnLigne(sous_projet,nb_actes_valide_n, nb_actes_valide_d, nb_actes_valide_m)
		SELECT nom, @nb_actes_valide_n AS nb_actes_valide_n,@nb_actes_valide_d AS nb_actes_valide_d, @nb_actes_valide_m AS nb_actes_valide_m
		FROM Projets WITH (NOLOCK)
		WHERE id_projet = @id_projet
		
		TRUNCATE TABLE #tmp
		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1

	DROP TABLE #tmp
	
	DELETE FROM StatistiquesNbActesMettreEnLigne WHERE nb_actes_valide_n = 0 AND nb_actes_valide_d = 0 AND nb_actes_valide_m = 0
	
END


GO
