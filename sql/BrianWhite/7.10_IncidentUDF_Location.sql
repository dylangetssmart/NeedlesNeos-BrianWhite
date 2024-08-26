USE SANeosBrianWhite
GO


INSERT INTO sma_MST_UDFDefinition
	(
	udfsUDFCtg
   ,udfnRelatedPK
   ,udfsUDFName
   ,udfsScreenName
   ,udfsType
   ,udfsLength
   ,udfnSortOrder
   ,udfbIsActive
   ,udfnRecUserID
   ,udfnDtCreated
	)
	SELECT
		'C'				  AS udfsUDFCtg
	   ,ct.cstnCaseTypeID AS udfnRelatedPK
	   ,u.udf			  AS udfsUDFName
	   ,'Case Wizard'	  AS udfsScreenName
	   ,'Text'			  AS udfsType
	   ,100				  AS udfsLength
	   ,0				  AS udfnSortOrder
	   ,1				  AS udfbIsActive
	   ,368				  AS udfnRecUserID
	   ,GETDATE()		  AS udfnDtCreated
	FROM (
		SELECT
			'Location' AS udf
		UNION
		SELECT
			'City' AS udf
		UNION
		SELECT
			'State' AS udf
		UNION
		SELECT
			'County' AS udf
	) u
	CROSS JOIN (
		SELECT
			cstnCaseTypeID
		FROM sma_mst_Casetype
		WHERE VenderCaseType = 'BrianWhiteCaseType'
	) ct
	LEFT JOIN sma_MST_UDFDefinition udf
		ON udf.udfnRelatedPK = ct.cstnCaseTypeID
			AND udf.udfsUDFName = 'Location'
			AND udf.udfsScreenName = 'Case Wizard'
	WHERE udf.udfnUDFID IS NULL


--INCIDENT LOCATION
---LOCATION---
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		(
			SELECT
				udfnUDFID
			FROM sma_MST_UDFDefinition
			WHERE udfnRelatedPK = cas.casnOrgCaseTypeID
				AND udfsScreenName = 'Case Wizard'
				AND udfsUDFName = 'Location'
		)			   
		AS [udvnUDFID]
	   ,'Case Wizard'  AS [udvsScreenName]
	   ,'C'			   AS [udvsUDFCtg]
	   ,CAS.casnCaseID AS [udvnRelatedID]
	   ,0			   AS [udvnSubRelatedID]
	   ,u.[data]	   AS [udvsUDFValue]
	   ,368			   AS [udvnRecUserID]
	   ,GETDATE()	   AS [udvdDtCreated]
	   ,NULL		   AS [udvnModifyUserID]
	   ,NULL		   AS [udvdDtModified]
	   ,NULL		   AS [udvnLevelNo]
	FROM [NeosBrianWhite].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'Location of Accident'
	) u
		ON u.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.[id])



---CITY---
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		(
			SELECT
				udfnUDFID
			FROM sma_MST_UDFDefinition
			WHERE udfnRelatedPK = cas.casnOrgCaseTypeID
				AND udfsScreenName = 'Case Wizard'
				AND udfsUDFName = 'City'
		)			   
		AS [udvnUDFID]
	   ,'Case Wizard'  AS [udvsScreenName]
	   ,'C'			   AS [udvsUDFCtg]
	   ,CAS.casnCaseID AS [udvnRelatedID]
	   ,0			   AS [udvnSubRelatedID]
	   ,u.[data]	   AS [udvsUDFValue]
	   ,368			   AS [udvnRecUserID]
	   ,GETDATE()	   AS [udvdDtCreated]
	   ,NULL		   AS [udvnModifyUserID]
	   ,NULL		   AS [udvdDtModified]
	   ,NULL		   AS [udvnLevelNo]
	FROM [NeosBrianWhite].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'City'
	) u
		ON u.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.[id])

---COUNTY---
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		(
			SELECT
				udfnUDFID
			FROM sma_MST_UDFDefinition
			WHERE udfnRelatedPK = cas.casnOrgCaseTypeID
				AND udfsScreenName = 'Case Wizard'
				AND udfsUDFName = 'County'
		)			   
		AS [udvnUDFID]
	   ,'Case Wizard'  AS [udvsScreenName]
	   ,'C'			   AS [udvsUDFCtg]
	   ,CAS.casnCaseID AS [udvnRelatedID]
	   ,0			   AS [udvnSubRelatedID]
	   ,u.[data]	   AS [udvsUDFValue]
	   ,368			   AS [udvnRecUserID]
	   ,GETDATE()	   AS [udvdDtCreated]
	   ,NULL		   AS [udvnModifyUserID]
	   ,NULL		   AS [udvdDtModified]
	   ,NULL		   AS [udvnLevelNo]
	FROM [NeosBrianWhite].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'County'
	) u
		ON u.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.[id])


---STATE---
INSERT INTO [sma_TRN_UDFValues]
	(
	[udvnUDFID]
   ,[udvsScreenName]
   ,[udvsUDFCtg]
   ,[udvnRelatedID]
   ,[udvnSubRelatedID]
   ,[udvsUDFValue]
   ,[udvnRecUserID]
   ,[udvdDtCreated]
   ,[udvnModifyUserID]
   ,[udvdDtModified]
   ,[udvnLevelNo]
	)
	SELECT
		(
			SELECT
				udfnUDFID
			FROM sma_MST_UDFDefinition
			WHERE udfnRelatedPK = cas.casnOrgCaseTypeID
				AND udfsScreenName = 'Case Wizard'
				AND udfsUDFName = 'State'
		)			   
		AS [udvnUDFID]
	   ,'Case Wizard'  AS [udvsScreenName]
	   ,'C'			   AS [udvsUDFCtg]
	   ,CAS.casnCaseID AS [udvnRelatedID]
	   ,0			   AS [udvnSubRelatedID]
	   ,u.[data]	   AS [udvsUDFValue]
	   ,368			   AS [udvnRecUserID]
	   ,GETDATE()	   AS [udvdDtCreated]
	   ,NULL		   AS [udvnModifyUserID]
	   ,NULL		   AS [udvdDtModified]
	   ,NULL		   AS [udvnLevelNo]
	FROM [NeosBrianWhite].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [NeosBrianWhite]..user_tab6_data td
		JOIN [NeosBrianWhite]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'State'
	) u
		ON u.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.[id])