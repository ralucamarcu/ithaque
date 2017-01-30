SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure spInsertionAnneeRepublicaineComplementaires
@annee_republicaine varchar(10)
,@annee_gregoriene int
,@bissextile bit --1/0
,@after_bissextile bit --1/0
as

declare  @mois_republicaine varchar(100) = null, @jour_republicaine int = null, @date_republicaine varchar(255) = null
,@date_gregoriene_string varchar(255)
, @date_gregoriene datetime = null, @mois_gregoriene varchar(50) = null, @jour_gregoriene int = null

set @jour_republicaine = 1
set @jour_gregoriene = 17
set @mois_republicaine = 'complémentaire'

begin

	if @bissextile = 0
	begin
		while @jour_republicaine <=5 and @jour_gregoriene <=21
		begin
			set @date_republicaine = CAST(@jour_republicaine as varchar(5)) + ' ' + @mois_republicaine + ' ' + @annee_republicaine
			set @date_gregoriene_string = CAST(@jour_gregoriene as varchar(5))+'.09.'+CAST(@annee_gregoriene as varchar(5))
			set @date_gregoriene = convert(datetime,  @date_gregoriene_string, 104)
			insert into dates_republicaines(annee_republicaine, mois_republicaine, jour_republicaine, date_republicaine
					, annee_gregoriene, mois_gregoriene, jour_gregoriene, date_gregoriene)
			values (@annee_republicaine, @mois_republicaine, @jour_republicaine, @date_republicaine, @annee_gregoriene, 9, @jour_gregoriene
			, @date_gregoriene)		
			
			set @jour_republicaine = @jour_republicaine + 1
			set @jour_gregoriene = @jour_gregoriene + 1
		end
	end


	if @bissextile = 1
	begin
		while @jour_republicaine <=6 and @jour_gregoriene <=22
		begin
			set @date_republicaine = CAST(@jour_republicaine as varchar(5)) + ' ' + @mois_republicaine + ' ' + @annee_republicaine
			set @date_gregoriene_string = CAST(@jour_gregoriene as varchar(5))+'.09.'+CAST(@annee_gregoriene as varchar(5))
			set @date_gregoriene = convert(datetime,  @date_gregoriene_string, 104)
			insert into dates_republicaines(annee_republicaine, mois_republicaine, jour_republicaine, date_republicaine
					, annee_gregoriene, mois_gregoriene, jour_gregoriene, date_gregoriene)
			values (@annee_republicaine, @mois_republicaine, @jour_republicaine, @date_republicaine, @annee_gregoriene, 9, @jour_gregoriene
			, @date_gregoriene)		
			
			set @jour_republicaine = @jour_republicaine + 1
			set @jour_gregoriene = @jour_gregoriene + 1
		end
	end
	
	if @after_bissextile = 1
	begin
		update dates_republicaines
		set date_gregoriene = DATEADD(DAY, 1, date_gregoriene)
			,jour_gregoriene = jour_gregoriene + 1
		where annee_republicaine = @annee_republicaine
		and mois_republicaine = 'complémentaire'
		
	end
end
GO
