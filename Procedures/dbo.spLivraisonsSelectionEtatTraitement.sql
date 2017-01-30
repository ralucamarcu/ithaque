SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Statut = 1 -> Termine
--				Statut = 2 -> En cours
--				Statut = 3 -> En attente
--				Statut = 4 -> Pas Traite
-- =============================================
CREATE PROCEDURE spLivraisonsSelectionEtatTraitement
	-- Add the parameters for the stored procedure here
	-- Test Run : spLivraisonsSelectionEtatTraitement 268
	@id_traitement INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @nb_lots_total INT, @nb_lots_traite INT
	SET @nb_lots_total = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
							INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
							WHERE t.id_traitement = @id_traitement)
							
	SET @nb_lots_traite = (SELECT COUNT(dxee.id_echantillon) FROM DataXmlEchantillonEntete dxee WITH (NOLOCK)
							INNER JOIN Traitements t WITH (NOLOCK) ON dxee.id_traitement = t.id_traitement
							WHERE t.id_traitement = @id_traitement AND dxee.traite = 1)
	
	SELECT (CASE WHEN @nb_lots_total = @nb_lots_traite AND @nb_lots_total <> 0 THEN 1
				WHEN @nb_lots_total > @nb_lots_traite THEN 2
				WHEN @nb_lots_traite = 0 AND @nb_lots_total <> 0 THEN 3
				WHEN @nb_lots_traite = 0 AND @nb_lots_total = 0 THEN 4
				ELSE 0 END) AS Statut
	
	
END
GO
