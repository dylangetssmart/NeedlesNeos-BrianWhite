
USE BrianWhiteSA
GO
/*
alter table [sma_TRN_Depositions] disable trigger all
delete from [sma_TRN_Depositions] 
DBCC CHECKIDENT ('[sma_TRN_Depositions]', RESEED, 0);
alter table [sma_TRN_Depositions] enable trigger all
*/

--select * from BrianWhiteNeos..neosUsertab1

ALTER TABLE [dbo].[sma_TRN_Depositions]
ALTER COLUMN [dpssComments] [VARCHAR](MAX) NULL
GO


IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Depositions')
	)
BEGIN
	ALTER TABLE sma_TRN_Depositions
	ADD saga VARCHAR(50)
END
GO

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_ExpertContacts')
	)
BEGIN
	ALTER TABLE sma_TRN_ExpertContacts
	ADD saga VARCHAR(50) NULL
END
GO
---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'user_tab_contacts_helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE user_tab_contacts_helper
END
GO

---(0)---
CREATE TABLE user_tab_contacts_helper (
	TableIndex INT IDENTITY (1, 1) NOT NULL
   ,caseID VARCHAR(50)
   ,tabID VARCHAR(50)
   ,
	--DeponentNameId		  int,
	--DeponentName		  varchar(200),
	--DeponentCID			  int,
	--DeponentCTG			  int,
	--DeponentAID			  int,
	--DeponentUniqueID	  int,
	CourtReporterNameID VARCHAR(50)
   ,CourtReporterName VARCHAR(200)
   ,CourtReporterCID INT
   ,CourtReporterCTG INT
   ,CourtReporterAID INT
   ,CourtReporterUniqueID INT
   ,WitnessNameID VARCHAR(50)
   ,WitnessName VARCHAR(200)
   ,WitnessCID INT
   ,WitnessCTG INT
   ,WitnessAID INT
   ,WitnessUniqueID INT
   ,
	--JudgeName			  varchar(200),
	--   JudgeCID			  int,
	--   JudgeCTG			  int,
	--   JudgeAID			  int,
	--   JudgeUniqueID		  int,
	VideographerName VARCHAR(200)
   ,VideographerCID INT
   ,VideographerCTG INT
   ,VideographerAID INT
   ,VideographerUniqueID INT
   ,DepoLocationNameID VARCHAR(50)
   ,DepoLocationName VARCHAR(200)
   ,DepoLocationCID INT
   ,DepoLocationAID INT
   ,DepoLocationCTG INT
   ,casnCaseID INT
   ,ForWhichParty VARCHAR(200)
   ,ServeByID INT
   ,CONSTRAINT IOC_Clustered_Index_user_tab_contacts_helper PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO


--Court Reporter
--Deposition Location
--Judge
--Name
--Videographer


---(0)--- INSERT PRIMARY FIELD
INSERT INTO user_tab_contacts_helper
	(
	caseID
   ,tabID
   ,WitnessNameId
   ,WitnessName
   ,WitnessCID
   ,WitnessCTG
   ,WitnessAID
   ,WitnessUniqueID
   ,
	--CourtReporterCID,CourtReporterCTG,CourtReporterAID,CourtReporterUniqueID, VideographerCID,VideographerCTG,VideographerAID,VideographerUniqueID,TranslatorCID,TranslatorCTG,TranslatorAID,TranslatorUniqueID,
	casnCaseID
   ,ForWhichParty
   ,ServeByID
	)
	SELECT
		n.casesid		 AS caseID
	   ,		-- needles case
		n.tablistid		 AS tabID
	   ,		-- needles records TAB item
		n.[Witness Name] AS WitnessNameId
	   ,IOC.[Name]		 AS WitnessName
	   ,IOC.CID			 AS WitnessCID
	   ,IOC.CTG			 AS WitnessCTG
	   ,IOC.AID			 AS WitnessAID
	   ,IOC.UNQCID		 AS WitnessUniqueID
	   ,CAS.casnCaseID	 AS casnCaseID
	   ,NULL			 AS ForWhichParty
	   ,NULL			 AS ServeByID
	--select *
	FROM BrianWhiteNeos..neosUsertab1 n
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), n.[Witness Name])
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), n.CasesID)
GO

