SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER trg_update_date_modification
   ON  [dbo].[DataXmlRC_zones]
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE()
    UPDATE [DataXmlRC_zones]
	SET date_modification=@date
	FROM [dbo].[DataXmlRC_zones] z WITH (NOLOCK)
	INNER JOIN INSERTED i ON z.id_zone=i.id_zone

END
GO
