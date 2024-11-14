
USE [BrianWhiteSA]
GO
/*
alter table [sma_MST_IndvContacts] disable trigger all
delete from [sma_MST_IndvContacts] 
DBCC CHECKIDENT ('[dbo].[sma_MST_IndvContacts]', RESEED, 0);
alter table [sma_MST_IndvContacts] enable trigger all

alter table [sma_MST_users] disable trigger all
delete from [sma_MST_users] 
DBCC CHECKIDENT ('[sma_MST_users]', RESEED, 0);
alter table [sma_MST_users] enable trigger all

alter table [sma_MST_OrgContacts] disable trigger all
delete from [sma_MST_OrgContacts] 
DBCC CHECKIDENT ('[sma_MST_OrgContacts]', RESEED, 0);
alter table [sma_MST_OrgContacts] enable trigger all
*/


--(0) saga field for needles names_id ---
ALTER TABLE [sma_MST_IndvContacts]
ADD saga_ref VARCHAR(50)
GO

ALTER TABLE [sma_MST_OrgContacts]
ADD saga_ref VARCHAR(50)
GO

ALTER TABLE [sma_MST_IndvContacts]
ALTER COLUMN [cinsNickName] VARCHAR(50)
GO

ALTER TABLE [sma_MST_IndvContacts]
ALTER COLUMN [saga] INT
GO

ALTER TABLE [sma_MST_orgContacts]
ALTER COLUMN [saga] INT
GO
/*
--(0)---
INSERT INTO [sma_MST_Languages] ([lngsLanguageName])
SELECT race_name FROM [BrianWhiteNeos].[dbo].[race] WHERE isnull(race_name,'')<>''
EXCEPT
SELECT [lngsLanguageName] FROM [sma_MST_Languages]
GO
*/

------------------------------------------
--ADD EMPTY / DEFAULT RECORDS
------------------------------------------
IF NOT EXISTS (
		SELECT
			*
		FROM sma_mst_Indvcontacts
		WHERE [cinsFirstName] = 'Staff'
			AND [cinsLastName] = 'Unassigned'
	)
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,'Mr.'
		   ,'Staff'
		   ,''
		   ,'Unassigned'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END

