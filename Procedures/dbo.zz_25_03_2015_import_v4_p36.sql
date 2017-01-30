SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE zz_25_03_2015_import_v4_p36
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @date datetime = getdate()
	insert into Images (id_source, id_projet, id_status_version_processus, locked, date_creation, path_origine, nom_fichier_origine)
	select 'B9AC2127-7E6D-4AB1-B08F-373A10552CBE' as id_source, '65042153-90E9-47E8-9BDA-C0DBE370EDD2' as id_projet
		, 4  as id_status_version_processus, 0 as locked, @date as date_creation, file_path  as path_origine
		, [FILE_NAME] as nom_fichier_origine
	from files3 with (nolock)

	insert into Taches_Images_Logs (id_image, path_origine, path_destination, id_tache, date_creation, nom_fichier_image_origine
	, nom_fichier_image_destination, id_status)
	select id_image, REPLACE(path_origine, '\V4\', '\V3\') as path_origine, path_origine as path_destination, 4 as id_tache
		, @date as date_creation, nom_fichier_origine as nom_fichier_image_origine, nom_fichier_origine as nom_fichier_image_destination
		, 2 as id_status
	from Images with (nolock)
	where id_source = 'B9AC2127-7E6D-4AB1-B08F-373A10552CBE'

	EXEC spMAJImagesAttributesImport @id_source = 'B9AC2127-7E6D-4AB1-B08F-373A10552CBE'
	, @path_general_v3 =  '\\10.1.0.196\bigvol\Projets\p36-TD69\V4\images\', @rc=0

	UPDATE DataXmlRC_zones
	SET id_image = tli.id_image
	FROM DataXmlRC_zones dxz WITH (NOLOCK)
	INNER JOIN Taches_Images_Logs tli WITH (NOLOCK)
		ON dxz.image = REPLACE((REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination))
			, 'V4\images', '\images')), '\', '/') + tli.nom_fichier_image_destination AND id_tache = 4
	inner join Images i with (nolock) on tli.id_image = i.id_image
	WHERE i.id_source = 'B9AC2127-7E6D-4AB1-B08F-373A10552CBE' and dxz.id_image IS NULL 

	exec [AEL_MAJ_Images_Traitements_Zonage] @id_projet ='65042153-90E9-47E8-9BDA-C0DBE370EDD2'
		,@id_document  = 'E36BAB6F-42F2-47E7-B54E-C45C907BCE38'



END
GO
