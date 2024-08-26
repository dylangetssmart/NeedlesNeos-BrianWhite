
USE [BrianWhiteSA]
GO
/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

alter table [sma_TRN_SpDamages] disable trigger all
delete [sma_TRN_SpDamages]
DBCC CHECKIDENT ('[sma_TRN_SpDamages]', RESEED, 0);
alter table [sma_TRN_SpDamages] enable trigger all

alter table [sma_TRN_SpecialDamageAmountPaid] disable trigger all
delete [sma_TRN_SpecialDamageAmountPaid]
DBCC CHECKIDENT ('[sma_TRN_SpecialDamageAmountPaid]', RESEED, 0);
alter table [sma_TRN_SpecialDamageAmountPaid] enable trigger all
*/

--select distinct code, description from [BrianWhiteNeos].[dbo].[value] order by code
-----------

ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_SpecialDamageAmountPaid] DISABLE TRIGGER ALL
GO


---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
BEGIN
	ALTER TABLE [sma_TRN_Hospitals] ADD [saga] [VARCHAR](100) NULL;
END
GO

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_bill_id'
			AND Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
BEGIN
	ALTER TABLE [sma_TRN_SpDamages] ADD [saga_bill_id] [VARCHAR](100) NULL;
END
GO

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_MedicalProvider_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_MedicalProvider_Helper
END
GO

