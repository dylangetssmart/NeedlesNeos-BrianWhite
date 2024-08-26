
USE [BrianWhiteSANeos]
GO
/*
alter table [sma_TRN_ReferredOut] disable trigger all
delete [sma_TRN_ReferredOut]
DBCC CHECKIDENT ('[sma_TRN_ReferredOut]', RESEED, 0);
alter table [sma_TRN_ReferredOut] enable trigger all

select * from [sma_TRN_ReferredOut]
*/

--(1)--
INSERT INTO [sma_TRN_ReferredOut]
	(
	rfosType
   ,rfonCaseID
   ,rfonPlaintiffID
   ,rfonLawFrmContactID
   ,rfonLawFrmAddressID
   ,rfonAttContactID
   ,rfonAttAddressID
   ,rfonGfeeAgreement
   ,rfobMultiFeeStru
   ,rfobComplexFeeStru
   ,rfonReferred
   ,rfonCoCouncil
   ,rfonIsLawFirmUpdateToSend
	)

	SELECT
		'G'			   AS rfosType
	   ,CAS.casnCaseID AS rfonCaseID
	   ,-1			   AS rfonPlaintiffID
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END			   AS rfonLawFrmContactID
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END			   AS rfonLawFrmAddressID
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END			   AS rfonAttContactID
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END			   AS rfonAttAddressID
	   ,0			   AS rfonGfeeAgreement
	   ,0			   AS rfobMultiFeeStru
	   ,0			   AS rfobComplexFeeStru
	   ,1			   AS rfonReferred
	   ,0			   AS rfonCoCouncil
	   ,0			   AS rfonIsLawFirmUpdateToSend
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[cases_indexed] C
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), C.id)
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), C.referredto_namesid)
	WHERE ISNULL(CONVERT(VARCHAR(50), C.referredto_namesid), '') <> ''


--(2)--
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [dbo].[sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
)
WHERE cinnContactID IN (
	SELECT
		rfonAttContactID
	FROM sma_TRN_ReferredOut
	WHERE ISNULL(rfonAttContactID, '') <> ''
)


