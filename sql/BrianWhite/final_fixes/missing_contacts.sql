/*
Author:		Dylan Smith | dylans@smartadvocate.com
Date:		2024-11-27

- During the final conversion, users and their associated contact records were not created for contacts that did not exist
in the implementation system.
- This script creates the contacts that were missed, and then the associated user records.
- Both contacts and users are marked as inactive.

*/

use BrianWhiteSA
go

-----------------------------------------------------------------------------------------------------------
-- 1. contacts_to_exclude
	-- A list of contacts that we do not want to create. These contacts were created manually in the implementation system and
	-- as such do not have a saga to key off of. They should not be created in the next step.
	-- id = neos..staff.id

--SELECT * 
--FROM brianwhiteneos..staff
--WHERE full_name IN (
--    'Ajejandro Reyes',
--    'Ariel Somarribas',
--    'Brian E. White',
--    'Brigitte Rosado Rivera',
--    'Diana Maldonado Molina',
--    'Flavia Medeiros Da Cunha',
--	  'Jessica Zamudio',
--    'John M. Kuker',
--    'Lex M. Allgaier',
--	  'Matthew Clemen',
--    'Marlon Moncrieffe',
--    'Noelia Vargas',
--    'neos-sup',
--    'neos-sys',
--	  'Willie Rodriguez'
--)
--order by full_name

IF OBJECT_ID('contacts_to_exclude', 'U') IS NOT NULL
	DROP TABLE contacts_to_exclude;
GO

CREATE TABLE contacts_to_exclude (id UNIQUEIDENTIFIER);
GO

INSERT INTO contacts_to_exclude (id)
VALUES 
('2C853DD9-FE02-4D39-80D7-B1720154EB69'), -- Ajejandro Reyes
('DFC9E3F2-1D0D-427C-91C5-B1E200EE0C1E'), -- Ariel Somarribas
('6EF24FF1-3480-4FDD-B941-ACD80122842A'), -- Brian E. White
('FBC4634C-01D0-4C45-85E2-B02F0104C2D9'), -- Brigitte Rosado Rivera
('A580FC79-9AC6-4636-A988-B1F100FD7368'), -- Diana Maldonado Molina
('EB06256E-2D32-43AB-9B6E-AFD90139E279'), -- Flavia Medeiros Da Cunha
('9E74B3DA-16E7-4F0C-9CFB-B12B00F67846'), -- Jessica Zamudio
('98A6D36A-9FF1-4990-AADA-B12401672379'), -- John M. Kuker
('793F065F-AAB8-45A9-A68C-AE2500D2A20B'), -- Lex M. Allgaier
('F07D6787-4757-49D3-9FEA-B1E1011FBEE5'), -- Matthew Clemen
('EA460689-9818-4D67-98D6-B1FB014857E0'), -- Willie Rodriguez
('439EBE8A-0691-435D-AA12-B1E100F5BD2E'), -- Noelia Vargas
('EFFA63DF-F1C1-EA11-B9E0-54BF64903F76'), -- neos-sup, neos-sys
('7486163E-F3D9-4CD8-B183-B1E200EEC432')  -- Marlon Moncrieffe
GO
--SELECT * FROM contacts_to_exclude cte


-- 1.2 Pre-validation
-- Save to excel - users to create
--SELECT
--	*
--FROM BrianWhiteNeos..staff s
--LEFT JOIN sma_MST_Users u
--	ON u.saga = s.id
--WHERE u.saga IS NULL
--	AND s.id NOT IN (
--		SELECT
--			id
--		FROM contacts_to_exclude
--	)
--ORDER BY s.staff_code

-- Save to excel - all contacts before insert
SELECT * FROM sma_MST_IndvContacts smic

-- Save to excel - all users before insert
SELECT * FROM sma_MST_Users smu

-----------------------------------------------------------------------------------------------------------
-- 2. Insert individual contact records
	-- https://github.com/dylangetssmart/NeedlesNeos-BrianWhite/issues/12
	-- Create contacts that do not exist (see JOINS + WHERE)
	-- [cinbStatus] = 0
	-- [saga] = 47
		-- This is an arbitrary number used to find these contact records later when creating users.

--ALTER TABLE [sma_MST_IndvContacts] DISABLE TRIGGER ALL
--GO

