USE [SUSDB]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[spCountObsoleteUpdatesToCleanup]

SELECT	'Return Value' = @return_value

GO
