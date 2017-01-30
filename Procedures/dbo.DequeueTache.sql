SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DequeueTache]
@NbItems int = 1
AS

SET NOCOUNT ON

UPDATE TOP(@NbItems) Taches WITH (UPDLOCK, READPAST)
SET statut = 1, date_debut=GETDATE(), machine_traitement=HOST_NAME()
OUTPUT inserted.id_tache, inserted.nom, inserted.id_projet, inserted.chemin_source,inserted.chemin_destination
FROM Taches qm 
where isnull(qm.statut,0) = 0 

SET NOCOUNT OFF
GO
