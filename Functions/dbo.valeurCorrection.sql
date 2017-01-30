SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Frédéric Robillard
-- Create date: 22/05/2012
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[valeurCorrection] 
(
	-- Add the parameters for the function here
	@valeurInitiale varchar(MAX),
	@valeurCorrection varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @valeurRetour varchar(MAX)
	SET @valeurRetour = RTRIM(LTRIM(@valeurCorrection))
	--IF (LEN(@valeurRetour)=0 OR (@valeurRetour = @valeurInitiale))
	IF (@valeurRetour = @valeurInitiale)
	BEGIN
		SET @valeurRetour = NULL
	END
	-- Return the result of the function
	RETURN @valeurRetour

END

GO
