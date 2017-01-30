SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecritureDateActeGregorien]
	-- Add the parameters for the stored procedure here
	@date_acte NVARCHAR(50)
	,@id_acte INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @annee_acte NVARCHAR(50), @calendrier_date_acte VARCHAR(255)
		,@annee_acte_numeric INT, @date_acte_datetime DATETIME
		,@jour_acte_republicain INT, @mois_acte_republicain VARCHAR(50), @annee_republicaine VARCHAR(20)
		
				IF (@date_acte LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
				BEGIN
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = (CASE WHEN SUBSTRING(@date_acte,1,4) < 1600 THEN SUBSTRING(@date_acte,6,LEN(@date_acte))
									ELSE SUBSTRING(@date_acte,1,4) END)
						,date_acte_Correction_Reecriture = '01/01/' + (CASE WHEN SUBSTRING(@date_acte,1,4) < 1600 
								THEN SUBSTRING(@date_acte,6,LEN(@date_acte)) ELSE SUBSTRING(@date_acte,1,4) END)
					WHERE id_acte = @id_acte
				END
				
				IF ((@date_acte LIKE 'LES_[0-9][0-9][0-9][0-9]') OR (@date_acte LIKE 'AN[0-9][0-9][0-9][0-9]'))
				BEGIN
					SET @annee_acte_numeric = CAST(RTRIM(LTRIM(REPLACE(@date_acte,LEFT(@date_acte, PATINDEX('%[0-9]%', @date_acte 
						+ '1') - 1), ''))) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				
				IF ((@date_acte LIKE 'SECTION%[0-9][0-9][0-9][0-9]') )
				BEGIN
					SET @annee_acte_numeric = CAST(RTRIM(LTRIM(SUBSTRING(REPLACE(@date_acte,LEFT(@date_acte, PATINDEX('%[0-9]%', @date_acte 
						+ '1') - 1), ''),4, LEN (REPLACE(@date_acte,LEFT(@date_acte, PATINDEX('%[0-9]%', @date_acte + '1') - 1), ''))))) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				IF (@date_acte LIKE '[0-9][0-9][0-9][0-9]__')
				BEGIN
					SET @annee_acte_numeric = CAST(SUBSTRING(@date_acte,1,4) AS INT)
					SET @mois_acte_republicain = SUBSTRING(REVERSE(@date_acte),1,1)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/' + CAST(@mois_acte_republicain AS NVARCHAR(30)) + '/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				IF (@date_acte LIKE '[0-9][0-9][0-9][0-9]_part%')
				BEGIN
					SET @annee_acte_numeric = CAST(SUBSTRING(@date_acte,1,4) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				IF (@date_acte LIKE '%/00/%')
				BEGIN
					SET @annee_acte_numeric = CAST(SUBSTRING(@date_acte,7,4) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				
				IF (@date_acte LIKE '00/%/%')
				BEGIN
					SET @mois_acte_republicain = SUBSTRING(@date_acte,4,2)
					SET @annee_acte_numeric = CAST(SUBSTRING(@date_acte,7,4) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/' + CAST(@mois_acte_republicain AS NVARCHAR(50)) + '/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
				END
				
			IF (@date_acte LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]') AND (SUBSTRING(@date_acte, 7,4) < 1753) AND (ISDATE(@date_acte) <> 1)
			BEGIN
				UPDATE tmp_reecriture_date_acte
				SET date_acte_Correction_Reecriture = @date_acte
					,annee_acte_Correction_Reecriture = annee_acte
				WHERE id_acte = @id_acte
			END
			IF (@date_acte LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]') AND (ISDATE(@date_acte) <> 1)
			BEGIN
				UPDATE tmp_reecriture_date_acte
				SET date_acte_Correction_Reecriture = '01/' + SUBSTRING(@date_acte,4, LEN(@date_acte))
					,annee_acte_Correction_Reecriture = annee_acte
				WHERE id_acte = @id_acte
				
			END
END
GO