---(0)---
CREATE TABLE value_tab_MedicalProvider_Helper (
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
   ,CONSTRAINT IOC_Clustered_Index_value_tab_MedicalProvider_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_MedicalProvider_Helper_case_id ON [value_tab_MedicalProvider_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_MedicalProvider_Helper_value_id ON [value_tab_MedicalProvider_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_MedicalProvider_Helper_ProviderNameId ON [value_tab_MedicalProvider_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO value_tab_MedicalProvider_Helper
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
		CONVERT(VARCHAR(50), V.namesid) AS ProviderNamesId
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
	WHERE vc.code IN ('MEDICAL')
GO
---(0)---
DBCC DBREINDEX ('value_tab_MedicalProvider_Helper', ' ', 90) WITH NO_INFOMSGS
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

UPDATE value_tab_MedicalProvider_Helper
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

UPDATE value_tab_MedicalProvider_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


---(1)---
INSERT INTO [sma_TRN_Hospitals]
	(
	[hosnCaseID]
   ,[hosnContactID]
   ,[hosnContactCtg]
   ,[hosnAddressID]
   ,[hossMedProType]
   ,[hosdStartDt]
   ,[hosdEndDt]
   ,[hosnPlaintiffID]
   ,[hosnComments]
   ,[hosnHospitalChart]
   ,[hosnRecUserID]
   ,[hosdDtCreated]
   ,[hosnModifyUserID]
   ,[hosdDtModified]
   ,[saga]
	)
	SELECT
		A.casnCaseID  AS [hosnCaseID]
	   ,A.ProviderCID AS [hosnContactID]
	   ,A.ProviderCTG AS [hosnContactCtg]
	   ,A.ProviderAID AS [hosnAddressID]
	   ,'M'			  AS [hossMedProType]
	   ,NULL		  AS [hosdStartDt]
	   ,NULL		  AS [hosdEndDt]
	   ,A.PlaintiffID AS hosnPlaintiffID
	   ,NULL		  AS [hosnComments]
	   ,NULL		  AS [hosnHospitalChart]
	   ,368			  AS [hosnRecUserID]
	   ,GETDATE()	  AS [hosdDtCreated]
	   ,NULL		  AS [hosnModifyUserID]
	   ,NULL		  AS [hosdDtModified]
	   ,'value'		  AS [saga]
	FROM (
		SELECT -- (Note: make sure no duplicate provider per case )
			ROW_NUMBER() OVER (PARTITION BY MAP.ProviderCID, MAP.ProviderCTG, MAP.casnCaseID, MAP.PlaintiffID ORDER BY V.id) AS RowNumber
		   ,MAP.PlaintiffID
		   ,MAP.casnCaseID
		   ,MAP.ProviderCID
		   ,MAP.ProviderCTG
		   ,MAP.ProviderAID
		FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
		INNER JOIN value_tab_MedicalProvider_Helper MAP
			ON MAP.case_id = CONVERT(VARCHAR(50), V.casesid)
			AND MAP.value_id = CONVERT(VARCHAR(50), V.id)
	) A
	WHERE A.RowNumber = 1 ---Note: No merging. got to be the first script to populate Medical Provider
GO

---(2)--- (Medical Provider Bill section)
INSERT INTO [sma_TRN_SpDamages]
	(
	[spdsRefTable]
   ,[spdnRecordID]
   ,[spdnBillAmt]
   ,[spddNegotiatedBillAmt]
   ,[spddDateFrom]
   ,[spddDateTo]
   ,[spddDamageSubType]
   ,[spdnVisitId]
   ,[spdsComments]
   ,[spdnRecUserID]
   ,[spddDtCreated]
   ,[spdnModifyUserID]
   ,[spddDtModified]
   ,[spdnBalance]
   ,[spdbLienConfirmed]
   ,[spdbDocAttached]
   ,[saga_bill_id]
	)
	SELECT
		'Hospitals'														 AS spdsRefTable
	   ,H.hosnHospitalID												 AS spdnRecordID
	   ,V.total_value													 AS spdnBillAmt
	   ,(V.total_value - V.reduction)									 AS spddNegotiatedBillAmt
	   ,CASE
			WHEN V.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN CONVERT(DATE, V.[start_date])
			ELSE NULL
		END																 
		AS spddDateFrom
	   ,CASE
			WHEN V.[stop_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN CONVERT(DATE, V.[stop_date])
			ELSE NULL
		END																 
		AS spddDateTo
	   ,NULL															 AS spddDamageSubType
	   ,NULL															 AS spdnVisitId
	   ,ISNULL('value tab medical bill. memo - ' + NULLIF(memo, ''), '') AS spdsComments
	   ,368																 AS spdnRecordID
	   ,GETDATE()														 AS spddDtCreated
	   ,NULL															 AS spdnModifyUserID
	   ,NULL															 AS spddDtModified
	   ,V.due															 AS spdnBalance
	   ,0																 AS spdbLienConfirmed
	   ,0																 AS spdbDocAttached
	   ,V.id															 AS saga_bill_id  -- one bill one value
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN value_tab_MedicalProvider_Helper MAP
		ON MAP.case_id = CONVERT(VARCHAR(50), V.casesid)
			AND MAP.value_id = CONVERT(VARCHAR(50), V.id)
	JOIN [sma_TRN_Hospitals] H
		ON H.hosnContactID = MAP.ProviderCID
			AND H.hosnContactCtg = MAP.ProviderCTG
			AND H.hosnCaseID = MAP.casnCaseID
			AND H.hosnPlaintiffID = MAP.PlaintiffID
GO

---(3)--- (Amount Paid section)  --Type=Client--
INSERT INTO [sma_TRN_SpecialDamageAmountPaid]
	(
	[AmountPaidDamageReferenceID]
   ,[AmountPaidCollateralType]
   ,[AmountPaidPaidByID]
   ,[AmountPaidTotal]
   ,[AmountPaidClaimSubmittedDt]
   ,[AmountPaidDate]
   ,[AmountPaidRecUserID]
   ,[AmountPaidDtCreated]
   ,[AmountPaidModifyUserID]
   ,[AmountPaidDtModified]
   ,[AmountPaidLevelNo]
   ,[AmountPaidAdjustment]
   ,[AmountPaidComments]
	)
	SELECT
		SPD.spdnSpDamageID AS [AmountPaidDamageReferenceID]
	   ,(
			SELECT
				cltnCollateralTypeID
			FROM [dbo].[sma_MST_CollateralType]
			WHERE cltsDscrptn = 'Client'
		)				   
		AS [AmountPaidCollateralType]
	   ,NULL			   AS [AmountPaidPaidByID]
	   ,VP.payment_amount  AS [AmountPaidTotal]
	   ,NULL			   AS [AmountPaidClaimSubmittedDt]
	   ,CASE
			WHEN VP.date_paid BETWEEN '1900-01-01' AND '2079-06-06'
				THEN VP.date_paid
			ELSE NULL
		END				   AS [AmountPaidDate]
	   ,368				   AS [AmountPaidRecUserID]
	   ,GETDATE()		   AS [AmountPaidDtCreated]
	   ,NULL			   AS [AmountPaidModifyUserID]
	   ,NULL			   AS [AmountPaidDtModified]
	   ,NULL			   AS [AmountPaidLevelNo]
	   ,NULL			   AS [AmountPaidAdjustment]
	   ,ISNULL('paid by:' + NULLIF(payBy.[name], '') + CHAR(13), '') +
		ISNULL('paid to:' + NULLIF(payTo.[Name], '') + CHAR(13), '') +
		''				   AS [AmountPaidComments]
	FROM [BrianWhiteNeos]..[value_Indexed] V
	JOIN value_tab_MedicalProvider_Helper MAP
		ON MAP.case_id = CONVERT(VARCHAR(50), V.casesid)
			AND MAP.value_id = CONVERT(VARCHAR(50), V.id)
	JOIN [sma_TRN_SpDamages] SPD
		ON SPD.saga_bill_id = CONVERT(VARCHAR(50), V.id)
	JOIN [BrianWhiteNeos]..[value_payment] VP
		ON VP.valueid = v.id -- multiple payment per value_id
	LEFT JOIN IndvOrgContacts_Indexed payBy
		ON payby.SAGA_ref = CONVERT(VARCHAR(50), vp.paidbyID)
	LEFT JOIN IndvOrgContacts_Indexed payTo
		ON payTo.SAGA_ref = CONVERT(VARCHAR(50), vp.paidToID)
GO


---(Appendix)--- Update hospital TotalBill from Bill section
UPDATE [sma_TRN_Hospitals]
SET hosnTotalBill = (
	SELECT
		SUM(spdnBillAmt)
	FROM sma_TRN_SpDamages
	WHERE sma_TRN_SpDamages.spdsRefTable = 'Hospitals'
		AND sma_TRN_SpDamages.spdnRecordID = hosnHospitalID
)
GO

-----------
ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_SpecialDamageAmountPaid] ENABLE TRIGGER ALL
GO
-----------
