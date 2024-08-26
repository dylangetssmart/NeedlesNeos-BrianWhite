
USE BrianWhiteSA
GO
/*
alter table [sma_trn_caseJudgeorClerk] disable trigger all
delete from [sma_trn_caseJudgeorClerk]
DBCC CHECKIDENT ('[sma_trn_caseJudgeorClerk]', RESEED, 0);
alter table [sma_trn_caseJudgeorClerk] enable trigger all

alter table [sma_TRN_CourtDocket] disable trigger all
delete from [sma_TRN_CourtDocket]
DBCC CHECKIDENT ('[sma_TRN_CourtDocket]', RESEED, 0);
alter table [sma_TRN_CourtDocket] enable trigger all

alter table [sma_TRN_Courts] disable trigger all
delete from [sma_TRN_Courts]
DBCC CHECKIDENT ('[dbo].[sma_TRN_Courts]', RESEED, 0);
alter table [sma_TRN_Courts] enable trigger all
*/

---
ALTER TABLE [sma_trn_caseJudgeorClerk] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_CourtDocket] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Courts] DISABLE TRIGGER ALL
GO
---

/*
select * 
FROM [BrianWhiteNeos].[dbo].[cases] C
WHERE isnull(convert(varchar(50),court_namesid),'')<>''
or isnull(convert(varchar(50),judge_namesid),'')<>''
or isnull(docket,'') <> ''
*/


---(1)---
INSERT INTO [sma_TRN_Courts]
	(
	crtnCaseID
   ,crtnCourtID
   ,crtnCourtAddId
   ,crtnIsActive
	--crtnLevelNo 
	)
	SELECT
		A.casnCaseID AS crtnCaseID
	   ,A.CID		 AS crtnCourtID
	   ,A.AID		 AS crtnCourtAddId
	   ,1			 AS crtnIsActive
	FROM (
		SELECT
			CAS.casnCaseID
		   ,IOC.CID
		   ,IOC.AID
		--C.judge_link
		--select *
		FROM [BrianWhiteNeos].[dbo].[cases] C
		JOIN [sma_TRN_cases] CAS
			ON CAS.Neos_Saga = CONVERT(VARCHAR(50), C.id)
		JOIN IndvOrgContacts_Indexed IOC
			ON IOC.SAGA = CONVERT(VARCHAR(50), C.court_Namesid)
		WHERE ISNULL(CONVERT(VARCHAR(50), C.court_Namesid), '') <> ''

		UNION
		SELECT
			CAS.casnCaseID
		   ,IOC.CID
		   ,IOC.AID
		--C.judge_link
		FROM [BrianWhiteNeos].[dbo].[cases_Indexed] C
		JOIN [sma_TRN_cases] CAS
			ON CAS.Neos_Saga = C.id
		JOIN IndvOrgContacts_Indexed IOC
			ON IOC.SAGA = '-1'
			AND IOC.[Name] = 'Unidentified Court'
		WHERE ISNULL(CONVERT(VARCHAR(50), court_namesid), '') = ''
			AND (ISNULL(CONVERT(VARCHAR(50), judge_namesid), '') <> ''
			OR ISNULL(docket, '') <> '')
	) A
GO

---------------------------------------------------
--UPDATE COURT CAPTION FIELDS
---------------------------------------------------
UPDATE sma_TRN_Courts
SET crtsPlaintiffCaption = c.[Plaintiff Caption]
   ,crtsDefendantCaption = c.[Defendant Caption]
   ,crtsComment = ISNULL('Type of Court : ' + NULLIF(CONVERT(VARCHAR(MAX), d.code), '') + CHAR(13), '') + ''
FROM BrianWhiteNeos..NeosUserCase c
LEFT JOIN BrianWhiteNeos..mini_general_dir d
	ON d.id = c.[type of court]
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), C.casesid)
JOIN sma_trn_Courts crt
	ON crt.crtnCaseID = cas.casnCaseID
GO

--------------------
--COURT DOCKET
--------------------
INSERT INTO [sma_TRN_CourtDocket]
	(
	crdnCourtsID
   ,crdnIndexTypeID
   ,crdnDocketNo
   ,crdddate
   ,crdnPrice
   ,crdbActiveInActive
   ,crdsEfile
   ,crdsComments
	)
	SELECT
		crtnPKCourtsID AS crdnCourtsID
	   ,(
			SELECT
				idtnIndexTypeID
			FROM sma_MST_IndexType
			WHERE idtsDscrptn = 'Docket Number'
		)			   
		AS crdnIndexTypeID
	   ,CASE
			WHEN ISNULL(C.docket, '') <> ''
				THEN LEFT(C.docket, 30)
			ELSE 'Case-' + CAS.cassCaseNumber
		END			   AS crdnDocketNo
	   ,NULL		   AS crdddate
	   ,0			   AS crdnPrice
	   ,1			   AS crdbActiveInActive
	   ,0			   AS crdsEfile
	   ,'Docket Number:' + LEFT(C.docket, 30)
		AS crdsComments
	FROM [sma_TRN_Courts] CRT
	JOIN [sma_TRN_cases] CAS
		ON CAS.casnCaseID = CRT.crtnCaseID
	JOIN [BrianWhiteNeos].[dbo].[cases_indexed] C
		ON CONVERT(VARCHAR(50), c.id) = CAS.Neos_Saga
GO


--------------------------
--INSERT JUDGE
--------------------------
INSERT INTO [sma_trn_caseJudgeorClerk]
	(
	crtDocketID
   ,crtJudgeorClerkContactID
   ,crtJudgeorClerkContactCtgID
   ,crtJudgeorClerkRoleID
	)
	SELECT DISTINCT
		CRD.crdnCourtDocketID AS crtDocketID
	   ,IOC.CID				  AS crtJudgeorClerkContactID
	   ,IOC.CTG				  AS crtJudgeorClerkContactCtgID
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM sma_MST_OriginalContactTypes
			WHERE octsDscrptn = 'Judge'
		)					  
		AS crtJudgeorClerkRoleID
	FROM [sma_TRN_CourtDocket] CRD
	JOIN [sma_TRN_Courts] CRT
		ON CRT.crtnPKCourtsID = CRD.crdnCourtsID
	JOIN sma_trn_Cases cas
		ON cas.casnCaseID = crt.crtnCaseID
	JOIN [BrianWhiteNeos]..[cases_indexed] ci
		ON CONVERT(VARCHAR(50), ci.id) = cas.Neos_Saga
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.SAGA = CONVERT(VARCHAR(50), ci.judge_namesid)

