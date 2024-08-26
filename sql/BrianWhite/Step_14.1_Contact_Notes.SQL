
USE [BrianWhiteSA]
GO
/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/


---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0				 AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)				 
		AS notnNoteTypeID
	   ,CASE
			WHEN ISNULL(date_of_majority, '') = ''
				THEN 'Date of Majority : N/A'
			ELSE 'Date of Majority : ' + CONVERT(VARCHAR, date_of_majority)
		END				 AS notmDescription
	   ,CASE
			WHEN ISNULL(date_of_majority, '') = ''
				THEN 'Date of Majority : N/A'
			ELSE 'Date of Majority : ' + CONVERT(VARCHAR, date_of_majority)
		END				 AS notmPlainText
	   ,I.cinnContactCtg AS notnContactCtgID
	   ,I.cinnContactID	 AS notnContactId
	   ,'Normal'		 AS notsPriority
	   ,0				 AS notnFormID
	   ,368				 AS notnRecUserID
	   ,GETDATE()		 AS notdDtCreated
	   ,NULL			 AS notnModifyUserID
	   ,NULL			 AS notdDtModified
	FROM [BrianWhiteNeos].[dbo].[party] P
	JOIN sma_MST_IndvContacts I
		ON I.saga_ref = CONVERT(VARCHAR(50), P.namesid)

----(2)----
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0				 AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)				 
		AS notnNoteTypeID
	   ,CASE
			WHEN ISNULL(minor, '') = ''
				THEN 'Minor : N'
			ELSE 'Minor : ' + CONVERT(VARCHAR, minor)
		END				 AS notmDescription
	   ,CASE
			WHEN ISNULL(minor, '') = ''
				THEN 'Minor : N'
			ELSE 'Minor : ' + CONVERT(VARCHAR, minor)
		END				 AS notmPlainText
	   ,I.cinnContactCtg AS notnContactCtgID
	   ,I.cinnContactID	 AS notnContactId
	   ,'Normal'		 AS notsPriority
	   ,0				 AS notnFormID
	   ,368				 AS notnRecUserID
	   ,GETDATE()		 AS notdDtCreated
	   ,NULL			 AS notnModifyUserID
	   ,NULL			 AS notdDtModified
	FROM [BrianWhiteNeos].[dbo].[party] P
	JOIN sma_MST_IndvContacts I
		ON I.saga_ref = CONVERT(VARCHAR(50), P.namesid)


---(3)--- 
INSERT INTO sma_TRN_Notes
	(
	notnCaseID
   ,notnNoteTypeID
   ,notmDescription
   ,notmPlainText
   ,notnContactCtgID
   ,notnContactId
   ,notsPriority
   ,notnFormID
   ,notnRecUserID
   ,notdDtCreated
   ,notnModifyUserID
   ,notdDtModified
	)
	SELECT
		0		  AS notnCaseID
	   ,(
			SELECT
				nttnNoteTypeID
			FROM sma_MST_NoteTypes
			WHERE nttsCode = 'CONTACT'
		)		  
		AS notnNoteTypeID
	   ,PN.note	  AS notmDescription
	   ,PN.note	  AS notmPlainText
	   ,IOC.CTG	  AS notnContactCtgID
	   ,IOC.CID	  AS notnContactId
	   ,'Normal'  AS notsPriority
	   ,0		  AS notnFormID
	   ,368		  AS notnRecUserID
	   ,GETDATE() AS notdDtCreated
	   ,NULL	  AS notnModifyUserID
	   ,NULL	  AS notdDtModified
	FROM [BrianWhiteNeos].[dbo].[provider_notes] PN
	JOIN IndvOrgContacts_Indexed IOC
		ON IOC.saga_ref = CONVERT(VARCHAR(50), PN.providerid)

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---



