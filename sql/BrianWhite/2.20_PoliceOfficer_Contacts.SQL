USE SANeosBrianWhite
GO

--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--

INSERT INTO [sma_MST_IndvContacts] (
	[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade], saga_Ref) 
SELECT DISTINCT 
    1								as cinbPrimary,
    (select octnOrigContactTypeID from [dbo].[sma_MST_OriginalContactTypes] where octsDscrptn='Police Officer' and octnContactCtgID =1) as cinnContactTypeID,
    null,
    'Officer'						as cinsPrefix,
    dbo.FirstName_FromText(u.officer)	as cinsFirstName,
    dbo.MiddleName_FromText(u.officer)	as cinsMiddleName,
    dbo.LastName_FromText(u.officer)	as cinsLastName,
    null							as cinsSuffix,
    null							as cinsNickName, 
    1,null,null,null,1,'','',null,'','',1,'',1,1,null,null,'','',null,0,368,GETDATE(),'',null,0,'','','','',null+null,null,'',Null,'','','','',-1,'',
    null							as cinsGrade,
	u.[officer]						as saga_Ref
--select p.[data]
FROM NeosBrianWhite..NeosUserTab6 u
WHERE isnull(officer,'') NOT IN ('','N/A','?','NONE')
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO
--

