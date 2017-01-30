SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[image_v1] 
	-- Add the parameters for the stored procedure here
	@id_projet uniqueidentifier,
	@id_tache int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    insert into Images_Evenements(
		id_image,
		id_type_evenement,
		date_evenement,
		id_status,
		date_status,
		date_creation,
		id_tache)
	select id_image, 10,GETDATE(),1,GETDATE(),	GETDATE(), @id_tache
	from Images (nolock) 
	where id_projet =@id_projet
	
	update Images set id_statut=1, date_statut=GETDATE() where id_projet =@id_projet
    
END
GO
