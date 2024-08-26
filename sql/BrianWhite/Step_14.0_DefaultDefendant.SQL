
USE [BrianWhiteSA]
GO


---(1)---
DELETE FROM sma_MST_CaseTypeDefualtDefs

---(2)---
INSERT INTO sma_MST_CaseTypeDefualtDefs
	SELECT DISTINCT
		CST.cstnCaseTypeID AS cddnCaseTypeID
	   ,I.cinnContactID	   AS cddnDefContatID
	   ,I.cinnContactCtg   AS cddnDefContactCtgID
	   ,sbrnSubRoleId	   AS cddnRoleID
	   ,A.addnAddressID	   AS cddnDefAddressID
	FROM sma_mst_casetype CST
	JOIN sma_mst_SubRole S
		ON sbrnCaseTypeID = CST.cstnCaseTypeID
	JOIN sma_mst_SubRoleCode STC
		ON S.sbrnTypeCode = STC.srcnCodeId
			AND STC.srcsDscrptn = '(D)-Defendant'
	CROSS JOIN sma_MST_IndvContacts I
	JOIN sma_MST_Address A
		ON A.addnContactID = I.cinnContactID
			AND A.addnContactCtgID = I.cinnContactCtg
			AND A.addbPrimary = 1
	WHERE CST.VenderCaseType = 'BrianWhiteCaseType'
		AND I.cinsFirstName = 'Individual'
		AND I.cinsLastName = 'Unidentified'




