USE BrianWhiteSANeos
GO

/*
alter table [sma_TRN_Lienors] disable trigger all
delete from [sma_TRN_Lienors] 
DBCC CHECKIDENT ('[sma_TRN_Lienors]', RESEED, 0);
alter table [sma_TRN_Lienors] enable trigger all

alter table [sma_TRN_LienDetails] disable trigger all
delete from [sma_TRN_LienDetails] 
DBCC CHECKIDENT ('[sma_TRN_LienDetails]', RESEED, 0);
alter table [sma_TRN_LienDetails] enable trigger all


alter table [sma_TRN_Lienors] disable trigger all

alter table [sma_TRN_LienDetails] disable trigger all
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Lienors')
	)
BEGIN
	ALTER TABLE [sma_TRN_Lienors] ADD [saga] VARCHAR(50) NULL;
END

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Liencheckbox_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Liencheckbox_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Liencheckbox_Helper (
	TableIndex INT IDENTITY (1, 1) NOT NULL
   ,value_id VARCHAR(50)
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Liencheckbox_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Liencheckbox_Helper_value_id ON [value_tab_Liencheckbox_Helper] (value_id);
GO

---(0)---
INSERT INTO value_tab_Liencheckbox_Helper
	(
	value_id
	)
	SELECT
		VP1.id
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] VP1
	LEFT JOIN (
		SELECT DISTINCT
			id
		FROM [BrianWhiteNeos]..[value_Indexed]
		WHERE lien = 1
	) VP2
		ON VP1.id = VP2.id
			AND VP2.id IS NOT NULL
	WHERE VP2.id IS NOT NULL -- ( Lien checkbox got marked ) 
GO

---(0)---
DBCC DBREINDEX ('value_tab_Liencheckbox_Helper', ' ', 90) WITH NO_INFOMSGS
GO


---(0)---
INSERT INTO [sma_MST_LienType]
	(
	[lntsCode]
   ,[lntsDscrptn]
	)
	(
	SELECT DISTINCT
		'CONVERSION'
	   ,VC.[description]
	FROM [BrianWhiteNeos].[dbo].[value] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON VC.id = V.valuecodeid
	WHERE ISNULL(Vc.code, '') IN ('OAG')
	)
	EXCEPT
	SELECT
		[lntsCode]
	   ,[lntsDscrptn]
	FROM [sma_MST_LienType]
GO


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Lien_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Lien_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Lien_Helper (
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
   ,Paid VARCHAR(20)
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Lien_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_case_id ON [dbo].[value_tab_Lien_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_value_id ON [dbo].[value_tab_Lien_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Lien_Helper_ProviderNameId ON [dbo].[value_tab_Lien_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO value_tab_Lien_Helper
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
   ,Paid
	)
	SELECT
		CONVERT(VARCHAR(50), V.casesid) AS case_id
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
	   ,NULL							AS Paid
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON VC.id = V.valuecodeid
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), V.Namesid)
	WHERE code IN ('OAG')
		OR V.id IN (
			SELECT
				value_id
			FROM value_tab_Liencheckbox_Helper
		)
GO

---(0)---
DBCC DBREINDEX ('value_tab_Lien_Helper', ' ', 90) WITH NO_INFOMSGS
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
   ,CONVERT(VARCHAR, ((
		SELECT
			SUM(payment_amount)
		FROM [BrianWhiteNeos].[dbo].[value_payment]
		WHERE id = V.id
	)
	))		  AS Paid
   ,T.plnnPlaintiffID INTO value_tab_Multi_Party_Helper_Temp
FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
JOIN [BrianWhiteNeos].[dbo].[value_code] VC
	ON VC.id = V.valuecodeid
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Plaintiff] t
	ON t.plnnCaseID = CAS.casnCaseID
		AND t.saga_party = v.partyid
--JOIN [BrianWhiteNeos].[dbo].Party_Indexed pt on pt.id = v.partyid and pt.casesid = v.casesid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = convert(varchar(50),pt.namesid)
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Lien_Helper
SET PlaintiffID = A.plnnPlaintiffID
   ,Paid = A.Paid
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
   ,CONVERT(VARCHAR, ((
		SELECT
			SUM(payment_amount)
		FROM [BrianWhiteNeos].[dbo].[value_payment]
		WHERE id = V.id
	)
	))		  AS Paid
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
	ON VC.id = V.valuecodeid
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Defendants] d
	ON d.defnCaseID = cas.casncaseid
		AND d.saga_party = v.partyid
--JOIN [BrianWhiteNeos].[dbo].Party_Indexed pt on pt.id = v.partyid and pt.casesid = v.casesid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_REF = convert(varchar(50),pt.namesid)
--JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Lien_Helper
SET PlaintiffID = A.plnnPlaintiffID
   ,Paid = A.Paid
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO

---------------------------------------------------------------------------------------
ALTER TABLE [sma_TRN_Lienors] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LienDetails] DISABLE TRIGGER ALL
GO
---(1)---
INSERT INTO [sma_TRN_Lienors]
	(
	[lnrnCaseID]
   ,[lnrnLienorTypeID]
   ,[lnrnLienorContactCtgID]
   ,[lnrnLienorContactID]
   ,[lnrnLienorAddressID]
   ,[lnrnLienorRelaContactID]
   ,[lnrnPlaintiffID]
   ,[lnrnCnfrmdLienAmount]
   ,[lnrnNegLienAmount]
   ,[lnrsComments]
   ,[lnrnRecUserID]
   ,[lnrdDtCreated]
   ,[lnrnFinal]
   ,[saga]
	)
	SELECT
		MAP.casnCaseID			 AS [lnrnCaseID]
	   ,(
			SELECT TOP 1
				lntnLienTypeID
			FROM [sma_MST_LienType]
			WHERE lntsDscrptn = (
					SELECT
						[description]
					FROM BrianWhiteNeos..[value_code]
					WHERE [code] = vc.code
				)
		)						 
		AS [lnrnLienorTypeID]
	   ,MAP.ProviderCTG			 AS [lnrnLienorContactCtgID]
	   ,MAP.ProviderCID			 AS [lnrnLienorContactID]
	   ,MAP.ProviderAID			 AS [lnrnLienorAddressID]
	   ,0						 AS [lnrnLienorRelaContactID]
	   ,MAP.PlaintiffID			 AS [lnrnPlaintiffID]
	   ,ISNULL(V.total_value, 0) AS [lnrnCnfrmdLienAmount]
	   ,ISNULL(V.due, 0)		 AS [lnrnNegLienAmount]
	   ,ISNULL('Memo : ' + ISNULL(V.memo, '') + CHAR(13), '') +
		ISNULL('From : ' + CONVERT(VARCHAR(10), V.start_date) + CHAR(13), '') +
		ISNULL('To : ' + CONVERT(VARCHAR(10), V.stop_date) + CHAR(13), '') +
		ISNULL('Value Total : ' + CONVERT(VARCHAR, V.total_value) + CHAR(13), '') +
		ISNULL('Reduction : ' + CONVERT(VARCHAR, V.reduction) + CHAR(13), '') +
		ISNULL('Paid : ' + MAP.Paid, '')
		AS [lnrsComments]
	   ,368						 AS [lnrnRecUserID]
	   ,GETDATE()				 AS [lnrdDtCreated]
	   ,0						 AS [lnrnFinal]
	   ,V.id					 AS [saga]
	FROM [BrianWhiteNeos].[dbo].[value_Indexed] V
	JOIN [BrianWhiteNeos].[dbo].[value_code] VC
		ON VC.id = V.valuecodeid
	JOIN [value_tab_Lien_Helper] MAP
		ON MAP.case_id = V.casesid
			AND MAP.value_id = V.id
GO

---(2)---
INSERT INTO [sma_TRN_LienDetails]
	(
	lndnLienorID
   ,lndnLienTypeID
   ,lndnCnfrmdLienAmount
   ,lndsRefTable
   ,lndnRecUserID
   ,lnddDtCreated
	)
	SELECT
		lnrnLienorID		 AS lndnLienorID
	   ,lnrnLienorTypeID	 AS lndnLienTypeID
	   ,lnrnCnfrmdLienAmount AS lndnCnfrmdLienAmount
	   ,'sma_TRN_Lienors'	 AS lndsRefTable
	   ,368					 AS lndnRecUserID
	   ,GETDATE()			 AS lnddDtCreated
	FROM [sma_TRN_Lienors]
GO

----
ALTER TABLE [sma_TRN_Lienors] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LienDetails] ENABLE TRIGGER ALL
GO






