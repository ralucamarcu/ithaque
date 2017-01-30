SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesCommunes] 
	@id_traitement as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT lieu_acte as [Commune], geonameid_acte as GeonameId, nb_actes_TD as [Nb d'actes TD], nb_actes_EC as [Nb d'actes EC], nb_actes_TD_orphelins as [Nb d'actes TD orphelins], CASE WHEN nb_actes_TD_orphelins>0 THEN (CAST(nb_actes_TD_orphelins AS FLOAT)/CAST(nb_actes_TD AS FLOAT)*100) ELSE NULL END [Ratio des actes TD orphelins], nb_actes_EC_orphelins as [Nb d'actes EC orphelins], CASE WHEN nb_actes_EC_orphelins>0 THEN (CAST(nb_actes_EC_orphelins AS FLOAT)/CAST(nb_actes_EC AS FLOAT)*100) ELSE NULL END [Ratio des actes EC orphelins], nb_actes_TD_trouves as [Nb d'actes TD avec correspondance EC], nb_actes_EC_trouves as [Nb d'actes EC avec correspondance TD]
	FROM dbo.DataXmlStatsCommunes (NOLOCK) 
	WHERE id_traitement=@id_traitement
	ORDER BY lieu_acte ASC
END

GO
