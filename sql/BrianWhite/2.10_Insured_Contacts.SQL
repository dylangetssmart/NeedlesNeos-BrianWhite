USE SANeosBrianWhite
GO

if exists (select * from sys.tables where name = 'InsuredHelper')
begin
	drop table InsuredHelper
end

create table InsuredHelper (Insured varchar(100), wordct int, firstname varchar(30), middle varchar(30), lastname varchar(80), company varchar(100))

INSERT INTO InsuredHelper (Insured, wordct)
SELECT DISTINCT insured, dbo.WordCount(Insured)
FROM [NeosBrianWhite].[dbo].[insurance] INS
WHERE isnull(insured,'')<>''


update InsuredHelper 
set company = Insured
where wordct not in (2,3,4) 

update InsuredHelper 
set company = Insured
from InsuredHelper
where company is null
	and (insured like '%inc%' or insured like '%llc%' or insured like '%freight%' or insured like '%auto%'
	or insured like '%solution%' or insured like '%hauler%' or insured like '% and %'  or insured like '%realty%' 
	or insured like '%apartment%' or insured like '% LP%' or insured like '% truck%' or insured like '% & %' 
	or insured like '%pizza%' or insured like '%company%' or insured like '%plaza%' or insured like '%trust%'
	or insured like '% by %' or insured like '%construction%' or insured like '%transfer%' or insured like '%supermercado%'
	or insured like '%management%' or insured like '%partner%' or insured like '%.com%' or insured like '%insurance%'
	or insured like '%commercial%' or insured like '%county%' or insured like '%school%' or insured like '%health%'
	or insured like '% car %' or insured like '%academy%' or insured like '% mart' or insured like '%insured%'
	or insured like '%[0-9]%' or insured like '%grocery%' or insured like '%church%' or insured like '%depot%'
	or insured like '%assistance%' or insured like '%hospital%' or insured like '%marriott%' or insured like '%corporation%'
	or insured like '%suite%' or insured like '%transport%' or insured like '%underground%' or insured like '%plumbing%'
	or insured like '%claim%' or insured like '%police%' or insured like '%sausage%' or insured like '%southwest%'
	or insured like '%houston%' or insured like '%moving%' or insured like '%market%' or insured like '%children%' 
	or insured like '%wheelhouse%' or insured like '%LTD%' or insured like '% UM %' or insured like '%coverage%'
	or insured like '% pip %' or insured like '%rental%' or insured like '%holding%' or insured like '%laboratories%'
	or insured like '%service%' or insured like '%diagnostic%' or insured like '%enterprise%' or insured like '%L.P.%'
	or insured like 'The %' or insured like '%texas%' or insured like '%complete%' )
GO

UPDATE InsuredHelper
SET firstname = dbo.FirstName_FromText(insured), 
	middle = dbo.MiddleName_FromText(Insured), 
	lastname = dbo.LastName_FromText(Insured)
FROM InsuredHelper
WHERE company is null
GO

---------------------------------------------
--CREATE CONTACT CARDS FOR INSURED
---------------------------------------------
--
ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
GO
--
INSERT INTO [sma_MST_IndvContacts] (
	[cinbPrimary],[cinnContactTypeID],[cinnContactSubCtgID],[cinsPrefix],[cinsFirstName],[cinsMiddleName],[cinsLastName],[cinsSuffix],[cinsNickName],[cinbStatus],[cinsSSNNo],[cindBirthDate],
	[cinsComments],[cinnContactCtg],[cinnRefByCtgID],[cinnReferredBy],[cindDateOfDeath],[cinsCVLink],[cinnMaritalStatusID],[cinnGender],[cinsBirthPlace],[cinnCountyID],[cinsCountyOfResidence],
	[cinbFlagForPhoto],[cinsPrimaryContactNo],[cinsHomePhone],[cinsWorkPhone],[cinsMobile],[cinbPreventMailing],[cinnRecUserID],[cindDtCreated],[cinnModifyUserID],[cindDtModified],[cinnLevelNo],
	[cinsPrimaryLanguage],[cinsOtherLanguage],[cinbDeathFlag],[cinsCitizenship],[cinsHeight],[cinnWeight],[cinsReligion],[cindMarriageDate],[cinsMarriageLoc],[cinsDeathPlace],[cinsMaidenName],
	[cinsOccupation],[saga],[cinsSpouse],[cinsGrade], [saga_ref]) 
SELECT DISTINCT 
	1			as [cinbPrimary],
	10			as [cinnContactTypeID],
	null,'',
	Firstname	as [cinsFirstName],
	middle		as [cinsMiddleName],
	lastname	as [cinsLastName], 
	null		as [cinsSuffix],
	null		as [cinsNickName],
	1			as [cinbStatus],
	null		as [cinsSSNNo],
	null		as [cindBirthDate],
	null,
	1			as [cinnContactCtg],
	'','',null,'','',1,'',1,1,null,null,'','',null,0,
	368			as [cinnRecUserID],
	GETDATE()	as [cindDtCreated],
	''			as [cinnModifyUserID],
	null		as [cindDtModified],
	0,'','','','',
	null		as [cinsHeight],
	null		as [cinnWeight],
	'',Null,'','','','',
	-1			as [saga],
	''			as [cinsSpouse],
	NULL		as [cinsGrade], 
	insured		as [saga_ref]
FROM InsuredHelper
WHERE firstname IS NOT NULL
GO

--
ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
GO


INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga],
		[saga_ref]
	)
SELECT 
    company			as [consName],
    NULL			as [consWorkPhone],
	''				as [consComments],
    2				as [connContactCtg],
    (select octnOrigContactTypeID FROM [sma_MST_OriginalContactTypes] where octsDscrptn='General' and octnContactCtgID=2) as [connContactTypeID],
    368				as [connRecUserID],
    getdate()		as [condDtCreated],
    1				as [conbStatus],		-- Hardcode Status as ACTIVE
    -1				as [saga],
	Insured			as [saga_ref]
--SELECT *
FROM InsuredHelper
WHERE Company IS NOT NULL
GO
