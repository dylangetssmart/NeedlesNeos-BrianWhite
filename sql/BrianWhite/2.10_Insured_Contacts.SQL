USE BrianWhiteSA
GO

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'InsuredHelper'
	)
BEGIN
	DROP TABLE InsuredHelper
END

CREATE TABLE InsuredHelper (
	Insured VARCHAR(100)
   ,wordct INT
   ,firstname VARCHAR(30)
   ,middle VARCHAR(30)
   ,lastname VARCHAR(80)
   ,company VARCHAR(100)
)

INSERT INTO InsuredHelper
	(
	Insured
   ,wordct
	)
	SELECT DISTINCT
		insured
	   ,dbo.WordCount(Insured)
	FROM [BrianWhiteNeos].[dbo].[insurance] INS
	WHERE ISNULL(insured, '') <> ''


UPDATE InsuredHelper
SET company = Insured
WHERE wordct NOT IN (2, 3, 4)

UPDATE InsuredHelper
SET company = Insured
FROM InsuredHelper
WHERE company IS NULL
AND (insured LIKE '%inc%'
OR insured LIKE '%llc%'
OR insured LIKE '%freight%'
OR insured LIKE '%auto%'
OR insured LIKE '%solution%'
OR insured LIKE '%hauler%'
OR insured LIKE '% and %'
OR insured LIKE '%realty%'
OR insured LIKE '%apartment%'
OR insured LIKE '% LP%'
OR insured LIKE '% truck%'
OR insured LIKE '% & %'
OR insured LIKE '%pizza%'
OR insured LIKE '%company%'
OR insured LIKE '%plaza%'
OR insured LIKE '%trust%'
OR insured LIKE '% by %'
OR insured LIKE '%construction%'
OR insured LIKE '%transfer%'
OR insured LIKE '%supermercado%'
OR insured LIKE '%management%'
OR insured LIKE '%partner%'
OR insured LIKE '%.com%'
OR insured LIKE '%insurance%'
OR insured LIKE '%commercial%'
OR insured LIKE '%county%'
OR insured LIKE '%school%'
OR insured LIKE '%health%'
OR insured LIKE '% car %'
OR insured LIKE '%academy%'
OR insured LIKE '% mart'
OR insured LIKE '%insured%'
OR insured LIKE '%[0-9]%'
OR insured LIKE '%grocery%'
OR insured LIKE '%church%'
OR insured LIKE '%depot%'
OR insured LIKE '%assistance%'
OR insured LIKE '%hospital%'
OR insured LIKE '%marriott%'
OR insured LIKE '%corporation%'
OR insured LIKE '%suite%'
OR insured LIKE '%transport%'
OR insured LIKE '%underground%'
OR insured LIKE '%plumbing%'
OR insured LIKE '%claim%'
OR insured LIKE '%police%'
OR insured LIKE '%sausage%'
OR insured LIKE '%southwest%'
OR insured LIKE '%houston%'
OR insured LIKE '%moving%'
OR insured LIKE '%market%'
OR insured LIKE '%children%'
OR insured LIKE '%wheelhouse%'
OR insured LIKE '%LTD%'
OR insured LIKE '% UM %'
OR insured LIKE '%coverage%'
OR insured LIKE '% pip %'
OR insured LIKE '%rental%'
OR insured LIKE '%holding%'
OR insured LIKE '%laboratories%'
OR insured LIKE '%service%'
OR insured LIKE '%diagnostic%'
OR insured LIKE '%enterprise%'
OR insured LIKE '%L.P.%'
OR insured LIKE 'The %'
OR insured LIKE '%texas%'
OR insured LIKE '%complete%')
GO

UPDATE InsuredHelper
SET firstname = dbo.FirstName_FromText(insured)
   ,middle = dbo.MiddleName_FromText(Insured)
   ,lastname = dbo.LastName_FromText(Insured)
FROM InsuredHelper
WHERE company IS NULL
GO

