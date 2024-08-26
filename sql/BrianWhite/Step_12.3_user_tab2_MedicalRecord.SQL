USE BrianWhiteSANeos
GO

/*
alter table [sma_TRN_Hospitals] disable trigger all
delete [sma_TRN_Hospitals]
DBCC CHECKIDENT ('[sma_TRN_Hospitals]', RESEED, 0);
alter table [sma_TRN_Hospitals] enable trigger all

select distinct g.*
from BrianWhiteNeos..neosUsertab2 u
LEFT JOIN BrianWhiteNeos..mini_general_dir g on g.id = u.[Type of Record]
where isnull(g.code,'') IN ('', 'Medical Records w/Affidavit','Billing Records w/Affidavit','Medical Record and Bill w/Affidavit',
	'Record and Bill','Medical Record','Medical Record and Bill','Billing','Medical Bill','MRI Reports w/Affidavit','Authorization Request',
	'MRI Billing Records w/Affidavit' )
*/

------------------------------------
--ADD SAGA BILL ID TO SP DAMAGES
------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_bill_id'
			AND Object_ID = OBJECT_ID(N'sma_TRN_SpDamages')
	)
BEGIN
	ALTER TABLE [sma_TRN_SpDamages]
	ADD [saga_bill_id] [VARCHAR](50) NULL;
END
GO
/*
------------------------------------
--ADD SAGA TO VISITS
------------------------------------
IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Visits'))
BEGIN
    ALTER TABLE [sma_TRN_Visits] 
	ADD [saga] [varchar](50) NULL; 
END
GO
*/
------------------------------------
--ADD SAGA TO HOSPITALS TABLE
------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Hospitals')
	)
BEGIN
	ALTER TABLE [sma_TRN_Hospitals]
	ADD [saga] [VARCHAR](50) NULL;
END

------------------------------------
--ADD SAGA TO MEDICAL REQUESTS TABLE
------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_trn_MedicalProviderRequest')
	)
BEGIN
	ALTER TABLE [sma_trn_MedicalProviderRequest]
	ADD [saga] [VARCHAR](50) NULL;
END

------------------------------------
--RECORD REQUEST TYPES
------------------------------------
INSERT INTO sma_MST_Request_RecordTypes
	(
	RecordType
	)
	(SELECT DISTINCT
		ISNULL(g.code, 'Other')
	FROM BrianWhiteNeos..neosUsertab2 u
	LEFT JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Type of Record]
	WHERE ISNULL(g.code, '') IN ('', 'Medical Records w/Affidavit', 'Billing Records w/Affidavit', 'Medical Record and Bill w/Affidavit',
		'Record and Bill', 'Medical Record', 'Medical Record and Bill', 'Billing', 'Medical Bill', 'MRI Reports w/Affidavit', 'Authorization Request',
		'MRI Billing Records w/Affidavit')
	)
	EXCEPT
	SELECT
		RecordType
	FROM sma_MST_Request_RecordTypes
GO
------------------------------------
--REQUEST STATUS
------------------------------------
INSERT INTO sma_MST_RequestStatus
	(
	Status
   ,Description
	)
	SELECT
		'No Record Available'
	   ,'No Record Available'
	EXCEPT
	SELECT
		Status
	   ,Description
	FROM sma_MST_RequestStatus
GO

------------------------------------
--MEDICAL PROVIDER HELPER
------------------------------------
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'user_tab2_MedicalProvider_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE user_tab2_MedicalProvider_Helper
END
GO

---(0)---
CREATE TABLE user_tab2_MedicalProvider_Helper (
	TableIndex [INT] IDENTITY (1, 1) NOT NULL
   ,case_id VARCHAR(50)
   ,tab_id VARCHAR(50)
   ,ProviderNameId VARCHAR(50)
   ,ProviderName VARCHAR(200)
   ,ProviderCID INT
   ,ProviderCTG INT
   ,ProviderAID INT
   ,
	--CounselOrderingCID		int,
	--CounselOrderingCTG		int,
	--CounselOrderingAID		int,
	casnCaseID INT
   ,CONSTRAINT IOC_Clustered_Index_user_tab2_MedicalProvider_Helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_case_id ON [user_tab2_MedicalProvider_Helper] (case_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_tab_id ON [user_tab2_MedicalProvider_Helper] (tab_id);
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_user_tab2_MedicalProvider_Helper_ProviderNameId ON [user_tab2_MedicalProvider_Helper] (ProviderNameId);
GO

---(0)---
INSERT INTO user_tab2_MedicalProvider_Helper
	(
	case_id
   ,tab_id
   ,ProviderNameId
   ,ProviderName
   ,ProviderCID
   ,ProviderCTG
   ,ProviderAID
   ,casnCaseID
	)
	SELECT
		u.CasesID		  AS case_id
	   ,u.tablistid		  AS tab_id
	   ,		--NEEDLES RECORDS TAB ITEM
		u.[Provider Name] AS ProviderNameId
	   ,IOC.[Name]		  AS ProviderName
	   ,IOC.CID			  AS ProviderCID
	   ,IOC.CTG			  AS ProviderCTG
	   ,IOC.AID			  AS ProviderAID
	   ,CAS.casnCaseID	  AS casnCaseID
	FROM BrianWhiteNeos..neosUsertab2 u
	LEFT JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Type of Record]
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), u.[Provider Name])
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = u.casesid
	WHERE ISNULL(g.code, '') IN ('', 'Medical Records w/Affidavit', 'Billing Records w/Affidavit', 'Medical Record and Bill w/Affidavit',
		'Record and Bill', 'Medical Record', 'Medical Record and Bill', 'Billing', 'Medical Bill', 'MRI Reports w/Affidavit', 'Authorization Request',
		'MRI Billing Records w/Affidavit')
