CREATE FUNCTION [dbo].[DateRepublicaineEnGregorienne]
(
	@AChaineDate [nvarchar](4000)
)
	RETURNS [datetime]
	WITH EXECUTE AS CALLER
AS
	EXTERNAL NAME [DateRepublicaineConversion].[DateRepublicaineConversion.DateRepublicaineConversion].[DateRepublicaineEnGregorienne]
GO
