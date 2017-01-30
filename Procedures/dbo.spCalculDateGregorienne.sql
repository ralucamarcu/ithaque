SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Robillard Frédéric
-- Create date: 08/06/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spCalculDateGregorienne]
	@id_traitement as int,
	@type_xml as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @type_xml = 'EC'
	BEGIN
		UPDATE [dbo].[DataXmlEC_actes] 
		SET date_acte_gregorienne=CASE ISDATE(date_acte) WHEN 1 THEN date_acte WHEN 0 THEN dbo.DateRepublicaineEnGregorienne(date_acte) END
		WHERE id_traitement=@id_traitement
	END
	ELSE IF @type_xml = 'TD'
	BEGIN
		UPDATE [dbo].[DataXmlTD_actes] 
		SET date_acte_gregorienne=CASE ISDATE(date_acte) WHEN 1 THEN date_acte WHEN 0 THEN dbo.DateRepublicaineEnGregorienne(date_acte) END
		WHERE id_traitement=@id_traitement
	END
	
END

GO
