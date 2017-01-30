SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DequeueZone]
@id_projet uniqueidentifier,
@NbItems int = 1
AS

SET NOCOUNT ON

UPDATE TOP(@NbItems) Images_Traitements WITH (UPDLOCK, READPAST)
SET zone_status = 1, zone_date =GETDATE() 
OUTPUT inserted.id_image
FROM Images_Traitements qm 
where zone_status=0 and id_projet = @id_projet

SET NOCOUNT OFF
GO
