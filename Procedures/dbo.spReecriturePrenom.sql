SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spReecriturePrenom]
	-- Add the parameters for the stored procedure here
	-- Test Run : spReecriturePrenom 'Honor e'
	@string VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF  @string LIKE '  %'
	BEGIN
		SET @string = RTRIM(LTRIM(@string))
	END
	IF @string LIKE '[0-9]%'
	BEGIN
		WHILE @string LIKE '[0-9]%'
		BEGIN
			SET @string =  RIGHT(@string, LEN(@string) - 1)
		END
	END
	IF (SELECT COUNT(*) FROM DataXmlRC_individus_prenoms WHERE prenom_initial = @string) > 0
	BEGIN
		SET @string = (SELECT prenom_reecriture FROM DataXmlRC_individus_prenoms WHERE prenom_initial = @string)
	END
	
	IF (@string = 'Jean Benoite')
	BEGIN
		SET @string = 'Jean Baptiste'
	END
	
	SELECT @string
END
GO
