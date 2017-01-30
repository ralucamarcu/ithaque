SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesCommunesRC] 
	@id_traitement as int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT lieu_acte as [Commune], geonameid_acte as GeonameId, nb_actes as [Nb d'actes], nb_individus as [Nb d'individus], nb_caracteres as [Nb de caracteres],nb_images as [Nb d'images], nb_fichiers_XML as [Nb de fichiers XML]
	FROM dbo.DataXmlStatsCommunesRC (NOLOCK) 
	WHERE id_traitement=@id_traitement
	ORDER BY lieu_acte ASC
END

GO
