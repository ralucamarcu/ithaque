SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 11.09.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spMAJImagesAttributesImport] 
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJImagesAttributesImport '1E0C01C4-24C6-41B3-915F-35BFED4985FB', '\\10.1.0.196\bigvol\Sources\85-VENDEE-AD\V3\images\'
	@id_source UNIQUEIDENTIFIER
	,@path_general_v3 varchar(255)
	,@rc bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_image UNIQUEIDENTIFIER, @path_v3 VARCHAR(255), @type_image VARCHAR(100), @path_general_v3_var varchar(255)
		, @commune VARCHAR(255), @periode VARCHAR(50), @type_acte VARCHAR(10), @id_image_type INT
	set @path_general_v3_var = @path_general_v3
	
	DECLARE cursor_1 CURSOR FOR
	SELECT i.id_image, path_destination AS path_v3
	FROM Images i WITH (NOLOCK)
	INNER JOIN Taches_Images_Logs til WITH (NOLOCK) ON til.id_image = i.id_image AND til.id_tache = 3 
		AND til.path_origine NOT LIKE '%DUPLICATEDIMAGES%'
	WHERE i.id_source = @id_source
	GROUP BY i.id_image, path_destination
	OPEN cursor_1
	FETCH FROM cursor_1 INTO @id_image, @path_v3
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if (@rc = 0)
		begin
			SET @type_image = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			SET @path_general_v3_var = @path_general_v3_var + @type_image + '\'
			SET @commune = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			SET @path_general_v3_var = @path_general_v3_var + @commune + '\' + @commune + '_'
			SET @periode = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			SET @path_general_v3_var = @path_general_v3_var + @periode + '\'
			SET @type_acte = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
		end
		if (@rc = 1)
		begin
			--SET @type_image = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			--SET @path_general_v3_var = @path_general_v3_var + @type_image + '\'
			SET @commune = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			SET @path_general_v3_var = @path_general_v3_var + @commune + '\' + @commune + '_'
			SET @periode = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			SET @path_general_v3_var = @path_general_v3_var + @periode + '\'
			SET @type_acte = LEFT(REPLACE(@path_v3, @path_general_v3_var, ''),CHARINDEX('\', REPLACE(@path_v3, @path_general_v3_var, ''))-1)
			set @type_image = @type_acte
		end
		
		IF EXISTS (SELECT * FROM Images_Types WITH (NOLOCK) WHERE image_type_code = @type_image)
		BEGIN
			SET @id_image_type = (SELECT id_image_type FROM Images_Types WITH (NOLOCK) WHERE image_type_code = @type_image)
		END
		ELSE
		BEGIN
			INSERT INTO Images_Types(image_type_code) VALUES (@type_image)
			SET @id_image_type = SCOPE_IDENTITY()			
		END
		
		UPDATE Images
		SET id_image_type = @id_image_type
			,annee_debut = (CASE WHEN CHARINDEX('-', @periode) > 0 THEN CAST(LEFT(@periode, 4) AS CHAR(4)) ELSE @periode END)
			,annee_fin = (CASE WHEN CHARINDEX('-', @periode) > 0 THEN CAST(RIGHT(@periode, 4) AS CHAR(4)) ELSE NULL END)
			,commune = @commune
			,type_acte = @type_acte
		WHERE id_image = @id_image
		
		SET @id_image_type = NULL
		set @path_general_v3_var = @path_general_v3
		set @type_image = null
		set @commune = null
		set @periode = null
		set @type_acte = null
		
		FETCH FROM cursor_1 INTO @id_image, @path_v3
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
END

GO
