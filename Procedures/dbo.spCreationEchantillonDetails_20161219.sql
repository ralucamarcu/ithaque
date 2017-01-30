SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 11/09/2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spCreationEchantillonDetails_20161219] 
	@id_traitement INTEGER = NULL,
	@id_lot UNIQUEIDENTIFIER = NULL	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE @nb_champs_acte int, @nb_champs_individu int, @objectif_champs_echantillon int, @objectif_champs_echantillon_init int
	DECLARE @id_echantillon INT--, @id_lot UNIQUEIDENTIFIER
	DECLARE @nom_echantillon NVARCHAR(200)
	DECLARE @nb_champs INT, @nb_enregs INT
	DECLARE @sumsofar INT
	DECLARE @EchantillonEntete_Inserted table(id_echantillon int)
	SET @objectif_champs_echantillon_init = 315
	SET @nb_champs_acte = 1
	SET @nb_champs_individu = 2
	SET @objectif_champs_echantillon = 315

	BEGIN TRANSACTION
	BEGIN TRY

		--CREATION DES ENREGS DataXmlEchantillonEntete
		INSERT INTO dbo.DataXmlEchantillonEntete (id_traitement, nom_echantillon, date_creation, pourcent_selection_commune, pourcent_selection_echantillon, pourcent_echantillon_sur_totalite, flag_echantillon_communes, flag_echantillon_actes, type_echantillon, id_lot)
			OUTPUT INSERTED.id_echantillon
			INTO @EchantillonEntete_Inserted
		SELECT t.id_traitement, 'Echantillon - ' + lf.nom_lot, GETDATE(), NULL, NULL, NULL, 1, 1, NULL, id_lot
		FROM dbo.Traitements t (nolock)
		INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) ON t.id_traitement=lf.id_traitement
		WHERE t.id_traitement=@id_traitement AND (@id_lot IS NULL OR lf.id_lot=@id_lot)
		--GROUP BY t.id_traitement, 'Echantillon ' + cast(lf.id_lot as varchar) + ' - ' + t.nom, id_lot
		ORDER BY lf.ordre

		--NB DE CHAMPS A CONTRÔLER PAR ACTE
		IF OBJECT_ID('tempdb..#temp_actes') is not null 
			DROP TABLE #temp_actes
		SELECT a.id AS id_acte, f.id_fichier, lf.id_lot
