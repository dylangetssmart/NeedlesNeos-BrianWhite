USE BrianWhiteSA
GO

----------------------------
--CASE UDF DEFINITION
----------------------------
INSERT INTO [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg]
   ,[udfnRelatedPK]
   ,[udfsUDFName]
   ,[udfsScreenName]
   ,[udfsType]
   ,[udfsLength]
   ,[udfbIsActive]
   ,[udfshortName]
   ,[udfsNewValues]
   ,[udfnSortOrder]
	)
	SELECT DISTINCT
		'C'												   AS [udfsUDFCtg]
	   ,cas.casnOrgCaseTypeID							   AS [udfnRelatedPK]
	   ,ucf.field_title									   AS [udfsUDFName]
	   ,'Case'											   AS [udfsScreenName]
	   ,nuf.UDFType										   AS [udfsType]
	   ,nuf.field_len									   AS [udfsLength]
	   ,1												   AS [udfbIsActive]
	   ,'user_Case_Data' + ucf.field_title				   AS [udfshortName]
	   ,nuf.dropdownValues								   AS [udfsNewValues]
	   ,DENSE_RANK() OVER (ORDER BY cas.casnOrgCaseTypeID) AS udfnSortOrder
	--select td.*
	FROM [BrianWhiteNeos]..user_case_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	JOIN NeedlesUserFields nuf
		ON nuf.field_title = ucf.field_title
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = CONVERT(VARCHAR(50), td.casesid)
	--LEFT JOIN (select distinct table_Name, column_name From [BrianWhiteNeos]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
	--on dmp.column_name = ucf.field_Title
	LEFT JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = ucf.field_title
			AND def.[udfsScreenName] = 'Case'
			AND udfstype = nuf.UDFType
	WHERE def.udfnUDFID IS NULL
	ORDER BY ucf.field_title
GO

--------------------------------------
--UDF VALUES
--------------------------------------
ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO
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
	SELECT --fieldtitle, udf.casnOrgCaseTypeID,
		def.udfnUDFID AS [udvnUDFID]
	   ,'Case'		  AS [udvsScreenName]
	   ,'C'			  AS [udvsUDFCtg]
	   ,casnCaseID	  AS [udvnRelatedID]
	   ,0			  AS [udvnSubRelatedID]
	   ,CASE
			WHEN ucf.field_Type = '14'
				THEN (
						SELECT TOP 1
							CONVERT(VARCHAR, UNQCID)
						FROM indvorgcontacts_Indexed
						WHERE saga_Ref = CONVERT(VARCHAR(50), td.[namesid])
					)
			ELSE td.[data]
		END			  AS [udvsUDFValue]
	   ,368			  AS [udvnRecUserID]
	   ,GETDATE()	  AS [udvdDtCreated]
	   ,NULL		  AS [udvnModifyUserID]
	   ,NULL		  AS [udvdDtModified]
	   ,NULL		  AS [udvnLevelNo]
	--select *
	FROM [BrianWhiteNeos]..user_case_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = CONVERT(VARCHAR(50), td.casesid)
	JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = ucf.field_title
			AND def.[udfsScreenName] = 'Case' --and udfstype = nuf.UDFType
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO


-----------------------------------------------------------------------------
--cases.alt_case_num


----------------------------
--CASE UDF DEFINITION
----------------------------
INSERT INTO [sma_MST_UDFDefinition]
	(
	[udfsUDFCtg]
   ,[udfnRelatedPK]
   ,[udfsUDFName]
   ,[udfsScreenName]
   ,[udfsType]
   ,[udfsLength]
   ,[udfbIsActive]
   ,[udfshortName]
   ,[udfsNewValues]
   ,[udfnSortOrder]
	)
	SELECT DISTINCT
		'C'										AS [udfsUDFCtg]
	   ,cas.casnOrgCaseTypeID					AS [udfnRelatedPK]
	   ,'BW File No.'							AS [udfsUDFName]
	   ,'Case'									AS [udfsScreenName]
	   ,'Text'									AS [udfsType]
	   ,75										AS [udfsLength]
	   ,1										AS [udfbIsActive]
	   ,'BW File No.'							AS [udfshortName]
	   ,null									AS [udfsNewValues]
	   ,DENSE_RANK() OVER (ORDER BY cas.casnOrgCaseTypeID) AS udfnSortOrder
	--select td.*
	FROM [BrianWhiteNeos]..cases c
	-- JOIN [BrianWhiteNeos]..user_case_fields ucf
	-- 	ON ucf.id = td.usercasefieldid
	-- JOIN NeedlesUserFields nuf
	-- 	ON nuf.field_title = ucf.field_title
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = c.id
	--LEFT JOIN (select distinct table_Name, column_name From [BrianWhiteNeos]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
	--on dmp.column_name = ucf.field_Title
	LEFT JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = 'BW File No.'
			AND def.[udfsScreenName] = 'Case'
			--AND udfstype = nuf.UDFType
	WHERE def.udfnUDFID IS NULL
	--ORDER BY ucf.field_title
GO



--------------------------------------
--UDF VALUES
--------------------------------------
ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO
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
	SELECT --fieldtitle, udf.casnOrgCaseTypeID,
		def.udfnUDFID			AS [udvnUDFID]
	   ,'Case'					AS [udvsScreenName]
	   ,'C'						AS [udvsUDFCtg]
	   ,casnCaseID				AS [udvnRelatedID]
	   ,0						AS [udvnSubRelatedID]
	   ,c.alt_case_num			AS [udvsUDFValue]
	   ,368						AS [udvnRecUserID]
	   ,GETDATE()				AS [udvdDtCreated]
	   ,NULL					AS [udvnModifyUserID]
	   ,NULL					AS [udvdDtModified]
	   ,NULL					AS [udvnLevelNo]
	--select *
	FROM [BrianWhiteNeos]..cases c
	-- JOIN [BrianWhiteNeos]..user_case_fields ucf
	-- 	ON ucf.id = td.usercasefieldid
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = c.id
	JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = 'BW File No.'
			AND def.[udfsScreenName] = 'Case' --and udfstype = nuf.UDFType
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO