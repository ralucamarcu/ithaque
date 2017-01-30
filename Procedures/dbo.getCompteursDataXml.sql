SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frederic Robillard
-- Create date: 20/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[getCompteursDataXml]
	@id_traitement integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT a.id_compteur, a.id_type_traitement, a.nom_compteur, a.requete_sql 
	FROM dbo.Compteurs_types_traitements a WITH (nolock)
	INNER JOIN dbo.Traitements b WITH (nolock) ON a.id_type_traitement=b.id_type_traitement
	WHERE b.id_traitement=@id_traitement and LEN(requete_sql)>0
	ORDER by a.ordre;
END

GO
