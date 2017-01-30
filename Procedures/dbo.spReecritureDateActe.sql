SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecritureDateActe] 
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecritureDateActe] '85FB4438-6E26-4419-94BF-3CABC3C241D3'
	@id_projet UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @annee_acte NVARCHAR(50), @date_acte NVARCHAR(50), @calendrier_date_acte VARCHAR(255), @id_acte INT
		,@annee_acte_numeric INT, @date_acte_datetime DATETIME
		,@jour_acte_republicain INT, @mois_acte_republicain VARCHAR(50), @annee_republicaine VARCHAR(20)
	
	IF OBJECT_ID('tmp_reecriture_date_acte') IS NULL 
	BEGIN
		CREATE TABLE tmp_reecriture_date_acte (id_acte INT, annee_acte NVARCHAR(50), date_acte NVARCHAR(50), calendrier_date_acte NVARCHAR(50)
			,date_acte_Correction_Reecriture NVARCHAR(50), annee_acte_Correction_Reecriture NVARCHAR(50))
		INSERT INTO tmp_reecriture_date_acte (id_acte, annee_acte, date_acte, calendrier_date_acte)
		SELECT dxa.id AS id_acte, dxa.annee_acte, dxa.date_acte, dxa.calendrier_date_acte
		FROM DataXmlRC_actes dxa WITH (NOLOCK)
		INNER JOIN DataXml_fichiers dxf WITH (NOLOCK) ON dxa.id_fichier = dxf.id_fichier
		INNER JOIN Traitements t WITH (NOLOCK) ON dxf.id_traitement = t.id_traitement
		WHERE t.id_projet = @id_projet
	END
	
	
	DECLARE cursor_1 CURSOR FOR
	SELECT id_acte, annee_acte, date_acte, calendrier_date_acte
	FROM tmp_reecriture_date_acte WITH (NOLOCK)
	WHERE date_acte_Correction_Reecriture IS NULL
		AND ISNULL(date_acte,'') <> ''
		AND ISNULL(annee_acte,'') <> ''
	OPEN cursor_1
	FETCH cursor_1 INTO @id_acte, @annee_acte, @date_acte, @calendrier_date_acte
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @id_acte
		IF (@calendrier_date_acte = 'republicain')
		BEGIN
		PRINT 11
			IF EXISTS(SELECT * FROM dates_republicaines WITH (NOLOCK) WHERE date_republicaine = CAST(@date_acte AS VARCHAR(100)))
			BEGIN
				SELECT @date_acte_datetime = date_gregoriene , @annee_acte_numeric = annee_gregoriene
				FROM dates_republicaines WITH (NOLOCK)
				WHERE date_republicaine = CAST(@date_acte AS VARCHAR(100))
				PRINT 111
				
				UPDATE tmp_reecriture_date_acte
				SET date_acte_Correction_Reecriture = CONVERT(NVARCHAR(50), @date_acte_datetime, 103)
					,annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
				WHERE id_acte = @id_acte
			END
			ELSE
			BEGIN 
			PRINT 1111
				EXEC [spReecritureDateActeRepublicain] @date_acte = @date_acte, @id_acte = @id_acte					
			END
		END
		
		IF (@calendrier_date_acte = 'gregorien')
		BEGIN
		PRINT 2
			IF (ISNUMERIC(@annee_acte) = 1) AND (ISDATE(@date_acte) = 1)
			BEGIN
			PRINT 22
				SET @annee_acte_numeric = CAST(@annee_acte AS INT)
				SET @date_acte_datetime = CONVERT(DATETIME,@date_acte, 104)
					
				IF (@annee_acte_numeric = YEAR(@date_acte_datetime))
				BEGIN
				PRINT 222
					UPDATE tmp_reecriture_date_acte
					SET date_acte_Correction_Reecriture = @date_acte
						,annee_acte_Correction_Reecriture = annee_acte
					WHERE id_acte = @id_acte
				END
				IF (@annee_acte_numeric <> YEAR(@date_acte_datetime)) 
				BEGIN
				PRINT 2222
					IF (CAST(@annee_acte AS INT) < 1600)
					BEGIN
						UPDATE tmp_reecriture_date_acte
						SET annee_acte_Correction_Reecriture = YEAR(@date_acte_datetime)
							,date_acte_Correction_Reecriture = @date_acte
						WHERE id_acte = @id_acte
					END
					IF (YEAR(@date_acte_datetime) < 1600) AND (@annee_acte_numeric > 1600)
					BEGIN
						UPDATE tmp_reecriture_date_acte
						SET annee_acte_Correction_Reecriture = @annee_acte
							,date_acte_Correction_Reecriture = SUBSTRING(@date_acte,1,6) + @annee_acte
						WHERE id_acte = @id_acte
					END
					IF (YEAR(@date_acte_datetime) > 1600) AND (@annee_acte_numeric > 1600)
					BEGIN
						UPDATE tmp_reecriture_date_acte
						SET annee_acte_Correction_Reecriture = YEAR(@date_acte_datetime)
							,date_acte_Correction_Reecriture = @date_acte
						WHERE id_acte = @id_acte
					END
				END
			END
			ELSE
			
			BEGIN
			PRINT 222222
				EXEC [spReecritureDateActeGregorien] @date_acte = @date_acte, @id_acte = @id_acte	
			END
		END
		
		FETCH cursor_1 INTO @id_acte, @annee_acte, @date_acte, @calendrier_date_acte
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1 
	
		
	UPDATE DataXmlRC_actes
	SET date_acte_gregorienne = (CASE WHEN dxa.calendrier_date_acte = 'republicain'
						AND dxa.date_acte_gregorienne IS NULL AND dxa.date_acte_Correction IS NOT NULL 
						THEN t.date_acte_Correction_Reecriture ELSE date_acte_gregorienne END)
		,date_acte_Correction_Reecriture = t.date_acte_Correction_Reecriture
		,annee_acte_Correction_Reecriture = t.annee_acte_Correction_Reecriture
	FROM DataXmlRC_actes dxa WITH (NOLOCK)
	INNER JOIN tmp_reecriture_date_acte t WITH (NOLOCK) ON dxa.id = t.id_acte
	
	DROP TABLE tmp_reecriture_date_acte
END
GO
