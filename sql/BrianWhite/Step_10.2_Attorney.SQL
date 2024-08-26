USE BrianWhiteSANeos
GO
/*
alter table [sma_TRN_PlaintiffAttorney] disable trigger all
delete from [sma_TRN_PlaintiffAttorney] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffAttorney]', RESEED, 0);
alter table [sma_TRN_PlaintiffAttorney] enable trigger all

alter table [sma_TRN_LawFirms] disable trigger all
delete from [sma_TRN_LawFirms] 
DBCC CHECKIDENT ('[sma_TRN_LawFirms]', RESEED, 0);
alter table [sma_TRN_LawFirms] enable trigger all

alter table [sma_TRN_LawFirmAttorneys] disable trigger all
delete from [sma_TRN_LawFirmAttorneys] 
DBCC CHECKIDENT ('[sma_TRN_LawFirmAttorneys]', RESEED, 0);
alter table [sma_TRN_LawFirmAttorneys] enable trigger all
*/
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_PlaintiffAttorney')
	)
BEGIN
	ALTER TABLE [sma_TRN_PlaintiffAttorney]
	ADD saga [VARCHAR](50) NULL;
END
GO
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_LawFirms')
	)
BEGIN
	ALTER TABLE [sma_TRN_LawFirms]
	ADD saga [VARCHAR](50) NULL;
END
GO
/*
-----------------------------------------------------------------------------------
--INSERT ATTORNEY TYPES
-----------------------------------------------------------------------------------
INSERT INTO sma_MST_AttorneyTypes (atnsAtorneyDscrptn)
SELECT Distinct Type_OF_Attorney From BrianWhiteNeos..user_counsel_data where isnull(Type_of_attorney,'')<>''
EXCEPT
SELECT atnsAtorneydscrptn from sma_MST_AttorneyTypes
*/


---
ALTER TABLE [sma_TRN_PlaintiffAttorney] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] DISABLE TRIGGER ALL
GO
---
--------------------------------------
--PLAINTIFF ATTONEYS
--------------------------------------
INSERT INTO [sma_TRN_PlaintiffAttorney]
	(
	[planPlaintffID]
   ,[planCaseID]
   ,[planPlCtgID]
   ,[planPlContactID]
   ,[planLawfrmAddID]
   ,[planLawfrmContactID]
   ,[planAtorneyAddID]
   ,[planAtorneyContactID]
   ,[planAtnTypeID]
   ,[plasFileNo]
   ,[planRecUserID]
   ,[pladDtCreated]
   ,[planModifyUserID]
   ,[pladDtModified]
   ,[planLevelNo]
   ,[planRefOutID]
   ,[plasComments]
   ,[saga]
	)
	SELECT DISTINCT
		T.plnnPlaintiffID AS [planPlaintffID]
	   ,CAS.casnCaseID	  AS [planCaseID]
	   ,T.plnnContactCtg  AS [planPlCtgID]
	   ,T.plnnContactID	  AS [planPlContactID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END				  AS [planLawfrmAddID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END				  AS [planLawfrmContactID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END				  AS [planAtorneyAddID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END				  AS [planAtorneyContactID]
	   ,(
			SELECT
				atnnAtorneyTypeID
			FROM sma_MST_AttorneyTypes
			WHERE atnsAtorneyDscrptn = 'Plaintiff Attorney'
		)				  
		AS [planAtnTypeID]
	   ,NULL			  AS [plasFileNo]
	   , --	 UD.Their_File_Number
		(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), c.staffCreatedID)
		)				  
		AS [planRecUserID]
	   ,c.date_created	  AS [pladDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), c.staffmodifiedid)
		)				  
		AS [planModifyUserID]
	   ,c.date_modified	  AS [pladDtModified]
	   ,0				  AS [planLevelNo]
	   ,NULL			  AS [planRefOutID]
	   ,ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), C.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), IOCP.name), '') + CHAR(13), '') +
		''				  AS [plasComments]
	   ,c.id			  AS [saga]
	--SELECT *
	FROM [BrianWhiteNeos]..[counsel_Indexed] C
	--LEFT JOIN [BrianWhiteNeos].[dbo].[user_counsel_data] UD on UD.counsel_id=C.counsel_id and C.case_num=UD.casenum  
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), C.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), C.counselnamesid)
	JOIN IndvOrgContacts_Indexed IOCP
		ON IOCP.SAGA_ref = CONVERT(VARCHAR(50), C.representingnamesid) -- and isnull(C.party_id,0)<>0
	JOIN [sma_TRN_Plaintiff] T
		ON T.plnnContactID = IOCP.CID
			AND T.plnnContactCtg = IOCP.CTG
			AND T.plnnCaseID = CAS.casnCaseID
GO

