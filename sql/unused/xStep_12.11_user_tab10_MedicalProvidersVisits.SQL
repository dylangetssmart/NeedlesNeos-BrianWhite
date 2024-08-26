USE BrianWhiteSA
GO

if exists (select * From sys.tables where name = 'Tab10_MedProv_Helper')
begin
	drop table Tab10_MedProv_Helper
end
GO

--------------------------------------------
--CREATE MEDICAL PROVIDER HELPER 
--------------------------------------------
SELECT DISTINCT n.case_id,m.field_title, [user_name], ioc.*, cas.casnCaseID
INTO Tab10_MedProv_Helper
FROM [BrianWhiteNeos]..User_Tab10_Matter m
JOIN BrianWhiteNeos..user_Tab10_Name n on m.ref_num = n.ref_num
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = convert(varchar,[user_name])
JOIN sma_trn_cases cas on cas.casscasenumber = convert(varchar,n.case_id)
WHERE n.[user_name] <> 0
and m.field_title IN ('Hospital Name','Dr. Name','DC/PT Name')
GO

--------------------------------------------
--INSERT MEDICAL PROVIDERS
--------------------------------------------
ALTER TABLE [sma_TRN_Hospitals] DISABLE TRIGGER ALL
GO

---(1)---
INSERT INTO [sma_TRN_Hospitals]
 (	[hosnCaseID], 
	[hosnContactID], 
	[hosnContactCtg],
	[hosnAddressID], 
	[hossMedProType], 
	[hosdStartDt],
	[hosdEndDt],
	[hosnPlaintiffID],
	[hosnComments], 
	[hosnHospitalChart], 
	[hosnRecUserID],
	[hosdDtCreated], 
	[hosnModifyUserID],
	[hosdDtModified],
	[saga]
)

SELECT 
    cas.casnCaseID		as [hosnCaseID], 
    CID					as [hosnContactID],
    CTG					as [hosnContactCtg],
    AID					as [hosnAddressID], 
    'M'					as [hossMedProType],
    null				as [hosdStartDt],
    null				as [hosdEndDt],
    (select plnnPlaintiffID From sma_trn_Plaintiff where plnnCaseID = cas.casncaseid and plnbIsPrimary =1)		as hosnPlaintiffID,
    null				as [hosnComments],
    null				as [hosnHospitalChart],
    368				    as [hosnRecUserID],
    getdate()			as [hosdDtCreated],
    null				as [hosnModifyUserID],
    null				as [hosdDtModified],
    'Tab10'			    as [saga]
FROM Tab10_MedProv_Helper h 
JOIN sma_trn_Cases cas on cas.casscasenumber = convert(varchar,h.case_ID)
GO

ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO

