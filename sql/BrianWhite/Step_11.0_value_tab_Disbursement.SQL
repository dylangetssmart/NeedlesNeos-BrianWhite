
USE [SANeosBrianWhite]
GO


/*
alter table [sma_TRN_Disbursement] disable trigger all
delete from [sma_TRN_Disbursement] 
DBCC CHECKIDENT ('[sma_TRN_Disbursement]', RESEED, 0);
alter table [sma_TRN_Disbursement] enable trigger all
*/

ALTER TABLE sma_trn_Disbursement
ALTER COLUMN dissDescription NVARCHAR(600)
GO
---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Disbursement')
	)
BEGIN
	ALTER TABLE [sma_TRN_Disbursement] ADD [saga] VARCHAR(50) NULL;
END
GO
/*
INSERT INTO [sma_MST_CheckRequestStatus] ([description])
select 'Unrecouped'
EXCEPT SELECT [description] FROM [sma_MST_CheckRequestStatus]
*/
---(0)---
INSERT INTO [sma_MST_DisbursmentType]
	(
	dissTypeName
	)
	(
	SELECT DISTINCT
		VC.[description]
	FROM NeosBrianWhite..value_code vc
	JOIN NeosBrianWhite..value_Indexed vi
		ON vc.id = vi.valuecodeid
	WHERE ISNULL(vc.code, '') IN ('CASEEXP', 'CDB', 'DEBTPAY', 'LOAN', 'ADV', 'DTF', 'Write Off')
	)
	EXCEPT
	SELECT
		dissTypeName
	FROM [sma_MST_DisbursmentType]
GO

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Disbursement_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Disbursement_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Disbursement_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id VARCHAR(50)
   ,value_id VARCHAR(50)
   ,ProviderNamesId VARCHAR(50)
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,ProviderUID BIGINT
   ,casnCaseID INT
   ,PlaintiffID INT
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Disbursement_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_case_id ON [value_tab_Disbursement_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_value_id ON [value_tab_Disbursement_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Disbursement_Helper_ProviderNameId ON [value_tab_Disbursement_Helper] (ProviderNamesId);
GO

---(0)---
INSERT INTO value_tab_Disbursement_Helper
	(
	case_id
   ,value_id
   ,ProviderNamesId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,ProviderUID
   ,casnCaseID
   ,PlaintiffID
	)
	SELECT
		V.casesid	   AS case_id
	   ,	-- needles case
		V.id		   AS tab_id
	   ,		-- needles records TAB item
		V.namesid	   AS ProviderNamesId
	   ,IOC.Name	   AS ProviderName
	   ,IOC.CID		   AS ProviderCID
	   ,IOC.CTG		   AS ProviderCTG
	   ,IOC.AID		   AS ProviderAID
	   ,IOC.UNQCID	   AS ProviderUID
	   ,CAS.casnCaseID AS casnCaseID
	   ,NULL		   AS PlaintiffID
	--SELECT *
	FROM [NeosBrianWhite].[dbo].[value_Indexed] V
	JOIN [NeosBrianWhite].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), V.[namesid])
	WHERE code IN ('CASEEXP', 'CDB', 'DEBTPAY', 'LOAN', 'ADV', 'DTF', 'Write Off')
GO

---(0)---
DBCC DBREINDEX ('value_tab_Disbursement_Helper', ' ', 90) WITH NO_INFOMSGS
GO



---(0)--- value_id may associate with secondary plaintiff
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.casesid AS cid
   ,V.id	  AS vid
   ,T.plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM [NeosBrianWhite].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN NeosBrianWhite..Party_Indexed pt
	ON pt.id = v.partyid
JOIN IndvOrgContacts_Indexed IOC
	ON IOC.SAGA_REF = CONVERT(VARCHAR(50), pt.namesid)
JOIN [sma_TRN_Plaintiff] T
	ON T.plnnContactID = IOC.CID
		AND T.plnnContactCtg = IOC.CTG
		AND T.plnnCaseID = CAS.casnCaseID

UPDATE value_tab_Disbursement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

---(0)--- value_id may associate with defendant. steve malman make it associates to primary plaintiff 
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'value_tab_Multi_Party_Helper_Temp'
	)
BEGIN
	DROP TABLE value_tab_Multi_Party_Helper_Temp
END
GO

