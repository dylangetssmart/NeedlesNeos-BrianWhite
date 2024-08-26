
USE BrianWhiteSANeos
GO
/*
alter table [sma_TRN_Defendants] disable trigger all
delete from [sma_TRN_Defendants] 
DBCC CHECKIDENT ('[sma_TRN_Defendants]', RESEED, 0);
alter table [sma_TRN_Defendants] enable trigger all

alter table [sma_TRN_Plaintiff] disable trigger all
delete from [sma_TRN_Plaintiff] 
DBCC CHECKIDENT ('[sma_TRN_Plaintiff]', RESEED, 0);
alter table [sma_TRN_Plaintiff] enable trigger all

select * from [sma_TRN_Plaintiff] enable trigger all
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Plaintiff')
	)
BEGIN
	ALTER TABLE [sma_TRN_Plaintiff] ADD [saga_party] VARCHAR(50) NULL;
END

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_party'
			AND Object_ID = OBJECT_ID(N'sma_TRN_Defendants')
	)
BEGIN
	ALTER TABLE [sma_TRN_Defendants] ADD [saga_party] VARCHAR(50) NULL;
END


---
ALTER TABLE [sma_TRN_Plaintiff] DISABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Defendants] DISABLE TRIGGER ALL
GO
---

-------(1) sma_TRN_Plaintiff
INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID]
   ,[plnnContactCtg]
   ,[plnnContactID]
   ,[plnnAddressID]
   ,[plnnRole]
   ,[plnbIsPrimary]
   ,[plnbWCOut]
   ,[plnnPartiallySettled]
   ,[plnbSettled]
   ,[plnbOut]
   ,[plnbSubOut]
   ,[plnnSeatBeltUsed]
   ,[plnnCaseValueID]
   ,[plnnCaseValueFrom]
   ,[plnnCaseValueTo]
   ,[plnnPriority]
   ,[plnnDisbursmentWt]
   ,[plnbDocAttached]
   ,[plndFromDt]
   ,[plndToDt]
   ,[plnnRecUserID]
   ,[plndDtCreated]
   ,[plnnModifyUserID]
   ,[plndDtModified]
   ,[plnnLevelNo]
   ,[plnsMarked]
   ,[saga]
   ,[plnnNoInj]
   ,[plnnMissing]
   ,[plnnLIPBatchNo]
   ,[plnnPlaintiffRole]
   ,[plnnPlaintiffGroup]
   ,[plnnPrimaryContact]
   ,[plnsComments]
   ,[plnbIsClient]
   ,[saga_party]
	)
	SELECT
		CAS.casnCaseID  AS [plnnCaseID]
	   ,CIO.CTG			AS [plnnContactCtg]
	   ,CIO.CID			AS [plnnContactID]
	   ,CIO.AID			AS [plnnAddressID]
	   ,S.sbrnSubRoleId AS [plnnRole]
	   ,1				AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = p.staffcreatedid
		)				
		AS [plnnRecUserID]
	   ,p.date_created  AS [plndDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = p.staffmodifiedid
		)				
		AS [plnnModifyUserID]
	   ,p.date_modified AS [plndDtModified]
	   ,NULL			AS [plnnLevelNo]
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1				AS [plnnPrimaryContact]
	   ,ISNULL('Relationship: ' + NULLIF(CONVERT(VARCHAR, p.relationship), '') + CHAR(13), '') +
		''				AS [plnsComments]
	   ,p.our_client	AS [plnbIsClient]
	   ,P.id			AS [saga_party]
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), P.casesid)
	JOIN IndvOrgContacts_Indexed CIO
		ON CIO.saga_ref = CONVERT(VARCHAR(50), P.namesid)
	JOIN [BrianWhiteNeos]..party_role_list prl
		ON prl.id = p.partyrolelistid
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = prl.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 4
	WHERE pr.[sa party] = 'Plaintiff'
	ORDER BY p.record_num
GO

/*
select * from [sma_MST_SubRole]
---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [BrianWhiteSANeos].[dbo].[PartyRoles] where [SA Party]='Plaintiff'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN

    update [BrianWhiteSANeos].[dbo].[sma_TRN_Plaintiff] set plnnRole=S.sbrnSubRoleId
    from [BrianWhiteNeos].[dbo].[party_indexed] P 
    inner join [BrianWhiteSANeos].[dbo].[sma_TRN_Cases] CAS on CAS.cassCaseNumber = P.case_id  
    inner join [BrianWhiteSANeos].[dbo].[sma_MST_SubRole] S on CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=4 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed CIO on CIO.SAGA = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/

-------(2) [sma_TRN_Defendants]
INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID]
   ,[defnContactCtgID]
   ,[defnContactID]
   ,[defnAddressID]
   ,[defnSubRole]
   ,[defbIsPrimary]
   ,[defbCounterClaim]
   ,[defbThirdParty]
   ,[defsThirdPartyRole]
   ,[defnPriority]
   ,[defdFrmDt]
   ,[defdToDt]
   ,[defnRecUserID]
   ,[defdDtCreated]
   ,[defnModifyUserID]
   ,[defdDtModified]
   ,[defnLevelNo]
   ,[defsMarked]
   ,[saga]
   ,[defsComments]
   ,[defbIsClient]
   ,[saga_party]
	)
	SELECT
		casnCaseID		AS [defnCaseID]
	   ,ACIO.CTG		AS [defnContactCtgID]
	   ,ACIO.CID		AS [defnContactID]
	   ,ACIO.AID		AS [defnAddressID]
	   ,sbrnSubRoleId   AS [defnSubRole]
	   ,1				AS [defbIsPrimary]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = p.staffcreatedid
		)				
		AS [defnRecUserID]
	   ,p.date_created  AS [defdDtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = p.staffmodifiedid
		)				
		AS [defnModifyUserID]
	   ,p.date_modified AS [defdDtModified]
	   ,NULL			AS [defnLevelNo]
	   ,NULL
	   ,NULL
	   ,ISNULL('Relationship: ' + NULLIF(CONVERT(VARCHAR, p.relationship), '') + CHAR(13), '') +
		''				AS [defsComments]
	   ,p.our_client	AS [defbIsClient]
	   ,P.[id]			AS [saga_party]
	FROM [BrianWhiteNeos].[dbo].[party_indexed] P
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), P.casesid)
	JOIN IndvOrgContacts_Indexed ACIO
		ON ACIO.saga_ref = CONVERT(VARCHAR(50), P.namesid)
	JOIN [BrianWhiteNeos]..party_role_list prl
		ON prl.id = p.partyrolelistid
	JOIN [PartyRoles] pr
		ON pr.[Needles Roles] = prl.[role]
	JOIN [sma_MST_SubRole] S
		ON CAS.casnOrgCaseTypeID = S.sbrnCaseTypeID
			AND s.sbrsDscrptn = [sa roles]
			AND S.sbrnRoleID = 5
	WHERE pr.[sa party] = 'Defendant'
	ORDER BY p.record_num
GO


/*
from [BrianWhiteNeos].[dbo].[party_indexed] P 
inner join [BrianWhiteSANeos].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
inner join [BrianWhiteSANeos].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID
inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA_REF = P.party_id
where S.sbrnRoleID=5 and S.sbrsDscrptn='(D)-Default Role'
and P.role in (SELECT [Needles Roles] FROM [BrianWhiteSANeos].[dbo].[PartyRoles] where [SA Party]='Defendant')
GO

---( Now. do special role assignment )
DECLARE @needles_role varchar(100);
DECLARE @sa_role varchar(100);
DECLARE role_cursor CURSOR FOR 
SELECT [Needles Roles],[SA Roles] FROM [BrianWhiteSANeos].[dbo].[PartyRoles] where [SA Party]='Defendant'
 
OPEN role_cursor 
FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
WHILE @@FETCH_STATUS = 0
BEGIN


    update [BrianWhiteSANeos].[dbo].[sma_TRN_Defendants] set defnSubRole=S.sbrnSubRoleId
    from [BrianWhiteNeos].[dbo].[party_indexed] P 
    inner join [BrianWhiteSANeos].[dbo].[sma_TRN_Cases] C on C.cassCaseNumber = P.case_id  
    inner join [BrianWhiteSANeos].[dbo].[sma_MST_SubRole] S on C.casnOrgCaseTypeID = S.sbrnCaseTypeID and S.sbrnRoleID=5 and S.sbrsDscrptn=@sa_role
    inner join IndvOrgContacts_Indexed ACIO on ACIO.SAGA_REF = P.party_id
    where P.role=@needles_role
    and P.TableIndex=saga_party 

FETCH NEXT FROM role_cursor INTO @needles_role,@sa_role
END 
CLOSE role_cursor;
DEALLOCATE role_cursor;
GO
*/
---(Appendix A)-- every case need at least one plaintiff
INSERT INTO [sma_TRN_Plaintiff]
	(
	[plnnCaseID]
   ,[plnnContactCtg]
   ,[plnnContactID]
   ,[plnnAddressID]
   ,[plnnRole]
   ,[plnbIsPrimary]
   ,[plnbWCOut]
   ,[plnnPartiallySettled]
   ,[plnbSettled]
   ,[plnbOut]
   ,[plnbSubOut]
   ,[plnnSeatBeltUsed]
   ,[plnnCaseValueID]
   ,[plnnCaseValueFrom]
   ,[plnnCaseValueTo]
   ,[plnnPriority]
   ,[plnnDisbursmentWt]
   ,[plnbDocAttached]
   ,[plndFromDt]
   ,[plndToDt]
   ,[plnnRecUserID]
   ,[plndDtCreated]
   ,[plnnModifyUserID]
   ,[plndDtModified]
   ,[plnnLevelNo]
   ,[plnsMarked]
   ,[saga]
   ,[plnnNoInj]
   ,[plnnMissing]
   ,[plnnLIPBatchNo]
   ,[plnnPlaintiffRole]
   ,[plnnPlaintiffGroup]
   ,[plnnPrimaryContact]
	)

	SELECT
		casnCaseID AS [plnnCaseID]
	   ,1		   AS [plnnContactCtg]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Plaintiff'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [plnnContactID]
	   ,   -- Unidentified Plaintiff
		NULL	   AS [plnnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(P)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS plnnRole
	   ,1		   AS [plnbIsPrimary]
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,0
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,GETDATE()
	   ,NULL
	   ,368		   AS [plnnRecUserID]
	   ,GETDATE()  AS [plndDtCreated]
	   ,NULL
	   ,NULL
	   ,''
	   ,NULL
	   ,''
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1		   AS [plnnPrimaryContact]
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Plaintiff] T
		ON T.plnnCaseID = CAS.casnCaseID
	WHERE plnnCaseID IS NULL
