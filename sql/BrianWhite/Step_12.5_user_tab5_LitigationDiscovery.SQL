USE BrianWhiteSA
GO

/*
select DISTINCT g.code
FROM BrianWhiteNeos..NeosUserTab5 u
JOIN BrianWhiteNeos..mini_general_dir g on g.id = u.[Litigation Document]
*/

IF NOT EXISTS (
		SELECT
			*
		FROM sys.tables t
		JOIN sys.columns c
			ON t.object_id = c.object_id
		WHERE t.name = 'sma_TRN_LitigationDiscovery'
			AND c.name = 'saga'
	)
BEGIN
	ALTER TABLE sma_TRN_LitigationDiscovery
	ADD saga VARCHAR(50)
END
GO

ALTER TABLE sma_TRN_LitigationDiscovery
ALTER COLUMN SAGA VARCHAR(50)
GO
--------------------------------------
--LITIGATION DISCOVERY TYPE
--------------------------------------
INSERT INTO sma_MST_DiscoveryType
	(
	dstsDescription
   ,dstsDescriptionType
	)
	SELECT DISTINCT
		g.code
	   ,g.code
	FROM BrianWhiteNeos..NeosUserTab5 u
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Litigation Document]
	WHERE ISNULL([Litigation Document], '') <> ''
	EXCEPT
	SELECT
		dstsDescription
	   ,dstsDescriptionType
	FROM sma_MST_DiscoveryType
GO

--------------------------------------
--INSERT SERVICE TYPES
--------------------------------------
INSERT INTO sma_MST_ServiceTypes
	(
	sctsCode
   ,sctsDscrptn
	)
	SELECT
		NULL
	   ,'Unknown'
	EXCEPT
	SELECT
		sctsCode
	   ,sctsDscrptn
	FROM sma_MST_ServiceTypes

--sp_help sma_TRN_LitigationDiscovery
--------------------------------------------
--INSERT LITIGATION DISCOVERY
--------------------------------------------
INSERT INTO sma_TRN_LitigationDiscovery
	(
	caseid
   ,EnteredDt
   ,typeid
   ,MethodOfService
   ,ServedByID
   ,ResDescription
   ,DemandOrder
   ,OrderDt
   ,OnDate
   ,OnBeforeDt
   ,WithinDays
   ,FromDt
   ,DtToComply
   ,AppointmentID
   ,RecUserID
   ,ModifyUserID
   ,DtModified
   ,lidnRespondentType
   ,saga
	)
	SELECT DISTINCT
		cas.casnCaseID							   AS caseid
	   ,NULL									   AS EnteredDt
	   ,(
			SELECT
				dstnDiscoveryTypeID
			FROM sma_MST_DiscoveryType
			WHERE dstsDescription = g.Code
		)										   
		AS typeid
	   ,(
			SELECT
				sctnSrvcTypeID
			FROM sma_MST_ServiceTypes
			WHERE sctsDscrptn = 'Unknown'
		)										   
		AS MethodOfService
	   ,NULL									   AS ServedByID
	   ,ISNULL('Filed Date: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Filed Date]), ''), '') + CHAR(13) +
		ISNULL('Note: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Note]), ''), '') + CHAR(13) +
		ISNULL('All Counsel Copied: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[All Counsel Copied]), ''), '') + CHAR(13) +
		ISNULL('Answered Date: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Answered Date]), ''), '') + CHAR(13) +
		ISNULL('Document Name: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Document Name]), ''), '') + CHAR(13) +
		ISNULL('Filing Party: ' + NULLIF(CONVERT(VARCHAR(MAX), ioc.[name]), ''), '') + CHAR(13) +
		ISNULL('Party Receiving: ' + NULLIF(CONVERT(VARCHAR(MAX), iocr.[name]), ''), '') + CHAR(13) +
		ISNULL('Medical Provider: ' + NULLIF(CONVERT(VARCHAR(MAX), iocp.[name]), ''), '') + CHAR(13) +
		ISNULL('Received Date: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Received Date]), ''), '') + CHAR(13) +
		ISNULL('Service Date: ' + NULLIF(CONVERT(VARCHAR(MAX), u.[Service Date]), ''), '') + CHAR(13) +
		''										   AS ResDescription
	   ,   --2000
		1										   AS DemandOrder
	   ,		--1=Demand; 2=Order
		[Service Date]							   AS OrderDt
	   ,CASE
			WHEN u.[Service Date] BETWEEN '1/1/1900' AND '6/6/2079'
				THEN u.[Service Date]
			ELSE NULL
		END										   AS OnDate
	   ,NULL									   AS OnBeforeDt
	   ,NULL									   AS WithinDays
	   ,NULL									   AS FromDt
	   ,CASE
			WHEN u.[Due Date] BETWEEN '1/1/1900' AND '6/6/2079'
				THEN u.[Due Date]
			ELSE NULL
		END										   AS DtToComply
	   ,NULL									   AS AppointmentID
	   ,368										   AS RecUserID
	   ,NULL									   AS ModifyUserID
	   ,NULL									   AS DtModified
	   ,NULL									   AS lidnRespondentType
	   ,'Tab5: ' + CONVERT(VARCHAR(50), tablistid) AS saga
	--select *
	FROM BrianWhiteNeos..NeosUserTab5 u
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Litigation Document]
	JOIN sma_trn_Cases cas
		ON CAS.Neos_saga = CONVERT(VARCHAR(50), u.casesid)
	LEFT JOIN IndvorgContacts_Indexed ioc
		ON ioc.saga_ref = CONVERT(VARCHAR(50), u.[Filing Party])
	LEFT JOIN IndvorgContacts_Indexed iocp
		ON iocp.saga_ref = CONVERT(VARCHAR(50), u.[Medical Provider])
	LEFT JOIN IndvorgContacts_Indexed iocr
		ON iocr.saga_ref = CONVERT(VARCHAR(50), u.[Party Receiving])
	WHERE ISNULL([litigation document], '') <> ''
		OR ISNULL([document name], '') <> ''
GO

--------------------------
--INSERT COMPLIED DATE
--------------------------
INSERT INTO sma_TRN_DiscoveryDepositionRespondents
	(
	DiscoveryID
   ,RespondentID
   ,CSWDt
   ,RecUserID
   ,DtCreated
   ,CSW
	)
	SELECT
		ld.DiscoveryID  AS DiscoveryID
	   ,NULL			AS RespondentID
	   ,[Answered Date] AS CSWDt
	   ,368				AS RecUserID
	   ,GETDATE()		AS DtCreated
	   ,1				AS CSW
	FROM BrianWhiteNeos..NeosUserTab5 u
	JOIN BrianWhiteNeos..mini_general_dir g
		ON g.id = u.[Litigation Document]
	JOIN sma_TRN_LitigationDiscovery ld
		ON ld.saga = 'Tab5: ' + CONVERT(VARCHAR(50), tablistid)
	WHERE ISNULL(u.[Answered Date], '') <> ''
GO