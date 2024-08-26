USE BrianWhiteSA
GO
/*
alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all
*/

---(1)---SOL for Defendant ---
ALTER TABLE [sma_TRN_SOLs] DISABLE TRIGGER ALL
GO
INSERT INTO [sma_TRN_SOLs]
	(
	[solnCaseID]
   ,[solnSOLTypeID]
   ,[soldSOLDate]
   ,[soldDateComplied]
   ,[soldSnCFilingDate]
   ,[soldServiceDate]
   ,[solnDefendentID]
   ,[soldToProcessServerDt]
   ,[soldRcvdDate]
   ,[solsType]
   ,[solsComments]
   ,[solnRecUserID]
   ,[soldDtCreated]
   ,[solnModifyUserID]
   ,[soldDtModified]

	)
	SELECT DISTINCT
		CAS.casnCaseID	  AS [solnCaseID]
	   ,(
			SELECT
				sldnSOLDetID
			FROM sma_MST_SOLDetails
			WHERE sldnSOLTypeID = 16
				AND sldnCaseTypeID = -1
				AND sldsDorP = 'D'
		)				  
		AS [solnSOLTypeID]
	   ,CASE
			WHEN (CKL.due_date NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN NULL
			ELSE CKL.due_date
		END				  AS [soldSOLDate]
	   ,CASE
			WHEN CKL.[status] = 'Done'
				THEN GETDATE()
			ELSE NULL
		END				  AS [soldDateComplied]
	   ,NULL			  AS [soldSnCFilingDate]
	   ,NULL			  AS [soldServiceDate]
	   ,D.defnDefendentID AS [solnDefendentID]
	   ,NULL			  AS [soldToProcessServerDt]
	   ,NULL			  AS [soldRcvdDate]
	   ,'D'				  AS [solsType]
	   ,ISNULL('description : ' + NULLIF(CKL.[description], '') + CHAR(13), '') +
		-- isnull('staff assigned : ' + nullif(CKL.[staff_assigned],'') + CHAR(13) ,'') 
		''				  AS [solsComments]
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = CKL.staffassignedid
		)				  
		AS [solnRecUserID]
	   ,GETDATE()		  AS [soldDtCreated]
	   ,NULL			  AS [solnModifyUserID]
	   ,NULL			  AS [soldDtModified]
	--SELECT *
	FROM [sma_TRN_Defendants] D
	JOIN [sma_TRN_Cases] CAS
		ON CAS.casnCaseID = D.defnCaseID
			AND D.defbIsPrimary = 1
	--JOIN [sma_MST_SOLDetails] S on S.sldnCaseTypeID=CAS.casnOrgCaseTypeID and S.sldnStateID=CAS.casnStateID and S.sldnDefRole=D.defnSubRole
	JOIN [BrianWhiteNeos].[dbo].[case_checklist] CKL
		ON CONVERT(VARCHAR(50), CKL.casesid) = CAS.Neos_Saga
	WHERE CKL.due_date BETWEEN '1900-01-01' AND '2079-06-06'
		AND (
			SELECT
				lim
			FROM [BrianWhiteNeos].[dbo].[checklist_dir]
			WHERE ckl.checklistdirid = id
		)
		= 1
GO

ALTER TABLE [sma_TRN_SOLs] ENABLE TRIGGER ALL
GO



