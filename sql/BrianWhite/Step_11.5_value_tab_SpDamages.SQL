USE BrianWhiteSANeos
GO

----------------------------------------------------------------------------
--CUSTOM DAMAGE
----------------------------------------------------------------------------
--delete From [sma_TRN_SpDamages] where spdsRefTable = 'CustomDamage'
--INSERT DAMAGE SUBTYPE (UNDER "OTHER" DAMAGE TYPE)
IF (
		SELECT
			COUNT(*)
		FROM sma_MST_SpecialDamageType
		WHERE SpDamageTypeDescription = 'Other'
	)
	= 0
BEGIN
	INSERT INTO sma_MST_SpecialDamageType
		(
		SpDamageTypeDescription
	   ,IsEditableType
	   ,SpDamageTypeCreatedUserID
	   ,SpDamageTypeDtCreated
		)
		SELECT
			'Other'
		   ,1
		   ,368
		   ,GETDATE()
END

INSERT INTO sma_MST_SpecialDamageSubType
	(
	spdamagetypeid
   ,SpDamageSubTypeDescription
	) --, SpDamageSubTypeDtCreated, SpDamageSubTypeCreatedUserID)
	SELECT
		(
			SELECT
				spdamagetypeid
			FROM sma_MST_SpecialDamageType
			WHERE SpDamageTypeDescription = 'Other'
		)
	   ,vc.[description]--, getdate(), 368
	FROM BrianWhiteNeos..value_code vc
	WHERE code IN ('PROP DAM')
	EXCEPT
	SELECT
		spdamagetypeid
	   ,SpDamageSubTypeDescription
	FROM sma_MST_SpecialDamageSubType

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_spDamages_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_spDamages_Helper
END
GO

---(0)---
CREATE TABLE value_tab_spDamages_Helper (
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
   ,CONSTRAINT IOC_Clustered_Index_value_tab_spDamages_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_case_id ON [value_tab_spDamages_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_value_id ON [value_tab_spDamages_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_spDamages_Helper_ProviderNameId ON [value_tab_spDamages_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO [value_tab_spDamages_Helper]
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
		CONVERT(VARCHAR(50), v.casesid) AS case_id
	   ,	-- needles case
		CONVERT(VARCHAR(50), V.id)		AS tab_id
	   ,		-- needles records TAB item
		CONVERT(VARCHAR(50), V.namesid) AS ProviderNameId
	   ,IOC.[Name]						AS ProviderName
	   ,IOC.CID							AS ProviderCID
	   ,IOC.CTG							AS ProviderCTG
	   ,IOC.AID							AS ProviderAID
	   ,CAS.casnCaseID					AS casnCaseID
	   ,NULL							AS PlaintiffID
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), V.namesid)
	WHERE code IN ('PROP DAM')

---(0)---
DBCC DBREINDEX ('value_tab_spDamages_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)---
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
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Plaintiff] t
	ON t.plnnCaseID = CAS.casnCaseID
		AND t.saga_party = v.partyid

--JOIN [BrianWhiteNeos].[dbo].[Party_Indexed] pt on pt.id = v.partyid  and v.casesid = pt.casesid
--JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),pt.namesid)
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

UPDATE [value_tab_spDamages_Helper]
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
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Defendants] d
	ON d.defnCaseID = cas.casncaseid
		AND d.saga_party = v.partyid

--JOIN [BrianWhiteNeos].[dbo].[Party_Indexed] pt on pt.id = convert(varchar(50),v.partyid) and v.casesid = pt.casesid
--JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(Varchar(50),pt.namesid)
--JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_spDamages_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


ALTER TABLE [sma_TRN_SpDamages] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_SpDamages]
	(
	spdsRefTable
   ,spdnRecordID
   ,spddCaseID
   ,spddPlaintiff
   ,spddDamageType
   ,spddDamageSubType
   ,spdnRecUserID
   ,spddDtCreated
   ,spdnLevelNo
   ,spdnBillAmt
   ,spddDateFrom
   ,spddDateTo
   ,spdsComments
	)
	SELECT DISTINCT
		'CustomDamage'										  AS spdsRefTable
	   ,NULL												  AS spdnRecordID
	   ,sdh.casnCaseID										  AS spddCaseID
	   ,sdh.PlaintiffID										  AS spddPlaintiff
	   ,(
			SELECT
				spdamagetypeid
			FROM sma_MST_SpecialDamageType
			WHERE SpDamageTypeDescription = 'Other'
		)													  
		AS spddDamageType
	   ,(
			SELECT
				SpDamageSubTypeID
			FROM sma_MST_SpecialDamageSubType
			WHERE SpDamageSubTypeDescription = vc.[description]
				AND spdamagetypeid = (
					SELECT
						spdamagetypeid
					FROM sma_MST_SpecialDamageType
					WHERE SpDamageTypeDescription = 'Other'
				)
		)													  
		AS spddDamageSubType
	   ,368													  AS spdnRecUserID
	   ,GETDATE()											  AS spddDtCreated
	   ,0													  AS spdnLevelNo
	   ,v.total_value										  AS spdnBillAmt
	   ,CASE
			WHEN v.[start_date] BETWEEN '1900-01-01' AND '2079-06-01'
				THEN v.[start_date]
			ELSE NULL
		END													  AS spddDateFrom
	   ,CASE
			WHEN v.stop_date BETWEEN '1900-01-01' AND '2079-06-01'
				THEN v.stop_date
			ELSE NULL
		END													  AS spddDateTo
	   ,'Provider: ' + SDH.[ProviderName] + CHAR(13) + v.memo AS spdsComments
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON v.valuecodeid = vc.id
	JOIN [value_tab_spDamages_Helper] SDH
		ON CONVERT(VARCHAR(50), v.id) = sdh.value_id
	WHERE vc.code IN ('PROP DAM')
GO

ALTER TABLE [sma_TRN_SpDamages] ENABLE TRIGGER ALL
GO
