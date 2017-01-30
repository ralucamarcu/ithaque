SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 21/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[creationEchantillonCommunes] 
	@id_echantillon integer
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @id_traitement integer
	DECLARE @type_echantillon varchar(10)
	DECLARE @pourcent_selection as float
	DECLARE @id_type_traitement as integer
	
		SELECT @id_type_traitement=tt.id_type_traitement, @type_echantillon=type_echantillon FROM dbo.DataXmlEchantillonEntete (nolock) ee INNER JOIN dbo.Traitements (nolock) t ON ee.id_traitement=t.id_traitement INNER JOIN dbo.Types_traitements (nolock) tt ON t.id_type_traitement=tt.id_type_traitement WHERE id_echantillon=@id_echantillon

	--BEGIN TRY
		BEGIN TRANSACTION
	
		DELETE FROM dbo.DataXmlEchantillonCommunes WHERE id_echantillon=@id_echantillon
		UPDATE dbo.DataXmlEchantillonEntete SET flag_echantillon_communes=0 WHERE id_echantillon=@id_echantillon
		
		SELECT @id_traitement=id_traitement, @pourcent_selection=pourcent_selection_commune FROM dbo.DataXmlEchantillonEntete WHERE id_echantillon=@id_echantillon

		IF @id_type_traitement=1 AND @type_echantillon='TD'
		--Echantillon TD
			BEGIN
				INSERT INTO dbo.DataXmlEchantillonCommunes (id_echantillon, geonameid)
				SELECT TOP (@pourcent_selection) PERCENT @id_echantillon, geonameid_acte FROM DataXmlStatsCommunes WHERE @id_traitement=id_traitement ORDER BY NEWID()
			END
		--ELSE IF ((@id_type_traitement=1 AND @type_echantillon='EC') OR (@id_type_traitement=3))
		----Echantillon EC
		--	BEGIN
		--		INSERT INTO dbo.DataXmlEchantillonCommunes (id_echantillon, geonameid)
		--		SELECT TOP (@pourcent_selection) PERCENT @id_echantillon, geonameid_acte FROM DataXmlStatsCommunesEC WHERE @id_traitement=id_traitement ORDER BY NEWID()
		--	END
		ELSE IF (@id_type_traitement=2 OR @id_type_traitement=3)
		--Echantillon RC
			BEGIN
				INSERT INTO dbo.DataXmlEchantillonCommunes (id_echantillon, geonameid)
				SELECT TOP (@pourcent_selection) PERCENT @id_echantillon, geonameid_acte FROM DataXmlStatsCommunesRC WHERE @id_traitement=id_traitement ORDER BY NEWID()
			END
		
		UPDATE dbo.DataXmlEchantillonEntete SET flag_echantillon_communes=1 WHERE id_echantillon=@id_echantillon
		
		COMMIT TRANSACTION	
	--END TRY
	--BEGIN CATCH
	--	ROLLBACK TRANSACTION
	--END CATCH
END

GO
