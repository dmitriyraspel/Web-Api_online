ALTER PROCEDURE [dbo].[Create_BTC_USDT_OpenOrder]
@userid nvarchar(450),
@isBuy bit,
@price decimal(38,20),
@amount decimal(38,20),
@total decimal(38,20),
@new_identity bigint OUTPUT
AS
BEGIN

SELECT @new_identity = NEXT VALUE FOR [dbo].[BTC_USDT_OpenOrderId_Sequence]

INSERT INTO [Exchange].[dbo].[BTC_USDT_OpenOrders] (OpenOrderId, IsBuy, Price, Amount, Total, CreateUserId)
VALUES (@new_identity, @isBuy, @price, @amount, @total, @userid)

SELECT @new_identity

END
