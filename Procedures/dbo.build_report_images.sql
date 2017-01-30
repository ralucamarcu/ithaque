SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[build_report_images]	
AS
BEGIN

delete from report_images


insert into report_images
select id_projet ,nom,0,0,0,0,0,0,0,0,0,0,0,0
from Projets

update report_images
set v1=nb_v1,
v1_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(v1.id_evenement_image) as nb_v1
from taches t (nolock) inner join Images_Evenements v1 (nolock) on v1.id_tache=t.id_tache
where t.nom='v1'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet


update report_images
set v2=nb_v2,
v2_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(v2.id_evenement_image) as nb_v2
from taches t (nolock) inner join Images_Evenements v2 (nolock) on v2.id_tache=t.id_tache
where t.nom='v2'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet


update report_images
set v3=nb_v3,
v3_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(v3.id_evenement_image) as nb_v3
from taches t (nolock) inner join Images_Evenements v3 (nolock) on v3.id_tache=t.id_tache
where t.nom='v3'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet


update report_images
set v4=nb_v4,
v4_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(v4.id_evenement_image) as nb_v4
from taches t (nolock) inner join Images_Evenements v4 (nolock) on v4.id_tache=t.id_tache
where t.nom='v4'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet



update report_images
set v5=nb_v5,
v5_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(v5.id_evenement_image) as nb_v5
from taches t (nolock) inner join Images_Evenements v5 (nolock) on v5.id_tache=t.id_tache
where t.nom='v5'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet

update report_images
set prod=nb_prod,
prod_statut = statut
 from
report_images 
inner join (
select id_projet,  t.statut, COUNT(prod.id_evenement_image) as nb_prod
from taches t (nolock) inner join Images_Evenements prod (nolock) on prod.id_tache=t.id_tache
where t.nom='prod'
group by id_projet, statut) b  on b.id_projet= report_images.id_projet


/*

update report_images
set v1=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=10
group by report_images.id_projet) b on b.id_projet= report_images.id_projet


update report_images
set v2=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=11
group by report_images.id_projet) b on b.id_projet= report_images.id_projet

update report_images
set v3=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=12
group by report_images.id_projet) b on b.id_projet= report_images.id_projet


update report_images
set v4=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=13
group by report_images.id_projet) b on b.id_projet= report_images.id_projet


update report_images
set v5=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=14
group by report_images.id_projet) b on b.id_projet= report_images.id_projet

update report_images
set prod=nb from
report_images 
inner join (
select report_images.id_projet,COUNT(v1.id_evenement_image) as nb
from report_images (nolock) 
inner join Images i(nolock) on i.id_projet = report_images.id_projet 
inner join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=15
group by report_images.id_projet) b on b.id_projet= report_images.id_projet*/

/*insert into report_images
	select p.id_projet ,p.nom, 
sum(case when v1.id_evenement_image is null then 0 else 1 end) as v1,
sum(case when v2.id_evenement_image is null then 0 else 1 end) as v2,
sum(case when v3.id_evenement_image is null then 0 else 1 end) as v3,
sum(case when v4.id_evenement_image is null then 0 else 1 end) as v4,
sum(case when v5.id_evenement_image is null then 0 else 1 end) as v5,
sum(case when prod.id_evenement_image is null then 0 else 1 end) as prod
from Projets p (nolock) 
left join Images i(nolock) on i.id_projet = p.id_projet 
left join Images_Evenements v1 (nolock) on i.id_image = v1.id_image and v1.id_type_evenement=10
left join Images_Evenements v2 (nolock) on i.id_image = v2.id_image and v2.id_type_evenement=11
left join Images_Evenements v3 (nolock) on i.id_image = v3.id_image and v3.id_type_evenement=12
left join Images_Evenements v4 (nolock) on i.id_image = v4.id_image and v4.id_type_evenement=13
left join Images_Evenements v5 (nolock) on i.id_image = v5.id_image and v5.id_type_evenement=14
left join Images_Evenements prod (nolock) on i.id_image = prod.id_image and prod.id_type_evenement=15
group by p.nom,p.id_projet */
    
END
GO
