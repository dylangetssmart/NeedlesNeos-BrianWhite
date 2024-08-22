
USE SANeosBrianWhite
GO

DECLARE @FileId int;
DECLARE @addnContactID int;
DECLARE @addnAddressID int;
DECLARE @addnContactCtgID int;
DECLARE @UTCCreationDateTime DateTime;
DECLARE @label varchar(100);
 
DECLARE OtherContact_cursor CURSOR FOR 
SELECT DISTINCT 
    CAS.casnCaseID,
    IOC.CID,
    IOC.AID,
    '',
    IOC.CTG,
    case
	   when Pr.[role] = 'See Relationship' then P.[relationship]
	   when Pr.[role] = 'Witness' then 'Witness ' + isnull(': ' + nullif(P.relationship,''),'')
	   else null
    end
FROM [NeosBrianWhite].[dbo].[party_Indexed] P 
JOIN [NeosBrianWhite].[dbo].[party_role_list] PR on pr.id = p.[partyrolelistid]
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),p.casesid)
JOIN IndvOrgContacts_Indexed IOC on IOC.SAGA_ref = convert(varchar(50),P.namesid)
WHERE Pr.[role] in
(
'See Relationship',
'Witness'
)



OPEN OtherContact_cursor 

FETCH NEXT FROM OtherContact_cursor 
INTO @FileId,@addnContactID,@addnAddressID,@UTCCreationDateTime,@addnContactCtgID,@label

WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @p1 VARCHAR(80);

EXEC [dbo].[sma_SP_Insert_OtherCaseRelatedContacts]
@CaseID=@FileId,   
@ContactID=@addnContactID,
@ContactCtgID=@addnContactCtgID,
@ContactAddressID=@addnAddressID,
@ContactRoleID=@label,
@ContactCreatedUserID=368,
@ContactComment=null,
@identity_column_value=@p1

PRINT @p1

FETCH NEXT FROM OtherContact_cursor 
INTO @FileId,@addnContactID,@addnAddressID,@UTCCreationDateTime,@addnContactCtgID,@label

END 

CLOSE OtherContact_cursor;
DEALLOCATE OtherContact_cursor;

GO