GO

---(0)---
DBCC DBREINDEX ('user_tab2_MedicalProvider_Helper', ' ', 90) WITH NO_INFOMSGS
GO

---
ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_trn_MedicalProviderRequest] DISABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] disable trigger all
--GO
--alter table [sma_TRN_Visits] disable trigger all
--GO

--------------------------------------------------------------------------
---------------------------- MEDICAL PROVIDERS ---------------------------
--------------------------------------------------------------------------
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
	SELECT DISTINCT
		casnCaseID  AS [hosnCaseID]
	   ,ProviderCID AS [hosnContactID]
	   ,ProviderCTG AS [hosnContactCtg]
	   ,ProviderAID AS [hosnAddressID]
	   ,'M'			AS [hossMedProType]
	   ,			--M or P (P for Prior Medical Provider)
		NULL		AS [hosdStartDt]
	   ,NULL		AS [hosdEndDt]
	   ,(
			SELECT
				plnnPlaintiffID
			FROM [sma_TRN_Plaintiff]
			WHERE plnnCaseID = casnCaseID
				AND plnbIsPrimary = 1
		)			
		AS hosnPlaintiffID
	   ,''			AS [hosnComments]
	   ,NULL		AS [hosnHospitalChart]
	   ,368			AS [hosnRecUserID]
	   ,GETDATE()   AS [hosdDtCreated]
	   ,NULL		AS [hosnModifyUserID]
	   ,NULL		AS [hosdDtModified]
	   ,'tab2'		AS [saga]
	--'tab2:'+convert(varchar,UD.tab_id)	as [saga]
	FROM BrianWhiteNeos..neosUsertab2 d
	JOIN user_tab2_MedicalProvider_Helper MAP
		ON MAP.case_id = CONVERT(VARCHAR(50), D.casesid)
			AND MAP.tab_id = CONVERT(VARCHAR(50), D.tablistid)
	LEFT JOIN [sma_TRN_Hospitals] H
		ON H.hosnCaseID = MAP.casnCaseID
			AND H.hosnContactID = MAP.ProviderCID
			AND H.hosnContactCtg = MAP.ProviderCTG
			AND H.hosnAddressID = MAP.ProviderAID
	WHERE H.hosnHospitalID IS NULL	--only add the hospital if it does not already exist
GO

