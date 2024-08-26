USE BrianWhiteSA
GO


/*
select [name of employer], [Lenght of Time at Working], [occupation], [Other Employment], [Position], [Scope of Employment]
from BrianWhiteNeos..NeosUserParty
WHERE isnull([name of employer],'') <> ''
or isnull([Lenght of Time at Working],'') <> ''
or isnull([occupation],'') <> ''
or isnull([Other Employment],'') <> ''
or isnull([Position],'') <> ''
*/

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Employment')
	)
BEGIN
	ALTER TABLE [sma_TRN_Employment]
	ADD saga VARCHAR(50)
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
INSERT INTO [sma_TRN_Employment]
	(
	empnPlaintiffID
   ,empnEmprAddressID
   ,empnEmployerID
   ,empncontactPersonID
   ,empnCPAddressID
   ,empnEmpUnion
   ,empnStatusId
   ,empsJobTitle
   ,empsCompensationComments
   ,empnAverageWeeklyWage
   ,empnSalaryAmt
   ,empnSalaryFreqID
   ,empbOnTheJob
   ,empbWCClaim
   ,empdDateHired
   ,empdDateTo
   ,empsComments
   ,saga
	)
	SELECT  --MAP.case_id
		(
			SELECT TOP 1
				plnnPlaintiffID
			FROM sma_trn_plaintiff
			WHERE plnnCaseID = cas.casncaseid
				AND plnbIsPrimary = 1
		)								 
		AS empnPlaintiffID
	   ,ioc.AID							 AS empnEmprAddressID
	   ,ioc.CID							 AS empnEmployerID
	   ,NULL							 AS empncontactPersonID
	   ,NULL							 AS empnCPAddressID
	   ,NULL							 AS empnEmpUnion
	   ,NULL
	   ,					--(select TOP 1 [ID] From sma_MST_EmploymentStatuses where [name] = ud.[Employment Status])		as empnStatusId,
		ud.[Position]					 AS empsJobTitle
	   ,''								 AS empsCompensationComments
	   ,NULL							 AS empnAverageWeeklyWage
	   ,NULL							 AS empnSalaryAmt
	   ,NULL							 AS empnSalaryFreqID
	   ,NULL							 AS empbOnTheJob
	   ,NULL							 AS empbWCClaim
	   ,NULL							 AS empdDateHired
	   ,NULL							 AS empdDateTo
	   ,ISNULL('Length of Time at Working: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Lenght of Time at Working]), '') + CHAR(13), '') +
		ISNULL('Occupation: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Occupation]), '') + CHAR(13), '') +
		ISNULL('Other Employment: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Other Employment]), '') + CHAR(13), '') +
		ISNULL('Position: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Position]), '') + CHAR(13), '') +
		ISNULL('Scope of Employment: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Scope of Employment]), '') + CHAR(13), '') +
		''								 AS empsComments
	   ,CONVERT(VARCHAR(50), ud.partyid) AS saga
	--select *
	FROM BrianWhiteNeos..NeosUserParty ud
	JOIN BrianWhiteNeos..Party_Indexed p
		ON p.id = ud.partyid
	JOIN sma_trn_cases cas
		ON cas.Neos_saga = CONVERT(VARCHAR(50), p.casesid)
	JOIN IndvOrgContacts_Indexed ioc
		ON ioc.saga_ref = [name of employer]
	WHERE ISNULL([name of employer], '') <> ''
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