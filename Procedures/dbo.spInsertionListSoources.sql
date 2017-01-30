SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spInsertionListSoources
	@id_source_list varchar(5000)='524D274A-A7FA-475F-958D-2F4155E5279B,DDFF87EC-422E-4E72-8651-92CB59B02901,7B287C70-FB0E-4182-9440-549F3102A8B8,7B287C70-FB0E-4182-9440-549F3102A8B0'
	,@ordre_list varchar (5000)='1,2,3,4'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @sDelimiter VARCHAR(8000) = ',',@sItem VARCHAR(8000),@last_element VARCHAR(8000),@sItem_order VARCHAR(8000),@last_element_order VARCHAR(8000)
	CREATE TABLE #temp_sources(id int identity,id_source UNIQUEIDENTIFIER)
	CREATE TABLE #temp_ordre(id int identity,ordre int)
	
	
	WHILE CHARINDEX(@sDelimiter,@id_source_list,0) <> 0
	BEGIN
		 SELECT @sItem=RTRIM(LTRIM(SUBSTRING(@id_source_list,1,CHARINDEX(@sDelimiter,@id_source_list,0)-1))),
		  @id_source_list=RTRIM(LTRIM(SUBSTRING(@id_source_list,CHARINDEX(@sDelimiter,@id_source_list,0)+LEN(@sDelimiter),LEN(@id_source_list)))),
		  @last_element=RTRIM(LTRIM(@id_source_list))
 		IF LEN(@sItem) > 0
		BEGIN
			insert into #temp_sources(id_source) SElect @sItem
		END
	 END
	 IF LEN(@sItem) > 0
		BEGIN
			insert into #temp_sources(id_source) SElect @last_element
		END


	WHILE CHARINDEX(@sDelimiter,@ordre_list,0) <> 0
	BEGIN
		 SELECT @sItem_order=RTRIM(LTRIM(SUBSTRING(@ordre_list,1,CHARINDEX(@sDelimiter,@ordre_list,0)-1))),
		  @ordre_list=RTRIM(LTRIM(SUBSTRING(@ordre_list,CHARINDEX(@sDelimiter,@ordre_list,0)+LEN(@sDelimiter),LEN(@ordre_list)))),
		  @last_element_order=RTRIM(LTRIM(@ordre_list))

   
		IF LEN(@sItem_order) > 0
		BEGIN
			insert into #temp_ordre(ordre) SElect @sItem_order
		END
	 END
	 IF LEN(@sItem_order) > 0
		BEGIN
			insert into #temp_ordre(ordre) SElect @last_element_order
		END
	
	SELECT id_source,ordre INTO #temp_source_ordre FROM #temp_sources ts inner join #temp_ordre tor ON ts.id=tor.id
	
	UPDATE Taches_Logs_test
	SET [doit_etre_execute]=0
	WHERE ordre in (SELECT ordre FROM #temp_source_ordre) AND id_status=4 -- [doit_etre_execute]=1 AND 

	UPDATE Taches_Logs_test
	SET	 ordre=tso.ordre
		,[doit_etre_execute]=1
	FROM Taches_Logs_test ts (nolock) inner join #temp_source_ordre tso (NOLOCK) on ts.id_source=tso.id_source
	WHERE ts.id_status=4

select * from #temp_source_ordre
select * from #temp_sources
select * from #temp_ordre

	DROP TABLE #temp_source_ordre
	DROP TABLE #temp_sources
	DROP TABLE #temp_ordre


END
GO
