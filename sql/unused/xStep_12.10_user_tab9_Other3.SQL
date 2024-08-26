USE [SANeosBrianWhite]
GO
/*
alter table [sma_MST_UDFDefinition] disable trigger all
delete [sma_MST_UDFDefinition]
DBCC CHECKIDENT ('[sma_MST_UDFDefinition]', RESEED, 0);
alter table [sma_MST_UDFDefinition] enable trigger all

alter table [sma_TRN_UDFValues] disable trigger all
delete [sma_TRN_UDFValues]
DBCC CHECKIDENT ('[sma_TRN_UDFValues]', RESEED, 0);
alter table [sma_TRN_UDFValues] enable trigger all
*/

----------------------------
--PIVOT TABLE CONSTRUCTION
----------------------------
/*
select distinct m.field_Title, column_name, 'convert(varchar(max), ['+ column_Name + '] ) as ['+ m.field_title +'], ', '['+m.field_title+'],'
FROM [NeosBrianWhite].[dbo].[user_tab9_matter] M 
JOIN [NeosBrianWhite].[dbo].[user_case_fields] F on F.field_title=M.field_title
where m.field_Type <> 'label'
*/
IF EXISTS (Select * From sys.tables where name = 'UserTab9_UDF3' and type = 'U')
BEGIN
	DROP TABLE UserTab9_UDF3
