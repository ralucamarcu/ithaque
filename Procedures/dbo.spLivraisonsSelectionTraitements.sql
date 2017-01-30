SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsSelectionTraitements]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spLivraisonsSelectionTraitements] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	DECLARE @id_traitement INT, @id_statut INT, @nb_individus INT, @nb_naissances INT, @nb_mariages INT, @nb_deces INT, @nb_recensements INT
	IF OBJECT_ID('Traitements_Info') IS NOT NULL 
		DROP TABLE Traitements_Info	
	CREATE TABLE Traitements_Info (id_livraison INT, nom VARCHAR(255), date_livraison DATETIME, [TYPE] VARCHAR(10)
		, LivA_B VARCHAR(50), [description] VARCHAR(255), nb_fichiers INT, nb_actes INT, ImportCQ BIT
		, taille_lots_echantillonnage INT, nb_lots_rejetes INT, avancement_controle INT, nb_total_lots_livraison INT
		, date_retour_conformite_xml DATETIME, date_retour_cq DATETIME, date_reecriture DATETIME, date_publication DATETIME
		, commentaire VARCHAR(MAX), id_projet UNIQUEIDENTIFIER, statut INT, date_conforme DATETIME, nb_individus INT, nb_images INT
		, nb_naissances INT, nb_mariages INT, nb_deces INT, nb_recensements INT, import_xml BIT)
	
	CREATE TABLE #tmp2 ( id_statut INT)
	CREATE TABLE #tmp3 (id_acte INT, type_acte VARCHAR(255))
	
		DECLARE cursor_1 CURSOR FOR
		SELECT id_traitement
		FROM Traitements WITH (NOLOCK)		
		OPEN cursor_1 
		FETCH cursor_1 INTO @id_traitement
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO #tmp3(id_acte, type_acte)
			SELECT dxa.id, dxa.type_acte
			FROM DataXmlRC_actes dxa WITH (NOLOCK)
			INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
			WHERE dxf.id_traitement = @id_traitement
			
			SET @nb_individus = (SELECT COUNT(dxi.id) FROM DataXmlRC_individus dxi WITH (NOLOCK)
								INNER JOIN #tmp3 t ON dxi.id_acte = t.id_acte)
			SET @nb_naissances = (SELECT COUNT(id_acte) FROM #tmp3 WHERE type_acte = 'naissance')
			SET @nb_mariages = (SELECT COUNT(id_acte) FROM #tmp3 WHERE type_acte = 'mariage')
			SET @nb_deces = (SELECT COUNT(id_acte) FROM #tmp3 WHERE type_acte = 'deces')
			SET @nb_recensements = (SELECT COUNT(id_acte) FROM #tmp3 WHERE type_acte = 'recensement')
			
			INSERT INTO Traitements_Info(id_livraison, nom, date_livraison, [TYPE], LivA_B, [description], nb_fichiers, nb_actes
			, ImportCQ, taille_lots_echantillonnage, nb_lots_rejetes, avancement_controle, nb_total_lots_livraison, date_retour_conformite_xml
			, date_retour_cq, date_reecriture, date_publication, commentaire)
			EXEC [spLivraisonsSelectionParIdTraitement] @id_traitement = @id_traitement
			
			INSERT INTO #tmp2
			EXEC [spLivraisonsSelectionEtatTraitement] @id_traitement
			
			SET @id_statut = (SELECT TOP 1 id_statut FROM #tmp2)
			UPDATE Traitements_Info
			SET statut = @id_statut
				,nb_individus = @nb_individus
				,nb_naissances = @nb_naissances
				,nb_mariages = @nb_mariages
				,nb_deces = @nb_deces
				,nb_recensements = @nb_recensements
			WHERE id_livraison = @id_traitement
			
			TRUNCATE TABLE #tmp2
			TRUNCATE TABLE #tmp3
			
			FETCH cursor_1 INTO @id_traitement
		END
		CLOSE cursor_1
		DEALLOCATE cursor_1
		
		UPDATE Traitements_Info
		SET id_projet = t.id_projet
			,date_conforme = t.date_verification_conformite
			,nb_images = t.nb_images
			,import_xml = t.import_xml
		FROM Traitements_Info ti WITH (NOLOCK)
		INNER JOIN Traitements t WITH (NOLOCK) ON ti.id_livraison = t.id_traitement
		
		DROP TABLE #tmp2
		DROP TABLE #tmp3
END
GO
