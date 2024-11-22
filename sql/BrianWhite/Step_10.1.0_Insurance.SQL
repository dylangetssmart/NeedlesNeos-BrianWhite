USE [BrianWhiteSA]
GO

/*
alter table [sma_TRN_InsuranceCoverage] disable trigger all
delete from [sma_TRN_InsuranceCoverage]
DBCC CHECKIDENT ('[sma_TRN_InsuranceCoverage]', RESEED, 0);
alter table [sma_TRN_InsuranceCoverage] disable trigger all

truncate table [sma_TRN_InsuranceCoverageAdjusters]
*/

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND object_id = OBJECT_ID(N'sma_TRN_InsuranceCoverage')
	)
BEGIN
	ALTER TABLE [sma_TRN_InsuranceCoverage]
	ADD [saga] VARCHAR(50);
END

ALTER TABLE sma_trn_InsuranceCoverage
ALTER COLUMN [incsPolicyNo] VARCHAR(35)
GO

ALTER TABLE sma_trn_InsuranceCoverage
ALTER COLUMN [incsClaimNo] VARCHAR(45)
GO

---------------------------------------------------------------------------
-------------INSURANCE COMMENTS FROM USER_INSURANCE_DATA TABLE-------------
---------------------------------------------------------------------------
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'Insurance_Comment_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Insurance_Comment_Helper
END
GO

SELECT
	td.insuranceid
   ,STRING_AGG(ucf.field_title + ': ' + td.[data], CHAR(10) + CHAR(13)) AS ins_comment INTO Insurance_Comment_Helper
FROM [BrianWhiteNeos]..user_insurance_data td
JOIN [BrianWhiteNeos]..user_case_fields ucf
	ON ucf.id = td.usercasefieldid
GROUP BY td.insuranceid

-------------------------------------------------------------------------------
---------------------------INSURANCE CONTACTS HELPER---------------------------
-------------------------------------------------------------------------------
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'Insurance_Contacts_Helper'
			AND type = 'U'
	)
BEGIN
	DROP TABLE Insurance_Contacts_Helper
END
GO

CREATE TABLE Insurance_Contacts_Helper (
	tableIndex INT IDENTITY (1, 1) NOT NULL
   ,insurance_id VARCHAR(50)
   ,		-- table id
	insurer_id VARCHAR(50)
   ,			-- insurance company
	adjuster_id VARCHAR(50)
   ,		-- adjuster
	insured VARCHAR(100)
   ,	-- a person or organization covered by insurance
	incnInsContactID INT
   ,incnInsAddressID INT
   ,incnAdjContactId INT
   ,incnAdjAddressID INT
   ,incnInsured INT
   ,pord VARCHAR(1)
   ,caseID INT
   ,PlaintiffDefendantID INT
	CONSTRAINT IX_Insurance_Contacts_Helper PRIMARY KEY CLUSTERED
	(
	tableIndex
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurance_id ON Insurance_Contacts_Helper (insurance_id);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurer_id ON Insurance_Contacts_Helper (insurer_id);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_adjuster_id ON Insurance_Contacts_Helper (adjuster_id);
GO

---(0)---
INSERT INTO Insurance_Contacts_Helper
	(
	insurance_id, insurer_id, adjuster_id, insured, incnInsContactID, incnInsAddressID, incnAdjContactId, incnAdjAddressID, incnInsured, pord, caseID, PlaintiffDefendantID
	)
	SELECT
		CONVERT(VARCHAR(50), INS.id)
	   ,CONVERT(VARCHAR(50), INS.insurer_namesid)
	   ,CONVERT(VARCHAR(50), INS.adjuster_namesid)
	   ,INS.insured
	   ,IOC1.CID			 AS incnInsContactID
	   ,IOC1.AID			 AS incnInsAddressID
	   ,IOC2.CID			 AS incnAdjContactId
	   ,IOC2.AID			 AS incnAdjAddressID
	   ,INFO.UniqueContactId AS incnInsured
	   ,NULL				 AS pord
	   ,CAS.casnCaseID		 AS caseID
	   ,NULL				 AS PlaintiffDefendantID
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[insurance_Indexed] INS
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), INS.casesid)
	JOIN IndvOrgContacts_Indexed IOC1
		ON IOC1.saga_ref = CONVERT(VARCHAR(50), INS.insurer_namesid)
	LEFT JOIN IndvOrgContacts_Indexed IOC2
		ON IOC2.saga_ref = CONVERT(VARCHAR(50), INS.adjuster_namesid)
	LEFT JOIN [sma_MST_IndvContacts] I
		ON I.cinsLastName = INS.insured
			AND I.cinsGrade = INS.insured
			AND I.saga = '-1'
	LEFT JOIN [sma_MST_AllContactInfo] INFO
		ON INFO.ContactId = I.cinnContactID
			AND INFO.ContactCtg = I.cinnContactCtg
GO

DBCC DBREINDEX ('Insurance_Contacts_Helper', ' ', 90) WITH NO_INFOMSGS
GO

---(0)--- (prepare for multiple party)
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'multi_party_helper_temp'
	)
BEGIN
	DROP TABLE [multi_party_helper_temp]
END
GO

SELECT
	INS.id AS ins_id
   ,T.plnnPlaintiffID INTO [multi_party_helper_temp]
FROM [BrianWhiteNeos]..[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), INS.casesid)
JOIN [sma_TRN_Plaintiff] T
	ON t.saga_party = CONVERT(VARCHAR(50), ins.partyid)
GO



UPDATE [Insurance_Contacts_Helper]
SET pord = 'P'
   ,PlaintiffDefendantID = A.plnnPlaintiffID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO

IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE Name = 'multi_party_helper_temp'
	)
BEGIN
	DROP TABLE [multi_party_helper_temp]
END
GO

SELECT
	INS.id AS ins_id
   ,D.defnDefendentID INTO [multi_party_helper_temp]
FROM [BrianWhiteNeos].[dbo].[insurance_Indexed] INS
JOIN [sma_TRN_cases] CAS
	ON CAS.Neos_saga = CONVERT(VARCHAR(50), INS.casesid)
JOIN [sma_TRN_Defendants] D
	ON d.saga_party = CONVERT(VARCHAR(50), ins.partyid)
GO

UPDATE [Insurance_Contacts_Helper]
SET pord = 'D'
   ,PlaintiffDefendantID = A.defnDefendentID
FROM [multi_party_helper_temp] A
WHERE A.ins_id = insurance_id
GO
-------------------------------------------------------------------------------
-------------------------END INSURANCE CONTACTS HELPER-------------------------
-------------------------------------------------------------------------------

---------------------------------
--INSURANCE TYPES
---------------------------------
INSERT INTO [sma_MST_InsuranceType]
	(
	intsDscrptn
	)
	SELECT
		'Unspecified'
	UNION
	SELECT DISTINCT
		[type]
	FROM [BrianWhiteNeos]..[insurance] INS
	JOIN [BrianWhiteNeos]..[insurance_type] it
		ON it.id = ins.insurancetypeid
	EXCEPT
	SELECT
		intsDscrptn
	FROM [sma_MST_InsuranceType]
GO

---
ALTER TABLE [sma_TRN_InsuranceCoverage] DISABLE TRIGGER ALL
GO

