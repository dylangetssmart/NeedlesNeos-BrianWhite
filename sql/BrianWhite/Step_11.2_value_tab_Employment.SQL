
USE SANeosBrianWhite
GO

/*
alter table [dbo].[sma_TRN_Employment] disable trigger all
delete [dbo].[sma_TRN_Employment]
DBCC CHECKIDENT ('[dbo].[sma_TRN_Employment]', RESEED, 0);
alter table [dbo].[sma_TRN_Employment] enable trigger all

alter table [dbo].[sma_TRN_LostWages] disable trigger all
delete [dbo].[sma_TRN_LostWages]
DBCC CHECKIDENT ('[dbo].[sma_TRN_LostWages]', RESEED, 0);
alter table [dbo].[sma_TRN_LostWages] enable trigger all

delete from sma_TRN_SpDamages where spdsreftable='LostWages'
*/

---(0)---
if not exists (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_TRN_Employment'))
begin
    ALTER TABLE [sma_TRN_Employment] 
	ADD [saga] varchar(50) NULL; 
end
GO

---(0)---
if exists (select * from sys.objects where name='value_tab_Employment_Helper' and type='U')
begin
	drop table value_tab_Employment_Helper
end 
GO

---(0)---
create table value_tab_Employment_Helper (
    TableIndex [int] IDENTITY(1,1) NOT NULL,
    case_id		    varchar(50),
    value_id		 varchar(50),
    ProviderNameId	    varchar(50),
    ProviderName	    varchar(200),
    ProviderCID	    int,
    ProviderCTG	    int,
    ProviderAID	    int,
    casnCaseID		    int,
    PlaintiffID	    int,
CONSTRAINT IOC_Clustered_Index_value_tab_Employment_Helper PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_case_id ON SANeosBrianWhite.[dbo].[value_tab_Employment_Helper] (case_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_value_id ON SANeosBrianWhite.[dbo].[value_tab_Employment_Helper] (value_id);   
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_tab_Employment_Helper_ProviderNameId ON SANeosBrianWhite.[dbo].[value_tab_Employment_Helper] (ProviderNameId);   
GO

---(0)---
insert into value_tab_Employment_Helper ( case_id,value_id,ProviderNameId,ProviderName,ProviderCID,ProviderCTG,ProviderAID,casnCaseID,PlaintiffID )
select
    V.casesid		    as case_id,	-- needles case
    V.id			    as value_id,		-- needles records TAB item
    V.namesid		    as ProviderNameId,  
    IOC.Name		    as ProviderName,
    IOC.CID		    as ProviderCID,  
    IOC.CTG		    as ProviderCTG,
    IOC.AID		    as ProviderAID,
    CAS.casnCaseID	    as casnCaseID,
    null			    as PlaintiffID  
--select *
from [NeosBrianWhite]..[value_Indexed] V
JOIN [NeosBrianWhite]..[value_code] vc on vc.id = v.valuecodeid
JOIN [sma_TRN_cases] CAS on CAS.neos_saga = convert(varchar(50),V.casesid)
JOIN IndvOrgContacts_Indexed IOC on ioc.SAGA_ref = convert(varchar(50),v.namesid) --and isnull(convert(varchar(50),v.namesid),'')<>''
WHERE vc.code in ( 'LOSTWAGE')
GO

---(0)---
DBCC DBREINDEX('value_tab_Employment_Helper',' ',90)  WITH NO_INFOMSGS 
GO


---(0)---
if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

select 
    V.casesid		    as cid,	
    V.id			    as vid,
    T.plnnPlaintiffID
INTO value_tab_Multi_Party_Helper_Temp   
--SELECT *
from NeosBrianWhite..[value_Indexed] V
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN [sma_TRN_Plaintiff] t on t.plnnCaseID=CAS.casnCaseID and t.saga_party = v.partyid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = convert(varchar(50),V.partyid)
--JOIN [sma_TRN_Plaintiff] T on T.plnnContactID=IOC.CID and T.plnnContactCtg=IOC.CTG and T.plnnCaseID=CAS.casnCaseID
GO

update value_tab_Employment_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO


if exists (select * from sys.objects where Name='value_tab_Multi_Party_Helper_Temp')
begin
    drop table value_tab_Multi_Party_Helper_Temp
end
GO

select 
    V.casesid		    as cid,	
    V.id			    as vid,
    ( select plnnPlaintiffID from [sma_TRN_Plaintiff] where plnnCaseID=CAS.casnCaseID and plnbIsPrimary=1) as plnnPlaintiffID 
INTO value_tab_Multi_Party_Helper_Temp   
--SELECT *
from NeosBrianWhite.[dbo].[value_Indexed] V
JOIN [sma_TRN_cases] CAS on CAS.Neos_saga = convert(varchar(50),V.casesid)
JOIN [sma_TRN_Defendants] d on d.defnCaseID = cas.casncaseid and d.saga_party = v.partyid
--JOIN [IndvOrgContacts_Indexed] IOC on IOC.SAGA_ref = V.party_id
--JOIN [sma_TRN_Defendants] D on D.defnContactID=IOC.CID and D.defnContactCtgID=IOC.CTG and D.defnCaseID=CAS.casnCaseID
GO

update value_tab_Employment_Helper set PlaintiffID=A.plnnPlaintiffID
from value_tab_Multi_Party_Helper_Temp A
where case_id=A.cid and value_id=A.vid
GO


---(1)---
INSERT INTO [dbo].[sma_TRN_Employment]
(
    empnPlaintiffID,
    empnEmprAddressID,
    empnEmployerID,
    empnEmpUnion,
    empsJobTitle,
    empsCompensationComments,
    empnAverageWeeklyWage,
    empnSalaryAmt,
    empbOnTheJob,
    empbWCClaim,
    empdDateHired,
    empsComments,
    saga
)

SELECT  --MAP.case_id,
    MAP.PlaintiffID		   as empnPlaintiffID,
    MAP.ProviderAID		   as empnEmprAddressID,
    MAP.ProviderCID		   as empnEmployerID,
    null				   as empnEmpUnion,
    null				   as empsJobTitle,
    V.memo				  as empsCompensationComments,
    null				   as empnAverageWeeklyWage,
    null				   as empnSalaryAmt,
    null				   as empbOnTheJob,
    null				   as empbWCClaim,
    null				   as empdDateHired,
    null				   as empsComments,
    v.id				   as saga
--select *
FROM [NeosBrianWhite]..[value_Indexed] V
JOIN value_tab_Employment_Helper MAP on MAP.case_id = V.casesid and MAP.value_id = V.id

---(2)---
INSERT INTO [sma_TRN_LostWages]
(
       [ltwnEmploymentID]
      ,[ltwsType]
      ,[ltwdFrmDt]
      ,[ltwdToDt]
      ,[ltwnAmount]
      ,[ltwnAmtPaid]
      ,[ltwnLoss]
      ,[ltwdMDConfReqDt]
      ,[ltwdMDConfDt]
      ,[ltwdEmpVerfReqDt]
      ,[ltwdEmpVerfRcvdDt]
      ,[ltwnRecUserID]
      ,[ltwdDtCreated]
      ,[ltwnModifyUserID]
      ,[ltwdDtModified]
      ,[ltwnLevelNo]
)
SELECT
    EM.empnEmploymentID				as [ltwnEmploymentID],
    (select wgtnWagesTypeID from [dbo].[sma_MST_WagesTypes] where wgtsDscrptn='Salary')	as [ltwsType],
    case
	   when v.[start_date] between '1900-01-01' and '2079-06-06' then v.[start_date]
	   else null  end				as [ltwdFrmDt],
    case
	   when v.[stop_date] between '1900-01-01' and '2079-06-06' then v.[stop_date]
	   else null  end				as [ltwdToDt],
    null							as [ltwnAmount],
    null							as [ltwnAmtPaid],
    V.total_value					as [ltwnLoss],
    null							as [ltwdMDConfReqDt],
    null							as [ltwdMDConfDt],
    null							as [ltwdEmpVerfReqDt],
    null							as [ltwdEmpVerfRcvdDt],
    368								as [ltwnRecUserID],
    getdate()						as [ltwdDtCreated],
    null							as [ltwnModifyUserID],
    null							as [ltwdDtModified],
    null							as [ltwnLevelNo]
FROM [NeosBrianWhite]..[value_Indexed] V
JOIN [sma_TRN_Employment] EM on EM.saga=convert(varchar(50),v.id)
GO


INSERT INTO [sma_TRN_SpDamages]
(
     spdsRefTable
    ,spdnRecordID
    ,spdnRecUserID
    ,spddDtCreated
    ,spdnLevelNo
    ,spdnBillAmt
    ,spddDateFrom
    ,spddDateTo
)
SELECT DISTINCT 
    'LostWages'	    as spdsRefTable,
    ltwnLostWagesID	    as spdnRecordID,
    368			    as spdnRecUserID,
    getdate()		    as spddDtCreated,
    0			    as spdnLevelNo,
    ltwnLoss		    as spdnBillAmt,
    ltwdFrmDt		    as spddDateFrom,
    ltwdToDt		    as spddDateTo
FROM sma_TRN_LostWages 
GO

