SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		select * from projets where id_departement = '02'
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--testrun: [create_zonage_table_ithaque_MAJ_MEP] 'F08A87A0-73C6-43FD-BCC8-2E1637BBE991'
CREATE PROCEDURE [dbo].[create_zonage_table_ithaque_MAJ_MEP] 
	-- Add the parameters for the stored procedure here
	@id_projet uniqueidentifier 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	create table Images_Traitements_zonage([id_image] [uniqueidentifier] NOT NULL,[id_projet] [uniqueidentifier] NOT NULL
	,[date_creation] [datetime] NULL,[chemin] [varchar](500) NULL,[id_images_traitements_sources] [int] )
	 create table tmp_zonage (text_zonage varchar(2000))
	 
	declare @nom_projet_dossier varchar(255), @command varchar(800), @nom_fichier varchar(50)
		, @id_departement varchar(10), @nb_images_zonage int, @id_document uniqueidentifier,@nom varchar(100)
	
	select @nom_projet_dossier = nom_projet_dossier, @id_departement = id_departement ,@nom=nom
	from ithaque.dbo.projets (NOLOCK)
	where id_projet  = @id_projet

	IF (@nom_projet_dossier LIKE '%-RC')
	BEGIN
		set @nom_fichier = @nom+'_zonage_dept' + @id_departement	
	END
	ELSE
	BEGIN
		set @nom_fichier = 'zonage_dept' + @id_departement	
	END
