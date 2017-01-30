SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 02/04/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatsEchantillon] 
	@id_echantillon as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT te.libelle AS [Type d'erreur], COUNT(d.id) AS [Nb]
	FROM dbo.DataXmlEchantillonDetails (nolock) d 
	LEFT JOIN dbo.DataXmlTypesErreurs (nolock) te ON d.id_type_erreur=te.id_type_erreur
	INNER JOIN dbo.DataXmlTD_actes (nolock) a ON d.id_acte_TD=a.id
	WHERE d.id_echantillon=@id_echantillon AND traite=1
	GROUP BY te.libelle
	ORDER BY te.libelle DESC
	
END

GO
