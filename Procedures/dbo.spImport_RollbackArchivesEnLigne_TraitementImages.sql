SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 28/09/2015
-- Description:	'Rollback' all modification-> deletes all inserted data
-- =============================================
CREATE PROCEDURE [dbo].[spImport_RollbackArchivesEnLigne_TraitementImages]
	 @date_publication datetime
	,@id_projet uniqueidentifier
	,@id_document uniqueidentifier
AS
BEGIN
	
	SET NOCOUNT ON;

    DELETE FROM [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_images] WHERE id_document=@id_document
	DELETE FROM [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_pages] WHERE id_document=@id_document
	DELETE FROM [PRESQL04].[Archives_Preprod].[dbo].[saisie_donnees_documents] WHERE id_document=@id_document

END
GO
