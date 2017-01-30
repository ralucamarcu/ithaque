SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[TermTachesNotifications]
   ON  [dbo].[Taches_Logs] 
   FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here

	DECLARE @nom_utilisateur VARCHAR(100), @nom_format_dossier_source VARCHAR(100), @date_debut DATETIME, @date_fin DATETIME, @nom_tache VARCHAR(100)
		,@description_tache VARCHAR(500), @erreur_message VARCHAR(800), @subject_text NVARCHAR(255), @body_text NVARCHAR(MAX) = '', @id_statuts INT
		,@recipients1 VARCHAR(MAX),@recipients2 VARCHAR(MAX),@recipients3 VARCHAR(MAX),@recipientstest VARCHAR(MAX), @id_tache INT,@nb_actes INT,@nb_images INT
		,@nb_fichiers INT,@nom_departement VARCHAR(155),@nb_actes_total_reecrit int,@nb_actes_reecrit_date int,@nb_actes_reecrit_nom_prenom int,@nb_identites int
		,@profileaccount VARCHAR(500)
		
	SET @recipients1 = 'rmarcu@pitechnologies.ro;caroline.guilvard-tran@notrefamille.com;frederic.robillard@notrefamille.com;'
	SET @recipients2 = 'rmarcu@pitechnologies.ro;frederic.robillard@notrefamille.com;vincent.brossier@genealogie.com'
	SET @recipients3 = 'rmarcu@pitechnologies.ro;caroline.guilvard-tran@notrefamille.com;frederic.robillard@notrefamille.com;vincent.brossier@genealogie.com'
	SET @recipientstest = 'rmarcu@pitechnologies.ro'
	SET @profileaccount = 'IthaqueNotifications'
	
	IF UPDATE(date_fin) AND UPDATE(id_status) AND (SELECT i.id_status FROM INSERTED i) in (1,2)
    BEGIN
		SELECT @nom_utilisateur = u.nom + ' ' + u.prenom, @nom_format_dossier_source = s.nom_format_dossier, @date_debut = i.date_debut, @id_tache = i.id_tache
			, @date_fin = i.date_fin, @nom_tache = t.nom_tache, @description_tache = t.description_tache, @erreur_message = i.erreur_message, @id_statuts = i.id_status
		FROM inserted i
		INNER JOIN Taches t WITH (NOLOCK) ON i.id_tache = t.id_tache
		INNER JOIN Sources s WITH (NOLOCK) ON i.id_source = s.id_source
		INNER JOIN Utilisateurs u WITH (NOLOCK) ON i.id_utilisateur = u.id_utilisateur
		
		SET @subject_text = N'La tâche: ' + CAST(@nom_tache AS NVARCHAR(100)) 
			+ (CASE WHEN ISNULL(@nom_format_dossier_source, '') <> '' THEN N' pour le département ' + CAST(@nom_format_dossier_source AS NVARCHAR(100))
				ELSE '' END)
			+ ' a terminé'
		SET @body_text = @body_text + N'La tâche ' + CAST(@nom_tache AS NVARCHAR(100)) + ': - ' + CAST(@description_tache AS NVARCHAR(500))  
				+ (CASE WHEN ISNULL(@nom_format_dossier_source, '') <> '' THEN N' pour le département ' + CAST(@nom_format_dossier_source AS NVARCHAR(100))
				ELSE '' END)
				+ CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'La tâche a été commencé par: ' + CAST(@nom_utilisateur AS NVARCHAR(100)) + N' à '  
			+ CAST(@date_debut AS NVARCHAR(50)) + CHAR(10) + CHAR(13)
		SET @body_text = @body_text + N'La tâche terminée à ' + CAST(@date_fin AS NVARCHAR(50)) + N' avec le statut: '
			+(CASE WHEN @id_statuts = 1 THEN N'Succes' WHEN @id_statuts = 2 THEN N'Erreur: ' + CAST(@erreur_message AS NVARCHAR(800))  ELSE ' Toujours en cours' END)+'. ' + CHAR(10) + CHAR(13)
		print @body_text
		
		IF (@id_tache IN (23,24))
		BEGIN
			SELECT	@nb_actes =nb_actes_total_import,@nb_images=nb_images,@nb_fichiers=nb_fichiers,@nom_departement=nom_departement,@nb_actes_total_reecrit=[nb_actes_total_reecrit],
					@nb_actes_reecrit_date=[nb_actes_reecrit_date],@nb_actes_reecrit_nom_prenom=[nb_actes_reecrit_nom_prenom],@nb_identites=[nb_identites]
			FROM Ithaque_Reecriture.[dbo].[Details_reecriture]
			
			SET @body_text= @body_text + N'Nom du département: ' +  CAST(@nom_departement as NVARCHAR(155)) +',' +N'Nombre fichiers importés: ' + CAST(@nb_fichiers AS NVARCHAR(10)) +', ' + CHAR(10) + CHAR(13)
			SET @body_text= @body_text + N'Nombre d''images importées: ' + CAST(@nb_images AS NVARCHAR(10)) +', '+N'Nombre d''actes importés est ' + CAST(@nb_actes AS NVARCHAR(10)) + CHAR(10) + CHAR(13)
					
		IF (@id_tache =24)
			BEGIN
				SET  @body_text= @body_text + N'Nombre d''actes reecrit: ' + CAST (@nb_actes_total_reecrit AS NVARCHAR(10)) + N', Nombre d''actes reecrit Date: ' + CAST(@nb_actes_reecrit_date AS NVARCHAR(10)) +',' + CHAR(10) + CHAR(13)
				SET  @body_text= @body_text +  N'Nombre d''actes reecrit Nom: ' + CAST (@nb_actes_reecrit_nom_prenom AS NVARCHAR(10)) +N', Nombre des identites: ' +  CAST(@nb_identites AS NVARCHAR(10)) +'.' + CHAR(10) + CHAR(13)
			END
		print @body_text

			EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients2, --2
			  @profile_name = @profileaccount,
			  @subject = @subject_text, 
			  @body = @body_text;	
		END		


		IF (@id_tache =27)
		BEGIN
			SELECT	@nb_actes =nb_actes_total_import
			FROM Ithaque_Reecriture.[dbo].[Details_reecriture]
			
			SET @body_text= @body_text + N'Nombre des actes importés: ' + CAST(@nb_actes AS NVARCHAR(10))
			
			EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients2, --2
			  @profile_name = @profileaccount,
			  @subject = @subject_text, 
			  @body = @body_text;
		END

		IF (@id_tache IN (1,2,7,9,17,21,22))
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients1, --1
			  @profile_name = @profileaccount,
			  @subject = @subject_text, 
			  @body = @body_text;	
        END
        IF (@id_tache IN (4,5,6,11,13,14,15,16,18,25,12,3,29, 28, 32))
		BEGIN
			print 1
			EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients2, --2
			  @profile_name = @profileaccount,
			  @subject = @subject_text, 
			  @body = @body_text;	
        END
        IF (@id_tache IN (10,19,20))
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail
			  @recipients = @recipients3, --3
			  @profile_name = @profileaccount,
			  @subject = @subject_text, 
			  @body = @body_text;	
        END
		--IF (@id_tache IN (12,3))
		--BEGIN
		--	EXEC msdb.dbo.sp_send_dbmail
		--	  @recipients = @recipientstest, 
		--	  @profile_name = @profileaccount,
		--	  @subject = @subject_text, 
		--	  @body = @body_text;	
  --      END
    END
END

GO
DISABLE TRIGGER [dbo].[TermTachesNotifications]
	ON [dbo].[Taches_Logs]
GO
