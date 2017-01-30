SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spLivraisonsCreationTableSuiviLivraisons] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_traitement INT
	IF OBJECT_ID('LivraisonsSuivi') IS NOT NULL 
		DROP TABLE LivraisonsSuivi
	CREATE TABLE LivraisonsSuivi (id_livraisons_suivi INT NOT NULL IDENTITY(1,1) PRIMARY KEY
		, id_livraison int
		, nom_livraisons VARCHAR (250), date_livraisons DATETIME, nom_projet VARCHAR(250), type_livraisons VARCHAR(10), a_traiter BIT, conformity BIT, valide BIT
		, import_cq BIT, echantill bit, avancement_controle FLOAT, nb_fichiers INT, nb_actes INT, rejetess FLOAT
		, nb_actes_naissance int, nb_actes_mariage int, nb_actes_deces int, nb_actes_recensement int, livraison_annule bit,date_retour_conformite datetime,date_retour_CQ datetime)
	
	DECLARE cursor_1 CURSOR FOR
	SELECT id_traitement
	FROM Traitements WITH (NOLOCK)
	OPEN cursor_1
	FETCH cursor_1 INTO @id_traitement
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO LivraisonsSuivi (id_livraison, nom_livraisons, date_livraisons, nom_projet, type_livraisons
			, a_traiter, conformity, valide, import_cq, echantill, avancement_controle
			, nb_fichiers, nb_actes, rejetess, nb_actes_naissance, nb_actes_mariage, nb_actes_deces, nb_actes_recensement, livraison_annule,date_retour_conformite,date_retour_CQ)
		EXEC spLivraisonsSelectionSuiviInfo @id_traitement = @id_traitement
		FETCH cursor_1 INTO @id_traitement
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
END
GO
