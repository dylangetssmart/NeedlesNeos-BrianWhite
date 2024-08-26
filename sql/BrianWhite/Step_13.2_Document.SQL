
USE [SANeosBrianWhite]
GO

/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/


/*
IF OBJECT_ID (N'dbo.FileNamePart', N'FN') IS NOT NULL
    DROP FUNCTION FileNamePart;
GO
CREATE FUNCTION dbo.FileNamePart(@parameter varchar(MAX) )
RETURNS varchar(MAX) 
AS 

BEGIN
	declare @trimParameter varchar(MAX)=ltrim(rtrim(@parameter));
    DECLARE @return varchar(MAX);
	declare @position int =convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0)))
	set @return=substring (right(@trimParameter,@position),2,1000)
    RETURN @return;
END;
GO

---(0)---

IF OBJECT_ID (N'dbo.PathPart', N'FN') IS NOT NULL
    DROP FUNCTION PathPart;
GO
CREATE FUNCTION dbo.PathPart(@parameter varchar(MAX) )
RETURNS varchar(MAX) 
AS 

BEGIN
	declare @trimParameter varchar(MAX)=ltrim(rtrim(@parameter));
    DECLARE @return varchar(MAX);
	if ((len(@trimParameter) + 2 - convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0)))) < 0 )
	begin
		set @return=@trimParameter
	END
	ELSE
	BEGIN
		SET @return=substring(@trimParameter,0,len(@trimParameter) + 2 - convert(int,(SELECT CHARINDEX('\', REVERSE (@trimParameter), 0))))
	end
		RETURN @return;
END;
GO
*/

---(0)---
INSERT INTO [sma_MST_ScannedDocCategories]
	(
	sctgsCategoryName
	)
	(
	SELECT DISTINCT
		cat.[name] AS sctgsCategoryName
	FROM [NeosBrianWhite].[dbo].[documents] doc
	JOIN [NeosBrianWhite].[dbo].[document_category] cat
		ON doc.doc_category_id = cat.id
	UNION
	SELECT
		'Other'
	)
	EXCEPT
	SELECT
		sctgsCategoryName
	FROM [sma_MST_ScannedDocCategories]
GO

ALTER TABLE [dbo].[sma_TRN_Documents]
ALTER COLUMN [docsToContact] [VARCHAR](120) NULL
GO

----

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Documents')
	)
BEGIN
	ALTER TABLE [sma_TRN_Documents] ADD [saga] [VARCHAR](50) NULL;
END
GO
----

ALTER TABLE [sma_TRN_Documents] DISABLE TRIGGER ALL
GO
SET QUOTED_IDENTIFIER ON

---(1)---


/*
alter table [sma_TRN_Documents] disable trigger all
delete from [sma_TRN_Documents] 
DBCC CHECKIDENT ('[sma_TRN_Documents]', RESEED, 0);
alter table [sma_TRN_Documents] enable trigger all
*/

INSERT INTO [sma_TRN_Documents]
	(
	[docnCaseID]
   ,[docsDocumentName]
   ,[docsDocumentPath]
   ,[docsDocumentData]
   ,[docnCategoryID]
   ,[docnSubCategoryID]
   ,[docnFromContactCtgID]
   ,[docnFromContactID]
   ,[docsToContact]
   ,[docsDocType]
   ,[docnTemplateID]
   ,[docbAttachFlag]
   ,[docsDescrptn]
   ,[docnAuthor]
   ,[docsDocsrflag]
   ,[docnRecUserID]
   ,[docdDtCreated]
   ,[docnModifyUserID]
   ,[docdDtModified]
   ,[docnLevelNo]
   ,[ctgnCategoryID]
   ,[sctnSubCategoryID]
   ,[sctssSubSubCategoryID]
   ,[sctsssSubSubSubCategoryID]
   ,[docnMedProvContactctgID]
   ,[docnMedProvContactID]
   ,[docnComments]
   ,[docnReasonReject]
   ,[docsReviewerContactId]
   ,[docsReviewDate]
   ,[docsDocumentAnalysisResultId]
   ,[docsIsReviewed]
   ,[docsToContactID]
   ,[docsToContactCtgID]
   ,[docdLastUpdated]
   ,[docnPriority]
   ,[saga]
	)

	SELECT
		CAS.casnCaseID				 AS [docnCaseID]
	   ,doc.[file_name]				 AS [docsDocumentName]
	   ,odi.web_url					 AS [docsDocumentPath]
	   ,''							 AS [docsDocumentData]
	   ,NULL						 AS [docnCategoryID]
	   ,NULL						 AS [docnSubCategoryID]
	   ,auth.CTG					 AS [docnFromContactCtgID]
	   ,auth.CID					 AS [docnFromContactID]
	   ,NULL						 AS [docsToContact]
	   ,'Doc'						 AS [docsDocType]
	   ,NULL						 AS [docnTemplateID]
	   ,NULL						 AS [docbAttachFlag]
	   ,doc.[file_name]				 AS [docsDescrptn]
	   ,0							 AS [docnAuthor]
	   ,''							 AS [docsDocsrflag]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.staffcreatedid
		)							 
		AS [docnRecUserID]
	   ,doc.date_created			 AS [docdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = doc.staffmodifiedid
		)							 
		AS [docnModifyUserID]
	   ,doc.date_modified			 AS [docdDtModified]
	   ,''							 AS [docnLevelNo]
	   ,CASE
			WHEN EXISTS (
					SELECT
						*
					FROM sma_MST_ScannedDocCategories
					WHERE sctgsCategoryName = cat.[name]
				)
				THEN (
						SELECT
							sctgnCategoryID
						FROM sma_MST_ScannedDocCategories
						WHERE sctgsCategoryName = cat.[name]
					)
			ELSE (
					SELECT
						sctgnCategoryID
					FROM sma_MST_ScannedDocCategories
					WHERE sctgsCategoryName = 'Other/Misc'
				)
		END							 AS [ctgnCategoryID]
	   ,NULL						 AS [sctnSubCategoryID]
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,3							 AS [docnPriority]
	   ,  -- normal priority
		CONVERT(VARCHAR(50), doc.id) AS [saga]
	--SELECT *
	FROM [NeosBrianWhite].[dbo].[documents] DOC
	JOIN [NeosBrianWhite].[dbo].[one_drive_items] odi
		ON doc.onedriveitemid = odi.id
	LEFT JOIN [NeosBrianWhite].[dbo].[document_category] cat
		ON doc.doc_category_id = cat.id
	LEFT JOIN IndvOrgContacts_Indexed auth
		ON auth.saga_ref = CONVERT(VARCHAR(50), doc.author)
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), DOC.cases_id)
GO


ALTER TABLE [sma_TRN_Documents] ENABLE TRIGGER ALL
GO

