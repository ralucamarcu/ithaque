SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 04/12/2012
-- Description:	Renseigne le rang d'un individu au sein de son acte
-- =============================================
CREATE PROCEDURE [dbo].[spCalculRangIndividus]
	-- Add the parameters for the stored procedure here
	@id_traitement integer
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT OFF;

	IF EXISTS(SELECT TOP 1 id_traitement FROM dbo.Traitements WHERE id_traitement=@id_traitement)
	BEGIN
		SELECT ind.id, RANK() OVER (PARTITION BY ind.id_acte ORDER BY ind.id_acte, ind.id) as rang 
		INTO #temp_rang
		FROM dbo.DataXmlTD_individus (NOLOCK) ind
		INNER JOIN dbo.DataXmlTD_actes (NOLOCK) a ON ind.id_acte=a.id
		where id_traitement=@id_traitement
		order by ind.id_acte, id

		UPDATE dbo.DataXmlTD_individus SET rang=rang.rang
		FROM dbo.DataXmlTD_individus (nolock) i 
		INNER JOIN #temp_rang rang ON i.id=rang.id
	END
END

GO
