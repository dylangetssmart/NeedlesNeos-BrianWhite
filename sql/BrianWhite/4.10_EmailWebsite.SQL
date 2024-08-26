USE [SANeosBrianWhite]
GO
/*
alter table [sma_MST_EmailWebsite] disable trigger all
delete from [sma_MST_EmailWebsite] 
DBCC CHECKIDENT ('[sma_MST_EmailWebsite]', RESEED, 0);
alter table [sma_MST_EmailWebsite] enable trigger all
*/

---
ALTER TABLE [sma_MST_EmailWebsite] DISABLE TRIGGER ALL
GO
---------------------------------------------------------------------
----- (1/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR INDIVIDUAL -
---------------------------------------------------------------------

INSERT INTO [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID]
   ,[cewnContactID]
   ,[cewsEmailWebsiteFlag]
   ,[cewsEmailWebSite]
   ,[cewbDefault]
   ,[cewnRecUserID]
   ,[cewdDtCreated]
   ,[cewnModifyUserID]
   ,[cewdDtModified]
   ,[cewnLevelNo]
   ,[saga]
   ,[cewnComments]
	)
	SELECT
		C.cinnContactCtg AS cewnContactCtgID
	   ,C.cinnContactID	 AS cewnContactID
	   ,'E'				 AS cewsEmailWebsiteFlag
	   ,N.email			 AS cewsEmailWebSite
	   ,CASE
			WHEN [order] = 0
				THEN 1
			ELSE 0
		END				 AS cewbDefault
	   ,368				 AS cewnRecUserID
	   ,GETDATE()		 AS cewdDtCreated
	   ,368				 AS cewnModifyUserID
	   ,GETDATE()		 AS cewdDtModified
	   ,NULL
	   ,1				 AS saga
	   , -- indicate email
		ISNULL('Type: ' + NULLIF(CONVERT(VARCHAR, n.[type]), '') + CHAR(13), '') +
		''				 AS [cewnComments]
	FROM [NeosBrianWhite].[dbo].[email_accounts] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.namesId)
	WHERE ISNULL(email, '') <> ''

------------------------------
--INSERT EMAIL FOR STAFF
------------------------------
INSERT INTO [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID]
   ,[cewnContactID]
   ,[cewsEmailWebsiteFlag]
   ,[cewsEmailWebSite]
   ,[cewbDefault]
   ,[cewnRecUserID]
   ,[cewdDtCreated]
   ,[cewnModifyUserID]
   ,[cewdDtModified]
   ,[cewnLevelNo]
   ,[saga]
   ,[cewnComments]
	)
	SELECT
		C.cinnContactCtg AS cewnContactCtgID
	   ,C.cinnContactID	 AS cewnContactID
	   ,'E'				 AS cewsEmailWebsiteFlag
	   ,N.email			 AS cewsEmailWebSite
	   ,1				 AS cewbDefault
	   ,368				 AS cewnRecUserID
	   ,GETDATE()		 AS cewdDtCreated
	   ,368				 AS cewnModifyUserID
	   ,GETDATE()		 AS cewdDtModified
	   ,NULL
	   ,1				 AS saga
	   , -- indicate email
		--isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''				 AS [cewnComments]
	--select *
	FROM [NeosBrianWhite].[dbo].[staff] N
	JOIN [sma_MST_IndvContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.id)
	WHERE ISNULL(email, '') <> ''

/*
INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
SELECT 
		C.cinnContactCtg	as cewnContactCtgID,
		C.cinnContactID		as cewnContactID,
		'W'					as cewsEmailWebsiteFlag,
		N.website			as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		4					as saga -- indicate website
FROM [NeosBrianWhite].[dbo].[names] N
JOIN [SANeosBrianWhite].[dbo].[sma_MST_IndvContacts] C on C.saga_ref = N.names_id
WHERE isnull(website,'') <> ''
*/

--------------------------------------------------------------------
----- (2/3) CONSTRUCT SMA_MST_EMAILWEBSITE FOR ORGANIZATION ------
--------------------------------------------------------------------
INSERT INTO [sma_MST_EmailWebsite]
	(
	[cewnContactCtgID]
   ,[cewnContactID]
   ,[cewsEmailWebsiteFlag]
   ,[cewsEmailWebSite]
   ,[cewbDefault]
   ,[cewnRecUserID]
   ,[cewdDtCreated]
   ,[cewnModifyUserID]
   ,[cewdDtModified]
   ,[cewnLevelNo]
   ,[saga]
   ,[cewnComments]
	)
	SELECT
		C.connContactCtg AS cewnContactCtgID
	   ,C.connContactID	 AS cewnContactID
	   ,'E'				 AS cewsEmailWebsiteFlag
	   ,N.email			 AS cewsEmailWebSite
	   ,NULL			 AS cewbDefault
	   ,368				 AS cewnRecUserID
	   ,GETDATE()		 AS cewdDtCreated
	   ,368				 AS cewnModifyUserID
	   ,GETDATE()		 AS cewdDtModified
	   ,NULL
	   ,1				 AS saga
	   , -- indicate email
		ISNULL('Type: ' + NULLIF(CONVERT(VARCHAR, n.[type]), '') + CHAR(13), '') +
		''				 AS [cewnComments]
	FROM [NeosBrianWhite].[dbo].[email_accounts] N
	JOIN [sma_MST_OrgContacts] C
		ON C.saga_ref = CONVERT(VARCHAR(50), N.namesId)
	WHERE ISNULL(email, '') <> ''

/*
INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
SELECT 
		C.connContactCtg	as cewnContactCtgID,
		C.connContactID		as cewnContactID,
		'W'					as cewsEmailWebsiteFlag,
		N.website			as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		4					as saga -- indicate website
FROM [NeosBrianWhite].[dbo].[names] N
JOIN [sma_MST_OrgContacts] C on C.saga_ref = N.names_id
WHERE isnull(website,'') <> ''
*/
---
ALTER TABLE [sma_MST_EmailWebsite] ENABLE TRIGGER ALL
GO
 ---


