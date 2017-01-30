SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesImagesTotal]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER
	IF OBJECT_ID('Statistiques_Images') IS NOT NULL 
		DROP TABLE Statistiques_Images
	CREATE TABLE Statistiques_Images (id_statistiques_image int not null identity(1,1) primary key
		, nom_sous_projet VARCHAR (50), nb_total_img_v4 INT
		, nb_total_img_envoye_a_prestataire INT, pourcentage_total_img_envoye_img_par_projet float
		, nb_img_validite_conformite INT, pourcentage_total_img_envoye_img_validite_conformite float
		, nb_img_validitate_CQ INT, pourcentage_total_img_envoye_img_validitate_CQ float
		, nb_img_rejet INT, pourcentage_total_img_envoye_img_rejet float)
	
	DECLARE cursor_1 CURSOR FOR
	SELECT distinct p.id_projet
	FROM projets p WITH (NOLOCK)
	WHERE id_status_version_processus >= 4
	--GROUP BY p.id_projet
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO Statistiques_Images (nom_sous_projet, nb_total_img_v4, nb_total_img_envoye_a_prestataire, nb_img_validite_conformite
			, nb_img_validitate_CQ, nb_img_rejet, pourcentage_total_img_envoye_img_par_projet, pourcentage_total_img_envoye_img_validite_conformite
			, pourcentage_total_img_envoye_img_validitate_CQ, pourcentage_total_img_envoye_img_rejet)
		EXEC [spStatistiquesImagesParProjet] @id_projet, 4
		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	
	
			
END
GO
