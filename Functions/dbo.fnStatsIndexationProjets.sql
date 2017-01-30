SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION fnStatsIndexationProjets
()
RETURNS @StatsIndexationProjets TABLE 
(
	-- Add the column definitions for the TABLE variable here
	id_projet uniqueidentifier,
	statut varchar,
	projet varchar(500),
	nb_xml_attendus int,
	nb_fichiers_xml_livres int,
	nb_actes_total int
)
AS
BEGIN
	DECLARE @temp_projets_retraites TABLE (id_projet uniqueidentifier, nom varchar(500), statut varchar)
	DECLARE @temp_projets_non_retraites TABLE (id_projet uniqueidentifier, nom varchar(500), statut varchar)
	DECLARE @temp_projets TABLE (id_projet uniqueidentifier, nom varchar(500), statut varchar)
	DECLARE @nb_xml_attendus_projet TABLE (id_projet uniqueidentifier, nb_xml_attendus int)
	DECLARE @temp_fichiers_acceptes TABLE (id_projet uniqueidentifier, projet varchar(500), traitement varchar(500), id_fichier uniqueidentifier, id_fichierData uniqueidentifier, nb_actes int)
	DECLARE @temp_fichiers_a_controler TABLE (id_projet uniqueidentifier, projet varchar(500), traitement varchar(500), id_fichier uniqueidentifier, id_fichierData uniqueidentifier, nb_actes int)
	DECLARE @temp_fichiers_rejetes TABLE (id_projet uniqueidentifier, projet varchar(500), traitement varchar(500), id_fichier uniqueidentifier, id_fichierData uniqueidentifier, nb_actes int)
	DECLARE @temp_fichiers_recus_jamais_controles TABLE (id_projet uniqueidentifier, projet varchar(500), traitement varchar(500), id_fichier uniqueidentifier, id_fichierData uniqueidentifier, nb_actes int)
	DECLARE @temp_fichiers_acceptes_nb TABLE (id_projet uniqueidentifier, projet uniqueidentifier, nb_fichiers int, nb_fichierData int, nb_actes int)
	DECLARE @temp_fichiers_rejetes_nb TABLE (id_projet uniqueidentifier, projet uniqueidentifier, nb_fichiers int, nb_fichierData int, nb_actes int)
	DECLARE @temp_fichiers_a_controler_nb TABLE (id_projet uniqueidentifier, projet uniqueidentifier, nb_fichiers int, nb_fichierData int, nb_actes int)
	DECLARE @temp_fichiers_recus_jamais_controles_nb TABLE (id_projet uniqueidentifier, projet uniqueidentifier, nb_fichiers int, nb_fichierData int, nb_actes int)
	
	--Projets retraités (A')
	insert @temp_projets_retraites
	select id_projet, nom, 'A''' as statut
	from Projets (nolock)
	where id_projet in ('9219D296-1BEB-4E37-9ABF-A71B592B2421', 'D1A682D4-D117-4D2C-A256-9855EF79DEAC', '9DDEBB0E-38D1-48A7-85E1-F561F2B95AA1','0C4F8E64-047A-4552-8725-929E205B2EE2','E2AC10C8-B670-4F9A-8DFD-1CE471207FBF','B0F8B9B0-99E2-4A12-BB18-E021D0C7F562','3A7C7386-EACF-4BBE-BDFA-39F77659FA01','4CE67ECB-B269-44C8-927B-52B354F808DB','B4323FCA-F824-42F7-8116-630E2EC0F10F','F34FEEC1-0BB3-4D21-A356-EDB44A365648','7DB302ED-8525-48B7-8CEC-932FCEBB27D8','B48730B4-8B2D-4AEF-8EDB-9D8D844AA2A0','EB3FE005-3836-4AEE-BF4A-B76C5406ED8B','5687DAFC-85C7-4D9B-957A-EBBA04F7ACAC','E1E95870-9881-41C9-AD00-B112DA373A7A','0C13983F-845D-4DEF-891E-12F382D347EE','F08A87A0-73C6-43FD-BCC8-2E1637BBE991','BC222059-010B-45C8-85BF-DD246BC4F41B','0F49F5DA-800F-465F-A27E-39C16F3C93B3','EA12F801-0305-409F-A526-8E7FC0954B6F','023B3053-73CD-4990-9B48-5522EBD59C29','A89FAAEC-57DC-42DD-A1EC-D3303910AF96','FC645973-F83D-4D52-9A56-72764D4F92B8','C94C3D9C-1F04-4629-934F-5EFDCD782768','8F80C9ED-6A2E-4B62-B955-6C222B3B4C63','5EB600EE-FF22-440B-85B5-4678CC3993D7')

	--Projets non retraités (A)
	insert @temp_projets_non_retraites
	select id_projet, nom, 'A' as statut
	from Projets (nolock)
	where id_projet not in (select id_projet from @temp_projets_retraites) and id_projet not in ('65042153-90E9-47E8-9BDA-C0DBE370EDD2', '5BC4606A-A0F3-46A9-9542-91D457F271E7', '6F8401B1-301E-44B9-B895-737183B56401', '18F9F73B-2F20-4E11-9396-CE3208715190','2BA5B255-9C49-4F87-AB72-F4D95E9C93A4','09302A58-FAA0-4441-B1D0-D9683BFBEA94','8C6D2075-B353-45E3-96B3-821E4D349BB6','0B86DAC0-599A-4A48-8B16-7E79792779C7','80FC9ADF-A611-4B47-95BB-E7CF395ABEE0','FD653D02-BF44-4678-A243-1B5DC34F8BEC')

	--Tous les projets
	insert @temp_projets
	select * from 
	(
	select *
	from @temp_projets_retraites
	union
	select *
	from @temp_projets_non_retraites) a
	--where id_projet='681102E8-D403-476B-B83E-49A6F0257192'

	--select * from #temp_projets

	--Nb fichiers XML attendus par projet
	insert @nb_xml_attendus_projet
	select p.id_projet, COUNT(fd.id_fichier) as [nb_xml_attendus]
	from FichiersData fd (nolock)
	inner join @temp_projets p on fd.id_projet=p.id_projet
	group by p.id_projet

	--Tous les fichiers acceptés de tous les projets
	insert @temp_fichiers_acceptes
	select p.id_projet, p.nom as projet, t.nom as traitement, f.id_fichier, f.id_fichierData, f.nb_actes
	from dbo.DataXml_fichiers f (nolock)
	inner join FichiersData fd (nolock) on f.id_FichierData=fd.id_fichier
	inner join Traitements t (nolock) on f.id_traitement=t.id_traitement
	inner join @temp_projets p on t.id_projet=p.id_projet --and p.id_projet='9219D296-1BEB-4E37-9ABF-A71B592B2421'
	inner join dbo.DataXml_lots_fichiers lf (nolock) on t.id_traitement=lf.id_traitement and f.id_lot=lf.id_lot
	inner join dbo.DataXmlEchantillonEntete ee (nolock) on ee.id_lot=lf.id_lot and ee.traite=1 and ee.id_statut in (1,3)
	where isnull(t.livraison_annulee,0)=0 and (t.livraison_conforme=1 and t.controle_livraison_conformite=1) and (isnull(f.ignore,0)=0 and isnull(f.rejete,0)=0 and ISNULL(f.conforme,1)=1)
	order by p.nom, f.nom_fichier

	--Tous les fichiers à contrôler
	insert @temp_fichiers_a_controler
	select p.id_projet, p.nom as projet, t.nom as traitement, f.id_fichier, f.id_fichierData, f.nb_actes
	from dbo.DataXml_fichiers f (nolock)
	inner join Traitements t (nolock) on f.id_traitement=t.id_traitement
	inner join @temp_projets p on t.id_projet=p.id_projet --and p.id_projet='7DB302ED-8525-48B7-8CEC-932FCEBB27D8'
	left join dbo.DataXml_lots_fichiers lf (nolock) on t.id_traitement=lf.id_traitement and f.id_lot=lf.id_lot
	left join dbo.DataXmlEchantillonEntete ee (nolock) on ee.id_lot=lf.id_lot and isnull(ee.traite,0)=1
	left join @temp_fichiers_acceptes fa on fa.id_fichier=f.id_fichier
	where isnull(t.livraison_annulee,0)=0 and (t.livraison_conforme=1 and t.controle_livraison_conformite=1) and (isnull(f.ignore,0)=0 and isnull(f.rejete,0)=0 and ISNULL(f.conforme,1)=1)
		and ee.id_echantillon is null and fa.id_fichier is null
	order by p.nom, f.nom_fichier

	--Tous les fichiers rejetés jamais acceptés de tous les projets
	insert @temp_fichiers_rejetes
	select id_projet, projet, traitement, id_fichier, id_fichierData, nb_actes from (
	select ROW_NUMBER() OVER(PARTITION BY f.id_FichierData ORDER BY f.id_traitement DESC) as rn, p.id_projet, p.nom as projet, t.nom as traitement, f.*
	from dbo.DataXml_fichiers f (nolock)
	inner join Traitements t (nolock) on f.id_traitement=t.id_traitement
	inner join @temp_projets p on t.id_projet=p.id_projet
	inner join dbo.DataXml_lots_fichiers lf (nolock) on t.id_traitement=lf.id_traitement and f.id_lot=lf.id_lot
	inner join dbo.DataXmlEchantillonEntete ee (nolock) on ee.id_lot=lf.id_lot and ee.traite=1 and ee.id_statut in (2)
	left join @temp_fichiers_acceptes fa on fa.id_fichierData=f.id_fichierData
	left join @temp_fichiers_a_controler fac on fac.id_fichierData=f.id_fichierData
	where isnull(t.livraison_annulee,0)=0 and (t.livraison_conforme=1 and t.controle_livraison_conformite=1) and (isnull(f.ignore,0)=0 and isnull(f.rejete,0)=0 and ISNULL(f.conforme,1)=1)
		and fa.id_fichierData is null and fac.id_fichierData is null
	) a where a.rn=1
	order by projet, nom_fichier

	--Tous les fichiers reçus et jamais contrôler
	insert @temp_fichiers_recus_jamais_controles
	select p.id_projet, p.nom as projet, t.nom as traitement, f.id_fichier, f.id_fichierData, f.nb_actes
	from dbo.DataXml_fichiers f (nolock)
	inner join Traitements t (nolock) on f.id_traitement=t.id_traitement
	inner join @temp_projets p on t.id_projet=p.id_projet --and p.id_projet='7DB302ED-8525-48B7-8CEC-932FCEBB27D8'
	left join dbo.DataXml_lots_fichiers lf (nolock) on t.id_traitement=lf.id_traitement and f.id_lot=lf.id_lot
	left join dbo.DataXmlEchantillonEntete ee (nolock) on ee.id_lot=lf.id_lot and isnull(ee.traite,0)=1
	left join @temp_fichiers_acceptes fa on fa.id_fichier=f.id_fichier
	left join @temp_fichiers_rejetes fr on fr.id_fichier=f.id_fichier
	where isnull(t.livraison_annulee,0)=0 and (t.livraison_conforme=1 and t.controle_livraison_conformite=1) and (isnull(f.ignore,0)=0 and isnull(f.rejete,0)=0 and ISNULL(f.conforme,1)=1)
		and ee.id_echantillon is null and fa.id_fichier is null and fr.id_fichier is null
	order by p.nom, f.nom_fichier

	insert @temp_fichiers_acceptes_nb select id_projet, projet, COUNT(f.id_fichier) as nb_fichiers, COUNT(distinct f.id_fichierData) as nb_fichierData, SUM(f.nb_actes) as [nb_actes] from @temp_fichiers_acceptes f group by id_projet, projet order by projet
	insert @temp_fichiers_rejetes_nb select id_projet, projet, COUNT(f.id_fichier) as nb_fichiers, COUNT(distinct f.id_fichierData) as nb_fichierData, SUM(f.nb_actes) as [nb_actes] from @temp_fichiers_rejetes f group by id_projet, projet order by projet
	insert @temp_fichiers_a_controler_nb select id_projet, projet, COUNT(f.id_fichier) as nb_fichiers, COUNT(distinct f.id_fichierData) as nb_fichierData, SUM(f.nb_actes) as [nb_actes] from @temp_fichiers_a_controler f group by id_projet, projet order by projet
	insert @temp_fichiers_recus_jamais_controles_nb select id_projet, projet, COUNT(f.id_fichier) as nb_fichiers, COUNT(distinct f.id_fichierData) as nb_fichierData, SUM(f.nb_actes) as [nb_actes] from @temp_fichiers_recus_jamais_controles f group by id_projet, projet order by projet
	/*
	select * from @temp_fichiers_acceptes_nb
	select * from @temp_fichiers_rejetes_nb
	select * from @temp_fichiers_a_controler_nb
	select * from @temp_fichiers_recus_jamais_controles_nb
	*/

	insert @StatsIndexationProjets
	select p.id_projet, p.statut, p.nom as projet, z.nb_xml_attendus
	, isnull(fa.nb_fichierData,0) + isnull(fac.nb_fichierData,0) + isnull(fr.nb_fichierData,0) as [nb_fichiers_xml_livres]
	, isnull(fa.nb_actes,0) + isnull(fac.nb_actes,0) + isnull(fr.nb_actes,0) as [nb_actes_total]
	--/*, fac.nb_fichiers*/, fac.nb_fichierData as [nb_fichierData_a_controler]/*, fac.nb_actes_NMD*/, fac.nb_actes as [nb_actes_a_controler],
	--/*, frjc.nb_fichiers*/, frjc.nb_fichierData as [nb_fichierData_recus_jamais_controles]/*, frjc.nb_actes_NMD*/, frjc.nb_actes as [nb_actes_recus_jamais_controles],
	--/*, fa.nb_fichiers*/, fa.nb_fichierData as [nb_fichierData_acceptes]/*, fa.nb_actes_NMD*/, fa.nb_actes as [nb_actes_acceptes]
	--/*, fr.nb_fichiers*/, fr.nb_fichierData as [nb_fichierData_rejetes]/*, fr.nb_actes_NMD*/, fr.nb_actes as [nb_actes_rejetes]
	--, t.[date_min_livraison], t.[date_max_livraison]
	from @temp_projets p 
	left join @nb_xml_attendus_projet z on z.id_projet=p.id_projet
	left join @temp_fichiers_acceptes_nb fa on p.id_projet=fa.id_projet
	left join @temp_fichiers_a_controler_nb fac on p.id_projet=fac.id_projet
	left join @temp_fichiers_rejetes_nb fr on p.id_projet=fr.id_projet
	left join @temp_fichiers_recus_jamais_controles_nb frjc on p.id_projet=frjc.id_projet
	left join (select id_projet, convert(varchar(10),min(date_livraison),103) as [date_min_livraison], convert(varchar(10),MAX(date_livraison),103) as [date_max_livraison] from dbo.Traitements (nolock) where (controle_livraison_conformite=1 and livraison_conforme=1 and isnull(livraison_annulee,0)=0) group by id_projet) t on p.id_projet=t.id_projet 
	--where fa.id_projet is not null or fac.id_projet is not null or fr.id_projet is not null
	order by p.nom

	
	RETURN; 
END
GO
