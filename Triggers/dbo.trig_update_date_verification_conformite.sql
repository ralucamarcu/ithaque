SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER trig_update_date_verification_conformite 
   ON  dbo.Traitements 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    DECLARE @current_date DATETIME = GETDATE()
    IF UPDATE(controle_livraison_conformite)
    BEGIN
		UPDATE dbo.Traitements
		SET date_verification_conformite = @current_date
		FROM dbo.Traitements t
		INNER JOIN INSERTED I ON t.id_traitement = I.id_traitement
	END

END
GO
