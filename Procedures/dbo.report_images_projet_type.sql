SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[report_images_projet_type]	
(@id_projet as uniqueidentifier, @id_type_evenement as integer)
AS
BEGIN

/*select p.id_projet, p.nom, t.id_type_evenement, t.libelle, COUNT(nb.id_evenement_image) as nb, sum(case when nb.id_evenement_image  is null then 1 else 0 end) as nb_absent
from Images i(nolock) 
inner join Projets p (nolock) on i.id_projet = p.id_projet 
inner join FichiersData_Types_Evenements t (nolock) on t.id_type_evenement = @id_type_evenement
left join Images_Evenements nb (nolock) on i.id_image = nb.id_image and nb.id_type_evenement=@id_type_evenement
where i.id_projet=@id_projet
group by p.id_projet, p.nom, t.id_type_evenement, t.libelle */

select n.id_projet, p.nom, n.id_type_evenement, ty.libelle, n.nb, n.nb_absent 
from
(select p.id_projet, t.id_type_evenement, t.id_tache, COUNT(*) as nb, sum(case when e.id_evenement_image  is null then 1 else 0 end) as nb_absent
from Projets p (nolock)
inner join taches t (nolock) on t.id_projet=p.id_projet and t.id_type_evenement=@id_type_evenement
left join Images_Evenements e (nolock) on e.id_tache = t.id_tache
where p.id_projet = @id_projet
group by p.id_projet, p.nom, t.id_type_evenement, t.id_tache ) n
inner join Projets p (nolock) on n.id_projet = p.id_projet 
inner join FichiersData_Types_Evenements ty (nolock) on n.id_type_evenement=ty.id_type_evenement 
inner join Taches t (nolock) on n.id_tache=t.id_tache



END
GO