--------------------------------------------------------------------------
---------------------------- MEDICAL REQUESTS ----------------------------
--------------------------------------------------------------------------
INSERT INTO [sma_trn_MedicalProviderRequest]
	(
	MedPrvCaseID
   ,MedPrvPlaintiffID
   ,MedPrvhosnHospitalID
   ,MedPrvRecordType
   ,MedPrvRequestdate
   ,MedPrvAssignee
   ,MedPrvAssignedBy
   ,MedPrvHighPriority
   ,MedPrvFromDate
   ,MedPrvToDate
   ,MedPrvComments
   ,MedPrvNotes
   ,MedPrvCompleteDate
   ,MedPrvStatusId
   ,MedPrvFollowUpDate
   ,MedPrvStatusDate
   ,OrderAffidavit
   ,FollowUpNotes
   ,		--Retrieval Provider Notes
	SAGA
	)
	SELECT
		hosnCaseID									  AS MedPrvCaseID
	   ,hosnPlaintiffID								  AS MedPrvPlaintiffID
	   ,H.hosnHospitalID							  AS MedPrvhosnHospitalID
	   ,(
			SELECT
				uId
			FROM sma_MST_Request_RecordTypes
			WHERE RecordType = ISNULL(g.code, 'Other')
		)											  
		AS MedPrvRecordType
	   ,CASE
			WHEN (UD.[Date Requested] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN UD.[Date Requested]
			ELSE NULL
		END											  AS MedPrvRequestdate
	   ,NULL										  AS MedPrvAssignee
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users u
			JOIN sma_MST_IndvContacts i
				ON u.usrnContactID = i.cinnContactID
			WHERE i.cinsGrade = ud.[Ordered By]
		)											  
		AS MedPrvAssignedBy
	   ,0											  AS MedPrvHighPriority
	   ,		--1=high priority; 0=Normal
		NULL										  AS MedPrvFromDate
	   ,NULL										  AS MedPrvToDate
	   ,ISNULL('PrePayment Required: ' + NULLIF(CONVERT(VARCHAR, UD.[pre-payment required]), '') + CHAR(13), '') +
		ISNULL('Method: ' + NULLIF(CONVERT(VARCHAR, me.code), '') + CHAR(13), '') +
		ISNULL('Value Code: ' + NULLIF(CONVERT(VARCHAR, vc.[Description]), '') + CHAR(13), '') +
		ISNULL('Alternate Provider: ' + NULLIF(CONVERT(VARCHAR, iocalt.[Name]), '') + CHAR(13), '') +
		''											  AS MedPrvComments
	   ,ISNULL('Comments: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.Comments), '') + CHAR(13), '') +
		ISNULL('Findings: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.Findings), '') + CHAR(13), '') +
		''											  AS MedPrvNotes
	   ,CASE
			WHEN (UD.[Date Received] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN UD.[Date Received]
			ELSE NULL
		END											  AS MedPrvCompleteDate
	   ,CASE
			WHEN (UD.[Date Received] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN (
						SELECT
							uId
						FROM [sma_MST_RequestStatus]
						WHERE [status] = 'Received'
					)
			ELSE NULL
		END											  AS MedPrvStatusId
	   ,NULL										  AS MedPrvFollowUpDate
	   ,CASE
			WHEN (UD.[Date Received] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN (
						SELECT
							uId
						FROM [sma_MST_RequestStatus]
						WHERE [status] = 'Received'
					)
			ELSE NULL
		END											  AS MedPrvStatusDate
	   ,NULL										  AS OrderAffidavit
	   ,	--bit
		''											  AS FollowUpNotes
	   ,	--Retreival Provider Notes
		'tab2: ' + CONVERT(VARCHAR(50), UD.tablistid) AS SAGA
	--select *
	FROM BrianWhiteNeos..neosUsertab2 UD
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = ud.[Type of Record]
	LEFT JOIN BrianWhiteNeos..value_code vc
		ON vc.id = ud.[value Code]
	LEFT JOIN BrianWhiteNeos..mini_general_dir me
		ON me.id = ud.[method]
	JOIN user_tab2_MedicalProvider_Helper MAP
		ON MAP.case_id = CONVERT(VARCHAR(50), UD.caseSid)
			AND MAP.tab_id = CONVERT(VARCHAR(50), UD.tablistid)
	LEFT JOIN IndvOrgContacts_Indexed iocalt
		ON iocalt.saga_ref = CONVERT(VARCHAR(50), ud.[Alternate Provider])
	JOIN [sma_TRN_Hospitals] H
		ON H.hosnContactID = MAP.ProviderCID
			AND H.hosnContactCtg = MAP.ProviderCTG
			AND H.hosnCaseID = MAP.casnCaseID
GO


/*
--------------------------------------------------------------------------
------------------------------ MEDICAL VISITS -----------------------------
--------------------------------------------------------------------------
insert into  [BrianWhiteSANeos].[dbo].[sma_TRN_Visits]
(
       [vissRefTable]
      ,[visnRecordID]
      ,[visdAdmissionDt]
      ,[visnAdmissionTypeID]
      ,[visdDischargeDt]
      ,[vissAccountNo]
	  ,[vissComplaint]
	  ,[vissDiagnosis]
      ,[visnRecUserID]
      ,[visdDtCreated]
      ,[visnModifyUserID]
      ,[visdDtModified]
	  ,[vissTreatmentPlan]
	  ,[vissComments]
)
select 
    'Hospitals'			  as [vissRefTable],
    H.hosnHospitalID	   as [visnRecordID],
    NULL				   as [visdAdmissionDt],
    (select amtnAdmsnTypeID from sma_MST_AdmissionType where amtsDscrptn='Office Visit')  as [visnAdmissionTypeID],
    NULL				   as [visdDischargeDt],
    NULL				   as [vissAccountNo],
    NULL				   as [vissComplaint],
    d.Findings			   as [vissDiagnosis],
    368					   as [visnRecUserID],
    getdate()			   as [visdDtCreated],
    NULL				   as [visnModifyUserID],
    NULL				   as [visdDtModified],
    D.Treatment_Received		   as [vissTreatmentPlan],
    null				   as [vissComments]
from [BrianWhiteNeos].[dbo].[user_tab2_data] D
inner join user_tab2_MedicalProvider_Helper MAP on MAP.tab_ID=D.tab_id
inner join [BrianWhiteSANeos].[dbo].[sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 
WHERE isnull(Treatment_Received,'')<> '' or
isnull(findings,'')<>''

--------------------------------------------------------------------------
------------------------------ MEDICAL BILLS -----------------------------
--------------------------------------------------------------------------
insert into [BrianWhiteSANeos].[dbo].[sma_TRN_SpDamages]
(
     [spdsRefTable]
    ,[spdnRecordID]
    ,[spdnBillAmt]
    ,[spdsAccntNo]
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
select 
    'Hospitals'			   as spdsRefTable,
    H.hosnHospitalID	   as spdnRecordID,
    convert(numeric(18, 2), D.Total_Bill_Amount)	as spdnBillAmt,
    NULL				   as spdsAccntNo,
    null				   as spddNegotiatedBillAmt,
    null				   as spddDateFrom,
    null				   as spddDateTo,
    null				   as spddDamageSubType,
    null				   as spdnVisitId, 
    isnull('SSA RFCs: ' + NULLIF(D.SSA_RFCs,'') + CHAR(13),'') + 
	isnull('Reason for 1''s: ' + NULLIF(convert(varchar,D.Reason_for_1s),'') + CHAR(13),'') + 
	isnull('Phone #: ' + NULLIF(convert(varchar,D.Phone_#),'') + CHAR(13),'') + 
	isnull('Final Outstanding Balance:' + NULLIF(convert(varchar,D.Final_Outstanding_Balance),'') + CHAR(13),'') + 
	isnull('Final Balance Confirmed:' + NULLIF(convert(varchar,D.Final_Balance_Confirmed),'') + CHAR(13),'') + 
	isnull('HITECH AUTH SENT:' + NULLIF(convert(varchar,D.HITECH_AUTH_SENT),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION:' + NULLIF(convert(varchar,D.HITECH_VIOLATION),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION LTR SENT:' + NULLIF(convert(varchar,D.HITECH_VIOLATION_LTR_SENT),'') + CHAR(13),'') + 
	isnull('HITECH VIOLATION F/U:' + NULLIF(convert(varchar,D.HITECH_VIOLATION_FU),'') + CHAR(13),'') + 
	isnull('HITECH Comments:' + NULLIF(D.HITECH_Comments,'') + CHAR(13),'') + 
	isnull('Req Confirmed with Prov.:' + NULLIF(convert(varchar,D.Req_Confirmed_with_Prov),'') + CHAR(13),'') + 
	''						as spdsComments,
    368						as spdnRecordID,
    getdate()				as spddDtCreated,
    null					as spdnModifyUserID,
    null				    as spddDtModified,
    null				    as spdnBalance,
    0						as spdbLienConfirmed,
    0						as spdbDocAttached,
    'tab2:' + convert(varchar,D.tab_id)	
							as saga_bill_id  -- one bill one value
from [BrianWhiteNeos].[dbo].[user_tab2_data] D
inner join user_tab2_MedicalProvider_Helper MAP on MAP.tab_id=D.tab_id
inner join [BrianWhiteSANeos].[dbo].[sma_TRN_Hospitals] H on H.hosnCaseID=MAP.casnCaseID and H.hosnContactID=MAP.ProviderCID and H.hosnContactCtg=MAP.ProviderCTG and H.hosnAddressID=MAP.ProviderAID 


---(Appendix)--- Update hospital TotalBill from Bill section
UPDATE [sma_TRN_Hospitals]
SET hosnTotalBill = (SELECT SUM(spdnBillAmt) FROM sma_TRN_SpDamages WHERE sma_TRN_SpDamages.spdsRefTable='Hospitals' AND sma_TRN_SpDamages.spdnRecordID = hosnHospitalID)

UPDATE [sma_TRN_Hospitals]
SET hosnTotalMedicalVisits = (SELECT count(*) FROM sma_TRN_Visits WHERE sma_TRN_Visits.vissRefTable='Hospitals' AND sma_TRN_Visits.visnRecordID = hosnHospitalID)

*/


---
ALTER TABLE [sma_trn_MedicalProviderRequest] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO
--alter table [sma_TRN_SpDamages] enable trigger all
--GO
--alter table [sma_TRN_Visits] enable trigger all
--GO



