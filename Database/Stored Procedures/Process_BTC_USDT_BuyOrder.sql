ALTER PROCEDURE [dbo].[Process_BTC_USDT_BuyOrder]
@createUserId nvarchar(450),
@isBuy bit,
@price decimal(38,20),
@amount decimal(38,20),
@total decimal(38,20),
@createDate datetime
AS
BEGIN

SELECT TOP 1 *
INTO   #selectedOrder
FROM   [Exchange].[dbo].[BTC_USDT_OpenOrders]
WHERE  IsBuy = 0 AND @price >= Price
ORDER  BY Price

DECLARE @selectOrderAmount DECIMAL(38, 20);
SET @selectOrderAmount = 
	(SELECT Amount FROM #selectedOrder) 

DECLARE @amountLocal DECIMAL(38, 20);
SET @amountLocal = 0;

IF NOT EXISTS(SELECT 1 FROM #selectedOrder)
BEGIN	
	DECLARE @newId bigint

	EXEC [Exchange].[dbo].[Create_BTC_USDT_OpenOrder]
		@userId = @createUserId,
		@isBuy = @isBuy,
		@price = @price,
		@amount = @amount,
		@total = @total,
		@new_identity = @newId output

	SELECT @amount as Amount, @newId as Id;
END
ELSE IF (@amount > @selectOrderAmount)
BEGIN
	SET @amountLocal = @amount - @selectOrderAmount;
	
	DELETE FROM [Exchange].[dbo].[BTC_USDT_OpenOrders]
	WHERE  OpenOrderId = 
		(SELECT OpenOrderId FROM #selectedOrder) 

	INSERT INTO [Exchange].[dbo].[BTC_USDT_ClosedOrders] (	
				ClosedOrderId, Total, CreateDate,
				ClosedDate, IsBuy, ExposedPrice, TotalPrice, Difference, Amount,
				CreateUserId, BoughtUserId, Status)

		VALUES ((SELECT OpenOrderId FROM #selectedOrder),
				(SELECT Total FROM #selectedOrder),
				(SELECT CreateDate FROM #selectedOrder),
				 getdate(),
				(SELECT IsBuy FROM #selectedOrder),
				(SELECT Price FROM #selectedOrder),
				@price,
				((SELECT Price FROM #selectedOrder) - @price),
				(SELECT Amount FROM #selectedOrder),
				(SELECT CreateUserId FROM #selectedOrder),
				@createUserId, 
				1)
	
	UPDATE [Exchange].[dbo].[Wallets]
	SET Value = Value + (SELECT Total FROM #selectedOrder)
	WHERE UserId = (SELECT CreateUserId FROM #selectedOrder) 
		AND CurrencyAcronim = 'USDT' 

	
	SELECT @amountLocal as Amount, -1 as Id
END
ELSE IF (@amount < @selectOrderAmount)
BEGIN
	INSERT INTO [Exchange].[dbo].[BTC_USDT_ClosedOrders] (
				ClosedOrderId, Total, CreateDate,
				ClosedDate, IsBuy, ExposedPrice, TotalPrice, Difference, Amount,
				CreateUserId, BoughtUserId, Status)

		VALUES (NEXT VALUE FOR [dbo].[BTC_USDT_OpenOrderId_Sequence],
				@total,
				@createDate,
				getdate(),
				@isBuy,
				@price,
				(SELECT Price FROM #selectedOrder),
				(@price - (SELECT Price FROM #selectedOrder)),
				@amount,
				@createUserId,
				(SELECT CreateUserId FROM #selectedOrder), 
				1)
				
	UPDATE [Exchange].[dbo].[Wallets]
	SET Value = Value + @amount
	WHERE UserId = @createUserId 
		AND CurrencyAcronim = 'BTC'  			
	
	UPDATE [Exchange].[dbo].[BTC_USDT_OpenOrders]
	SET    IsBuy = (SELECT IsBuy FROM #selectedOrder),
		   Price = (SELECT Price FROM #selectedOrder),
		   Amount = (@selectOrderAmount - @amount),
		   CreateUserId = (SELECT CreateUserId FROM #selectedOrder)
	WHERE  OpenOrderId = (SELECT OpenOrderId FROM #selectedOrder)
	
	SELECT 0 as Amount, -1 as Id
END
ELSE IF (@amount = @selectOrderAmount)
BEGIN

	DELETE FROM [Exchange].[dbo].[BTC_USDT_OpenOrders]
	WHERE  OpenOrderId = 
		(SELECT OpenOrderId FROM #selectedOrder) 

	INSERT INTO [Exchange].[dbo].[BTC_USDT_ClosedOrders] (
				ClosedOrderId, Total, CreateDate,
				ClosedDate, IsBuy, ExposedPrice, TotalPrice, Difference, Amount,
				CreateUserId, BoughtUserId, Status)
		VALUES ((SELECT OpenOrderId FROM #selectedOrder),
				(SELECT Total FROM #selectedOrder),
				(SELECT CreateDate FROM #selectedOrder),
				 getdate(),
				(SELECT IsBuy FROM #selectedOrder),
				(SELECT Price FROM #selectedOrder),
				@price,
				((SELECT Price FROM #selectedOrder) - @price),
				(SELECT Amount FROM #selectedOrder),
				(SELECT CreateUserId FROM #selectedOrder),
				@createUserId, 
				1)


	UPDATE [Exchange].[dbo].[Wallets]
	SET Value = Value + (SELECT Total FROM #selectedOrder)
	WHERE UserId = (SELECT CreateUserId FROM #selectedOrder) 
		AND CurrencyAcronim = 'USDT' 

	INSERT INTO [Exchange].[dbo].[BTC_USDT_ClosedOrders] (
				ClosedOrderId, Total, CreateDate,
				ClosedDate, IsBuy, ExposedPrice, TotalPrice, Difference, Amount,
				CreateUserId, BoughtUserId, Status)

		VALUES (NEXT VALUE FOR [dbo].[BTC_USDT_OpenOrderId_Sequence],
				@total,
				@createDate,
				getdate(),
				@isBuy,
				@price,
				(SELECT Price FROM #selectedOrder),
				(@price - (SELECT Price FROM #selectedOrder)),
				@amount,
				@createUserId,
				(SELECT CreateUserId FROM #selectedOrder), 
				1)
				
	UPDATE [Exchange].[dbo].[Wallets]
	SET Value = Value + @amount
	WHERE UserId = @createUserId 
		AND CurrencyAcronim = 'BTC'  	

	SELECT 0 as Amount, -1 as Id
END

END