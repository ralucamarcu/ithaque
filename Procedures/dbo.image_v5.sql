SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[image_v5] 
	-- Add the parameters for the stored procedure here
	 @path varchar(800)	
	,@id_projet uniqueidentifier
	,@id_tache int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @id_image uniqueidentifier
    select @id_image=id_image from Images (nolock)
    where path_projet=@path and id_projet = @id_projet
    
    insert into Images_Evenements(
		id_image,
		id_type_evenement,
		date_evenement,
		id_status,
		date_status,
		date_creation,
		id_tache)
	values
	(
		@id_image,
		14,
		GETDATE(),
		5,
		GETDATE(),
		GETDATE(),
		@id_tache
	)
	
	update Images set locked=0, id_statut=5, date_statut = GETDATE() where id_image =@id_image
    
END
GO
