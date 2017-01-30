SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spFichiersSelectionStatParProjet 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    create table #tmp (id_fichier varchar(255), conforme int, id_statut int, traite int)
    create table #tmp2 (nom_projet varchar(255), nb_fichiers_acceptes_cq int, nb_fichiers_refuses_cq int, nb_fichiers_total int)
	declare @id_projet uniqueidentifier, @nb_fichiers_acceptes_cq int, @nb_fichiers_refuses_cq int, @nb_fichiers_total int
	
	declare cursor_fichiers cursor for
	select t.id_projet
	from DataXml_fichiers dxf with (nolock)
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement
	group by t.id_projet
	open cursor_fichiers 
	fetch cursor_fichiers into @id_projet
	while @@FETCH_STATUS = 0
	begin	
		insert into #tmp (id_fichier, id_statut)
		select dxf.id_fichier, dxee.id_statut
		from DataXml_fichiers dxf with (nolock)
		inner join DataXmlEchantillonEntete dxee with (nolock) on dxf.id_lot = dxee.id_lot
		inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement
		where id_projet = @id_projet
		
		set @nb_fichiers_total = (select COUNT(id_fichier) from #tmp)
		set @nb_fichiers_acceptes_cq = (select COUNT(id_fichier) from #tmp where id_statut in (1,3))
		set @nb_fichiers_refuses_cq  = (select COUNT(id_fichier) from #tmp where id_statut = 2)
		
		insert into #tmp2(nom_projet, nb_fichiers_acceptes_cq, nb_fichiers_refuses_cq, nb_fichiers_total)
		select nom, @nb_fichiers_acceptes_cq, @nb_fichiers_refuses_cq, @nb_fichiers_total
		from Projets with (nolock)
		where id_projet = @id_projet
		
		truncate table #tmp
		
		fetch cursor_fichiers into @id_projet
	end
	close cursor_fichiers
	deallocate cursor_fichiers
	
	select * from #tmp2 where nb_fichiers_total <> 0
	
	drop table #tmp
	drop table #tmp2
END
GO