SELECT
	V.casesid AS cid
   ,V.id	  AS vid
   ,(
		SELECT
			plnnPlaintiffID
		FROM [sma_TRN_Plaintiff]
		WHERE plnnCaseID = CAS.casnCaseID
			AND plnbIsPrimary = 1
	)		  
	AS plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM [NeosBrianWhite].[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN NeosBrianWhite..Party_Indexed pt
	ON pt.id = v.partyid
JOIN IndvOrgContacts_Indexed IOC
	ON IOC.SAGA_ref = CONVERT(VARCHAR(50), pt.namesid)
JOIN [sma_TRN_Defendants] D
	ON D.defnContactID = IOC.CID
		AND D.defnContactCtgID = IOC.CTG
		AND D.defnCaseID = CAS.casnCaseID
GO

UPDATE value_tab_Disbursement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

--sp_help [sma_TRN_Disbursement]
---
ALTER TABLE [sma_TRN_Disbursement] DISABLE TRIGGER ALL
---
GO
---(1)---
INSERT INTO [sma_TRN_Disbursement]
	(
	disnCaseID
   ,disnPayeeContactCtgID
   ,disnPayeeContactID
   ,disnAmount
   ,disnPlaintiffID
   ,dissDisbursementType
   ,UniquePayeeID
   ,dissDescription
   ,dissComments
   ,disnCheckRequestStatus
   ,disdBillDate
   ,disdDueDate
   ,disnRecUserID
   ,disdDtCreated
   ,disnRecoverable
   ,saga
	)
	SELECT
		MAP.casnCaseID  AS disnCaseID
	   ,MAP.ProviderCTG AS disnPayeeContactCtgID
	   ,MAP.ProviderCID AS disnPayeeContactID
	   ,V.total_value   AS disnAmount
	   ,MAP.PlaintiffID AS disnPlaintiffID
	   ,(
			SELECT
				disnTypeID
			FROM [sma_MST_DisbursmentType]
			WHERE dissTypeName = vc.[description]
		)				
		AS dissDisbursementType
	   ,MAP.ProviderUID AS UniquePayeeID
	   ,V.[memo]		AS dissDescription
	   ,  --nvarchar 510
		--isnull('Invoice Request #: ' + nullif(convert(varchar,uvd.[Invoice__Request_#]),'') + CHAR(13),'') +
		--isnull('Trans ID Approval Code: ' + nullif(convert(varchar,uvd.[Trans_ID__Approval_Code]),'') + CHAR(13),'') +
		--isnull('Check Voided: ' + nullif(convert(varchar,uvd.Check_Voided),'') + CHAR(13),'') +
		''				AS dissComments
	   ,
		--case when v.code in ( 'CEX', 'EXP', 'HEA', 'REN','TOW','TRF' )   then  (select Id FROM [sma_MST_CheckRequestStatus] where [Description]='Paid')	
		--when v.code in ('UCC') then  (select Id FROM [sma_MST_CheckRequestStatus] where [Description]='Unrecouped')	
		NULL			AS disnCheckRequestStatus
	   ,CASE
			WHEN V.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.[start_date]
			ELSE NULL
		END				AS disdBillDate
	   ,CASE
			WHEN V.stop_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.stop_date
			ELSE NULL
		END				AS disdDueDate
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = CONVERT(VARCHAR(50), v.staffcreatedid)
		)				
		AS disnRecUserID
	   ,CASE
			WHEN v.date_created BETWEEN '1900-01-01' AND '2079-06-06'
				THEN v.date_created
			ELSE NULL
		END				AS disdDtCreated
	   ,CASE
			WHEN vc.code IN ('DTF', 'LOAN')
				THEN 0
			ELSE 1
		END				AS disnRecoverable
	   ,
		--1						as disnRecoverable,
		V.id			AS saga
	--select max(len(V.[memo]))
	FROM [NeosBrianWhite].[dbo].[value_Indexed] V
	JOIN [NeosBrianWhite].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	--LEFT JOIN NeosBrianWhite..user_value_data uvd on v.value_ID = uvd.value_id
	JOIN value_tab_Disbursement_Helper MAP
		ON MAP.case_id = V.casesid
			AND MAP.value_id = V.id
GO
---
ALTER TABLE [sma_TRN_Disbursement] ENABLE TRIGGER ALL
GO
---
