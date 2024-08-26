
USE BrianWhiteSA
GO
/*
alter table [sma_TRN_CriticalComments] disable trigger all
delete from [sma_TRN_CriticalComments] 
DBCC CHECKIDENT ('[sma_TRN_CriticalComments]', RESEED, 0);
alter table [sma_TRN_CriticalComments] enable trigger all
*/

INSERT INTO [sma_TRN_CriticalComments]
	(
	[ctcnCaseID]
   ,[ctcnCommentTypeID]
   ,[ctcsText]
   ,[ctcbActive]
   ,[ctcnRecUserID]
   ,[ctcdDtCreated]
   ,[ctcnModifyUserID]
   ,[ctcdDtModified]
   ,[ctcnLevelNo]
   ,[ctcsCommentType]
	)
	SELECT
		CAS.casnCaseID AS [ctcnCaseID]
	   ,0			   AS [ctcnCommentTypeID]
	   ,special_note   AS [ctcsText]
	   ,1			   AS [ctcbActive]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = CONVERT(VARCHAR(50), staffcreatedid)
		)			   
		AS [ctcnRecUserID]
	   ,date_created   AS [ctcdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = CONVERT(VARCHAR(50), staffmodifiedid)
		)			   
		AS [ctcnModifyUserID]
	   ,date_modified  AS [ctcdDtModified]
	   ,NULL		   AS [ctcnLevelNo]
	   ,NULL		   AS [ctcsCommentType]
	--select *
	FROM [BrianWhiteNeos].[dbo].[cases_Indexed] C
	JOIN [sma_trn_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), C.id)
	WHERE ISNULL(special_note, '') <> ''

