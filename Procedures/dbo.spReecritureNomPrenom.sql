SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [spReecritureNomPrenom] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecritureNomPrenom] '85FB4438-6E26-4419-94BF-3CABC3C241D3'
	@id_projet uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @id_individu int, @id_acte int, @nom_initial varchar(255), @prenom_initial varchar(255), @nom_reecriture varchar(255)
		,@prenom_reecriture varchar(255), @nom_variante varchar(255), @prenom_variante varchar(255), @current_date datetime, @type_acte varchar(255)
	create table #tmp(string varchar(255))	
	create table #tmp2(id_identity int, string varchar(255))
	create table #tmp3(id_identity int, string varchar(255), id_type_identite int)
	set @current_date = GETDATE()
	
	declare cursor_1 cursor for
	select dxi.id as id_individu, dxi.id_acte, dxi.nom, dxi.prenom, dxa.type_acte
	from DataXmlRC_individus dxi with (nolock)
	inner join DataXmlRC_actes dxa with (nolock) on dxa.id = dxi.id_acte
	inner join DataXml_fichiers dxf with (nolock) on dxa.id_fichier = dxf.id_fichier
	inner join Traitements t with (nolock) on dxf.id_traitement = t.id_traitement
	where t.id_projet = @id_projet
		--and ()
	open cursor_1
	fetch cursor_1 into @id_individu, @id_acte, @nom_initial, @prenom_initial, @type_acte
	while @@FETCH_STATUS = 0
	begin
		--truncate table #tmp2
		--truncate table #tmp3
		insert into #tmp
		exec spReecritureNom @string = @nom_initial		
		select @nom_reecriture = (select string from #tmp)		
		truncate table #tmp
		
		insert into #tmp
		exec spReecriturePrenom @string = @prenom_initial		
		select @prenom_reecriture = (select string from #tmp)
		truncate table #tmp
		
		update DataXmlRC_individus
		set nom_Correction_Reecriture = (case when nom <> @nom_reecriture then @nom_reecriture else null end)
			,prenom_Correction_Reecriture = (case when prenom <> @prenom_reecriture then @prenom_reecriture else null end)
		where id = @id_individu		
		
		INSERT INTO #tmp2
		EXEC spReecritureNomVariante @string = @nom_initial
		
		if ((select count(*) from #tmp2) > 1) or (((select count(*) from #tmp2) = 1) and ((select string from #tmp2) <> @nom_initial))
		begin			
			if (@nom_initial like '--' and @type_acte in ('deces', 'mariage', 'recensement'))
			begin
				insert into DataXmlRC_individus_identites(id_acte, id_individu, id_type_identite, ordre, nom, prenom, date_creation)
				select @id_acte as id_acte, @id_individu as id_individu, 3 as id_type_identite, id_identity as ordre, string as nom
					, @prenom_initial as prenom, @current_date as date_creation
				from #tmp2
				where string = RTRIM(LTRIM(LEFT(@nom_initial, CHARINDEX('--', @nom_initial) - 1)))	
				
				insert into DataXmlRC_individus_identites(id_acte, id_individu, id_type_identite, ordre, nom, prenom, date_creation)
				select @id_acte as id_acte, @id_individu as id_individu, 3 as id_type_identite, id_identity as ordre, string as nom
					, null as prenom, @current_date as date_creation
				from #tmp2
				where string = RTRIM(LTRIM(REPLACE(SUBSTRING(@nom_initial, CHARINDEX('--', @nom_initial), LEN(@nom_initial)), '--', '')))				
			end
			else
			begin
				insert into DataXmlRC_individus_identites(id_acte, id_individu, id_type_identite, ordre, nom, prenom, date_creation)
				select @id_acte as id_acte, @id_individu as id_individu, 3 as id_type_identite, id_identity as ordre, string as nom
					, @prenom_initial as prenom, @current_date as date_creation
				from #tmp2
				where string <> @nom_initial
			end
		end
		
		INSERT INTO #tmp3
		EXEC [spReecriturePrenomVariante] @string = @prenom_initial 
		
		if exists (select * from #tmp3 where id_type_identite in (6,7))
		begin
			insert into DataXmlRC_individus_identites(id_acte, id_individu, id_type_identite, ordre, nom, prenom, date_creation)
			select @id_acte as id_acte, @id_individu as id_individu, id_type_identite as id_type_identite, id_identity as ordre, string as nom
				,@prenom_initial  as prenom, @current_date as date_creation
			from #tmp3
		end
		
		if exists (select * from #tmp3 where id_type_identite = 3)
		begin
			insert into DataXmlRC_individus_identites(id_acte, id_individu, id_type_identite, ordre, nom, prenom, date_creation)
			select @id_acte as id_acte, @id_individu as id_individu, id_type_identite as id_type_identite, id_identity as ordre, @nom_initial as nom
				,string  as prenom, @current_date as date_creation
			from #tmp3
			where string <> @prenom_initial
		end
		
		
		truncate table #tmp2
		truncate table #tmp3
		
		fetch cursor_1 into @id_individu, @id_acte, @nom_initial, @prenom_initial, @type_acte
	end
	close cursor_1
	deallocate cursor_1
	
	drop table #tmp
	drop table #tmp2
    drop table #tmp3
END
GO
