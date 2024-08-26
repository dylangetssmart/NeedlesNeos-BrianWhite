
USE [BrianWhiteSA]
GO

/*
alter table [sma_TRN_TaskNew] disable trigger all
delete from [sma_TRN_TaskNew]
DBCC CHECKIDENT ('[sma_TRN_TaskNew]', RESEED, 0);
alter table [sma_TRN_TaskNew] disable trigger all

select distinct g.*
from BrianWhiteNeos..neosUsertab2 u
LEFT JOIN BrianWhiteNeos..mini_general_dir g on g.id = u.[Type of Record]
WHERE isnull(g.code,'') IN ('Investigation Report','Declaration Page','Curriculum Vitae','Itemized Subrogation Lien','Video Preservation',
'Policy Limits','Open Records','Osha - California','Maintenance Report','Police Report','Lost Wages','Prior Claim(s) Report' )
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
	ALTER TABLE [sma_TRN_TaskNew] ADD [saga] VARCHAR(50);
END
GO

----------------------------------
--TASK CATEGORY
----------------------------------
INSERT INTO [sma_MST_TaskCategory]
	(
	tskCtgDescription
	)
	SELECT DISTINCT
		ISNULL(g.code, 'Other')
	FROM BrianWhiteNeos..neosUsertab2 u
	LEFT JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Type of Record]
	WHERE ISNULL(g.code, '') IN ('Investigation Report', 'Declaration Page', 'Curriculum Vitae', 'Itemized Subrogation Lien', 'Video Preservation',
		'Policy Limits', 'Open Records', 'Osha - California', 'Maintenance Report', 'Police Report', 'Lost Wages', 'Prior Claim(s) Report')
	EXCEPT
	SELECT
		tskCtgDescription
	FROM [sma_MST_TaskCategory]
GO

---(1)---
ALTER TABLE [sma_TRN_TaskNew] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_TaskNew]
	(
	[tskCaseID]
   ,[tskDueDate]
   ,[tskStartDate]
   ,[tskCompletedDt]
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
	SELECT
		CAS.casnCaseID								 AS [tskCaseID]
	   ,NULL										 AS [tskDueDate]
	   ,CASE
			WHEN u.[Date Requested] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN u.[Date Requested]
			ELSE NULL
		END											 AS [tskStartDate]
	   ,CASE
			WHEN u.[date received] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN u.[date received]
			ELSE NULL
		END											 AS [tskCompletedDt]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), u.[Ordered By])
		)											 
		AS [tskRequestorID]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), u.[Ordered By])
		)											 
		AS [tskAssigneeId]
	   ,NULL										 AS [tskReminderDays]
	   ,ISNULL('PrePayment Required: ' + NULLIF(CONVERT(VARCHAR, u.[pre-payment required]), '') + CHAR(13), '') +
		ISNULL('Method: ' + NULLIF(CONVERT(VARCHAR, me.code), '') + CHAR(13), '') +
		ISNULL('Value Code: ' + NULLIF(CONVERT(VARCHAR, vc.[Description]), '') + CHAR(13), '') +
		ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), u.Comments), '') + CHAR(13), '') +
		ISNULL('Alternate Provider: ' + NULLIF(CONVERT(VARCHAR, iocalt.[Name]), '') + CHAR(13), '') +
		''											 AS [tskDescription]
	   ,NULL										 AS [tskCreatedDt]
	   ,NULL										 AS tskCreatedUserID
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
			WHERE tskCtgDescription = ISNULL(g.[code], 'Other')
		)											 
		AS [tskCtgID]
	   ,iocp.[Name]									 AS [tskSummary]
	   ,  --task subject--
		(
			SELECT
				uId
			FROM PriorityTypes
			WHERE PriorityType = 'Normal'
		)											 
		AS [tskPriority]
	   ,CASE
			WHEN u.[date received] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN (
						SELECT
							StatusID
						FROM TaskStatusTypes
						WHERE StatusType = 'Completed'
					)
			ELSE (
					SELECT
						StatusID
					FROM TaskStatusTypes
					WHERE StatusType = 'In Progress'
				)
		END											 AS [tskCompleted]
	   ,'tab2: ' + CONVERT(VARCHAR(50), u.tablistid) AS [saga]
	--SELECT *
	FROM BrianWhiteNeos..neosUsertab2 u
	LEFT JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Type of Record]
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), u.casesid)
	LEFT JOIN BrianWhiteNeos..value_code vc
		ON vc.id = u.[value Code]
	LEFT JOIN BrianWhiteNeos..mini_general_dir me
		ON me.id = u.[method]
	LEFT JOIN IndvOrgContacts_Indexed iocp
		ON iocp.saga_ref = CONVERT(VARCHAR(50), u.[provider name])
	LEFT JOIN IndvOrgContacts_Indexed iocalt
		ON iocalt.saga_ref = CONVERT(VARCHAR(50), u.[Alternate Provider])
	WHERE ISNULL(g.code, '') IN ('Investigation Report', 'Declaration Page', 'Curriculum Vitae', 'Itemized Subrogation Lien', 'Video Preservation',
		'Policy Limits', 'Open Records', 'Osha - California', 'Maintenance Report', 'Police Report', 'Lost Wages', 'Prior Claim(s) Report')
GO

ALTER TABLE [sma_TRN_TaskNew] ENABLE TRIGGER ALL
GO

--select * from needlesgma..user_tab2_data where Second_Followed_Up_By