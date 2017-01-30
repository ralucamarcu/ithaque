SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER DateRetourCQNotification
   ON  dbo.Traitements
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    DECLARE @id_traitement INT, @subject_text NVARCHAR(255), @body_text NVARCHAR(MAX) = '', @date_retour_cq DATETIME, @date_livraison DATETIME, @nom_livraison VARCHAR(100)
		,@nb_lots_rejetes INT, @nb_lots_acceptes INT, @utilisateurs_list VARCHAR(255) = '';

    IF UPDATE(date_retour_cq)
    BEGIN
		SELECT @id_traitement = i.id_traitement , @date_retour_cq = date_retour_cq, @date_livraison = date_livraison, @nom_livraison = nom
		FROM inserted i 
		
		SELECT @utilisateurs_list+=u.nom+' '+u.prenom+', '
		FROM inserted i
		INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON i.id_traitement = dxee.id_traitement
		INNER JOIN Utilisateurs u WITH (NOLOCK) ON dxee.id_utilisateur_verrou = u.id_utilisateur
		GROUP BY u.nom, u.prenom
		IF ISNULL(@utilisateurs_list, '') <> ''
		BEGIN
			SET @utilisateurs_list = LEFT(@utilisateurs_list,LEN(@utilisateurs_list)-1);
		END
		
		SET @nb_lots_rejetes = (SELECT COUNT(id_echantillon) 
			FROM inserted i
			INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON i.id_traitement = dxee.id_traitement 
			WHERE dxee.traite = 1 AND id_statut = 2)
			
		SET @nb_lots_acceptes = (SELECT COUNT(id_echantillon) 
			FROM inserted i
			INNER JOIN DataXmlEchantillonEntete dxee WITH (NOLOCK) ON i.id_traitement = dxee.id_traitement 
			WHERE dxee.traite = 1 AND id_statut IN (1,3))
		
		SET @subject_text = N'Etat Contrôle de la Qualité pour la Livraison: ' + CAST(@nom_livraison AS NVARCHAR(50))
		SET @body_text = @body_text + N'L''Etat Contrôle de la Qualité pour la Livraison ' + CAST(@nom_livraison AS NVARCHAR(50)) + N', avec l''Id Livraison '
			+ CAST(@id_traitement AS NVARCHAR(10)) + N' est: ' + CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'Nombre lots rejeté: ' + CAST(@nb_lots_rejetes AS NVARCHAR(10))  + CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'Nombre lots accepté: ' + CAST(@nb_lots_acceptes AS NVARCHAR(10))  + CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'Le contrôle de la qualité pour la Livraison ' + CAST(@nom_livraison AS NVARCHAR(50))  
			+ N' a été traitée par: '+ CAST(@utilisateurs_list AS NVARCHAR(50))   + CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'et le contrôle terminé dans la date: ' + CAST(@date_retour_cq AS NVARCHAR(50)) 
		PRINT @body_text

        EXEC msdb.dbo.sp_send_dbmail
          @recipients = 'rmarcu@pitechnologies.ro;caroline.guilvard-tran@notrefamille.com;frederic.robillard@notrefamille.com;vincent.brossier@genealogie.com', 
          @profile_name = 'Raluca',
          @subject = @subject_text, 
          @body = @body_text;
    END
END
GO
