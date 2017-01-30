SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SearchAndReplace
-- Test Run : SearchAndReplace 'dbo.DataXmlRC_actes', '§', '?'
(
	@table varchar(255)
	,@from_cond varchar(2000)
	,@id_projet uniqueidentifier
	,@search_string varchar(5) 
	,@replace_string varchar(5) 
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ColumnName nvarchar(128), @search_string2 nvarchar(110), @SQL nvarchar(4000), @RCTR int
	SET @search_string2 = QUOTENAME('%' + @search_string + '%','''')
	SET @RCTR = 0

	
	BEGIN
		SET @ColumnName = ''
		
		print @table

		WHILE (@ColumnName IS NOT NULL)
		BEGIN
			SET @ColumnName =
			(
				SELECT MIN(QUOTENAME(COLUMN_NAME))
				FROM 	INFORMATION_SCHEMA.COLUMNS
				WHERE 		TABLE_SCHEMA	= PARSENAME(@table, 2)
					AND	TABLE_NAME	= PARSENAME(@table, 1)
					AND	DATA_TYPE IN ('char', 'varchar', 'nchar', 'nvarchar')
					AND	QUOTENAME(COLUMN_NAME) > @ColumnName
			)
			--print @ColumnName
			
			--IF @ColumnName IS NOT NULL
			--BEGIN
			--	SET @SQL=	'if exists( ' + ' select *'  + 
			--			@from_cond +
			--			' WHERE id_projet = ''' + cast(@id_projet as nvarchar(255)) + ''' AND ' + @ColumnName + ' LIKE ' + @search_string2
			--			+ ')'
			--			+' begin '
			--			+ ' select *'  + 
			--			@from_cond +
			--			' WHERE id_projet = ''' + cast(@id_projet as nvarchar(255)) + ''' AND ' + @ColumnName + ' LIKE ' + @search_string2
			--			+' end '
			--	print @sql
			--	EXEC (@SQL)
			--	SET @RCTR = @RCTR + @@ROWCOUNT
			--	print @SQL
			--END
			
			IF @ColumnName IS NOT NULL
			BEGIN
				SET @SQL= 'IF EXISTS( ' + ' SELECT *'   
							+ @from_cond 
							+ ' WHERE id_projet = ''' + cast(@id_projet as nvarchar(255)) + ''' AND ' + @ColumnName + ' LIKE ' + @search_string2
							+ ')'
							+' BEGIN '	
									+ 'UPDATE ' + @table + 
									' SET ' + @ColumnName 
									+ ' =  REPLACE(' + @ColumnName + ', ' 
									+ QUOTENAME(@search_string, '''') + ', ' + QUOTENAME(@replace_string, '''') + 
									') ' 
									+ @from_cond +
									' WHERE id_projet = ''' + cast(@id_projet as nvarchar(255)) + ''' AND ' + @ColumnName + ' LIKE ' + @search_string2
							+' END '
				print @SQL
				EXEC (@SQL)
				SET @RCTR = @RCTR + @@ROWCOUNT
			END
		END	
	END

	SELECT 'Replaced ' + CAST(@RCTR AS varchar) + ' occurence(s)' AS 'Outcome'
END
GO
