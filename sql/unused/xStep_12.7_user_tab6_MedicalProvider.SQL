USE BrianWhiteSA
GO

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
    ioc.CID				as [hosnContactID],
    ioc.CTG				as [hosnContactCtg],
    ioc.AID				as [hosnAddressID], 
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
    'Tab6'			    as [saga]
FROM [BrianWhiteNeos]..User_Tab6_Matter m
JOIN BrianWhiteNeos..user_Tab6_Name n on m.ref_num = n.ref_num
JOIN sma_trn_Cases cas on cas.casscasenumber = convert(varchar,n.case_ID)
LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = convert(varchar,n.[user_name])
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'
GO

ALTER TABLE [sma_TRN_Hospitals] ENABLE TRIGGER ALL
GO

--------------------------------
--UPDATE CONTACT TYPE
--------------------------------
--INDIVIDUAL CONTACTS
UPDATE sma_MST_IndvContacts 
set cinnContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octnContactCtgID = 1 and octsDscrptn = 'Doctor')
FROM [BrianWhiteNeos]..User_Tab6_Matter m
JOIN BrianWhiteNeos..user_Tab6_Name n on m.ref_num = n.ref_num
--JOIN IndvOrgContacts_Indexed ioc on ioc.saga_ref = n.[user_name]
JOIN sma_MST_IndvContacts ind on ind.saga = n.[user_name]
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'

--ORGANIZATION CONTACTS
UPDATE sma_MST_orgContacts 
set connContactTypeID = (select octnOrigContactTypeID From sma_MST_OriginalContactTypes where octnContactCtgID = 2 and octsDscrptn = 'Hospital')
FROM [BrianWhiteNeos]..User_Tab6_Matter m
JOIN BrianWhiteNeos..user_Tab6_Name n on m.ref_num = n.ref_num
--JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
JOIN sma_MST_orgContacts org on org.saga = n.[user_name]
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'

----------------------------------------------------
--ADD AMBULANCE AS SPECIALTY TO CONTACT RECORD
----------------------------------------------------
INSErT INTO sma_TRN_MedicalProviderSpecialitySubSpeciality (mdprvspeID, mdprvContactID, mdprvContactctgID)
SELECT DISTINCT (select splID From sma_MST_MedicalProvideSpeciality where spDescription = 'Ambulance'),
	ioc.cid, ioc.CTG
FROM [BrianWhiteNeos]..User_Tab6_Matter m
JOIN BrianWhiteNeos..user_Tab6_Name n on m.ref_num = n.ref_num
JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
WHERE n.[user_name] <> 0
and m.field_title = 'Ambulance/Rescue'