SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Insertion_Parametres]
	-- Add the parameters for the stored procedure here
	@titre_document VARCHAR(255)
	,@description VARCHAR(255)
	,@miniature_document VARCHAR(255)
	,@sous_titre VARCHAR(255)
	,@image_principale VARCHAR(255)
	,@image_secondaire VARCHAR(255)
	,@publie BIT
	,@date_publication DATETIME
	,@id_projet UNIQUEIDENTIFIER
	,@chemin_dossier_v4 VARCHAR(255)
	,@chemin_dossier_v5 VARCHAR(255)
	,@chemin_xml VARCHAR(255)
	,@id_association INT
	,@date_creation_projet DATETIME
	,@chemin_dossier_v6 VARCHAR(255)
	,@chemin_dossier_general VARCHAR(255)
	,@id_livraisons VARCHAR(255) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_ael_parametre INT
    
    UPDATE dbo.AEL_Parametres
	SET principal = 0	
	WHERE principal=1
	
	IF NOT EXISTS (SELECT * FROM AEL_Parametres WHERE id_projet = @id_projet AND chemin_dossier_general = @chemin_dossier_general)
	BEGIN		
		INSERT INTO dbo.AEL_Parametres([titre_document],[description],[miniature_document],[sous_titre],[image_principale],[image_secondaire]
		  ,[publie],[date_publication],[id_projet],[chemin_dossier_v4],[chemin_dossier_v5],[chemin_xml],[id_association],[date_creation_projet]
		  ,[chemin_dossier_v6],[principal],[chemin_dossier_general], id_livraisons)
		VALUES (@titre_document,@description ,@miniature_document ,@sous_titre ,@image_principale ,@image_secondaire ,@publie 
		,@date_publication ,@id_projet ,@chemin_dossier_v4 ,@chemin_dossier_v5 ,@chemin_xml ,@id_association ,@date_creation_projet 
		,@chemin_dossier_v6,1,@chemin_dossier_general, @id_livraisons)
	END
	ELSE
	BEGIN
		SET @id_ael_parametre = (SELECT id_ael_parametres FROM AEL_Parametres WHERE id_projet = @id_projet AND chemin_dossier_general = @chemin_dossier_general)
		UPDATE dbo.AEL_Parametres
		SET [titre_document] = (CASE WHEN @titre_document IS NOT NULL THEN @titre_document ELSE titre_document END)
			,[description] = (CASE WHEN @description IS NOT NULL THEN @description ELSE [description] END)
			,[miniature_document] = (CASE WHEN @miniature_document IS NOT NULL THEN @miniature_document ELSE miniature_document END)
			,[sous_titre] = (CASE WHEN @sous_titre IS NOT NULL THEN @sous_titre ELSE sous_titre END)
			,[image_principale] = (CASE WHEN @image_principale IS NOT NULL THEN @image_principale ELSE image_principale END)
			,[image_secondaire] = (CASE WHEN @image_secondaire IS NOT NULL THEN @image_secondaire ELSE image_secondaire END)
			,[publie] = (CASE WHEN @publie IS NOT NULL THEN @publie ELSE publie END)
			,[date_publication] = (CASE WHEN @date_publication IS NOT NULL THEN @date_publication ELSE date_publication END)
			,[id_projet] = (CASE WHEN @id_projet IS NOT NULL THEN @id_projet ELSE id_projet END)
			,[chemin_dossier_v4] = (CASE WHEN @chemin_dossier_v4 IS NOT NULL THEN @chemin_dossier_v4 ELSE chemin_dossier_v4 END)
			,[chemin_dossier_v5] = (CASE WHEN @chemin_dossier_v5 IS NOT NULL THEN @chemin_dossier_v5 ELSE chemin_dossier_v5 END)
			,[chemin_xml] = (CASE WHEN @chemin_xml IS NOT NULL THEN @chemin_xml ELSE chemin_xml END)
			,[id_association] = (CASE WHEN @id_association IS NOT NULL THEN @id_association ELSE id_association END)
			,[date_creation_projet] = (CASE WHEN @date_creation_projet IS NOT NULL THEN @date_creation_projet ELSE date_creation_projet END)
			,[chemin_dossier_v6] = (CASE WHEN @chemin_dossier_v6 IS NOT NULL THEN @chemin_dossier_v6 ELSE chemin_dossier_v6 END)
			,[chemin_dossier_general] = (CASE WHEN @chemin_dossier_general IS NOT NULL THEN @chemin_dossier_general ELSE chemin_dossier_general END)
			,principal = 1
			,id_livraisons = (CASE WHEN @id_livraisons IS NOT NULL THEN @id_livraisons ELSE id_livraisons END)			
		  WHERE id_ael_parametres = @id_ael_parametre
	END
END
GO
