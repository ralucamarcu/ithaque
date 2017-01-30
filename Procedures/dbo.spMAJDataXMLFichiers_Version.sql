SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spMAJDataXMLFichiers_Version 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @nom VARCHAR(255)
	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT fd.nom
	FROM FichiersData fd WITH (NOLOCK)
	INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON fd.nom = df.nom_fichier
	WHERE df.version IS NULL
	OPEN cursor_1
	FETCH cursor_1 INTO @nom
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		UPDATE DataXml_fichiers
		SET VERSION = x.row_num
		FROM (SELECT ROW_NUMBER() OVER(ORDER BY t.date_livraison) AS row_num, df.id_fichier
		FROM DataXml_fichiers df WITH (NOLOCK)
		INNER JOIN Traitements t WITH (NOLOCK) ON df.id_traitement = t.id_traitement
		WHERE nom_fichier = @nom)
		AS x
		INNER JOIN DataXml_fichiers df WITH (NOLOCK) ON x.id_fichier = df.id_fichier
		
		FETCH cursor_1 INTO @nom	
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
END
GO
