
USE BrianWhiteSA
GO
/*
alter table [sma_TRN_OtherReferral] disable trigger all
delete [sma_TRN_OtherReferral]
DBCC CHECKIDENT ('[sma_TRN_OtherReferral]', RESEED, 0);
alter table [sma_TRN_OtherReferral] enable trigger all
*/

--(1)--

INSERT INTO [sma_TRN_OtherReferral]
	(
	[otrnCaseID]
   ,[otrnRefContactCtg]
   ,[otrnRefContactID]
   ,[otrnRefAddressID]
   ,[otrnPlaintiffID]
   ,[otrsComments]
   ,[otrnUserID]
   ,[otrdDtCreated]
	)
	SELECT
		CAS.casnCaseID AS [otrnCaseID]
	   ,IOC.CTG		   AS [otrnRefContactCtg]
	   ,IOC.CID		   AS [otrnRefContactID]
	   ,IOC.AID		   AS [otrnRefAddressID]
	   ,-1			   AS [otrnPlaintiffID]
	   ,NULL		   AS [otrsComments]
	   ,368			   AS [otrnUserID]
	   ,GETDATE()	   AS [otrdDtCreated]
	FROM [BrianWhiteNeos].[dbo].[cases_indexed] C
	JOIN [sma_TRN_cases] CAS
		ON CAS.cassCaseNumber = C.casenum
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), C.referredby_namesid)
	WHERE ISNULL(CONVERT(VARCHAR(50), C.referredby_namesid), '') <> ''
