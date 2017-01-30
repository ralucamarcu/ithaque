SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <19/08/2015>
-- Description:	<Description,,>
-- =============================================

--testrun: [dbo].[spComparaisonBatchFile_VerificationBatchOutputImages]  @id_fichier_batch='E6CF705F-23BD-4111-AF3F-CFE64E708EA1',@id_fichier_recu='EA91F410-4343-4035-9477-3E377C8B52E0'

CREATE PROCEDURE spComparaisonBatchFile_VerificationBatchOutputImages
	 @id_fichier_batch uniqueidentifier
	,@id_fichier_recu uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
	--CREATE TABLE #temp_ComparaisonBatchOutputFile_NbImages(id int identity, id_fichier_batch uniqueidentifier, id_fichier_recu uniqueidentifier,nb_images_batch int,nb_images_recu)
	DECLARE @nb_images_batch int, @nb_images_output int
	
	SET @nb_images_batch =(SELECT COUNT(DISTINCT id_image) FROM Images WITH(NOLOCK) WHERE id_fichier_data_batch= @id_fichier_batch)

	SET @nb_images_output =(SELECT COUNT(DISTINCT dz.id_image) 
							 FROM [dbo].[DataXml_fichiers] df with(nolock)
							 INNER JOIN [DataXmlRC_actes] da with (nolock) ON  da.id_fichier=df.id_fichier 
							 INNER JOIN [DataXmlRC_zones]  dz with(nolock) ON da.id=dz.id_acte
							 WHERE df.id_fichier= @id_fichier_recu
							 GROUP BY df.id_fichier)
	
	IF (@nb_images_batch=@nb_images_output)
		SELECT 1
	ELSE
		SELECT 2

END
GO
