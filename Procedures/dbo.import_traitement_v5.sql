SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[import_traitement_v5] 
	-- Add the parameters for the stored procedure here
	 @id_projet uniqueidentifier
	,@id_document uniqueidentifier
	,@id_tache int
AS
BEGIN
	
	update taches
    set statut=1, date_debut= GETDATE()
    where id_tache =@id_tache
	
	update Images
	set id_statut = 5,
	date_statut = GETDATE()
	where id_image  in(
		select i2.id_image 
		from Archives_Preprod.dbo.Saisie_donnees_images i(nolock) 
		inner join Archives_Preprod.dbo.Saisie_donnees_pages p(nolock) on i.id_page = p.id_page 
		inner join Images i2(nolock) on i2.path_projet = i.path collate french_ci_as
	where p.id_document=@id_document
	and jp2_traitee is not null)

	INSERT into Images_Evenements(id_image,id_type_evenement,date_evenement,id_status,date_status,date_creation, id_tache) 
	select id_image, 14,GETDATE(),5, GETDATE(),	GETDATE(), @id_tache from images 
	where id_statut=5 and id_projet=@id_projet

    update taches
    set statut=2, date_fin= GETDATE()
    where id_tache =@id_tache
END

GO
