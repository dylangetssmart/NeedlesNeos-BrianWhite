
USE [BrianWhiteSANeos]
GO

---
ALTER TABLE sma_MST_IndvContacts DISABLE TRIGGER ALL
GO
---

----(1)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age : ' + CONVERT(VARCHAR, A.Age)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,DATEPART(yyyy, GETDATE()) - DATEPART(yyyy, N.date_of_birth) - 1 AS Age

	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE N.date_of_birth IS NOT NULL
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref


----(2)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Age at DOI : ' + CONVERT(VARCHAR, A.DOI)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,DATEPART(yyyy, C.date_of_incident) - DATEPART(yyyy, N.date_of_birth) - 1 AS DOI
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	JOIN [BrianWhiteNeos].[dbo].[cases] C
		ON C.id = P.casesid
	WHERE C.date_of_incident IS NOT NULL
		AND N.date_of_birth IS NOT NULL
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref


----(3)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Deceased : ' + CONVERT(VARCHAR, A.Deceased)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,N.Deceased AS Deceased
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE N.Deceased IS NOT NULL
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref


----(4)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Date of Death : ' + CONVERT(VARCHAR, A.DOD)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,DATEPART(yyyy, N.date_of_death) AS DOD
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE N.date_of_death IS NOT NULL
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref



----(5)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacitated : ' + CONVERT(VARCHAR, A.incapacitated)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,P.incapacitated AS incapacitated
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE ISNULL(incapacitated, '') <> ''
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref


----(5)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Incapacity : ' + CONVERT(VARCHAR, A.Incapacity)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,P.incapacity AS Incapacity
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE ISNULL(incapacity, '') <> ''
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref



----(6)----
UPDATE sma_MST_IndvContacts
SET cinsComments = ISNULL(cinsComments, '') + CHAR(13) + 'Responsible for another party : ' + CONVERT(VARCHAR, A.Responsibility)
FROM (
	SELECT
		P.casesid AS CaseID
	   ,P.namesid AS PartyID
	   ,P.responsibility AS Responsibility
	FROM [BrianWhiteNeos].[dbo].[party_Indexed] P
	JOIN [BrianWhiteNeos].[dbo].[names] N
		ON N.id = P.namesid
	WHERE ISNULL(P.responsibility, '') <> ''
) A
WHERE CONVERT(VARCHAR(50), A.PartyID) = saga_ref


---
ALTER TABLE sma_MST_IndvContacts ENABLE TRIGGER ALL
GO
---
