SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spTest_actes_rhone_single_acte_preprod
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @id_acte_xml varchar(100),
			@id_acte_ithaque bigint,
			@lieu_acte_ithaque varchar(100),
			@nom_ithaque varchar(100),
			@prenom_ithaque varchar(100),
			@id_acte_archives uniqueidentifier,
			@lieu_acte_archives varchar(100),
			@nom_archives varchar(100),
			@prenom_archives varchar(100)


--    SELECT DISTINCT id_acte_xml INTO temp_acte_xml_ithaque_test from [temp_departement_acte_xml_rhone_nom_prenom_ithaque] (NOLOCK)
----	ALTER TABLE temp_acte_xml_ithaque_test add id_acte_archives uniqueidentifier, id_acte_ithaque bigint, flag int

	DECLARE id_acte_xml_cursor CURSOR FOR
	SELECT id_acte_xml FROM temp_acte_xml_ithaque_test where id_acte_xml not like'%?%' and flag is null
	OPEN id_acte_xml_cursor
	FETCH NEXT FROM id_acte_xml_cursor INTO  @id_acte_xml
	WHILE @@FETCH_STATUS=0

	BEGIN 
--select @id_acte_xml

		SELECT TOP 1 @id_acte_ithaque=id_acte_ithaque from [temp_departement_acte_xml_rhone_nom_prenom_ithaque] (NOLOCK) where id_acte_xml=@id_acte_xml
		SELECT id_acte_ithaque,lieu_acte_ithaque,nom_ithaque,prenom_ithaque
		INTO #temp_details_actes_ithaque 
		FROM [temp_departement_acte_xml_rhone_nom_prenom_ithaque] (nolock) where id_acte_ithaque=@id_acte_ithaque
		GROUP BY id_acte_ithaque,lieu_acte_ithaque,nom_ithaque,prenom_ithaque

	--select @id_acte_ithaque
	 
		SELECT TOP 1 @id_acte_archives=id_acte_archives from [temp_departement_acte_xml_rhone_nom_prenom] (NOLOCK) where id_acte_xml=@id_acte_xml
		SELECT id_acte_archives,lieu_acte_archives,nom_archives,prenom_archives
		INTO #temp_details_actes_archives
		FROM [temp_departement_acte_xml_rhone_nom_prenom] (nolock) where id_acte_archives=@id_acte_archives
		GROUP BY id_acte_archives,lieu_acte_archives,nom_archives,prenom_archives
	
	--SELECT @id_acte_archives

	--SELECT * FROM #temp_details_actes_ithaque
	--SELECT * FROM #temp_details_actes_archives

		DECLARE nom_prenom_cursor CURSOR FOR
		SELECT nom_ithaque,prenom_ithaque,lieu_acte_ithaque FROM #temp_details_actes_ithaque
		OPEN nom_prenom_cursor
		FETCH NEXT FROM nom_prenom_cursor INTO  @nom_ithaque,@prenom_ithaque,@lieu_acte_ithaque
		WHILE @@FETCH_STATUS=0

		BEGIN
--select 'CURSOR 2'
			IF EXISTS(SELECT nom_archives,prenom_archives FROM #temp_details_actes_archives where nom_archives collate database_default=@nom_ithaque AND prenom_archives collate database_default=@prenom_ithaque AND lieu_acte_archives collate database_default=@lieu_acte_ithaque)
			BEGIN 
--select 'EXISTS'
				DELETE FROM #temp_details_actes_ithaque where nom_ithaque=@nom_ithaque AND prenom_ithaque=@prenom_ithaque AND lieu_acte_ithaque=@lieu_acte_ithaque
			END
			--ELSE 
			--BEGIN
			--	select 'NOT EXISTS'
		--	END
			FETCH NEXT FROM nom_prenom_cursor INTO  @nom_ithaque,@prenom_ithaque,@lieu_acte_ithaque
			
		END
--select 'ed cursor 2'
		CLOSE nom_prenom_cursor
		DEALLOCATE nom_prenom_cursor

		IF EXISTS (select * from #temp_details_actes_ithaque)
		BEGIN
--select 'NOK'
			UPDATE temp_acte_xml_ithaque_test
			SET id_acte_archives=@id_acte_archives,
				id_acte_ithaque=@id_acte_ithaque,
				flag=1 -- NOK
			WHERE id_acte_xml=@id_acte_xml
		END
		ELSE
		BEGIN
--SELECT 'OK'
			UPDATE temp_acte_xml_ithaque_test
			SET id_acte_archives=@id_acte_archives,
				id_acte_ithaque=@id_acte_ithaque,
				flag=2 -- OK
			WHERE id_acte_xml=@id_acte_xml
		END
		
		DROP TABLE #temp_details_actes_ithaque
		DROP TABLE #temp_details_actes_archives
		
		FETCH NEXT FROM id_acte_xml_cursor INTO  @id_acte_xml
		
	END
	CLOSE id_acte_xml_cursor
	DEALLOCATE id_acte_xml_cursor


END
GO