-- UPDATE COURT REPORTER INFO
UPDATE user_tab_contacts_helper
SET CourtReporterCID = IOC.CID
   ,CourtReporterCTG = IOC.CTG
   ,CourtReporterAID = IOC.AID
   ,CourtReporterUniqueID = IOC.UNQCID
   ,CourtReporterName = ioc.[name]
FROM BrianWhiteNeos..neosUsertab1 n
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA_ref = CONVERT(VARCHAR(50), n.[Court Reporter])
WHERE tabid = CONVERT(VARCHAR(50), n.tablistid)
GO


--UPDATE DEPO LOCATION INTO
UPDATE user_tab_contacts_helper
SET DepoLocationNameID = [Location of Deposition]
   ,DepoLocationName = ioc.[name]
   ,DepoLocationCID = ioc.cid
   ,DepoLocationAID = ioc.AID
   ,DepoLocationCTG = ioc.CTG
FROM BrianWhiteNeos..neosUsertab1 n
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA_ref = CONVERT(VARCHAR(50), n.[Location of Deposition])
WHERE tabid = CONVERT(VARCHAR(50), n.tablistid)
GO

-- UPDATE VIDEOGRAPHER INFO
UPDATE user_tab_contacts_helper
SET VideographerCID = IOC.CID
   ,VideographerCTG = IOC.CTG
   ,VideographerAID = IOC.AID
   ,VideographerUniqueID = IOC.UNQCID
   ,VideographerName = ioc.[name]
FROM BrianWhiteNeos..neosUsertab1 n
JOIN [IndvOrgContacts_Indexed] IOC
	ON IOC.SAGA_ref = CONVERT(VARCHAR(50), n.[Videographer])
WHERE tabid = CONVERT(VARCHAR(50), n.tablistid)
GO
---
DBCC DBREINDEX ('user_tab_contacts_helper', ' ', 90) WITH NO_INFOMSGS
---
GO

-----------------------------------------------------
------------------- CONTACT TYPES-- -----------------
-----------------------------------------------------
INSERT INTO sma_MST_ContactTypes
	(
	cntnContactCtgID
   ,cntsDscrptn
   ,cntsRoleGroup
   ,cntbFlag
	)
	SELECT DISTINCT
		1	   AS cntnContactCtgID
	   ,g.code AS cntsDscrptn
	   ,'O'	   AS cntsRoleGroup
	   ,1	   AS cntbFlag
	FROM BrianWhiteNeos..neosUsertab1 D
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = d.[Type of Witness]
	WHERE ISNULL(D.[Type of Witness], '') <> ''
	EXCEPT
	SELECT
		cntnContactCtgID
	   ,cntsDscrptn
	   ,cntsRoleGroup
	   ,cntbFlag
	FROM sma_MST_ContactTypes
GO

-----------------------------------------------------
----------------- EXPERT SPECIALITY -----------------
-----------------------------------------------------
INSERT INTO sma_MST_Speciality
	(
	splsSpeciality
   ,splnContactTypeID
	)
	SELECT DISTINCT
		g.code
	   ,(
			SELECT
				cntnContactTypeID
			FROM sma_MST_ContactTypes
			WHERE cntsDscrptn = 'Experts'
		)
	FROM BrianWhiteNeos..neosUsertab1 D
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = d.[Type of Expert]
	WHERE ISNULL(d.[Type of Expert], '') <> ''
	EXCEPT
	SELECT
		splsSpeciality
	   ,(
			SELECT
				cntnContactTypeID
			FROM sma_MST_ContactTypes
			WHERE cntsDscrptn = 'Experts'
		)
	FROM sma_MST_Speciality
GO

-----------------------------------------------------
----------------- DEPOSITION TYPES -----------------
-----------------------------------------------------
INSERT INTO [sma_MST_DepositionType]
	(
	dptsDescription
	)
	SELECT DISTINCT
		g.code AS cntsDscrptn
	FROM BrianWhiteNeos..neosUsertab1 D
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = d.[Type of Witness]
	WHERE ISNULL(D.[Type of Witness], '') <> ''
	EXCEPT
	SELECT
		dptsDescription
	FROM [sma_MST_DepositionType]
GO

