USE [BrianWhiteSANeos]
GO
/*
alter table [sma_TRN_Cases] disable trigger all
delete from [sma_TRN_Cases] 
DBCC CHECKIDENT ('[sma_TRN_Cases]', RESEED, 0); 
alter table [sma_TRN_Cases] enable trigger all

select * from [sma_MST_CaseType]
*/


--ADD NEEDLES SAGA - CASE SAGA HAS TO BE INT TYPE
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'Neos_saga'
			AND Object_ID = OBJECT_ID(N'sma_trn_Cases')
	)
BEGIN
	ALTER TABLE [sma_trn_Cases]
	ADD Neos_saga [VARCHAR](50) NULL;
END
GO

---(0)---cASE GROUPS
IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_CaseGroup]
		WHERE [cgpsDscrptn] = 'Neos'
	)
BEGIN

	INSERT INTO [sma_MST_CaseGroup]
		(
		[cgpsCode]
	   ,[cgpsDscrptn]
	   ,[cgpnRecUserId]
	   ,[cgpdDtCreated]
	   ,[cgpnModifyUserID]
	   ,[cgpdDtModified]
	   ,[cgpnLevelNo]
	   ,[IncidentTypeID]
	   ,[LimitGroupStatuses]
		)
		SELECT
			NULL	  AS [cgpsCode]
		   ,'Neos'	  AS [cgpsDscrptn]
		   ,368		  AS [cgpnRecUserId]
		   ,GETDATE() AS [cgpdDtCreated]
		   ,NULL	  AS [cgpnModifyUserID]
		   ,NULL	  AS [cgpdDtModified]
		   ,NULL	  AS [cgpnLevelNo]
		   ,(
				SELECT
					IncidentTypeID
				FROM [sma_MST_IncidentTypes]
				WHERE Description = 'General Negligence'
			)		  
			AS [IncidentTypeID]
		   ,NULL	  AS [LimitGroupStatuses]
END
GO
---------------------------
--INSERT OFFICE
---------------------------
INSERT INTO [sma_mst_offices]
	(
	[office_status]
   ,[office_name]
   ,[state_id]
   ,[is_default]
   ,[date_created]
   ,[user_created]
   ,[date_modified]
   ,[user_modified]
   ,[Letterhead]
   ,[UniqueContactId]
   ,[PhoneNumber]
	)
	SELECT
		1					AS [office_status]
	   ,sd.Firm_name		AS [office_name]
	   ,(
			SELECT
				sttnStateID
			FROM sma_MST_States
			WHERE sttsCode = sd.[state]
		)					
		AS [state_id]
	   ,1					AS [is_default]
	   ,GETDATE()			AS [date_created]
	   ,368					AS [user_created]
	   ,GETDATE()			AS [date_modified]
	   ,368					AS [user_modified]
	   ,'LetterheadUt.docx' AS [Letterhead]
	   ,NULL				AS [UniqueContactId]
	   ,sd.phone			AS [PhoneNumber]
	--Select *
	FROM BrianWhiteNeos..systemdata sd
	LEFT JOIN [sma_mst_offices] o
		ON o.office_name = sd.firm_name
	WHERE o.office_id IS NULL
GO


-----(0)-----
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'VenderCaseType'
			AND Object_ID = OBJECT_ID(N'sma_MST_CaseType')
	)
BEGIN
	ALTER TABLE sma_MST_CaseType
	ADD VenderCaseType VARCHAR(100)
END
GO

