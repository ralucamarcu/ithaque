SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[report_images_projet]	
(@id_projet as uniqueidentifier)
AS
BEGIN

select n.id_projet, p.nom, n.id_type_evenement, ty.libelle, ty.description, t.date_fin as date, n.nb as nb_images
from
(select p.id_projet, t.id_type_evenement, t.id_tache, COUNT(*) as nb
from Projets p (nolock)
inner join taches t (nolock) on t.id_projet=p.id_projet
inner join Images_Evenements e (nolock) on e.id_tache = t.id_tache
where p.id_projet = @id_projet
group by p.id_projet, p.nom, t.id_type_evenement, t.id_tache ) n
inner join Projets p (nolock) on n.id_projet = p.id_projet 
inner join FichiersData_Types_Evenements ty (nolock) on n.id_type_evenement=ty.id_type_evenement 
inner join Taches t (nolock) on n.id_tache=t.id_tache

/*select p.id_projet, p.nom, ty.id_type_evenement, ty.libelle, ty.description,  t.date_fin as date, n.nb as nb_images
from Projets p (nolock)
inner join taches t (nolock) on t.id_projet=p.id_projet
inner join FichiersData_Types_Evenements ty (nolock) on ty.libelle = t.nom
inner join (select id_tache, count(e.id_evenement_image) as nb from Images_Evenements e (nolock) group by id_tache) n on n.id_tache=t.id_tache
where p.id_projet = @id_projet*/

END



GO
