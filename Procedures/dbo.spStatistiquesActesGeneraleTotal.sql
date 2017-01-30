SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Raluca Marcu
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spStatistiquesActesGeneraleTotal]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER
	IF OBJECT_ID('Statistiques_Actes') IS NOT NULL 
		DROP TABLE Statistiques_Actes
	CREATE TABLE Statistiques_Actes (id_statistiques_actes int not null identity(1,1) primary key
		, projet VARCHAR(50), [sous-projet] VARCHAR(50), prestataire VARCHAR(50), lots_recus INT
		, actes_recus INT, lots_controles INT, actes_controles INT, avancement_pourcentage FLOAT, lots_rejet INT, tx_rejet_pourcentage FLOAT)
	
	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT p.id_projet
	FROM projets p WITH (NOLOCK)
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO Statistiques_Actes (projet, [sous-projet], prestataire, lots_recus, actes_recus, lots_controles, actes_controles
			, avancement_pourcentage, lots_rejet, tx_rejet_pourcentage)
		EXEC [spStatistiquesActesGeneralParProjet] @id_projet
		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1
	
	
	
			
END


GO