GO

UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 0

UPDATE sma_TRN_Plaintiff
SET plnbIsPrimary = 1
FROM (
	SELECT DISTINCT
		T.plnnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY T.plnnCaseID ORDER BY P.record_num) AS RowNumber
	   ,T.plnnPlaintiffID AS ID
	FROM sma_TRN_Plaintiff T
	LEFT JOIN [BrianWhiteNeos].[dbo].[party_indexed] P
		ON P.[id] = T.saga_party
) A
WHERE A.RowNumber = 1
AND plnnPlaintiffID = A.ID



---(Appendix B)-- every case need at least one defendant
INSERT INTO [sma_TRN_Defendants]
	(
	[defnCaseID]
   ,[defnContactCtgID]
   ,[defnContactID]
   ,[defnAddressID]
   ,[defnSubRole]
   ,[defbIsPrimary]
   ,[defbCounterClaim]
   ,[defbThirdParty]
   ,[defsThirdPartyRole]
   ,[defnPriority]
   ,[defdFrmDt]
   ,[defdToDt]
   ,[defnRecUserID]
   ,[defdDtCreated]
   ,[defnModifyUserID]
   ,[defdDtModified]
   ,[defnLevelNo]
   ,[defsMarked]
   ,[saga]
	)
	SELECT
		casnCaseID AS [defnCaseID]
	   ,1		   AS [defnContactCtgID]
	   ,(
			SELECT
				cinncontactid
			FROM sma_MST_IndvContacts
			WHERE cinsFirstName = 'Defendant'
				AND cinsLastName = 'Unidentified'
		)		   
		AS [defnContactID]
	   ,NULL	   AS [defnAddressID]
	   ,(
			SELECT
				sbrnSubRoleId
			FROM sma_MST_SubRole S
			INNER JOIN sma_MST_SubRoleCode C
				ON C.srcnCodeId = S.sbrnTypeCode
				AND C.srcsDscrptn = '(D)-Default Role'
			WHERE S.sbrnCaseTypeID = CAS.casnOrgCaseTypeID
		)		   
		AS [defnSubRole]
	   ,1		   AS [defbIsPrimary]
	   , -- reexamine??
		NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,368		   AS [defnRecUserID]
	   ,GETDATE()  AS [defdDtCreated]
	   ,368		   AS [defnModifyUserID]
	   ,GETDATE()  AS [defdDtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	FROM sma_trn_cases CAS
	LEFT JOIN [sma_TRN_Defendants] D
		ON D.defnCaseID = CAS.casnCaseID
	WHERE D.defnCaseID IS NULL

----
UPDATE sma_TRN_Defendants
SET defbIsPrimary = 0

UPDATE sma_TRN_Defendants
SET defbIsPrimary = 1
FROM (
	SELECT DISTINCT
		D.defnCaseID
	   ,ROW_NUMBER() OVER (PARTITION BY D.defnCaseID ORDER BY P.record_num) AS RowNumber
	   ,D.defnDefendentID AS ID
	FROM sma_TRN_Defendants D
	LEFT JOIN [BrianWhiteNeos].[dbo].[party_indexed] P
		ON P.[id] = D.saga_party
) A
WHERE A.RowNumber = 1
AND defnDefendentID = A.ID

GO

---
ALTER TABLE [sma_TRN_Defendants] ENABLE TRIGGER ALL
GO
ALTER TABLE [sma_TRN_Plaintiff] ENABLE TRIGGER ALL
GO
---







