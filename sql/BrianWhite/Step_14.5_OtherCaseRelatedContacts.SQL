
USE BrianWhiteSA
GO

DECLARE @FileId INT;
DECLARE @addnContactID INT;
DECLARE @addnAddressID INT;
DECLARE @addnContactCtgID INT;
DECLARE @UTCCreationDateTime DATETIME;
DECLARE @label VARCHAR(100);

DECLARE OtherContact_cursor CURSOR FOR SELECT DISTINCT
	CAS.casnCaseID
   ,IOC.CID
   ,IOC.AID
   ,''
   ,IOC.CTG
   ,CASE
		WHEN Pr.[role] = 'See Relationship'
			THEN P.[relationship]
		WHEN Pr.[role] = 'Witness'
			THEN 'Witness ' + ISNULL(': ' + NULLIF(P.relationship, ''), '')
		ELSE NULL
	END
FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
JOIN [BrianWhiteNeos].[dbo].[party_role_list] PR
	ON pr.id = p.[partyrolelistid]
JOIN [sma_TRN_Cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), p.casesid)
JOIN IndvOrgContacts_Indexed IOC
	ON IOC.SAGA_ref = CONVERT(VARCHAR(50), P.namesid)
WHERE Pr.[role] IN
	(
	'See Relationship',
	'Witness'
	)



OPEN OtherContact_cursor

FETCH NEXT FROM OtherContact_cursor
INTO @FileId, @addnContactID, @addnAddressID, @UTCCreationDateTime, @addnContactCtgID, @label

WHILE @@FETCH_STATUS = 0
BEGIN

DECLARE @p1 VARCHAR(80);

EXEC [dbo].[sma_SP_Insert_OtherCaseRelatedContacts] @CaseID = @FileId
												   ,@ContactID = @addnContactID
												   ,@ContactCtgID = @addnContactCtgID
												   ,@ContactAddressID = @addnAddressID
												   ,@ContactRoleID = @label
												   ,@ContactCreatedUserID = 368
												   ,@ContactComment = NULL
												   ,@identity_column_value = @p1

PRINT @p1

FETCH NEXT FROM OtherContact_cursor
INTO @FileId, @addnContactID, @addnAddressID, @UTCCreationDateTime, @addnContactCtgID, @label

END

CLOSE OtherContact_cursor;
DEALLOCATE OtherContact_cursor;

GO

