USE [BrianWhiteSA]
GO
/****** Object:  Table [dbo].[PartyRoles]    Script Date: 11/21/2018 11:22:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
select distinct prl.[role]
from BrianWhiteNeos..party p
JOIN [BrianWhiteNeos]..party_role_list prl on prl.id = p.partyrolelistid
*/

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'PartyRoles'
	)
BEGIN
	DROP TABLE PartyRoles
END

CREATE TABLE [dbo].[PartyRoles] (
	[Needles Roles] [NVARCHAR](255) NULL
   ,[SA Roles] [NVARCHAR](255) NULL
   ,[SA Party] [NVARCHAR](255) NULL
) ON [PRIMARY]

GO
INSERT [dbo].[PartyRoles]
	(
	[Needles Roles]
   ,[SA Roles]
   ,[SA Party]
	)
	SELECT
		'Deceased'
	   ,'(P)-Deceased'
	   ,'Plaintiff'
	UNION
	SELECT
		'Relative'
	   ,'(P)-Relative'
	   ,'Plaintiff'
	UNION
	SELECT
		'Lead Plaintiff'
	   ,'(P)-Plaintiff'
	   ,'Plaintiff'
	UNION
	SELECT
		'Guardian'
	   ,'(P)-Guardian'
	   ,'Plaintiff'
	UNION
	SELECT
		'Defendant'
	   ,'(D)-Defendant'
	   ,'Defendant'
	UNION
	SELECT
		'Beneficiary'
	   ,'(P)-Beneficiary'
	   ,'Plaintiff'
	UNION
	SELECT
		'Other Plaintiff'
	   ,'(P)-Other Plaintiff'
	   ,'Plaintiff'
	UNION
	SELECT
		'Spouse'
	   ,'(P)-Spouse'
	   ,'Plaintiff'
	UNION
	SELECT
		'Heir'
	   ,'(P)-Heir'
	   ,'Plaintiff'
	UNION
	SELECT
		'Plaintiff'
	   ,'(P)-Plaintiff'
	   ,'Plaintiff'
	UNION
	SELECT
		'Vehicle Owner'
	   ,'(D)-Owner'
	   ,'Defendant'
	UNION
	SELECT
		'Personal Representative'
	   ,'(P)-Personal Representative'
	   ,'Plaintiff'
	UNION
	SELECT
		'Testator'
	   ,'(P)-Testator'
	   ,'Plaintiff'
	UNION
	SELECT
		'Beneficiary/Child'
	   ,'(P)-Beneficiary/Child'
	   ,'Plaintiff'
	UNION
	SELECT
		'Contractor'
	   ,'(D)-Contractor'
	   ,'Defendant'
	UNION
	SELECT
		'Employer'
	   ,'(D)-Employer'
	   ,'Defendant'
	UNION
	SELECT
		'Def-Owner'
	   ,'(D)-Owner'
	   ,'Defendant'
	UNION
	SELECT
		'Def-Driver'
	   ,'(D)-Driver'
	   ,'Defendant'
	UNION
	SELECT
		'Def-Driver/Owner'
	   ,'(D)-Driver/Owner'
	   ,'Defendant'
	UNION
	SELECT
		'Neos Default'
	   ,'(P)-Neos Default'
	   ,'Plaintiff' 
