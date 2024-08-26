
USE [SANeosBrianWhite]
GO
/*
alter table [sma_TRN_Negotiations] disable trigger all
delete [sma_TRN_Negotiations]
DBCC CHECKIDENT ('[sma_TRN_Negotiations]', RESEED, 1);
alter table [sma_TRN_Negotiations] enable trigger all

alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

--(0)--

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'SettlementAmount'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Negotiations')
	)
BEGIN
	ALTER TABLE sma_TRN_Negotiations
	ADD SettlementAmount DECIMAL(18, 2) NULL
END
GO

--(1)--
INSERT INTO [sma_TRN_Negotiations]
	(
	[negnCaseID]
   ,[negsUniquePartyID]
   ,[negdDate]
   ,[negnStaffID]
   ,[negnPlaintiffID]
   ,[negbPartiallySettled]
   ,[negnClientAuthAmt]
   ,[negbOralConsent]
   ,[negdOralDtSent]
   ,[negdOralDtRcvd]
   ,[negnDemand]
   ,[negnOffer]
   ,[negbConsentType]
   ,[negnRecUserID]
   ,[negdDtCreated]
   ,[negnModifyUserID]
   ,[negdDtModified]
   ,[negnLevelNo]
   ,[negsComments]
   ,[SettlementAmount]
	)
	SELECT
		CAS.casnCaseID AS [negnCaseID]
	   ,('I' + CONVERT(VARCHAR, (
			SELECT TOP 1
				incnInsCovgID
			FROM [sma_TRN_InsuranceCoverage] INC
			WHERE INC.incnCaseID = CAS.casnCaseID
				AND INC.saga = CONVERT(VARCHAR(50), INS.id)
				AND INC.incnInsContactID = (
					SELECT TOP 1
						connContactID
					FROM [sma_MST_OrgContacts]
					WHERE saga_ref = CONVERT(VARCHAR(50), INS.insurer_namesid)
				)
		)
		))			   
		AS [negsUniquePartyID]
	   ,CASE
			WHEN NEG.neg_date BETWEEN '1900-01-01' AND '2079-12-31'
				THEN NEG.neg_date
			ELSE NULL
		END			   AS [negdDate]
	   ,(
			SELECT
				usrnContactiD
			FROM sma_MST_Users
			WHERE saga = CONVERT(VARCHAR(50), NEG.staffid)
		)			   
		AS [negnStaffID]
	   ,-1			   AS [negnPlaintiffID]
	   ,NULL		   AS [negbPartiallySettled]
	   ,CASE
			WHEN nt.[name] = 'Client Authorize'
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnClientAuthAmt]
	   ,NULL		   AS [negbOralConsent]
	   ,NULL		   AS [negdOralDtSent]
	   ,NULL		   AS [negdOralDtRcvd]
	   ,CASE
			WHEN nt.[name] = 'Demand'
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnDemand]
	   ,CASE
			WHEN nt.[name] IN ('Offer', 'Conditional Ofr')
				THEN NEG.amount
			ELSE NULL
		END			   AS [negnOffer]
	   ,NULL		   AS [negbConsentType]
	   ,368
	   ,GETDATE()
	   ,368
	   ,GETDATE()
	   ,0			   AS [negnLevelNo]
	   ,ISNULL(nt.[name] + ' : ' + NULLIF(CONVERT(VARCHAR, NEG.amount), '') + CHAR(13) + CHAR(10), '') +
		NEG.notes	   AS [negsComments]
	   ,CASE
			WHEN nt.[name] = 'Settlement'
				THEN NEG.amount
			ELSE NULL
		END			   AS [SettlementAmount]
	--select *
	FROM [NeosBrianWhite].[dbo].[negotiation] NEG
	LEFT JOIN NeosBrianWhite..negotiation_type nt
		ON nt.id = neg.negotiationtypeid
	LEFT JOIN [NeosBrianWhite].[dbo].[insurance_Indexed] INS
		ON INS.id = NEG.insuranceid
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), neg.casesid)
	LEFT JOIN [Insurance_Contacts_Helper] MAP
		ON CONVERT(VARCHAR(50), INS.id) = MAP.insurance_id


-----------------

INSERT INTO [sma_TRN_Settlements]
	(
	stlnSetAmt
   ,stlnStaffID
   ,stlnPlaintiffID
   ,stlsUniquePartyID
   ,stlnCaseID
   ,stlnNegotID
	)
	SELECT
		SettlementAmount  AS stlnSetAmt
	   ,negnStaffID		  AS stlnStaffID
	   ,negnPlaintiffID	  AS stlnPlaintiffID
	   ,negsUniquePartyID AS stlsUniquePartyID
	   ,negnCaseID		  AS stlnCaseID
	   ,negnID			  AS stlnNegotID
	FROM [sma_TRN_Negotiations]
	WHERE ISNULL(SettlementAmount, 0) > 0