---------------------------------------------
--------------- WITNESS TYPES-- -------------
---------------------------------------------
INSERT INTO SMA_MST_WitnessType
	(
	WitnessType
   ,CreatedBy
   ,CreatedDate
	)
	SELECT DISTINCT
		g.code
	   ,368
	   ,GETDATE()
	FROM BrianWhiteNeos..neosUsertab1 D
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = d.[Type of Witness]
	LEFT JOIN SMA_MST_WitnessType WT
		ON WT.WitnessType = g.[code]
	WHERE g.[code] <> 'Expert'
		AND WT.ID IS NULL
GO

---------------------------------------------
------------- WITNESS CONTACTS -------------
---------------------------------------------
INSERT INTO [dbo].[sma_TRN_CaseWitness]
	(
	[witnCaseID]
   ,[witnWitnesContactID]
   ,[witnWitnesAdID]
   ,[witnRoleID]
   ,[witnFavorable]
   ,[witnTestify]
   ,[witdStmtReqDate]
   ,[witdStmtDate]
   ,[witbHasRec]
   ,[witsDoc]
   ,[witsComment]
   ,[witnRecUserID]
   ,[witdDtCreated]
   ,[witnModifyUserID]
   ,[witdDtModified]
   ,[witnLevelNo]
	)
	SELECT
		casnCaseid		AS [witnCaseID]
	   ,WitnessUniqueID AS [witnWitnesContactID]
	   ,WitnessAID		AS [witnWitnesAdID]
	   ,(
			SELECT
				ID
			FROM SMA_MST_WitnessType
			WHERE witnesstype = d.code
		)				
		AS [witnRoleID]
	   ,CASE
			WHEN d.code = 'Party'
				THEN 1
			ELSE NULL
		END				AS [witnFavorable]
	   ,NULL			AS [witnTestify]
	   ,NULL			AS [witdStmtReqDate]
	   ,NULL			AS [witdStmtDate]
	   ,NULL			AS [witbHasRec]
	   ,NULL			AS [witsDoc]
	   ,
		--ISNULL(('Statement Context : ' + nullif(UD.[Statement_Context],'') + CHAR(13)),'') + 
		''				AS [witsComment]
	   ,368				AS [witnRecUserID]
	   ,GETDATE()		AS [witdDtCreated]
	   ,NULL			AS [witnModifyUserID]
	   ,NULL			AS [witdDtModified]
	   ,1				AS [witnLevelNo]
	--select *
	FROM user_tab_contacts_helper CH
	JOIN BrianWhiteNeos..neosUsertab1 UD
		ON CONVERT(VARCHAR(50), UD.tablistid) = CH.tabID
			AND CONVERT(VARCHAR(50), ud.CasesID) = ch.caseID
	JOIN BrianWhiteNeos..mini_general_dir d
		ON d.id = ud.[Type of Witness]
	WHERE d.code <> 'Expert'
GO


---------------------------------------------
-------------- EXPERT CONTACTS -------------- 
---------------------------------------------
ALTER TABLE [dbo].[sma_TRN_ExpertContacts] DISABLE TRIGGER ALL
GO

---(1)---
INSERT INTO [dbo].[sma_TRN_ExpertContacts]
	(
	[ectnCaseID]
   ,[ectnExpContactID]
   ,[ectnExpContactCtgId]
   ,[ectnExpAddressID]
   ,[ectnExpertFor]
   ,[ectnExpertTypeID]
   ,[ectdDisclosureDt]
   ,[ectsComment]
   ,[ectnRecUserID]
   ,[ectdDtCreated]
   ,[ectbDocAttached]
	--,[ectnSpeciality]
	--,[ectnSubspeciality]
	)
	SELECT
		MAP.casnCaseID AS [ectnCaseID]
	   ,MAP.WitnessCID AS [ectnExpContactID]
	   ,MAP.WitnessCTG AS [ectnExpContactCtgId]
	   ,MAP.WitnessAID AS [ectnExpAddressID]
	   ,CASE
			WHEN ud.[Type of Witness] = 'Party'
				THEN 0
			ELSE 2
		END			   AS ectnExpertFor
	   ,  -- 0 for Plaintiff, 1 for Defendant, 2=neutral
		NULL		   AS ectnExpertTypeID
	   ,GETDATE()	   AS [ectdDisclosureDt]
	   ,ISNULL('Type of Witness: ' + NULLIF(CONVERT(VARCHAR, UD.[Type of Witness]), '') + CHAR(13) + CHAR(10), '') +
		ISNULL('Type of Expert: ' + NULLIF(CONVERT(VARCHAR, UD.[Type of Expert]), '') + CHAR(13) + CHAR(10), '') +
		''			   AS [ectsComment]
	   ,368			   AS [ectnRecUserID]
	   ,GETDATE()	   AS [ectdDtCreated]
	   ,0			   AS [ectbDocAttached]
	--(select splnSpecialityID from sma_MST_Speciality where UD.Type_of_Expert = splsSpeciality)			as [ectnSpeciality],
	--(select splnSpecialityID from sma_MST_Speciality where UD.Type_of_Expert = splsSpeciality)			as [ectnSubspeciality]
	FROM user_tab_contacts_helper MAP
	JOIN BrianWhiteNeos..neosUsertab1 UD
		ON CONVERT(VARCHAR(50), UD.tablistid) = map.tabID
			AND CONVERT(VARCHAR(50), ud.CasesID) = map.caseID
	JOIN BrianWhiteNeos..mini_general_dir d
		ON d.id = ud.[Type of Witness]
	WHERE d.[code] = 'Expert'
