SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: 22.10.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesGeneralesCCAvancement] 
	-- Add the parameters for the stored procedure here
	-- Test Run : spStatistiquesGeneralesCCAvancement '01-01-2014', '20-10-2014', '3871A253-F67C-43F0-B693-EF4D49F81440'
	 @date_debut DATETIME = NULL
	,@date_fin DATETIME = NULL
	,@id_projet UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    -- Stats contrôle qualité : suivi journalier opérateur
	exec spStatistiquesSelectionControleQualiteOperateurs
	
	-- Stats contrôle qualité : suivi qualité - filtre chronologique : global ou période à définir
	IF (@date_debut IS NOT NULL) AND (@date_fin IS NOT NULL)
	BEGIN
		EXEC spStatistiquesControleQualiteProjetParPeriode @date_debut, @date_fin
	END
	
	-- Stats contrôle qualité : suivi sous-projet - filtre : choix sous-projet
	IF (@id_projet IS NOT NULL)
	BEGIN
		EXEC spStatistiquesControleQualiteParProjet @id_projet
	END
	
	-- Stats contrôle qualité : Structure export .csv
	exec spStatistiquesSelectionControleQualiteExport
	
	-- Stats projets : stats avancement projet
	SELECT * FROM Statistiques_Avancement_Projets_Images WITH (NOLOCK)
	
	-- Stats projets : stats détails projets
	SELECT * FROM Statistiques_Avancement_Projets_Details WITH (NOLOCK)
	
	-- Stats projets : Structure export .csv
	EXEC [spStatistiquesAvancementProjetsExportCSV]

END
GO
