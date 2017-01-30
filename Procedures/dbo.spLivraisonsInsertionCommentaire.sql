SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spLivraisonsInsertionCommentaire
	-- Add the parameters for the stored procedure here
	 @id_traitement INT
	,@text_commentaire VARCHAR(MAX)
	,@id_utilisateur INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @id_projet UNIQUEIDENTIFIER, @date_creation DATETIME
    SET @id_projet = (SELECT id_projet FROM Traitements WHERE id_traitement = @id_traitement)
    SET @date_creation = GETDATE()
	INSERT INTO Commentaires(commentaire, id_utilisateur, date_creation, id_projet, id_objet, type_objet)
	VALUES (@text_commentaire, @id_utilisateur, @date_creation, @id_projet, @id_traitement, 'traitement')
	
END
GO
