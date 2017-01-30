SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spSelectionListeActifProcessus]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT s.id_source, s.[nom_format_dossier], t.nom_tache, tl.ordre
	FROM Taches_Logs tl WITH(NOLOCK) 
	INNER JOIN Sources s WITH(NOLOCK) ON tl.id_source=s.id_source
	INNER JOIN Taches t WITH(NOLOCK) ON tl.id_tache=t.id_tache
	WHERE [id_status]=4 AND [doit_etre_execute]=1
	ORDER BY s.[nom_departement],tl.id_tache
END
GO
