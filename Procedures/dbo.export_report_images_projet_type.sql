SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[export_report_images_projet_type]	
(@id_projet as uniqueidentifier, @id_type_evenement as integer, @exist as bit)
AS
BEGIN

if @exist=1 
begin
	select i.*
	from Images i(nolock) 
	inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=@id_type_evenement
	where i.id_projet=@id_projet
end
else begin
	select i.*
	from Images i(nolock) 
	left join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=@id_type_evenement
	where i.id_projet=@id_projet
	and v1.id_image is null
end




END
GO
