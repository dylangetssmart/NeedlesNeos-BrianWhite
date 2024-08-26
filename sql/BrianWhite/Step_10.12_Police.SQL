
USE [SANeosBrianWhite]
GO
/*
alter table [sma_TRN_PoliceReports] disable trigger all
delete from [sma_TRN_PoliceReports]
DBCC CHECKIDENT ('[sma_TRN_PoliceReports]', RESEED, 0);
alter table [sma_TRN_PoliceReports] enable trigger all
*/

ALTER TABLE [sma_TRN_PoliceReports]
ALTER COLUMN porsComments VARCHAR(MAX)
GO
/*
select distinct [police dept], n.fullname_lastfirst, u.officer--, u.Badge
from NeosBrianWhite..NeosUserTab6 u
JOIN NeosBrianWhite..names n on u.[police dept] = convert(varchar(50),n.id)
WHERE isnull([police dept],'') <>''
and isnull(officer,'') NOT IN ('','N/A','?','NONE')
*/

---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE [name] = 'Officer_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Officer_Helper
END
GO

CREATE TABLE Officer_Helper (
	OfficerCID INT
   ,OfficerCTG INT
   ,OfficerAID INT
   ,officerUNQCID INT
   ,cinsGrade VARCHAR(400)
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Officer_Helper ON [Officer_Helper] (cinsGrade);
----
GO
---(0)---
INSERT INTO Officer_Helper
	(
	OfficerCID
   ,OfficerCTG
   ,OfficerAID
   ,officerUNQCID
   ,cinsGrade
	)
	SELECT DISTINCT
		I.cinnContactID														 AS OfficerCID
	   ,I.cinnContactCtg													 AS OfficerCTG
	   ,A.addnAddressID														 AS OfficerAID
	   ,CONVERT(VARCHAR, cinnContactCtg) + CONVERT(VARCHAR, i.cinnContactID) AS officerUNQCID
	   ,I.cinsGrade
	FROM NeosBrianWhite..NeosUserTab6 P   --BRIAN WHITE POLICE DATA COMES FROM TAB6, NOT THE POLICE TABLE
	JOIN [sma_MST_IndvContacts] I
		ON I.cinsGrade = P.officer
			AND I.cinsPrefix = 'Officer'
	JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
			AND A.addnContactCtgID = I.cinnContactCtg
			AND A.addbPrimary = 1
GO

DBCC DBREINDEX ('Officer_Helper', ' ', 90) WITH NO_INFOMSGS


---(0)---
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'Police_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Police_Helper
END
GO

CREATE TABLE Police_Helper (
	PoliceCID INT
   ,PoliceCTG INT
   ,PoliceAID INT
   ,PoliceUNQCID INT
   ,police_id VARCHAR(50)
   ,case_num VARCHAR(50)
   ,casnCaseID INT
   ,officerCID INT
   ,officerAID INT
   ,officerUNQcid INT
)
GO
----
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Police_Helper ON [Police_Helper] (police_id);
----
GO

INSERT INTO Police_Helper
	(
	PoliceCID
   ,PoliceCTG
   ,PoliceAID
   ,PoliceUNQCID
   ,police_id
   ,case_num
   ,casnCaseID
   ,officerCID
   ,officerAID
   ,officerUNQcid
	)
	SELECT
		IOC.CID								   AS PoliceCID
	   ,IOC.CTG								   AS PoliceCTG
	   ,IOC.AID								   AS PoliceAID
	   ,ioc.unqcid							   AS PoliceUNQCID
	   ,CONVERT(VARCHAR(50), PD.[Police Dept]) AS police_id
	   ,pd.casesid
	   ,CAS.casnCaseID						   AS casnCaseID
	   ,(
			SELECT
				H.OfficerCID
			FROM Officer_Helper H
			WHERE H.cinsGrade = pd.officer
		)									   
		AS officerCID
	   ,(
			SELECT
				H.OfficerAID
			FROM Officer_Helper H
			WHERE H.cinsGrade = pd.officer
		)									   
		AS officerAID
	   ,(
			SELECT
				H.officerUNQCID
			FROM Officer_Helper H
			WHERE H.cinsGrade = pd.officer
		)									   
		AS officerUNQCID
	FROM NeosBrianWhite..NeosUserTab6 pd
	JOIN [sma_TRN_cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), pd.casesid)
	JOIN [IndvOrgContacts_Indexed] IOC
		ON IOC.SAGA_ref = CONVERT(VARCHAR(50), Pd.[Police Dept])
