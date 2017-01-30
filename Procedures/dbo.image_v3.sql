SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[image_v3] 
	-- Add the parameters for the stored procedure here
	 @path_origine varchar(800)
	,@path_projet varchar(800)
	,@id_projet uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @id_image uniqueidentifier
    select @id_image=id_image from Images (nolock)
    where path_origine=@path_origine and id_projet = @id_projet and id_statut<>3
    
    if @id_image is null 
    begin
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
			12,
			GETDATE(),
			3,	
			GETDATE(),
			GETDATE()
		)	
		update Images set path_projet=@path_projet, id_statut=3, date_statut=GETDATE() where id_image =@id_image
	end 
    
END
GO
