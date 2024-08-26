
USE BrianWhiteSANeos
GO

------
ALTER TABLE sma_MST_OrgContacts DISABLE TRIGGER ALL
GO
ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO
-----

----(0)----

UPDATE [sma_MST_IndvContacts]
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Adjuster'
		AND octnContactCtgID = 1
)
WHERE cinnContactID IN (
	SELECT DISTINCT
		incnAdjContactId
	FROM [sma_TRN_InsuranceCoverage] INS
	WHERE incnAdjContactId IS NOT NULL
)

GO

UPDATE [sma_MST_OrgContacts]
SET connContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Insurance Company'
		AND octnContactCtgID = 2
)
WHERE connContactID IN (
	SELECT DISTINCT
		incnInsContactID
	FROM [sma_TRN_InsuranceCoverage] INS
	WHERE incnInsContactID IS NOT NULL
)
GO


----(1)----

UPDATE [sma_MST_IndvContacts]
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Doctor'
		AND octnContactCtgID = 1
)
WHERE cinnContactID IN (
	SELECT DISTINCT
		hosnContactID
	FROM [sma_TRN_Hospitals] HOS
	WHERE hosnContactID IS NOT NULL
		AND hosnContactCtg = 1
)
GO

UPDATE [sma_MST_OrgContacts]
SET connContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Medical Office'
		AND octnContactCtgID = 2
)
WHERE connContactID IN (
	SELECT DISTINCT
		hosnContactID
	FROM [sma_TRN_Hospitals] HOS
	WHERE hosnContactID IS NOT NULL
		AND hosnContactCtg = 2
)
GO



----(2)----

UPDATE [sma_MST_IndvContacts]
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
WHERE cinnContactID IN (
	SELECT DISTINCT
		planAtorneyContactID
	FROM [sma_TRN_PlaintiffAttorney]
	WHERE planAtorneyContactID IS NOT NULL
)

UPDATE [sma_MST_OrgContacts]
SET connContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Law Firm'
		AND octnContactCtgID = 2
)
WHERE connContactID IN (
	SELECT DISTINCT
		planLawfrmContactID
	FROM [sma_TRN_PlaintiffAttorney]
	WHERE planLawfrmContactID IS NOT NULL
)


----(3)----

UPDATE [sma_MST_IndvContacts]
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Attorney'
		AND octnContactCtgID = 1
)
WHERE cinnContactID IN (
	SELECT DISTINCT
		lwfnAttorneyContactID
	FROM [sma_TRN_LawFirms]
	WHERE lwfnAttorneyContactID IS NOT NULL
)

UPDATE [sma_MST_OrgContacts]
SET connContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Law Firm'
		AND octnContactCtgID = 2
)
WHERE connContactID IN (
	SELECT DISTINCT
		lwfnLawFirmContactID
	FROM [sma_TRN_LawFirms]
	WHERE lwfnLawFirmContactID IS NOT NULL
)


----(4)----
UPDATE [sma_MST_IndvContacts]
SET cinnContactTypeID = (
	SELECT
		octnOrigContactTypeID
	FROM [sma_MST_OriginalContactTypes]
	WHERE octsDscrptn = 'Judge'
)
FROM (
	SELECT DISTINCT
		judge_namesid
	FROM [BrianWhiteNeos].[dbo].[cases_Indexed]
) A
WHERE CONVERT(VARCHAR(50), A.judge_namesid) = saga_ref
AND ISNULL(CONVERT(VARCHAR(50), A.judge_namesid), '') <> ''



------
ALTER TABLE sma_MST_OrgContacts ENABLE TRIGGER ALL
GO
ALTER TABLE sma_MST_IndvContacts ENABLE TRIGGER ALL
GO
-----
