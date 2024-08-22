USE SANeosBrianWhite
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
    'C'						as [udfsUDFCtg],
    cas.casnOrgCaseTypeID	as [udfnRelatedPK],
    ucf.field_title			as [udfsUDFName],   
    'Case'					as [udfsScreenName],
    nuf.UDFType				as [udfsType],
    nuf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Case_Data'+ucf.field_title	as [udfshortName],
    nuf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by cas.casnOrgCaseTypeID) as udfnSortOrder
--select td.*
FROM [NeosBrianWhite]..user_case_data td
JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN NeedlesUserFields nuf on nuf.field_title = ucf.field_title 
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
--LEFT JOIN (select distinct table_Name, column_name From [NeosBrianWhite]..[document_merge_params] where table_Name = 'user_Tab6_Data') dmp
												--on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case' and udfstype = nuf.UDFType
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
select --fieldtitle, udf.casnOrgCaseTypeID,
	def.udfnUDFID		as [udvnUDFID],
	'Case'		as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	case when ucf.field_Type = '14' then (select top 1 convert(varchar,UNQCID) from indvorgcontacts_Indexed where saga_Ref = convert(varchar(50),td.[namesid])) else td.[data] end			as [udvsUDFValue],  
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM [NeosBrianWhite]..user_case_data td
JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50), td.casesid)
JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cas.casnOrgCaseTypeID and def.[udfsUDFName] = ucf.field_title and def.[udfsScreenName] = 'Case' --and udfstype = nuf.UDFType
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO

