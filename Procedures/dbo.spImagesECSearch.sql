SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robillard Frédéric
-- Create date: 01/06/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spImagesECSearch]
	@id_traitement as int,
	@id_type_acte as integer,
	@date_min as varchar(50),
	@date_max as varchar(50),
	@lieu as varchar(250)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @sql as varchar(MAX)
	DECLARE @type_acte as varchar(50)
	DECLARE @soustype_acte as varchar(50)
	SET @sql = ''	
	SELECT @type_acte=type_acte, @soustype_acte=soustype_acte FROM dbo.vue_Types_Actes_Traitement WHERE id=@id_type_acte

	SET @sql = @sql + 'SELECT DISTINCT z.image /*, a.type_acte, a.soustype_acte, isnull(a.date_acte_gregorienne, a.date_acte), a.date_acte, a.date_acte_gregorienne, a.lieu_acte*/ '
	SET @sql = @sql + 'FROM dbo.DataXmlEC_actes (NOLOCK) a '
	SET @sql = @sql + 'INNER JOIN DataXmlEC_zones (NOLOCK) z ON a.id=z.id_acte '
	SET @sql = @sql + 'WHERE a.id_traitement=' + cast(@id_traitement as varchar(10)) + ' '
	IF @type_acte IS NOT NULL
		SET @sql = @sql + 'AND a.type_acte=''' + @type_acte + ''' '
	IF @soustype_acte IS NOT NULL
		SET @sql = @sql + 'AND a.soustype_acte=''' + @soustype_acte + ''' '
	IF (@date_min IS NOT NULL) AND (ISDATE(@date_min)=1)
		SET @sql = @sql + 'AND a.date_acte_gregorienne>=''' + @date_min + ''' '
	IF (@date_max IS NOT NULL) AND (ISDATE(@date_max)=1)
		SET @sql = @sql + 'AND a.date_acte_gregorienne<=''' + @date_max + ''' '
	IF @lieu IS NOT NULL
		SET @sql = @sql + 'AND a.lieu_acte like ''' + replace(@lieu,'''', '''''') + ''' '
	SET @sql = @sql + 'ORDER BY z.image ASC'
	
	PRINT @sql
	EXECUTE(@sql)
END

GO
