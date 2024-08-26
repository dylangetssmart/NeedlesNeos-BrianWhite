USE SANeosBrianWhite
GO

/*
SELECT pty.casesid as CasesID, td.partyid, pty.namesid as PartyNamesID, case when convert(varchar(50),td.[namesid]) IS NULL then td.[data] else convert(varchar(50),td.[namesid]) end as [data], ucf.field_title, prl.role, rol.[SA Party]
	from [NeosBrianWhite]..user_Party_data td
	JOIN [NeosBrianWhite]..Party_Indexed pty on pty.id = td.partyid
	JOIN [NeosBrianWhite]..party_role_list prl on prl.id = pty.partyrolelistid
	JOIN PartyRoles rol on rol.[Needles Roles] = prl.[role]
	JOIN [NeosBrianWhite]..user_case_fields ucf on ucf.id = td.usercasefieldid
	WHERE field_Title in ('Accidents/Injuries', 'Agent for Service', 'Been Convicted of a Crime', 'Business Type', 'Client Insured?', 'Contact', 'Contact Address', 'Contact Phone', 'Currently Treating?', 
					'Days Absent', 'Defendant Insured?', 'Details', 'Drivers License No.', 'Drivers License State', 'Education', 'Employer Name', 'Health Insurance?', 'Job Duties', 'Language', 'Marital Status', 
					'Minor Children', 'Missed Time from Work', 'Name of Court', 'Name of Employer', 'Name of Spouse', 'Occupation', 'Other Employment', 'Parent/Guardian', 'Pending Bankruptcy?', 'Previous Complaints', 
					'Prior Accidents/Injuries', 'Priors/Subsequents', 'Rate of Pay', 'Relationship', 'Role in Accident', 'Scope of Employment', 'Type of Crime', 'Type of Health Insurance', 'Workers'' Comp Claim?' )
ORDER BY rol.[SA Party]
*/

-------------------------------------------------------------------------
--PLAINTIFF AND DEFENDANT UDFS
-------------------------------------------------------------------------
-----------------------------------------
--UDF DEFINITION
-----------------------------------------
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
	SELECT DISTINCT
		'C'											 AS [udfsUDFCtg]
	   ,cas.casnOrgCaseTypeID						 AS [udfnRelatedPK]
	   ,nuf.field_title								 AS [udfsUDFName]
	   ,rol.[SA Party]								 AS [udfsScreenName]
	   ,nuf.UDFType									 AS [udfsType]
	   ,nuf.field_len								 AS [udfsLength]
	   ,1											 AS [udfbIsActive]
	   ,NULL										 AS [udfnLevelNo]
	   ,'user_party_Data' + ucf.[field_title]		 AS [udfshortName]
	   ,nuf.dropdownValues							 AS [udfsNewValues]
	   ,DENSE_RANK() OVER (ORDER BY nuf.field_title) AS [udfnSortOrder]
	--SELECT DISTINCT nuf.*
	FROM [NeosBrianWhite]..user_Party_data td
	JOIN [NeosBrianWhite]..Party_Indexed pty
		ON pty.id = td.partyid
	JOIN [NeosBrianWhite]..party_role_list prl
		ON prl.id = pty.partyrolelistid
	JOIN PartyRoles rol
		ON rol.[Needles Roles] = prl.[role]
	JOIN [NeosBrianWhite]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	JOIN NeedlesUserFields nuf
		ON nuf.field_id = ucf.id
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = CONVERT(VARCHAR(50), pty.casesid)
	LEFT JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = nuf.field_title
			AND def.[udfsScreenName] = rol.[SA Party]
GO

---------------------------------
--UDF VALUES
---------------------------------
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
	SELECT DISTINCT
		def.udfnUDFID								   AS [udvnUDFID]
	   ,rol.[SA Party]								   AS [udvsScreenName]
	   ,'C'											   AS [udvsUDFCtg]
	   ,CAS.casnCaseID								   AS [udvnRelatedID]
	   ,ISNULL(Pl.plnnPlaintiffID, df.defnDefendentID) AS [udvnSubRelatedID]
	   ,CASE
			WHEN ucf.field_Type = '14'
				THEN (
						SELECT TOP 1
							CONVERT(VARCHAR, UNQCID)
						FROM indvorgcontacts_Indexed
						WHERE saga_ref = CONVERT(VARCHAR(50), td.[namesid])
					)
			ELSE td.[data]
		END											   AS [udvsUDFValue]
	   ,368											   AS [udvnRecUserID]
	   ,GETDATE()									   AS [udvdDtCreated]
	   ,NULL										   AS [udvnModifyUserID]
	   ,NULL										   AS [udvdDtModified]
	   ,NULL										   AS [udvnLevelNo]
	FROM [NeosBrianWhite]..user_Party_data td
	JOIN [NeosBrianWhite]..Party_Indexed pty
		ON pty.id = td.partyid
	JOIN [NeosBrianWhite]..party_role_list prl
		ON prl.id = CONVERT(VARCHAR(50), pty.partyrolelistid)
	JOIN PartyRoles rol
		ON rol.[Needles Roles] = prl.[role]
	JOIN [NeosBrianWhite]..user_case_fields ucf
		ON ucf.id = CONVERT(VARCHAR(50), td.usercasefieldid)
	--JOIN NeedlesUserFields nuf on nuf.field_id = ucf.id
	JOIN sma_trn_Cases cas
		ON cas.Neos_Saga = CONVERT(VARCHAR(50), pty.casesid)
	LEFT JOIN [sma_MST_UDFDefinition] def
		ON def.[udfnRelatedPK] = cas.casnOrgCaseTypeID
			AND def.[udfsUDFName] = ucf.field_title
			AND def.[udfsScreenName] = rol.[SA Party]
	LEFT JOIN sma_trn_Plaintiff Pl
		ON pl.saga_party = CONVERT(VARCHAR(50), pty.id)
	LEFT JOIN sma_trn_Defendants DF
		ON DF.saga_party = CONVERT(VARCHAR(50), pty.id)
GO