GO

ALTER TABLE [sma_TRN_ExpertContacts] ENABLE TRIGGER ALL
GO

------------------------------------------------------------------------
------------ UPDATE CONTACT TYPE TO EXPERT IN CONTACT CARDS ------------
------------------------------------------------------------------------
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM sma_MST_OriginalContactTypes
	WHERE octsDscrptn = 'Expert'
		AND octnContactCtgID = 1
)
--select * 
FROM [sma_TRN_ExpertContacts] EC
JOIN sma_MST_IndvContacts IND
	ON EC.ectnExpContactID = IND.cinnContactID
	AND EC.ectnExpContactCtgId = IND.cinnContactCtg
GO

UPDATE sma_MST_OrgContacts
SET connContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM sma_MST_OriginalContactTypes
	WHERE octsDscrptn = 'Expert'
		AND octnContactCtgID = 2
)
--select * 
FROM [sma_TRN_ExpertContacts] EC
JOIN sma_MST_OrgContacts Org
	ON EC.ectnExpContactID = Org.connContactID
	AND EC.ectnExpContactCtgId = Org.connContactCtg
GO


------------------------------------------------------------------------
--INSERT SPECIALTY TO CONTACT CARDS
------------------------------------------------------------------------
INSERT INTO sma_TRN_ExpertSpecialtySubSpecialty
	(
	[ExpertSpecialtyID]
   ,[ExpertSubSpecialtyID]
   ,[ExpertContactID]
   ,[ExpertContactCtg]
   ,[CreatedUserID]
   ,[CreatedDate]
   ,[ModifiedUserID]
   ,[ModifiedDate]
	)
	SELECT DISTINCT
		(
			SELECT
				splnSpecialityID
			FROM sma_MST_Speciality
			WHERE d.code = splsSpeciality
		)			   
		AS [ExpertSpecialtyID]
	   ,NULL		   AS [ExpertSubSpecialtyID]
	   ,map.WitnessCID AS [ExpertContactID]
	   ,map.WitnessCTG AS [ExpertContactCtg]
	   ,368			   AS [CreatedUserID]
	   ,GETDATE()	   AS [CreatedDate]
	   ,NULL		   AS [ModifiedUserID]
	   ,NULL		   AS [ModifiedDate]
	FROM user_tab_contacts_helper MAP
	JOIN BrianWhiteNeos..neosUsertab1 UD
		ON CONVERT(VARCHAR(50), UD.tablistid) = map.tabID
			AND CONVERT(VARCHAR(50), ud.CasesID) = map.caseID
	JOIN BrianWhiteNeos..mini_general_dir d
		ON d.id = ud.[Type of Expert]
	WHERE ISNULL([Type of Expert], '') <> ''
GO


-----------------------------------------------
-- POPULATE DEPOSITIONS
-----------------------------------------------
ALTER TABLE [sma_TRN_Depositions] DISABLE TRIGGER ALL
GO
--- 

