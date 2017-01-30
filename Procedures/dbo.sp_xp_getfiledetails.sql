CREATE PROCEDURE [dbo].[sp_xp_getfiledetails]
	@FileName [nvarchar](500)
AS
	EXTERNAL NAME [xp_getfiledetails_var].[SQLCLR].[xp_getfiledetails]
GO
