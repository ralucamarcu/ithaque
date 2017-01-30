SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 27.01.2015
-- Description:	@id_tache = 13 -> Importation Saisie
--				@id_tache = 12 -> Import Image JPG2000
--				@id_tache = 15 -> Import Image Zones
-- =============================================
CREATE PROCEDURE spMAJProgressionPourcentageImportImageImportationImage 
	-- Add the parameters for the stored procedure here
	-- Test Run : spMAJProgressionPourcentageImportImageImportationImage '{85fb4438-6e26-4419-94bf-3cabc3c241d3}', 1
	 @id_projet UNIQUEIDENTIFIER
	,@id_tache INT
	,@progression_pourcent INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_document UNIQUEIDENTIFIER, @nb_total_fichiers_xml INT, @nb_total_fichiers_xml_complet INT
		,@nb_total_jp2000_a_traiter INT, @nb_total_jp2000_traitee INT, @nb_total_zones_a_traiter INT, @nb_total_zones_traitee INT
    SET @id_document = (SELECT id_document FROM AEL_Parametres WHERE id_projet = @id_projet)
	IF (@id_tache = 13)
	BEGIN
		SET @nb_total_fichiers_xml = (SELECT COUNT(*) FROM [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_fichiers_xml WITH (NOLOCK) 
							WHERE id_document = @id_document)
		SET @nb_total_fichiers_xml_complet = (SELECT COUNT(*) FROM [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_fichiers_xml WITH (NOLOCK) 
							WHERE id_document = @id_document AND statut = 2)
		
		set @progression_pourcent = (SELECT FLOOR(CAST(CAST(@nb_total_fichiers_xml_complet AS FLOAT)/CAST(@nb_total_fichiers_xml AS FLOAT) AS FLOAT) * 100))
		RETURN		
	END
	
	IF (@id_tache = 12)
	BEGIN
		SET @nb_total_jp2000_a_traiter = (SELECT COUNT(*) FROM [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_images WITH (NOLOCK)
					WHERE id_document =  @id_document AND jp2_a_traiter = 1)
		SET @nb_total_jp2000_traitee = (SELECT COUNT(*) FROM [192.168.0.138].Archives_Preprod.dbo.saisie_donnees_images WITH (NOLOCK)
					WHERE id_document =  @id_document AND jp2_a_traiter = 1 AND jp2_traitee IS NOT NULL)				
		
		set @progression_pourcent = (SELECT FLOOR(CAST(CAST(@nb_total_jp2000_traitee AS FLOAT)/CAST(@nb_total_jp2000_a_traiter AS FLOAT) AS FLOAT) * 100))
		RETURN			
	END
	
	IF (@id_tache = 15)
	BEGIN
		SET @nb_total_zones_a_traiter = (SELECT COUNT(*) FROM Images_Traitements WITH (NOLOCK) WHERE id_projet = @id_projet)
		SET @nb_total_zones_traitee = (SELECT COUNT(*) FROM Images_Traitements WITH (NOLOCK) WHERE id_projet = @id_projet AND zone_status = 2)
	
		set @progression_pourcent = (SELECT FLOOR(CAST(CAST(@nb_total_zones_traitee AS FLOAT)/CAST(@nb_total_zones_a_traiter AS FLOAT) AS FLOAT) * 100))
		RETURN			
	END

END
GO
