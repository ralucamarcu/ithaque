SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	@type_objet = Traitement/Fichier/etc
-- =============================================
CREATE PROCEDURE spInsertionCommentaire 
	-- Add the parameters for the stored procedure here
	 @commentaire VARCHAR(255)
	,@id_objet INT
	,@type_objet VARCHAR(255)
	,@id_utilisateur INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @current_date DATETIME
    SET @current_date = GETDATE()
    
	INSERT INTO Commentaires(commentaire, id_utilisateur, date_creation, id_objet, type_objet)
	VALUES (@commentaire, @id_utilisateur, @current_date, @id_objet, @type_objet)
END
GO
