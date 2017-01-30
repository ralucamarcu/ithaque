SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spReecritureCaractereRemplacement
	-- Add the parameters for the stored procedure here
	-- Test Run : spReecritureCaractereRemplacement '65042153-90E9-47E8-9BDA-C0DBE370EDD2'
	@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @table VARCHAR(255),@from_cond VARCHAR(2000)
	SET @table = 'dbo.DataXmlRC_actes'
	SET @from_cond = 'from DataXmlRC_actes dxa with (nolock)
	inner join DataXml_fichiers dxf with (nolock) on dxf.id_fichier = dxa.id_fichier
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement'	
	EXEC dbo.SearchAndReplace  @table, @from_cond, @id_projet, '§', '?'
	
	
	SET @table = 'dbo.DataXmlRC_individus'
	SET @from_cond = 'from dbo.DataXmlRC_individus dxi
	inner join DataXmlRC_actes dxa with (nolock) on dxi.id_acte = dxa.id
	inner join DataXml_fichiers dxf with (nolock) on dxf.id_fichier = dxa.id_fichier
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement'	
	EXEC dbo.SearchAndReplace  @table, @from_cond, @id_projet, '§', '?'
	
	
	SET @table = 'dbo.DataXmlRC_zones'
	SET @from_cond = 'from dbo.DataXmlRC_zones dxz
	inner join DataXmlRC_actes dxa with (nolock) on dxz.id_acte = dxa.id
	inner join DataXml_fichiers dxf with (nolock) on dxf.id_fichier = dxa.id_fichier
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement'	
	EXEC dbo.SearchAndReplace  @table, @from_cond, @id_projet, '§', '?'
	
	
	SET @table = 'dbo.DataXmlRC_individus_zones'
	SET @from_cond = 'from dbo.DataXmlRC_individus_zones dxiz
	inner join dbo.DataXmlRC_zones dxz on dxiz.id_zone = dxz.id_zone
	inner join DataXmlRC_actes dxa with (nolock) on dxz.id_acte = dxa.id
	inner join DataXml_fichiers dxf with (nolock) on dxf.id_fichier = dxa.id_fichier
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement'	
	EXEC dbo.SearchAndReplace  @table, @from_cond, @id_projet, '§', '?'
	
	
	
END
GO
