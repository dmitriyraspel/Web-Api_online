USE [web-api.online]
GO
/****** Object:  StoredProcedure [dbo].[FindUserIdForSendPage]    Script Date: 13.12.2021 18:41:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[FindUserIdForSendPageWebApi]
@searchText nvarchar(max)
AS
BEGIN

Select ANU.Id
FROM AspNetUsers as ANU
WHERE 
ANU.UserName = @searchText
OR ANU.NormalizedUserName = @searchText
OR ANU.Email = @searchText
OR ANU.PhoneNumber = @searchText

END