IF NOT EXISTS (
		SELECT
			*
		FROM sma_mst_Indvcontacts
		WHERE [cinsFirstName] = 'Individual'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,'Mr.'
		   ,'Individual'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,'Unknown'
		   ,''
		   ,''
		   ,NULL
END

IF NOT EXISTS (
		SELECT
			*
		FROM sma_mst_Indvcontacts
		WHERE [cinsFirstName] = 'Plaintiff'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		SELECT
			1
		   ,10
		   ,NULL
		   ,''
		   ,'Plaintiff'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END

IF NOT EXISTS (
		SELECT
			*
		FROM sma_mst_Indvcontacts
		WHERE [cinsFirstName] = 'Defendant'
			AND [cinsLastName] = 'Unidentified'
	)
BEGIN
	INSERT INTO [sma_MST_IndvContacts]
		(
		[cinbPrimary], [cinnContactTypeID], [cinnContactSubCtgID], [cinsPrefix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsSuffix], [cinsNickName], [cinbStatus], [cinsSSNNo], [cindBirthDate], [cinsComments], [cinnContactCtg], [cinnRefByCtgID], [cinnReferredBy], [cindDateOfDeath], [cinsCVLink], [cinnMaritalStatusID], [cinnGender], [cinsBirthPlace], [cinnCountyID], [cinsCountyOfResidence], [cinbFlagForPhoto], [cinsPrimaryContactNo], [cinsHomePhone], [cinsWorkPhone], [cinsMobile], [cinbPreventMailing], [cinnRecUserID], [cindDtCreated], [cinnModifyUserID], [cindDtModified], [cinnLevelNo], [cinsPrimaryLanguage], [cinsOtherLanguage], [cinbDeathFlag], [cinsCitizenship], [cinsHeight], [cinnWeight], [cinsReligion], [cindMarriageDate], [cinsMarriageLoc], [cinsDeathPlace], [cinsMaidenName], [cinsOccupation], [saga], [cinsSpouse], [cinsGrade]
		)

		SELECT DISTINCT
			1
		   ,10
		   ,NULL
		   ,''
		   ,'Defendant'
		   ,''
		   ,'Unidentified'
		   ,NULL
		   ,NULL
		   ,1
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,''
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,1
		   ,''
		   ,1
		   ,1
		   ,NULL
		   ,NULL
		   ,''
		   ,''
		   ,NULL
		   ,0
		   ,368
		   ,GETDATE()
		   ,''
		   ,NULL
		   ,0
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL + NULL
		   ,NULL
		   ,''
		   ,NULL
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,''
		   ,NULL
END


------------------------------------------------------------------------------------------------
---------------------------------------BEGIN INSERT USERS---------------------------------------
------------------------------------------------------------------------------------------------

-- Indv Contact Cards for staff
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinsPrefix], [cinsSuffix], [cinsFirstName], [cinsLastName], [cinsHomePhone], [cinsWorkPhone], [cinsSSNNo], [cindBirthDate], [cindDateOfDeath], [cinnGender], [cinsMobile], [cinsComments], [cinnContactCtg], [cinnContactTypeID], [cinnRecUserID], [cindDtCreated], [cinbStatus], [cinbPreventMailing], [cinsNickName], [cinsOccupation], [saga], [cinsGrade],				-- remember the [staff_code]
	[saga_ref]
	)
	SELECT
		iu.Prefix						AS [cinsPrefix]
	   ,iu.Suffix						AS [cinsSuffix]
	   	,iu.SAFirst								as [cinsFirstName]
	,iu.SAMiddle							as [cinsmiddleName]
	 --  ,CASE
		--	WHEN ISNULL(stf.first_name, '') = ''
		--		THEN LEFT(ISNULL(first_name, dbo.get_firstword(full_name)), 30)
		--	ELSE stf.first_name
		--END								AS [cinsFirstName]
	 --  ,CASE
		--	WHEN ISNULL(stf.last_name, '') = ''
		--		THEN LEFT(ISNULL(last_name, dbo.get_lastword(full_name)), 40)
		--	ELSE stf.last_name
		--END								AS [cinsLastName]
	   ,NULL							AS [cinsHomePhone]
	   ,LEFT(phone_number, 20)			AS [cinsWorkPhone]
	   ,NULL							AS [cinsSSNNo]
	   ,NULL							AS [cindBirthDate]
	   ,NULL							AS [cindDateOfDeath]
	   ,CASE s.gender
			WHEN 1
				THEN 1
			WHEN 2
				THEN 2
			ELSE 0
		END								AS [cinnGender]
	   ,LEFT(s.mobile_number, 20)			AS [cinsMobile]
	   ,ISNULL('Supervisor: ' + NULLIF(CONVERT(VARCHAR, s.supervisor), '') + CHAR(13), '') +
		ISNULL('Bar1: ' + NULLIF(CONVERT(VARCHAR, s.Bar1), '') + CHAR(13), '') +
		ISNULL('Bar1 State: ' + NULLIF(CONVERT(VARCHAR, s.Bar_State1), '') + CHAR(13), '') +
		ISNULL('Bar2: ' + NULLIF(CONVERT(VARCHAR, s.Bar2), '') + CHAR(13), '') +
		ISNULL('Bar2 State: ' + NULLIF(CONVERT(VARCHAR, s.Bar_State2), '') + CHAR(13), '') +
		ISNULL('Bar3: ' + NULLIF(CONVERT(VARCHAR, s.Bar3), '') + CHAR(13), '') +
		ISNULL('Bar3 State: ' + NULLIF(CONVERT(VARCHAR, s.Bar_State3), '') + CHAR(13), '') +
		'Works on Cases: ' +
		CASE
			WHEN s.works_on_cases = 1
				THEN 'Yes'
			ELSE 'No'
		END + CHAR(13) +
		''								AS [cinsComments]
	   ,1								AS [cinnContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM sma_MST_OriginalContactTypes
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)								
		AS [cinnContactTypeID]
	   ,368
	   ,s.Date_Created
	   ,1								AS [cinbStatus]
	   ,0
	   ,CONVERT(VARCHAR(15), s.full_name) AS [cinsNickName]
	   ,s.job_title					AS [cinsOccupation]
	   ,NULL							AS [saga]
	   ,s.staff_code					AS [cinsGrade]
	   , -- Remember it to go to sma_MST_Users
		s.id							AS [saga_ref]
	--SELECT *
	--FROM [BrianWhiteNeos].[dbo].[staff] stf
	--LEFT JOIN [BrianWhiteNeos]..[prefix] p
	--	ON stf.prefixid = p.id
	--LEFT JOIN [BrianWhiteNeos]..[suffix] s
	--	ON s.id = stf.suffixid
	FROM [implementation_users] iu
--LEFT JOIN [sma_MST_IndvContacts] ind on iu.StaffCode = ind.cinsgrade
LEFT JOIN [sma_MST_IndvContacts] ind on iu.SAContactID = ind.cinnContactID
LEFT JOIN BrianWhiteNeos..[staff] s on s.staff_code = iu.staffcode
WHERE cinncontactid IS NULL
and SALoginID <> 'aadmin'

GO


-- (3.2) construct [sma_MST_Users]
IF (
		SELECT
			COUNT(*)
		FROM sma_MST_Users
		WHERE usrsLoginID = 'aadmin'
	)
	= 0
