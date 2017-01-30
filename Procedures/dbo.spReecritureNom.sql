SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spReecritureNom
	-- Add the parameters for the stored procedure here
	-- Test Run : spReecritureNom 'l ptest'
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
	
	IF @string LIKE '_ %'
	BEGIN
		IF (@string NOT LIKE '[DL] [AEIOUaeiouÀÂÄÈÉÊËÎÏÔŒÙÛÜŸàâäèéêëîïôœùûüÿÇç]%')
		BEGIN
			SET @string = RIGHT(@string, LEN(@string) - 2) 
		END
	END
	
	SELECT @string
END
GO