----------------------------
--MEDICAL VISITS
----------------------------
INSERT INTO [sma_TRN_Visits]
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
SELECT 
    'Hospitals'					as [vissRefTable],
    isnull(isnull(hn.hosnHospitalID,dn.hosnHospitalID), dc.hosnHospitalID)			as [visnRecordID],
    case when Client_Treatment_Began between '1/1/1900' and '6/6/2079' then Client_Treatment_Began else null end		as [visdAdmissionDt],
    (select amtnAdmsnTypeID from sma_MST_AdmissionType where amtsDscrptn='Office Visit')  as [visnAdmissionTypeID],
    NULL						as [visdDischargeDt],
    NULL						as [vissAccountNo],
    isnull('Client Med Compliant?: ' + nullif(convert(varchar(max),d.Client_Med_Compliant),'') + CHAR(13),'') +
	''							as [vissComplaint],
    isnull('Back: ' + nullif(convert(varchar(max),d.Back),'') + CHAR(13),'') +
	isnull('Headaches: ' + nullif(convert(varchar(max),d.Headaches),'') + CHAR(13),'') +
	isnull('Neck: ' + nullif(convert(varchar(max),d.Neck),'') + CHAR(13),'') +
	isnull('MRI Status: ' + nullif(convert(varchar(max),d.MRI_Status),'') + CHAR(13),'') +
	isnull('Injection Status: ' + nullif(convert(varchar(max),d.Injection_Status),'') + CHAR(13),'') +
	isnull('Surgery Status: ' + nullif(convert(varchar(max),d.Surgery_Status),'') + CHAR(13),'') +
	isnull('Loss of Consciousness: ' + nullif(convert(varchar(max),d.Loss_of_Consciousness),'') + CHAR(13),'') +
	isnull('Head Injury: ' + nullif(convert(varchar(max),d.Head_Injury),'') + CHAR(13),'') +
	isnull('Soft Tissue: ' + nullif(convert(varchar(max),d.Soft_Tissue),'') + CHAR(13),'') +
	isnull('Radiating Pain: ' + nullif(convert(varchar(max),d.Radiating_Pain),'') + CHAR(13),'') +
	isnull('Disc Injury: ' + nullif(convert(varchar(max),d.Disc_Injury),'') + CHAR(13),'') +
	isnull('Bruising: ' + nullif(convert(varchar(max),d.Bruising),'') + CHAR(13),'') +
	isnull('Lacerations: ' + nullif(convert(varchar(max),d.Lacerations),'') + CHAR(13),'') +
	isnull('Broken Bones: ' + nullif(convert(varchar(max),d.Broken_Bones),'') + CHAR(13),'') +
	isnull('Taken by Ambulance: ' + nullif(convert(varchar(max),d.Taken_by_Ambulance),'') + CHAR(13),'') +
	isnull('Scarring: ' + nullif(convert(varchar(max),d.Scarring),'') + CHAR(13),'') +
	isnull('What did your body hit?: ' + nullif(convert(varchar(max),d.What_did_your_body_hit),'') + CHAR(13),'') +
	isnull('ER: ' + nullif(convert(varchar(max),d.ER),'') + CHAR(13),'') +
	''							as [vissDiagnosis],
    368							as [visnRecUserID],
    getdate()					as [visdDtCreated],
    NULL						as [visnModifyUserID],
    NULL						as [visdDtModified],
    case when D.Treatment_Since_Injury between '1/1/1900' and '6/6/2079' then D.Treatment_Since_Injury else NULL end	as [vissTreatmentPlan],
    isnull('Medical History: ' + nullif(convert(varchar(max),d.Medical_History),'') + CHAR(13),'') +
	''							as [vissComments]
FROM [BrianWhiteNeos]..[user_tab10_data] D
JOIN sma_trn_Cases cas on cas.casscasenumber = convert(varchar,d.case_id)
LEFT JOIN (Select case_id, hosnHospitalID From sma_TRN_Hospitals h join Tab10_MedProv_Helper mp on mp.field_Title = 'Hospital Name' and mp.casnCaseID = h.hosnCaseID and mp.ctg = h.hosnContactCtg and mp.CID = h.hosnContactID) HN on hn.case_id = d.case_id
LEFT JOIN (Select case_id, hosnHospitalID From sma_TRN_Hospitals hdr join Tab10_MedProv_Helper mpdr on mpdr.field_Title = 'Dr. Name' and mpdr.casnCaseID = hdr.hosnCaseID and mpdr.ctg = hdr.hosnContactCtg and mpdr.CID = hdr.hosnContactID) DN on dn.case_id = d.case_id
LEFT JOIN (Select case_id, hosnHospitalID From sma_TRN_Hospitals hdc join Tab10_MedProv_Helper mpdc on mpdc.field_Title = 'DC/PT Name' and mpdc.casnCaseID = hdc.hosnCaseID and mpdc.ctg = hdc.hosnContactCtg and mpdc.CID = hdc.hosnContactID) DC on dc.case_id = d.case_id
WHERE isnull(d.Back,'') <> ''
or isnull(d.Headaches,'') <> ''
or isnull(d.Neck,'') <> ''
or isnull(d.Treatment_Since_Injury,'') <> ''
or isnull(d.Medical_History,'') <> ''
or isnull(d.Client_Treatment_Began,'') <> ''
or isnull(d.Client_Med_Compliant,'') <> ''
or isnull(d.MRI_Status,'') <> ''
or isnull(d.Injection_Status,'') <> ''
or isnull(d.Surgery_Status,'') <> ''
or isnull(d.Loss_of_Consciousness,'') <> ''
or isnull(d.Head_Injury,'') <> ''
or isnull(d.Soft_Tissue,'') <> ''
or isnull(d.Radiating_Pain,'') <> ''
or isnull(d.Disc_Injury,'') <> ''
or isnull(d.Bruising,'') <> ''
or isnull(d.Lacerations,'') <> ''
or isnull(d.Broken_Bones,'') <> ''
or isnull(d.Taken_by_Ambulance,'') <> ''
or isnull(d.Scarring,'') <> ''
or isnull(d.What_did_your_body_hit,'') <> ''
or isnull(d.ER,'') <> ''