BEGIN
	SET IDENTITY_INSERT sma_mst_users ON

	INSERT INTO [sma_MST_Users]
		(
		usrnUserID, [usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState]
		)
		SELECT DISTINCT
			368
		   ,(
				SELECT
					cinnContactID
				FROM sma_mst_Indvcontacts
				WHERE [cinsFirstName] = 'Staff'
					AND cinsLastName = 'Unassigned'
			)
		   ,'aadmin'
		   ,'2/'
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,33
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1
		   ,GETDATE()
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,1

	SET IDENTITY_INSERT sma_mst_users OFF
END

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_MST_Users')
	)
BEGIN
	ALTER TABLE [sma_MST_Users] ADD [saga] [VARCHAR](50) NULL;
END
GO

-- ds 2024-11-13
-- Insert data into sma_MST_Users table from implementation_users table
-- don't create users that already exist
INSERT INTO [sma_MST_Users]
	(
	[usrnContactID], [usrsLoginID], [usrsPassword], [usrsBackColor], [usrsReadBackColor], [usrsEvenBackColor], [usrsOddBackColor], [usrnRoleID], [usrdLoginDate], [usrdLogOffDate], [usrnUserLevel], [usrsWorkstation], [usrnPortno], [usrbLoggedIn], [usrbCaseLevelRights], [usrbCaseLevelFilters], [usrnUnsuccesfulLoginCount], [usrnRecUserID], [usrdDtCreated], [usrnModifyUserID], [usrdDtModified], [usrnLevelNo], [usrsCaseCloseColor], [usrnDocAssembly], [usrnAdmin], [usrnIsLocked], [usrbActiveState], [saga]
	)

	SELECT
		indv.cinnContactID					 AS [usrnContactID]
	   --,CONVERT(VARCHAR(20), staff_code) AS [usrsLoginID]
	   ,stf.saloginid AS [usrsLoginID]
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
	   ,stf.active						 AS [usrbActiveState]
	   --,stf.[id]						 AS [saga]
	   ,CONVERT(VARCHAR(20), STF.staffcode) as saga
	--SELECT *
	--FROM [BrianWhiteNeos].[dbo].[staff] STF
	--JOIN sma_MST_IndvContacts INDV
	--	ON INDV.cinsGrade = STF.staff_code
	--LEFT JOIN [sma_MST_Users] u
	--	ON u.saga = STF.[id]
	--WHERE u.usrsLoginID IS NULL
	FROM implementation_users STF
JOIN sma_MST_IndvContacts INDV
	ON INDV.cinsGrade = STF.staffcode
LEFT JOIN [sma_MST_Users] u
	ON u.saga = CONVERT(VARCHAR(20), STF.staffcode)
WHERE u.usrsLoginID IS NULL
GO

-----------------------------------------------------------

DECLARE @UserID INT

DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT
	usrnUserID
FROM sma_mst_users

OPEN staff_cursor

FETCH NEXT FROM staff_cursor INTO @UserID

SET NOCOUNT ON;
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO sma_TRN_CaseBrowseSettings
	(
	cbsnColumnID, cbsnUserID, cbssCaption, cbsbVisible, cbsnWidth, cbsnOrder, cbsnRecUserID, cbsdDtCreated, cbsn_StyleName
	)
	SELECT DISTINCT
		cbcnColumnID
	   ,@UserID
	   ,cbcscolumnname
	   ,'True'
	   ,200
	   ,cbcnDefaultOrder
	   ,@UserID
	   ,GETDATE()
	   ,'Office2007Blue'
	FROM [sma_MST_CaseBrowseColumns]
	WHERE cbcnColumnID NOT IN (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33)

FETCH NEXT FROM staff_cursor INTO @UserID
END

CLOSE staff_cursor
DEALLOCATE staff_cursor


---- Appendix ----
INSERT INTO Account_UsersInRoles
	(
	user_id, role_id
	)
	SELECT
		usrnUserID AS user_id
	   ,2		   AS role_id
	FROM sma_MST_Users

UPDATE Account_UsersInRoles
SET role_id = 1
WHERE user_id = 368

