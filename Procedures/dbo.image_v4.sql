SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[image_v4] 
	-- Add the parameters for the stored procedure here
	 @path varchar(800)	
	,@id_projet uniqueidentifier
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
		date_creation)
	values
	(
		@id_image,
		13,
		GETDATE(),
		4,
		GETDATE(),
		GETDATE()
	)
	
	update Images set id_statut=4, date_statut = GETDATE() where id_image =@id_image
    
END
GO
