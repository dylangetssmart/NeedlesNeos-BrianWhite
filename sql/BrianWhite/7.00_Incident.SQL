USE [BrianWhiteSANeos]
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
		CAS.casnCaseID									 AS CaseId
	   ,CASE
			WHEN (C.[date_of_incident] BETWEEN '1900-01-01' AND '2079-06-06')
				THEN CONVERT(DATE, C.[date_of_incident])
			ELSE NULL
		END												 AS IncidentDate
	   ,CASE
			WHEN s.[data] IS NOT NULL
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE [sttsDescription] = s.[data]
					)
			WHEN st.[data] IS NOT NULL
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE sttsCode = st.[data]
					)
			ELSE (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE sttsCode = 'TX'
				)
		END												 AS [StateID]
	   ,0												 AS LiabilityCodeId
	   ,C.synopsis + CHAR(13) +
		--isnull('Description of Accident:' + nullif(u.Description_of_Accident,'') + CHAR(13),'') + 
		''												 AS IncidentFacts
	   ,''												 AS [MergedFacts]
	   ,
		--isnull(('Preferred GMA Location: '+ nullif(convert(varchar(max),td.Preferred_GMA_Location),'')+char(13)),'')  +
		--isnull(('Clients Eye Color: '+ nullif(convert(varchar(max),td.Clients_eye_color),'')+char(13)),'')  +
		''												 AS [Comments]
	   ,
		--substring(convert(varchar, U.[Time_of_Accident], 108),0,6)
		SUBSTRING(CONVERT(VARCHAR, a.[data], 108), 0, 6) AS [IncidentTime]
	   ,368												 AS [RecUserID]
	   ,GETDATE()										 AS [DtCreated]
	   ,NULL											 AS [ModifyUserID]
	   ,NULL											 AS [DtModified]
	--select *
	FROM [BrianWhiteNeos].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_case_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'State of Suit'
	) s
		ON s.casesid = c.id
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_tab6_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title IN ('Time of Accident', 'Time of Assault')
	) a
		ON a.casesid = c.id
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_tab6_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title IN ('State')
	) st
		ON st.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.id)


UPDATE CAS
SET CAS.casdIncidentDate = INC.IncidentDate
   ,CAS.casnStateID = INC.StateID
   ,CAS.casnState = INC.StateID
FROM sma_trn_cases AS CAS
LEFT JOIN sma_TRN_Incidents AS INC
	ON casnCaseID = caseid
WHERE INC.CaseId = CAS.casncaseid

---
ALTER TABLE [sma_TRN_Incidents] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO

