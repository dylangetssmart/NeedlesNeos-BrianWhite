USE SANeosBrianWhite
GO


/*
select [name of employer], [Lenght of Time at Working], [occupation], [Other Employment], [Position], [Scope of Employment]
from NeosBrianWhite..NeosUserParty
WHERE isnull([name of employer],'') <> ''
or isnull([Lenght of Time at Working],'') <> ''
or isnull([occupation],'') <> ''
or isnull([Other Employment],'') <> ''
or isnull([Position],'') <> ''
*/

IF NOT EXISTS (SELECT * From sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Employment') )
BEGIN
	ALTER TABLE [sma_TRN_Employment]
	ADD saga varchar(50)
END
GO

/*
---------------------------------------------
--EMPLOYMENT STATUSES
---------------------------------------------
INSERT INTO sma_MST_EmploymentStatuses ([Name])
SELECT DISTINCT [Employment Status]
FROM EmploymentPivot WHERE isnull([Employment Status],'') <>''
EXCEPT SELECT [Name] FROM sma_MST_EmploymentStatuses

---------------------------------------------
--EMPLOYMENT TRADES
---------------------------------------------
INSERT INTO sma_MST_Trades ([Name])
SELECT DISTINCT [Type of Business]
FROM EmploymentPivot WHERE isnull([Type of Business],'') <>''
EXCEPT SELECT [Name] From sma_MST_Trades
*/
---------------------------------------------
--INSERT EMPLOYMENT
---------------------------------------------
INSERT INTO [sma_TRN_Employment] (
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
	empncontactPersonID,
	empnCPAddressID,
    empnEmpUnion,
	empnStatusId,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
	empnSalaryFreqID,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
	empdDateTo,
    empsComments,
	saga
)
SELECT  --MAP.case_id
    (SELECT TOP 1 plnnPlaintiffID FROM sma_trn_plaintiff WHERE plnnCaseID = cas.casncaseid and plnbIsPrimary = 1)		as empnPlaintiffID,
    ioc.AID					as empnEmprAddressID,
    ioc.CID					as empnEmployerID,
	NULL					as empncontactPersonID,
	NULL	 				as empnCPAddressID,
    null					as empnEmpUnion,
	NULL,					--(select TOP 1 [ID] From sma_MST_EmploymentStatuses where [name] = ud.[Employment Status])		as empnStatusId,
    ud.[Position]			as empsJobTitle,
	''						as empsCompensationComments,
    null					as empnAverageWeeklyWage,
    NULL					as empnSalaryAmt,
	NULL					as empnSalaryFreqID,
    null					as empbOnTheJob,
    null					as empbWCClaim,
    NULL					as empdDateHired,
	NULL					as empdDateTo,
    isnull('Length of Time at Working: ' + nullif(convert(varchar(max),ud.[Lenght of Time at Working]),'') + CHAR(13),'') + 
	isnull('Occupation: ' + nullif(convert(varchar(max),ud.[Occupation]),'') + CHAR(13),'') + 
	isnull('Other Employment: ' + nullif(convert(varchar(max),ud.[Other Employment]),'') + CHAR(13),'') + 
	isnull('Position: ' + nullif(convert(varchar(max),ud.[Position]),'') + CHAR(13),'') + 
	isnull('Scope of Employment: ' + nullif(convert(varchar(max),ud.[Scope of Employment]),'') + CHAR(13),'') + 
	 ''						as empsComments,
	 convert(varchar(50),ud.partyid)			as saga
--select *
FROM NeosBrianWhite..NeosUserParty ud
JOIN NeosBrianWhite..Party_Indexed p on p.id = ud.partyid
JOIN sma_trn_cases cas on cas.Neos_saga = convert(varchar(50),p.casesid)
JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = [name of employer]
WHERE isnull([name of employer],'') <> ''
GO

/*
-------------------------------------
--INSERT TRADES
-------------------------------------
INSERT INTO sma_TRN_Employment_Trades (EmploymentId, TradesId)
SELECT DISTINCT em.empnEmploymentID, tr.Id
FROM EmploymentPivot pv
JOIN [sma_TRN_Employment]  em on convert(varchar(50),pv.tablistid) = em.saga
JOIN sma_MST_Trades tr on tr.[name] = pv.[Type of Business]
WHERE isnull([Type of Business],'') <> ''
*/