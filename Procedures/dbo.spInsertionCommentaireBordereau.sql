SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spInsertionCommentaireBordereau
	-- Add the parameters for the stored procedure here
	-- Test Run: spInsertionCommentaireBordereau 467, '\quality\p9973vi-livB20150423-RP-id468\QIReport_p9973vi-livB20150423-EC_Traitement467_20150427_135142.xlsx', 'p9973-Questions-NF-ID467-p9973vi-livB20150423-EC.xlsx'
	@id_traitement INT
	,@fichier_details_controle VARCHAR(500)
	,@fichier_questions VARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @commentaire VARCHAR(MAX), @nom_traitement VARCHAR(255), @nb_total_fichiers INT, @nb_total_actes INT
		,@nb_fichiers_rejetes INT, @nb_actes_rejetes INT, @pourcentage_rejetes FLOAT
    
    CREATE TABLE #tmp (id_fichier UNIQUEIDENTIFIER, id_statut INT)
	INSERT INTO #tmp (id_fichier, id_statut)
    SELECT df.id_fichier, de.id_statut
    FROM DataXml_fichiers df WITH (NOLOCK)
    INNER JOIN DataXmlEchantillonEntete de WITH (NOLOCK)  ON df.id_lot = de.id_lot    
    WHERE df.id_traitement = @id_traitement
    
    SET @nb_total_fichiers =(SELECT COUNT(id_fichier) FROM #tmp)
    SET @nb_total_actes = (SELECT COUNT(da.id) FROM DataXmlRC_actes da WITH (NOLOCK) INNER JOIN #tmp ON da.id_fichier = #tmp.id_fichier)
    
    DELETE FROM #tmp WHERE id_statut <> 2
    SET @nb_fichiers_rejetes =(SELECT COUNT(id_fichier) FROM #tmp)
    SET @nb_actes_rejetes = (SELECT COUNT(da.id) FROM DataXmlRC_actes da WITH (NOLOCK) INNER JOIN #tmp ON da.id_fichier = #tmp.id_fichier)
    
    SET @pourcentage_rejetes = (CASE WHEN (ISNULL(@nb_fichiers_rejetes, 0) <> 0 AND ISNULL(@nb_total_fichiers, 0) <> 0 )
			THEN CAST(CAST(CAST(@nb_fichiers_rejetes AS FLOAT) / CAST( @nb_total_fichiers  AS FLOAT) AS FLOAT) * 100 AS FLOAT) ELSE NULL END)
			
	SET @nom_traitement = (SELECT RIGHT(REPLACE(REPLACE(REPLACE(REPLACE (t.nom, 'livA', ''), 'livB', ''), 'liv', ''), REPLACE(p.nom, '-', ''), '')
							,LEN(REPLACE(REPLACE(REPLACE(REPLACE (t.nom, 'livA', ''), 'livB', ''), 'liv', ''), REPLACE(p.nom, '-', ''), ''))-1)
						FROM Traitements t INNER JOIN projets p ON p.id_projet = t.id_projet WHERE id_traitement = @id_traitement)
	
	

    
    SET @commentaire = 'Pour la livraison ' + @nom_traitement + ' (Id' + CAST(@id_traitement AS VARCHAR(50)) + '):
		Taux de rejet : ' + CAST(@pourcentage_rejetes AS VARCHAR(10)) + '% [' + CAST(@nb_actes_rejetes AS VARCHAR(10)) + ' actes sur '
		 + CAST(@nb_fichiers_rejetes AS VARCHAR(10)) + ' fichiers sur ' + CAST(@nb_total_actes AS VARCHAR(10)) + ' actes livrés dans '
		  + CAST(@nb_total_fichiers AS VARCHAR(10)) + ' fichiers]
		Détails de contrôle disponibles dans : ' + @fichier_details_controle + '
		Fichier de questions : ' + @fichier_questions
		
	UPDATE Traitements 
	SET commentaire_bordereau = @commentaire
	WHERE id_traitement = @id_traitement
END





GO
