
USE [BrianWhiteSANeos]
GO
/*
alter table [sma_TRN_caseStaff] disable trigger all
delete [sma_TRN_caseStaff]
DBCC CHECKIDENT ('[sma_TRN_caseStaff]', RESEED, 0);
alter table [sma_TRN_caseStaff] enable trigger all

select * 
From BrianWhiteNeos..case_staff cs
JOIN BrianWhiteNeos..matter_staff ms on ms.id = cs.matterstaffid
JOIN BrianWhiteNeos..staff_Role sr on sr.id = ms.staffroleid
*/


----(0) staff roles ----
INSERT INTO [sma_MST_SubRoleCode]
	(
	srcsDscrptn
   ,srcnRoleID
	)
	SELECT
		CASE
			WHEN [role] = 'Attorney'
				THEN 'Primary Attorney'
			ELSE [role]
		END
	   ,10
	FROM BrianWhiteNeos..staff_Role
	EXCEPT
	SELECT
		srcsDscrptn
	   ,srcnRoleID
	FROM [sma_MST_SubRoleCode]


----(1)-----
---
ALTER TABLE [sma_TRN_caseStaff] DISABLE TRIGGER ALL
GO
---

INSERT INTO sma_TRN_caseStaff
	(
	[cssnCaseID]
   ,[cssnStaffID]
   ,[cssnRoleID]
   ,[csssComments]
   ,[cssdFromDate]
   ,[cssdToDate]
   ,[cssnRecUserID]
   ,[cssdDtCreated]
   ,[cssnModifyUserID]
   ,[cssdDtModified]
   ,[cssnLevelNo]
	)
	SELECT DISTINCT
		CAS.casnCaseID  AS [cssnCaseID]
	   ,U.usrnContactID AS [cssnStaffID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole
			WHERE sbrsDscrptn = CASE
					WHEN [role] = 'Attorney'
						THEN 'Primary Attorney'
					ELSE [role]
				END
				AND sbrnRoleID = 10
		)				
		AS [cssnRoleID]
	   ,NULL			AS [csssComments]
	   ,NULL			AS cssdFromDate
	   ,NULL			AS cssdToDate
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = cs.staffcreatedid
		)				
		AS cssnRecUserID
	   ,cs.date_created AS [cssdDtCreated]
	   ,NULL			AS [cssnModifyUserID]
	   ,NULL			AS [cssdDtModified]
	   ,0				AS cssnLevelNo
	--SELECT *
	FROM BrianWhiteNeos..case_staff cs
	JOIN BrianWhiteNeos..matter_staff ms
		ON ms.id = cs.matterstaffid
	JOIN BrianWhiteNeos..staff_Role sr
		ON sr.id = ms.staffroleid
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), cs.casesid)
	JOIN [sma_MST_Users] U
		ON (U.saga = CONVERT(VARCHAR(50), cs.staffid))
GO

---
ALTER TABLE [sma_TRN_caseStaff] ENABLE TRIGGER ALL
GO
---


