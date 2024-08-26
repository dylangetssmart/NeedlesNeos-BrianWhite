
USE [SANeosBrianWhite]
GO

/*
alter table [sma_TRN_TaskNew] disable trigger all
delete from [sma_TRN_TaskNew]
DBCC CHECKIDENT ('[sma_TRN_TaskNew]', RESEED, 0);
alter table [sma_TRN_TaskNew] disable trigger all
*/

----(0)----
INSERT INTO [sma_MST_TaskCategory]
	(
	tskCtgDescription
	)
	SELECT
		'Checklist'
	EXCEPT
	SELECT
		tskCtgDescription
	FROM [sma_MST_TaskCategory]

/*
select distinct (select top 1 replace(ltrim(DIR.[description]),'>','')) 
FROM [NeosBrianWhite].[dbo].[checklist_dir] DIR 
inner join [NeosBrianWhite].[dbo].[case_checklist] LST on DIR.code=LST.code
where isnull(DIR.[description],'')<>''
except
select tskCtgDescription from [SANeosBrianWhite].[dbo].[sma_MST_TaskCategory] 
GO
*/
---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_TaskNew')
	)
BEGIN
	ALTER TABLE [sma_TRN_TaskNew] ADD [saga] INT NULL;
END
GO

---(1)---
ALTER TABLE [sma_TRN_TaskNew] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_TaskNew]
	(
	[tskCaseID]
   ,[tskDueDate]
   ,[tskStartDate]
   ,[tskRequestorID]
   ,[tskAssigneeId]
   ,[tskReminderDays]
   ,[tskDescription]
   ,[tskCreatedDt]
   ,[tskCreatedUserID]
   ,[tskMasterID]
   ,[tskCtgID]
   ,[tskSummary]
   ,[tskPriority]
   ,[tskCompleted]
   ,[saga]
	)
	SELECT DISTINCT
		CAS.casnCaseID				 AS [tskCaseID]
	   ,CASE
			WHEN CKL.due_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN CKL.due_date
			ELSE '1900-01-01'
		END							 AS [tskDueDate]
	   ,NULL						 AS [tskStartDate]
	   ,NULL						 AS [tskRequestorID]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = CONVERT(VARCHAR(50), CKL.staffassignedid)
		)							 
		AS [tskAssigneeId]
	   ,NULL						 AS [tskReminderDays]
	   ,
		--ltrim(CKL.[description])																as [tskDescription],
		NULL						 AS [tskDescription]
	   ,ckl.date_created			 AS [tskCreatedDt]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_Users
			WHERE saga = ckl.staffcreatedid
		)							 
		AS tskCreatedUserID
	   ,(
			SELECT
				tskMasterID
			FROM sma_mst_Task_Template
			WHERE tskMasterDetails = 'Custom Task'
		)							 
		AS [tskMasterID]
	   ,(
			SELECT
				tskCtgID
			FROM sma_MST_TaskCategory
			WHERE tskCtgDescription = 'Checklist'
		)							 
		AS [tskCtgID]
	   ,LTRIM(CKL.[description])	 AS [tskSummary]
	   ,  --task subject--
		(
			SELECT
				uId
			FROM PriorityTypes
			WHERE PriorityType = 'Normal'
		)							 
		AS [tskPriority]
	   ,CASE
			WHEN CKL.[status] = 'Done'
				THEN (
						SELECT
							StatusID
						FROM TaskStatusTypes
						WHERE StatusType = 'Completed'
					)
			WHEN CKL.[status] = 'Open'
				THEN (
						SELECT
							StatusID
						FROM TaskStatusTypes
						WHERE StatusType = 'In Progress'
					)
			WHEN CKL.[status] = 'N/A'
				THEN (
						SELECT
							StatusID
						FROM TaskStatusTypes
						WHERE StatusType = 'Cancelled'
					)
			ELSE (
					SELECT
						StatusID
					FROM TaskStatusTypes
					WHERE StatusType = 'Not Started'
				)
		END							 AS [tskCompleted]
	   ,CONVERT(VARCHAR(50), CKL.id) AS [saga]
	--SELECT *
	FROM [NeosBrianWhite].[dbo].[case_checklist] CKL
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CKL.casesid)
	WHERE ISNULL(CAS.casdClosingDate, '') = ''
		AND CKL.due_date BETWEEN '1900-01-01' AND '2079-06-06'
GO

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO

