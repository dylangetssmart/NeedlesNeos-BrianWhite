USE SANeosBrianWhite
GO

/*
alter table [sma_TRN_SOLs] disable trigger all
delete [sma_TRN_SOLs]
DBCC CHECKIDENT ('[sma_TRN_SOLs]', RESEED, 0);
alter table [sma_TRN_SOLs] enable trigger all

alter table [sma_MST_SOLDetails] disable trigger all
delete [sma_MST_SOLDetails]
DBCC CHECKIDENT ('[sma_MST_SOLDetails]', RESEED, 0);
alter table [sma_MST_SOLDetails] enable trigger all
*/

---------------------------------------------------------------------------------
--INSERT SOL 000 FOR CONVERSION ONLY - DO NOT ADD FOR EVERY SINGLE CASE TYPE
---------------------------------------------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_SOLDetails]
		WHERE sldnSOLTypeID = 16
			AND sldnCaseTypeID = -1
			AND sldsDorP = 'D'
	)
BEGIN
	INSERT INTO [dbo].[sma_MST_SOLDetails]
		(
		[sldnSOLTypeID]
	   ,[sldnCaseTypeID]
	   ,[sldnDefRole]
	   ,[sldnStateID]
	   ,[sldnYears]
	   ,[sldnMonths]
	   ,[sldnDays]
	   ,[sldnSOLDays]
	   ,[sldnRecUserID]
	   ,[slddDtCreated]
	   ,[sldnModifyUserID]
	   ,[slddDtModified]
	   ,[sldnLevelNo]
	   ,[sldsDorP]
	   ,[sldsSOLName]
	   ,[sldbIsIncidDtEffect]
	   ,[sldbDefualt]
	   ,[sldnFromIncident]
		)
		SELECT
			16
		   ,-1
		   ,-1
		   ,-1
		   ,0
		   ,0
		   ,0
		   ,NULL
		   ,368
		   ,GETDATE()
		   ,NULL
		   ,NULL
		   ,NULL
		   ,'D'
		   ,'SOL'
		   ,0
		   ,0
		   ,0
END
GO


-----
ALTER TABLE [sma_TRN_SOLs] DISABLE TRIGGER ALL
GO
-----

----(2)----
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
	)
	SELECT DISTINCT
		D.defnCaseID	  AS [solnCaseID]
	   ,(
			SELECT
				sldnSOLDetID
			FROM sma_MST_SOLDetails
			WHERE sldnSOLTypeID = 16
				AND sldnCaseTypeID = -1
				AND sldsDorP = 'D'
		)
	   ,			--[solnSOLTypeID],
		CASE
			WHEN (C.[lim_date] NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN NULL
			ELSE C.[lim_date]
		END				  AS [soldSOLDate]
	   ,NULL			  AS [soldDateComplied]
	   ,NULL			  AS [soldSnCFilingDate]
	   ,NULL			  AS [soldServiceDate]
	   ,D.defnDefendentID AS [solnDefendentID]
	   ,NULL			  AS [soldToProcessServerDt]
	   ,NULL			  AS [soldRcvdDate]
	   ,'D'				  AS [solsType]
	FROM [NeosBrianWhite].[dbo].[cases_Indexed] C
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), C.id)
	JOIN [sma_TRN_Defendants] D
		ON D.defnCaseID = CAS.casnCaseID
	WHERE C.lim_date IS NOT NULL
GO

-----
ALTER TABLE [sma_TRN_SOLs] ENABLE TRIGGER ALL
GO
-----


----(Appendix)----
UPDATE sma_MST_SOLDetails
SET sldnFromIncident = 0
WHERE sldnFromIncident IS NULL
AND sldnRecUserID = 368

