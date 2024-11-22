
USE [BrianWhiteSA]
GO
/*
alter table [sma_MST_Address] disable trigger all
delete from [sma_MST_Address] 
DBCC CHECKIDENT ('[sma_MST_Address]', RESEED, 0);
alter table [sma_MST_Address] enable trigger all
*/
-- select distinct addr_Type from  [BrianWhiteNeos].[dbo].[multi_addresses]
-- select * from  [BrianWhiteNeos].[dbo].[multi_addresses] where addr_type not in ('Home','business', 'other')

---
ALTER TABLE [sma_MST_Address] DISABLE TRIGGER ALL
GO
---
-----------------------------------------------------------------------------
----(1)--- CONSTRUCT SMA_MST_ADDRESS FROM EXISTING SMA_MST_INDVCONTACTS
-----------------------------------------------------------------------------
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,left(A.[address],75)		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,a.default_addr	 AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,CASE
			WHEN ISNULL(A.company, '') <> ''
				THEN 'Company : ' + CHAR(13) + A.company
			ELSE ''
		END				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	--select *
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Indvcontacts] I
		ON CONVERT(VARCHAR(50), I.saga_ref) = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = I.cinnContactCtg
			AND T.addsCode = 'HM'
	WHERE (A.[addr_type] = 'Home'
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))

INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,A.[address]		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,A.[default_addr] AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,CASE
			WHEN ISNULL(A.company, '') <> ''
				THEN 'Company : ' + CHAR(13) + A.company
			ELSE ''
		END				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Indvcontacts] I
		ON I.saga_ref = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = I.cinnContactCtg
			AND T.addsCode = 'WORK'
	WHERE (A.[addr_type] = 'Business'
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))


INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,A.[address]		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,A.[default_addr] AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,ISNULL('Address Type: ' + NULLIF(CONVERT(VARCHAR, a.addr_type), '') + CHAR(13), '') +
		ISNULL('Company: ' + NULLIF(CONVERT(VARCHAR, a.company), '') + CHAR(13), '') +
		''				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Indvcontacts] I
		ON I.saga_ref = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = I.cinnContactCtg
			AND T.addsCode = 'OTH'
	WHERE (A.[addr_type] NOT IN ('Business', 'Home')
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))


-------------------------------------------------------
----(2)---- CONSTRUCT FROM SMA_MST_ORGCONTACTS
-------------------------------------------------------
INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,A.[address]		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,A.[default_addr] AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,CASE
			WHEN ISNULL(A.company, '') <> ''
				THEN 'Company : ' + CHAR(13) + A.company
			ELSE ''
		END				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Orgcontacts] O
		ON O.saga_Ref = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'HO'
	WHERE (A.[addr_type] = 'Home'
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))

INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,A.[address]		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,A.[default_addr] AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,CASE
			WHEN ISNULL(A.company, '') <> ''
				THEN 'Company : ' + CHAR(13) + A.company
			ELSE ''
		END				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Orgcontacts] O
		ON O.saga_ref = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'WRK'
	WHERE (A.[addr_type] = 'Business'
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))



