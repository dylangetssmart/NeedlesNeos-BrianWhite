USE [BrianWhiteSA]
GO

SET QUOTED_IDENTIFIER ON;
/*
alter table [sma_TRN_CalendarAppointments] disable trigger all
delete from [sma_TRN_CalendarAppointments]
DBCC CHECKIDENT ('[sma_TRN_CalendarAppointments]', RESEED, 0);
alter table [sma_TRN_CalendarAppointments] disable trigger all

alter table [sma_trn_AppointmentStaff] disable trigger all
delete from [sma_trn_AppointmentStaff]
DBCC CHECKIDENT ('[sma_trn_AppointmentStaff]', RESEED, 0);
alter table [sma_trn_AppointmentStaff] disable trigger all
*/

--select * from [BrianWhiteNeos].[dbo].[calendar]

---(0)---
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga'
			AND Object_ID = OBJECT_ID(N'sma_TRN_CalendarAppointments')
	)
BEGIN
	ALTER TABLE [sma_TRN_CalendarAppointments]
	ADD [saga] [VARCHAR](50) NULL;
END
GO

ALTER TABLE sma_TRN_CalendarAppointments
ALTER COLUMN [Address] VARCHAR(300)
GO

----(0)----
IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'CalendarJudgeStaffCourt'
			AND type = 'U'
	)
BEGIN
	DROP TABLE CalendarJudgeStaffCourt
END
GO

SELECT
	CAL.id		   AS CalendarId
   ,CAS.casnCaseID AS CaseID
   ,0			   AS Judge_Contact
   ,0			   AS Staff_Contact
   ,0			   AS Court_Contact
   ,0			   AS Court_Address
   ,0			   AS Party_Contact INTO CalendarJudgeStaffCourt
FROM [BrianWhiteNeos].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CAL.casesid)
WHERE ISNULL(CONVERT(VARCHAR(50), CAL.casesid), '') <> ''

UPDATE CalendarJudgeStaffCourt
SET Judge_Contact = I.cinnContactID
FROM [BrianWhiteNeos].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CAL.casesid)
JOIN [sma_MST_IndvContacts] I
	ON I.saga_ref = CONVERT(VARCHAR(50), CAL.judge_namesid)
	AND ISNULL(CONVERT(VARCHAR(50), CAL.judge_namesid), '') <> ''
WHERE CAL.id = ID
/*
UPDATE CalendarJudgeStaffCourt set Staff_Contact=J.cinnContactID
FROM [BrianWhiteNeos].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS on CAS.Neos_Saga = convert(varchar(50),CAL.casesid)
JOIN [sma_MST_IndvContacts] J on J.cinsGrade = CAL.staff_id and isnull(CAL.staff_id,'')<>'' 
WHERE CAL.id = ID
*/
UPDATE CalendarJudgeStaffCourt
SET Court_Contact = i.cid
   ,Court_Address = i.aid
FROM [BrianWhiteNeos].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CAL.casesid)
JOIN IndvOrgContacts_Indexed I
	ON I.saga_ref = CONVERT(VARCHAR(50), CAL.court_namesid)
	AND ISNULL(CONVERT(VARCHAR(50), CAL.court_namesid), '') <> ''
WHERE CAL.id = ID

UPDATE CalendarJudgeStaffCourt
SET Party_Contact = i.cid
FROM [BrianWhiteNeos].[dbo].[calendar] CAL
JOIN [sma_TRN_Cases] CAS
	ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CAL.casesid)
JOIN IndvOrgContacts_Indexed I
	ON I.saga_ref = CONVERT(VARCHAR(50), CAL.party_namesid)
	AND ISNULL(CONVERT(VARCHAR(50), CAL.party_namesid), '') <> ''
WHERE CAL.id = id

---------------------------------------------
--ACTIVITY TYPES
---------------------------------------------
INSERT INTO [sma_MST_ActivityType]
	(
	attsDscrptn
   ,attnActivityCtg
	)
	SELECT
		A.ActivityType
	   ,(
			SELECT
				atcnPKId
			FROM sma_MST_ActivityCategory
			WHERE atcsDscrptn = 'Case-Related Appointment'
		)
	FROM (
		SELECT DISTINCT
			[TYPE] AS ActivityType
		FROM [BrianWhiteNeos].[dbo].[calendar] CAL
		JOIN [BrianWhiteNeos].[dbo].[appointment_type] ap
			ON cal.appointmenttypeid = ap.id
		WHERE ISNULL([TYPE], '') <> ''
		EXCEPT
		SELECT
			attsDscrptn AS ActivityType
		FROM sma_MST_ActivityType
		WHERE attnActivityCtg = (
				SELECT
					atcnPKId
				FROM sma_MST_ActivityCategory
				WHERE atcsDscrptn = 'Case-Related Appointment'
			)
			AND ISNULL(attsDscrptn, '') <> ''
	) A
GO


ALTER TABLE [sma_TRN_CalendarAppointments] DISABLE TRIGGER ALL
GO

--sp_help [sma_TRN_CalendarAppointments]
----(1)-----
INSERT INTO [sma_TRN_CalendarAppointments]
	(
	[FromDate]
   ,[ToDate]
   ,[AllDayEvent]
   ,[AppointmentTypeID]
   ,[ActivityTypeID]
   ,[CaseID]
   ,[LocationContactID]
   ,[LocationContactGtgID]
   ,[JudgeID]
   ,[Comments]
   ,[StatusID]
   ,[Address]
   ,[Subject]
   ,[RecurranceParentID]
   ,[AdjournedID]
   ,[RecUserID]
   ,[DtCreated]
   ,[ModifyUserID]
   ,[DtModified]
   ,[DepositionType]
   ,[Deponants]
   ,[OriginalAppointmentID]
   ,[OriginalAdjournedID]
   ,[RecurrenceId]
   ,[WorkPlanItemId]
   ,[AutoUpdateAppId]
   ,[AutoUpdated]
   ,[AutoUpdateProviderId]
   ,[saga]
	)
	SELECT
		CASE
			WHEN CAL.[start_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN cal.[start_date]
			ELSE '1900-01-01'
		END							 AS [FromDate]
	   ,CASE
			WHEN CAL.[stop_date] BETWEEN '1900-01-01' AND '2079-06-06'
				THEN cal.stop_date
			ELSE '1900-01-01'
		END							 AS [ToDate]
	   ,cal.[all_Day_event]			 AS [AllDayEvent]
	   ,(
			SELECT
				ID
			FROM [sma_MST_CalendarAppointmentType]
			WHERE AppointmentType = 'Case-related'
		)							 
		AS [AppointmentTypeID]
	   ,CASE
			WHEN ISNULL(ap.[type], '') <> ''
				THEN (
						SELECT
							attnActivityTypeID
						FROM sma_MST_ActivityType
						WHERE attnActivityCtg = (
								SELECT
									atcnPKId
								FROM sma_MST_ActivityCategory
								WHERE atcsDscrptn = 'Case-Related Appointment'
							)
							AND attsDscrptn = ap.[type]
					)
			ELSE (
					SELECT
						attnActivityTypeID
					FROM [sma_MST_ActivityType]
					WHERE attnActivityCtg = (
							SELECT
								atcnPKId
							FROM sma_MST_ActivityCategory
							WHERE atcsDscrptn = 'Case-Related Appointment'
						)
						AND attsDscrptn = 'Appointment'
				)
		END							 AS [ActivityTypeID]
	   ,CAS.casnCaseID				 AS [CaseID]
	   ,MAP.Court_Contact			 AS [LocationContactID]
	   ,2							 AS [LocationContactGtgID]
	   ,MAP.Judge_Contact			 AS [JudgeID]
	   ,ISNULL('party name: ' + NULLIF(CAL.[party_name], '') + CHAR(13), '') +
		ISNULL('short notes: ' + NULLIF(CAL.[short_notes], '') + CHAR(13), '') +
		ISNULL('Location: ' + NULLIF(CAL.[Location], '') + CHAR(13), '') +
		ISNULL('Docket: ' + NULLIF(CAL.[docket], '') + CHAR(13), '') +
		''							 AS [Comments]
	   ,CASE
			WHEN stat.[name] = 'Canceled'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Canceled'
					)
			WHEN stat.[name] = 'Done'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Completed'
					)
			WHEN stat.[name] = 'No Show'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Open'
					)
			WHEN stat.[name] = 'Open'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Open'
					)
			WHEN stat.[name] = 'Postponed'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Adjourned'
					)
			WHEN stat.[name] = 'Rescheduled'
				THEN (
						SELECT
							[StatusId]
						FROM [sma_MST_AppointmentStatus]
						WHERE [StatusName] = 'Adjourned'
					)
			ELSE (
					SELECT
						[StatusId]
					FROM [sma_MST_AppointmentStatus]
					WHERE [StatusName] = 'Open'
				)
		END							 AS [StatusID]
	   ,cal.[Location]				 AS [Address]
	   ,	--200
		LEFT(CAL.[subject], 120)	 AS [Subject]
	   ,	--nvarchar 240
		NULL
	   ,NULL
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), cal.staffcreatedid)
		)							 
		AS [RecUserID]
	   ,CAL.[date_created]			 AS [DtCreated]
	   ,(
			SELECT
				usrnUserID
			FROM sma_mst_users
			WHERE saga = CONVERT(VARCHAR(50), cal.staffmodifiedid)
		)							 
		AS [ModifyUserID]
	   ,cal.[date_created]			 AS [DtModified]
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,NULL
	   ,CONVERT(VARCHAR(50), CAL.id) AS [saga]
	--select max(len(cal.location))
	FROM [BrianWhiteNeos].[dbo].[calendar] CAL
	LEFT JOIN [BrianWhiteNeos].[dbo].[appointment_type] ap
		ON cal.appointmenttypeid = ap.id
	LEFT JOIN [BrianWhiteNeos].[dbo].[appointment_status] stat
		ON cal.appointmentstatusid = stat.id
	JOIN [sma_TRN_Cases] CAS
		ON CAS.Neos_Saga = CONVERT(VARCHAR(50), CAL.casesid)
	JOIN CalendarJudgeStaffCourt MAP
		ON MAP.CalendarId = CONVERT(VARCHAR(50), CAL.id)
	WHERE ISNULL(CONVERT(VARCHAR(50), CAL.casesid), '') <> ''
GO

ALTER TABLE [sma_TRN_CalendarAppointments] ENABLE TRIGGER ALL
GO


----(2)-----
INSERT INTO [sma_trn_AppointmentStaff]
	(
	[AppointmentId]
   ,[StaffContactId]
   ,StaffContactCtg
	)
	SELECT DISTINCT
		APP.AppointmentID
	   ,ind.cinnContactID
	   ,ind.cinnContactCtg
	FROM [sma_TRN_CalendarAppointments] APP
	JOIN [BrianWhiteNeos].[dbo].[calendar] CAL
		ON APP.saga = CONVERT(VARCHAR(50), CAL.id)
	CROSS APPLY (
		SELECT
			[data]
		FROM dbo.Split(cal.staff, ';')
	) x
	LEFT JOIN sma_MST_IndvContacts ind
		ON ind.cinsGrade = x.data
	WHERE ISNULL(CONVERT(VARCHAR(50), cal.casesid), '') <> ''

