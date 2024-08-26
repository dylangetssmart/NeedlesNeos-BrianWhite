
USE [BrianWhiteSA]
GO
/*
alter table [sma_MST_ContactNumbers] disable trigger all
delete from [sma_MST_ContactNumbers] 
DBCC CHECKIDENT ('[sma_MST_ContactNumbers]', RESEED, 0);
alter table [sma_MST_ContactNumbers] enable trigger all
*/


---(0)---
INSERT INTO sma_MST_ContactNoType
	(
	ctysDscrptn
   ,ctynContactCategoryID
   ,ctysDefaultTexting
	)
	SELECT
		'Fax'
	   ,1
	   ,0
	UNION
	SELECT
		'Other'
	   ,1
	   ,0
	UNION
	SELECT
		'Home Phone'
	   ,2
	   ,0
	UNION
	SELECT
		'Other'
	   ,2
	   ,0
	EXCEPT
	SELECT
		ctysDscrptn
	   ,ctynContactCategoryID
	   ,ctysDefaultTexting
	FROM sma_MST_ContactNoType


---(0)----
IF OBJECT_ID(N'dbo.FormatPhone', N'FN') IS NOT NULL
	DROP FUNCTION FormatPhone;
GO
CREATE FUNCTION dbo.FormatPhone (@phone VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF LEN(@phone) = 10
		AND ISNUMERIC(@phone) = 1
	BEGIN
		RETURN '(' + SUBSTRING(@phone, 1, 3) + ') ' + SUBSTRING(@phone, 4, 3) + '-' + SUBSTRING(@phone, 7, 4) ---> this is good for perecman
	END
	RETURN @phone;
END;
GO

---
ALTER TABLE [sma_MST_ContactNumbers] DISABLE TRIGGER ALL
GO
---

INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
   ,[Comments]
	)
	SELECT
		C.cinnContactCtg		  AS cnnnContactCtgID
	   ,C.cinnContactID			  AS cnnnContactID
	   ,ctynContactNoTypeID		  AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(n.number) AS cnnsContactNumber
	   ,n.extension				  AS cnnsExtension
	   ,CASE
			WHEN n.sort_order = 1
				THEN 1
			ELSE 0
		END						  AS cnnbPrimary
	   ,NULL					  AS cnnbVisible
	   ,A.addnAddressID			  AS cnnnAddressID
	   ,ct.ctysDscrptn			  AS cnnsLabelCaption
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = staffcreatedid
		)						  
		AS cnnnRecUserID
	   ,date_created			  AS cnndDtCreated
	   ,368						  AS cnnnModifyUserID
	   ,GETDATE()				  AS cnndDtModified
	   ,NULL
	   ,NULL
	   ,ISNULL('Phone Type: ' + NULLIF(CONVERT(VARCHAR, n.[title]), '') + CHAR(13), '') +
		''						  AS [Comments]
	--select *
	FROM [BrianWhiteNeos].[dbo].[phone] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.namesid)
	LEFT JOIN sma_MST_ContactNoType ct
		ON ctynContactCategoryID = 1
			AND ct.ctysDscrptn = CASE
				WHEN n.title = 'Mobile'
					THEN 'Cell'
				WHEN n.title = 'Home'
					THEN 'Home Primary Phone'
				WHEN n.title = 'Business'
					THEN 'HQ/Main Office Phone'
				WHEN n.title = 'Fax'
					THEN 'Fax'
				ELSE 'Other'
			END
	JOIN [sma_MST_Address] A
		ON A.addnContactID = C.cinnContactID
			AND A.addnContactCtgID = C.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(N.number, '') <> ''

--STAFF MAIN NUMBER
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
   ,[Comments]
	)
	SELECT
		C.cinnContactCtg				AS cnnnContactCtgID
	   ,C.cinnContactID					AS cnnnContactID
	   ,ctynContactNoTypeID				AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(n.phone_number) AS cnnsContactNumber
	   ,n.extension						AS cnnsExtension
	   ,1								AS cnnbPrimary
	   ,NULL							AS cnnbVisible
	   ,A.addnAddressID					AS cnnnAddressID
	   ,ct.ctysDscrptn					AS cnnsLabelCaption
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = staffcreatedid
		)								
		AS cnnnRecUserID
	   ,date_created					AS cnndDtCreated
	   ,368								AS cnnnModifyUserID
	   ,GETDATE()						AS cnndDtModified
	   ,NULL
	   ,NULL
	   ,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''								AS [Comments]
	--select *
	FROM [BrianWhiteNeos].[dbo].[staff] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.id)
	LEFT JOIN sma_MST_ContactNoType ct
		ON ctynContactCategoryID = 1
			AND ct.ctysDscrptn = 'HQ/Main Office Phone'
	JOIN [sma_MST_Address] A
		ON A.addnContactID = C.cinnContactID
			AND A.addnContactCtgID = C.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(N.phone_number, '') <> ''



--STAFF FAX NUMBER
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
   ,[Comments]
	)
	SELECT
		C.cinnContactCtg			  AS cnnnContactCtgID
	   ,C.cinnContactID				  AS cnnnContactID
	   ,ctynContactNoTypeID			  AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(n.fax_number) AS cnnsContactNumber
	   ,NULL						  AS cnnsExtension
	   ,1							  AS cnnbPrimary
	   ,NULL						  AS cnnbVisible
	   ,A.addnAddressID				  AS cnnnAddressID
	   ,ct.ctysDscrptn				  AS cnnsLabelCaption
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = staffcreatedid
		)							  
		AS cnnnRecUserID
	   ,date_created				  AS cnndDtCreated
	   ,368							  AS cnnnModifyUserID
	   ,GETDATE()					  AS cnndDtModified
	   ,NULL
	   ,NULL
	   ,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''							  AS [Comments]
	--select *
	FROM [BrianWhiteNeos].[dbo].[staff] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.id)
	LEFT JOIN sma_MST_ContactNoType ct
		ON ctynContactCategoryID = 1
			AND ct.ctysDscrptn = 'Fax'
	JOIN [sma_MST_Address] A
		ON A.addnContactID = C.cinnContactID
			AND A.addnContactCtgID = C.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(N.fax_number, '') <> ''


