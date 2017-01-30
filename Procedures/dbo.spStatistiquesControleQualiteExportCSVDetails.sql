SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesControleQualiteExportCSVDetails]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spStatistiquesControleQualiteExportCSVDetails] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @lots_controles INT, @lots_valides INT, @lots_rejetes INT, @tx_lots_rejetes FLOAT
		, @actes_controles INT, @livraisons INT, @actes_valides INT, @actes_rejetes INT, @tx_actes_rejetes FLOAT
		, @id_projet UNIQUEIDENTIFIER, @id_traitement INT, @id_identity INT, @id_utilisateur INT, @date_traitement DATETIME
   	CREATE TABLE #tmp_lots_controles (id_lot UNIQUEIDENTIFIER)
   	IF OBJECT_ID('Statistiques_Controle_Export_Details') IS NOT NULL 
		DROP TABLE Statistiques_Controle_Export_Details
   	CREATE TABLE Statistiques_Controle_Export_Details
	(id_statistiques_controle_qualite_export_details INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	, sous_projet VARCHAR(255), livraison VARCHAR(100), date_livraison DATETIME, id_operateur INT, nom_operateur VARCHAR(100)
	, prenom_utilisateur VARCHAR(100), date_traitement DATETIME, lots_controles INT, lots_valides INT, lots_rejetes INT
	, taux_lots_rejetes FLOAT, actes_controles INT, actes_valides INT, actes_rejetes INT, taux_actes_rejetes FLOAT, actes_lus INT)

	DECLARE cursor_1 CURSOR FOR
	SELECT t.id_projet, t.id_traitement, id_utilisateur, DATEADD(dd,00,DATEDIFF(dd, 0, date_log)) AS [DATE]
	FROM Logs_actions la WITH (NOLOCK)
	INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON la.id_objet = dxee.id_echantillon
	INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement 
	WHERE [ACTION] = 'CocheEchantillonTraité'
	GROUP BY t.id_projet, t.id_traitement, id_utilisateur , DATEADD(dd,00,DATEDIFF(dd, 0, date_log))
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet, @id_traitement, @id_utilisateur, @date_traitement
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO Statistiques_Controle_Export_Details
		EXEC [spStatistiquesActesTraitesParOperateurTraitements] @id_projet, @id_utilisateur, @date_traitement, @id_traitement
		FETCH cursor_1 INTO @id_projet, @id_traitement, @id_utilisateur, @date_traitement
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
				
		
	DROP TABLE #tmp_lots_controles
	   	
END
GO
