SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/01/2016
-- Description:	Importation Saisie -> create files & insert pages and images on Archives_Preprod database
-- =============================================
-- testrun: [dbo].[spImportationSaisie_BulkInsertPagesImages] '69689087-9FA6-477D-9F56-896DE7884F5D','794D0CF7-9B6A-4EE7-B277-819C88F4FC5E','2016-01-08'
CREATE PROCEDURE [dbo].[spImportationSaisie_BulkInsertPagesImages] 
	@id_projet uniqueidentifier,
	@id_document uniqueidentifier,
	@date_publication datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @command varchar(800), @id_image_max bigint
	SET @id_image_max= (SELECT max(id_image) FROM [PRESQL04].[Archives_Preprod].[dbo].[Saisie_donnees_images])
	
	IF OBJECT_id('saisie_donnees_pages_preprod') IS NOT NULL
	BEGIN
		DROP TABLE saisie_donnees_pages_preprod
		CREATE TABLE [dbo].[saisie_donnees_pages_preprod]([id_page] [uniqueidentifier] NOT NULL,[description] [varchar](50) NULL,[image_viewer] [varchar](255) NULL
					,[image_miniature] [varchar](255) NULL,	[image_origine] [varchar](255) NULL,[id_document] [uniqueidentifier] NULL,[ordre] [int] NULL,[fenetre_navigation] [int] NULL
					,[id_lot] [int] NOT NULL,[visible] [bit] NOT NULL,[date_creation] [datetime] NULL, [affichage_image] [bit] NOT NULL,[ordre_fichier_xml] [int] NULL,[id_fichier_xml] [int] NULL
					,[id_statut] [int] NULL,[cote] [varchar](50) NULL,[id_fichier_xml_test] [int] NULL,[date_modification] [datetime] NULL)
		print 1
	END

	IF OBJECT_id('saisie_donnees_images') IS NOT NULL
	BEGIN
		DROP TABLE saisie_donnees_images
		CREATE TABLE [dbo].[Saisie_donnees_images]([id_image] [int] NOT NULL,[path] [varchar](500) NULL,[zones_a_traiter] [bit] NULL,[zones_traitees] [datetime] NULL,[jp2_a_traiter] [bit] NULL,
					 [jp2_traitee] [datetime] NULL,[id_page] [uniqueidentifier] NULL,[id_document] [uniqueidentifier] NULL,[status] [int] NOT NULL,[date_status] [datetime] NULL,[production] [bit] NULL,
					 [date_production] [datetime] NULL,[thumb_a_traiter] [bit] NULL,[thumb_traitee] [datetime] NULL,[taille_img_verifie] [int] NULL,[id_fichier_xml] [uniqueidentifier] NULL,[date_creation] [datetime] NULL)
		print 2
	END

	-- ithaque temp tables
	CREATE TABLE #valid_fichiers (subdirectory varchar(255), deprth int, [file] int)
	CREATE TABLE #temp_command_create_file (command varchar(800))

	INSERT INTO [dbo].[saisie_donnees_pages_preprod]([id_page],[description],[image_viewer],[image_miniature],[image_origine],[id_document],[ordre],[fenetre_navigation],[id_lot],[visible],[date_creation]
           ,[affichage_image],[ordre_fichier_xml],[id_fichier_xml],[id_statut],[cote],[id_fichier_xml_test],[date_modification])
	SELECT newid(), NULL AS [description]
           ,REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
				+ tli.nom_fichier_image_destination AS [image_viewer]
           ,NULL AS [image_miniature]
           ,REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
				+ tli.nom_fichier_image_destination AS [image_origine]
           ,@id_document AS [id_document],NULL AS [ordre],NULL AS [fenetre_navigation],1 AS [id_lot],1 AS [visible],@date_publication AS [date_creation],1 AS [affichage_image]
		   ,NULL AS [ordre_fichier_xml],NULL AS [id_fichier_xml],NULL AS [id_statut],NULL AS [cote],NULL AS [id_fichier_xml_test],NULL AS [date_modification]
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
	WHERE id_projet = @id_projet AND tli.id_tache = 4

	
	INSERT INTO  [dbo].[Saisie_donnees_images]([id_image],[path],[zones_a_traiter],[zones_traitees],[jp2_a_traiter],[jp2_traitee],[id_page],[id_document],[status],[date_status],[production]
				,[date_production],[thumb_a_traiter],[thumb_traitee],[taille_img_verifie],[id_fichier_xml],[date_creation])
	SELECT  ROW_NUMBER() OVER (ORDER BY REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
				+ tli.nom_fichier_image_destination)+@id_image_max AS [id_image]
           ,REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
				+ tli.nom_fichier_image_destination AS [path], NULL AS [zones_a_traitees]
           ,NULL AS [zones_traitees],(CASE WHEN id_acte IS NOT NULL THEN 1 ELSE 0 END) AS [jp2_a_traiter],NULL AS [jp2_traitee],NULL AS [id_page],@id_document AS [id_document],0 AS [status]
           ,NULL AS [date_status],NULL AS [production],NULL AS [date_production],(CASE WHEN id_acte IS NOT NULL THEN 1 ELSE 0 END) AS [thumb_a_traiter],NULL AS [thumb_traitee]
           ,NULL AS [taille_img_verifie],dxa.id_fichier AS [id_fichier_xml],@date_publication AS [date_creation]
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
	LEFT JOIN tmp_images_actes t ON i.id_image = t.id_image
	LEFT JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON t.id_acte = dxa.id
	WHERE id_projet = @id_projet AND tli.id_tache = 4
	GROUP BY REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
				+ tli.nom_fichier_image_destination, (CASE WHEN id_acte IS NOT NULL THEN 1 ELSE 0 END),dxa.id_fichier
	
	INSERT INTO #valid_fichiers
	EXEC xp_dirtree '\\10.1.0.196\bigvol\ImportationSaisie_ImportPagesImages\', 1,1
	
	IF EXISTS(SELECT * FROM #valid_fichiers t )
	BEGIN
		EXEC xp_cmdshell 'DEL \\10.1.0.196\bigvol\ImportationSaisie_ImportPagesImages\*.dat'
	END
	
	INSERT INTO #temp_command_create_file(command)
	select '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\bcp.exe" '
		+  QUOTENAME(DB_NAME())+ '.' /* Current Database */
		+  QUOTENAME(SCHEMA_NAME(SCHEMA_ID))+'.'            
		+  QUOTENAME(name)  
		+  ' out \\10.1.0.196\bigvol\ImportationSaisie_ImportPagesImages\' 
		+  REPLACE(SCHEMA_NAME(schema_id),' ','') + '_' 
		+  REPLACE(name,' ','') + '_' 
		+ cast(day(getdate()) AS varchar(5)) + cast(month(getdate()) AS varchar(5)) + cast(year(getdate()) AS varchar(5))
		+ '.dat -T -E -SARDSQL02\ARDSQL02FR -n -t' /* ServerName, -E will take care of Identity, -n is for Native Format */
	from sys.tables
	where name in ('saisie_donnees_pages_preprod','saisie_donnees_images')


	DECLARE cursor_import_file CURSOR FOR
	select command from #temp_command_create_file tcf
	OPEN cursor_import_file
	FETCH cursor_import_file INTO @command
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC master..xp_CMDShell @command
		FETCH cursor_import_file INTO @command
	END
	CLOSE cursor_import_file
	DEALLOCATE cursor_import_file

	EXEC [PRESQL04].[Archives_Preprod].[dbo].[spImportationSaisie_BulkInsertPagesImages_ArchivesPreprod]

	DROP TABLE #temp_command_create_file
	DROP TABLE #valid_fichiers

END


GO
