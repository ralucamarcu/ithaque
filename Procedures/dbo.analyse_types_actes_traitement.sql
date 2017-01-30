SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 31/05/2012
-- Description:	Calcul le nombre d'actes par type/sous-type pour un id_traitement
-- =============================================
CREATE PROCEDURE [dbo].[analyse_types_actes_traitement]
	-- Add the parameters for the stored procedure here
	@id_traitement integer
AS
BEGIN
	SET NOCOUNT ON;
	SET ARITHABORT OFF;
	
	DECLARE @id_type_traitement int
	
	SELECT @id_type_traitement=id_type_traitement FROM Traitements (nolock) t WHERE id_traitement=@id_traitement
	
	--Suppression des enregistrements existants pour ce traitement
	DELETE FROM dbo.Types_actes_traitements WHERE id_traitement=@id_traitement

	--Calcul du nombre d'actes par type/sous-type pour EC
	IF @id_type_traitement IN (1)
	BEGIN
		INSERT INTO dbo.Types_actes_traitements(id_traitement, type_dataxml, type_acte, soustype_acte, nb_actes)
		SELECT a.id_traitement, 'EC', a.type_acte, a.soustype_acte, count(a.id)
		FROM DataXmlEC_actes a WITH (nolock)
		WHERE id_traitement=@id_traitement
		GROUP BY a.id_traitement,a.type_acte, a.soustype_acte
		ORDER BY a.type_acte, a.soustype_acte
	END
	
	--Calcul du nombre d'actes par type/sous-type pour TD
	IF @id_type_traitement IN (1)
	BEGIN
		INSERT INTO dbo.Types_actes_traitements(id_traitement, type_dataxml, type_acte, soustype_acte, nb_actes)
		SELECT a.id_traitement, 'TD', a.type_acte, a.soustype_acte, count(a.id)
		FROM DataXmlTD_actes a WITH (nolock)
		WHERE id_traitement=@id_traitement
		GROUP BY a.id_traitement,a.type_acte, a.soustype_acte
		ORDER BY a.type_acte, a.soustype_acte
	END
	
	--Calcul du nombre d'actes par type/sous-type pour les actes standards (EC, RC)
	IF @id_type_traitement IN (2,3,4)
	BEGIN
		INSERT INTO dbo.Types_actes_traitements(id_traitement, type_acte, soustype_acte, nb_actes)
		SELECT a.id_traitement, a.type_acte, a.soustype_acte, count(a.id)
		FROM DataXmlRC_actes a WITH (nolock)
		WHERE id_traitement=@id_traitement
		GROUP BY a.id_traitement,a.type_acte, a.soustype_acte
		ORDER BY a.type_acte, a.soustype_acte
	END

	
END

GO
