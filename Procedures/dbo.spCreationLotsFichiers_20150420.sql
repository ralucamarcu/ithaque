SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric ROBILLARD
-- Create date: 09/09/2013
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spCreationLotsFichiers]
	@id_traitement as int = 0,
	@dispatch_reste as BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @seuil_lot INTEGER, @plafond_lot INTEGER, @nb_manquants INTEGER, @id_lot_choisi UNIQUEIDENTIFIER
--SET @seuil_lot = 10001
--SET @plafond_lot = 35000
DECLARE @id_fichier UNIQUEIDENTIFIER, @chemin_fichier varchar(512), @nb_champs_a_controler_acte INTEGER, @nb_champs_a_controler_fichier INTEGER, @nb_actes_fichier INTEGER, @id_lot UNIQUEIDENTIFIER
DECLARE @id_fichier_dispo UNIQUEIDENTIFIER, @fichier_xml_dispo VARCHAR(512), @nb_champs_fichier_dispo INTEGER, @nb_actes_fichier_dispo INTEGER, @id_lot_dispo UNIQUEIDENTIFIER
DECLARE @id_fichier_reste UNIQUEIDENTIFIER, @fichier_xml_reste VARCHAR(512), @nb_champs_fichier_reste INTEGER, @nb_actes_fichier_reste INTEGER, @id_lot_reste UNIQUEIDENTIFIER
DECLARE @i INTEGER, @nb_champs_lot INTEGER, @nb_actes_lot INTEGER, @flag_lot_complet bit, @excedent_lot INTEGER
DECLARE @id_fichier_a_retirer UNIQUEIDENTIFIER, @nb_champs_a_retirer INTEGER, @flag_fin_retrait_fichier BIT
DECLARE @nb_champs_restants INTEGER, @flag_exit BIT

SET @i = 0
SET @nb_actes_lot = 0
SET @flag_lot_complet = 0
SET @excedent_lot = 0
SET @flag_exit = 0

SET NOCOUNT ON

--RECUPERATION DE L'EFFECTIF MIN ET MAX DES LOTS
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
RAISERROR (N'RECUPERATION DE L''EFFECTIF MIN ET MAX DES LOTS',0,1) WITH NOWAIT;
SELECT @seuil_lot=ISNULL(t.objectif_effectif_min, ISNULL(p.objectif_effectif_min, el.effectif_min)), @plafond_lot=el.effectif_max FROM dbo.Projets p (NOLOCK) INNER JOIN dbo.Traitements t (NOLOCK) ON p.id_projet=t.id_projet INNER JOIN dbo.Table_effectifs_lots el (NOLOCK) ON p.id_effectif_lot=el.id_effectif_lot WHERE t.id_traitement=@id_traitement


--NB DE CHAMPS A CONTRÔLER PAR ACTE
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
RAISERROR (N'NB DE CHAMPS A CONTRÔLER PAR ACTE',0,1) WITH NOWAIT;
IF OBJECT_ID('tempdb..#temp_actes') is not null 
	DROP TABLE #temp_actes
SELECT a.id, a.id_fichier
--	, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END + SUM(CASE WHEN i.nom IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN i.prenom IS NOT NULL THEN 1 ELSE 0 END) AS nb_champs_a_controler_acte
--	, 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) AS nb_champs_a_controler_acte
	, CASE WHEN a.type_acte IN ('naissance', 'mariage', 'deces') THEN 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) ELSE 0 END AS nb_champs_a_controler_acte
INTO #temp_actes
FROM dbo.Traitements t WITH (nolock)
INNER JOIN dbo.DataXmlRC_actes a WITH (nolock) ON t.id_traitement=a.id_traitement
LEFT JOIN dbo.DataXmlRC_individus i WITH (nolock) ON a.id=i.id_acte
WHERE t.id_traitement=@id_traitement
GROUP BY a.id, a.id_fichier/*, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END*/, a.type_acte

