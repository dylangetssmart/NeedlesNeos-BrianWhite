USE BrianWhiteSA
GO

/******************************************
 * FIELD TYPES
 *-------------------------
 * 1	Alpha
 * 5	true/false
 * 7	Date
 * 12	mini-dir picklist
 * 13	Money
 * 14	Name
 * 16	Number
 * 27	Staff/User
 * 29	State
 * 31	Time
 * 33	Value Code
 * 35	Y/N/?
 *****************************************/

IF EXISTS (
		SELECT
			*
		FROM sys.tables
		WHERE name = 'NeedlesUserFields'
			AND type = 'U'
	)
BEGIN
	DROP TABLE NeedlesUserFields
END
-------------------------------------------
--CREATE TABLE NEEDLES USER FIELDS
-------------------------------------------
CREATE TABLE NeedlesUserFields (
	field_id VARCHAR(50)
   ,field_title VARCHAR(30)
   ,
	--column_name varchar(30),
	field_Type INT
   , --varchar(20),
	field_len VARCHAR(10)
   ,mini_Dir VARCHAR(50)
   ,UDFType VARCHAR(30)
   ,DropDownValues VARCHAR(MAX)
)
-------------------------------------------------------------------
--BUILD USER FIELDS PLUS DROP DOWNS FOR UDF DEFINITION PURPOSES
-------------------------------------------------------------------
INSERT INTO NeedlesUserFields
	(
	field_id
   ,field_title
   ,field_Type
   ,field_len
   ,mini_Dir
   ,UDFType
	)
	SELECT
		ucf.id
	   ,field_title
	   ,field_type
	   ,CASE
			WHEN field_Type IN (13, 16)
				THEN CONVERT(VARCHAR, field_len) + ',2'
			ELSE CONVERT(VARCHAR, field_len)
		END
	   ,minidirlistid
	   ,CASE
			WHEN field_Type IN (1, 29, 33, 27)
				THEN 'Text'
			WHEN field_Type = 14
				THEN 'Contact'  --for new SA version
			WHEN field_Type IN (13, 16)
				THEN 'Number'
			WHEN field_Type = 5
				THEN 'CheckBox'
			WHEN field_Type IN (12, 35)
				THEN 'Dropdown'
			WHEN field_Type = 7
				THEN 'Date'
			WHEN field_Type = 31
				THEN 'Time'
			ELSE NULL
		END
	--Select *
	FROM BrianWhiteNeos..[user_case_fields] ucf
--LEFT JOIN BrianWhiteNeos..[mini_dir_list] dl on ucf.minidirlistid = dl.id

-----------------------------------------------------
--CURSOR TO FILL IN DROP DOWN VALUES FOR MINI DIRS
-----------------------------------------------------
DECLARE @miniDir VARCHAR(50)
	   ,@numberCt INT
	   ,@code VARCHAR(30)

DECLARE userFields_cursor CURSOR FOR SELECT
	Mini_Dir
FROM NeedlesUserFields
WHERE ISNULL(Mini_Dir, '') <> ''

OPEN userFields_Cursor
FETCH NEXT FROM userFields_Cursor INTO @miniDir
WHILE @@FETCH_STATUS = 0
BEGIN

SELECT
	IDENTITY(INT, 1, 1) AS Number
   ,gd.code INTO #values
--select *
FROM BrianWhiteNeos..mini_general_dir gd
--JOIN BrianWhiteNeos..mini_dir_list dl on gd.num_assigned = dl.dir_key
WHERE gd.minidirlistid = @miniDir

SET @numberCt = (
	SELECT
		MAX(number)
	FROM #values
)

WHILE @numberCt >= 1
BEGIN

SET @code = (
	SELECT
		code
	FROM #values
	WHERE Number = @numberCt
)

UPDATE NeedlesUserFields
SET DropDownValues =
CASE
	WHEN dropDownValues IS NULL
		THEN @code
	ELSE DropDownValues + '~' + @code
END
WHERE Mini_Dir = @miniDir

SET @numberCt = @numberCt - 1

END

DROP TABLE #values

FETCH NEXT FROM userFields_Cursor INTO @miniDir
END
CLOSE userFields_Cursor;
DEALLOCATE userFields_Cursor;

--------------------------------------------------------
--UPDATE DROPDOWN VALUES WHERE FIELD TYPE = 35 (Y/N/?)
--------------------------------------------------------
UPDATE NeedlesUserFields
SET DropDownValues = 'Y~N~?'
WHERE field_Type = 35

