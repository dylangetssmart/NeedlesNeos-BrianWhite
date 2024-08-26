
USE [SANeosBrianWhite]
GO
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

---(0)---
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
			WHERE atcsDscrptn = 'Non-Case Related Appointment'
		)
	FROM (
		SELECT DISTINCT
			[TYPE] AS ActivityType
		FROM [NeosBrianWhite].[dbo].[calendar] CAL
		JOIN [NeosBrianWhite].[dbo].[appointment_type] ap
			ON cal.appointmenttypeid = ap.id
		WHERE ISNULL([TYPE], '') <> ''
			AND ISNULL(CONVERT(VARCHAR(50), cal.casesid), '') = ''
		EXCEPT
		SELECT
			attsDscrptn AS ActivityType
		FROM sma_MST_ActivityType
		WHERE attnActivityCtg = (
				SELECT
					atcnPKId
				FROM sma_MST_ActivityCategory
				WHERE atcsDscrptn = 'Non-Case Related Appointment'
			)
			AND ISNULL(attsDscrptn, '') <> ''
	) A
GO

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
			WHERE AppointmentType = 'Non-Case related Office'
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
								WHERE atcsDscrptn = 'Non-Case Related Appointment'
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
							WHERE atcsDscrptn = 'Non-Case Related Appointment'
						)
						AND attsDscrptn = 'Appointment'
				)
		END							 AS [ActivityTypeID]
	   ,NULL						 AS [CaseID]
	   ,NULL						 AS [LocationContactID]
	   ,NULL						 AS [LocationContactGtgID]
	   ,NULL						 AS [JudgeID]
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
	   ,cal.location				 AS [Address]
	   ,LEFT(CAL.subject, 120)		 AS [Subject]
	   ,NULL
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
	   ,CONVERT(VARCHAR(50), CAL.id) AS [SAGA]
	FROM [NeosBrianWhite].[dbo].[calendar] CAL
	LEFT JOIN [NeosBrianWhite].[dbo].[appointment_type] ap
		ON cal.appointmenttypeid = ap.id
	LEFT JOIN [NeosBrianWhite].[dbo].[appointment_status] stat
		ON cal.appointmentstatusid = stat.id
	WHERE ISNULL(CONVERT(VARCHAR(50), CAL.casesid), '') = ''

------(2)-----
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
	JOIN [NeosBrianWhite].[dbo].[calendar] CAL
		ON APP.saga = CONVERT(VARCHAR(50), CAL.id)
	CROSS APPLY (
		SELECT
			[data]
		FROM dbo.Split(cal.staff, ';')
	) x
	LEFT JOIN sma_MST_IndvContacts ind
		ON ind.cinsGrade = x.data
	WHERE ISNULL(CONVERT(VARCHAR(50), cal.casesid), '') = ''
