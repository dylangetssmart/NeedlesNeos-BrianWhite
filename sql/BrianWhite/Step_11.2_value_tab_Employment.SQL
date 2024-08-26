
USE BrianWhiteSA
GO

/*
alter table [dbo].[sma_TRN_Employment] disable trigger all
delete [dbo].[sma_TRN_Employment]
DBCC CHECKIDENT ('[dbo].[sma_TRN_Employment]', RESEED, 0);
alter table [dbo].[sma_TRN_Employment] enable trigger all

alter table [dbo].[sma_TRN_LostWages] disable trigger all
delete [dbo].[sma_TRN_LostWages]
DBCC CHECKIDENT ('[dbo].[sma_TRN_LostWages]', RESEED, 0);
alter table [dbo].[sma_TRN_LostWages] enable trigger all

delete from sma_TRN_SpDamages where spdsreftable='LostWages'
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Employment')
	)
BEGIN
	ALTER TABLE [sma_TRN_Employment]
	ADD [saga] VARCHAR(50) NULL;
END
GO

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'value_tab_Employment_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE value_tab_Employment_Helper
END
GO

---(0)---
CREATE TABLE value_tab_Employment_Helper (
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
   ,CONSTRAINT IOC_Clustered_Index_value_tab_Employment_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_case_id ON BrianWhiteSA.[dbo].[value_tab_Employment_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_value_id ON BrianWhiteSA.[dbo].[value_tab_Employment_Helper] (value_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_ProviderNameId ON BrianWhiteSA.[dbo].[value_tab_Employment_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO value_tab_Employment_Helper
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
		V.casesid	   AS case_id
	   ,	-- needles case
		V.id		   AS value_id
	   ,		-- needles records TAB item
		V.namesid	   AS ProviderNameId
	   ,IOC.Name	   AS ProviderName
	   ,IOC.CID		   AS ProviderCID
	   ,IOC.CTG		   AS ProviderCTG
	   ,IOC.AID		   AS ProviderAID
	   ,CAS.casnCaseID AS casnCaseID
	   ,NULL		   AS PlaintiffID
	--select *
	FROM [BrianWhiteNeos]..[value_Indexed] V
	JOIN [BrianWhiteNeos]..[value_code] vc
		ON vc.id = v.valuecodeid
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), V.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON ioc.SAGA_ref = CONVERT(VARCHAR(50), v.namesid) --and isnull(convert(varchar(50),v.namesid),'')<>''
	WHERE vc.code IN ('LOSTWAGE')
GO

---(0)---
DBCC DBREINDEX ('value_tab_Employment_Helper', ' ', 90) WITH NO_INFOMSGS
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
--SELECT *
FROM BrianWhiteNeos..[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Plaintiff] t
	ON t.plnnCaseID = CAS.casnCaseID
		AND t.saga_party = v.partyid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = convert(varchar(50),V.partyid)
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Employment_Helper
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
--SELECT *
FROM BrianWhiteNeos.[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), V.casesid)
JOIN [sma_TRN_Defendants] d
	ON d.defnCaseID = cas.casncaseid
		AND d.saga_party = v.partyid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = V.party_id
--JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

UPDATE value_tab_Employment_Helper
SET PlaintiffID = A.plnnPlaintiffID
FROM value_tab_Multi_Party_Helper_Temp A
WHERE case_id = A.cid
AND value_id = A.vid
GO


---(1)---
INSERT INTO [dbo].[sma_TRN_Employment]
	(
	empnPlaintiffID
   ,empnEmprAddressID
   ,empnEmployerID
   ,empnEmpUnion
   ,empsJobTitle
   ,empsCompensationComments
   ,empnAverageWeeklyWage
   ,empnSalaryAmt
   ,empbOnTheJob
   ,empbWCClaim
   ,empdDateHired
   ,empsComments
   ,saga
	)

	SELECT  --MAP.case_id,
		MAP.PlaintiffID AS empnPlaintiffID
	   ,MAP.ProviderAID AS empnEmprAddressID
	   ,MAP.ProviderCID AS empnEmployerID
	   ,NULL			AS empnEmpUnion
	   ,NULL			AS empsJobTitle
	   ,V.memo			AS empsCompensationComments
	   ,NULL			AS empnAverageWeeklyWage
	   ,NULL			AS empnSalaryAmt
	   ,NULL			AS empbOnTheJob
	   ,NULL			AS empbWCClaim
	   ,NULL			AS empdDateHired
	   ,NULL			AS empsComments
	   ,v.id			AS saga
	--select *
	FROM [BrianWhiteNeos]..[value_Indexed] V
	JOIN value_tab_Employment_Helper MAP
		ON MAP.case_id = V.casesid
			AND MAP.value_id = V.id

---(2)---
INSERT INTO [sma_TRN_LostWages]
	(
	[ltwnEmploymentID]
   ,[ltwsType]
   ,[ltwdFrmDt]
   ,[ltwdToDt]
   ,[ltwnAmount]
   ,[ltwnAmtPaid]
   ,[ltwnLoss]
   ,[ltwdMDConfReqDt]
   ,[ltwdMDConfDt]
   ,[ltwdEmpVerfReqDt]
   ,[ltwdEmpVerfRcvdDt]
   ,[ltwnRecUserID]
   ,[ltwdDtCreated]
   ,[ltwnModifyUserID]
   ,[ltwdDtModified]
   ,[ltwnLevelNo]
	)
	SELECT
		EM.empnEmploymentID AS [ltwnEmploymentID]
	   ,(
			SELECT
				wgtnWagesTypeID
			FROM [dbo].[sma_MST_WagesTypes]
			WHERE wgtsDscrptn = 'Salary'
		)					
		AS [ltwsType]
	   ,CASE
			WHEN v.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN v.[start_date]
			ELSE NULL
		END					AS [ltwdFrmDt]
	   ,CASE
			WHEN v.[stop_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN v.[stop_date]
			ELSE NULL
		END					AS [ltwdToDt]
	   ,NULL				AS [ltwnAmount]
	   ,NULL				AS [ltwnAmtPaid]
	   ,V.total_value		AS [ltwnLoss]
	   ,NULL				AS [ltwdMDConfReqDt]
	   ,NULL				AS [ltwdMDConfDt]
	   ,NULL				AS [ltwdEmpVerfReqDt]
	   ,NULL				AS [ltwdEmpVerfRcvdDt]
	   ,368					AS [ltwnRecUserID]
	   ,GETDATE()			AS [ltwdDtCreated]
	   ,NULL				AS [ltwnModifyUserID]
	   ,NULL				AS [ltwdDtModified]
	   ,NULL				AS [ltwnLevelNo]
	FROM [BrianWhiteNeos]..[value_Indexed] V
	JOIN [sma_TRN_Employment] EM
		ON EM.saga = CONVERT(VARCHAR(50), v.id)
GO


INSERT INTO [sma_TRN_SpDamages]
	(
	spdsRefTable
   ,spdnRecordID
   ,spdnRecUserID
   ,spddDtCreated
   ,spdnLevelNo
   ,spdnBillAmt
   ,spddDateFrom
   ,spddDateTo
	)
	SELECT DISTINCT
		'LostWages'		AS spdsRefTable
	   ,ltwnLostWagesID AS spdnRecordID
	   ,368				AS spdnRecUserID
	   ,GETDATE()		AS spddDtCreated
	   ,0				AS spdnLevelNo
	   ,ltwnLoss		AS spdnBillAmt
	   ,ltwdFrmDt		AS spddDateFrom
	   ,ltwdToDt		AS spddDateTo
	FROM sma_TRN_LostWages
GO