------------------------------------------------------------------------------------------------
----------------------------------------END INSERT USERS----------------------------------------
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
--------------------------------------BEGIN INSERT CONTACTS-------------------------------------
------------------------------------------------------------------------------------------------
--INDV CONTACTS
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinsPrefix], [cinsSuffix], [cinsFirstName], [cinsMiddleName], [cinsLastName], [cinsHomePhone], [cinsWorkPhone], [cinsSSNNo], [cindBirthDate], [cindDateOfDeath], [cinnGender], [cinsMobile], [cinsComments], [cinnContactCtg], [cinnContactTypeID], [cinnContactSubCtgID], [cinnRecUserID], [cindDtCreated], [cinbStatus], [cinbPreventMailing], [cinsNickName], [cinsPrimaryLanguage], [cinsOtherLanguage], [saga], [saga_ref]
	)
	SELECT
		p.[name]										   AS [cinsPrefix]
	   ,s.[name]										   AS [cinsSuffix]
	   ,CONVERT(VARCHAR(30), N.[first_name])			   AS [cinsFirstName]
	   ,CONVERT(VARCHAR(30), N.[initial])				   AS [cinsMiddleName]
	   ,CONVERT(VARCHAR(40), N.[last_long_name])		   AS [cinsLastName]
	   ,NULL											   AS [cinsHomePhone]
	   ,NULL											   AS [cinsWorkPhone]
	   ,LEFT(N.[ss_number], 20)							   AS [cinsSSNNo]
	   ,CASE
			WHEN (N.[date_of_birth] NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE N.[date_of_birth]
		END												   
		AS [cindBirthDate]
	   ,CASE
			WHEN (N.[date_of_death] NOT BETWEEN '1900-01-01' AND '2079-12-31')
				THEN GETDATE()
			ELSE N.[date_of_death]
		END												   
		AS [cindDateOfDeath]
	   ,CASE
			WHEN N.[gender] = 1
				THEN 1
			WHEN N.[gender] = 2
				THEN 2
			ELSE 0
		END												   AS [cinnGender]
	   ,NULL											   AS [cinsMobile]
	   ,''												   AS [cinsComments]
	   ,1												   AS [cinnContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)												   
		AS [cinnContactTypeID]
	   ,CASE
			WHEN N.[deceased] = 1
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Deceased'
					)
			WHEN EXISTS (
					SELECT
						*
					FROM [BrianWhiteNeos].[dbo].[party] P
					WHERE P.[namesid] = N.[id]
						AND P.incapacitated = 1
				)
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Incompetent'
					)
			WHEN EXISTS (
					SELECT
						*
					FROM [BrianWhiteNeos].[dbo].[party] P
					WHERE P.[namesid] = N.[id]
						AND P.minor = 1
				)
				THEN (
						SELECT
							cscnContactSubCtgID
						FROM [sma_MST_ContactSubCategory]
						WHERE cscsDscrptn = 'Infant'
					)
			ELSE (
					SELECT
						cscnContactSubCtgID
					FROM [sma_MST_ContactSubCategory]
					WHERE cscsDscrptn = 'Adult'
				)
		END												   AS cinnContactSubCtgID
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_Users u
			WHERE u.saga = n.staffcreatedid
		)												   
		AS cinnRecUserID
	   ,n.date_created									   AS cindDtCreated
	   ,1												   AS [cinbStatus]
	   ,			-- Hardcode Status as ACTIVE 
		0												   AS [cinbPreventMailing]
	   ,ISNULL(aka_first, '') + ' ' + ISNULL(aka_last, '') AS [cinsNickName]
	   ,NULL											   AS [cinsPrimaryLanguage]
	   ,NULL											   AS [cinsOtherLanguage]
	   ,NULL											   AS saga
	   ,n.id											   AS [saga_ref]
	--SELECT max(len( isnull(aka_first,'') + ' ' + isnull(aka_last,'') ))
	FROM [BrianWhiteNeos]..[names] N
	LEFT JOIN [BrianWhiteNeos]..[prefix] p
		ON n.prefixid = p.id
	LEFT JOIN [BrianWhiteNeos]..[suffix] s
		ON s.id = n.suffixid
	WHERE N.[person] = 1

-----------------
--ORG CONTACTS
-----------------
INSERT INTO [sma_MST_OrgContacts]
	(
	[consName], [consWorkPhone], [consComments], [connContactCtg], [connContactTypeID], [connRecUserID], [condDtCreated], [conbStatus], [saga], [saga_ref]
	)
	SELECT
		N.[last_long_name] AS [consName]
	   ,NULL			   AS [consWorkPhone]
	   ,ISNULL('AKA: ' + NULLIF(CONVERT(VARCHAR, n.aka_full), '') + CHAR(13), '') +
		''				   AS [consComments]
	   ,2				   AS [connContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [BrianWhiteSA].[dbo].[sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 2
		)				   
		AS [connContactTypeID]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_Users u
			WHERE u.saga = n.staffcreatedid
		)				   
		AS [connRecUserID]
	   ,date_created	   AS [condDtCreated]
	   ,1				   AS [conbStatus]
	   ,		-- Hardcode Status as ACTIVE
		NULL			   AS [saga]
	   ,n.id			   AS [saga_ref]
	--SELECT *
	FROM [BrianWhiteNeos].[dbo].[names] N
	WHERE N.[person] <> 1


------------------------------------------------------------------------------------------------
---------------------------------------END INSERT CONTACTS--------------------------------------
------------------------------------------------------------------------------------------------