SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Raluca Marcu
-- Create date: 26.08.2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spCalculSplit]
	-- Add the parameters for the stored procedure here
	-- Test Run : spCalculSplit '7DA68C98-741C-4CAD-ADAB-17F41AA36A37,BC9AAD7F-4211-4D1C-BE04-3D0ABC513DC0,174145D4-3139-4B03-80D6-4399ECFD3AAD,D4F010C2-22AB-4862-AEC5-55A0B55E2239,EC051990-F100-4555-9822-58067E0C9503'
	@id_list VARCHAR(MAX)  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @table TABLE ( id VARCHAR(255) )
	DECLARE @x INT = 0
	DECLARE @firstcomma INT = 0
	DECLARE @nextcomma INT = 0

	SET @x = LEN(@id_list) - LEN(REPLACE(@id_list, ',', '')) + 1 -- number of ids in id_list

	WHILE @x > 0
		BEGIN
			SET @nextcomma = CASE WHEN CHARINDEX(',', @id_list, @firstcomma + 1) = 0
								  THEN LEN(@id_list) + 1
								  ELSE CHARINDEX(',', @id_list, @firstcomma + 1)
							 END
			INSERT  INTO @table
			VALUES  ( SUBSTRING(@id_list, @firstcomma + 1, (@nextcomma - @firstcomma) - 1) )
			SET @firstcomma = CHARINDEX(',', @id_list, @firstcomma + 1)
			SET @x = @x - 1
		END

	SELECT  *
	FROM    @table
END

GO
