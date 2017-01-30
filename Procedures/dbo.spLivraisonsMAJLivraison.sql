SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsMAJLivraison] 
	-- Add the parameters for the stored procedure here
	@id_traitement INT
	,@type_livraison INT = NULL
	,@nom VARCHAR(800) = NULL
	,@dossier_xml_controle_conformite VARCHAR(800) = NULL
	,@dossier_xml_cq VARCHAR(800) = NULL
	,@dossier_images  VARCHAR(800) = NULL
	,@objectif_min INT = NULL
	,@dossier_source_export VARCHAR(800) = NULL
    ,@dossier_destination_export VARCHAR(800) = NULL
    ,@informations VARCHAR(800) = NULL
    ,@date_livraison DATETIME = NULL
    ,@date_publication DATETIME = NULL
    ,@date_reecriture DATETIME = NULL
    ,@date_retour_conformite DATETIME = NULL
    ,@date_retour_cq DATETIME = NULL
    ,@livraison_conforme BIT = NULL
    ,@import_xml BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE Traitements
	SET	[id_type_traitement] = (CASE WHEN @type_livraison IS NOT NULL THEN @type_livraison ELSE id_type_traitement END)
      ,[nom] = (CASE WHEN @nom IS NOT NULL THEN @nom ELSE nom END)
      ,dossier_livraison = (CASE WHEN @dossier_xml_controle_conformite IS NOT NULL THEN @dossier_xml_controle_conformite ELSE dossier_livraison END)
      ,[folder_XML] = (CASE WHEN @dossier_xml_cq IS NOT NULL THEN @dossier_xml_cq ELSE folder_XML END)
      ,[folder_images] = (CASE WHEN @dossier_images IS NOT NULL THEN @dossier_images ELSE folder_images END)
      ,[objectif_effectif_min] = (CASE WHEN @objectif_min IS NOT NULL THEN @objectif_min ELSE [objectif_effectif_min]  END)
      ,[dossier_source_export] = (CASE WHEN @dossier_source_export IS NOT NULL THEN @dossier_source_export ELSE [dossier_source_export] END)
      ,[dossier_destination_export] = (CASE WHEN @dossier_destination_export IS NOT NULL THEN @dossier_destination_export ELSE [dossier_destination_export] END)
      ,[remarques] = (CASE WHEN @informations IS NOT NULL THEN @informations ELSE [remarques] END)
      ,[date_livraison] = (CASE WHEN @date_livraison IS NOT NULL THEN @date_livraison ELSE [date_livraison] END)
      ,[date_publication] = (CASE WHEN @date_publication IS NOT NULL THEN @date_publication ELSE [date_publication] END)
      ,[date_retour_cq] = (CASE WHEN @date_retour_cq IS NOT NULL THEN @date_retour_cq ELSE [date_retour_cq] END)
      ,[date_retour_conformite_xml] = (CASE WHEN @date_retour_conformite IS NOT NULL THEN @date_retour_conformite ELSE [date_retour_conformite_xml] END)
      ,[date_reecriture] = (CASE WHEN @date_reecriture IS NOT NULL THEN @date_reecriture ELSE [date_reecriture] END)
      ,[import_xml] = [import_xml] 
      ,[livraison_conforme] = [livraison_conforme]    
    WHERE id_traitement = @id_traitement
END


GO