-------- (1) sma_MST_CaseType ----------------------
INSERT INTO [sma_MST_CaseType]
	(
	[cstsCode]
   ,[cstsType]
   ,[cstsSubType]
   ,[cstnWorkflowTemplateID]
   ,[cstnExpectedResolutionDays]
   ,[cstnRecUserID]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbTimeTracking]
   ,[cstnGroupID]
   ,[cstnGovtMunType]
   ,[cstnIsMassTort]
   ,[cstnStatusID]
   ,[cstnStatusTypeID]
   ,[cstbActive]
   ,[cstbUseIncident1]
   ,[cstsIncidentLabel1]
   ,[VenderCaseType]
	)
	SELECT
		NULL					  AS cstsCode
	   ,[SmartAdvocate Case Type] AS cstsType
	   ,NULL					  AS cstsSubType
	   ,NULL					  AS cstnWorkflowTemplateID
	   ,720						  AS cstnExpectedResolutionDays
	   , -- ( Hardcode 2 years )
		368						  AS cstnRecUserID
	   ,GETDATE()				  AS cstdDtCreated
	   ,368						  AS cstnModifyUserID
	   ,GETDATE()				  AS cstdDtModified
	   ,0						  AS cstnLevelNo
	   ,NULL					  AS cstbTimeTracking
	   ,(
			SELECT
				cgpnCaseGroupID
			FROM sma_MST_caseGroup
			WHERE cgpsDscrptn = 'Neos'
		)						  
		AS cstnGroupID
	   ,NULL					  AS cstnGovtMunType
	   ,NULL					  AS cstnIsMassTort
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						  
		AS cstnStatusID
	   ,(
			SELECT
				stpnStatusTypeID
			FROM [sma_MST_CaseStatusType]
			WHERE stpsStatusType = 'Status'
		)						  
		AS cstnStatusTypeID
	   ,1						  AS cstbActive
	   ,1						  AS cstbUseIncident1
	   ,'Incident 1'			  AS cstsIncidentLabel1
	   ,'BrianWhiteCaseType'	  AS VenderCaseType
	FROM [CaseTypeMixture] MIX
	LEFT JOIN [sma_MST_CaseType] ct
		ON ct.cststype = mix.[SmartAdvocate Case Type]
	WHERE ct.cstncasetypeid IS NULL
GO


UPDATE [sma_MST_CaseType]
SET VenderCaseType = 'BrianWhiteCaseType'
FROM [CaseTypeMixture] MIX
JOIN [sma_MST_CaseType] ct
	ON ct.cststype = mix.[SmartAdvocate Case Type]
WHERE ISNULL(VenderCaseType, '') = ''


---(0) sma_MST_CaseSubTypeCode
INSERT INTO [dbo].[sma_MST_CaseSubTypeCode]
	(
	stcsDscrptn
	)
	SELECT DISTINCT
		MIX.[SmartAdvocate Case Sub Type]
	FROM [CaseTypeMixture] MIX
	WHERE ISNULL(MIX.[SmartAdvocate Case Sub Type], '') <> ''
	EXCEPT
	SELECT
		stcsDscrptn
	FROM [dbo].[sma_MST_CaseSubTypeCode]


---(2.1) sma_MST_CaseSubType
INSERT INTO [sma_MST_CaseSubType]
	(
	[cstsCode]
   ,[cstnGroupID]
   ,[cstsDscrptn]
   ,[cstnRecUserId]
   ,[cstdDtCreated]
   ,[cstnModifyUserID]
   ,[cstdDtModified]
   ,[cstnLevelNo]
   ,[cstbDefualt]
   ,[saga]
   ,[cstnTypeCode]
	)
	SELECT
		NULL						  AS [cstsCode]
	   ,cstncasetypeid				  AS [cstnGroupID]
	   ,[SmartAdvocate Case Sub Type] AS [cstsDscrptn]
	   ,368							  AS [cstnRecUserId]
	   ,GETDATE()					  AS [cstdDtCreated]
	   ,NULL						  AS [cstnModifyUserID]
	   ,NULL						  AS [cstdDtModified]
	   ,NULL						  AS [cstnLevelNo]
	   ,1							  AS [cstbDefualt]
	   ,NULL						  AS [saga]
	   ,(
			SELECT
				stcnCodeId
			FROM [sma_MST_CaseSubTypeCode]
			WHERE stcsDscrptn = [SmartAdvocate Case Sub Type]
		)							  
		AS [cstnTypeCode]
	FROM [sma_MST_CaseType] CST
	JOIN [CaseTypeMixture] MIX
		ON MIX.[SmartAdvocate Case Type] = CST.cststype
	LEFT JOIN [sma_MST_CaseSubType] sub
		ON sub.[cstnGroupID] = cstncasetypeid
			AND sub.[cstsDscrptn] = [SmartAdvocate Case Sub Type]
	WHERE sub.cstncasesubtypeID IS NULL
		AND ISNULL([SmartAdvocate Case Sub Type], '') <> ''