--STAFF MOBILE NUMBER
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
   ,[Comments]
	)
	SELECT
		C.cinnContactCtg				 AS cnnnContactCtgID
	   ,C.cinnContactID					 AS cnnnContactID
	   ,ctynContactNoTypeID				 AS cnnnPhoneTypeID
	   ,dbo.FormatPhone(n.mobile_number) AS cnnsContactNumber
	   ,NULL							 AS cnnsExtension
	   ,1								 AS cnnbPrimary
	   ,NULL							 AS cnnbVisible
	   ,A.addnAddressID					 AS cnnnAddressID
	   ,ct.ctysDscrptn					 AS cnnsLabelCaption
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = staffcreatedid
		)								 
		AS cnnnRecUserID
	   ,date_created					 AS cnndDtCreated
	   ,368								 AS cnnnModifyUserID
	   ,GETDATE()						 AS cnndDtModified
	   ,NULL
	   ,NULL
	   ,
		--isnull('Phone Type: ' + nullif(convert(varchar,n.[title]),'') + CHAR(13),'') +
		''								 AS [Comments]
	--select *
	FROM [BrianWhiteNeos].[dbo].[staff] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.id)
	LEFT JOIN sma_MST_ContactNoType ct
		ON ctynContactCategoryID = 1
			AND ct.ctysDscrptn = 'Cell'
	JOIN [sma_MST_Address] A
		ON A.addnContactID = C.cinnContactID
			AND A.addnContactCtgID = C.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(N.mobile_number, '') <> ''

------------------------------------
--ORG CONTACT PHONE NUMBERS 
------------------------------------
INSERT INTO [sma_MST_ContactNumbers]
	(
	[cnnnContactCtgID]
   ,[cnnnContactID]
   ,[cnnnPhoneTypeID]
   ,[cnnsContactNumber]
   ,[cnnsExtension]
   ,[cnnbPrimary]
   ,[cnnbVisible]
   ,[cnnnAddressID]
   ,[cnnsLabelCaption]
   ,[cnnnRecUserID]
   ,[cnndDtCreated]
   ,[cnnnModifyUserID]
   ,[cnndDtModified]
   ,[cnnnLevelNo]
   ,[caseNo]
	)
	SELECT
		C.connContactCtg		  AS cnnnContactCtgID
	   ,C.connContactID			  AS cnnnContactID
	   ,ctynContactNoTypeID		  AS cnnnPhoneTypeID
	   ,   -- Office Phone 
		dbo.FormatPhone(n.number) AS cnnsContactNumber
	   ,extension				  AS cnnsExtension
	   ,CASE
			WHEN n.sort_order = 1
				THEN 1
			ELSE 0
		END						  AS cnnbPrimary
	   ,NULL					  AS cnnbVisible
	   ,A.addnAddressID			  AS cnnnAddressID
	   ,ct.ctysDscrptn			  AS cnnsLabelCaption
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = staffcreatedid
		)						  
		AS cnnnRecUserID
	   ,date_created			  AS cnndDtCreated
	   ,368						  AS cnnnModifyUserID
	   ,GETDATE()				  AS cnndDtModified
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[phone] N
	JOIN [sma_MST_OrgContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.namesid)
	LEFT JOIN sma_MST_ContactNoType ct
		ON ctynContactCategoryID = 2
			AND ct.ctysDscrptn = CASE
				WHEN n.title = 'Mobile'
					THEN 'Cell'
				WHEN n.title = 'Home'
					THEN 'Home Phone'
				WHEN n.title = 'Business'
					THEN 'Office Phone'
				WHEN n.title = 'Fax'
					THEN 'Office Fax'
				ELSE 'Other'
			END
	JOIN [sma_MST_Address] A
		ON A.addnContactID = C.connContactID
			AND A.addnContactCtgID = C.connContactCtg
			AND A.addbPrimary = 1
	WHERE ISNULL(n.number, '') <> ''




/*
---(Appendix) Finally, only one phone number as primary---
UPDATE [sma_MST_ContactNumbers] set cnnbPrimary=0
FROM (
SELECT 
	ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
	cnnnContactNumberID as ContactNumberID  
FROM [sma_MST_ContactNumbers] 
WHERE cnnnContactCtgID = (select ctgnCategoryID FROM [BrianWhiteSA].[dbo].[sma_MST_ContactCtg] where ctgsDesc='Individual')
) A
WHERE A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID


UPDATE [sma_MST_ContactNumbers] set cnnbPrimary=0
FROM (
SELECT 
	ROW_NUMBER() OVER (Partition BY cnnnContactID order by cnnnContactNumberID )  as RowNumber,
	cnnnContactNumberID as ContactNumberID  
FROM [sma_MST_ContactNumbers] 
WHERE cnnnContactCtgID = (select ctgnCategoryID FROM [BrianWhiteSA].[dbo].[sma_MST_ContactCtg] where ctgsDesc='Organization')
) A
WHERE A.RowNumber <> 1
and A.ContactNumberID=cnnnContactNumberID
*/
---
ALTER TABLE [sma_MST_ContactNumbers] ENABLE TRIGGER ALL
GO
--- 
