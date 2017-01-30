SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 08-09-2014
-- Description:
-- =============================================
CREATE PROCEDURE  [dbo].[spImportFileMetadata]
	-- Add the parameters for the stored procedure here
	-- Test Run : spImportFileMetadata '1E0C01C4-24C6-41B3-915F-35BFED4985FB'
	@id_source uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    delete from FilesMetadata where id_source = @id_source
    
    declare @id_file int, @file_path varchar(500), @file_name varchar(255), @current_date datetime = getdate()
		, @file_name_path varchar(255)
	
	
	declare cursor_1 cursor for
	select * from Files with (nolock) where FILE_PATH LIKE '%workspace%'
	open cursor_1
	fetch next from cursor_1 into @id_file,@file_path,@file_name
	while @@FETCH_STATUS = 0
	begin
		set @file_name_path = @file_path + @file_name 		
		insert into dbo.FilesMetadata (id_source, path_source, taille_file_metadata_KB, type_file_metadata, id_status, date_creation
			, nom_fichier_metadata, date_dernier_acces, date_derniere_maj)		
		select @id_source as id_source, @file_path as path_source, Size as taille_file_metadata_KB, Type as type_file_metadata
			, 1 as id_status, isnull(DateCreated, @current_date) as date_creation, Name as nom_fichier_metadata, DateLastAccessed as date_dernier_acces
			, DateLastModified as date_derniere_maj
		from [dbo].[fnSelectionDetailsFichier] (@file_path, @file_name_path)
		print @file_name
		print @file_path

		fetch next from cursor_1 into @id_file,@file_path,@file_name
	end
	close cursor_1
	deallocate cursor_1

	
END

GO
