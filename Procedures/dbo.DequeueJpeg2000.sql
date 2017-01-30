SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DequeueJpeg2000]
@id_projet uniqueidentifier,
@NbItems int = 1
AS

SET NOCOUNT ON

UPDATE TOP(@NbItems) Images WITH (UPDLOCK, READPAST)
SET locked = 1
OUTPUT inserted.id_image, inserted.path_projet as path
FROM Images qm 
where qm.id_statut = 4 and locked=0 and id_projet = @id_projet

SET NOCOUNT OFF
GO