INSERT INTO [dbo].[sma_TRN_Depositions]
	(
	[dpsnCaseId]
   ,[dscdEnteredDt]
   ,[dpsnType]
   ,[dpsdOnDate]
   ,[dpsdTrnscrptServedDt]  --Transcript Requested
   ,[dpsdTrnscrptRcvdDt]
   ,[dpssComments]
   ,[dpsnExecutedWaived]
   ,[dpsdExecDt]
   ,[dpsbVideoTape]
   ,[dpsnRecUserID]
   ,[dpsdDtCreated]
   ,[dpsnModifyUserID]
   ,[dpsdDtModified]
   ,[dpsbTranslator]
   ,[ServedByUniqueID]
   ,[DeponentUID]
   ,[TestifyForUniqueID]
   ,[CourtReporterUID]
   ,[CourtAgencyUID]
   ,[VideoOperatorUID]
   ,[VideoCompanyUID]
   ,[TranslatorUID]
   ,[TranslAgencyUID]
   ,[saga]
	)
	SELECT
		MAP.casnCaseID			  AS [dpsnCaseId]
	   ,NULL					  AS [dscdEnteredDt]
	   ,(
			SELECT
				dptnDepositionTypeID
			FROM [dbo].[sma_MST_DepositionType]
			WHERE dptsDescription = g.code
		)						  
		AS [dpsnType]
	   ,CASE
			WHEN ud.[Depo Date] BETWEEN '1/1/1900' AND '6/6/2079'
				THEN ud.[Depo Date]
			ELSE NULL
		END						  AS [dpsdOnDate]
	   ,NULL					  AS [dpsdTrnscrptServedDt]
	   ,NULL					  AS [dpsdTrnscrptRcvdDt]
	   ,ISNULL(('Depo Time: ' + NULLIF(CONVERT(VARCHAR, UD.[Depo Time]), '') + CHAR(13)), '') +
		ISNULL(('Notes: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.Notes), '') + CHAR(13)), '') +
		ISNULL(('Depo Prep Date: ' + NULLIF(CONVERT(VARCHAR, UD.[Depo Prep Date]), '') + CHAR(13)), '') +
		ISNULL(('Depo Prep Time: ' + NULLIF(CONVERT(VARCHAR, UD.[Depo Prep Time]), '') + CHAR(13)), '') +
		ISNULL(('Interpreter?: ' + NULLIF(CONVERT(VARCHAR, UD.Interpreter), '') + CHAR(13)), '') +
		ISNULL(('Location of Deposition: ' + NULLIF(Map.depoLocationName, '') + CHAR(13)), '') +
		ISNULL(('Ct. Reporter Cost: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.[court reporter cost]), '') + CHAR(13)), '') +
		ISNULL(('CV on File?: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.[CV on File?]), '') + CHAR(13)), '') +
		ISNULL(('Video?: ' + NULLIF(CONVERT(VARCHAR(MAX), UD.[Video?]), '') + CHAR(13)), '') +
		''						  AS [dpssComments]
	   ,0
	   ,NULL
	   ,CASE
			WHEN UD.[Video?] = 'Y'
				THEN 1
			ELSE 0
		END						  AS [dpsbVideoTape]
	   ,368						  AS [dpsnRecUserID]
	   ,GETDATE()				  AS [dpsdDtCreated]
	   ,NULL					  AS [dpsnModifyUserID]
	   ,NULL					  AS [dpsdDtModified]
	   ,NULL					  AS [dpsbTranslator]
	   ,NULL					  AS [ServedByUniqueID]
	   ,MAP.WitnessUniqueID		  AS [DeponentUID]
	   ,NULL					  AS [TestifyForUniqueID]
	   ,map.CourtReporterUniqueID AS [CourtReporterUID]
	   ,NULL					  AS [CourtAgencyUID]
	   ,map.VideographerUniqueID  AS [VideoOperatorUID]
	   ,NULL					  AS [VideoCompanyUID]
	   ,NULL					  AS [TranslatorUID]
	   ,NULL					  AS [TranslAgencyUID]
	   ,UD.tablistid			  AS [saga]
	--SELECT [Video?]
	FROM BrianWhiteNeos..neosUsertab1 UD
	JOIN user_tab_contacts_helper MAP
		ON MAP.caseID = CONVERT(VARCHAR(50), UD.CasesID)
			AND MAP.tabID = CONVERT(VARCHAR(50), UD.tablistid)
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = ud.[Type of Witness]
GO

---
ALTER TABLE [dbo].[sma_TRN_Depositions] ENABLE TRIGGER ALL
GO
---

