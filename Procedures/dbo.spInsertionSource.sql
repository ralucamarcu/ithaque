SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 27.08.2014
-- Description:	insérer une nouvelle source dans la base de données avec id_status = 1 (v1)
--				
-- =============================================
CREATE PROCEDURE [dbo].[spInsertionSource] 
	-- Add the parameters for the stored procedure here
	-- Test Run : EXEC [spInsertionSource] '85', 'VENDEE', 1, 0, 'RC', NULL
	@id_departement VARCHAR(50)
	,@nom_departement VARCHAR(255)
	,@id_fournisseur INT
	,@taille_dossier_GB INT
	,@image_type_code VARCHAR(5)
	,@image_type VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
       PRINT 0
    DECLARE @date DATETIME = GETDATE(), @nom_format VARCHAR(255) = '', @id_image_type INT, @id_source  UNIQUEIDENTIFIER
		,@chemin_dossier varchar(255)
    CREATE TABLE #tmp (id_source UNIQUEIDENTIFIER)
    
    PRINT 1
    
    IF EXISTS (SELECT * FROM dbo.Images_Types WHERE image_type_code = @image_type_code)
    BEGIN
		SET @id_image_type = (SELECT id_image_type FROM dbo.Images_Types WHERE image_type_code = @image_type_code)
		UPDATE Images_Types
		SET image_type = @image_type
		WHERE image_type_code = @image_type_code
		   PRINT 2
    END
    ELSE
    BEGIN
		INSERT INTO dbo.Images_Types  (image_type, image_type_code)
		VALUES (@image_type, @image_type_code)
		SET @id_image_type = SCOPE_IDENTITY()
		   PRINT 3
    END
    
    IF (@image_type IS NULL)
    BEGIN
		SET @image_type = (SELECT image_type FROM Images_Types WHERE id_image_type = @id_image_type)
    END
    
    BEGIN TRY
	BEGIN TRANSACTION spInsertionSource;
		SET @nom_format = @id_departement + '-' + @nom_departement + '-' + @image_type_code
		set @chemin_dossier = '\\10.1.0.196\bigvol\Sources\' + @nom_format + '\'
		   PRINT 5
		INSERT INTO dbo.Sources (id_departement, nom_departement, id_fournisseur, taille_dossier_GB, id_status_version_processus
			, date_creation, nom_format_dossier, chemin_dossier_general)
		OUTPUT inserted.id_source
		INTO #tmp
		VALUES (@id_departement, @nom_departement, @id_fournisseur, @taille_dossier_GB, 0
			, @date, @nom_format, @chemin_dossier)
		SET @id_source = (SELECT id_source FROM #tmp)
		
		   PRINT 6
		INSERT INTO dbo.Sources_Images_Types (id_image_type, id_source)
		VALUES (@id_image_type, @id_source)
		
	   PRINT 7
	COMMIT TRANSACTION spInsertionSource;
	
	   PRINT 8
	SELECT @id_source AS id_source
	
	RETURN
	   PRINT 9
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		ROLLBACK TRANSACTION spInsertionSource;
		
		SELECT '-1' AS id_source
		   PRINT 10
		
		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,
				   @ErrorSeverity, 
				   @ErrorState 
				   );
	END CATCH;
	
END

GO
