SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE spInsertionImageTypes
	-- Add the parameters for the stored procedure here
	 @image_type VARCHAR(50)
	,@image_type_code VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO Images_Types (image_type, image_type_code)
	VALUES (@image_type,@image_type_code)
END
GO
