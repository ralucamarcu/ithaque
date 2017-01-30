SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecritureDateActeRepublicain]
	-- Add the parameters for the stored procedure here
	-- Test Run : [spReecritureDateActeRepublicain] '20/12/1858', 33541219
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
		
					IF (@date_acte LIKE '%ANX%') OR (@date_acte LIKE '%ANI%') OR (@date_acte LIKE '%ANV%')
									OR (@date_acte LIKE '%Ventose%') OR (@date_acte LIKE '%Nivose%') OR (@date_acte LIKE '%Pluviose%')
									OR (@date_acte LIKE '%rairial%')  OR (@date_acte LIKE '%rumaire%')  OR (@date_acte LIKE '%essidor%')
									OR (@date_acte LIKE '%omplémentaire%') OR (@date_acte LIKE '%Frimaire%') OR (@date_acte LIKE '%loréal%')
									OR (@date_acte LIKE '%endémiaire%') OR (@date_acte LIKE '%hermidor%')  OR (@date_acte LIKE '%entose%')
									OR (@date_acte LIKE '%ivôse%') OR (@date_acte LIKE '%luviôse%')  OR (@date_acte LIKE '%erminal%')
									OR (@date_acte LIKE '%ructidor%') OR(@date_acte LIKE '%sans-culottide%') OR(@date_acte LIKE '%sans culotide%')
									OR (@date_acte LIKE '[1-9] % %')
					BEGIN
					SET @date_acte = (CASE 
								WHEN @date_acte LIKE '%ANXV' THEN REPLACE(@date_acte, 'ANXII', 'AN15')
								WHEN @date_acte LIKE '%ANXIV' THEN REPLACE(@date_acte, 'ANXII', 'AN14')
								WHEN @date_acte LIKE '%ANXIII' THEN REPLACE(@date_acte, 'ANXIII', 'AN13')
								WHEN @date_acte LIKE '%ANXII' THEN REPLACE(@date_acte, 'ANXII', 'AN12')
								WHEN @date_acte LIKE '%ANXI' THEN REPLACE(@date_acte, 'ANXI', 'AN11')
								WHEN @date_acte LIKE '%ANX' THEN REPLACE(@date_acte, 'ANXI', 'AN10')
								WHEN @date_acte LIKE '%ANIX' THEN REPLACE(@date_acte, 'ANXI', 'AN09')
								WHEN @date_acte LIKE '%ANVIII' THEN REPLACE(@date_acte, 'ANXI', 'AN08')
								WHEN @date_acte LIKE '%ANVII' THEN REPLACE(@date_acte, 'ANXI', 'AN07')
								WHEN @date_acte LIKE '%ANVI' THEN REPLACE(@date_acte, 'ANXI', 'AN06')
								WHEN @date_acte LIKE '%ANV' THEN REPLACE(@date_acte, 'ANXI', 'AN05')
								WHEN @date_acte LIKE '%ANIV' THEN REPLACE(@date_acte, 'ANXI', 'AN04')
								WHEN @date_acte LIKE '%ANIII' THEN REPLACE(@date_acte, 'ANXI', 'AN03')
								WHEN @date_acte LIKE '%ANII' THEN REPLACE(@date_acte, 'ANXI', 'AN02')
								WHEN @date_acte LIKE '%ANI' THEN REPLACE(@date_acte, 'ANXI', 'AN01')
								WHEN @date_acte LIKE '%Ventose%' THEN REPLACE(@date_acte, 'Ventose', 'Ventôse')
								WHEN @date_acte LIKE '%Nivose%' THEN REPLACE(@date_acte, 'Nivose', 'Nivôse')
								WHEN @date_acte LIKE '%Pluviose%' THEN REPLACE(@date_acte, 'Pluviose', 'Pluviôse')
								WHEN @date_acte LIKE '%rairial%' THEN REPLACE(@date_acte, 'rairial', 'Prairial')
								WHEN @date_acte LIKE '%rumaire%' THEN REPLACE(@date_acte, 'rumaire', 'Brumaire')
								WHEN @date_acte LIKE '%essidor%' THEN REPLACE(@date_acte, 'essidor', 'Messidor')
								WHEN @date_acte LIKE '%omplémentaire%' THEN REPLACE(@date_acte, 'omplémentaire', 'complémentaire')
								WHEN @date_acte LIKE '%rimaire%' THEN REPLACE(@date_acte, 'rimaire', 'Frimaire')
								WHEN @date_acte LIKE '%loréal%' THEN REPLACE(@date_acte, 'loréal', 'Floréal')
								WHEN @date_acte LIKE '%endémiaire%' THEN REPLACE(@date_acte, 'endémiaire', 'Vendémiaire')
								WHEN @date_acte LIKE '%hermidor%' THEN REPLACE(@date_acte, 'hermidor', 'Thermidor')
								WHEN @date_acte LIKE '%entose%' THEN REPLACE(@date_acte, 'entose', 'Ventôse')								
								WHEN @date_acte LIKE '%ivôse%' THEN REPLACE(@date_acte, 'ivôse', 'Nivôse')
								WHEN @date_acte LIKE '%luviôse%' THEN REPLACE(@date_acte, 'luviôse', 'Pluviôse')
								WHEN @date_acte LIKE '%erminal%' THEN REPLACE(@date_acte, 'erminal', 'Germinal')
								WHEN @date_acte LIKE '%ructidor%' THEN REPLACE(@date_acte, 'ructidor', 'Fructidor')
								WHEN @date_acte LIKE '%sans-culottide%' THEN REPLACE(@date_acte, 'sans-culottide', 'complémentaire')
								WHEN @date_acte LIKE '%sans culotide%' THEN REPLACE(@date_acte, 'sans culotide', 'complémentaire')
								WHEN @date_acte LIKE '[1-9] % %' THEN '0' + @date_acte								
								ELSE @date_acte END)
					SELECT @date_acte_datetime = date_gregoriene , @annee_acte_numeric = annee_gregoriene
					FROM dates_republicaines WHERE date_republicaine = CAST(@date_acte AS VARCHAR(100))
				
					UPDATE tmp_reecriture_date_acte
					SET date_acte_Correction_Reecriture =  CONVERT(NVARCHAR(50), @date_acte_datetime, 103)
						,annee_acte_Correction_Reecriture = CONVERT(NVARCHAR(50), @annee_acte_numeric)
					WHERE id_acte = @id_acte
	END
	ELSE
		IF ((@date_acte LIKE '% 00 %') OR (@date_acte LIKE '% Illisible %') OR (@date_acte LIKE '% 0 %')
					 OR (@date_acte LIKE '[0-9][0-9] [0-9][0-9] AN%') OR (@date_acte LIKE '[0-9] [0-9][0-9] AN%')
					 OR (@date_acte LIKE '[0-9][0-9] [0-9] AN%') OR (@date_acte LIKE '%;% AN%') OR (RTRIM(LTRIM(@date_acte)) LIKE 'AN%'))				  
					AND (@date_acte NOT LIKE '%AN00')
		BEGIN
					SET @annee_acte_numeric = (SELECT MIN(dr.annee_gregoriene) 
						FROM tmp_reecriture_date_acte dxa WITH (NOLOCK)
						INNER JOIN dates_republicaines dr ON dr.annee_republicaine 
							= REPLACE(SUBSTRING(dxa.date_acte, CHARINDEX('AN', dxa.date_acte), LEN(dxa.date_acte) ), '', '')
						WHERE dxa.id_acte = @id_acte)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture =  CONVERT(NVARCHAR(50), @annee_acte_numeric)
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
		END
		IF (@date_acte LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]')
		BEGIN
		PRINT 1
			IF (ISDATE(@date_acte)=1)
			BEGIN
				UPDATE tmp_reecriture_date_acte
				SET annee_acte_Correction_Reecriture = annee_acte
					,date_acte_Correction_Reecriture = @date_acte
				WHERE id_acte = @id_acte
			END
			ELSE
			BEGIN
					SET @annee_acte_numeric = CAST((REVERSE(LEFT(REVERSE(@date_acte), CHARINDEX('/', REVERSE(@date_acte)) -1))) AS INT)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
			END
		END
				
		IF (@date_acte LIKE '%[Vendémiaire|Brumaire|Frimaire|Nivôse|Pluviôse|Ventôse|Germinal|Floréal|Prairial|Messidor|Thermidor|Fructidor|complémentaire|sans-culottide|supplémentaire] %')
					AND (SELECT COUNT(*) FROM tmp_reecriture_date_acte WITH (NOLOCK) WHERE id_acte = @id_acte AND date_acte_Correction_Reecriture IS NOT NULL) > 0
		BEGIN
					SET @annee_republicaine = RTRIM(LTRIM(REPLACE(SUBSTRING(@date_acte, CHARINDEX('AN', @date_acte), LEN(@date_acte) ), '', '')))
					SET @mois_acte_republicain = RTRIM(LTRIM(REPLACE((REPLACE(@date_acte, (REPLACE(SUBSTRING(@date_acte, 
						CHARINDEX('AN', @date_acte), LEN(@date_acte) ), '', '')), '')),SUBSTRING(@date_acte,1,2),'')))
					SET @jour_acte_republicain = CAST((SUBSTRING(@date_acte,1,2)) AS INT)
					
					SELECT @date_acte_datetime = date_gregoriene, @annee_acte_numeric = annee_gregoriene
					FROM dates_republicaines
					WHERE jour_republicaine = @jour_acte_republicain 
						AND mois_republicaine = @mois_acte_republicain
						AND annee_republicaine = @annee_republicaine
					
					UPDATE tmp_reecriture_date_acte
					SET date_acte_Correction_Reecriture =  CONVERT(NVARCHAR(50), @date_acte_datetime, 103)
						,annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
						AND date_acte_Correction_Reecriture IS NULL
		END
		IF EXISTS(SELECT * FROM dates_republicaines WHERE annee_republicaine = RIGHT(@date_acte, 4))
		BEGIN
			SET @annee_acte_numeric = (SELECT MIN(dr.annee_gregoriene) 
						FROM tmp_reecriture_date_acte dxa WITH (NOLOCK)
						INNER JOIN dates_republicaines dr ON dr.annee_republicaine = dxa.annee_acte
						WHERE dxa.id_acte = @id_acte)
					UPDATE tmp_reecriture_date_acte
					SET annee_acte_Correction_Reecriture = CAST(@annee_acte_numeric AS NVARCHAR(50))
						,date_acte_Correction_Reecriture = '01/01/' + CAST(@annee_acte_numeric AS NVARCHAR(50))
					WHERE id_acte = @id_acte
			
		END
END
GO
