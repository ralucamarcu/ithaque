SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 28/03/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spFichiersData_Dashboard]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--	DECLARE @query  AS NVARCHAR(MAX)
	--set @query = 'SELECT id_projet, p.nom ,SUM([1]) as [type1], SUM([2]) as [type2], SUM([3]) as [type3], SUM([4]) as [type4], SUM([5]) as [type5], SUM([6]) as [type6], SUM([8]) as [type8], SUM([9]) as [type9], SUM([16]) as [type16], SUM([17]) as [type17], SUM([18]) as [type18] from 
	--			 (
	--				select p.id_projet, p.nom, e.id_type_evenement, t.libelle, COUNT(distinct f.id_fichier) as nb 
	--				from Projets p(nolock)
	--				left join FichiersData f (nolock) on p.id_projet = f.id_projet
	--				left join FichiersData_Evenements_Fichiers e (nolock) on f.id_fichier=e.id_fichier  
	--				left join FichiersData_Types_Evenements t (nolock) on t.id_type_evenement = e.id_type_evenement and t.id_type_evenement in (1,2,3,4,5,6,8,9,16,17,18)
	--				group by p.id_projet, p.nom, e.id_type_evenement, t.libelle
	--			) x
	--			pivot 
	--			(
	--				sum(nb)
	--				for id_type_evenement in ([1],[2],[3],[4],[5],[6],[8],[9],[16],[17],[18])
	--			) p 
	--			group by id_projet, p.nom'

	--execute(@query);


	CREATE TABLE #tmp (id_projet UNIQUEIDENTIFIER, nom VARCHAR(255), [type1] INT, [type2] INT, [type3] INT, [type4] INT, [type5] INT, [type6] INT
		, [type8] INT, [type9] INT, [type16] INT, [type17] INT, [type18] INT)
	INSERT INTO #tmp (id_projet, nom, [type1], [type2], [type3], [type4], [type5], [type6], [type8], [type9], [type16], [type17], [type18])
	SELECT
		p.id_projet, p.nom 
	   , (CASE WHEN e.id_type_evenement = 1 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type1]'
	   , (CASE WHEN e.id_type_evenement = 2 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type2]'
	   , (CASE WHEN e.id_type_evenement = 3 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type3]'
	   , (CASE WHEN e.id_type_evenement = 4 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type4]'
	   , (CASE WHEN e.id_type_evenement = 5 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type5]'
	   , (CASE WHEN e.id_type_evenement = 6 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type6]'
	   , (CASE WHEN e.id_type_evenement = 8 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type8]'
	   , (CASE WHEN e.id_type_evenement = 9 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type9]'
	   , (CASE WHEN e.id_type_evenement = 16 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type16]'
	   , (CASE WHEN e.id_type_evenement = 17 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type17]'
	   , (CASE WHEN e.id_type_evenement = 18 THEN COUNT(DISTINCT f.id_fichier) END) AS '[type18]'
	FROM Projets p(NOLOCK)
	LEFT JOIN FichiersData f (NOLOCK) ON p.id_projet = f.id_projet
	LEFT JOIN FichiersData_Evenements_Fichiers e (NOLOCK) ON f.id_fichier=e.id_fichier  
	LEFT JOIN FichiersData_Types_Evenements t (NOLOCK) ON t.id_type_evenement = e.id_type_evenement AND t.id_type_evenement IN (1,2,3,4,5,6,8,9,16,17,18)
	GROUP BY p.id_projet, p.nom ,  e.id_type_evenement

	SELECT id_projet, nom
		--, (CASE WHEN MAX(ISNULL([type1],0)) = 0 THEN NULL ELSE MAX(ISNULL([type1],0)) END) AS [type1]
		--, (CASE WHEN MAX(ISNULL([type2],0)) = 0 THEN NULL ELSE MAX(ISNULL([type2],0)) END) AS [type2] 
		--, (CASE WHEN MAX(ISNULL([type3],0)) = 0 THEN NULL ELSE MAX(ISNULL([type3],0)) END) AS [type3]
		--, (CASE WHEN MAX(ISNULL([type4],0)) = 0 THEN NULL ELSE MAX(ISNULL([type4],0)) END) AS [type4]
		--, (CASE WHEN MAX(ISNULL([type5],0)) = 0 THEN NULL ELSE MAX(ISNULL([type5],0)) END) AS [type5]
		--, (CASE WHEN MAX(ISNULL([type6],0)) = 0 THEN NULL ELSE MAX(ISNULL([type6],0)) END) AS [type6]
		--, (CASE WHEN MAX(ISNULL([type8],0)) = 0 THEN NULL ELSE MAX(ISNULL([type8],0)) END) AS [type8]
		--, (CASE WHEN MAX(ISNULL([type9],0)) = 0 THEN NULL ELSE MAX(ISNULL([type9],0)) END) AS [type9]
		--, (CASE WHEN MAX(ISNULL([type16],0)) = 0 THEN NULL ELSE MAX(ISNULL([type16],0)) END) AS [type16]
		--, (CASE WHEN MAX(ISNULL([type17],0)) = 0 THEN NULL ELSE MAX(ISNULL([type17],0)) END) AS [type17]
		--, (CASE WHEN MAX(ISNULL([type18],0)) = 0 THEN NULL ELSE MAX(ISNULL([type18],0)) END) AS [type18]
		, MAX(ISNULL([type1],0)) AS [type1] 
		, MAX(ISNULL([type2],0)) AS [type2] 
		, MAX(ISNULL([type3],0)) AS [type3]
		, MAX(ISNULL([type4],0)) AS [type4]
		, MAX(ISNULL([type5],0)) AS [type5]
		, MAX(ISNULL([type6],0)) AS [type6]
		, MAX(ISNULL([type8],0)) AS [type8]
		, MAX(ISNULL([type9],0)) AS [type9]
		, MAX(ISNULL([type16],0)) AS [type16]
		, MAX(ISNULL([type17],0)) AS [type17]
		, MAX(ISNULL([type18],0)) AS [type18]
	FROM #tmp
	GROUP BY id_projet, nom

	DROP TABLE #tmp

END
GO