--------------------------------------
--DEFENSE ATTORNEYS
--------------------------------------
INSERT INTO [sma_TRN_LawFirms]
	(
	[lwfnLawFirmContactID]
   ,[lwfnLawFirmAddressID]
   ,[lwfnAttorneyContactID]
   ,[lwfnAttorneyAddressID]
   ,[lwfnAttorneyTypeID]
   ,[lwfsFileNumber]
   ,[lwfnRoleType]
   ,[lwfnContactID]
   ,[lwfnRecUserID]
   ,[lwfdDtCreated]
   ,[lwfnModifyUserID]
   ,[lwfdDtModified]
   ,[lwfnLevelNo]
   ,[lwfnAdjusterID]
   ,[lwfsComments]
   ,[saga]
	)
	SELECT DISTINCT
		CASE
			WHEN IOC.CTG = 2
				THEN IOC.CID
			ELSE NULL
		END				  AS [lwfnLawFirmContactID]
	   ,CASE
			WHEN IOC.CTG = 2
				THEN IOC.AID
			ELSE NULL
		END				  AS [lwfnLawFirmAddressID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.CID
			ELSE NULL
		END				  AS [lwfnAttorneyContactID]
	   ,CASE
			WHEN IOC.CTG = 1
				THEN IOC.AID
			ELSE NULL
		END				  AS [lwfnAttorneyAddressID]
	   ,(
			SELECT
				atnnAtorneyTypeID
			FROM [sma_MST_AttorneyTypes]
			WHERE atnsAtorneyDscrptn = 'Defense Attorney'
		)				  
		AS [lwfnAttorneyTypeID]
	   ,NULL			  AS [lwfsFileNumber]
	   ,2				  AS [lwfnRoleType]
	   ,D.defnDefendentID AS [lwfnContactID]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), c.staffCreatedID)
		)				  
		AS [lwfnRecUserID]
	   ,c.date_created	  AS [lwfdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), c.staffmodifiedid)
		)				  
		AS [lwfnModifyUserID]
	   ,c.date_modified	  AS [lwfdDtModified]
	   ,NULL			  AS [lwfnLevelNo]
	   ,NULL			  AS [lwfnAdjusterID]
	   ,ISNULL('comments : ' + NULLIF(CONVERT(VARCHAR(MAX), C.comments), '') + CHAR(13), '') +
		ISNULL('Attorney for party : ' + NULLIF(CONVERT(VARCHAR(MAX), IOCD.name), '') + CHAR(13), '') +
		''				  AS [lwfsComments]
	   ,c.id			  AS [saga]
	FROM [BrianWhiteNeos].[dbo].[counsel_Indexed] C
	--LEFT JOIN [BrianWhiteNeos].[dbo].[user_counsel_data] UD on UD.counsel_id=C.counsel_id and C.case_num=UD.casenum
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), C.casesid)
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), C.counselnamesid)
	JOIN IndvOrgContacts_Indexed IOCD
		ON IOCD.SAGA_ref = CONVERT(VARCHAR(50), C.representingnamesid)
	JOIN [sma_TRN_Defendants] D
		ON D.defnContactID = IOCD.CID
			AND D.defnContactCtgID = IOCD.CTG
			AND D.defnCaseID = CAS.casnCaseID
GO


----(3)---- Plaintiff Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID
   ,UniqueContactID
   ,IsDefendant
   ,IsPrimary
	)
	SELECT
		A.LawFirmID			AS SourceTableRowID
	   ,A.AttorneyContactID AS UniqueAontactID
	   ,0					AS IsDefendant
	   , --0:Plaintiff
		CASE
			WHEN A.SequenceNumber = 1
				THEN 1
			ELSE 0
		END					AS IsPrimary
	FROM (
		SELECT
			F.planAtnID AS LawFirmID
		   ,AC.UniqueContactId AS AttorneyContactID
		   ,ROW_NUMBER() OVER (PARTITION BY F.planCaseID ORDER BY F.planAtnID) AS SequenceNumber
		FROM [sma_TRN_PlaintiffAttorney] F
		LEFT JOIN sma_MST_AllContactInfo AC
			ON AC.ContactCtg = 1
			AND AC.ContactId = F.planAtorneyContactID
	) A
	WHERE A.AttorneyContactID IS NOT NULL
GO


----(4)---- Defense Attorney list
INSERT INTO sma_TRN_LawFirmAttorneys
	(
	SourceTableRowID
   ,UniqueContactID
   ,IsDefendant
   ,IsPrimary
	)
	SELECT
		A.LawFirmID			AS SourceTableRowID
	   ,A.AttorneyContactID AS UniqueAontactID
	   ,1					AS IsDefendant
	   ,CASE
			WHEN A.SequenceNumber = 1
				THEN 1
			ELSE 0
		END					AS IsPrimary
	FROM (
		SELECT
			F.lwfnLawFirmID AS LawFirmID
		   ,AC.UniqueContactId AS AttorneyContactID
		   ,ROW_NUMBER() OVER (PARTITION BY F.lwfnModifyUserID ORDER BY F.lwfnLawFirmID) AS SequenceNumber
		FROM [sma_TRN_LawFirms] F
		LEFT JOIN sma_MST_AllContactInfo AC
			ON AC.ContactCtg = 1
			AND AC.ContactId = F.lwfnAttorneyContactID
	) A
	WHERE A.AttorneyContactID IS NOT NULL
GO


---(Appendix)----
UPDATE sma_MST_IndvContacts
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
FROM (
	SELECT
		I.cinnContactID AS ID
	--select *
	FROM [BrianWhiteNeos].[dbo].[counsel_Indexed] C
	JOIN [BrianWhiteNeos].[dbo].[names] L
		ON C.counselnamesid = L.id
	JOIN [dbo].[sma_MST_IndvContacts] I
		ON saga_ref = CONVERT(VARCHAR(50), L.id)
	WHERE L.person = 1
) A
WHERE cinnContactID = A.ID
GO
---
ALTER TABLE [sma_TRN_PlaintiffAttorney] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirms] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_LawFirmAttorneys] ENABLE TRIGGER ALL
GO
---

