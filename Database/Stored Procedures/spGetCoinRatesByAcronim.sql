ALTER PROCEDURE [dbo].[spGetCoinRatesByAcronim]
@acronim nvarchar(10)
AS
BEGIN

--declare @acronim nvarchar(10)
--set @acronim = 'GPS'

select * 
from [CoinsRates] 
where Acronim = @acronim

END
