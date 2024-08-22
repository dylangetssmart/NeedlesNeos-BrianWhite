USE [SANeosBrianWhite]
GO

/*
alter table [sma_TRN_Incidents] disable trigger all
delete [sma_TRN_Incidents]
DBCC CHECKIDENT ('[sma_TRN_Incidents]', RESEED, 0);
alter table [sma_TRN_Incidents] enable trigger all
*/

---
ALTER TABLE [sma_TRN_Incidents] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO
---
INSERT INTO [sma_TRN_Incidents]
(
       [CaseId]
      ,[IncidentDate]
      ,[StateID]
      ,[LiabilityCodeId]
      ,[IncidentFacts]
      ,[MergedFacts]
      ,[Comments]
      ,[IncidentTime]
      ,[RecUserID]
      ,[DtCreated]
      ,[ModifyUserID]
      ,[DtModified]
)
SELECT 
		CAS.casnCaseID				as CaseId,
		case when ( C.[date_of_incident] between '1900-01-01' and '2079-06-06' ) 
			 then convert(date,C.[date_of_incident]) 
		  else null end 			as IncidentDate,
		case when s.[data] is not null then (select [sttnStateID] from [sma_MST_States] where [sttsDescription]=s.[data])
			when st.[data] is not null then (select [sttnStateID] from [sma_MST_States] where sttsCode = st.[data])
			else (select [sttnStateID] from [sma_MST_States] where sttsCode = 'TX') end	as [StateID],
		0							as LiabilityCodeId, 
		C.synopsis +char(13) +
		--isnull('Description of Accident:' + nullif(u.Description_of_Accident,'') + CHAR(13),'') + 
		''							as IncidentFacts,
		''							as [MergedFacts],
		--isnull(('Preferred GMA Location: '+ nullif(convert(varchar(max),td.Preferred_GMA_Location),'')+char(13)),'')  +
		--isnull(('Clients Eye Color: '+ nullif(convert(varchar(max),td.Clients_eye_color),'')+char(13)),'')  +
		''							as [Comments],
		--substring(convert(varchar, U.[Time_of_Accident], 108),0,6)
		substring(convert(varchar,a.[data], 108),0,6)	as [IncidentTime],
		368							as [RecUserID],
		getdate()					as [DtCreated],
		null						as [ModifyUserID],
		null						as [DtModified]
--select *
FROM [NeosBrianWhite].[dbo].[cases] C
LEFT JOIN (SELECT td.casesid , td.[data]
		FROM [NeosBrianWhite]..user_case_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title = 'State of Suit') s on s.casesid = c.id
LEFT JOIN (SELECT td.casesid , td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title IN ( 'Time of Accident', 'Time of Assault' ) ) a on a.casesid = c.id
LEFT JOIN (SELECT td.casesid , td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
		WHERE field_title IN ( 'State' ) ) st on st.casesid = c.id
JOIN [sma_TRN_cases] CAS on CAS.neos_saga = convert(varchar(50),C.id)


UPDATE CAS
SET CAS.casdIncidentDate=INC.IncidentDate,
    CAS.casnStateID=INC.StateID,
    CAS.casnState=INC.StateID
FROM sma_trn_cases as CAS
LEFT JOIN sma_TRN_Incidents as INC on casnCaseID=caseid
WHERE INC.CaseId=CAS.casncaseid 

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO

