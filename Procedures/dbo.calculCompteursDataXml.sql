SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frederic Robillard
-- Create date: 15/03/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[calculCompteursDataXml] 
	@id_traitement integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @nb_actes_EC as int
	DECLARE @nb_actes_TD as int
	DECLARE @nb_individus_TD as int
	DECLARE @id_compteur int, @id_type_traitement int, @nom_compeur varchar(100), @requete_sql varchar(1000)
	DECLARE @sql as nvarchar(1000)
	DECLARE @outputVariable as int
	
	DELETE Compteurs_traitements WHERE id_traitement=@id_traitement

	DECLARE Compteurs_Cursor CURSOR FOR
	SELECT a.id_compteur, a.id_type_traitement, a.nom_compteur, a.requete_sql 
	FROM dbo.Compteurs_types_traitements a WITH (nolock)
	INNER JOIN dbo.Traitements b WITH (nolock) ON a.id_type_traitement=b.id_type_traitement
	WHERE b.id_traitement=@id_traitement and LEN(requete_sql)>0
	ORDER by a.ordre;

	OPEN Compteurs_Cursor;
	FETCH NEXT FROM Compteurs_Cursor
	INTO @id_compteur, @id_type_traitement, @nom_compeur, @requete_sql 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @sql = CAST(@requete_sql as nvarchar(2000))
		PRINT @sql
		EXEC sp_executesql @sql, N'@id_traitement integer, @output INT OUTPUT', @id_traitement, @outputVariable OUTPUT WITH RECOMPILE
		PRINT '@outputVariable : ' + cast(@outputVariable as varchar(max))
		INSERT INTO dbo.Compteurs_traitements (id_compteur, valeur, id_traitement) VALUES (@id_compteur, @outputVariable, @id_traitement) 
		SET @requete_sql = ''
		SET @outputVariable = ''
		FETCH NEXT FROM Compteurs_Cursor
		INTO @id_compteur, @id_type_traitement, @nom_compeur, @requete_sql
	END;

	CLOSE Compteurs_Cursor;
	DEALLOCATE Compteurs_Cursor;END

GO
