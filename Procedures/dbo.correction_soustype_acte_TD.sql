SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 16/05/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[correction_soustype_acte_TD] 
	@id_traitement as int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.DataXmlTD_actes SET soustype_xml_acte=soustype_acte WHERE id_traitement=@id_traitement AND soustype_xml_acte IS NULL

	UPDATE dbo.DataXmlTD_actes SET soustype_acte=REPLACE(soustype_acte,'tablesDecennales_','') WHERE id_traitement=@id_traitement AND soustype_xml_acte IS NOT NULL AND soustype_acte LIKE 'tablesDecennales_%'

END

GO
