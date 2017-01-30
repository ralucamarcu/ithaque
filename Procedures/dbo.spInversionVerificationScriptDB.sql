SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	le script courant a déjà été exécuté pour ce département
-- =============================================
CREATE PROCEDURE spInversionVerificationScriptDB
	-- Add the parameters for the stored procedure here
	@id_source UNIQUEIDENTIFIER
	,@script_applied VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (SELECT COUNT(*) FROM InversionInfoLog WITH (NOLOCK) WHERE id_source = @id_source AND script_applied = @script_applied) > 0
	BEGIN
		SELECT 1 AS IntegerResult -- le script courant a déjà été exécuté pour ce département
	END
	ELSE
	BEGIN
		SELECT 0 AS IntergerResult -- le script courant peut etre exécuté pour ce département
	END
	
END
GO