END
GO
----------------------
--PIVOT TABLE
----------------------
SELECT casncaseid, casnorgcasetypeID, Case_ID, fieldTitle, FieldVal
INTO UserTab9_UDF3
FROM ( SELECT cas.casnCaseID, cas.CasnOrgCaseTypeID, Case_ID, 
		convert(varchar(max), [Accident_Report] ) as [Accident Report?], 
		convert(varchar(max), [Accredited_Service] ) as [Accredited Service], 
		convert(varchar(max), [Address] ) as [Address], 
		convert(varchar(max), [Apartment_Home_Payment] ) as [Apartment Home Payment], 
		convert(varchar(max), [Applicable_FRAOSHA_Reg] ) as [Applicable FRA/OSHA Reg], 
		convert(varchar(max), [Cell_Phone] ) as [Cell Phone], 
		convert(varchar(max), [Copy_of_Report_Attached] ) as [Copy of Report Attached], 
		convert(varchar(max), [Date_of_Accident] ) as [Date of Accident], 
		convert(varchar(max), [Description_of_Accident] ) as [Description of Accident], 
		convert(varchar(max), [Electric_Bill] ) as [Electric Bill], 
		convert(varchar(max), [Employer_Name] ) as [Employer Name], 
		convert(varchar(max), [Food] ) as [Food], 
		convert(varchar(max), [Gas_Bill] ) as [Gas Bill], 
		convert(varchar(max), [Home_Phone] ) as [Home Phone], 
		convert(varchar(max), [Hour_of_Day_Started_Work] ) as [Hour of Day Started Work], 
		convert(varchar(max), [Hours_Worked_DOA] ) as [Hours Worked DOA], 
		convert(varchar(max), [Injuries] ) as [Injuries], 
		convert(varchar(max), [Location_of_Accident] ) as [Location of Accident], 
		convert(varchar(max), [Lost_income] ) as [Lost income?], 
		convert(varchar(max), [Lost_Wages_Information] ) as [Lost Wages Information], 
		convert(varchar(max), [Miles_to_PT] ) as [Miles to PT], 
		convert(varchar(max), [Miles_to_Your_Doctor] ) as [Miles to Your Doctor], 
		convert(varchar(max), [Number_People_At_Home] ) as [Number People At Home?], 
		convert(varchar(max), [Overtime__If_so_#_Hours] ) as [Overtime?  If so, # Hours], 
		convert(varchar(max), [Pay_for_Parking_Dr_or_PT] ) as [Pay for Parking Dr or PT], 
		convert(varchar(max), [Send_Lien_Letter_To] ) as [Send Lien Letter To], 
		convert(varchar(max), [Statement_Given_To] ) as [Statement Given To], 
		convert(varchar(max), [Statement_Taken] ) as [Statement Taken?], 
		convert(varchar(max), [Time_of_Accident] ) as [Time of Accident], 
		convert(varchar(max), [Time_Working_for_Railroad] ) as [Time Working for Railroad], 
		convert(varchar(max), [Wage_Paid_by_Employer] ) as [Wage Paid by Employer], 
		convert(varchar(max), [Water_or_Sewer_Bill] ) as [Water or Sewer Bill], 
		convert(varchar(max), [We_Have_Apt_Home_Info] ) as [We Have Apt Home Info], 
		convert(varchar(max), [We_Have_Cell_Phone_Bill] ) as [We Have Cell Phone Bill], 
		convert(varchar(max), [We_Have_Electric_Bill] ) as [We Have Electric Bill], 
		convert(varchar(max), [We_Have_Food_Receipts] ) as [We Have Food Receipts], 
		convert(varchar(max), [We_Have_Gas_Bill] ) as [We Have Gas Bill], 
		convert(varchar(max), [We_Have_Home_Phone_Bill] ) as [We Have Home Phone Bill], 
		convert(varchar(max), [We_Have_Parking_Receipts] ) as [We Have Parking Receipts], 
		convert(varchar(max), [We_Have_Water_Sewer_Bill] ) as [We Have Water Sewer Bill], 
		convert(varchar(max), [Who_Filed_Report] ) as [Who Filed Report?], 
		convert(varchar(max), [Why_Railroad_Was_at_Fault] ) as [Why Railroad Was at Fault]
	FROM NeosBrianWhite..user_tab9_data ud
	JOIN NeosBrianWhite..cases_Indexed c on c.casenum = ud.case_id
	JOIN sma_TRN_Cases cas on cas.cassCaseNumber = convert(varchar,ud.case_id)
) pv
UNPIVOT (FieldVal FOR FieldTitle IN ([Accident Report?],[Accredited Service],[Address],[Apartment Home Payment],
				[Applicable FRA/OSHA Reg],[Cell Phone],[Copy of Report Attached],[Date of Accident],[Description of Accident],
				[Electric Bill],[Employer Name],[Food],[Gas Bill],[Home Phone],[Hour of Day Started Work],[Hours Worked DOA],
				[Injuries],[Location of Accident],[Lost income?],[Lost Wages Information],[Miles to PT],[Miles to Your Doctor],
				[Number People At Home?],[Overtime?  If so, # Hours],[Pay for Parking Dr or PT],[Send Lien Letter To],
				[Statement Given To],[Statement Taken?],[Time of Accident],[Time Working for Railroad],[Wage Paid by Employer],
				[Water or Sewer Bill],[We Have Apt Home Info],[We Have Cell Phone Bill],[We Have Electric Bill],[We Have Food Receipts],
				[We Have Gas Bill],[We Have Home Phone Bill],[We Have Parking Receipts],[We Have Water Sewer Bill],[Who Filed Report?],
				[Why Railroad Was at Fault] )
) as unpvt



----------------------------
--UDF DEFINITION
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
    vd.casnOrgCaseTypeID	as [udfnRelatedPK],
    vd.fieldTitle			as [udfsUDFName],   
    'Other3'				as [udfsScreenName],
    ucf.UDFType				as [udfsType],
    ucf.field_len			as [udfsLength],
    1						as [udfbIsActive],
	 'user_Tab9_Data'+ucf.column_name	as [udfshortName],
    ucf.dropdownValues		as [udfsNewValues],
    DENSE_RANK() over( order by vd.fieldTitle) as udfnSortOrder
FROM UserTab9_UDF3 vd
JOIN NeedlesUserFields ucf on ucf.field_title = vd.fieldtitle 
LEFT JOIN (select distinct table_Name, column_name From [NeosBrianWhite]..[document_merge_params] where table_Name = 'user_Tab9_Data') dmp
												on dmp.column_name = ucf.field_Title
LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = vd.casnOrgCaseTypeID and def.[udfsUDFName] = vd.fieldTitle and def.[udfsScreenName] = 'Other3' and udfstype = ucf.UDFType
WHERE def.udfnUDFID IS NULL
ORDER BY vd.fieldtitle
GO
--FROM [sma_MST_CaseType] CST
--JOIN CaseTypeMixture mix on mix.[SmartAdvocate Case Type] = cst.cstsType
--JOIN [NeosBrianWhite].[dbo].[user_tab9_matter] M on M.mattercode=mix.matcode and M.field_type <> 'label'
--JOIN (select DISTINCT fieldTitle from UserTab9_UDF3) vd on vd.FieldTitle = m.field_title
--JOIN NeedlesUserFields ucf on ucf.field_num = m.ref_num
--LEFT JOIN (select distinct table_Name, column_name From [NeosBrianWhite]..[document_merge_params] where table_Name = 'user_Tab9_Data') dmp
--												on dmp.column_name = ucf.field_Title
--LEFT JOIN [sma_MST_UDFDefinition] def on def.[udfnRelatedPK] = cst.cstnCaseTypeID and def.[udfsUDFName] = m.field_title and def.[udfsScreenName] = 'Other3' and udfstype = ucf.UDFType
--WHERE def.udfnUDFID IS NULL
--ORDER BY m.field_title
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
	def.udfnUDFID		as [udvnUDFID],
	'Other3'			as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	casnCaseID			as [udvnRelatedID],
	0					as [udvnSubRelatedID],
	--isnull(nm.UNQCID, udf.FieldVal)		as [udvsUDFValue],  --IF field is a Name, then use unique ID for "Contact" Types
	udf.FieldVal		as [udvsUDFValue],  --IF field is a Name, then use unique ID for "Contact" Types
	368					as [udvnRecUserID],
	getdate()			as [udvdDtCreated],
	null				as [udvnModifyUserID],
	null				as [udvdDtModified],
	null				as [udvnLevelNo]
--select *
FROM UserTab9_UDF3 udf
--LEFT JOIN (
--		select m.field_title, n.case_id, convert(varchar,ioc.UNQCID) as UNQCID --n.[user_name], ioc.*
--		from NeosBrianWhite..user_tab9_matter m
--		jOIN NeosBrianWhite..user_tab9_name n on m.ref_num = n.ref_num
--		LEFT JOIN IndvOrgContacts_Indexed ioc on ioc.saga = n.[user_name]
--		WHERE n.[user_name] <> 0 ) nm on nm.field_title = udf.FieldTitle and udf.case_id = nm.case_id
LEFT JOIN sma_MST_UDFDefinition def on def.udfnRelatedPK = udf.casnOrgCaseTypeID and def.udfsUDFName = FieldTitle and def.udfsScreenName = 'Other3'
GO

ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO

