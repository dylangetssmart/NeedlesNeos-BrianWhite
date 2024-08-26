
USE [BrianWhiteSA]
GO
/*
alter table [sma_TRN_CriticalDeadlines] disable trigger all
delete [sma_TRN_CriticalDeadlines]
DBCC CHECKIDENT ('[sma_TRN_CriticalDeadlines]', RESEED, 0);
alter table [sma_TRN_CriticalDeadlines] enable trigger all

(select cdtnCriticalTypeID FROM [sma_MST_CriticalDeadlineTypes] where cdtbActive = 1 and cdtsDscrptn='date due') 
*/
-----
ALTER TABLE [sma_TRN_CriticalDeadlines] DISABLE TRIGGER ALL
-----

----(0)----- 
INSERT INTO [sma_MST_CriticalDeadlineTypes]
	(
	cdtsDscrptn
   ,cdtbActive
	)
	SELECT DISTINCT
		[label]
	   ,1
	FROM BrianWhiteNeos..[date_labels]
	EXCEPT
	SELECT
		cdtsDscrptn
	   ,cdtbActive
	FROM [sma_MST_CriticalDeadlineTypes]
	WHERE cdtbActive = 1


----(1)-----
INSERT INTO [sma_TRN_CriticalDeadlines]
	(
	[crdnCaseID]
   ,[crdnCriticalDeadlineTypeID]
   ,[crddDueDate]
   ,[crdsRequestFrom]
   ,[ResponderUID]
	)
	SELECT
		CAS.casnCaseID								AS [crdnCaseID]
	   ,(
			SELECT
				cdtnCriticalTypeID
			FROM [sma_MST_CriticalDeadlineTypes]
			WHERE cdtbActive = 1
				AND cdtsDscrptn = dl.[label]
		)											
		AS [crdnCriticalDeadlineTypeID]
	   ,CASE
			WHEN C.casedate BETWEEN '1900-01-01' AND '2079-06-01'
				THEN C.casedate
			ELSE NULL
		END											AS [crddDueDate]
	   ,CONVERT(VARCHAR, aci.UniqueContactId) + ';' AS [crdsRequestFrom]
	   ,CONVERT(VARCHAR, aci.UniqueContactId)		AS [ResponderUID]
	FROM [BrianWhiteNeos]..[case_dates] C
	JOIN [BrianWhiteNeos]..date_labels dl
		ON c.datelabelid = dl.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), c.casesid)
	LEFT JOIN sma_TRN_Plaintiff p
		ON p.plnnCaseID = cas.casncaseid
	JOIN sma_MST_AllContactInfo aci
		ON ContactCtg = plnnContactCtg
			AND ContactId = plnnContactID
	WHERE ISNULL(c.casedate, '') <> ''


-----
ALTER TABLE [sma_TRN_CriticalDeadlines] ENABLE TRIGGER ALL
GO
-----


---(Appendix)---
ALTER TABLE sma_TRN_CriticalDeadlines DISABLE TRIGGER ALL
GO

UPDATE [sma_TRN_CriticalDeadlines]
SET crddCompliedDate = GETDATE()
WHERE crddDueDate < GETDATE()
GO

ALTER TABLE sma_TRN_CriticalDeadlines ENABLE TRIGGER ALL
GO