--			, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END + SUM(CASE WHEN i.nom IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN i.prenom IS NOT NULL THEN 1 ELSE 0 END) AS nb_champs_a_controler_acte
			, 1 /*date_acte*/ + SUM(1+1 /*nom+prenom*/) AS nb_champs_a_controler_acte
			, NEWID() as rn
		INTO #temp_actes
		FROM dbo.Traitements t (nolock)
		INNER JOIN dbo.DataXmlRC_actes a (nolock) ON t.id_traitement=a.id_traitement
		INNER JOIN dbo.DataXmlRC_individus i (nolock) ON a.id=i.id_acte
		INNER JOIN dbo.DataXml_fichiers f (nolock) ON f.id_fichier=a.id_fichier
		INNER JOIN dbo.DataXml_lots_fichiers lf (nolock) ON lf.id_lot=f.id_lot
		WHERE t.id_traitement=@id_traitement
		GROUP BY a.id, f.id_fichier, lf.id_lot, CASE WHEN a.date_acte IS NOT NULL THEN 1 ELSE 0 END
		--SELECT * FROM #temp_actes

		CREATE NONCLUSTERED INDEX [IX_temp_actes_1]
		ON [dbo].[#temp_actes] ([id_lot])
		INCLUDE ([id_acte],[nb_champs_a_controler_acte],[rn])

		CREATE NONCLUSTERED INDEX [IX_temp_actes_2]
		ON [dbo].[#temp_actes] ([rn])

		--REMPLISSAGE DES ECHANTILLONS
		--SELECT id_echantillon, id_lot FROM dbo.DataXmlEchantillonEntete (nolock) WHERE id_traitement=@id_traitement ORDER BY id_echantillon
		DECLARE cur_lot CURSOR FOR
			SELECT ee.id_echantillon, ee.id_lot, ee.nom_echantillon FROM dbo.DataXmlEchantillonEntete ee (nolock) INNER JOIN @EchantillonEntete_Inserted ins ON ins.id_echantillon=ee.id_echantillon WHERE id_traitement=@id_traitement ORDER BY id_echantillon
			OPEN cur_lot
			FETCH NEXT FROM cur_lot
			INTO @id_echantillon, @id_lot, @nom_echantillon
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--ON RECALCULE @objectif_champs_echantillon EN FONCTION DE CE QUI EXISTE DEJA DANS L'ECHANTILLON
			SELECT @objectif_champs_echantillon = @objectif_champs_echantillon_init - SUM(nb_champs_a_controler_acte) FROM #temp_actes a INNER JOIN dbo.DataXmlEchantillonDetailsRC (nolock) ed ON a.id_acte=ed.id_acte_RC WHERE id_lot=@id_lot and id_echantillon=@id_echantillon
			SET @objectif_champs_echantillon=ISNULL(@objectif_champs_echantillon, @objectif_champs_echantillon_init)
			
			IF @objectif_champs_echantillon>0
			BEGIN
				IF OBJECT_ID('tempdb..#details') is not null 
				DROP TABLE #details
				;with numbered as
				(
				  -- this first query gives a sequential number to all records
				  -- the biggest quantities are number 1,2,3 etc to the smallest quantities
				  -- this ordering is because the minimum number of rows is most quickly
				  -- achieved by combining the biggest quantities
				  select a.id_acte, a.nb_champs_a_controler_acte, a.id_lot, a.id_fichier, RANK() over (order by rn) rn
				  from #temp_actes a
				  where 1=1 and a.id_lot=@id_lot
					--ON EXCLUT LES ACTES DEJA PRESENT DANS L'ECHANTILLON
					AND a.id_acte not in (SELECT id_acte_RC FROM dbo.DataXmlEchantillonDetailsRC (nolock) ed INNER JOIN dbo.DataXmlEchantillonEntete (nolock) ee ON ed.id_echantillon=ee.id_echantillon WHERE ee.id_traitement=@id_traitement and ee.id_lot=@id_lot)
				), cte as
				( 
				  -- this is a common table expression
				  -- it starts off with the record with the smallest rn
				  select id_acte, id_lot, nb_champs_a_controler_acte, rn, sumsofar = nb_champs_a_controler_acte
				  from numbered
				  where rn = 1

				  union all

				  -- this is the recursive part
				  -- "CTE" references the previous record in the loop
				  select b.id_acte, b.id_lot, b.nb_champs_a_controler_acte, b.rn, sumsofar + b.nb_champs_a_controler_acte
				  from numbered b
				  inner join cte a on b.rn = a.rn+1  -- add the next record (as ordered)
				  -- continue the loop only if the goal is not yet reached
				  where a.sumsofar + (1+2) <= @objectif_champs_echantillon AND a.sumsofar + b.nb_champs_a_controler_acte<=@objectif_champs_echantillon
				)
				
				-- this finally selects all the records that have been collected to satisfy the @goal
				select * into #details from cte order by sumsofar desc OPTION (MAXRECURSION 500)
				--SI ON PEUT COMPLETER AVEC UN ACTE
				SELECT @sumsofar = MAX(sumsofar) FROM #details
				--PRINT @sumsofar
				IF @sumsofar<=@objectif_champs_echantillon-(1+2)
				BEGIN
					INSERT INTO #details 
					SELECT TOP 1 a.id_acte, a.id_lot, a.nb_champs_a_controler_acte, NULL, sumsofar = @sumsofar + a.nb_champs_a_controler_acte FROM #temp_actes a LEFT JOIN #details d ON a.id_acte=d.id_acte WHERE a.id_lot=@id_lot AND d.id_acte IS NULL AND @sumsofar + a.nb_champs_a_controler_acte <= @objectif_champs_echantillon ORDER BY a.nb_champs_a_controler_acte
				END
				--SET @nb_enregs = @@ROWCOUNT
				SELECT @nb_enregs=COUNT(id_acte),@nb_champs=MAX(sumsofar) FROM #details
				PRINT CONVERT(varchar(50), getdate(), 131) + ' : ' + @nom_echantillon + ' (' + CAST(@id_lot AS VARCHAR(100)) + ') : ' + CAST(@nb_enregs AS VARCHAR) + ' enregs / ' + CAST(@nb_champs AS VARCHAR) + ' champs / @objectif_champs_echantillon : ' + CAST(@objectif_champs_echantillon AS VARCHAR)
				--PRINT 'Lot ' + CAST(@id_lot AS VARCHAR(100)) + ' : ' + CAST(@nb_enregs AS VARCHAR) + ' enregs / ' + CAST(@nb_champs AS VARCHAR) + ' champs'
				--SELECT *, @nom_echantillon FROM #details ORDER BY sumsofar desc
				
				--SELECT id_acte, COUNT(id_acte) FROM #details GROUP BY id_acte HAVING COUNT(id_acte)>1
				
				INSERT INTO dbo.DataXmlEchantillonDetailsRC (id_echantillon, id_acte_RC)
				SELECT @id_echantillon, id_acte FROM #details order by sumsofar
				--PRINT @@ROWCOUNT
			END
			FETCH NEXT FROM cur_lot 
			INTO @id_echantillon, @id_lot, @nom_echantillon
		END 
		CLOSE cur_lot
		DEALLOCATE cur_lot
		COMMIT TRANSACTION
		--ROLLBACK TRANSACTION
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
		SELECT * FROM dbo.DataXmlEchantillonEntete ee INNER JOIN dbo.DataXmlEchantillonDetailsRC ec ON ee.id_echantillon=ec.id_echantillon WHERE ee.id_traitement=@id_traitement
		--COMMIT TRANSACTION;
		--ROLLBACK TRANSACTION;
		/*
		SELECT lf.id_lot, lf.ordre, f.id_fichier
		FROM dbo.DataXml_lots_fichiers lf WITH (NOLOCK)
		INNER JOIN dbo.DataXml_fichiers f WITH (NOLOCK) ON lf.id_lot=f.id_lot
		WHERE lf.id_traitement=@id_traitement
		ORDER BY lf.ordre, f.id_fichier
		*/
	END    

END

GO
