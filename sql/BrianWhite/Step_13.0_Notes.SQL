USE [SANeosBrianWhite]
GO

/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/

IF NOT EXISTS (
		SELECT
			*
		FROM sys.tables t
		JOIN sys.columns c
			ON t.object_id = c.object_id
		WHERE t.name = 'sma_trn_notes'
			AND c.name = 'saga'
	)
BEGIN
	ALTER TABLE sma_trn_notes
	ADD SAGA VARCHAR(50)
END
GO

----(0)----
INSERT INTO [sma_MST_NoteTypes]
	(
	nttsDscrptn
   ,nttsNoteText
	)
	SELECT DISTINCT
		topic AS nttsDscrptn
	   ,topic AS nttsNoteText
	FROM [NeosBrianWhite].[dbo].[case_notes_Indexed] cn
	JOIN [NeosBrianWhite]..[case_note_topic] t
		ON cn.casenotetopicid = t.id
	EXCEPT
	SELECT
		nttsDscrptn
	   ,nttsNoteText
	FROM [sma_MST_NoteTypes]
GO

---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---
----(1)----
INSERT INTO [sma_TRN_Notes]
	(
	[notnCaseID]
   ,[notnNoteTypeID]
   ,[notmDescription]
   ,[notmPlainText]
   ,[notnContactCtgID]
   ,[notnContactId]
   ,[notsPriority]
   ,[notnFormID]
   ,[notnRecUserID]
   ,[notdDtCreated]
   ,[notnModifyUserID]
   ,[notdDtModified]
   ,[notnLevelNo]
   ,[notdDtInserted]
   ,[WorkPlanItemId]
   ,[notnSubject]
   ,SAGA
	)
	SELECT
		casnCaseID						AS [notnCaseID]
	   ,(
			SELECT
				MIN(nttnNoteTypeID)
			FROM [sma_MST_NoteTypes]
			WHERE nttsDscrptn = t.topic
		)								
		AS [notnNoteTypeID]
	   ,note							AS [notmDescription]
	   ,REPLACE(note, CHAR(10), '<br>') AS [notmPlainText]
	   ,0								AS [notnContactCtgID]
	   ,NULL							AS [notnContactId]
	   ,NULL							AS [notsPriority]
	   ,NULL							AS [notnFormID]
	   ,U.usrnUserID					AS [notnRecUserID]
	   ,CASE
			WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN n.note_date
			ELSE '1900-01-01'
		END								AS notdDtCreated
	   ,NULL							AS [notnModifyUserID]
	   ,NULL							AS notdDtModified
	   ,NULL							AS [notnLevelNo]
	   ,NULL							AS [notdDtInserted]
	   ,NULL							AS [WorkPlanItemId]
	   ,NULL							AS [notnSubject]
	   ,CONVERT(VARCHAR(50), n.ID)		AS SAGA
	--select *
	FROM [NeosBrianWhite].[dbo].[case_notes_Indexed] N
	LEFT JOIN [NeosBrianWhite]..[case_note_topic] t
		ON n.casenotetopicid = t.id
	JOIN [sma_TRN_Cases] C
		ON C.Neos_Saga = CONVERT(VARCHAR(50), N.casesid)
	LEFT JOIN [sma_MST_Users] U
		ON U.saga = CONVERT(VARCHAR(50), N.staffcreatedid)
	LEFT JOIN [sma_TRN_Notes] ns
		ON ns.saga = CONVERT(VARCHAR(50), n.ID)
	WHERE ns.notnNoteID IS NULL
GO


---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---