---------------------------------------------
--CREATE CONTACT CARDS FOR INSURED
---------------------------------------------
--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinbPrimary]
   ,[cinnContactTypeID]
   ,[cinnContactSubCtgID]
   ,[cinsPrefix]
   ,[cinsFirstName]
   ,[cinsMiddleName]
   ,[cinsLastName]
   ,[cinsSuffix]
   ,[cinsNickName]
   ,[cinbStatus]
   ,[cinsSSNNo]
   ,[cindBirthDate]
   ,[cinsComments]
   ,[cinnContactCtg]
   ,[cinnRefByCtgID]
   ,[cinnReferredBy]
   ,[cindDateOfDeath]
   ,[cinsCVLink]
   ,[cinnMaritalStatusID]
   ,[cinnGender]
   ,[cinsBirthPlace]
   ,[cinnCountyID]
   ,[cinsCountyOfResidence]
   ,[cinbFlagForPhoto]
   ,[cinsPrimaryContactNo]
   ,[cinsHomePhone]
   ,[cinsWorkPhone]
   ,[cinsMobile]
   ,[cinbPreventMailing]
   ,[cinnRecUserID]
   ,[cindDtCreated]
   ,[cinnModifyUserID]
   ,[cindDtModified]
   ,[cinnLevelNo]
   ,[cinsPrimaryLanguage]
   ,[cinsOtherLanguage]
   ,[cinbDeathFlag]
   ,[cinsCitizenship]
   ,[cinsHeight]
   ,[cinnWeight]
   ,[cinsReligion]
   ,[cindMarriageDate]
   ,[cinsMarriageLoc]
   ,[cinsDeathPlace]
   ,[cinsMaidenName]
   ,[cinsOccupation]
   ,[saga]
   ,[cinsSpouse]
   ,[cinsGrade]
   ,[saga_ref]
	)
	SELECT DISTINCT
		1		  AS [cinbPrimary]
	   ,10		  AS [cinnContactTypeID]
	   ,NULL
	   ,''
	   ,Firstname AS [cinsFirstName]
	   ,middle	  AS [cinsMiddleName]
	   ,lastname  AS [cinsLastName]
	   ,NULL	  AS [cinsSuffix]
	   ,NULL	  AS [cinsNickName]
	   ,1		  AS [cinbStatus]
	   ,NULL	  AS [cinsSSNNo]
	   ,NULL	  AS [cindBirthDate]
	   ,NULL
	   ,1		  AS [cinnContactCtg]
	   ,''
	   ,''
	   ,NULL
	   ,''
	   ,''
	   ,1
	   ,''
	   ,1
	   ,1
	   ,NULL
	   ,NULL
	   ,''
	   ,''
	   ,NULL
	   ,0
	   ,368		  AS [cinnRecUserID]
	   ,GETDATE() AS [cindDtCreated]
	   ,''		  AS [cinnModifyUserID]
	   ,NULL	  AS [cindDtModified]
	   ,0
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL	  AS [cinsHeight]
	   ,NULL	  AS [cinnWeight]
	   ,''
	   ,NULL
	   ,''
	   ,''
	   ,''
	   ,''
	   ,-1		  AS [saga]
	   ,''		  AS [cinsSpouse]
	   ,NULL	  AS [cinsGrade]
	   ,insured	  AS [saga_ref]
	FROM InsuredHelper
	WHERE firstname IS NOT NULL
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO


INSERT INTO [sma_MST_OrgContacts]
	(
	[consName]
   ,[consWorkPhone]
   ,[consComments]
   ,[connContactCtg]
   ,[connContactTypeID]
   ,[connRecUserID]
   ,[condDtCreated]
   ,[conbStatus]
   ,[saga]
   ,[saga_ref]
	)
	SELECT
		company	  AS [consName]
	   ,NULL	  AS [consWorkPhone]
	   ,''		  AS [consComments]
	   ,2		  AS [connContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 2
		)		  
		AS [connContactTypeID]
	   ,368		  AS [connRecUserID]
	   ,GETDATE() AS [condDtCreated]
	   ,1		  AS [conbStatus]
	   ,		-- Hardcode Status as ACTIVE
		-1		  AS [saga]
	   ,Insured	  AS [saga_ref]
	--SELECT *
	FROM InsuredHelper
	WHERE Company IS NOT NULL
GO
