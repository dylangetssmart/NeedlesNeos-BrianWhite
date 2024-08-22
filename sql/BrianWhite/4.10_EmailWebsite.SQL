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
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.cinnContactCtg	as cewnContactCtgID,
		C.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		N.email				as cewsEmailWebSite,
		case when [order] = 0 then 1 else 0 end			as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments]
FROM [NeosBrianWhite].[dbo].[email_accounts] N
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),N.namesId)
WHERE isnull(email,'') <> ''

------------------------------
--INSERT EMAIL FOR STAFF
------------------------------
INSERT INTO [sma_MST_EmailWebsite]
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.cinnContactCtg	as cewnContactCtgID,
		C.cinnContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		N.email				as cewsEmailWebSite,
		1					as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		--isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments]
--select *
FROM [NeosBrianWhite].[dbo].[staff] N
JOIN [sma_MST_IndvContacts] C on C.saga_ref = convert(varchar(50),N.id)
WHERE isnull(email,'') <> ''

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
  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga],[cewnComments] )
SELECT 
		C.connContactCtg	as cewnContactCtgID,
		C.connContactID		as cewnContactID,
		'E'					as cewsEmailWebsiteFlag,
		N.email				as cewsEmailWebSite,
		null				as cewbDefault,
		368					as cewnRecUserID,
		getdate()			as cewdDtCreated,
		368					as cewnModifyUserID,
		getdate()			as cewdDtModified,
		null,
		1					as saga, -- indicate email
		isnull('Type: ' + nullif(convert(varchar,n.[type]),'') + CHAR(13),'') +
		''					as [cewnComments]
FROM [NeosBrianWhite].[dbo].[email_accounts] N
JOIN [sma_MST_OrgContacts] C on C.saga_ref = convert(varchar(50),N.namesId)
WHERE isnull(email,'') <> ''

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


