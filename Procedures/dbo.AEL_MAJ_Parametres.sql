SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_MAJ_Parametres]
	-- Add the parameters for the stored procedure here
	@titre_document VARCHAR(255) = NULL
	,@description VARCHAR(255) = NULL
	,@miniature_document VARCHAR(255) = NULL
	,@sous_titre VARCHAR(255) = NULL
	,@image_principale VARCHAR(255) = NULL
	,@image_secondaire VARCHAR(255) = NULL
	,@publie BIT = NULL
	,@id_projet UNIQUEIDENTIFIER = NULL
	,@chemin_dossier_v4 VARCHAR(255) = NULL
	,@chemin_dossier_v5 VARCHAR(255) = NULL
	,@chemin_xml VARCHAR(255) = NULL
	,@id_association INT = NULL
	,@chemin_dossier_v6 VARCHAR(255) = NULL
	,@chemin_dossier_general VARCHAR(255) = NULL
	,@id_livraisons VARCHAR(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.AEL_Parametres
	SET [titre_document] = (CASE WHEN @titre_document IS NOT NULL THEN @titre_document ELSE titre_document END)
		,[description] = (CASE WHEN @description IS NOT NULL THEN @description ELSE [description] END)
		,[miniature_document] = (CASE WHEN @miniature_document IS NOT NULL THEN @miniature_document ELSE miniature_document END)
		,[sous_titre] = (CASE WHEN @sous_titre IS NOT NULL THEN @sous_titre ELSE sous_titre END)
		,[image_principale] = (CASE WHEN @image_principale IS NOT NULL THEN @image_principale ELSE image_principale END)
		,[image_secondaire] = (CASE WHEN @image_secondaire IS NOT NULL THEN @image_secondaire ELSE image_secondaire END)
        ,[publie] = (CASE WHEN @publie IS NOT NULL THEN @publie ELSE publie END)
        ,[id_projet] = (CASE WHEN @id_projet IS NOT NULL THEN @id_projet ELSE id_projet END)
        ,[chemin_dossier_v4] = (CASE WHEN @chemin_dossier_v4 IS NOT NULL THEN @chemin_dossier_v4 ELSE chemin_dossier_v4 END)
        ,[chemin_dossier_v5] = (CASE WHEN @chemin_dossier_v5 IS NOT NULL THEN @chemin_dossier_v5 ELSE chemin_dossier_v5 END)
        ,[chemin_xml] = (CASE WHEN @chemin_xml IS NOT NULL THEN @chemin_xml ELSE chemin_xml END)
        ,[id_association] = (CASE WHEN @id_association IS NOT NULL THEN @id_association ELSE id_association END)
        ,[chemin_dossier_v6] = (CASE WHEN @chemin_dossier_v6 IS NOT NULL THEN @chemin_dossier_v6 ELSE chemin_dossier_v6 END)
        ,[chemin_dossier_general] = (CASE WHEN @chemin_dossier_general IS NOT NULL THEN @chemin_dossier_general ELSE chemin_dossier_general END)
		,id_livraisons = (CASE WHEN @id_livraisons IS NOT NULL THEN @id_livraisons ELSE id_livraisons END)     
      WHERE principal = 1
END
GO
