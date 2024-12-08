USE [BrianWhiteSA]
GO

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'CaseTypeMixture'
	)
BEGIN
	DROP TABLE [dbo].[CaseTypeMixture]
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CaseTypeMixture] (
	[matcode] [NVARCHAR](255) NULL
   ,[header] [NVARCHAR](255) NULL
   ,[description] [NVARCHAR](255) NULL
   ,[SmartAdvocate Case Type] [NVARCHAR](255) NULL
   ,[SmartAdvocate Case Sub Type] [NVARCHAR](255) NULL
) ON [PRIMARY]


INSERT INTO [dbo].[CaseTypeMixture]
	(
	[matcode]
   ,[header]
   ,[description]
   ,[SmartAdvocate Case Type]
   ,[SmartAdvocate Case Sub Type]
	)
	SELECT
		[matcode]
	   ,[header]
	   ,[description]
	   ,CASE
			WHEN [description] IS NULL
				THEN [matcode]
			ELSE [description]
		END
	   ,'Unknown'
	FROM [BrianWhiteNeos].[dbo].[matter] M

