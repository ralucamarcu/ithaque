SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spComparaisonBatchFile_InsertionImagesProcessusGeneralTousDeparts]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @id_projet [uniqueidentifier]

	DECLARE cursor_1 CURSOR FOR
	SELECT DISTINCT id_projet
	FROM dbo.FichiersData fd WITH (NOLOCK)
	WHERE fd.id_projet NOT IN ('85FB4438-6E26-4419-94BF-3CABC3C241D3', 'D55624BF-2847-4E69-8C26-089C122B3E0C')
	GROUP BY fd.id_projet
	OPEN cursor_1
	FETCH cursor_1 INTO @id_projet
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spComparaisonBatchFile_InsertionImagesProcessusGeneral @id_projet

		FETCH cursor_1 INTO @id_projet
	END
	CLOSE cursor_1
	DEALLOCATE cursor_1

END


--CLOSE NomFichier_Cursor
--	DEALLOCATE NomFichier_Cursor

GO