--sp_help [sma_TRN_InsuranceCoverage]
-------------------------------------
--PLAINTIFF INSURANCE
-------------------------------------
INSERT INTO [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID], [incnInsContactID], [incnInsAddressID], [incbCarrierHasLienYN], [incnInsType], [incnAdjContactId], [incnAdjAddressID], [incsPolicyNo], [incsClaimNo], [incnStackedTimes], [incsComments], [incnInsured], [incnCovgAmt], [incnDeductible], [incnUnInsPolicyLimit], [incnUnderPolicyLimit], [incbPolicyTerm], [incbTotCovg], [incsPlaintiffOrDef], [incnPlaintiffIDOrDefendantID], [incnTPAdminOrgID], [incnTPAdminAddID], [incnTPAdjContactID], [incnTPAdjAddID], [incsTPAClaimNo], [incnRecUserID], [incdDtCreated], [incnModifyUserID], [incdDtModified], [incnLevelNo], [incnUnInsPolicyLimitAcc], [incnUnderPolicyLimitAcc], [incb100Per], [incnMVLeased], [incnPriority], [incbDelete], [incnauthtodefcoun], [incnauthtodefcounDt], [incbPrimary], [saga]
	)
	SELECT
		MAP.caseID				 AS [incnCaseID]
	   ,MAP.incnInsContactID	 AS [incnInsContactID]
	   ,MAP.incnInsAddressID	 AS [incnInsAddressID]
	   ,NULL					 AS [incbCarrierHasLienYN]
	   ,(
			SELECT
				intnInsuranceTypeID
			FROM [sma_MST_InsuranceType]
			WHERE intsDscrptn = CASE
					WHEN ISNULL(It.[type], '') <> ''
						THEN it.[type]
					ELSE 'Unspecified'
				END
		)						 
		AS [incnInsType]
	   ,MAP.incnAdjContactId	 AS [incnAdjContactId]
	   ,MAP.incnAdjAddressID	 AS [incnAdjAddressID]
	   ,LEFT(INS.[policy], 35)	 AS [incsPolicyNo]
	   ,LEFT(INS.claim, 45)		 AS [incsClaimNo]

	   ,NULL					 AS [incnStackedTimes]
	   ,ISNULL('Comment: ' + NULLIF(CONVERT(VARCHAR, ud.ins_comment), '') + CHAR(13), '') +
		ISNULL('Insurance Information: ' + NULLIF(CONVERT(VARCHAR, ni.[Insurance Information]), '') + CHAR(13), '') +
		ISNULL('MedPay Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[MedPay Coverage]), '') + CHAR(13), '') +
		ISNULL('PIP Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Coverage]), '') + CHAR(13), '') +
		ISNULL('PIP Exhausted: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Exhausted]), '') + CHAR(13), '') +
		ISNULL('PIP Waiver: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Waiver]), '') + CHAR(13), '') +
		ISNULL('UM/UIM Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[UM/UIM Coverage]), '') + CHAR(13), '') +
		ISNULL('Other Household Vehicles: ' + NULLIF(CONVERT(VARCHAR, ni.[Other Household Vehicles]), '') + CHAR(13), '') +
		''						 AS [incsComments]
	   ,MAP.incnInsured			 AS [incnInsured]
	   ,INS.actual				 AS [incnCovgAmt]
	   ,NULL					 AS [incnDeductible]
	   ,ins.maximum_amount		 AS [incnUnInsPolicyLimit]
	   ,ins.minimum_amount		 AS [incnUnderPolicyLimit]
	   ,0						 AS [incbPolicyTerm]
	   ,0						 AS [incbTotCovg]
	   ,'P'						 AS [incsPlaintiffOrDef]
	   ,
		--    ( select plnnPlaintiffID from sma_TRN_Plaintiff where plnnCaseID=MAP.caseID and plnbIsPrimary=1 )  
		MAP.PlaintiffDefendantID AS [incnPlaintiffIDOrDefendantID]
	   ,NULL					 AS [incnTPAdminOrgID]
	   ,NULL					 AS [incnTPAdminAddID]
	   ,NULL					 AS [incnTPAdjContactID]
	   ,NULL					 AS [incnTPAdjAddID]
	   ,NULL					 AS [incsTPAClaimNo]
	   ,368						 AS [incnRecUserID]
	   ,GETDATE()				 AS [incdDtCreated]
	   ,NULL					 AS [incnModifyUserID]
	   ,NULL					 AS [incdDtModified]
	   ,NULL					 AS [incnLevelNo]
	   ,NULL					 AS [incnUnInsPolicyLimitAcc]
	   ,NULL					 AS [incnUnderPolicyLimitAcc]
	   ,0						 AS [incb100Per]
	   ,NULL					 AS [incnMVLeased]
	   ,NULL					 AS [incnPriority]
	   ,0						 AS [incbDelete]
	   ,0						 AS [incnauthtodefcoun]
	   ,NULL					 AS [incnauthtodefcounDt]
	   ,0						 AS [incbPrimary]
	   ,INS.id					 AS [saga]
	--SELECT max(len([claim]))
	FROM [BrianWhiteNeos].[dbo].[insurance_Indexed] INS
	LEFT JOIN [BrianWhiteNeos].[dbo].[insurance_type] it
		ON it.id = ins.insurancetypeid
	LEFT JOIN Insurance_Comment_Helper UD
		ON CONVERT(VARCHAR(50), INS.id) = CONVERT(VARCHAR(50), UD.insuranceid)
	JOIN [Insurance_Contacts_Helper] MAP
		ON INS.id = MAP.insurance_id
			AND MAP.pord = 'P'
	LEFT JOIN BrianWhiteNeos..NeosUserInsurance ni
		ON ni.insuranceid = ins.id
GO



-------------------------------------
--DEFENDANT INSURANCE
-------------------------------------
INSERT INTO [sma_TRN_InsuranceCoverage]
	(
	[incnCaseID], [incnInsContactID], [incnInsAddressID], [incbCarrierHasLienYN], [incnInsType], [incnAdjContactId], [incnAdjAddressID], [incsPolicyNo], [incsClaimNo], [incnStackedTimes], [incsComments], [incnInsured], [incnCovgAmt], [incnDeductible], [incnUnInsPolicyLimit], [incnUnderPolicyLimit], [incbPolicyTerm], [incbTotCovg], [incsPlaintiffOrDef], [incnPlaintiffIDOrDefendantID], [incnTPAdminOrgID], [incnTPAdminAddID], [incnTPAdjContactID], [incnTPAdjAddID], [incsTPAClaimNo], [incnRecUserID], [incdDtCreated], [incnModifyUserID], [incdDtModified], [incnLevelNo], [incnUnInsPolicyLimitAcc], [incnUnderPolicyLimitAcc], [incb100Per], [incnMVLeased], [incnPriority], [incbDelete], [incnauthtodefcoun], [incnauthtodefcounDt], [incbPrimary], [saga]
	)
	SELECT DISTINCT
		MAP.caseID				 AS [incnCaseID]
	   ,MAP.incnInsContactID	 AS [incnInsContactID]
	   ,MAP.incnInsAddressID	 AS [incnInsAddressID]
	   ,NULL					 AS [incbCarrierHasLienYN]
	   ,(
			SELECT
				intnInsuranceTypeID
			FROM [sma_MST_InsuranceType]
			WHERE intsDscrptn = CASE
					WHEN ISNULL(It.[type], '') <> ''
						THEN it.[type]
					ELSE 'Unspecified'
				END
		)						 
		AS [incnInsType]
	   ,MAP.incnAdjContactId	 AS [incnAdjContactId]
	   ,MAP.incnAdjAddressID	 AS [incnAdjAddressID]
	   ,left(INS.[policy],35)			 AS [incsPolicyNo]
	   ,left(INS.claim,45)				 AS [incsClaimNo]
	   ,NULL					 AS [incnStackedTimes]
	   ,ISNULL('Comment: ' + NULLIF(CONVERT(VARCHAR, ud.ins_comment), '') + CHAR(13), '') +
		ISNULL('Insurance Information: ' + NULLIF(CONVERT(VARCHAR, ni.[Insurance Information]), '') + CHAR(13), '') +
		ISNULL('MedPay Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[MedPay Coverage]), '') + CHAR(13), '') +
		ISNULL('PIP Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Coverage]), '') + CHAR(13), '') +
		ISNULL('PIP Exhausted: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Exhausted]), '') + CHAR(13), '') +
		ISNULL('PIP Waiver: ' + NULLIF(CONVERT(VARCHAR, ni.[PIP Waiver]), '') + CHAR(13), '') +
		ISNULL('UM/UIM Coverage: ' + NULLIF(CONVERT(VARCHAR, ni.[UM/UIM Coverage]), '') + CHAR(13), '') +
		ISNULL('Other Household Vehicles: ' + NULLIF(CONVERT(VARCHAR, ni.[Other Household Vehicles]), '') + CHAR(13), '') +
		''						 AS [incsComments]
	   ,MAP.incnInsured			 AS [incnInsured]
	   ,INS.actual				 AS [incnCovgAmt]
	   ,NULL					 AS [incnDeductible]
	   ,ins.maximum_amount		 AS [incnUnInsPolicyLimit]
	   ,ins.minimum_amount		 AS [incnUnderPolicyLimit]
	   ,0						 AS [incbPolicyTerm]
	   ,0						 AS [incbTotCovg]
	   ,'D'						 AS [incsPlaintiffOrDef]
	   ,MAP.PlaintiffDefendantID AS [incnPlaintiffIDOrDefendantID]
	   ,NULL					 AS [incnTPAdminOrgID]
	   ,NULL					 AS [incnTPAdminAddID]
	   ,NULL					 AS [incnTPAdjContactID]
	   ,NULL					 AS [incnTPAdjAddID]
	   ,NULL					 AS [incsTPAClaimNo]
	   ,368						 AS [incnRecUserID]
	   ,GETDATE()				 AS [incdDtCreated]
	   ,NULL					 AS [incnModifyUserID]
	   ,NULL					 AS [incdDtModified]
	   ,NULL					 AS [incnLevelNo]
	   ,NULL					 AS [incnUnInsPolicyLimitAcc]
	   ,NULL					 AS [incnUnderPolicyLimitAcc]
	   ,0						 AS [incb100Per]
	   ,NULL					 AS [incnMVLeased]
	   ,NULL					 AS [incnPriority]
	   ,0						 AS [incbDelete]
	   ,0						 AS [incnauthtodefcoun]
	   ,NULL					 AS [incnauthtodefcounDt]
	   ,0						 AS [incbPrimary]
	   ,INS.id					 AS [saga]
	FROM [BrianWhiteNeos].[dbo].[insurance_Indexed] INS
	LEFT JOIN [BrianWhiteNeos].[dbo].[insurance_type] it
		ON it.id = ins.insurancetypeid
	LEFT JOIN Insurance_Comment_Helper UD
		ON CONVERT(VARCHAR(50), INS.id) = CONVERT(VARCHAR(50), UD.insuranceid)
	JOIN [Insurance_Contacts_Helper] MAP
		ON INS.ID = MAP.insurance_id
			AND MAP.pord = 'D'
	LEFT JOIN BrianWhiteNeos..NeosUserInsurance ni
		ON ni.insuranceid = ins.id
GO
---
ALTER TABLE [sma_TRN_InsuranceCoverage] ENABLE TRIGGER ALL
GO
---


---(Adjuster/Insurer association)---
INSERT INTO [sma_MST_RelContacts]
	(
	[rlcnPrimaryCtgID], [rlcnPrimaryContactID], [rlcnPrimaryAddressID], [rlcnRelCtgID], [rlcnRelContactID], [rlcnRelAddressID], [rlcnRelTypeID], [rlcnRecUserID], [rlcdDtCreated], [rlcnModifyUserID], [rlcdDtModified], [rlcnLevelNo], [rlcsBizFam], [rlcnOrgTypeID]
	)
	SELECT DISTINCT
		1					  AS [rlcnPrimaryCtgID]
	   ,IC.[incnAdjContactId] AS [rlcnPrimaryContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnPrimaryAddressID]
	   ,2					  AS [rlcnRelCtgID]
	   ,IC.[incnInsContactID] AS [rlcnRelContactID]
	   ,IC.[incnAdjAddressID] AS [rlcnRelAddressID]
	   ,2					  AS [rlcnRelTypeID]
	   ,368					  AS [rlcnRecUserID]
	   ,GETDATE()			  AS [rlcdDtCreated]
	   ,NULL				  AS [rlcnModifyUserID]
	   ,NULL				  AS [rlcdDtModified]
	   ,NULL				  AS [rlcnLevelNo]
	   ,'Business'			  AS [rlcsBizFam]
	   ,NULL				  AS [rlcnOrgTypeID]
	FROM [sma_TRN_InsuranceCoverage] IC
	WHERE ISNULL(IC.[incnAdjContactId], 0) <> 0
		AND ISNULL(IC.[incnInsContactID], 0) <> 0


------------------------------
--INSURANCE ADJUSTERS
------------------------------
INSERT INTO [sma_TRN_InsuranceCoverageAdjusters]
	(
	InsuranceCoverageId, AdjusterContactUID
	)
	SELECT
		incnInsCovgID
	   ,ioc2.UNQCID
	FROM sma_TRN_InsuranceCoverage ic
	JOIN [BrianWhiteNeos]..[insurance_Indexed] INS
		ON CONVERT(VARCHAR(50), INS.ID) = IC.SAGA
	JOIN IndvOrgContacts_Indexed IOC2
		ON IOC2.saga_ref = CONVERT(VARCHAR(50), ins.adjuster_namesid)
	UNION
	--UM/UIM ADJUSTER
	SELECT
		incnInsCovgID
	   ,ioc2.UNQCID
	FROM sma_TRN_InsuranceCoverage ic
	JOIN [BrianWhiteNeos]..[NeosUserInsurance] INS
		ON CONVERT(VARCHAR(50), INS.insuranceid) = IC.SAGA
	JOIN IndvOrgContacts_Indexed IOC2
		ON IOC2.saga_ref = CONVERT(VARCHAR(50), ins.[UM/UIM Adjuster])
	WHERE ISNULL([UM/UIM Adjuster], '') <> ''
GO
