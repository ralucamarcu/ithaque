SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AEL_Selection_Verification_JP2000]
	-- Add the parameters for the stored procedure here
	@id_projet UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    IF OBJECT_ID('ael_tmp_image_jp2000_nok') IS NOT NULL 
		DROP TABLE ael_tmp_image_jp2000_nok
	CREATE TABLE ael_tmp_image_jp2000_nok (id_image INT )
	CREATE TABLE #tmp (id_acte INT, id_image UNIQUEIDENTIFIER)
	CREATE TABLE #tmp2(PATH VARCHAR(500))
	
	IF @id_projet IS NULL
	BEGIN
		SET @id_projet = (SELECT id_projet FROM AEL_Parametres WHERE principal = 1)
	END
	
	INSERT INTO #tmp
	SELECT dxz.id_acte, dxz.id_image
	FROM DataXmlRC_zones dxz WITH (NOLOCK)
	INNER JOIN DataXmlRC_actes dxa WITH (NOLOCK) ON dxz.id_acte = dxa.id
	INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON dxf.id_lot = dxee.id_lot
	INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
	WHERE t.id_projet = @id_projet AND dxee.id_statut IN (1,3)
	GROUP BY dxz.id_acte, dxz.id_image 
			
	
	INSERT INTO #tmp2	
	SELECT REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
					+ tli.nom_fichier_image_destination AS [PATH]
	FROM Taches_Images_Logs tli WITH (NOLOCK)
	INNER JOIN Images i WITH (NOLOCK) ON tli.id_image = i.id_image 
	LEFT JOIN #tmp t ON i.id_image = t.id_image
	WHERE id_projet = @id_projet AND tli.id_tache = 4
	 AND id_acte IS NOT NULL
	GROUP BY REPLACE(SUBSTRING(tli.path_destination, CHARINDEX('V4\images', tli.path_destination), LEN(tli.path_destination)), 'V4\images', '')
					+ tli.nom_fichier_image_destination
	
	INSERT INTO ael_tmp_image_jp2000_nok				
	SELECT id_image FROM [PRESQL04].Archives_Preprod.dbo.saisie_donnees_images WITH (NOLOCK) WHERE [PATH] COLLATE database_default IN 
		(SELECT [PATH] FROM #tmp2) AND jp2_a_traiter = 0
	
	DROP TABLE #tmp
	DROP TABLE #tmp2
		
END
GO
