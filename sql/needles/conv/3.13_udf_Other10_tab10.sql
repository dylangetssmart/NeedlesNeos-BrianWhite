/* ########################################################
This script populates UDF Other10 with all columns from user_tab10_data
*/

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Other10UDF' AND type = 'U')
BEGIN
    DROP TABLE Other10UDF
END

-- Create temporary table for columns to exclude
IF OBJECT_ID('tempdb..#ExcludedColumns') IS NOT NULL
    DROP TABLE #ExcludedColumns;

CREATE TABLE #ExcludedColumns (
    column_name VARCHAR(128)
);


-- Insert columns to exclude
INSERT INTO #ExcludedColumns (column_name)
VALUES
('case_id'),
('tab_id_location'),
('modified_timestamp'),
('show_on_status_tab'),
('case_status_attn'),
('case_status_client');


-- Dynamically get all columns from TestClientNeedles..user_tab10_data for unpivoting
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql = STRING_AGG(CONVERT(VARCHAR(MAX), 
    N'CONVERT(VARCHAR(MAX), ' + QUOTENAME(column_name) + N') AS ' + QUOTENAME(column_name)
), ', ')
FROM TestClientNeedles.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'user_tab10_data'
AND column_name NOT IN (SELECT column_name FROM #ExcludedColumns);


-- Dynamically create the UNPIVOT list
DECLARE @unpivot_list NVARCHAR(MAX) = N'';
SELECT @unpivot_list = STRING_AGG(QUOTENAME(column_name), ', ')
FROM TestClientNeedles.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'user_tab10_data'
AND column_name NOT IN (SELECT column_name FROM #ExcludedColumns);


-- Generate the dynamic SQL for creating the pivot table
SET @sql = N'
SELECT casnCaseID, casnOrgCaseTypeID, FieldTitle, FieldVal
INTO Other10UDF
FROM ( 
    SELECT 
        cas.casnCaseID, 
        cas.casnOrgCaseTypeID, ' + @sql + N'
    FROM TestClientNeedles..user_tab10_data ud
    JOIN TestClientNeedles..cases_Indexed c ON c.casenum = ud.case_id
    JOIN sma_TRN_Cases cas ON cas.cassCaseNumber = CONVERT(VARCHAR, ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN (' + @unpivot_list + N')) AS unpvt;';

EXEC sp_executesql @sql;
select * from Other10udf
select * from TestClientNeedles..user_tab10_data

----------------------------
--UDF DEFINITION
----------------------------
alter table [sma_MST_UDFDefinition] disable trigger all
GO

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
   'C'													as [udfsUDFCtg]
	,CST.cstnCaseTypeID									as [udfnRelatedPK]
	,M.field_title										as [udfsUDFName]
	,'Other10'											as [udfsScreenName]
	,ucf.UDFType										as [udfsType]
	,ucf.field_len										as [udfsLength]
	,1													as [udfbIsActive]
	,'user_tab10_data' + ucf.column_name					as [udfshortName]
	,ucf.dropdownValues									as [udfsNewValues]
	,DENSE_RANK() OVER (ORDER BY M.field_title)			as udfnSortOrder
FROM [sma_MST_CaseType] CST
	JOIN CaseTypeMixture mix
		ON mix.[SmartAdvocate Case Type] = cst.cstsType
	JOIN [TestClientNeedles].[dbo].[user_tab10_matter] M
		ON M.mattercode = mix.matcode
		AND M.field_type <> 'label'
	JOIN	(
				SELECT DISTINCT	fieldTitle
				FROM Other10UDF
			) vd
		ON vd.FieldTitle = M.field_title
	JOIN [SATestClientNeedles].[dbo].[NeedlesUserFields] ucf
		ON ucf.field_num = M.ref_num
	LEFT JOIN	(
					SELECT DISTINCT table_Name, column_name
					FROM [TestClientNeedles].[dbo].[document_merge_params]
					WHERE table_Name = 'user_tab10_data'
				) dmp
		ON dmp.column_name = ucf.field_Title
	LEFT JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cst.cstnCaseTypeID
		AND def.[udfsUDFName] = M.field_title
		AND def.[udfsScreenName] = 'Other10'
		AND def.[udfsType] = ucf.UDFType
AND def.udfnUDFID IS NULL
ORDER BY M.field_title



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
SELECT 
   def.udfnUDFID		as [udvnUDFID],
	'Other10'				as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	udf.FieldVal		as [udvsUDFValue],
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
FROM Other10UDF udf
	LEFT JOIN sma_MST_UDFDefinition def
	ON def.udfnRelatedPK = udf.casnOrgCaseTypeID
	AND def.udfsUDFName = FieldTitle
	AND def.udfsScreenName = 'Other10'

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO
