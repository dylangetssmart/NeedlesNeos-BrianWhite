
USE [BrianWhiteSA]
GO


/*
alter table [sma_TRN_Settlements] disable trigger all
delete [sma_TRN_Settlements]
DBCC CHECKIDENT ('[sma_TRN_Settlements]', RESEED, 1);
alter table [sma_TRN_Settlements] enable trigger all
*/

--select distinct code, description from [BrianWhiteNeos].[dbo].[value] order by code
---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Settlements')
	)
BEGIN
	ALTER TABLE [sma_TRN_Settlements] ADD [saga] VARCHAR(50) NULL;
END
GO

---(0)---
------------------------------------------------
--INSERT SETTLEMENT TYPES
------------------------------------------------
INSERT INTO [sma_MST_SettlementType]
	(
	SettlTypeName
	)
	SELECT
		'Settlement'
	EXCEPT
	SELECT
		SettlTypeName
	FROM [sma_MST_SettlementType]
GO


IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Settlement_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Settlement_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Settlement_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id VARCHAR(50)
   ,value_id VARCHAR(50)
   ,ProviderNameId VARCHAR(50)
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,casnCaseID INT
   ,PlaintiffID INT
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Settlement_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_case_id ON [value_tab_Settlement_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_value_id ON [value_tab_Settlement_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_ProviderNameId ON [value_tab_Settlement_Helper] (ProviderNameId);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Settlement_Helper_PlaintiffID ON [value_tab_Settlement_Helper] (PlaintiffID);
GO

---(0)---
INSERT INTO value_tab_Settlement_Helper
	(
	case_id
   ,value_id
   ,ProviderNameId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,casnCaseID
   ,PlaintiffID
	)
	SELECT
		CONVERT(VARCHAR(50), V.casesid) AS case_id
	   ,	-- needles case
		CONVERT(VARCHAR(50), V.id)		AS tab_id
	   ,		-- needles records TAB item
		CONVERT(VARCHAR(50), V.namesid) AS ProviderNameId
	   ,IOC.Name						AS ProviderName
	   ,IOC.CID							AS ProviderCID
	   ,IOC.CTG							AS ProviderCTG
	   ,IOC.AID							AS ProviderAID
	   ,CAS.casnCaseID					AS casnCaseID
	   ,NULL							AS PlaintiffID
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), V.namesid)
	WHERE code IN ('UIM', 'SETTLE', 'SUBRO', 'ATTYFEE', 'PIP', 'ATTYREFFEE', 'UM', 'REFERRAL', 'MEDPAY')
GO
---(0)---
DBCC DBREINDEX ('value_tab_Settlement_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)--- (prepare for multiple party)
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
FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
JOIN [BrianWhiteNeos].[dbo].[value_code] VC
	ON v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Plaintiff] t
	ON t.plnnCaseID = CAS.casnCaseID
		AND t.saga_party = v.partyid

--JOIN [BrianWhiteNeos].[dbo].[Party_Indexed] pt on pt.id = v.partyid and v.casesid = pt.casesid
--JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),pt.namesid)
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID

UPDATE value_tab_Settlement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


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
FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
JOIN [BrianWhiteNeos].[dbo].[value_code] VC
	ON v.valuecodeid = vc.id
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Defendants] d
	ON d.defnCaseID = cas.casncaseid
		AND d.saga_party = v.partyid

--JOIN [BrianWhiteNeos].[dbo].[Party_Indexed] pt on pt.id = convert(varchar(50),v.partyid) and v.casesid = pt.casesid
--JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(Varchar(50),pt.namesid)
--JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Settlement_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

----(1)----(  specified items go to settlement rows )
ALTER TABLE [sma_TRN_Settlements] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Settlements]
	(
	stlnCaseID
   ,stlnSetAmt
   ,stlnNet
   ,stlnNetToClientAmt
   ,stlnPlaintiffID
   ,stlnStaffID
   ,stlnLessDisbursement
   ,stlnGrossAttorneyFee
   ,stlnForwarder
   ,  --referrer
	stlnOther
   ,stlnMedPay
   ,InterestOnDisbursement
   ,stlsComments
   ,stlTypeID
   ,stldSettlementDate
   ,saga
	)
	SELECT
		MAP.casnCaseID  AS stlnCaseID
	   ,CASE
			WHEN vc.code IN ('SETTLE', 'SUBRO', 'UIM', 'PIP', 'UM')
				THEN v.total_value
			ELSE NULL
		END				AS stlnSetAmt
	   ,NULL			AS stlnNet
	   ,NULL			AS stlnNetToClientAmt
	   ,MAP.PlaintiffID AS stlnPlaintiffID
	   ,NULL			AS stlnStaffID
	   ,NULL			AS stlnLessDisbursement
	   ,CASE
			WHEN Vc.code IN ('ATTYFEE')
				THEN v.total_value
			ELSE NULL
		END				AS stlnGrossAttorneyFee
	   ,CASE
			WHEN vc.code IN ('ATTYREFFEE', 'REFERRAL')
				THEN v.total_value
			ELSE NULL
		END				AS stlnForwarder
	   ,    --Referrer
		NULL			AS stlnOther
	   ,CASE
			WHEN vc.code = 'MEDPAY'
				THEN v.total_value
			ELSE NULL
		END				AS stlnMedPay
	   ,NULL			AS InterestOnDisbursement
	   ,ISNULL('memo:' + NULLIF(V.memo, '') + CHAR(13), '') +
		ISNULL('code:' + NULLIF(Vc.code, '') + CHAR(13), '') +
		''				AS [stlsComments]
	   ,(
			SELECT
				ID
			FROM [sma_MST_SettlementType]
			WHERE SettlTypeName = 'Settlement'
		)				
		AS stlTypeID
	   ,CASE
			WHEN V.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN V.[start_date]
			ELSE NULL
		END				AS stldSettlementDate
	   ,V.id			AS saga
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	JOIN value_tab_Settlement_Helper MAP
		ON MAP.case_id = CONVERT(VARCHAR(50), V.casesid)
			AND MAP.value_id = CONVERT(VARCHAR(50), V.id)
	WHERE Vc.code IN ('UIM', 'SETTLE', 'SUBRO', 'ATTYFEE', 'PIP', 'ATTYREFFEE', 'UM', 'REFERRAL', 'MEDPAY')
GO

ALTER TABLE [sma_TRN_Settlements] ENABLE TRIGGER ALL
GO

