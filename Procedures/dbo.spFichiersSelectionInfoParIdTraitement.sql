SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spFichiersSelectionInfoParIdTraitement 
	-- Add the parameters for the stored procedure here
	@id_traitement int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT dxf.nom_fichier, fd.version_valide, fd.nb_images, fd.nb_actes, fd.nb_individus
	from DataXml_fichiers dxf with (nolock)
	inner join FichiersData fd with (nolock) on dxf.nom_fichier = fd.nom	
	where dxf.id_traitement = @id_traitement
	group by dxf.nom_fichier, fd.version_valide, fd.nb_images, fd.nb_actes, fd.nb_individus
END
GO
