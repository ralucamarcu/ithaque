SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric ROBILLARD
-- Create date: 11/09/2014
-- Description:	-- A AMELIORER -- Nouvelle Proc Stock de création de lots
-- =============================================
CREATE PROCEDURE [dbo].[spCreationLotsFichiers]
	@id_traitement as int = 0,
	@dispatch_reste as BIT = 1,
	@simulation as BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @seuil_lot_norme INTEGER, @seuil_lot INTEGER, @seuil_lot_a_atteindre INTEGER, @plafond_lot INTEGER, @nb_manquants INTEGER, @id_lot_choisi UNIQUEIDENTIFIER
	--SET @seuil_lot = 10001
	--SET @plafond_lot = 35000
	DECLARE @id_fichier UNIQUEIDENTIFIER, @chemin_fichier varchar(512), @nb_champs_a_controler_acte INTEGER, @nb_champs_a_controler_fichier INTEGER, @nb_actes_fichier INTEGER, @id_lot UNIQUEIDENTIFIER
	DECLARE @id_fichier_dispo UNIQUEIDENTIFIER, @fichier_xml_dispo VARCHAR(512), @nb_champs_fichier_dispo INTEGER, @nb_actes_fichier_dispo INTEGER, @id_lot_dispo UNIQUEIDENTIFIER
	DECLARE @id_fichier_reste UNIQUEIDENTIFIER, @fichier_xml_reste VARCHAR(512), @nb_champs_fichier_reste INTEGER, @nb_actes_fichier_reste INTEGER, @id_lot_reste UNIQUEIDENTIFIER
	DECLARE @i INTEGER, @nb_champs_lot INTEGER, @nb_actes_lot INTEGER, @flag_lot_complet bit, @excedent_lot INTEGER
	DECLARE @id_fichier_a_retirer UNIQUEIDENTIFIER, @nb_champs_a_retirer INTEGER, @flag_fin_retrait_fichier BIT
	DECLARE @nb_champs_restants INTEGER, @flag_exit BIT
	DECLARE @nb_champs_total INTEGER
	DECLARE @flag_poursuite_lot as BIT = 1

	SET @i = 0
	SET @nb_actes_lot = 0
	SET @flag_lot_complet = 0
	SET @excedent_lot = 0
	SET @flag_exit = 0

	SET NOCOUNT ON

	--RECUPERATION DE L'EFFECTIF MIN ET MAX DES LOTS
	SELECT @seuil_lot_norme=el.effectif_min, @seuil_lot=ISNULL(t.objectif_effectif_min, ISNULL(p.objectif_effectif_min, el.effectif_min)), @plafond_lot=el.effectif_max FROM dbo.Projets p (NOLOCK) INNER JOIN dbo.Traitements t (NOLOCK) ON p.id_projet=t.id_projet INNER JOIN dbo.Table_effectifs_lots el (NOLOCK) ON p.id_effectif_lot=el.id_effectif_lot WHERE t.id_traitement=@id_traitement
	PRINT 'SEUIL LOT NORME : ' + cast(@seuil_lot_norme as varchar)
	PRINT 'SEUIL LOT : ' + cast(@seuil_lot as varchar)
	--NB DE CHAMPS A CONTRÔLER PAR ACTE
	PRINT 'NB DE CHAMPS A CONTRÔLER PAR ACTE : ' + cast(getdate() as varchar)
	IF OBJECT_ID('tempdb..#temp_actes') is not null 
		DROP TABLE #temp_actes
	SELECT a.id, a.id_fichier
	--	, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END + SUM(CASE WHEN i.nom IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN i.prenom IS NOT NULL THEN 1 ELSE 0 END) AS nb_champs_a_controler_acte
	--	, 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) AS nb_champs_a_controler_acte
	--	, CASE WHEN a.type_acte IN ('naissance', 'mariage', 'deces') THEN 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) ELSE 0 END AS nb_champs_a_controler_acte
		, CASE 
			WHEN a.type_acte IN ('naissance', 'mariage', 'deces') OR (a.type_acte='tablesDecennales' AND a.soustype_acte IN ('naissance', 'mariage', 'deces')) THEN 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) 
			WHEN a.type_acte IN ('Recensement') THEN SUM(1+1 /*nom+prenom*/ + 1 /*âge ou année de naissance*/ + 1 /*lieu de naissance*/ + CASE WHEN i.nom_jeune_fille IS NULL THEN 0 ELSE 1 END /*nom de jeune fille*/)
			ELSE 0 
		  END AS nb_champs_a_controler_acte
	INTO #temp_actes
	FROM dbo.Traitements t (nolock)
	LEFT JOIN dbo.DataXmlRC_actes a (nolock) ON t.id_traitement=a.id_traitement
	LEFT JOIN dbo.DataXmlRC_individus i (nolock) ON a.id=i.id_acte
	WHERE t.id_traitement=@id_traitement
	GROUP BY a.id, a.id_fichier, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END, a.type_acte, a.soustype_acte

	--SELECT * FROM #temp_actes

	--NB DE CHAMPS A CONTRÔLER PAR FICHIER
	PRINT 'NB DE CHAMPS A CONTRÔLER PAR FICHIER : ' + cast(getdate() as varchar)
	IF OBJECT_ID('tempdb..#temp_fichiers') is not null 
		DROP TABLE #temp_fichiers
	SELECT f.id_fichier, f.chemin_fichier
		, ISNULL(SUM(nb_champs_a_controler_acte),0) AS nb_champs_a_controler_fichier
		, COUNT(DISTINCT a.id) AS nb_actes
		, CAST(NULL AS UNIQUEIDENTIFIER) AS id_lot
		, f.id_traitement
	INTO #temp_fichiers
	FROM dbo.DataXml_Fichiers f (nolock)
	LEFT JOIN #temp_actes a (nolock) ON a.id_fichier=f.id_fichier
	WHERE f.id_traitement=@id_traitement
	GROUP BY f.id_fichier, f.chemin_fichier, f.id_traitement
	/*
	SELECT f.id_fichier, f.chemin_fichier
		, SUM(nb_champs_a_controler_acte) AS nb_champs_a_controler_fichier
		, COUNT(DISTINCT a.id) AS nb_actes
		, CAST(NULL AS UNIQUEIDENTIFIER) AS id_lot
		, f.id_traitement
	INTO #temp_fichiers
	FROM #temp_actes a (nolock)
	INNER JOIN dbo.DataXml_Fichiers f (nolock) ON a.id_fichier=f.id_fichier
	GROUP BY f.id_fichier, f.chemin_fichier, f.id_traitement
	*/

	PRINT 'CREATION INDEX SUR LA TABLE TEMPORAIRE : ' + cast(getdate() as varchar)
	ALTER TABLE #temp_fichiers ADD PRIMARY KEY (id_fichier)
	CREATE INDEX IX_temp_fichier_lot ON #temp_fichiers (id_lot)
	
	--/* MIS EN COMMENTAIRE CAR CREATION DE 3 LOTS QUAND 2 SONT POSSIBLES
	--SI LE NB TOTAL DE CHAMPS EST SUPERIEUR AU PLAFOND D'UN LOT ET INFERIEUR AU DOUBLE DU PLAFOND D'UN LOT 
	--ALORS LE SEUIL D'UN LOT DEVIENT LA VALEUR MEDIANE ENTRE @seuil_lot_norme ET @seuil_lot
	SELECT @nb_champs_total=SUM(nb_champs_a_controler_fichier) FROM #temp_fichiers
	IF (@nb_champs_total>@plafond_lot AND @nb_champs_total<@plafond_lot*2)
		SET @seuil_lot = @seuil_lot - ((@seuil_lot - @seuil_lot_norme) / 2)
		PRINT 'SEUIL LOT REEVALUE : ' + cast(@seuil_lot as varchar)
	--*/

	--ON PARCOURT LES FICHIERS DANS L'ORDRE DECROISSANT DU NOMBRE DE CHAMPS
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
		SET @flag_poursuite_lot = 1
		IF @id_lot IS NULL
		BEGIN
			SET @i = @i + 1
			SET @id_lot = newid()
			SET @nb_actes_lot = @nb_actes_fichier
			SET @nb_champs_lot = @nb_champs_a_controler_fichier
			SET @seuil_lot_a_atteindre = @seuil_lot
			PRINT '1 - ' + CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier AS VARCHAR(50)) + ' (' + @chemin_fichier + ') - ' + CAST(@nb_champs_a_controler_fichier AS varchar(512)) + ' - lot ' + CAST(@i AS varchar(512)) + ' (' + CAST(@id_lot AS VARCHAR(512))+ ')'
			INSERT INTO #temp_lots
				SELECT TOP 1 @id_lot, @id_traitement, @i
			UPDATE #temp_fichiers SET id_lot=@id_lot WHERE CURRENT OF fichier_xml_cursor
			--select * from #temp_fichiers WHERE id_fichier=@id_fichier
			--SI IL FAUT COMPLETER LE LOT ET QU'IL RESTE DES FICHIERS SANS LOT
			--IF @nb_champs_lot<@seuil_lot AND EXISTS(SELECT id_fichier FROM #temp_fichiers WHERE id_lot IS NULL) AND @flag_poursuite_lot=1
			IF @nb_champs_lot<@seuil_lot_a_atteindre AND EXISTS(SELECT id_fichier FROM #temp_fichiers WHERE id_lot IS NULL) AND @flag_poursuite_lot=1
			BEGIN
				--TANT QUE L'ON A PAS ATTEINT LE SEUIL VOULU
				--WHILE @nb_champs_lot < @seuil_lot AND @flag_poursuite_lot = 1
				WHILE @nb_champs_lot < @seuil_lot_a_atteindre AND @flag_poursuite_lot = 1
				BEGIN
					--PRINT '@flag_lot_complet = ' + CONVERT(varchar(50), @flag_lot_complet, 131)
					--SET @nb_manquants = @seuil_lot - @nb_champs_lot
					SET @nb_manquants = @seuil_lot_a_atteindre - @nb_champs_lot
					PRINT '2 - ' + CONVERT(varchar(50), getdate(), 131) + ' (' + @chemin_fichier + ') - ' + CAST(@nb_champs_a_controler_fichier AS varchar(512)) + ' - lot ' + CAST(@i AS varchar(512)) + ' : ' + CAST(@nb_manquants AS varchar(512))  + ' manquants'
					/*
					IF @i=78
					BEGIN
						SELECT * FROM #temp_fichiers WHERE id_lot IS NULL AND (nb_champs_a_controler_fichier+@nb_champs_lot BETWEEN @seuil_lot AND @plafond_lot) ORDER BY nb_champs_a_controler_fichier ASC
						SELECT * FROM #temp_fichiers ORDER BY id_lot, nb_champs_a_controler_fichier ASC
						return
					END
					*/
					--ON SELECTIONNE LE FICHIER SANS LOT QUI A UN NOMBRE D'ACTES PERMETTANT D'ATTEINDRE LE SEUIL VOULU DU LOT SANS DEPASSER LE PLAFOND
					DECLARE fichier_xml_jaidelachance_cursor CURSOR 
						--FOR SELECT TOP 1 id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL AND (nb_champs_a_controler_fichier+@nb_champs_lot BETWEEN @seuil_lot_norme AND @plafond_lot) ORDER BY ABS(@nb_champs_lot+nb_champs_a_controler_fichier-@seuil_lot) ASC FOR UPDATE OF id_lot
						--FOR SELECT TOP 1 id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL AND (nb_champs_a_controler_fichier+@nb_champs_lot BETWEEN @seuil_lot AND @plafond_lot) ORDER BY ABS(@nb_champs_lot+nb_champs_a_controler_fichier-@seuil_lot) ASC FOR UPDATE OF id_lot
						FOR SELECT TOP 1 id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL /*AND (nb_champs_a_controler_fichier+@nb_champs_lot BETWEEN @seuil_lot_a_atteindre AND @plafond_lot)*/ ORDER BY CASE WHEN (@nb_champs_lot+nb_champs_a_controler_fichier-@seuil_lot_a_atteindre>=0) THEN 1 ELSE 0 END DESC, ABS(@nb_champs_lot+nb_champs_a_controler_fichier-@seuil_lot_a_atteindre) ASC FOR UPDATE OF id_lot
					OPEN fichier_xml_jaidelachance_cursor
					FETCH NEXT FROM fichier_xml_jaidelachance_cursor
					INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
					IF @@CURSOR_ROWS = 0
					BEGIN
						PRINT 'Aucun fichier ne complète le lot.'
						SET @seuil_lot_a_atteindre = @seuil_lot_norme
						PRINT 'Changement de seuil : ' + cast(@seuil_lot_a_atteindre as varchar)
					END
					ELSE
						PRINT 'Fichier complétant le lot trouvé.'
					WHILE @@FETCH_STATUS = 0 AND @flag_lot_complet = 0
					BEGIN
						SET @nb_actes_lot = @nb_actes_lot + @nb_actes_fichier_dispo
						SET @nb_champs_lot = @nb_champs_lot + @nb_champs_fichier_dispo
						PRINT '3 - ' + CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_dispo AS VARCHAR(50)) + ' (' + @fichier_xml_dispo + ') - ' + CAST(@nb_champs_fichier_dispo AS varchar(512)) + ' - ajout au lot ' + CAST(@i AS varchar(512)) + ' (' + CAST(@id_lot AS VARCHAR(512))+ ') - nb champs du lot ' + CAST(@nb_champs_lot AS varchar(512))
						UPDATE #temp_fichiers SET id_lot=@id_lot WHERE CURRENT OF fichier_xml_jaidelachance_cursor
						--IF @nb_champs_lot>@seuil_lot
						IF @nb_champs_lot>=@seuil_lot_a_atteindre
						BEGIN
							PRINT '4 - ' + 'Lot ' + CAST(@i AS varchar(512)) + ' complet avec ' + CAST(@nb_champs_lot AS varchar(512)) + ' champs.'
							SET @flag_lot_complet = 1
							SET @flag_poursuite_lot = 0
						END
						FETCH NEXT FROM fichier_xml_jaidelachance_cursor
						INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
					END
					CLOSE fichier_xml_jaidelachance_cursor
					DEALLOCATE fichier_xml_jaidelachance_cursor
					
					--SI IL N'Y A PLUS DE FICHIER SANS LOT, ON SORT DE LA BOUCLE
					IF NOT EXISTS(SELECT TOP 1 id_fichier FROM #temp_fichiers WHERE id_lot IS NULL)
					BEGIN
						PRINT 'Plus de fichier sans lot.'
						SET @flag_poursuite_lot = 0
					END

					/*
					--SI IL FAUT COMPLETER LE LOT ET QU'IL RESTE DES FICHIERS SANS LOT
					IF (@flag_lot_complet = 0 AND @nb_champs_lot<@seuil_lot) AND EXISTS(SELECT id_fichier FROM #temp_fichiers WHERE id_lot IS NULL)
					BEGIN
						--ON PARCOURT DANS L'ORDRE DECROISSANT DU NOMBRE DE CHAMPS LES FICHIERS SANS LOT QUI ONT UN NOMBRE DE CHAMPS PERMETTANT DE S'APPROCHER AU MAX DU SEUIL
						DECLARE fichier_xml_dispo_cursor CURSOR 
							FOR SELECT TOP 1 id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL AND nb_champs_a_controler_fichier+@nb_champs_lot <= @plafond_lot ORDER BY nb_champs_a_controler_fichier DESC FOR UPDATE OF id_lot
						OPEN fichier_xml_dispo_cursor
						FETCH NEXT FROM fichier_xml_dispo_cursor
						INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
						IF @@CURSOR_ROWS = 0
							SET @flag_poursuite_lot = 0
						ELSE
							SET @flag_poursuite_lot = 1
						PRINT '@flag_poursuite_lot = ' + CAST(@flag_poursuite_lot AS VARCHAR(50))
						WHILE @@FETCH_STATUS = 0 AND @flag_lot_complet = 0
						BEGIN
							SET @flag_poursuite_lot = 1
							--ON AJOUTE LE FICHIER DANS LE LOT SI ON NE DEPASSE PAS LE PLAFOND
							IF @nb_actes_lot + @nb_actes_fichier_dispo <= @plafond_lot
							BEGIN
								SET @nb_actes_lot = @nb_actes_lot + @nb_actes_fichier_dispo
								SET @nb_champs_lot = @nb_champs_lot + @nb_champs_fichier_dispo
								PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_dispo AS VARCHAR(50)) + ' (' + @fichier_xml_dispo + ') - ' + CAST(@nb_champs_fichier_dispo AS varchar(512)) + ' - ajout au lot ' + CAST(@i AS varchar(512)) + ' - nb champs du lot ' + CAST(@nb_champs_lot AS varchar(512))
								UPDATE #temp_fichiers SET id_lot=@id_lot WHERE CURRENT OF fichier_xml_dispo_cursor
								IF @nb_champs_lot>@seuil_lot
								BEGIN
									SET @flag_lot_complet = 1
								END
							END
							FETCH NEXT FROM fichier_xml_dispo_cursor
							INTO @id_fichier_dispo, @fichier_xml_dispo, @nb_champs_fichier_dispo, @nb_actes_fichier_dispo, @id_lot_dispo
						END
						CLOSE fichier_xml_dispo_cursor
						DEALLOCATE fichier_xml_dispo_cursor
					END
					ELSE
					BEGIN
						SET @flag_poursuite_lot = 0
					END
						*/
					--SET @flag_poursuite_lot = 0
					set @flag_lot_complet = 0
					/*
					--EST-CE QU'ON PEUT RETIRER DES FICHIERS DU LOT SANS QU'IL PASSE SOUS LE SEUIL
					SET @excedent_lot = @nb_champs_lot - @seuil_lot
					--PRINT 'excédent restant 1 : ' + CAST(@excedent_lot AS varchar(512))
					SET @flag_fin_retrait_fichier = 0
					WHILE @excedent_lot>0 AND @flag_fin_retrait_fichier=0
					BEGIN
						SELECT TOP 1 @id_fichier_a_retirer=id_fichier, @nb_champs_a_retirer=nb_champs_a_controler_fichier FROM #temp_fichiers WHERE id_lot=@id_lot AND nb_champs_a_controler_fichier<=@excedent_lot ORDER BY nb_champs_a_controler_fichier DESC
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
					*/
				END
			END
		END
		
		/*
		--SI LA SOMME DES CHAMPS A CONTRÔLER DES FICHIERS SANS LOT EST INFERIEURE AU SEUIL VOULU MAIS SUPERIEURE OU EGAL AU SEUIL DE LA NORME
		SELECT @nb_champs_restants=ISNULL(SUM(nb_champs_a_controler_fichier), 0) FROM #temp_fichiers WHERE id_lot IS NULL
		PRINT CONVERT(varchar(50), getdate(), 131) + ' : Nb champs restants : ' + CAST(ISNULL(@nb_champs_restants, 0) AS varchar(512))
		IF (ISNULL(@nb_champs_restants, 0) < @seuil_lot)
		BEGIN
			SET @flag_exit = 1
		END
		*/

		--SI LA SOMME DES CHAMPS A CONTRÔLER DES FICHIERS SANS LOT EST INFERIEURE AU SEUIL VOULU, ON SORT DE LA BOUCLE
		SELECT @nb_champs_restants=SUM(nb_champs_a_controler_fichier) FROM #temp_fichiers WHERE id_lot IS NULL
		IF @dispatch_reste = 1
		BEGIN
			--SELECT @nb_champs_restants=SUM(nb_champs_a_controler_fichier) FROM #temp_fichiers WHERE id_lot IS NULL
			PRINT CONVERT(varchar(50), getdate(), 131) + ' : Nb champs restants : ' + CAST(ISNULL(@nb_champs_restants, 0) AS varchar(512))
			IF (ISNULL(@nb_champs_restants, 0) < @seuil_lot)
			BEGIN
				SET @flag_exit = 1
			END
		END
		ELSE IF @dispatch_reste = 0 AND (@nb_champs_restants BETWEEN @seuil_lot AND @plafond_lot)
		BEGIN
			SET @id_lot = newid()
		END
		FETCH NEXT FROM fichier_xml_cursor 
		INTO @id_fichier, @chemin_fichier, @nb_champs_a_controler_fichier, @nb_actes_fichier, @id_lot
	END 

	CLOSE fichier_xml_cursor
	DEALLOCATE fichier_xml_cursor

	SELECT * FROM #temp_fichiers order by id_lot asc
	SELECT id_lot, COUNT(DISTINCT id_fichier), SUM(nb_champs_a_controler_fichier)  FROM #temp_fichiers GROUP BY id_lot ORDER BY SUM(nb_champs_a_controler_fichier) DESC

	--SI LA SOMME DES CHAMPS A CONTRÔLER DES FICHIERS SANS LOT EST INFERIEURE AU SEUIL ALORS ON REPARTIE CES FICHIERS SUR LES DIFFERENTS LOTS
	--RESUME PAR LOT
	IF OBJECT_ID('tempdb..#recap_lots') is not null 
		DROP TABLE #recap_lots
	SELECT id_lot, SUM(nb_champs_a_controler_fichier) AS [Nb champs], COUNT(id_fichier) AS [Nb fichiers] INTO #recap_lots FROM #temp_fichiers WHERE id_lot IS NOT NULL GROUP BY id_lot HAVING SUM(nb_champs_a_controler_fichier)<@plafond_lot ORDER BY id_lot ASC
	--SELECT * FROM #recap_lots
	--TANT QU'IL Y A DES FICHIERS ORPHELINS DE LOT
	DECLARE fichier_xml_reste_cursor CURSOR 
		FOR SELECT id_fichier, chemin_fichier, nb_champs_a_controler_fichier, nb_actes, id_lot FROM #temp_fichiers WHERE id_lot IS NULL ORDER BY nb_champs_a_controler_fichier DESC FOR UPDATE OF id_lot
	OPEN fichier_xml_reste_cursor
	FETCH NEXT FROM fichier_xml_reste_cursor
	INTO @id_fichier_reste, @fichier_xml_reste, @nb_champs_fichier_reste, @nb_actes_fichier_reste, @id_lot_reste
	PRINT 'Nombre de fichiers orphelins de lot : ' + CAST(@@CURSOR_ROWS AS VARCHAR(512))
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_reste AS varchar(50))
		DECLARE @nb_champs as INT, @new_nb_champs as INT
		DECLARE @table_new_nb_champs table (nb_champs int NOT NULL);
		SET @id_lot_choisi = NULL
		SELECT TOP 1 @id_lot_choisi=id_lot, @nb_champs=[Nb champs] FROM #recap_lots WHERE [Nb champs]+@nb_champs_fichier_reste<=@plafond_lot ORDER BY ABS([Nb champs]+@nb_champs_fichier_reste-@seuil_lot) ASC
		PRINT '@nb_champs_fichier_reste = ' + CAST(@nb_champs_fichier_reste AS VARCHAR(52)) + ' / @nb_champs = ' + CAST(@nb_champs AS VARCHAR(52)) + ' / @id_lot_choisi = ' + CAST(@id_lot_choisi AS VARCHAR(52))
		IF @id_lot_choisi IS NOT NULL
		BEGIN
			PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + CAST(@id_fichier_reste AS VARCHAR(50)) + ' (' + @fichier_xml_reste + ') - ' + CAST(@nb_champs_fichier_reste AS varchar(512)) + ' - ajout au lot ' + CAST(@id_lot_choisi AS varchar(512)) + ' - nb champs du lot ' + CAST(@nb_champs AS varchar(512))
			PRINT CONVERT(varchar(50), getdate(), 131) + ' : Fichier ' + CAST(@id_fichier_reste AS varchar(512)) + ' dans lot ' + CAST(@id_lot_choisi AS varchar(512)) + ' : ' + CAST((@nb_champs + @nb_champs_fichier_reste) AS VARCHAR(512))
			UPDATE #temp_fichiers SET id_lot=@id_lot_choisi WHERE CURRENT OF fichier_xml_reste_cursor
			UPDATE #recap_lots SET [Nb champs]=[Nb champs]+@nb_champs_fichier_reste OUTPUT INSERTED.[Nb champs] INTO @table_new_nb_champs WHERE id_lot=@id_lot_choisi
			SELECT TOP 1 @new_nb_champs=nb_champs FROM @table_new_nb_champs
			PRINT 'Le lot ' + CAST(@id_lot_choisi AS VARCHAR(512)) + ' contient ' + CAST(@new_nb_champs as VARCHAR(512)) + ' champs'
		END
		FETCH NEXT FROM fichier_xml_reste_cursor 
		INTO @id_fichier_reste, @fichier_xml_reste, @nb_champs_fichier_reste, @nb_actes_fichier_reste, @id_lot_reste
	END
	CLOSE fichier_xml_reste_cursor
	DEALLOCATE fichier_xml_reste_cursor

	SELECT * FROM #temp_fichiers order by id_lot asc
	SELECT id_lot, COUNT(DISTINCT id_fichier) as nb_fichier, SUM(nb_actes) as nb_actes, SUM(nb_champs_a_controler_fichier) as nb_champs FROM #temp_fichiers GROUP BY id_lot ORDER BY SUM(nb_champs_a_controler_fichier) DESC

	/*
	SELECT * FROM #temp_lots
	SELECT * FROM #temp_fichiers order by id_lot asc
	SELECT id_lot, COUNT(DISTINCT id_fichier) AS [Nb fichiers], SUM(nb_champs_a_controler_fichier) AS [Nb champs]  FROM #temp_fichiers GROUP BY id_lot ORDER BY id_lot
	*/
	/* A DECOMMENTER POUR ECRITURE EN BDD*/
	IF @simulation=0
	BEGIN
		--SUPPRESSION DES ECHANTILLONS, DETACHEMENT DES FICHIERS AUX LOTS ET SUPPRESSION DES LOTS 
		--PUIS INSERTION DES LOTS DANS LA TABLE DataXml_lots_fichiers ET RATTACHEMENT DES FICHIERS (TABLE DataXml_fichiers) AUX LOTS
		BEGIN TRANSACTION
		BEGIN TRY
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
			
			--INSERTION DES LOTS
			PRINT CONVERT(varchar(50), getdate(), 131) + ' : Insertion des lots'
			INSERT INTO dbo.DataXml_lots_fichiers (id_lot, id_traitement, nom_lot, ordre) SELECT id_lot, id_traitement, 'Lot ' + CAST(ordre AS VARCHAR(10)) AS nom_lot, ordre FROM #temp_lots
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
	/**/
END
GO