GO

DBCC DBREINDEX ('Police_Helper', ' ', 90) WITH NO_INFOMSGS
GO

---
ALTER TABLE [sma_TRN_PoliceReports] DISABLE TRIGGER ALL
GO
---
---(2)---
INSERT INTO [sma_TRN_PoliceReports]
	(
	[pornCaseID]
   ,[pornPoliceID]
   ,[pornPoliceAdID]
   ,[porsReportNo]
   ,[porsComments]
   ,[pornPOContactID]
   ,[pornPOCtgID]
   ,[pornPOAddressID]
	)
	SELECT
		MAP.casnCaseID				AS pornCaseID
	   ,MAP.officerCID				AS pornPoliceID
	   ,MAP.officerAID				AS pornPoliceAdID
	   ,LEFT(P.[Report Number], 30) AS porsReportNo
	   ,ISNULL('Badge: ' + NULLIF(P.badge, '') + CHAR(13), '') +
		ISNULL('Police Report? ' + NULLIF(P.[Police Report?], '') + CHAR(13), '') +
		ISNULL('Police Report Scanned? ' + NULLIF(P.[Police Report Scanned?], '') + CHAR(13), '') +
		ISNULL('Statement Taken? ' + NULLIF(P.[statement taken?], '') + CHAR(13), '') +
		ISNULL('Statement Context: ' + NULLIF(P.[statement context], '') + CHAR(13), '') +
		ISNULL('Photographs: ' + NULLIF(P.[Photographs], '') + CHAR(13), '') +
		ISNULL('Photos Taken at Accident: ' + NULLIF(P.[Photos Taken At Accident], '') + CHAR(13), '') +
		''							AS porsComments
	   ,MAP.PoliceCID				AS [pornPOContactID]
	   ,MAP.PoliceCTG				AS [pornPOCtgID]
	   ,MAP.PoliceAID				AS [pornPOAddressID]
	--select max(len([statement context]))
	FROM NeosBrianWhite..NeosUserTab6 p
	JOIN Police_Helper MAP
		ON MAP.case_num = CONVERT(VARCHAR(50), P.casesid)
	WHERE ISNULL([Police Dept], '') <> ''
		OR ISNULL([Police Report?], '') <> ''
		OR ISNULL(Badge, '') <> ''
		OR ISNULL(p.[statement taken?], '') <> ''
		OR ISNULL(p.[statement context], '') <> ''
		OR ISNULL(p.[Report Number], '') <> ''
GO

---
ALTER TABLE [sma_TRN_PoliceReports] ENABLE TRIGGER ALL
GO
---

------------------------------------------------------------
--INSERT BADGE NUMBER INTO POLICE OFFICER CONTACT UDF
------------------------------------------------------------
INSERT INTO sma_TRN_UDFValues
	(
	udvnUDFID
   ,udvsScreenName
   ,udvsUDFCtg
   ,udvnRelatedID
   ,udvnSubRelatedID
   ,udvsUDFValue
   ,udvnRecUserID
   ,udvdDtCreated
	)
	SELECT DISTINCT
		(
			SELECT
				udfnUDFID
			FROM sma_MST_UDFDefinition
			WHERE udfsUDFName LIKE '%Badge #%'
				AND udfnRelatedPK = (
					SELECT
						octnOrigContactTypeID
					FROM [dbo].[sma_MST_OriginalContactTypes]
					WHERE octsDscrptn = 'Police Officer'
				)
		)			   
		AS udvnUDFID
	   ,''			   AS udvsScreenName
	   ,'R'			   AS udvsUDFCtg
	   ,map.officerCID AS udvnRelatedID
	   ,1			   AS udvnSubRelatedID
	   ,p.Badge		   AS udvsUDFValue
	   ,368			   AS udvnRecUserID
	   ,GETDATE()	   AS udvdDtCreated
	FROM NeosBrianWhite..NeosUserTab6 p
	JOIN Police_Helper MAP
		ON MAP.case_num = CONVERT(VARCHAR(50), P.casesid)
	WHERE ISNULL(officer, '') NOT IN ('', 'N/A', '?', 'NONE')
		AND ISNULL(Badge, '') <> ''

