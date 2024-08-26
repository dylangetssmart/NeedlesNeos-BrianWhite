USE BrianWhiteSANeos
GO

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
   ,saga_Ref
	)
	SELECT DISTINCT
		1								   AS cinbPrimary
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [dbo].[sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'Police Officer'
				AND octnContactCtgID = 1
		)								   
		AS cinnContactTypeID
	   ,NULL
	   ,'Officer'						   AS cinsPrefix
	   ,dbo.FirstName_FromText(u.officer)  AS cinsFirstName
	   ,dbo.MiddleName_FromText(u.officer) AS cinsMiddleName
	   ,dbo.LastName_FromText(u.officer)   AS cinsLastName
	   ,NULL							   AS cinsSuffix
	   ,NULL							   AS cinsNickName
	   ,1
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1
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
	   ,368
	   ,GETDATE()
	   ,''
	   ,NULL
	   ,0
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL + NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,''
	   ,''
	   ,''
	   ,-1
	   ,''
	   ,NULL							   AS cinsGrade
	   ,u.[officer]						   AS saga_Ref
	--select p.[data]
	FROM BrianWhiteNeos..NeosUserTab6 u
	WHERE ISNULL(officer, '') NOT IN ('', 'N/A', '?', 'NONE')
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
--

