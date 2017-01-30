SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure spInsertionAnneeRepublicaine
--test Run : spInsertionAnneeRepublicaine 4, '22.09.1794'
@contor_annee int  
,@date_gregoriene datetime  
as

declare @annee_republicaine varchar(50) = null, @mois_republicaine varchar(100) = null, @jour_republicaine int = null
, @date_republicaine varchar(255) = null, @annee_gregoriene int = null, @mois_gregoriene varchar(50) = null, @jour_gregoriene int = null

,@contor_mois int = 1

,@contor_jour int = 1
if @contor_annee < 10
begin
	set @annee_republicaine = 'AN0' + cast(@contor_annee as varchar(2))
end
else
begin
	set @annee_republicaine = 'AN' + cast(@contor_annee as varchar(2))
end
	print @annee_republicaine
	while @contor_mois <= 12
	begin
		set @mois_republicaine = (select mois from mois_republicain where id_mois = @contor_mois)
		print @mois_republicaine
		while @contor_jour < =30
		begin
			print @jour_republicaine
			set @jour_republicaine = @contor_jour
			set @date_republicaine = cast(@jour_republicaine as varchar(50)) + ' '+ @mois_republicaine + ' ' + @annee_republicaine
			print @date_republicaine
			
			set @date_gregoriene = DATEADD(DAY,1, @date_gregoriene)
			set @annee_gregoriene = YEAR(@date_gregoriene)
			set @mois_gregoriene = MONTH(@date_gregoriene)
			set @jour_gregoriene = DAY(@date_gregoriene)
			
			 
			insert into dates_republicaines(annee_republicaine, mois_republicaine, jour_republicaine, date_republicaine
			, annee_gregoriene, mois_gregoriene, jour_gregoriene, date_gregoriene)
			values (@annee_republicaine, @mois_republicaine, @jour_republicaine, @date_republicaine
			, @annee_gregoriene, @mois_gregoriene, @jour_gregoriene, @date_gregoriene)
			
			set @contor_jour = @contor_jour + 1
			set @annee_gregoriene = null
			set @mois_gregoriene = null
			set @jour_gregoriene = null
			set @date_republicaine = null
			set @jour_republicaine = null
		end
		
		set @contor_mois = @contor_mois + 1
		set @mois_republicaine = null
		set @contor_jour = 1
	end
	
	set @annee_republicaine = null
	set @contor_mois = 1
GO