INSERT INTO [sma_MST_Address]
	(
	[addnContactCtgID], [addnContactID], [addnAddressTypeID], [addsAddressType], [addsAddTypeCode], [addsAddress1], [addsAddress2], [addsAddress3], [addsStateCode], [addsCity], [addnZipID], [addsZip], [addsCounty], [addsCountry], [addbIsResidence], [addbPrimary], [adddFromDate], [adddToDate], [addnCompanyID], [addsDepartment], [addsTitle], [addnContactPersonID], [addsComments], [addbIsCurrent], [addbIsMailing], [addnRecUserID], [adddDtCreated], [addnModifyUserID], [adddDtModified], [addnLevelNo], [caseno], [addbDeleted], [addsZipExtn], [saga]
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,T.addnAddTypeID	 AS addnAddressTypeID
	   ,T.addsDscrptn	 AS addsAddressType
	   ,T.addsCode		 AS addsAddTypeCode
	   ,A.[address]		 AS addsAddress1
	   ,A.[address_2]	 AS addsAddress2
	   ,NULL			 AS addsAddress3
	   ,A.[state]		 AS addsStateCode
	   ,A.[city]		 AS addsCity
	   ,NULL			 AS addnZipID
	   ,A.[zipcode]		 AS addsZip
	   ,A.[county]		 AS addsCounty
	   ,A.[country]		 AS addsCountry
	   ,NULL			 AS addbIsResidence
	   ,A.[default_addr] AS addbPrimary
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,ISNULL('Address Type: ' + NULLIF(CONVERT(VARCHAR, a.addr_type), '') + CHAR(13), '') +
		ISNULL('Company: ' + NULLIF(CONVERT(VARCHAR, a.company), '') + CHAR(13), '') +
		''				 AS [addsComments]
	   ,NULL
	   ,NULL
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	   ,368				 AS addnModifyUserID
	   ,GETDATE()		 AS adddDtModified
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	FROM [BrianWhiteNeos].[dbo].[multi_addresses] A
	JOIN [sma_MST_Orgcontacts] O
		ON O.saga_ref = CONVERT(VARCHAR(50), A.namesid)
	JOIN [sma_MST_AddressTypes] T
		ON T.addnContactCategoryID = O.connContactCtg
			AND T.addsCode = 'BR'
	WHERE (A.[addr_type] NOT IN ('Home', 'Business')
		AND (ISNULL(A.[address], '') <> ''
		OR ISNULL(A.[address_2], '') <> ''
		OR ISNULL(A.[city], '') <> ''
		OR ISNULL(A.[state], '') <> ''
		OR ISNULL(A.[zipcode], '') <> ''
		OR ISNULL(A.[county], '') <> ''
		OR ISNULL(A.[country], '') <> ''))


---(APPENDIX)---
---(A.0)
INSERT INTO [sma_MST_Address]
	(
	addnContactCtgID, addnContactID, addnAddressTypeID, addsAddressType, addsAddTypeCode, addbPrimary, addnRecUserID, adddDtCreated
	)
	SELECT
		I.cinnContactCtg AS addnContactCtgID
	   ,I.cinnContactID	 AS addnContactID
	   ,(
			SELECT
				addnAddTypeID
			FROM [sma_MST_AddressTypes]
			WHERE addsDscrptn = 'Other'
				AND addnContactCategoryID = I.cinnContactCtg
		)				 
		AS addnAddressTypeID
	   ,'Other'			 AS addsAddressType
	   ,'OTH'			 AS addsAddTypeCode
	   ,1				 AS addbPrimary
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	FROM [sma_MST_IndvContacts] I
	LEFT JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
			AND A.addnContactCtgID = I.cinnContactCtg
	WHERE A.addnAddressID IS NULL

---(A.1)
INSERT INTO [sma_MST_AddressTypes]
	(
	addsCode, addsDscrptn, addnContactCategoryID, addbIsWork
	)
	SELECT
		'OTH_O'
	   ,'Other'
	   ,2
	   ,0
	EXCEPT
	SELECT
		addsCode
	   ,addsDscrptn
	   ,addnContactCategoryID
	   ,addbIsWork
	FROM [sma_MST_AddressTypes]


INSERT INTO [sma_MST_Address]
	(
	addnContactCtgID, addnContactID, addnAddressTypeID, addsAddressType, addsAddTypeCode, addbPrimary, addnRecUserID, adddDtCreated
	)
	SELECT
		O.connContactCtg AS addnContactCtgID
	   ,O.connContactID	 AS addnContactID
	   ,(
			SELECT
				addnAddTypeID
			FROM [sma_MST_AddressTypes]
			WHERE addsDscrptn = 'Other'
				AND addnContactCategoryID = O.connContactCtg
		)				 
		AS addnAddressTypeID
	   ,'Other'			 AS addsAddressType
	   ,'OTH_O'			 AS addsAddTypeCode
	   ,1				 AS addbPrimary
	   ,368				 AS addnRecUserID
	   ,GETDATE()		 AS adddDtCreated
	FROM [sma_MST_OrgContacts] O
	LEFT JOIN [sma_MST_Address] A
		ON A.addnContactID = O.connContactID
			AND A.addnContactCtgID = O.connContactCtg
	WHERE A.addnAddressID IS NULL

----(APPENDIX)----
UPDATE [sma_MST_Address]
SET addbPrimary = 1
FROM (
	SELECT
		I.cinnContactID AS CID
	   ,A.addnAddressID AS AID
	   ,ROW_NUMBER() OVER (PARTITION BY I.cinnContactID ORDER BY A.addnAddressID ASC) AS RowNumber
	FROM [sma_MST_Indvcontacts] I
	JOIN [sma_MST_Address] A
		ON A.addnContactID = I.cinnContactID
		AND A.addnContactCtgID = I.cinnContactCtg
		AND A.addbPrimary <> 1
	WHERE I.cinnContactID NOT IN (
			SELECT
				I.cinnContactID
			FROM [sma_MST_Indvcontacts] I
			JOIN [sma_MST_Address] A
				ON A.addnContactID = I.cinnContactID
				AND A.addnContactCtgID = I.cinnContactCtg
				AND A.addbPrimary = 1
		)
) A
WHERE A.RowNumber = 1
AND A.AID = addnAddressID

UPDATE [sma_MST_Address]
SET addbPrimary = 1
FROM (
	SELECT
		O.connContactID AS CID
	   ,A.addnAddressID AS AID
	   ,ROW_NUMBER() OVER (PARTITION BY O.connContactID ORDER BY A.addnAddressID ASC) AS RowNumber
	FROM [sma_MST_OrgContacts] O
	JOIN [sma_MST_Address] A
		ON A.addnContactID = O.connContactID
		AND A.addnContactCtgID = O.connContactCtg
		AND A.addbPrimary <> 1
	WHERE O.connContactID NOT IN (
			SELECT
				O.connContactID
			FROM [sma_MST_OrgContacts] O
			JOIN [sma_MST_Address] A
				ON A.addnContactID = O.connContactID
				AND A.addnContactCtgID = O.connContactCtg
				AND A.addbPrimary = 1
		)
) A
WHERE A.RowNumber = 1
AND A.AID = addnAddressID


---
ALTER TABLE [sma_MST_Address] ENABLE TRIGGER ALL
GO
---



------------- Check Uniqueness------------
-- select I.cinnContactID
-- 	 from [BrianWhiteSA].[dbo].[sma_MST_Indvcontacts] I 
--	 inner join [BrianWhiteSA].[dbo].[sma_MST_Address] A on A.addnContactID=I.cinnContactID and A.addnContactCtgID=I.cinnContactCtg and A.addbPrimary=1 
--	 group by cinnContactID
--	 having count(cinnContactID)>1

-- select O.connContactID
-- 	 from [BrianWhiteSA].[dbo].[sma_MST_OrgContacts] O 
--	 inner join [BrianWhiteSA].[dbo].[sma_MST_Address] A on A.addnContactID=O.connContactID and A.addnContactCtgID=O.connContactCtg and A.addbPrimary=1 
--	 group by connContactID
--	 having count(connContactID)>1