INSERT INTO [sma_MST_IndvContacts]
	(
	[cinsPrefix], [cinsSuffix], [cinsFirstName], [cinsLastName], [cinsHomePhone], [cinsWorkPhone], [cinsSSNNo], [cindBirthDate], [cindDateOfDeath], [cinnGender], [cinsMobile], [cinsComments], [cinnContactCtg], [cinnContactTypeID], [cinnRecUserID], [cindDtCreated], [cinbStatus], [cinbPreventMailing], [cinsNickName], [cinsOccupation], [saga], [cinsGrade],				-- remember the [staff_code]
	[saga_ref]
	)
	SELECT
		pre.[name]							AS [cinsPrefix]
	   ,suf.[name]							AS [cinsSuffix]
	   ,CASE
			WHEN stf.first_name = ''
				THEN LEFT(dbo.get_firstword(stf.full_name), 30)
			ELSE stf.first_name
		END									AS [cinsFirstName]
	   ,CASE
			WHEN stf.last_name = ''
				THEN LEFT(dbo.get_lastword(stf.full_name), 40)
			ELSE stf.last_name
		END									AS [cinsLastName]
	   ,NULL								AS [cinsHomePhone]
	   ,LEFT(phone_number, 20)				AS [cinsWorkPhone]
	   ,NULL								AS [cinsSSNNo]
	   ,NULL								AS [cindBirthDate]
	   ,NULL								AS [cindDateOfDeath]
	   ,CASE stf.gender
			WHEN 1
				THEN 1
			WHEN 2
				THEN 2
			ELSE 0
		END									AS [cinnGender]
	   ,LEFT(stf.mobile_number, 20)			AS [cinsMobile]
	   ,ISNULL('Supervisor: ' + NULLIF(CONVERT(VARCHAR, stf.supervisor), '') + CHAR(13), '') +
		ISNULL('Bar1: ' + NULLIF(CONVERT(VARCHAR, stf.bar1), '') + CHAR(13), '') +
		ISNULL('Bar1 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state1), '') + CHAR(13), '') +
		ISNULL('Bar2: ' + NULLIF(CONVERT(VARCHAR, stf.bar2), '') + CHAR(13), '') +
		ISNULL('Bar2 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state2), '') + CHAR(13), '') +
		ISNULL('Bar3: ' + NULLIF(CONVERT(VARCHAR, stf.bar3), '') + CHAR(13), '') +
		ISNULL('Bar3 State: ' + NULLIF(CONVERT(VARCHAR, stf.bar_state3), '') + CHAR(13), '') +
		'Works on Cases: ' +
		CASE
			WHEN stf.works_on_cases = 1
				THEN 'Yes'
			ELSE 'No'
		END + CHAR(13) +
		''									AS [cinsComments]
	   ,1									AS [cinnContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM sma_MST_OriginalContactTypes
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)									
		AS [cinnContactTypeID]
	   ,368
	   ,stf.Date_Created
	   ,0									AS [cinbStatus]
	   ,0									AS [cinbPreventMailing]
	   ,CONVERT(VARCHAR(15), stf.full_name) AS [cinsNickName]
	   ,stf.job_title						AS [cinsOccupation]
	   ,47									AS [saga]
	   ,stf.staff_code						AS [cinsGrade]
	   ,stf.id								AS [saga_ref]
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[staff] stf
	LEFT JOIN [BrianWhiteNeos]..[prefix] pre
		ON stf.prefixid = pre.id
	LEFT JOIN [BrianWhiteNeos]..[suffix] suf
		ON suf.id = stf.suffixid
	LEFT JOIN [implementation_users] iu
		ON iu.StaffCode = stf.staff_code
	LEFT JOIN [sma_MST_IndvContacts] smic
		ON smic.cinnContactID = iu.SAContactID
	WHERE iu.SAContactID IS NULL
		AND stf.id NOT IN (
			SELECT
				id
			FROM contacts_to_exclude
		)
GO

--ALTER TABLE [sma_MST_IndvContacts] ENABLE TRIGGER ALL
--GO

-----------------------------------------------------------------------------------------------------------
-- 3. Insert user records
	-- Create users for the contacts created above
	-- [usrbActiveState] = 0

--SELECT
--	*
--FROM sma_MST_IndvContacts smic
--ORDER BY smic.cinsFirstName --WHERE smic.saga = 47

--ALTER TABLE sma_MST_Users DISABLE TRIGGER ALL
--GO

INSERT INTO [sma_MST_Users]
	(
	[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState], [saga]
	)
	SELECT
		indv.cinnContactID				 AS [usrnContactID]
	   ,CONVERT(VARCHAR(20), staff_code) AS [usrsLoginID]
	   ,'#'								 AS [usrsPassword]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,33								 AS [usrnRoleID]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,1								 AS [usrnRecUserID]
	   ,GETDATE()						 AS [usrdDtCreated]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,0								 AS [usrbActiveState]
	   ,stf.[id]						 AS [saga]
	--,CONVERT(VARCHAR(20), STF.staff_code) as saga
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[staff] STF
	JOIN sma_MST_IndvContacts INDV
		ON INDV.cinsGrade = STF.staff_code
	LEFT JOIN [sma_MST_Users] u
		ON u.saga = STF.[id]
	WHERE u.usrsLoginID IS NULL
		AND indv.saga = 47
	ORDER BY u.usrsLoginID
GO

--ALTER TABLE sma_MST_Users ENABLE TRIGGER ALL
--GO

-----------------------------------------------------------------------------------------------------------
-- 4. Update [sma_MST_Users].[saga]
	-- https://github.com/dylangetssmart/NeedlesNeos-BrianWhite/issues/3
	-- For the users that were created manually in the implementation system, we need to fill out [saga] with [staff].[id]
	-- My initial update on this field missed these users because they have no link to the source system

UPDATE sma_mst_users
SET saga = 
    CASE usrsLoginID
        WHEN 'alejandro' THEN '2C853DD9-FE02-4D39-80D7-B1720154EB69'  -- Alejandro Reyes
        WHEN 'ariel' THEN 'DFC9E3F2-1D0D-427C-91C5-B1E200EE0C1E'      -- Ariel Somarribas
        WHEN 'brian' THEN '6EF24FF1-3480-4FDD-B941-ACD80122842A'      -- Brian E. White
        WHEN 'brigitte' THEN 'FBC4634C-01D0-4C45-85E2-B02F0104C2D9'   -- Brigitte Rosado Rivera
        WHEN 'diana' THEN 'A580FC79-9AC6-4636-A988-B1F100FD7368'      -- Diana Maldonado Molina
        WHEN 'flavia' THEN 'EB06256E-2D32-43AB-9B6E-AFD90139E279'     -- Flavia Medeiros Da Cunha
		WHEN 'jessica' THEN '9E74B3DA-16E7-4F0C-9CFB-B12B00F67846'    -- Jessica Zamudio
        WHEN 'john' THEN '98A6D36A-9FF1-4990-AADA-B12401672379'       -- John M. Kuker
        WHEN 'lex' THEN '793F065F-AAB8-45A9-A68C-AE2500D2A20B'        -- Lex M. Allgaier
        WHEN 'matthew' THEN 'F07D6787-4757-49D3-9FEA-B1E1011FBEE5'    -- Matthew Clemen
        WHEN 'marlon' THEN '7486163E-F3D9-4CD8-B183-B1E200EEC432'     -- Marlon Moncrieffe
        WHEN 'noelia' THEN '439EBE8A-0691-435D-AA12-B1E100F5BD2E'     -- Noelia Vargas
        WHEN 'will' THEN 'EA460689-9818-4D67-98D6-B1FB014857E0'       -- Willie Rodriguez
    END																					  
WHERE usrsLoginID IN (
    'alejandro',
    'ariel',
    'brian',
    'brigitte',
    'diana',
    'flavia',
	'jessica',
    'john',
    'lex',
    'matthew',
    'marlon',
    'noelia',
    'will'
);
GO

-----------------------------------------------------------------------------------------------------------
-- 5. Validation

-- Should return neos-sup or neos-sys, which share a uniqueID
SELECT *
FROM BrianWhiteNeos..staff s
LEFT JOIN sma_MST_Users u
	ON u.saga = s.id
WHERE u.saga IS NULL
ORDER BY s.staff_code

-- Should return:
	-- aadmin (SA)
	-- implementation (SA)
	-- Mara (no match to source)
	-- hakeem (no match to source)
	-- rosemary (no match to source)
	-- claude (SA)
	-- Cooper (SA)
SELECT * FROM sma_MST_Users smu WHERE smu.saga is null

---- Save to excel - contacts that were created
--SELECT *
--from sma_MST_IndvContacts ic
--WHERE ic.saga = 47

---- Save to excel - users that were created
--SELECT *
--from sma_MST_Users u
--JOIN sma_MST_IndvContacts ic
--on ic.cinnContactID = u.usrnContactID
--WHERE ic.saga = 47

-- Save to excel - all contacts after insert
SELECT * FROM sma_MST_IndvContacts smic

-- Save to excel - all users after insert
SELECT * FROM sma_MST_Users smu










---- scratch below this line ------------------------------------------------------------------------------------------------------


---- insert contacts from staff 
---- but not for contacts that exist already (staff > imp_user > contacts)
---- but not for users where saga is null (staff > imp_user > user)

--SELECT *, CASE WHEN iu.StaffCode = '' then 'y' else 'n' end FROM implementation_users iu ORDER BY iu.StaffCode


----24F2B802-C315-4676-B3B8-B0AB0101FF1D

----Brigitte Rosado Rivera
----FBC4634C-01D0-4C45-85E2-B02F0104C2D9
---- sa contactid = 32
---- sa userid = 390
--SELECT * FROM BrianWhiteNeos..staff s WHERE s.id = 'FBC4634C-01D0-4C45-85E2-B02F0104C2D9'
--SELECT * FROM sma_MST_IndvContacts smic WHERE smic.cinsFirstName = 'brigitte'
--SELECT * FROM sma_MST_Users smu WHERE smu.usrnContactID = 32 or smu.usrnContactID = 14424

--SELECT * FROM sma_MST_Users smu WHERE smu.saga is null

--SELECT * FROM BrianWhiteNeos..staff  order BY full_name WHERE first_name = 'lex'
--SELECT * FROM implementation_users iu order BY iu.SAFirst WHERE iu.SAFirst = 'lex'
--SELECT * FROM sma_MST_IndvContacts smic WHERE smic.cinnContactID = 52
--SELECT * FROM sma_MST_Users smu WHERE smu.usrnUserID = 410




---- does not exist in staff (8):
---- hakeem
---- jesica thomas
---- mara siegel
---- marlon perez (?) > Marlon Moncrieffe: 7486163E-F3D9-4CD8-B183-B1E200EEC432
---- noelia Quiros
---- rosemary Wilshusen
---- aadmin
---- implementation

-- records from staff without a match in imp_users
--SELECT s.* FROM BrianWhiteNeos..staff s
--LEFT JOIN implementation_users iu
--ON iu.StaffCode = s.staff_code
--WHERE iu.StaffCode is NULL
--AND s.id NOT IN (SELECT id FROM contacts_to_exclude)
--order BY s.full_name 













--SELECT * from implementation_users iu
--join sma_MST_IndvContacts i
--ON i.cinnContactID = iu.SAContactID
--WHERE iu.StaffCode = ''
--ORDER BY iu.SALoginID


---- records I want to exclude
--SELECT * FROM sma_MST_IndvContacts i
--JOIN implementation_users iu
--ON iu.SAContactID = i.cinnContactID
--WHERE iu.StaffCode = ''
--JOIN BrianWhiteNeos..staff s
--ON s.first_name = i.cinsFirstName






--SELECT stf.*
--FROM [BrianWhiteNeos].[dbo].[staff] stf
--LEFT JOIN [implementation_users] iu
--    ON iu.StaffCode = stf.staff_code 
--left JOIN [sma_MST_IndvContacts] smic
--    ON smic.cinnContactID = iu.SAContactID
--WHERE iu.SAContactID IS NULL 
--order BY stf.staff_code


---- STAFF
--SELECT * FROM BrianWhiteNeos..staff order by staff_code

---- IMP_USERS
--SELECT * FROM implementation_users iu   where iu.StaffCode = '' order BY iu.StaffCode

---- records from staff without a match in imp_users
--SELECT s.* FROM BrianWhiteNeos..staff s
--LEFT JOIN implementation_users iu
--ON iu.StaffCode = s.staff_code
--WHERE iu.StaffCode is null
--order BY s.staff_code



--SELECT u.usrnContactID, u.usrnContactID, u.saga, iu_filtered.*, s.*
--FROM BrianWhiteNeos..staff s
--LEFT JOIN (
--    SELECT StaffCode
--    FROM implementation_users
--    WHERE StaffCode <> '' -- Only include rows with non-blank StaffCode
--) iu_filtered
--ON iu_filtered.StaffCode = s.staff_code
--LEFT JOIN sma_MST_Users u
--ON u.saga = s.id
--WHERE iu_filtered.StaffCode IS NULL
--ORDER BY s.staff_code;

---- contact.id > imp_user > staff via first_name










---- USERS
--SELECT * FROM sma_MST_Users smu 








---- remove lex because his staff.id does not exist in users
--SELECT * FROM BrianWhiteNeos..staff s
--join sma_MST_IndvContacts i
--JOIN sma_MST_Users u













---- these are the guys I want to exclude? maybe?

--SELECT u.saga, * from BrianWhiteNeos..staff s
--LEFT join sma_MST_Users u
--ON u.saga = s.id
--WHERE u.saga is NOT null
--order BY s.staff_code

--SELECT *, CASE WHEN iu.StaffCode = '' then 'y' else 'n' end FROM implementation_users iu ORDER BY iu.StaffCode
--SELECT * FROM sma_MST_Users smu WHERE smu.saga is null


---- insert contacts from staff 
---- but not for contacts that exist already (staff > imp_user > contacts)
---- but not for users where saga is null (staff > imp_user > user)

--SELECT stf.*
--FROM [BrianWhiteNeos].[dbo].[staff] stf
--LEFT JOIN [implementation_users] iu
--    ON iu.StaffCode = stf.staff_code
--WHERE NOT EXISTS (
--    -- Exclude records already in contacts
--    SELECT 1
--    FROM sma_MST_IndvContacts smic
--    WHERE smic.cinnContactID = iu.SAContactID
--)
--AND NOT EXISTS (
--    -- Exclude records where saga in users is NULL
--    SELECT 1
--    FROM sma_MST_Users u
--    WHERE u.saga = stf.id AND u.saga IS NULL
--);



--SELECT stf.*
--FROM [BrianWhiteNeos].[dbo].[staff] stf
--LEFT JOIN [implementation_users] iu
--    ON iu.StaffCode = stf.staff_code 
--left JOIN [sma_MST_IndvContacts] smic
--    ON smic.cinnContactID = iu.SAContactID
----	AND smic.cinnContactID is null
----left join sma_MST_Users u
----on u.saga = stf.id
----	AND u.saga is null
--WHERE iu.SAContactID IS NULL 
--order BY stf.staff_code



--SELECT * FROM BrianWhiteNeos..staff s

--SELECT stf.*
--FROM [BrianWhiteNeos].[dbo].[staff] stf
--LEFT JOIN [implementation_users] iu
--    ON iu.StaffCode = stf.staff_code 
--left JOIN [sma_MST_IndvContacts] smic
--    ON smic.cinnContactID = iu.SAContactID
----	AND smic.cinnContactID is null
----left join sma_MST_Users u
----on u.saga = stf.id
----	AND u.saga is null
--WHERE iu.SAContactID IS NULL 
--order BY stf.staff_code


--SELECT u.saga, * from BrianWhiteNeos..staff s
--LEFT join sma_MST_Users u
--ON u.saga = s.id
--WHERE u.saga is NOT null
--order BY s.staff_code

--SELECT s.* FROM BrianWhiteNeos..staff s

--JOIN sma_MST_Users u
--ON u.saga = s.id
--WHERE u.saga is null


--EXCEPT SELECT stf2.*
--FROM BrianWhiteNeos..staff stf2
--JOIN sma_MST_Users smu
--ON stf2.id = smu.saga
  

--SELECT * FROM sma_MST_IndvContacts smic where smic.cinnContactID = 23767

--select *
--from implementation_users iu
--LEFT JOIN sma_MST_IndvContacts smic
--ON smic.cinnContactID = iu.SAContactID
--JOIN BrianWhiteNeos..staff s
--ON s.staff_code = iu.StaffCode
--WHERE iu.StaffCode <> '' AND iu.SAContactID is null



--SELECT * FROM implementation_users iu where iu.StaffCode = ''
-------------------------------------------------------------------------------------------------
