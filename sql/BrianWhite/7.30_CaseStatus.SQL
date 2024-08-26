
USE BrianWhiteSANeos
GO

/*
alter table [sma_TRN_CaseStatus] disable trigger all
delete from [sma_TRN_CaseStatus]
DBCC CHECKIDENT ('[sma_TRN_CaseStatus]', RESEED, 0);
alter table [sma_TRN_CaseStatus] enable trigger all
*/

---(0)---
INSERT INTO sma_MST_CaseStatus
	(
	csssDescription
   ,cssnStatusTypeID
	)
	SELECT
		A.[name]
	   ,(
			SELECT
				stpnStatusTypeID
			FROM sma_MST_CaseStatusType
			WHERE stpsStatusType = 'Status'
		)
	FROM (
		SELECT DISTINCT
			[description] AS [name]
		FROM [BrianWhiteNeos].[dbo].[class] class
		JOIN [BrianWhiteNeos].[dbo].[cases] C
			ON C.classid = class.[id]
		UNION
		SELECT
			'Conversion Case No Status'
		EXCEPT
		SELECT
			csssDescription AS [name]
		FROM sma_MST_CaseStatus
		WHERE cssnStatusTypeID = (
				SELECT
					stpnStatusTypeID
				FROM sma_MST_CaseStatusType
				WHERE stpsStatusType = 'Status'
			)
	) A
GO


---(1)---
ALTER TABLE [sma_TRN_CaseStatus] DISABLE TRIGGER ALL
GO
---------

INSERT INTO [sma_TRN_CaseStatus]
	(
	[cssnCaseID]
   ,[cssnStatusTypeID]
   ,[cssnStatusID]
   ,[cssnExpDays]
   ,[cssdFromDate]
   ,[cssdToDt]
   ,[csssComments]
   ,[cssnRecUserID]
   ,[cssdDtCreated]
   ,[cssnModifyUserID]
   ,[cssdDtModified]
   ,[cssnLevelNo]
   ,[cssnDelFlag]
	)
	SELECT
		CAS.casnCaseID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM sma_MST_CaseStatusType
			WHERE stpsStatusType = 'Status'
		)		  
		AS [cssnStatusTypeID]
	   ,CASE
			WHEN C.close_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN (
						SELECT
							cssnStatusID
						FROM sma_MST_CaseStatus
						WHERE csssDescription = 'Closed Case'
					)
			WHEN EXISTS (
					SELECT
						*
					FROM sma_MST_CaseStatus
					WHERE csssDescription = CL.[description]
				)
				THEN (
						SELECT
							cssnStatusID
						FROM sma_MST_CaseStatus
						WHERE csssDescription = CL.[description]
					)
			ELSE (
					SELECT
						cssnStatusID
					FROM sma_MST_CaseStatus
					WHERE csssDescription = 'Conversion Case No Status'
				)
		END		  AS [cssnStatusID]
	   ,''		  AS [cssnExpDays]
	   ,GETDATE() AS [cssdFromDate]
	   ,NULL	  AS [cssdToDt]
	   ,CASE
			WHEN C.close_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN 'Prior Status : ' + CL.[description]
			ELSE ''
		END + CHAR(13) +
		''		  AS [csssComments]
	   ,368
	   ,GETDATE()
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [sma_trn_cases] CAS
	JOIN [BrianWhiteNeos].[dbo].[cases] C
		ON CONVERT(VARCHAR(50), C.[id]) = CAS.Neos_saga
	JOIN [BrianWhiteNeos].[dbo].[class] CL
		ON C.classid = CL.id
GO

--------
ALTER TABLE [sma_TRN_CaseStatus] ENABLE TRIGGER ALL
GO
--------


---(2)---
ALTER TABLE [sma_trn_cases] DISABLE TRIGGER ALL
GO
---------
UPDATE sma_trn_cases
SET casnStatusValueID = STA.cssnStatusID
FROM sma_TRN_CaseStatus STA
WHERE STA.cssnCaseID = casnCaseID
GO

ALTER TABLE [sma_trn_cases] ENABLE TRIGGER ALL
GO