PRINT 1
	create table #tmp_fichiers(id_fichier uniqueidentifier)
	insert into #tmp_fichiers (id_fichier)
	select ae.id_fichier  
	from archives.dbo.MAJ_MEP_acte_xml_traitements_AcceptedEchantillon ae (NOLOCK)

	CREATE INDEX idx_idFichier ON #tmp_fichiers(id_fichier)

	INSERT INTO Images_Traitements_zonage(id_image, id_projet, date_creation, chemin, [id_images_traitements_sources])
	SELECT dxz.id_image, @id_projet AS id_projet
		, GETDATE() AS date_creation, m.[image] AS chemin, 1 AS [id_images_traitements_sources]
	FROM Ithaque.dbo.DataXmlRC_marges m(NOLOCK)
	INNER JOIN Ithaque.dbo.DataXmlRC_zones dxz WITH (NOLOCK) ON m.[image] = dxz.[image]
	INNER JOIN Ithaque.dbo.DataXmlRC_actes a WITH (NOLOCK) ON m.id_acte = a.id
	WHERE m.id_marge IN (
	SELECT id_marge FROM 
		(SELECT ROW_NUMBER() OVER (PARTITION BY a.id_acte_xml ORDER BY a.id ASC)  As list, m.id_marge
		FROM Ithaque.dbo.DataXmlRC_marges m(NOLOCK)
		INNER JOIN Ithaque.dbo.DataXmlRC_actes a (NOLOCK) ON m.id_acte = a.id	
		INNER JOIN Ithaque.dbo.DataXml_fichiers dxf WITH (NOLOCK) ON a.id_fichier = dxf.id_fichier
		inner join #tmp_fichiers t on dxf.id_fichier = t.id_fichier) AS dt
		WHERE list=1
		GROUP BY id_marge)
	and dxz.id_image is not null
	GROUP BY dxz.id_image, m.[image]
PRINT 3
	CREATE TABLE #temp_image_zones([path] VARCHAR(500),zone_left VARCHAR(50),zone_top VARCHAR(50),zone_right VARCHAR(50),zone_bottom VARCHAR(50),id_image uniqueidentifier)
	INSERT INTO #temp_image_zones ([path],zone_left,zone_top,zone_right,zone_bottom,id_image)
	SELECT DISTINCT dxz.image as path, dxm.rect_x1 as zone_left,dxm.rect_y1 as zone_top,dxm.rect_x2 as zone_right,dxm.rect_y2 as zone_bottom,dxz.id_image
		FROM #tmp_fichiers f
		INNER JOIN DataXmlRC_actes a with (nolock)  ON a.id_fichier=f.id_fichier 
		INNER JOIN DataXmlRC_marges dxm with (nolock) ON dxm.id_acte = a.id 
		INNER JOIN DataXmlRC_zones dxz WITH (nolock) ON dxm.[image] = dxz.[image] 

	CREATE INDEX idx_id_image ON #temp_image_zones(id_image)
	 
	 DECLARE @id_image uniqueidentifier, @source varchar(255)=null, @dest varchar(255)=null
		,@path varchar(255), @zone_left int, @zone_top int, @zone_right int, @zone_bottom int
		,@text_zonage varchar(2000) = null,@path1 varchar(255) = NULL
PRINT 4
	 DECLARE cursor_1 cursor for
	 select id_image from Images_Traitements_zonage
	 open cursor_1
	 fetch cursor_1 into @id_image
	 while @@FETCH_STATUS = 0
	 begin
		set @source = replace(@nom_projet_dossier + '\V3\images\', '\','/')
		set @dest = replace(@nom_projet_dossier + '\images\', '\','/')
		
		set @path1 = (select distinct [image] from DataXmlRC_zones with (nolock) where id_image = @id_image)
		set @path1 = REPLACE (@path1, '/images/', '')
		set @text_zonage = '$SRC/' + @source + @path1 + ';'
		declare cursor_2 cursor for
		--select  distinct dxz.image as path, dxm.rect_x1 as zone_left,dxm.rect_y1 as zone_top,dxm.rect_x2 as zone_right,dxm.rect_x2 as zone_bottom 
		--  --from DataXmlRC_marges dxm with (nolock) 
		--  --inner join DataXmlRC_zones dxz with (nolock) on dxm.[image] = dxz.[image] 
		--  --inner join DataXmlRC_actes a with (nolock) on dxm.id_acte = a.id 
		--  --inner join DataXml_fichiers f (nolock) on a.id_fichier=f.id_fichier 
		--  --inner join DataXmlEchantillonEntete e (nolock) on e.id_lot = f.id_lot 
		--  where dxz.id_image = @id_image

		SELECT [path],zone_left,zone_top,zone_right,zone_bottom FROM #temp_image_zones tiz WHERE id_image = @id_image

		 open cursor_2
		 fetch cursor_2 into @path, @zone_left, @zone_top, @zone_right, @zone_bottom
		 while @@FETCH_STATUS = 0
		 begin
			set @text_zonage = @text_zonage + '-draw "rectangle ' 
				+ cast(@zone_left as varchar(50)) + ',' + cast(@zone_top as varchar(50)) + ' ' 
				+ cast(@zone_right as varchar(50))+ ',' + cast(@zone_bottom as varchar(50)) + '" ' 
			fetch cursor_2 into @path, @zone_left, @zone_top, @zone_right, @zone_bottom
		 end
		 close cursor_2
		 deallocate cursor_2
		 
		 set @path1 = REPLACE(@path1, '.jpg', '.jp2')
		 set @text_zonage = rtrim(ltrim(@text_zonage)) 
		 set @text_zonage = @text_zonage + ';$DEST/'
			+ @dest + @path1
			
		insert into tmp_zonage (text_zonage)
		select @text_zonage
		
		set @source = null
		set @dest = null
		set @path1 = null
		set @text_zonage = null
		fetch cursor_1 into @id_image
	 end
	 close cursor_1
	 deallocate cursor_1
 PRINT 5
	 
	 set @nb_images_zonage = (select count(*) from tmp_zonage)
 
	IF (@nom_projet_dossier LIKE '%-RC')
	BEGIN
		set @command = '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\bcp.exe" [Ithaque].[dbo].[tmp_zonage] out \\10.1.0.196\bigvol\Jobs\zonage_fichiers_recensement_update\' 
		+ @nom_fichier + '.txt -T -E -SARDSQL02\ARDSQL02FR -t -c'
	END
	ELSE
	BEGIN
	 set @command = '"C:\Program Files\Microsoft SQL Server\100\Tools\Binn\bcp.exe" [Ithaque].[dbo].[tmp_zonage] out \\10.1.0.196\bigvol\Jobs\zonage_fichiers_update\' 
		+ @nom_fichier + '.txt -T -E -SARDSQL02\ARDSQL02FR -t -c'
	END

	EXEC master..xp_CMDShell @command
	print @command
PRINT 6
	print 'Pour id_projet: ' + cast(@id_projet as varchar(255)) + '  id_projet: ' + cast(@id_projet as varchar(255)) 
		+ ' et nom_projet_dossier:' + @nom_projet_dossier
		+ ' -> nb_images_zonage = ' + cast(@nb_images_zonage as varchar(50))
	
	
	create table #tmp (subdirectory varchar(160), depth int, [file] int)
	insert into #tmp		
	exec xp_dirtree '\\10.1.0.196\bigvol\Jobs\zonage_fichiers_update',1,1

	--if (select count(*) from #tmp where subdirectory = @nom_fichier + '.txt') > 0
	--begin
	--	--update saisie_donnees_documents
	--	--set zonage_fichier = 1
	--	--where id_document = @id_document
	--end
	
	update projets
	set zonage_fichier = 1
		,nb_img_zonage = @nb_images_zonage
	where id_projet = @id_projet
	
	set @id_document = (select id_document from AEL_Parametres_nouveau where id_projet = @id_projet)
	
	update archives.dbo.saisie_donnees_documents
	set zonage_fichier = 1
	where id_document = @id_document
	
	drop table #tmp

	drop table Images_Traitements_zonage
	drop table tmp_zonage
END


--select count(*) from Images_Traitements_zonage
--select count(*) from tmp_zonage
GO