CREATE INDEX IX_temp_actes_id_fichier ON #temp_actes (id_fichier)
--SELECT * FROM #temp_actes

--NB DE CHAMPS A CONTRÔLER PAR FICHIER
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
RAISERROR (N'NB DE CHAMPS A CONTRÔLER PAR FICHIER',0,1) WITH NOWAIT;
IF OBJECT_ID('tempdb..#temp_fichiers') is not null 
	DROP TABLE #temp_fichiers
SELECT f.id_fichier, f.chemin_fichier
	, ISNULL(SUM(nb_champs_a_controler_acte), 0) AS nb_champs_a_controler_fichier
	, COUNT(DISTINCT a.id) AS nb_actes
	, CAST(NULL AS UNIQUEIDENTIFIER) AS id_lot
	, f.id_traitement
INTO #temp_fichiers
FROM dbo.DataXml_Fichiers f (nolock) 
LEFT JOIN #temp_actes a (nolock) ON a.id_fichier=f.id_fichier
WHERE f.id_traitement=@id_traitement
GROUP BY f.id_fichier, f.chemin_fichier, f.id_traitement

ALTER TABLE #temp_fichiers ADD PRIMARY KEY (id_fichier)
CREATE INDEX IX_temp_fichier_lot ON #temp_fichiers (id_lot)

--ON PARCOURT LES FICHIERS DANS L'ORDRE DECROISSANT DU NOMBRE DE CHAMPS
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
RAISERROR (N'PARCOURS LES FICHIERS DANS L''ORDRE DECROISSANT DU NOMBRE DE CHAMPS',0,1) WITH NOWAIT;
IF OBJECT_ID('tempdb..#temp_lots') is not null 
BEGIN
	DROP TABLE #temp_lots
END
SELECT TOP 0 id_lot, id_traitement, ordre INTO #temp_lots FROM dbo.DataXml_lots_fichiers WITH (NOLOCK)
DECLARE fichier_xml_cursor CURSOR 
	FOR SELECT id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL ORDER BY nb_champs_a_controler_fichier DESC FOR UPDATE OF id_lot
