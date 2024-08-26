
use BrianWhiteSA
GO

/*
---(Supporting Statements)---
select 'when LIST.column_name=' + ''''+ F.column_name +'''' + ' then convert(varchar(MAX),UD.' + F.column_name + ')',
'isnull( convert(varchar,'+F.column_name +'),'''')<>'''' or '
from [BrianWhiteNeos].[dbo].[user_case_fields] F
where field_title in ( select distinct field_title from [BrianWhiteNeos].[dbo].[user_party_matter] ) 
*/


----(0)---- build a supporting table with anchors and values
if exists (select * from sys.objects where name='UDF_Helper' and type='U')
begin
    drop table UDF_Helper
end
GO
----(0)---- 
create table UDF_Helper
(
    tableIndex		int IDENTITY(1,1) NOT NULL,
    ref_num			int,		
    column_name		varchar(100),	
    field_title		varchar(100),	
    mattercode		varchar(100),
	UDFType			varchar(30),
	field_len		varchar(20)
 CONSTRAINT IX_UDF_Helper PRIMARY KEY CLUSTERED 
(
	tableIndex
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_ref_num ON UDF_Helper (ref_num);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_column_name ON UDF_Helper (column_name);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_field_title ON UDF_Helper (field_title); 
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_mattercode ON UDF_Helper (mattercode); 
GO  
--select * From UDF_Helper

----(0)---- 
insert into UDF_Helper (
    ref_num,
    column_name,
    field_title,
    mattercode,
	UDFType,
	field_len
)
select ref_num,F.column_name,F.field_title,M.mattercode , udftype, f.field_len
from [BrianWhiteNeos].[dbo].[user_party_matter] M 
JOIN NeedlesUserFields F on F.field_num=M.ref_num 
JOIN [PartyRoles] R on R.[Needles Roles]=M.party_role
where R.[SA Party]='Plaintiff'
GO
----(0)---- 
DBCC DBREINDEX('UDF_Helper',' ',90) WITH NO_INFOMSGS 
/*
----------------------BUILD USER PARTY HELPER----------------------
if exists (select * from sys.objects where name='UserParty_Helper' and type='U')
begin
    drop table UserParty_Helper
end
GO

select p.tableindex, party_ID, case_ID, [role], [sa party],IOC.CID, IOC.CTG, IOC.AID, IOC.UNQCID, IOC.Name, IOC.SAGA 
INTO UserParty_Helper
From [BrianWhiteNeos].[dbo].[party_Indexed] P
JOIN [BrianWhiteSA].[dbo].[IndvOrgContacts_Indexed] IOC on IOC.SAGA = P.party_id
JOIN [BrianWhiteSA].[dbo].[PartyRoles] R on R.[Needles Roles]=p.[role]
*/
--select * from BrianWhiteNeos..user_case_fields

---(1/2)---
INSERT INTO [sma_MST_UDFDefinition]
(
    [udfsUDFCtg]
    ,[udfnRelatedPK]
    ,[udfsUDFName]
    ,[udfsScreenName]
    ,[udfsType]
    ,[udfsLength]
    ,[udfbIsActive]
    ,[udfnLevelNo]
	,[UdfShortName]
	,[udfsNewValues]
    ,[udfnSortOrder]
)
select 
    A.[udfsUDFCtg],
    A.[udfnRelatedPK],
    A.[udfsUDFName],   
    A.[udfsScreenName],
    A.[udfsType],
    A.[udfsLength],
    A.[udfbIsActive],
	A.[udfnLevelNo],
	A.[udfshortName],
	a.[udfsNewValues],
    DENSE_RANK() over( order by A.[udfsUDFName]) as udfnSortOrder
FROM
(
SELECT DISTINCT 
    'C'					   as [udfsUDFCtg],
    CST.cstnCaseTypeID	   as [udfnRelatedPK],
    M.field_title		   as [udfsUDFName],   
    r.[SA Party]		   as [udfsScreenName],
    ucf.UDFType			   as [udfsType],
    ucf.field_len		   as [udfsLength],
    1					   as [udfbIsActive],
	'user_party_Data'+ ucf.column_name		as [udfshortName],
	ucf.dropdownValues	   as [udfsNewValues],
    M.ref_num			   as [udfnLevelNo]
FROM [sma_MST_CaseType] CST
JOIN CaseTypeMixture mix on mix.[SmartAdvocate Case Type] = cst.cstsType
JOIN [BrianWhiteNeos].[dbo].[user_party_matter] M on M.mattercode=mix.matcode
JOIN [PartyRoles] R on R.[Needles Roles]=M.party_role
JOIN NeedlesUserFields ucf on m.ref_num = ucf.field_num
LEFT JOIN (select distinct table_Name, column_name From [BrianWhiteNeos].[dbo].[document_merge_params] where table_Name = 'user_party_Data') dmp
												on dmp.column_name = ucf.column_Name
LEFT JOIN [sma_MST_UDFDefinition] udf on udf.udfnRelatedPK = cst.cstnCaseTypeID and udf.udfsScreenName = [SA Party] and udf.udfsUDFName = m.field_title and udfstype = ucf.UDFType
WHERE R.[SA Party]='Plaintiff'
and CST.VenderCaseType='SchechterCaseType'
and udf.udfnUDFID IS NULL
) A

GO

alter table sma_TRN_UDFValues disable trigger all
GO

---(2/2)---
insert into [sma_TRN_UDFValues]
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
select DISTINCT
	(select top 1 udfnUDFID from [sma_MST_UDFDefinition] 
		where udfnRelatedPK=casnOrgCaseTypeID and udfsUDFName=LIST.field_title and udfsScreenName='Plaintiff' and udfstype=UDFType)
						as [udvnUDFID],
	'Plaintiff'			as [udvsScreenName],
	'C'					as [udvsUDFCtg],
	CAS.casnCaseID		as [udvnRelatedID],
	T.plnnPlaintiffID	as[udvnSubRelatedID],
	case
		when LIST.column_name='Agent_for_Service' then convert(varchar(MAX),UD.Agent_for_Service)
		when LIST.column_name='At_What_Wage' then convert(varchar(MAX),UD.At_What_Wage)
		when LIST.column_name='Average_Weekly_Wages' then convert(varchar(MAX),UD.Average_Weekly_Wages)
		when LIST.column_name='Bankruptcy_Information' then convert(varchar(MAX),UD.Bankruptcy_Information)
		when LIST.column_name='Business_Type' then convert(varchar(MAX),UD.Business_Type)
		when LIST.column_name='Caller_ID_number' then convert(varchar(MAX),UD.Caller_ID_number)
		when LIST.column_name='Certificates_and_Licenses' then convert(varchar(MAX),UD.Certificates_and_Licenses)
		when LIST.column_name='Children' then convert(varchar(MAX),UD.Children)
		when LIST.column_name='Court_Order_Child_Support' then convert(varchar(MAX),UD.Court_Order_Child_Support)
		when LIST.column_name='Digital_Signature' then convert(varchar(MAX),UD.Digital_Signature)
		when LIST.column_name='Do_Not_Contact' then convert(varchar(MAX),UD.Do_Not_Contact)
		when LIST.column_name='Drivers_License_#' then convert(varchar(MAX),UD.Drivers_License_#)
		when LIST.column_name='Education' then convert(varchar(MAX),UD.Education)
		when LIST.column_name='Employer_Name' then convert(varchar(MAX),UD.Employer_Name)
		when LIST.column_name='Employment_History' then convert(varchar(MAX),UD.Employment_History)
		when LIST.column_name='Employment_Status' then convert(varchar(MAX),UD.Employment_Status)
		when LIST.column_name='Guardian' then convert(varchar(MAX),UD.Guardian)
		when LIST.column_name='Injuries' then convert(varchar(MAX),UD.Injuries)
		when LIST.column_name='Length_of_Employment' then convert(varchar(MAX),UD.Length_of_Employment)
		when LIST.column_name='Lives_with_Whom' then convert(varchar(MAX),UD.Lives_with_Whom)
		when LIST.column_name='Losing_Time' then convert(varchar(MAX),UD.Losing_Time)
		when LIST.column_name='Lost_income' then convert(varchar(MAX),UD.Lost_income)
		when LIST.column_name='Marital_Status' then convert(varchar(MAX),UD.Marital_Status)
		when LIST.column_name='Medical_History' then convert(varchar(MAX),UD.Medical_History)
		when LIST.column_name='MedicareMedicaid_#' then convert(varchar(MAX),UD.MedicareMedicaid_#)
		when LIST.column_name='Newsletter' then convert(varchar(MAX),UD.Newsletter)
		when LIST.column_name='Other_Employment' then convert(varchar(MAX),UD.Other_Employment)
		when LIST.column_name='Pay_Period' then convert(varchar(MAX),UD.Pay_Period)
		when LIST.column_name='Previous_Complaints' then convert(varchar(MAX),UD.Previous_Complaints)
		when LIST.column_name='Prior_Accidents' then convert(varchar(MAX),UD.Prior_Accidents)
		when LIST.column_name='Prior_Conditions' then convert(varchar(MAX),UD.Prior_Conditions)
		when LIST.column_name='Prior_Lawsuits' then convert(varchar(MAX),UD.Prior_Lawsuits)
		when LIST.column_name='Rate_of_Pay' then convert(varchar(MAX),UD.Rate_of_Pay)
		when LIST.column_name='Registered_Agent' then convert(varchar(MAX),UD.Registered_Agent)
		when LIST.column_name='Returned_to_Work' then convert(varchar(MAX),UD.Returned_to_Work)
		when LIST.column_name='Role_in_Accident' then convert(varchar(MAX),UD.Role_in_Accident)
		when LIST.column_name='Spouse_Name' then convert(varchar(MAX),UD.Spouse_Name)
		when LIST.column_name='State_for_Tax_Returns' then convert(varchar(MAX),UD.State_for_Tax_Returns)
		when LIST.column_name='Statement_Given_To' then convert(varchar(MAX),UD.Statement_Given_To)
		when LIST.column_name='Treatment_Since_Injury' then convert(varchar(MAX),UD.Treatment_Since_Injury)
		when LIST.column_name='Union_Membership' then convert(varchar(MAX),UD.Union_Membership)
		when LIST.column_name='While_Working' then convert(varchar(MAX),UD.While_Working)
		when LIST.column_name='Z_Card_#' then convert(varchar(MAX),UD.Z_Card_#)
     end					as [udvsUDFValue],
	368						as [udvnRecUserID],
	getdate()				as [udvdDtCreated],
	null					as [udvnModifyUserID],
	null					as [udvdDtModified],
	null					as [udvnLevelNo]
	--select * --cas.casncaseid, T.plnnPlaintiffID, cst.cstscode, p.role, casnOrgCaseTypeID, t.saga_party, p.tableindex, ud.*
FROM [BrianWhiteNeos].[dbo].[user_party_data] UD 
JOIN [BrianWhiteNeos].[dbo].[cases_Indexed] ci on ud.case_id = ci.casenum
JOIN [sma_TRN_cases] CAS on CAS.cassCaseNumber = convert(varchar,UD.case_id)
JOIN [sma_MST_CaseType] CST on CST.cstnCaseTypeID=CAS.casnOrgCaseTypeID and VenderCaseType='SchechterCaseType'
join [BrianWhiteNeos].[dbo].[party_Indexed] P on P.party_id=UD.party_id and P.case_id=UD.case_id
JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA = UD.party_id
join sma_TRN_Plaintiff T on P.TableIndex= T.[saga_party]
join UDF_Helper LIST on LIST.mattercode=ci.matcode
join (SELECT [Needles Roles] FROM [BrianWhiteSA].[dbo].[PartyRoles] where [SA Party]='Plaintiff') N on N.[Needles Roles]=P.[role]
WHERE (
		isnull( convert(varchar,Agent_for_Service),'')<>'' or 
		isnull( convert(varchar,At_What_Wage),'')<>'' or 
		isnull( convert(varchar,Average_Weekly_Wages),'')<>'' or 
		isnull( convert(varchar,Bankruptcy_Information),'')<>'' or 
		isnull( convert(varchar,Business_Type),'')<>'' or 
		isnull( convert(varchar,Caller_ID_number),'')<>'' or 
		isnull( convert(varchar,Certificates_and_Licenses),'')<>'' or 
		isnull( convert(varchar,Children),'')<>'' or 
		isnull( convert(varchar,Court_Order_Child_Support),'')<>'' or 
		isnull( convert(varchar,Digital_Signature),'')<>'' or 
		isnull( convert(varchar,Do_Not_Contact),'')<>'' or 
		isnull( convert(varchar,Drivers_License_#),'')<>'' or 
		isnull( convert(varchar,Education),'')<>'' or 
		isnull( convert(varchar,Employer_Name),'')<>'' or 
		isnull( convert(varchar,Employment_History),'')<>'' or 
		isnull( convert(varchar,Employment_Status),'')<>'' or 
		isnull( convert(varchar,Guardian),'')<>'' or 
		isnull( convert(varchar,Injuries),'')<>'' or 
		isnull( convert(varchar,Length_of_Employment),'')<>'' or 
		isnull( convert(varchar,Lives_with_Whom),'')<>'' or 
		isnull( convert(varchar,Losing_Time),'')<>'' or 
		isnull( convert(varchar,Lost_income),'')<>'' or 
		isnull( convert(varchar,Marital_Status),'')<>'' or 
		isnull( convert(varchar,Medical_History),'')<>'' or 
		isnull( convert(varchar,MedicareMedicaid_#),'')<>'' or 
		isnull( convert(varchar,Newsletter),'')<>'' or 
		isnull( convert(varchar,Other_Employment),'')<>'' or 
		isnull( convert(varchar,Pay_Period),'')<>'' or 
		isnull( convert(varchar,Previous_Complaints),'')<>'' or 
		isnull( convert(varchar,Prior_Accidents),'')<>'' or 
		isnull( convert(varchar,Prior_Conditions),'')<>'' or 
		isnull( convert(varchar,Prior_Lawsuits),'')<>'' or 
		isnull( convert(varchar,Rate_of_Pay),'')<>'' or 
		isnull( convert(varchar,Registered_Agent),'')<>'' or 
		isnull( convert(varchar,Returned_to_Work),'')<>'' or 
		isnull( convert(varchar,Role_in_Accident),'')<>'' or 
		isnull( convert(varchar,Spouse_Name),'')<>'' or 
		isnull( convert(varchar,State_for_Tax_Returns),'')<>'' or 
		isnull( convert(varchar,Statement_Given_To),'')<>'' or 
		isnull( convert(varchar,Treatment_Since_Injury),'')<>'' or 
		isnull( convert(varchar,Union_Membership),'')<>'' or 
		isnull( convert(varchar,While_Working),'')<>'' or 
		isnull( convert(varchar,Z_Card_#),'')<>'' 
)
	
ALTER TABLE sma_TRN_UDFValues ENABLE TRIGGER ALL
GO