/*
---(2.2) sma_MST_CaseSubType
insert into [sma_MST_CaseSubType]
(
       [cstsCode]
      ,[cstnGroupID]
      ,[cstsDscrptn]
      ,[cstnRecUserId]
      ,[cstdDtCreated]
      ,[cstnModifyUserID]
      ,[cstdDtModified]
      ,[cstnLevelNo]
      ,[cstbDefualt]
      ,[saga]
      ,[cstnTypeCode]
)
select  	null				as [cstsCode],
		cstncasetypeid		as [cstnGroupID],
		MIX.[SmartAdvocate Case Sub Type] as [cstsDscrptn], 
		368 				as [cstnRecUserId],
		getdate()			as [cstdDtCreated],
		null				as [cstnModifyUserID],
		null				as [cstdDtModified],
		null				as [cstnLevelNo],
		1				as [cstbDefualt],
		null				as [saga],
		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=MIX.[SmartAdvocate Case Sub Type]) as [cstnTypeCode] 
FROM [sma_MST_CaseType] CST 
JOIN [CaseTypeMixture] MIX on MIX.matcode=CST.cstsCode  
LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] = cstncasetypeid and sub.[cstsDscrptn] = MIX.[SmartAdvocate Case Sub Type]
WHERE isnull(MIX.[SmartAdvocate Case Type],'')<>''
and sub.cstncasesubtypeID is null
*/


--- (3.0) sma_MST_SubRole ----
INSERT INTO [sma_MST_SubRole]
	(
	[sbrsCode]
   ,[sbrnRoleID]
   ,[sbrsDscrptn]
   ,[sbrnCaseTypeID]
   ,[sbrnPriority]
   ,[sbrnRecUserID]
   ,[sbrdDtCreated]
   ,[sbrnModifyUserID]
   ,[sbrdDtModified]
   ,[sbrnLevelNo]
   ,[sbrbDefualt]
   ,[saga]
	)
	SELECT
		[sbrsCode]		   AS [sbrsCode]
	   ,[sbrnRoleID]	   AS [sbrnRoleID]
	   ,[sbrsDscrptn]	   AS [sbrsDscrptn]
	   ,CST.cstnCaseTypeID AS [sbrnCaseTypeID]
	   ,[sbrnPriority]	   AS [sbrnPriority]
	   ,[sbrnRecUserID]	   AS [sbrnRecUserID]
	   ,[sbrdDtCreated]	   AS [sbrdDtCreated]
	   ,[sbrnModifyUserID] AS [sbrnModifyUserID]
	   ,[sbrdDtModified]   AS [sbrdDtModified]
	   ,[sbrnLevelNo]	   AS [sbrnLevelNo]
	   ,[sbrbDefualt]	   AS [sbrbDefualt]
	   ,[saga]			   AS [saga]
	FROM sma_MST_CaseType CST
	LEFT JOIN sma_mst_subrole S
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
			OR S.sbrnCaseTypeID = 1
	JOIN [CaseTypeMixture] MIX
		ON MIX.matcode = CST.cstsCode
	WHERE VenderCaseType = 'BrianWhiteCaseType'
		AND ISNULL(MIX.[SmartAdvocate Case Type], '') = ''

---- (3.1) sma_MST_SubRole : use the sma_MST_SubRole.sbrsDscrptn value to set the sma_MST_SubRole.sbrnTypeCode field ---
UPDATE sma_MST_SubRole
SET sbrnTypeCode = A.CodeId
FROM (
	SELECT
		S.sbrsDscrptn AS sbrsDscrptn
	   ,S.sbrnSubRoleId AS SubRoleId
	   ,(
			SELECT
				MAX(srcnCodeId)
			FROM sma_MST_SubRoleCode
			WHERE srcsDscrptn = S.sbrsDscrptn
		)
		AS CodeId
	FROM sma_MST_SubRole S
	JOIN sma_MST_CaseType CST
		ON CST.cstnCaseTypeID = S.sbrnCaseTypeID
		AND CST.VenderCaseType = 'BrianWhiteCaseType'
) A
WHERE A.SubRoleId = sbrnSubRoleId


---- (4) specific plaintiff and defendant party roles ----
INSERT INTO [sma_MST_SubRoleCode]
	(
	srcsDscrptn
   ,srcnRoleID
	)
	(
	SELECT
		'(P)-Default Role'
	   ,4
	UNION ALL
	SELECT
		'(D)-Default Role'
	   ,5
	UNION ALL
	SELECT
		[SA Roles]
	   ,4
	FROM [PartyRoles]
	WHERE [SA Party] = 'Plaintiff'
	UNION ALL
	SELECT
		[SA Roles]
	   ,5
	FROM [PartyRoles]
	WHERE [SA Party] = 'Defendant'
	)
	EXCEPT
	SELECT
		srcsDscrptn
	   ,srcnRoleID
	FROM [sma_MST_SubRoleCode]


---- (4.1) Not already in sma_MST_SubRole-----
INSERT INTO sma_MST_SubRole
	(
	sbrnRoleID
   ,sbrsDscrptn
   ,sbrnCaseTypeID
   ,sbrnTypeCode
	)

	SELECT
		T.sbrnRoleID
	   ,T.sbrsDscrptn
	   ,T.sbrnCaseTypeID
	   ,T.sbrnTypeCode
	FROM (
		SELECT
			R.PorD AS sbrnRoleID
		   ,R.[role] AS sbrsDscrptn
		   ,CST.cstnCaseTypeID AS sbrnCaseTypeID
		   ,(
				SELECT
					srcnCodeId
				FROM sma_MST_SubRoleCode
				WHERE srcsDscrptn = R.role
					AND srcnRoleID = R.PorD
			)
			AS sbrnTypeCode
		FROM sma_MST_CaseType CST
		CROSS JOIN (
			SELECT
				'(P)-Default Role' AS role
			   ,4 AS PorD
			UNION ALL
			SELECT
				'(D)-Default Role' AS role
			   ,5 AS PorD
			UNION ALL
			SELECT
				[SA Roles] AS role
			   ,4 AS PorD
			FROM [PartyRoles]
			WHERE [SA Party] = 'Plaintiff'
			UNION ALL
			SELECT
				[SA Roles] AS role
			   ,5 AS PorD
			FROM [PartyRoles]
			WHERE [SA Party] = 'Defendant'
		) R
		WHERE CST.VenderCaseType = 'BrianWhiteCaseType'
	) T
	EXCEPT
	SELECT
		sbrnRoleID
	   ,sbrsDscrptn
	   ,sbrnCaseTypeID
	   ,sbrnTypeCode
	FROM sma_MST_SubRole



/* 
---Checking---
SELECT CST.cstnCaseTypeID,CST.cstsType,sbrsDscrptn
FROM sma_MST_SubRole S
INNER JOIN sma_MST_CaseType CST on CST.cstnCaseTypeID=S.sbrnCaseTypeID
WHERE CST.VenderCaseType='SchechterCaseType'
and sbrsDscrptn='(D)-Default Role'
ORDER BY CST.cstnCaseTypeID
*/


-------- (5) sma_TRN_cases ----------------------
ALTER TABLE [sma_TRN_Cases] DISABLE TRIGGER ALL
GO

INSERT INTO [sma_TRN_Cases]
	(
	[cassCaseNumber]
   ,[casbAppName]
   ,[cassCaseName]
   ,[casnCaseTypeID]
   ,[casnState]
   ,[casdStatusFromDt]
   ,[casnStatusValueID]
   ,[casdsubstatusfromdt]
   ,[casnSubStatusValueID]
   ,[casdOpeningDate]
   ,[casdClosingDate]
   ,[casnCaseValueID]
   ,[casnCaseValueFrom]
   ,[casnCaseValueTo]
   ,[casnCurrentCourt]
   ,[casnCurrentJudge]
   ,[casnCurrentMagistrate]
   ,[casnCaptionID]
   ,[cassCaptionText]
   ,[casbMainCase]
   ,[casbCaseOut]
   ,[casbSubOut]
   ,[casbWCOut]
   ,[casbPartialOut]
   ,[casbPartialSubOut]
   ,[casbPartiallySettled]
   ,[casbInHouse]
   ,[casbAutoTimer]
   ,[casdExpResolutionDate]
   ,[casdIncidentDate]
   ,[casnTotalLiability]
   ,[cassSharingCodeID]
   ,[casnStateID]
   ,[casnLastModifiedBy]
   ,[casdLastModifiedDate]
   ,[casnRecUserID]
   ,[casdDtCreated]
   ,[casnModifyUserID]
   ,[casdDtModified]
   ,[casnLevelNo]
   ,[cassCaseValueComments]
   ,[casbRefIn]
   ,[casbDelete]
   ,[casbIntaken]
   ,[casnOrgCaseTypeID]
   ,[CassCaption]
   ,[cassMdl]
   ,[office_id]
   ,[saga]
   ,[LIP]
   ,[casnSeriousInj]
   ,[casnCorpDefn]
   ,[casnWebImporter]
   ,[casnRecoveryClient]
   ,[cas]
   ,[ngage]
   ,[casnClientRecoveredDt]
   ,[CloseReason]
   ,[Neos_saga]
	)
	SELECT
		C.casenum	   AS cassCaseNumber
	   ,''			   AS casbAppName
	   ,case_name	   AS cassCaseName
	   ,(
			SELECT
				cstnCaseSubTypeID
			FROM [sma_MST_CaseSubType] ST
			WHERE ST.cstnGroupID = CST.cstnCaseTypeID
				AND ST.cstsDscrptn = MIX.[SmartAdvocate Case Sub Type]
		)			   
		AS casnCaseTypeID
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = ISNULL(s.[data], 'Texas')
		)			   
		AS casnState
	   ,GETDATE()	   AS casdStatusFromDt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnStatusValueID
	   ,GETDATE()	   AS casdsubstatusfromdt
	   ,(
			SELECT
				cssnStatusID
			FROM [sma_MST_CaseStatus]
			WHERE csssDescription = 'Presign - Not Scheduled For Sign Up'
		)			   
		AS casnSubStatusValueID
	   ,CASE
			WHEN (C.date_opened NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.date_opened
		END			   
		AS casdOpeningDate
	   ,CASE
			WHEN (C.close_date NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE C.close_date
		END			   
		AS casdClosingDate
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0
	   ,case_title	   AS cassCaptionText
	   ,1
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,1
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0
	   ,0
	   ,(
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE [sttsDescription] = ISNULL(s.[data], 'Texas')
		)			   
		AS casnStateID
	   ,NULL
	   ,NULL
	   ,(
			SELECT
				usrnUserID
			FROM sma_MST_Users
			WHERE saga = C.staffintakeid
		)			   
		AS casnRecUserID
	   ,CASE
			WHEN C.intake_date BETWEEN '1900-01-01' AND '2079-06-06' --and C.intake_time between '1900-01-01' and '2079-06-06' 
				THEN (
						SELECT
							CAST(CONVERT(DATE, C.intake_date) AS DATETIME) + CAST(CONVERT(TIME, C.intake_date) AS DATETIME)
					)
			ELSE NULL
		END			   AS casdDtCreated
	   ,NULL
	   ,NULL
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,cstnCaseTypeID AS casnOrgCaseTypeID
	   ,''			   AS CassCaption
	   ,0			   AS cassMdl
	   ,(
			SELECT
				office_id
			FROM sma_MST_Offices
			WHERE office_name = (
					SELECT
						firm_name
					FROM [BrianWhiteNeos]..systemdata
				)
		)			   
		AS office_id
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0			   AS CloseReason
	   ,c.[id]		   AS [Neos_saga]
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[cases_Indexed] C
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
	LEFT JOIN [BrianWhiteNeos]..[matter] m
		ON m.id = c.matterid
	JOIN caseTypeMixture mix
		ON mix.matcode = m.matcode
	LEFT JOIN sma_MST_CaseType CST
		ON CST.cststype = mix.[smartadvocate Case Type]
			AND VenderCaseType = 'BrianWhiteCaseType'
	ORDER BY C.casenum
GO

---
ALTER TABLE [sma_TRN_Cases] ENABLE TRIGGER ALL
GO
---