OPEN fichier_xml_cursor
FETCH NEXT FROM fichier_xml_cursor
INTO @id_fichier, @chemin_fichier, @nb_champs_a_controler_fichier, @nb_actes_fichier, @id_lot
WHILE @@FETCH_STATUS = 0 AND @flag_exit=0
BEGIN
	IF @id_lot IS NULL
	BEGIN
		SET @i = @i + 1
		SET @id_lot = newid()
		SET @nb_actes_lot = @nb_actes_fichier
		SET @nb_champs_lot = @nb_champs_a_controler_fichier
		PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier AS VARCHAR(50)) + ' (' + @chemin_fichier + ') - ' + CAST(@nb_champs_a_controler_fichier AS varchar(512)) + ' - lot ' + CAST(@i AS varchar(512))
		INSERT INTO #temp_lots
			SELECT TOP 1 @id_lot, @id_traitement, @i
		UPDATE #temp_fichiers SET id_lot=@id_lot WHERE CURRENT OF fichier_xml_cursor
		--SI IL FAUT COMPLETER LE LOT ET QU'IL RESTE DES FICHIERS SANS LOT
		IF @nb_champs_lot<@seuil_lot AND EXISTS(SELECT id_fichier FROM #temp_fichiers WHERE id_lot IS NULL)
		BEGIN
			SET @nb_manquants = @seuil_lot - @nb_champs_lot
			PRINT CONVERT(varchar(50), getdate(), 131) + ' (' + @chemin_fichier + ') - ' + CAST(@nb_champs_a_controler_fichier AS varchar(512)) + ' - lot ' + CAST(@i AS varchar(512)) + ' : ' + CAST(@nb_manquants AS varchar(512))  + ' manquants'
			--ON PARCOURT LES FICHIERS SANS LOT DANS L'ORDRE CROISSANT DU NOMBRE DE CHAMPS POUR COMPLETER LE LOT
			DECLARE fichier_xml_dispo_cursor CURSOR 
				FOR SELECT id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL ORDER BY nb_champs_a_controler_fichier ASC FOR UPDATE OF id_lot
			OPEN fichier_xml_dispo_cursor
			FETCH NEXT FROM fichier_xml_dispo_cursor
			INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
			WHILE @@FETCH_STATUS = 0 AND @flag_lot_complet = 0
			BEGIN
				SET @nb_actes_lot = @nb_actes_lot + @nb_actes_fichier_dispo
				SET @nb_champs_lot = @nb_champs_lot + @nb_champs_fichier_dispo
				PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_dispo AS VARCHAR(50)) + ' (' + @fichier_xml_dispo + ') - ' + CAST(@nb_champs_fichier_dispo AS varchar(512)) + ' - ajout au lot ' + CAST(@i AS varchar(512)) + ' - nb champs du lot ' + CAST(@nb_champs_lot AS varchar(512))
				UPDATE #temp_fichiers SET id_lot=@id_lot WHERE CURRENT OF fichier_xml_dispo_cursor
				IF @nb_champs_lot>@seuil_lot
				BEGIN
					SET @flag_lot_complet = 1
				END
				FETCH NEXT FROM fichier_xml_dispo_cursor
				INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
			END
			set @flag_lot_complet = 0
			SELECT * FROM #temp_fichiers WHERE id_lot=@id_lot
			--EST-CE QU'ON PEUT RETIRER DES FICHIERS DU LOT SANS QU'IL PASSE SOUS LE SEUIL
			SET @excedent_lot = @nb_champs_lot - @seuil_lot
			--PRINT 'excédent restant 1 : ' + CAST(@excedent_lot AS varchar(512))
			SET @flag_fin_retrait_fichier = 0
			WHILE @excedent_lot>0 AND @flag_fin_retrait_fichier=0
			BEGIN
				SELECT TOP 1 @id_fichier_a_retirer=id_fichier, @nb_champs_a_retirer=nb_champs_a_controler_fichier FROM #temp_fichiers WHERE id_lot=@id_lot AND (nb_champs_a_controler_fichier<=@excedent_lot AND nb_champs_a_controler_fichier>0) ORDER BY nb_champs_a_controler_fichier DESC
				IF @id_fichier_a_retirer IS NULL
				BEGIN
					SET @flag_fin_retrait_fichier = 1
				END
				ELSE
				BEGIN
					--SI ON TROUVE UN FICHIER QUI A UN NOMBRE DE CHAMPS INFERIEUR OU EGAL A L'EXCEDENT, ON LE RETIRE DU LOT
					--PRINT 'nb champs retirés : ' + CAST(@nb_champs_a_retirer AS varchar(512))
					UPDATE #temp_fichiers SET id_lot=NULL WHERE id_fichier=@id_fichier_a_retirer
					SET @nb_champs_lot = @nb_champs_lot - @nb_champs_a_retirer
					SET @excedent_lot = @nb_champs_lot - @seuil_lot
					PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_a_retirer AS varchar(512)) + ' - ' + CAST(@nb_champs_a_retirer AS varchar(512)) + ' - retiré du lot ' + CAST(@i AS varchar(512)) + ' - nb champs du lot ' + CAST(@nb_champs_lot AS varchar(512))
					--PRINT 'excédent restant 2 : ' + CAST(@excedent_lot AS varchar(512))
				END
				SET @id_fichier_a_retirer = NULL
			END
			CLOSE fichier_xml_dispo_cursor
			DEALLOCATE fichier_xml_dispo_cursor
		END
		SELECT * FROM #temp_fichiers WHERE id_lot=@id_lot
	END
	
	--SI LA SOMME DES CHAMPS A CONTRÔLER DES FICHIERS SANS LOT EST INFERIEURE AU SEUIL, ON SORT DE LA BOUCLE
	IF @dispatch_reste = 1
	BEGIN
		SELECT @nb_champs_restants=SUM(nb_champs_a_controler_fichier) FROM #temp_fichiers WHERE id_lot IS NULL
		PRINT CONVERT(varchar(50), getdate(), 131) + ' : Nb champs restants : ' + CAST(ISNULL(@nb_champs_restants, 0) AS varchar(512))
		IF (ISNULL(@nb_champs_restants, 0) < @seuil_lot)
		BEGIN
			SET @flag_exit = 1
		END
	END
    FETCH NEXT FROM fichier_xml_cursor 
    INTO @id_fichier, @chemin_fichier, @nb_champs_a_controler_fichier, @nb_actes_fichier, @id_lot
END 
/*
SELECT * FROM #temp_fichiers order by id_lot asc
SELECT id_lot, COUNT(DISTINCT id_fichier), SUM(nb_champs_a_controler_fichier)  FROM #temp_fichiers GROUP BY id_lot ORDER BY id_lot
*/

--SI LA SOMME DES CHAMPS A CONTRÔLER DES FICHIERS SANS LOT EST INFERIEURE AU SEUIL ALORS ON REPARTIE CES FICHIERS SUR LES DIFFERENTS LOTS
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
RAISERROR (N'REPARTITION DES FICHIERS SANS LOT SUR LES DIFFERENTS LOTS',0,1) WITH NOWAIT;
IF (ISNULL(@nb_champs_restants, 0) > 0 AND ISNULL(@nb_champs_restants, 0) < @seuil_lot)
BEGIN
	--RESUME PAR LOT
	IF OBJECT_ID('tempdb..#recap_lots') is not null 
		DROP TABLE #recap_lots
	SELECT id_lot, SUM(nb_champs_a_controler_fichier) AS [Nb champs], COUNT(id_fichier) AS [Nb fichiers] INTO #recap_lots FROM #temp_fichiers WHERE id_lot IS NOT NULL GROUP BY id_lot ORDER BY id_lot ASC
	--SELECT * FROM #recap_lots

	DECLARE fichier_xml_reste_cursor CURSOR 
		FOR SELECT id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL ORDER BY nb_champs_a_controler_fichier DESC FOR UPDATE OF id_lot
	OPEN fichier_xml_reste_cursor
	FETCH NEXT FROM fichier_xml_reste_cursor
	INTO @id_fichier_reste, @fichier_xml_reste, @nb_champs_fichier_reste, @nb_actes_fichier_reste, @id_lot_reste
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_reste AS varchar(50))
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT TOP 1 @id_lot_choisi=id_lot FROM #recap_lots WHERE [Nb champs]+@nb_champs_fichier_reste<=@plafond_lot ORDER BY [Nb champs] ASC
		PRINT CONVERT(varchar(50), getdate(), 131) + ' : Fichier ' + CAST(@id_fichier_reste AS varchar(512)) + ' dans lot ' + CAST(@id_lot_choisi AS varchar(512))
		IF @id_lot_choisi IS NOT NULL
		BEGIN
			UPDATE #temp_fichiers SET id_lot=@id_lot_choisi WHERE CURRENT OF fichier_xml_reste_cursor
			UPDATE #recap_lots SET [Nb champs]=[Nb champs]+@nb_champs_fichier_reste WHERE id_lot=@id_lot_choisi
		END
		FETCH NEXT FROM fichier_xml_reste_cursor 
		INTO @id_fichier_reste, @fichier_xml_reste, @nb_champs_fichier_reste, @nb_actes_fichier_reste, @id_lot_reste
	END
	CLOSE fichier_xml_reste_cursor
	DEALLOCATE fichier_xml_reste_cursor
END
CLOSE fichier_xml_cursor
DEALLOCATE fichier_xml_cursor

/*
SELECT * FROM #temp_lots
SELECT * FROM #temp_fichiers order by id_lot asc
SELECT id_lot, COUNT(DISTINCT id_fichier) AS [Nb fichiers], SUM(nb_champs_a_controler_fichier) AS [Nb champs]  FROM #temp_fichiers GROUP BY id_lot ORDER BY id_lot
*/

--SUPPRESSION DES ECHANTILLONS, DETACHEMENT DES FICHIERS AUX LOTS ET SUPPRESSION DES LOTS 
--PUIS INSERTION DES LOTS DANS LA TABLE DataXml_lots_fichiers ET RATTACHEMENT DES FICHIERS (TABLE DataXml_fichiers) AUX LOTS
BEGIN TRANSACTION
BEGIN TRY
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'SUPPRESSION DES ECHANTILLONS, DETACHEMENT DES FICHIERS AUX LOTS ET SUPPRESSION DES LOTS',0,1) WITH NOWAIT;
	--SUPPRESSION DES DETAILS DES ECHANTILLONS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Suppression des détails des échantillons'
	DELETE DataXmlEchantillonDetailsRC FROM DataXmlEchantillonDetailsRC ed (NOLOCK) INNER JOIN DataXmlEchantillonEntete ee (NOLOCK) ON ed.id_echantillon=ee.id_echantillon INNER JOIN DataXml_lots_fichiers lf (NOLOCK) ON ee.id_lot=lf.id_lot WHERE lf.id_traitement=@id_traitement
	--SUPPRESSION DES ENTETES DES ECHANTILLONS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Suppression des entêtes des échantillons'
	DELETE DataXmlEchantillonEntete FROM DataXmlEchantillonEntete ee (NOLOCK) INNER JOIN DataXml_lots_fichiers lf (NOLOCK) ON ee.id_lot=lf.id_lot WHERE lf.id_traitement=@id_traitement
	--DETACHEMENT DES FICHIERS AUX LOTS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Détachement des fichiers aux lots'
	UPDATE DataXml_Fichiers SET id_lot=NULL WHERE id_traitement=@id_traitement
	--SUPPRESSION DES LOTS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Suppression des lots'
	DELETE DataXml_lots_fichiers WHERE id_traitement=@id_traitement
	
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'INSERTION DES LOTS',0,1) WITH NOWAIT;
	--INSERTION DES LOTS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Insertion des lots'
	INSERT INTO dbo.DataXml_lots_fichiers (id_lot, id_traitement, nom_lot, ordre) SELECT id_lot, id_traitement, 'Lot ' + CAST(ordre AS VARCHAR(10)) AS nom_lot, ordre FROM #temp_lots
	PRINT (CONVERT( VARCHAR(24), GETDATE(), 121));
	RAISERROR (N'RATTACHEMENT DES FICHIERS AUX LOTS',0,1) WITH NOWAIT;
	--RATTACHEMENT DES FICHIERS AUX LOTS
	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Rattachement des fichiers aux lots'
	UPDATE DataXml_fichiers 
	SET id_lot=tf.id_lot
	FROM DataXml_fichiers f WITH (NOLOCK) INNER JOIN #temp_fichiers tf ON f.id_traitement=tf.id_traitement AND f.id_fichier=tf.id_fichier
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
IF @@TRANCOUNT > 0
BEGIN
    COMMIT TRANSACTION;
    SELECT lf.id_lot, lf.ordre, f.id_fichier
    FROM dbo.DataXml_lots_fichiers lf WITH (NOLOCK)
    INNER JOIN dbo.DataXml_fichiers f WITH (NOLOCK) ON lf.id_lot=f.id_lot
    WHERE lf.id_traitement=@id_traitement
    ORDER BY lf.ordre, f.id_fichier

	PRINT CONVERT(varchar(50), getdate(), 131) + ' : Création des lots terminée sans erreur.'

END    

END

GO
